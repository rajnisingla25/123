@isTest
public class quotaProductTriggerHandler_Test {
public static testMethod void commissionTestMethod() {
    
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;  
        
        commission_settings__c setting = new commission_settings__c();
        setting.Name = 'workflows';
        setting.product1__c = 'Top Producer';
        setting.product2__c = 'Reesio';
        setting.Asset_name1__c = 'Top Producer CRM';
        setting.Asset_name2__c = 'FiveStreet';
        insert setting;
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
        Product_Family__c PF = new Product_Family__c(Name = 'Top Producer CRM' ,Family_Name__c = 'Prosoft');
        insert PF;
        
        Profile p = [select id from profile where name='System Administrator'];
        String WLVTeam = Commissions_Constants.WLV_TERRITORY_TEAM; 
    
        id rectypidp1 = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Retention Commission').getRecordTypeId();
        id rectypidp2 = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        
        // creating user
        User user1 = Commissions_TestDataFactory.createUser(null,p.id,null,'test15411@move.com','test15411@move.com',true,WLVTeam);
        User1.Managers__c = 'Heather Riggio';
        update user1;
        
        // creating period
        Period__c period = Commissions_TestDataFactory.Createperiod('Test',false,Date.today().toStartOfMonth());
        period.Tiger_Lead_Qualifier_Amount__c = 100.00;
        period.BOBAmount__c = 100.00;
    	period.Credit_Signing_AE__c = true;
        period.Credit_Asset_Owner__c = true;
        insert period;
    
        // creating quota
        Quota__c  QuotaHandler1 = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler1.Target_Amount__c = 1000;
        QuotaHandler1.User_Team__c =WLVTeam;
        QuotaHandler1.Current_Quater__c = '';
        QuotaHandler1.Is_Kicker__c = false;      
        insert QuotaHandler1;
    
        // creating product data
        Product2 prdctdata1 = Commissions_TestDataFactory.CreateProduct('Top Producer',false);
        insert prdctdata1;
    
        // creating quota product
        List<Quota_Product__c> qplist = new List<Quota_Product__c>();
        Quota_Product__c quotaPrdct = new Quota_Product__c(Product_Name__c = prdctdata1.id,Related_To_Quota__c = QuotaHandler1.id);
        quotaPrdct.Sales_Achivement__c = 10;
        quotaPrdct.Sales__c = 15;
        quotaPrdct.Unit_Achivement__c = 10;
        quotaPrdct.Unit__c = 5;
        quotaPrdct.License_Achivement__c = 10.0;
        quotaPrdct.License__c = 5.0;
        qplist.add(quotaPrdct);      
        
                // creating quota product
        Quota_Product__c quotaPrdct1 = new Quota_Product__c(Product_Family__c = 'ProSoft',Related_To_Quota__c = QuotaHandler1.id);
        quotaPrdct1.Sales_Achivement__c = 10;
        quotaPrdct1.Sales__c = 15;
        quotaPrdct1.Unit_Achivement__c = 10;
        quotaPrdct1.Unit__c = 5;
        quotaPrdct1.License_Achivement__c = 10.0;
        quotaPrdct1.License__c = 5.0;
        qplist.add(quotaPrdct1);     
        if(qplist!=null &&qplist.size()>0){
            insert qplist;
        }
        // creating asset
        Asset Asset1 = Commissions_TestDataFactory.CreateAsset(rectypidp2, user1.id,prdctdata1.id,false);
        Asset1.Name = 'Top Producer CRM';
        Asset1.License_Tier__c = 10;
        Asset1.Renewal_Type__c = 'Auto';
        insert Asset1;
        
        // creating commissions
        Id devRecordTypeId = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('New Sale').getRecordTypeId();
        List<Commission__c> commlist = new List<Commission__c>();
        Commission__c comm1 = Commissions_TestDataFactory.CreateComm(QuotaHandler1.id, prdctdata1.id,rectypidp1,null ,false);
        comm1.Related_to_Asset__c = Asset1.id;
        comm1.Commissionable_Amount2__c = 100.0;
        comm1.Commissionable_Amount1B__c = 100.0;
        comm1.Other_Product__c = setting.product1__c;
        comm1.Product__c = prdctdata1.Id;
        comm1.User_Team__c = WLVTeam;
        comm1.Signing_AE__c = user1.Id;
        Commission__c comm2 = new Commission__c();
        comm2.Related_To_Quota__c = QuotaHandler1.id;
        comm2.Related_to_Asset__c = Asset1.id;
        comm2.Line_Type__c = 'Amend';
        comm2.Commissionable_Amount2__c = 100.0;
        comm2.Commissionable_Amount1B__c = 100.0;
        comm2.Other_Product__c = setting.product1__c;
        comm2.User_Team__c = WLVTeam;
        comm2.recordtypeId = devRecordTypeId;
        comm2.Product__c = prdctdata1.Id;
        comm2.Signing_AE__c = user1.Id;
        commlist.add(comm1);
        commlist.add(comm2);
        if(commlist!=null && commlist.size()>0){
        insert commlist;  
        }
        RecursionBlockerClass.runOnceBool = true;
        quotaProductTriggerHandler.processQuotaproducts(qplist);
        quotaProductTriggerHandler.updateCommWQP(qplist);//CRM-3027 - To update quota product on commissions.
      }
}