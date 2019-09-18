@isTest(seeAllData = false)
public class Commissions_CreateCollectionComms_Test {
    public static testMethod void mainTest1() {
          
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(alias = 'standt', email='standarduser@testorg.com',
                            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                            localesidkey='en_US', profileid = p.Id,timezonesidkey='America/New_York', 
                            username='standarduser444@test.com',Payout_Rate_Month_1__c=1,Payout_Rate_Month_2__c=2,Payout_Rate_Month_3__c=3,Team__c='WLV Territory Team');
        insert u;
        
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg; 

        
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        
        Account newAccount = new Account();
        newAccount.RecordTypeId = rectypidaccount;
        newAccount.name = 'XYZ';
        newAccount.Phone = '1234567890';
        newAccount.BillingStreet = 'Am Tierpark 16';
        newAccount.BillingCity = 'Cologne';
        newAccount.BillingPostalCode = '54321';
        newAccount.BillingState = 'Nordrhein-Westfalen';
        newAccount.BillingCountry = 'Germany';
        newAccount.Primary_Email__c = 'ra@gmail.com';
        newAccount.Home_Phone__c = '1234567890';
        newAccount.Work_Phone__c = '1234567890';
        newAccount.Mobile1__c = '1234567890';
        newAccount.Mobile2_Other__c = '1245787';
        newAccount.party_id__c = '206084041';
        newAccount.Ownerid=u.id;
        insert newAccount;
        system.debug('Account ownerid1111'+newAccount.Ownerid);
        
        Period__c pe= new Period__c();
        pe.Name='test';
        pe.Start_Date__c = Date.today().toStartOfMonth();
        insert pe;
        
        
        Quota__c  QuotaHandler = new Quota__c();
        QuotaHandler.Target_Amount__c = 10;
        QuotaHandler.User__c = u.id;
        QuotaHandler.TP_Units_Sold__c=6;
        QuotaHandler.Is_Kicker__c = true;
        QuotaHandler.Period_Name__c=pe.id;      
        
        insert QuotaHandler;

        Payment_History__c ph= new Payment_History__c();
        ph.Name='test';
        ph.Bill_To_Account__c= newAccount.id;
        ph.Transaction_Amount__c = 100;
        ph.CreatedByid= u.id;
        insert ph;
        system.debug('Payment_HistoryCreatedByid1111'+ph.CreatedByid);
        
        Payment_History__c ph1= new Payment_History__c();
        ph1.Name='test1';
        ph1.Bill_To_Account__c= newAccount.id;
        ph1.Transaction_Amount__c = 100;
        ph1.CreatedByid= u.id;
        insert ph1;
        
        Map<Id,Payment_History__c> newMap = new Map<Id,Payment_History__c>();
        newMap.put(ph.id,ph);
        
        
        Map<Id,Payment_History__c> oldMap = new  Map<Id,Payment_History__c>();
        oldMap.put(ph1.id,ph1);
        
        
        
        id rectypidq = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('New Sale').getRecordTypeId();  
        
        Commission__c  commission1 = new Commission__c();
        commission1.RecordTypeId = rectypidq;
        commission1.Related_to_Quota__c = QuotaHandler.id;
        //commission1.Product__c = prdctdata.id;
        commission1.Other_Product__c ='Top Producer';
        commission1.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c=3.0;
        commission1.CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c=4.0;
        commission1.Payment_History__c=ph.id;
        commission1.Commissionable_Amount2__c=5.0;              
        commission1.Commissionable_Amount3__c=6.0;      
        commission1.Is_Manager_Commission__c = true;
        insert commission1;
        
        set<Id> accountIds = new set<Id>();
        accountIds.add(ph.Bill_To_Account__c);
        set<Id> accountOwnerIds = new set<Id>();
        accountOwnerIds.add(newAccount.Ownerid);
        set<Id> OwnerIds = new set<Id>();
        OwnerIds.add(ph.CreatedByid);
        Set<Id> paymentQuotaUserIds = new Set<Id>();
        paymentQuotaUserIds.add(QuotaHandler.User__c);
        
        Set<Id> accountQuotaUserIds = new Set<Id>();
        accountQuotaUserIds.add(QuotaHandler.User__c);
        
        Commissions_CreateCollectionCommsClass co = new Commissions_CreateCollectionCommsClass();
        Test.startTest();
        // co.CreateCommissions(newMap,oldMap);
        Test.stopTest();
    }
    
