@isTest(seeAllData=false)
private class orderTriggerHandlerManager_Test {
    
      private static testMethod void testTriggerFunctionality() {
          OrderDecompController.stopCreatingAccount = true;
          User thisUser = [ Select Id from User where Id = :UserInfo.getUserId() ];
          // User Batchuser = [Select Id from User where username = 'batchintegration_user@move.com.dev'];
          User Batchuser = [Select Id from User where username like 'batchintegration_user@move.com%'];
          System.runAs( thisUser ){              
              Collection_Users__c mycs = Collection_Users__c.getValues('batchintegration user');              
              if(mycs == null) {
                  mycs = new Collection_Users__c(Name= 'batchintegration user');
                  mycs.Id__c = Batchuser.id; // '005j000000CdBiE';
                  insert mycs;
              }
          }           
          
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;     
        Account theAccount = TestDataFactory.createAccount('The Test Account', null, false);
        theAccount.Primary_Email__c = 'theAcc@move.com';
         theAccount.Type = 'Broker';
        theAccount.Account_Sub_Type__c ='Prospect';
        theAccount.Do_Not_Move__c = false;
        theAccount.Sales_Lock_User__c = userinfo.getuserid();
        insert theAccount;
        Set<Id> setAccountIds= new Set<Id> ();
        setAccountIds.add(theAccount.Id);
        system.debug('theAccount:' + theAccount.Id);     
    Account childAccount = TestDataFactory.createAccount('Child Account',null,false);
    childAccount.Primary_Email__c = 'childacc@move.com';
    childAccount.Type = 'Realtor Office';                                
    childAccount.Account_Sub_Type__c = 'Prospect';
    childAccount.Sales_Lock_User__c = userinfo.getuserid();
    insert childAccount;  
        
      Id StandardPriceBookId = Test.getStandardPricebookId();
       Product2 theTestProduct = new Product2(
      Name = 'Laptop X200',
      Family = 'Hardware',
      ProductCode = 'Showcase',
      S_No__c = 2
    );
    insert theTestProduct;
    Id accountRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Account Relationship').RecordTypeId;
     Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship
                                                            (theAccount.Id, childAccount.Id, null, null, true, false);
    accountRelation.RecordTypeId =  accountRelationshipRecordTypeId;
    accountRelation.Is_Parent_Primary__c = true;
    insert accountRelation; 
    Opportunity testOpp = new Opportunity();
        testOpp.Name = 'my test opportunity';
        testOpp.StageName = 'Prospecting';
        testOpp.ForecastCategoryName = 'Pipeline';
        testOpp.CloseDate = System.today();
        testOpp.AccountId = theAccount.Id;
        testOpp.Opportunity_Short_Description__c = 'Renewal';
        testOpp.Amount = 0.00;        
        //Required Custom Fields
        testOpp.Type = 'Renewal';
        insert testOpp;
       Set<Id> setOpportunityIds = new Set<Id> ();
        setOpportunityIds.add(testOpp.Id);
      map<ID,Order> newMap = new map<ID,Order>();
      map<ID,Order> oldMap = new map<ID,Order>();
      
    Order r =new Order();       
            r.AccountId=theAccount.id;
            r.Name='test';
            r.EffectiveDate=System.today();
            //r.Contractid=c.id;
            r.Status='Created';
            r.Pricebook2Id = standardpricebookid;   
            r.Is_OLI_Creation_Complete__c = false;
            r.Fulfillment_Status__c = 'Pending Fulfillment'; 
            r.OpportunityId = testOpp.Id;                  
            insert r;      
     oldMap.Put(r.id , r);     
     r.Fulfillment_Status__c = 'Fulfilled';
     update r;
     newMap.Put(r.id , r);  
     
     PricebookEntry thePricebookEntrie = new PricebookEntry();         
        thePricebookEntrie.Pricebook2Id = StandardPriceBookId;
        thePricebookEntrie.Product2Id = theTestProduct.Id;
        thePricebookEntrie.UnitPrice = 1000;
        thePricebookEntrie.IsActive = true;        
         insert thePricebookEntrie;
   OrderItem oi = new OrderItem(OrderId=r.id,Quantity=1.0,PricebookEntryId=thePricebookEntrie.Id,unitPrice=1000,Inventory_Transaction_Id__c = r.Id,Fulfillment_Status__c = 'Pending Fulfillment');
            insert oi;  
            
   
     test.starttest();     
     orderTriggerHandlerManager handler = new orderTriggerHandlerManager();
     handler.accountOwnerUpdate(newMap,oldMap);
     handler.AsyncupdateOfficeAccounts(setAccountIds);
     handler.updateOfficeAccounts(setAccountIds);
     handler.GenerateJsonOrdersStrings(newMap);
     handler.UpdateOpportunity(setOpportunityIds);
     test.stoptest();
     
  }

