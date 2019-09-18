//
// (c) 2015 NTTData, Inc.
//
// Test Class Name: WebserviceCallBigMachineQuoteCls_Test
// Description: Test Class for WebserviceCallBigMachineQuoteCls
//
// 07th Dec 2015    Sonu Sharma    Original (Task # T-380800)

@isTest
private class WebserviceCallBigMachineQuoteCls_Test {
    Public static testMethod void testWebserviceCallBigMachineQuoteClsFunctionality() {
        MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
        mtduc.CreateBMURLSingle();
        mtduc.CreateDisabledTriggerSingle();
        mtduc.CreateBrokerAccountSingle();
        mtduc.CreateOppurtunitySingle();
        mtduc.CreateContactSingle();
        mtduc.CreateContractSingle();
        mtduc.CreateProductSingle();
        mtduc.CreateOracleQuoteSingle();
        Asset ast = mtduc.CreateFullfilledAssetSingle();
        Map<Id,String> assetIds = new Map<Id,String>();
        Set<Id> asstId = new Set<Id>();
        List<CreateWaitlistQuoteWrapper> lstCreateWaitlistQuoteWrapper = new List<CreateWaitlistQuoteWrapper>();
        CreateWaitlistQuoteWrapper cwqw = new CreateWaitlistQuoteWrapper();
        lstCreateWaitlistQuoteWrapper.add(cwqw);
        assetIds.put(ast.id,'amend##customerRequest');
        asstId.add(ast.Id);
        WebserviceCallBigMachineQuoteCls wcbmq = new WebserviceCallBigMachineQuoteCls();
        wcbmq.CreateQuote('SonuSharma','TestPassword',mtduc.newAccount.id,mtduc.theOpportunity.id,null,'Retention','amend',true,false,assetIds);
    	wcbmq.CreateQuote('SonuSharma','TestPassword',mtduc.newAccount.id,mtduc.theOpportunity.id,null,'Backout','amend',true,false,assetIds);
    
        //Test.setMock(WebServiceMock.class, new WebServiceBMSessionId());
        //String sessionIdd = wcbmq.GetSessionId('SonuSharma','123123');
        //wcbmq.CreateBigMachineQuote();
        //wcbmq.CreateBigMachineQuoteWaitlist();
        wcbmq.UpdateBigMachineQuote('23423','ppp');
        //wcbmq.CreateWaitlistQuote('SonuSharma','TestPassword',mtduc.newAccount.id,mtduc.theOpportunity.id,null,'Retention','amend',true,false,assetIds);
        wcbmq.CreateWaitlistQuote('SonuSharma','TestPassword',mtduc.newAccount.id,mtduc.theOpportunity.id,null,'Retention','amend',true,false,'waitlistId','wquoteOwnerName','wquoteOwnerId',lstCreateWaitlistQuoteWrapper);
        wcbmq.executeAutoRenewalUpdate= false;
        wcbmq.UpdateBigMachineQuoteWaitlist('23423','ppp');
    }

    Public static testMethod void testWebserviceCallBigMachineQuoteClsFunctionality2() {
        MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
        mtduc.CreateBMURLSingle();
        mtduc.CreateDisabledTriggerSingle();
        mtduc.CreateBrokerAccountSingle();
        mtduc.CreateOppurtunitySingle();
        mtduc.CreateContactSingle();
        mtduc.CreateContractSingle();
        mtduc.CreateProductSingle();
        mtduc.CreateOracleQuoteSingle();
        Asset ast = mtduc.CreateFullfilledAssetSingle();
        Asset ast1 = mtduc.CreateFullfilledAssetSingle();
        ast.Commerce_Group__c = 'Agent Marketing Solution';
        ast.ConfigOptions__c = 'Residential';
        ast.ResidentialLeadPPL__c = 100;
        ast.ResidentialBrandPPL__c = 100;
        ast.ResidentialAMLC__c = 100;
        ast.LandAMLC__c = 100;
        ast.RentalAMLC__c = 100;
        ast.ContractedAMLC__c = 100;
        ast.DecommissionedAsset__c = ast1.Id;
        ast.AMLCOverride__c = 100;
        ast.PPLOverride__c = 100;
        ast.Billing_Period__c = 'Monthly';
        update ast;
        Map<Id,String> assetIds = new Map<Id,String>();
        Set<Id> asstId = new Set<Id>();
        List<CreateWaitlistQuoteWrapper> lstCreateWaitlistQuoteWrapper = new List<CreateWaitlistQuoteWrapper>();
        CreateWaitlistQuoteWrapper cwqw = new CreateWaitlistQuoteWrapper();
        lstCreateWaitlistQuoteWrapper.add(cwqw);
        assetIds.put(ast.id,'amend##customerRequest');
        asstId.add(ast.Id);
        WebserviceCallBigMachineQuoteCls wcbmq = new WebserviceCallBigMachineQuoteCls();
        wcbmq.CreateQuote('SonuSharma','TestPassword',mtduc.newAccount.id,mtduc.theOpportunity.id,null,'Retention','amend',true,false,assetIds);
        wcbmq.UpdateBigMachineQuote('23423','ppp');
        //wcbmq.CreateWaitlistQuote('SonuSharma','TestPassword',mtduc.newAccount.id,mtduc.theOpportunity.id,null,'Retention','amend',true,false,assetIds);
        wcbmq.CreateC3Quote('SonuSharma','TestPassword',mtduc.newAccount.id,mtduc.theOpportunity.id,null,'Retention','amend',true,false,'waitlistId','wquoteOwnerName','wquoteOwnerId',lstCreateWaitlistQuoteWrapper);
        wcbmq.executeAutoRenewalUpdate= false;
        wcbmq.UpdateBigMachineQuoteWaitlist('23423','ppp');
        List<WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper> lstAutoRenewalQuoteLineWrapper = new List<WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper>();
        WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper arqlwr = new WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper();
        arqlwr.BMActionRequired='Remove';
        lstAutoRenewalQuoteLineWrapper.add(arqlwr);
        wcbmq.UpdateDeleteAutoRenewalQuote(wcbmq.SFCreatedQuoteId,lstAutoRenewalQuoteLineWrapper);
        
        WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper arqlwr1 = new WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper();
        arqlwr1.BMActionRequired = 'Add';
        lstAutoRenewalQuoteLineWrapper.add(arqlwr1);
        wcbmq.UpdateDeleteAutoRenewalQuote(wcbmq.SFCreatedQuoteId,lstAutoRenewalQuoteLineWrapper);
        
        WebserviceCallBigMachineQuoteCls.SendQuoteDocuSign('1234', 'exportAttachmentViaTimer_quote');
        
        wcbmq.lineActionType = 'CFBQuote';
        wcbmq.UpdateBigMachineQuote('23423','ppp');
    }
        
}