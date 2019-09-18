//**************************************************//
// (c) 2015 NTTDATA, Inc.
// Class Name : QuoteToOrderTrg_Test
// Usage: Used for trigger QuoteToOrderTrg and QuoteToOrderHelperCls.
//
// Created 30th june 2015   Author Name:-  Vikram Thallapelli     Original
// Modified 30th june 2015   Author Name:-  Vikram Thallapelli     Modified
//**************************************************//
@isTest(seeAllData = false)
Public Class QuoteToOrderTrg_Test{
    static {
        BigMachines__Configuration_Record__c site = new BigMachines__Configuration_Record__c(BigMachines__Is_Active__c=true, BigMachines__action_id_copy__c='test', BigMachines__action_id_open__c='test', BigMachines__bm_site__c='test', BigMachines__document_id__c='test', BigMachines__process__c='test', BigMachines__process_id__c='test',BigMachines__version_id__c='test');
        insert site;
   }
    private static final Integer COUNTER = 1;
    
    public static testMethod Void QuoteTest1(){
        //test.startTest();
        OrderDecompController.stopCreatingAccount = true;
        SkipOrderItemTrigger.setSkipTrgTrue();
        Tiger_Lead_Products__c tl = new Tiger_Lead_Products__c(Name = 'DACAMPAIGN' , Queue_Name__c = 'DAP_Fulfillment' , TigerLeadActivities__c = 'Stripe Setup;Customer Completed Training' , Tiger_Lead_Product_List__c = 'HANDRAISER;HOMESRCH');
        insert tl;
        Tiger_Lead_Products__c tl1 = new Tiger_Lead_Products__c(Name = 'TigerLeads' , TigerLeadActivities__c = 'Complete DACAMPAIGN Manual Activities' , Tiger_Lead_Product_List__c = 'DACAMPAIGN;HOMESRCH');
        insert tl1;
        Cancellation_Reason_CPQ_Mapping__c cr =  new Cancellation_Reason_CPQ_Mapping__c(Name = 'Good Cancel' , CPQ_Variable_Name__c = 'goodCancel');
        insert cr;
        Schedule_Batch_Setting__c scheduleBatchSetting = new Schedule_Batch_Setting__c(Name = 'NVM Callback', Assetresttime__c = 1, Execution_Min__c=1);
        insert scheduleBatchSetting;

        MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
        mtduc.CreatePresaleAvailable();

        mtduc.CreateUserSingle();  
        //mtduc.UpdateUserSingle();   
        mtduc.CreateDisabledTriggerSingle();
        mtduc.CreateTigerLeadSingle2();
        mtduc.CreateBrokerAccountSingle();
        mtduc.CreateContractSingle();

              mtduc.CreateCaseSingle();

        mtduc.CreateOppurtunitySingle();
        mtduc.CreateContactSingle(); 
        Product2 prod = mtduc.CreateProductSingle(); 
        prod.Fulfillment_Type__c = 'Auto';
        prod.ProductCode = 'REESIO';
        update prod;
        Id orderId = mtduc.CreateOrderSingle().id;
        mtduc.CreateProductManualSingle();
        Asset a = mtduc.CreateFullfilledAssetSingle();
        a.Auto_Renewal__c = 'yes';
        mtduc.CreatePricebookEntrySingle();
        mtduc.CreatePricebookEntryManualSingle();
        //System.debug(mtduc.thePricebookEntrie+'666666');
        mtduc.CreateOpportunityProductSingle();
        mtduc.CreateOracleQuoteSingle();


        BigMachines__Quote_Product__c qp = mtduc.CreateQuoteProductSingleAndManual()[0];
        qp.Available_Presale_Inventory__c = 'test';
        qp.Need_Manual_Renew__c = true;
        qp.BigMachines__Quantity__c = 100;
        qp.asset__c = a.Id;
        update qp;
        /*mtduc.CreateQuoteProductPresaleSingle();
        */
        test.startTest(); 

        mtduc.UpdateOracleQuoteSingle();
        QuoteToOrderHelperCls qtohcls = new QuoteToOrderHelperCls();         
        Set<Id> newsetbmQuotes = new Set<Id>();
        Set<Id> newsetOpportnity = new Set<Id>();
        Set<Id> newsetAssetIds = new Set<Id>();
        Set<Id> neworderids = new Set<Id>();
        Set<Id> orderids = new Set<Id>{orderId};
        Map<Id, BigMachines__Quote__c> mapQuote = new Map<Id, BigMachines__Quote__c>();
        mapQuote.put(mtduc.UpdateOracleQuoteSingle().id,mtduc.UpdateOracleQuoteSingle());
        neworderids.add(mtduc.CreateOrderSingle().id);
        List<Order> lstOrders = new List<Order>();
        lstOrders.add(mtduc.CreateOrderSingle());


        Map<Id,Id> mapAccountAccountManagerUserIds = new Map<Id,Id>();
        Map<Id,Account_Relationship__c> mapAccountRelationship = new Map<Id,Account_Relationship__c>();
        newsetbmQuotes.add(mtduc.OracleQuote.id);
        newsetOpportnity.add(mtduc.theOpportunity.id);
        QuoteToOrderHelperCls.TriggerQuoteToOrder(newsetbmQuotes);          
        QuoteToOrderHelperCls.UpdateAutoRenewalFlage(newsetbmQuotes);
        QuoteToOrderHelperCls.UpdateOpportunityTypeToTigerLead(newsetbmQuotes);         
        QuoteToOrderHelperCls.UpdateQuoteStatusToOrdered(newsetbmQuotes,newsetOpportnity,newsetAssetIds,mapAccountAccountManagerUserIds,mapAccountRelationship);
        QuoteToOrderHelperCls.UpdateQuoteStatusToRejected(newsetbmQuotes);
        QuoteToOrderHelperCls.UpdateOLICreationStatus(orderids, orderids);
        Map<Id, Asset> assets = new Map<Id, Asset>([Select id FROM Asset]);
        List<OrderItem> items = new List<OrderItem>();
        OrderItem item1 = new OrderItem();
        item1.Asset__c = assets.values()[0].Id;
        item1.Contracted_Advantage_PPL_string__c = 'test';
        items.add(item1);
         QuoteToOrderHelperCls.UpdateRenewalAsset(assets.keySet(), items, 'test', 'test', new Map<Id, PriceBookEntry>([Select id FROM PriceBookEntry]));
       
        //QuoteToOrderHelperCls.GenerateQuoteTRansactionStrings(mapQuote);
        //QuoteToOrderHelperCls.createCaseForTigerLeadAmendments(lstOrders);
        Test.stoptest();
    }
     
    public static testMethod Void QuoteTest2(){
        //test.startTest();
        OrderDecompController.stopCreatingAccount = true;
        SkipOrderItemTrigger.setSkipTrgTrue();
        Tiger_Lead_Products__c tl = new Tiger_Lead_Products__c(Name = 'DACAMPAIGN' , Queue_Name__c = 'DAP_Fulfillment' , TigerLeadActivities__c = 'Stripe Setup;Customer Completed Training' , Tiger_Lead_Product_List__c = 'HANDRAISER;HOMESRCH');
        insert tl;
        Tiger_Lead_Products__c tl1 = new Tiger_Lead_Products__c(Name = 'TigerLeads' , TigerLeadActivities__c = 'Complete DACAMPAIGN Manual Activities' , Tiger_Lead_Product_List__c = 'DACAMPAIGN;HOMESRCH');
        insert tl1;
        Cancellation_Reason_CPQ_Mapping__c cr =  new Cancellation_Reason_CPQ_Mapping__c(Name = 'Good Cancel' , CPQ_Variable_Name__c = 'goodCancel');
        insert cr;
        Schedule_Batch_Setting__c scheduleBatchSetting = new Schedule_Batch_Setting__c(Name = 'NVM Callback', Assetresttime__c = 1, Execution_Min__c=1);
        insert scheduleBatchSetting;

        MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
              mtduc.CreatePresaleAvailable();

        mtduc.CreateUserSingle();  
        //mtduc.UpdateUserSingle();   
        //mtduc.CreateDisabledTriggerSingle();
        DisabledTrigger__c Dtrg = new DisabledTrigger__c();
        Dtrg.Name = 'Disabled';
        Dtrg.Order_Trigger__c= UserInfo.getUserName();
        insert Dtrg;
        
        mtduc.CreateTigerLeadSingle2();
        mtduc.CreateBrokerAccountSingle();
        mtduc.CreateContractSingle();
              mtduc.CreateCaseSingle();

        mtduc.CreateOppurtunitySingle();
        mtduc.CreateContactSingle(); 
        Product2 prod = mtduc.CreateProductSingle(); 
        prod.Fulfillment_Type__c = 'Auto';
        prod.ProductCode = 'DIGITALAGENT';
        update prod;
        mtduc.CreateOrderSingle();
        mtduc.CreateProductManualSingle();
        mtduc.CreateFullfilledAssetSingle();
        mtduc.CreatePricebookEntrySingle();
        mtduc.CreatePricebookEntryManualSingle();
        //System.debug(mtduc.thePricebookEntrie+'666666');
        mtduc.CreateOpportunityProductSingle();
        mtduc.CreateOracleQuoteSingle();
        //mtduc.CreateQuoteProductSingle();

        List<BigMachines__Quote_Product__c> qpl = mtduc.CreateQuoteProductSingleAndManual();
        qpl[0].name = 'COBROKE';
        qpl[0].Available_Presale_Inventory__c = 'test';
        update qpl[0];
        //mtduc.CreateQuoteProductPresaleSingle();
        //
        test.startTest();

        BigMachines__Quote__c bquote = mtduc.UpdateOracleQuoteSingle();
        //mtduc.UpdateOracleQuoteSingle()
        QuoteToOrderHelperCls qtohcls = new QuoteToOrderHelperCls();         
        Set<Id> newsetbmQuotes = new Set<Id>();
        Set<Id> newsetOpportnity = new Set<Id>();
        Set<Id> newsetAssetIds = new Set<Id>();
        Set<Id> neworderids = new Set<Id>();
        Set<Id> orderids = new Set<Id>();
        Map<Id, BigMachines__Quote__c> mapQuote = new Map<Id, BigMachines__Quote__c>();
        mapQuote.put(bquote.id,bquote);
        QuoteToOrderHelperCls.GenerateQuoteTRansactionStrings(mapQuote);
        neworderids.add(mtduc.CreateOrderSingle().id);
        List<Order> lstOrders = new List<Order>();
        Order odr = mtduc.CreateOrderModifySingle();
        odr.Type='Retention';
        update odr;
        mtduc.CreateOrderModifyItemSingle();
        lstOrders.add(odr);
        QuoteToOrderHelperCls.createCaseForTigerLeadAmendments(lstOrders);
        Map<Id, Asset> assets = new Map<Id, Asset>([Select id FROM Asset]);
        List<OrderItem> items = new List<OrderItem>();
        OrderItem item1 = new OrderItem();
        item1.asset__c=mtduc.CreateFullfilledAssetSingle().Id;
        item1.Contracted_Advantage_PPL_string__c = 'test';
        items.add(item1);
        try {
         QuoteToOrderHelperCls.UpdateRenewalAsset(assets.keySet(), items, 'test', 'test', new Map<Id, PriceBookEntry>([Select id FROM PriceBookEntry]));
        }catch(exception e){}
        Test.stoptest();
    }
   
    public static testMethod Void QuoteTest3(){
        DisabledTrigger__c Dtrg = new DisabledTrigger__c();
        Dtrg.Name = 'Disabled';
        Dtrg.Order_Trigger__c= UserInfo.getUserName();
        insert Dtrg;
        Manual_Fulfillment_Product_Case__c moving = new Manual_Fulfillment_Product_Case__c(name='Moving', area__c='moving', Status__c='Open', Origin__c='web', Subject__c='Moving');
        insert moving;
        OrderDecompController.stopCreatingAccount = true;
        SkipOrderItemTrigger.setSkipTrgTrue();
        //test.startTest();
        Tiger_Lead_Products__c tl = new Tiger_Lead_Products__c(Name = 'DACAMPAIGN' , Queue_Name__c = 'DAP_Fulfillment' , TigerLeadActivities__c = 'Stripe Setup;Customer Completed Training' , Tiger_Lead_Product_List__c = 'HANDRAISER;HOMESRCH');
        insert tl;
        Tiger_Lead_Products__c tl1 = new Tiger_Lead_Products__c(Name = 'TigerLeads' , TigerLeadActivities__c = 'Complete DACAMPAIGN Manual Activities' , Tiger_Lead_Product_List__c = 'DACAMPAIGN');
        insert tl1;
        Cancellation_Reason_CPQ_Mapping__c cr =  new Cancellation_Reason_CPQ_Mapping__c(Name = 'Good Cancel' , CPQ_Variable_Name__c = 'goodCancel');
        insert cr;
        Schedule_Batch_Setting__c scheduleBatchSetting = new Schedule_Batch_Setting__c(Name = 'NVM Callback', Assetresttime__c = 1, Execution_Min__c=1);
        insert scheduleBatchSetting;

        MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
        Presale_Available_Inventory__c inv = mtduc.CreatePresaleAvailable();

        mtduc.CreateUserSingle();  
        //mtduc.UpdateUserSingle();   
        //mtduc.CreateDisabledTriggerSingle();
        
        mtduc.CreateTigerLeadSingle2();
        Account brkAcc = mtduc.CreateBrokerAccountSingle();
        system.debug('brokeracct-------->>>' + brkAcc);
        Contract contrct = mtduc.CreateContractSingle();
        system.debug('contrct-------->>>' + contrct);
              mtduc.CreateCaseSingle();

        mtduc.CreateOppurtunitySingle();
        mtduc.CreateContactSingle(); 
        Product2 prod = mtduc.CreateProductSingle(); 
        prod.Fulfillment_Type__c = 'Auto';
        //prod.ProductCode = 'ADVANTAGE';
        update prod;
        mtduc.CreateOrderSingle();
        Product2 p = mtduc.CreateProductManualSingle();
       // p.ProductCode = 'MOVINGLEADS';
       // update p;
        //mtduc.CreateFullfilledAssetSingle();
        mtduc.CreatePricebookEntrySingle();
        //mtduc.newProductManual = prod;
        mtduc.CreatePricebookEntryManualSingle();
        //System.debug(mtduc.thePricebookEntrie+'666666');
        mtduc.CreateOpportunityProductSingle();
        BigMachines__Quote__c bmquote = mtduc.CreateOracleQuoteSingle();
        system.debug('bmq--------->>' + bmquote);
        bmquote.BigMachines__Account__c = brkAcc.id;
       
        update bmquote;
        BigMachines__Quote_Product__c qp = mtduc.CreateQuoteProductSingle();
        qp.asset__c = mtduc.CreateFullfilledAssetSingle().id;
        qp.Inventory_Transaction_Id__c = 'qwe';
        qp.Available_Presale_Inventory__c = null;
        qp.RS_Action_Type__c = 'Upgrade';
        update qp;
        test.startTest();
        List<BigMachines__Quote_Product__c> updlist = new List<BigMachines__Quote_Product__c>();
        List<BigMachines__Quote_Product__c>  bqpl = mtduc.CreateQuoteProductSingleAndManual();
        bqpl[0].promotion__c = 'FREEBUNDLERSRESPOND';
        bqpl[1].promotion__c = 'FREEBUNDLERSCONNECT';
        updlist.addAll(bqpl);
        BigMachines__Quote_Product__c bqp = mtduc.CreateQuoteProductSingle();
        bqp.promotion__c = 'FREEBUNDLERSTRANSACT';
        updlist.add(bqp);
        update updlist;
        /*mtduc.CreateQuoteProductPresaleSingle();
        */
        // test.startTest();

        BigMachines__Quote__c bquote = mtduc.UpdateOracleQuoteSingle();
        //mtduc.UpdateOracleQuoteSingle()
        QuoteToOrderHelperCls qtohcls = new QuoteToOrderHelperCls();         
        Set<Id> newsetbmQuotes = new Set<Id>();
        Set<Id> newsetOpportnity = new Set<Id>();
        Set<Id> newsetAssetIds = new Set<Id>();
        Set<Id> neworderids = new Set<Id>();
        Set<Id> orderids = new Set<Id>();
        Map<Id, BigMachines__Quote__c> mapQuote = new Map<Id, BigMachines__Quote__c>();
        mapQuote.put(bquote.id,bquote);
        QuoteToOrderHelperCls.GenerateQuoteTRansactionStrings(mapQuote);
        bquote.BigMachines__Status__c = 'Pending Approval';
        update bquote;
        bquote.BigMachines__Status__c = 'Rejected';
        update bquote;
        set<Id> accId = new Set<id>();
        accid.add(mtduc.newAccount.id);
        bquote.BigMachines__Status__c = 'Approved';
        bquote.BigMachines_Quote_Type__c = 'Modify';
        update bquote;
        QuoteToOrderHelperCls.CreateOrderOnApproval(mapQuote.keySet(), accId);
        QuoteToOrderHelperCls.UpdateRenewalAsset(new Map<Id, Asset>([Select id FROM Asset]).keySet(), [Select id FROM OrderItem], 'test', 'test', new Map<Id, PriceBookEntry>([Select id FROM PriceBookEntry]));
        Test.stoptest();
    }
}