@isTest
public class Commissions_QuotaPayoutCalculation_Test {         
    public static testMethod void mainTest1(){
        Profile p = [select id from profile where name='System Administrator'];
        String ManagerTeam = Commissions_Constants.MANAGERS_TEAM;
        String WLVTeam = Commissions_Constants.WLV_TERRITORY_TEAM;       
                
        Commissions_TestDataFactory CT = new Commissions_TestDataFactory();
        User user1 = Commissions_TestDataFactory.createUser(null,p.id,null,'test15410@move.com','test15410@move.com',true,WLVTeam);
        User1.Managers__c = 'Heather Riggio';
        update user1;
        User user2 = Commissions_TestDataFactory.createUser(null,p.id,null,'TestUser124611@mail.com','test15141@move.com',True,ManagerTeam);
        User2.LastName ='Riggio';
        User2.FirstName='Heather';
        update User2;
        
        User user3 = Commissions_TestDataFactory.createUser(null,p.id,null,'TestUser124621@mail.com','test154123@move.com',True,WLVTeam);
        User3.Managers__c = Commissions_Constants.NEW_HIRE_TEAM;
        user3.Payout_Rate_Month_1__c = 10;
        update User3;
       
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
         
        Period__c period = Commissions_TestDataFactory.Createperiod('Test',false,Date.today().toStartOfMonth());
        period.Tiger_Lead_Qualifier_Amount__c = 100.00;
        period.BOBAmount__c = 100.00;
        insert period;
        
         Product2 prdctdata = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata.ProductCode ='ADVANTAGE';
        insert prdctdata; 
         
                         
        Product2 prdctdata2 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata2.ProductCode ='COBROKE';
        insert prdctdata2; 
                        
        Product2 prdctdata3 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata3.ProductCode ='DACAMPAIGN';
        insert prdctdata3; 
                        
        Product2 prdctdata4 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata4.ProductCode ='ADVANTAGE';
        insert prdctdata4; 
                        
        Product2 prdctdata5 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata5.ProductCode ='DIGITALAGENT';
        insert prdctdata5; 
                        
        Product2 prdctdata6 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata6.ProductCode ='DOMAINNAME';
        insert prdctdata6; 
                        
        Product2 prdctdata7 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata7.ProductCode ='FEATCMA';
        insert prdctdata7; 
                        
        Product2 prdctdata8 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata8.ProductCode ='FEATDISP';
        insert prdctdata8; 
                        
        Product2 prdctdata9 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata9.ProductCode ='FEATHOMES';
        insert prdctdata9; 
        
        Product2 prdctdata10 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata10.ProductCode ='FIVESTREET';
        insert prdctdata10;
        Product2 prdctdata11 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata11.ProductCode ='LISTHUBPRO';
        insert prdctdata11;
        Product2 prdctdata12 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata12.ProductCode ='MRKTBUILD';
        insert prdctdata12;
        Product2 prdctdata13 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata13.ProductCode ='SELLERLEAD';
        insert prdctdata13;
        Product2 prdctdata14 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata14.ProductCode ='SELLERLEADBUNDLE';
        insert prdctdata14;
        Product2 prdctdata15 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata15.ProductCode ='SHOWCASE';
        insert prdctdata15;
        Product2 prdctdata16 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata16.ProductCode ='SIGNRIDER';
        insert prdctdata16;
        Product2 prdctdata17 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata17.ProductCode ='STANDLIST';
        insert prdctdata17;
        Product2 prdctdata18 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata18.ProductCode ='TOPCRM';
        insert prdctdata18;
        Product2 prdctdata19 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata19.ProductCode ='TOPIDX';
        insert prdctdata19;
        Product2 prdctdata20 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata20.ProductCode ='TOPMRKSNP';
        insert prdctdata20;
        Product2 prdctdata21 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata21.ProductCode ='TOPWEB';
        insert prdctdata21;
        Product2 prdctdata22 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata22.ProductCode ='TOPWEBFEE';
        insert prdctdata22;
        Product2 prdctdata23 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata23.ProductCode ='TRKPHNMBR';
        insert prdctdata23;
        Product2 prdctdata24 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata24.ProductCode ='TURBO';
        insert prdctdata24;
        Product2 prdctdata25 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata25.ProductCode ='WEBSITE';
        insert prdctdata25; 
        Product2 prdctdata26 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata26.ProductCode ='WEBSITEFEE';
        insert prdctdata26; 
        
        Product2 prdctdata27 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata27.ProductCode ='REESIO';
        insert prdctdata27;
        
        
        Product2 prdctdata28 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata28.ProductCode ='RSRESPOND';
        insert prdctdata28; 
        
        
        
        Product2 prdctdata29 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata29.ProductCode ='MEDIABUY';
        insert prdctdata29; 
        
        Product2 prdctdata30 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata30.ProductCode ='RSCONNECT';
        insert prdctdata30; 
        
        
        Product2 prdctdata31 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata31.ProductCode ='RSTRANSACT';
        insert prdctdata31;
        
        Product2 prdctdata32 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata32.ProductCode ='LOCALEXPERT';
        insert prdctdata32;
         
        Quota__c  QuotaHandler1 = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler1.Target_Amount__c = 1000;
        QuotaHandler1.User_Team__c =WLVTeam;
        QuotaHandler1.Current_Quater__c = '';
        QuotaHandler1.Is_Kicker__c = false;      
        insert QuotaHandler1;
        
        Quota__c  QuotaHandler2 = Commissions_TestDataFactory.CreateQuota(user2.id,period.id,false);
        QuotaHandler2.Target_Amount__c = 1000;
        QuotaHandler2.User_Team__c =ManagerTeam;        
        QuotaHandler2.Current_Quater__c = 'Q1';
        insert QuotaHandler2;
        
        Quota__c  QuotaHandler3 = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler3.Target_Amount__c = 1000;
        QuotaHandler3.User_Team__c =WLVTeam;
        QuotaHandler3.Current_Quater__c = '';
        QuotaHandler3.Is_Kicker__c = true;      
        insert QuotaHandler3;
        
        Quota__c  QuotaHandler4 = Commissions_TestDataFactory.CreateQuota(user2.id,period.id,false);
        QuotaHandler4.Target_Amount__c = 1000;
        QuotaHandler4.User_Team__c =ManagerTeam;        
        QuotaHandler4.Current_Quater__c = 'Q1';
        insert QuotaHandler4;
        Quota__c  QuotaHandler5 = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler5.Target_Amount__c = 1000;
        QuotaHandler5.User_Team__c =WLVTeam;
        QuotaHandler5.Current_Quater__c = '';
        QuotaHandler5.Is_Kicker__c = true;      
        insert QuotaHandler5;
        Quota__c  QuotaHandler6 = Commissions_TestDataFactory.CreateQuota(user3.id,period.id,false);
        QuotaHandler6.Target_Amount__c = 1000;
        QuotaHandler6.User_Team__c =Commissions_Constants.NEW_HIRE_TEAM;
        QuotaHandler6.Current_Quater__c = '';
        QuotaHandler6.Is_Kicker__c = true;      
        insert QuotaHandler6;  
        id rectypidp1 = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get('Heather Riggio').getRecordTypeId();
        id rectypidp2 = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(WLVTeam).getRecordTypeId();   
        
        Payout__c pa1= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa1.Period__c = period.Id;
        pa1.Commissionable__c = 10.0;
        pa1.Product_Name__c = prdctdata.id;
        pa1.Sale_Type__c = 'New';        
        pa1.After_Optimization__c=false;
        insert pa1; 
        
        Payout__c pa2= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa2.Period__c = period.Id;
        pa2.Commissionable__c = 10.0;
        pa2.Product_Name__c = prdctdata2.id;
        pa2.Sale_Type__c = 'New';  
        pa2.After_Optimization__c=false;        
        insert pa2;
        
        Payout__c pa3= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa3.Period__c = period.Id;
        pa3.Commissionable__c = 10.0;
        pa3.Product_Name__c = prdctdata3.id;
        pa3.Sale_Type__c = 'New';        
        pa3.After_Optimization__c=false;        
        insert pa3;
        
        Payout__c pa4= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa4.Period__c = period.Id;
        pa4.Commissionable__c = 10.0;
        pa4.Product_Name__c = prdctdata4.id;
        pa4.Sale_Type__c = 'New';        
        pa4.After_Optimization__c=false;        
        insert pa4;
        
        Payout__c pa5= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa5.Period__c = period.Id;
        pa5.Commissionable__c = 10.0;
        pa5.Product_Name__c = prdctdata5.id;
        pa5.Sale_Type__c = 'New';        
        pa5.After_Optimization__c=false;        
        insert pa5;
        
        Payout__c pa6= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa6.Period__c = period.Id;
        pa6.Commissionable__c = 10.0;
        pa6.Product_Name__c = prdctdata6.id;
        pa6.Sale_Type__c = 'New';        
        pa6.After_Optimization__c=false;        
        insert pa6; 
        
        Payout__c pa7= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa7.Period__c = period.Id;
        pa7.Commissionable__c = 10.0;
        pa7.Product_Name__c = prdctdata7.id;
        pa7.Sale_Type__c = 'New';        
        pa7.After_Optimization__c=false;        
        insert pa7;
        
        Payout__c pa8= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa8.Period__c = period.Id;
        pa8.Commissionable__c = 10.0;
        pa8.Product_Name__c = prdctdata8.id;
        pa8.Sale_Type__c = 'New';        
        pa8.After_Optimization__c=false;        
        insert pa8;
        
        Payout__c pa9= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa9.Period__c = period.Id;
        pa9.Commissionable__c = 10.0;
        pa9.Product_Name__c = prdctdata9.id;
        pa9.Sale_Type__c = 'New';        
        pa9.After_Optimization__c=false;        
        insert pa9;
        
        Payout__c pa10= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa10.Period__c = period.Id;
        pa10.Commissionable__c = 10.0;
        pa10.Product_Name__c = prdctdata10.id;
        pa10.Sale_Type__c = 'New';        
        pa10.After_Optimization__c=false;       
        insert pa10;
        
        Payout__c pa11= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa11.Period__c = period.Id;
        pa11.Commissionable__c = 10.0;
        pa11.Product_Name__c = prdctdata11.id;
        pa11.Sale_Type__c = 'New';        
        pa11.After_Optimization__c=false;       
        insert pa11; 
        
        Payout__c pa12= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa12.Period__c = period.Id;
        pa12.Commissionable__c = 10.0;
        pa12.Product_Name__c = prdctdata12.id;
        pa12.Sale_Type__c = 'New';        
        pa12.After_Optimization__c=false;       
        insert pa12;
        
        Payout__c pa13= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa13.Period__c = period.Id;
        pa13.Commissionable__c = 10.0;
        pa13.Product_Name__c = prdctdata13.id;
        pa13.Sale_Type__c = 'New';
        pa13.After_Optimization__c=false;                 
        insert pa13;
        
        Payout__c pa14= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa14.Period__c = period.Id;
        pa14.Commissionable__c = 10.0;
        pa14.Product_Name__c = prdctdata14.id;
        pa14.Sale_Type__c = 'New';        
        pa14.After_Optimization__c=false;       
        insert pa14;
        
        Payout__c pa15= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa15.Period__c = period.Id;
        pa15.Commissionable__c = 10.0;
        pa15.Product_Name__c = prdctdata15.id;
        pa15.Sale_Type__c = 'New';        
        pa15.After_Optimization__c=false;       
        insert pa15;
        
        Payout__c pa16= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa16.Period__c = period.Id;
        pa16.Commissionable__c = 10.0;
        pa16.Product_Name__c = prdctdata16.id;
        pa16.Sale_Type__c = 'New';        
        pa16.After_Optimization__c=false;       
          insert pa16; 
        
        Payout__c pa17= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa17.Period__c = period.Id;
        pa17.Commissionable__c = 10.0;
        pa17.Product_Name__c = prdctdata17.id;
        pa17.Sale_Type__c = 'New'; 
        pa17.After_Optimization__c=false;               
        insert pa17;
        
        Payout__c pa18= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa18.Period__c = period.Id;
        pa18.Commissionable__c = 10.0;
        pa18.Product_Name__c = prdctdata18.id;
        pa18.Sale_Type__c = 'New';        
        pa18.After_Optimization__c=false;       
        insert pa18;
        
        Payout__c pa19= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa19.Period__c = period.Id;
        pa19.Commissionable__c = 10.0;
        pa19.Product_Name__c = prdctdata19.id;
        pa19.Sale_Type__c = 'New';        
        pa19.After_Optimization__c=false;       
        insert pa19;
        
        Payout__c pa20= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa20.Period__c = period.Id;
        pa20.Commissionable__c = 10.0;
        pa20.Product_Name__c = prdctdata20.id;
        pa20.Sale_Type__c = 'New';        
        pa20.After_Optimization__c=false;
        insert pa20;
        
        Payout__c pa21= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa21.Period__c = period.Id;
        pa21.Commissionable__c = 10.0;
        pa21.Product_Name__c = prdctdata21.id;
        pa21.Sale_Type__c = 'New'; 
        pa21.After_Optimization__c=false;       
        insert pa21;
        
        Payout__c pa22= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa22.Period__c = period.Id;
        pa22.Commissionable__c = 10.0;
        pa22.Product_Name__c = prdctdata22.id;
        pa22.Sale_Type__c = 'New';        
        pa22.After_Optimization__c=false;
        insert pa22;
        
        Payout__c pa23= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa23.Period__c = period.Id;
        pa23.Commissionable__c = 10.0;
        pa23.Product_Name__c = prdctdata23.id;
        pa23.Sale_Type__c = 'New';        
        pa23.After_Optimization__c=false;
        insert pa23;
        
        Payout__c pa24= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa24.Period__c = period.Id;
        pa24.Commissionable__c = 10.0;
        pa24.Product_Name__c = prdctdata24.id;
        pa24.Sale_Type__c = 'New';        
        pa24.After_Optimization__c=false;
        insert pa24;
        
        Payout__c pa25= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa25.Period__c = period.Id;
        pa25.Commissionable__c = 10.0;
        pa25.Product_Name__c = prdctdata25.id;
        pa25.Sale_Type__c = 'New';        
        pa25.After_Optimization__c=false;
        insert pa25; 
        
        Payout__c pa26= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa26.Period__c = period.Id;
        pa26.Commissionable__c = 10.0;
        pa26.Product_Name__c = prdctdata26.id;
        pa26.Sale_Type__c = 'New';        
        pa26.After_Optimization__c=false;
        insert pa26;
     
        Payout__c pa27= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa27.Period__c = period.Id;
        pa27.Commissionable__c = 10.0;
        pa27.Product_Name__c = prdctdata27.id;
        pa27.Sale_Type__c = 'New';        
        pa27.After_Optimization__c=false;
        insert pa27;
        
        
        Payout__c pa28= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa28.Period__c = period.Id;
        pa28.Commissionable__c = 10.0;
        pa28.Product_Name__c = prdctdata28.id;
        pa28.Sale_Type__c = 'New';        
        pa28.After_Optimization__c=false;
        insert pa28;
        
        
        Payout__c pa29= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa29.Period__c = period.Id;
        pa29.Commissionable__c = 10.0;
        pa29.Product_Name__c = prdctdata29.id;
        pa29.Sale_Type__c = 'New';        
        pa29.After_Optimization__c=false;
        insert pa29;
        
        
        Payout__c pa30= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa30.Period__c = period.Id;
        pa30.Commissionable__c = 10.0;
        pa30.Product_Name__c = prdctdata30.id;
        pa30.Sale_Type__c = 'New';        
        pa30.After_Optimization__c=false;
        insert pa30;
        
        Payout__c pa31= Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa31.Period__c = period.Id;
        pa31.Commissionable__c = 10.0;
        pa31.Product_Name__c = prdctdata31.id;
        pa31.Sale_Type__c = 'New';        
        pa31.After_Optimization__c=false;
        insert pa31;
        
        
        
        
        
        
        Set<Id> quotaAfterinsertIds = new Set<Id>();       
        quotaAfterinsertIds.add(QuotaHandler1.Id);   
        quotaAfterinsertIds.add(QuotaHandler2.Id);       
        quotaAfterinsertIds.add(QuotaHandler3.Id);
        quotaAfterinsertIds.add(QuotaHandler4.Id);       
        quotaAfterinsertIds.add(QuotaHandler5.Id); 
        quotaAfterinsertIds.add(QuotaHandler6.Id);
         
        Test.startTest();    
        Commissions_QuotaPayoutCalculation cq = new Commissions_QuotaPayoutCalculation();
        cq.QuotaPayoutCalculation(quotaAfterinsertIds);  
        Test.stopTest();
    }
      
