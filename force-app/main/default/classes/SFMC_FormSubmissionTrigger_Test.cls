@isTest (seeAllData = false)
public  class SFMC_FormSubmissionTrigger_Test {

    @testsetup
    static void testsetup(){
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        Business_Hours__c bh = new Business_Hours__c(name = 'OwnChange', Lowermin__c = 450, UpMin__c = 950);
        insert bh;
        Business_Hours__c bh1 = new Business_Hours__c(name = 'StatusChange', Lowermin__c = 450, UpMin__c = 950);
        insert bh1;
        
        
    }  
    
     @isTest
    static void testCMPresentAndNoOpenLead() {
        
        Account accountRecord = SFMC_TestDataFactory.createAccount('Test Account BI',null,true);
        

        Contact contactRecord = SFMC_TestDataFactory.createContact('Test Contact FN', 'Test Contact LN', accountRecord.Id, true, false);

        Campaign campaignRecord  = SFMC_TestDataFactory.CreateCampaign('Test Campaign 1', true, true);

        ContactMethod__c cmRecord = SFMC_TestDataFactory.createContactMethod(contactRecord.Id,'Email','Business Email','abc@abc.com', true, true);

        accountRecord.PrimaryEmail_CMId__c = cmRecord.Id;

        update accountRecord;

        Form_Submission__c formSubmissionRecord = new Form_Submission__c(Contact_Method_Id__c = cmRecord.Id, Campaign_Id__c = campaignRecord.Id, Account_Id__c = accountRecord.Id, First_Name__c = 'first Name', Last_Name__c = 'last Name', Email__c = 'abc@abc.com', Phone__c='115107090028', Form_Type__c = 'Uberflip form',source__C = 'Landing Page');

        insert formSubmissionRecord;

        formSubmissionRecord = [SELECT Lead__c, Campaign_Id__c, Account_Id__c, Contact_Method_Id__c FROM Form_Submission__c];

        //Assert if Lead Id is updated on Form Submission record
        System.assert(formSubmissionRecord.Lead__c != null);

        Lead createdLead = [SELECT Recent_Campaign_Id__c,Recent_Campaign__c, Account__c, Contact_Method__c FROM Lead];

        //Assert recent Campaign ID is same as Form Submission's Campaign
        System.assert(createdLead.Recent_Campaign_Id__c == formSubmissionRecord.Campaign_Id__c);
        
        //Assert recent Campaign name is populated in Recent Campaign field in Lead
        System.assert(createdLead.Recent_Campaign__c == campaignRecord.name);

        //Assert custom method's account is set on new lead and form submission object
        System.assert(createdLead.Account__c == formSubmissionRecord.Account_Id__c);

        //Assert custom method's CM is set on new lead and form submission object
        System.assert(createdLead.Contact_Method__c == formSubmissionRecord.Contact_Method_Id__c);



    }

    @isTest
    static void testCMPresentAndOpenLeadExists_1(){ // MLT = Nurture Lead Type and createddate < 30 , it should update existing lead

         
        Account accountRecord = SFMC_TestDataFactory.createAccount('Test Account BI',null,true);
        

        Contact contactRecord = SFMC_TestDataFactory.createContact('Test Contact FN', 'Test Contact LN', accountRecord.Id, true, false);

        Campaign campaignRecord1  = SFMC_TestDataFactory.CreateCampaign('Test Campaign 1', true, true);

        Campaign campaignRecord2  = SFMC_TestDataFactory.CreateCampaign('Test Campaign 2', true, true);

        ContactMethod__c cmRecord = SFMC_TestDataFactory.createContactMethod(contactRecord.Id,'Email','Business Email','abc@abc.com', true, true);

        ContactMethod__c cmRecord1 = SFMC_TestDataFactory.createContactMethod(contactRecord.Id,'Email','Business Email','abc@abc.com', true, true);

        accountRecord.PrimaryEmail_CMId__c = cmRecord.Id;

        update accountRecord;  

        Lead leadRecord = SFMC_TestDataFactory.createLead('firstName',  'lastName', 'In Progress',accountRecord.Id, contactRecord.Id, 'Company',SFMC_Constants.NURTURE_LEAD, false);


        leadRecord.Recent_Campaign__c = campaignRecord1.Id;  

        leadRecord.Link_Campaign__c = campaignRecord1.Id; 

        leadRecord.Contact_Method__c = cmRecord1.Id;

        insert leadRecord;

        String newLeadSource = 'NewLeadOrigin';
        
        Form_Submission__c formSubmissionRecord = new Form_Submission__c(Contact_Method_Id__c = cmRecord.Id, Campaign_Id__c = campaignRecord2.Id, Account_Id__c = accountRecord.Id, First_Name__c = 'first Name', Last_Name__c = 'last Name', Email__c = 'abc@abc.com', Phone__c='15107090028', Form_Type__c = 'Uberflip form',source__C = 'Landing Page', Lead_Origin__c = newLeadSource);

        insert formSubmissionRecord;

        formSubmissionRecord = [SELECT Lead__c, Campaign_Id__c, Lead_Origin__c FROM Form_Submission__c];

        System.debug('formSubmissionRecord ' + formSubmissionRecord);

        //Assert if Lead Id is updated on Form Submission record
        System.assert(formSubmissionRecord.Lead__c != null);

        System.assert(formSubmissionRecord.Lead__c == leadRecord.Id);       

        Lead updatedLead = [SELECT Recent_Campaign_Id__c, Contact_Method__c, Link_Campaign__c, Lead_Origin__c FROM Lead];

        System.debug('updatedLead ' + updatedLead);

        //Assert recent Campaign ID is same as Form Submission's Campaign
        System.assert(updatedLead.Recent_Campaign_Id__c == formSubmissionRecord.Campaign_Id__c);

        System.assert(updatedLead.Link_Campaign__C == campaignRecord2.Id);
        //assert CM Id has not changed on Lead
        System.assert(updatedLead.Contact_Method__c == cmRecord1.Id);   

        System.assert(updatedLead.Lead_Origin__c == newLeadSource);     

        


    }

