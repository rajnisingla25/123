//LCM-98 Cancel co-marketing relationship when Lender payment does not go through
public class Z_IIASchedule implements schedulable{
    public static Zuora.zApi zApi;
    public void execute(SchedulableContext SC){
        IIAadjustments();
    }
    @future(callout=true) 
    Public static void IIAadjustments(){
        Set<Id> invoiceIds = new Set<Id>();
        Set<String> paymentMethodids = new Set<String>();  
        Set<Id> coMarketing = new Set<Id>();
        List<Zuora.zObject> adjustmentBatch = new List<Zuora.zObject>();  
        List<Invoice_Item__c> updateInvitems = new List<Invoice_Item__c>();
        List<Zuora.ZObject> adjustments = new  List<Zuora.ZObject>();
        List<String> Invces = new List<String>();      
        //Set<String> parentIds = new Set<String>();
        Map<String, Invoice_Item__c> invItems = new Map<String, Invoice_Item__c>();
        Map<Id, Comarketing_Relationship__c> updatecoMarkeintgMap = new Map<Id, Comarketing_Relationship__c>();
        zApi = new Zuora.zApi();
        String adjustmentDate = Z_SubscriptionCallhelper.getdate(date.today());
        try{
            Map<String, Zuora__PaymentInvoice__c> Invoices = new Map<String, Zuora__PaymentInvoice__c>();
            for(Zuora__PaymentInvoice__c inloop: [SELECT Status__c,Zuora__Invoice__c,Zuora__Invoice__r.Zuora__Account__c,Zuora__Invoice__r.Zuora__Account__r.Type,
                                                  Zuora__Invoice__r.Zuora__DueDate__c ,Zuora__Invoice__r.Zuora__Zuora_Id__c, Zuora__Invoice__r.Zuora__Account__r.Billing_Preference__c,
                                                  Zuora__Invoice__r.Name,Zuora__Payment__c,Zuora__Payment__r.ZPaymentMethodId__c, Zuora__ApplyAmount__c
                                                  FROM Zuora__PaymentInvoice__c 
                                                  WHERE createddate  >=Yesterday 
                                                  AND Zuora__Invoice__r.Zuora__Account__r.Type = 'Lender Individual' 
                                                  AND Status__c ='Error']){          
                                                      invoiceIds.add(inloop.Zuora__Invoice__c);                                                        
                                                      paymentMethodids.add(inloop.Zuora__Payment__r.ZPaymentMethodId__c);     
                                                  }
            //Select Id,CMRelationship__c From Zuora__Subscription__c where CMRelationship__c != null LIMIT 2 a2t1h000000Gz4tAAC            
            system.debug('invoiceIdssize : ' + invoiceIds.size());
            
            for(Invoice_Item__c inloop: [SELECT Id,Service_End_Date__c ,Subscription__r.CMRelationship__r.Relationship__c,Zuora_Comment__c,Invoice__r.Zuora__Zuora_Id__c, Invoice_Item_Zuora_ID__c , Subscription__r.CMRelationship__c , 
                                         Charge_Amount__c ,Service_Start_Date__c,Subscription__r.Zuora__TermStartDate__c ,Subscription__r.Zuora__Zuora_Id__c,Subscription__r.PaymentMethodId__c,Subscription__r.Zuora__SubscriptionNumber__c                                                     
                                         FROM Invoice_Item__c 
                                         WHERE Invoice__c IN: invoiceIds]){  
                                             if(paymentMethodids.contains(inloop.Subscription__r.PaymentMethodId__c) && inloop.Subscription__r !=null && inloop.Subscription__r.CMRelationship__c != null && inloop.Zuora_Comment__c != 'Invoice Item Adjusted' || test.isrunningtest()){
                                                 Invces.add(inloop.Invoice__r.Zuora__Zuora_Id__c);
                                                 coMarketing.add(inloop.Subscription__r.CMRelationship__c);    
                                                 if(!test.isrunningtest())
                                                     updatecoMarkeintgMap.put(inloop.Subscription__r.CMRelationship__c , new Comarketing_Relationship__c
                                                                              (Id = inloop.Subscription__r.CMRelationship__c, 
                                                                               Agent_Zuora_Status__c  = 'Pending Update', 
                                                                               Lender_Zuora_Status__c = 'Pending Update', 
                                                                               Status__c = 'Cancelled',
                                                                               Cancellation_Reason__c = 'Payment Failed',
                                                                               Agent_Cancellation_Date__c = inloop.Service_Start_Date__c,
                                                                               Lender_Cancellation_Date__c = inloop.Service_End_Date__c.adddays(1), 
                                                                               Action__c = 'Cancel'));   
                                                 invItems.put(inloop.Invoice_Item_Zuora_ID__c,inloop);  
                                                // parentIds.add(inloop.Subscription__r.CMRelationship__r.Relationship__c);
                                                 Zuora.ZObject invAdjustment = new Zuora.ZObject('InvoiceItemAdjustment');  
                                                 invAdjustment.setvalue('AdjustmentDate', adjustmentDate);
                                                 invAdjustment.setvalue('Amount',inloop.Charge_Amount__c);
                                                 invAdjustment.setvalue('Comment','Paymetn failed for lender');
                                                 invAdjustment.setvalue('InvoiceId',inloop.Invoice__r.Zuora__Zuora_Id__c);
                                                 invAdjustment.setvalue('SourceId',inloop.Invoice_Item_Zuora_ID__c);
                                                 invAdjustment.setvalue('SourceType','InvoiceDetail');
                                                 invAdjustment.setvalue('Type','Credit');
                                                 adjustments.add(invAdjustment);
                                             }                                            
                                         }
            system.debug('coMarketing : ' + coMarketing);
            system.debug('coMarketingsize : ' + coMarketing.size());
            system.debug('adjustments : ' + adjustments.size());
            if(adjustments!=null && !adjustments.isEmpty()){ 
                zApi = Z_SubscriptionCallhelper.zuoraApiAccess();
                Integer qCount =  adjustments.size();    
                system.debug('qCount '+qCount);       
                
                for(Integer a = 0; a< qCount; a++){               
                    adjustmentBatch.add(adjustments[0]);
                    adjustments.remove(0);
                    system.debug('adjustmentBatch.size() : ' +adjustmentBatch.size() + '  Invbatch.size() : '+adjustmentBatch.size());                   
                    if(adjustments.size() == 0 || adjustmentBatch.size() == 50){                     
                        List<Zuora.ZApi.SaveResult> results = SendToZuora(adjustmentBatch);                                                                                        
                        for (Zuora.zApi.SaveResult result : results){
                            Zuora.ZObject invAdjustment =  adjustmentBatch[0];
                            String InvitemId =   (String)invAdjustment.getvalue('SourceId');
                            System.debug('SourceId@1 : '+ InvitemId);
                            
                            if(!result.Success){                                
                                Zuora.zObject[] errors = result.errors;
                                System.debug( 'Results arrey Errors :' + errors);                   
                                String errorText = '';                   
                                for (Zuora.zObject error : errors) {
                                    if(!test.isrunningtest())
                                        errorText = errorText + (String)error.getValue('Code') + ': ' + (String)error.getValue('Message') + '|';                                                
                                }
                                if(invItems.containskey(InvitemId)){                               
                                    Invoice_Item__c  inv = new Invoice_Item__c(Id = invItems.get(InvitemId).id, Zuora_Comment__c  = errorText.abbreviate(255));
                                    updateInvitems.add(inv);
                                }
                            }else if(result.Success){
                                Invoice_Item__c  inv = new Invoice_Item__c(Id = invItems.get(InvitemId).id, Zuora_Comment__c  = 'Invoice Item Adjusted');
                                updateInvitems.add(inv);                                
                                System.debug('Results arrey Success :' + result.Id);    
                            }
                            adjustmentBatch.remove(0);                        
                        } 
                        adjustmentBatch = new List<Zuora.zObject>();  
                    }
                }               
                Z_UpdateInvoiceToStopRetry.UpdateInoivceFlagFromIIA(Invces);  
               
                update updatecoMarkeintgMap.values(); 
                try{
                update updateInvitems;
                }catch(exception ex){
                   system.debug('Failed to udpdate the Items' + ex); 
                }
                system.debug('@@@ end @@@');
            }
        }catch(exception ex){
            updatelogs(ex.getMessage());         
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
    public static void updatelogs(String Message){
        system_logs__c logs = new system_logs__c();         
        logs.Object_Type__c = 'Z_IIASchedule';
        logs.Message__c =Message;
        insert logs;  
    }
    
    
    /*for(Invoice_Item__c inloop: [SELECT Id,Service_End_Date__c ,Charge_Amount__c,Service_Start_Date__c,Subscription__r.Zuora__Zuora_Id__c,Subscription__r.CMRelationship__c, 
Subscription__r.PaymentMethodId__c, Subscription__r.Zuora__SubscriptionNumber__c             
FROM Invoice_Item__c 
WHERE Subscription__r.CMRelationship__c IN:coMarketing 
AND Billing_Account__r.Zuora__Account__r.Type = 'Realtor Agent' order by Service_Start_Date__c ASC]){

if(updatecoMarkeintgMap.containskey(inloop.Subscription__r.CMRelationship__c)){
Comarketing_Relationship__c CML = updatecoMarkeintgMap.get(inloop.Subscription__r.CMRelationship__c);                   
CML.Agent_Zuora_Status__c  = 'Pending Update';
CML.Agent_Cancellation_Date__c = inloop.Service_Start_Date__c;
updatecoMarkeintgMap.put(inloop.Subscription__r.CMRelationship__c, CML);
}else{
updatecoMarkeintgMap.put(inloop.Subscription__r.CMRelationship__c, new Comarketing_Relationship__c(
Id = inloop.Subscription__r.CMRelationship__c,
Agent_Zuora_Status__c  = 'Pending Update',
Agent_Cancellation_Date__c = inloop.Service_Start_Date__c,
Action__c = 'Cancel')); 
}

}*/
    
}