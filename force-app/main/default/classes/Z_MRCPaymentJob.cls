//CRM-5242
//CRM-5314 Mortgage: Case Management
public class Z_MRCPaymentJob implements schedulable{
    public static Zuora.zApi zApi;
    public void execute(SchedulableContext SC){
        runthePaymentprocess();            
    }
    @future(callout = true)
    public static void runthePaymentprocess(){
        // account balance - assetsbalance  0011h00000KOArjAAH
        //(select Id From Assets),  
        //Fulfillment_Status__c  = Fulfilled       
        Set<String> lenderAcctype = new Set<String>{'Lender Parent','Lender Branch', 'Loan Officer'};
            Set<String> billingPreferences = new Set<String>{'Invoice-Terms'};
                List<Account>  Acts = [Select Id, (select Id, RCM_Payment_Amount__c  From Assets where Status = 'Active' and Fulfillment_Status__c  = 'Fulfilled'), (select Id,Zuora__Balance__c,Zuora__Zuora_Id__c From R00N40000001kyLcEAI__r LIMIT 1), (select Id, SplitPercentage__c , PaymentMethodId__c  From Payment_Profiles__r where SplitPercentage__c = 100) From Account Where Type IN:lenderAcctype and Billing_Preference__c  NOT IN:billingPreferences];
        
        List<Zuora.zObject> Paymentlist = new List<Zuora.zObject>();
        for(Account AC : Acts){            
            Decimal assetsAmt = 0.00;           
            Decimal Amount = 0.00;
            String ZId = '';
            if(AC.R00N40000001kyLcEAI__r.size()>0){
                for(Asset inloop:AC.Assets){
                    assetsAmt += inloop.RCM_Payment_Amount__c ;               
                }
                Amount = assetsAmt + AC.R00N40000001kyLcEAI__r[0].Zuora__Balance__c;                  
                ZId = AC.R00N40000001kyLcEAI__r[0].Zuora__Zuora_Id__c;  
                System.debug('@Amount '+Amount);
                if(Amount>0){
                    for(PaymentProfiles__c  inloop:AC.Payment_Profiles__r){
                        if(inloop.SplitPercentage__c == 100){
                            Zuora.zObject payment = new Zuora.zObject('Payment');
                            payment.setValue('AccountId', zId);
                            // payment.setValue('Amount', paymentAmount);
                            payment.setValue('Comment', 'Create Payment for MRC');
                            payment.setValue('AppliedCreditBalanceAmount', Amount);
                            payment.setValue('EffectiveDate', Zuora.zUtil.getZuoraDateonly(Date.today()));
                            payment.setValue('PaymentMethodId', inloop.PaymentMethodId__c);
                            payment.setValue('ZPaymentMethodId__c', inloop.PaymentMethodId__c);
                            payment.setValue('Type', 'Electronic');
                            payment.setValue('Status', 'Processed');
                            Paymentlist.add(payment);     
                        }
                    } 
                }
            }
        }
        zApi =  Z_RetryPastDueinvoicesSchedule.zuoraApiAccess();
        makePaymentNow(Paymentlist);     
        Datetime dtime = System.now().addMinutes(4);
        String tt = dtime.Second() + ' ' + dtime.Minute() + ' ' + dtime.hour() + ' ' + dtime.day() + ' ' + dtime.Month() + ' ? ' + dtime.year();
        System.schedule('Z_MRCCollectionSchedular', tt, new Z_MRCCollectionSchedular());
    }       
    public static void makePaymentNow(List<Zuora.ZObject> sendlist){
        List<Zuora.zObject> sendPayments = new List<Zuora.zObject>();
        Integer qCount =  sendlist.size();    
        system.debug('qCount '+qCount);               
        for(Integer a = 0; a< qCount; a++){               
            sendPayments.add(sendlist[0]);
            sendlist.remove(0);
            system.debug('sendPayments.size() : ' +sendPayments.size() + '  sendPayments.size() : '+sendPayments.size());                   
            if(sendlist.size() == 0 || sendPayments.size() == 40){                     
                List<Zuora.ZApi.SaveResult> results = SendToZuora(sendPayments);                                                                                        
                for (Zuora.zApi.SaveResult result : results){                                      
                    if(!result.Success){                                
                        Zuora.zObject[] errors = result.errors;
                        System.debug( 'Results arrey Errors :' + errors);                   
                        String errorText = '';                   
                        for (Zuora.zObject error : errors) {
                            if(!test.isrunningtest())
                                errorText = errorText + (String)error.getValue('Code') + ': ' + (String)error.getValue('Message') + '|';                                                
                        }                       
                    }else if(result.Success){                                                     
                        System.debug('Results arrey Success :' + result.Id);    
                    }
                    sendPayments.remove(0);                        
                } 
                sendPayments = new List<Zuora.zObject>();  
            }
        }      
    } 
    public static List<Zuora.ZApi.SaveResult> SendToZuora(List<Zuora.ZObject> sendlist){        
        List<Zuora.ZApi.SaveResult> results = new List<Zuora.ZApi.SaveResult>(); 
        system.debug('Request : ' +sendlist);
        if(!Test.isRunningTest()){
            results.addall(zApi.zCreate(sendlist));                   
            system.debug('Response : ' +results);
        } else {                    
            Zuora.zApi.SaveResult res = new Zuora.zApi.SaveResult();
            res.Success = false;
            Zuora.zObject error = new Zuora.zObject('Error');
            res.errors = new Zuora.zObject[]{error};
                results = new List<Zuora.zApi.SaveResult>{};
                    results.add(res);
        }                
        return results;                      
    }
    
}