    @isTest
    static void testCMresentAndOpenLeadExists_2(){ // MLT = Nurture Lead Type and createddate > 30 , it should reject existing lead and create new lead
        
        
        Account accountRecord = SFMC_TestDataFactory.createAccount('Test Account BI',null,true);
        
        
        Contact contactRecord = SFMC_TestDataFactory.createContact('Test Contact FN', 'Test Contact LN', accountRecord.Id, true, false);
        
        Campaign campaignRecord1  = SFMC_TestDataFactory.CreateCampaign('Test Campaign 1', true, true);
        
        Campaign campaignRecord2  = SFMC_TestDataFactory.CreateCampaign('Test Campaign 2', true, true);
        
        
        ContactMethod__c cmRecord = SFMC_TestDataFactory.createContactMethod(contactRecord.Id,'Email','Business Email','abc@abc.com', true, true);
        
        accountRecord.PrimaryEmail_CMId__c = cmRecord.Id;
        
        update accountRecord;
        
        
        Lead leadRecord = SFMC_TestDataFactory.createLead('firstName',  'lastName', 'In Progress',accountRecord.Id, contactRecord.Id, 'Company',SFMC_Constants.NURTURE_LEAD, false);
        
        
        leadRecord.Recent_Campaign__c = campaignRecord1.Id;  
        
        leadRecord.Link_Campaign__C = campaignRecord1.Id; 
        
        leadRecord.Callback_Date__c = '10/10/2016';
        leadRecord.Callback_Time__c = '6:00 AM';
        
        insert leadRecord;
        
        Datetime pastDate = Datetime.now().addDays(-32);
        Test.setCreatedDate(leadRecord.Id, pastDate);
        
        
        String newLeadSource = 'NewLeadOrigin';
        
        
        Form_Submission__c formSubmissionRecord = new Form_Submission__c(Contact_Method_Id__c = cmRecord.Id, Campaign_Id__c = campaignRecord2.Id, Account_Id__c = accountRecord.Id, First_Name__c = 'first Name', Last_Name__c = 'last Name', Email__c = 'abc@abc.com', Phone__c='5107090028', Form_Type__c = 'Uberflip form',source__C = 'Landing Page', Lead_Origin__c = newLeadSource);
        
        
        insert formSubmissionRecord;
        
        formSubmissionRecord = [SELECT Lead__c, Campaign_Id__c, Contact_Method_Id__c, Lead_Origin__c FROM Form_Submission__c];
        
        System.debug('formSubmissionRecord ' + formSubmissionRecord);
        
        //Assert if Lead Id is updated on Form Submission record
      /*  System.assert(formSubmissionRecord.Lead__c != null);
        
        //on Form Submission record, the lead Id should not be the existing lead Id 
        System.assert(formSubmissionRecord.Lead__c != leadRecord.Id);       
        
        Lead[] leadRecords = [SELECT Recent_Campaign_Id__c, status, Rejected_Reason__c, Link_Campaign__C, Lead_Origin__c FROM Lead order by Id desc];
        
        Lead newLead = leadRecords[0];
        
        Lead rejectedLead = leadRecords[1];
        
        System.assert(formSubmissionRecord.Lead__c == newLead.Id); 
        
        
        //Assert recent Campaign ID is same as Form Submission's Campaign
        System.assert(newLead.Recent_Campaign_Id__c == formSubmissionRecord.Campaign_Id__c);
        
        System.assert(newLead.Link_Campaign__C == campaignRecord2.Id);
        
        System.assert(newLead.Lead_Origin__c == newLeadSource);
        
        //existing lead is rejected
        
        System.debug('rejectedLead ' + rejectedLead );
        System.assert(rejectedLead.Status == SFMC_Constants.LEAD_REJECTED_STATUS && rejectedLead.Rejected_Reason__c == SFMC_Constants.LEAD_REJECTED_REASON_CLOSED_DUE_TO_NEW_SUBMISSION && rejectedLead.Lead_Origin__c == SFMC_Constants.NURTURE_LEAD); 
    */
    }

