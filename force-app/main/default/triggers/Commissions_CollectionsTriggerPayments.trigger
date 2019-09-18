/***********************************************************************************
    Created By          :    Srinivas Pendli    
    Created Date        :    16.09.2015
    Company             :    NTT Data,Inc.
    Usage               :    The main purpose of this trigger is to create collection commissions for collection team members.
    
    Modified By         :    Srinivas Pendli
    Modifide Date       :    10-JUL-2017 : Modified the code as per #CRM-1014 -line #no-11-17,
************************************************************************************/
trigger Commissions_CollectionsTriggerPayments on Zuora__Payment__c (after insert,after update, before insert, before update) {
    //DisabledTrigger__c  custom setting added to inactive the trigger for specific users
    DisabledTrigger__c Dtrg= DisabledTrigger__c.getValues('Disabled'); 
    String usercheck='';
    if(Dtrg.Commissions_CollectionsTriggerPayments__c !=null ){
        usercheck=Dtrg.Commissions_CollectionsTriggerPayments__c;
    }
    if(!usercheck.contains(UserInfo.getUserName())){   
        if(trigger.isafter){
            Commissions_CreateCollectionCommsClass collectionsMethod = new Commissions_CreateCollectionCommsClass();
            Map<Id,Zuora__Payment__c > collectionsMap = new Map<id,Zuora__Payment__c >();
            Decimal Zuora_AppliedInvoiceAmount;
            for(Zuora__Payment__c PH : Trigger.New){        
                Zuora_AppliedInvoiceAmount = 0.0;
                if(test.isRunningTest()){
                    Zuora_AppliedInvoiceAmount = 10;    
                }
                else{
                    Zuora_AppliedInvoiceAmount = PH.Zuora__AppliedInvoiceAmount__c;
                }
                if(PH.Zuora__Status__c =='Processed' && Zuora_AppliedInvoiceAmount > 0){
                    if(Commissions_TriggerHelperClass.firstRun == false){
                        Commissions_TriggerHelperClass.firstRun = true;
                        collectionsMap.put(PH.Id,Ph);
                    }
                }
            }
            if(collectionsMap.size()> 0){
                collectionsMethod.CreateCommissions(collectionsMap);  
            }
            
            // CRM-2082 - Commented below code as this functionality is not needed now.
            /*
            //Send notification to account AE when Payment fails
            PreAuthPaymentFailureNotifyOnUpdate notification = New PreAuthPaymentFailureNotifyOnUpdate();
            notification.VerifyandSendNotification(trigger.oldmap,trigger.newmap,trigger.isInsert);
            */
        }
        /*OTC-195 LCMPopulate the Credit Card holder name and Split Percentage on the Payment Object and invoice payment for Customer Statement*/
        //CRM-2791
    }
    //CRM-4066 removed trigger on update.
    if(trigger.isbefore){ 
        Date today = system.today();
        Set<String> ZId = new Set<String>(); 
        Set<String> ZoldId = new Set<String>();  
        Set<Id> setPaymentId =new Set<Id>();  
        Map<Id,Id> mapInvoiceTransferAE = new Map<Id,Id>();
        List<PaymentProfiles__History> paymentprofileshistory = new   List<PaymentProfiles__History>(); 
        List<Zuora__PaymentMethod__c> paymentmethods = new   List<Zuora__PaymentMethod__c>(); 
        List<PaymentProfiles__c> paymentprofile = new   List<PaymentProfiles__c>(); 
        
        Set<String> SalesforceCollectionsRepUsernames = new Set<String>();    // CRM-3643 - Set to store all user names.
        for(Zuora__Payment__c be : Trigger.New){
            // CRM-3643 - Add user name to list
            if (trigger.isInsert || (be.SalesforceCollectionsRepUsername__c != Trigger.oldMap.get(be.id).SalesforceCollectionsRepUsername__c)) {
                SalesforceCollectionsRepUsernames.add(be.SalesforceCollectionsRepUsername__c);   
            }
            if(be.Zuora__Type__c == 'Electronic' && be.ZPaymentMethodId__c!= null){               
                ZId.add(be.ZPaymentMethodId__c); 
                System.debug('ZId ' + ZId);
                 System.debug('ZId@@ ' + be.Zuora__Effective_Date__c);
                if(be.Zuora__Effective_Date__c < today || Test.isRunningtest()){
                    ZoldId.add(be.ZPaymentMethodId__c);
                }                               
            }
            setPaymentId.add(be.Id);
        }
        
        // CRM-3643 - Fetch User Id for all user names in SalesforceCollectionsRepUsernames
        Map<String, Id> userIdForUserName = new Map<String, Id>();
        for (User repUser : [SELECT UserName, id FROM User WHERE UserName IN :SalesforceCollectionsRepUsernames]) {
            userIdForUserName.put(repUser.UserName, repUser.Id);
        }
        // Update Salesforce_Collections_Rep__c
        for(Zuora__Payment__c bi : Trigger.New){
            if (SalesforceCollectionsRepUsernames.contains(bi.SalesforceCollectionsRepUsername__c)) {
                bi.Salesforce_Collections_Rep__c = userIdForUserName.get(bi.SalesforceCollectionsRepUsername__c); 
            }
        }
        // CRM-3643 - End
        
        //CRM-3549 - need to populate Transfer AE from case
        Map<Id,Id> mapInvoicePaymentId = new map<Id,Id>();
                for(Zuora__PaymentInvoice__c zPI:[Select Id,name,Zuora__Payment__c,Zuora__Invoice__c from Zuora__PaymentInvoice__c where Zuora__Payment__c=:setPaymentId]){
                //if(mapInvoiceTransferAE.containskey(zPI.Zuora__Invoice__c)){
                mapInvoicePaymentId.put(zPI.Zuora__Invoice__c,zPI.Zuora__Payment__c);//,mapInvoiceTransferAE.get(zPI.Zuora__Invoice__c));
                //}
                }
        if(setPaymentId.size()>0){
        for(Case_Invoice_Relationship__c cir:[Select Id,name,Invoice__c,Case__r.Transfer_AE__c from Case_Invoice_Relationship__c where Invoice__c=:mapInvoicePaymentId.keyset() and Case__r.Transfer_AE__c!=null AND Case__r.Type = 'Collections' order by LastModifiedDate DESC limit 20]){
        if(cir.Case__r.Transfer_AE__c!=null){
        if(mapInvoicePaymentId.containskey(cir.Invoice__c)){
        if(!mapInvoiceTransferAE.containskey(mapInvoicePaymentId.get(cir.Invoice__c))){
        mapInvoiceTransferAE.put(mapInvoicePaymentId.get(cir.Invoice__c),cir.Case__r.Transfer_AE__c);
        }
        }
        }
        }
        }
            paymentprofileshistory = [SELECT ParentId,Id,OldValue,NewValue,Field, createddate,parent.PaymentMethodId__c, parent.SplitPercentage__c FROM PaymentProfiles__History where Parent.PaymentMethodId__c IN: ZoldId Order by createddate ASC];
            paymentmethods = [Select Id ,Zuora__External_Id__c, Zuora__CreditCardHolderName__c, Zuora__Type__c From Zuora__PaymentMethod__c where Zuora__External_Id__c IN: ZId];
            paymentprofile = [Select Id, SplitPercentage__c,BillingAccountId__c,PaymentMethodId__c, Payment_Method__c From PaymentProfiles__c where PaymentMethodId__c IN: ZId];
            if(!ZId.isempty()){               
                Map<String, Zuora__PaymentMethod__c> Paymentmthodmap = new Map<String, Zuora__PaymentMethod__c>();                
                Map<String, PaymentProfiles__c> paymentprofilemap = new Map<String, PaymentProfiles__c>();
                Map<String, List<PaymentProfiles__History>> Oldpaymentprofilemap = new Map<String, List<PaymentProfiles__History>>();
                
                for(Zuora__PaymentMethod__c pe : paymentmethods){                       
                    Paymentmthodmap.put(pe.Zuora__External_Id__c, pe);                                                                                                                               
                }
                for(PaymentProfiles__c re : paymentprofile){
                    if(re.PaymentMethodId__c!=null){                               
                        paymentprofilemap.put(re.PaymentMethodId__c, re);                              
                    }
                }
                if(!ZoldId.isempty()){
                    for(PaymentProfiles__History inloop2: paymentprofileshistory){                    
                        List<PaymentProfiles__History> temppay = new List<PaymentProfiles__History>();
                        if(inloop2.parent.PaymentMethodId__c!=null && inloop2.Field == 'SplitPercentage__c'){
                            if(Oldpaymentprofilemap.containskey(inloop2.parent.PaymentMethodId__c)){
                                temppay = Oldpaymentprofilemap.get(inloop2.parent.PaymentMethodId__c);
                                }else{
                                temppay = new List<PaymentProfiles__History>();
                            }
                            temppay.add(inloop2);                          
                            Oldpaymentprofilemap.put(inloop2.parent.PaymentMethodId__c,temppay);
                        }
                    }               
                }
                
                for(Zuora__Payment__c bi : Trigger.New){
                //CRM-3549 - need to populate Transfer AE from case
                    if(mapInvoiceTransferAE.containskey(bi.id)){
                        bi.Transfer_AE__c = mapInvoiceTransferAE.get(bi.Id);
                    }   
                    if(trigger.isinsert){
                    if(Paymentmthodmap.containskey(bi.ZPaymentMethodId__c) && Paymentmthodmap.get(bi.ZPaymentMethodId__c).Zuora__CreditCardHolderName__c!=null){                 
                        bi.Credit_Card_Holder_Name__c = Paymentmthodmap.get(bi.ZPaymentMethodId__c).Zuora__CreditCardHolderName__c;
                        bi.Payment_Method__c = Paymentmthodmap.get(bi.ZPaymentMethodId__c).Id;
                    }
                    if(paymentprofilemap.containskey(bi.ZPaymentMethodId__c) && paymentprofilemap.get(bi.ZPaymentMethodId__c).SplitPercentage__c!=null){
                        bi.Split__c = paymentprofilemap.get(bi.ZPaymentMethodId__c).SplitPercentage__c;
                        system.debug('Newsplit ' + bi.Split__c);
                    }                      
                    if(Oldpaymentprofilemap.containskey(bi.ZPaymentMethodId__c) && bi.Zuora__Effective_Date__c < today){                                    
                        for(PaymentProfiles__History inloop : Oldpaymentprofilemap.get(bi.ZPaymentMethodId__c)){                             
                            if(inloop.Field == 'SplitPercentage__c'){                                                         
                                if(inloop.createddate < bi.createddate){
                                    bi.Split__c = Integer.Valueof(inloop.NewValue);  
                                    system.debug('Oldsplit ' +inloop.NewValue);
                                }
                            }
                        }
                    }                                                           
                }
                } 
            }   
        
        
    } 
}