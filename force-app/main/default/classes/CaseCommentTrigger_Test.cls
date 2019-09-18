//
// (c) 2015 Appirio, Inc.
//
// Apex Test Class Name: CaseCommentTrigger_Test
// For Testing: CaseCommentTrigger.trigger And CaseCommentTriggerHandler.cls
//
// 16th March 2015    Ravindra Shekhawat    Original (Task # T-370339)
// 13th April 2015    Kirti Agarwal   Original (Task # T-377169)
//
@isTest
private class CaseCommentTrigger_Test {
    
    
    static testMethod void testCaseCommentTrigger(){

        Group collectionGroup = TestDataFactory.createPublicGroup('CC Collections Team',true);
        TestDataFactory.createPublicGroupMember(UserInfo.getUserId(),collectionGroup.Id,true);
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtId = CaseRecordTypeInfo.get('Retention').getRecordTypeId();

        System.runAs(new User(Id = UserInfo.getUserId())){ 
            
            CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
            insert setting;
            //Inserting Customsetting for Account     
          DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
              insert Dtrg;
            Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
            testAccount.Primary_Email__c = 'testAccount@move.com';
            testAccount.ShippingState  = 'CA';
            testAccount.ShippingCountry  = 'USA';
            insert testAccount;
            Contact testContact = TestDataFactory.createContact('Test Contact','TestL',testAccount.Id,true,false);
            testContact.Email = 'rshekhawat@move.com';
            insert testContact;
            //Switch_CaseTrigger__c testcasesetting = new Switch_CaseTrigger__c(Set_Overall_Trigger_Off__c  = true);
            //insert testcasesetting; 
            
            Case testCase = TestDataFactory.createCase('Invalid Rights','New','Collections' ,'Test Description', testContact.Id,testAccount.Id,true);
            // Insert the custom Setting for CaseCommentTrigger
            Switch_CaseCommentTrigger__c testSetting = new Switch_CaseCommentTrigger__c(Set_Case_Comment_Counting_Off__c=false,Set_Overall_Trigger_Off__c=false,Set_Performance_Function_Off__c=false);
            insert testSetting;
            Test.startTest();
            // Insert a Comment on Case
            CaseComment testComment1 = TestDataFactory.createCaseComment('Test Comment', testCase.Id, true,false);
            //CaseComment testComment2 = TestDataFactory.createCaseComment('Test Comment1', testCase.Id, true,false);
            List<CaseComment> caseCommentList = new List<CaseComment>();
            caseCommentList.add(testComment1);
            //caseCommentList.add(testComment2);
            //Test.startTest();
           // insert caseCommentList;
            CaseComment comment = TestDataFactory.createCaseComment('Test Comment2', testCase.Id, true,false);
           // insert comment;
            
           
            // Delete The comment from Case
            system.debug('caseCommentList:'+caseCommentList);
            try{ 
            //delete caseCommentList;
            }catch(exception e){}
            // Check the update Case Comment Count
           
            //System.assert(casePerformances.size()==1);
            // Update custom setting for CaseComment Trigger to switch off the Case Comment Counting
            testSetting.Set_Case_Comment_Counting_Off__c = true;
            testSetting.Set_Performance_Function_Off__c=true;
            //update testSetting;
            
           // delete comment;
            // Comment is deleted, but as per custom setting, case comment couting should not have been done, so check if Count is Still 1
            
            
            // Set the custom setting to turn overall trigger off, in this case also case comment count should not change
            testSetting.Set_Case_Comment_Counting_Off__c = false;
            testSetting.Set_Overall_Trigger_Off__c = true;
            comment = TestDataFactory.createCaseComment('Test Comment3', testCase.Id, true,false);
            //insert comment;
            
            Test.stopTest();
            
        }
    }
    
    //  @method name  : testUpdatedLastWorkFieldUpdation
    //  @purpose : Used to test functionality
    //  @return nothing
    //  @task : T-377169
    //  @created By : Kirti Agarwal
    static testmethod void testUpdatedLastWorkFieldUpdation() {
        
        //Inserting Customsetting for Account     
      DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
              insert Dtrg;
        Account testAccount = TestDataFactory.createAccount('Test Account', null, false);
        testAccount.Primary_Email__c = 'testAcc@move.com';
        testAccount.ShippingState  = 'CA';
        testAccount.ShippingCountry  = 'USA';
        insert testAccount;
        Contact testContact = TestDataFactory.createContact('Test Contact', 'TestL', testAccount.Id, true, false);
        testContact.Email = 'testCon@move.com';        
        insert testContact;
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtId = CaseRecordTypeInfo.get('Retention').getRecordTypeId();
        
        CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
        insert setting;
        
       
        
        Case testCase1 = TestDataFactory.createCase('Invalid Rights', 'New', 'Collections'
                                                    , 'Test Description', testContact.Id, testAccount.Id, true);
        //Case testCase2 = TestDataFactory.createCase('Invalid Rights', 'New', 'Collections'
        //                                            , 'Test Description', testContact.Id, testAccount.Id, true);
        //testCase2.ParentId = testCase1.Id;
        //insert testCase2;
        // Insert the custom Setting for CaseCommentTrigger
        Switch_CaseCommentTrigger__c testSetting = new Switch_CaseCommentTrigger__c(
            Set_Last_Worked_Fields_On_Case_Off__c = false
            , Set_Case_Comment_Counting_Off__c = false, Set_Overall_Trigger_Off__c =
            false, Set_Performance_Function_Off__c = false);
        insert testSetting;
        
         
        // Insert a Comment on Case
        CaseComment testComment1 = TestDataFactory.createCaseComment(
            'Test Comment', testCase1.Id, true, false);
        //CaseComment testComment2 = TestDataFactory.createCaseComment(
            //'Test Comment1', testCase1.Id, true, false);
        
        List < CaseComment > caseCommentList = new List < CaseComment > ();
        caseCommentList.add(testComment1);
        //caseCommentList.add(testComment2);
        Test.startTest();
        //insert caseCommentList;
        //System.assertEquals([SELECT Id, Last_Worked_By__c, Last_Worked_By__r.Id FROM Case limit 1].Last_Worked_By__r.Id, UserInfo.getUserId());
        testComment1.CommentBody = 'test';
       // update testComment1;
        Test.stopTest();
    }
}