/********************************************************************************************
*   @Author :       Aparna Shankar(Brillio Technologies) 
*   @Purpose:       Test methods for EngagementActivityUtils
*   @TestClass      SFMC_EngagementActivityUtils_Test
*   @Class          AccountContactMappingHandler
*   @JIRA           SMCI-52
*   @CreatedDate:   12-13-2018
*********************************************************************************************
   JIRA No      Date       Modified By         Description                                Tag No
***********************************************************************************************
*/
@isTest
private class SFMC_EngagementActivityUtils_Test{
    
    @testSetup static void setup() {

        DisabledTrigger__c dt=new DisabledTrigger__c();
        dt.name='Disabled';
        dt.TaskTrigger__c='move@.com';
        insert dt;

        List<Account> testAccts = new List<Account>();
        for(Integer i=0;i<10;i++) {
           //testAccts.add(TestDataFactory.createAccount('Test'+i,null,false));
           testAccts.add(SFMC_TestDataFactory.createAccount('Test'+i,null,false));
        }
        insert testAccts;
        List<Contact> testContacts = new List<Contact>();
        for(Integer i=0;i<10;i++) {
           testContacts.add(SFMC_TestDataFactory.createContact('Test Contact FN'+i, 'Test Contact LN'+i, testAccts.get(i).Id, true, false));
        }
        insert testContacts;   

        Campaign camp = new Campaign();
        camp.Name = 'Test Campaign';
        insert camp;

        
    
    }
    @isTest static void test_createEGAforFormSubmission_success_1() {
        List<Account> testAccts = [Select Id from Account];
        List<Contact> testContacts = [Select Id from Contact];
        Campaign camp = [Select Id from Campaign where Name='Test Campaign' LIMIT 1];
        
        List<ContactMethod__c> testContactMethods = new List<ContactMethod__c>();
         for(Integer i=0;i<5;i++) {
            for(Integer j=0;j<5;j++){
                testContactMethods.add(SFMC_TestDataFactory.createContactMethod(testContacts.get(i).Id,'Email','test'+i+'_'+j+'@gmail.com',true,false,'Business Email',false));
            }
        }
        insert testContactMethods; 

        Engagement_Activity_Type__c enAcTy = new Engagement_Activity_Type__c(Channel__c=SFMC_Constants.ENGAGEMENT_ACTIVITY_TYPE_CHANNEL_FORM,
                                                                            Type__c=SFMC_Constants.ENGAGEMENT_ACTIVITY_TYPE_TYPE_LANDING_PAGE,
                                                                            Score__c=500,
                                                                            Weightage__c=50);
        insert enAcTy;

        List<Form_Submission__c>  fsList = createFormSubmission(testContactMethods,camp.Id);
        System.debug('**++**'+fsList);
        Test.startTest();
        insert fsList[0];
        Test.stopTest();
        
        List<Engagement_Activity__c> ega = [Select Id,Engagement_Activity_Type__r.Channel__c,Engagement_Activity_Type__r.Type__c 
                                            from Engagement_Activity__c e ];
                                            //where Contact_Method__c =:testContactMethods[0].Id];

        System.assertNotEquals(0,ega.size());

    }
    @isTest static void test_createEGAWithoutAccount(){
        List<Contact> testContactWithoutAccount = new List<Contact>();
        List<Lead> testLeadList = new List<Lead>();
        Set<Id> ContactMethodIdSet = new Set<Id>();
        Campaign camp = [Select Id from Campaign where Name='Test Campaign' LIMIT 1];
        for(Integer i=0;i<10;i++) {
           testContactWithoutAccount.add(SFMC_TestDataFactory.createContact('Test Contact FN'+i, 'Test Contact LN'+i, null, true, false));
        }
        insert testContactWithoutAccount;
        
        for(Integer i=0;i<10;i++) {
           testLeadList.add(SFMC_TestDataFactory.CreateLead('Test Lead FN'+i, 'Test Lead LN'+i, 'New', null, testContactWithoutAccount.get(i).Id, 'Test', 'Email', false));
        }
        insert testLeadList;
        List<ContactMethod__c> testContactMethods = new List<ContactMethod__c>();
         for(Integer i=0;i<5;i++) {
            for(Integer j=0;j<5;j++){
                testContactMethods.add(SFMC_TestDataFactory.createContactMethod(testContactWithoutAccount.get(i).Id,'Email','test'+i+'_'+j+'@gmail.com',true,false,'Business Email',false));
            }
        }
        insert testContactMethods;
        
        for(ContactMethod__c cm:testContactMethods){
            ContactMethodIdSet.add(cm.Id);
        }
        
        Engagement_Activity_Type__c enAcTy = new Engagement_Activity_Type__c(Channel__c=SFMC_Constants.ENGAGEMENT_ACTIVITY_TYPE_CHANNEL_FORM,
                                                                            Type__c=SFMC_Constants.ENGAGEMENT_ACTIVITY_TYPE_TYPE_LANDING_PAGE,
                                                                            Score__c=500,
                                                                            Weightage__c=50);
        insert enAcTy;
		
        
        
        List<Form_Submission__c>  fsList = createFormSubmission(testContactMethods,camp.Id);
        System.debug('**++**'+fsList);
        Test.startTest();
        insert fsList[0];
        //SFMC_EngagementActivityUtils objSFMC_EngagementActivityUtils = new SFMC_EngagementActivityUtils();
        
        Test.stopTest();
    }
    
