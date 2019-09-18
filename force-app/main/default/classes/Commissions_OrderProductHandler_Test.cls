@isTest(seeAllData = false)
public class Commissions_OrderProductHandler_Test {
   public static testMethod void mainTest() {
        Profile p = [select id from profile where name='System Administrator'];       
        String WLVTerritory = Commissions_Constants.WLV_TERRITORY_TEAM  ;
        String ManagerTeam  = Commissions_Constants.MANAGERS_TEAM;
        String RDTeam = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM ;  
        
        User user1 = Commissions_TestDataFactory.createUser(null,p.id,null,'test1541@move.com','test15421@move.com',false,WLVTerritory);
        //user1.Vacation_Start_Date__c = Date.today().adddays(-5);
        //user1.Vacation_End_Date__c = Date.today().adddays(10);
        //user1.managers__c = user2.Id;
        user1.managers__c = 'Heather Riggio';
        user1.FirstName = 'FName';
        User1.Team__c = WLVTerritory;
        insert User1;
                
        User user2 = Commissions_TestDataFactory.createUser(null,p.id,null,'test15432@move.com','test15432@move.com',true,RDTeam);
        user2.Managers__c = 'Heather Riggio';
        //user2.Vacation_Start_Date__c = Date.today().adddays(-5);
       // user2.Vacation_End_Date__c = Date.today().adddays(10);
        update user2;
        
        User user3 = Commissions_TestDataFactory.createUser(null,p.id,null,'test15411@move.com','test154212@move.com',true,ManagerTeam);
        User3.LastName ='Riggio';
        User3.FirstName='Heather ';
        update User3;        
        
        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;        
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        Account newAccount = Commissions_TestDataFactory.createAccount('Name','theAcc@move.com',rectypidaccount,type,false);
        newAccount.OwnerId = user2.id;
        insert newAccount;  
         
        Contract c =new Contract();
        c.Accountid=newAccount.id;
        c.OwnerId = User1.id;
        insert c; 
        
        Period__c period = Commissions_TestDataFactory.Createperiod('Test',True,Date.today());
        
        Quota__c  QuotaHandler1 = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler1.Target_Amount__c = 1000;  
        QuotaHandler1.Is_Kicker__c = True; 
        QuotaHandler1.User_team__c = WLVTerritory;  
        QuotaHandler1.Current_Quater__c = 'Q1';   
        insert QuotaHandler1;
        
        Quota__c  QuotaHandler2 = Commissions_TestDataFactory.CreateQuota(user2.id,period.id,false);
        QuotaHandler2.Target_Amount__c = 1000;  
        QuotaHandler2.Is_Kicker__c = True; 
        QuotaHandler2.User_team__c = RDTeam;  
        QuotaHandler2.Current_Quater__c = 'Q1';   
        insert QuotaHandler2;
            
        Quota__c  QuotaHandler3 = Commissions_TestDataFactory.CreateQuota(user3.id,period.id,false);
        QuotaHandler3.Target_Amount__c = 1000;  
        QuotaHandler3.Is_Kicker__c = True; 
        QuotaHandler3.User_team__c = ManagerTeam;     
        insert QuotaHandler3;  
            
        Id pricebookId = Test.getStandardPricebookId();                         
        system.debug('pricebookId '+pricebookId);
        
        Product2 prod = Commissions_TestDataFactory.CreateProduct('Test Product',true);
            
        PricebookEntry pet=new PricebookEntry(UnitPrice = 10.00,Product2Id=prod.id,Pricebook2Id=pricebookId,isActive=true);
        insert pet;
            
        Order o = new Order(name='Test1',AccountId=newAccount.id,EffectiveDate=system.today(),status='Created', PriceBook2Id=pricebookId,ContractId = c.id,ownerId = user1.id);
        
        insert o; 

        OrderItem oi = new OrderItem(OrderId= o.id,Quantity=1,PricebookEntryId=pet.id, unitPrice=10.00);
        oi.Total_Net__c = 100;
        //try{
        insert oi;
        //}catch(Exception e){}
              
        Map<Id, OrderItem> newTriggerValues = new Map<Id, OrderItem>();
        newTriggerValues.put(oi.id,oi);
        
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get('Broker Regional Directors Sales Team').getRecordTypeId(); 
        Payout__c pa= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp, null, null,10.00,100.00,2.25,1.05,2.02,3.00,false);
        pa.Period__c = period.id;
        insert pa;
             
