@isTest
public class preauthWaitlistRenewal_Test{
    public static testMethod void test1(){
        //creating test data
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;  
        insertWaitlistURLS();
        createStateAbbreviations();
        Account newAccount = createAccount();
        createAccountRelationship(newAccount);
        insertWaitlistDetails(newAccount);       
        stateAbbreviation();
        createWaitlists();
        paymentProfiles(newAccount);
        //start test
        Test.startTest();      
        PageReference pgr=page.PreAuthWaitListRenewal;
        pgr.getParameters().put('id',newAccount.id);
        Test.SetCurrentPage(pgr);
        ApexPages.StandardController sc = new ApexPages.standardController(newAccount);
        PreAuthWaitListRenewalExtn obj = new PreAuthWaitListRenewalExtn(sc);
        obj.getStates();
        obj.getCcLast4Digits();
        obj.getCities();
        obj.getCities2();
        obj.getCities3();
        obj.getCities4();
        obj.getCounties();
        obj.getLeadRoute();
        obj.getLeadRoutes();
        obj.getMarkets();
        obj.getPostalCodes();
        obj.getPostalCodes2();
        obj.getPostalCodes3();
        obj.getPostalCodes4();
        obj.getPreauthEffectiveDate();
        obj.getSelectedCities();
        obj.getSelectedCounties();
        obj.getSelectedPostalCodes();
        obj.getShowCity();
        obj.getShowPostalCode();
        obj.getState();
        obj.getTotalMaxSpend();
        obj.getStates();
        obj.getWaitListItems();
        obj.getWaitListProductType();
        obj.getWaitlistProductTypes();
            obj.refresh();
        obj.setCities2(null);
        obj.setCities3(null);
        obj.setCities4(null);
        obj.setPostalCodes2(null);
        obj.setPostalCodes3(null);
        obj.setPostalCodes4(null);
        obj.setPreauthEffectiveDate(Date.newInstance(2017, 12, 12));
        obj.setWaitListProductType('');
        obj.setLeadRoute('');
        obj.setState('');
        obj.setCcLast4Digits('1111');
        obj.handlecities();
        List<String> postalcodes = new List<String>();
        postalCodes.add('95132');
        postalCodes.add('94132');
        String markets = '95134, 95142';
 
        obj.setSelectedPostalCodes(postalCodes);
        obj.setmarkets(markets);
        obj.onChangeProducts();
        obj.setselproduct('Local Expert');
        obj.onChangeProducts();
        obj.setselproduct('Local Expert City');
        obj.onChangeProducts();
        obj.onChangeState();
        obj.onChangeCity();
        obj.onChangeCounty();
        obj.onChangeWaitListType();
        obj.onChangePreAuthType();
    
        Set<String> marketSets = new Set<String>();
        marketSets.add('95134');
        marketSets.add('98763');
        obj.setMarketSets(marketSets);
        obj.addToList();
        List<WaitListItem> items = new List<WaitListItem>();
        for(waitListItem wli: obj.getWaitListItems()){
            wli.maxSpend = 100;
            items.add(wli);
        }
        obj.setWaitListItems(items);
        PreAuthWaitListRenewalExtnUtil.updateParentItems(items);
        obj.submit();
   

        Test.stopTest();
    }
    
    private static void insertWaitlistURLS(){
       List<Waitlist_Urls__c> wlUrlList = new List<Waitlist_Urls__c>();
       Waitlist_Urls__c wl = new Waitlist_Urls__c ();
       wl.Name = 'cityURL';
       wl.URL__c = 'http://geo.svc.move.com/GeoWcfService/County.svc/CityNamesWithinCounty/stateAbb/cntyslctd?app=RDC&v=1&format=JSON';
       wl.replacement_parameter__c = 'stateAbb/cntyslctd';
       wlUrlList.add(wl);
       
       Waitlist_Urls__c wl2 = new Waitlist_Urls__c ();
       wl2.Name = 'countyURL';
       wl2.URL__c = 'http://geo.svc.move.com/GeoWcfService/State.svc/Counties/SelectedState?app=RDC&v=1&format=json';
       wl2.replacement_parameter__c = 'SelectedState';
       wlUrlList.add(wl2);

       Waitlist_Urls__c wl3 = new Waitlist_Urls__c ();
       wl3.Name = 'postalCodeArea';
       wl3.URL__c = 'http://geo.svc.move.com/GeoWcfService/PostalCode.svc/PostalCodeArea/postalcodetobeentered?app=RDC&v=1&format=json';
       wl3.replacement_parameter__c = 'postalcodetobeentered';
       wlUrlList.add(wl3);
        
       Waitlist_Urls__c wl4 = new Waitlist_Urls__c ();
       wl4.Name = 'postalCodes';
       wl4.URL__c = 'http://geo.svc.move.com/GeoWcfService/State.svc/Postalcodes/stateAbb?app=RDC&v=1&format=JSON';
       wl4.replacement_parameter__c = 'stateAbb';
       wlUrlList.add(wl4);
        
       Waitlist_Urls__c wl5 = new Waitlist_Urls__c ();
       wl5.Name = 'StateAbb';
       wl5.URL__c = 'http://geo.svc.move.com/GeoWcfService/State.svc/StateAbbreviation/stateSelected?app=RDC&v=1&format=JSON';
       wl5.replacement_parameter__c = 'stateSelected';
       wlUrlList.add(wl5);
        
       Waitlist_Urls__c wl6 = new Waitlist_Urls__c ();
       wl6.Name = 'stateURL';
       wl6.URL__c = 'http://geo.svc.move.com/GeoWcfService/Country.svc/States/?app=RDC&v=1&format=json';
       wl6.replacement_parameter__c = 'state';
       wlUrlList.add(wl6);
        
       Waitlist_Urls__c wl7 = new Waitlist_Urls__c ();
       wl7.Name = 'zipsIntersectsCity';
       wl7.URL__c = 'http://geo.svc.move.com/GeoWcfService/City.svc/ZipsIntersectsCity/stateAbb/cityslctd?app=RDC&v=1&format=JSON';
       wl7.replacement_parameter__c = 'stateAbb/cityslctd';
       wlUrlList.add(wl7);
        
       Waitlist_Urls__c wl8 = new Waitlist_Urls__c ();
       wl8.Name = 'CreateWaitlist';
       wl8.URL__c = 'http://geo.svc.move.com/GeoWcfService/City.svc/ZipsIntersectsCity/stateAbb/cityslctd?app=RDC&v=1&format=JSON';
       wlUrlList.add(wl8);
        
       insert wlUrlList;
    }
    
