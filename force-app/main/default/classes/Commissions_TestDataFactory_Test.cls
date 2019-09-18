@isTest(seeAllData = false)
public class Commissions_TestDataFactory_Test {
    public static testMethod void mainTest() {
        Profile p = [select id from profile where name='System Administrator'];
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get('Broker Regional Directors Sales Team').getRecordTypeId(); 
        id Commrectypidq = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('New Sale').getRecordTypeId(); 
        id rectypidasset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();   
         
        User user3 = Commissions_TestDataFactory.createUser(null,p.id,null,'test1595@move.com','test1595@move.com',true,'RDTeam');
        user3.Managers__c = 'Heather Riggio';
        update User3;
            
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;        
       
        Collection_Users__c coll = new Collection_Users__c(Name='batchintegration user', id__c= '005j000000CdBiE');
        insert coll;
        
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
        commission_settings__c setting = new commission_settings__c();
        setting.Name = 'workflows';
        setting.product1__c = 'Top Producer';
        setting.product2__c = 'Reesio';
        setting.Asset_name1__c = 'Top Producer CRM';
        setting.Asset_name2__c = 'FiveStreet';
        insert setting; 
        
        Account newAccount = Commissions_TestDataFactory.createAccount('Name','theAcc@move.com',rectypidaccount,'Broker',false);
        newAccount.OwnerId = user3.id;
        insert newAccount; 
        
        Account newAccount1 = Commissions_TestDataFactory.createAccount('Name','theAcc@move.com',rectypidaccount,'Broker Consil',false);
        newAccount1.OwnerId = user3.id;
        insert newAccount1;
        
        Contact Con = Commissions_TestDataFactory.createContact('FName','LName',newAccount.id,true,true);
      
        Period__c period = Commissions_TestDataFactory.Createperiod('Test',True,Date.today());
    
        Quota__c  QuotaHandler1 = Commissions_TestDataFactory.CreateQuota(user3.id,period.id,True);
        
        Product2 prod = Commissions_TestDataFactory.CreateProduct('Test Product',True);
        
        Zuora__CustomerAccount__c cAccount = new Zuora__CustomerAccount__c();
        cAccount.Name = 'TestAccount';
        cAccount.Zuora__Account__c= newAccount.Id;
        cAccount.Zuora__Zuora_Id__c = '2c92c0f94c750685014c78c1967e660a';
        insert cAccount; 
            
        System.runAs(user3)
        {
           Commissions_TestDataFactory.createUser(null,p.id,null,'Sudhatest@gmail.com','Sudhatest@gmail.com',true,'WLV Team');
           Commissions_TestDataFactory.createAccount('Name','test@gmail.com',rectypidaccount,'parent',true);
           Commissions_TestDataFactory.createContact('FName','LName',newAccount.id,true,true);
          // Commissions_TestDataFactory.createCase('My test Case', 'Open','type','description',con.id,newAccount.id,true);
           Commissions_TestDataFactory.Createperiod('December',true,System.Today());
           Commissions_TestDataFactory.CreateQuota(user3.id,period.id,true);
           Commissions_TestDataFactory.CreateProduct('TestProduct',true);
           Commissions_TestDataFactory.CreatePayout('NewSale',rectypidp,10.00,10.00,10.00,15.00,11.00,20.00,21.00,30.00,true);
           //Commissions_TestDataFactory.CreatePaymentHistory('Name',user3.id,newAccount.id,true);
           Commissions_TestDataFactory.CreateZuoraPayment('Test',cAccount.id,'12456',Date.today(),200,true);
           Commissions_TestDataFactory.CreateComm(QuotaHandler1.id,prod.id,Commrectypidq,null,true);
           Commissions_TestDataFactory.CreateAsset(rectypidasset,user3.id,prod.id,true);
           Commissions_TestDataFactory.createAccountRelationship(newAccount.id,newAccount1.id,con.id,'TestRole',true,true);
           
        }
    }
}