      private static testMethod void testTriggerFunctionality1() {
      OrderDecompController.stopCreatingAccount = true;
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;     
        Account theAccount = TestDataFactory.createAccount('The Test Account', null, false);
        theAccount.Primary_Email__c = 'theAcc@move.com';
         theAccount.Type = 'Broker';
        theAccount.Account_Sub_Type__c ='Prospect';
        theAccount.Do_Not_Move__c = True;
        //theAccount.Sales_Lock_User__c = userinfo.getuserid();
        insert theAccount;
        Set<Id> setAccountIds= new Set<Id> ();
        setAccountIds.add(theAccount.Id);
        system.debug('theAccount:' + theAccount.Id);     
    Account childAccount = TestDataFactory.createAccount('Child Account',null,false);
    childAccount.Primary_Email__c = 'childacc@move.com';
    childAccount.Type = 'Realtor Office';                                
    childAccount.Account_Sub_Type__c = 'Prospect';
    //childAccount.Sales_Lock_User__c = userinfo.getuserid();
    insert childAccount;  
          
          User thisUser = [ Select Id from User where Id = :UserInfo.getUserId() ];
 User Batchuser = [Select Id from User where username LIKE 'batchintegration_user@move.com%' ];

          System.runAs( thisUser ){              
              Collection_Users__c mycs = Collection_Users__c.getValues('batchintegration user');              
              if(mycs == null) {
                  mycs = new Collection_Users__c(Name= 'batchintegration user');
                  mycs.Id__c = Batchuser.id; //'005j000000CdBiE';
                  insert mycs;
              }
          } 
        
      Id StandardPriceBookId = Test.getStandardPricebookId();
       Product2 theTestProduct = new Product2(
      Name = 'Laptop X200',
      Family = 'Hardware',
      ProductCode = 'Showcase',
      S_No__c = 2
    );
    insert theTestProduct;
    Id accountRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Account Relationship').RecordTypeId;
     Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship
                                                            (theAccount.Id, childAccount.Id, null, null, true, false);
    accountRelation.RecordTypeId =  accountRelationshipRecordTypeId;
    accountRelation.Is_Parent_Primary__c = true;
    insert accountRelation; 
    Opportunity testOpp = new Opportunity();
        testOpp.Name = 'my test opportunity';
        testOpp.StageName = 'Prospecting';
        testOpp.ForecastCategoryName = 'Pipeline';
        testOpp.CloseDate = System.today();
        testOpp.AccountId = theAccount.Id;
        testOpp.Opportunity_Short_Description__c = 'Renewal';
        testOpp.Amount = 0.00;        
        //Required Custom Fields
        testOpp.Type = 'Renewal';
        insert testOpp;
       Set<Id> setOpportunityIds = new Set<Id> ();
        setOpportunityIds.add(testOpp.Id);
      map<ID,Order> newMap = new map<ID,Order>();
      map<ID,Order> oldMap = new map<ID,Order>();
      
    Order r =new Order();       
            r.AccountId=theAccount.id;
            r.Name='test';
            r.EffectiveDate=System.today();
            //r.Contractid=c.id;
            r.Status='Created';
            r.Pricebook2Id = standardpricebookid;   
            r.Is_OLI_Creation_Complete__c = false;
            r.Fulfillment_Status__c = 'Pending Fulfillment'; 
            r.OpportunityId = testOpp.Id;      
            insert r;      
     oldMap.Put(r.id , r);     
     r.Fulfillment_Status__c = 'Fulfilled';
     update r;
     newMap.Put(r.id , r);  
     
     PricebookEntry thePricebookEntrie = new PricebookEntry();         
        thePricebookEntrie.Pricebook2Id = StandardPriceBookId;
        thePricebookEntrie.Product2Id = theTestProduct.Id;
        thePricebookEntrie.UnitPrice = 1000;
        thePricebookEntrie.IsActive = true;        
         insert thePricebookEntrie;
   OrderItem oi = new OrderItem(OrderId=r.id,Quantity=1.0,PricebookEntryId=thePricebookEntrie.Id,unitPrice=1000,Inventory_Transaction_Id__c = r.Id,Fulfillment_Status__c = 'Pending Fulfillment');
            insert oi;  
            
     test.starttest();     
     orderTriggerHandlerManager handler = new orderTriggerHandlerManager();     
     handler.accountOwnerUpdate(newMap,oldMap);
     handler.AsyncupdateOfficeAccounts(setAccountIds);
     handler.updateOfficeAccounts(setAccountIds);
     handler.GenerateJsonOrdersStrings(newMap);
     handler.UpdateOpportunity(setOpportunityIds);
     test.stoptest();
     
  }
}