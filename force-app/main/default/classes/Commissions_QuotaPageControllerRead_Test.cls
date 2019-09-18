@isTest
public class Commissions_QuotaPageControllerRead_Test{
    
   public static testMethod void testMethod1() {
    
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
           
  }
}