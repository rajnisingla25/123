@isTest
public class Commissions_QuotaCompPlanController_Test {

    @testSetup static void testQuotasForCompensation() {
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
        prdctdata.ProductCode = 'SELLERLEADBUNDLE';
        prdctdata.isActive = true;
        insert prdctdata;     
        
        SkipUserTrigger.setSkipTrgTrue();
        Profile p = [select id from profile where name='System Administrator'];   
        User user1 = Commissions_TestDataFactory_New.createUser(null,p.id,null,'testq1541@move.com','testq1541@move.com',true,WLVTerritory,'Heather Riggio1');      
        User user2 = Commissions_TestDataFactory_New.createUser(null,p.id,null,'testq1542@move.com','testq1542@move.com',true,ManagerTeam,'Heather Riggio2');      
        User user3 = Commissions_TestDataFactory_New.createUser(null,p.id,null,'testq1543@move.com','testq1543@move.com',true,WLVTerritory,'Heather Riggio3');
        User user4 = Commissions_TestDataFactory_New.createUser(null,p.id,null,'testq1544@move.com','testq1544@move.com',true,ManagerTeam,'Heather Riggio4');
        
        SkipAccountTrigger.setSkipTrgTrue();        
        Account acc = Commissions_TestDataFactory_New.createAccount('test','test@test.com',rectypidaccount,'Test Street','City','State','12345',type,user1.id,true);
        
        Period__c period = Commissions_TestDataFactory_New.createPeriod('Test',System.today(),brokerRDteam,50,50,true);   
        Payout__c pa= Commissions_TestDataFactory_New.CreatePayout('New Sale without Qualifier',rectypidp, 10.00, 50.00,null,null,true);   
        Quota__c  QuotaHandlerlatest1 = Commissions_TestDataFactory_New.CreateQuota(user1.id,WLVTerritory,brokerRDteam,period.Id,true,false);
        Quota__c  QuotaHandlerlatest2 = Commissions_TestDataFactory_New.CreateQuota(user2.id,'Managers Team',brokerRDteam,period.Id,false,false);  
        Quota__c  QuotaHandlerlatest3 = Commissions_TestDataFactory_New.CreateQuota(user3.id,WLVTerritory,brokerRDteam,period.Id,true,true);
        Quota__c  QuotaHandlerlatest4 = Commissions_TestDataFactory_New.CreateQuota(user4.id,'Managers Team',brokerRDteam,period.Id,false,true);

	}
    
    public static testmethod void testQuotasforCompensationsDocuSign(){
        
        PageReference pageRef = Page.QuotaCompPlanConfirmation;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Id,User__c,User__r.Name,Name,User_Team__c,Period_Name__c,Target_Amount__c,Total_Sale_Renewal__c,Collection_Target_Amount__c,(Select Id,dsfs__Sent_Date_Time__c,dsfs__Envelope_Status__c From DocuSign_Status__r ORDER BY dsfs__Sent_Date_Time__c DESC LIMIT 1) FROM Quota__c]));
        sc.setSelected([SELECT Id,User__c,User__r.Name,Name,User_Team__c,Period_Name__c,Target_Amount__c,Total_Sale_Renewal__c,Collection_Target_Amount__c,(Select Id,dsfs__Sent_Date_Time__c,dsfs__Envelope_Status__c From DocuSign_Status__r ORDER BY dsfs__Sent_Date_Time__c DESC LIMIT 1) FROM Quota__c]);
        
        Commissions_QuotaCompPlanController cntrl = new Commissions_QuotaCompPlanController(sc);        
        cntrl.wrapperRecordList[0].isSelected = true;        
               
        Test.startTest();
        cntrl.listviewURL = 'https://moveinc--dev--c.cs79.visual.force.com/apex/QuotaCompPlanConfirmation?retURL=%2Fa2e%3Ffcf%3D00Bj0000004PtXv&wrapMassAction=1&scontrolCaching=1';
        cntrl.first();
        cntrl.getTotalPages();
        cntrl.goBackandSelectMore();
        cntrl.last();
        cntrl.previous();
        cntrl.confirmCompensationPlan();
        cntrl.next(); 
        cntrl.doSelectQuotaRecord();
        cntrl.doDeselectQuotaRecord();
        cntrl.getSelectedCount();
        cntrl.isSelectedAll();
        Test.stopTest();
        
    }
}