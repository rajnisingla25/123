@isTest
public class caseupdateschedularTest {
    
    private static final Integer COUNTER = 10;
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    static testmethod void SchedulesTimesheetJob() 
    {
        Test.startTest();
        String jobId = System.schedule('ScheduleApexClassTest',
                                       CRON_EXP, 
                                       new scheduledSalesLockTCVWaitlistExpire());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        Test.stopTest();        
        System.assertEquals(CRON_EXP, 
                            ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2022-03-15 00:00:00', 
                            String.valueOf(ct.NextFireTime));
        
    }
    
    
     static testMethod void caseUpdateTest()
     {
        Test.startTest();
        Profile objProfile = [Select Id, Name from Profile where Name =: 'Move Retentions & Collections' limit 1];
        String key = EncodingUtil.convertToHex(crypto.generateAesKey(128));      

        User newUser = new User(
            profileId = objProfile.id,
            username = 'testsdsadasdsadasd@test.com'+key.substring(0, 1),
            email = 'test@test.com',
            emailencodingkey = 'UTF-8',
            localesidkey = 'en_US',
            languagelocalekey = 'en_US',
            timezonesidkey = 'America/Los_Angeles',
            alias=key.substring(0, 7),
            lastname='lname',
            firstname='fname' //,
            //contactId =
        );
        insert newUser;
        system.runAs(newUser) {
            // Compare the logged in user has Move Retentions & Collections profile
            if(objProfile.Id == newUser.profileID){
                CaseUpdate ca = new CaseUpdate();
                Id rententionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Retention').getRecordTypeId();
             
             //Inserting Customsetting for Account     
                DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
                  insert Dtrg;
                Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
                Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
                Id rtId = CaseRecordTypeInfo.get('Retention').getRecordTypeId();
                
                CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
                insert setting;
                
                Id profile = [SELECT Id FROM Profile WHERE Name = 'Move Retentions & Collections' limit 1].id;
            
                // Test Account
                Account theTestAccount = TestDataFactory.createAccount('Team Member Test Account', null, false);
                theTestAccount.Primary_Email__c = 'testEmailRandom@test.com';
                insert theTestAccount; 
            
                // Test Team Member
                AccountTeamMember actMember = new AccountTeamMember();
                actMember.AccountId = theTestAccount.Id;
               // actMember.UserId = '005g0000002BxaT';
                actMember.UserId = Userinfo.getUserId();
                actMember.TeamMemberRole='Retention Rep';
                insert actMember;
             
                 case a = new case();
                 a.AccountId=thetestAccount.Id;
                 a.status = 'Open';
                 a.Origin='Phone';
                 a.recordTypeId = rtId;
                 insert a;
                 
                 
                 Product2 prdctdata = Commissions_TestDataFactory.CreateProduct('Name',false);
                 prdctdata.Commission_Category__c = 'NORMAL';
                 insert prdctdata;         
         
                id rectypidasset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();    
                Asset assets = new Asset();
                assets.RecordTypeId = rectypidasset;
                assets.Name = 'test';
                assets.Renewal_Status__c = 'Renew';
                assets.Auto_Renewal__c = 'No';
                assets.Asset_Type__c = 'Parent';
                assets.Product2Id = prdctdata .id;
                assets.Fulfillment_Status__c = 'Constants.FULFILLMENT_STATUS';
                assets.Status = 'Constants.ACTIVE_STATUS';
                assets.At_Risk__c = false;
                assets.Billing_Period__c = 'Monthly';
                assets.Start_Date__c = system.today();
                assets.End_Date__c = system.today().addDays(10);
                assets.Asset_Type__c = 'Parent';
                assets.Auto_Renewal__c  = 'Yes';
                assets.Line_Type__c = 'renew';
                assets.Price = 10.00;
                insert assets;
             
                Case_Asset_Relationship__c cr = new Case_Asset_Relationship__c();
                    cr.Case__c= a.id;
                    cr.Asset__c= assets.id;
                    cr.At_Risk_Amount__c = 20.00;
                    cr.New_Risk__c = 10.00;
                    cr.Saved_Amount__c = 21.00;
                    //cr.Asset_Status__c ='Cancelled';
                insert cr;
                
                
                // Inserting Test Contact With No Email Address.
                Contact theContactWithoutEmail = TestDataFactory.createContact('The Test', 'Contact Without Email', theTestAccount.Id, true, false);
                //theContactWithoutEmail.Email = 'hsingh@appirio.com';
                insert theContactWithoutEmail; 
                   
                // Inserting Child Cases.
                Case theChildCase = null;
                List<Case> theChildCases = new List<Case>();
                for(Integer index = 0; index < COUNTER; index++) {
                  theChildCase = TestDataFactory.createCase(
                   'Child Case #' + index,
                   'New',
                   'International',
                   'Child Case #' + index,
                   (index <= 1) ? theContactWithoutEmail.Id : theContactWithoutEmail.Id,
                   theTestAccount.Id,
                   false
                  );
                  theChildCase.ParentId = a.Id;
                  theChildCase.status ='Closed';
                  theChildCases.add(theChildCase);
                }
                insert theChildCases;
                        
             ID batchprocessid = Database.executeBatch(ca);
            }
        }
               Test.StopTest();

     }

    
}