        id rectypidq = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('New Sale').getRecordTypeId();  
        Commission__c  commission1 = Commissions_TestDataFactory.CreateComm(QuotaHandler1.Id, prod.Id,rectypidq,null,false);
        commission1.Order_Product__c = oi.Id;
        commission1.Signing_AE__c = user1.id;       
        commission1.Commissionable_Amount2__c = 100;
        commission1.OpenBook_New_Sale_Comm_ble_Amount__c = 100;
        commission1.Payout_rate__c = 10.00;
        commission1.Payout_Rate1B__c = 10.00;
        commission1.Order_Product__c = oi.id;
        insert commission1;
        
        Commission__c  commission2 = Commissions_TestDataFactory.CreateComm(QuotaHandler2.Id, prod.Id,rectypidq,null,false);
        commission2.Order_Product__c = oi.Id;
        commission2.Signing_AE__c = user2.id;       
        commission2.Commissionable_Amount2__c = 100;
        commission2.OpenBook_New_Sale_Comm_ble_Amount__c = 100;
        commission2.Payout_rate__c = 10.00;
        commission2.Payout_Rate1B__c = 10.00;
        commission2.Order_Product__c = oi.id;
        insert commission2;
        
        Commission__c  commission3 = Commissions_TestDataFactory.CreateComm(QuotaHandler3.Id, prod.Id,rectypidq,null,false);
        commission3.Order_Product__c = oi.Id;
        commission3.Signing_AE__c = user3.id;       
        commission3.Commissionable_Amount2__c = 100;
        commission3.OpenBook_New_Sale_Comm_ble_Amount__c = 100;
        commission3.Payout_rate__c = 10.00;
        commission3.Payout_Rate1B__c = 10.00;
        commission3.Order_Product__c = oi.id;
        insert commission3;
              
