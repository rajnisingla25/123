@isTest
public class Commissions_KickerQualifierSwapCls_Test {
    
   public static testMethod void mainTest1(){
        
      //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;  
        
        Profile p = [select id from profile where name='System Administrator'];
        String ManagerTeam = Commissions_Constants.MANAGERS_TEAM;
        String WLVTeam = Commissions_Constants.WLV_TERRITORY_TEAM;      
        
        id rectypidp1 = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Retention Commission').getRecordTypeId();
        id rectypidp2 = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();

        User user1 = Commissions_TestDataFactory.createUser(null,p.id,null,'test154j@move.com','test154h@move.com',true,WLVTeam);
        User1.Managers__c = 'Heather Riggio';
        update user1;
  
        Period__c period = Commissions_TestDataFactory.Createperiod('Test',false,Date.today().toStartOfMonth());
        period.Tiger_Lead_Qualifier_Amount__c = 100.00;
        period.BOBAmount__c = 100.00;
        insert period;
       
        Quota__c  QuotaHandler1 = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler1.Target_Amount__c = 1000;
        QuotaHandler1.User_Team__c =WLVTeam;
        QuotaHandler1.Is_Kicker__c = TRUE;
        QuotaHandler1.RD_Team_Qualifier__c = false; 
       // QuotaHandler1.RecordTypeid = '012Z000000012s9';
        QuotaHandler1.TP_Units_Sold__c = 0;
        QuotaHandler1.No_Of_Tiger_Leads__c = 0;
        QuotaHandler1.is_kicker__c = false;
        QuotaHandler1.user__c = user1.id;
        insert QuotaHandler1;

       Product2 prdctdata1 = Commissions_TestDataFactory.CreateProduct('Product1',false);
        insert prdctdata1;
        
        Asset Asset1 = Commissions_TestDataFactory.CreateAsset(rectypidp2, user1.id,prdctdata1.id,false);
        Asset1.Renewal_Type__c = 'test';
        insert Asset1;
         
        Commission__c comm1 = Commissions_TestDataFactory.CreateComm(QuotaHandler1.id, prdctdata1.id,rectypidp1,null ,false);
        comm1.Related_to_Asset__c = Asset1.id;
        comm1.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c = 10.0;
        comm1.line_type__C = 'Renew';
        comm1.Signing_AE__c  = QuotaHandler1.user__c;
       // comm1.is_kicker__c = false;
        insert comm1;  

        Set<Id> quotaAfterinsertIds = new Set<Id>();
        quotaAfterinsertIds.add(QuotaHandler1.Id);  
        
        Test.startTest();    
        Commissions_KickerQualifierSwapClass ckq = new Commissions_KickerQualifierSwapClass();
        ckq.SwapMethod(quotaAfterinsertIds);  
        Test.stopTest();   
        
    }
            
    public static testMethod void mainTest2(){
        
      //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;  
        
        Profile p = [select id from profile where name='System Administrator'];
        String ManagerTeam = Commissions_Constants.MANAGERS_TEAM;
        String WLVTeam = Commissions_Constants.WLV_TERRITORY_TEAM;      
        
        id rectypidp1 = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Collection Commission').getRecordTypeId();
        id rectypidp2 = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();

        User user1 = Commissions_TestDataFactory.createUser(null,p.id,null,'test15d4@move.com','teste154@move.com',true,WLVTeam);
        User1.Managers__c = 'Heather Riggio';
        update user1;
  
        Period__c period = Commissions_TestDataFactory.Createperiod('Test',false,Date.today().toStartOfMonth());
        period.Tiger_Lead_Qualifier_Amount__c = 100.00;
        period.BOBAmount__c = 100.00;
        insert period;
       
        Quota__c  QuotaHandler1 = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler1.Target_Amount__c = 1000;
        QuotaHandler1.User_Team__c =WLVTeam;
        QuotaHandler1.Current_Quater__c = '';
        QuotaHandler1.TP_Units_Sold__c = 0;
        QuotaHandler1.No_Of_Tiger_Leads__c = 0;
        QuotaHandler1.RD_Team_Qualifier__c = true;
        QuotaHandler1.is_kicker__c = false;
        QuotaHandler1.user__c = user1.id;
        insert QuotaHandler1;

        Product2 prdctdata1 = Commissions_TestDataFactory.CreateProduct('Product1',false);
        insert prdctdata1;
        
        Asset Asset1 = Commissions_TestDataFactory.CreateAsset(rectypidp2, user1.id,prdctdata1.id,false);
        Asset1.Renewal_Type__c = 'Auto';
        insert Asset1;
        
        Commission__c comm1 = Commissions_TestDataFactory.CreateComm(QuotaHandler1.id, prdctdata1.id,rectypidp1,null ,false);
        comm1.Related_to_Asset__c = Asset1.id;
        comm1.CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c = 10.0;
        comm1.CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c = 10.0;
        comm1.line_type__C = 'add';
        comm1.Signing_AE__c  = QuotaHandler1.user__c;
        insert comm1;       

        Set<Id> quotaAfterinsertIds = new Set<Id>();
        quotaAfterinsertIds.add(QuotaHandler1.Id);  
        
        Test.startTest();    
        Commissions_KickerQualifierSwapClass ckq = new Commissions_KickerQualifierSwapClass();
        ckq.SwapMethod(quotaAfterinsertIds);  
        Test.stopTest();   
        
    }
    
