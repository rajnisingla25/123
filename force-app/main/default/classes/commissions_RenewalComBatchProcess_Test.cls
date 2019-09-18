@isTest
public class commissions_RenewalComBatchProcess_Test{
    
      public static testMethod void mainTestmethod1() 
      {     
        String WLVTerritory = Commissions_Constants.HYBRID_AGENT_TEAM ;  
        String ManagerTeam = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM;         
        //string status = Constants.ACTIVE_STATUS;
        //string fullfilled = Constants.FULFILLMENT_STATUS;
        //string type1 = Constants.ASSET_TYPE;
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        //Integer Year = Date.Today().Year(); 
        
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
        
        Product2 prdctdata = new Product2();
        prdctdata.name = 'New Test';
        prdctdata.S_No__c = 12;
        prdctdata.ProductCode = 'SELLERLEADBUNDLE';
        prdctdata.isActive = true;
        insert prdctdata;     
        
        Profile p = [select id from profile where name='System Administrator'];   
        User user1 = Commissions_TestDataClass_New.createUser(null,p.id,null,'testq1541@move.com','testq1541@move.com',true,WLVTerritory,'Heather Riggio');      
        //User user2 = Commissions_TestDataClass_New.createUser(null,p.id,null,'testq1542@move.com','testq1542@move.com',true,WLVTerritory,'Heather Riggio');      
        
        Account acc = Commissions_TestDataClass_New.createAccount('test','test@test.com',rectypidaccount,'Test Street','City','State','12345',type,user1.id,true);
             
        Asset assets = Commissions_TestDataClass_New.CreateAsset(acc.ID,rectypidasset,user1.id,user1.id,1000,prdctdata.id,'Amend',1000,true);
      
      
        Asset assets1 =[select id,Name,accountId,Account.RecordTypeId,Product2Id,Sign_in_AE__c,OwnerId,Asset_Type__c,Fulfillment_Status__c,Status,Account_Type__c,
                LastModifiedDate,CreatedDate,Line_Type__c,Legacy_Created_Date__c,End_Date__c,Billing_Period__c,Total_Net__c,Renewal_Type__c,Product_Code__c,Product2.ProductCode,
                Commission_field__c,Sign_in_AE__r.Team__c,Delta_Price_w_o_Tax__c,Start_Date__c,Commissions_are_calculated__c,Order_Line_Item__c,Order_Line_Item__r.Product_Commission_Category__c 
                 from Asset where id=:assets.id ];
        
        List<Asset> fullfilledAssets = new  List<Asset>();
        Set<id> fullfilledAssetsSet = new  Set<id>();
        
        fullfilledAssets.add(assets1); 
        for(Asset ac:fullfilledAssets )
        {
          fullfilledAssetsSet.add(ac.id) ;
        }
        
      Test.startTest();
            Database.executeBatch(new commissions_RenewalComBatchProcess_New (fullfilledAssetsSet),1);
      Test.stopTest();
    }   
    

    
    
    
}