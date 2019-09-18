@isTest
Public class CreateRetentionQuote_Test{
    static testMethod void CreateRetentionQuote_Test(){
    //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
    Switch_AccountRelationshipTrigger__c art = new Switch_AccountRelationshipTrigger__c(name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
    insert art;      
    //Inserting Test Account       
     Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
          testAccount.Primary_Email__c = 'testAccount@move.com';
                    insert testAccount; 
     //Inserting Test Contact 
    Contact testContact = TestDataFactory.createContact('Test Contact','TestL',testAccount.Id,true,false);
          testContact.Email = 'rshekhawat@move.com';          
          insert testContact;       
      Account_Relationship__c listAccRel = new Account_Relationship__c();
      listAccRel.Parent_Account__c = testAccount.Id;
      listAccRel.Contact_Role__c='Primary Contact';
      insert listAccRel;
      
    Schema.DescribeSObjectResult cfrcSchema = Schema.SObjectType.Case; 
          Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrcSchema.getRecordTypeInfosByName(); 
          Id rtnId = CaseRecordTypeInfo.get('Retention').getRecordTypeId();          
    CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtnId);
                  insert setting;      
     //Inserting Test Case       
    Case testCase = TestDataFactory.createCase('Invalid Rights','New','Retention' ,'Test Description', testContact.Id,testAccount.Id,true);
       PageReference pgr = page.CreateRetentionQuote ;
        pgr.getParameters().put('accountId',testAccount.id);
        pgr.getParameters().put('caseId',testCase.id);        
        Test.SetCurrentPage(pgr);
       
        CreateRetentionQuote handler = new CreateRetentionQuote();
        handler.createQuote();  
       
    }
 static testMethod void CreateRetentionQuote_Test1(){ 
     //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
     Switch_AccountRelationshipTrigger__c art = new Switch_AccountRelationshipTrigger__c(name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
    insert art;     
    //Inserting Test Account       
     Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
          testAccount.Primary_Email__c = 'testAccount@move.com';
          insert testAccount; 
      Account_Relationship__c listAccRel = new Account_Relationship__c();
      listAccRel.Parent_Account__c = testAccount.Id;
      listAccRel.Contact_Role__c='Primary Contact';
      insert listAccRel;     
     //Inserting Test Contact 
    Contact testContact = TestDataFactory.createContact('Test Contact','TestL',testAccount.Id,true,false);
          testContact.Email = 'rshekhawat@move.com';
          insert testContact;    
      Opportunity theOpportunity = new Opportunity();
         theOpportunity.Name = 'The Opportunity';
         theOpportunity.StageName = 'Prospecting';
         theOpportunity.CloseDate = system.today();
         theOpportunity.AccountId = testAccount.id;
        theOpportunity.Opportunity_Short_Description__c = 'Retention';
        theOpportunity.Amount = 0.00;
         insert theOpportunity;       
       // Inserting Assets.
     Asset assets = new Asset();
        assets.Name = 'test';
        assets.Renewal_Status__c = 'Renew';
        assets.Auto_Renewal__c = 'No';
        assets.Asset_Type__c = 'Parent';
        assets.AccountId = testAccount.id;
        assets.Fulfillment_Status__c = 'Fulfilled';
        assets.Status = 'Active';
        assets.At_Risk__c = false;
        assets.Billing_Period__c = 'Monthly';
        assets.Start_Date__c = system.today();
        assets.End_Date__c = system.today().addDays(10);
        assets.Auto_Renewal__c  = 'Yes';
        assets.Price = 10.00;
        assets.Include_Asset__c = true;
        insert assets; 
      Map<Id,String> mapAssetIds = new Map<Id,String>();
        mapAssetIds.put(assets.Id,assets.Id);
               
    Schema.DescribeSObjectResult cfrcSchema = Schema.SObjectType.Case; 
          Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrcSchema.getRecordTypeInfosByName(); 
          Id rtnId = CaseRecordTypeInfo.get('Retention').getRecordTypeId();          
    CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtnId);
                  insert setting;  
    Cancellation_Reason_CPQ_Mapping__c cpq = new Cancellation_Reason_CPQ_Mapping__c(name = 'Customer Request',CPQ_Variable_Name__c = 'Customer Request');
    insert cpq;              
                      
     //Inserting Test Case       
    Case testCase = TestDataFactory.createCase('Invalid Rights','New','Retention' ,'Test Description', testContact.Id,testAccount.Id,true);
    
     // Inserted Case Asset Relationships.
    Case_Asset_Relationship__c theCaseAssetRelationship = new Case_Asset_Relationship__c();    
        theCaseAssetRelationship.Asset__c = assets.Id;
        theCaseAssetRelationship.Case__c = testCase.Id;
        theCaseAssetRelationship.Line_Action__c = 'cancel';
        theCaseAssetRelationship.Cancellation_Reason__c = 'Customer Request';     
    insert theCaseAssetRelationship;
     
   PageReference pgr = page.CreateRetentionQuote ;       
         pgr.getParameters().put('accountId',testAccount.id);   
        pgr.getParameters().put('caseId',testCase.id); 
         pgr.getParameters().put('opptyId',theOpportunity.id);              
        Test.SetCurrentPage(pgr);       
        CreateRetentionQuote handler = new CreateRetentionQuote();
        CreateRetentionQuote.createOpportunity(testAccount.id); 
        handler.createQuote();        
        CreateRetentionQuote.reDirect(null,null,testAccount.Id,theOpportunity.Id,testCase.id,'Retention',mapAssetIds);      
    
    }  
    
  }