    @isTest static void test_createEGAforFormSubmission_success_2() {
        List<Account> testAccts = [Select Id from Account];
        List<Contact> testContacts = [Select Id from Contact];
		List<Lead> testLeadList = new List<Lead>();
        Campaign camp = [Select Id from Campaign where Name='Test Campaign' LIMIT 1];
        
        List<ContactMethod__c> testContactMethods = new List<ContactMethod__c>();
         for(Integer i=0;i<5;i++) {
            for(Integer j=0;j<5;j++){
                testContactMethods.add(SFMC_TestDataFactory.createContactMethod(testContacts.get(i).Id,'Email','test'+i+'_'+j+'@gmail.com',true,false,'Business Email',false));
            }
        }
        insert testContactMethods;
        Set<Id> ContactMethodIdSet = new Set<Id>();

        for(ContactMethod__c cm:testContactMethods){
            ContactMethodIdSet.add(cm.Id);
        }
        System.debug('**++**'+ContactMethodIdSet);

        Engagement_Activity_Type__c enAcTy = new Engagement_Activity_Type__c(Channel__c=SFMC_Constants.ENGAGEMENT_ACTIVITY_TYPE_CHANNEL_FORM,
                                                                            Type__c=SFMC_Constants.ENGAGEMENT_ACTIVITY_TYPE_TYPE_LANDING_PAGE,
                                                                            Score__c=500,
                                                                            Weightage__c=50);
        insert enAcTy;
		
		for(Integer i=0;i<10;i++) {
           testLeadList.add(SFMC_TestDataFactory.CreateLead('Test Lead FN'+i, 'Test Lead LN'+i, 'New', null, testContacts.get(i).Id, 'Test', 'Email', false));
        }
        insert testLeadList;

        List<Form_Submission__c> fsList =  createFormSubmission(testContactMethods,camp.Id);
        
        Test.startTest();
        insert fsList;
        Test.stopTest();

        
        
        List<Engagement_Activity__c> ega = [Select Id,Engagement_Activity_Type__r.Channel__c,Engagement_Activity_Type__r.Type__c 
                                            from Engagement_Activity__c e 
                                            where Contact_Method__c in :ContactMethodIdSet];

        SFMC_EngagementActivityUtils.createEngagementActivitiesForLeads(ega[0],testLeadList);
        System.assertNotEquals(0,ega.size());

    }
    
    @isTest static void test_createEGAforFormSubmission_failure1() {

        List<Account> testAccts = [Select Id from Account];
        List<Contact> testContacts = [Select Id from Contact];
        Campaign camp = [Select Id from Campaign where Name='Test Campaign' LIMIT 1];
        
        List<ContactMethod__c> testContactMethods = new List<ContactMethod__c>();
         for(Integer i=0;i<5;i++) {
            for(Integer j=0;j<5;j++){
                testContactMethods.add(SFMC_TestDataFactory.createContactMethod(testContacts.get(i).Id,'Email','test'+i+'_'+j+'@gmail.com',true,false,'Business Email',false));
            }
        }
        insert testContactMethods;
        
        Set<Id> ContactMethodIdSet = new Set<Id>();

        for(ContactMethod__c cm:testContactMethods){
            ContactMethodIdSet.add(cm.Id);
        }

        List<Form_Submission__c> fsList =  createFormSubmission(testContactMethods,camp.Id);
        
        Test.startTest();
        insert fsList;
        Test.stopTest();

        
        System.debug('**++**'+ContactMethodIdSet);
        List<Engagement_Activity__c> ega = [Select Id,Engagement_Activity_Type__r.Channel__c,Engagement_Activity_Type__r.Type__c 
                                            from Engagement_Activity__c e 
                                            where Contact_Method__c in :ContactMethodIdSet];

        System.assertEquals(0,ega.size());

    

    }

