@isTest
public class CreateMyQuoteControllerWL_Test{
    static {
        BigMachines__Configuration_Record__c site = new BigMachines__Configuration_Record__c(BigMachines__Is_Active__c=true, BigMachines__action_id_copy__c='test', BigMachines__action_id_open__c='test', BigMachines__bm_site__c='test', BigMachines__document_id__c='test', BigMachines__process__c='test', BigMachines__process_id__c='test',BigMachines__version_id__c='test');
        insert site;
    }
    
    public static testMethod void main1(){
   //Insertion  of setting for Account 
      DisabledTrigger__c Dtrg           = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'test@test.com');
        insert Dtrg;
         //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
        testAccount.Name = 'XYZ';
         testAccount.Phone = '+49-12345';
         testAccount.BillingStreet = 'Am Tierpark 16';
         testAccount.BillingCity = 'Cologne';
         testAccount.BillingPostalCode = '54321';
         testAccount.BillingState = 'Nordrhein-Westfalen';
         testAccount.BillingCountry = 'Germany';
         testAccount.Primary_Email__c = 'ra@gmail.com';
         testAccount.Home_Phone__c = '1234567890';
         testAccount.Work_Phone__c = '456789';
         testAccount.Mobile1__c = '1234566';
         testAccount.Mobile2_Other__c = '1245787';
         testAccount.party_id__c = '';
          insert testAccount; 
          ApexPages.currentPage().getParameters().put('id',testAccount.id);
          Test.startTest();     
          ApexPages.StandardController stc = new ApexPages.StandardController(testAccount);
         CreateMyQuoteControllerWL StcObj = new  CreateMyQuoteControllerWL(stc);
         CreateMyQuoteControllerWL obj = new CreateMyQuoteControllerWL();
         String newvalue;
         String n = newvalue;
         
         obj.setToken(n);
         obj.getToken();
         obj.setDegree(n);
         obj.getDegree();
         obj.setSlotSize(n);
         obj.getSlotSize();
         obj.setLeadRoutingType(n);
         obj.getLeadRoutingType();
         obj.setStatus(n);
         obj.getStatus();
         obj.setAccountId(n);
         obj.getAccountId();
         obj.setNotes(n);
         obj.getNotes();
         obj.setqtyinterested(n);
         obj.getqtyinterested();
         obj.setoperation(n);
         obj.getoperation();
         obj.getMyOrderBy();
         obj.setMyOrderBy(n);
         obj.getMyFilter();
         obj.setMyFilter(n);
         obj.getMyLimit();
         obj.setMyLimit(n);
         obj.mSetting_CPQURL ='testurl';
         obj.mSetting_CPQFULLURL='testesds';
         obj.mSetting_CPQUSER='Temporary1';
         obj.mSetting_CPQPASSWORD ='test1';
         ApexPages.StandardController sc1 = new ApexPages.standardController(testAccount);
         CreateMyQuoteControllerWL obj1 = new CreateMyQuoteControllerWL(sc1);
         obj1.createQuote();
         CreateMyQuoteControllerWL.MyQuote MQ = new CreateMyQuoteControllerWL.MyQuote();
         CreateMyQuoteControllerWL.QuoteWrapper QW = new CreateMyQuoteControllerWL.QuoteWrapper();
         CreateMyQuoteControllerWL.MyQuote MQ1 = new CreateMyQuoteControllerWL.MyQuote();
         MQ1.sfdcid = '344234';
         //MQ1.OpportunityId = '006g0000007cRgg'; 
         List<CreateMyQuoteControllerWL.MyQuote> MQlist = new List<CreateMyQuoteControllerWL.MyQuote>();
         MQlist.add(MQ1);
         CreateMyQuoteControllerWL.QuoteWrapper QW1 = new CreateMyQuoteControllerWL.QuoteWrapper();
         List<CreateMyQuoteControllerWL.QuoteWrapper> QWrapper = new List<CreateMyQuoteControllerWL.QuoteWrapper>();
         QWrapper.add(QW1);
         Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
         String sessionId=UserInfo.getSessionId();
         String tId;
         Integer i;
         tId = '10';
         
         insert new BigMachineUrls__c(Name='WLBM', DefaultUserName__c = 'sonusharma', DefaultPassword__c='csE7342(H4');
       insert new Waitlist_Urls__c(Name='CPQXSD', URL__c = 'https://devmoveinc.bigmachines.com/bmfsweb/devmoveinc/schema/v1_0/commerce/oraclecpqo.xsd');
       insert new Waitlist_Urls__c(Name='CPQReciever', URL__c = 'https://devmoveinc.bigmachines.com/v1_0/receiver');        
        
        
        
         QW1.UpdateBigMachineQuote(tId,'atype',MQlist,QW);
         QW1.bmsessionid = 'bm Test';
         QW1.AccountId = 'Account id test';
         QW1.LeadId = 'Test lead';
         QW1.OpportunityId = 'test opportunity';
         QW1.CaseId = 'test Case id';
         QW1.party_Id = 'test party id';
         QW1.quoteType = 'Test Quote type';
         QW1.assetid = 12335;
         QW1.contractterm = '1223';
         QW1.prodemail = 'Test prod';
         QW1.billingperiod='Monthly';
         QW1.commercegrp='test grp';
         QW1.hlcoverride ='Test cvr';
         QW1.msaTier ='test ms tier';
         QW1.assetpricee = 2345.56;
         QW1.ProductCode = 'Test pro code';
         //CreateMyQuoteControllerWL.CreateMyQuoteProc(MQlist);
        boolean b =checkRecursive.runOnce();
        
