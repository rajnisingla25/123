@isTest(seeAllData = false)
public class Commissions_CreateCltnCommsCls_Test {
    public static testMethod void mainTest1() {
        String CollectionTeam = Commissions_Constants.COLLECTION_TEAM;
        String ManagerTeam  = Commissions_Constants.MANAGERS_TEAM;
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        
        Profile p = [select id from profile where name='System Administrator'];
       
        User user2 = Commissions_TestDataFactory.createUser(null,p.id,null,'testcltrep@move.com','testcltrep@move.com',true,ManagerTeam);
        User2.LastName ='MATTHEWS';
        User2.FirstName='ADRIAN ';
        //User2.Username = 'testcltrep@move.com';
        update User2;
        
        User user1 = Commissions_TestDataFactory.createUser(null,p.id,null,'testcltrep1@move.com','testcltrep1@move.com',true,CollectionTeam);
        user1.Managers__c = 'ADRIAN MATTHEWS';
        update User1;
               
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg; 
         CommissionTeams__c cmt = new CommissionTeams__c(Name= 'MANAGERS_TEAM' , Team_Name__c = 'Managers Team');
        insert cmt; 
        CommissionTeams__c cmt1 = new CommissionTeams__c(Name= 'COLLECTION_TEAM' , Team_Name__c = 'Collections Team');
        insert cmt1;  
        CommissionTeams__c cmt2 = new CommissionTeams__c(Name= 'COLLECTIONS_CLIENT_RELATIONS_MANAGERS' , Team_Name__c = 'Collections Client Relations Manager');
        insert cmt2;  
        CommissionTeams__c cmt3 = new CommissionTeams__c(Name= 'BROKER_REGIONAL_DIRECTORS_TEAM' , Team_Name__c = 'Broker Regional Directors Sales Team');
        insert cmt3;  
        CommissionTeams__c cmt4 = new CommissionTeams__c(Name= 'CLIENT_RELATIONS_MANAGERS' , Team_Name__c = 'Client Relations Manager');
        insert cmt4;     
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        Account Acc = Commissions_TestDataFactory.createAccount('Name','theAcc@move.com',rectypidaccount,type,true);      
        
        Period__c period = Commissions_TestDataFactory.Createperiod('Test',True,Date.today().toStartOfMonth());        
        
        Zuora__CustomerAccount__c cAccount = new Zuora__CustomerAccount__c();
        cAccount.Name = 'TestAccount';
        cAccount.Zuora__Account__c= Acc.Id;
        cAccount.Zuora__Zuora_Id__c = '2c92c0f94c750685014c78c1967e660a';
        insert cAccount;
        
        String zID = '111111111444111111111111';
        Zuora__PaymentMethod__c pay = new Zuora__PaymentMethod__c(); 
        pay.Name = 'Testt';
        pay.Zuora__BillingAccount__c = cAccount.id;
        pay.Zuora__Type__c = 'CreditCard';
        pay.Zuora__CreditCardMaskNumber__c = '34512456';
         pay.Zuora__CreditCardHolderName__c = '34512456';
        pay.Zuora__External_Id__c = zID;
        insert pay;
        
        PaymentProfiles__c pp = new PaymentProfiles__c();
         pp.Account__c = Acc.id;     
         pp.PaymentMethodId__c = zId;
         pp.SplitPercentage__c = 20.0;
       
        insert pp;
         PaymentProfiles__c ppu = new PaymentProfiles__c();
        ppu.Id = pp.Id;
        ppu.SplitPercentage__c = 10.0;
        update ppu;
             
        Zuora__Payment__c Zp = new Zuora__Payment__c ();
        Zp.Name = 'Test';
        Zp.Zuora__BillingAccount__c = cAccount.id;
        Zp.Zuora__PaymentMethod__c = '12456';
        Zp.ZPaymentMethodId__c = zID;        
        Zp.Zuora__Amount__c = 200;
        Zp.Zuora__Status__c ='Processed'; 
        Zp.Zuora__Type__c = 'Electronic';       
        zp.SalesforceCollectionsRepUsername__c = 'testcltrep1@move.com';
        
        
        insert Zp;       
        
        system.debug('Effectivedate ' + Zp.Zuora__EffectiveDate__c);
        Map<id,Zuora__Payment__c> newMap1 = new Map<id,Zuora__Payment__c>();
        newMap1.Put(Zp.id,Zp);  
        
        Quota__c  QuotaHandler = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false); 
        QuotaHandler.User_Team__c = CollectionTeam;
        QuotaHandler.User__c = user1.id;
        insert QuotaHandler;
        
        Quota__c  QuotaHandlerM = Commissions_TestDataFactory.CreateQuota(user2.id,period.id,false);
        QuotaHandlerM.User_Team__c = ManagerTeam;
        QuotaHandlerM.User__c =user2.Id;     
        insert QuotaHandlerM; 
        
        Product2 prdctdata = Commissions_TestDataFactory.CreateProduct('Name',true);       
        String NewSale = Commissions_Constants.NEW_SALE_WITHOUT_QUALIFIER;
        
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(CollectionTeam).getRecordTypeId(); 
        Payout__c pa= Commissions_TestDataFactory.CreatePayout(NewSale,rectypidp, null, null,1,100,2.25,1.05,2.02,3.00,false);
        pa.Low_Level__c = Null;
        pa.High_Level__c = null;
        pa.Period__c = period.id;
        pa.Commissionable__c = 2.0;
        
        insert pa;           
        
        id rectypidp1 = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get('Heather Riggio').getRecordTypeId(); 
        Payout__c pa1= Commissions_TestDataFactory.CreatePayout(NewSale,rectypidp1, null, null,1,100,2.25,1.05,2.02,3.00,false);
        pa1.Period__c = period.id;
        pa1.Low_Level__c = Null;
        pa1.High_Level__c = null;
        pa1.Commissionable__c = 2.0;
        insert pa1;             
       
        Test.startTest();
            Commissions_CreateCollectionCommsClass cls = new Commissions_CreateCollectionCommsClass();
            cls.CreateCommissions(newMap1);
        Test.stopTest(); 
    }   
}