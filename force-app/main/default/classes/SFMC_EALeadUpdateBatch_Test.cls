/*
    class: SFMC_EALeadUpdateBatch_Test 
    Purpose: Test class for SFMC_EngagementActivityLeadUpdateBatch
    Created by: Aparna
    Created date : 1/4/2018
*/
@isTest()
private class SFMC_EALeadUpdateBatch_Test {
    @testsetup
    static void testsetup(){
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
    }
    
    @isTest static void test_method_one() {
        Account accountRecord = SFMC_TestDataFactory.createAccount('Test Account BI',null,true);
        Contact contactRecord = SFMC_TestDataFactory.createContact('Test Contact FN', 'Test Contact LN', accountRecord.Id, true, true);
        //ContactMethod__c contactMethodRecord = SFMC_TestDataFactory.createContactMethod(contactRecord.Id, 'Email', 'Business Email', 'test@gmail.com', true, true);
        ContactMethod__c contactMethodRecord = SFMC_TestDataFactory.createContactMethod(contactRecord.Id,'Email','test@gmail.com',true,false,'Business Email',true);
        Lead leadRecord = SFMC_TestDataFactory.createLead('Test Contact FN', 'Test Contact LN', 'New',accountRecord.id, contactRecord.id,contactMethodRecord.Id,'test',true);  
        Engagement_Activity_Type__c eaTypeRecord = SFMC_TestDataFactory.createEngagementActivtyType('Email open',30,30,true);
        Engagement_Activity__c engagementActivityRecord = SFMC_TestDataFactory.createEngagementActivity(contactMethodRecord.id,eaTypeRecord.id,true); 
        
        Test.startTest();
        Database.executeBatch(new SFMC_EngagementActivityLeadUpdateBatch(), 200);
        Test.stopTest(); 

        List<Engagement_Activity__c> engagementActivityList = [Select Id from Engagement_Activity__c where Lead__c!=null];
        System.assertNotEquals(0,engagementActivityList.size());

    }

    @isTest(SeeAllData=false)
    static void test_method_two() {
        Engagement_Activity_Type__c eaTypeRecord = SFMC_TestDataFactory.createEngagementActivtyType('Email open',30,30,true);
        List<Account> accountList = new List<Account>();
        List<Contact> contactList = new List<Contact>();
        List<ContactMethod__c> cmList = new List<ContactMethod__c>();
        List<Lead> leadList = new List<Lead>();
        List<Engagement_Activity__c> eaList = new List<Engagement_Activity__c>();
        List<Campaign> campaignList =  new List<Campaign>();
        campaignList.add(SFMC_TestDataFactory.CreateCampaign('Test Campaign 1', 'Agent',true, true));
        campaignList.add(SFMC_TestDataFactory.CreateCampaign('Test Campaign 2', 'Broker',true, true));


        Integer bulkCount=10;
        for(Integer count=0; count<bulkCount;count++){
            Integer y = Math.mod(count, 2);
            Account accountRecord = new Account();
            if(y==0){
                accountRecord = SFMC_TestDataFactory.createAccount('Test Account BI'+count,null,false);
            }else{
                accountRecord = createAccount('Test Account BI'+count,null,false,'Broker');
            }
           
            accountList.add(accountRecord);
        }
        insert accountList;
        for(Integer count=0; count<bulkCount;count++){
            Contact contactRecord = SFMC_TestDataFactory.createContact('Test Contact FN'+count, 'Test Contact LN'+count, accountList.get(count).Id, true, false);
            contactList.add(contactRecord);
        }
        insert contactList;

        for(Integer count=0; count<bulkCount;count++){
            ContactMethod__c contactMethodRecord = SFMC_TestDataFactory.createContactMethod(contactList.get(count).Id,'Email','test'+count+'@gmail.com',true,false,'Business Email',false);
            cmList.add(contactMethodRecord);
        }
        System.debug(cmList);
        insert cmList;

        for(Integer count=0; count<bulkCount;count++){
            Integer x = Math.mod(count, 3);
            Integer y = Math.mod(count, 2);
            Lead leadRecord = SFMC_TestDataFactory.createLead('Test Contact FN', 'Test Contact LN', 'New',accountList.get(count).Id, contactList.get(count).Id,cmList.get(x).Id,'test',campaignList.get(y).Id,false);  
            leadList.add(leadRecord);
        }
        insert leadList;

        for(Integer count=0; count<bulkCount;count++){
            Engagement_Activity__c engagementActivityRecord;
            Integer y = Math.mod(count, 2);
            if(y==0){
                engagementActivityRecord = SFMC_TestDataFactory.createEngagementActivity(cmList.get(count).Id,eaTypeRecord.id,campaignList.get(0).Id,false); 
            }else{
                engagementActivityRecord = SFMC_TestDataFactory.createEngagementActivity(cmList.get(count).Id,eaTypeRecord.id,false); 
            }
            eaList.add(engagementActivityRecord);
        }
        insert eaList;

        
        Test.startTest();
        ID batchID=Database.executeBatch(new SFMC_EngagementActivityLeadUpdateBatch(), 200);
        Test.stopTest();    

        List<Engagement_Activity__c> engagementActivityList = [Select Id from Engagement_Activity__c where Lead__c!=null];
        System.assertNotEquals(0,engagementActivityList.size());
    }

    @isTest static void test_method_three() {
        Account accountRecord = SFMC_TestDataFactory.createAccount('Test Account BI',null,true);
        Contact contactRecord = SFMC_TestDataFactory.createContact('Test Contact FN', 'Test Contact LN', accountRecord.Id, true, true);
        //ContactMethod__c contactMethodRecord = SFMC_TestDataFactory.createContactMethod(contactRecord.Id, 'Email', 'Business Email', 'test@gmail.com', true, true);
        ContactMethod__c contactMethodRecord = SFMC_TestDataFactory.createContactMethod(contactRecord.Id,'Email','test@gmail.com',true,false,'Business Email',true);
        Lead leadRecord = SFMC_TestDataFactory.createLead('Test Contact FN', 'Test Contact LN', 'New',accountRecord.id, contactRecord.id,contactMethodRecord.Id,'test',true);  
        Engagement_Activity_Type__c eaTypeRecord = SFMC_TestDataFactory.createEngagementActivtyType('Email open',30,30,true);
        Engagement_Activity__c engagementActivityRecord = SFMC_TestDataFactory.createEngagementActivity(contactMethodRecord.id,eaTypeRecord.id,true); 
        
        Test.startTest();
        Database.executeBatch(new SFMC_LeadScoreCalculationBatch(), 200);
        Database.executeBatch(new SFMC_EngagementActivityLeadUpdateBatch(), 200);
        Test.stopTest();  

        List<Engagement_Activity__c> engagementActivityList = [Select Id from Engagement_Activity__c where Lead__c!=null];
        System.assertEquals(0,engagementActivityList.size());  
    }

    public static Account createAccount(String theName, Id OwnerId, Boolean isInsert,String accountType) {
        Account theAccount = SFMC_TestDataFactory.createAccount(theName,OwnerId,false);
        theAccount.Type=accountType;
        if(isInsert) {
          insert theAccount;
        }
        return theAccount;
      }


    
}