//CRM-1935 Retry the Past due invoices if Respective payment method is succeeded under Account  

public class Z_RetryPastDueinvoicesSchedule implements schedulable{
    public static Zuora.zApi zApi;
    public static Boolean inloop = true;
    public void execute(SchedulableContext SC){
    RunthePaymentProcess();
    }
     @future(callout=true)
      public static void RunthePaymentProcess(){
          //CRM-3642 Exclude Collections accounts From Job. addd collection hold condion on query.
          List<Zuora__Payment__c> Paymentsprocessed = [Select Id, Split__c, ZPaymentMethodId__c, Zuora__Account__c,Zuora__BillingAccount__c, Zuora__BillingAccount__r.Zuora__Zuora_Id__c From Zuora__Payment__c where Zuora__Status__c = 'Processed' and CreatedDate >=yesterday and Zuora__BillingAccount__r.Past_Due_Balance__c > 0 and Zuora__Account__r.Collections_Hold__c =false];
        Set<Id> Billid = new Set<Id>();
        Set<Id> Accid = new Set<Id>();
        Map<String , Zuora__Payment__c> Zidpay = new Map<String , Zuora__Payment__c>();
        if(Paymentsprocessed != null && !Paymentsprocessed.isEmpty()){
            for(Zuora__Payment__c inloop : Paymentsprocessed){
                Billid.add(inloop.Zuora__BillingAccount__c); 
                Accid.add(inloop.Zuora__Account__c);
                Zidpay.put(inloop.ZPaymentMethodId__c, inloop);
            }
            
           /* List<PaymentProfiles__c> paymentprofile = [Select id, PaymentMethodId__c, SplitPercentage__c, BillingAccountId__c,Account__c From PaymentProfiles__c where Account__c IN:Accid and SplitPercentage__c > 0];     
            Map<String , PaymentProfiles__c> Zidsplit = new Map<String , PaymentProfiles__c>();
            for(PaymentProfiles__c inloop : paymentprofile){
                system.debug('Paymentprofile Z Id' + inloop.PaymentMethodId__c);
                Zidsplit.put(inloop.PaymentMethodId__c ,inloop);                
            }*/
           
            List<Zuora__ZInvoice__c> InvoicesPastdue1 = new List<Zuora__ZInvoice__c>();
            InvoicesPastdue1  = [Select Id, Zuora__Account__c,  Zuora__Balance2__c, Zuora__TotalAmount__c,Zuora__BillingAccount__r.Zuora__Zuora_Id__c,Zuora__Zuora_Id__c,Name,(Select Id,Zuora__Invoice__c,Split_Percentage__c, Zuora__Payment__r.ZPaymentMethodId__c, Status__c From Zuora__PaymentInvoices__r where Split_Percentage__c >0 order by createddate ASC) From Zuora__ZInvoice__c where Zuora__Account__c IN :Accid and Invoice_Status__c = 'Past Due' and Zuora__Balance2__c>0];
            Map<String , Zuora__PaymentInvoice__c> payinvmap = new Map<String , Zuora__PaymentInvoice__c>();
            Map<Id , Zuora__ZInvoice__c> Invmap = new Map<Id ,Zuora__ZInvoice__c>();
             Map<Id , Zuora__PaymentInvoice__c> InvSplit = new Map<Id , Zuora__PaymentInvoice__c>();
            //Set<String> payIdProcessed = new Set<String>();
            Set<String> payInvIdProcessed = new Set<String>();
            Set<Id> temppay1;
            Map<String ,Set<Id>> PayInv = new Map<String ,Set<Id>>();
            if(InvoicesPastdue1!= null && !InvoicesPastdue1.isEmpty()){
                for(Zuora__ZInvoice__c inloop : InvoicesPastdue1){
                    system.debug('inloop : ' +inloop.Name);
                    Invmap.put(inloop.Id , inloop);
                    for(Zuora__PaymentInvoice__c inloop2 : inloop.Zuora__PaymentInvoices__r){
                        if(inloop2.Status__c == 'Processed' && inloop2.Zuora__Payment__r.ZPaymentMethodId__c!= null){
                            String Paymethod =  inloop.Id+inloop2.Zuora__Payment__r.ZPaymentMethodId__c;
                            system.debug('Paymethod : ' +Paymethod);
                            payInvIdProcessed.add(Paymethod);
                            //payIdProcessed.add(inloop2.Zuora__Payment__r.ZPaymentMethodId__c);
                            }else if(inloop2.Zuora__Payment__r.ZPaymentMethodId__c!= null && inloop2.Status__c == 'Error'){
                            if(PayInv.containskey(inloop2.Zuora__Payment__r.ZPaymentMethodId__c)){
                                temppay1 = PayInv.get(inloop2.Zuora__Payment__r.ZPaymentMethodId__c);
                                }else{
                                temppay1 = new Set<Id>();
                            }
                            temppay1.add(inloop2.Zuora__Invoice__c);
                            PayInv.put(inloop2.Zuora__Payment__r.ZPaymentMethodId__c, temppay1);
                            if(inloop2.Split_Percentage__c !=null){
                               InvSplit.put(inloop.Id,inloop2);

                            }
                        }
                    }
                }
                List<Zuora.zObject> objs = new List<Zuora.zObject>();
                for(String inloop : PayInv.keyset()){
                    system.debug('payinv : ' +inloop);
                    List<Zuora.zObject> invoicePayments = new List<Zuora.zObject>();
                    Zuora.zObject ip;
                    Decimal totalamount = 0;
                    Zuora.zObject payment = new Zuora.zObject('Payment');                    
                    for(Id inloop2 : PayInv.get(inloop)){
                        payment.setValue('AccountId', Invmap.get(inloop2).Zuora__BillingAccount__r.Zuora__Zuora_Id__c);
                        if(payInvIdProcessed.Contains(inloop2+inloop)){                     
                            system.debug('payInvIdProcessed ' + inloop2+inloop);
                            continue;
                        }
                        if(Zidpay.containskey(inloop) && InvSplit.containskey(inloop2)){
                            //if(Zidsplit.containskey(inloop)){
                            system.debug('InviceIdd ' + inloop2);
                            ip = new Zuora.zObject('InvoicePayment');
                            Decimal payAmount = ((InvSplit.get(inloop2).Split_Percentage__c*Invmap.get(inloop2).Zuora__TotalAmount__c)/100).setscale(2);
                            system.debug('payAmount' + payAmount);
                            Decimal balamount  = payAmount >= Invmap.get(inloop2).Zuora__Balance2__c ? Invmap.get(inloop2).Zuora__Balance2__c : payAmount;
                            system.debug('balamount' + balamount);
                            ip.setValue('Amount', balamount);
                            system.debug('Invoice amount '+ balamount);
                            ip.setValue('InvoiceId', Invmap.get(inloop2).Zuora__Zuora_Id__c);                  
                            invoicePayments.add(ip);
                            system.debug('Invoice Id ' +inloop2);
                            totalamount+= balamount;
                        }
                    }
                    if(invoicePayments.isEmpty())
                    continue;
                    //payment.setValue('AccountId', Zidpay.get(inloop).Zuora__BillingAccount__r.Zuora__Zuora_Id__c);
                    payment.setValue('ZPaymentMethodId__c', inloop);
                    payment.setValue('Comment', 'Creating payment with Sfdc payment job');          
                    payment.setValue('EffectiveDate', Zuora.zUtil.getZuoraDateonly(Date.today()));
                    payment.setValue('PaymentMethodId', inloop);
                    payment.setValue('Type', 'Electronic');    
                    payment.setValue('Status', 'Processed');
                    payment.setValue('OneTimePayment__c', 'True');                              
                    system.debug('[TP]============> Invoice Payments: ' + invoicePayments);
                    Zuora.zObject invoicePaymentData = new Zuora.zObject('InvoicePaymentData');
                    invoicePaymentData.setValue('InvoicePayment', invoicePayments);
                    payment.setValue('InvoicePaymentData', invoicePaymentData);
                    payment.setValue('Amount', totalamount);
                    objs.add(payment);                                              
                }
                zApi = zuoraApiAccess();
                List<Zuora.zApi.SaveResult> result = new List<Zuora.zApi.SaveResult>();
                makePaymentNow(objs, result);
                }else{
                String Message = 'Number Invoicesrecords found is Zero';
                Boolean errorstatus =false; 
                updateSystemLogs(ErrorStatus,Message);
                return; 
            }
            }else{
            String Message = 'Number paymentprocessedrecords found is Zero';
            Boolean errorstatus =false; 
            updateSystemLogs(ErrorStatus,Message);
            return;
        }      
    }
    public static void makePaymentNow(List<Zuora.zObject> sendlist, List<Zuora.zApi.SaveResult> results){
        system.debug('Payemnts Size :' +sendlist.size());
        for(Zuora.zObject inloop : sendlist) {              
            system.debug('Payment with each payment method :' +inloop );
        }        
        List<Zuora.zObject> paybatch = new List<Zuora.zObject>();           
        if(sendlist!=null && !sendlist.isEmpty()){              
            Integer qCount = (sendlist.size() > 40 ? 40: sendlist.size());                                                
            for(Integer a = 0; a<qCount; a++){
                paybatch.add(sendlist[0]);
                sendlist.remove(0);
            }
            try{
                system.debug('Request : ' +paybatch);
                if(!Test.isRunningTest()){
                results.addall(zapi.zcreate(paybatch));
                system.debug('Response : ' +results);
                } else {
                Zuora.zApi.SaveResult res = new Zuora.zApi.SaveResult();
                res.Success = false;
                Zuora.zObject error = new Zuora.zObject('Error');
                res.errors = new Zuora.zObject[]{error};
                results = new List<Zuora.zApi.SaveResult>{};
                results.add(res);
                }
                makePaymentNow(sendlist ,results);           
                String ErrorMessage = '';
                Boolean errorstatus = false;                
                if(inloop){
                    for (Zuora.zApi.SaveResult result : results){
                        inloop = false;
                        if(!result.Success){                            
                            Zuora.zObject[] errors = result.errors;
                            System.debug('Results arrey Errors :' + errors);                   
                            String errorText = '';                   
                            for (Zuora.zObject error : errors) {
                                errorText = errorText + (String)error.getValue('Code') + ': ' + (String)error.getValue('Message') + '|';                        
                            }
                            errorstatus=true;
                            ErrorMessage += errorText + '$';
                            System.debug('Results :' + ErrorMessage);                       
                            }else if(result.Success){
                            System.debug('Results arrey Success :' + result.Id);    
                        }
                    }
                    if(errorstatus == true){
                        updateSystemLogs(errorstatus, ErrorMessage);
                        return;
                    }
                }
                } catch(Exception e){
                String ErrorMessage ='Exception Occured While making payments Exception Message: '+e.getMessage()+' Stacktrace: '+e.getStackTraceString();             
                Boolean ErrorStatus = true;             
                updateSystemLogs(ErrorStatus,ErrorMessage);
                return;
            }
        }            
    }
    public static void updateSystemLogs(Boolean status, String message){
        system.debug('Entered into System Logs : ' + message);
        system_logs__c logs = new system_logs__c();      
        logs.Object_Type__c = 'paymentfailed';
        logs.Message__c =message;
        insert logs;
    }
    public static Zuora.ZApi zuoraApiAccess(){
        system.debug('@@@###Login');
        final String FUNC_STR = 'zuoraApiAccess: ';
        zApi = new Zuora.ZApi();
        try {
            Zuora.ZApi.LoginResult loginResult = (!Test.isRunningTest()) ? zApi.zLogin() : new Zuora.ZApi.LoginResult();  
            } catch (Exception ex) {
            System.debug(FUNC_STR+' Login to Zuora failed. Message: '+ex.getMessage()+' Stacktrace: '+ex.getStackTraceString());
            throw ex;
        }
        return zApi;
    }
}