    private static void createStateAbbreviations(){
        State_Abbreviations__c sAbb = new State_Abbreviations__c();
        sAbb.Name = 'CA';
        sAbb.Full_Name__c = 'California';
        insert sAbb;
    }
    
    private static account createAccount(){
        Switch_AccountRelationshipTrigger__c arc = new Switch_AccountRelationshipTrigger__c(Name ='Set Overall Trigger Off1' , Set_Overall_Trigger_Off__c = True);
        insert arc;
        Account newAccount = TestDataFactory.createAccount('TheTestAccount', null, false);
        newAccount.Primary_Email__c = 'theAcc@move.com';
        newAccount.party_id__c = '206084041';
        newAccount.Current_Monthly_Pre_Auth_Spend__c=12;
        newAccount.Total_MAX_Monthly_Pre_Auth_Spend__c=125;
        newAccount.Billing_Preference__c = 'Invoice-CC';  
        newAccount.Account_Sub_Type__c='Customer';
        newAccount.Type='MLS Account';
        newAccount.billingstate = 'CA';
        newAccount.Preferred_Phone__c = '1232334455';
        insert newAccount;
        return newAccount;
    }
    
   
    private static contact createContact(account newAccount){
        contact c = new contact();
        c.lastname = 'test';
        c.accountid = newAccount.id;
        c.FirstName = 'ravi';
        c.Title = 'sath';
        c.email ='ravi@gmail.com';
        c.Phone = '1234567895';
        c.MobilePhone= '1234567895';
        c.MailingState = 'California';
        c.MailingCountry = 'United States';
        c.MailingCity = 'knr';
        c.MailingStreet = 'test';
        c.MailingPostalCode = '524345';
        c.Preferred_Phone__c='1234567890';
        insert c; 
        return c;
    }

    private static void createAccountRelationship(account newAccount){
        Contact testContact2 = Z_LegacyTestFactory.makeContact(newAccount); //Create Contact         
        Account_Relationship__c ar = new Account_Relationship__c();
        ar.Contact_to__c = testContact2.Id;
        ar.Billing_Contact__c = true;
        ar.Zuora_Bill_to_Contact_ID__c = testContact2.Id;
        ar.Zuora_Ship_to_Contact_ID__c = testContact2.Id;
        ar.Relationship_Type__c = 'Contact';
        ar.Active__c = true;
        ar.Parent_Account__c = newAccount.Id;
        ar.Contact_Role__c = 'Primary Contact';
        insert ar;
    }

    

