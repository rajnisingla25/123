@isTest(seeAllData =false)
public  class AutoRenewalQuoteCreationBatchCls_Test{
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
        
         //Inserting Test Contact 
    Contact testContact = TestDataFactory.createContact('Test Contact','TestL',testAccount.Id,true,false);
          testContact.Email = 'rshekhawat@move.com';
          insert testContact;         
        
        Product2 newProduct = new Product2();
        newProduct.Name = 'TestProduct';
        newProduct.Commission_Category__c = 'Normal';    
        newProduct.Normalization_factor__c = 1.10;
        newProduct.Commission_Category__c = 'CFCB';
        newProduct.Fulfillment_Type__c = 'Manual';
        newProduct.Auto_Renewal__c = True;
        newProduct.ProductCode='SHOWCASE' ;
        newProduct.S_No__c = 2;
        insert newProduct;
        
        Asset assets = new Asset();
        assets.Name = 'test';
        assets.Renewal_Status__c = 'Renew';
        assets.Auto_Renewal__c = 'Yes';
        assets.Asset_Type__c = 'Parent';
        assets.AccountId = testAccount.id;
        assets.Fulfillment_Status__c = 'Fulfilled';
        assets.Status = 'Active';
        assets.Line_Type__c = 'Backout Credit';
        assets.Billing_Period__c = 'Monthly';
        assets.Start_Date__c = system.today();
        assets.End_Date__c = System.today().addDays(30);
        assets.Product2Id = newProduct.id;
        assets.Haircut_Asset__c = false;
        insert assets; 
      
        set<id> accids = new set<id>();
        accids.add(testAccount.id);
        
        
        AutoRenewalQuoteCreationBatchCls ARQCB = new  AutoRenewalQuoteCreationBatchCls();
                
list<Asset> li2 = new list<Asset>();
li2.add(assets);
Test.startTest();

        Database.BatchableContext bc;
             
        ARQCB.start(bc);
        ARQCB.execute(bc,li2);
        ARQCB.finish(bc);   
              
        Database.executeBatch(ARQCB,200);  
        ARQCB.createOpportunity(accids);  
          
        Test.stopTest();
       
       }
   }