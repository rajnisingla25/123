@isTest
public class EmailCaseServiceForBLATest {
    
    @testSetup
    public static void setTestData(){
        String WLVTerritory = Commissions_Constants.HYBRID_AGENT_TEAM ;  
        String ManagerTeam = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM;         
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        id rectypidasset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(WLVTerritory).getRecordTypeId();
                
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'test@test.com');
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
        commission_settings__c setting = new commission_settings__c();
        setting.Name = 'workflows';
        setting.product1__c = 'Top Producer';
        setting.product2__c = 'Reesio';
        setting.Asset_name1__c = 'Top Producer CRM';
        setting.Asset_name2__c = 'FiveStreet';
        insert setting; 
        
        Integer monthValue = system.today().Month();
        String brokerRDteam = 'Q2' ;   
        If (monthValue <= 3) {       
            brokerRDteam = 'Q3';
        } else if (monthValue <= 6) {
            brokerRDteam = 'Q4';
        } else if (monthValue <= 9) {
            brokerRDteam = 'Q1';
        }

        Product2 prdctdata = new Product2();
        prdctdata.name = 'New Test';
        prdctdata.S_No__c = 12;
        prdctdata.ProductCode = 'OPCITYBLA';
        prdctdata.isActive = true;
        insert prdctdata;     
        
        SkipUserTrigger.setSkipTrgTrue();
        Profile p = [select id from profile where name='System Administrator'];   
        User user1 = Commissions_TestDataFactory_New.createUser(null,p.id,null,'testq1541@move.com','testq1541@move.com',true,WLVTerritory,'Heather Riggio1');      
        User user2 = Commissions_TestDataFactory_New.createUser(null,p.id,null,'testq1542@move.com','testq1542@move.com',true,ManagerTeam,'Heather Riggio2');      
        User user3 = Commissions_TestDataFactory_New.createUser(null,p.id,null,'testq1543@move.com','testq1543@move.com',true,WLVTerritory,'Heather Riggio3');
        User user4 = Commissions_TestDataFactory_New.createUser(null,p.id,null,'testq1544@move.com','testq1544@move.com',true,ManagerTeam,'Heather Riggio4');
        
        SkipAccountTrigger.setSkipTrgTrue();        
        Account acc = Commissions_TestDataFactory_New.createAccount('test','test@test.com',rectypidaccount,'Test Street','City','State','12345',type,user1.id,false);
        acc.Party_ID__c = '98761195';
        insert acc;
        
        Period__c period = Commissions_TestDataFactory_New.createPeriod('Test',System.today(),brokerRDteam,50,50,true);   
        Payout__c pa= Commissions_TestDataFactory_New.CreatePayout('New Sale without Qualifier',rectypidp, 10.00, 50.00,null,null,true);   
        

        SkipAssetTrigger.setSkipTrgTrue();
        Asset parentAsset = Commissions_TestDataFactory_New.CreateAsset(acc.ID,rectypidasset,user3.id,user3.id,1000,prdctdata.id,'Add',1000,false);
        parentAsset.Fulfillment_Status__c = Constants.ORDER_FULFILLMENT_STATUS_MANUAL; //Manual
        parentAsset.Stage__c = 'Agreement Sent';
        parentAsset.Asset_Type__c = Constants.ASSET_TYPE; // Parent
        parentAsset.Commission_field__c = 'Ignore';
        insert parentAsset;
        
        Asset fulfillToasset = Commissions_TestDataFactory_New.CreateAsset(acc.ID,rectypidasset,user4.id,user4.id,1000,prdctdata.id,'Add',1000,false);
        fulfillToasset.Fulfillment_Status__c = Constants.ORDER_FULFILLMENT_STATUS_MANUAL; // Manual
        fulfillToasset.Stage__c = 'Agreement Sent';
        fulfillToasset.Asset_Type__c = Constants.ASSET_TYPE_FULFILL; // Fulfill To
        fulfillToasset.Parent_Asset__c = parentAsset.Id;
        fulfillToasset.Commission_field__c = 'Ignore';
        insert fulfillToasset;
        
        Asset parentassetFromAccount = Commissions_TestDataFactory_New.CreateAsset(acc.ID,rectypidasset,user1.id,user1.id,1000,prdctdata.id,'Add',1000,false);
        parentassetFromAccount.Fulfillment_Status__c = Constants.ORDER_FULFILLMENT_STATUS_MANUAL; //Manual
        parentassetFromAccount.Stage__c = 'Agreement Sent';
        parentassetFromAccount.Asset_Type__c = Constants.ASSET_TYPE; // Parent
        parentassetFromAccount.Commission_field__c = 'Ignore';
        insert parentassetFromAccount;
        
        Asset parentassetFromAccount1 = Commissions_TestDataFactory_New.CreateAsset(acc.ID,rectypidasset,user1.id,user1.id,1000,prdctdata.id,'Add',1000,false);
        parentassetFromAccount1.Fulfillment_Status__c = Constants.ORDER_FULFILLMENT_STATUS_MANUAL; //Manual
        parentassetFromAccount1.Stage__c = 'Agreement Sent';
        parentassetFromAccount1.Asset_Type__c = Constants.ASSET_TYPE; // Parent
        parentassetFromAccount1.Commission_field__c = 'Ignore';
        insert parentassetFromAccount1;
      
    }
    
    static testMethod void TestEmailServiceForBLAOPCITY() {
        Test.startTest();
    	// create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();        
        
        
         // setup the data for the email
        email.subject = 'Agreement Signed!';
        email.fromAddress = 'pravin.sonawane.contractor@move.com';
           
        email.plainTextBody = 'Party ID: 98761195';
        email.toAddresses = new List<String>{'pravin.sonawane.contractor@move.com'};
        
        // call the email service class and test it with the data in the testMethod
        EmailCaseServiceForBLA serviceForBLA = new EmailCaseServiceForBLA();
        result = serviceForBLA.handleInboundEmail(email, env);
        
        List<Asset> lstFulFillToAsset = [Select Id,Account_Party_ID__c,Parent_Asset__c,Contract_Signed_Date__c,Stage__c,Product_Code__c,Asset_Type__c,Fulfillment_Status__c
                                         From Asset Where Account_Party_ID__c = '98761195' LIMIT 1];
        System.assertEquals('Brokerage Signed (won deal)', lstFulFillToAsset[0].Stage__c);
        System.assertNotEquals(null, lstFulFillToAsset[0].Contract_Signed_Date__c);
        
        Test.stopTest();
        
        
    
    }

}