    @isTest
    static void testCMPresentAndNoOpenLeadException() { // not providing last name
        
        Account accountRecord = SFMC_TestDataFactory.createAccount('Test Account BI',null,true);
        

        Contact contactRecord = SFMC_TestDataFactory.createContact('Test Contact FN', 'Test Contact LN', accountRecord.Id, true, false);

        Campaign campaignRecord  = SFMC_TestDataFactory.CreateCampaign('Test Campaign 1', true, true);


        ContactMethod__c cmRecord = SFMC_TestDataFactory.createContactMethod(contactRecord.Id,'Email','Business Email','abc@abc.com', true, true);

        accountRecord.PrimaryEmail_CMId__c = cmRecord.Id;

        update accountRecord;

        Form_Submission__c formSubmissionRecord = new Form_Submission__c(Contact_Method_Id__c = cmRecord.Id, Campaign_Id__c = campaignRecord.Id, Account_Id__c = accountRecord.Id, First_Name__c = 'first Name',  Email__c = 'abc@abc.com', Form_Type__c = 'Uberflip form',source__C = 'Landing Page');

        insert formSubmissionRecord;

        formSubmissionRecord = [SELECT Lead__c, Campaign_Id__c, Error_Message__c FROM Form_Submission__c];

        //Assert if Lead Id is updated on Form Submission record
        System.assert(formSubmissionRecord.Lead__c == null);
        System.AssertNotEquals(formSubmissionRecord.Error_Message__c, null);
        
        Lead[] createdLead = [SELECT Recent_Campaign__c FROM Lead];

        System.assert(createdLead.isEmpty());        
        //Assert recent Campaign ID is same as Form Submission's Campaign
    }

    @isTest
    static void testCMPresentAndOpenLeadExists_3(){ // MLT !=  than Nurture Lead Type. it should update existing lead

         
        Account accountRecord = SFMC_TestDataFactory.createAccount('Test Account BI',null,true);
        

        Contact contactRecord = SFMC_TestDataFactory.createContact('Test Contact FN', 'Test Contact LN', accountRecord.Id, true, false);

        Campaign campaignRecord1  = SFMC_TestDataFactory.CreateCampaign('Test Campaign 1', true, true);

        Campaign campaignRecord2  = SFMC_TestDataFactory.CreateCampaign('Test Campaign 2', true, true);

        ContactMethod__c cmRecord = SFMC_TestDataFactory.createContactMethod(contactRecord.Id,'Email','Business Email','abc@abc.com', true, true);

        accountRecord.PrimaryEmail_CMId__c = cmRecord.Id;

        update accountRecord;

        Lead leadRecord = SFMC_TestDataFactory.createLead('firstName',  'lastName', 'In Progress',accountRecord.Id, contactRecord.Id, 'Company',false);


        leadRecord.Recent_Campaign__c = campaignRecord1.Id;  

        leadRecord.Callback_Date__c = '10/10/2016';
        leadRecord.Callback_Time__c = '6:00 AM';

        leadRecord.Lead_Origin__c = 'Other';

        insert leadRecord;

        Datetime pastDate = Datetime.now().addDays(-32);
        Test.setCreatedDate(leadRecord.Id, pastDate);

        

        String newLeadSource = 'NewLeadOrigin';

        Form_Submission__c formSubmissionRecord = new Form_Submission__c(Contact_Method_Id__c = cmRecord.Id, Campaign_Id__c = campaignRecord2.Id, Account_Id__c = accountRecord.Id, First_Name__c = 'first Name', Last_Name__c = 'last Name', Email__c = 'abc@abc.com', Form_Type__c = 'Uberflip form',source__C = 'Landing Page', Lead_Origin__c = newLeadSource);


        insert formSubmissionRecord;

        formSubmissionRecord = [SELECT Lead__c, Campaign_Id__c,Lead_Origin__c FROM Form_Submission__c];

        System.debug('formSubmissionRecord ' + formSubmissionRecord);

        //Assert if Lead Id is updated on Form Submission record
        System.assert(formSubmissionRecord.Lead__c != null);

        //on Form Submission record, the lead Id should  be the existing lead Id    
        System.assert(formSubmissionRecord.Lead__c == leadRecord.Id);       

        leadRecord = [SELECT Recent_Campaign_Id__c, status, Rejected_Reason__c, Lead_Origin__c FROM Lead order by Id desc];

        

        System.assert(formSubmissionRecord.Lead__c == leadRecord.Id); 

        //check lead status
        System.assert(leadRecord.Status == 'In Progress'); 
        //Assert recent Campaign ID is same as Form Submission's Campaign
        System.assert(leadRecord.Recent_Campaign_Id__c == formSubmissionRecord.Campaign_Id__c);

        System.assert(leadRecord.Lead_Origin__c == newLeadSource);

    }
   
