@isTest
public class Commissions_QuotaPageController_Test{
    
   public static testMethod void testMethod1() {
    
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;  
        Product_Family__c PF = new Product_Family__c(Name = 'Top Producer CRM' ,Family_Name__c = 'Prosoft');
        insert PF;
       CommissionTeams__c  CommissionTeamsBroker = new CommissionTeams__c(Name = 'BROKER_REGIONAL_DIRECTORS_TEAM', Team_Name__c = 'Broker Regional Directors Sales Team');
       insert CommissionTeamsBroker;
       CommissionTeams__c  CommissionTeams = new CommissionTeams__c(Name = 'MANAGERS_TEAM', Team_Name__c = 'Managers Team');
       insert commissionteams;
        Profile p = [select id from profile where name='System Administrator'];
        String WLVTeam = Commissions_Constants.WLV_TERRITORY_TEAM; 
    
        id rectypidp1 = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Retention Commission').getRecordTypeId();
        id rectypidp2 = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        
        // creating user
        User user1 = Commissions_TestDataFactory.createUser(null,p.id,null,'test154122@move.com','test15422@move.com',true,WLVTeam);
        User1.Managers__c = 'Heather Riggio';
        update user1;
        
        // creating period
        Period__c period = Commissions_TestDataFactory.Createperiod('Test',false,Date.today().toStartOfMonth());
        period.Tiger_Lead_Qualifier_Amount__c = 100.00;
        period.BOBAmount__c = 100.00;
        insert period;
    
        // creating quota
        Quota__c  QuotaHandler1 = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler1.Target_Amount__c = 1000;
        QuotaHandler1.User_Team__c =WLVTeam;
        QuotaHandler1.Current_Quater__c = '';
        QuotaHandler1.Is_Kicker__c = false;      
        insert QuotaHandler1;
    
        // creating product data
        Product2 prdctdata1 = Commissions_TestDataFactory.CreateProduct('Top Producer FiveStreet',false);
        insert prdctdata1;
    
        // creating quota product
        Quota_Product__c quotaPrdct = new Quota_Product__c(Product_Name__c = prdctdata1.id,Related_To_Quota__c = QuotaHandler1.id);
        quotaPrdct.Sales_Achivement__c = 10;
        quotaPrdct.Sales__c = 5;
        quotaPrdct.Unit_Achivement__c = 10;
        quotaPrdct.Unit__c = 5;
        quotaPrdct.License_Achivement__c = 10.0;
        quotaPrdct.License__c = 5.0;
        insert quotaPrdct;        
      
        // creating asset
        Asset Asset1 = Commissions_TestDataFactory.CreateAsset(rectypidp2, user1.id,prdctdata1.id,false);
        Asset1.Name = 'FiveStreet Top Producer';
        Asset1.License_Tier__c = 10;
        Asset1.Renewal_Type__c = 'Auto';
         Asset1.Line_Type__c = 'Add';
        insert Asset1;
        
        // creating commissions
        Commission__c comm1 = Commissions_TestDataFactory.CreateComm(QuotaHandler1.id, prdctdata1.id,rectypidp1,null ,false);
        comm1.Related_to_Asset__c = Asset1.id;
        comm1.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c = 10.0;
        comm1.Line_Type__c = 'Add';
        comm1.Signing_AE__c = user1.id;
        insert comm1;  

        PageReference pageRef = page.Commissions_QuotaPageController;
        Test.setCurrentPage(pageRef);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(QuotaHandler1);
        ApexPages.currentPage().getParameters().put('Id',QuotaHandler1.id); 
    
        //Commissions_QuotaPageController Commissions_QuotaPageController = new Commissions_QuotaPageController(sc); 
 
      Test.startTest(); 
        //Commissions_QuotaPageController.addrow();
        //Commissions_QuotaPageController.deleteRow();
        //Commissions_QuotaPageController.selectAll();
        //Commissions_QuotaPageController.MyMethod();
        //Commissions_QuotaPageController.save();
        //Commissions_QuotaPageController.Cancel();
        //Commissions_QuotaPageController.kickerLogic();
       
        //Commissions_QuotaPageController.CalculateLogic(true,'AND',true);
        //Commissions_QuotaPageController.CalculateLogic(true,'OR',true);
     Test.stopTest();       
       
       
  }
    
