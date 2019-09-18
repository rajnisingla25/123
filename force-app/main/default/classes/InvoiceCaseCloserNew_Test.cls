@IsTest
private class InvoiceCaseCloserNew_Test{
     static testMethod void InvoiceAssignmentHandler_Test(){
        
     test.startTest();  
    //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
    insert Dtrg;
     
    Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
    Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
    Id rtId = AccountRecordTypeInfo .get('Collections').getRecordTypeId();
    
    CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Collection' , Record_Type_Id__c = rtId);
    insert setting;
             
     Schema.DescribeSObjectResult cfrSchema1 = Schema.SObjectType.Case; 
    Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo1 = cfrSchema1.getRecordTypeInfosByName(); 
    Id rtId1 = AccountRecordTypeInfo1.get('Retention').getRecordTypeId();
    
    CaseRecordTypes__c setting1 = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId1);
             insert setting1;      
         
    Account theAccount = TestDataFactory.createAccount('The Test Account', null, false);
    theAccount.Primary_Email__c = 'theAcc@move.com';
    theAccount.Type = Constants.OFFICE_ACCOUNT_TYPE;
    insert theAccount;
    system.debug('theAccount:' + theAccount.Id);  
   
   List<Zuora__ZInvoice__c> invoices = new List<Zuora__ZInvoice__c>();
   Zuora__ZInvoice__c inv = new Zuora__ZInvoice__c();
          inv.Name = 'TestInv';
          inv.Zuora__DueDate__c = System.TODAY();
          inv.Zuora__Balance2__c = 0; 
          inv.Zuora__Account__c = theAccount.Id;
          inv.Zuora__Status__c  = 'Posted' ;
          invoices.Add(inv);
          insert invoices ;           
         // inv.Zuora__Status__c  = 'Paid' ;
    //InvoiceAssignmentRecursive.run = False;       
         // Update invoices;
    Map<Id, Zuora__ZInvoice__c> mapAllInvoices = new Map<Id, Zuora__ZInvoice__c>();
    mapAllInvoices.put(inv.Id,inv);
   
     Case testCase = new case();
     testCase.recordTypeId = rtId;
     testCase.Status = 'New';
     testCase.Origin = 'Phone';
     testCase.AccountId = theAccount.Id;     
     Insert testCase;
    system.debug('testCase:' + testCase.Id);    
    
    Case_Invoice_Relationship__c cir = new Case_Invoice_Relationship__c();
    cir.Invoice__c = inv.Id;
    cir.case__c = testCase.Id;   
    insert cir;
    InvoiceCaseCloserNew cs = new InvoiceCaseCloserNew();
    cs.CaseCloser(invoices );  
 
 test.stopTest();
        
   }
 }