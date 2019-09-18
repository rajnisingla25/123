//**************************************************//
// (c) 2015 NTTDATA, Inc.
// Class Name : ChildToParentUpdateHandlerTest
// This Class is Used to Upadate Parent case to closed, when all the child cases are closed. 
//
// Created 1th july 2015   Author Name:-  Vikram Thallapelli     Original
// Modified 09th july 2015   Author Name:-  Vikram Thallapelli     Modified
//**************************************************//
@isTest
private class ChildToParentUpdateHandlerTest {
        
    
    public static List<Case> createCaseHierarchy(String startingStatus) {
      //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
    //Inserting Test Account
    Account brokerAccount = TestDataFactory.createAccount('Broker Account', null, false);
        brokerAccount.RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('B2B').RecordTypeId;
        brokerAccount.Type = 'Broker';
        brokerAccount.Primary_Email__c = 'brokerAccount@b2b.com';
        insert brokerAccount; 
        
          Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
         Id rtId = CaseRecordTypeInfo.get('Retention').getRecordTypeId();
     
    CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
            insert setting;
        
        List<Case> cases = new List<Case>();
        
        Case parent = new Case(Subject='foo',Origin='Phone',AccountId = brokerAccount.id ,Status=startingStatus,RecordTypeId = rtId );      
        insert parent;      
        cases.add(parent);           
        Case child1 = new Case(Subject='child1',Origin='Phone',AccountId = brokerAccount.id,Status=startingStatus,ParentId=parent.Id,RecordTypeId = rtId );        
        insert child1;  
        cases.add(child1);
        //Case child2 = new Case(Subject='child2',Origin='Phone',AccountId = brokerAccount.id ,Status=startingStatus,ParentId=parent.Id,RecordTypeId = rtId );
        //insert child2;
                //cases.add(child2);
      
        return cases;       
    }
  
    static testMethod void childToParentTest(){
        
         DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
    //Inserting Test Account
    Account brokerAccount = TestDataFactory.createAccount('Broker Account', null, false);
        brokerAccount.RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('B2B').RecordTypeId;
        brokerAccount.Type = 'Broker';
        brokerAccount.Primary_Email__c = 'brokerAccount@b2b.com';
        insert brokerAccount; 
        
          Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
         Id rtId = CaseRecordTypeInfo.get('Retention').getRecordTypeId();
     
    CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
            insert setting;
        
        List<Case> cases = new List<Case>();
         Test.startTest(); 
        Case parent = new Case(Subject='foo',Origin='Phone',AccountId = brokerAccount.id ,Status='New',RecordTypeId = rtId );      
        insert parent;      
                   
        Case child1 = new Case(Subject='child1',Origin='Phone',AccountId = brokerAccount.id,Status='New',ParentId=parent.Id,RecordTypeId = rtId );        
        //cases.add(child1);
        
        //Case child2 = new Case(Subject='child2',Origin='Phone',AccountId = brokerAccount.id ,Status='New',ParentId=parent.Id,RecordTypeId = rtId );
         //cases.add(child2);
      insert child1;
      //cases[0].status = 'Open';
      //update cases[0];
        map<id,case> oldCases = new map<id,case>();
        oldCases.put(child1.Id , child1);
        
      
        ChildToParentUpdateHandler controller = new ChildToParentUpdateHandler();
        controller.onBeforeUpdate(oldCases,oldCases);
      Test.stopTest();  
    }

}