    @isTest
    static void testCMPresentForEmailAndNoOpenLead() { // CM present with Form Submission's email
        
        Account accountRecord = SFMC_TestDataFactory.createAccount('Test Account BI',null,true);
        
        
        String emailAddress = 'myemail@email.com';
        Contact contactRecord = new Contact(FirstName = 'Test Contact FN', LastName = 'Test Contact LN', AccountId = accountRecord.Id, Active__c = true,email = emailAddress);

        insert contactRecord;       
        
               
        Campaign campaignRecord  = SFMC_TestDataFactory.CreateCampaign('Test Campaign 1', true, true);

        ContactMethod__c cmRecord = SFMC_TestDataFactory.createContactMethod( contactRecord.Id,'Email','Business Email',emailAddress,true, true);
        accountRecord.Email_Address__c = emailAddress; // Added as Account trigger reset primary CMID if not set.
        accountRecord.PrimaryEmail_CMId__c = cmRecord.Id;       
        update accountRecord;

        String newLeadSource = 'NewLeadOrigin';
        
        
        //CM is not associated to Form Submission record
        Form_Submission__c formSubmissionRecord = new Form_Submission__c(Campaign_Id__c = campaignRecord.Id, First_Name__c = 'first Name', Last_Name__c = 'last Name', Email__c = emailAddress, source__C = 'Landing Page', Form_Type__c = 'Uberflip form',Lead_Origin__c = newLeadSource);

        insert formSubmissionRecord;

        formSubmissionRecord = [SELECT Lead__c, Campaign_Id__c, Contact_Method_Id__c,Account_Id__c FROM Form_Submission__c];

        //Assert if Lead Id is updated on Form Submission record
        System.assert(formSubmissionRecord.Lead__c != null);
                     
        System.assert(formSubmissionRecord.Account_Id__c != null);

        System.assert(formSubmissionRecord.Contact_Method_Id__c != null);
        

        Lead createdLead = [SELECT Recent_Campaign_Id__c,Account__c,Contact__c, Contact_Method__c,Lead_Origin__c FROM Lead];

        //Assert recent Campaign ID is same as Form Submission's Campaign
        System.assert(createdLead.Recent_Campaign_Id__c == formSubmissionRecord.Campaign_Id__c);
        System.assert(createdLead.Account__c == accountRecord.id);

        System.assert(createdLead.Contact_Method__c == formSubmissionRecord.Contact_Method_Id__c);

        System.assert(createdLead.Lead_Origin__c == newLeadSource);

    }

