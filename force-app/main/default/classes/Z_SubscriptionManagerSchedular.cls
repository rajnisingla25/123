//LCM-49 Create subscription record in Zuora application.
public class Z_SubscriptionManagerSchedular implements schedulable{
    public void execute(SchedulableContext sc) {
        updateZuoraSubscriptions('Pending Update');   
    }
   @future(callout=true)
    Public static void updateZuoraSubscriptions(String ZStatus){        
        Map<Id, Comarketing_Relationship__c> CmMap = new Map<Id, Comarketing_Relationship__c>();
        Map<String, zqu__ProductRatePlanCharge__c> CPQID_rateplan = new Map<String, zqu__ProductRatePlanCharge__c>();
        Map<Id, String> SAccZAccId = new Map<Id, String>();       
        Map<String, Zuora__SubscriptionProductCharge__c> CmSubmap = new Map<String, Zuora__SubscriptionProductCharge__c>();
        Set<Id> Accountids = new Set<Id>();
        Set<Id> parentIds = new Set<Id>();
        Set<Id> CancellationIds = new Set<Id>();
        Map<Id, Comarketing_Relationship__c> ResultMap = new  Map<Id, Comarketing_Relationship__c>();
        for(Comarketing_Relationship__c inloop: [SELECT Action__c,Agent_Account__c, Lender_Cancellation_Date__c,Agent_Cancellation_Date__c, Agent_Account__r.Consolidated_Billing_Flag__c,Agent_Account__r.Billing_Preference__c,CFCB_Asset__r.Product2.ProductCode, 
                                                 CFCB_Asset__r.Credit_Amount__c,CFCB_Asset__r.Line_Type__c ,Agent_Adv_Id__c,Agent_Lender_Asset_Id__c,Agent_Party_Id__c,Agent_Total_Contribution__c,Lenders_Monthly_Contribution__c,Agent_Zuora_Status__c ,Agent_Zuora_Comment__c ,
                                                 Amendment_Description__c,Lender_Asset_Monthly_Contribution__c, Amendment_Effective_Date__c ,Amendment_Reason__c,Cancellation_Reason__c,Cancel_Description__c,CFCB_Asset__c,
                                                 Credit__c, Id,Lender_Account__c, Lender_Account__r.EssentialsStatus__c, Relationship__c ,Lender_Account__r.Consolidated_Billing_Flag__c,Lender_Account__r.Billing_Preference__c, Lender_Zuora_Status__c ,Lender_Zuora_Comment__c ,
                                                 Market__c,Status__c, Payment_Profile__r.PaymentMethodId__c,CFCB_Asset__r.Order_line_item__c, CFCB_Asset__r.Order_Line_Item__r.Credit_amount__c,CFCB_Asset__r.Order_Line_Item__r.Total_credit_amount__c,CFCB_Asset__r.Order_line_item__r.line_type__c  
                                                 FROM Comarketing_Relationship__c 
                                                 WHERE Agent_Zuora_Status__c = :ZStatus OR Lender_Zuora_Status__c =:ZStatus
                                                 LIMiT 20]){ 
                                                     //LCM-97 //LCM-278 added below condition.
                                                    if(inloop.Action__c == 'Cancel' && inloop.CFCB_Asset__r.Order_line_item__c != null && inloop.CFCB_Asset__r.Order_line_item__r.line_type__c =='Cancel' && (inloop.Credit__c ==null || inloop.Credit__c ==0)){
                                                     if(inloop.CFCB_Asset__r.Order_Line_Item__r.Credit_amount__c != null && inloop.CFCB_Asset__r.Order_Line_Item__r.Total_credit_amount__c != null && inloop.CFCB_Asset__r.Order_Line_Item__r.Credit_amount__c > 0 
                                                        && inloop.CFCB_Asset__r.Order_Line_Item__r.Total_credit_amount__c > 0 &&  inloop.CFCB_Asset__r.Order_Line_Item__r.Credit_amount__c != inloop.CFCB_Asset__r.Order_Line_Item__r.Total_credit_amount__c)
                                                     continue;                  
                                                     }                                                        
                                                     if(inloop.Action__c == 'Cancel')
                                                      CancellationIds.add(inloop.Relationship__c);   
                                                     CmMap.put(inloop.Id, inloop);                                                      
                                                     parentIds.add(inloop.Relationship__c);
                                                     Accountids.add(inloop.Agent_Account__c);
                                                     Accountids.add(inloop.Lender_Account__c);
                                                 }
        if(Accountids.size() > 0){
            for(Zuora__CustomerAccount__c inloop: [SELECT Zuora__Account__c,Zuora__Zuora_Id__c 
                                                   FROM Zuora__CustomerAccount__c 
                                                   WHERE Zuora__Account__c IN:Accountids]){
                                                       SAccZAccId.put(inloop.Zuora__Account__c, inloop.Zuora__Zuora_Id__c);
                                                   }
            
            for(zqu__ProductRatePlanCharge__c inloop:[SELECT Id,zqu__ZuoraId__c, CPQID__c,zqu__ProductRatePlan__r.zqu__ZuoraId__c 
                                                      FROM zqu__ProductRatePlanCharge__c
                                                      WHERE zqu__Deleted__c = false]){
                                                          CPQID_rateplan.put(inloop.CPQID__c,inloop);                                  
                                                      }
            if(test.isrunningtest())
                CmSubmap = Z_SubscriptionManagerSchedularTest.CmSubmaptest.clone();
            for(Zuora__SubscriptionProductCharge__c inloop : [SELECT Id,Zuora__ProductRatePlanChargeId__c ,Zuora__Subscription__r.Zuora__Account__r.type ,Zuora__SubscriptionRatePlan__r.Zuora__External_Id__c ,Zuora__Subscription__r.Zuora__Zuora_Id__c, Zuora__Subscription__r.CMRelationshipId__c,Zuora__Type__c , Zuora__Price__c 
                                                              FROM Zuora__SubscriptionProductCharge__c 
                                                              WHERE Zuora__Subscription__r.CMRelationship__c = :CmMap.keyset() 
                                                              AND Zuora__Type__c = 'Recurring' 
                                                              AND Zuora__Subscription__r.Zuora__Status__c = 'Active'] ){
                                                                  
                                                                  String CMid =  inloop.Zuora__Subscription__r.Zuora__Account__r.type != 'Lender Individual'? inloop.Zuora__Subscription__r.CMRelationshipId__c+'Agent': inloop.Zuora__Subscription__r.CMRelationshipId__c+ 'Lender';
                                                                  CmSubmap.put(CMid, inloop);           
                                                              }
            try{
            Z_SubscriptionCallhelper.zuoraApiAccess();
            for(Id inloop: CmMap.keyset()){
                Comarketing_Relationship__c CM = CmMap.get(inloop);                      
                Date Termstartdate = date.today();            
                system.debug('RelationShipId: ' + CM.Id);
                system.debug('@@@@@CM : ' +CM);
                //@@@ Agent @@@@
               Boolean Activaterel = true;
                if(CM.Agent_Zuora_Status__c == ZStatus){
                    Decimal Price = -1*CM.Lender_Asset_Monthly_Contribution__c.setscale(2);                 
                    system.debug('Entered for Agent : ' + CM.Id);
                    String ZuoraComment = 'Send to Z-Billing';
                    
                    if(CM.Action__c == 'Add'&& !CmSubmap.containskey(CM.id + 'Agent')){
                        system.debug('Entered for Agent Add Action : ' + CM.Id);                   
                        if(SAccZAccId.containskey(CM.Agent_Account__c)){                      
                            String ZuoraAccountId = SAccZAccId.get(CM.Agent_Account__c);
                            String CPQID =CM.CFCB_Asset__r.Product2.ProductCode;
                            CPQID = 'LCMCT' + (CM.Agent_Account__r.Billing_Preference__c == 'CC-Direct'? 'PAY' + CPQID: 'INV' + CPQID);     
                            System.debug('CPQID '+ CPQID);
                            Boolean IsinvSeperate = false;
                            if(CPQID_rateplan.containskey(CPQID)){
                                String APRPID = CPQID_rateplan.get(CPQID).zqu__ProductRatePlan__r.zqu__ZuoraId__c;    
                                String APRPCD  =  CPQID_rateplan.get(CPQID).zqu__ZuoraId__c;
                                System.debug('APRPID '+APRPID);
                                 System.debug('APRPCD '+ APRPCD);
                                try{
                                    Z_SubscriptionCallhelper.Z_subscribe(Z_SubscriptionCallhelper.prepareSubscriptionRequest(ZuoraAccountId, String.valueof(CM.Id), APRPID, APRPCD, Price, Termstartdate, '',IsinvSeperate));
                                }catch(exception ex){
                                    ZuoraComment =  ex.getmessage();  
                                } 
                            }else{
                                ZuoraComment =  'Rateplan id not found for CPQID : ' +CPQID;
                            }
                        }else{
                            ZuoraComment =  'Zuora Account Id not found';
                        }
                    }     
                    
                    if(CM.Action__c == 'Amend' || CM.Action__c == 'Cancel'){
                        system.debug('Entered for Agent Amend : ' + CM.Id);
                        if(CmSubmap.containskey(CM.id + 'Agent')){
                            Decimal Creditamount = CM.Credit__c;                        
                            Zuora__SubscriptionProductCharge__c  sub =  CmSubmap.get(CM.id + 'Agent');
                            String SubscriptionId = sub.Zuora__Subscription__r.Zuora__Zuora_Id__c;                        
                            try{
                                System.debug('Price : ' + Price + ' Subprice : '+sub.Zuora__Price__c);
                                if(Price != sub.Zuora__Price__c){
                                    if(CM.Amendment_Effective_Date__c != null){
                                        Date Amendmenteffectivedate = CM.Amendment_Effective_Date__c;
                                        if(Price !=  sub.Zuora__Price__c){  
                                            system.debug('Entered for Agent Priceamendment Amend : ' + CM.Id);
                                            SubscriptionId = Z_SubscriptionCallhelper.amendForUpdateProduct('Update Product', sub.Zuora__SubscriptionRatePlan__r.Zuora__External_Id__c, sub.Zuora__ProductRatePlanChargeId__c, Price, SubscriptionId, Amendmenteffectivedate);                                              
                                        }
                                        
                                    }else{
                                        ZuoraComment = 'Amendement effectivedate is null';  
                                    }
                                }
                                system.debug('@@ inside cancel agent @@' + CM.Action__c + '  '+ZuoraComment);
                                if(CM.Action__c == 'Cancel' && ZuoraComment =='Send to Z-Billing'){
                                    system.debug('@@ inside cancel agent @@');
                                    if(CM.Agent_Cancellation_Date__c != null){
                                        system.debug('Entered for Agent Cancel Amend : ' + CM.Id);                         
                                        Z_SubscriptionCallhelper.createAmendmentforCancel('cancellation Amendment', SubscriptionId , CM.Agent_Cancellation_Date__c);
                                    }else{
                                        ZuoraComment = 'Cancellation Date is null';    
                                    }
                                    system.debug('Exit for Agent Cancel: ' + CM.Id);
                                }
                            }catch(exception ex){
                                ZuoraComment = ex.getmessage(); 
                            }                        
                            system.debug('Exit for Agent Amend: ' + CM.Id);
                        }else{
                            ZuoraComment = 'Subscription Not found'; 
                        }                                  
                    }
                    System.debug(ZuoraComment);
                    String Zuorastatus = ZuoraComment == 'Send to Z-Billing'? 'Success' : 'Error'; 
                    Activaterel = ZuoraComment == 'Send to Z-Billing'? true : false; 
                    Comarketing_Relationship__c CMR = new Comarketing_Relationship__c(Id = CM.Id, Status__c  = CM.Status__c , Agent_Zuora_Status__c = Zuorastatus, Agent_Zuora_Comment__c = ZuoraComment);  
                    ResultMap.put(CM.Id, CMR);
                    system.debug(' Agent Zuora Comment : ' + ZuoraComment);
                    system.debug('Exit for Agent : ' + CM.Id);
                }  
                //@@@ Lender@@@
                if(CM.Lender_Zuora_Status__c == ZStatus){
                    Decimal Price = CM.Lender_Asset_Monthly_Contribution__c.setscale(2);
                    system.debug('Entered for Lender : ' + CM.Id);
                    String ZuoraComment = 'Send to Z-Billing';
                    if(CM.Action__c == 'Add' && !CmSubmap.containskey(CM.id + 'Lender')){
                        // String Paymentmethodid = CM.Payment_Profile__c != null ? 
                        system.debug('Entered for Lender Add Action : ' + CM.Id);                   
                        if(SAccZAccId.containskey(CM.Lender_Account__c)){
                            String ZuoraAccountId = SAccZAccId.get(CM.Lender_Account__c);
                            String CPQID =CM.CFCB_Asset__r.Product2.ProductCode;
                            CPQID = 'LCMCT'  + (CM.Lender_Account__r.Billing_Preference__c == 'CC-Direct'? 'PAY' + CPQID: 'INV' + CPQID);                                                      
                            if(CPQID_rateplan.containskey(CPQID)){
                                String APRPID = CPQID_rateplan.get(CPQID).zqu__ProductRatePlan__r.zqu__ZuoraId__c;    
                                String APRPCD  =  CPQID_rateplan.get(CPQID).zqu__ZuoraId__c;
                                try{
                                    Z_SubscriptionCallhelper.Z_subscribe(Z_SubscriptionCallhelper.prepareSubscriptionRequest(ZuoraAccountId, String.valueof(CM.Id), APRPID, APRPCD, Price, Termstartdate, CM.Payment_Profile__r.PaymentMethodId__c, false));
                                }catch(exception ex){
                                    ZuoraComment  = ex.getmessage();  
                                    system.debug('@@@ ZuoraComment ' +ex);
                                } 
                            }else{
                                ZuoraComment =  'Rateplan id not found for CPQID : ' +CPQID;
                            }
                        }else{
                            ZuoraComment =  'Zuora Account Id not found';
                        }
                    }                
                    if(CM.Action__c == 'Amend' || CM.Action__c == 'Cancel'){
                        system.debug('Entered for Lender Amend : ' + CM.Id);
                        if(CmSubmap.containskey(CM.id + 'Lender')){
                            Decimal creditAmount = CM.Credit__c;                        
                            Zuora__SubscriptionProductCharge__c  sub =  CmSubmap.get(CM.id + 'Lender');
                            String SubscriptionId = sub.Zuora__Subscription__r.Zuora__Zuora_Id__c;                        
                            try{
                                System.debug('Price : ' + Price + ' Subprice : '+sub.Zuora__Price__c);
                                if(Price != sub.Zuora__Price__c || Creditamount > 0){
                                    if(CM.Amendment_Effective_Date__c != null){
                                        Date Amendmenteffectivedate = CM.Amendment_Effective_Date__c;
                                        if(Price !=  sub.Zuora__Price__c){  
                                            system.debug('Entered for Lender Priceamendment Amend : ' + CM.Id);
                                            SubscriptionId = Z_SubscriptionCallhelper.amendForUpdateProduct('Update Product', sub.Zuora__SubscriptionRatePlan__r.Zuora__External_Id__c, sub.Zuora__ProductRatePlanChargeId__c, Price, SubscriptionId, Amendmenteffectivedate);                                              
                                        }
                                        if(creditAmount > 0){
                                            system.debug('Entered for Lender Credit Amend : ' + CM.Id);
                                            String CPQID =  CM.CFCB_Asset__r.Product2.ProductCode;
                                            CPQID = 'LCMCTPAY' + CPQID +'CREDIT';                                           
                                            // CPQID = 'LCM' +(CM.Lender_Account__r.Consolidated_Billing_Flag__c == false?'' + CPQID +'CREDIT':CPQID+'CREDIT');
                                            if(CPQID_rateplan.containskey(CPQID)){
                                                String APRPID = CPQID_rateplan.get(CPQID).zqu__ProductRatePlan__r.zqu__ZuoraId__c;    
                                                String APRPCD  =  CPQID_rateplan.get(CPQID).zqu__ZuoraId__c;
                                                SubscriptionId = Z_SubscriptionCallhelper.amendForCredit('Credit Amendment', APRPID, APRPCD, -1*creditAmount, SubscriptionId, Amendmenteffectivedate);                 
                                            }else{
                                                ZuoraComment =  'Rateplan id not found for CPQID : ' +CPQID;
                                            }
                                            system.debug('Exit for Lender Credit: ' + CM.Id);
                                        }
                                    }else{
                                        ZuoraComment = 'Amendement effectivedate is null';  
                                    }
                                }
                                if(CM.Action__c == 'Cancel' && ZuoraComment =='Send to Z-Billing'){
                                    if(CM.Lender_Cancellation_Date__c != null){
                                        system.debug('Entered for Lender Cancel Amend : ' + CM.Id);                          
                                        Z_SubscriptionCallhelper.createAmendmentforCancel('cancellation Amendment', SubscriptionId , CM.Lender_Cancellation_Date__c);
                                    }else{
                                        ZuoraComment = 'Cancellation Date is null';    
                                    }
                                    system.debug('Exit for Lender Cancel: ' + CM.Id);
                                }
                            }catch(exception ex){
                                ZuoraComment = ex.getmessage(); 
                            }                        
                            system.debug('Exit for Lender Amend: ' + CM.Id);
                        }else{
                            ZuoraComment = 'Subscription Not found'; 
                        }                                  
                    }
                    
                    String Zuorastatus = ZuoraComment == 'Send to Z-Billing'? 'Success' : 'Error'; 
                    Activaterel = ZuoraComment == 'Send to Z-Billing'? Activaterel : false;
                    Decimal creditAmount =  ZuoraComment ==  'Send to Z-Billing'? 0 : CM.Credit__c ;
                    system.debug(' Lender Zuora Comment : ' + ZuoraComment);
                    system.debug('Exit for Lender : ' + CM.Id);     
                    if(Activaterel){
                     CM.Status__c =  CM.Action__c == 'Cancel'?'Cancelled': 'Active';                  
                    }

                      if(ResultMap.containskey(CM.Id)){
                        Comarketing_Relationship__c CML = ResultMap.get(CM.Id);
                        CML.Lender_Zuora_Status__c = Zuorastatus;
                        CML.Lender_Zuora_Comment__c = ZuoraComment;
                        CML.Credit__c = creditAmount;
                        CML.Status__c =  CM.Status__c;
                        ResultMap.put(CM.Id, CML);
                    }else{
                        ResultMap.put(CM.Id, new Comarketing_Relationship__c(Id = CM.Id,Credit__c = creditAmount, Status__c = CM.Status__c, Lender_Zuora_Status__c = Zuorastatus, Lender_Zuora_Comment__c = ZuoraComment)); 
                    }
                    
                }
            }
            }catch(exception ex){
            }
            update ResultMap.values();
            if(parentIds.size()>0){
                try{
                    Set<String> failurIds = new Set<String>();
                    Set<Id> CancellationfailureIds = new Set<Id>();
                    List<Account_Relationship__c> relList = new List<Account_Relationship__c>();
   
                    for (AggregateResult inloop : [SELECT Relationship__c ,Count(ID) FROM Comarketing_Relationship__c WHERE Relationship__c IN: parentIds AND (Agent_Zuora_Status__c != 'Success' OR Lender_Zuora_Status__c != 'Success') GROUP BY Relationship__c limit 1000]) {
                        // integer rcount = Integer.valueOf(inloop.get('expr0'));
                        system.debug('Rel Id '+ string.valueof(inloop.get('Relationship__c')));
                        failurIds.add(string.valueof(inloop.get('Relationship__c')));                    
                    }
                   
                    for (AggregateResult inloop : [SELECT Relationship__c ,Count(ID) FROM Comarketing_Relationship__c WHERE Relationship__c IN: CancellationIds AND Status__c != 'Cancelled' GROUP BY Relationship__c limit 1000]) {
                        // integer rcount = Integer.valueOf(inloop.get('expr0'));
                        system.debug('Rel Id '+ string.valueof(inloop.get('Relationship__c')));
                        CancellationfailureIds.add(string.valueof(inloop.get('Relationship__c')));                      
                    }
                    for(id inloop: parentIds){
                     if(!CancellationfailureIds.contains(inloop) && CancellationIds.contains(inloop)){
                           Account_Relationship__c accRel = new Account_Relationship__c(Id = inloop,Comarketing_Zuora_InProgress__c = false, Comarketing_Status__c = 'Cancelled', Active__c  = false);
                            relList.add(accRel); 
                        }else if(!failurIds.contains(inloop)){
                            Account_Relationship__c accRel = new Account_Relationship__c(Id = inloop,Comarketing_Zuora_InProgress__c = false, Comarketing_Status__c = 'Active');
                            relList.add(accRel);
                        }
                       
                   }
                    update relList;
                }catch(exception ex){
                    System.debug('update Account Rel' + ex);
                }
            }
        }
    }  
    
    /* if(Creditamount > 0){
system.debug('Entered for Agent Credit Amend : ' + CM.Id);
String CPQID =  CM.CFCB_Asset__r.Product2.ProductCode;
CPQID = CM.Agent_Account__r.Billing_Preference__c == 'CC-Direct'? 'PAY' + CPQID: 'INV' + CPQID;            
CPQID = 'LCM' +(CM.Agent_Account__r.Consolidated_Billing_Flag__c == false?'CT' + CPQID +'CREDIT':CPQID+'CREDIT');
if(CPQID_rateplan.containskey(CPQID)){
String APRPID = CPQID_rateplan.get(CPQID).zqu__ProductRatePlan__r.zqu__ZuoraId__c;    
String APRPCD  =  CPQID_rateplan.get(CPQID).zqu__ZuoraId__c;
SubscriptionId = Z_SubscriptionCallhelper.amendForCredit('Credit Amendment', APRPID, APRPCD, Creditamount, SubscriptionId, Amendmenteffectivedate);                 
}else{
ZuoraComment =  'Rateplan id not found for CPQID : ' +CPQID;
}
}*/
}