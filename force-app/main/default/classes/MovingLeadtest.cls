@isTest (seeAllData=True)
public class MovingLeadtest 
{
    public static boolean ismoving = true;
    public String Ischanged { get; set; }
    public String PerUnitPrice { get; set; }
    public String Quantity { get; set; }
    public boolean isnewmovinglead { get; set;}
    public string pageName{get;set;}
    Public String Fieldapi{get; set;}
    //public Blob csvFileBody{get;set;}
    public static String[] csvFileLines{get;set;}
    static String str = 'Name,AccountNumber,Type,Accountsource,Industry\n Esha Patharabe,10001,Prospect,Test,Banking\n Trupti Nimje,10002,Prospect,Test,Banking,Test_123,10001,100,New,Test,01pn0000000Mrs2'; 
    static testmethod void testfileupload(){
        Test.startTest();    
        Test.setCurrentPage(Page.mortgage);
        MovingLeadcontroller ext = new MovingLeadcontroller();
        Blob csvFileBody = Blob.valueOf(str);
        String csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\n'); 
        ext.csvFileBody = csvFileBody;
        ext.importCSVFile();
        set<String> setcids = new set<string>{'t2174093','t2174098'};
        ext.sendErrorEmail(setcids);
        Test.stopTest();
    } 
    static testmethod void testfileupload1(){
        Test.startTest();  
         Test.setCurrentPage(Page.mortgage);
       Blob csvFileBody = Blob.valueOf(str);
        String csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\n'); 
        MovingLeadcontroller ext = new MovingLeadcontroller();
        ext.importCSVFile();
        Test.stopTest();
    }
    static testMethod void testMethodmoving() 
    {
   Id movingRecordTypeId = Schema.SObjectType.Moving_Lead__c.getRecordTypeInfosByName().get('Moving').getRecordTypeId();
   Id mortgageRecordTypeId = Schema.SObjectType.Moving_Lead__c.getRecordTypeInfosByName().get('Mortgage').getRecordTypeId();
        // DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        //  insert Dtrg;
        //Account account = Z_LegacyTestFactory.makeAccount(); 
        Account testaccount = new Account();    
        testaccount.name = 'test';
        //testaccount.email = '1@1.com';
        testaccount.phone = '123456789';
        insert testaccount;
        // Contact testContact = Z_LegacyTestFactory.makeContact(account);   
        Contact testContact = new contact();    
        testContact.lastname = 'test';
        testContact.firstname = 'testmail';
        testContact.email = '1@1.com';
        testContact.phone = '123456789';
        testContact.AccountId = testaccount .Id;
        insert testContact;    
        Product2 prdctdata1 = new Product2();
        prdctdata1.name = 'New MovingTest';
        prdctdata1.S_No__c = 11;
        prdctdata1.ProductCode = 'MOVINGLEADS';
        prdctdata1.isActive = true;
        insert prdctdata1; 
     
        Asset myAsset = new Asset();
        myAsset.Name = 'test asset';
        myAsset.AccountId = testaccount .Id;      
        myAsset.Fulfillment_Status__c = 'Success';
        myAsset.Asset_Type__c = 'Parent';
        myAsset.ContactId = testContact.Id;
        myAsset.Product2Id = prdctdata1.Id;
        myAsset.Subscription_Id__c = '323232323232323232323232323';
       If(Switch_AssetTrigger__c.getInstance().Set_Overall_Trigger_Off__c == True){
        insert myAsset;
        }
        List<Moving_Lead__c> insmvng = new List<Moving_Lead__c>();
        Moving_Lead__c mvg = new Moving_Lead__c();
        mvg.Asset__c = myAsset.Id;
        mvg.Quantity__c= 2;
        mvg.Status__c = 'New';
        mvg.Per_Unit_Price__c= 32;
        mvg.Account_ID__c = testaccount.Id;
        mvg.Created_Date__c = Date.today();
        mvg.RecordTypeId = mortgageRecordTypeId;
        insmvng.add(mvg);
        Moving_Lead__c mvg2 = new Moving_Lead__c();
        mvg2.Asset__c = myAsset.Id;
        mvg2.Quantity__c= 2;
        mvg2.Status__c = 'Processing';
        mvg2.Per_Unit_Price__c= 32;
        mvg2.Account_ID__c = testaccount.Id;
        mvg2.Created_Date__c = Date.today();
        mvg2.RecordTypeId = movingRecordTypeId;
        insmvng.add(mvg2);
        insert insmvng;
        
        Test.startTest();
        Test.setCurrentPage(Page.MovingLeads);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(insmvng);
        stdSetController.setSelected(insmvng);  
        MovingLeadcontroller ext = new MovingLeadcontroller();
        ext.orderByColumn = 'Name';
        ext.Ascdesc = 'ASC';
        ext.Selectall = true;
        ext.statusvalue = 'New';
        ext.rowIndex = 0;
        ext.Changestatusselected();
        ext.Sendtozuora();
        ext.first(); 
        ext.last(); 
        ext.save();
        ext.Newrecords();
        ext.NewLead();
        ext.previous(); 
        ext.next(); 
        ext.ReturntoHome();
        ext.getthevalues();
        ext.editmethid();
        ext.getTotalPages();
        ext.refreshPageSize();
        ext.Search();
        ext.savemethid();
        ext.hasNext = false;
        ext.hasPrevious = false;
        ext.pageNumber  =20;
        ext.deleteSelectedLeads();
        set<String> setis = new set<string>{'01pn0000000Mrsz', '01pn0000000Mrs2'};
            ext.sendEmail(setis);
        ext.dateFormat(String.valueOf(system.today()));  
        Test.stopTest();      
    }
    static testMethod void testMethodmovingRestCall() 
    {
        Test.startTest();
        Test.setCurrentPage(Page.MovingLeads);
        MovingLeadcontroller obj = new MovingLeadcontroller();
        MovingLeadcontroller.startDate = Date.today()-19;
        MovingLeadcontroller.endDate = Date.today();
        Test.setMock(HttpCalloutMock.class, new MockMovingLeadController());
        obj.importLeads();
        ImportLeads testData= getLeadData();
        obj.insertLeads(testData);
        Test.stopTest();
    }
    private static ImportLeads getLeadData() {
        ImportLeads testData = new ImportLeads(); 
        List<ImportLeads.UsageRecord> records = new List<ImportLeads.UsageRecord>();
        Asset asid = [Select id from asset where product_code__c ='MOVINGLEADS' and status = 'Active' and fulfillment_status__c ='Fulfilled' and Asset_Type__c = 'Parent' and Line_type__c ='Add' limit 1];
        For (integer i=0;i<1;i++) {
            ImportLeads.UsageRecord lead = new ImportLeads.UsageRecord();
            lead.acct ='11';
            lead.aid = string.valueof(asid.Id);
            lead.qty = '1';
            lead.rate = '1';
            lead.name = 'test';
            records.add(lead);
        }
        testData.Status = 'Success';
        testData.UsageRecord = records;
        return testData; 
    }
    
}