    @isTest
    static void testCMPresentForEmailAndOpenLeadExist(){ // MLT !=  than Nurture Lead Type. it should update existing lead

         
        Account accountRecord = SFMC_TestDataFactory.createAccount('Test Account BI',null,true);
        
        String emailAddress = 'test@test.com';

        Contact contactRecord = SFMC_TestDataFactory.createContact('Test Contact FN', 'Test Contact LN', accountRecord.Id, true, false);

        Campaign campaignRecord1  = SFMC_TestDataFactory.CreateCampaign('Test Campaign 1', true, true);

        Campaign campaignRecord2  = SFMC_TestDataFactory.CreateCampaign('Test Campaign 2', true, true);

        ContactMethod__c cmRecord = SFMC_TestDataFactory.createContactMethod(contactRecord.Id,'Email','Business Email',emailAddress, true, true);
        
        accountRecord.Email_Address__c = emailAddress; // Added as Account trigger reset primary CMID if not set.
        accountRecord.PrimaryEmail_CMId__c = cmRecord.Id;

        update accountRecord;

        Lead leadRecord = SFMC_TestDataFactory.createLead('firstName',  'lastName', 'In Progress',accountRecord.Id, contactRecord.Id, 'Company',false);

        leadRecord.Lead_Origin__c = 'Other';

        leadRecord.Recent_Campaign__c = campaignRecord1.Id;  

        leadRecord.Callback_Date__c = '10/10/2016';
        leadRecord.Callback_Time__c = '6:00 AM';

        insert leadRecord;

        Datetime pastDate = Datetime.now().addDays(-32);
        Test.setCreatedDate(leadRecord.Id, pastDate);

        

        String newLeadSource = 'NewLeadOrigin';

        Form_Submission__c formSubmissionRecord = new Form_Submission__c( Campaign_Id__c = campaignRecord2.Id,  First_Name__c = 'first Name', Last_Name__c = 'last Name', Email__c = emailAddress, source__C = 'Landing Page', Form_Type__c = 'Uberflip form',Lead_Origin__c = newLeadSource);


        insert formSubmissionRecord;

        formSubmissionRecord = [SELECT Lead__c, Campaign_Id__c, Contact_Method_Id__c, Lead_Origin__c FROM Form_Submission__c];

        System.debug('formSubmissionRecord ' + formSubmissionRecord);

        //Assert if Lead Id is updated on Form Submission record
        System.assert(formSubmissionRecord.Lead__c != null);

        //on Form Submission record, the lead Id should  be the existing lead Id    
        System.assert(formSubmissionRecord.Lead__c == leadRecord.Id);       

        leadRecord = [SELECT Recent_Campaign_Id__c, status, Rejected_Reason__c,Contact_Method__c, Lead_Origin__c FROM Lead order by Id desc];

        

        System.assert(formSubmissionRecord.Lead__c == leadRecord.Id); 

        //check lead status
        System.assert(leadRecord.Status == 'In Progress'); 
        //Assert recent Campaign ID is same as Form Submission's Campaign
        System.assert(leadRecord.Recent_Campaign_Id__c == formSubmissionRecord.Campaign_Id__c);

        //cm should be updated on lead
        System.assertEquals(leadRecord.Contact_Method__c, formSubmissionRecord.Contact_Method_Id__c); 

        //update lead origin on Lead
        System.assert(leadRecord.Lead_Origin__c == newLeadSource);      

    }
/*
    @isTest
    static void testNoCMForEmail(){ //Lead should be created, Form submsission should not have CM Id, Acc Id

         
        Account accountRecord = SFMC_TestDataFactory.createAccount('Test Account BI',null,true);
        
        String emailAddress = 'test@test.com';


        Campaign campaignRecord1  = SFMC_TestDataFactory.CreateCampaign('Test Campaign 1', true, true);

        Campaign campaignRecord2  = SFMC_TestDataFactory.CreateCampaign('Test Campaign 2', true, true);



        

        String newLeadSource = 'NewLeadOrigin';

        Form_Submission__c formSubmissionRecord = new Form_Submission__c( Campaign_Id__c = campaignRecord2.Id,  First_Name__c = 'first Name', Last_Name__c = 'last Name', Email__c = emailAddress, source__C = 'Landing Page', Form_Type__c = 'Uberflip form',Lead_Origin__c = newLeadSource);


        insert formSubmissionRecord;

        formSubmissionRecord = [SELECT Lead__c, Campaign_Id__c, Contact_Method_Id__c, Account_Id__c FROM Form_Submission__c];

        System.debug('formSubmissionRecord ' + formSubmissionRecord);

        //Assert if Lead Id is updated on Form Submission record
        System.assert(formSubmissionRecord.Lead__c != null);


        Lead leadRecord = [SELECT Recent_Campaign_Id__c, status, Rejected_Reason__c, Contact_Method__c, Lead_Origin__c FROM Lead order by Id desc];

        

        System.assert(formSubmissionRecord.Lead__c == leadRecord.Id); 

        //Assert recent Campaign ID is same as Form Submission's Campaign
        System.assert(leadRecord.Recent_Campaign_Id__c == formSubmissionRecord.Campaign_Id__c);

        //cm should not updated on lead
        System.assert(leadRecord.Contact_Method__c == null);

        System.assert(formSubmissionRecord.Contact_Method_Id__c == null);

        System.assert(formSubmissionRecord.Account_Id__c == null);  

        System.assert(leadRecord.Lead_Origin__c == newLeadSource);              




    }           
   */ 
    @isTest
    static void testFormSubmissionCodeException() { //test exception try catch block
        
        Account accountRecord = SFMC_TestDataFactory.createAccount('Test Account BI',null,true);
        

        Contact contactRecord = SFMC_TestDataFactory.createContact('Test Contact FN', 'Test Contact LN', accountRecord.Id, true, false);

        Campaign campaignRecord  = SFMC_TestDataFactory.CreateCampaign('Test Campaign 1', true, true);


        ContactMethod__c cmRecord = SFMC_TestDataFactory.createContactMethod(contactRecord.Id,'Email','Business Email','abc@abc.com', true, true);

        accountRecord.PrimaryEmail_CMId__c = cmRecord.Id;

        update accountRecord;

        Form_Submission__c formSubmissionRecord = new Form_Submission__c(Contact_Method_Id__c = cmRecord.Id, Campaign_Id__c = campaignRecord.Id, Account_Id__c = accountRecord.Id, First_Name__c = 'first Name', Last_Name__c = 'last Name',  Email__c = 'abc@abc.com', Form_Type__c = 'Uberflip form',source__C = 'Landing Page');

        insert formSubmissionRecord;

        formSubmissionRecord = [SELECT id, Error_Message__c FROM Form_Submission__c];

        String errorMessage = 'Error Message' ;
                
        System.AssertEquals(formSubmissionRecord.Error_Message__c, null);
        
        Test.startTest();
        
        Map<id,Form_Submission__c> formSubmissionMap = new Map<id,Form_Submission__c>();
        formSubmissionMap.put(formSubmissionRecord.id,formSubmissionRecord);
        
        SFMC_FormSubmissionHelper.recordExceptionError(formSubmissionMap,errorMessage);
        
        Form_Submission__c updatedFormSubmissionRecord = [SELECT id, Error_Message__c FROM Form_Submission__c where id = : formSubmissionRecord.id];

        System.AssertEquals(updatedFormSubmissionRecord.Error_Message__c,errorMessage);
        
        Test.stopTest();

    }    
    