    public static testMethod void mainTest3(){
        
      //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;  
        
        Profile p = [select id from profile where name='System Administrator'];
        String ManagerTeam = Commissions_Constants.MANAGERS_TEAM;
        String WLVTeam = Commissions_Constants.WLV_TERRITORY_TEAM;      
        
        id rectypidp1 = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Collection Commission').getRecordTypeId();
        id rectypidp2 = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();

        User user1 = Commissions_TestDataFactory.createUser(null,p.id,null,'terst154@move.com','tesrt154@move.com',true,WLVTeam);
        User1.Managers__c = 'Heather Riggio';
        update user1;
  
        Period__c period = Commissions_TestDataFactory.Createperiod('Test',false,Date.today().toStartOfMonth());
        period.Tiger_Lead_Qualifier_Amount__c = 100.00;
        period.BOBAmount__c = 0;
        period.Tiger_Lead_Qualifier_Amount__c = 0;
        insert period;
       
        Quota__c  QuotaHandler1 = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler1.Target_Amount__c = 1000;
        QuotaHandler1.User_Team__c ='Retention Team';
        QuotaHandler1.Current_Quater__c = '';   
        QuotaHandler1.RD_Team_Qualifier__c = TRUE;
       // QuotaHandler1.RecordTypeid = '012Z000000012s9';
        QuotaHandler1.user__c = user1.id;
        insert QuotaHandler1;

        Product2 prdctdata1 = Commissions_TestDataFactory.CreateProduct('Product1',false);
        insert prdctdata1;
        
        Asset Asset1 = Commissions_TestDataFactory.CreateAsset(rectypidp2, user1.id,prdctdata1.id,false);
        Asset1.Renewal_Type__c = 'test';
        insert Asset1;
        
        Commission__c comm1 = Commissions_TestDataFactory.CreateComm(QuotaHandler1.id, prdctdata1.id,rectypidp1,null ,false);
        comm1.Related_to_Asset__c = Asset1.id;
        comm1.CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c = 10.0;
        comm1.User_Team__c = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM;
        comm1.line_type__C = 'add';
        comm1.Signing_AE__c  = QuotaHandler1.user__c;
        insert comm1;       

        Set<Id> quotaAfterinsertIds = new Set<Id>();
        quotaAfterinsertIds.add(QuotaHandler1.Id);  
        System.debug('***quotaAfterinsertIds: '+ quotaAfterinsertIds);
        
        Commissions_KickerQualifierSwapClass ckq = new Commissions_KickerQualifierSwapClass();
        Test.startTest();
        ckq.SwapMethodBrokerRD(quotaAfterinsertIds);  
        Test.stopTest();   
        
    }
    
