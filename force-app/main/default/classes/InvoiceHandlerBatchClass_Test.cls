@isTest(seeAllData =false)
public  class InvoiceHandlerBatchClass_Test{
    public static testMethod void mainMethod1(){       
         Profile p = [select id from profile where name='Standard User'];
        User u = new User(alias = 'standt', email='standarduser@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/New_York', username='standarduser@test.com');    
    
    //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
    //Inserting Test Account       
     Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
          testAccount.Primary_Email__c = 'testAccount@move.com';
          insert testAccount; 
    Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
    Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
    Id rtId = AccountRecordTypeInfo .get('Collections').getRecordTypeId();
    
 CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Collection' , Record_Type_Id__c = rtId);
             insert setting;       
         //Inserting Test Contact 
    Contact testContact = TestDataFactory.createContact('Test Contact','TestL',testAccount.Id,true,false);
          testContact.Email = 'rshekhawat@move.com';
          insert testContact; 
      Zuora__ZInvoice__c inv = new Zuora__ZInvoice__c();
          inv.Name = 'TestInv';
          inv.Zuora__DueDate__c = System.TODAY()-1;
          inv.Zuora__Balance2__c = 100; 
          inv.Zuora__Status__c = '';
          inv.Zuora__Account__c = testAccount.Id;
          insert inv;  
      List<Zuora__ZInvoice__c> invoices = new List<Zuora__ZInvoice__c>();
       invoices.Add(inv);    
        Boolean  isFromTrigger = false ;  
      InvoiceHandlerBatchClass ARQCB = new InvoiceHandlerBatchClass(invoices,isFromTrigger) ;
          ID batchprocessid = Database.executeBatch(ARQCB ,1);
       //ARQCB.isRepOnVacation(null,null);   
      
   }
 }