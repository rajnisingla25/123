@isTest(seeAllData =false)
public  class AccountTriggerHandlerManager_Test{
static {
        BigMachines__Configuration_Record__c site = new BigMachines__Configuration_Record__c(BigMachines__Is_Active__c=true, BigMachines__action_id_copy__c='test12', BigMachines__action_id_open__c='test', BigMachines__bm_site__c='test', BigMachines__document_id__c='test', BigMachines__process__c='test', BigMachines__process_id__c='test',BigMachines__version_id__c='test');
        insert site;
   }
    public static testMethod void main(){
       
        Profile p = [select id from profile where name='Standard User'];
        User u = new User(alias = 'standt', email='standarduser@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
        localesidkey='en_US', profileid = p.Id,
        timezonesidkey='America/New_York', username='standarduser@test.com');    
   
        DisabledTrigger__c Dtrg = new DisabledTrigger__c();
        Dtrg.Name = 'Disabled';
        Dtrg.TaskTrigger__c = 'Test@test.com';
        Dtrg.AssetTrigger__c = 'Test@test.com';
        insert Dtrg;
        Set<String> BLAstrings = new set <String>{'BLA Unconfirmed','BLA Confirmed'};
        set<String> Corestring = new set<String>{'Core'};
        Switch_AccountRelationshipTrigger__c arc = new Switch_AccountRelationshipTrigger__c(Name ='Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
        insert arc; 
        Switch_AccountTrigger__c arc1 = new Switch_AccountTrigger__c(Name ='Brokeraccountblacoreflag' , Brokeraccountblacoreflag__c = True);
        insert arc1;
        Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;  
        List<Account> lstAccounts = new List<Account>();   
        id b2bRecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('B2B').RecordTypeId;
        liSt<Account>lstAccount = new liSt<Account>();
        Account  newAccount2 = new Account();
        newAccount2.name='XYZ';
        newAccount2.Phone = '+49-12346';
        newAccount2.BillingStreet = '2537343 ROUTE 52 STE 10 # 10';
        newAccount2.BillingCity = 'HOPE JUNCTION';
        newAccount2.BillingPostalCode = '12533';
        newAccount2.BillingState = 'NY';
        newAccount2.BillingCountry = 'USA';
        newAccount2.Primary_Email__c= 'ra1@gmail.com';
        newAccount2.Home_Phone__c= '96763322877';
        newAccount2.Work_Phone__c = '426789';
        newAccount2.Mobile1__c = '3234511';
        newAccount2.Mobile2_Other__c = '1245787';
        newAccount2.party_id__c = '206084041';
        newAccount2.Type = 'Realtor Office';
        newAccount2.Auto_Renewal__c = True;
        newAccount2.Account_Status__c = 'Active';
        newAccount2.Territories__c = 'test';
       // newAccount2.Associated_Agent_Account__c = newAccount2.id;
      //  newAccount2.Associated_Broker_Account__c = newAccount2.id; 
        newAccount2.Zoura_Account_id__c ='Test';
		newAccount2.Office_Agent_BLA__c =null;
        newAccount2.EssentialsStatus__c = 'Activated';     
        newAccount2.Resend_Welcome_Email__c =false;  
        //lstAccounts.add(newAccount); 
        insert newAccount2;
        Account acc= [Select id,name,Mobile1__c,EssentialsStatus__c,Resend_Welcome_Email__c,Office_Agent_BLA__c from Account where Id =:newAccount2.Id];
        acc.name='XYZ';
        acc.Mobile1__c = '1134511';
        acc.EssentialsStatus__c = 'Activated';   
        acc.Resend_Welcome_Email__c =true;  
		acc.Office_Agent_BLA__c = 'BLA Confirmed';
        lstAccount.add(acc);
        update lstAccount;
        User ownId = [select Id from user where IsActive = true Limit 1];
        Account  newAccount = new Account();
        newAccount.name='XYZ';
        newAccount.Phone = '+49-12345';
        newAccount.BillingStreet = '2537 ROUTE 52 STE 10 # 10';
        newAccount.BillingCity = 'HOPEWELL JUNCTION';
        newAccount.BillingPostalCode = '12533';
        newAccount.BillingState = 'NY';
        newAccount.BillingCountry = 'USA';
        newAccount.Primary_Email__c= 'ra@gmail.com';
        newAccount.Home_Phone__c= '967622877';
        newAccount.Work_Phone__c = '456789';
        newAccount.Mobile1__c = '1234566';
        newAccount.Mobile2_Other__c = '1245787';
        newAccount.party_id__c = '206084041';
        newAccount.Type = 'Broker';
        newAccount.Auto_Renewal__c = True;
        newAccount.Territories__c = 'test';
        newAccount.Associated_Agent_Account__c = newAccount2.id;
        newAccount.Associated_Broker_Account__c = newAccount.id;   
        newAccount.Zoura_Account_id__c ='Test';
        newAccount.RecordTypeId = b2bRecordTypeId; 
        newAccount.Agent_Broker__c =true;
        newAccount.OwnerID = ownId.Id;
        newAccount.BLA__c = null;
        newAccount.Account_Status__c = 'Active';
        newAccount.Core__c=null;
		//newAccount.Office_Agent_BLA__c =null;
        lstAccounts.add(newAccount); 
        insert lstAccounts; 
      //  Account acc =  [SELECT Id,Office_Agent_BLA__c FROM Account WHERE Id = :lstAccounts[0].id];
		//update acc;                    
        Contact myContact = new Contact ();
        myContact.FirstName ='Joe';
        myContact.LastName ='Schmoe';
        myContact.Email ='Joe.Schmoe@test.de';
        myContact.Account = newAccount;
        myContact.MailingStreet = newAccount.BillingStreet;
        myContact.MailingState = newAccount.BillingState;
        myContact.MailingCity = newAccount.BillingCity;
        myContact.MailingPostalCode = newAccount.BillingPostalCode;
        myContact.MailingCountry = newAccount.BillingCountry;
        myContact.Phone=newAccount.Phone;
        myContact.Type__c = 'Other';
        myContact.Active__c = true;
        insert myContact;
         
        List<Account> acctlist= new List<Account>();
        acctlist.add(newAccount);
        Map<id,Account> acctmap = new Map<id,Account>();
        acctmap.put(newAccount.id,newAccount);
                 
        EntityFields__c entry = new EntityFields__c(Entity_Name__c = 'XYZ' , Name = 'Phone',Zuoura_Sync__c = true);                
        insert entry; 
       
        AccountTriggerHandlerManager ATHM = new AccountTriggerHandlerManager();
        List<Account_Relationship__c> lstAccRltn = new List<Account_Relationship__c>();
        Account_Relationship__c primarycntct = new Account_Relationship__c();
        primarycntct.Child_Account__c = lstAccount[0].id;
        primarycntct.Contact_To__c = myContact.id;
        primarycntct.Contact_Role__c = 'Primary Contact';
        primarycntct.Entity_Name__c = 'BillToAddress';
        primarycntct.Is_Parent_Primary__c = true;
        primarycntct.Parent_Account__c = lstAccounts[0].id;
        primarycntct.Active__c = true;
        primarycntct.Relationship_Type__c = 'Member';
        primarycntct.Zuora_Bill_to_Contact_ID__c = 'test';
        primarycntct.Zuora_Ship_to_Contact_ID__c = 'testing';
        primarycntct.Zuora_Sync__c = true;
        primarycntct.Billing_Contact__c =true;
        primarycntct.RecordTypeId=contactRelationshipRecordTypeId;
        lstAccRltn.add(primarycntct);
        insert lstAccRltn; 
            
        Map<id,String> acctmaptype = new Map<id,String>();
        acctmaptype.put(newAccount2.id,entry.Entity_Name__c);
        
        Map<id,Account> acctmapnew = new Map<id,Account>();
        Map<id,Account> accountMapold = new Map<id,Account>();
        accountMapold.put(newAccount.id,newAccount);
        acctmap.put(newAccount.id,newAccount2 );
        ATHM.webserviceCallout(acctlist,acctmap);
        AccountTriggerHandlerManager.firstentity = true;
        AccountTriggerHandlerManager.sendOutboundMessageNow(acctmaptype);
        AccountTriggerHandlerManager.sendOutboundMessageInFuture(acctmaptype);
        ATHM.populateAssociatedFields(acctmapnew,acctmap);
        ATHM.getAssociatedAccounts(acctlist,acctmapnew,acctmap,true);
        ATHM.getRecordTypeIdForAccount();
        ATHM.onAccountTerritorychange(acctmapnew,acctmap);
        ATHM.AccountAssetAutoRenewal(acctmapnew,acctmap);
        ATHM.SalesLockValidate(acctmapnew,acctmap);
		ATHM.Brokeraccountblacoreflag(lstAccount,acctmap);  
        newAccount.Account_Sub_Type__c = 'Customer';
        newAccount.Auto_Renewal__c = False;
        update newAccount;
        acctmap.put(newAccount.id,newAccount);
        ATHM.AccountAssetAutoRenewal(acctmap,accountMapold);
        newAccount.Auto_Renewal__c = True;
        update newAccount;
        acctmap.put(newAccount.id,newAccount);
        ATHM.AccountAssetAutoRenewal(acctmap,accountMapold);          
    }
    
    public static testMethod void main2(){     
        OrderDecompController.stopCreatingAccount = true;
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Switch_AccountRelationshipTrigger__c arc = new Switch_AccountRelationshipTrigger__c(Name ='Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
        insert arc;     
        //Inserting Test Account       
        Account newAccount = TestDataFactory.createAccount('newAccount',null,false);
        newAccount.Primary_Email__c = 'testAccount@move.com';
        newAccount.Type = 'Broker';
        newAccount.Account_Sub_Type__c = 'Prospect';
        newAccount.Auto_Renewal__c = True;
        newAccount.EssentialsStatus__c = 'Activated';
        insert newAccount; 
 
        //Inserting Test Contact 
        Contact testContact = TestDataFactory.createContact('Test Contact','TestL',newAccount.Id,true,false);
        testContact.Email = 'rshekhawat@move.com';
        insert testContact;            
        
        Product2 newProduct = new Product2();
        newProduct.Name = 'TestProduct';        
        newProduct.S_No__c = 2;
        newProduct.Auto_Renewal__c = True;
        newProduct.ProductCode = 'Showcase';
        insert newProduct;
        
        //Id theStandardPriceBookId = Test.getStandardPricebookId(); 
        Id StandardPriceBookId = Test.getStandardPricebookId();
        PricebookEntry thePricebookEntrie   = new PricebookEntry();
        thePricebookEntrie.Pricebook2Id     = StandardPriceBookId;
        thePricebookEntrie.Product2Id       = newProduct.Id;
        thePricebookEntrie.UnitPrice        = 1000;
        thePricebookEntrie.IsActive         = true;        
        insert thePricebookEntrie;   
        
        Asset assets = new Asset();
        assets.Name = 'test';        
        assets.Asset_Type__c = 'Parent';
        assets.AccountId = newAccount.id;
        assets.Product2Id = newProduct.id;
        assets.Fulfillment_Status__c = 'Fulfilled';
        assets.Status = 'Active';        
        assets.Start_Date__c = system.today();
        assets.End_Date__c = system.today().addDays(10);
        assets.Asset_Type__c = 'Parent';  
        assets.Auto_Renewal__c = 'Yes';      
        insert assets;
        
         
   
        Order  Orders = new Order();
        Orders.AccountId = newAccount.id;
        Orders.Fulfillment_Status__c = 'Fulfilled';
        Orders.Status = 'Created';
        Orders.Name = 'Test order'; 
        Orders.Pricebook2Id = thePricebookEntrie.Pricebook2Id;
        Orders.EffectiveDate = system.today();
        Orders.EndDate = system.today().addDays(10);
        insert Orders;
        
        OrderItem OrderItems = new OrderItem();
        OrderItems.UnitPrice = 789.62;
        OrderItems.Quantity = 6;
        OrderItems.Asset__c = assets.id;
        OrderItems.OrderId = Orders.id;
        OrderItems.Auto_Renewal__c = 'Yes';
        OrderItems.PricebookEntryId = thePricebookEntrie.Id;
        insert OrderItems;
   
        Map<id,Account> accountMapold = new Map<id,Account>();
        accountMapold.put(newAccount.id,newAccount);
        Account oldacc = accountMapold.get(assets.AccountId);
        system.debug('Imran'+accountMapold.get(newAccount.id));
        newAccount.Auto_Renewal__c = True;
        newAccount.EssentialsStatus__c = 'Activated';
        update newAccount; 
        Map<id,Account> accountMap = new Map<id,Account>();
        accountMap.put(newAccount.id,newAccount);  
        Account acc = accountMap.get(assets.AccountId);
        //System.assertNotEquals(acc.Auto_Renewal__c,oldacc.Auto_Renewal__c);  
        system.debug('Imran2'+accountMap.get(newAccount.id)); 
        Map<Id,PricebookEntry> pbMap = new Map<Id,PricebookEntry>();
        pbMap.put(thePricebookEntrie.id,thePricebookEntrie);
        assets.Auto_Renewal__c = 'Yes';      
        Update assets;
        Map<id,Asset> AssetMap = new Map<id,Asset>(); 
        AssetMap.put(assets.id,assets);
        AccountTriggerHandlerManager ATHM = new AccountTriggerHandlerManager();
        ATHM.AccountAssetAutoRenewal(accountMap, accountMapold );
        newAccount.Account_Sub_Type__c = 'Customer';
        oldacc.Account_Sub_Type__c='Prospect';
        newAccount.Auto_Renewal__c = True;
           oldacc.Auto_Renewal__c = False;
        update newAccount;
        accountMap.put(newAccount.id,newAccount);
        ATHM.AccountAssetAutoRenewal(accountMap,accountMapold);          
    } 
    
    public static testMethod void main3(){
        DisabledTrigger__c Dtrg = new DisabledTrigger__c();
        Dtrg.Name = 'Disabled';
        Dtrg.TaskTrigger__c = 'Test@test.com';
        Dtrg.AssetTrigger__c = 'Test@test.com';
        insert Dtrg;
        Switch_AccountRelationshipTrigger__c arc = new Switch_AccountRelationshipTrigger__c(Name ='Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
        insert arc; 
        Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;  
        List<Account> lstAccounts = new List<Account>();   
                
        id b2bRecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('B2B').RecordTypeId;
        
        Account a=new Account();
        a.name='test';
        insert a;
                
        Account  newAccount2 = new Account();
        newAccount2.name='XYZ';
        newAccount2.Phone = '+49-12346';
        newAccount2.BillingStreet = '2537343 ROUTE 52 STE 10 # 10';
        newAccount2.BillingCity = 'HOPE JUNCTION';
        newAccount2.BillingPostalCode = '12533';
        newAccount2.BillingState = 'NY';
        newAccount2.BillingCountry = 'USA';
        newAccount2.Primary_Email__c= 'ra1@gmail.com';
        newAccount2.Home_Phone__c= '96763322877';
        newAccount2.Work_Phone__c = '426789';
        newAccount2.Mobile1__c = '3234511';
        newAccount2.Mobile2_Other__c = '1245787';
        newAccount2.party_id__c = '206084041';
        newAccount2.Type = 'Broker';
        newAccount2.Auto_Renewal__c = True;
        newAccount2.Territories__c = 'test';
       // newAccount2.Associated_Agent_Account__c = newAccount2.id;
        newAccount2.Associated_Broker_Account__c = newAccount2.id; 
        newAccount2.Zoura_Account_id__c ='Test'; 
        newAccount2.RecordTypeId = b2bRecordTypeId;  
        //lstAccounts.add(newAccount); 
        insert newAccount2; 
        Map<id,Account> acctmapold = new Map<id,Account>();
        acctmapold.put(newAccount2.id,newAccount2);
        newAccount2.Associated_Agent_Account__c =a.id;
        newAccount2.name='XYZ';    
        newAccount2.Mobile1__c = '1134511';
        update newAccount2;
        
        Account  newAccount = new Account();        
        newAccount.name='XYZ';
        newAccount.Phone = '+49-12345';
        newAccount.BillingStreet = '2537 ROUTE 52 STE 10 # 10';
        newAccount.BillingCity = 'HOPEWELL JUNCTION';
        newAccount.BillingPostalCode = '12533';
        newAccount.BillingState = 'NY';
        newAccount.BillingCountry = 'USA';
        newAccount.Primary_Email__c= 'ra@gmail.com';
        newAccount.Home_Phone__c= '967622877';
        newAccount.Work_Phone__c = '456789';
        newAccount.Mobile1__c = '1234566';
        newAccount.Mobile2_Other__c = '1245787';
        newAccount.party_id__c = '206084041';
        newAccount.Type = 'Broker Council';
        newAccount.Auto_Renewal__c = True;
        newAccount.Territories__c = 'test';
        newAccount.Associated_Agent_Account__c = newAccount2.id;
        newAccount.Associated_Broker_Account__c = newAccount.id;   
        newAccount.Zoura_Account_id__c ='Test';
        //newAccount.RecordTypeId = b2bRecordTypeId; 
        newAccount.Agent_Broker__c =true;
        lstAccounts.add(newAccount); 
        insert lstAccounts; 
        
        Map<id,Account> acctmap = new Map<id,Account>();
        acctmap.put(newAccount.id,newAccount2);
        
        Contact myContact = new Contact ();
        myContact.FirstName ='Joe';
        myContact.LastName ='Schmoe';
        myContact.Email ='Joe.Schmoe@test.de';
        myContact.Account = newAccount;
        myContact.MailingStreet = newAccount.BillingStreet;
        myContact.MailingState = newAccount.BillingState;
        myContact.MailingCity = newAccount.BillingCity;
        myContact.MailingPostalCode = newAccount.BillingPostalCode;
        myContact.MailingCountry = newAccount.BillingCountry;
        myContact.Phone=newAccount.Phone;
        myContact.Type__c = 'Other';
        myContact.Active__c = true;
        insert myContact;
                        
        EntityFields__c entry = new EntityFields__c(Entity_Name__c = 'Test' , Name = 'Phone',Zuoura_Sync__c = true);                
        insert entry; 
       
        AccountTriggerHandlerManager ATHM = new AccountTriggerHandlerManager();
        List<Account_Relationship__c> lstAccRltn = new List<Account_Relationship__c>();
        Account_Relationship__c primarycntct = new Account_Relationship__c();
        primarycntct.Child_Account__c = newAccount2.id;
        primarycntct.Contact_To__c = myContact.id;
        primarycntct.Contact_Role__c = 'Primary Contact';
        primarycntct.Entity_Name__c = 'BillToAddress';
        primarycntct.Is_Parent_Primary__c = true;
        primarycntct.Parent_Account__c = lstAccounts[0].id;
        primarycntct.Active__c = true;
        primarycntct.Relationship_Type__c = 'Member';
        primarycntct.Zuora_Bill_to_Contact_ID__c = 'test';
        primarycntct.Zuora_Ship_to_Contact_ID__c = 'testing';
        primarycntct.Zuora_Sync__c = true;
        primarycntct.Billing_Contact__c =true;
        primarycntct.RecordTypeId=contactRelationshipRecordTypeId;
        lstAccRltn.add(primarycntct);
        insert lstAccRltn; 
            
        Map<id,String> acctmaptype = new Map<id,String>();
        acctmaptype.put(newAccount2.id,entry.Entity_Name__c);
        
        Map<id,Account> acctmapnew = new Map<id,Account>();
        acctmapnew.put(newAccount2.id,newAccount2 );        
        AccountTriggerHandlerManager.firstentity = false;       
        AccountTriggerHandlerManager.preventityName ='Testing';
        ATHM.webserviceCallout(lstAccounts,acctmap);
        ATHM.getAssociatedAccounts(null,acctmapnew,acctmapold,false);
     
    }
        
    public static testMethod void main4(){
        DisabledTrigger__c Dtrg = new DisabledTrigger__c();
        Dtrg.Name = 'Disabled';
        Dtrg.TaskTrigger__c = 'Test@test.com';
        Dtrg.AssetTrigger__c = 'Test@test.com';
        insert Dtrg;
        Switch_AccountRelationshipTrigger__c arc = new Switch_AccountRelationshipTrigger__c(Name ='Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
        insert arc; 
        Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;  
        List<Account> lstAccounts = new List<Account>();   
                
        id b2cRecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('B2C').RecordTypeId;
            
        Account  newAccount2 = new Account();
        newAccount2.name='XYZ';
        newAccount2.Phone = '+49-12346';
        newAccount2.BillingStreet = '2537343 ROUTE 52 STE 10 # 10';
        newAccount2.BillingCity = 'HOPE JUNCTION';
        newAccount2.BillingPostalCode = '12533';
        newAccount2.BillingState = 'NY';
        newAccount2.BillingCountry = 'USA';
        newAccount2.Primary_Email__c= 'ra1@gmail.com';
        newAccount2.Home_Phone__c= '96763322877';
        newAccount2.Work_Phone__c = '426789';
        newAccount2.Mobile1__c = '3234511';
        newAccount2.Mobile2_Other__c = '1245787';
        newAccount2.party_id__c = '206084041';
        newAccount2.Type = 'Broker';
        newAccount2.Auto_Renewal__c = True;
        newAccount2.Territories__c = 'test';
        newAccount2.Associated_Agent_Account__c = newAccount2.id;
        newAccount2.Associated_Broker_Account__c = newAccount2.id; 
        newAccount2.Zoura_Account_id__c ='Test';   
        //lstAccounts.add(newAccount); 
        insert newAccount2;
        newAccount2.name='XYZ';
        newAccount2.Mobile1__c = '1134511';
        update newAccount2;
        
        Account  newAccount = new Account();
        //newAccount.RecordTypeId = b2cRecordTypeId; 
        newAccount.name='XYZ';
        newAccount.Phone = '+49-12345';
        newAccount.BillingStreet = '2537 ROUTE 52 STE 10 # 10';
        newAccount.BillingCity = 'HOPEWELL JUNCTION';
        newAccount.BillingPostalCode = '12533';
        newAccount.BillingState = 'NY';
        newAccount.BillingCountry = 'USA';
        newAccount.Primary_Email__c= 'ra@gmail.com';
        newAccount.Home_Phone__c= '967622877';
        newAccount.Work_Phone__c = '456789';
        newAccount.Mobile1__c = '1234566';
        newAccount.Mobile2_Other__c = '1245787';
        newAccount.party_id__c = '206084041';
        newAccount.Type = 'Broker Council';
        newAccount.Auto_Renewal__c = True;
        newAccount.Territories__c = 'test';
        newAccount.Associated_Agent_Account__c = newAccount2.id;
        newAccount.Associated_Broker_Account__c = newAccount.id;   
        newAccount.Zoura_Account_id__c ='Test';
        newAccount.Agent_Broker__c =true;
        lstAccounts.add(newAccount); 
        insert lstAccounts; 
                        
        Map<id,Account> acctmap = new Map<id,Account>();
        acctmap.put(newAccount2.id,newAccount2);
        
        Map<id,Account> acctmapnew = new Map<id,Account>();
        acctmap.put(newAccount2.id,newAccount2 );      
        
        AccountTriggerHandlerManager ATHM = new AccountTriggerHandlerManager();
        ATHM.getAssociatedAccounts(lstAccounts,acctmapnew,acctmap,true); 
            
    }
        
    public static testMethod void main5(){
        DisabledTrigger__c Dtrg = new DisabledTrigger__c();
        Dtrg.Name = 'Disabled';
        Dtrg.TaskTrigger__c = 'Test@test.com';
        Dtrg.AssetTrigger__c = 'Test@test.com';
        insert Dtrg;
        Switch_AccountRelationshipTrigger__c arc = new Switch_AccountRelationshipTrigger__c(Name ='Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
        insert arc;
        Set<Id> bmqSetId = new Set<Id>();
        
        MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
        Account newAccount = mtduc.CreateBrokerAccountSingle();
        Product2 newProduct = mtduc.CreateProductSingle();
        newProduct.EssentialsRequired__c = True;
        update newProduct;
        mtduc.CreatePricebookEntrySingle();       
        Opportunity theOpportunity = mtduc.CreateOppurtunitySingle();
        mtduc.CreateOpportunityProductSingle();
        
        BigMachines__Quote__c OracleQuote = new BigMachines__Quote__c();
        OracleQuote.BigMachines_authorization_status__c = 'Success';
        OracleQuote.BigMachines_authorization_amount__c = 10.00;
        OracleQuote.BigMachines_first_month_payment__c = 30.00;
        OracleQuote.BigMachines__Account__c = newAccount.id;
        OracleQuote.BigMachines__Opportunity__c = theOpportunity.id;
        OracleQuote.BigMachines__Is_Primary__c = true;
        OracleQuote.BigMachines_Quote_Type__c = 'New';
        OracleQuote.BigMachines__Status__c = 'In Progress';
        OracleQuote.tigerLeadProductExists__c = true;
        insert OracleQuote;
        
        BigMachines__Quote_Product__c QuoteProduct = new BigMachines__Quote_Product__c();
        QuoteProduct.BigMachines__Quote__c = OracleQuote.id;
        QuoteProduct.BigMachines__Sales_Price__c = 10.00;
        QuoteProduct.BigMachines__Quantity__c = 10;
        QuoteProduct.Need_Manual_Renew__c = false;
        QuoteProduct.BigMachines__Description__c = 'test';
        QuoteProduct.BigMachines__Product__c = newProduct.id;
        QuoteProduct.Line_Type__c = 'Add';
        QuoteProduct.Market_Tier__c = '100';
        QuoteProduct.Commerce_Group__c = 'test';
        insert QuoteProduct;
        bmqSetId.add(OracleQuote.Id);
        
        AccountTriggerHandlerManager ATHM = new AccountTriggerHandlerManager();
        ATHM.accountActivateEssentialStatus(bmqSetId);    
      
    }
    
     public static testMethod void test6(){
       
        Profile p = [select id from profile where name='Standard User'];
        User u = new User(alias = 'standt', email='standarduser@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
        localesidkey='en_US', profileid = p.Id,
        timezonesidkey='America/New_York', username='standarduser@test.com');    
   
        DisabledTrigger__c Dtrg = new DisabledTrigger__c();
        Dtrg.Name = 'Disabled';
        Dtrg.TaskTrigger__c = 'Test@test.com';
        Dtrg.AssetTrigger__c = 'Test@test.com';
        insert Dtrg;
        Switch_AccountRelationshipTrigger__c arc = new Switch_AccountRelationshipTrigger__c(Name ='Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
        insert arc; 
        Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;  
        List<Account> lstAccounts = new List<Account>();   
        id b2bRecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('B2B').RecordTypeId;
        
        Account  newAccount2 = new Account();
        newAccount2.name='XYZ';
        newAccount2.Phone = '+49-12346';
        newAccount2.BillingStreet = '2537343 ROUTE 52 STE 10 # 10';
        newAccount2.BillingCity = 'HOPE JUNCTION';
        newAccount2.BillingPostalCode = '12533';
        newAccount2.BillingState = 'NY';
        newAccount2.BillingCountry = 'USA';
        newAccount2.Primary_Email__c= 'ra1@gmail.com';
        newAccount2.Home_Phone__c= '96763322877';
        newAccount2.Work_Phone__c = '426789';
        newAccount2.Mobile1__c = '3234511';
        newAccount2.Mobile2_Other__c = '1245787';
        newAccount2.party_id__c = '206084041';
        newAccount2.Type = 'Broker';
        newAccount2.Auto_Renewal__c = True;
        newAccount2.Territories__c = 'test';
       // newAccount2.Associated_Agent_Account__c = newAccount2.id;
      //  newAccount2.Associated_Broker_Account__c = newAccount2.id;
        newAccount2.Resend_Welcome_Email__c =false;
        newAccount2.EssentialsStatus__c = 'Inactive';
        newAccount2.Basic_Optout__c = 'Activate';
        newAccount2.Zoura_Account_id__c ='Test';   
        //lstAccounts.add(newAccount); 
        insert newAccount2;
        newAccount2.name='XYZ';
        newAccount2.Mobile1__c = '1134511';
        update newAccount2;
        
        Account  newAccount = new Account();
        newAccount.name='XYZ';
        newAccount.Phone = '+49-12345';
        newAccount.BillingStreet = '2537 ROUTE 52 STE 10 # 10';
        newAccount.BillingCity = 'HOPEWELL JUNCTION';
        newAccount.BillingPostalCode = '12533';
        newAccount.BillingState = 'NY';
        newAccount.BillingCountry = 'USA';
        newAccount.Primary_Email__c= 'ra@gmail.com';
        newAccount.Home_Phone__c= '967622877';
        newAccount.Work_Phone__c = '456789';
        newAccount.Mobile1__c = '1234566';
        newAccount.Mobile2_Other__c = '1245787';
        newAccount.party_id__c = '206084041';
        newAccount.Type = 'Broker Council';
        newAccount.Auto_Renewal__c = True;
        newAccount.Territories__c = 'test';
        newAccount.Associated_Agent_Account__c = newAccount2.id;
        newAccount.Associated_Broker_Account__c = newAccount.id;   
        newAccount.Zoura_Account_id__c ='Test';
        newAccount.RecordTypeId = b2bRecordTypeId;
        newAccount.EssentialsStatus__c = 'Inactive';
        newAccount.Agent_Broker__c =true;
        lstAccounts.add(newAccount); 
        insert lstAccounts; 
                    
        Contact myContact = new Contact ();
        myContact.FirstName ='Joe';
        myContact.LastName ='Schmoe';
        myContact.Email ='Joe.Schmoe@test.de';
        myContact.Account = newAccount;
        myContact.MailingStreet = newAccount.BillingStreet;
        myContact.MailingState = newAccount.BillingState;
        myContact.MailingCity = newAccount.BillingCity;
        myContact.MailingPostalCode = newAccount.BillingPostalCode;
        myContact.MailingCountry = newAccount.BillingCountry;
        myContact.Phone=newAccount.Phone;
        myContact.Type__c = 'Other';
        myContact.Active__c = true;
        insert myContact;
         
        List<Account> acctlist= new List<Account>();
        acctlist.add(newAccount);
        Map<id,Account> acctmap = new Map<id,Account>();
        acctmap.put(newAccount.id,newAccount);
                 
        EntityFields__c entry = new EntityFields__c(Entity_Name__c = 'XYZ' , Name = 'Phone',Zuoura_Sync__c = true);                
        insert entry; 
       
        AccountTriggerHandlerManager ATHM = new AccountTriggerHandlerManager();
        List<Account_Relationship__c> lstAccRltn = new List<Account_Relationship__c>();
        Account_Relationship__c primarycntct = new Account_Relationship__c();
        primarycntct.Child_Account__c = newAccount2.id;
        primarycntct.Contact_To__c = myContact.id;
        primarycntct.Contact_Role__c = 'Primary Contact';
        primarycntct.Entity_Name__c = 'BillToAddress';
        primarycntct.Is_Parent_Primary__c = true;
        primarycntct.Parent_Account__c = lstAccounts[0].id;
        primarycntct.Active__c = true;
        primarycntct.Relationship_Type__c = 'Member';
        primarycntct.Zuora_Bill_to_Contact_ID__c = 'test';
        primarycntct.Zuora_Ship_to_Contact_ID__c = 'testing';
        primarycntct.Zuora_Sync__c = true;
        primarycntct.Billing_Contact__c =true;
        primarycntct.RecordTypeId=contactRelationshipRecordTypeId;
        lstAccRltn.add(primarycntct);
        insert lstAccRltn; 
            
        Map<id,String> acctmaptype = new Map<id,String>();
        acctmaptype.put(newAccount2.id,entry.Entity_Name__c);
        
        Map<id,Account> acctmapnew = new Map<id,Account>();
        Map<id,Account> accountMapold = new Map<id,Account>();
        accountMapold.put(newAccount.id,newAccount);
        acctmap.put(newAccount.id,newAccount2 );
        ATHM.webserviceCallout(lstAccounts,acctmap);
        AccountTriggerHandlerManager.firstentity = true;
        AccountTriggerHandlerManager.sendOutboundMessageNow(acctmaptype);
        AccountTriggerHandlerManager.sendOutboundMessageInFuture(acctmaptype);
        ATHM.populateAssociatedFields(acctmapnew,acctmap);
        ATHM.getAssociatedAccounts(acctlist,acctmapnew,acctmap,true);
        ATHM.getRecordTypeIdForAccount();
        ATHM.onAccountTerritorychange(acctmapnew,acctmap);
        ATHM.AccountAssetAutoRenewal(acctmapnew,acctmap);
        ATHM.SalesLockValidate(acctmapnew,acctmap);
        newAccount.Account_Sub_Type__c = 'Customer';
        newAccount.Auto_Renewal__c = False;
        update newAccount;
        acctmap.put(newAccount.id,newAccount);
        ATHM.AccountAssetAutoRenewal(acctmap,accountMapold);
        newAccount.Auto_Renewal__c = True;
        update newAccount;
        acctmap.put(newAccount.id,newAccount);
        ATHM.AccountAssetAutoRenewal(acctmap,accountMapold);   
         
    }
     public static testMethod void test7(){
       
        Profile p = [select id from profile where name='Standard User'];
        User u = new User(alias = 'standt', email='standarduser@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
        localesidkey='en_US', profileid = p.Id,
        timezonesidkey='America/New_York', username='standarduser@test.com');    
   
        DisabledTrigger__c Dtrg = new DisabledTrigger__c();
        Dtrg.Name = 'Disabled';
        Dtrg.TaskTrigger__c = 'Test@test.com';
        Dtrg.AssetTrigger__c = 'Test@test.com';
        insert Dtrg;
        Switch_AccountRelationshipTrigger__c arc = new Switch_AccountRelationshipTrigger__c(Name ='Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
        insert arc; 
        Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;  
        List<Account> lstAccounts = new List<Account>();   
        id b2bRecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('B2B').RecordTypeId;
        
        Account  newAccount2 = new Account();
        newAccount2.name='XYZ';
        newAccount2.Phone = '+49-12346';
        newAccount2.BillingStreet = '2537343 ROUTE 52 STE 10 # 10';
        newAccount2.BillingCity = 'HOPE JUNCTION';
        newAccount2.BillingPostalCode = '12533';
        newAccount2.BillingState = 'NY';
        newAccount2.BillingCountry = 'USA';
        newAccount2.Primary_Email__c= 'ra1@gmail.com';
        newAccount2.Home_Phone__c= '96763322877';
        newAccount2.Work_Phone__c = '426789';
        newAccount2.Mobile1__c = '3234511';
        newAccount2.Mobile2_Other__c = '1245787';
        newAccount2.party_id__c = '206084041';
        newAccount2.Type = 'Broker';
        newAccount2.Auto_Renewal__c = True;
        newAccount2.Territories__c = 'test';
        newAccount2.EssentialsStatus__c = 'Activated';
       // newAccount2.Associated_Agent_Account__c = newAccount2.id;
      //  newAccount2.Associated_Broker_Account__c = newAccount2.id; 
        newAccount2.Zoura_Account_id__c ='Test';   
        //lstAccounts.add(newAccount); 
        insert newAccount2;
        newAccount2.name='XYZ';
        newAccount2.Mobile1__c = '1134511';             
        update newAccount2;
        
        Account  newAccount = new Account();
        newAccount.name='XYZ';
        newAccount.Phone = '+49-12345';
        newAccount.BillingStreet = '2537 ROUTE 52 STE 10 # 10';
        newAccount.BillingCity = 'HOPEWELL JUNCTION';
        newAccount.BillingPostalCode = '12533';
        newAccount.BillingState = 'NY';
        newAccount.BillingCountry = 'USA';
        newAccount.Primary_Email__c= 'ra@gmail.com';
        newAccount.Home_Phone__c= '967622877';
        newAccount.Work_Phone__c = '456789';
        newAccount.Mobile1__c = '1234566';
        newAccount.Mobile2_Other__c = '1245787';
        newAccount.party_id__c = '206084041';
        newAccount.Type = 'Broker Council';
        newAccount.Auto_Renewal__c = True;
        newAccount.Territories__c = 'test';
        newAccount.Associated_Agent_Account__c = newAccount2.id;
        newAccount.Associated_Broker_Account__c = newAccount.id;   
        newAccount.Zoura_Account_id__c ='Test';
        newAccount.RecordTypeId = b2bRecordTypeId; 
        newAccount.Agent_Broker__c =true;
        newAccount.Resend_Welcome_Email__c =true;
        newAccount.EssentialsStatus__c = 'Activated';
        lstAccounts.add(newAccount); 
        insert lstAccounts; 
                    
        Contact myContact = new Contact ();
        myContact.FirstName ='Joe';
        myContact.LastName ='Schmoe';
        myContact.Email ='Joe.Schmoe@test.de';
        myContact.Account = newAccount;
        myContact.MailingStreet = newAccount.BillingStreet;
        myContact.MailingState = newAccount.BillingState;
        myContact.MailingCity = newAccount.BillingCity;
        myContact.MailingPostalCode = newAccount.BillingPostalCode;
        myContact.MailingCountry = newAccount.BillingCountry;
        myContact.Phone=newAccount.Phone;
        myContact.Type__c = 'Other';
        myContact.Active__c = true;
        insert myContact;
        
        Map<id,string> acctmap = new Map<id,string>();
        acctmap.put(newAccount.id,'206084041');
        AccountTriggerHandlerManager.sendOutboundMessageInFuture(acctmap);
        AccountTriggerHandlerManager.sendOutboundMsgInFuture(acctmap.values());
        
        Map<String,string> partyIdAndTypeMap= new Map<String,string>();
        partyIdAndTypeMap.put('206084041', 'Broker');
        AccountTriggerHandlerManager.sendOutboundMessageInFutureDelete(partyIdAndTypeMap);
        Map<id,id> mapAccountid = new Map<id,id>();
        mapAccountid.put(newAccount.id, UserInfo.getUserId());
        AccountTriggerHandlerManager.AccountAssetOwnerUpdate(mapAccountid);
        
    }
    
 }