    public static testmethod void productmethod(){
          CommissionTeams__c  CommissionTeamsBroker = new CommissionTeams__c(Name = 'BROKER_REGIONAL_DIRECTORS_TEAM', Team_Name__c = 'Broker Regional Directors Sales Team');
       insert CommissionTeamsBroker;
       CommissionTeams__c  CommissionTeams = new CommissionTeams__c(Name = 'MANAGERS_TEAM', Team_Name__c = 'Managers Team');
       insert commissionteams;
       DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;  
    Product_Family__c PF = new Product_Family__c(Name = 'Top Producer CRM' ,Family_Name__c = 'Prosoft');
        insert PF;
        Profile p = [select id from profile where name='System Administrator'];
        String WLVTeam = Commissions_Constants.WLV_TERRITORY_TEAM; 
    
        id rectypidp1 = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Retention Commission').getRecordTypeId();
        id rectypidp2 = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        
        // creating user
        User user1 = Commissions_TestDataFactory.createUser(null,p.id,null,'test15433@move.com','test15433@move.com',true,WLVTeam);
        User1.Managers__c = 'Heather Riggio';
        update user1;
        
        // creating period
        Period__c period = Commissions_TestDataFactory.Createperiod('Test',false,Date.today().toStartOfMonth());
        period.Tiger_Lead_Qualifier_Amount__c = 100.00;
        period.BOBAmount__c = 100.00;
        insert period;
    
        // creating quota
        Quota__c  QuotaHandler1 = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler1.Target_Amount__c = 1000;
        QuotaHandler1.User_Team__c =WLVTeam;
        QuotaHandler1.Current_Quater__c = '';
        QuotaHandler1.Is_Kicker__c = false;      
        insert QuotaHandler1;
    
        // creating product data
        Product2 prdctdata1 = Commissions_TestDataFactory.CreateProduct('Top Producer CRM',false);
        prdctdata1.Product_Family__c = 'Prosoft';
        insert prdctdata1;
         Product2 prdctdata2 = Commissions_TestDataFactory.CreateProduct('Top Producer CRM',false);
         prdctdata2.Product_Family__c = 'Prosoft';
        insert prdctdata2;
    
        // creating quota product
       /* Quota_Product__c quotaPrdct = new Quota_Product__c(Product_Name__c = prdctdata2.id,Related_To_Quota__c = QuotaHandler1.id);
        quotaPrdct.Sales_Achivement__c = 10;
        quotaPrdct.Sales__c = 5;
        quotaPrdct.Unit_Achivement__c = 10;
        quotaPrdct.Unit__c = 5;
        quotaPrdct.License_Achivement__c = 10.0;
        quotaPrdct.License__c = 5.0;
        insert quotaPrdct;   */     
      
        // creating asset
        Asset Asset1 = Commissions_TestDataFactory.CreateAsset(rectypidp2, user1.id,prdctdata1.id,false);
        Asset1.Name = 'FiveStreet Top Producer';
        Asset1.License_Tier__c = 10;
        Asset1.Renewal_Type__c = 'Auto';
        Asset1.Line_Type__c = 'Add';
        insert Asset1;
        
        // creating commissions
        Commission__c comm1 = Commissions_TestDataFactory.CreateComm(QuotaHandler1.id, prdctdata1.id,rectypidp1,null ,false);
        comm1.Related_to_Asset__c = Asset1.id;
        comm1.Line_Type__c = 'Add';
        comm1.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c = 10.0;
        comm1.Signing_AE__c = user1.id;
        insert comm1;  

        PageReference pageRef = page.Commissions_QuotaPageController;
        Test.setCurrentPage(pageRef);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(QuotaHandler1);
        ApexPages.currentPage().getParameters().put('Id',QuotaHandler1.id); 
    
        Commissions_QuotaPageController Commissions_QuotaPageController = new Commissions_QuotaPageController(sc); 
 
      Test.startTest(); 
        Commissions_QuotaPageController.addrow();
        Commissions_QuotaPageController.deleteRow();
        Commissions_QuotaPageController.selectAll();
        Commissions_QuotaPageController.MyMethod();
        Commissions_QuotaPageController.save();
        Commissions_QuotaPageController.Cancel();
        //Commissions_QuotaPageController.kickerLogic();
       
       //Commissions_QuotaPageController.CalculateLogic(true,'AND',true);
       //Commissions_QuotaPageController.CalculateLogic(true,'OR',true);
       Test.stopTest();       
         
    }
        public static testmethod void testmethod2(){
              
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;  
    Product_Family__c PF = new Product_Family__c(Name = 'Top Producer CRM' ,Family_Name__c = 'Prosoft');
        insert PF;
             CommissionTeams__c  CommissionTeamsBroker = new CommissionTeams__c(Name = 'BROKER_REGIONAL_DIRECTORS_TEAM', Team_Name__c = 'Broker Regional Directors Sales Team');
       insert CommissionTeamsBroker;
            CommissionTeams__c  CommissionTeams = new CommissionTeams__c(Name = 'MANAGERS_TEAM', Team_Name__c = 'Managers Team');
       insert commissionteams;
        Profile p = [select id from profile where name='System Administrator'];
        String WLVTeam = Commissions_Constants.WLV_TERRITORY_TEAM; 
    
        id rectypidp1 = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Retention Commission').getRecordTypeId();
        id rectypidp2 = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        
        // creating user
        User user1 = Commissions_TestDataFactory.createUser(null,p.id,null,'test15433@move.com','test15433@move.com',true,WLVTeam);
        User1.Managers__c = 'Heather Riggio';
        update user1;
        
        // creating period
        Period__c period = Commissions_TestDataFactory.Createperiod('Test',false,Date.today().toStartOfMonth());
        period.Tiger_Lead_Qualifier_Amount__c = 100.00;
        period.BOBAmount__c = 100.00;
        insert period;
    
        // creating quota
        Quota__c  QuotaHandler1 = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler1.Target_Amount__c = 1000;
        QuotaHandler1.User_Team__c =WLVTeam;
        QuotaHandler1.Current_Quater__c = '';
        QuotaHandler1.Is_Kicker__c = false;      
        insert QuotaHandler1;
    
        // creating product data
        Product2 prdctdata1 = Commissions_TestDataFactory.CreateProduct('Top Producer CRM',True);
        //insert prdctdata1;
         Product2 prdctdata2 = Commissions_TestDataFactory.CreateProduct('Connection(SM) for Co-Brokerage',false);
        insert prdctdata2;
    
        // creating quota product
        Quota_Product__c quotaPrdct = new Quota_Product__c(Related_To_Quota__c = QuotaHandler1.id);
         quotaPrdct.Product_Name__c = prdctdata1.id;
        //quotaPrdct.Product_Family__c = 'ProSoft';
        quotaPrdct.Sales_Achivement__c = 10;
        quotaPrdct.Sales__c = 5;
        quotaPrdct.Unit_Achivement__c = 10;
        //quotaPrdct.Unit__c = 5;
        quotaPrdct.License_Achivement__c = 10.0;
        //quotaPrdct.License__c = 5.0;
        insert quotaPrdct;        
      
        // creating asset
        Asset Asset1 = Commissions_TestDataFactory.CreateAsset(rectypidp2, user1.id,prdctdata1.id,false);
        Asset1.Name = 'FiveStreet Top Producer';
        Asset1.License_Tier__c = 10;
        Asset1.Renewal_Type__c = 'Auto';
        Asset1.Line_Type__c = 'Add';
        insert Asset1;
        
        // creating commissions
        Commission__c comm1 = Commissions_TestDataFactory.CreateComm(QuotaHandler1.id, prdctdata1.id,rectypidp1,null ,false);
        comm1.Related_to_Asset__c = Asset1.id;
        comm1.Line_Type__c = 'Add';
        comm1.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c = 10.0;
        comm1.other_product__c = null;
        comm1.Signing_AE__c = user1.id;
        insert comm1;  

        PageReference pageRef = page.Commissions_QuotaPageController;
        Test.setCurrentPage(pageRef);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(QuotaHandler1);
        ApexPages.currentPage().getParameters().put('Id',QuotaHandler1.id); 
    
        Commissions_QuotaPageController Commissions_QuotaPageController = new Commissions_QuotaPageController(sc); 
 
      Test.startTest(); 
        Commissions_QuotaPageController.addrow();
        Commissions_QuotaPageController.deleteRow();
        Commissions_QuotaPageController.selectAll();
        Commissions_QuotaPageController.MyMethod();
        Commissions_QuotaPageController.save();
        Commissions_QuotaPageController.Cancel();
        // Commissions_QuotaPageController.kickerLogic();
       
        //Commissions_QuotaPageController.CalculateLogic(true,'AND',true);
        //Commissions_QuotaPageController.CalculateLogic(true,'OR',true);
        Test.stopTest();       
         
    }
    
    

