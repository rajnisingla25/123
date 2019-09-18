/*
CRM-4721 Modify/ Create the pages for manage billing profile/ manage billing account
CRM-4717 Zuora changes for subscription centric payment
CRM-4351 Accept the payment method at the subscription level.
*/


public class Z_UpdateInvoiceToStopRetry {
    public static Zuora.zApi zApi;
    public static Map<String , Zuora__ZInvoice__c> PayInvmap;
    @future(callout=true)
    public static void UpdateInoivceFlag(String sfdcAccount, String Paymentmethodid){
        Set<String> Invid = new Set<String>();
        PayInvmap = new Map<String, Zuora__ZInvoice__c>();
        List<Zuora__PaymentInvoice__c> PayInv =  [SELECT Status__c,Zuora__Invoice__r.Id,Zuora__Invoice__r.Zuora__Zuora_Id__c,Zuora__Invoice__c,Zuora__Invoice__r.Zuora__Account__c,Zuora__Invoice__r.Zuora__Account__r.Billing_Preference__c,
                                                  Zuora__Payment__c, Zuora__ApplyAmount__c 
                                                  FROM Zuora__PaymentInvoice__c                     
                                                  WHERE Zuora__Invoice__r.Zuora__Account__c  =:sfdcAccount 
                                                  AND Zuora__Invoice__r.Zuora__Balance2__c > 1 
                                                  AND Zuora__Payment__r.ZPaymentMethodId__c =:PaymentmethodId 
                                                  AND Status__c = 'Processed'];
        system.debug('PayInv.size() : ' +PayInv.size());
        for(Zuora__PaymentInvoice__c inloop: PayInv){
            Invid.add(inloop.Zuora__Invoice__r.Zuora__Zuora_Id__c); 
            Zuora__ZInvoice__c  nn = new Zuora__ZInvoice__c (Id = inloop.Zuora__Invoice__c, DoNotRetry__c = 'Error');  
            PayInvmap.put(inloop.Zuora__Invoice__r.Zuora__Zuora_Id__c,nn);
            
        }             
        List<String> sendlist = new List<String>(Invid);  
        UpdateInvoiceflag(sendlist);
    }
    @future(callout=true)
    public static void UpdateInoivceFlagFromPage(String sfdcAccount, Set<String> overridingpayids){
        Set<String> Invid = new Set<String>();
        PayInvmap = new Map<String, Zuora__ZInvoice__c>();
        List<Zuora__PaymentInvoice__c> PayInv =  [SELECT Status__c,Zuora__Invoice__r.Id,Zuora__Invoice__r.Zuora__Zuora_Id__c,Zuora__Invoice__c,Zuora__Invoice__r.Zuora__Account__c,Zuora__Invoice__r.Zuora__Account__r.Billing_Preference__c,
                                                  Zuora__Payment__r.ZPaymentMethodId__c , Zuora__ApplyAmount__c 
                                                  FROM Zuora__PaymentInvoice__c                     
                                                  WHERE Zuora__Invoice__r.Zuora__Account__c  =:sfdcAccount 
                                                  AND Zuora__Invoice__r.Zuora__Balance2__c > 1 
                                                  AND Status__c = 'Processed' 
                                                  AND Zuora__Payment__r.ZPaymentMethodId__c IN :overridingpayids ];
        system.debug('PayInv.size() : ' +PayInv.size());        
        for(Zuora__PaymentInvoice__c inloop: PayInv){
            if(overridingpayids.contains(inloop.Zuora__Payment__r.ZPaymentMethodId__c)){ 
                Invid.add(inloop.Zuora__Invoice__r.Zuora__Zuora_Id__c); 
                Zuora__ZInvoice__c  nn = new Zuora__ZInvoice__c (Id = inloop.Zuora__Invoice__c, DoNotRetry__c = 'Error');  
                PayInvmap.put(inloop.Zuora__Invoice__r.Zuora__Zuora_Id__c,nn);
            }
        }             
        List<String> sendlist = new List<String>(Invid);  
        UpdateInvoiceflag(sendlist);
    }
    //LCM-98 Cancel co-marketing relationship when Lender payment does not go through
    public static void UpdateInoivceFlagFromIIA(List<String> sendlist){
        PayInvmap = new Map<String, Zuora__ZInvoice__c>();
        UpdateInvoiceflag(sendlist);
    }
    Public static void UpdateInvoiceflag(List<String> sendlist){
        Zuora.zApi zApi = zuoraApiAccess(); 
        List<Zuora.zObject> Invbatch = new List<Zuora.zObject>();           
        if(sendlist!=null && !sendlist.isEmpty()){                        
            Integer qCount =  sendlist.size();    
            system.debug('qCount '+qCount);           
            for(Integer a = 0; a< qCount; a++){               
                Zuora.ZObject updatesubscription = new Zuora.ZObject('Invoice');
                updatesubscription.setValue('Id', sendlist[0]);
                updatesubscription.setValue('DoNotRetry__c', 'True');
                Invbatch.add(updatesubscription);
                sendlist.remove(0);
                // system.debug('sendlist.size() : ' +sendlist.size() + '  Invbatch.size() '+Invbatch.size());
                if(sendlist.size() == 0 || Invbatch.size() == 50){                     
                    SendtoZuora(Invbatch); 
                    Invbatch = new List<Zuora.zObject>();                     
                }              
            }
            
            If(PayInvmap.size()>0){
                update PayInvmap.values();
            }
            
        }
    }
    public static void SendtoZuora(List<Zuora.zObject> Invbatch){
        List<Zuora.zApi.SaveResult> results = new List<Zuora.zApi.SaveResult>();
        List<Zuora.ZApi.SaveResult> updatesubResults = new List<Zuora.ZApi.SaveResult>();
        try{
            system.debug('Request : ' +Invbatch);
            if(!Test.isRunningTest()){
                results.addall(zApi.zUpdate(Invbatch));                   
                system.debug('Response : ' +results);
            } else {                
                Zuora.zApi.SaveResult res = new Zuora.zApi.SaveResult();
                res.Success = false;
                Zuora.zObject error = new Zuora.zObject('Error');
                res.errors = new Zuora.zObject[]{error};
                    results = new List<Zuora.zApi.SaveResult>{};
                        results.add(res);
            }
            
            String ErrorMessage = '';
            Boolean errorstatus = false;                          
            for (Zuora.zApi.SaveResult result : results){
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
                    if(PayInvmap.containskey(result.Id)){
                        PayInvmap.remove(result.Id); 
                    }
                    //  System.debug('Results arrey Success :' + result.Id); 
                }
            }
            
        } catch(Exception e){
            
            String ErrorMessage = e.getMessage()+' Stacktrace: '+e.getStackTraceString();             
            Boolean ErrorStatus = true;             
            
            // updateSystemLogs(ErrorStatus,ErrorMessage);
            return;
        }
    } 
    public static Zuora.ZApi zuoraApiAccess(){
        system.debug('Login');      
        zApi = new Zuora.ZApi();
        try {
            Zuora.ZApi.LoginResult loginResult = (!Test.isRunningTest()) ? zApi.zLogin() : new Zuora.ZApi.LoginResult();  
        } catch (Exception ex) {
            System.debug(' Login to Zuora failed. Message: '+ex.getMessage()+' Stacktrace: '+ex.getStackTraceString());
            throw ex;
        }
        return zApi;
    }
    
}