        try {QW1.GetSessionId('','');} catch(Exception e) {}
        try {QW1.GetSessionId(null,null);} catch(Exception e) {}
        try {QW1.GetSessionId('test',null);} catch(Exception e) {}
        try {QW1.CreateBigMachineQuote(MQlist,QW1);}catch(Exception e) {}
        QW1.accountId = testAccount.Id;
        Contact myContact = new Contact ();
        myContact.FirstName='Joe';
        myContact.LastName='Schmoe';
        myContact.Email='Joe.Schmoe@test.de';
        myContact.Account= testAccount;
        myContact.Type__c = 'Other';
        myContact.Active__c = true;
        insert myContact;
        Campaign Campaigns = new Campaign(); 
        Campaigns.Name = 'test';
        insert Campaigns;
        CampaignMember m1 = new CampaignMember();
        m1.ContactId = myContact.Id; 
        m1.status = 'sent';
        m1.CampaignId = Campaigns.Id;
        //m1.LeadId = LedAll[0].id;
        insert m1;
        try {QW1.createOpportunity();}catch(Exception e) {}
        delete testAccount;
        try {QW1.createOpportunity();}catch(Exception e) {}
        List<CreateMyQuoteControllerWL.MyQuote> temp = QW1.mQuoteItems;
         Test.stopTest();  
         
     }
  
   public static testMethod void main2(){
         
         CreateMyQuoteControllerWL.MyQuote MQ1 = new CreateMyQuoteControllerWL.MyQuote();
         MQ1.sfdcid = '344234';
         MQ1.OpportunityId = ''; 
         MQ1.Product = 'FAC';
         List<CreateMyQuoteControllerWL.MyQuote> MQlist = new List<CreateMyQuoteControllerWL.MyQuote>();
         MQlist.add(MQ1);
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
         CreateMyQuoteControllerWL.QuoteWrapper QW1 = new CreateMyQuoteControllerWL.QuoteWrapper();
         String tId;
         Integer i;
         tId = '10';
    insert new BigMachineUrls__c(Name='WLBM', DefaultUserName__c = 'sonusharma', DefaultPassword__c='csE7342(H4');
       insert new Waitlist_Urls__c(Name='CPQXSD', URL__c = 'https://devmoveinc.bigmachines.com/bmfsweb/devmoveinc/schema/v1_0/commerce/oraclecpqo.xsd');
       insert new Waitlist_Urls__c(Name='CPQReciever', URL__c = 'https://devmoveinc.bigmachines.com/v1_0/receiver');        
        
         QW1.UpdateBigMachineQuote(tId,'atype',MQlist,QW1);
         
         Test.stopTest();
     }
     
    public static testMethod void PageReference(){
   //Insertion  of setting for Account 
   DisabledTrigger__c Dtrg           = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'test@test.com');
        insert Dtrg;
         //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
        testAccount.Name = 'XYZ';
         testAccount.Phone = '+49-12345';
         testAccount.BillingStreet = 'Am Tierpark 16';
         testAccount.BillingCity = 'Cologne';
         testAccount.BillingPostalCode = '54321';
         testAccount.BillingState = 'Nordrhein-Westfalen';
         testAccount.BillingCountry = 'Germany';
         testAccount.Primary_Email__c = 'ra@gmail.com';
         testAccount.Home_Phone__c = '1234567890';
         testAccount.Work_Phone__c = '456789';
         testAccount.Mobile1__c = '1234566';
         testAccount.Mobile2_Other__c = '1245787';
         testAccount.party_id__c = '';
         insert testAccount; 
         ApexPages.currentPage().getParameters().put('id',testAccount.id);
         Test.startTest();
        
         ApexPages.StandardController sc2 = new ApexPages.standardController(testAccount);
         CreateMyQuoteControllerWL obj2 = new CreateMyQuoteControllerWL(sc2);
      
      insert new BigMachineUrls__c(Name='WLBM', DefaultUserName__c = 'sonusharma', DefaultPassword__c='csE7342(H4');
       insert new Waitlist_Urls__c(Name='CPQXSD', URL__c = 'https://devmoveinc.bigmachines.com/bmfsweb/devmoveinc/schema/v1_0/commerce/oraclecpqo.xsd');
       insert new Waitlist_Urls__c(Name='CPQReciever', URL__c = 'https://devmoveinc.bigmachines.com/v1_0/receiver');        
    
        obj2.createQuote();
        string temp = obj2.bmsessionid;
        temp = obj2.quoteType;
        Date d = obj2.clsdate;
        try { obj2.InsertOpportunity();}catch(exception e) {}
        try {CreateMyQuoteControllerWL.CreateNewOpportunity(testAccount.Id);}catch(exception e) {}
        try {obj2.CallQuote();}catch(exception e) {}
        List<CreateMyQuoteControllerWL.MyQuote> quotes = new List<CreateMyQuoteControllerWL.MyQuote>();
        CreateMyQuoteControllerWL.MyQuote q = new CreateMyQuoteControllerWL.MyQuote();
        q.sfdcid = testAccount.Id;
        q.caseId = '';
        temp = q.caseId;
        quotes.add(q);
        try {CreateMyQuoteControllerWL.CreateMyQuoteProc(quotes);}catch(exception e) {}
        Test.stopTest();
     
    }
}