     public static testMethod void mainTest4(){
        
      //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;  
        
        Profile p = [select id from profile where name='System Administrator'];
        String ManagerTeam = Commissions_Constants.MANAGERS_TEAM;
        String WLVTeam = Commissions_Constants.WLV_TERRITORY_TEAM;      
        
        id rectypidp1 = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Retention Commission').getRecordTypeId();
        id rectypidp2 = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();

        User user1 = Commissions_TestDataFactory.createUser(null,p.id,null,'ttest154@move.com','ytest154@move.com',true,WLVTeam);
        User1.Managers__c = 'Heather Riggio';
        update user1;
  
        Period__c period = Commissions_TestDataFactory.Createperiod('Test',false,Date.today().toStartOfMonth());
        period.Tiger_Lead_Qualifier_Amount__c = 100.00;
        period.BOBAmount__c = 100.00;
        insert period;
       
        Quota__c  QuotaHandler1 = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler1.Target_Amount__c = 1000;
        QuotaHandler1.User_Team__c ='Retention Team';
        QuotaHandler1.Retention_Escalation__c = TRUE;   
        //QuotaHandler1.RecordTypeid = '012Z000000012s9';
        QuotaHandler1.user__c = user1.id;
        insert QuotaHandler1;

        Product2 prdctdata1 = Commissions_TestDataFactory.CreateProduct('Product1',false);
        insert prdctdata1;
        
        Asset Asset1 = Commissions_TestDataFactory.CreateAsset(rectypidp2, user1.id,prdctdata1.id,false);
        Asset1.Renewal_Type__c = 'Auto';
        insert Asset1;
        
        Commission__c comm1 = Commissions_TestDataFactory.CreateComm(QuotaHandler1.id, prdctdata1.id,rectypidp1,null ,false);
        comm1.Related_to_Asset__c = Asset1.id;
        comm1.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c = 10.0;
        comm1.User_Team__c = 'Retention Team';
        comm1.line_type__C = 'Renew';
        comm1.Signing_AE__c  = QuotaHandler1.user__c;
        insert comm1; 

        Set<Id> quotaAfterinsertIds = new Set<Id>();
        quotaAfterinsertIds.add(QuotaHandler1.Id);  
        
        Test.startTest();    
        Commissions_KickerQualifierSwapClass ckq = new Commissions_KickerQualifierSwapClass();
        ckq.swapMethodRetention(quotaAfterinsertIds);  
        Test.stopTest();    
        
    }
    
         public static testMethod void mainTest5(){
        
      //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;  
        
        Profile p = [select id from profile where name='System Administrator'];
        String ManagerTeam = Commissions_Constants.MANAGERS_TEAM;
        String WLVTeam = Commissions_Constants.WLV_TERRITORY_TEAM;      
        
        id rectypidp1 = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Retention Commission').getRecordTypeId();
        id rectypidp2 = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();

        User user1 = Commissions_TestDataFactory.createUser(null,p.id,null,'test4154@move.com','test1554@move.com',true,WLVTeam);
        User1.Managers__c = 'Heather Riggio';
        update user1;
  
        Period__c period = Commissions_TestDataFactory.Createperiod('Test',false,Date.today().toStartOfMonth());
        period.Tiger_Lead_Qualifier_Amount__c = 100.00;
        period.BOBAmount__c = 100.00;
        insert period;
       
        Quota__c  QuotaHandler1 = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler1.Target_Amount__c = 1000;
        QuotaHandler1.User_Team__c ='Retention Team';
        QuotaHandler1.Retention_Escalation__c = FALSE;   
        // QuotaHandler1.RecordTypeid = '012Z000000012s9';
        QuotaHandler1.user__c = user1.id;
        insert QuotaHandler1;
        
        Product2 prdctdata1 = Commissions_TestDataFactory.CreateProduct('Product1',false);
        insert prdctdata1;
        
        Asset Asset1 = Commissions_TestDataFactory.CreateAsset(rectypidp2, user1.id,prdctdata1.id,false);
        Asset1.Renewal_Type__c = 'Auto';
        insert Asset1;
        
        Commission__c comm1 = Commissions_TestDataFactory.CreateComm(QuotaHandler1.id, prdctdata1.id,rectypidp1,null ,false);
        comm1.Related_to_Asset__c = Asset1.id;
        comm1.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c = 10.0;
        comm1.User_Team__c = 'Retention Team';
        comm1.Related_to_Quota__c = QuotaHandler1.id;
        comm1.line_type__C = 'Add';
        comm1.Signing_AE__c  = QuotaHandler1.user__c;
        insert comm1; 

        Set<Id> quotaAfterinsertIds = new Set<Id>();
        quotaAfterinsertIds.add(QuotaHandler1.Id);  
        
        Test.startTest();    
        Commissions_KickerQualifierSwapClass ckq = new Commissions_KickerQualifierSwapClass();
        ckq.swapMethodRetention(quotaAfterinsertIds);  
        Test.stopTest();    
        
    }
    