    @isTest
    static void testLeadCreationForReferralFormSubmission(){
        List<Form_Submission__c> sflist = new List<Form_Submission__c>();
        sflist.add(new Form_Submission__c(
            First_Name__c =  'from anonymous',
            Last_Name__c = 'lastname',
            friend_email_4__c = 'shashi@comitydesigns.com',
            Friend_Last_Name_4__c = 'Lastname 11',
            Friend_Last_Name_2__c = 'Lastname 21',
            Friend_Phone_2__c = '9854578452',
            Form_type__c = 'Referral form'));
        sflist.add(new Form_Submission__c(
            First_Name__c =  'from anonymous 2',
            Last_Name__c = 'last',
            friend_email_1__c = 'bhupendra3@comitydesigns.com',
            Friend_Last_Name_1__c = 'Lastname 21',
            Friend_Last_Name_3__c = 'Lastname 22',
            Friend_Phone_3__c = '9854578452',
            Form_Type__c = 'Referral form'
        ));
        sflist.add(new Form_Submission__c(
            First_Name__c =  'from anonymous 3',
            Last_Name__c = 'last',
            friend_email_5__c = 'varun@comitydesigns.com',
            Friend_Last_Name_5__c = 'Lastname 31',            
            Form_Type__c = 'Referral form'
        ));
        insert sflist;
        Map<id, Form_Submission__c> leadIdToFormSubmissionMap = new Map<id, Form_Submission__c>();
        
        List<Form_Submission__c> formSubmissionList = [select friend_lead_id_4__c, friend_lead_id_3__c
                                                       from Form_Submission__c
                                                       where First_Name__c =: 'from anonymous' or First_Name__c =: 'from anonymous 2'];

        for(Form_Submission__c rec : formSubmissionList){
            system.debug('rec : ' + rec);
            if(String.isNotBlank(rec.friend_lead_id_4__c)){
                leadIdToFormSubmissionMap.put(rec.friend_lead_id_4__c, rec);
            }
            if(String.isNotBlank(rec.friend_lead_id_3__c)){
                leadIdToFormSubmissionMap.put(rec.friend_lead_id_3__c, rec);
            }
        }
        
        List<Lead> leadsCreated = [select id, lastname from Lead where lastname =: 'Lastname 11' and lastname =: 'Lastname 22'];
        for(Lead leadRec : leadsCreated){
            if(leadRec.lastname.equals('Lastname 11')){
                system.assertEquals(leadIdToFormSubmissionMap.get(leadRec.id).friend_lead_id_4__c, leadRec.id);  
            }
            if(leadRec.lastname.equals('Lastname 22')){
                system.assertEquals(leadIdToFormSubmissionMap.get(leadRec.id).friend_lead_id_3__c, leadRec.id);  
            }
        }
    }
    
