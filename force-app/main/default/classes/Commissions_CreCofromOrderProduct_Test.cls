@isTest(seeAllData = false)
public class Commissions_CreCofromOrderProduct_Test {

private static Boolean IsUpdate;
    public static testMethod void mainTest1() {
        Profile p = [select id from profile where name='System Administrator'];
       //String RDteam = Commissions_Constants.NEW_HIRE_TEAM;
        User u = Commissions_TestDataFactory.createUser(null,p.id,null,'test154@move.com','test154@move.com',true,'New Hire Team');
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
         insert Dtrg;
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        Account newAccount = Commissions_TestDataFactory.createAccount('Name','theAcc@move.com',rectypidaccount,type,false);
        newAccount.ownerId = u.id;
        insert newAccount;
        
         Zuora__CustomerAccount__c cAccount = new Zuora__CustomerAccount__c();
        cAccount.Name = 'TestAccount';
        cAccount.Zuora__Account__c= newAccount.Id;
        cAccount.Zuora__Zuora_Id__c = '2c92c0f94c750685014c78c1967e660a';
      insert cAccount; 
      system.debug('cAccount:' + cAccount.Id);
            
        Contract c =new Contract();
        c.Accountid=newAccount.id;
        //c.Status='Draft';
        insert c; 
            
        Id pricebookId = Test.getStandardPricebookId();                         
        system.debug('pricebookId '+pricebookId);
        
        Product2 prod = Commissions_TestDataFactory.CreateProduct('Name',false);
        prod.Commission_Category__c = 'CFCB';
       
        insert prod;
        
        PricebookEntry pet=new PricebookEntry(UnitPrice = 10.00,Product2Id=prod.id,Pricebook2Id=pricebookId,isActive=true);
        insert pet;
        system.debug('pet'+pet.id);
        
        Order o = new Order(name='Test1',AccountId=newAccount.id,EffectiveDate=system.today(),status='Created', PriceBook2Id=pricebookId,ContractId = c.id);
        insert o;
        system.debug('order'+o.id);               
        
        OrderItem oi = new OrderItem(OrderId= o.id,Quantity=1,PricebookEntryId=pet.id, unitPrice=10.00);
        insert oi;
        system.debug('*******OrderItem'+ oi.id);       
        
        Period__c pe = Commissions_TestDataFactory.Createperiod('Test',True,Date.today().toStartOfMonth());
            
        Quota__c  QuotaHandler = Commissions_TestDataFactory.CreateQuota(u.id,pe.id,false);
        QuotaHandler.Target_Amount__c = 1000.00;
        
         QuotaHandler.Target_Amount_2__c = 1000.00;
        QuotaHandler.user_Team__c = 'New Hire Team';
        insert QuotaHandler;
         
        //Payment_History__c ph= Commissions_TestDataFactory.CreatePaymentHistory('Name',u.id,newAccount.id,true);
        //ph.CreatedByid= User1.Id;

        Set<Id> orderQuotaUserIds = new Set<Id>();
        orderQuotaUserIds.add(QuotaHandler.User__c);
        
        Set<String> OrderManagers =  new Set<String>(); 
        OrderManagers.add('standarduser4test.com');
        
        id rectypidasset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();    
        Asset assets = new Asset();
        assets.RecordTypeId = rectypidasset;
        assets.Name = 'test';
        assets.Ownerid=u.id;
        assets.Renewal_Status__c = 'Renew';
        assets.Auto_Renewal__c = 'No';
        assets.Asset_Type__c = 'Constants.ASSET_TYPE';
        assets.Product2Id = prod.id;
        assets.Fulfillment_Status__c = 'Constants.FULFILLMENT_STATUS';
        assets.Status = 'Constants.ACTIVE_STATUS';
        assets.At_Risk__c = false;
        assets.Billing_Period__c = 'Monthly';
        assets.Start_Date__c = system.today();
        assets.End_Date__c = system.today().addDays(10);
        assets.Asset_Type__c = 'Parent';
        assets.Auto_Renewal__c  = 'Yes';
        assets.Line_Type__c = 'renew';
        assets.Price = 10.00;
        assets.Sign_in_AE__c=u.id;
        assets.Order_Line_Item__c = oi.Id;
        insert assets;
        
         Zuora__Payment__c Zp = Commissions_TestDataFactory.CreateZuoraPayment('Test',cAccount.id,'12456',Date.today(),200,true);

                Map<id,Zuora__Payment__c> newMap1 = new Map<id,Zuora__Payment__c>();
                newMap1.Put(Zp.id,Zp); 
        
        id rectypidq = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('New Sale').getRecordTypeId();  
        Commission__c  commission1 = Commissions_TestDataFactory.CreateComm(QuotaHandler.Id, prod.Id,rectypidq,null,false);
        commission1.Order_Product__c = oi.Id;
        commission1.Related_to_Asset__c = assets.id;
        commission1.Signing_AE__c = u.id;
        //commission1.Payout_Rate_3__c = 20.00;
        commission1.Commissionable_Amount3__c = 100;
        commission1.OpenBook_New_Sale_Comm_ble_Amount__c =0.0 ;
        commission1.Payout_rate__c = 10.00;
        commission1.Payout_Rate1B__c = 10.00;
        commission1.Payment__c = zp.id;       
        
        insert commission1;
        
        set<id> allCommissionIds= new set<id>();
        allCommissionIds.add(commission1.id);
        
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get('WLV Territory Team').getRecordTypeId(); 
        Payout__c pa= Commissions_TestDataFactory.CreatePayout('Component 1',rectypidp, 10.00,10.00,Null,Null,2.25,1.05,2.02,3.00,false);
        pa.Period__c = pe.id;
        insert pa;
        
        Test.startTest();
        Commissions_CreateCommsfromOrderProduct.OnIsinsert(allCommissionIds);
        Test.stopTest();
        
  }
  
