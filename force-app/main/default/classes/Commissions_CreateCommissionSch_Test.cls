/****************************************************************
    Author : Bala
    Description: Test class for Commissions_CreateCommissionSchClass Schedulable class
****************************************************************/

@isTest
global class Commissions_CreateCommissionSch_Test{
    Static TestMethod void ScheduleMethod(){
       
        Profile p = [select id from profile where name='System Administrator'];
       
        User user1 = Commissions_TestDataFactory.createUser(null,p.id,null,'test154@move.com','test154@move.com',false,'WLV Territory Team');
        user1.Vacation_Start_Date__c = Date.today();
        user1.Vacation_End_Date__c = Date.today();
        user1.managers__c = 'First Name';
        insert user1;        
        
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg; 

        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        Account Acc = Commissions_TestDataFactory.createAccount('Name','theAcc@move.com',rectypidaccount,type,true); 
        
        Period__c period = Commissions_TestDataFactory.Createperiod('Test',false,Date.today().toStartOfMonth());
        period.Start_Date__c = date.today();
        //Integer Year = Date.Today().Year(); 
        insert period;
        
        Contract c =new Contract();
        c.Accountid=Acc.id;       
        insert c; 
        
        Quota__c  QuotaHandler = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler.Target_Amount__c = 1000;
        QuotaHandler.User_Team__c = user1.team__c;
        QuotaHandler.Period_Name__c = period.id;          
        insert QuotaHandler;       
        
        Product2 prdctdata = Commissions_TestDataFactory.CreateProduct('Name',false);
        prdctdata.Commission_Category__c = 'CFCB';
        insert prdctdata; 
        Id pricebookId= Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prdctdata.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
            
        Pricebook2 custompb = new Pricebook2(Name = 'Standard Price Book 2009', Description = 'Price Book 2009 Products', IsActive = true);
        insert custompb;
           
        PricebookEntry custompbe = new PricebookEntry(Pricebook2Id = custompb.Id, Product2Id = prdctdata.Id, UnitPrice = 1, IsActive = true);
        insert custompbe;
          
        set<Id> ProductIds = new set<id>();
        ProductIds.add(prdctdata.id);
            
        Order r =new Order();       
        r.AccountId=Acc.id;
        r.Name='test';
        r.EffectiveDate=System.today();
        r.Contractid=c.id;
        r.Status='Created';
        r.Pricebook2Id = pricebookId;
        r.OwnerId = user1.id;
        insert r;
            
        OrderItem oi = new OrderItem(OrderId=r.id,Quantity=1,PricebookEntryId=standardPrice.id,unitPrice=1);
        insert oi;
            
        set<Id> orderOwnerIds = new set<id>();
        orderOwnerIds.add(user1.id);
        
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get('WLV Territory Team').getRecordTypeId(); 
        Payout__c pa= Commissions_TestDataFactory.CreatePayout('Component 1',rectypidp, 10.00, 50.00,null,null,2.25,1.05,2.02,3.00,false);
        pa.Period__c = period.Id;
        insert pa;
        
        id rectypidasset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();    
        String status = Constants.ACTIVE_STATUS;
        string fullfilled = Constants.FULFILLMENT_STATUS;
        String type1 = Constants.ASSET_TYPE;
        Asset assets = Commissions_TestDataFactory.CreateAsset(rectypidasset,user1.Id,prdctdata.Id,false);
        assets.RecordTypeId = rectypidasset;
        assets.Name = 'test';
        assets.Ownerid=user1.id;
        assets.Renewal_Status__c = 'Renew';
        assets.Auto_Renewal__c = 'No';
        assets.Asset_Type__c = type1;
        assets.Product2Id = prdctdata.id;
        assets.Fulfillment_Status__c = fullfilled;
        assets.Status = status;
        assets.At_Risk__c = false;
        assets.Billing_Period__c = 'Monthly';
        assets.Start_Date__c = system.today();
        assets.End_Date__c = system.today().addDays(10);
        assets.Asset_Type__c = 'Parent';
        assets.Auto_Renewal__c  = 'Yes';
        assets.Line_Type__c = 'renew';
        assets.Price = 10.00;
        assets.Sign_in_AE__c= user1.id;
        assets.Commission_field__c='Calculate';
        assets.Total_Net__c = 1200.00;
        assets.Delta_Price__c = 120.00;
        assets.Order_Line_Item__c = oi.id;
        insert assets;
        update assets;
        
        Test.StartTest();
        Commissions_CreateCommissionSchClass sh1 = new Commissions_CreateCommissionSchClass();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);        
        String SCHEDULE_NAME = 'test'; 
        id cronid = System.schedule(SCHEDULE_NAME, '0 15 0-23 * * ?', new CleanupCronTriggers());            
        System.abortJob(cronid);
        Test.stopTest();
    }
}