  public static testMethod void mainTest6(){
        
      //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;  
        
        Profile p = [select id from profile where name='System Administrator'];
        String ManagerTeam = Commissions_Constants.MANAGERS_TEAM;
        String WLVTeam = Commissions_Constants.WLV_TERRITORY_TEAM;      
        
        id rectypidp1 = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Retention Commission').getRecordTypeId();
        id rectypidp2 = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();

        User user1 = Commissions_TestDataFactory.createUser(null,p.id,null,'test1549@move.com','test1504@move.com',true,WLVTeam);
        User1.Managers__c = 'Heather Riggio';
        update user1;
  
        Period__c period = Commissions_TestDataFactory.Createperiod('Test',false,Date.today().toStartOfMonth());
        period.Tiger_Lead_Qualifier_Amount__c = 100.00;
        period.BOBAmount__c = 100.00;
        insert period;
       
        Quota__c  QuotaHandler1 = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler1.Target_Amount__c = 1000;
        QuotaHandler1.User_Team__c =Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM ;
        QuotaHandler1.Retention_Escalation__c = FALSE;   
       // QuotaHandler1.RecordTypeid = '012Z000000012s9';
        QuotaHandler1.user__c = user1.id;
        insert QuotaHandler1;

        Product2 prdctdata1 = Commissions_TestDataFactory.CreateProduct('Product1',false);
        insert prdctdata1;
        
        Asset Asset1 = Commissions_TestDataFactory.CreateAsset(rectypidp2, user1.id,prdctdata1.id,false);
        Asset1.Renewal_Type__c = 'Auto';
        insert Asset1;
        
        Commission__c comm1 = Commissions_TestDataFactory.CreateComm(QuotaHandler1.id, prdctdata1.id,rectypidp1,null ,false);
        comm1.Related_to_Asset__c = Asset1.id;
        comm1.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c = 10.0;
        comm1.User_Team__c = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM ;
        comm1.line_type__C = 'Renew';
        comm1.Signing_AE__c  = QuotaHandler1.user__c;
        insert comm1; 
      
        Set<Id> quotaAfterinsertIds = new Set<Id>();
        quotaAfterinsertIds.add(QuotaHandler1.Id);  
        
        Test.startTest();    
        Commissions_KickerQualifierSwapClass ckq = new Commissions_KickerQualifierSwapClass();
        ckq.swapMethodRetention(quotaAfterinsertIds);  
        Test.stopTest();    
        
    }      
    public static testMethod void mainTest7(){
        
      //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;  
        
        Profile p = [select id from profile where name='System Administrator'];
        String ManagerTeam = Commissions_Constants.MANAGERS_TEAM;
        String WLVTeam = Commissions_Constants.WLV_TERRITORY_TEAM;      
        
        id rectypidp1 = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Retention Commission').getRecordTypeId();
        id rectypidp2 = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();

        User user1 = Commissions_TestDataFactory.createUser(null,p.id,null,'test1549@move.com','test1504@move.com',true,ManagerTeam );
        User1.Managers__c = 'Heather Riggio';
        update user1;
  
        Period__c period = Commissions_TestDataFactory.Createperiod('Test',false,Date.today().toStartOfMonth());
        period.Tiger_Lead_Qualifier_Amount__c = 100.00;
        period.BOBAmount__c = 100.00;
        insert period;
       
        Quota__c  QuotaHandler1 = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler1.Target_Amount__c = 1000;
        QuotaHandler1.User_Team__c =ManagerTeam ;
        QuotaHandler1.Retention_Escalation__c = FALSE;   
       // QuotaHandler1.RecordTypeid = '012Z000000012s9';
        QuotaHandler1.user__c = user1.id;
        insert QuotaHandler1;

        Product2 prdctdata1 = Commissions_TestDataFactory.CreateProduct('Product1',false);
        insert prdctdata1;
        
        Asset Asset1 = Commissions_TestDataFactory.CreateAsset(rectypidp2, user1.id,prdctdata1.id,false);
        Asset1.Renewal_Type__c = 'Auto';
        insert Asset1;
        
        Commission__c comm1 = Commissions_TestDataFactory.CreateComm(QuotaHandler1.id, prdctdata1.id,rectypidp1,null ,false);
        comm1.Related_to_Asset__c = Asset1.id;
        comm1.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c = 10.0;
        comm1.User_Team__c = ManagerTeam ;
        comm1.line_type__C = 'Renew';
        comm1.Signing_AE__c  = QuotaHandler1.user__c;
        insert comm1; 
        Commission__c comm2 = Commissions_TestDataFactory.CreateComm(QuotaHandler1.id, prdctdata1.id,rectypidp1,null ,false);
        comm2.Related_to_Asset__c = Asset1.id;
        comm2.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c = 10.0;
        comm2.User_Team__c = ManagerTeam ;
        comm2.line_type__C = 'Add';
        comm2.Signing_AE__c  = QuotaHandler1.user__c;
        insert comm2; 
      
        Set<Id> quotaAfterinsertIds = new Set<Id>();
        quotaAfterinsertIds.add(QuotaHandler1.Id);  
        
        Test.startTest();    
        Commissions_KickerQualifierSwapClass ckq = new Commissions_KickerQualifierSwapClass();
        ckq.swapMethodRetention(quotaAfterinsertIds);  
        Test.stopTest();    
        
    }      
   }