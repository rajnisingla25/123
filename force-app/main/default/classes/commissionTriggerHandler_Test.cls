@isTest
public class commissionTriggerHandler_Test {
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
        QuotaHandler1.ADVANTAGE_New__c = 10.0;
        QuotaHandler1.LISTHUBPRO_New__c = 8.0;
        QuotaHandler1.MRKTBUILD_New__c = 7.0;
        QuotaHandler1.TOPIDX_New__c = 6.0;
        QuotaHandler1.COBROKE_New__c = 5.0;
        QuotaHandler1.DACAMPAIGN_New__c = 4.0;
        QuotaHandler1.DIGITALAGENT_New__c = 3.0;
        QuotaHandler1.DOMAINNAME_New__c = 2.0;        
        QuotaHandler1.FEATCMA_New__c = 2.0;
        QuotaHandler1.FIVESTREET_New__c = 10.0;
        QuotaHandler1.SHOWCASE_New__c = 9.0;
        QuotaHandler1.SIGNRIDER_New__c = 8.0;
        QuotaHandler1.STANDLIST_New__c = 7.0;
        QuotaHandler1.TOPCRM_New__c = 6.0;
        QuotaHandler1.TOPWEB_New__c = 5.0;
        QuotaHandler1.TOPWEBFEE_New__c = 4.0;
        QuotaHandler1.TURBO_New__c = 3.0;        
        QuotaHandler1.SELLERLEAD_New__c = 2.0;
        QuotaHandler1.TRKPHNMBR_New__c = 1.0;
        QuotaHandler1.SELLERLEADBUNDLE_New__c = 10.0;
        QuotaHandler1.RSRESPOND_New__c = 9.0;        
        QuotaHandler1.MEDIABUY_New__c = 8.0;
        QuotaHandler1.REESIO_New__c = 7.0;
        QuotaHandler1.BETARESPOND_New__c = 6.0;
        QuotaHandler1.FEATDISP_New__c = 5.0;
        QuotaHandler1.FEATHOMES_New__c = 4.0;
        QuotaHandler1.RSCONNECT_New__c = 3.0;
        QuotaHandler1.RSTRANSACT_New__c = 2.0;
        insert QuotaHandler1;
    
        // creating product data
        Product2 prdctdata1 = Commissions_TestDataFactory.CreateProduct('Top Producer',false);
        insert prdctdata1;
    
        // creating quota product
        Quota_Product__c quotaPrdct = new Quota_Product__c(Product_Name__c = prdctdata1.id,Related_To_Quota__c = QuotaHandler1.id);
        quotaPrdct.Sales_Achivement__c = 10;
        quotaPrdct.Sales__c = 15;
        quotaPrdct.Unit_Achivement__c = 10;
        quotaPrdct.Unit__c = 5;
        quotaPrdct.License_Achivement__c = 10.0; 
        quotaPrdct.License__c = 5.0;
        insert quotaPrdct;      
        
                // creating quota product
        Quota_Product__c quotaPrdct1 = new Quota_Product__c(Product_Family__c = 'ProSoft',Related_To_Quota__c = QuotaHandler1.id);
        quotaPrdct1.Sales_Achivement__c = 10;
        quotaPrdct1.Sales__c = 15;
        quotaPrdct1.Unit_Achivement__c = 10;
        quotaPrdct1.Unit__c = 5;
        quotaPrdct1.License_Achivement__c = 10.0;
        quotaPrdct1.License__c = 5.0;
       
        insert quotaPrdct1;
      
        // creating asset
        Asset Asset1 = Commissions_TestDataFactory.CreateAsset(rectypidp2, user1.id,prdctdata1.id,false);
        Asset1.Name = 'Top Producer CRM';
        Asset1.License_Tier__c = 10;
        Asset1.Renewal_Type__c = 'Auto';
        insert Asset1;
        
        // creating commissions
        Id devRecordTypeId = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('New Sale').getRecordTypeId();
        List<Commission__c> commlist = new List<Commission__c>();
        List<Commission__c> commlistnew = new List<Commission__c>();
        Commission__c comm1 = Commissions_TestDataFactory.CreateComm(QuotaHandler1.id, prdctdata1.id,rectypidp1,null ,false);
        comm1.Related_to_Asset__c = Asset1.id;
        comm1.Commissionable_Amount2__c = 100.0;
        comm1.Commissionable_Amount1B__c = 100.0;
        comm1.Other_Product__c = setting.product1__c;
        comm1.Product__c = prdctdata1.Id;
        comm1.User_Team__c = WLVTeam;
        comm1.line_type__c = 'Add';
        comm1.Signing_AE__c = user1.Id;
        comm1.recordtypeId = devRecordTypeId;
        comm1.status__c = 'Active';
        Commission__c comm2 = new Commission__c();
        comm2.Related_To_Quota__c = QuotaHandler1.id;
        comm2.Related_to_Asset__c = Asset1.id;
        comm2.Line_Type__c = 'Add';
        comm2.Commissionable_Amount2__c = 100.0;
        comm2.Commissionable_Amount1B__c = 100.0;
        comm2.Other_Product__c = setting.product1__c;
        comm2.User_Team__c = WLVTeam;
        comm2.recordtypeId = devRecordTypeId;
        comm2.Product__c = prdctdata1.Id;
        comm2.Signing_AE__c = user1.Id;
        comm2.status__c = 'Active';
        commlist.add(comm1);
        commlist.add(comm2);
        insert commlist;  
        RecursionBlockerClass.runOnceBool = true;
        commissionTriggerHandler.processQuotaproducts(commlist);
        commissionTriggerHandler.updateCommissionswQP(commlist);//CRM-3027 - To update quota product on commissions.
        for(commission__c ct : commlist){
            ct.Commissionable_Amount2__c = 200.00;
            commlistnew.add(ct);    
        }
        if(commlistnew.size()>0){
            update commlistnew;
        }
        Delete commlistnew;
        undelete commlistnew;
        
        Commissions_TestDataFactory_New.CreateProduct('Advantage - Leads and Branding','ADVANTAGE','Listing Enhancements',1,true);
          
        Product2 product1 =  [Select Id,ProductCode From Product2 Where ProductCode = 'ADVANTAGE' Limit 1];
        system.debug('product1='+product1);
        Id rectypidOtherProduct = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get(System.Label.Commission_Other_Products).getRecordTypeId();
        
        Commission__c commission1 = new Commission__c();
        commission1.Related_To_Quota__c = QuotaHandler1.Id;
        commission1.Product__c = product1.Id;
        commission1.Line_Type__c = 'Add';
        commission1.RecordTypeId = rectypidOtherProduct;
        commission1.Signing_AE__c = UserInfo.getUserId();
        insert commission1;
        system.assertNotEquals(null, commission1.Id);
        Commission__c newComm1 = [Select Id,Payout_Rate__c From Commission__c Where Id =:commission1.Id ];
        System.assertEquals(10.0, newComm1.Payout_Rate__c);
        
    }
    
}