    public static testMethod void mainTest2(){
        Profile p = [select id from profile where name='System Administrator'];
        String ManagerTeam = Commissions_Constants.MANAGERS_TEAM;
        String WLVTeam = Commissions_Constants.WLV_TERRITORY_TEAM;       
        
        Commissions_TestDataFactory CT = new Commissions_TestDataFactory();
        User user1 = Commissions_TestDataFactory.createUser(null,p.id,null,'test15410@move.com','test15410@move.com',true,WLVTeam);
        User1.Managers__c = 'Heather Riggio';
        update user1;
        User user2 = Commissions_TestDataFactory.createUser(null,p.id,null,'TestUser124611@mail.com','test15141@move.com',True,ManagerTeam);
        User2.LastName ='Riggio';
        User2.FirstName='Heather';
        update User2;
        
        User user3 = Commissions_TestDataFactory.createUser(null,p.id,null,'TestUser124621@mail.com','test154123@move.com',True,WLVTeam);
        User3.Managers__c = Commissions_Constants.NEW_HIRE_TEAM;
        user3.Payout_Rate_Month_1__c = 10;
        update User3;
       
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
        Period__c period = Commissions_TestDataFactory.Createperiod('Test',false,Date.today().toStartOfMonth());
        period.Tiger_Lead_Qualifier_Amount__c = 100.00;
        period.BOBAmount__c = 100.00;
        insert period;
        
        Product2 prdctdata = Commissions_TestDataFactory.CreateProduct('Name',false);        
        prdctdata.ProductCode ='ADVANTAGE';
        insert prdctdata; 
         
                         
        Product2 prdctdata2 = Commissions_TestDataFactory.CreateProduct('Name',false);      
        prdctdata2.ProductCode ='COBROKE';
        insert prdctdata2; 
                        
        Product2 prdctdata3 = Commissions_TestDataFactory.CreateProduct('Name',false);     
        prdctdata3.ProductCode ='DACAMPAIGN';
        insert prdctdata3; 
                        
        Product2 prdctdata4 = Commissions_TestDataFactory.CreateProduct('Name',false);        
        prdctdata4.ProductCode ='ADVANTAGE';
        insert prdctdata4; 
                        
        Product2 prdctdata5 = Commissions_TestDataFactory.CreateProduct('Name',false);      
        prdctdata5.ProductCode ='DIGITALAGENT';
        insert prdctdata5; 
                        
        Product2 prdctdata6 = Commissions_TestDataFactory.CreateProduct('Name',false);      
        prdctdata6.ProductCode ='DOMAINNAME';
        insert prdctdata6; 
                        
        Product2 prdctdata7 = Commissions_TestDataFactory.CreateProduct('Name',false);    
        prdctdata7.ProductCode ='FEATCMA';
        insert prdctdata7; 
                        
        Product2 prdctdata8 = Commissions_TestDataFactory.CreateProduct('Name',false);       
        prdctdata8.ProductCode ='FEATDISP';
        insert prdctdata8; 
                        
        Product2 prdctdata9 = Commissions_TestDataFactory.CreateProduct('Name',false);        
        prdctdata9.ProductCode ='FEATHOMES';
        insert prdctdata9; 
        
        Product2 prdctdata10 = Commissions_TestDataFactory.CreateProduct('Name',false);      
        prdctdata10.ProductCode ='FIVESTREET';
        insert prdctdata10;
        
        Product2 prdctdata11 = Commissions_TestDataFactory.CreateProduct('Name',false);       
        prdctdata11.ProductCode ='LISTHUBPRO';
        insert prdctdata11;
        
        Product2 prdctdata12 = Commissions_TestDataFactory.CreateProduct('Name',false);      
        prdctdata12.ProductCode ='MRKTBUILD';
        insert prdctdata12;
        Product2 prdctdata13 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata13.ProductCode ='SELLERLEAD';
        insert prdctdata13;
        Product2 prdctdata14 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata14.ProductCode ='SELLERLEADBUNDLE';
        insert prdctdata14;
        Product2 prdctdata15 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata15.ProductCode ='SHOWCASE';
        insert prdctdata15;
        Product2 prdctdata16 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata16.ProductCode ='SIGNRIDER';
        insert prdctdata16;
        Product2 prdctdata17 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata17.ProductCode ='STANDLIST';
        insert prdctdata17;
        Product2 prdctdata18 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata18.ProductCode ='TOPCRM';
        insert prdctdata18;
        Product2 prdctdata19 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata19.ProductCode ='TOPIDX';
        insert prdctdata19;
        Product2 prdctdata20 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata20.ProductCode ='TOPMRKSNP';
        insert prdctdata20;
        Product2 prdctdata21 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata21.ProductCode ='TOPWEB';
        insert prdctdata21;
        Product2 prdctdata22 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata22.ProductCode ='TOPWEBFEE';
        insert prdctdata22;
        Product2 prdctdata23 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata23.ProductCode ='TRKPHNMBR';
        insert prdctdata23;
        Product2 prdctdata24 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata24.ProductCode ='TURBO';
        insert prdctdata24;
        Product2 prdctdata25 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata25.ProductCode ='WEBSITE';
        insert prdctdata25; 
        Product2 prdctdata26 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata26.ProductCode ='WEBSITEFEE';
        insert prdctdata26; 
        
        Product2 prdctdata27 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata27.ProductCode ='REESIO';
        insert prdctdata27; 
        
        
        Product2 prdctdata28 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata28.ProductCode ='RSRESPOND';
        insert prdctdata28; 
        
        Product2 prdctdata29 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata29.ProductCode ='MEDIABUY';
        insert prdctdata29;
        
        
        Product2 prdctdata30 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata30.ProductCode ='RSCONNECT';
        insert prdctdata30; 
        
        
        Product2 prdctdata31 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata31.ProductCode ='RSTRANSACT';
        insert prdctdata31; 
        
        Quota__c  QuotaHandler1 = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler1.Target_Amount__c = 1000;
        QuotaHandler1.User_Team__c =WLVTeam;
        QuotaHandler1.Current_Quater__c = '';
        QuotaHandler1.Is_Kicker__c = false;      
        insert QuotaHandler1;
        
        Quota__c  QuotaHandler2 = Commissions_TestDataFactory.CreateQuota(user2.id,period.id,false);
        QuotaHandler2.Target_Amount__c = 1000;
        QuotaHandler2.User_Team__c =ManagerTeam;        
        QuotaHandler2.Current_Quater__c = 'Q1';
        insert QuotaHandler2;
        
        Quota__c  QuotaHandler3 = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler3.Target_Amount__c = 1000;
        QuotaHandler3.User_Team__c =WLVTeam;
        QuotaHandler3.Current_Quater__c = '';
        QuotaHandler3.Is_Kicker__c = true;      
        insert QuotaHandler3;
        
        Quota__c  QuotaHandler4 = Commissions_TestDataFactory.CreateQuota(user2.id,period.id,false);
        QuotaHandler4.Target_Amount__c = 1000;
        QuotaHandler4.User_Team__c =ManagerTeam;        
        QuotaHandler4.Current_Quater__c = 'Q1';
        insert QuotaHandler4;
        
        Quota__c  QuotaHandler5 = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler5.Target_Amount__c = 1000;
        QuotaHandler5.User_Team__c =WLVTeam;
        QuotaHandler5.Current_Quater__c = '';
        QuotaHandler5.Is_Kicker__c = true;      
        insert QuotaHandler5;
        
        Quota__c  QuotaHandler6 = Commissions_TestDataFactory.CreateQuota(user3.id,period.id,false);
        QuotaHandler6.Target_Amount__c = 1000;
        QuotaHandler6.User_Team__c =Commissions_Constants.NEW_HIRE_TEAM;
        QuotaHandler6.Current_Quater__c = '';
        QuotaHandler6.Is_Kicker__c = true;      
        insert QuotaHandler6;  
        id rectypidp1 = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get('Heather Riggio').getRecordTypeId();
        id rectypidp2 = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(WLVTeam).getRecordTypeId();   
        
        Payout__c pa1= Commissions_TestDataFactory.CreatePayout('New Sale with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa1.Period__c = period.Id;
        pa1.Commissionable__c = 10.0;
        pa1.Product_Name__c = prdctdata.id;
        pa1.Sale_Type__c = 'New';        
        pa1.After_Optimization__c=false;
        insert pa1; 
        
        Payout__c pa2= Commissions_TestDataFactory.CreatePayout('New Sale with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa2.Period__c = period.Id;
        pa2.Commissionable__c = 10.0;
        pa2.Product_Name__c = prdctdata2.id;
        pa2.Sale_Type__c = 'New';        
        pa2.After_Optimization__c=false;
        insert pa2;
        
        Payout__c pa3= Commissions_TestDataFactory.CreatePayout('New Sale with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa3.Period__c = period.Id;
        pa3.Commissionable__c = 10.0;
        pa3.Product_Name__c = prdctdata3.id;
        pa3.Sale_Type__c = 'New';        
        pa3.After_Optimization__c=false;
        insert pa3;
        
        Payout__c pa4= Commissions_TestDataFactory.CreatePayout('New Sale with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa4.Period__c = period.Id;
        pa4.Commissionable__c = 10.0;
        pa4.Product_Name__c = prdctdata4.id;
        pa4.Sale_Type__c = 'New';        
        pa4.After_Optimization__c=false;
        insert pa4;
        
        Payout__c pa5= Commissions_TestDataFactory.CreatePayout('New Sale with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa5.Period__c = period.Id;
        pa5.Commissionable__c = 10.0;
        pa5.Product_Name__c = prdctdata5.id;
        pa5.Sale_Type__c = 'New';        
        pa5.After_Optimization__c=false;
        insert pa5;
        
        Payout__c pa6= Commissions_TestDataFactory.CreatePayout('New Sale with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa6.Period__c = period.Id;
        pa6.Commissionable__c = 10.0;
        pa6.Product_Name__c = prdctdata6.id;
        pa6.Sale_Type__c = 'New';        
        pa6.After_Optimization__c=false;
        insert pa6; 
        
        Payout__c pa7= Commissions_TestDataFactory.CreatePayout('New Sale with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa7.Period__c = period.Id;
        pa7.Commissionable__c = 10.0;
        pa7.Product_Name__c = prdctdata7.id;
        pa7.Sale_Type__c = 'New';        
        pa7.After_Optimization__c=false;
        insert pa7;
        
        Payout__c pa8= Commissions_TestDataFactory.CreatePayout('New Sale with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa8.Period__c = period.Id;
        pa8.Commissionable__c = 10.0;
        pa8.Product_Name__c = prdctdata8.id;
        pa8.Sale_Type__c = 'New';        
        pa8.After_Optimization__c=false;
        insert pa8;
        
        Payout__c pa9= Commissions_TestDataFactory.CreatePayout('New Sale with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa9.Period__c = period.Id;
        pa9.Commissionable__c = 10.0;
        pa9.Product_Name__c = prdctdata9.id;
        pa9.Sale_Type__c = 'New';        
        pa9.After_Optimization__c=false;
        insert pa9;
        
        Payout__c pa10= Commissions_TestDataFactory.CreatePayout('New Sale with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa10.Period__c = period.Id;
        pa10.Commissionable__c = 10.0;
        pa10.Product_Name__c = prdctdata10.id;
        pa10.Sale_Type__c = 'New';        
        pa10.After_Optimization__c=false;
        insert pa10;
        
        Payout__c pa11= Commissions_TestDataFactory.CreatePayout('New Sale with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa11.Period__c = period.Id;
        pa11.Commissionable__c = 10.0;
        pa11.Product_Name__c = prdctdata11.id;
        pa11.Sale_Type__c = 'New';        
        pa11.After_Optimization__c=false;
        insert pa11; 
        
        Payout__c pa12= Commissions_TestDataFactory.CreatePayout('New Sale with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa12.Period__c = period.Id;
        pa12.Commissionable__c = 10.0;
        pa12.Product_Name__c = prdctdata12.id;
        pa12.Sale_Type__c = 'New';        
        pa12.After_Optimization__c=false;
        insert pa12;
        
        Payout__c pa13= Commissions_TestDataFactory.CreatePayout('New Sale with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa13.Period__c = period.Id;
        pa13.Commissionable__c = 10.0;
        pa13.Product_Name__c = prdctdata13.id;
        pa13.Sale_Type__c = 'New';        
        pa13.After_Optimization__c=false;
        insert pa13;
        
        Payout__c pa14= Commissions_TestDataFactory.CreatePayout('New Sale with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa14.Period__c = period.Id;
        pa14.Commissionable__c = 10.0;
        pa14.Product_Name__c = prdctdata14.id;
        pa14.Sale_Type__c = 'New';        
        pa14.After_Optimization__c=false;
        insert pa14;
        
        Payout__c pa15= Commissions_TestDataFactory.CreatePayout('New Sale with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa15.Period__c = period.Id;
        pa15.Commissionable__c = 10.0;
        pa15.Product_Name__c = prdctdata15.id;
        pa15.Sale_Type__c = 'New';    
        pa15.After_Optimization__c=false;       
        insert pa15;
        
        Payout__c pa16= Commissions_TestDataFactory.CreatePayout('New Sale with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa16.Period__c = period.Id;
        pa16.Commissionable__c = 10.0;
        pa16.Product_Name__c = prdctdata16.id;
        pa16.Sale_Type__c = 'New';        
        pa16.After_Optimization__c=false;
        insert pa16; 
        
        Payout__c pa17= Commissions_TestDataFactory.CreatePayout('New Sale with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa17.Period__c = period.Id;
        pa17.Commissionable__c = 10.0;
        pa17.Product_Name__c = prdctdata17.id;
        pa17.Sale_Type__c = 'New';        
        pa17.After_Optimization__c=false;
        insert pa17;
        
        Payout__c pa18= Commissions_TestDataFactory.CreatePayout('New Sale with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa18.Period__c = period.Id;
        pa18.Commissionable__c = 10.0;
        pa18.Product_Name__c = prdctdata18.id;
        pa18.Sale_Type__c = 'New';        
        pa18.After_Optimization__c=false;
        insert pa18;
        
        Payout__c pa19= Commissions_TestDataFactory.CreatePayout('New Sale with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa19.Period__c = period.Id;
        pa19.Commissionable__c = 10.0;
        pa19.Product_Name__c = prdctdata19.id;
        pa19.Sale_Type__c = 'New';        
        pa19.After_Optimization__c=false;
        insert pa19;
        
        Payout__c pa20= Commissions_TestDataFactory.CreatePayout('New Sale with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa20.Period__c = period.Id;
        pa20.Commissionable__c = 10.0;
        pa20.Product_Name__c = prdctdata20.id;
        pa20.Sale_Type__c = 'New';        
        pa20.After_Optimization__c=false;
        insert pa20;
        
        Payout__c pa21= Commissions_TestDataFactory.CreatePayout('New Sale with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa21.Period__c = period.Id;
        pa21.Commissionable__c = 10.0;
        pa21.Product_Name__c = prdctdata21.id;
        pa21.Sale_Type__c = 'New';    
        pa21.After_Optimization__c=false;       
        insert pa21;
        
        Payout__c pa22= Commissions_TestDataFactory.CreatePayout('New Sale with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa22.Period__c = period.Id;
        pa22.Commissionable__c = 10.0;
        pa22.Product_Name__c = prdctdata22.id;
        pa22.Sale_Type__c = 'New';        
        pa22.After_Optimization__c=false;
        insert pa22;
        
        Payout__c pa23= Commissions_TestDataFactory.CreatePayout('New Sale with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa23.Period__c = period.Id;
        pa23.Commissionable__c = 10.0;
        pa23.Product_Name__c = prdctdata23.id;
        pa23.Sale_Type__c = 'New';     
        pa23.After_Optimization__c=false;       
        insert pa23;
        
        Payout__c pa24= Commissions_TestDataFactory.CreatePayout('New Sale with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa24.Period__c = period.Id;
        pa24.Commissionable__c = 10.0;
        pa24.Product_Name__c = prdctdata24.id;
        pa24.Sale_Type__c = 'New';        
        pa24.After_Optimization__c=false;
        insert pa24;
        
        Payout__c pa25= Commissions_TestDataFactory.CreatePayout('New Sale with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa25.Period__c = period.Id;
        pa25.Commissionable__c = 10.0;
        pa25.Product_Name__c = prdctdata25.id;
        pa25.Sale_Type__c = 'New';     
        pa25.After_Optimization__c=false;       
        insert pa25; 
        
        Payout__c pa26= Commissions_TestDataFactory.CreatePayout('New Sale with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa26.Period__c = period.Id;
        pa26.Commissionable__c = 10.0;
        pa26.Product_Name__c = prdctdata26.id;
        pa26.Sale_Type__c = 'New';        
        pa26.After_Optimization__c=false;
        insert pa26;
        
        
        Payout__c pa27= Commissions_TestDataFactory.CreatePayout('New Sale with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa27.Period__c = period.Id;
        pa27.Commissionable__c = 10.0;
        pa27.Product_Name__c = prdctdata27.id;
        pa27.Sale_Type__c = 'New';        
        pa27.After_Optimization__c=false;
        insert pa27;
        
        
        Payout__c pa28= Commissions_TestDataFactory.CreatePayout('New Sale with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa28.Period__c = period.Id;
        pa28.Commissionable__c = 10.0;
        pa28.Product_Name__c = prdctdata28.id;
        pa28.Sale_Type__c = 'New';        
        pa28.After_Optimization__c=false;
        insert pa28;
        
        
        
        Payout__c pa29= Commissions_TestDataFactory.CreatePayout('New Sale with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa29.Period__c = period.Id;
        pa29.Commissionable__c = 10.0;
        pa29.Product_Name__c = prdctdata29.id;
        pa29.Sale_Type__c = 'New';        
        pa29.After_Optimization__c=false;
        insert pa29;
        
        
        Payout__c pa30= Commissions_TestDataFactory.CreatePayout('New Sale with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa30.Period__c = period.Id;
        pa30.Commissionable__c = 10.0;
        pa30.Product_Name__c = prdctdata30.id;
        pa30.Sale_Type__c = 'New';        
        pa30.After_Optimization__c=false;
        insert pa30;
     
        Payout__c pa31= Commissions_TestDataFactory.CreatePayout('New Sale with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa31.Period__c = period.Id;
        pa31.Commissionable__c = 10.0;
        pa31.Product_Name__c = prdctdata31.id;
        pa31.Sale_Type__c = 'New';        
        pa31.After_Optimization__c=false;
        insert pa31;
     
        Set<Id> quotaAfterinsertIds = new Set<Id>();       
        quotaAfterinsertIds.add(QuotaHandler1.Id);   
        quotaAfterinsertIds.add(QuotaHandler2.Id);       
        quotaAfterinsertIds.add(QuotaHandler3.Id);
        quotaAfterinsertIds.add(QuotaHandler4.Id);       
        quotaAfterinsertIds.add(QuotaHandler5.Id); 
        quotaAfterinsertIds.add(QuotaHandler6.Id);
         
        Test.startTest();    
        Commissions_QuotaPayoutCalculation cq = new Commissions_QuotaPayoutCalculation();
        cq.QuotaPayoutCalculation(quotaAfterinsertIds);  
        Test.stopTest();
    }
    public static testMethod void mainTest3(){
        Profile p = [select id from profile where name='System Administrator'];
        String ManagerTeam = Commissions_Constants.MANAGERS_TEAM;
        String WLVTeam = Commissions_Constants.WLV_TERRITORY_TEAM;       
        
        Commissions_TestDataFactory CT = new Commissions_TestDataFactory();
        User user1 = Commissions_TestDataFactory.createUser(null,p.id,null,'test15410@move.com','test15410@move.com',true,WLVTeam);
        User1.Managers__c = 'Heather Riggio';
        update user1;
        User user2 = Commissions_TestDataFactory.createUser(null,p.id,null,'TestUser124611@mail.com','test15141@move.com',True,ManagerTeam);
        User2.LastName ='Riggio';
        User2.FirstName='Heather';
        update User2;
        
        User user3 = Commissions_TestDataFactory.createUser(null,p.id,null,'TestUser124621@mail.com','test154123@move.com',True,WLVTeam);
        User3.Managers__c = Commissions_Constants.NEW_HIRE_TEAM;
        user3.Payout_Rate_Month_1__c = 10;
        update User3;
       
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
        Period__c period = Commissions_TestDataFactory.Createperiod('Test',false,Date.today().toStartOfMonth());
        period.Tiger_Lead_Qualifier_Amount__c = 100.00;
        period.BOBAmount__c = 100.00;
        insert period;
        
        Product2 prdctdata = Commissions_TestDataFactory.CreateProduct('Name',false);        
        prdctdata.ProductCode ='ADVANTAGE';
        insert prdctdata; 
         
                         
        Product2 prdctdata2 = Commissions_TestDataFactory.CreateProduct('Name',false);      
        prdctdata2.ProductCode ='COBROKE';
        insert prdctdata2; 
                        
        Product2 prdctdata3 = Commissions_TestDataFactory.CreateProduct('Name',false);     
        prdctdata3.ProductCode ='DACAMPAIGN';
        insert prdctdata3; 
                        
        Product2 prdctdata4 = Commissions_TestDataFactory.CreateProduct('Name',false);        
        prdctdata4.ProductCode ='ADVANTAGE';
        insert prdctdata4; 
                        
        Product2 prdctdata5 = Commissions_TestDataFactory.CreateProduct('Name',false);      
        prdctdata5.ProductCode ='DIGITALAGENT';
        insert prdctdata5; 
                        
        Product2 prdctdata6 = Commissions_TestDataFactory.CreateProduct('Name',false);      
        prdctdata6.ProductCode ='DOMAINNAME';
        insert prdctdata6; 
                        
        Product2 prdctdata7 = Commissions_TestDataFactory.CreateProduct('Name',false);    
        prdctdata7.ProductCode ='FEATCMA';
        insert prdctdata7; 
                        
        Product2 prdctdata8 = Commissions_TestDataFactory.CreateProduct('Name',false);       
        prdctdata8.ProductCode ='FEATDISP';
        insert prdctdata8; 
                        
        Product2 prdctdata9 = Commissions_TestDataFactory.CreateProduct('Name',false);        
        prdctdata9.ProductCode ='FEATHOMES';
        insert prdctdata9; 
        
        Product2 prdctdata10 = Commissions_TestDataFactory.CreateProduct('Name',false);      
        prdctdata10.ProductCode ='FIVESTREET';
        insert prdctdata10;
        
        Product2 prdctdata11 = Commissions_TestDataFactory.CreateProduct('Name',false);       
        prdctdata11.ProductCode ='LISTHUBPRO';
        insert prdctdata11;
        
        Product2 prdctdata12 = Commissions_TestDataFactory.CreateProduct('Name',false);      
        prdctdata12.ProductCode ='MRKTBUILD';
        insert prdctdata12;
        Product2 prdctdata13 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata13.ProductCode ='SELLERLEAD';
        insert prdctdata13;
        Product2 prdctdata14 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata14.ProductCode ='SELLERLEADBUNDLE';
        insert prdctdata14;
        Product2 prdctdata15 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata15.ProductCode ='SHOWCASE';
        insert prdctdata15;
        Product2 prdctdata16 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata16.ProductCode ='SIGNRIDER';
        insert prdctdata16;
        Product2 prdctdata17 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata17.ProductCode ='STANDLIST';
        insert prdctdata17;
        Product2 prdctdata18 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata18.ProductCode ='TOPCRM';
        insert prdctdata18;
        Product2 prdctdata19 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata19.ProductCode ='TOPIDX';
        insert prdctdata19;
        Product2 prdctdata20 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata20.ProductCode ='TOPMRKSNP';
        insert prdctdata20;
        Product2 prdctdata21 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata21.ProductCode ='TOPWEB';
        insert prdctdata21;
        Product2 prdctdata22 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata22.ProductCode ='TOPWEBFEE';
        insert prdctdata22;
        Product2 prdctdata23 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata23.ProductCode ='TRKPHNMBR';
        insert prdctdata23;
        Product2 prdctdata24 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata24.ProductCode ='TURBO';
        insert prdctdata24;
        Product2 prdctdata25 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata25.ProductCode ='WEBSITE';
        insert prdctdata25; 
        Product2 prdctdata26 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata26.ProductCode ='WEBSITEFEE';
        insert prdctdata26;
        
        Product2 prdctdata27 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata27.ProductCode ='REESIO';
        insert prdctdata27; 
        
        
        Product2 prdctdata28 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata28.ProductCode ='RSRESPOND';
        insert prdctdata28; 
        
        Product2 prdctdata29 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata29.ProductCode ='MEDIABUY';
        insert prdctdata29; 
        
        
        Product2 prdctdata30 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata30.ProductCode ='RSCONNECT';
        insert prdctdata30;
        
        
        Product2 prdctdata31 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata31.ProductCode ='RSTRANSACT';
        insert prdctdata31;
        
        Quota__c  QuotaHandler1 = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler1.Target_Amount__c = 1000;
        QuotaHandler1.User_Team__c =WLVTeam;
        QuotaHandler1.Current_Quater__c = '';
        QuotaHandler1.Is_Kicker__c = false;      
        insert QuotaHandler1;
        
        Quota__c  QuotaHandler2 = Commissions_TestDataFactory.CreateQuota(user2.id,period.id,false);
        QuotaHandler2.Target_Amount__c = 1000;
        QuotaHandler2.User_Team__c =ManagerTeam;        
        QuotaHandler2.Current_Quater__c = 'Q1';
        insert QuotaHandler2;
        
        Quota__c  QuotaHandler3 = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler3.Target_Amount__c = 1000;
        QuotaHandler3.User_Team__c =WLVTeam;
        QuotaHandler3.Current_Quater__c = '';
        QuotaHandler3.Is_Kicker__c = true;      
        insert QuotaHandler3;
        
        Quota__c  QuotaHandler4 = Commissions_TestDataFactory.CreateQuota(user2.id,period.id,false);
        QuotaHandler4.Target_Amount__c = 1000;
        QuotaHandler4.User_Team__c =ManagerTeam;        
        QuotaHandler4.Current_Quater__c = 'Q1';
        insert QuotaHandler4;
        Quota__c  QuotaHandler5 = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler5.Target_Amount__c = 1000;
        QuotaHandler5.User_Team__c =WLVTeam;
        QuotaHandler5.Current_Quater__c = '';
        QuotaHandler5.Is_Kicker__c = true;      
        insert QuotaHandler5;
        Quota__c  QuotaHandler6 = Commissions_TestDataFactory.CreateQuota(user3.id,period.id,false);
        QuotaHandler6.Target_Amount__c = 1000;
        QuotaHandler6.User_Team__c =Commissions_Constants.NEW_HIRE_TEAM;
        QuotaHandler6.Current_Quater__c = '';
        QuotaHandler6.Is_Kicker__c = true;      
        insert QuotaHandler6;  
        id rectypidp1 = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get('Heather Riggio').getRecordTypeId();
        id rectypidp2 = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(WLVTeam).getRecordTypeId();   
        
        Payout__c pa1= Commissions_TestDataFactory.CreatePayout('Renewal without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa1.Period__c = period.Id;
        pa1.Commissionable__c = 10.0;
        pa1.Product_Name__c = prdctdata.id;
        pa1.Sale_Type__c = 'Renewal';        
        pa1.After_Optimization__c=false;
        insert pa1; 
        
        Payout__c pa2= Commissions_TestDataFactory.CreatePayout('Renewal without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa2.Period__c = period.Id;
        pa2.Commissionable__c = 10.0;
        pa2.Product_Name__c = prdctdata2.id;
        pa2.Sale_Type__c = 'Renewal';        
        pa2.After_Optimization__c=false;
        insert pa2;
        
        Payout__c pa3= Commissions_TestDataFactory.CreatePayout('Renewal without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa3.Period__c = period.Id;
        pa3.Commissionable__c = 10.0;
        pa3.Product_Name__c = prdctdata3.id;
        pa3.Sale_Type__c = 'Renewal';        
        pa3.After_Optimization__c=false;
        insert pa3;
        
        Payout__c pa4= Commissions_TestDataFactory.CreatePayout('Renewal without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa4.Period__c = period.Id;
        pa4.Commissionable__c = 10.0;
        pa4.Product_Name__c = prdctdata4.id;
        pa4.Sale_Type__c = 'Renewal';        
        pa4.After_Optimization__c=false;
        insert pa4;
        
        Payout__c pa5= Commissions_TestDataFactory.CreatePayout('Renewal without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa5.Period__c = period.Id;
        pa5.Commissionable__c = 10.0;
        pa5.Product_Name__c = prdctdata5.id;
        pa5.Sale_Type__c = 'Renewal';        
        pa5.After_Optimization__c=false;
        insert pa5;
        
        Payout__c pa6= Commissions_TestDataFactory.CreatePayout('Renewal without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa6.Period__c = period.Id;
        pa6.Commissionable__c = 10.0;
        pa6.Product_Name__c = prdctdata6.id;
        pa6.Sale_Type__c = 'Renewal';        
        pa6.After_Optimization__c=false;
        insert pa6; 
        
        Payout__c pa7= Commissions_TestDataFactory.CreatePayout('Renewal without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa7.Period__c = period.Id;
        pa7.Commissionable__c = 10.0;
        pa7.Product_Name__c = prdctdata7.id;
        pa7.Sale_Type__c = 'Renewal';        
        pa7.After_Optimization__c=false;
        insert pa7;
        
        Payout__c pa8= Commissions_TestDataFactory.CreatePayout('Renewal without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa8.Period__c = period.Id;
        pa8.Commissionable__c = 10.0;
        pa8.Product_Name__c = prdctdata8.id;
        pa8.Sale_Type__c = 'Renewal';        
        pa8.After_Optimization__c=false;
        insert pa8;
        
        Payout__c pa9= Commissions_TestDataFactory.CreatePayout('Renewal without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa9.Period__c = period.Id;
        pa9.Commissionable__c = 10.0;
        pa9.Product_Name__c = prdctdata9.id;
        pa9.Sale_Type__c = 'Renewal';        
        pa9.After_Optimization__c=false;
        insert pa9;
        
        Payout__c pa10= Commissions_TestDataFactory.CreatePayout('Renewal without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa10.Period__c = period.Id;
        pa10.Commissionable__c = 10.0;
        pa10.Product_Name__c = prdctdata10.id;
        pa10.Sale_Type__c = 'Renewal';        
        pa10.After_Optimization__c=false;
        insert pa10;
        
        Payout__c pa11= Commissions_TestDataFactory.CreatePayout('Renewal without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa11.Period__c = period.Id;
        pa11.Commissionable__c = 10.0;
        pa11.Product_Name__c = prdctdata11.id;
        pa11.Sale_Type__c = 'Renewal';        
        pa11.After_Optimization__c=false;
        insert pa11; 
        
        Payout__c pa12= Commissions_TestDataFactory.CreatePayout('Renewal without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa12.Period__c = period.Id;
        pa12.Commissionable__c = 10.0;
        pa12.Product_Name__c = prdctdata12.id;
        pa12.Sale_Type__c = 'Renewal';        
        pa12.After_Optimization__c=false;
        insert pa12;
        
        Payout__c pa13= Commissions_TestDataFactory.CreatePayout('Renewal without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa13.Period__c = period.Id;
        pa13.Commissionable__c = 10.0;
        pa13.Product_Name__c = prdctdata13.id;
        pa13.Sale_Type__c = 'Renewal';        
        pa13.After_Optimization__c=false;
        insert pa13;
        
        Payout__c pa14= Commissions_TestDataFactory.CreatePayout('Renewal without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa14.Period__c = period.Id;
        pa14.Commissionable__c = 10.0;
        pa14.Product_Name__c = prdctdata14.id;
        pa14.Sale_Type__c = 'Renewal';        
        pa14.After_Optimization__c=false;
        insert pa14;
        
        Payout__c pa15= Commissions_TestDataFactory.CreatePayout('Renewal without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa15.Period__c = period.Id;
        pa15.Commissionable__c = 10.0;
        pa15.Product_Name__c = prdctdata15.id;
        pa15.Sale_Type__c = 'Renewal';        
        pa15.After_Optimization__c=false;
        insert pa15;
        
        Payout__c pa16= Commissions_TestDataFactory.CreatePayout('Renewal without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa16.Period__c = period.Id;
        pa16.Commissionable__c = 10.0;
        pa16.Product_Name__c = prdctdata16.id;
        pa16.Sale_Type__c = 'Renewal';        
        pa16.After_Optimization__c=false;
        insert pa16; 
        
        Payout__c pa17= Commissions_TestDataFactory.CreatePayout('Renewal without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa17.Period__c = period.Id;
        pa17.Commissionable__c = 10.0;
        pa17.Product_Name__c = prdctdata17.id;
        pa17.Sale_Type__c = 'Renewal';        
        pa17.After_Optimization__c=false;
        insert pa17;
        
        Payout__c pa18= Commissions_TestDataFactory.CreatePayout('Renewal without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa18.Period__c = period.Id;
        pa18.Commissionable__c = 10.0;
        pa18.Product_Name__c = prdctdata18.id;
        pa18.Sale_Type__c = 'Renewal';        
        pa18.After_Optimization__c=false;
        insert pa18;
        
        Payout__c pa19= Commissions_TestDataFactory.CreatePayout('Renewal without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa19.Period__c = period.Id;
        pa19.Commissionable__c = 10.0;
        pa19.Product_Name__c = prdctdata19.id;
        pa19.Sale_Type__c = 'Renewal';        
        pa19.After_Optimization__c=false;
        insert pa19;
        
        Payout__c pa20= Commissions_TestDataFactory.CreatePayout('Renewal without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa20.Period__c = period.Id;
        pa20.Commissionable__c = 10.0;
        pa20.Product_Name__c = prdctdata20.id;
        pa20.Sale_Type__c = 'Renewal';        
        pa20.After_Optimization__c=false;
        insert pa20;
        
        Payout__c pa21= Commissions_TestDataFactory.CreatePayout('Renewal without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa21.Period__c = period.Id;
        pa21.Commissionable__c = 10.0;
        pa21.Product_Name__c = prdctdata21.id;
        pa21.Sale_Type__c = 'Renewal';        
        pa21.After_Optimization__c=false;
        insert pa21;
        
        Payout__c pa22= Commissions_TestDataFactory.CreatePayout('Renewal without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa22.Period__c = period.Id;
        pa22.Commissionable__c = 10.0;
        pa22.Product_Name__c = prdctdata22.id;
        pa22.Sale_Type__c = 'Renewal';        
        pa22.After_Optimization__c=false;
        insert pa22;
        
        Payout__c pa23= Commissions_TestDataFactory.CreatePayout('Renewal without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa23.Period__c = period.Id;
        pa23.Commissionable__c = 10.0;
        pa23.Product_Name__c = prdctdata23.id;
        pa23.Sale_Type__c = 'Renewal';        
        pa23.After_Optimization__c=false;
        insert pa23;
        
        Payout__c pa24= Commissions_TestDataFactory.CreatePayout('Renewal without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa24.Period__c = period.Id;
        pa24.Commissionable__c = 10.0;
        pa24.Product_Name__c = prdctdata24.id;
        pa24.Sale_Type__c = 'Renewal';        
        pa24.After_Optimization__c=false;
        insert pa24;
        
        Payout__c pa25= Commissions_TestDataFactory.CreatePayout('Renewal without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa25.Period__c = period.Id;
        pa25.Commissionable__c = 10.0;
        pa25.Product_Name__c = prdctdata25.id;
        pa25.Sale_Type__c = 'Renewal';        
        pa25.After_Optimization__c=false;
        insert pa25; 
        
        Payout__c pa26= Commissions_TestDataFactory.CreatePayout('Renewal without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa26.Period__c = period.Id;
        pa26.Commissionable__c = 10.0;
        pa26.Product_Name__c = prdctdata26.id;
        pa26.Sale_Type__c = 'Renewal';   
        pa26.After_Optimization__c=false;
        insert pa26;

        Payout__c pa27= Commissions_TestDataFactory.CreatePayout('Renewal without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa27.Period__c = period.Id;
        pa27.Commissionable__c = 10.0;
        pa27.Product_Name__c = prdctdata27.id;
        pa27.Sale_Type__c = 'Renewal';   
        pa27.After_Optimization__c=false;
        insert pa27;
     
     
        Payout__c pa28= Commissions_TestDataFactory.CreatePayout('Renewal without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa28.Period__c = period.Id;
        pa28.Commissionable__c = 10.0;
        pa28.Product_Name__c = prdctdata28.id;
        pa28.Sale_Type__c = 'Renewal';   
        pa28.After_Optimization__c=false;
        insert pa28;
        
        
        Payout__c pa29= Commissions_TestDataFactory.CreatePayout('Renewal without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa29.Period__c = period.Id;
        pa29.Commissionable__c = 10.0;
        pa29.Product_Name__c = prdctdata29.id;
        pa29.Sale_Type__c = 'Renewal';   
        pa29.After_Optimization__c=false;
        insert pa29;
        
        
        
        Payout__c pa30= Commissions_TestDataFactory.CreatePayout('Renewal without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa30.Period__c = period.Id;
        pa30.Commissionable__c = 10.0;
        pa30.Product_Name__c = prdctdata30.id;
        pa30.Sale_Type__c = 'Renewal';   
        pa30.After_Optimization__c=false;
        insert pa30;
        
        
        
        Payout__c pa31= Commissions_TestDataFactory.CreatePayout('Renewal without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa31.Period__c = period.Id;
        pa31.Commissionable__c = 10.0;
        pa31.Product_Name__c = prdctdata31.id;
        pa31.Sale_Type__c = 'Renewal';   
        pa31.After_Optimization__c=false;
        insert pa31;
        
        Set<Id> quotaAfterinsertIds = new Set<Id>();       
        quotaAfterinsertIds.add(QuotaHandler1.Id);   
        quotaAfterinsertIds.add(QuotaHandler2.Id);       
        quotaAfterinsertIds.add(QuotaHandler3.Id);
        quotaAfterinsertIds.add(QuotaHandler4.Id);       
        quotaAfterinsertIds.add(QuotaHandler5.Id); 
        quotaAfterinsertIds.add(QuotaHandler6.Id);
         
        Test.startTest();    
        Commissions_QuotaPayoutCalculation cq = new Commissions_QuotaPayoutCalculation();
        cq.QuotaPayoutCalculation(quotaAfterinsertIds);  
        Test.stopTest();
    }
    public static testMethod void mainTest4(){
        Profile p = [select id from profile where name='System Administrator'];
        String ManagerTeam = Commissions_Constants.MANAGERS_TEAM;
        String WLVTeam = Commissions_Constants.WLV_TERRITORY_TEAM;       
        
        Commissions_TestDataFactory CT = new Commissions_TestDataFactory();
        User user1 = Commissions_TestDataFactory.createUser(null,p.id,null,'test15410@move.com','test15410@move.com',true,WLVTeam);
        User1.Managers__c = 'Heather Riggio';
        update user1;
        User user2 = Commissions_TestDataFactory.createUser(null,p.id,null,'TestUser124611@mail.com','test15141@move.com',True,ManagerTeam);
        User2.LastName ='Riggio';
        User2.FirstName='Heather';
        update User2;
        
        User user3 = Commissions_TestDataFactory.createUser(null,p.id,null,'TestUser124621@mail.com','test154123@move.com',True,WLVTeam);
        User3.Managers__c = Commissions_Constants.NEW_HIRE_TEAM;
        user3.Payout_Rate_Month_1__c = 10;
        update User3;
       
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
        Period__c period = Commissions_TestDataFactory.Createperiod('Test',false,Date.today().toStartOfMonth());
        period.Tiger_Lead_Qualifier_Amount__c = 100.00;
        period.BOBAmount__c = 100.00;
        insert period;
        
        Product2 prdctdata = Commissions_TestDataFactory.CreateProduct('Name',false);        
        prdctdata.ProductCode ='ADVANTAGE';
        insert prdctdata; 
         
                         
        Product2 prdctdata2 = Commissions_TestDataFactory.CreateProduct('Name',false);      
        prdctdata2.ProductCode ='COBROKE';
        insert prdctdata2; 
                        
        Product2 prdctdata3 = Commissions_TestDataFactory.CreateProduct('Name',false);     
        prdctdata3.ProductCode ='DACAMPAIGN';
        insert prdctdata3; 
                        
        Product2 prdctdata4 = Commissions_TestDataFactory.CreateProduct('Name',false);        
        prdctdata4.ProductCode ='ADVANTAGE';
        insert prdctdata4; 
                        
        Product2 prdctdata5 = Commissions_TestDataFactory.CreateProduct('Name',false);      
        prdctdata5.ProductCode ='DIGITALAGENT';
        insert prdctdata5; 
                        
        Product2 prdctdata6 = Commissions_TestDataFactory.CreateProduct('Name',false);      
        prdctdata6.ProductCode ='DOMAINNAME';
        insert prdctdata6; 
                        
        Product2 prdctdata7 = Commissions_TestDataFactory.CreateProduct('Name',false);    
        prdctdata7.ProductCode ='FEATCMA';
        insert prdctdata7; 
                        
        Product2 prdctdata8 = Commissions_TestDataFactory.CreateProduct('Name',false);       
        prdctdata8.ProductCode ='FEATDISP';
        insert prdctdata8; 
                        
        Product2 prdctdata9 = Commissions_TestDataFactory.CreateProduct('Name',false);        
        prdctdata9.ProductCode ='FEATHOMES';
        insert prdctdata9; 
        
        Product2 prdctdata10 = Commissions_TestDataFactory.CreateProduct('Name',false);      
        prdctdata10.ProductCode ='FIVESTREET';
        insert prdctdata10;
        
        Product2 prdctdata11 = Commissions_TestDataFactory.CreateProduct('Name',false);       
        prdctdata11.ProductCode ='LISTHUBPRO';
        insert prdctdata11;
        
        Product2 prdctdata12 = Commissions_TestDataFactory.CreateProduct('Name',false);      
        prdctdata12.ProductCode ='MRKTBUILD';
        insert prdctdata12;
        Product2 prdctdata13 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata13.ProductCode ='SELLERLEAD';
        insert prdctdata13;
        Product2 prdctdata14 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata14.ProductCode ='SELLERLEADBUNDLE';
        insert prdctdata14;
        Product2 prdctdata15 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata15.ProductCode ='SHOWCASE';
        insert prdctdata15;
        Product2 prdctdata16 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata16.ProductCode ='SIGNRIDER';
        insert prdctdata16;
        Product2 prdctdata17 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata17.ProductCode ='STANDLIST';
        insert prdctdata17;
        Product2 prdctdata18 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata18.ProductCode ='TOPCRM';
        insert prdctdata18;
        Product2 prdctdata19 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata19.ProductCode ='TOPIDX';
        insert prdctdata19;
        Product2 prdctdata20 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata20.ProductCode ='TOPMRKSNP';
        insert prdctdata20;
        Product2 prdctdata21 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata21.ProductCode ='TOPWEB';
        insert prdctdata21;
        Product2 prdctdata22 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata22.ProductCode ='TOPWEBFEE';
        insert prdctdata22;
        Product2 prdctdata23 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata23.ProductCode ='TRKPHNMBR';
        insert prdctdata23;
        Product2 prdctdata24 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata24.ProductCode ='TURBO';
        insert prdctdata24;
        Product2 prdctdata25 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata25.ProductCode ='WEBSITE';
        insert prdctdata25; 
        Product2 prdctdata26 = Commissions_TestDataFactory.CreateProduct('Name',false);
        //prdctdata.Commission_Category__c = 'CFCB';
        prdctdata26.ProductCode ='WEBSITEFEE';
        insert prdctdata26; 
        
        Quota__c  QuotaHandler1 = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler1.Target_Amount__c = 1000;
        QuotaHandler1.User_Team__c =WLVTeam;
        QuotaHandler1.Current_Quater__c = '';
        QuotaHandler1.Is_Kicker__c = false;      
        insert QuotaHandler1;
        
        Quota__c  QuotaHandler2 = Commissions_TestDataFactory.CreateQuota(user2.id,period.id,false);
        QuotaHandler2.Target_Amount__c = 1000;
        QuotaHandler2.User_Team__c =ManagerTeam;        
        QuotaHandler2.Current_Quater__c = 'Q1';
        insert QuotaHandler2;
        
        Quota__c  QuotaHandler3 = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler3.Target_Amount__c = 1000;
        QuotaHandler3.User_Team__c =WLVTeam;
        QuotaHandler3.Current_Quater__c = '';
        QuotaHandler3.Is_Kicker__c = true;      
        insert QuotaHandler3;
        
        Quota__c  QuotaHandler4 = Commissions_TestDataFactory.CreateQuota(user2.id,period.id,false);
        QuotaHandler4.Target_Amount__c = 1000;
        QuotaHandler4.User_Team__c =ManagerTeam;        
        QuotaHandler4.Current_Quater__c = 'Q1';
        insert QuotaHandler4;
        Quota__c  QuotaHandler5 = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,false);
        QuotaHandler5.Target_Amount__c = 1000;
        QuotaHandler5.User_Team__c =WLVTeam;
        QuotaHandler5.Current_Quater__c = '';
        QuotaHandler5.Is_Kicker__c = true;      
        insert QuotaHandler5;
        Quota__c  QuotaHandler6 = Commissions_TestDataFactory.CreateQuota(user3.id,period.id,false);
        QuotaHandler6.Target_Amount__c = 1000;
        QuotaHandler6.User_Team__c =Commissions_Constants.NEW_HIRE_TEAM;
        QuotaHandler6.Current_Quater__c = '';
        QuotaHandler6.Is_Kicker__c = true;      
        insert QuotaHandler6;  
        id rectypidp1 = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get('Heather Riggio').getRecordTypeId();
        id rectypidp2 = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(WLVTeam).getRecordTypeId();   
        
        Payout__c pa1= Commissions_TestDataFactory.CreatePayout('Renewal with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa1.Period__c = period.Id;
        pa1.Commissionable__c = 10.0;
        pa1.Product_Name__c = prdctdata.id;
        pa1.Sale_Type__c = 'Renewal'; 
        pa1.After_Optimization__c=false;       
        insert pa1; 
        
        Payout__c pa2= Commissions_TestDataFactory.CreatePayout('Renewal with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa2.Period__c = period.Id;
        pa2.Commissionable__c = 10.0;
        pa2.Product_Name__c = prdctdata2.id;
        pa2.Sale_Type__c = 'Renewal';   
        pa2.After_Optimization__c=false;     
        insert pa2;
        
        Payout__c pa3= Commissions_TestDataFactory.CreatePayout('Renewal with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa3.Period__c = period.Id;
        pa3.Commissionable__c = 10.0;
        pa3.Product_Name__c = prdctdata3.id;
        pa3.Sale_Type__c = 'Renewal';   
        pa3.After_Optimization__c=false;     
        insert pa3;
        
        Payout__c pa4= Commissions_TestDataFactory.CreatePayout('Renewal with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa4.Period__c = period.Id;
        pa4.Commissionable__c = 10.0;
        pa4.Product_Name__c = prdctdata4.id;
        pa4.Sale_Type__c = 'Renewal';        
        
        pa4.After_Optimization__c=false;
        insert pa4;
        
        Payout__c pa5= Commissions_TestDataFactory.CreatePayout('Renewal with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa5.Period__c = period.Id;
        pa5.Commissionable__c = 10.0;
        pa5.Product_Name__c = prdctdata5.id;
        pa5.Sale_Type__c = 'Renewal'; 
        pa5.After_Optimization__c=false;
               
        insert pa5;
        
        Payout__c pa6= Commissions_TestDataFactory.CreatePayout('Renewal with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa6.Period__c = period.Id;
        pa6.Commissionable__c = 10.0;
        pa6.Product_Name__c = prdctdata6.id;
        pa6.Sale_Type__c = 'Renewal';        
        pa6.After_Optimization__c=false;
        
        insert pa6; 
        
        Payout__c pa7= Commissions_TestDataFactory.CreatePayout('Renewal with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa7.Period__c = period.Id;
        pa7.Commissionable__c = 10.0;
        pa7.Product_Name__c = prdctdata7.id;
        pa7.Sale_Type__c = 'Renewal';        
        pa7.After_Optimization__c=false;
        
        insert pa7;
        
        Payout__c pa8= Commissions_TestDataFactory.CreatePayout('Renewal with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa8.Period__c = period.Id;
        pa8.Commissionable__c = 10.0;
        pa8.Product_Name__c = prdctdata8.id;
        pa8.Sale_Type__c = 'Renewal';        
        pa8.After_Optimization__c=false;
        
        insert pa8;
        
        Payout__c pa9= Commissions_TestDataFactory.CreatePayout('Renewal with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa9.Period__c = period.Id;
        pa9.Commissionable__c = 10.0;
        pa9.Product_Name__c = prdctdata9.id;
        pa9.Sale_Type__c = 'Renewal';        
        pa9.After_Optimization__c=false;
        
        insert pa9;
        
        Payout__c pa10= Commissions_TestDataFactory.CreatePayout('Renewal with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa10.Period__c = period.Id;
        pa10.Commissionable__c = 10.0;
        pa10.Product_Name__c = prdctdata10.id;
        pa10.Sale_Type__c = 'Renewal';        
        pa10.After_Optimization__c=false;
        
        insert pa10;
        
        Payout__c pa11= Commissions_TestDataFactory.CreatePayout('Renewal with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa11.Period__c = period.Id;
        pa11.Commissionable__c = 10.0;
        pa11.Product_Name__c = prdctdata11.id;
        pa11.Sale_Type__c = 'Renewal';        
        pa11.After_Optimization__c=false;
        
        insert pa11; 
        
        Payout__c pa12= Commissions_TestDataFactory.CreatePayout('Renewal with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa12.Period__c = period.Id;
        pa12.Commissionable__c = 10.0;
        pa12.Product_Name__c = prdctdata12.id;
        pa12.Sale_Type__c = 'Renewal';        
        pa12.After_Optimization__c=false;
        
        insert pa12;
        
        Payout__c pa13= Commissions_TestDataFactory.CreatePayout('Renewal with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa13.Period__c = period.Id;
        pa13.Commissionable__c = 10.0;
        pa13.Product_Name__c = prdctdata13.id;
        pa13.Sale_Type__c = 'Renewal';        
        pa13.After_Optimization__c=false;
        
        insert pa13;
        
        Payout__c pa14= Commissions_TestDataFactory.CreatePayout('Renewal with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa14.Period__c = period.Id;
        pa14.Commissionable__c = 10.0;
        pa14.Product_Name__c = prdctdata14.id;
        pa14.Sale_Type__c = 'Renewal';        
        pa14.After_Optimization__c=false;
        
        insert pa14;
        
        Payout__c pa15= Commissions_TestDataFactory.CreatePayout('Renewal with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa15.Period__c = period.Id;
        pa15.Commissionable__c = 10.0;
        pa15.Product_Name__c = prdctdata15.id;
        pa15.Sale_Type__c = 'Renewal';        
        pa15.After_Optimization__c=false;
        
        insert pa15;
        
        Payout__c pa16= Commissions_TestDataFactory.CreatePayout('Renewal with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa16.Period__c = period.Id;
        pa16.Commissionable__c = 10.0;
        pa16.Product_Name__c = prdctdata16.id;
        pa16.Sale_Type__c = 'Renewal';        
        pa16.After_Optimization__c=false;
        
        insert pa16; 
        
        Payout__c pa17= Commissions_TestDataFactory.CreatePayout('Renewal with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa17.Period__c = period.Id;
        pa17.Commissionable__c = 10.0;
        pa17.Product_Name__c = prdctdata17.id;
        pa17.Sale_Type__c = 'Renewal';        
        pa17.After_Optimization__c=false;
        
        insert pa17;
        
        Payout__c pa18= Commissions_TestDataFactory.CreatePayout('Renewal with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa18.Period__c = period.Id;
        pa18.Commissionable__c = 10.0;
        pa18.Product_Name__c = prdctdata18.id;
        pa18.Sale_Type__c = 'Renewal';        
        pa18.After_Optimization__c=false;
        
        insert pa18;
        
        Payout__c pa19= Commissions_TestDataFactory.CreatePayout('Renewal with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa19.Period__c = period.Id;
        pa19.Commissionable__c = 10.0;
        pa19.Product_Name__c = prdctdata19.id;
        pa19.Sale_Type__c = 'Renewal';        
        pa19.After_Optimization__c=false;
        
        insert pa19;
        
        Payout__c pa20= Commissions_TestDataFactory.CreatePayout('Renewal with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa20.Period__c = period.Id;
        pa20.Commissionable__c = 10.0;
        pa20.Product_Name__c = prdctdata20.id;
        pa20.Sale_Type__c = 'Renewal';        
        pa20.After_Optimization__c=false;
        
        insert pa20;
        
        Payout__c pa21= Commissions_TestDataFactory.CreatePayout('Renewal with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa21.Period__c = period.Id;
        pa21.Commissionable__c = 10.0;
        pa21.Product_Name__c = prdctdata21.id;
        pa21.Sale_Type__c = 'Renewal';        
        pa21.After_Optimization__c=false;
        
        insert pa21;
        
        Payout__c pa22= Commissions_TestDataFactory.CreatePayout('Renewal with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa22.Period__c = period.Id;
        pa22.Commissionable__c = 10.0;
        pa22.Product_Name__c = prdctdata22.id;
        pa22.Sale_Type__c = 'Renewal';        
        pa22.After_Optimization__c=false;
        
        insert pa22;
        
        Payout__c pa23= Commissions_TestDataFactory.CreatePayout('Renewal with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa23.Period__c = period.Id;
        pa23.Commissionable__c = 10.0;
        pa23.Product_Name__c = prdctdata23.id;
        pa23.Sale_Type__c = 'Renewal';        
        pa23.After_Optimization__c=false;
        
        insert pa23;
        
        Payout__c pa24= Commissions_TestDataFactory.CreatePayout('Renewal with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa24.Period__c = period.Id;
        pa24.Commissionable__c = 10.0;
        pa24.Product_Name__c = prdctdata24.id;
        pa24.Sale_Type__c = 'Renewal';        
        pa24.After_Optimization__c=false;
        
        insert pa24;
        
        Payout__c pa25= Commissions_TestDataFactory.CreatePayout('Renewal with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa25.Period__c = period.Id;
        pa25.Commissionable__c = 10.0;
        pa25.Product_Name__c = prdctdata25.id;
        pa25.Sale_Type__c = 'Renewal';        
        pa25.After_Optimization__c=false;
        
        insert pa25; 
        
        Payout__c pa26= Commissions_TestDataFactory.CreatePayout('Renewal with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa26.Period__c = period.Id;
        pa26.Commissionable__c = 10.0;
        pa26.Product_Name__c = prdctdata26.id;
        pa26.Sale_Type__c = 'Renewal';        
        pa26.After_Optimization__c=false;
        
        insert pa26;
     
        Set<Id> quotaAfterinsertIds = new Set<Id>();       
        quotaAfterinsertIds.add(QuotaHandler1.Id);   
        quotaAfterinsertIds.add(QuotaHandler2.Id);       
        quotaAfterinsertIds.add(QuotaHandler3.Id);
        quotaAfterinsertIds.add(QuotaHandler4.Id);       
        quotaAfterinsertIds.add(QuotaHandler5.Id); 
        quotaAfterinsertIds.add(QuotaHandler6.Id);
        
        Test.startTest();    
        Commissions_QuotaPayoutCalculation cq = new Commissions_QuotaPayoutCalculation();
        cq.QuotaPayoutCalculation(quotaAfterinsertIds);  
        
        Test.stopTest();
    }
    
     public static testMethod void mainTest5(){
        Profile p = [select id from profile where name='System Administrator'];
         
        String ManagerTeam = Commissions_Constants.MANAGERS_TEAM;
                 
        User user2 = Commissions_TestDataFactory.createUser(null,p.id,null,'TestUser124612@mail.com','test15142@move.com',True,ManagerTeam);
        user2.LastName ='Riggio';
        user2.FirstName='Heather';
        update user2;
         
        id rectypidp1 = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get('Heather Riggio').getRecordTypeId();
        id rectypidp2 = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(Commissions_Constants.COLLECTION_TEAM).getRecordTypeId();
        
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
         
        Period__c period = Commissions_TestDataFactory.Createperiod('Test',false,Date.today().toStartOfMonth());
        period.Tiger_Lead_Qualifier_Amount__c = 100.00;
        period.BOBAmount__c = 100.00;
        period.Agent_Sigh_In_AE__c = 50;
        period.Agent_Asset_Owner__c = 50;
        insert period;
        
        Product2 prdctdata = Commissions_TestDataFactory.CreateProduct('Name',false);        
        prdctdata.ProductCode ='ADVANTAGE';
        insert prdctdata; 
         
        Payout__c pa = Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp1, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa.Period__c = period.Id;
        pa.Commissionable__c = 10.0;
        pa.Product_Name__c = prdctdata.id;
        pa.Sale_Type__c = 'New';        
        pa.After_Optimization__c=false;       
        insert pa;
        
        Payout__c pa1 = Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp1, null, null,0.0,1.0,2.25,1.05,2.02,3.00,false);
        pa1.Period__c = period.Id;
        pa1.Commissionable__c = 10.0;
        pa1.Product_Name__c = prdctdata.id;
        pa1.Sale_Type__c = 'New';        
        pa1.After_Optimization__c=false;       
        insert pa1;
         
        Payout__c pa2 = Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp2, null, null,0.0,1.0,2.25,1.05,2.02,3.00,false);
        pa2.Period__c = period.Id;
        pa2.Commissionable__c = 10.0;
        pa2.Product_Name__c = prdctdata.id;
        pa2.Sale_Type__c = 'New';        
        pa2.After_Optimization__c=false;       
        insert pa2;
         
        Payout__c pa3 = Commissions_TestDataFactory.CreatePayout('New Sale without Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        pa3.Period__c = period.Id;
        pa3.Commissionable__c = 10.0;
        pa3.Product_Name__c = prdctdata.id;
        pa3.Sale_Type__c = 'New';        
        pa3.After_Optimization__c=false;       
        insert pa3;        
        
        //with qualifier payouts 
         
        Payout__c panq = Commissions_TestDataFactory.CreatePayout('New Sale with Qualifier',rectypidp1, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        panq.Period__c = period.Id;
        panq.Commissionable__c = 10.0;
        panq.Product_Name__c = prdctdata.id;
        panq.Sale_Type__c = 'New';        
        panq.After_Optimization__c=false;       
        insert panq;
        
        Payout__c panq1 = Commissions_TestDataFactory.CreatePayout('New Sale with Qualifier',rectypidp1, null, null,0.0,1.0,2.25,1.05,2.02,3.00,false);
        panq1.Period__c = period.Id;
        panq1.Commissionable__c = 10.0;
        panq1.Product_Name__c = prdctdata.id;
        panq1.Sale_Type__c = 'New';        
        panq1.After_Optimization__c=false;       
        insert panq1;
         
        Payout__c panq2 = Commissions_TestDataFactory.CreatePayout('New Sale with Qualifier',rectypidp2, null, null,0.0,1.0,2.25,1.05,2.02,3.00,false);
        panq2.Period__c = period.Id;
        panq2.Commissionable__c = 10.0;
        panq2.Product_Name__c = prdctdata.id;
        panq2.Sale_Type__c = 'New';        
        panq2.After_Optimization__c=false;       
        insert panq2;
         
        Payout__c panq3 = Commissions_TestDataFactory.CreatePayout('New Sale with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        panq3.Period__c = period.Id;
        panq3.Commissionable__c = 10.0;
        panq3.Product_Name__c = prdctdata.id;
        panq3.Sale_Type__c = 'New';        
        panq3.After_Optimization__c=false;       
        insert panq3;        
        
        //Renewal with qualifier payouts 
         
        Payout__c parq = Commissions_TestDataFactory.CreatePayout('Renewal with Qualifier',rectypidp1, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        parq.Period__c = period.Id;
        parq.Commissionable__c = 10.0;
        parq.Product_Name__c = prdctdata.id;
        parq.Sale_Type__c = 'Renewal';        
        parq.After_Optimization__c=false;       
        insert parq;
        
        Payout__c parq1 = Commissions_TestDataFactory.CreatePayout('Renewal with Qualifier',rectypidp1, null, null,0.0,1.0,2.25,1.05,2.02,3.00,false);
        parq1.Period__c = period.Id;
        parq1.Commissionable__c = 10.0;
        parq1.Product_Name__c = prdctdata.id;
        parq1.Sale_Type__c = 'Renewal';        
        parq1.After_Optimization__c=false;       
        insert parq1;
         
        Payout__c parq2 = Commissions_TestDataFactory.CreatePayout('Renewal with Qualifier',rectypidp2, null, null,0.0,1.0,2.25,1.05,2.02,3.00,false);
        parq2.Period__c = period.Id;
        parq2.Commissionable__c = 10.0;
        parq2.Product_Name__c = prdctdata.id;
        parq2.Sale_Type__c = 'Renewal';        
        parq2.After_Optimization__c=false;       
        insert parq2;
         
        Payout__c parq3 = Commissions_TestDataFactory.CreatePayout('Renewal with Qualifier',rectypidp2, 0.0, 1.0,null,null,2.25,1.05,2.02,3.00,false);
        parq3.Period__c = period.Id;
        parq3.Commissionable__c = 10.0;
        parq3.Product_Name__c = prdctdata.id;
        parq3.Sale_Type__c = 'Renewal';        
        parq3.After_Optimization__c=false;       
        insert parq3;    
         
        Quota__c  QuotaHandler1 = Commissions_TestDataFactory.CreateQuota(user2.id,period.id,false);
        QuotaHandler1.Target_Amount__c = 1000;
        QuotaHandler1.User_Team__c = ManagerTeam;        
        QuotaHandler1.Current_Quater__c = 'Q1';
        QuotaHandler1.Collection_Target_Amount__c = 500;
        QuotaHandler1.User__c = user2.Id;        
        QuotaHandler1.Manager_Total_Sale__c = 300;
        QuotaHandler1.Manager_Collection_Sale__c = 300;
        insert QuotaHandler1; 
         
        Quota__c  QuotaHandler2 = Commissions_TestDataFactory.CreateQuota(user2.id,period.id,false);
        QuotaHandler2.Target_Amount__c = 1000;
        QuotaHandler2.User_Team__c = ManagerTeam;        
        QuotaHandler2.Current_Quater__c = 'Q1';
        QuotaHandler2.Collection_Target_Amount__c = 0;
        QuotaHandler2.User__c = user2.Id;
        insert QuotaHandler2;
         
        Quota__c  QuotaHandler3 = Commissions_TestDataFactory.CreateQuota(user2.id,period.id,false);
        QuotaHandler3.Target_Amount__c = 500;
        QuotaHandler3.User_Team__c = Commissions_Constants.COLLECTION_TEAM;        
        QuotaHandler3.Current_Quater__c = 'Q1';
        QuotaHandler3.Collection_Target_Amount__c = 500;
        QuotaHandler3.User__c = user2.Id;
        QuotaHandler3.Manager_Total_Sale__c = 300;
        QuotaHandler3.Manager_Collection_Sale__c = 300;
        insert QuotaHandler3;
         
        Set<Id> quotaAfterinsertIds = new Set<Id>();       
        quotaAfterinsertIds.add(QuotaHandler1.Id);      
        quotaAfterinsertIds.add(QuotaHandler2.Id);
        quotaAfterinsertIds.add(QuotaHandler3.Id);  
        
         Commission__c comm1 = new Commission__c(Related_to_Quota__c = QuotaHandler1.Id);
         comm1.Collection_Commissionable_Amount__c = 300;
         comm1.RecordTypeId = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Collection Commission').getRecordTypeId();
         
         insert comm1;
         
        Test.startTest();    
            Commissions_QuotaPayoutCalculation cq = new Commissions_QuotaPayoutCalculation();
            cq.QuotaPayoutCalculation(quotaAfterinsertIds);  
        Test.stopTest();   
     }
    
 }