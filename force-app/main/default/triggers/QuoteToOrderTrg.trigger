//**************************************************//
// (c) 2015 NTTDATA, Inc.
// Class Name : QuoteToOrderTrg
// This trigger is Used to Create Create and split order based upon start date and product type
// Complete logic in available in Helper class
// Created 28th May 2015   Author Name:-  Sonu Sharma     Original
// Modified 29th june 2015   Author Name:- Vikram Thallapelli   Modified
// Modified 15th Dec 2015 Author Name:- Stanley Sequeira
//**************************************************//
trigger QuoteToOrderTrg on BigMachines__Quote__c(before Insert, before update, after update, after insert) {
    //if(checkRecursive.runOnce()){
    DisabledTrigger__c Dtrg = DisabledTrigger__c.getValues('Disabled');
    // Turn off trigger if the value of custom setting field is true.
    if (Dtrg.QuoteTrigger__c != UserInfo.getUserName()) {
        if (Trigger.isUpdate && Trigger.isbefore) {
            QuoteToOrderHelperCls.GenerateQuoteTRansactionStrings(Trigger.newMap);
            QuoteToOrderHelperCls.updateParentQuoteId(Trigger.new); //CRM-4804
            for (BigMachines__Quote__c bmq: Trigger.new) {
            //  CRM-631, Copy Quote product trnsaction Ids to order product Ids
            bmq.All_Order_Product_Ids__c = bmq.All_Quote_Product_Ids__c;
                if (Trigger.oldMap.get(bmq.id).BigMachines__Status__c == 'Ordered') {
                    bmq.BigMachines__Status__c = 'Ordered';
                }                              
            }
            
            // CRM-2808 - Assign Quote Submitter
            QuoteToOrderHelperCls.assignQuoteSubmitter(Trigger.newMap, Trigger.oldMap);
            // CRM-2808 End
        }
        if (Trigger.isUpdate && Trigger.isAfter) {
            if (SkipTrigger.skiptrigger == false) {
                //QuoteToOrderHelperCls.CreateOrderOnApproval(false,Trigger.oldMap,Trigger.newMap);
                QuoteToOrderHelperCls.UpdateAssetModification(Trigger.newMap, Trigger.oldMap);
                QuoteToOrderHelperCls.CreateValidQuote(false, Trigger.oldMap, Trigger.newMap);

                //QuoteToOrderHelperCls.TriggerQuoteToOrder(Trigger.newMap.keyset());
                QuoteToOrderHelperCls.findAutoRenewalFlag(Trigger.newMap.keyset());

                for (BigMachines__Quote__c qq: Trigger.new) {
                    if (qq.BigMachines__Status__c == 'Pending Signature') {
                        QuoteToOrderHelperCls.UpdateOpportunityTypeToTigerLead(Trigger.newMap.keyset());
                    }
                }

            }
            //Code added by Vikram Thallapelli,
            //Usage : Update case status based on quote approval process status.
            QuoteToCaseHandlerClass.QuoteToCase(Trigger.new);
            //Vikram code ends

        }
        if (Trigger.isInsert && Trigger.isBefore) {
            // QuoteToOrderHelperCls.CreateOrderOnApproval(true,Trigger.oldMap,Trigger.newMap);
            QuoteToOrderHelperCls.updateParentQuoteId(Trigger.new); //CRM-4804
            for (BigMachines__Quote__c bqq: Trigger.new) {
                bqq.ownerId = userInfo.getUserId();
            }
        }
        //}

        // Code Added by Stanley Sequeira - NTT Data
        if (Trigger.isAfter && Trigger.isUpdate) {
            if(!SkipQuoteWelcomeTrigger.skiptrigger){
            BigMachinesQuoteTriggerHandler.createCases(Trigger.New, Trigger.oldMap);
            }

        }

        //Code Added by Srinivas Vadla 
        //Usage : TO Submit the quotes which are created through CANCEL ALL ASSETS button
        if(Trigger.isAfter && Trigger.isUpdate){
            for(BigMachines__Quote__c bqq: Trigger.new){
                    CreateRetentionQuoteOnPastDue.submitQuote(Trigger.newMap.keyset());
            }
        }
        //Code Added by Srinivas Vadla 
        //Usage : TO create an opportunity for the quick quotes which are created through Sales Dashboard
        if (Trigger.isAfter && Trigger.isInsert) {
            if(!SkipQuoteWelcomeTrigger.skiptrigger){
                BigMachinesQuoteTriggerHandler.createOpportunityforQQ(Trigger.new);
            }
        }  
    }
}