    public static testmethod void testmethod3(){
    
        list<Commission_Products__c> cmpcslist = new list<Commission_Products__c>();
    CommissionTeams__c  CommissionTeams = new CommissionTeams__c(Name = 'MANAGERS_TEAM', Team_Name__c = 'Managers Team');
       insert commissionteams;
         CommissionTeams__c  CommissionTeamsBroker = new CommissionTeams__c(Name = 'BROKER_REGIONAL_DIRECTORS_TEAM', Team_Name__c = 'Broker Regional Directors Sales Team');
       insert CommissionTeamsBroker;
        Commission_Products__c cp = new Commission_Products__c ();
        cp.name = 'Top Producer CRM';
        cp.Other_Product_Name__c = 'Top Producer CRM';
       // Commission_Products__c cp1 = new Commission_Products__c ();
        //cp1.Other_Product_Name__c = 'List Hub Pro';
        cmpcslist.add(cp);
        //cmpcslist.add(cp1);
        insert cmpcslist;
        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;  
    Product_Family__c PF = new Product_Family__c(Name = 'Top Producer CRM' ,Family_Name__c = 'Prosoft');
        insert PF;
        Profile p = [select id from profile where name='System Administrator'];
        String WLVTeam = Commissions_Constants.WLV_TERRITORY_TEAM; 
    
        id rectypidp1 = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Retention Commission').getRecordTypeId();
        id rectypidp2 = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        
        // creating user
        User user1 = Commissions_TestDataFactory.createUser(null,p.id,null,'test15433@move.com','test15433@move.com',true,WLVTeam);
        User1.Managers__c = 'Heather Riggio';
        update user1;
        
        // creating period
        Period__c period = Commissions_TestDataFactory.Createperiod('Test',false,Date.today().toStartOfMonth());
        period.Tiger_Lead_Qualifier_Amount__c = 100.00;
        period.BOBAmount__c = 100.00;
        insert period;
    
        // creating quota
        Quota__c  QuotaHandler1 = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler1.Target_Amount__c = 1000;
        QuotaHandler1.User_Team__c =WLVTeam;
        QuotaHandler1.Current_Quater__c = '';
        QuotaHandler1.Is_Kicker__c = false;      
        insert QuotaHandler1;
    
        // creating product data
        Product2 prdctdata1 = Commissions_TestDataFactory.CreateProduct('Top Producer CRM',false);
        insert prdctdata1;
         Product2 prdctdata2 = Commissions_TestDataFactory.CreateProduct('Connection(SM) for Co-Brokerage',false);
        insert prdctdata2;
    
        // creating quota product
        Quota_Product__c quotaPrdct = new Quota_Product__c(Related_To_Quota__c = QuotaHandler1.id);
        quotaPrdct.Sales_Achivement__c = 10;
        quotaPrdct.Sales__c = 5;
        quotaPrdct.Unit_Achivement__c = 10;
        //quotaPrdct.Unit__c = 5;
        quotaPrdct.License_Achivement__c = 10.0;
        //quotaPrdct.License__c = 5.0;
        quotaPrdct.Product_Name__c = prdctdata1.id;
        insert quotaPrdct;        
      
        // creating asset
        Asset Asset1 = Commissions_TestDataFactory.CreateAsset(rectypidp2, user1.id,prdctdata1.id,false);
        Asset1.Name = 'FiveStreet Top Producer';
        Asset1.License_Tier__c = 10;
        Asset1.Renewal_Type__c = 'Auto';
        Asset1.Line_Type__c = 'Add';
        insert Asset1;
        
        // creating commissions
        Commission__c comm1 = Commissions_TestDataFactory.CreateComm(QuotaHandler1.id, prdctdata1.id,rectypidp1,null ,false);
        //comm1.Related_to_Asset__c = Asset1.id;
        comm1.Line_Type__c = 'Add';
        comm1.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c = 10.0;
        comm1.other_product__c = 'Top Producer CRM';
        comm1.Signing_AE__c = user1.id;
        comm1.Product__c = prdctdata1.Id;
        insert comm1;  

        PageReference pageRef = page.Commissions_QuotaPageController;
        Test.setCurrentPage(pageRef);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(QuotaHandler1);
        ApexPages.currentPage().getParameters().put('Id',QuotaHandler1.id); 
    
        Commissions_QuotaPageController Commissions_QuotaPageController = new Commissions_QuotaPageController(sc); 
 
      Test.startTest(); 
        Commissions_QuotaPageController.addrow();
        Commissions_QuotaPageController.deleteRow();
        Commissions_QuotaPageController.selectAll();
        Commissions_QuotaPageController.MyMethod();
        Commissions_QuotaPageController.save();
        Commissions_QuotaPageController.Cancel();
        //Commissions_QuotaPageController.kickerLogic();
       
        //Commissions_QuotaPageController.CalculateLogic(true,'AND',true);
        //Commissions_QuotaPageController.CalculateLogic(true,'OR',true);
        Test.stopTest();       
         
    }
    public static testMethod void testMethod5() {
    CommissionTeams__c  CommissionTeams = new CommissionTeams__c(Name = 'MANAGERS_TEAM', Team_Name__c = 'Managers Team');
       insert commissionteams;
         CommissionTeams__c  CommissionTeamsBroker = new CommissionTeams__c(Name = 'BROKER_REGIONAL_DIRECTORS_TEAM', Team_Name__c = 'Broker Regional Directors Sales Team');
       insert CommissionTeamsBroker;
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;  
    
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
        insert period;
    
        // creating quota
        Quota__c  QuotaHandler1 = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler1.Target_Amount__c = 1000;
        QuotaHandler1.User_Team__c =WLVTeam;
        QuotaHandler1.Current_Quater__c = '';
        QuotaHandler1.Is_Kicker__c = false;      
        insert QuotaHandler1;
    
        // creating product data
        Product2 prdctdata1 = Commissions_TestDataFactory.CreateProduct('Top Producer FiveStreet',false);
        insert prdctdata1;
    
        // creating quota product
        Quota_Product__c quotaPrdct = new Quota_Product__c(Product_Name__c = prdctdata1.id,Related_To_Quota__c = QuotaHandler1.id);
        quotaPrdct.Sales_Achivement__c = 10;
        quotaPrdct.Sales__c = 5;
        quotaPrdct.Unit_Achivement__c = 10;
        quotaPrdct.Unit__c = 5;
        quotaPrdct.License_Achivement__c = 10.0;
        quotaPrdct.License__c = 5.0;
        insert quotaPrdct;        
      
        // creating asset
        Asset Asset1 = Commissions_TestDataFactory.CreateAsset(rectypidp2, user1.id,prdctdata1.id,false);
        Asset1.Name = 'FiveStreet Top Producer';
        Asset1.License_Tier__c = 10;
        Asset1.Renewal_Type__c = 'Auto';
        insert Asset1;
        
        // creating commissions
        Commission__c comm1 = Commissions_TestDataFactory.CreateComm(QuotaHandler1.id, prdctdata1.id,rectypidp1,null ,false);
        comm1.Related_to_Asset__c = Asset1.id;
        comm1.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c = 10.0;
        insert comm1;  

        PageReference pageRef = page.Commissions_QuotaPageControllerRead;
        Test.setCurrentPage(pageRef);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(QuotaHandler1);
        ApexPages.currentPage().getParameters().put('Id',QuotaHandler1.id); 
    
        Commissions_QuotaPageControllerRead Commissions_QuotaPageController = new Commissions_QuotaPageControllerRead(sc); 
       
    /*  Test.startTest(); 
        Commissions_QuotaPageController.AddMoreProducts();
        Commissions_QuotaPageController.myMethod();
        
     Test.stopTest();     
*/  
  }
}