  public static testMethod void mainTest11() {
        Profile p = [select id from profile where name='System Administrator'];
       //String RDteam = Commissions_Constants.NEW_HIRE_TEAM;
        User u = Commissions_TestDataFactory.createUser(null,p.id,null,'test154@move.com','test154@move.com',true,'WLV Territory Team');
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
         insert Dtrg;
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        Account newAccount = Commissions_TestDataFactory.createAccount('Name','theAcc@move.com',rectypidaccount,type,false);
        newAccount.ownerId = u.id;
        insert newAccount;
        
         Zuora__CustomerAccount__c cAccount = new Zuora__CustomerAccount__c();
        cAccount.Name = 'TestAccount';
        cAccount.Zuora__Account__c= newAccount.Id;
        cAccount.Zuora__Zuora_Id__c = '2c92c0f94c750685014c78c1967e660a';
      insert cAccount; 
      system.debug('cAccount:' + cAccount.Id);
            
        Contract c =new Contract();
        c.Accountid=newAccount.id;
        //c.Status='Draft';
        insert c; 
            
        Id pricebookId = Test.getStandardPricebookId();                         
        system.debug('pricebookId '+pricebookId);
        
        Product2 prod = Commissions_TestDataFactory.CreateProduct('Name',false);
        prod.Commission_Category__c = 'CFCB';
       
        insert prod;
        
        PricebookEntry pet=new PricebookEntry(UnitPrice = 10.00,Product2Id=prod.id,Pricebook2Id=pricebookId,isActive=true);
        insert pet;
        system.debug('pet'+pet.id);
        
        Order o = new Order(name='Test1',AccountId=newAccount.id,EffectiveDate=system.today(),status='Created', PriceBook2Id=pricebookId,ContractId = c.id);
        insert o;
        system.debug('order'+o.id);               
        
        OrderItem oi = new OrderItem(OrderId= o.id,Quantity=1,PricebookEntryId=pet.id, unitPrice=10.00);
        insert oi;
        system.debug('*******OrderItem'+ oi.id);       
        
        Period__c pe = Commissions_TestDataFactory.Createperiod('Test',True,Date.today().toStartOfMonth());
            
        Quota__c  QuotaHandler = Commissions_TestDataFactory.CreateQuota(u.id,pe.id,false);
        QuotaHandler.Target_Amount__c = 1000.00;
        
        QuotaHandler.Target_Amount_2__c = 1000.00;
        QuotaHandler.user_Team__c = 'WLV Territory Team';
        insert QuotaHandler;
         
        //Payment_History__c ph= Commissions_TestDataFactory.CreatePaymentHistory('Name',u.id,newAccount.id,true);
        //ph.CreatedByid= User1.Id;

        Set<Id> orderQuotaUserIds = new Set<Id>();
        orderQuotaUserIds.add(QuotaHandler.User__c);
        
        Set<String> OrderManagers =  new Set<String>(); 
        OrderManagers.add('standarduser4test.com');
        
        id rectypidasset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();    
        Asset assets = new Asset();
        assets.RecordTypeId = rectypidasset;
        assets.Name = 'test';
        assets.Ownerid=u.id;
        assets.Renewal_Status__c = 'Renew';
        assets.Auto_Renewal__c = 'No';
        assets.Asset_Type__c = 'Constants.ASSET_TYPE';
        assets.Product2Id = prod.id;
        assets.Fulfillment_Status__c = 'Constants.FULFILLMENT_STATUS';
        assets.Status = 'Constants.ACTIVE_STATUS';
        assets.At_Risk__c = false;
        assets.Billing_Period__c = 'Monthly';
        assets.Start_Date__c = system.today();
        assets.End_Date__c = system.today().addDays(10);
        assets.Asset_Type__c = 'Parent';
        assets.Auto_Renewal__c  = 'Yes';
        assets.Line_Type__c = 'renew';
        assets.Price = 10.00;
        assets.Sign_in_AE__c=u.id;
        assets.Order_Line_Item__c = oi.Id;
        insert assets;
        
         Zuora__Payment__c Zp = Commissions_TestDataFactory.CreateZuoraPayment('Test',cAccount.id,'12456',Date.today(),200,true);

                Map<id,Zuora__Payment__c> newMap1 = new Map<id,Zuora__Payment__c>();
                newMap1.Put(Zp.id,Zp); 
        
        id rectypidq = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('New Sale').getRecordTypeId();  
        Commission__c  commission1 = Commissions_TestDataFactory.CreateComm(QuotaHandler.Id, prod.Id,rectypidq,null,false);
        commission1.Order_Product__c = oi.Id;
        commission1.Related_to_Asset__c = assets.id;
        commission1.Signing_AE__c = u.id;
        //commission1.Payout_Rate_3__c = 20.00;
        commission1.Commissionable_Amount3__c = 100;
        commission1.OpenBook_New_Sale_Comm_ble_Amount__c =0.0 ;
        commission1.Payout_rate__c = 10.00;
        commission1.Payout_Rate1B__c = 10.00;
        commission1.Payment__c = zp.id;       
        commission1.User_Team__C = 'WLV Territory Team';
        insert commission1;
        
        set<id> allCommissionIds= new set<id>();
        allCommissionIds.add(commission1.id);
        
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get('WLV Territory Team').getRecordTypeId(); 
        Payout__c pa= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp, 10.00,10.00,Null,Null,2.25,1.05,2.02,3.00,false);
        pa.Period__c = pe.id;
        insert pa;
        
