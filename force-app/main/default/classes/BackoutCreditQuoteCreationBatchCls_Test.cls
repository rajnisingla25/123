@isTest(seeAllData =false)
public  class BackoutCreditQuoteCreationBatchCls_Test{

@testSetup static void DataSetUpClass() {

         
        
        Profile p = [select id from profile where name='Standard User'];
        User u = new User(alias = 'standt', email='standarduser@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/New_York', username='standarduser@test.com'); 
   
   //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        List<Account> lstAccount = new List<Account>();
        Account theAccountb = TestDataFactory.createAccount('The Test Account', null, false);
        theAccountb.Primary_Email__c = 'theAcc@move.com';
        theAccountb.Type = 'Broker';
        lstAccount.add(theAccountb);
        //insert theAccountb;
        
    Account theAccounto = TestDataFactory.createAccount('The Test Account', null, false);
        theAccounto.Primary_Email__c = 'theAcc@move.com';
        theAccounto.Type = 'Realtor Office';
        lstAccount.add(theAccounto);
        //insert theAccounto;
    
    Account theAccount = TestDataFactory.createAccount('The Test Account', null, false);
        theAccount.Primary_Email__c = 'theAcc@move.com';
        theAccount.Type = 'Realtor Agent';
        theAccount.Status__c = 'Active';
        lstAccount.add(theAccount);
        //insert theAccount;
        
        Account theAccountmls = TestDataFactory.createAccount('The Test Account', null, false);
        theAccountmls.Primary_Email__c = 'theAcc@move.com';
        theAccountmls.Type = 'MLS Account';
        
        lstAccount.add(theAccountmls);
        //insert theAccountmls;
        system.debug('theAccount:' + theAccount.Id);  
        Insert lstAccount;
        
        MLS__c mls = new MLS__c();
        mls.Name = 'LA-ooirdjsd';
        mls.Office__c = theAccounto.id;
        mls.Status__c = 'Active';
        mls.MLS__c = theAccountmls.id;
        insert mls;
        
        List<Account_Relationship__c> toBeInserted = new List<Account_Relationship__c>();
  
    Id accountRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Account Relationship').RecordTypeId;
    Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;

    //Create Account Relationship Records for Accounts
    Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship
                                                            (theAccountb.Id, theAccounto.Id, null, null, true, false);
    accountRelation.RecordTypeId =  accountRelationshipRecordTypeId;
    accountRelation.Is_Parent_Primary__c = true;
    accountRelation.Active__c = true;
    toBeInserted.add(accountRelation); 
    
    Account_Relationship__c accountRelation1 = TestDataFactory.createAccountRelationship
                                                            (theAccounto.Id, theAccount.Id, null, null, true, false);
    accountRelation1.RecordTypeId =  accountRelationshipRecordTypeId;
    accountRelation1.Is_Parent_Primary__c = true;
    accountRelation1.Active__c = true;
    toBeInserted.add(accountRelation1); 
    
    Insert toBeInserted;
        
    Contact theContact = TestDataFactory.createContact('The Test', 'Contact 1', theAccount.Id, true, false);
        theContact.Phone = '9876543210';
        theContact.Email = 'hsingh@appirio.com';
        insert theContact ;
    Product2 newProduct = new Product2();
        newProduct.Name = 'TestProduct';        
        newProduct.ProductCode='SHOWCASE' ;
        newProduct.S_No__c = 2;
        insert newProduct;
        
        
    List<Asset> asset = new List<Asset>();  
        Asset assets = new Asset();
        assets.Name = 'test';
        assets.Renewal_Status__c = 'Renew';
        assets.Auto_Renewal__c = 'Yes';
        assets.Asset_Type__c = 'Parent';
        assets.AccountId = theAccount.id;
        assets.Fulfillment_Status__c = 'Fulfilled';
        assets.Status = 'Active';
        assets.Line_Type__c = 'Add';
        assets.Billing_Period__c = 'Monthly';
        assets.Start_Date__c = system.today();
        assets.End_Date__c = System.today().addDays(10);
        assets.Product2Id = newProduct.id;
        //assets.Ultimate_Parent_Id_Text__c = 'Test';        
        insert assets;
        
        Asset assets1 = new Asset();
        assets1.Name = 'test';
        assets1.Renewal_Status__c = 'Renew';
        assets1.Auto_Renewal__c = 'Yes';
        assets1.Asset_Type__c = 'Fulfill to';
        assets1.AccountId = theAccount.id;
        assets1.Fulfillment_Status__c = 'Fulfilled';
        assets1.Status = 'Active';
        assets1.Line_Type__c = 'Add';
        assets1.parent_asset__c = assets.id;
        assets1.Billing_Period__c = 'Monthly';
        assets1.Start_Date__c = system.today();
        assets1.End_Date__c = System.today().addDays(10);
        assets1.Product2Id = newProduct.id;
        assets1.Ultimate_Parent_Id_Text__c = assets.id;        
        insert assets1;
        
        Asset assets2 = new Asset();
        assets2.Name = 'test';
        //assets2.Renewal_Status__c = 'Add';
        assets2.Auto_Renewal__c = 'Yes';
        assets2.Asset_Type__c = 'Participant';
        assets2.AccountId = theAccount.id;
        assets2.Fulfillment_Status__c = 'Fulfilled';
        assets2.Status = 'Active';
        assets2.Line_Type__c = 'Add';
        assets2.parent_asset__c = assets1.id;
        assets2.Billing_Period__c = 'Monthly';
        assets2.Start_Date__c = system.today();
        assets2.End_Date__c = System.today().addDays(10);
        assets2.Product2Id = newProduct.id;
        assets2.mls_set__c = mls.id;
        assets2.Ultimate_Parent_Id_Text__c = assets.id;        
        insert assets2;
                
        
        asset.add(assets);
        //insert asset;
        Set<Id> theAssetIdsToProcess = new Set<Id>();
        theAssetIdsToProcess.add(assets.id);
                
        Map<Id,Map<Id,String>> mapAgentAccountIds = new Map<Id,Map<Id,String>>();
        Map<Id,String> setAccountAssetIds = new Map<Id,String>();
        mapAgentAccountIds.put(assets.AccountId,setAccountAssetIds);
        }
        
        public static testMethod void mainMethod(){  
        List<Asset> lstasset = [Select id,name,Parent_Asset__c,AccountId,Product2Id,Product2.ProductCode,Status,Line_Type__c,Ultimate_Parent__c from Asset where Asset_Type__c='Parent' and Status='Active'];
        Test.StartTest();
        BackoutCreditQuoteCreationBatchCls BCQCB = new BackoutCreditQuoteCreationBatchCls ();
        Database.BatchableContext bc;             
        BCQCB.start(bc);
        BCQCB.execute(bc,lstasset);
        BCQCB.finish(bc);  
              
        Database.executeBatch(BCQCB,200);     
        Test.StopTest();
    }
     
}