    @isTest
    static void testLeadUpdationAndCreationForReferralFormSubmission(){
        Account accountRecord = SFMC_TestDataFactory.createAccount('Test Account BI',null,true);
        Account accountRecord2 = SFMC_TestDataFactory.createAccount('Test Account BI 1',null,true);
        Account accountRecord3 = SFMC_TestDataFactory.createAccount('Test Account BI 3',null,true);
        
        String emailAddress = 'test@test.com';
        String emailAddress2 = 'test2@test.com';
        String emailAddress3 = 'test3@test.com';
        
        Contact contactRecord = SFMC_TestDataFactory.createContact('Test Contact FN', 'Test Contact LN', accountRecord.Id, true, true);
        contactRecord.email = emailAddress;
        update contactRecord;
        Contact contactRecord2 = SFMC_TestDataFactory.createContact('Test Contact FN', 'Test Contact LN', accountRecord2.Id, true, true);
        Contact contactRecord3 = SFMC_TestDataFactory.createContact('Test Contact FN', 'Test Contact LN', accountRecord3.Id, true, true);
        
        Campaign campaignRecord1  = SFMC_TestDataFactory.CreateCampaign('Test Campaign 1', true, true);
        Campaign campaignRecord2  = SFMC_TestDataFactory.CreateCampaign('Test Campaign 2', true, true);
        Campaign campaignRecord3  = SFMC_TestDataFactory.CreateCampaign('Test Campaign 3', true, true);
        
        ContactMethod__c cmRecord = SFMC_TestDataFactory.createContactMethod(contactRecord.Id,'Email','Business Email',emailAddress, true, true);
        cmRecord.Primary_To_Contact__c = true;
        update cmRecord;
        ContactMethod__c cmRecord2 = SFMC_TestDataFactory.createContactMethod(contactRecord2.Id,'Email','Business Email',emailAddress2, true, true);
        ContactMethod__c cmRecord3 = SFMC_TestDataFactory.createContactMethod(contactRecord3.Id,'Email','Business Email',emailAddress3, true, true);
        
        List<Account> accountListToBeUpdated = new List<Account>();
        
        accountRecord.Email_Address__c = emailAddress; // Added as Account trigger reset primary CMID if not set.
        accountRecord.PrimaryEmail_CMId__c = cmRecord.Id;
        accountRecord.Account_Sub_Type__c = 'Prospect';
        accountListToBeUpdated.add(accountRecord);
        
        accountRecord2.Email_Address__c = emailAddress2; // Added as Account trigger reset primary CMID if not set.
        accountRecord2.PrimaryEmail_CMId__c = cmRecord2.Id;
        accountRecord2.Account_Sub_Type__c = 'Prospect';
        accountListToBeUpdated.add(accountRecord2);
        
        accountRecord3.Email_Address__c = emailAddress3; // Added as Account trigger reset primary CMID if not set.
        accountRecord3.PrimaryEmail_CMId__c = cmRecord3.Id;
        accountRecord3.Account_Sub_Type__c = 'Prospect';
        accountListToBeUpdated.add(accountRecord3);
        update accountListToBeUpdated;
        
        Lead leadRecord = SFMC_TestDataFactory.createLead('firstName',  'lastName', 'In Progress',accountRecord.Id, contactRecord.Id, 'Company',false);
        leadRecord.Lead_Origin__c = 'Other';
        leadRecord.Recent_Campaign__c = campaignRecord1.Id;  
        leadRecord.Callback_Date__c = '10/10/2016';
        leadRecord.Callback_Time__c = '6:00 AM';
        insert leadRecord;
        
        Datetime pastDate = Datetime.now().addDays(-32);
        Test.setCreatedDate(leadRecord.Id, pastDate);
        String newLeadSource = 'NewLeadOrigin';
        Form_Submission__c formSubmissionRecord1 = new Form_Submission__c( Campaign_Id__c = campaignRecord2.Id,  First_Name__c = 'first Name', Last_Name__c = 'last Name', Email__c = emailAddress, source__C = 'Referral form', Form_Type__c = 'Referral form',Lead_Origin__c = newLeadSource,
                                                                         Friend_Email_1__c=emailAddress, Friend_Last_Name_1__c = 'Laster',
                                                                         Friend_Email_2__c=emailAddress2, Friend_Last_Name_2__c = 'Laster 2',
                                                                         Friend_Email_3__c=emailAddress3, Friend_Last_Name_3__c = 'Laster 3');
        
        Form_Submission__c formSubmissionRecord2 = new Form_Submission__c(
            First_Name__c =  'First Name 2',
            Last_Name__c = 'last 2',
            friend_email_5__c = 'bhup@comitydesigns.com',
            Friend_Last_Name_5__c = 'Lastname 25',
            Form_Type__c = 'Referral form'
        );
        
        Test.startTest();
        List<Form_Submission__c> fsList = new List<Form_Submission__c>{formSubmissionRecord1,formSubmissionRecord2};
        //1st Record: Has 2 referrals
            //  Referral 1: Data such that(Friend_Email_1__c) accountId is returned from ACM method and has a open lead. This open  lead is updated.
            //  Referral 2: Data such that(Friend_Email_2__c) accountId is returned from ACM, but does not have open lead. This lead will be created.
            //  Referral 3: Same as referral 2. Added to increase code coverage.
        //2nd Record: Has 1 referral
            //  All data is new, new orphan lead is created.
        insert fsList;
        Test.stopTest();
        formSubmissionRecord1 = [SELECT Friend_Lead_Id_1__c, Friend_Lead_Id_2__c, Campaign_Id__c FROM Form_Submission__c where Last_Name__c =: 'last name' limit 1];
        formSubmissionRecord2 = [SELECT Friend_Lead_Id_5__c FROM Form_Submission__c where Last_Name__c =: 'last 2' limit 1];
        Lead leadRecCreated = [select id, referral__c, Link_Campaign__c from Lead where lastname =: 'Laster 2' limit 1];
        Lead orphanLeadRecCreated = [select id, referral__c, Link_Campaign__c from Lead where lastname =: 'Lastname 25' limit 1];
        system.assertEquals(formSubmissionRecord1.Friend_Lead_Id_1__c, leadRecord.Id);
        system.assertEquals(formSubmissionRecord1.Friend_Lead_Id_2__c,  leadRecCreated.Id);
        system.assertEquals(formSubmissionRecord2.Friend_Lead_Id_5__c,  orphanLeadRecCreated.Id);
        system.assertEquals(leadRecCreated.referral__c,true);
        system.assertEquals(leadRecCreated.Link_Campaign__c,formSubmissionRecord1.Campaign_Id__c);        
    }
    
