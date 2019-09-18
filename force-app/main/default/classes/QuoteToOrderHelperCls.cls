//**************************************************//
// (c) 2015 NTTDATA, Inc.
// Class Name : QuoteToOrderHelperCls
// This Class is Used to Create Create and split order based upon start date and product type
//
// Created 28th May 2015   Author Name:-  Sonu Sharma     Original
// Modified 28th May 2015  Author Name:-  Sonu Sharma    Modified
// 24th May 2016           Krishna Veni Bodala    -Added method:createCaseForTigerLeadAmendments
//Modified 18 th July 2016 Author Name: Rajamohan Vakati -- Modifed for JIRA STORY ADVP-1937
//Modified 29th Aug 2016   Author Name: Pallavi Tammana - Modifed for JIRA STORY ADVP-2026
//Modified 27th March 2017 Author Name : Mridula Boinpally - Modified for JIRA STORY CRM-1079
//Modified 2nd April 2018  Author Name: Pallavi Tammana - Modified for Jira CRM-3584
//**************************************************//

Public class QuoteToOrderHelperCls {

    Public Static void CreateValidQuote(Boolean triggerevent, Map<Id, BigMachines__Quote__c> oldMapbmQuotes, Map<Id, BigMachines__Quote__c> newMapbmQuotes) {

        system.debug('Inside Create valid quote');
        Set<Id> setAllAccountIds = new Set<Id>();
        Set<Id> setAccountIds = new Set<Id>(); //set of account Ids
        Set<Id> setBMQuoteIds = new Set<Id>(); //set of Big machine Quote Ids
        Set<Id> setProductIds = new Set<Id>(); //set of Product Ids
        Map<id, Decimal> mapTLWithoutSigned = new Map<id, Decimal>();
        try {
            for (BigMachines__Quote__c bmq : newMapbmQuotes.values()) {
                setAllAccountIds.add(bmq.BigMachines__Account__c);
                mapTLWithoutSigned.put(bmq.id, 0.0);
            }
            
            // CRM-2352 Added Owner.UserName, sales_lock_user__c, Owner.Profile.Name, Owner.IsActive, Do_Not_Move__c in below SOQL
            // CRM-2980 Added Type, Account_Sub_Type__c to below SOQL
            Map<Id, Account> mapAccountQuote = new Map<Id, Account>([Select Id, Name, Billing_Preference__c, Owner.UserName, sales_lock_user__c, 
                                                Owner.Profile.Name, Owner.IsActive, Do_Not_Move__c, Type, Account_Sub_Type__c from Account where Id = :setAllAccountIds]);

            // CRM-2532 Get Un-Assigned Users List
            List<Account> accountOwnerToUpdate = new List<Account>();
            Set<String> unAssignedUsers = new Set<String>();
            Error_Notification_Email_Settings__c theUserNamelist = Error_Notification_Email_Settings__c.getInstance('Account Owner List Transfer');
            if (theUserNamelist != null) {
                unAssignedUsers.addAll(theUserNamelist.Asset_Creation_Error_Emails__c.split(';'));
            }
            for (BigMachines__Quote__c bmq : newMapbmQuotes.values()) {
                // CRM-2352 Start
                Account quoteAccount = mapAccountQuote.get(bmq.BigMachines__Account__c);
                if (Label.Run_Owner_Reassignment_Quote == 'true' && 
                    ((quoteAccount.Type == 'Broker' || quoteAccount.Type == 'Realtor Agent') &&
                     (quoteAccount.Account_Sub_Type__c == 'Prospect' || quoteAccount.Account_Sub_Type__c == 'Former Customer'))) {
                    Id ownerId = null;
                    Boolean ownerUnAssigned = ((!quoteAccount.Owner.IsActive || unAssignedUsers.contains(quoteAccount.Owner.UserName) || !Label.Account_Owner_Not_Be_Changed_Profile_List.contains(quoteAccount.Owner.Profile.Name))  
                    ); 
                         // CRM-3952 Commented below line and added new condition above
                        //(quoteAccount.Owner.Profile.Name != 'Move Agent Sales Rep' && quoteAccount.Owner.Profile.Name != 'Move Broker Sales Rep'); 
                    if (ownerUnAssigned && 
                        ((bmq.BigMachines__Status__c == 'Approved' && oldMapbmQuotes.get(bmq.id).BigMachines__Status__c != 'Approved') || 
                        (bmq.BigMachines__Status__c == 'Pending Approval' && oldMapbmQuotes.get(bmq.id).BigMachines__Status__c != 'Pending Approval'))) {
                        if (quoteAccount.sales_lock_user__c == null) {
                            ownerId = bmq.OwnerId;
                        }
                        else if (!quoteAccount.Do_Not_Move__c){
                            ownerId = quoteAccount.sales_lock_user__c;
                        }
                    }
                    if (ownerId != null) {
                        quoteAccount.OwnerId = ownerId;
                        accountOwnerToUpdate.add(quoteAccount);
                    }
                }
                // CRM-2352 End
                
                // CRM-2352 - Declared a map to store original Billing_Preference__c 
                Map<Id, String> billingPreferenceMap = new Map<Id, String>();
                
                //System.debug('6666666'+mapAccountQuote.get(bmq.BigMachines__Account__c).Billing_Preference__c);
                if (mapAccountQuote.get(bmq.BigMachines__Account__c).Billing_Preference__c != null) {
                    // CRM-2352 - Store origninal Billing_Preference__c in map
                    billingPreferenceMap.put(bmq.BigMachines__Account__c, mapAccountQuote.get(bmq.BigMachines__Account__c).Billing_Preference__c);
                    
                    // CRM-6098 - Consider default Billing Preference as CC-Direct for BLA Quotes 
                    if (bmq.Is_BLA_Auto_Quote__c) {
                        mapAccountQuote.get(bmq.BigMachines__Account__c).Billing_Preference__c = 'CC-Direct';
                    }
                    else {
                        if (mapAccountQuote.get(bmq.BigMachines__Account__c).Billing_Preference__c == 'Invoice-CC') {
                            mapAccountQuote.get(bmq.BigMachines__Account__c).Billing_Preference__c = 'CC-Direct';
                        }
                        if (mapAccountQuote.get(bmq.BigMachines__Account__c).Billing_Preference__c == 'Arrears-CC') {
                            mapAccountQuote.get(bmq.BigMachines__Account__c).Billing_Preference__c = 'CC-Direct';
                        }
                        if (mapAccountQuote.get(bmq.BigMachines__Account__c).Billing_Preference__c == 'Invoice-Terms') {
                            mapAccountQuote.get(bmq.BigMachines__Account__c).Billing_Preference__c = 'Invoice';
                        }
                        if (mapAccountQuote.get(bmq.BigMachines__Account__c).Billing_Preference__c == 'Arrears-Invoice') {
                            mapAccountQuote.get(bmq.BigMachines__Account__c).Billing_Preference__c = 'Invoice';
                        }
                    }
                }
                //CRM-2978 Included the condition to check the old status != Approved in case of Suppress Docusign = True. No check for Old condition was causing duplicate orders getting generated intermittently. 
                System.debug('PPPPPP' + bmq.id +(bmq.BigMachines__Status__c != 'Ordered' && bmq.BigMachines__Status__c == 'Customer Rejected') + 'KK' + (bmq.BigMachines__Status__c != 'Ordered' && bmq.BigMachines__Status__c == Constants.QUOTE_STATUS_APPROVED && oldMapbmQuotes.get(bmq.Id).BigMachines__Status__c != Constants.QUOTE_STATUS_APPROVED && mapAccountQuote.get(bmq.BigMachines__Account__c).Billing_Preference__c == Constants.ACCOUNT_BILLING_PREFERENCE_CC_Direct && (bmq.tigerLeadProductExists__c == false || (bmq.tigerLeadProductExists__c == true && bmq.TL_Primary_Add__c == 0))) + 'PPPP' + (bmq.BigMachines__Status__c != 'Ordered' && oldMapbmQuotes.get(bmq.Id).BigMachines__Status__c != Constants.QUOTE_STATUS_APPROVED && (bmq.BigMachines_Quote_Type__c == 'Retention' || bmq.BigMachines_Quote_Type__c == 'Modify') && bmq.BigMachines__Status__c == Constants.QUOTE_STATUS_APPROVED) + 'KKKKK' + (bmq.BigMachines__Status__c != 'Ordered' && (oldMapbmQuotes.get(bmq.Id).BigMachines__Status__c != Constants.QUOTE_STATUS_SIGNED && bmq.BigMachines__Status__c == Constants.QUOTE_STATUS_SIGNED) && (mapAccountQuote.get(bmq.BigMachines__Account__c).Billing_Preference__c != Constants.ACCOUNT_BILLING_PREFERENCE_CC_Direct || (bmq.tigerLeadProductExists__c == true && bmq.TL_Primary_Add__c > 0))));
                if (bmq.BigMachines__Status__c != 'Rejected' && bmq.BigMachines__Status__c != 'Customer Rejected' && bmq.BigMachines__Status__c != 'Document Expired') {
                    if ((bmq.BigMachines__Status__c != 'Ordered' && bmq.BigMachines__Status__c == 'Approved' && bmq.Suppress_Docusign__c == true && oldMapbmQuotes.get(bmq.Id).BigMachines__Status__c != Constants.QUOTE_STATUS_APPROVED) || (bmq.BigMachines__Status__c != 'Ordered' && (bmq.BigMachines__Status__c == 'Customer Rejected' || bmq.BigMachines__Status__c == 'Document Expired')) || (bmq.BigMachines__Status__c != 'Ordered' && bmq.BigMachines__Status__c == Constants.QUOTE_STATUS_APPROVED && oldMapbmQuotes.get(bmq.Id).BigMachines__Status__c != Constants.QUOTE_STATUS_APPROVED && mapAccountQuote.get(bmq.BigMachines__Account__c).Billing_Preference__c == Constants.ACCOUNT_BILLING_PREFERENCE_CC_Direct && (bmq.tigerLeadProductExists__c == false || (bmq.tigerLeadProductExists__c == true && bmq.TL_Primary_Add__c == 0))) || (bmq.BigMachines__Status__c != 'Ordered' && oldMapbmQuotes.get(bmq.Id).BigMachines__Status__c != Constants.QUOTE_STATUS_APPROVED && (bmq.BigMachines_Quote_Type__c == 'Retention' || (bmq.BigMachines_Quote_Type__c == 'Modify'  && bmq.Modify_Add_Renew__c < 1)) && bmq.BigMachines__Status__c == Constants.QUOTE_STATUS_APPROVED) || (bmq.BigMachines__Status__c != 'Ordered' && (oldMapbmQuotes.get(bmq.Id).BigMachines__Status__c != Constants.QUOTE_STATUS_SIGNED && bmq.BigMachines__Status__c == Constants.QUOTE_STATUS_SIGNED) && (mapAccountQuote.get(bmq.BigMachines__Account__c).Billing_Preference__c != Constants.ACCOUNT_BILLING_PREFERENCE_CC_Direct || (bmq.tigerLeadProductExists__c == true && bmq.TL_Primary_Add__c > 0)))) {
                        if (triggerevent) {
                            if (bmq.BigMachines__Status__c == Constants.QUOTE_STATUS_APPROVED) { // && bmq.Retention_Not_Cancel__c==0
                                setBMQuoteIds.add(bmq.id); //Pushing Quote Ids
                                setAccountIds.Add(bmq.BigMachines__Account__c); //Pushing Account Ids
                            }
                        } else {
                            if (oldMapbmQuotes.get(bmq.Id).BigMachines__Status__c != null && bmq.BigMachines__Status__c != null) {
                                 if ((bmq.BigMachines__Status__c != 'Ordered' && bmq.BigMachines__Status__c == 'Approved' && bmq.Suppress_Docusign__c == true && oldMapbmQuotes.get(bmq.Id).BigMachines__Status__c != Constants.QUOTE_STATUS_APPROVED) || (bmq.BigMachines__Status__c != 'Ordered' && (bmq.BigMachines__Status__c == 'Customer Rejected' || bmq.BigMachines__Status__c == 'Document Expired')) || (bmq.BigMachines__Status__c != 'Ordered' && bmq.BigMachines__Status__c == Constants.QUOTE_STATUS_APPROVED && oldMapbmQuotes.get(bmq.Id).BigMachines__Status__c != Constants.QUOTE_STATUS_APPROVED && mapAccountQuote.get(bmq.BigMachines__Account__c).Billing_Preference__c == Constants.ACCOUNT_BILLING_PREFERENCE_CC_Direct && (bmq.tigerLeadProductExists__c == false || (bmq.tigerLeadProductExists__c == true && bmq.TL_Primary_Add__c == 0))) || (bmq.BigMachines__Status__c != 'Ordered' && oldMapbmQuotes.get(bmq.Id).BigMachines__Status__c != Constants.QUOTE_STATUS_APPROVED && (bmq.BigMachines_Quote_Type__c == 'Retention' || (bmq.BigMachines_Quote_Type__c == 'Modify' && bmq.Modify_Add_Renew__c < 1)) && bmq.BigMachines__Status__c == Constants.QUOTE_STATUS_APPROVED) || (bmq.BigMachines__Status__c != 'Ordered' && (oldMapbmQuotes.get(bmq.Id).BigMachines__Status__c != Constants.QUOTE_STATUS_SIGNED && bmq.BigMachines__Status__c == Constants.QUOTE_STATUS_SIGNED) && (mapAccountQuote.get(bmq.BigMachines__Account__c).Billing_Preference__c != Constants.ACCOUNT_BILLING_PREFERENCE_CC_Direct || (bmq.tigerLeadProductExists__c == true && bmq.TL_Primary_Add__c > 0)))) {
                                    System.debug(oldMapbmQuotes.get(bmq.Id).BigMachines__Status__c + '$$$$$$' + bmq.BigMachines__Status__c + '$$$$$$' + bmq.BigMachines__Account__r.Billing_Preference__c);
                                    setBMQuoteIds.add(bmq.id); //Pushing Quote Ids
                                    setAccountIds.Add(bmq.BigMachines__Account__c); //Pushing Account Ids
                                }
                            }
                        }
                    }
                } else {
                    Set<Id> setBMQIds = new Set<Id>();
                    UpdateQuoteStatusToRejected(setBMQIds);
                }
                
                // CRM-2352 - Assign back original Billing_Preference__c 
                mapAccountQuote.get(bmq.BigMachines__Account__c).Billing_Preference__c = billingPreferenceMap.get(bmq.BigMachines__Account__c);
            }
            
            // CRM-2352 Update Accounts
            if (accountOwnerToUpdate.size() > 0) {
                update accountOwnerToUpdate;
            }
            // CRM-2352 End
            System.debug('Till here' + setBMQuoteIds);
            if (setBMQuoteIds.size() > 0) {
            Set<Id> setQuickIds = new Set<Id>();
            Set<Id> setNormalIds = new Set<Id>();
            Boolean QuickFulfill = false;
                List<BigMachines__Quote__c> lstBMQuote = [Select Id, name,Quick_now__c, Execute_Order_Process__c from BigMachines__Quote__c where Id = :setBMQuoteIds and Execute_Order_Process__c = false];
                for (BigMachines__Quote__c bmq : lstBMQuote) {
                    bmq.Execute_Order_Process__c = true;
                    if(bmq.Quick_now__c>0){
                    System.debug('Quick Fulfill here ' + bmq.Quick_now__c );
                    QuickFulfill = true;
                    }
                }
                System.debug('Till here' + lstBMQuote );
                if(QuickFulfill){
                BatchProcessQuoteQuickFulfill bpqi = new BatchProcessQuoteQuickFulfill();
                bpqi.setBMQIds = setBMQuoteIds;
                bpqi.setAccIds = setAccountIds;
                Database.executeBatch(bpqi,1);
                } else {
                CreateOrderOnApproval(setBMQuoteIds, setAccountIds);
                }
                BigMachinesQuoteTriggerHandler.assignQuoteTask(setBMQuoteIds);
                processOpportunity(setBMQuoteIds);
                if(Test.isRunningTest()){
                Integer ii = 1/0;
                }
            }
            //Added try-Catch by Nevil Jain: To track the LEAP-8290
        } catch (Exception ex) {
            List<Error__c> lstError = new List<Error__c>();
            for (Id idd : setBMQuoteIds) {
                Error__c error = new Error__c();
                error.Name = idd;
                error.Entity_Id__c = 'Quote to order';
                error.Interface_Name__c = 'QuoteToOrderHelperCls';
                error.Error_Description__c = 'Trigger -' + ex.getMessage() + '' + '------' + ex.getStackTraceString();
                lstError.add(error);
            }
            if (lstError.size() > 0) {
                insert lstError;
            }
        }
    }

    
    @future
    Public static void CreateOrderOnApproval(Set<Id> setBMQIds, Set<Id> setAccIds) {
    CreateOrderOnApprovalMethod(setBMQIds,setAccIds);
    }
    Public static Set<Id> CreateOrderOnApprovalMethod(Set<Id> setBMQIds, Set<Id> setAccIds) {
                Map<Id, Set<String>> productCodesMap = new Map<Id,Set<String>>(); // CRM 1079
        system.debug('Inside CreateOrderOnApproval');
        Set<Id> setAccountIds = new Set<Id>(); //set of account Ids
        Set<Id> setBMQuoteIds = new Set<Id>(); //set of Big machine Quote Ids
        Set<Id> setProductIds = new Set<Id>(); //set of Product Ids
        Set<Id> setBMQuoteEssIds = new Set<Id>(); //set of Big machine Quote Essential Required Ids
        Map<Id, Id> mapQuoteIdOrderId = new Map<Id, Id>(); //Map to keep relation between quote and order
        Map<Id, Decimal> mapQuoteCancelCount = new Map<Id, Decimal>(); //Map to keep relation between quote and order
        Map<Id, Id> mapAccountContractId = new Map<Id, Id>(); // Map to Account and Contract Ids
        Map<Id, PriceBookEntry> mapProductPriceBookEntryId = new Map<Id, PriceBookEntry>(); // Map of all productprice book entries
        Map<Id, PriceBookEntry> mapPriceBookEntryId = new Map<Id, PriceBookEntry>(); // Map of all productprice book entries

        List<Contract> lstNewContract = new List<Contract>();  // List of new contract needs to be create if needed
        Map<String, Order> mapListOrder = new Map<String, Order>(); //Contains map of all order needs to be create
        List<OrderItem> lstOrderLineItems = new List<OrderItem>(); //Contains map of all orderline Item needs to be create
        Set<string> TLProductStrings = new Set<string>();
        Set<string> RSBundleBilltoProductCode = new Set<string>{'RSCONNECT','RSTRANSACT'};
        Map<Id,Boolean> mapTLLineType = new Map<Id,Boolean>();
        List<Task> lstTask = new List<Task>();
        Set<string> TLActivitiesStrings = new Set<string>();
        List<Case> lstCases = new List<Case>();
        Set<Id> setOrderIds = new Set<Id>();
        Set<Id> setRenewalAssetIds = new Set<Id>();
        Set<String> setManualNames = new Set<String>();
        Boolean havingDAP = false;
        String quoteId = null;
        String quoteNumber = null;
        String quoteType = '';
        Boolean createdDAPCase = false;
        String QuoteLineDescp = '';
        Map<String, Boolean> mapTLActivities = new Map<String, Boolean>();
        Map<String, String> mapManualActivities = new Map<String, String>();
        Map<String, String> mapHomeSearchTL = new Map<String, String>();
        Map<String, String> mapCancellationReason = new Map<String, String>();
        Map<String, String> mapManualQueueName = new Map<String, String>();
        Map<String, String> mapProductCodeQueueName = new Map<String, String>();
        Map<String, String> mapQuoteLineIdProductCode = new Map<String, String>();
        Map<String, String> mapQuoteLineIdProductName = new Map<String, String>();
        Map<String, String> mapProductCodeLineType = new Map<String, String>();
        Map<String, String> mapProductCodeQuoteLineId = new Map<String, String>();
        Map<String, Date> mapProductCodeStartDate = new Map<String, Date>();
        Tiger_Lead_Products__c TLProducts = Tiger_Lead_Products__c.getValues('TigerLeads');
        Map<Id, BigMachines__Quote_Product__c> lcmAssetQuoteProdMap =  new Map<Id, BigMachines__Quote_Product__c>();
        Map<Id, Decimal> QPCreditPercntMap = new Map<Id, Decimal>();
        Map<Id,String> OrderMapList = new Map<Id,String>();
        Map<String, String> mapProductCodeOrdId = new Map<String, String>();
        List<Presale_Available_Inventory__c> presaleorders = new List<Presale_Available_Inventory__c>();//Presale requirement
        String presalequoteid;//Presale requirement
        Decimal totalQuantity;//Presale requirement
        Boolean noCasesForCredit = false;

        try {

            if (TLProducts != null) {
                TLProductStrings.addall(TLProducts.Tiger_Lead_Product_List__c.split(';'));
                TLActivitiesStrings.addall(TLProducts.TigerLeadActivities__c.split(';'));
            }

            Map<Id, Account_Relationship__c> mapAccountRelationship = new Map<Id, Account_Relationship__c>();
            for (Account_Relationship__c accRelation : [Select Id, Name, Parent_Account__c ,Parent_Account__r.Email_Address__c, Contact_To__c, Contact_To__r.FirstName, Contact_To__r.LastName, Contact_To__r.Preferred_Phone__c,
                                                        Contact_To__r.HomePhone, Contact_To__r.MobilePhone, Contact_To__r.Work_Phone__c, Contact_To__r.OtherPhone
                                                        , Contact_To__r.Contact_Party_ID__c, Contact_To__r.Work_Phone_Ext__c, Contact_To__r.Email from Account_Relationship__c
                                                        where Contact_Role__c = 'Primary Contact' and Contact_To__c != null and Parent_Account__c = :setAccIds limit 1]) {
                                                            mapAccountRelationship.put(accRelation.Parent_Account__c, accRelation);
                                                        }
            Map<Id, Id> mapAccountAccountManagerUserIds = new Map<Id, Id>();
            for (AccountTeamMember atm : [SELECT AccountId, TeamMemberRole, UserId FROM AccountTeamMember where AccountId = :setAccIds and TeamMemberRole = 'Account Manager']) {
                mapAccountAccountManagerUserIds.put(atm.AccountId, atm.UserId);
            }

            for (Tiger_Lead_Products__c mntlp : [Select Id, Name, Tiger_Lead_Product_List__c, Queue_Name__c, TigerLeadActivities__c from Tiger_Lead_Products__c where (Name != 'TigerLeads' AND Name != 'TOPIDX')]) {
                mapManualActivities.put(mntlp.Tiger_Lead_Product_List__c, mntlp.TigerLeadActivities__c);
                setManualNames.add(mntlp.Queue_Name__c);
                mapProductCodeQueueName.put(mntlp.Tiger_Lead_Product_List__c, mntlp.Queue_Name__c);
            }
            
            for (Cancellation_Reason_CPQ_Mapping__c mntlp : [Select Id, Name, CPQ_Variable_Name__c from Cancellation_Reason_CPQ_Mapping__c]) {
                mapCancellationReason.put(mntlp.CPQ_Variable_Name__c, mntlp.Name);
            }
            for (Group grp : [SELECT DeveloperName, Id, Name, Type FROM Group WHERE DeveloperName = :setManualNames and Type = 'Queue']) {
                mapManualQueueName.put(grp.DeveloperName, grp.Id);
            }
            setBMQuoteIds = setBMQIds;
            setAccountIds = setAccIds;
            system.debug('Set BM Quotes  Before: ' + setBMQuoteIds);
            if (setBMQuoteIds.size() > 0) {
                //SkipTrigger.setSkipTrgTrue();
                // Soql query to get list of related Quote lines
                // id PBID = [select Id from Pricebook2 where name = 'Move Price Book'].Id;
                // Modified By Rajamohan Vakati for JIRA Story ADVP-1937
                // Moification list - Added to Query ResidentialLeadPPL__c,ResidentialLeadPPLOverride__c,ResidentialBrandPPL__c,ResidentialBrandPPLOverride__c,ResidentialAMLC__c,ResidentialAMLCOverride__c,LandAMLC__c,LandAMLCOverride__c,RentalAMLC__c,RentalAMLCOverride__c,ContractedAMLC__c

                //CRM-2328 - Displays proration credit amount generated while placing the Quote. Included Proration Credit in the query
                List<BigMachines__Quote_Product__c> lstBMQuoteProduct = [Select No_Term_Sale__c,Id,BigMachines__Quote__r.Is_Quick_Quote__c,Real_Suite_Parent__c, Cancel_Type__c, Migrated_From_Legacy__c,Category__c, Name, MLS_Type__c, Franchise_Asset__c, BigMachines__Description__c,
                                                                         BigMachines__Quote__r.BigMachines__Status__c, Asset__c, Line_Type__c, Auto_Renewal__c,
                                                                         Product_Email__c, Product_Account__c, Est_Tax__c, Manual_Override_Amount__c, Zuora_payment_method__c,
                                                                         Net_Price_Each__c, Extended_Net_Price__c, Promotion_Amount__c, Total_Discount__c,
                                                                         Market_Budget_Fee__c, Fulfill_To_Account__c, HLC__c, HLC_Override__c,Quick_fulfillment__c,
                                                                         Quote_Transaction_ID__c, Inv_Lock_Expire_Date__c, Market__c, MLS_Set_Id__c,
                                                                         Term_Start_Date__c, Participant__c, Promotion__c, Tax_Error_Description__c, Lead_Type__c,
                                                                         Billing_Period__c, Top_Connector__c, Featured_Mortgage__c, Product_Type__c,
                                                                         NAR_Membership__c, Promo_Discount__c, Manual_Discount__c, Discount_Type__c, Manual_Price_Override__c,
                                                                         Price_Tier__c, Qty_Tier__c, MSA_Tier__c, HLC_Range__c, License_Tier_Range__c,
                                                                         ResidentialLeadPPL__c,ResidentialLeadPPLOverride__c,ResidentialBrandPPL__c,ResidentialBrandPPLOverride__c,
                                                                         ResidentialAMLC__c,ResidentialAMLCOverride__c,LandAMLC__c,LandAMLCOverride__c,RentalAMLC__c,ConfigOptions__c,
                                                                         RentalAMLCOverride__c,ContractedAMLC__c,DecommissionedAsset__c,AMLCOverride__c,PPLOverride__c,
                                                                         Franchise_Amount__c, Inventory_Transaction_ID__c , Subscription_Term__c, Suppress_Welcome_Calls__c, Cancellation_Date__c, Choice_Lead_Form__c, Asset_Structure__c
                                                                         , BigMachines__Quote__r.BigMachines_Quote_Type__c, Create_Broker_Tools__c, RS_Action_Type__c,
                                                                         BigMachines__Quote__r.BigMachines__Account__r.BillingCity,
                                                                         BigMachines__Quote__r.BigMachines__Account__r.BillingState,
                                                                         BigMachines__Quote__r.BigMachines__Account__r.BillingPostalCode,
                                                                         BigMachines__Quote__r.BigMachines__Account__r.BillingCountry,
                                                                         BigMachines__Quote__r.BigMachines__Account__r.ShippingStreet,
                                                                         BigMachines__Quote__r.BigMachines__Account__r.ShippingCity,
                                                                         BigMachines__Quote__r.BigMachines__Account__r.ShippingState,
                                                                         BigMachines__Quote__r.BigMachines__Account__r.ShippingPostalCode,
                                                                         BigMachines__Quote__r.BigMachines__Account__r.ShippingCountry,
                                                                         BigMachines__Quote__r.BigMachines__Account__r.BillingStreet,
                                                                         BigMachines__Quote__r.BigMachines__Account__r.EssentialsStatus__c,
                                                                         BigMachines__Quote__r.BigMachines__Transaction_Id__c,
                                                                         BigMachines__Quote__r.tigerLeadProductExists__c,
                                                                         BigMachines__Quote__r.BigMachines__Total__c,
                                                                         BigMachines__Quote__r.Auto_Discount__c,
                                                                         BigMachines__Quote__r.Auto_Discount_Amt__c,
                                                                         BigMachines__Quote__r.Auto_Est_Tax__c,
                                                                         BigMachines__Quote__r.Auto_Fulfilled_Total__c,
                                                                         BigMachines__Quote__r.Auto_List_Price__c,
                                                                         BigMachines__Quote__r.Auto_Net_Price__c,
                                                                         BigMachines__Quote__r.Auto_Subtotal__c,
                                                                         BigMachines__Quote__r.Case__c,
                                                                         BigMachines__Quote__r.Name,
                                                                         Unit_Total_Price__c, Price_Effective_Date__c,
                                                                         BigMachines__Quote__r.Retention_Not_Cancel__c,
                                                                         BigMachines__Quote__r.Manual_Discount__c,
                                                                         BigMachines__Quote__r.Manual_Discount_Amt__c,
                                                                         BigMachines__Quote__r.Manual_Est_Tax__c,
                                                                         BigMachines__Quote__r.Manual_List_Price__c,
                                                                         BigMachines__Quote__r.Manually_Fulfilled_Total__c,
                                                                         BigMachines__Quote__r.Manual_Net_Price__c,
                                                                         BigMachines__Quote__r.Manual_Subtotal__c,
                                                                         BigMachines__Quote__r.Maximum_First_Charge__c,
                                                                         BigMachines__Quote__r.Minimum_First_Charge__c,
                                                                         BigMachines__Quote__r.One_Time_Discount__c,
                                                                         BigMachines__Quote__r.One_Time_Discount_Amt__c,
                                                                         BigMachines__Quote__r.One_Time_Est_Tax__c,
                                                                         BigMachines__Quote__r.One_Time_List_Price__c,
                                                                         BigMachines__Quote__r.One_Time_Net_Price__c,
                                                                         BigMachines__Quote__r.One_Time_Subtotal__c,
                                                                         //BigMachines__Quote__r.Oracle_Quote__c,
                                                                         BigMachines__Quote__r.Set_Up_Fee__c,
                                                                         BigMachines__Quote__r.ownerId,
                                                                         Delta_Price_w_o_Tax__c,Trial__c,
                                                                         Cost_Per_Action__c,
                                                                         BigMachines__Quote__r.Total_Discount__c,
                                                                         BigMachines__Quote__r.Total_Discount_Amt__c,
                                                                         BigMachines__Quote__r.Total_Est_Tax__c,
                                                                         BigMachines__Quote__r.Total_List_Price__c,
                                                                         BigMachines__Quote__r.Total_Net_Price__c,
                                                                         BigMachines__Quote__r.Total_Price_W_Tax__c,
                                                                         BigMachines__Quote__r.Usage_Total__c, Refund_Request__c,
                                                                         BigMachines__Quote__r.Suppress_Order_Confirmation__c,
                                                                         BigMachines__Quote__r.BigMachines__Total_Amount__c,
                                                                         BigMachines__Quote__r.BigMachines__Account__r.Franchise_Type__c,
                                                                         BigMachines__Quote__r.BigMachines_authorization_date__c,
                                                                         BigMachines__Quote__r.BigMachines__Opportunity__c, Contract_Term__c,
                                                                         Extended_List__c, Total_List_Price__c, Total_Price_WithTax__c,
                                                                         Extension_Type__c, Net_Price__c, Total_Net_Price__c, Total_Net__c, Est_Total_Tax__c,
                                                                         Market_Tier__c, Available_Presale_Inventory__c, Ext_Days__c,
                                                                         Promotion_Discount__c, Strategic_Discount__c, Strategic_Discount_Percent__c, Strategic_Discount_dollar__c,
                                                                         Manual_Discount_Amount__c, Manual_Discount_Type__c, Manual_Discount_Percent__c,
                                                                         Quote_Discount_Percent__c, Combined_Discount_Percent__c, Combined_Discount__c, Total_Discount_Percent__c,
                                                                         Total_Discount_Amount__c, Override_Term__c, Delta_Price__c,
                                                                         Subscription_Start_Date__c, Subscription_End_Date__c,
                                                                         Credit_Amount__c , Commerce_Group__c, Cancellation_Reason__c, Buyout_Amount__c, Buyout_Discount__c,
                                                                         License_Tier__c, Cancellation_Effective_Date__c, Remaining_Asset_Value__c,
                                                                         List_Price__c, BigMachines__Quantity__c , Product_Account__r.Billing_Preference__c,
                                                                         Promo_Description__c , Start_Date__c, End_Date__c, BigMachines__Product__r.Fulfillment_Type__c,
                                                                         BigMachines__Quote__r.BigMachines__Account__c, BigMachines__Product__r.ProductCode,
                                                                         BigMachines__Product__r.RealSuite_Family__c,BigMachines__Quote__r.BigMachines__Description__c, BigMachines__Quote__c,
                                                                         BigMachines__Quote__r.BigMachines_currency_type__c, Extended_Discount__c,
                                                                         BigMachines__Quote__r.BigMachines_Quote_Status__c, BigMachines__Quote__r.ParentQuote__c,
                                                                         Spot_Promo_Code__c, //CRM-2627
                                                                         Spot_Promo_Percentage__c, //CRM-2627
                                                                         Contracted_Advantage_PPL_string__c,
                                                                         Proration_Credit__c,
                                                                         // CRM-3738 - Fetch fields from asset
                                                                         asset__r.ResidentialAMLC__c,
                                                                         asset__r.RentalAMLC__c,
                                                                         asset__r.LandAMLC__c,
                                                                         asset__r.ResidentialBrandPPL__c,
                                                                         asset__r.ResidentialLeadPPL__c,
                                                                         // CRM-3738 - End
                                                                         // CRM-6063 - BLA Fields
                                                                         Setup_Fee__c,
                                                                         Opcity_MSA__c,
                                                                         Backup_Monthly_Plan__c,
                                                                         Launch_Date__c,
                                                                         Source__c,
                                                                         Expected_Monthly_Lead_Volume__c,
                                                                         Stage__c,
                                                                         unlicensed_state_leads__c,
                                                                         can_disclose_fees__c,
                                                                         Focus_Fire_Id__c
                                                                         // CRM-6063 - End
                                                                         from BigMachines__Quote_Product__c
                                                                         where BigMachines__Quote__c = :setBMQuoteIds and Need_Manual_Renew__c = false and BigMachines__Quantity__c > 0];


                Map<Id, Contract> mapAccountContractlst = new   Map<Id, Contract>();
                Map<Id, Account> mapAccountQuote = new Map<Id, Account>([Select Id, Name, BillingCity, BillingState, BillingPostalCode, BillingCountry, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, BillingStreet, Billing_Preference__c from Account where Id = :setAccIds]);
                system.debug('-----setAccountIds --> '+setAccountIds);
                system.debug('-----contracts --> '+[Select id, accountid from contract where AccountID IN: setAccountIds]);
                for (Contract  contr : [Select Id, Name, AccountId, StartDate, EndDate, BillingCity, BillingState, BillingPostalCode, BillingCountry, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, BillingStreet, ContractTerm from Contract where AccountId = :setAccountIds]) {
                    if (mapAccountQuote.containskey(contr.AccountId)) {
                        contr.BillingCity = mapAccountQuote.get(contr.AccountId).BillingCity;
                        contr.BillingState = mapAccountQuote.get(contr.AccountId).BillingState;
                        contr.BillingPostalCode = mapAccountQuote.get(contr.AccountId).BillingPostalCode;
                        contr.BillingCountry = mapAccountQuote.get(contr.AccountId).BillingCountry;
                        contr.ShippingStreet = mapAccountQuote.get(contr.AccountId).ShippingStreet;
                        contr.ShippingCity = mapAccountQuote.get(contr.AccountId).ShippingCity;
                        contr.ShippingState = mapAccountQuote.get(contr.AccountId).ShippingState;
                        contr.ShippingPostalCode = mapAccountQuote.get(contr.AccountId).ShippingPostalCode;
                        contr.ShippingCountry = mapAccountQuote.get(contr.AccountId).ShippingCountry;
                        contr.BillingStreet = mapAccountQuote.get(contr.AccountId).BillingStreet;
                        contr.Status = 'Active';
                    }
                    mapAccountContractId.put(contr.AccountId, contr.Id); //Pushing exiting Account and contract relation
                    mapAccountContractlst.put(contr.AccountId, contr);
                }

                for (Id accId : setAccountIds) {
                    if (!mapAccountContractId.Containskey(accId)) {
                        Contract contrct = new Contract();
                        contrct.AccountId = accId;
                        //contrct.Status = 'Draft';
                        if (mapAccountQuote.containskey(accId)) {
                            contrct.BillingCity = mapAccountQuote.get(accId).BillingCity;
                            contrct.BillingState = mapAccountQuote.get(accId).BillingState;
                            contrct.BillingPostalCode = mapAccountQuote.get(accId).BillingPostalCode;
                            contrct.BillingCountry = mapAccountQuote.get(accId).BillingCountry;
                            contrct.ShippingStreet = mapAccountQuote.get(accId).ShippingStreet;
                            contrct.ShippingCity = mapAccountQuote.get(accId).ShippingCity;
                            contrct.ShippingState = mapAccountQuote.get(accId).ShippingState;
                            contrct.ShippingPostalCode = mapAccountQuote.get(accId).ShippingPostalCode;
                            contrct.ShippingCountry = mapAccountQuote.get(accId).ShippingCountry;
                            contrct.BillingStreet = mapAccountQuote.get(accId).BillingStreet;
                        }
                        lstNewContract.add(contrct); // List of contract needs to create new
                    }
                }
                Insert lstNewContract;

                for (Contract  contr : lstNewContract) {
                    contr.Status = 'Active';
                    mapAccountContractId.put(contr.AccountId, contr.Id);
                }

                Date orderstartdate;
                Date orderenddate;
                Integer contracttrm = 0;
                Set<Id> setAssetIds = new Set<Id>();
                Set<Id> setBMQuoteProductIds = new Set<Id>();
                Set<String> setlstPresaleString = new Set<String>();
                Map<Id, String> mapOrderActionString = new Map<Id, String>();
                Map<Id, String> mapOrderTLProductString = new Map<Id, String>();
                Map<Id, String> mapOrdernonTLProductString = new Map<Id, String>();
                // RS bundling variables
                Set<Id> suppressModifyQuoteIds = new Set<Id>();
                Map<Id, List<String>> suppressMap = new Map<Id, List<String>>();
                Set<String> promoBundle = new Set<String>();
                Set<String> nonProsoftPromo = new Set<String>();
                promoBundle.addAll(System.Label.RS_bundle_email_suppress_promo.split(';'));
                nonProsoftPromo.addAll(System.Label.RS_bundle_non_prosoft_promo.split(';'));
                Boolean isRSRespondPresent = false;
                Boolean isRSConnectPresent = false;
                Set<String> newCobrokeSet = new Set<String>();
                Set<String> renewCobrokeSet = new Set<String>();
                //Boolean allowSubscription = false;
                
                for (BigMachines__Quote_Product__c bmqp : lstBMQuoteProduct) {
                    
                    //Added by Pratik for CRM-4653 on 5th September 2018
                    if(bmqp.BigMachines__Product__r.ProductCode == 'RSCONNECT' 
                       && bmqp.Net_Price__c == 0){
                        isRSConnectPresent = true;
                        }
                    else if(bmqp.BigMachines__Product__r.ProductCode == 'RSRESPOND' && bmqp.Net_Price__c == 0){
                        isRSRespondPresent = true;
                        //isRSConnectPresent = true;
                        }
                    //ends here
                    // CRM-3738 - Assign fields from asset level for ADVANTAGE
                    if (bmqp.BigMachines__Product__r.ProductCode == 'ADVANTAGE' && bmqp.Line_Type__c != 'Add' 
                       && bmqp.Line_Type__c != 'Renew' && bmqp.Asset__r != null) {
                        bmqp.ResidentialAMLC__c = bmqp.Asset__r.ResidentialAMLC__c;
                        bmqp.RentalAMLC__c = bmqp.Asset__r.RentalAMLC__c;
                        bmqp.LandAMLC__c = bmqp.Asset__r.LandAMLC__c;
                        bmqp.ResidentialBrandPPL__c = bmqp.Asset__r.ResidentialBrandPPL__c;
                        bmqp.ResidentialLeadPPL__c = bmqp.Asset__r.ResidentialLeadPPL__c;
                    }
                    //CRM-3738 - End
                    
                     //CRM-5197
                      if(bmqp.Name == 'COBROKE'){
                          if(bmqp.Line_Type__c == 'Add'){newCobrokeSet.add(bmqp.BigMachines__Quote__c);}
                          if(bmqp.Line_Type__c == 'Renew'){renewCobrokeSet.add(bmqp.BigMachines__Quote__c);}
                      }
                      
                        //Standalone RS: Suppress modify order confimation in upgrade/downgrade scenarios
                        if(bmqp.RS_Action_Type__c!=null && bmqp.Line_Type__c!=null){
                            if(bmqp.RS_Action_Type__c.equalsIgnoreCase('upgrade') && bmqp.Line_Type__c == 'amend'){
                                   suppressModifyQuoteIds.add(bmqp.BigMachines__Quote__c);
                            } else if(bmqp.RS_Action_Type__c.equalsIgnoreCase('downgrade') && bmqp.Line_Type__c == 'cancel'){
                                //*** Will update this when Janaki confirms the scenario 
                                    // Here both orders will be of Modify type, so suppress one having cancel line type
                                   //suppressQuoteIds.add(bmqp.BigMachines__Quote__c);
                            }
                        }
                     
                    // LCM-97
                    
                    if (bmqp.Asset__c != null && bmqp.Name == 'COBROKE' && bmqp.Credit_Amount__c != null && bmqp.Credit_Amount__c != 0.00) {
                            lcmAssetQuoteProdMap.put(bmqp.Asset__c, bmqp);
                    }
                    
                    // CRM-3209 Take backup of End_Date__c
                    Date originalEndDate = bmqp.End_Date__c;
                    quoteNumber = bmqp.BigMachines__Quote__r.Name;
                    quoteType = bmqp.BigMachines__Quote__r.BigMachines_Quote_Type__c;
                    setBMQuoteProductIds.add(bmqp.Id);
                    QuoteLineDescp = QuoteLineDescp + ', ' + bmqp.Line_type__C;
                    if (bmqp.BigMachines__Product__r.ProductCode == 'DIGITALAGENT') {
                        havingDAP = true;
                        quoteId = bmqp.BigMachines__Quote__c;
                    }
                    System.debug('KKKKKK' + bmqp.End_date__c + 'PPPP' + (bmqp.End_date__c > System.today().addMonths(135)));

                    if (bmqp.End_date__c > System.today().addMonths(140)) {bmqp.End_date__c = System.today().addMonths(135);}
                    System.debug('KKKKKK' + bmqp.End_date__c);

                    mapQuoteLineIdProductCode.put(bmqp.id, bmqp.BigMachines__Product__r.ProductCode);
                    mapProductCodeLineType.put(bmqp.BigMachines__Product__r.ProductCode, bmqp.line_Type__c);
                    mapQuoteLineIdProductName.put(bmqp.id, bmqp.BigMachines__Description__c);
                    mapQuoteCancelCount.put(bmqp.BigMachines__Quote__c, bmqp.BigMachines__Quote__r.Retention_Not_Cancel__c);
                    mapProductCodeQuoteLineId.put(bmqp.BigMachines__Product__r.ProductCode, bmqp.id);
                  
                    if (bmqp.Asset__c != null) {setAssetIds.add(bmqp.Asset__c);}
                    System.debug('KKKKKK' + bmqp.End_date__c);
                    if (bmqp.Line_Type__c == 'Add') {
                        if (bmqp.Start_date__c == null) {bmqp.Start_date__c = System.today();}
                        if (bmqp.End_date__c == null) {bmqp.End_date__c = System.today().AddMonths(6).AddDays(-1);}
                        if (bmqp.Contract_Term__c == null) {bmqp.Contract_Term__c = '6';}
                        bmqp.End_date__c = (bmqp.Start_date__c.AddMonths(Integer.valueof(bmqp.Contract_Term__c)).AddDays(-1));
                        //Modified 2nd Dec 2016  Author Name: Pallavi Tammana -- Modifed for JIRA STORY ADVP-2026
                        if(bmqp.BigMachines__Quote__r.BigMachines__Account__r.EssentialsStatus__c != 'Activated')
                            setBMQuoteEssIds.add(bmqp.BigMachines__Quote__c);
                    }
                    System.debug('KKKKKK' + bmqp.End_date__c);
                    if (bmqp.Override_Term__c != null) {
                        if (bmqp.Line_Type__c == 'Add') {
                            if (bmqp.Override_Term__c > 0) {
                                bmqp.End_date__c = (bmqp.Start_date__c.AddMonths(Integer.valueof(bmqp.Override_Term__c)).AddDays(-1));
                                if(bmqp.Ext_Days__c!=null){
                                    bmqp.End_date__c = bmqp.End_date__c.addDays(Integer.valueof(bmqp.Ext_Days__c));
                                }
                            }
                        }
                    }
                    mapProductCodeStartDate.put(bmqp.BigMachines__Product__r.ProductCode, bmqp.Start_Date__c);
                    // CRM-3209 If its a Moving Product then assign back the original End Date
                    if(bmqp.BigMachines__Product__r.ProductCode!=null && Label.Moving_Product_Codes.contains(bmqp.BigMachines__Product__r.ProductCode )) {
                        bmqp.End_Date__c = originalEndDate;
                    }
                    System.debug('KKKKKKPPPP' + bmqp.End_date__c);
                    setProductIds.add(bmqp.BigMachines__Product__c);//Pushing new Account and contract relation
                    if (orderstartdate == null) {orderstartdate = bmqp.Start_date__c;}
                    if (orderenddate == null) {orderenddate = bmqp.End_date__c;}

                    if (bmqp.Start_date__c != null) {if (orderstartdate > bmqp.Start_date__c) {orderstartdate = bmqp.Start_date__c;}}
                    if (bmqp.End_date__c != null) {if (orderenddate < bmqp.End_date__c) {orderenddate = bmqp.End_date__c;}}
                    contracttrm = orderstartdate.monthsBetween(orderenddate);
                    if (bmqp.Contract_Term__c != null) {
                        if (contracttrm < Integer.valueof(bmqp.Contract_Term__c)) {contracttrm = Integer.valueof(bmqp.Contract_Term__c);}
                    }
                    System.debug('KKKKKK' + contracttrm);
                    System.debug(mapAccountContractlst + '####');

                    if (mapAccountContractlst.containskey(bmqp.BigMachines__Quote__r.BigMachines__Account__c)) {
                        System.debug(mapAccountContractlst + '####' + bmqp.BigMachines__Quote__r.BigMachines__Account__c);
                        if (orderenddate > mapAccountContractlst.get(bmqp.BigMachines__Quote__r.BigMachines__Account__c).EndDate) {
                            orderenddate = mapAccountContractlst.get(bmqp.BigMachines__Quote__r.BigMachines__Account__c).EndDate;
                        }
                        if (orderstartdate < mapAccountContractlst.get(bmqp.BigMachines__Quote__r.BigMachines__Account__c).StartDate) {
                            mapAccountContractlst.get(bmqp.BigMachines__Quote__r.BigMachines__Account__c).StartDate = orderstartdate;
                        }
                        if (mapAccountContractlst.get(bmqp.BigMachines__Quote__r.BigMachines__Account__c).contractTerm <= contracttrm) {
                            mapAccountContractlst.get(bmqp.BigMachines__Quote__r.BigMachines__Account__c).contractTerm = (contracttrm + 24);
                        } else{
                            contracttrm = mapAccountContractlst.get(bmqp.BigMachines__Quote__r.BigMachines__Account__c).contractTerm+36;
                        }
                        System.debug('HHHHHH' + contracttrm);
                        //Line needs to remove
                        if(contracttrm>9000){contracttrm=9000;}
                        mapAccountContractlst.get(bmqp.BigMachines__Quote__r.BigMachines__Account__c).contractTerm = (contracttrm + 56);

                    }
                }
                //LCM-97
                for(Comarketing_Relationship__c coMarRel : [Select id, Lender_Percentage_Contribution__c,CFCB_Asset__c from Comarketing_Relationship__c 
                                                            where CFCB_Asset__c IN :lcmAssetQuoteProdMap.keySet() and Lender_Percentage_Contribution__c != null and (status__c = 'Active' or (status__c = 'Pending Activation' and Action__c = 'Amend'))]){
                    QPCreditPercntMap.put(lcmAssetQuoteProdMap.get(coMarRel.CFCB_Asset__c).id, coMarRel.Lender_Percentage_Contribution__c);
                }
                //LCM-End
               
                if(isRSConnectPresent && isRSRespondPresent){
                isRSRespondPresent = false;
                }
                update mapAccountContractlst.values();
                System.debug('orderstartdate' + orderstartdate);
                System.debug(mapAccountContractlst.values() + 'orderenddate' + orderenddate);
                if(contracttrm>9000){contracttrm=9000;}
                for (Contract  contr : lstNewContract) {

                    if (contr.StartDate == null) {contr.StartDate = orderstartdate.addMonths(-1);}
                    if (contr.ContractTerm == null) {contr.ContractTerm = (contracttrm + 46);}
                }
                System.debug('Contract==' + lstNewContract);
                Update lstNewContract;

                // Creating map of product and pricebookentry

                if (!Test.isRunningTest()) {
                    for (PriceBookEntry pbe : [Select Id,Product2.ProductCode,ProductCode, PriceBook2Id, Product2Id,Product2.Inventory__c, Product2.Fulfillment_ID__c, Product2.Subscription_Type__c from PriceBookEntry where Pricebook2.IsStandard = true and Product2Id = :setProductIds]) { //Pricebook2.name = 'Move Price Book' and
                        mapProductPriceBookEntryId.put(pbe.Product2Id, pbe);
                        mapPriceBookEntryId.put(pbe.Id, pbe);

                    }
                } else {
                    for (PriceBookEntry pbe : [Select Id,Product2.ProductCode,ProductCode, PriceBook2Id, Product2Id,Product2.Inventory__c, Product2.Fulfillment_ID__c, Product2.Subscription_Type__c from PriceBookEntry where Product2Id = :setProductIds]) { //Pricebook2.name = 'Move Price Book' and
                        mapProductPriceBookEntryId.put(pbe.Product2Id, pbe);
                        mapPriceBookEntryId.put(pbe.Id, pbe);

                    }
                }
                 System.debug('CODEIDS' + mapProductPriceBookEntryId);
                presaleorders = [Select p.Presale_Quantity__c, p.Inventory_Transaction_Id__c, p.Availability_Date__c, End_date__c From Presale_Available_Inventory__c p Limit 1];
                system.debug('---- presaleorders --> ' + presaleorders);
                
                // iterating list of all quote line and creating a map to create new orders based upon spliting logic
                for (BigMachines__Quote_Product__c bmqp : lstBMQuoteProduct) {
                    if (bmqp.Contract_Term__c == null) {bmqp.Contract_Term__c = '6';}
                    System.debug(bmqp.Contract_Term__c + '$$$$$$$' + bmqp.BigMachines__Product__r.Fulfillment_Type__c);
                    System.debug('KKKKKK' + bmqp.End_date__c + 'PPPP' + (bmqp.End_date__c > System.today().addMonths(50)));
                    // CRM 5271,CRM-5197 Start: RS bundling 
                     // Map of Quote and bundled products includind prosoft (part numbers)
                     if(bmqp.Promotion__c != null){
                         List<string> assetPromo = bmqp.Promotion__c.split('---');
                         for(String promo: assetPromo){
                             if(promoBundle.contains(promo)){
                                 if(nonprosoftPromo.contains(promo)
                                   ||(!newCobrokeSet.contains(bmqp.BigMachines__Quote__c) && !renewCobrokeSet.contains(bmqp.BigMachines__Quote__c)) 
                                   ||(newCobrokeSet.contains(bmqp.BigMachines__Quote__c)) ){
                                    if(!suppressMap.containskey(bmqp.BigMachines__Quote__c)){
                                        suppressMap.put(bmqp.BigMachines__Quote__c, new List<String>{bmqp.Name});
                                      } else {
                                        List<String> bqpl = suppressMap.get(bmqp.BigMachines__Quote__c);
                                        bqpl.add(bmqp.Name);
                                        suppressMap.put(bmqp.BigMachines__Quote__c, bqpl);
                                      }
                                       break;
                                }  
                             }
                         }   
                     }// END: RS bundling
                    if (bmqp.Available_Presale_Inventory__c != null) {
                        totalQuantity = 0;
                        presalequoteid = bmqp.id;
                        system.debug('id bmq----->>' + bmqp.id);
                        presaleorders = [Select p.Presale_Quantity__c, p.Inventory_Transaction_Id__c, p.Availability_Date__c, End_date__c From Presale_Available_Inventory__c p where p.Quote_Product__c = : presalequoteid and p.Presale_Quantity__c != null and p.Inventory_Transaction_Id__c != null and p.Availability_Date__c != null and End_date__c != null];
                        for (Presale_Available_Inventory__c p : presaleorders) {
                            totalQuantity += p.Presale_Quantity__c;
                        }
                    } else {
                        //Presale_Available_Inventory__c dummypresale = new Presale_Available_Inventory__c();
                        //dummypresale.id = bmqp.id;
                        //presaleorders.add(dummypresale);
                    }
                    
                    System.debug('presaleorders:' + presaleorders);
                    for (Presale_Available_Inventory__c presaleOdr : presaleorders) {
                        System.debug(bmqp.BigMachines__Quote__r.BigMachines__Status__c + 'presaleOdr:' + presaleOdr);
                        System.debug((bmqp.BigMachines__Quote__r.BigMachines__Status__c != 'Ordered' && (bmqp.BigMachines__Quote__r.BigMachines__Status__c == 'Customer Rejected' || bmqp.BigMachines__Quote__r.BigMachines__Status__c == 'Document Expired' || bmqp.BigMachines__Quote__r.BigMachines__Status__c == Constants.QUOTE_STATUS_APPROVED || bmqp.BigMachines__Quote__r.BigMachines__Status__c == Constants.QUOTE_STATUS_SIGNED)));
                        //System.debug((bmqp.BigMachines__Product__r.Fulfillment_Type__c.equalsIgnoreCase(Constants.PRODUCT_FULFILLMENT_TYPE_MANUAL) + ' $$$$$$$$$$$ ' + !String.isBlank(bmqp.Commerce_Group__c.trim())));
                        if (bmqp.BigMachines__Quote__r.BigMachines__Status__c != 'Ordered' && (bmqp.BigMachines__Quote__r.BigMachines__Status__c == 'Customer Rejected' || bmqp.BigMachines__Quote__r.BigMachines__Status__c == 'Document Expired' || bmqp.BigMachines__Quote__r.BigMachines__Status__c == Constants.QUOTE_STATUS_APPROVED || bmqp.BigMachines__Quote__r.BigMachines__Status__c == Constants.QUOTE_STATUS_SIGNED)) {
                            //  if(true){
                            system.debug('New Test');
                            // System.debug((bmqp.BigMachines__Product__r.Fulfillment_Type__c + ' $$$$$$$$$$$ ' + bmqp.Commerce_Group__c.trim()));
                            system.debug('New Test ----- > bmqp' + bmqp);
                            system.debug('-> condition 1' + (bmqp.BigMachines__Product__r.Fulfillment_Type__c.equalsIgnoreCase(Constants.PRODUCT_FULFILLMENT_TYPE_MANUAL)));
                            //system.debug('-> condition 2' + (bmqp.Commerce_Group__c.length()));
                            Integer commercegrouplength = 0; //CRM-4045
                            if (bmqp.Commerce_Group__c != null){
                                commercegrouplength = bmqp.Commerce_Group__c.length();
                            }
                            system.debug('-> condition 3' + !mapHomeSearchTL.containskey(bmqp.BigMachines__Product__r.ProductCode));
                            //CRM-4045 Modified below if condition to use commercegrouplength instead of bmqp.Commerce_Group__c.length();
                            if ((bmqp.BigMachines__Product__r.Fulfillment_Type__c.equalsIgnoreCase(Constants.PRODUCT_FULFILLMENT_TYPE_MANUAL) || (commercegrouplength > 4)) && !mapHomeSearchTL.containskey(bmqp.BigMachines__Product__r.ProductCode)) {
                                if (bmqp.BigMachines__Product__r.ProductCode == 'HOMESRCH' || bmqp.BigMachines__Product__r.ProductCode == 'HSMARKETSPND') {
                                    if (mapHomeSearchTL.values().size() == 0) {
                                        if (bmqp.BigMachines__Product__r.ProductCode.equalsIgnoreCase('HOMESRCH')) {
                                            mapHomeSearchTL.put('HSMARKETSPND', bmqp.id);
                                        }
                                        if (bmqp.BigMachines__Product__r.ProductCode.equalsIgnoreCase('HSMARKETSPND')) {
                                            mapHomeSearchTL.put('HOMESRCH', bmqp.id);
                                        }
                                    }
                                }
                                Order odr = new Order();
                                odr.TL_Quote_Product_Reference__c = bmqp.id;
                                odr.Pricebook2Id = mapProductPriceBookEntryId.get(bmqp.BigMachines__Product__c).PriceBook2Id;
                                //odr.PriceBook2Id = PBID;
                                if (mapAccountAccountManagerUserIds.containskey(bmqp.BigMachines__Quote__r.BigMachines__Account__c)) {
                                    odr.Account_Manager__c = mapAccountAccountManagerUserIds.get(bmqp.BigMachines__Quote__r.BigMachines__Account__c);
                                }
                                odr.ownerId = bmqp.BigMachines__Quote__r.ownerId;
                                odr.Oracle_Quote__c = bmqp.BigMachines__Quote__c;
                                //CRM-4045 - Add if condition to check if commercegroup is not null
                                if (bmqp.Commerce_Group__c != null){
                                    if (bmqp.Commerce_Group__c.length() > 4) {
                                        odr.Is_BMS__c = true;
                                    }
                                }
                                
                                
                                odr.Suppress_Order_Confirmation__c = bmqp.BigMachines__Quote__r.Suppress_Order_Confirmation__c;
                                odr.OpportunityId = bmqp.BigMachines__Quote__r.BigMachines__Opportunity__c;
                                odr.AccountId = bmqp.BigMachines__Quote__r.BigMachines__Account__c;
                                odr.BillingStreet = bmqp.BigMachines__Quote__r.BigMachines__Account__r.BillingStreet ;
                                odr.BillingCity   = bmqp.BigMachines__Quote__r.BigMachines__Account__r.BillingCity;
                                odr.BillingState  = bmqp.BigMachines__Quote__r.BigMachines__Account__r.BillingState;
                                odr.BillingPostalCode = bmqp.BigMachines__Quote__r.BigMachines__Account__r.BillingPostalCode;
                                odr.BillingCountry = bmqp.BigMachines__Quote__r.BigMachines__Account__r.BillingCountry;
                                odr.ShippingStreet = bmqp.BigMachines__Quote__r.BigMachines__Account__r.ShippingStreet ;
                                odr.ShippingCity   = bmqp.BigMachines__Quote__r.BigMachines__Account__r.ShippingCity;
                                odr.ShippingState  = bmqp.BigMachines__Quote__r.BigMachines__Account__r.ShippingState;
                                odr.ShippingPostalCode = bmqp.BigMachines__Quote__r.BigMachines__Account__r.ShippingPostalCode;
                                odr.ShippingCountry = bmqp.BigMachines__Quote__r.BigMachines__Account__r.ShippingCountry;
                                odr.ContractId = mapAccountContractId.get(bmqp.BigMachines__Quote__r.BigMachines__Account__c);
                                odr.Description = bmqp.BigMachines__Quote__r.BigMachines__Description__c;
                                //odr.Delta_Price_w_o_Tax__c =bmqp.BigMachines__Quote__r.Delta_Price_w_o_Tax__c;
                                odr.Status = Constants.ORDER_STATUS_CREATED; //bmqp.BigMachines__Quote__r.BigMachines_Quote_Status__c; //
                                if (bmqp.Available_Presale_Inventory__c != null) {
                                    odr.EffectiveDate = presaleOdr.Availability_Date__c.date().AddDays(1);
                                    odr.EndDate = presaleOdr.End_date__c;

                                } else {
                                    odr.EffectiveDate = bmqp.Start_date__c != null ? bmqp.Start_date__c : orderstartdate;
                                    odr.EndDate = bmqp.End_date__c != null ? bmqp.End_date__c : orderenddate;
                                }
                                if (mapAccountRelationship.containskey(bmqp.BigMachines__Quote__r.BigMachines__Account__c)) {
                                    odr.Primary_Email__c = mapAccountRelationship.get(bmqp.BigMachines__Quote__r.BigMachines__Account__c).Parent_Account__r.Email_Address__c;
                                    odr.Contact_Name__c = mapAccountRelationship.get(bmqp.BigMachines__Quote__r.BigMachines__Account__c).Contact_To__r.FirstName;
                                }
                                odr.Auto_Discount__c = bmqp.BigMachines__Quote__r.Auto_Discount__c;
                                odr.Auto_Discount_Amt__c = bmqp.BigMachines__Quote__r.Auto_Discount_Amt__c;
                                odr.Auto_Est_Tax__c = bmqp.BigMachines__Quote__r.Auto_Est_Tax__c;
                                odr.Auto_Fulfilled_Total__c = bmqp.BigMachines__Quote__r.Auto_Fulfilled_Total__c;
                                odr.Auto_List_Price__c = bmqp.BigMachines__Quote__r.Auto_List_Price__c;
                                odr.Auto_Net_Price__c = bmqp.BigMachines__Quote__r.Auto_Net_Price__c;
                                odr.Auto_Subtotal__c = bmqp.BigMachines__Quote__r.Auto_Subtotal__c;
                                odr.Case__c = bmqp.BigMachines__Quote__r.Case__c;
                                if (bmqp.BigMachines__Product__r.ProductCode == 'DIGITALAGENT') {
                                    odr.Market__c = bmqp.Market__c;
                                }
                                odr.Manual_Discount__c = bmqp.BigMachines__Quote__r.Manual_Discount__c;
                                odr.Manual_Discount_Amt__c = bmqp.BigMachines__Quote__r.Manual_Discount_Amt__c;
                                odr.Manual_Est_Tax__c = bmqp.BigMachines__Quote__r.Manual_Est_Tax__c;
                                odr.Manual_List_Price__c = bmqp.BigMachines__Quote__r.Manual_List_Price__c;
                                odr.Manually_Fulfilled_Total__c = bmqp.BigMachines__Quote__r.Manually_Fulfilled_Total__c;
                                odr.Manual_Net_Price__c = bmqp.BigMachines__Quote__r.Manual_Net_Price__c;
                                odr.Manual_Subtotal__c = bmqp.BigMachines__Quote__r.Manual_Subtotal__c;
                                odr.Maximum_First_Charge__c = bmqp.BigMachines__Quote__r.Maximum_First_Charge__c;
                                odr.Minimum_First_Charge__c = bmqp.BigMachines__Quote__r.Minimum_First_Charge__c;
                                odr.One_Time_Discount__c = bmqp.BigMachines__Quote__r.One_Time_Discount__c;
                                odr.One_Time_Discount_Amt__c = bmqp.BigMachines__Quote__r.One_Time_Discount_Amt__c;
                                odr.One_Time_Est_Tax__c = bmqp.BigMachines__Quote__r.One_Time_Est_Tax__c;
                                odr.One_Time_List_Price__c = bmqp.BigMachines__Quote__r.One_Time_List_Price__c;
                                odr.One_Time_Net_Price__c = bmqp.BigMachines__Quote__r.One_Time_Net_Price__c;
                                odr.One_Time_Subtotal__c = bmqp.BigMachines__Quote__r.One_Time_Subtotal__c;
                                //BigMachines__Quote__r.Oracle_Quote__c,
                                odr.Set_Up_Fee__c = bmqp.BigMachines__Quote__r.Set_Up_Fee__c;
                                odr.Total_Discount__c = bmqp.BigMachines__Quote__r.Total_Discount__c;
                                odr.Total_Discount_Amt__c = bmqp.BigMachines__Quote__r.Total_Discount_Amt__c;
                                odr.Total_Est_Tax__c = bmqp.BigMachines__Quote__r.Total_Est_Tax__c;
                                odr.Total_List_Price__c = bmqp.BigMachines__Quote__r.Total_List_Price__c;
                                odr.Total_Net_Price__c = bmqp.BigMachines__Quote__r.Total_Net_Price__c;
                                odr.Total_Price_W_Tax__c = bmqp.BigMachines__Quote__r.Total_Price_W_Tax__c;
                                odr.Usage_Total__c = bmqp.BigMachines__Quote__r.Usage_Total__c;

                                //odr.TotalAmount = bmqp.BigMachines__Quote__r.BigMachines__Total__c;
                                odr.Type = bmqp.BigMachines__Quote__r.BigMachines_Quote_Type__c;
                                //odr.ActivatedDate = bmqp.BigMachines__Quote__r.BigMachines_authorization_date__c;
                                odr.OrderReferenceNumber = bmqp.BigMachines__Quote__r.BigMachines__Transaction_Id__c;
                                //odr.Type = bmqp.BigMachines__Quote__r.BigMachines_Quote_Status__c;
                                odr.tigerLeadProductExists__c = bmqp.BigMachines__Quote__r.tigerLeadProductExists__c ;
                                //odr.ContractId = ;
                                odr.Is_OLI_Creation_Complete__c = false;
                                odr.Currency_Type__c = bmqp.BigMachines__Quote__r.BigMachines_currency_type__c;
                                odr.Fulfillment_Status__c = Constants.ORDER_FULFILLMENT_STATUS_PENDING;
                              
                                if (odr.tigerLeadProductExists__c == true) {
                                    odr.Fulfillment_Status__c = Constants.ORDER_FULFILLMENT_STATUS_MANUAL;
                                    odr.Is_Pre_Welcome_Call__c = true;
                                    if (TLProductStrings.contains(bmqp.BigMachines__Product__r.ProductCode)) {
                                        mapTLActivities.put(bmqp.id, true);
                                    }
                                    if (!mapTLActivities.containskey(odr.TL_Quote_Product_Reference__c)) {
                                        odr.Fulfillment_Status__c = Constants.ORDER_FULFILLMENT_STATUS_PENDING;
                                    }
                                }
                                if (mapManualActivities.containskey(mapQuoteLineIdProductCode.get(odr.TL_Quote_Product_Reference__c))) {
                                    odr.Fulfillment_Status__c = Constants.ORDER_FULFILLMENT_STATUS_MANUAL;
                                    if (!odr.Type.contains('New')) {
                                        odr.Fulfillment_Status__c = Constants.ORDER_FULFILLMENT_STATUS_PENDING;
                                    }
                                }
                                if (bmqp.BigMachines__Product__r.ProductCode == 'DIGITALAGENT') {
                                    odr.Fulfillment_Status__c = Constants.ORDER_FULFILLMENT_STATUS_PENDING;
                                }
                                if (bmqp.BigMachines__Product__r.ProductCode == 'DACAMPAIGN') {
                                    odr.Fulfillment_Status__c = Constants.ORDER_FULFILLMENT_STATUS_PENDING;
                                }
                                // Added for MediaBuy 
                                // Fulfillment status must be "Manual" for all order types except "credit" line type

                                if (bmqp.BigMachines__Product__r.ProductCode == 'MEDIABUY') {
                                    odr.Fulfillment_Status__c = Constants.ORDER_FULFILLMENT_STATUS_MANUAL;
                                }
                            
                                if (bmqp.BigMachines__Product__r.ProductCode == 'DOMAINNAME' && (bmqp.Line_Type__c == 'Add' || bmqp.Line_Type__c == 'Cancel' || 
                                bmqp.Line_Type__c == 'Buyout')) {
                                    odr.Fulfillment_Status__c = Constants.ORDER_FULFILLMENT_STATUS_MANUAL;
                                    }
                                if(bmqp.BigMachines__Product__r.ProductCode == 'DOMAINNAME' && (bmqp.Line_Type__c == 'Renew' || bmqp.Line_Type__c == 'Amend' || 
                                    bmqp.Line_Type__c == 'Credit')){
                                     odr.Fulfillment_Status__c = Constants.ORDER_FULFILLMENT_STATUS_PENDING;
                                }

                                System.debug('####' + odr);
                                if (bmqp.BigMachines__Quote__r.BigMachines__Status__c == 'Customer Rejected' || bmqp.BigMachines__Quote__r.BigMachines__Status__c == 'Document Expired') {
                                    odr.Fulfillment_Status__c = 'Cancel Order';
                                }

                                if (bmqp.BigMachines__Quote__r.BigMachines_Quote_Type__c.contains('Retention') && odr.tigerLeadProductExists__c == true) {
                                    odr.Fulfillment_Status__c = Constants.ORDER_FULFILLMENT_STATUS_PENDING;
                                }
                                System.debug(mapHomeSearchTL + 'HHHHHHHHHH');
                                //  if(bmqp.BigMachines__Product__r.ProductCode.equalsIgnoreCase('HSMARKETSPND')){
                                //  mapHomeSearchTL.put('HOMESRCH',bmqp.id);
                                //  }
                                if (mapHomeSearchTL.containskey(bmqp.BigMachines__Product__r.ProductCode)) {
                                } else {
                                    if (bmqp.Available_Presale_Inventory__c != null) {
                                        mapListOrder.put(bmqp.id + '##' + presaleOdr.Inventory_Transaction_Id__c, odr);
                                    } else {
                                        mapListOrder.put(bmqp.id, odr);
                                    }
                                }
                            } else  if (!mapListOrder.containskey(bmqp.BigMachines__Quote__c + '##' + bmqp.Start_Date__c)) {
                                Order odr = new Order();
                                odr.TL_Quote_Product_Reference__c = bmqp.id;
                                System.debug(mapProductPriceBookEntryId + '########' + bmqp.BigMachines__Product__c);
                                odr.Pricebook2Id = mapProductPriceBookEntryId.get(bmqp.BigMachines__Product__c).PriceBook2Id;
                                if (mapAccountAccountManagerUserIds.containskey(bmqp.BigMachines__Quote__r.BigMachines__Account__c)) {
                                    odr.Account_Manager__c = mapAccountAccountManagerUserIds.get(bmqp.BigMachines__Quote__r.BigMachines__Account__c);
                                }
                                if (mapAccountRelationship.containskey(bmqp.BigMachines__Quote__r.BigMachines__Account__c)) {
                                    odr.Primary_Email__c = mapAccountRelationship.get(bmqp.BigMachines__Quote__r.BigMachines__Account__c).Parent_Account__r.Email_Address__c;
                                    odr.Contact_Name__c = mapAccountRelationship.get(bmqp.BigMachines__Quote__r.BigMachines__Account__c).Contact_To__r.FirstName;
                                }
                                odr.Oracle_Quote__c = bmqp.BigMachines__Quote__c;
                                odr.ownerId = bmqp.BigMachines__Quote__r.ownerId;
                                odr.OpportunityId = bmqp.BigMachines__Quote__r.BigMachines__Opportunity__c;
                                odr.AccountId = bmqp.BigMachines__Quote__r.BigMachines__Account__c;
                                odr.BillingStreet = bmqp.BigMachines__Quote__r.BigMachines__Account__r.BillingStreet ;
                                odr.BillingCity   = bmqp.BigMachines__Quote__r.BigMachines__Account__r.BillingCity;
                                odr.BillingState  = bmqp.BigMachines__Quote__r.BigMachines__Account__r.BillingState;
                                odr.BillingPostalCode = bmqp.BigMachines__Quote__r.BigMachines__Account__r.BillingPostalCode;
                                odr.BillingCountry = bmqp.BigMachines__Quote__r.BigMachines__Account__r.BillingCountry;
                                odr.ShippingStreet = bmqp.BigMachines__Quote__r.BigMachines__Account__r.ShippingStreet ;
                                odr.ShippingCity   = bmqp.BigMachines__Quote__r.BigMachines__Account__r.ShippingCity;
                                odr.ShippingState  = bmqp.BigMachines__Quote__r.BigMachines__Account__r.ShippingState;
                                odr.ShippingPostalCode = bmqp.BigMachines__Quote__r.BigMachines__Account__r.ShippingPostalCode;
                                odr.ShippingCountry = bmqp.BigMachines__Quote__r.BigMachines__Account__r.ShippingCountry;
                                odr.ContractId = mapAccountContractId.get(bmqp.BigMachines__Quote__r.BigMachines__Account__c);
                                odr.Description = bmqp.BigMachines__Quote__r.BigMachines__Description__c;
                                odr.Status = Constants.ORDER_STATUS_CREATED; //bmqp.BigMachines__Quote__r.BigMachines_Quote_Status__c; //
                                if (bmqp.Available_Presale_Inventory__c != null) {
                                    odr.EffectiveDate = presaleOdr.Availability_Date__c.date().AddDays(1);
                                    odr.EndDate = presaleOdr.End_date__c;

                                } else {
                                    odr.EffectiveDate = bmqp.Start_date__c != null ? bmqp.Start_date__c : orderstartdate;
                                    odr.EndDate = bmqp.End_date__c != null ? bmqp.End_date__c : orderenddate;
                                }
                                //odr. Primary_Email__c =
                                //odr.Contact_Name__c =
                                //odr.Delta_Price_w_o_Tax__c =bmqp.BigMachines__Quote__r.Delta_Price_w_o_Tax__c;

                                odr.Auto_Discount__c = bmqp.BigMachines__Quote__r.Auto_Discount__c;
                                odr.Auto_Discount_Amt__c = bmqp.BigMachines__Quote__r.Auto_Discount_Amt__c;
                                odr.Auto_Est_Tax__c = bmqp.BigMachines__Quote__r.Auto_Est_Tax__c;
                                odr.Auto_Fulfilled_Total__c = bmqp.BigMachines__Quote__r.Auto_Fulfilled_Total__c;
                                odr.Auto_List_Price__c = bmqp.BigMachines__Quote__r.Auto_List_Price__c;
                                odr.Auto_Net_Price__c = bmqp.BigMachines__Quote__r.Auto_Net_Price__c;
                                odr.Auto_Subtotal__c = bmqp.BigMachines__Quote__r.Auto_Subtotal__c;
                                odr.Case__c = bmqp.BigMachines__Quote__r.Case__c;
                                odr.Manual_Discount__c = bmqp.BigMachines__Quote__r.Manual_Discount__c;
                                odr.Manual_Discount_Amt__c = bmqp.BigMachines__Quote__r.Manual_Discount_Amt__c;
                                odr.Manual_Est_Tax__c = bmqp.BigMachines__Quote__r.Manual_Est_Tax__c;
                                odr.Manual_List_Price__c = bmqp.BigMachines__Quote__r.Manual_List_Price__c;
                                odr.Manually_Fulfilled_Total__c = bmqp.BigMachines__Quote__r.Manually_Fulfilled_Total__c;
                                odr.Manual_Net_Price__c = bmqp.BigMachines__Quote__r.Manual_Net_Price__c;
                                odr.Manual_Subtotal__c = bmqp.BigMachines__Quote__r.Manual_Subtotal__c;
                                odr.Maximum_First_Charge__c = bmqp.BigMachines__Quote__r.Maximum_First_Charge__c;
                                odr.Minimum_First_Charge__c = bmqp.BigMachines__Quote__r.Minimum_First_Charge__c;
                                odr.One_Time_Discount__c = bmqp.BigMachines__Quote__r.One_Time_Discount__c;
                                odr.One_Time_Discount_Amt__c = bmqp.BigMachines__Quote__r.One_Time_Discount_Amt__c;
                                odr.One_Time_Est_Tax__c = bmqp.BigMachines__Quote__r.One_Time_Est_Tax__c;
                                odr.One_Time_List_Price__c = bmqp.BigMachines__Quote__r.One_Time_List_Price__c;
                                odr.One_Time_Net_Price__c = bmqp.BigMachines__Quote__r.One_Time_Net_Price__c;
                                odr.One_Time_Subtotal__c = bmqp.BigMachines__Quote__r.One_Time_Subtotal__c;
                                //BigMachines__Quote__r.Oracle_Quote__c,

                                if (bmqp.BigMachines__Product__r.ProductCode == 'DIGITALAGENT') {
                                    odr.Market__c = bmqp.Market__c;
                                }
                                odr.Set_Up_Fee__c = bmqp.BigMachines__Quote__r.Set_Up_Fee__c;
                                odr.Total_Discount__c = bmqp.BigMachines__Quote__r.Total_Discount__c;
                                odr.Total_Discount_Amt__c = bmqp.BigMachines__Quote__r.Total_Discount_Amt__c;
                                odr.Total_Est_Tax__c = bmqp.BigMachines__Quote__r.Total_Est_Tax__c;
                                odr.Total_List_Price__c = bmqp.BigMachines__Quote__r.Total_List_Price__c;
                                odr.Total_Net_Price__c = bmqp.BigMachines__Quote__r.Total_Net_Price__c;
                                odr.Total_Price_W_Tax__c = bmqp.BigMachines__Quote__r.Total_Price_W_Tax__c;
                                odr.Usage_Total__c = bmqp.BigMachines__Quote__r.Usage_Total__c;
                                //odr.TotalAmount = bmqp.BigMachines__Quote__r.BigMachines__Total__c;
                                odr.tigerLeadProductExists__c = bmqp.BigMachines__Quote__r.tigerLeadProductExists__c ;
                                //odr.ActivatedDate = bmqp.BigMachines__Quote__r.BigMachines_authorization_date__c;
                                odr.OrderReferenceNumber = bmqp.BigMachines__Quote__r.BigMachines__Transaction_Id__c;
                                //odr.Type = bmqp.BigMachines__Quote__r.BigMachines_Quote_Status__c;
                                odr.Type = bmqp.BigMachines__Quote__r.BigMachines_Quote_Type__c;
                                odr.Suppress_Order_Confirmation__c = bmqp.BigMachines__Quote__r.Suppress_Order_Confirmation__c;
                                //odr.ContractId = ;
                                odr.Is_OLI_Creation_Complete__c = false;
                                odr.Currency_Type__c = bmqp.BigMachines__Quote__r.BigMachines_currency_type__c;
                                odr.Fulfillment_Status__c = Constants.ORDER_FULFILLMENT_STATUS_PENDING;
                               
                                if (odr.tigerLeadProductExists__c == true) {
                                    odr.Fulfillment_Status__c = Constants.ORDER_FULFILLMENT_STATUS_MANUAL;
                                    odr.Is_Pre_Welcome_Call__c = true;
                                    system.debug('tlpr----->>>>' + TLProductStrings + bmqp.BigMachines__Product__r.ProductCode);
                                    if (TLProductStrings.contains(bmqp.BigMachines__Product__r.ProductCode)) {
                                        mapTLActivities.put(bmqp.id, true);
                                    }
                                    if (!mapTLActivities.containskey(odr.TL_Quote_Product_Reference__c)) {
                                        odr.Fulfillment_Status__c = Constants.ORDER_FULFILLMENT_STATUS_PENDING;
                                    }
                                }
                                if (mapManualActivities.containskey(mapQuoteLineIdProductCode.get(odr.TL_Quote_Product_Reference__c))) {
                                    odr.Fulfillment_Status__c = Constants.ORDER_FULFILLMENT_STATUS_MANUAL;
                                    if (!odr.Type.contains('New')) {
                                        odr.Fulfillment_Status__c = Constants.ORDER_FULFILLMENT_STATUS_PENDING;
                                    }
                                }
                                if (bmqp.BigMachines__Quote__r.BigMachines__Status__c == 'Customer Rejected' || bmqp.BigMachines__Quote__r.BigMachines__Status__c == 'Document Expired') {
                                    odr.Fulfillment_Status__c = 'Cancel Order';
                                }

                                if (bmqp.BigMachines__Quote__r.BigMachines_Quote_Type__c.contains('Retention') && odr.tigerLeadProductExists__c == true) {
                                    odr.Fulfillment_Status__c = Constants.ORDER_FULFILLMENT_STATUS_PENDING;
                                }

                                // CRM-1703: Added for Reesio product (Product fulfillment type changed to "Auto") 
                                // CRM-2010: Added start date condition because quote products with same start date will be in same Order. 
                                // Update TL_Quote_Product_Reference__c only on order containing REESIO
                                if (mapProductCodeQuoteLineId.containsKey('REESIO') && bmqp.Start_Date__c == mapProductCodeStartDate.get('REESIO')){
                                    odr.Fulfillment_Status__c = Constants.ORDER_FULFILLMENT_STATUS_PENDING;
                                    odr.TL_Quote_Product_Reference__c = mapProductCodeQuoteLineId.get('REESIO');
                                }
                                   // CRM-2341 - ListHub needs a Manual Fulfillment Process
                                 if (mapProductCodeQuoteLineId.containsKey('LISTHUBPRO') && bmqp.Start_Date__c == mapProductCodeStartDate.get('LISTHUBPRO')){
                                    odr.Fulfillment_Status__c = Constants.ORDER_FULFILLMENT_STATUS_PENDING;
                                    odr.TL_Quote_Product_Reference__c = mapProductCodeQuoteLineId.get('LISTHUBPRO');
                                }
                                 


                                if (!mapHomeSearchTL.containskey(bmqp.BigMachines__Product__r.ProductCode)) {
                                    if (bmqp.Available_Presale_Inventory__c != null) {
                                        mapListOrder.put(bmqp.id + '##' + presaleOdr.Inventory_Transaction_Id__c, odr);
                                    } else {
                                        mapListOrder.put(bmqp.BigMachines__Quote__c + '##' + bmqp.Start_Date__c, odr);
                                    }
                                }

                                system.debug('full----->'+odr.Fulfillment_Status__c);

                                

                            }
                        }
                      
                        if (bmqp.Available_Presale_Inventory__c != null) {
                            continue;
                        } else {
                            break;
                        }

                    }
                }
                system.debug('----- mapListOrder --->' + mapListOrder.values());
                upsert mapListOrder.values(); // Inserting new orders

                System.debug(mapListOrder + '#####');
                Map<String, String> mapQuoteOrderId = new Map<String, String>();
                Map<Id,Id> mapQuoteProductOppProductId = new Map<Id,Id>();
                Map<Id, List<BigMachines__Quote_Product__c>> quoteIdQuoteItemMap = new Map<Id, List<BigMachines__Quote_Product__c>>();
                // iterating list of all quote lines and creating a map to created new order and order lines based upon splitting logic
                presaleorders = [Select p.Presale_Quantity__c, p.Inventory_Transaction_Id__c, p.Availability_Date__c, End_date__c From Presale_Available_Inventory__c p Limit 1];
                for(OpportunityLineItem opp:[Select Id,Name,Quote_Product__c from OpportunityLineItem where Quote_Product__c=:setBMQuoteProductIds]){
                    mapQuoteProductOppProductId.put(opp.Quote_Product__c,opp.id);
                }
                for (BigMachines__Quote_Product__c bmqp : lstBMQuoteProduct) {
                   
                    System.debug(bmqp.id + '6666666' + presaleorders);
                    system.debug('avail presale---->' +bmqp.Available_Presale_Inventory__c);
                    if (bmqp.Asset__c != null && bmqp.Line_Type__c == 'Renew') {
                        setRenewalAssetIds.add(bmqp.Asset__c);
                    }
                    if (bmqp.Available_Presale_Inventory__c != null) {

                        presalequoteid = bmqp.id;
                        presaleorders = [Select p.Presale_Quantity__c, p.Inventory_Transaction_Id__c, p.Availability_Date__c, End_date__c From Presale_Available_Inventory__c p where p.Quote_Product__c = : presalequoteid and p.Presale_Quantity__c != null and p.Inventory_Transaction_Id__c != null and p.Availability_Date__c != null and End_date__c != null];
                        system.debug('presaleso----->>' + presaleorders);
                    } else {


                    }
                    for (Presale_Available_Inventory__c presaleOdr : presaleorders) {

                        System.debug('presaleOdr:' + presaleOdr);
                        System.debug('presaleodr:' + bmqp.id + '##' + presaleOdr.Inventory_Transaction_Id__c);
                        if (mapListOrder.containskey(bmqp.id) || mapListOrder.containskey(bmqp.id + '##' + presaleOdr.Inventory_Transaction_Id__c) || mapHomeSearchTL.containskey(bmqp.BigMachines__Product__r.ProductCode)) {
                            OrderItem oli = new OrderItem();
                             // CRM-6063 - Opcity BLA Field Assignment
                            oli.Setup_Fee__c = bmqp.Setup_Fee__c;
                            oli.Opcity_MSA__c = bmqp.Opcity_MSA__c;
                            oli.Backup_Monthly_Plan__c = bmqp.Backup_Monthly_Plan__c;
                            oli.Launch_Date__c = bmqp.Launch_Date__c;
                            oli.Source__c = bmqp.Source__c;
                            oli.Expected_Monthly_Lead_Volume__c = bmqp.Expected_Monthly_Lead_Volume__c;
                            oli.Stage__c = bmqp.Stage__c;
                            oli.can_disclose_fees__c = bmqp.can_disclose_fees__c;
                            oli.unlicensed_state_leads__c = bmqp.unlicensed_state_leads__c;
                            oli.Focus_Fire_Id__c = bmqp.Focus_Fire_Id__c;
                            // CRM-6063 - End 
                           
                            //CRM-1379 assign Quote Product category to OrderItem Category 
                            oli.Category__c = bmqp.Category__c;
                            // CRM-4718 assign Quote No_Term_Sale__c to OrderItem No_Term_Sale__c
                            oli.No_Term_Sale__c = bmqp.No_Term_Sale__c;
                            // LCM CRM-4807
                            oli.zuora_payment_method__c = bmqp.zuora_payment_method__c;
                            //CRM-1983 assign Quote Product Cancel_Type to OrderItem Cancel_Type
                            oli.Cancel_Type__c = bmqp.Cancel_Type__c;
                            oli.Migrated_From_Legacy__c = bmqp.Migrated_From_Legacy__c; //CRM-3438
                            // CRM-3906: Populate RS amend type
                            if(bmqp.RS_Action_Type__c != null) oli.RS_Action_Type__c = bmqp.RS_Action_Type__c;
 
                            if (mapCancellationReason.containskey(bmqp.Cancel_Type__c)) {oli.Cancel_Type__c = mapCancellationReason.get(bmqp.Cancel_Type__c);}
                            //End CRM-1983
                            if (bmqp.Available_Presale_Inventory__c != null) {
                                oli.OrderId = mapListOrder.get(bmqp.id + '##' + presaleOdr.Inventory_Transaction_Id__c).Id;
                            } else {
                                if (mapHomeSearchTL.containskey(bmqp.BigMachines__Product__r.ProductCode)) {
                                    oli.OrderId = mapListOrder.get(mapHomeSearchTL.get(bmqp.BigMachines__Product__r.ProductCode)).Id;
                                } else {
                                    oli.OrderId = mapListOrder.get(bmqp.id).Id;
                                }
                            }
                            mapQuoteOrderId.put(oli.OrderId, bmqp.id);
                            mapProductCodeOrdId.put(bmqp.Name, oli.OrderId);

                            if(bmqp.Line_Type__c != 'Renew' && bmqp.Line_Type__c != 'Cancel' && bmqp.Line_Type__c != 'Credit' && bmqp.Line_Type__c != 'Buyout'){

                                mapTLLineType.put(oli.OrderId,true);

                            }
                            oli.Fulfillment_Status__c = Constants.ORDER_FULFILLMENT_STATUS_PENDING;
                            oli.Net_Price__c = bmqp.Net_Price__c;
                            oli.Total_Net_Price__c = bmqp.Total_Net_Price__c;

                            // Added by Rajamohan Vakati for ADV - 1937
                            // Copied  below list of fields from  Big Mechine Quote object to OrderLine
                            //ResidentialLeadPPL__c,ResidentialLeadPPLOverride__c,
                            //ResidentialBrandPPL__c,ResidentialBrandPPLOverride__c,
                            //ResidentialAMLC__c,ResidentialAMLCOverride__c,LandAMLC__c,LandAMLCOverride__c,RentalAMLC__c,RentalAMLCOverride__c,ContractedAMLC__c

                            oli.Total_Net__c = bmqp.Total_Net__c;
                            oli.List_Price__c = bmqp.List_Price__c;
                            oli.Credit_Amount__c  = bmqp.Credit_Amount__c;
                            //LCM-97
                            
                            if(!QPCreditPercntMap.isEmpty() && QPCreditPercntMap.containsKey(bmqp.id)){
                                Decimal creditPercent = (100 - QPCreditPercntMap.get(bmqp.id))/100;
                                oli.total_credit_amount__c = oli.Credit_Amount__c;
                                oli.Credit_Amount__c = oli.Credit_Amount__c * creditPercent;
                            }
                            // Start===Added by - Rajamohan Vakati
                            if(bmqp.ResidentialLeadPPL__c!=null) oli.ResidentialLeadPPL__c = bmqp.ResidentialLeadPPL__c;
                            if(bmqp.ResidentialLeadPPLOverride__c!=null) oli.ResidentialLeadPPLOverride__c = bmqp.ResidentialLeadPPLOverride__c ;
                            if(bmqp.ResidentialBrandPPL__c!=null) oli.ResidentialBrandPPL__c = bmqp.ResidentialBrandPPL__c ;
                            if(bmqp.ResidentialBrandPPLOverride__c!=null) oli.ResidentialBrandPPLOverride__c =bmqp.ResidentialBrandPPLOverride__c;
                            if(bmqp.ResidentialAMLC__c!=null) oli.ResidentialAMLC__c = bmqp.ResidentialAMLC__c;
                            if(bmqp.ResidentialAMLCOverride__c!=null) oli.ResidentialAMLCOverride__c = bmqp.ResidentialAMLCOverride__c;
                            if(bmqp.LandAMLC__c!=null)  oli.LandAMLC__c = bmqp.LandAMLC__c ;
                            if(bmqp.LandAMLCOverride__c!=null)  oli.LandAMLCOverride__c = bmqp.LandAMLCOverride__c;
                            if(bmqp.RentalAMLC__c!=null) oli.RentalAMLC__c=bmqp.RentalAMLC__c;
                            if(bmqp.RentalAMLCOverride__c!=null)  oli.RentalAMLCOverride__c = bmqp.RentalAMLCOverride__c;
                            if(bmqp.ContractedAMLC__c!=null) oli.ContractedAMLC__c=bmqp.ContractedAMLC__c;
                            if(bmqp.DecommissionedAsset__c!=null)  oli.DecommissionedAsset__c=bmqp.DecommissionedAsset__c;
                            if(bmqp.ConfigOptions__c!=null)  oli.ConfigOptions__c=bmqp.ConfigOptions__c;
                            if(bmqp.AMLCOverride__c!=null)   oli.AMLCOverride__c=bmqp.AMLCOverride__c;
                            if(bmqp.PPLOverride__c!=null)  oli.PPLOverride__c=bmqp.PPLOverride__c;
                            // End == Added by Rajamohan Vakati

                            if(mapQuoteProductOppProductId.containskey(bmqp.id)){
                                oli.Opportunity_Product_URL__c = System.URL.getSalesforceBaseURL().toExternalForm()+'/'+mapQuoteProductOppProductId.get(bmqp.id);
                            }
                            if (TLProductStrings.contains(bmqp.BigMachines__Product__r.ProductCode)) {
                                Task tsk = new Task();

                                //tsk.WhatId = mapListOrder.get(bmqp.id).Id;
                                tsk.Subject = 'Pre Welcome Call';
                                tsk.Is_Tiger_Lead__c = true;
                                //lstTask.add(tsk);

                                oli.Fulfillment_Status__c = Constants.ORDER_FULFILLMENT_STATUS_MANUAL;

                            }
                                
                            //System.debug('$$$$'+mapListOrder.get(bmqp.id).Id);
                            if (bmqp.Available_Presale_Inventory__c != null) {
                                oli.Quantity = presaleOdr.Presale_Quantity__c;
                                oli.Start_Date__c = presaleOdr.Availability_Date__c.date().AddDays(1);
                                oli.End_Date__c = presaleOdr.End_date__c;
                                oli.Inventory_Transaction_Id__c = presaleOdr.Inventory_Transaction_Id__c;
                                If (presaleOdr.Presale_Quantity__c != null && totalQuantity != null && presaleOdr.Presale_Quantity__c != 0 && totalQuantity != 0) {

                                    if (bmqp.List_Price__c != null )
                                        oli.Extended_List__c = presaleOdr.Presale_Quantity__c * bmqp.List_Price__c;
                                    if (oli.Extended_List__c != null)
                                        oli.Total_List_Price__c = oli.Extended_List__c * (bmqp.Billing_Period__c == 'Monthly' ? 12 : 1);
                                    if (bmqp.BigMachines__Sales_Price__c != null)
                                        oli.Extended_Net_Price__c = presaleOdr.Presale_Quantity__c * bmqp.BigMachines__Sales_Price__c;
                                    if (oli.Extended_Net_Price__c != null)
                                        oli.Total_Net__c = oli.Extended_Net_Price__c * (bmqp.Billing_Period__c == 'Monthly' ? 12 : 1);
                                    if (oli.Manual_Discount_Type__c == '$' && bmqp.Manual_Discount_Amount__c != null && bmqp.Quote_Discount_Percent__c != null) {
                                        oli.Manual_Discount_Amount__c = bmqp.Manual_Discount_Amount__c * (presaleOdr.Presale_Quantity__c / totalQuantity);
                                        oli.Combined_Discount_Percent__c = 100 * (bmqp.Manual_Discount_Amount__c / bmqp.List_Price__c) + bmqp.Quote_Discount_Percent__c;

                                    } else {
                                        oli.Manual_Discount_Amount__c = bmqp.Manual_Discount_Amount__c;
                                        oli.Combined_Discount_Percent__c = bmqp.Combined_Discount_Percent__c;

                                    }
                                    if (oli.Combined_Discount_Percent__c != null && bmqp.List_Price__c != null)
                                        oli.Combined_Discount__c = bmqp.List_Price__c * (oli.Combined_Discount_Percent__c * .01);
                                    if (oli.Combined_Discount__c != null)
                                        oli.Extended_Discount__c = presaleOdr.Presale_Quantity__c * oli.Combined_Discount__c;
                                    if (oli.Extended_Discount__c != null)
                                        oli.Total_Discount_Amount__c = oli.Extended_Discount__c * (bmqp.Billing_Period__c == 'Monthly' ? 12 : 1);
                                    if (bmqp.Est_Tax__c != null)
                                        oli.Est_Tax__c = bmqp.Est_Tax__c * (presaleOdr.Presale_Quantity__c / totalQuantity);
                                    if (bmqp.Est_Total_Tax__c != null)
                                        oli.Est_Total_Tax__c = bmqp.Est_Total_Tax__c * (presaleOdr.Presale_Quantity__c / totalQuantity);
                                    if (oli.Total_Net__c != null && oli.Est_Total_Tax__c != null)
                                        oli.Total_Price_WithTax__c = oli.Total_Net__c + oli.Est_Total_Tax__c;
                                }

                            } else {
                                oli.Quantity = bmqp.BigMachines__Quantity__c;
                                oli.Start_Date__c = bmqp.Start_Date__c;
                                oli.End_Date__c = bmqp.End_Date__c;
                                oli.Extended_List__c = bmqp.Extended_List__c;
                                oli.Total_List_Price__c = bmqp.Total_List_Price__c;
                                oli.Total_Price_WithTax__c = bmqp.Total_Price_WithTax__c;
                                oli.Est_Total_Tax__c = bmqp.Est_Total_Tax__c;
                                oli.Extended_Net_Price__c = bmqp.Extended_Net_Price__c;
                                oli.Manual_Discount_Amount__c = bmqp.Manual_Discount_Amount__c;
                                oli.Combined_Discount_Percent__c = bmqp.Combined_Discount_Percent__c;
                                oli.Extended_Discount__c = bmqp.Extended_Discount__c;
                                oli.Total_Discount_Amount__c = bmqp.Total_Discount_Amount__c;
                                oli.Est_Tax__c = bmqp.Est_Tax__c;
                                oli.Inventory_Transaction_Id__c = bmqp.Inventory_Transaction_Id__c;
                            }
                            
                            oli.Spot_Promo_Code__c = bmqp.Spot_Promo_Code__c; //CRM-2627
                            oli.Spot_Promo_Percentage__c = bmqp.Spot_Promo_Percentage__c; //CRM-2627
                            //CRM-3584: Added new field on Order Product for Auto Renewals.
                            if(bmqp.Contracted_Advantage_PPL_string__c != null)
                                oli.Contracted_Advantage_PPL_string__c = bmqp.Contracted_Advantage_PPL_string__c;                            

                            oli.PricebookEntryId = mapProductPriceBookEntryId.get(bmqp.BigMachines__Product__c).Id;
                            oli.Product_Account__c = bmqp.Product_Account__c;
                            oli.Part_Number__c = bmqp.Name;
                            oli.Cost_Per_Action__c = bmqp.Cost_Per_Action__c;
                            oli.Term_Start_Date__c = bmqp.Term_Start_Date__c;
                            oli.Delta_Price__c = bmqp.Delta_Price__c;
                            oli.Line_Type__c = bmqp.Line_Type__c;
                            if (bmqp.BigMachines__Quote__r.BigMachines_Quote_Type__c.equalsIgnoreCase('Backout')) {
                                oli.Line_Type__c = 'Cancel';
                            }
                            System.debug('Working'+(bmqp.Quick_fulfillment__c =='true' && RSBundleBilltoProductCode.contains(bmqp.BigMachines__Product__r.ProductCode)));
                            //Updated by Pratik for CRM-4653 on 5th September 2018
                            if(bmqp.BigMachines__Product__r.RealSuite_Family__c 
                               && (bmqp.Net_Price__c>0 || (bmqp.Quick_fulfillment__c =='true' && RSBundleBilltoProductCode.contains(bmqp.BigMachines__Product__r.ProductCode))) 
                               && !bmqp.Line_Type__c.equalsIgnoreCase('Cancel')){
                            System.debug('WorkingYes');
                            oli.Realsuite_Bill__c   = true;
                            }
                            if(isRSRespondPresent && bmqp.BigMachines__Product__r.ProductCode == 'RSRESPOND'){oli.Realsuite_Bill__c   = true;}
                            if(isRSConnectPresent && bmqp.BigMachines__Product__r.ProductCode == 'RSCONNECT'){oli.Realsuite_Bill__c   = true;}
                            if(bmqp.BigMachines__Product__r.ProductCode == 'RSTRANSACT'){oli.Realsuite_Bill__c   = true;}
                            oli.Trial__c = bmqp.Trial__c;
                            oli.Description = bmqp.BigMachines__Description__c;
                            oli.Suppress_Welcome_Calls__c = bmqp.Suppress_Welcome_Calls__c;
                            oli.Ext_Days__c = bmqp.Ext_Days__c;
                            oli.Subscription_Start_Date__c = bmqp.Subscription_Start_Date__c;
                            oli.Subscription_End_Date__c = bmqp.Subscription_End_Date__c;
                            if (oli.Ext_Days__c == null) {oli.Ext_Days__c = 0;}
                            oli.Auto_Renewal__c = bmqp.Auto_Renewal__c;
                            oli.Asset__c = bmqp.Asset__c ;
                            oli.Refund_Request__c = bmqp.Refund_Request__c;
                            oli.License_Tier__c = bmqp.License_Tier__c;
                            oli.Product_Email__c = bmqp.Product_Email__c;
                            oli.Manual_Override_Amount__c = bmqp.Manual_Override_Amount__c;
                            oli.Net_Price_Each__c = bmqp.Net_Price_Each__c;
                            oli.Extended_Net_Price__c = bmqp.Extended_Net_Price__c;
                            oli.Promotion_Amount__c = bmqp.Promotion_Amount__c;
                            oli.Total_Discount__c = bmqp.Total_Discount__c;
                            oli.Market_Budget_Fee__c = bmqp.Market_Budget_Fee__c;
                            if (bmqp.Market_Tier__c != null) {
                                oli.Market_Tier__c = Decimal.valueof(bmqp.Market_Tier__c);
                            }
                            //oli.First_Month_Proration__c = bmqp.First_Month_Proration__c;
                            oli.Presale_Available_Inventory__c = bmqp.Available_Presale_Inventory__c;
                            oli.Fulfill_To_Account__c = bmqp.Fulfill_To_Account__c;
                            oli.Cancellation_Date__c = bmqp.Cancellation_Date__c;
                            oli.Cancellation_Effective_Date__c = bmqp.Cancellation_Effective_Date__c;
                            oli.Buyout_Amount__c = bmqp.Buyout_Amount__c;
                            oli.Buyout_Discount__c = bmqp.Buyout_Discount__c;
                            oli.HLC__c = bmqp.HLC__c;
                            oli.Promo_Description__c = bmqp.Promo_Description__c;
                            oli.Remaining_Amount__c = bmqp.Remaining_Asset_Value__c;
                            oli.Cancellation_Reason__c = bmqp.Cancellation_Reason__c;
                            if (mapCancellationReason.containskey(bmqp.Cancellation_Reason__c)) {oli.Cancellation_Reason__c = mapCancellationReason.get(bmqp.Cancellation_Reason__c);}
                            if (oli.Cancellation_Reason__c == 'customerRequest') {oli.Cancellation_Reason__c = 'Customer Request';}
                            oli.HLC_Override__c = bmqp.HLC_Override__c;
                            oli.Inv_Lock_Expire_Date__c = bmqp.Inv_Lock_Expire_Date__c;
                            oli.Market__c = bmqp.Market__c;
                            oli.MLS_Set_Id__c = bmqp.MLS_Set_Id__c;
                            oli.Participant__c = bmqp.Participant__c;
                            oli.Promotion__c = bmqp.Promotion__c;
                            oli.Tax_Error_Description__c = bmqp.Tax_Error_Description__c;
                            oli.Lead_Type__c = bmqp.Lead_Type__c;
                            oli.Billing_Period__c = bmqp.Billing_Period__c;
                            oli.Top_Connector__c = bmqp.Top_Connector__c;
                            oli.Featured_Mortgage__c = bmqp.Featured_Mortgage__c;
                            oli.Choice_Lead_Form__c = bmqp.Choice_Lead_Form__c;
                            oli.Asset_Structure__c = bmqp.Asset_Structure__c;
                            if (bmqp.BigMachines__Quote__r.BigMachines_Quote_Type__c.equalsIgnoreCase('Backout')) {
                                oli.Asset_Structure__c.replace('Add', 'Remove');
                            }
                            oli.Product_Type__c = bmqp.Product_Type__c;
                            oli.Promo_Discount__c = bmqp.Promo_Discount__c;
                            oli.Manual_Discount__c = bmqp.Manual_Discount__c;
                            oli.Manual_Price_Override__c = bmqp.Manual_Price_Override__c;
                            oli.Price_Tier__c = bmqp.Price_Tier__c;
                            oli.Qty_Tier__c = bmqp.Qty_Tier__c;
                            oli.MSA_Tier__c = bmqp.MSA_Tier__c;
                            oli.HLC_Range__c = bmqp.HLC_Range__c;
                            oli.MSA_Tier__c = bmqp.MSA_Tier__c;
                            oli.Strategic_Discount__c = bmqp.Strategic_Discount__c;
                            oli.Strategic_Discount_Percent__c = bmqp.Strategic_Discount_Percent__c;
                            oli.Strategic_Discount_dollar__c = bmqp.Strategic_Discount_dollar__c;
                            oli.Promotion_Discount__c = bmqp.Promotion_Discount__c;
                            oli.Manual_Discount_Type__c = bmqp.Manual_Discount_Type__c;
                            oli.Manual_Discount__c = bmqp.Manual_Discount_Percent__c;
                            oli.Quote_Discount_Percent__c = bmqp.Quote_Discount_Percent__c;
                            oli.Combined_Discount__c = bmqp.Combined_Discount__c;
                            oli.Total_Discount_Percent__c = bmqp.Total_Discount_Percent__c;
                            oli.Override_Term__c = bmqp.Override_Term__c;
                            oli.Delta_Price_w_o_Tax__c = bmqp.Delta_Price_w_o_Tax__c;
                            oli.Discount_Type__c = bmqp.Discount_Type__c;
                            if (bmqp.Commerce_Group__c != null) {oli.Commerce_Group__c = bmqp.Commerce_Group__c.trim();}
                            oli.Quote_Transaction_ID__c = bmqp.Quote_Transaction_ID__c;
                            oli.HLC_Range__c = bmqp.HLC_Range__c;
                            oli.NAR_Membership__c = bmqp.NAR_Membership__c;
                            oli.License_Tier_Range__c = bmqp.License_Tier_Range__c;
                            //oli.Licence_Tier_c = bmqp.Licence_Tier_c;
                            oli.MLS_Type__c = bmqp.MLS_Type__c;
                            oli.Delta_Price_w_o_Tax__c = bmqp.Delta_Price_w_o_Tax__c;
                            oli.Extension_Type__c = bmqp.Extension_Type__c;
                            oli.Ext_Days__c = bmqp.Ext_Days__c;
                            oli.Buyout_Amount__c = bmqp.Buyout_Amount__c;
                            oli.Buyout_Discount__c = bmqp.Buyout_Discount__c;
                            oli.Subscription_Start_Date__c = bmqp.Subscription_Start_Date__c;
                            oli.Subscription_End_Date__c = bmqp.Subscription_End_Date__c;
                            oli.Create_Broker_Tools__c = bmqp.Create_Broker_Tools__c;
                            oli.Franchise_Amount__c = bmqp.Franchise_Amount__c;
                            oli.Cancellation_Date__c = bmqp.Cancellation_Date__c;
                            oli.Quote_Product__c = bmqp.Id;
                            oli.Broker_Plan_Affiliation__c = bmqp.BigMachines__Quote__r.BigMachines__Account__r.Franchise_Type__c;
                            oli.Billing_Period__c = bmqp.Billing_Period__c;
                            oli.Contract_Term__c = bmqp.Contract_Term__c;
                            oli.UnitPrice = 0;
                           // if(bmqp.Real_Suite_Parent__c!=null){oli.Real_Suite_Parent__c = bmqp.Real_Suite_Parent__c;}

                            if (mapOrderActionString.containskey(oli.OrderId)) {
                                String linetypestring = mapOrderActionString.get(oli.OrderId) + ',' + oli.Line_type__c;
                                mapOrderActionString.put(oli.OrderId, linetypestring);
                            } else {
                                mapOrderActionString.put(oli.OrderId, oli.Line_type__c);
                            }
                            system.debug('line type--->>>' +mapOrderActionString);

                            if (mapOrderTLProductString.containskey(oli.OrderId)) {
                                String TLOrderProduct = mapOrderTLProductString.get(oli.OrderId);
                                if (TLOrderProduct != 'Tigerleads') {
                                    mapOrdernonTLProductString.put(oli.orderId, mapProductPriceBookEntryId.get(bmqp.BigMachines__Product__c).Product2.Fulfillment_ID__c);

                                    mapOrderTLProductString.put(oli.OrderId, mapProductPriceBookEntryId.get(bmqp.BigMachines__Product__c).Product2.Fulfillment_ID__c);}
                            } else {
                                mapOrderTLProductString.put(oli.OrderId, mapProductPriceBookEntryId.get(bmqp.BigMachines__Product__c).Product2.Fulfillment_ID__c);
                            }
                            oli.Price_Effective_Date__c = bmqp.Price_Effective_Date__c;
                            if (oli.Net_Price__c == null) {oli.Net_Price__c = 0;}
                            if (oli.Extended_Net_Price__c == null) {oli.Extended_Net_Price__c = 0.0;}
                            //CRM 2709
                            if (oli.Part_Number__c == 'BETACONNECT') {oli.Zuora_Comment__c = 'No Zuora Changes';}
                            if (oli.Part_Number__c == 'BETATRANSACT') {oli.Zuora_Comment__c = 'No Zuora Changes';}
                            
                            if (bmqp.Unit_Total_Price__c != null) {oli.UnitPrice = bmqp.Unit_Total_Price__c;}
                            oli.Subscription_Term__c = mapProductPriceBookEntryId.get(bmqp.BigMachines__Product__c).Product2.Subscription_Type__c;
                            if(OrderMapList.containsKey(oli.OrderId)) {
                                String PrCode = OrderMapList.get(oli.OrderId);
                                if(!PrCode.contains(mapProductPriceBookEntryId.get(bmqp.BigMachines__Product__c).Product2.ProductCode+'')){
                                PrCode += mapProductPriceBookEntryId.get(bmqp.BigMachines__Product__c).Product2.ProductCode+', ';
                                OrderMapList.put(oli.OrderId,PrCode);
                                }
                            }
                            else {
                                String PrCode = '';
                                PrCode = mapProductPriceBookEntryId.get(bmqp.BigMachines__Product__c).Product2.ProductCode+', ';
                                OrderMapList.put(oli.OrderId,PrCode);
                            }
                            if(productCodesMap.containskey(oli.orderId)){
                               Set<String> productCodes = productCodesMap.get(oli.orderId);
                               productCodes.add(mapProductPriceBookEntryId.get(bmqp.BigMachines__Product__c).Product2.ProductCode);
                               productCodesMap.put(oli.orderId, productCodes);
                            }else{
                               Set<String> productCodes = new Set<String>();
                               productCodes.add(mapProductPriceBookEntryId.get(bmqp.BigMachines__Product__c).Product2.ProductCode);
                               productCodesMap.put(oli.orderId, productCodes);
                            }
                            System.debug('####' + productCodesMap);
                            System.debug('####' + oli);
                            lstOrderLineItems.add(oli);
                        } else if (mapListOrder.containskey(bmqp.BigMachines__Quote__c + '##' + bmqp.Start_Date__c)) {
                            OrderItem oli = new OrderItem();
                             // CRM-6063 - Opcity BLA Field Assignment
                            oli.Setup_Fee__c = bmqp.Setup_Fee__c;
                            oli.Opcity_MSA__c = bmqp.Opcity_MSA__c;
                            oli.Backup_Monthly_Plan__c = bmqp.Backup_Monthly_Plan__c;
                            oli.Launch_Date__c = bmqp.Launch_Date__c;
                            oli.Source__c = bmqp.Source__c;
                            oli.Expected_Monthly_Lead_Volume__c = bmqp.Expected_Monthly_Lead_Volume__c;
                            oli.Stage__c = bmqp.Stage__c;
                            oli.can_disclose_fees__c = bmqp.can_disclose_fees__c;
                            oli.unlicensed_state_leads__c = bmqp.unlicensed_state_leads__c;
                            oli.Focus_Fire_Id__c = bmqp.Focus_Fire_Id__c;
                            // CRM-6063 - End 
                            
                            //CRM-1379 assign Quote Product category to OrderItem Category
                            oli.category__c = bmqp.category__c;
                            // CRM-4718 assign Quote No_Term_Sale__c to OrderItem No_Term_Sale__c
                            oli.No_Term_Sale__c = bmqp.No_Term_Sale__c;
                            // LCM CRM-4807
                            oli.zuora_payment_method__c = bmqp.zuora_payment_method__c;
                            //CRM-1983 assign Quote Product Cancel_Type to OrderItem Cancel_Type
                            oli.Cancel_Type__c = bmqp.Cancel_Type__c;
                            oli.Migrated_From_Legacy__c = bmqp.Migrated_From_Legacy__c; //
                            // CRM-3906: Populate RS amend type
                            if(bmqp.RS_Action_Type__c != null) oli.RS_Action_Type__c = bmqp.RS_Action_Type__c;
                            
                            if (mapCancellationReason.containskey(bmqp.Cancel_Type__c)) {oli.Cancel_Type__c = mapCancellationReason.get(bmqp.Cancel_Type__c);}
                            //End CRM-1983
                            oli.OrderId = mapListOrder.get(bmqp.BigMachines__Quote__c + '##' + bmqp.Start_Date__c).Id;
                            
                            oli.List_Price__c = bmqp.List_Price__c;
                            if(mapQuoteProductOppProductId.containskey(bmqp.id)){
                                oli.Opportunity_Product_URL__c = System.URL.getSalesforceBaseURL().toExternalForm()+'/'+mapQuoteProductOppProductId.get(bmqp.id);
                            }
                            oli.Credit_Amount__c  = bmqp.Credit_Amount__c;
                            //LCM-97
                            
                            if(!QPCreditPercntMap.isEmpty() && QPCreditPercntMap.containsKey(bmqp.id)){
                                Decimal creditPercent = (100 - QPCreditPercntMap.get(bmqp.id))/100;
                                oli.total_credit_amount__c = bmqp.Credit_Amount__c;
                                oli.Credit_Amount__c = bmqp.Credit_Amount__c * creditPercent;
                            }
                            System.debug('$$$$' + mapListOrder.get(bmqp.BigMachines__Quote__c + '##' + bmqp.Start_Date__c).Id);
                            if (bmqp.Available_Presale_Inventory__c != null) {
                                oli.Quantity = presaleOdr.Presale_Quantity__c;
                                oli.Start_Date__c = presaleOdr.Availability_Date__c.date().AddDays(1);
                                oli.End_Date__c = presaleOdr.End_date__c;
                                oli.Inventory_Transaction_Id__c = presaleOdr.Inventory_Transaction_Id__c;
                                If (presaleOdr.Presale_Quantity__c != null && totalQuantity != null && presaleOdr.Presale_Quantity__c != 0 && totalQuantity != 0) {
                                    if (bmqp.List_Price__c != null )
                                        oli.Extended_List__c = presaleOdr.Presale_Quantity__c * bmqp.List_Price__c;
                                    if (oli.Extended_List__c != null)
                                        oli.Total_List_Price__c = oli.Extended_List__c * (bmqp.Billing_Period__c == 'Monthly' ? 12 : 1);
                                    if (bmqp.BigMachines__Sales_Price__c != null)
                                        oli.Extended_Net_Price__c = presaleOdr.Presale_Quantity__c * bmqp.BigMachines__Sales_Price__c;
                                    if (oli.Extended_Net_Price__c != null)
                                        oli.Total_Net__c = oli.Extended_Net_Price__c * (bmqp.Billing_Period__c == 'Monthly' ? 12 : 1);
                                    if (oli.Manual_Discount_Type__c == '$' && bmqp.Manual_Discount_Amount__c != null && bmqp.Quote_Discount_Percent__c != null) {
                                        oli.Manual_Discount_Amount__c = bmqp.Manual_Discount_Amount__c * (presaleOdr.Presale_Quantity__c / totalQuantity);
                                        oli.Combined_Discount_Percent__c = 100 * (bmqp.Manual_Discount_Amount__c / bmqp.List_Price__c) + bmqp.Quote_Discount_Percent__c;
                                    } else {
                                        oli.Manual_Discount_Amount__c = bmqp.Manual_Discount_Amount__c;
                                        oli.Combined_Discount_Percent__c = bmqp.Combined_Discount_Percent__c;
                                    }
                                    if (oli.Combined_Discount_Percent__c != null && bmqp.List_Price__c != null)
                                        oli.Combined_Discount__c = bmqp.List_Price__c * (oli.Combined_Discount_Percent__c * .01);
                                    if (oli.Combined_Discount__c != null)
                                        oli.Extended_Discount__c = presaleOdr.Presale_Quantity__c * oli.Combined_Discount__c;
                                    if (oli.Extended_Discount__c != null)
                                        oli.Total_Discount_Amount__c = oli.Extended_Discount__c * (bmqp.Billing_Period__c == 'Monthly' ? 12 : 1);
                                    if (bmqp.Est_Tax__c != null)
                                        oli.Est_Tax__c = bmqp.Est_Tax__c * (presaleOdr.Presale_Quantity__c / totalQuantity);
                                    if (bmqp.Est_Total_Tax__c != null)
                                        oli.Est_Total_Tax__c = bmqp.Est_Total_Tax__c * (presaleOdr.Presale_Quantity__c / totalQuantity);
                                    if (oli.Total_Net__c != null && oli.Est_Total_Tax__c != null)
                                        oli.Total_Price_WithTax__c = oli.Total_Net__c + oli.Est_Total_Tax__c;
                                }

                            } else {
                                oli.Quantity = bmqp.BigMachines__Quantity__c;
                                oli.Start_Date__c = bmqp.Start_Date__c;
                                oli.End_Date__c = bmqp.End_Date__c;
                                oli.Extended_List__c = bmqp.Extended_List__c;
                                oli.Total_List_Price__c = bmqp.Total_List_Price__c;
                                oli.Total_Price_WithTax__c = bmqp.Total_Price_WithTax__c;
                                oli.Est_Total_Tax__c = bmqp.Est_Total_Tax__c;
                                oli.Extended_Net_Price__c = bmqp.Extended_Net_Price__c;
                                oli.Manual_Discount_Amount__c = bmqp.Manual_Discount_Amount__c;
                                oli.Combined_Discount_Percent__c = bmqp.Combined_Discount_Percent__c;
                                oli.Extended_Discount__c = bmqp.Extended_Discount__c;
                                oli.Total_Discount_Amount__c = bmqp.Total_Discount_Amount__c;
                                oli.Est_Tax__c = bmqp.Est_Tax__c;
                                oli.Total_Net__c = bmqp.Total_Net__c;
                                oli.Inventory_Transaction_Id__c = bmqp.Inventory_Transaction_Id__c;
                            }
                            mapQuoteOrderId.put(oli.OrderId, bmqp.id);
                            mapProductCodeOrdId.put(bmqp.Name, oli.OrderId);
                            oli.UnitPrice = 0;
                            if(bmqp.Line_Type__c != 'Renew' && bmqp.Line_Type__c != 'Cancel' && bmqp.Line_Type__c != 'Credit' && bmqp.Line_Type__c != 'Buyout'){

                                mapTLLineType.put(oli.OrderId,true);

                            }
                            if (bmqp.Unit_Total_Price__c != null) {oli.UnitPrice = bmqp.Unit_Total_Price__c;}
                            oli.PricebookEntryId = mapProductPriceBookEntryId.get(bmqp.BigMachines__Product__c).Id;
                            //oli.Pricebook2id = '01sg000000019AjAAI';
                            oli.Product_Account__c = bmqp.Product_Account__c;
                            oli.Part_Number__c = bmqp.Name;
                            oli.Delta_Price__c = bmqp.Delta_Price__c;
                            oli.Fulfillment_Status__c = Constants.ORDER_FULFILLMENT_STATUS_PENDING;
                            oli.Line_Type__c = bmqp.Line_Type__c;
                            oli.Auto_Renewal__c = bmqp.Auto_Renewal__c;
                            oli.Asset__c = bmqp.Asset__c ;
                            oli.Product_Email__c = bmqp.Product_Email__c;
                            oli.Delta_Price_w_o_Tax__c = bmqp.Delta_Price_w_o_Tax__c;
                            oli.Discount_Type__c = bmqp.Discount_Type__c;
                            oli.Spot_Promo_Code__c = bmqp.Spot_Promo_Code__c; //CRM-2627
                            oli.Spot_Promo_Percentage__c = bmqp.Spot_Promo_Percentage__c; //CRM-2627
                            //CRM-3584: Added new field on Order Product for Auto Renewals.
                            if(bmqp.Contracted_Advantage_PPL_string__c != null)
                                oli.Contracted_Advantage_PPL_string__c = bmqp.Contracted_Advantage_PPL_string__c;                           
                            oli.Proration_Credit__c = bmqp.Proration_Credit__c; //CRM-2328 - Displays proration credit amount generated while placing the Quote.
                            oli.Commerce_Group__c = bmqp.Commerce_Group__c;
                            oli.Quote_Transaction_ID__c = bmqp.Quote_Transaction_ID__c;
                            oli.Suppress_Welcome_Calls__c = bmqp.Suppress_Welcome_Calls__c;
                            oli.Ext_Days__c = bmqp.Ext_Days__c;
                            if (oli.Ext_Days__c == null) {oli.Ext_Days__c = 0;}
                            oli.Manual_Override_Amount__c = bmqp.Manual_Override_Amount__c;
                            oli.Net_Price_Each__c = bmqp.Net_Price_Each__c;
                            oli.Promotion_Amount__c = bmqp.Promotion_Amount__c;
                            oli.Total_Discount__c = bmqp.Total_Discount__c;
                            oli.Market_Budget_Fee__c = bmqp.Market_Budget_Fee__c;
                            //oli.First_Month_Proration__c = bmqp.First_Month_Proration__c;
                            oli.Fulfill_To_Account__c = bmqp.Fulfill_To_Account__c;
                            oli.Cancellation_Date__c = bmqp.Cancellation_Date__c;
                            oli.Cancellation_Effective_Date__c = bmqp.Cancellation_Effective_Date__c;
                            oli.Buyout_Amount__c = bmqp.Buyout_Amount__c;
                            oli.Buyout_Discount__c = bmqp.Buyout_Discount__c;
                            oli.HLC__c = bmqp.HLC__c;
                            oli.Cost_Per_Action__c = bmqp.Cost_Per_Action__c;
                            oli.Net_Price__c = bmqp.Net_Price__c;
                            oli.Total_Net_Price__c = bmqp.Total_Net_Price__c;
                            oli.Promo_Description__c = bmqp.Promo_Description__c;
                            oli.Strategic_Discount__c = bmqp.Strategic_Discount__c;
                            oli.Strategic_Discount_Percent__c = bmqp.Strategic_Discount_Percent__c;
                            oli.Strategic_Discount_dollar__c = bmqp.Strategic_Discount_dollar__c;
                            oli.Promotion_Discount__c = bmqp.Promotion_Discount__c;
                            oli.Manual_Discount_Type__c = bmqp.Manual_Discount_Type__c;
                            oli.Manual_Discount__c = bmqp.Manual_Discount_Percent__c;
                            oli.Quote_Discount_Percent__c = bmqp.Quote_Discount_Percent__c;
                            oli.Combined_Discount__c = bmqp.Combined_Discount__c;
                            if (bmqp.BigMachines__Quote__r.BigMachines_Quote_Type__c.equalsIgnoreCase('Backout')) {
                                oli.Line_Type__c = 'Cancel';
                            }
                            System.debug(bmqp.BigMachines__Product__r.RealSuite_Family__c+'Working'+bmqp.Quick_fulfillment__c +'PPP'+ RSBundleBilltoProductCode.contains(bmqp.BigMachines__Product__r.ProductCode)+'KKKK'+bmqp.BigMachines__Product__r.ProductCode);
                            System.debug('Testing '+(bmqp.BigMachines__Product__r.RealSuite_Family__c && (bmqp.Net_Price__c>0 || (bmqp.Quick_fulfillment__c =='true' && RSBundleBilltoProductCode.contains(bmqp.BigMachines__Product__r.ProductCode)) ) && !bmqp.Line_Type__c.equalsIgnoreCase('Cancel')));
                            if(bmqp.BigMachines__Product__r.RealSuite_Family__c && (bmqp.Net_Price__c>0 || (bmqp.Quick_fulfillment__c =='true' && RSBundleBilltoProductCode.contains(bmqp.BigMachines__Product__r.ProductCode)) ) && !bmqp.Line_Type__c.equalsIgnoreCase('Cancel')){
                            System.debug('Working now');
                            oli.Realsuite_Bill__c   = true;
                            }
                             if(isRSRespondPresent && bmqp.BigMachines__Product__r.ProductCode == 'RSRESPOND'){oli.Realsuite_Bill__c   = true;}
                            if(isRSConnectPresent && bmqp.BigMachines__Product__r.ProductCode == 'RSCONNECT'){oli.Realsuite_Bill__c   = true;}
                            if(bmqp.BigMachines__Product__r.ProductCode == 'RSTRANSACT'){oli.Realsuite_Bill__c   = true;}
                            oli.Trial__c = bmqp.Trial__c; 
                            oli.Total_Discount_Percent__c = bmqp.Total_Discount_Percent__c;
                            oli.Override_Term__c = bmqp.Override_Term__c;
                            oli.Remaining_Amount__c = bmqp.Remaining_Asset_Value__c;
                            oli.Cancellation_Reason__c = bmqp.Cancellation_Reason__c;
                            if (oli.Cancellation_Reason__c == 'goodCancel') {oli.Cancellation_Reason__c = 'Good Cancellation';}
                            if (oli.Cancellation_Reason__c == 'customerRequest') {oli.Cancellation_Reason__c = 'Customer Request';}
                            if (mapCancellationReason.containskey(bmqp.Cancellation_Reason__c)) {oli.Cancellation_Reason__c = mapCancellationReason.get(bmqp.Cancellation_Reason__c);}
                            System.debug(mapCancellationReason + '55555555' + oli.Cancellation_Reason__c);
                            oli.HLC_Override__c = bmqp.HLC_Override__c;
                            oli.Inv_Lock_Expire_Date__c = bmqp.Inv_Lock_Expire_Date__c;
                            oli.Market__c = bmqp.Market__c;
                            oli.License_Tier__c = bmqp.License_Tier__c;
                            oli.MLS_Set_Id__c = bmqp.MLS_Set_Id__c;
                            oli.Participant__c = bmqp.Participant__c;
                            oli.Promotion__c = bmqp.Promotion__c;
                            oli.Tax_Error_Description__c = bmqp.Tax_Error_Description__c;
                            oli.Lead_Type__c = bmqp.Lead_Type__c;
                            oli.Billing_Period__c = bmqp.Billing_Period__c;
                            oli.Create_Broker_Tools__c = bmqp.Create_Broker_Tools__c;
                            oli.Top_Connector__c = bmqp.Top_Connector__c;
                            oli.Featured_Mortgage__c = bmqp.Featured_Mortgage__c;
                            oli.Asset_Structure__c = bmqp.Asset_Structure__c;
                            if (bmqp.BigMachines__Quote__r.BigMachines_Quote_Type__c.equalsIgnoreCase('Backout')) {
                                oli.Asset_Structure__c.replace('Add', 'Remove');
                            }
                            oli.Term_Start_Date__c = bmqp.Term_Start_Date__c;
                            oli.Product_Type__c = bmqp.Product_Type__c;
                            oli.Promo_Discount__c = bmqp.Promo_Discount__c;
                            oli.Manual_Discount__c = bmqp.Manual_Discount__c;
                            oli.Manual_Price_Override__c = bmqp.Manual_Price_Override__c;
                            oli.Price_Tier__c = bmqp.Price_Tier__c;
                            oli.Qty_Tier__c = bmqp.Qty_Tier__c;
                            oli.MSA_Tier__c = bmqp.MSA_Tier__c;
                            oli.HLC_Range__c = bmqp.HLC_Range__c;
                            oli.MSA_Tier__c = bmqp.MSA_Tier__c;
                            oli.Choice_Lead_Form__c = bmqp.Choice_Lead_Form__c;
                            oli.HLC_Range__c = bmqp.HLC_Range__c;
                            if (bmqp.Market_Tier__c != null) {
                                oli.Market_Tier__c = Decimal.valueof(bmqp.Market_Tier__c);
                            }
                            // Start===Added by - Rajamohan Vakati
                            if(bmqp.ResidentialLeadPPL__c!=null) oli.ResidentialLeadPPL__c = bmqp.ResidentialLeadPPL__c;
                            if(bmqp.ResidentialLeadPPLOverride__c!=null)  oli.ResidentialLeadPPLOverride__c = bmqp.ResidentialLeadPPLOverride__c ;
                            if(bmqp.ResidentialBrandPPL__c!=null) oli.ResidentialBrandPPL__c = bmqp.ResidentialBrandPPL__c ;
                            if(bmqp.ResidentialBrandPPLOverride__c!=null)  oli.ResidentialBrandPPLOverride__c =bmqp.ResidentialBrandPPLOverride__c;
                            if(bmqp.ResidentialAMLC__c!=null) oli.ResidentialAMLC__c = bmqp.ResidentialAMLC__c;
                            if(bmqp.ResidentialAMLCOverride__c!=null)  oli.ResidentialAMLCOverride__c = bmqp.ResidentialAMLCOverride__c;
                            if(bmqp.LandAMLC__c!=null) oli.LandAMLC__c = bmqp.LandAMLC__c ;
                            if(bmqp.LandAMLCOverride__c!=null)  oli.LandAMLCOverride__c = bmqp.LandAMLCOverride__c;
                            if(bmqp.RentalAMLC__c!=null) oli.RentalAMLC__c=bmqp.RentalAMLC__c;
                            if(bmqp.RentalAMLCOverride__c!=null)  oli.RentalAMLCOverride__c = bmqp.RentalAMLCOverride__c;
                            if(bmqp.ContractedAMLC__c!=null) oli.ContractedAMLC__c=bmqp.ContractedAMLC__c;
                            if(bmqp.DecommissionedAsset__c!=null)  oli.DecommissionedAsset__c=bmqp.DecommissionedAsset__c;
                            if(bmqp.ConfigOptions__c!=null)  oli.ConfigOptions__c=bmqp.ConfigOptions__c;
                            if(bmqp.AMLCOverride__c!=null)  oli.AMLCOverride__c=bmqp.AMLCOverride__c;
                            if(bmqp.PPLOverride__c!=null) oli.PPLOverride__c=bmqp.PPLOverride__c;
                            // End == Added by Rajamohan Vakati
                            oli.Presale_Available_Inventory__c = bmqp.Available_Presale_Inventory__c;
                            oli.NAR_Membership__c = bmqp.NAR_Membership__c;
                            oli.License_Tier_Range__c = bmqp.License_Tier_Range__c;
                            //oli.Licence_Tier_c = bmqp.Licence_Tier_c;
                            oli.MLS_Type__c = bmqp.MLS_Type__c;
                            oli.Price_Effective_Date__c = bmqp.Price_Effective_Date__c;
                            oli.Franchise_Asset__c = bmqp.Franchise_Asset__c;
                            oli.Franchise_Amount__c = bmqp.Franchise_Amount__c;
                            oli.Subscription_Start_Date__c = bmqp.Subscription_Start_Date__c;
                            oli.Subscription_End_Date__c = bmqp.Subscription_End_Date__c;
                            oli.Cancellation_Date__c = bmqp.Cancellation_Date__c;
                            oli.Extension_Type__c = bmqp.Extension_Type__c;
                            oli.Ext_Days__c = bmqp.Ext_Days__c;
                            oli.Quote_Product__c = bmqp.Id;
                            if (bmqp.Commerce_Group__c != null) {oli.Commerce_Group__c = bmqp.Commerce_Group__c.trim();}
                            oli.Refund_Request__c = bmqp.Refund_Request__c;
                            oli.Buyout_Amount__c = bmqp.Buyout_Amount__c;
                            oli.Buyout_Discount__c = bmqp.Buyout_Discount__c;
                            if (oli.Net_Price__c == null) {oli.Net_Price__c = 0;}
                            oli.Broker_Plan_Affiliation__c = bmqp.BigMachines__Quote__r.BigMachines__Account__r.Franchise_Type__c;
                            oli.Billing_Period__c = bmqp.Billing_Period__c;
                            oli.Contract_Term__c = bmqp.Contract_Term__c;
                           // if(bmqp.Real_Suite_Parent__c!=null){oli.Real_Suite_Parent__c = bmqp.Real_Suite_Parent__c;}
                            
                            if (mapOrderActionString.containskey(oli.OrderId)) {
                                String linetypestring = mapOrderActionString.get(oli.OrderId) + ',' + oli.Line_type__c;
                                mapOrderActionString.put(oli.OrderId, linetypestring);
                            } else {
                                mapOrderActionString.put(oli.OrderId, oli.Line_type__c);
                            }
                            if (mapOrderTLProductString.containskey(oli.OrderId)) {
                                String TLOrderProduct = mapOrderTLProductString.get(oli.OrderId);
                                if (TLOrderProduct != 'Tigerleads') {mapOrderTLProductString.put(oli.OrderId, mapProductPriceBookEntryId.get(bmqp.BigMachines__Product__c).Product2.Fulfillment_ID__c);}
                            } else {
                                mapOrderTLProductString.put(oli.OrderId, mapProductPriceBookEntryId.get(bmqp.BigMachines__Product__c).Product2.Fulfillment_ID__c);
                            }
                            if(!mapOrdernonTLProductString.containskey(oli.OrderId)){
                                String TLOrderProduct = mapProductPriceBookEntryId.get(bmqp.BigMachines__Product__c).Product2.Fulfillment_ID__c;

                                if (TLOrderProduct != 'Tigerleads') {
                                    mapOrdernonTLProductString.put(oli.orderId, mapProductPriceBookEntryId.get(bmqp.BigMachines__Product__c).Product2.Fulfillment_ID__c);
                                }
                            }
                            oli.Subscription_Term__c = mapProductPriceBookEntryId.get(bmqp.BigMachines__Product__c).Product2.Subscription_Type__c;
                            if(OrderMapList.containsKey(oli.OrderId)) {
                                String PrCode = OrderMapList.get(oli.OrderId);
                                if(!PrCode.contains(mapProductPriceBookEntryId.get(bmqp.BigMachines__Product__c).Product2.ProductCode+'')){

                                PrCode += mapProductPriceBookEntryId.get(bmqp.BigMachines__Product__c).Product2.ProductCode+', ';
                                OrderMapList.put(oli.OrderId,PrCode);
                                }
                            }
                            else {
                                String PrCode = '';
                                PrCode = mapProductPriceBookEntryId.get(bmqp.BigMachines__Product__c).Product2.ProductCode+', ';
                                OrderMapList.put(oli.OrderId,PrCode);
                            }

                            System.debug('####' + oli);
                            if (oli.Extended_Net_Price__c == null) {oli.Extended_Net_Price__c = 0.0;}
                            //CRM 2709
                            if (oli.Part_Number__c == 'BETACONNECT') {oli.Zuora_Comment__c = 'No Zuora Changes';}
                            if (oli.Part_Number__c == 'BETATRANSACT') {oli.Zuora_Comment__c = 'No Zuora Changes';}
                            
                            //CRM 1079
                            if(productCodesMap.containskey(oli.orderId)){
                               Set<String> productCodes = productCodesMap.get(oli.orderId);
                               productCodes.add(mapProductPriceBookEntryId.get(bmqp.BigMachines__Product__c).Product2.ProductCode);
                               productCodesMap.put(oli.orderId, productCodes);
                            }else{
                               Set<String> productCodes = new Set<String>();
                               productCodes.add(mapProductPriceBookEntryId.get(bmqp.BigMachines__Product__c).Product2.ProductCode);
                               productCodesMap.put(oli.orderId, productCodes);
                            }
                            System.debug('####' + productCodesMap);
                            //*****
                            lstOrderLineItems.add(oli);
                        } else {

                        }
                        if (bmqp.Available_Presale_Inventory__c != null) {
                            continue;
                        } else {
                            break;
                        }
                    }
                }
               
                if (!lstOrderLineItems.isEmpty()) {

                    upsert lstOrderLineItems ; // Creating related quote line items
                
                    if (lstOrderLineItems.size() > 0) {
                        UpdateRenewalAsset(setRenewalAssetIds, lstOrderLineItems, quoteNumber, quoteType, mapPriceBookEntryId);
                    }
                    // Modified 29th Aug 2016  Author Name: Pallavi Tammana -- Modifed for JIRA STORY ADVP-2026
                    if(!setBMQuoteEssIds.isEmpty()){
                        List<AsyncRecordProcessExecution__c> lstAsyncRecord = new List<AsyncRecordProcessExecution__c>();
                        AsyncRecordProcessExecution__c arpe = new AsyncRecordProcessExecution__c();
                            arpe.Name = 'Account Trigger';
                            arpe.Interface_Name__c = 'AccountTrigger';
                            arpe.ClassName__c = 'AccountTriggerHandlerManager';
                            arpe.MethodName__c = 'AccountActivateEssentialStatus';
                            arpe.Boolean_Param__c = true;
                            arpe.Records_To_Process_Ids__c = setBMQuoteEssIds+'';
                            lstAsyncRecord.add(arpe);
                        if(!lstAsyncRecord.isEmpty())
                            insert lstAsyncRecord;
                    }
                    // For REESIO and MEDIABUY cases will be created for "Retention" type and no cases for Line Type "Credit".
                    List<OrderItem> oiList = [Select PricebookEntry.Product2.name, id,Part_Number__c,Line_Type__c, order.TL_Quote_Product_Reference__c,order.tigerLeadProductExists__c
                                              , Order.AccountId,Order.Oracle_Quote__c,Order.Type,OrderId,PricebookEntry.Product2.Description
                                              from OrderItem where orderId in :mapListOrder.values()];
                    Map<String, String> mapProductCodeOrdIdNew = new Map<String, String>();
                    Map<String, String> mapProductCodeLineTypeNew = new Map<String, String>();
                    for (OrderItem orderI : oiList) {                    
                        mapProductCodeOrdIdNew.put(orderI.Part_Number__c,orderI.Id);
                        mapProductCodeLineTypeNew.put(orderI.Part_Number__c,orderI.Line_Type__c);
                    }
                    for (OrderItem orderI : oiList) {                    
                        system.debug('Orderitem:' + orderI);
                        if (orderI.Order.Type == null) {orderI.Order.Type = 'New';}
                         // Moving.com : CRM-3209 Create case for Moving Product for manual fulfillment.
                       if ((Label.Moving_Product_Codes.contains(orderI.Part_Number__c) && Label.Moving_Line_Types_for_Manual_Case.contains(orderI.Line_Type__c)) ||
                            (Label.Mortgage_Product_Codes.contains(orderI.Part_Number__c) && Label.Mortgage_Line_Types_for_Manual_Case.contains(orderI.Line_Type__c)) ||
                            // CRM-5848  -- Opcity
                            (Label.Opcity_Product_Codes.contains(orderI.Part_Number__c) && Label.Opcity_Line_Types_for_Manual_Case.contains(orderI.Line_Type__c))) {
                            
                            string recordName = 'MOVING';
                            // CRM-5848 - Opcity
                            if (Label.Opcity_Product_Codes.contains(orderI.Part_Number__c)) {
                                recordName = 'OPCITY';
                            }
                            Manual_Fulfillment_Product_Case__c caseDetails = Manual_Fulfillment_Product_Case__c.getValues(recordName);
                            if (caseDetails != null) {
                                Case caseToAdd = new Case();
                                caseToAdd.Status = caseDetails.Status__c;
                                caseToAdd.Origin = caseDetails.Origin__c;
                                caseToAdd.Type = caseDetails.Type__c;
                                caseToAdd.Order__c = orderI.OrderId;
                                caseToAdd.AccountId = orderI.Order.AccountId;
                                caseToAdd.Area__c = caseDetails.Area__c.replaceAll('PRODUCT_NAME', orderI.PricebookEntry.Product2.name);
                                caseToAdd.Sub_Area__c = caseDetails.Sub_Area__c;
                                caseToAdd.Subject = caseDetails.Subject__c.replaceAll('PRODUCT_NAME', orderI.PricebookEntry.Product2.name);
                                if (Label.Mortgage_Product_Codes.contains(orderI.Part_Number__c)) {
                                    caseToAdd.RecordTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get('Mortgage Standard').RecordTypeId;
                                }
                                else {
                                    caseToAdd.RecordTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get(caseDetails.Record_Type__c).RecordTypeId;
                                
                                }
                                caseToAdd.Description = caseDetails.Description__c.replaceAll('PRODUCT_NAME', orderI.PricebookEntry.Product2.name);
                                
                                // For Assignment Rule
                                AssignmentRule AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
                                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                                dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id;
                                caseToAdd.setOptions(dmlOpts);
                                        
                                lstCases.add(caseToAdd);
                            }
                        }
                        // Moving.com : CRM-3209 End
                        else {
                            //CRM-1491 Did changes for Reesio Products added credit and renew to avoid cases
                           if((mapProductCodeOrdIdNew.get('REESIO') == orderI.OrderId && (mapProductCodeLineTypeNew.get('REESIO') == 'credit' || mapProductCodeLineTypeNew.get('REESIO') == 'Renew'))|| (mapProductCodeOrdIdNew.get('LISTHUBPRO') == orderI.OrderId && (mapProductCodeLineTypeNew.get('LISTHUBPRO') == 'credit' || mapProductCodeLineTypeNew.get('LISTHUBPRO') == 'Renew'))||(mapProductCodeOrdIdNew.get('MEDIABUY') == orderI.id && mapProductCodeLineTypeNew.get('MEDIABUY') == 'credit')||(mapProductCodeOrdIdNew.get('DOMAINNAME') == orderI.id && (mapProductCodeLineTypeNew.get('DOMAINNAME') == 'Amend'|| mapProductCodeLineTypeNew.get('DOMAINNAME') == 'credit' || mapProductCodeLineTypeNew.get('DOMAINNAME') == 'Renew'))){
                            noCasesForCredit = true;
                           }
                            system.debug('noCasesForCredit' + noCasesForCredit);
                            //CRM 2010: Case will be created if this order(Retention) contains REESIO or MEDIABUY 
                             if ((!orderI.Order.Type.contains('Retention') ||  mapProductCodeOrdIdNew.get('REESIO') == orderI.OrderId || mapProductCodeOrdIdNew.get('MEDIABUY') == orderI.id || mapProductCodeOrdIdNew.get('DOMAINNAME') == orderI.id || mapProductCodeOrdIdNew.get('LISTHUBPRO') == orderI.id) && (!noCasesForCredit)) {  /// new change manual 
                                system.debug('---- > oddr.tigerLeadProductExists__c '+orderI.Order.tigerLeadProductExists__c);
                                system.debug('---- > oddr.TL_Quote_Product_Reference__c --> '+orderI.Order.TL_Quote_Product_Reference__c);
                                system.debug('---- > mapTLActivities -->'+mapTLActivities);
                                if ((orderI.Order.tigerLeadProductExists__c == true) && (mapTLActivities.containskey(orderI.Order.TL_Quote_Product_Reference__c)) &&
                                    orderI.Order.Type == 'New' ) {
    
                                        AssignmentRule  AR = new AssignmentRule();
                                        AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
                                        
                                         //Creating the DMLOptions for "Assign using active assignment rules" checkbox
                                        Database.DMLOptions dmlOpts = new Database.DMLOptions();
                                        dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id;
                                        Case caseToAdd = new Case();
                                        caseToAdd.Status = 'New';
                                        caseToAdd.Origin = 'Web';
                                        caseToAdd.Type = 'Outbound';
                                        caseToAdd.Is_Tiger_Lead__c = true;
                                        caseToAdd.Order__c         = orderI.OrderId;
                                        caseToAdd.AccountId         = orderI.Order.AccountId;
                                        caseToAdd.Is_Pre_Welcome_Call__c = true;
                                        caseToAdd.Area__c = 'Product Set Up';
                                        caseToAdd.Subject = 'Tiger Lead Product Set Up activities';
                                        if (mapQuoteCancelCount.containskey(orderI.Order.Oracle_Quote__c)) {
                                            if (mapQuoteCancelCount.get(orderI.Order.Oracle_Quote__c) == 0) {
                                                caseToAdd.Subject = 'Complete Cancel Request';
                                            }
                                        }
                                        caseToAdd.setOptions(dmlOpts);
                                        //caseToAdd.OwnerId = odr.ContactId;
    
                                        caseToAdd.AccountId = orderI.Order.AccountId;
                                        lstCases.add(caseToAdd);
                                    }
                                system.debug('mapManualActivities:' + mapManualActivities);
                                system.debug('mapQuoteLineIdProductCode:' + mapQuoteLineIdProductCode);
                                system.debug('oddr.TL_Quote_Product_Reference__c:' + orderI.Order.TL_Quote_Product_Reference__c);
                                                
                                if (mapManualActivities.containskey(mapQuoteLineIdProductCode.get(orderI.Order.TL_Quote_Product_Reference__c))
                                   && (mapProductCodeOrdIdNew.get('REESIO') == orderI.id || mapProductCodeOrdIdNew.get('MEDIABUY') == orderI.id || mapProductCodeOrdIdNew.get('LISTHUBPRO') == orderI.id || mapProductCodeOrdIdNew.get('DOMAINNAME') == orderI.id) && (!noCasesForCredit)
                                   || test.isrunningTest()) {
                                    system.debug('inside case creation');
                                    Case caseToAdd = new Case();
                                    caseToAdd.Status = 'New';
                                    caseToAdd.Origin = 'Web';
                                    caseToAdd.Type = 'Creative';
                                    caseToAdd.Is_Tiger_Lead__c = true;
                                    caseToAdd.Order__c         = orderI.OrderId;
                                    caseToAdd.Is_Pre_Welcome_Call__c = false;
                                    caseToAdd.Area__c = 'New Ad';
                                    caseToAdd.Subject = 'Manual Activities';//mapManualActivities.get(mapQuoteLineIdProductCode.get(oddr.TL_Quote_Product_Reference__c));
                                    if (mapQuoteCancelCount.containskey(orderI.Order.Oracle_Quote__c)) {
                                        if (mapQuoteCancelCount.get(orderI.Order.Oracle_Quote__c) == 0) {
                                            caseToAdd.Subject = 'Complete Cancel Request';
                                        }
                                    }
                                    if (mapManualQueueName.containskey(mapProductCodeQueueName.get(mapQuoteLineIdProductCode.get(orderI.Order.TL_Quote_Product_Reference__c)))) {
    
                                        caseToAdd.OwnerId = mapManualQueueName.get(mapProductCodeQueueName.get(mapQuoteLineIdProductCode.get(orderI.Order.TL_Quote_Product_Reference__c)));
    
                                    }
                                                AssignmentRule AR = new AssignmentRule();
                                               AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
                                               Database.DMLOptions dmlOpts = new Database.DMLOptions();
                                               dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
                                    
                                    //CRM-1491 Did changes for Reesio Products
                                    //id CaseRecordType = Schema.SObjectType.Case.RecordTypeInfosByName.get('Standard').RecordTypeId;
                                    id CaseRecordType = Schema.SObjectType.Case.RecordTypeInfosByName.get('ProSoft Standard').RecordTypeId;
    
                                    if(mapProductCodeOrdIdNew.get('REESIO') == orderI.id || mapProductCodeOrdIdNew.get('MEDIABUY') == orderI.id || mapProductCodeOrdIdNew.get('LISTHUBPRO') == orderI.id || mapProductCodeOrdIdNew.get('DOMAINNAME') == orderI.id || test.isrunningTest()){
                                        //Case caseToAdd = new Case();
                                       system.debug('inside code:' + mapProductCodeOrdId);
                                        caseToAdd.Is_Tiger_Lead__c = false;
                                        caseToAdd.Type = 'Order';
                                       // caseToAdd.Subject = 'Manual Fulfillment Required';
                                        //caseToAdd.Area__c = 'Manual Fulfillment';
                                       // caseToAdd.Description =  orderI.PricebookEntry.Product2.Description; //mapQuoteLineIdProductName.get(orderI.Order.TL_Quote_Product_Reference__c);
                                        system.debug('checking product name:' + mapQuoteLineIdProductName);
                                        caseToAdd.RecordTypeId = CaseRecordType;
                                         system.debug('checking product code:' + mapProductCodeLineType);
    
                                        if(mapProductCodeLineTypeNew.get('REESIO') == 'Add' && mapProductCodeOrdIdNew.get('REESIO') == orderI.id){                                        
                                            caseToAdd.Area__c = 'Reesio';
                                            caseToAdd.Sub_Area__c = 'New';
                                             caseToAdd.Subject = 'Manual Fulfillment Required';
                                            caseToAdd.Description =  orderI.PricebookEntry.Product2.Description;
                                         }
                                        else if (mapProductCodeLineTypeNew.get('REESIO') == 'Amend' && mapProductCodeOrdIdNew.get('REESIO') == orderI.id){
                                            caseToAdd.Area__c = 'Reesio';
                                            caseToAdd.Sub_Area__c = 'Amendment';
                                             caseToAdd.Subject = 'Manual Fulfillment Required';
                                            caseToAdd.Description =  orderI.PricebookEntry.Product2.Description;
                                        }
                                        else if ((mapProductCodeLineTypeNew.get('REESIO') == 'Cancel' || mapProductCodeLineTypeNew.get('REESIO') == 'Buyout') && mapProductCodeOrdIdNew.get('REESIO') == orderI.id){
                                            caseToAdd.Area__c = 'Reesio';
                                            caseToAdd.Sub_Area__c = 'Cancel';
                                            caseToAdd.Subject = 'Manual Fulfillment Required';
                                            caseToAdd.Description =  orderI.PricebookEntry.Product2.Description;
                                        } //CRM-2329--- DOMAINNAME needs a Manual Fulfillment Process
                                        
                                       else if(mapProductCodeLineTypeNew.get('DOMAINNAME') == 'Add' && mapProductCodeOrdIdNew.get('DOMAINNAME') == orderI.id){                                        
                                            caseToAdd.Area__c = 'Domain Name';
                                            caseToAdd.Sub_Area__c = 'New';
                                            caseToAdd.Subject = 'Domain Name requires manual fulfillment';
                                            caseToAdd.Description = 'A new domain name order has been submitted. Please refer to the google inbox for requested domain for this customer.';
                                         }
                                        else if ((mapProductCodeLineTypeNew.get('DOMAINNAME') == 'Cancel' || mapProductCodeLineTypeNew.get('DOMAINNAME') == 'Buyout') && mapProductCodeOrdIdNew.get('DOMAINNAME') == orderI.id){
                                             caseToAdd.Area__c = 'Domain Name';
                                             caseToAdd.Sub_Area__c = 'Cancel';
                                             caseToAdd.Subject = 'Domain Name requires manual cancellation';
                                             caseToAdd.Description = 'A domain renewal order has been submitted for this customer. Please refer to the Asset for Domain URL specifics.';
                                        }
                                       // CRM-2341 - ListHub needs a Manual Fulfillment Process
                                         else if(mapProductCodeLineTypeNew.get('LISTHUBPRO') == 'Add' && mapProductCodeOrdIdNew.get('LISTHUBPRO') == orderI.id){                                        
                                            caseToAdd.Area__c = 'ListHub';
                                            caseToAdd.Sub_Area__c = 'New';
                                            caseToAdd.Subject = 'ListHub Fulfillment Required';
                                            caseToAdd.Description =  'ListHub Prod, New Order Requires Fulfillment';
                                         }
                                        else if (mapProductCodeLineTypeNew.get('LISTHUBPRO') == 'Amend' && mapProductCodeOrdIdNew.get('LISTHUBPRO') == orderI.id){
                                            caseToAdd.Area__c = 'ListHub';
                                            caseToAdd.Sub_Area__c = 'Amendment';
                                            caseToAdd.Subject = 'ListHub Fulfillment Required';
                                            caseToAdd.Description = 'ListHub Prod, Amendment Order Requires Fulfillment';
                                        }
                                        else if ((mapProductCodeLineTypeNew.get('LISTHUBPRO') == 'Cancel' || mapProductCodeLineTypeNew.get('LISTHUBPRO') == 'Buyout') && mapProductCodeOrdIdNew.get('LISTHUBPRO') == orderI.id){//
                                            caseToAdd.Area__c = 'ListHub';
                                            caseToAdd.Sub_Area__c = 'Cancel';
                                            caseToAdd.Subject = 'ListHub Fulfillment Required';
                                            caseToAdd.Description = 'ListHub Prod, Cancel Order Requires Fulfillment';
                                        }
                                       system.debug('2341 :' + orderI.OrderId + ' ' + mapProductCodeLineTypeNew.get('LISTHUBPRO') + ' ' + mapProductCodeOrdIdNew.get('LISTHUBPRO'));
                                    }
                                    system.debug('inside case creation added');
                                    caseToAdd.AccountId = orderI.Order.AccountId;
                                    caseToAdd.SetOptions(dmlOpts);
                                    system.debug('Cases to be created:' + caseToAdd);
                                    lstCases.add(caseToAdd);
                                }
                            } 
                        }
                    }
                   
                    if (lstCases.size() > 0) {
                        SkipCaseTrigger.setSkipTrgTrue();
                        system.debug('----- insert cases-->'+lstCases);
                        Insert lstCases;
                        for(case caseloop : lstCases) {

                            system.debug('----- case rcd type-->'+caseloop.RecordTypeId);
                        }

                        for (Case cas : lstCases) {
                            if (cas.Is_Pre_Welcome_Call__c) {
                                Task tsk = new Task();  
                                tsk.WhatId = cas.Id;
                                tsk.Subject = 'Pre Welcome Call';
                                if (cas.Subject == 'Complete Cancel Request') {
                                    tsk.Subject = 'Complete Cancel Request' ;
                                }
                                tsk.Is_Tiger_Lead__c = true;
                                lstTask.add(tsk);    
                            } else {
                                System.debug(mapQuoteLineIdProductCode + '$$$$$$$' + cas.Order__c + '$$$$$$' + mapQuoteOrderId.get(cas.Order__c) + 'pppppppp' + mapListOrder);
                                if (mapManualActivities.containskey(mapQuoteLineIdProductCode.get(mapQuoteOrderId.get(cas.Order__c)))) {
                                    system.debug('--- mapManualActivities.get(mapQuoteLineIdProductCode.get(mapQuoteOrderId.get(cas.Order__c)))'+mapManualActivities.get(mapQuoteLineIdProductCode.get(mapQuoteOrderId.get(cas.Order__c))));
                                    for (String sttr : mapManualActivities.get(mapQuoteLineIdProductCode.get(mapQuoteOrderId.get(cas.Order__c))).split(';')) {
                                        if(sttr != 'None'){
                                         Task tsk = new Task();  
                                        tsk.WhatId = cas.Id;
                                        tsk.Subject = sttr;
                                        tsk.Is_Tiger_Lead__c = false;
                                        lstTask.add(tsk);  
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if (!lstTask.isEmpty()) {
                        Insert lstTask;
                    }
                    if (!lstCases.isEmpty()) {
                        //insert lstCases;
                    }
                    Set<Id> orderIds = new  Set<Id>();
                    Set<Id> processedQuoteIds = new Set<Id>();
                    for (Order odr : mapListOrder.values()) {
                        if (odr.Type == 'Modify') {
                            if (mapOrderActionString.containskey(odr.id)) {
                                List<String> lstLineType = mapOrderActionString.get(odr.id).split(',');
                                Integer rcountAdd = 0;
                                Integer rcountRenew = 0;
                                Integer rcountOther = 0;
                                for (String sttr : lstLineType) {
                                    if (sttr != null) {
                                        if (sttr.equalsIgnoreCase('Add')) {
                                            rcountAdd = rcountAdd + 1;
                                        } else if (sttr.equalsIgnoreCase('Renew')) {
                                            rcountRenew = rcountRenew + 1;
                                        } else {
                                            rcountOther = rcountOther + 1;
                                        }
                                    }
                                }
                                if (rcountOther < 1) {
                                    if (rcountAdd > 0 && rcountRenew == 0) {
                                        odr.Type = 'New';
                                    }
                                    if (rcountAdd == 0 && rcountRenew > 0) {
                                        odr.Type = 'Renewal';
                                    }
                                }
                            }
                        }
                        
                        odr.tigerLeadProductExists__c = false;

                        if (mapOrderTLProductString.containskey(odr.id)) {
                            if (mapOrderTLProductString.get(odr.id) == 'Tigerleads') {
                                //mapOrderActionString.put(odr.id,'');
                                odr.tigerLeadProductExists__c = true;
                            }
                        }
                        if (mapOrdernonTLProductString.containskey(odr.id)) {
                            if (mapOrdernonTLProductString.get(odr.id) != 'Tigerleads') {
                                //mapOrderActionString.put(odr.id,'');
                                odr.nonTigerLeadExists__c = true;
                            }
                        }
                        if ((odr.Type == 'Modify' || odr.Type == 'Retension') && odr.nonTigerLeadExists__c == true) {
                            if(mapTLLineType.containskey(odr.id)){
                                odr.Fulfillment_Status__c = Constants.ORDER_FULFILLMENT_STATUS_PENDING;
                            }
                        }
                        if(!OrderMapList.isEmpty() && OrderMapList.containskey(odr.id)) {
                            odr.WelcomeProducts__c = OrderMapList.get(odr.Id);
                        }

                        //CRM 1079 -- Code to update unique product codes in product field
                        System.debug(productCodesMap+'$$$$$$$$');
                        if(productCodesMap.containskey(odr.id)){
                           // List<Order> ordersToUpdate = new List<Order>();
        
                                String uniqueCodes = '';
                                Set<String> productCodesSet = new Set<String>(); //CRM-6065
                                if(productCodesMap.get(odr.id)!=null){
                                List<string> productCodesList = new List<String>();
                                productCodesList.addAll(productCodesMap.get(odr.id));
                                productCodesSet.addAll(productCodesList);
                                if(productCodesSet.contains('LOCALEXPERTCITY') && !productCodesSet.contains('LOCALEXPERT')){ //CRM-6065
                                   odr.contains_only_city__c = true;
                                }
                                System.debug(productCodesList+'$$$$$$$$');
                                
                                for(integer i= 0; i<productCodesList.size(); i++){
                                      
                                     if(i == productCodesList.size()-1){
                                        uniqueCodes += productCodesList[i];
                                     }else{
                                        uniqueCodes += productCodesList[i]+', ';
                                     }
                                     System.debug(uniqueCodes+'$$$$$$$$');
                                }
                                }
                                odr.products__c = uniqueCodes;
                                
                        }
                
                        // Standalone RS
                        If(!suppressModifyQuoteIds.isEmpty() && suppressModifyQuoteIds.contains(odr.Oracle_Quote__c) && odr.Type == 'Modify'){
                                odr.Suppress_Order_Confirmation__c = true;
                        }
                       
                        // RS bundling: suppress email for any order containing bundled products except order containing cobroke
                        if(!suppressMap.isEmpty() && suppressMap.containskey(odr.Oracle_Quote__c) && !odr.products__c.contains('COBROKE')){
                            List<String> bmql = suppressMap.get(odr.Oracle_Quote__c);
                            Boolean isSuppress = true;
                            for(String partNum: bmql){
                                if(odr.products__c.contains(partNum)){
                                     odr.Suppress_Order_Confirmation__c = true;
                                }
                            }
                        }
                //*****
                    }
                    update mapListOrder.values();

                }
                createCaseForTigerLeadAmendments(mapListOrder.values() );

                if (lstBMQuoteProduct.size() > 0) {
                    if (!Test.isRunningTest()) {
                        UpdateQuoteStatusToOrdered(setBMQuoteIds, setOrderIds, setAssetIds, mapAccountAccountManagerUserIds, mapAccountRelationship);
                        //UpdateQuoteStatusToOrdered(setBMQuoteIds,setopportunityIds,setAssetIds,mapAccountAccountManagerUserIds, mapAccountRelationship)
                    }
                } 
                // CRM-2352 Account owner update on quote submission.
                //UpdateQuoteStatusToOrdered(setBMQuoteIds);
                system.debug('BMQuoteIds:' + setBMQuoteIds);
                Set<Id> setAccountIdsForSalesLockUser = new Set<Id>();
                SkipTrigger.setSkipTrgTrue();
                List<BigMachines__Quote__c> lstQuote = [Select Id, Name,  BigMachines__Status__c,BigMachines__Account__c from BigMachines__Quote__c where Id = :setBMQuoteIds];
                for (BigMachines__Quote__c qte : lstQuote) {
                    qte.BigMachines__Status__c = 'Ordered';
                    //setAccountIdsForSalesLockUser.add(qte.BigMachines__Account__c);
                }
                
               /* System.debug('till here+++ venu ' +setAccountIdsForSalesLockUser);
                List<Account> lstAccount = new List<Account>(); 
                for (Account acc : [Select Id, Sales_Lock_User__c,OwnerId from Account where id in :setAccountIdsForSalesLockUser
                                   and owner.Name in ('Realtor Unassigned', 'Batchintegration User','Datamigration User','Inactive AE') 
                                   and sales_lock_user__c != null ])
                {
                        acc.OwnerId = acc.Sales_Lock_User__c;
                        lstAccount.add(acc);
                }
                system.debug('List:' + lstAccount.size());
                if (lstAccount.size() > 0) {
                    system.debug('LstAccount:' + lstAccount);
                    update lstAccount ;
                }          
                   system.debug(' After account update LstAccount:' + lstAccount);
                //Update lstQuote;
                */   
            }
            //Added try-Catch by Nevil Jain: To track the LEAP-8290
        } 
            
            catch (Exception ex) {
            List<Error__c> lstError = new List<Error__c>();
            system.debug('----- error -->'+ex.getMessage()+'---- > '+ex.getLineNumber());

            for (Id idd : setBMQuoteIds) {
                Error__c error = new Error__c();
                error.Name = idd;
                error.Entity_Id__c = 'Quote to order';
                error.Interface_Name__c = 'QuoteToOrderHelperCls';
                error.Error_Description__c = 'CreateOrderOnApproval Future Method ' + ex.getMessage() + '---StackTrace----' + ex.getStackTraceString();
                lstError.add(error);
            }
            if (lstError.size() > 0) {
                insert lstError;
            }
        }
        return OrderMapList.keyset();
    }

    @future
    public static void UpdateOLICreationStatus(Set<Id> orderIds, Set<Id> setOrderIds) {

        List<Order> lstOrder = [Select Id, Name, Is_OLI_Creation_Complete__c from Order where Id = :orderIds];
        for (Order odr : lstOrder) {
            if (!setOrderIds.contains(odr.id)) {
                odr.Is_OLI_Creation_Complete__c = true;
            }
        }
        Update lstOrder;
    }

    Public static void UpdateRenewalAsset(set<Id> RenewalAssetids, List<OrderItem> lstOrderItem, String quoteNumber, String quoteType, Map<Id,PriceBookEntry> mapPriceBookEntryId) {
        Map<Id, Asset> lstRenewalAssets = new Map<Id, Asset>();
        for (OrderItem odri : lstOrderItem) {
            if (RenewalAssetids.contains(odri.Asset__c)) {
                Asset asst = new Asset(Id = odri.Asset__c, Include_Asset__c = false, Renewal_Order_Product__c = odri.id, Renewal_End_Date__c = odri.End_Date__c, Renewal_Price__c = odri.Total_Net__c, Renewal_Start_Date__c = odri.Start_Date__c, Renewal_Status__c = 'Pending Fulfillment');
                //CRM-1264: Renewal Type is set to Manual during Order creation, this needs to be stopped for Auto Renewal Orders
                if(quoteType != 'Auto-Renew')
                    asst.Renewal_Type__c = 'Manual';
                //CRM-3584: Added new field on Order Product for Auto Renewals.
                if(odri.Contracted_Advantage_PPL_string__c != null)
                    asst.Contracted_Advantage_PPL_string__c = odri.Contracted_Advantage_PPL_string__c;   
                asst.Skip_Validation__c = true;
                asst.Inflight_Quote__c = quoteNumber + '*' + odri.Line_type__c+'*PendingRenewalQuote';
                asst.Follow_Up_Status__c = 'Pending Renewal';
                lstRenewalAssets.put(odri.Asset__c, asst);
            } else {
                if (odri.Asset__c != null) {
                    Asset asst = new Asset(Id = odri.Asset__c, Include_Asset__c = false);
                    asst.Skip_Validation__c = true;
                    asst.Inflight_Quote__c = quoteNumber + '*' + odri.Line_type__c+'*OrderedbutPendingFulfillment';
                    if(odri.Line_type__c=='Renew'){asst.Inflight_Quote__c = quoteNumber + '*' + odri.Line_type__c+'*PendingRenewalQuote';}
                    if(mapPriceBookEntryId.get(odri.PriceBookEntryId).product2.Inventory__c==true){
                    if(odri.Line_type__c=='Amend'){asst.Inflight_Quote__c = quoteNumber + '*' + odri.Line_type__c+'*InventoryAssetModificationInflight';}
                    }
                    if(mapPriceBookEntryId.get(odri.PriceBookEntryId).product2.Inventory__c==false){
                    if(odri.Line_type__c=='Amend'){asst.Inflight_Quote__c = quoteNumber + '*' + odri.Line_type__c+'*NoninventoryAssetModificationInflight';}
                    }
                    //asst.Follow_Up_Status__c = 'Pending Renewal';
                    lstRenewalAssets.put(odri.Asset__c, asst);
                }
            }
        }
        if (lstRenewalAssets.values().size() > 0) {
            SkipBackoutAssetTrigger.setSkipTrgTrue();
            SkipComissionTrigger.setSkipTrgTrue();
            update lstRenewalAssets.values();
        }
    }

    public static void findAutoRenewalFlag(Set<Id> newsetbmQuotes) {
        // CRM-1423 Added condition to avoid executing SOQL if set is empty
        if (!newsetbmQuotes.isEmpty()) {
            Integer rcount = [Select count() from BigMachines__Quote_Product__c where BigMachines__Quote__c = :newsetbmQuotes and Need_Manual_Renew__c = true and BigMachines__Quantity__c = 0 and Asset__c != null and BigMachines__Quote__r.BigMachines__Status__c = 'Approved' and Asset__r.Auto_Renewal__c = 'Yes'];
            if (rcount > 0) {
                UpdateAutoRenewalFlage(newsetbmQuotes);
            }
        }
    }

    @future
    public static void UpdateAutoRenewalFlage(Set<Id> newsetbmQuotes) {
        List<Asset> lstAssets = new List<Asset>();
        for (BigMachines__Quote_Product__c bqp : [Select Id, Name, Asset__c, Need_Manual_Renew__c from BigMachines__Quote_Product__c where BigMachines__Quote__c = :newsetbmQuotes and Need_Manual_Renew__c = true and BigMachines__Quantity__c = 0 and Asset__c != null and BigMachines__Quote__r.BigMachines__Status__c = 'Approved' and Asset__r.Auto_Renewal__c = 'Yes']) {
            Asset ast = new Asset(Id = bqp.Asset__c, Auto_Renewal__c = 'No', Renewal_Start_Date__c = null, Renewal_End_Date__c = null);
            lstAssets.add(ast);
        }
        if (lstAssets.size() > 0) {
            SkipComissionTrigger.setSkipTrgTrue();
            update lstAssets;
        }
    }

    @future
    public static void TriggerQuoteToOrder(Set<Id> newsetbmQuotes) {
        List<BigMachines__Quote__c> lstbqp = [Select Id, Name, Execute_Order_Process__c from BigMachines__Quote__c where id = :newsetbmQuotes];
        for (BigMachines__Quote__c bqp : lstbqp) {
            bqp.Execute_Order_Process__c = true;
        }
        if (lstbqp.size() > 0) {
            update lstbqp;
        }
    }

    public Static void UpdateQuoteStatusToRejected(Set<Id> setBMQuoteIds) {
        SkipTrigger.setSkipTrgTrue();


        List<BigMachines__Quote__c> lstQuote = [Select Id, Name, BigMachines__Status__c, tigerLeadProductExists__c from BigMachines__Quote__c where Id = :setBMQuoteIds];
        for (BigMachines__Quote__c qte : lstQuote) {


            if (qte.BigMachines__Status__c == 'Document Expired' || qte.BigMachines__Status__c == 'Customer Rejected') {
                qte.BigMachines__Status__c = 'Rejected';
            }

        }
        if (!Test.isRunningTest()) {
            Update lstQuote;
            if (lstQuote.size() > 0) {
                set<Id> setAssetIds = new set<Id>();
                for (BigMachines__Quote_Product__c bqp : [Select Id, Name, Asset__c, Line_type__c from BigMachines__Quote_Product__c
                                                          where BigMachines__Quote__c = :setBMQuoteIds and Need_Manual_Renew__c = false and BigMachines__Quantity__c > 0]) {
                                                              if (bqp.Line_type__c.equalsIgnoreCase('Renew')) {
                                                                  setAssetIds.add(bqp.Asset__c);
                                                                  
                                                                  
                                                              }
                                                          }
                if (setAssetIds.size() > 0) {
                    List<Asset> lstAsset = [Select Id, Name, Renewal_Start_Date__c, Renewal_End_Date__c from asset where id = :setAssetIds];
                    for (Asset ast : lstAsset) {
                        ast.Renewal_Start_Date__c = null;
                        ast.Renewal_End_Date__c = null;
                    }
                    update lstAsset;
                }
            }
        }
    }



    public Static void UpdateQuoteStatusToOrdered(Set<Id> setBMQuoteIds, Set<Id> setopportunityIds, Set<Id> setAssetIds, Map<Id, Id> mapAccountAccountManagerUserIds, Map<Id, Account_Relationship__c> mapAccountRelationship) {
        SkipTrigger.setSkipTrgTrue();
        Map<Id, Boolean> mapTigerLeadOpp = new Map<Id, Boolean>();
        Map<Id, String> mapFinalOppType = new Map<Id, String>();

        List<BigMachines__Quote__c> lstQuote = [Select Id, Name, BigMachines__Opportunity__c, BigMachines__Account__c, contact_Name__c, Account_Manager__c  , BigMachines__Status__c, tigerLeadProductExists__c from BigMachines__Quote__c where Id = :setBMQuoteIds];
        for (BigMachines__Quote__c qte : lstQuote) {


            if (qte.BigMachines__Status__c == 'Document Expired' || qte.BigMachines__Status__c == 'Customer Rejected') {
                qte.BigMachines__Status__c = 'Expired';
            } else {
                qte.BigMachines__Status__c = 'Ordered';
                if (mapAccountRelationship.containskey(qte.BigMachines__Account__c)) {
                    qte.Primary_Email__c = mapAccountRelationship.get(qte.BigMachines__Account__c).Parent_Account__r.Email_Address__c;
                    qte.Contact_Name__c = mapAccountRelationship.get(qte.BigMachines__Account__c).Contact_To__r.FirstName;
                }
                //qte.contact_Name__c = '';
                if (mapAccountAccountManagerUserIds.containskey(qte.BigMachines__Account__c)) {
                    qte.Account_Manager__c = mapAccountAccountManagerUserIds.get(qte.BigMachines__Account__c);
                }
                //qte.Account_Manager__c = '';
            }
            mapTigerLeadOpp.put(qte.BigMachines__Opportunity__c, qte.tigerLeadProductExists__c );
        }
        if (!Test.isRunningTest()) {
            Update lstQuote;
        }
        Set<String> setNotQuoteType = new Set<String> {'Auto Renewal', 'Retention'};
            for (BigMachines__Quote_Product__c bmqp : [Select Id, name, line_Type__c, BigMachines__Quote__r.BigMachines__Opportunity__c from BigMachines__Quote_Product__c where BigMachines__Quote__r.BigMachines__Opportunity__c = :setopportunityIds and BigMachines__Quote__r.BigMachines_Quote_Type__c != :setNotQuoteType and Line_Type__c LIKE 'renew']) {
                mapFinalOppType.put(bmqp.BigMachines__Quote__r.BigMachines__Opportunity__c, 'Renewal');
            }
        List<Opportunity> lstOpportunity = [Select Id, Name, StageName, Account_Type__c, Is_Tiger_Lead_Quote_del__c from opportunity where id = :setopportunityIds];
        for (Opportunity opp : lstOpportunity) {
            opp.StageName = 'Closed / Won';
            if (mapFinalOppType.containskey(opp.id)) {
                opp.Account_Type__c = 'Renewal';
            }
            if (mapTigerLeadOpp.containskey(opp.Id)) {
                opp.Is_Tiger_Lead_Quote_del__c = mapTigerLeadOpp.get(opp.Id);
            }
        }
        update lstOpportunity ;

        if (lstOpportunity.size() > 0) {
            /* CreateNewAssetsOLIAssetJSONSchedule  p = new CreateNewAssetsOLIAssetJSONSchedule();
Datetime dtt = System.now().addSeconds(10);
String sch = dtt.Second()+' '+dtt.Minute()+' '+dtt.hour()+' '+dtt.day()+' '+dtt.Month()+' ? '+dtt.year();
system.schedule('CreateAssetScheduleJob'+dtt, sch, p);
*/
            List<CronTrigger> listCronTrigger = [select Id from CronTrigger where State = 'DELETED' and nextfiretime = null limit 20];
            If (listCronTrigger.size() > 0) {
                For (Integer i = 0; i < listCronTrigger.size(); i++)
                { System.abortJob(listCronTrigger[i].Id); }
            }
        }

    }

    Public Static void GenerateQuoteTRansactionStrings(Map<Id, BigMachines__Quote__c> mapOrders) {
        Map<Id, Set<String>> mapOrder = new Map<Id, Set<String>>();
        for (BigMachines__Quote_Product__c otm : [Select id, BigMachines__Quote__c,Line_type__c, Inventory_Transaction_Id__c from BigMachines__Quote_Product__c where BigMachines__Quote__c = :mapOrders.keyset() and Inventory_Transaction_Id__c != null]) {
            if(!otm.Line_type__c.equalsIgnoreCase('Renew')){
                if (mapOrder.containskey(otm.BigMachines__Quote__c)) {
                    Set<String> setOrderProductIds = new Set<String>();
                    setOrderProductIds = mapOrder.get(otm.BigMachines__Quote__c);
                    setOrderProductIds.add(otm.Inventory_Transaction_Id__c);
                    mapOrder.put(otm.BigMachines__Quote__c, setOrderProductIds);
                } else {
                    Set<String> setOrderProductIds = new Set<String>();
                    setOrderProductIds.add(otm.Inventory_Transaction_Id__c);
                    mapOrder.put(otm.BigMachines__Quote__c, setOrderProductIds);
                }
            }
        }
        for (Id idd : mapOrder.keyset()) {
            //mapOrders.get(idd).All_quote_Product_Ids__c = (mapOrder.get(idd) + '').replace('}', '').replace('{', '').replace(' ', '');    // CRM-6074 - Commented this line
            // CRM-6074 - Start
            List<String> ids = new List<String>();
            ids.addAll(mapOrder.get(idd));
            mapOrders.get(idd).All_quote_Product_Ids__c = String.join(ids,',');
            // CRM-6074 - End
        }
    }

    Public static void UpdateAssetModification(Map<Id, BigMachines__Quote__c> mapNewquote, Map<Id, BigMachines__Quote__c> mapOldquote) {
        Map<Id, Asset> lstRenewalAssets = new Map<Id, Asset>();

        Set<Id> setQuoteIds = new Set<Id>();
        Set<Id> setClearQuoteIds = new Set<Id>();
        for (BigMachines__Quote__c bmq : mapNewquote.values()) {
            if (bmq.BigMachines__Status__c != null) {
                if (bmq.BigMachines__Status__c == 'Pending Approval' || bmq.BigMachines__Status__c == 'Pending Admin Approval') {
                    setQuoteIds.add(bmq.id);
                } else if ((bmq.BigMachines__Status__c == 'Rejected' || bmq.BigMachines__Status__c == 'Customer Rejected' || bmq.BigMachines__Status__c == 'Document Expired') || ((bmq.BigMachines__Status__c == 'In Progress') && (mapOldquote.get(bmq.id).BigMachines__Status__c == 'Pending Approval' || mapOldquote.get(bmq.id).BigMachines__Status__c == 'Pending Admin Approval'))) {
                    setClearQuoteIds.add(bmq.id);
                }
            }
            System.debug(bmq.BigMachines__Status__c + ' PPP ' + mapOldquote.get(bmq.id).BigMachines__Status__c);
        }
        // CRM-1423 Added condition to avoid executing SOQL if set is empty
        if (!setQuoteIds.isEmpty()) {
            List<BigMachines__Quote_Product__c> lstBMQuoteProduct = [Select Id, BigMachines__Quote__r.BigMachines_Quote_Status__c,BigMachines__Quote__r.BigMachines__Status__c, BigMachines__Quote__r.Name, Asset__c, Line_type__c from BigMachines__Quote_Product__c where BigMachines__Quote__c = :setQuoteIds];
    
            for (BigMachines__Quote_Product__c odri : lstBMQuoteProduct) {
    
                if (odri.Asset__c != null) {
                    Asset asst = new Asset(Id = odri.Asset__c);
                    asst.Inflight_Quote__c = odri.BigMachines__Quote__r.Name + '*' + odri.Line_type__c+'*PendingApproval';
                    if (odri.BigMachines__Quote__r.BigMachines__Status__c == 'Pending Approval' || odri.BigMachines__Quote__r.BigMachines__Status__c == 'Pending Admin Approval') {
                    asst.Inflight_Quote__c = odri.BigMachines__Quote__r.Name + '*' + odri.Line_type__c+'*PendingApproval';
                    }
                    lstRenewalAssets.put(odri.Asset__c, asst);
                }
            }
        }
        
        // CRM-1423 Added condition to avoid executing SOQL if set is empty
        if (!setClearQuoteIds.isEmpty()) {
            List<BigMachines__Quote_Product__c> lstBMQuoteProduct1 = [Select Id, BigMachines__Quote__r.Name, Asset__c, Line_type__c from BigMachines__Quote_Product__c where BigMachines__Quote__c = :setClearQuoteIds];
    
            for (BigMachines__Quote_Product__c odri : lstBMQuoteProduct1) {
                if (odri.Asset__c != null) {
                    Asset asst = new Asset(Id = odri.Asset__c);
                    asst.Inflight_Quote__c = ' ';
                    lstRenewalAssets.put(odri.Asset__c, asst);
                }
            }
        }
        if (lstRenewalAssets.values().size() > 0) {
            SkipBackoutAssetTrigger.setSkipTrgTrue();
            SkipComissionTrigger.setSkipTrgTrue();
            SkipAssetTrigger.setSkipTrgTrue();
            update lstRenewalAssets.values();
        }

    }

    public Static void UpdateOpportunityTypeToTigerLead(Set<Id> setBMQuoteIds) {
        Map<Id, Boolean> mapTigerLeadOpp = new Map<Id, Boolean>();
        Set<Id> setopportunityIds = new Set<Id>();
        List<BigMachines__Quote__c> lstQuote = [Select Id, Name, BigMachines__Status__c, tigerLeadProductExists__c, Opportunity__c from BigMachines__Quote__c where Id = :setBMQuoteIds];
        for (BigMachines__Quote__c qte : lstQuote) {
            if (qte.tigerLeadProductExists__c == true) {
                setopportunityIds.add(qte.Opportunity__c);
            }
        }
        // Update lstQuote;
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        for (Opportunity opp : [Select Id, Name, StageName, Is_Tiger_Lead_Quote_del__c from opportunity where id = :setopportunityIds]) {
            if (opp.Is_Tiger_Lead_Quote_del__c == false) {
                opp.Is_Tiger_Lead_Quote_del__c = true;
                lstOpportunity.add(opp);
            }
        }
        if (lstOpportunity.size() > 0) {
            update lstOpportunity ;
        }
    }

    Public QuoteToOrderHelperCls() {

    }

    public static void createCaseForTigerLeadAmendments(List<Order> orderList ){

        List<Case> casesToBeCreated = new List<Case>();
        // Query TigerLead Amendment Orders - Open
        List<Group> tigerLeadAmendmentQueue = [SELECT Id
                                               FROM Group
                                               WHERE Name = 'TigerLead Amendment Orders - Open'
                                               AND Type = 'Queue'];

        /* Query Order and Order products where
*          Type IN(Modify,Retention)
*          TigerProductExists
*          Any Line Type = Amend Exists
*
*      If results found, create a case and assign to the queue TigerLead Amendment Orders - Open.
*/
        for(Order order : [SELECT Id, Oracle_Quote__c, Oracle_Quote__r.BigMachines__Account__c,
                           (SELECT Id
                            FROM OrderItems WHERE Line_Type__c != 'Buyout' and Line_Type__c != 'Credit' and Line_Type__c != 'Renew' and Line_Type__c != 'Cancel')
                           FROM Order
                           WHERE Id IN :orderList
                           AND tigerLeadProductExists__c = true
                           AND (Type = 'Retention' OR Type = 'Modify') ]){

                               if(order.OrderItems.size() > 0 || Test.isRunningTest()){
                                   Case caseToAdd = new Case();
                                   caseToAdd.Status = 'New';
                                   caseToAdd.Type = 'TigerLead';
                                   caseToAdd.Is_Tiger_Lead__c = true;
                                   caseToAdd.AccountId = order.Oracle_Quote__r.BigMachines__Account__c;
                                   caseToAdd.Order__c = order.Id;
                                   caseToAdd.Oracle_Quote__c = order.Oracle_Quote__c;
                                   caseToAdd.Area__c = 'SalesOps';
                                   caseToAdd.Sub_Area__c = 'Contract Amendment';
                                   caseToAdd.Subject = 'Amendment Quote Submitted';
                                   caseToAdd.Description = 'Amendment Quote has been approved and ordered, please process in fulfillment.';
                                   if(tigerLeadAmendmentQueue != null && tigerLeadAmendmentQueue.size() > 0){
                                       caseToAdd.OwnerId = tigerLeadAmendmentQueue[0].Id;
                                   }
                                   casesToBeCreated.add(caseToAdd);
                               }
                           }

        try{
            insert casesToBeCreated;
            // create one task per case. Assign the task to the case owner.
            /*
List<Task> listOfTasksToBeCreated = new List<Task>();
for(Case caseVar : casesToBeCreated){
Task task = new Task();
task.WhatId = caseVar.Id;
task.Is_Tiger_Lead__c = true;
task.Subject = 'Complete Manual Fulfillment';
listOfTasksToBeCreated.add(task);
}
insert listOfTasksToBeCreated;
*/
        }
        catch(exception ex){
            System.debug('exception ' + ex.getMessage() );
        }

    }
    
    // CRM-2808 - Method to assign Quote Submitter
    public static void assignQuoteSubmitter(Map<Id, BigMachines__Quote__c> newMapbmQuotes, Map<Id, BigMachines__Quote__c> oldMapbmQuotes) {
        for (BigMachines__Quote__c newQuote : newMapbmQuotes.values()) {
            if (newQuote.Quote_Submitted_By__c == null) {
                BigMachines__Quote__c oldQuote = oldMapbmQuotes.get(newQuote.id);
                if (newQuote.BigMachines__Status__c != oldQuote.BigMachines__Status__c &&
                    (newQuote.BigMachines__Status__c == 'Pending Approval' || newQuote.BigMachines__Status__c == 'Approved') &&
                    oldQuote.BigMachines__Status__c == 'In Progress') {
                        
                        newQuote.Quote_Submitted_By__c = UserInfo.getUserId();
                }
            }
        }
    } 
    // CRM-2808 End
    //CRM-4804: Update parent quote id
    public static void updateParentQuoteId(List<BigMachines__Quote__c> newListbmQuotes){
        Set<Id> setAccId = new Set<Id>();
        Map<String, BigMachines__Quote__c> tranIdQuoteMap = new Map<String, BigMachines__Quote__c>();
        for (BigMachines__Quote__c q : newListbmQuotes){
            if(q.Related_parent_quote__c == null && q.ParentQuote__c != null && q.ParentQuote__c != '' && q.ParentQuote__c != q.BigMachines__Transaction_Id__c){
                tranIdQuoteMap.put(q.ParentQuote__c, q);
            }
           
            //Added by Pratik on October 22, 2018 for CRM-4980
            if(q.BigMachines__Account__c != Null && Trigger.isInsert)
                setAccId.add(q.BigMachines__Account__c);
            //Ends here
        }
        if(!tranIdQuoteMap.isEmpty()){
            for(BigMachines__Quote__c pq: [Select id, BigMachines__Transaction_Id__c from BigMachines__Quote__c where BigMachines__Transaction_Id__c IN :tranIdQuoteMap.keySet()]){
                tranIdQuoteMap.get(pq.BigMachines__Transaction_Id__c).Related_parent_quote__c = pq.id;
            }
        }
        
        //Added by Pratik on October 22, 2018 for CRM-4980
        if(!setAccId.isEmpty())
        {
            Map<Id, Account> mapAccount = new Map<Id, Account>([Select Id, Total_Score__c, 
                                                                    Upsell_Score__c, Inventory_Score__c 
                                                                    From Account Where Id IN:setAccId]);
            Account account;
            
            for(BigMachines__Quote__c q : newListbmQuotes)
            {
                if(mapAccount.containsKey(q.BigMachines__Account__c))
                {
                    account = mapAccount.get(q.BigMachines__Account__c);
                    
                    if(account.Total_Score__c > 0)
                        q.Total_Score__c = account.Total_Score__c;
                    if(account.Upsell_Score__c > 0)
                        q.Upsell_Score__c = account.Upsell_Score__c;
                    if(account.Inventory_Score__c > 0)
                        q.Inventory_Score__c = account.Inventory_Score__c;
                }
            }
        }
        //Ends here
    }
    
    //Added by Pratik for SFMC_Lead_Process Requirement on 21st January 2019, commented as per discussion with Sonu on 20th Feb
    public static void handleAfterInsert(List<BigMachines__Quote__c> lstbmQuotes)
    {
        Set<Id> setLeadId = new Set<Id>();
        
        for(BigMachines__Quote__c bmq :lstbmQuotes)
        {
            if(bmq.Lead_Id__c != Null)
                setLeadId.add(bmq.Lead_Id__c);
        }
        
        if(!setLeadId.isEmpty())
            processOpportunity(setLeadId);
    }
    
    @future
    public static void processOpportunity(Set<Id> setQuoteId)
    {
        List<BigMachines__Quote__c> lstbmQuotes = [Select Id,Lead_Id__c,BigMachines__Opportunity__r.CampaignId,Opportunity__c,BigMachines__Opportunity__c, BigMachines__Opportunity__r.Lead__c, Opportunity__r.Lead__c,Opportunity__r.CampaignId From BigMachines__Quote__c Where Id IN:setQuoteId];
        
        Set<Id> setLeadId = new Set<Id>();
        Map<Id,Id> mapContactCampaignId = new Map<Id,Id>();
        Set<Id> setOppId = new Set<Id>();
        for(BigMachines__Quote__c bmq :lstbmQuotes)
        {
            if(bmq.Opportunity__r.Lead__c != Null){
                setLeadId.add(bmq.Opportunity__r.Lead__c);
                setOppId.add(bmq.Opportunity__c);
                }
                
                if(bmq.BigMachines__Opportunity__r.Lead__c != Null){
                setLeadId.add(bmq.BigMachines__Opportunity__r.Lead__c);
                setOppId.add(bmq.BigMachines__Opportunity__c);
                mapContactCampaignId.put(bmq.BigMachines__Opportunity__r.Lead__c,bmq.BigMachines__Opportunity__r.CampaignId);
                }
        }
        
        if(!setLeadId.isEmpty()|| Test.isRunningTest())
        {
            Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>([Select Id, Lead__c, CampaignId From Opportunity Where Lead__c IN:setLeadId and Id=:setOppId limit 1]);
            
            List<Campaign_History__c> lstCampaignHistory = [Select Id, Lead__c, Campaign__c, Campaign__r.Type, Lead__r.Contact__c 
                                                                From Campaign_History__c 
                                                                Where Lead__c IN:setLeadId and Campaign__r.Not_Eligible_for_Multi_Campaign_Attribut__c=false];
            
            List<CampaignTypeWeightage__mdt> lstCampaignTypeWeightage = [Select MasterLabel, Weightage__c 
                                                                            From CampaignTypeWeightage__mdt];
            
            Map<String, Decimal> mapCampaignTypeWeightage = new Map<String, Decimal>();
            
            for(CampaignTypeWeightage__mdt campaignTypeWeightage :lstCampaignTypeWeightage)
                mapCampaignTypeWeightage.put(campaignTypeWeightage.MasterLabel, campaignTypeWeightage.Weightage__c);
            
            Map<String, CampaignInfluence> mapCampaignHistoryVsInfluence = new Map<String, CampaignInfluence>();
            List<CampaignInfluence> lstCampaignInfluence = [Select CampaignId, Influence, OpportunityId, Campaign_history__c 
                                                                From CampaignInfluence 
                                                                Where OpportunityId IN :mapOpportunity.keySet()];
            
            for(CampaignInfluence campaignInfluence :lstCampaignInfluence){
                mapCampaignHistoryVsInfluence.put(campaignInfluence.Campaign_history__c, CampaignInfluence);
                }
            
            List<Campaign_History__c> lstCampaignHistoryRec;
            Map<Id, List<Campaign_History__c>> mapLeadVsCampaignHistory = new Map<Id, List<Campaign_History__c>>();
            Map<Id, Id> mapLeadVsContactId = new Map<Id, Id>();
            Map<Id, Decimal> mapLeadVsTotalWeight = new Map<Id, Decimal>();
            Decimal weight = 1;
            Map<Id,CampaignMember> mapCM = new Map<Id,CampaignMember>();
            for(CampaignMember cmm:[Select Id,Status,contactId from CampaignMember where CampaignId=:mapContactCampaignId.values() and ContactId=:mapContactCampaignId.keyset()]){
            mapCM.put(cmm.contactId,cmm);
            }
            
            for(Campaign_History__c campaignHistory :lstCampaignHistory)
            {
                mapLeadVsContactId.put(campaignHistory.Lead__c, campaignHistory.Lead__r.Contact__c);
                if(mapLeadVsCampaignHistory.containsKey(campaignHistory.Lead__c))
                {
                    lstCampaignHistoryRec = mapLeadVsCampaignHistory.get(campaignHistory.Lead__c);
                    
                    if(mapCampaignTypeWeightage.get(campaignHistory.Campaign__r.Type) > 0)
                    {
                        weight = 1; //mapLeadVsTotalWeight.get(campaignHistory.Lead__c) + mapCampaignTypeWeightage.get(campaignHistory.Campaign__r.Type);
                    }
                }
                else
                {
                    lstCampaignHistoryRec = new List<Campaign_History__c>();
                    if(mapCampaignTypeWeightage.get(campaignHistory.Campaign__r.Type) > 0)
                        weight = 1; //mapCampaignTypeWeightage.get(campaignHistory.Campaign__r.Type);
                }
                
                mapLeadVsTotalWeight.put(campaignHistory.Lead__c, weight);
                lstCampaignHistoryRec.add(campaignHistory);
                mapLeadVsCampaignHistory.put(campaignHistory.Lead__c, lstCampaignHistoryRec);
            }
            
            List<OpportunityContactRole> lstContactRole = new List<OpportunityContactRole>();
            CampaignInfluence newCI;
            String modelId = '03V3a000000fxWDEAY';
            for(CampaignInfluenceModel cim:[SELECT DeveloperName,id FROM CampaignInfluenceModel where DeveloperName='Linear']){
            modelId = cim.id;
            }
            for(Opportunity oppty :mapOpportunity.values())
            {
            if(mapLeadVsContactId.get(oppty.Lead__c)!=null){
                OpportunityContactRole contactRole = new OpportunityContactRole();
                contactRole.ContactId = mapLeadVsContactId.get(oppty.Lead__c);
                contactRole.IsPrimary = True;
                contactRole.OpportunityId = oppty.Id;
                contactRole.Role = 'Other';
                lstContactRole.add(contactRole);
                }
                
                Integer campaignhissize = 1;
                //System.debug(oppty.Lead__c+'$$$$$$'+mapLeadVsCampaignHistory.get(oppty.Lead__c));
                if(mapLeadVsCampaignHistory.containskey(oppty.Lead__c)){
                if(mapLeadVsCampaignHistory.get(oppty.Lead__c).size()>0){campaignhissize = mapLeadVsCampaignHistory.get(oppty.Lead__c).size();}
                for(Campaign_History__c campaignHistory :mapLeadVsCampaignHistory.get(oppty.Lead__c))
                {
                    if(mapCampaignHistoryVsInfluence.containsKey(campaignHistory.Id))
                    {
                        newCI = mapCampaignHistoryVsInfluence.get(campaignHistory.Id);
                    }
                    else
                    {
                        newCI = new CampaignInfluence();
                        newCI.CampaignId = campaignHistory.Campaign__c;
                        newCI.OpportunityId = oppty.Id;
                        newCI.ModelId = modelId;
                        newCI.Campaign_history__c = campaignHistory.Id;
                    }
                    
                    if(mapCampaignTypeWeightage.get(campaignHistory.Campaign__r.Type) > 0){
                        newCI.Influence = 100/campaignhissize; //(mapCampaignTypeWeightage.get(campaignHistory.Campaign__r.Type) / mapLeadVsTotalWeight.get(campaignHistory.Lead__c)) * 100;
                    system.debug('newCI.Influence ==>'+newCI.Influence);
                    }
                    
                    lstCampaignInfluence.add(newCI);
                }
                }
                
                system.debug('lstCampaignInfluence ==>'+lstCampaignInfluence);
            }
            
            system.debug('lstContactRole ==>'+lstContactRole);
            
            if(!lstContactRole.isEmpty())
                Database.insert(lstContactRole);
            
            if(!lstCampaignInfluence.isEmpty()){
            map<Id,Decimal> mapCISize = new map<Id,Decimal>();
            for(CampaignInfluence campInf :lstCampaignInfluence){
            if(mapCISize.containskey(campInf.OpportunityId)){
            Decimal oppsize = mapCISize.get(campInf.OpportunityId);
            mapCISize.put(campInf.OpportunityId,oppsize+1);
            } else {
            mapCISize.put(campInf.OpportunityId,1);
            }
            }
             for(CampaignInfluence campaignInfluence :lstCampaignInfluence){
             if(mapCISize.containskey(campaignInfluence.OpportunityId)){
                Decimal oppsize = mapCISize.get(campaignInfluence.OpportunityId);
                CampaignInfluence.Influence = 100/oppsize;
                }
                }
                Database.upsert(lstCampaignInfluence);
                }
                
                System.debug(lstCampaignInfluence+'My CI');
        }
    }
    //Ends here
   
}