    private static void insertWaitlistDetails(account newAccount){
        Contact c = Z_LegacyTestFactory.makeContact(newAccount); //Create Contact         
        Product2 p =new Product2();
        p.name = 'TigerLead HL'; 
        p.S_No__c = 2;
        insert p;
        
        Product2 p2 =new Product2();
        p2.name = 'Local Expert'; 
        p2.S_No__c = 3;
        insert p2;
        
        Product2 p3 =new Product2();
        p3.name = 'Local Expert City'; 
        p3.S_No__c = 4;
        insert p3;
        
        
        Waitlist_Urls__c wURL = new Waitlist_Urls__c();
    wURL.Name = 'accountOwnerChange';
    wURL.URL__c = '';
    wURL.replacement_parameter__c = 'TestUser,TestUser2';
    insert wURL;
        
         Waitlist__c  w = new Waitlist__c();
        w.Account__c= newAccount.id;
        w.Pre_Auth_Contact__c= c.id;
        w.Status__c='Created';
        w.Pre_Auth_Email__c='aj@gmail.com';
        w.Status__c = 'Active';
        w.Waitlist_Expiration_Date__c = System.Today().addDays(90);
        insert w;

        Waitlist_Item__c wt = new Waitlist_Item__c();
        wt.Waitlist__c =w.id;
        wt.Original_Max_Spend__c=2000;
        wt.Status__c='Active';
        wt.Market__c='test';
        wt.Waitlist_ID__c='wwwww';
        wt.Lead_Routing__c='Fast';
        wt.Product__c=p.id;
        wt.Account__c= newAccount.id;
        wt.Market_Type__c='Postal Code';
        wt.Waitlist_Expiration_Date__c=date.today();
        wt.Product_Size__c='Full';
        wt.Wailist_Type__c = 'Pre-Auth';
        wt.Amendment_Status__c='Pending Pre-Auth Approval';
        insert wt;
        
         Waitlist_Item__c wt2 = new Waitlist_Item__c();
        wt2.Waitlist__c =w.id;
        wt2.Original_Max_Spend__c=2000;
        wt2.Status__c='Active';
        wt2.Market__c='test';
        wt2.Waitlist_ID__c='wwwww';
        wt2.Lead_Routing__c='Fast';
        wt2.Product__c=p2.id;
        wt2.Account__c= newAccount.id;
        wt2.Market_Type__c='Postal Code';
        wt2.Waitlist_Expiration_Date__c=date.today();
        wt2.Product_Size__c='Full';
        wt2.Wailist_Type__c = 'Pre-Auth';
        wt2.Amendment_Status__c='Pending Pre-Auth Approval';
        insert wt2;
        
        Waitlist_Item__c wt3 = new Waitlist_Item__c();
        wt3.Waitlist__c =w.id;
        wt3.Original_Max_Spend__c=2000;
        wt3.Status__c='Active';
        wt3.Market__c='test';
        wt3.Waitlist_ID__c='wwwww';
        wt3.Lead_Routing__c='Fast';
        wt3.Product__c=p3.id;
        wt3.Account__c= newAccount.id;
        wt3.Market_Type__c='Postal Code';
        wt3.Waitlist_Expiration_Date__c=date.today();
        wt3.Product_Size__c='Full';
        wt3.Wailist_Type__c = 'Pre-Auth';
        wt3.Amendment_Status__c='Pending Pre-Auth Approval';
        insert wt3;
    }

    private static void stateAbbreviation(){
        State_Abbreviations__c st = New State_Abbreviations__c();
        st.name='MTS';
        st.Full_Name__c = 'Montana';
        insert st;
    }

    private static void createWaitlists(){
        CreateWaitlist__c cw = New CreateWaitlist__c();
        cw.Name ='23';
        cw.Default_Term__c = 6;
        cw.Degree__c = 'Warm 1 , Warm 2 , Warm 3';
        cw.Inventory_Product__c = 'TigerLead HS';
        cw.Lead_Routing_Type__c = 'Any';
        cw.Market_Sub_Type__c = '';
        cw.Market_Type__c = 'County';
        cw.Product__c = 'TigerLead Home Search';
        cw.Product_Code__c = 'HOMESRCH';
        cw.SFDC_Product__c = 'Home Search License';
        cw.Slot_Size__c = 'Any';
        cw.Status__c = 'Hot,Warm,Pipeline';
        cw.Terms__c = '6';
        cw.TigerLead_Product_Type__c = 'HL,HS';
        Insert cw;

        CreateWaitlist__c cw1 = New CreateWaitlist__c();
        cw1.Name ='213';
        cw1.Default_Term__c = 6;
        cw1.Degree__c = 'Warm 1 , Warm 2 , Warm 3';
        cw1.Inventory_Product__c = 'TigerLead HL';
        cw1.Lead_Routing_Type__c = 'Any';
        cw1.Market_Sub_Type__c = '';
        cw1.Market_Type__c = 'County';
        cw1.Product__c = 'TigerLead Hand Raiser';
        cw1.Product_Code__c = 'Postal Code';
        cw1.SFDC_Product__c = 'HandRaiser License';
        cw1.Slot_Size__c = 'Any';
        cw1.Status__c = 'Hot,Warm,Pipeline';
        cw1.Terms__c = '6';
        cw1.TigerLead_Product_Type__c = 'HL,HS';
        Insert cw1;
        
    }
    
    private static void paymentProfiles(Account newAccount)
    {
        PaymentProfiles__c pp = new PaymentProfiles__c();
        pp.Account__c = newAccount.id;
        pp.PaymentMethodId__c = '44444444441444444444444444444444';
        pp.CreditCardType__c = 'Visa';
        pp.ExpirationDate__c ='10/2020';
        pp.CardholderName__c = 'Test holder';
        pp.Credit_Card_BIN__c = '123';
        pp.Payment_Method_Type__c = 'CreditCard';
        pp.SplitPercentage__c = 100;
        pp.MaskNumber__c = '4111111111111111';
        insert pp;
    }

}