    @isTest
    static void testFormSubmissionByLinkedInLeads(){
        Id RecordTypeIdLead = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(SFMC_Constants.LEAD_SOCIAL_MEDIA_RECORD_TYPE).getRecordTypeId();
        system.debug('RecordTypeIdLead : ' + RecordTypeIdLead);
        Account acc = SFMC_TestDataFactory.createAccount('test test', Userinfo.getUserId(), true);
        Contact con = SFMC_TestDataFactory.createContact('con name', 'con lname', acc.id, true, true);
        ContactMethod__c cm = SFMC_TestDataFactory.createContactMethod(con.Id,'Email','Business Email','abc@abc.com', true, true);
        Campaign camp = SFMC_TestDataFactory.CreateCampaign('Test one', true, true);
        camp.Target_Product__c = 'TOPCRM';
        update camp;
        LinkedIn_Campaign_Mappping__c setting = new LinkedIn_Campaign_Mappping__c(name='138211016', SF_Campaign_Id__c=camp.id);
        insert setting;
        Lead socialMediaLead = new Lead(firstname='fname', lastname='lastname',recordTypeId = RecordTypeIdLead, LeadSource='LinkedIn', email='abc@abc.com', company='LinkedIn', Status='New', Recent_Campaign__c='urn:li:sponsoredCampaign:138211016');
        insert socialMediaLead;
        
        //Assertion Logic.
        Form_Submission__c fs = [select first_name__c,campaign_id__c,Lead__c from Form_Submission__c where first_name__c =: 'fname' limit 1];
        Lead newAssociatedLead = [select firstname, id from Lead where firstname = 'fname' and Recent_Campaign_Id__c =: camp.id limit 1];
        
        //Verify lead association.
        system.assertEquals(fs.Lead__c, newAssociatedLead.id);
        //Verify campaign association.
        system.assertEquals(fs.Campaign_Id__c, camp.id);
        //Verify social media lead deletion.
        system.assert([select id from Lead where Recent_Campaign__c =: 'urn:li:sponsoredCampaign:138211016'].size() == 0);
        //Verify field population.
        system.assertEquals(newAssociatedLead.firstname, 'fname');        
    }
    
    @isTest
    static void testFormSubmissionByLinkedInLeadsNegative(){
        //Verify trigger disable flag for Social Leads trigger functionality//
        DisabledTrigger__c Dtrg = DisabledTrigger__c.getValues('Disabled');
        Dtrg.SocialMediaLeadTrigger__c = userinfo.getUserName();
        update Dtrg;
        
        //Testing normal lead creation scenario//
        Id RecordTypeIdLead = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('RDC').getRecordTypeId();
        Account acc = SFMC_TestDataFactory.createAccount('test test', Userinfo.getUserId(), true);
        Contact con = SFMC_TestDataFactory.createContact('con name', 'con lname', acc.id, true, true);
        ContactMethod__c cm = SFMC_TestDataFactory.createContactMethod(con.Id,'Email','Business Email','abc@abc.com', true, true);
        Campaign camp = SFMC_TestDataFactory.CreateCampaign('Test one', true, true);
        camp.Target_Product__c = 'TOPCRM';
        update camp;
        
        //This is a normal lead, i.e a lead that is not of record type Social Media.
        Lead normalLead = new Lead(firstname='fname',recordTypeId=RecordTypeIdLead, lastname='lastname', LeadSource='LinkedIn', email='abc@abc.com', company='LinkedIn', Status='New');
        insert normalLead;
        
        //Verify that general lead is not deleted.
        system.assert([select id from Lead where firstname =: 'fname'].size() == 1);
        
        //Verify that no Form submission is created and associated with this lead.
        system.assert([select first_name__c,campaign_id__c,Lead__c from Form_Submission__c where Lead__c =: normalLead.Id].size() == 0);
        
        //Verify that social media lead trigger is not called and no FS record is created.
        Id RecordTypeIdLeadSocial = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(SFMC_Constants.LEAD_SOCIAL_MEDIA_RECORD_TYPE).getRecordTypeId();
        Lead socialLead1 = new Lead(firstname='fname1',recordTypeId=RecordTypeIdLeadSocial, lastname='lastname1', LeadSource='LinkedIn', email='abc@abc.com', company='LinkedIn', Status='New');
        insert socialLead1;
        system.assert([select first_name__c,campaign_id__c,Lead__c from Form_Submission__c where first_name__c =: 'fname1'].size() == 0);
        
        //Enabling trigger//
        Dtrg.SocialMediaLeadTrigger__c = '';
        update Dtrg;
        LinkedIn_Campaign_Mappping__c setting = new LinkedIn_Campaign_Mappping__c(name='138211016', SF_Campaign_Id__c='***');
        insert setting;
        Lead socialLead2= new Lead(firstname='fname2',recordTypeId=RecordTypeIdLeadSocial, lastname='lastname2', LeadSource='LinkedIn', email='abc@abc.com', company='LinkedIn', Status='New', Recent_Campaign__c= 'urn:li:sponsoredCampaign:138211016');
        insert socialLead2;
        system.debug('Error : ' + [select Error_Description__c from Error__c where Interface_Name__c =: 'SFMC_LeadTriggerHandler'][0].Error_Description__c);
    }
}