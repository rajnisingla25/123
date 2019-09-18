/*
Purpose:        To test the SFMC_EngagementActivityController class 
Created by:     Sarang D
Created date:   17/1/2018
*/
@isTest
public class SFMC_EngagementActivityControllerTest {
    
    /*
        Purpose:        To create test data that could be used in test methods. 
        Created by:     Sarang D
        Created date:   17/1/2018
    */
    @testSetup
    static void setupData(){
        Profile profile = [select id from Profile limit 1];
        User user = SFMC_TestDataFactory.createUser(null, profile.id, null, 'testabc@xyz.com', 'testtester@typ.com', true);
        Account acc = SFMC_TestDataFactory.createAccount('Test Acc1', user.id, true);
        Account acc2 = SFMC_TestDataFactory.createAccount('Test Acc2', user.id, true);
        Account acc3 = SFMC_TestDataFactory.createAccount('Test Acc3', user.id, true);
        DisabledTrigger__c dtrig = new DisabledTrigger__c(name = 'Disabled');
        insert dtrig;
        Contact con = SFMC_TestDataFactory.createContact('Test FirstName', 'Test LastName', acc.id, false, true);
        Contact con2 = SFMC_TestDataFactory.createContact('Test FirstName2', 'Test LastName2', acc.id, false, true);
        Contact con3 = SFMC_TestDataFactory.createContact('Test FirstName3', 'Test LastName3', acc.id, false, true);
        
        //Set 1
        Engagement_Activity_Type__c eType1 = SFMC_TestDataFactory.createEngagementActivtyType('', null, null, true);
        eType1.Channel__c = SFMC_Constants.ENGAGEMENT_ACTIVITY_TYPE_CHANNEL_FORM_SUBMISSION;
        update eType1;
        //ContactMethod__c cm = SFMC_TestDataFactory.createContactMethod(con.id,SFMC_Constants.TYPE_EMAIL, null, 'testered@xyz.com', true, true);
        ContactMethod__c cm = SFMC_TestDataFactory.createContactMethod(con.id,SFMC_Constants.TYPE_EMAIL,'testered@xyz.com',true,true,'Business Email',true);
        Engagement_Activity__c eActivity = SFMC_TestDataFactory.createEngagementActivty(con.id, null, eType1.id, true);
        eActivity.Contact_Method__c = cm.id;
        eActivity.Contact__c = con.id;

        //set value for product type 
        DescribeFieldResult describe = Engagement_Activity__c.Product__c.getDescribe();
        List<PicklistEntry> availableValues = describe.getPicklistValues();
        eActivity.Product__c = availableValues[0].getValue();
        eActivity.Email__c = 'test@xyz.com';
        eActivity.Phone__c = '9852124521';
        eActivity.Name__c = 'Title 1';
        eActivity.Journey_Name__c = 'Test Journey';
        eActivity.Form_Submission_URL__c = 'www.google.com';
        eActivity.Activity_Date__c = Date.today();
        update eActivity;
        
        //Set 2
        Engagement_Activity_Type__c eType2 = SFMC_TestDataFactory.createEngagementActivtyType('', null, null, true);
        eType2.Channel__c = SFMC_Constants.ENGAGEMENT_ACTIVITY_TYPE_WEBCONTENT;
        update eType2;
        Engagement_Activity__c eActivity2 = SFMC_TestDataFactory.createEngagementActivty(con.id, null, eType2.id, true);
        eActivity2.Contact_Method__c = cm.id;
        eActivity2.Name__c = 'Title 2';
        update eActivity2;
        
        //Set 3
        Engagement_Activity_Type__c eType3 = SFMC_TestDataFactory.createEngagementActivtyType('', null, null, true);
        eType3.Channel__c = SFMC_Constants.ENGAGEMENT_ACTIVITY_TYPE_SMS;
        update eType3;
        ContactMethod__c cm2 = SFMC_TestDataFactory.createContactMethod(con.id, SFMC_Constants.TYPE_PHONE, null, 'testered@xyz.com', true, true);
        Engagement_Activity__c eActivity3 = SFMC_TestDataFactory.createEngagementActivty(con.id, null, eType3.id, true);
        //set value for product type
        eActivity.Product__c = availableValues[0].getValue();
        //eActivity3.Product__c = 'Top Producer, RDC';
        eActivity3.Source__c = 'Journey';
        eActivity3.Name__c = 'Title 3';
        update eActivity3;
        
        //Sets for pagination testing
        List<Engagement_Activity__c> actList = new List<Engagement_Activity__c>();
        Integer counter;
        for(Integer i=0;i<100;i++){
            Engagement_Activity__c theEAREcord = new Engagement_Activity__c();
            theEAREcord = SFMC_TestDataFactory.createEngagementActivty(con3.id, null, null, true);
            counter = i + 1;
            theEAREcord.Name__c = 'EA - ' + counter ;
            actList.add(theEAREcord);
        }
        update actList;
        system.debug('actList : ' + actList);
    }
    