    public static testMethod void mainTest2() {
          
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(alias = 'standt', email='standarduser@testorg.com',
                            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                            localesidkey='en_US', profileid = p.Id,timezonesidkey='America/New_York', 
                            username='standarduser445@test.com',Payout_Rate_Month_1__c=1,Payout_Rate_Month_2__c=2,Payout_Rate_Month_3__c=3,Team__c='WLV Territory Team');
        insert u;
        
        User u1 = new User(alias = 'standt', email='standarduser@testorg.com',
                            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                            localesidkey='en_US', profileid = p.Id,timezonesidkey='America/New_York', 
                            username='standarduser6@test.com',Payout_Rate_Month_1__c=1,Payout_Rate_Month_2__c=2,Payout_Rate_Month_3__c=3,Team__c='WLV Territory Team');
        insert u1;
        
        
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg; 

        
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        
        Account newAccount = new Account();
        newAccount.RecordTypeId = rectypidaccount;
        newAccount.name = 'XYZ';
        newAccount.Phone = '1234567890';
        newAccount.BillingStreet = 'Am Tierpark 16';
        newAccount.BillingCity = 'Cologne';
        newAccount.BillingPostalCode = '54321';
        newAccount.BillingState = 'Nordrhein-Westfalen';
        newAccount.BillingCountry = 'Germany';
        newAccount.Primary_Email__c = 'ra@gmail.com';
        newAccount.Home_Phone__c = '1234567890';
        newAccount.Work_Phone__c = '1234567890';
        newAccount.Mobile1__c = '1234567890';
        newAccount.Mobile2_Other__c = '1245787';
        newAccount.party_id__c = '206084041';
        newAccount.Ownerid=u1.id;
        insert newAccount;
        system.debug('Account ownerid2222222'+newAccount.Ownerid);
        
        Period__c pe= new Period__c();
        pe.Name='test';
        pe.Sigh_In_AE__c = 10;
        pe.Start_Date__c = Date.today().toStartOfMonth();
        insert pe;
        
        
        Quota__c  QuotaHandler = new Quota__c();
        QuotaHandler.Target_Amount__c = 10;
        QuotaHandler.User__c = u1.id;
        QuotaHandler.TP_Units_Sold__c=6;
        QuotaHandler.Is_Kicker__c = true;
        QuotaHandler.Period_Name__c=pe.id;      
        
        insert QuotaHandler;
        
        Quota__c  QuotaHandler1 = new Quota__c();
        QuotaHandler1.Target_Amount__c = 10;
        QuotaHandler1.User__c = u.id;
        QuotaHandler1.TP_Units_Sold__c=6;
        QuotaHandler1.Is_Kicker__c = true;
        QuotaHandler1.Period_Name__c=pe.id;      
        
        insert QuotaHandler1;

        Payment_History__c ph= new Payment_History__c();
        ph.Name='test';
        ph.Transaction_Amount__c = 100;
        ph.Bill_To_Account__c= newAccount.id;
        ph.CreatedByid= u.id;
        ph.ownerid=u.id;
        insert ph;
        system.debug('Payment_HistoryCreatedByid222222222'+ph.CreatedByid);
        
        Payment_History__c ph1= new Payment_History__c();
        ph1.Name='test1';
        ph1.Transaction_Amount__c = 100;
        ph1.Bill_To_Account__c= newAccount.id;
        ph1.CreatedByid= u.id;
        insert ph1;
        
        Map<Id,Payment_History__c> newMap = new Map<Id,Payment_History__c>();
        newMap.put(ph.id,ph);
        
        
        Map<Id,Payment_History__c> oldMap = new  Map<Id,Payment_History__c>();
        oldMap.put(ph1.id,ph1);
        
        id rectypidq = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('New Sale').getRecordTypeId();  
        
        Commission__c  commission1 = new Commission__c();
        commission1.RecordTypeId = rectypidq;
        commission1.Related_to_Quota__c = QuotaHandler.id;
        //commission1.Product__c = prdctdata.id;
        commission1.Other_Product__c ='Top Producer';
        commission1.Payment_History__c=ph.id;
        commission1.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c=3.0;
        commission1.CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c=4.0;
        commission1.Commissionable_Amount2__c=5.0;             
        commission1.Commissionable_Amount3__c=6.0;      
        commission1.Is_Manager_Commission__c = true;
        insert commission1;
        
        set<Id> accountIds = new set<Id>();
        accountIds.add(ph.Bill_To_Account__c);
        set<Id> accountOwnerIds = new set<Id>();
        accountOwnerIds.add(newAccount.Ownerid);
        set<Id> OwnerIds = new set<Id>();
        OwnerIds.add(ph.CreatedByid);
        Set<Id> paymentQuotaUserIds = new Set<Id>();
        paymentQuotaUserIds.add(QuotaHandler.User__c);
        
        Set<Id> accountQuotaUserIds = new Set<Id>();
        accountQuotaUserIds.add(QuotaHandler.User__c);
        
        Commissions_CreateCollectionCommsClass co = new Commissions_CreateCollectionCommsClass();
        Test.startTest();
    //     co.CreateCommissions(newMap,oldMap);
        Test.stopTest();
    }
}