        Test.startTest();
        Commissions_CreateCommsfromOrderProduct.OnIsinsert(allCommissionIds);
        Test.stopTest();
        
  }
  public static testMethod void mainTest2() {
        Profile p = [select id from profile where name='System Administrator'];
        String RDteam = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM;
        //String RDteam = Commissions_Constants.COLLECTION_TEAM;
        User u = Commissions_TestDataFactory.createUser(null,p.id,null,'test154@move.com','test154@move.com',true,RDteam);
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
         insert Dtrg;        
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        Account newAccount = Commissions_TestDataFactory.createAccount('Name','theAcc@move.com',rectypidaccount,type,true);
            
        Contract c =new Contract();
        c.Accountid=newAccount.id;
        //c.Status='Draft';
        insert c; 
            
        Id pricebookId = Test.getStandardPricebookId();                         
        system.debug('pricebookId '+pricebookId);
        
        Product2 prod = Commissions_TestDataFactory.CreateProduct('Name',false);
        prod.Commission_Category__c = 'Tiger';
        insert prod;
        
        PricebookEntry pet=new PricebookEntry(UnitPrice = 10.00,Product2Id=prod.id,Pricebook2Id=pricebookId,isActive=true);
        insert pet;
        system.debug('pet'+pet.id);
        
        Order o = new Order(name='Test1',AccountId=newAccount.id,EffectiveDate=system.today(),status='Created', PriceBook2Id=pricebookId,ContractId = c.id);
        insert o;
        system.debug('order'+o.id);               
        
        OrderItem oi = new OrderItem(OrderId= o.id,Quantity=1,PricebookEntryId=pet.id, unitPrice=10.00);
        insert oi;
        system.debug('*******OrderItem'+ oi.id);       
        
        Period__c pe = Commissions_TestDataFactory.Createperiod('Test',True,Date.today().toStartOfMonth());
            
        Quota__c  QuotaHandler = Commissions_TestDataFactory.CreateQuota(u.id,pe.id,false);
        QuotaHandler.Target_Amount__c = 1000.00;
       
         QuotaHandler.Target_Amount_2__c = 1000.00;
         QuotaHandler.user_Team__c = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM;
         //QuotaHandler.Collection_Total_Sale__c = 50.00;
        insert QuotaHandler;
         
        //Payment_History__c ph= Commissions_TestDataFactory.CreatePaymentHistory('Name',u.id,newAccount.id,true);
        //ph.CreatedByid= User1.Id;

        Set<Id> orderQuotaUserIds = new Set<Id>();
        orderQuotaUserIds.add(QuotaHandler.User__c);
        
        Set<String> OrderManagers =  new Set<String>(); 
        OrderManagers.add('standarduser4test.com');
        
        id rectypidasset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();    
        Asset assets = new Asset();
        assets.RecordTypeId = rectypidasset;
        assets.Name = 'test';
        assets.Ownerid=u.id;
        assets.Renewal_Status__c = 'Renew';
        assets.Auto_Renewal__c = 'No';
        assets.Asset_Type__c = 'Constants.ASSET_TYPE';
        assets.Product2Id = prod.id;
        assets.Fulfillment_Status__c = 'Constants.FULFILLMENT_STATUS';
        assets.Status = 'Constants.ACTIVE_STATUS';
        assets.At_Risk__c = false;
        assets.Billing_Period__c = 'Monthly';
        assets.Start_Date__c = system.today();
        assets.End_Date__c = system.today().addDays(10);
        assets.Asset_Type__c = 'Parent';
        assets.Auto_Renewal__c  = 'Yes';
        assets.Line_Type__c = 'renew';
        assets.Price = 10.00;
        assets.Sign_in_AE__c=u.id;
        assets.Order_Line_Item__c = oi.Id;
        insert assets;
        
        Zuora__CustomerAccount__c cAccount = new Zuora__CustomerAccount__c();
        cAccount.Name = 'TestAccount';
        cAccount.Zuora__Account__c= newAccount.Id;
        cAccount.Zuora__Zuora_Id__c = '2c92c0f94c750685014c78c1967e660a';
      insert cAccount; 
      system.debug('cAccount:' + cAccount.Id);
         Zuora__Payment__c Zp = Commissions_TestDataFactory.CreateZuoraPayment('Test',cAccount.id,'12456',Date.today(),200,true);

                Map<id,Zuora__Payment__c> newMap1 = new Map<id,Zuora__Payment__c>();
                newMap1.Put(Zp.id,Zp); 
        
        id rectypidq = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('New Sale').getRecordTypeId();  
        Commission__c  commission1 = Commissions_TestDataFactory.CreateComm(QuotaHandler.Id, prod.Id,rectypidq,null,false);
        commission1.Order_Product__c = oi.Id;
        commission1.Related_to_Asset__c = assets.id;
        commission1.Signing_AE__c = u.id;        
        commission1.OpenBook_New_Sale_Comm_ble_Amount__c = 10.00;
        commission1.Payout_rate__c = 10.00;
        commission1.Payout_Rate1B__c = 10.00;
        commission1.TIGER_Commissionable_Amount4A__c = 100;
         commission1.Payment__c = zp.id;       
        insert commission1;
        
         
        Commission__c  commission11 = Commissions_TestDataFactory.CreateComm(QuotaHandler.Id, prod.Id,rectypidq,null,false);
        commission11.Order_Product__c = oi.Id;
        commission11.Related_to_Asset__c = assets.id;
        commission11.Signing_AE__c = u.id;        
        commission11.OpenBook_New_Sale_Comm_ble_Amount__c = 0.0;
        commission11.Payout_rate__c = 10.00;
        commission11.Payout_Rate1B__c = 10.00;
        commission11.Commissionable_Amount2__c = 0.0;
         commission11.Payment__c = zp.id;       
        insert commission11;
        
      
        set<id> allCommissionIds= new set<id>();
        allCommissionIds.add(commission1.id);
        allCommissionIds.add(commission11.id);
         
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get('Broker Regional Directors Sales Team').getRecordTypeId(); 
        Payout__c pa= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp, null, null,10.00,100.00,2.25,1.05,2.02,3.00,false);
        pa.Period__c = pe.id;
        insert pa;
        
        Payout__c pa1= Commissions_TestDataFactory.CreatePayout('Asset Owner Component',rectypidp, null, null,10.00,100.00,2.25,1.05,2.02,3.00,false);
        pa1.Period__c = pe.id;
        insert pa1;
        
        Test.startTest();
        Commissions_CreateCommsfromOrderProduct.OnIsinsert(allCommissionIds);
        Test.stopTest();
        
  }
  
    public static testMethod void mainTest3() {
        Profile p = [select id from profile where name='System Administrator'];
        User u = Commissions_TestDataFactory.createUser(null,p.id,null,'test154@move.com','test154@move.com',true,'Managers Team');
        u.LastName ='Riggio';
        u.FirstName='Heather';
        update u;
         String RDTeam = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM ;  
        User user1 = Commissions_TestDataFactory.createUser(null,p.id,null,'test1542@move.com','test1542@move.com',true,RDTeam);
        user1.Managers__c = 'Heather Riggio';
        update User1;
       // User u1 = [Select id from user where name = 'HEATHER RIGGIO' limit 1];
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
         insert Dtrg;        
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        Account newAccount = Commissions_TestDataFactory.createAccount('Name','theAcc@move.com',rectypidaccount,type,true);
            
        Contract c =new Contract();
        c.Accountid=newAccount.id;
        //c.Status='Draft';
        insert c; 
            
        Id pricebookId = Test.getStandardPricebookId();                         
        system.debug('pricebookId '+pricebookId);
        
        Product2 prod = Commissions_TestDataFactory.CreateProduct('Name',false);
        prod.Commission_Category__c = 'Tiger';
        insert prod;
        
        PricebookEntry pet=new PricebookEntry(UnitPrice = 10.00,Product2Id=prod.id,Pricebook2Id=pricebookId,isActive=true);
        insert pet;
        system.debug('pet'+pet.id);
        
        Order o = new Order(name='Test1',AccountId=newAccount.id,EffectiveDate=system.today(),status='Created', PriceBook2Id=pricebookId,ContractId = c.id);
        insert o;
        system.debug('order'+o.id);               
        
        OrderItem oi = new OrderItem(OrderId= o.id,Quantity=1,PricebookEntryId=pet.id, unitPrice=10.00);
        insert oi;
        system.debug('*******OrderItem'+ oi.id);       
        
        Period__c pe = Commissions_TestDataFactory.Createperiod('Test',True,Date.today().toStartOfMonth());
            
        Quota__c  QuotaHandler = Commissions_TestDataFactory.CreateQuota(u.id,pe.id,false);
        QuotaHandler.Target_Amount__c = 1000.00;
        QuotaHandler.User_Team__c = 'Managers Team';
        insert QuotaHandler;
       
         Quota__c  QuotaHandler1 = Commissions_TestDataFactory.CreateQuota(user1.id,pe.id,false);
        QuotaHandler1.Target_Amount__c = 1000.00;
        QuotaHandler1.User_Team__c = RDTeam ;
        insert QuotaHandler1; 
        //Payment_History__c ph= Commissions_TestDataFactory.CreatePaymentHistory('Name',u.id,newAccount.id,true);
        //ph.CreatedByid= User1.Id;

        Set<Id> orderQuotaUserIds = new Set<Id>();
        orderQuotaUserIds.add(QuotaHandler.User__c);
        
        Set<String> OrderManagers =  new Set<String>(); 
        OrderManagers.add('standarduser4test.com');
        
        id rectypidasset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();    
        Asset assets = new Asset();
        assets.RecordTypeId = rectypidasset;
        assets.Name = 'test';
        assets.Ownerid=u.id;
        assets.Renewal_Status__c = 'Renew';
        assets.Auto_Renewal__c = 'No';
        assets.Asset_Type__c = 'Constants.ASSET_TYPE';
        assets.Product2Id = prod.id;
        assets.Fulfillment_Status__c = 'Constants.FULFILLMENT_STATUS';
        assets.Status = 'Constants.ACTIVE_STATUS';
        assets.At_Risk__c = false;
        assets.Billing_Period__c = 'Monthly';
        assets.Start_Date__c = system.today();
        assets.End_Date__c = system.today().addDays(10);
        assets.Asset_Type__c = 'Parent';
        assets.Auto_Renewal__c  = 'Yes';
        assets.Line_Type__c = 'renew';
        assets.Price = 10.00;
        assets.Sign_in_AE__c=u.id;
        assets.Order_Line_Item__c = oi.Id;
        insert assets;
        
        Zuora__CustomerAccount__c cAccount = new Zuora__CustomerAccount__c();
        cAccount.Name = 'TestAccount';
        cAccount.Zuora__Account__c= newAccount.Id;
        cAccount.Zuora__Zuora_Id__c = '2c92c0f94c750685014c78c1967e660a';
      insert cAccount; 
      system.debug('cAccount:' + cAccount.Id);
         Zuora__Payment__c Zp = Commissions_TestDataFactory.CreateZuoraPayment('Test',cAccount.id,'12456',Date.today(),200,true);

                Map<id,Zuora__Payment__c> newMap1 = new Map<id,Zuora__Payment__c>();
                newMap1.Put(Zp.id,Zp); 
        
        id rectypidq = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('New Sale').getRecordTypeId();  
        Commission__c  commission1 = Commissions_TestDataFactory.CreateComm(QuotaHandler.Id, prod.Id,rectypidq,null,false);
        commission1.Order_Product__c = oi.Id;
        commission1.Related_to_Asset__c = assets.id;
        commission1.Signing_AE__c = u.id;
         commission1.Payment__c = zp.id;
        
        insert commission1;
        
        set<id> allCommissionIds= new set<id>();
        allCommissionIds.add(commission1.id);
        
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get('Heather Riggio').getRecordTypeId(); 
        Payout__c pa= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp, null, null,10.00,100.00,2.25,1.05,2.02,3.00,false);
        pa.Period__c = pe.id;
        insert pa;
        
        id rectypidqcb = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Clawback').getRecordTypeId(); 
        Commission__c  comm12 = Commissions_TestDataFactory.CreateComm(QuotaHandler1.Id, prod.Id,rectypidqcb,null,false);
        comm12.Related_to_Asset__c = assets.Id;
        comm12.Asset_Amount__c = 100;
        comm12.user_team__c = RDTeam;
        comm12.Commissionable_Amount2__c = 90;
        comm12.Payout_Rate1B__c = 1.0;
        comm12.Commissionable_Amount1B__c = 90;
        comm12.Related_Commission__c = commission1.id; 
        comm12.Payout_Rate_3__c =10;         
        comm12.Payout_rate__c = 10;
        comm12.Payout_rate1B__c = 10; 
        comm12.OpenBook_New_Sale_Comm_ble_Amount__c = 10;
        comm12.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c = 10;
        comm12.CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c = 10;  
        insert comm12;
        
        Test.startTest();
        Commissions_CreateCommsfromOrderProduct.OnIsinsert(allCommissionIds);
        Test.stopTest();
        
    }
   
  }