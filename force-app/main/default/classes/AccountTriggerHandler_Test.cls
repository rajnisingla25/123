@isTest(seeAllData = false)
public  class AccountTriggerHandler_Test{
    public static testMethod void main(){ 
    MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
    Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtId = CaseRecordTypeInfo.get('Retention').getRecordTypeId();     
            
            CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
            insert setting;
   
    //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
    Switch_AccountRelationshipTrigger__c art = new Switch_AccountRelationshipTrigger__c(name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
    insert art;
    Switch_AccountTrigger__c st=new Switch_AccountTrigger__c(); 
    st.Set_Overall_Trigger_Off__c = False;
    insert st;

    // Inserting a test user and asserting
    Profile p = [SELECT id FROM profile WHERE name='System Administrator' LIMIT 1];
    System.assertNotEquals(null, p.Id);
    User u = TestDataFactory.createUser(null, p.Id, null, 'testwaitlist12@test.com', 'testwaitlist12@test.com', false);
    u.NT_Login_ID__c = 'NTXZ';
    insert u;
    System.assertNotEquals(null, u.Id);
    
    insert new Incremental_data_load__c(Disable_Validation_Rules__c = True);

    List<Account> accList =new List<Account>();
    //Inserting Test Account       
    Account newAccount = TestDataFactory.createAccount('newAccount',null,false);
          newAccount.Primary_Email__c = 'testAccount@move.com';
          newAccount.Type = 'Broker';
          newAccount.party_id__c ='12345';
          newAccount.Ownerid =u.id;
          newAccount.Total_Contract_Value__c  = 5000;
    //accList.add(newAccount);
    insert newAccount; 
    system.debug('Owner1'+newAccount.Ownerid);
 
     //Inserting Test Contact 
    Contact testContact = TestDataFactory.createContact('Test Contact','TestL',newAccount.Id,true,false);
          testContact.Email = 'rshekhawat@move.com';
    insert testContact;            
    
     Account_Relationship__c primarycntct = new Account_Relationship__c();
       // primarycntct.Child_Account__c = newAccount.id;
        primarycntct .Contact_To__c = testContact.id;
        primarycntct.Contact_Role__c = 'Primary Contact';
        primarycntct.Entity_Name__c = 'abc';
        primarycntct.Is_Parent_Primary__c = true;
        newAccount.Total_Contract_Value__c  = 30000;
        newAccount.EssentialsStatus__c = 'Activated';
        update newAccount;
        primarycntct.Parent_Account__c = newAccount.id;
        primarycntct.Active__c = true;
        primarycntct.Relationship_Type__c = 'Member';
        primarycntct.Zuora_Bill_to_Contact_ID__c = 'test';
        primarycntct.Zuora_Ship_to_Contact_ID__c = 'testing';
        primarycntct.Zuora_Sync__c = true;
        insert primarycntct;
        
    //Inserting Waitlist and Asserting
    Waitlist__c waitList = new Waitlist__c(Account__c = newAccount.Id, Status__c='Active', Pre_Auth_Contact__c=testContact.Id, 
                                           Pre_Auth_Email__c='testpreauth@test.com'); 
    insert waitList;
    System.assertNotEquals(null, waitList.Id);  

  Product2 newProduct = new Product2();
        newProduct.Name = 'TestProduct';
        newProduct.Commission_Category__c = 'Normal';    
        newProduct.Normalization_factor__c = 1.10;
        newProduct.Commission_Category__c = 'CFCB';
        newProduct.Fulfillment_Type__c = 'Manual';
        newProduct.Auto_Renewal__c = True;
        newProduct.S_No__c = 2;
        insert newProduct;   
        
    Asset assets = new Asset();
        assets.Name = 'test';
        assets.Renewal_Status__c = 'Renew';
        assets.Auto_Renewal__c = 'No';
        assets.Asset_Type__c = 'Parent';
        assets.AccountId = newAccount.id;
        assets.Product2Id = newProduct.id;
        assets.Fulfillment_Status__c = 'Fulfilled';
        assets.Status = 'Active';
        assets.At_Risk__c = false;
        assets.Billing_Period__c = 'Monthly';
        assets.Start_Date__c = system.today();
        assets.End_Date__c = system.today().addDays(10);
        assets.Asset_Type__c = 'Parent';
        assets.Auto_Renewal__c  = 'Yes';
        assets.Price = 10.00;
        insert assets;
    Id theStandardPriceBookId = Test.getStandardPricebookId();  
   
    Order  Orders = new Order();
        Orders.AccountId = newAccount.id;
        Orders.Fulfillment_Status__c = 'Fulfilled';
        Orders.Status = 'Created';
        Orders.Name = 'Test order'; 
        Orders.Pricebook2Id = theStandardPriceBookId ;
        Orders.EffectiveDate = system.today();
        Orders.EndDate = system.today().addDays(10);
        insert Orders;
        
    OrderItem OrderItems = new OrderItem();
        OrderItems.UnitPrice = 789.62;
        OrderItems.Quantity = 6;
        OrderItems.Asset__c = assets.id;
        OrderItems.OrderId = Orders.id;
        OrderItems.Auto_Renewal__c = 'Yes';
        OrderItems.PricebookEntryId = theStandardPriceBookId;
        
         List<Case> cases = new List<Case>();
         Case theCase1 = new Case();
         theCase1.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Collections').getRecordTypeId();
         theCase1.Subject = 'Invalid Rights';
         theCase1.Status = 'New';
         theCase1.Origin = 'phone';
         theCase1.Type = 'Collections';
         theCase1.Description = 'Test Description';
         theCase1.Area__c = 'Access Issues';
         theCase1.AccountId = newAccount.ID;         
         theCase1.OwnerId = userinfo.getUserId();
         //insert theCase1;
         cases.add(theCase1);
         
        Case theCase2 = new Case();
         theCase2.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Sales Ops').getRecordTypeId();
         theCase2.Subject = 'Invalid Rights';
         theCase2.Status = 'New';
         theCase2.Origin = 'phone';
         theCase2.Type = 'Lead Suspension';
         theCase2.Description = 'Test Description';
         theCase2.Area__c = 'Access Issues';
         theCase2.AccountId = newAccount.ID;         
         theCase2.OwnerId = userinfo.getUserId();
         //insert theCase2;
         cases.add(theCase2);
         insert cases;

    
    Map<id,Account> accountMapold = new Map<id,Account>();
    accountMapold.put(newAccount.id,newAccount);
    //newAccount.Ownerid = userInfo.getUserId();
    User u1 = TestDataFactory.createUser(null, p.Id, null, 'testwaitlist123@test.com', 'testwaitlist123@test.com', false);
    u1.NT_Login_ID__c = 'NTXZ1';
    insert u1;
   
    Map<id,Asset> AssetMap = new Map<id,Asset>();
    AssetMap.put(assets.id,assets);
    Map<id,OrderItem> OrderItemsMap = new Map<id,OrderItem>();
    OrderItemsMap.put(OrderItems.id,OrderItems);
    Map<id,Contact> contactmap = new Map<id,Contact>();
    contactmap.put(primarycntct.Parent_Account__c,primarycntct .Contact_To__r); 
    set<id> AcctIds = new set<id>();
    AcctIds.add(newAccount.id);
    Set<Id> PricebookEntryIds = new Set<Id>();
    PricebookEntryIds.add(OrderItems.PricebookEntryId);
    
    Test.StartTest();
    List<Account> acctlist = new List<Account>();
    acctlist.add(newAccount);
    AccountTriggerHandler ATH = new AccountTriggerHandler(true,20);    
    ATH.onAfterInsert(accountMapold);
    ATH.onAfterUpdate(accountMapold,accountMapold);
   
    ATH.onBeforeUpdate(accountMapold, accountMapold);
     newAccount.Ownerid = u1.id;
     newAccount.party_id__c ='123456';
     newAccount.Home_Phone__c = '4159372843';
     newAccount.Mobile1__c = '4159372843';
     newAccount.Mobile2_Other__c = '4159372843';
     newAccount.Phone = '4159372843';
     newAccount.Work_Phone__c = '4159372843';
    newAccount.Resend_Welcome_Email__c = false;
    update newAccount;
    newAccount.Suspension_Status__c =  'Suspended';
     update newAccount;
    newAccount.Suspension_Status__c = 'Resumed';
     update newAccount; 
    system.debug('Owner2'+newAccount.Ownerid);
    Map<id,Account> accountMap = new Map<id,Account>();
    
    accountMap.put(newAccount.id,newAccount);
     ATH.AccountOwnerSync(accountMap,accountMapold);
     ATH.CollectioncaseReAssignment(accountMap,accountMapold);
     for(Account acct:[Select Id,name, Account_Mobile2_Formatted__c, Account_Work_Formatted__c, Account_Phone_Formatted__c, Account_HomePhone_Formatted__c, Account_Mobile1_Formatted__c from Account where Id=:accountMap.keyset()]){
     accountMap.put(newAccount.id,newAccount);
     }
    // AccountTriggerHandler.InsertUpdatePhone(accountMap,accountMapold);
    // AccountTriggerHandler.InsertUpdatePhone(accountMap,null);
     AccountTriggerHandler.UpdateLeadonTotalScoreChange(accountMap.keyset());
     system.debug('test123'+accountMap);
     system.debug('test1234'+accountMapold);
   // }
   Test.StopTest();
   } 
}