    /*
        Purpose:        To test if wrapper JSON is constructed correctly on load of VF page.
        Created by:     Sarang D
        Created date:   17/1/2018
    */    
    @isTest
    static void testInitialisation(){
        Contact con = [select id from Contact where firstname =: 'Test FirstName' limit 1];
        ApexPages.StandardController controller= new ApexPages.StandardController(con);
        SFMC_EngagementActivityController extension = new SFMC_EngagementActivityController(controller);
        extension.getEngagementActivityList();
        
        system.debug('extension.wrapperList : ' + extension.wrapperList);
        List<SFMC_EngagementActivityController.EngagementActivityWrapper> wrapperList = (List<SFMC_EngagementActivityController.EngagementActivityWrapper>)JSON.deserializeStrict(extension.wrapperList, List<SFMC_EngagementActivityController.EngagementActivityWrapper>.class);
        system.debug('wrapperList : ' + wrapperList);
        Engagement_Activity__c eActivity = [select id from Engagement_Activity__c where Name__c=: 'Title 1'];
        
        for(SFMC_EngagementActivityController.EngagementActivityWrapper wrapper : wrapperList){
            for(SFMC_EngagementActivityController.EngagementAttributeWrapper attWrapper: wrapper.attributeWrapper){
                system.assert(new Set<String>{'Title 1','Title 2','Title 3'}.contains(wrapper.activityDescriptionTitle));
                //For Engagement Activity of Title : 'Title 1'
                if(wrapper.activityDescriptionTitle.equals('Title 1')){ 
                    system.assertEquals(wrapper.activityURL, URL.getOrgDomainUrl().toExternalForm() + '/' + eActivity.id);  //Validate if activity URL generated is correct.
                    system.assert(new Set<String>{Label.SFMC_Contact_Name_Field_Label,Label.SFMC_Email_Field_Label,Label.SFMC_Product_Field_Label,Label.SFMC_Phone_Field_Label,Label.SFMC_Journey_Name_Label, Label.SFMC_Source_Field_Label, Label.SFMC_Form_Submission_URL}.contains(attWrapper.columnLabel));
                    if(attWrapper.columnLabel.equals(Label.SFMC_Contact_Name_Field_Label)){     //For 'Name' column
                        system.assertEquals('Test FirstName Test LastName', attWrapper.value);  //Validate contact name
                    }
                    if(attWrapper.columnLabel.equals(Label.SFMC_Email_Field_Label)){            //For 'Email' column
                        system.assertEquals('test@xyz.com', attWrapper.value);              //Validate resp. email__c field value is populated.
                    }
                }  
            }
        }
    }
    
    
    /*
        Purpose:        To test if wrapper JSON is constructed correctly when filter is applied.
        Created by:     Sarang D
        Created date:   17/1/2018
    */ 
    @isTest
    static void testFilter(){
        Contact con = [select id from Contact where firstname =: 'Test FirstName' limit 1];
        String serialisedList = SFMC_EngagementActivityController.getOffsetRecords(2,con.id, SFMC_Constants.ENGAGEMENT_ACTIVITY_TYPE_WEBCONTENT, true,'Test');
        system.debug('serialisedList : ' + serialisedList);
        List<SFMC_EngagementActivityController.EngagementActivityWrapper> wrapperList = (List<SFMC_EngagementActivityController.EngagementActivityWrapper>)JSON.deserializeStrict(serialisedList, List<SFMC_EngagementActivityController.EngagementActivityWrapper>.class);
        system.debug('wrapperList : ' + wrapperList);

        for(SFMC_EngagementActivityController.EngagementActivityWrapper wrapper : wrapperList){
            system.assertEquals(wrapper.attributeWrapper.size(), 0);        //Asserting that no fields are present.
            system.assertEquals(wrapper.activityDescriptionTitle, 'Title 2');
            //Asserting that other 2 records are not populated in wrapper.
            system.assertNotEquals(wrapper.activityDescriptionTitle, 'Title 3');
            system.assertNotEquals(wrapper.activityDescriptionTitle, 'Title 1');
        }
    }
    
    //Simulation of lightning component calling this utility method to shoe the picklist values.
    @isTest
    static void testGetPicklistValues(){
      List<SFMC_Utility.PicklistValuesWrapper> lists =  (List<SFMC_Utility.PicklistValuesWrapper>)JSON.deserialize(SFMC_EngagementActivityController.getPicklistValues(), List<SFMC_Utility.PicklistValuesWrapper>.class); 
    }
    
}