    @isTest static void test_createEGAforFormSubmission_failure2() {

        List<Account> testAccts = [Select Id from Account];
        List<Contact> testContacts = [Select Id from Contact];
        Campaign camp = [Select Id from Campaign where Name='Test Campaign' LIMIT 1];
        
        List<ContactMethod__c> testContactMethods = new List<ContactMethod__c>();
         for(Integer i=0;i<10;i++) {
            for(Integer j=0;j<10;j++){
                testContactMethods.add(SFMC_TestDataFactory.createContactMethod(testContacts.get(i).Id,'Email','test'+i+'_'+j+'@gmail.com',true,false,'Business Email',false));
            }
        }
        insert testContactMethods;

        Set<Id> ContactMethodIdSet = new Set<Id>();

        for(ContactMethod__c cm:testContactMethods){
            ContactMethodIdSet.add(cm.Id);
        }
        Engagement_Activity_Type__c enAcTy = new Engagement_Activity_Type__c(Channel__c=SFMC_Constants.ENGAGEMENT_ACTIVITY_TYPE_CHANNEL_FORM,
                                                                    Type__c=SFMC_Constants.ENGAGEMENT_ACTIVITY_TYPE_TYPE_LANDING_PAGE,
                                                                    Score__c=500,
                                                                    Weightage__c=50);
        insert enAcTy;


        List<Form_Submission__c> fsList =  createErrorFormSubmission1(testContactMethods,null);
        
        Test.startTest();
        insert fsList;
        Test.stopTest();

        
        System.debug('**++**'+ContactMethodIdSet);
        List<Engagement_Activity__c> ega = [Select Id,Engagement_Activity_Type__r.Channel__c,Engagement_Activity_Type__r.Type__c 
                                            from Engagement_Activity__c e 
                                            where Contact_Method__c in :ContactMethodIdSet];

        System.assertEquals(0,ega.size());

    

    }

    @isTest static void test_createUberflipForm(){
        List<Account> testAccts = [Select Id from Account];
        List<Contact> testContacts = [Select Id from Contact];
        Campaign camp = [Select Id from Campaign where Name='Test Campaign' LIMIT 1];
        
        List<ContactMethod__c> testContactMethods = new List<ContactMethod__c>();
         for(Integer i=0;i<10;i++) {
            for(Integer j=0;j<10;j++){
                testContactMethods.add(SFMC_TestDataFactory.createContactMethod(testContacts.get(i).Id,'Email','test'+i+'_'+j+'@gmail.com',true,false,'Business Email',false));
            }
        }
        insert testContactMethods; 
        //We won't be tracking cookie information in SFDC as this wont serve any practical purpose
        Form_Submission__c objFormSubmission = new Form_Submission__c(First_Name__c = 'test', Last_Name__c = 'test', Email__c='test00@gmail.com'/*,UF_Cookie_ID__c = 'test333'*/,Source__c = 'Uberflip form',Form_Type__c = 'Uberflip form',Contact_Method_Id__c = testContactMethods[0].Id);
        insert objFormSubmission;


        //System.assert();

    }


    private static List<Form_Submission__c> createFormSubmission(List<ContactMethod__c> cmList,Id CampaignId){
        Integer counter=0;
        List<Form_Submission__c> retList = new List<Form_Submission__c>();
        for(ContactMethod__c cm:cmList){
            Form_Submission__c fs= new Form_Submission__c(
                                                            Email__c = 'test@email.com'+counter,
                                                            First_Name__c = 'First'+counter,
                                                            Last_Name__c = 'Last'+counter,
                                                            Phone__c = '123-4567-8901'+counter,
                                                            Campaign_Id__c = CampaignId,
                                                            Contact_Method_Id__c = cmList[counter].Id,
                                                            Form_Type__c = SFMC_Constants.ENGAGEMENT_ACTIVITY_TYPE_TYPE_LANDING_PAGE);
            retList.add(fs);
            counter++;
        }
        return retList;
    }

    private static List<Form_Submission__c> createErrorFormSubmission1(List<ContactMethod__c> cmList,Id CampaignId){
        Integer counter=0;
        List<Form_Submission__c> retList = new List<Form_Submission__c>();
        for(ContactMethod__c cm:cmList){
            Form_Submission__c fs= new Form_Submission__c(
                                                            Email__c = 'test@email.com'+counter,
                                                            First_Name__c = 'First'+counter,
                                                            Last_Name__c = 'Last'+counter,
                                                            Phone__c = '123-4567-8901'+counter,
                                                            Campaign_Id__c = CampaignId,
                                                            Form_Type__c = SFMC_Constants.ENGAGEMENT_ACTIVITY_TYPE_TYPE_LANDING_PAGE);
            retList.add(fs);
            counter++;
        }
        return retList;
    }

    private static List<Form_Submission__c> createErrorFormSubmission2(List<ContactMethod__c> cmList,Id CampaignId){
        Integer counter=0;
        List<Form_Submission__c> retList = new List<Form_Submission__c>();
        for(ContactMethod__c cm:cmList){
            Form_Submission__c fs= new Form_Submission__c(
                                                            Email__c = 'test@email.com'+counter,
                                                            First_Name__c = 'First'+counter,
                                                            Last_Name__c = 'Last'+counter,
                                                            Phone__c = '123-4567-8901'+counter,
                                                            Contact_Method_Id__c = cmList[counter].Id,
                                                            Campaign_Id__c = CampaignId
                                                            );
            retList.add(fs);
            counter++;
        }
        return retList;
    }
    
}