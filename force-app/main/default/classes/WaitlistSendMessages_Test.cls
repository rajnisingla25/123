@isTest
private class WaitlistSendMessages_Test {
        static testMethod void method1(){
            
            
                    Account testAccount = createTestAccount(null, true);
/*
            Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
              testAccount.Primary_Email__c = 'testAccoun11t@move.com';
              testAccount.Billing_Preference__c = 'Invoice-CC';
              insert testAccount;
              
            
            contact c = new contact();
   c.lastname = 'test';
   c.accountid = testAccount.id;
   c.FirstName = 'ravi';
   c.Title = 'sath';
   c.email ='rav12i@gmail.com';
   c.Phone = '1234567895';
   c.MobilePhone= '1234567895';
   c.MailingState = 'California';
   c.MailingCountry = 'United States';
   c.MailingCity = 'knr';
   c.MailingStreet = 'test';
   c.MailingPostalCode = '524345';
   c.Preferred_Phone__c='1234567890';
   
   insert c;  
            
         //Inserting Test Contact 
           // Insert Opportunity
            Schema.DescribeSObjectResult OppSchema = Schema.SObjectType.Opportunity; 
            Map<String,Schema.RecordTypeInfo> OppRecType= OppSchema.getRecordTypeInfosByName(); 
            Id opprtId = OppRecType.get('Broker Field Sales').getRecordTypeId(); 
            
            Opportunity op = New Opportunity();
             op.name = 'TESTING BY BOSS';
             op.AccountId = testAccount.id;
             op.Opportunity_Short_Description__c = 'Testing BY BOSS';
             op.CloseDate = System.today().addDays(28);
             op.StageName = 'Qualify Opportunity';
             op.ForecastCategoryName = 'Pipeline';
             op.RecordTypeId = opprtId;
            Insert op;
            
        
          Waitlist__c wldata = new Waitlist__c();
        wldata.Account__c = testAccount.id;
        wldata.Status__c = 'Created';
        wldata.Pre_Auth_Contact__c = c.Id;
        wldata.Pre_Auth_Email__c = c.Email;
        Insert wldata;
          Product2 prdctdata = new Product2();
        prdctdata.Name = 'product name';
        prdctdata.S_No__c = 2;
        insert prdctdata;
        
        Waitlist_Item__c wlidata1 = new Waitlist_Item__c();
        wlidata1.Waitlist__c    = wldata.Id;
        wlidata1.Waitlist_ID__c = '1234'; 
        wlidata1.Waitlist_Expiration_Date__c  = system.today();
        wlidata1.Original_Max_Spend__c = 100;
        wlidata1.Status__c = 'Pending Pre-Auth';
        wlidata1.Account__c = testAccount.id;
        wlidata1.Product__c = prdctdata.id;
        wlidata1.Market__c = '30339';
        wlidata1.Market_Type__c = 'City';
        wlidata1.Product_Size__c = 'Full';
        wlidata1.rank__c = 0;
        insert wlidata1;
        
        Waitlist_Item__c wlidata2 = new Waitlist_Item__c();
        wlidata2.Waitlist__c    = wldata.Id;
        wlidata2.Waitlist_ID__c = '1234'; 
        wlidata2.Waitlist_Expiration_Date__c  = system.today();
        wlidata2.Original_Max_Spend__c = 100;
        wlidata2.Status__c = 'Active';
        wlidata2.Account__c = testAccount.id;
        wlidata2.Product__c = prdctdata.id;
        wlidata2.Market__c = '30339';
        wlidata2.Market_Type__c = 'City';
        wlidata2.Product_Size__c = 'Full';
        wlidata2.rank__c = 1;
        insert wlidata2;*/
            
             test.startTest();
            WaitlistSendMessages sh1 = new WaitlistSendMessages();   
            String sch = '12 12 12 * * ?';
           /* 
           List<CronTrigger> ct =  [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name LIKE 'WaitlistSchedule'] ; 
            for(CronTrigger c: ct){
                System.abortJob(c.id);

            } 
*/
            
                
            try{
            system.schedule('TestClass_Testing', sch, sh1);
            }catch(Exception e){
                
                
            }
        Test.stopTest();

        }
    
    public static Account createTestAccount(Account parent, Boolean doInsert) 
    {
        Account testAcc = new Account();
        testAcc.Name = 'Test Account';
        testAcc.BillingCity = 'Atlanta';
        testAcc.BillingState = 'GA';
        testAcc.BillingCountry = 'USA';
        testAcc.BillingPostalCode = '12345';
        testAcc.BillingStreet = '123 Main St';
        
        if (parent != null) {
            testAcc.ParentId = parent.Id;
        }
        if (doInsert) {
            insert testAcc;
        }
    
        return testAcc;
    }


}