        Commissions_OrderProductHandler co = new Commissions_OrderProductHandler();
        co.CreateCommissions(newTriggerValues);
        co.UpdateCommissions(newTriggerValues);            
    }
    public static testMethod void mainTest2() {
        Profile p = [select id from profile where name='System Administrator'];
        Profile p1 = [select id from profile where name='Open Book Profile'];       
        String WLVTerritory = Commissions_Constants.WLV_TERRITORY_TEAM  ;
        String ManagerTeam  = Commissions_Constants.MANAGERS_TEAM;
        String RDTeam = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM ;  
        
        User user1 = Commissions_TestDataFactory.createUser(null,p1.id,null,'test1541@move.com','test15421@move.com',false,WLVTerritory);
        //user1.Vacation_Start_Date__c = Date.today().adddays(-5);
        //user1.Vacation_End_Date__c = Date.today().adddays(10);
        //user1.managers__c = user2.Id;
        user1.managers__c = 'Heather Riggio';
        user1.FirstName = 'FName';
        User1.Team__c = WLVTerritory;
        insert User1;
                
        User user2 = Commissions_TestDataFactory.createUser(null,p.id,null,'test15432@move.com','test15432@move.com',true,RDTeam);
        user2.Managers__c = 'Heather Riggio';
        //user2.Vacation_Start_Date__c = Date.today().adddays(-5);
        //user2.Vacation_End_Date__c = Date.today().adddays(10);
        update user2;
        
        User user3 = Commissions_TestDataFactory.createUser(null,p.id,null,'test15411@move.com','test154212@move.com',true,ManagerTeam);
        User3.LastName ='Riggio';
        User3.FirstName='Heather ';
        update User3;        
        
        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;        
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        Account newAccount = Commissions_TestDataFactory.createAccount('Name','theAcc@move.com',rectypidaccount,type,false);
        newAccount.OwnerId = user1.id;
        insert newAccount;  
         
        Contract c =new Contract();
        c.Accountid=newAccount.id;
        c.OwnerId = User1.id;
        insert c; 
        
        Period__c period = Commissions_TestDataFactory.Createperiod('Test',True,Date.today());
        
        Quota__c  QuotaHandler1 = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler1.Target_Amount__c = 1000;  
        QuotaHandler1.Is_Kicker__c = True; 
        QuotaHandler1.User_team__c = WLVTerritory;  
        QuotaHandler1.Current_Quater__c = 'Q1';   
        insert QuotaHandler1;
        
        Quota__c  QuotaHandler2 = Commissions_TestDataFactory.CreateQuota(user2.id,period.id,false);
        QuotaHandler2.Target_Amount__c = 1000;  
        QuotaHandler2.Is_Kicker__c = True; 
        QuotaHandler2.User_team__c = RDTeam;  
        QuotaHandler2.Current_Quater__c = 'Q1';   
        insert QuotaHandler2;
            
        Quota__c  QuotaHandler3 = Commissions_TestDataFactory.CreateQuota(user3.id,period.id,false);
        QuotaHandler3.Target_Amount__c = 1000;  
        QuotaHandler3.Is_Kicker__c = True; 
        QuotaHandler3.User_team__c = ManagerTeam;     
        insert QuotaHandler3;  
            
        Id pricebookId = Test.getStandardPricebookId();                         
        system.debug('pricebookId '+pricebookId);
        
        Product2 prod = Commissions_TestDataFactory.CreateProduct('Test Product',true);
            
        PricebookEntry pet=new PricebookEntry(UnitPrice = 10.00,Product2Id=prod.id,Pricebook2Id=pricebookId,isActive=true);
        insert pet;
            
        Order o = new Order(name='Test1',AccountId=newAccount.id,EffectiveDate=system.today(),status='Created', PriceBook2Id=pricebookId,ContractId = c.id,ownerId = user1.id);
        
        insert o; 

        OrderItem oi = new OrderItem(OrderId= o.id,Quantity=1,PricebookEntryId=pet.id, unitPrice=10.00);
        oi.Total_Net__c = 100;
        insert oi;
              
        Map<Id, OrderItem> newTriggerValues = new Map<Id, OrderItem>();
        newTriggerValues.put(oi.id,oi);
        
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get('Broker Regional Directors Sales Team').getRecordTypeId(); 
        Payout__c pa= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp, null, null,10.00,100.00,2.25,1.05,2.02,3.00,false);
        pa.Period__c = period.id;
        insert pa;
             
        id rectypidq = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('New Sale').getRecordTypeId();  
        Commission__c  commission1 = Commissions_TestDataFactory.CreateComm(QuotaHandler1.Id, prod.Id,rectypidq,null,false);
        commission1.Order_Product__c = oi.Id;
        commission1.Signing_AE__c = user1.id;       
        commission1.Commissionable_Amount2__c = 100;
        commission1.OpenBook_New_Sale_Comm_ble_Amount__c = 100;
        commission1.Payout_rate__c = 10.00;
        commission1.Payout_Rate1B__c = 10.00;
        commission1.Order_Product__c = oi.id;
        insert commission1;
        
        Commission__c  commission2 = Commissions_TestDataFactory.CreateComm(QuotaHandler2.Id, prod.Id,rectypidq,null,false);
        commission2.Order_Product__c = oi.Id;
        commission2.Signing_AE__c = user2.id;       
        commission2.Commissionable_Amount2__c = 100;
        commission2.OpenBook_New_Sale_Comm_ble_Amount__c = 100;
        commission2.Payout_rate__c = 10.00;
        commission2.Payout_Rate1B__c = 10.00;
        commission2.Order_Product__c = oi.id;
        insert commission2;
        
        Commission__c  commission3 = Commissions_TestDataFactory.CreateComm(QuotaHandler3.Id, prod.Id,rectypidq,null,false);
        commission3.Order_Product__c = oi.Id;
        commission3.Signing_AE__c = user3.id;       
        commission3.Commissionable_Amount2__c = 100;
        commission3.OpenBook_New_Sale_Comm_ble_Amount__c = 100;
        commission3.Payout_rate__c = 10.00;
        commission3.Payout_Rate1B__c = 10.00;
        commission3.Order_Product__c = oi.id;
        insert commission3;
              
        Commissions_OrderProductHandler co = new Commissions_OrderProductHandler();
        co.CreateCommissions(newTriggerValues);
        co.UpdateCommissions(newTriggerValues);            
    }
    public static testMethod void mainTest3() {
        Profile p = [select id from profile where name='System Administrator'];       
        String WLVTerritory = Commissions_Constants.WLV_TERRITORY_TEAM  ;
        String ManagerTeam  = Commissions_Constants.MANAGERS_TEAM;
        String RDTeam = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM ;  
        
        User user1 = Commissions_TestDataFactory.createUser(null,p.id,null,'test1541@move.com','test15421@move.com',false,WLVTerritory);
        user1.Vacation_Start_Date__c = Date.today().adddays(-5);
        user1.Vacation_End_Date__c = Date.today().adddays(10);
        //user1.managers__c = user2.Id;
        user1.managers__c = 'Heather Riggio';
        user1.FirstName = 'FName';
        User1.Team__c = WLVTerritory;
        insert User1;
                
        User user2 = Commissions_TestDataFactory.createUser(null,p.id,null,'test15432@move.com','test15432@move.com',true,RDTeam);
        user2.Managers__c = 'Heather Riggio';
        user2.Vacation_Start_Date__c = Date.today().adddays(-5);
        user2.Vacation_End_Date__c = Date.today().adddays(10);
        update user2;
        
        User user3 = Commissions_TestDataFactory.createUser(null,p.id,null,'test15411@move.com','test154212@move.com',true,ManagerTeam);
        User3.LastName ='Riggio';
        User3.FirstName='Heather ';
        user3.Vacation_Start_Date__c = Date.today().adddays(-5);
        user3.Vacation_End_Date__c = Date.today().adddays(10);
        update User3;        
        
        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;        
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        Account newAccount = Commissions_TestDataFactory.createAccount('Name','theAcc@move.com',rectypidaccount,type,false);
        newAccount.OwnerId = user2.id;
        insert newAccount;  
         
        Contract c =new Contract();
        c.Accountid=newAccount.id;
        c.OwnerId = User1.id;
        insert c; 
        
        Period__c period = Commissions_TestDataFactory.Createperiod('Test',True,Date.today());
        
        Quota__c  QuotaHandler1 = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler1.Target_Amount__c = 1000;  
        QuotaHandler1.Is_Kicker__c = True; 
        QuotaHandler1.User_team__c = WLVTerritory;  
        QuotaHandler1.Current_Quater__c = 'Q1';   
        insert QuotaHandler1;
        
        Quota__c  QuotaHandler2 = Commissions_TestDataFactory.CreateQuota(user2.id,period.id,false);
        QuotaHandler2.Target_Amount__c = 1000;  
        QuotaHandler2.Is_Kicker__c = True; 
        QuotaHandler2.User_team__c = RDTeam;  
        QuotaHandler2.Current_Quater__c = 'Q1';   
        insert QuotaHandler2;
            
        Quota__c  QuotaHandler3 = Commissions_TestDataFactory.CreateQuota(user3.id,period.id,false);
        QuotaHandler3.Target_Amount__c = 1000;  
        QuotaHandler3.Is_Kicker__c = True; 
        QuotaHandler3.User_team__c = ManagerTeam;     
        insert QuotaHandler3;  
            
        Id pricebookId = Test.getStandardPricebookId();                         
        system.debug('pricebookId '+pricebookId);
        
        Product2 prod = Commissions_TestDataFactory.CreateProduct('Test Product',true);
            
        PricebookEntry pet=new PricebookEntry(UnitPrice = 10.00,Product2Id=prod.id,Pricebook2Id=pricebookId,isActive=true);
        insert pet;
            
        Order o = new Order(name='Test1',AccountId=newAccount.id,EffectiveDate=system.today(),status='Created', PriceBook2Id=pricebookId,ContractId = c.id,ownerId = user1.id);
        
        insert o; 

        OrderItem oi = new OrderItem(OrderId= o.id,Quantity=1,PricebookEntryId=pet.id, unitPrice=10.00);
        oi.Total_Net__c = 100;
        insert oi;
              
        Map<Id, OrderItem> newTriggerValues = new Map<Id, OrderItem>();
        newTriggerValues.put(oi.id,oi);
        
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get('Broker Regional Directors Sales Team').getRecordTypeId(); 
        Payout__c pa= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp, null, null,10.00,100.00,2.25,1.05,2.02,3.00,false);
        pa.Period__c = period.id;
        insert pa;
             
        id rectypidq = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('New Sale').getRecordTypeId();  
        Commission__c  commission1 = Commissions_TestDataFactory.CreateComm(QuotaHandler1.Id, prod.Id,rectypidq,null,false);
        commission1.Order_Product__c = oi.Id;
        commission1.Signing_AE__c = user1.id;       
        commission1.Commissionable_Amount2__c = 100;
        commission1.OpenBook_New_Sale_Comm_ble_Amount__c = 100;
        commission1.Payout_rate__c = 10.00;
        commission1.Payout_Rate1B__c = 10.00;
        commission1.Order_Product__c = oi.id;
        insert commission1;
        
        Commission__c  commission2 = Commissions_TestDataFactory.CreateComm(QuotaHandler2.Id, prod.Id,rectypidq,null,false);
        commission2.Order_Product__c = oi.Id;
        commission2.Signing_AE__c = user2.id;       
        commission2.Commissionable_Amount2__c = 100;
        commission2.OpenBook_New_Sale_Comm_ble_Amount__c = 100;
        commission2.Payout_rate__c = 10.00;
        commission2.Payout_Rate1B__c = 10.00;
        commission2.Order_Product__c = oi.id;
        insert commission2;
        
        Commission__c  commission3 = Commissions_TestDataFactory.CreateComm(QuotaHandler3.Id, prod.Id,rectypidq,null,false);
        commission3.Order_Product__c = oi.Id;
        commission3.Signing_AE__c = user3.id;       
        commission3.Commissionable_Amount2__c = 100;
        commission3.OpenBook_New_Sale_Comm_ble_Amount__c = 100;
        commission3.Payout_rate__c = 10.00;
        commission3.Payout_Rate1B__c = 10.00;
        commission3.Order_Product__c = oi.id;
        insert commission3;
              
        Commissions_OrderProductHandler co = new Commissions_OrderProductHandler();
        co.CreateCommissions(newTriggerValues);
        co.UpdateCommissions(newTriggerValues);            
    }
}