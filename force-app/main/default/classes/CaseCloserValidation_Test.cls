@isTest
Public class CaseCloserValidation_Test{
    static testMethod void CaseCloserValidation_Test(){
    //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
    //Inserting Test Account       
     Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
          testAccount.Primary_Email__c = 'testAccount@move.com';
          insert testAccount; 
     //Inserting Test Contact 
    Contact testContact = TestDataFactory.createContact('Test Contact','TestL',testAccount.Id,true,false);
          testContact.Email = 'rshekhawat@move.com';
          insert testContact;            
    Schema.DescribeSObjectResult cfrcSchema = Schema.SObjectType.Case; 
          Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrcSchema.getRecordTypeInfosByName(); 
          Id rtnId = CaseRecordTypeInfo.get('Retention').getRecordTypeId();
    Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
             Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
             Id rtId = AccountRecordTypeInfo .get('Collections').getRecordTypeId();       
    CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtnId);
                  insert setting;  
    CaseRecordTypes__c settings = new CaseRecordTypes__c(Name = 'Collection' , Record_Type_Id__c = rtId);
                  insert settings;      
           
    //Inserting test Invoice            
    Zuora__ZInvoice__c inv1 = new Zuora__ZInvoice__c();
          inv1.Name = 'TestInv';          
          inv1.Zuora__Account__c = testAccount.Id;
          inv1.Zuora__DueDate__c = system.Today()-1;
          inv1.Zuora__Balance2__c = 100;
            insert inv1;   
     List<Case> theTestCases = new List<Case>();                
     //Inserting Test Case       
     theTestCases.add(TestDataFactory.createCase('Invalid Rights','Closed','Collections' ,'Test Description', testContact.Id,testAccount.Id,false));
             insert theTestCases;      
    CaseCloserValidation Test = new CaseCloserValidation();        
        Test.ErrorMsg(theTestCases);           
  }
}