@isTest(Seealldata = true)
global class AccountCreateWaitlist_Test implements HttpCalloutMock{
global static testMethod void mainRenew(){
        Contact testContact2;    
      /*  //Inserting Customsetting for Account 
DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
insert Dtrg;  
        //17:15:09.0 (658579033)|USER_DEBUG|[958]|DEBUG|res body:====>>>>>>[{"params":{"request":{"__type":"eai.waitlist.api.ServiceModel.WaitList.CreateWaitlist, eai.waitlist.api.ServiceModel","party_id":"4256221","market_name":"06021","market_type":"Postal Code","product_type":"Connection for Co-Brokerage","state":"CT","waitlist_type":"Pre-Auth","waitlist_slot":"Any","waitlist_status":"Pending Pre-Auth","lead_routing":"Any","quantity":1,"created_by":"MBARTELLI","owner_name":"MBARTELLI","account_name":"Mark Toledo","account_sub_type":"Customer","phone":"8603012339","original_max_spend":"12","remnant_spend":"12"}},"waitlist_guid":"103036cc-20b9-4cbf-a590-dc62581375f6","party_id":"4256221","product_type":"Connection for Co-Brokerage","market_type":"Postal Code","waitlist_slot":"Any","state":"CT","market_name":"06021","waitlist_type":"Pre-Auth","lead_routing":"Any","quantity":"1","owner_name":"MBARTELLI","created_by":"MBARTELLI","ranking":"0","account_name":"Mark Toledo","phone":"8603012339","last_worked_date":"","original_max_spend":"12","remnant_spend":"12","pre_auth_status_date":"","pre_auth_expiry_date":"","presales_available_date":"","inventory_available_flex":"0","presales_available_flex":"0","inventory_available_fast":"0","presales_available_fast":"0","total_available_flex":"0","total_available_fast":"0","account_sub_type":"Customer","waitlist_status":"Pending Pre-Auth","credit_risk":0}]

        Switch_AccountRelationshipTrigger__c arc = new Switch_AccountRelationshipTrigger__c(Name ='Set Overall Trigger Off1' , Set_Overall_Trigger_Off__c = True);
        insert arc;         */
        Account newAccount = TestDataFactory.createAccount('TheTestAccount', null, false);
        newAccount.Primary_Email__c = 'theAcc@move.com';
        newAccount.party_id__c = '206084041';
        newAccount.Current_Monthly_Pre_Auth_Spend__c=12;
        newAccount.Total_MAX_Monthly_Pre_Auth_Spend__c=125;
        newAccount.Billing_Preference__c = 'Invoice-CC';  
         newAccount.Account_Sub_Type__c='Customer';
           newAccount.Type='MLS Account';
           newAccount.billingstate = 'california';
        insert newAccount;
        
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
        
        testContact2 = Z_LegacyTestFactory.makeContact(newAccount, 'contactemail@abc.com'); //Create Contact         
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
        
        Product2 p =new Product2();
        //p.name = 'Test';
        p.name = 'TigerLead HL'; 
        p.S_No__c = 2;
        insert p;
        
        Waitlist__c  w = new Waitlist__c();
        w.Account__c= newAccount.id;
        w.Pre_Auth_Contact__c= c.id;
        w.Status__c='Created';
        w.Pre_Auth_Email__c='aj@gmail.com';
        w.Waitlist_Expiration_Date__c = System.Today().addDays(90);
        insert w;
        
        Waitlist_Item__c wt = new Waitlist_Item__c();
    wt.Waitlist__c =w.id;
    wt.Original_Max_Spend__c=2000;
    wt.Status__c='Pending Pre-Auth Approval';
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

    waitlist_Item__c wt2 = new Waitlist_Item__c();
    wt2.Waitlist__c =w.id;
    wt2.Original_Max_Spend__c=2000;
    wt2.Status__c='Active';
    wt2.Market__c='test';
    wt2.Waitlist_ID__c='wwwww';
    wt2.Lead_Routing__c='Fast';
    wt2.Product__c=p.id;
    wt2.Account__c= newAccount.id;
    wt2.Market_Type__c='Postal Code';
    wt2.Waitlist_Expiration_Date__c=date.today();
    wt2.Product_Size__c='Full';
    wt2.Wailist_Type__c = 'Pre-Auth';
    wt2.Amendment_Status__c='Pending Pre-Auth Approval';
    
    insert wt2;
        
        CreateWaitlist__c cw = New CreateWaitlist__c();
        cw.Name ='323';
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
        
        State_Abbreviations__c st = New State_Abbreviations__c();
        st.name='MTS';
        st.Full_Name__c = 'Montana';
        insert st;
        
                   PaymentProfiles__c pp = new PaymentProfiles__c();
        pp.Account__c = newAccount.id;
       // pp.PaymentMethodId__c = '44444444441444444444444444444444';
        pp.CreditCardType__c = 'Visa';
        pp.ExpirationDate__c ='10/2020';
        pp.CardholderName__c = 'Test holder';
        pp.Credit_Card_BIN__c = '123';
        pp.Payment_Method_Type__c = 'CreditCard';
       // insert pp;
        
        map<String,string> tempStatus = new map<String,string>();
        tempStatus.put(cw.Status__c, cw.Status__c);
        tempStatus.put(cw1.Status__c, cw1.Status__c);
        
        Test.startTest();      
        PageReference pgr=page.AccountCreateWaitlist;
        pgr.getParameters().put('id',newAccount.id);
        pgr.getParameters().put('typeren','Renwals');
        Test.SetCurrentPage(pgr);
        ApexPages.StandardController sc = new ApexPages.standardController(newAccount);
        //  try{}
        
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorWlist());  

        AccountCreateWaitlist obj ; 
        try{
            obj= new AccountCreateWaitlist(sc);  
            
        }
        catch(Exception e){
            
        }
        obj.pymntprflerr = true ;
        obj.CC4digits=null;
        obj.recordIdAfterSave=w.Id;
        
        AccountCreateWaitlist.marketWrapper mk = New AccountCreateWaitlist.marketWrapper
            (obj.ProductselectedVal, '', obj.TypeOptions,obj.MarketTypeselectedVal,obj.DegreeselectedVal,
             obj.LeadRoutingselectedVal, obj.LeadRoutingOptions, obj.Quantity, obj.Message, 'TigerLead' ,newAccount, obj.stateAbbrevation,
             obj.SlotSizeselectedVal, obj.SlotSizeOptions, obj.userntlogin, obj.Term,'6' ,null);
                  mk.Status = 'Pre-Auth';
         mk.MaxSpend = 0 ;
mk.Product='Turbo';
        
        
        obj.submit();  
        try{
        obj.callinventory();
        }catch(Exception e){
        }
        
        obj.callapex();
        obj.cancel();
        obj.changeStatus();
        obj.changeStatusfromgrid();
        obj.FetchCityCountyPostcode();
        obj.FetchCityPostalcode();
        // obj.FetchMarketTypes();
        obj.FetchPostalcode();
        obj.stateSelected = 'NC';
 obj.CountySelected = new List<String>{'kalawao'};
        obj.CitySelected= new List<String>{'texas'};
            obj.FetchRoutingslottype();
        
        obj.MarketTypeselectedVal = 'County';
        obj.marketTextArea = '10001, 10003';
        obj.StatusselectedVal = 'Auth';
        obj.CC4digits = '123';
        obj.GenerateTable();
        obj.callinventory(); 
        
        obj.CitySelected= new List<String>{'texas'};
        obj.MarketTypeselectedVal = 'City';
        obj.marketTextArea = '10001, 10003';
        obj.GenerateTable();
        
        obj.postcodSelected= new List<String>{'10009'};
        obj.MarketTypeselectedVal = 'Postal Code';
        obj.marketTextArea = '10001, 10003';
        obj.GenerateTable();
        
        obj.queryCitys();
        obj.queryCountys();
        obj.queryDependecies();
        obj.querypostalcodes();
        obj.querypostalcodesforcities();
        
        
        Test.setMock(WebServiceMock.class, new WebServiceMockImplementation1());  
        //Test.setMock(WebServiceMock.class, new WebServiceMockVoidDocusign());
        //WebServiceMockVoidDocusign.callfrom = 'accounttrigger';   
        obj.Initialize();       
        obj.getStateOptions();
        obj.queryDependecies();
        obj.stateSelected = 'NC';
        obj.MarketTypeselectedVal = 'County';
        obj.FetchCityCountyPostcode();
        obj.queryCountys();
        obj.stateAbb = 'NC';
        obj.queryCitys(); 
        obj.MarketTypeselectedVal = 'City';
        obj.FetchCityCountyPostcode();
        obj.stateAbb = 'NC';
        obj.MarketTypeselectedVal = 'Postal Code';
        obj.FetchCityCountyPostcode();
        obj.FetchCityPostalcode();        
        obj.FetchPostalcode();
        obj.stateAbb = 'NC';              
        obj.querypostalcodes();
        obj.stateAbb = 'NC';
        obj.querypostalcodesforcities();
        // obj.getProductOptions(); 
        obj.MarketTypeselectedVal = 'City';
        obj.FetchCityPostalcode();
        obj.refresh();
        obj.MarketTypeselectedVal = 'County';
        obj.refresh();
        obj.callapex();            
        obj.changeStatus();             
        obj.cancel();
        obj.RefreshPage();
        obj.GenerateTable();            
        obj.TypeOptions =  new List<Selectoption>();
        obj.list2Options(tempStatus.values(),obj.TypeOptions);
        obj.addNoneOption(obj.list2Options(tempStatus.values(),obj.TypeOptions));
        obj.FetchRoutingslottype();
        obj.ProductselectedVal      = 'Connection for Co-Brokerage';
        obj.StatusselectedVal       = 'Pre-Auth';
        obj.MarketTypeselectedVal   = 'Postal Code';
        obj.DegreeselectedVal       = '';
        obj.LeadRoutingselectedVal  = 'Any';
        obj.Quantity = 6;
        obj.CC4digits = '0006';     
        obj.marketlist.add(mk); 
       // obj.marketlist.add(mk1); 
        
        obj.submit(); 
                  obj.addToMarketList('CBCE' ,false);

        List<SelectOption> temps = new List<SelectOption> ();
        for(integer i=0;i<1000;i++){
            temps.add(new SelectOption(String.valueOf(i),String.valueOf(i)));   
        }
        
        obj.handleMorecitys(temps);
        obj.handleMorePostcode(temps);
        obj.handleMorePostcode(temps);
          obj.handleMorecountys(temps);
        
        List<SelectOption> temps1 = new List<SelectOption> ();
        for(integer i=0;i<2010;i++){
            temps1.add(new SelectOption(String.valueOf(i),String.valueOf(i)));   
        }
        
        obj.handleMorecitys(temps1);
        obj.handleMorePostcode(temps1);
        obj.handleMorePostcode(temps1);
          obj.handleMorecountys(temps1);
        
         List<SelectOption> temps21 = new List<SelectOption> ();
        for(integer i=0;i<3010;i++){
            temps21.add(new SelectOption(String.valueOf(i),String.valueOf(i)));   
        }
        
        obj.handleMorecitys(temps21);
        obj.handleMorePostcode(temps21);
        obj.handleMorePostcode(temps21);
          obj.handleMorecountys(temps21);
        
        List<SelectOption> temps2 = new List<SelectOption> ();
        for(integer i=0;i<4010;i++){
            temps2.add(new SelectOption(String.valueOf(i),String.valueOf(i)));   
        }
        
        obj.handleMorecitys(temps2);
        obj.handleMorePostcode(temps1);
        obj.handleMorePostcode(temps1);
          obj.handleMorecountys(temps2);
        
        try{
            // obj.getProductOptions();
            obj.callinventory();
            
        }
        catch(Exception e){
            
        }
        try{
            obj.getProductOptions();
            //  obj.callinventory();
            
        }
        catch(Exception e){
            
        }
        
        Test.stopTest(); 
        
    }  
     
    global static testMethod void main1(){
        Contact testContact2;    
      /* //Inserting Customsetting for Account 
DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
insert Dtrg; 
        //17:15:09.0 (658579033)|USER_DEBUG|[958]|DEBUG|res body:====>>>>>>[{"params":{"request":{"__type":"eai.waitlist.api.ServiceModel.WaitList.CreateWaitlist, eai.waitlist.api.ServiceModel","party_id":"4256221","market_name":"06021","market_type":"Postal Code","product_type":"Connection for Co-Brokerage","state":"CT","waitlist_type":"Pre-Auth","waitlist_slot":"Any","waitlist_status":"Pending Pre-Auth","lead_routing":"Any","quantity":1,"created_by":"MBARTELLI","owner_name":"MBARTELLI","account_name":"Mark Toledo","account_sub_type":"Customer","phone":"8603012339","original_max_spend":"12","remnant_spend":"12"}},"waitlist_guid":"103036cc-20b9-4cbf-a590-dc62581375f6","party_id":"4256221","product_type":"Connection for Co-Brokerage","market_type":"Postal Code","waitlist_slot":"Any","state":"CT","market_name":"06021","waitlist_type":"Pre-Auth","lead_routing":"Any","quantity":"1","owner_name":"MBARTELLI","created_by":"MBARTELLI","ranking":"0","account_name":"Mark Toledo","phone":"8603012339","last_worked_date":"","original_max_spend":"12","remnant_spend":"12","pre_auth_status_date":"","pre_auth_expiry_date":"","presales_available_date":"","inventory_available_flex":"0","presales_available_flex":"0","inventory_available_fast":"0","presales_available_fast":"0","total_available_flex":"0","total_available_fast":"0","account_sub_type":"Customer","waitlist_status":"Pending Pre-Auth","credit_risk":0}]

        Switch_AccountRelationshipTrigger__c arc = new Switch_AccountRelationshipTrigger__c(Name ='Set Overall Trigger Off1' , Set_Overall_Trigger_Off__c = True);
        insert arc;   */
        
        Account newAccount = TestDataFactory.createAccount('TheTestAccount', null, false);
        newAccount.Primary_Email__c = 'theAcc@move.com';
        newAccount.party_id__c = '206084041';
        newAccount.Current_Monthly_Pre_Auth_Spend__c=12;
        newAccount.Total_MAX_Monthly_Pre_Auth_Spend__c=125;
        newAccount.Billing_Preference__c = 'Invoice-CC';  
         newAccount.Account_Sub_Type__c='Customer';
           newAccount.Type='MLS Account';
           newAccount.billingstate = 'california';
        insert newAccount;
        
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
        
        
        
        testContact2 = Z_LegacyTestFactory.makeContact(newAccount, 'contactemail@abc.com'); //Create Contact         
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
        
        Product2 p =new Product2();
        //p.name = 'Test';
        p.name = 'TigerLead HL'; 
        p.S_No__c = 2;
        insert p;
        
        Waitlist__c  w = new Waitlist__c();
        w.Account__c= newAccount.id;
        w.Pre_Auth_Contact__c= c.id;
        w.Status__c='Created';
        w.Pre_Auth_Email__c='aj@gmail.com';
        w.Waitlist_Expiration_Date__c = System.Today().addDays(90);
        insert w;
        
        Waitlist_Item__c wt = new Waitlist_Item__c();
    wt.Waitlist__c =w.id;
    wt.Original_Max_Spend__c=2000;
    wt.Status__c='Pending Pre-Auth Approval';
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

    waitlist_Item__c wt2 = new Waitlist_Item__c();
    wt2.Waitlist__c =w.id;
    wt2.Original_Max_Spend__c=2000;
    wt2.Status__c='Active';
    wt2.Market__c='test';
    wt2.Waitlist_ID__c='wwwww';
    wt2.Lead_Routing__c='Fast';
    wt2.Product__c=p.id;
    wt2.Account__c= newAccount.id;
    wt2.Market_Type__c='Postal Code';
    wt2.Waitlist_Expiration_Date__c=date.today();
    wt2.Product_Size__c='Full';
    wt2.Wailist_Type__c = 'Pre-Auth';
    wt2.Amendment_Status__c='Pending Pre-Auth Approval';
    
    insert wt2;
        
        CreateWaitlist__c cw = New CreateWaitlist__c();
        cw.Name ='235';
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
        
        State_Abbreviations__c st = New State_Abbreviations__c();
        st.name='MTS';
        st.Full_Name__c = 'Montana';
        insert st;
        
                   PaymentProfiles__c pp = new PaymentProfiles__c();
        pp.Account__c = newAccount.id;
       // pp.PaymentMethodId__c = '44444444441444444444444444444444';
        pp.CreditCardType__c = 'Visa';
        pp.ExpirationDate__c ='10/2020';
        pp.CardholderName__c = 'Test holder';
        pp.Credit_Card_BIN__c = '123';
        pp.Payment_Method_Type__c = 'CreditCard';
        //insert pp;
        
        map<String,string> tempStatus = new map<String,string>();
        tempStatus.put(cw.Status__c, cw.Status__c);
        tempStatus.put(cw1.Status__c, cw1.Status__c);
        
        Test.startTest();      
        PageReference pgr=page.AccountCreateWaitlist;
        pgr.getParameters().put('id',newAccount.id);
        Test.SetCurrentPage(pgr);
        ApexPages.StandardController sc = new ApexPages.standardController(newAccount);
        //  try{}
        
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorWlist());  

        AccountCreateWaitlist obj ; 
        try{
            obj= new AccountCreateWaitlist(sc);  
            
        }
        catch(Exception e){
            
        }
        obj.pymntprflerr = true ;
        obj.CC4digits=null;
        obj.recordIdAfterSave=w.Id;
        
        AccountCreateWaitlist.marketWrapper mk = New AccountCreateWaitlist.marketWrapper
            (obj.ProductselectedVal, '', obj.TypeOptions,obj.MarketTypeselectedVal,obj.DegreeselectedVal,
             obj.LeadRoutingselectedVal, obj.LeadRoutingOptions, obj.Quantity, obj.Message, 'TigerLead' ,newAccount, obj.stateAbbrevation,
             obj.SlotSizeselectedVal, obj.SlotSizeOptions, obj.userntlogin, obj.Term,'6' ,null);
                  mk.Status = 'Pre-Auth';
         mk.MaxSpend = 0 ;
mk.Product='Turbo';
        
        
        obj.submit();  
        try{
        obj.callinventory();
        }catch(Exception e){
        }
        
        obj.callapex();
        obj.cancel();
        obj.changeStatus();
        obj.changeStatusfromgrid();
        obj.FetchCityCountyPostcode();
        obj.FetchCityPostalcode();
        // obj.FetchMarketTypes();
        obj.FetchPostalcode();
        obj.stateSelected = 'NC';
        obj.CountySelected = new List<String>{'kalawao'};
        obj.CitySelected= new List<String>{'texas'};
        obj.FetchRoutingslottype();
        
        obj.MarketTypeselectedVal = 'County';
        obj.marketTextArea = '10001, 10003';
        obj.StatusselectedVal = 'Auth';
        obj.CC4digits = '123';
        obj.GenerateTable();
        obj.callinventory(); 
        
        obj.MarketTypeselectedVal = 'City';
        obj.marketTextArea = '10001, 10003';
        obj.GenerateTable();
        
        obj.postcodSelected= new List<String>{'10009'};
        obj.MarketTypeselectedVal = 'Postal Code';
        obj.marketTextArea = '10001, 10003';
        obj.GenerateTable();
        
        obj.queryCitys();
        obj.queryCountys();
        obj.queryDependecies();
        obj.querypostalcodes();
        obj.querypostalcodesforcities();
        
        
        Test.setMock(WebServiceMock.class, new WebServiceMockImplementation1());  
        //Test.setMock(WebServiceMock.class, new WebServiceMockVoidDocusign());
        //WebServiceMockVoidDocusign.callfrom = 'accounttrigger';   
        obj.Initialize();       
        obj.getStateOptions();
        obj.queryDependecies();
        obj.stateSelected = 'NC';
        obj.MarketTypeselectedVal = 'County';
        obj.FetchCityCountyPostcode();
        obj.queryCountys();
        obj.stateAbb = 'NC';
        obj.queryCitys(); 
        obj.MarketTypeselectedVal = 'City';
        obj.FetchCityCountyPostcode();
        obj.stateAbb = 'NC';
        obj.MarketTypeselectedVal = 'Postal Code';
        obj.FetchCityCountyPostcode();
        obj.FetchCityPostalcode();        
        obj.FetchPostalcode();
        obj.stateAbb = 'NC';              
        obj.querypostalcodes();
        obj.stateAbb = 'NC';
        obj.querypostalcodesforcities();
        // obj.getProductOptions(); 
        obj.MarketTypeselectedVal = 'City';
        obj.FetchCityPostalcode();
        obj.refresh();
        obj.MarketTypeselectedVal = 'County';
        obj.refresh();
        obj.callapex();            
        obj.changeStatus();             
        obj.cancel();
        obj.RefreshPage();
        obj.GenerateTable();            
        obj.TypeOptions =  new List<Selectoption>();
        obj.list2Options(tempStatus.values(),obj.TypeOptions);
        obj.addNoneOption(obj.list2Options(tempStatus.values(),obj.TypeOptions));
        obj.FetchRoutingslottype();
        obj.ProductselectedVal      = 'Connection for Co-Brokerage';
        obj.StatusselectedVal       = 'Pre-Auth';
        obj.MarketTypeselectedVal   = 'Postal Code';
        obj.DegreeselectedVal       = '';
        obj.LeadRoutingselectedVal  = 'Any';
        obj.Quantity = 6;
        obj.CC4digits = '0006';     
        obj.marketlist.add(mk); 
       // obj.marketlist.add(mk1); 
        
        obj.submit(); 
                  obj.addToMarketList('CBCE' ,false);

        List<SelectOption> temps = new List<SelectOption> ();
        for(integer i=0;i<1000;i++){
            temps.add(new SelectOption(String.valueOf(i),String.valueOf(i)));   
        }
        
        obj.handleMorecitys(temps);
        obj.handleMorePostcode(temps);
        obj.handleMorePostcode(temps);
          obj.handleMorecountys(temps);
        
        List<SelectOption> temps1 = new List<SelectOption> ();
        for(integer i=0;i<2010;i++){
            temps1.add(new SelectOption(String.valueOf(i),String.valueOf(i)));   
        }
        
        obj.handleMorecitys(temps1);
        obj.handleMorePostcode(temps1);
        obj.handleMorePostcode(temps1);
          obj.handleMorecountys(temps1);
        
         List<SelectOption> temps21 = new List<SelectOption> ();
        for(integer i=0;i<3010;i++){
            temps21.add(new SelectOption(String.valueOf(i),String.valueOf(i)));   
        }
        
        obj.handleMorecitys(temps21);
        obj.handleMorePostcode(temps21);
        obj.handleMorePostcode(temps21);
          obj.handleMorecountys(temps21);
        
        List<SelectOption> temps2 = new List<SelectOption> ();
        for(integer i=0;i<4010;i++){
            temps2.add(new SelectOption(String.valueOf(i),String.valueOf(i)));   
        }
        
        obj.handleMorecitys(temps2);
        obj.handleMorePostcode(temps1);
        obj.handleMorePostcode(temps1);
          obj.handleMorecountys(temps2);
        
        try{
            // obj.getProductOptions();
            obj.callinventory();
            
        }
        catch(Exception e){
            
        }
        try{
            obj.getProductOptions();
            //  obj.callinventory();
            
        }
        catch(Exception e){
            
        }

        Test.stopTest(); 
        
    }  
    
     global static testMethod void main11(){
        Contact testContact2;    
      /* //Inserting Customsetting for Account 
DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
insert Dtrg; 
        //17:15:09.0 (658579033)|USER_DEBUG|[958]|DEBUG|res body:====>>>>>>[{"params":{"request":{"__type":"eai.waitlist.api.ServiceModel.WaitList.CreateWaitlist, eai.waitlist.api.ServiceModel","party_id":"4256221","market_name":"06021","market_type":"Postal Code","product_type":"Connection for Co-Brokerage","state":"CT","waitlist_type":"Pre-Auth","waitlist_slot":"Any","waitlist_status":"Pending Pre-Auth","lead_routing":"Any","quantity":1,"created_by":"MBARTELLI","owner_name":"MBARTELLI","account_name":"Mark Toledo","account_sub_type":"Customer","phone":"8603012339","original_max_spend":"12","remnant_spend":"12"}},"waitlist_guid":"103036cc-20b9-4cbf-a590-dc62581375f6","party_id":"4256221","product_type":"Connection for Co-Brokerage","market_type":"Postal Code","waitlist_slot":"Any","state":"CT","market_name":"06021","waitlist_type":"Pre-Auth","lead_routing":"Any","quantity":"1","owner_name":"MBARTELLI","created_by":"MBARTELLI","ranking":"0","account_name":"Mark Toledo","phone":"8603012339","last_worked_date":"","original_max_spend":"12","remnant_spend":"12","pre_auth_status_date":"","pre_auth_expiry_date":"","presales_available_date":"","inventory_available_flex":"0","presales_available_flex":"0","inventory_available_fast":"0","presales_available_fast":"0","total_available_flex":"0","total_available_fast":"0","account_sub_type":"Customer","waitlist_status":"Pending Pre-Auth","credit_risk":0}]

        Switch_AccountRelationshipTrigger__c arc = new Switch_AccountRelationshipTrigger__c(Name ='Set Overall Trigger Off1' , Set_Overall_Trigger_Off__c = True);
        insert arc;   */
        
        Account newAccount = TestDataFactory.createAccount('TheTestAccount', null, false);
        newAccount.Primary_Email__c = 'theAcc@move.com';
        newAccount.party_id__c = '206084041';
        newAccount.Current_Monthly_Pre_Auth_Spend__c=12;
        newAccount.Total_MAX_Monthly_Pre_Auth_Spend__c=125;
        newAccount.Billing_Preference__c = 'Invoice-CC';  
         newAccount.Account_Sub_Type__c='Customer';
           newAccount.Type='MLS Account';
           newAccount.billingstate = 'california';
        insert newAccount;
        
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
        
        
        
        testContact2 = Z_LegacyTestFactory.makeContact(newAccount, 'contactemail@abc.com'); //Create Contact         
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
        
        Product2 p =new Product2();
        //p.name = 'Test';
        p.name = 'TigerLead HL'; 
        p.S_No__c = 2;
        insert p;
        
        Waitlist__c  w = new Waitlist__c();
        w.Account__c= newAccount.id;
        w.Pre_Auth_Contact__c= c.id;
        w.Status__c='Created';
        w.Pre_Auth_Email__c='aj@gmail.com';
        w.Waitlist_Expiration_Date__c = System.Today().addDays(90);
        insert w;
        
        Waitlist_Item__c wt = new Waitlist_Item__c();
    wt.Waitlist__c =w.id;
    wt.Original_Max_Spend__c=2000;
    wt.Status__c='Pending Pre-Auth Approval';
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

    waitlist_Item__c wt2 = new Waitlist_Item__c();
    wt2.Waitlist__c =w.id;
    wt2.Original_Max_Spend__c=2000;
    wt2.Status__c='Active';
    wt2.Market__c='test';
    wt2.Waitlist_ID__c='wwwww';
    wt2.Lead_Routing__c='Fast';
    wt2.Product__c=p.id;
    wt2.Account__c= newAccount.id;
    wt2.Market_Type__c='Postal Code';
    wt2.Waitlist_Expiration_Date__c=date.today();
    wt2.Product_Size__c='Full';
    wt2.Wailist_Type__c = 'Pre-Auth';
    wt2.Amendment_Status__c='Pending Pre-Auth Approval';
    
    insert wt2;
        
        CreateWaitlist__c cw = New CreateWaitlist__c();
        cw.Name ='235';
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
        
        State_Abbreviations__c st = New State_Abbreviations__c();
        st.name='MTS';
        st.Full_Name__c = 'Montana';
        insert st;
        
                   PaymentProfiles__c pp = new PaymentProfiles__c();
        pp.Account__c = newAccount.id;
       // pp.PaymentMethodId__c = '44444444441444444444444444444444';
        pp.CreditCardType__c = 'Visa';
        pp.ExpirationDate__c ='10/2020';
        pp.CardholderName__c = 'Test holder';
        pp.Credit_Card_BIN__c = '123';
        pp.Payment_Method_Type__c = 'CreditCard';
        //insert pp;
        
        map<String,string> tempStatus = new map<String,string>();
        tempStatus.put(cw.Status__c, cw.Status__c);
        tempStatus.put(cw1.Status__c, cw1.Status__c);
        
        Test.startTest();      
        PageReference pgr=page.AccountCreateWaitlist;
        pgr.getParameters().put('id',newAccount.id);
        Test.SetCurrentPage(pgr);
        ApexPages.StandardController sc = new ApexPages.standardController(newAccount);
        //  try{}
        
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorWlist());  

        AccountCreateWaitlist obj ; 
        try{
            obj= new AccountCreateWaitlist(sc);  
            
        }
        catch(Exception e){
            
        }
        obj.pymntprflerr = true ;
        obj.CC4digits=null;
        obj.recordIdAfterSave=w.Id;
        
        AccountCreateWaitlist.marketWrapper mk = New AccountCreateWaitlist.marketWrapper
            (obj.ProductselectedVal, '', obj.TypeOptions,obj.MarketTypeselectedVal,obj.DegreeselectedVal,
             obj.LeadRoutingselectedVal, obj.LeadRoutingOptions, obj.Quantity, obj.Message, 'TigerLead' ,newAccount, obj.stateAbbrevation,
             obj.SlotSizeselectedVal, obj.SlotSizeOptions, obj.userntlogin, obj.Term,'6' ,null);
                  mk.Status = 'Pre-Auth';
         mk.MaxSpend = 0 ;
mk.Product='Turbo';
        
        
        obj.submit();  
        try{
        obj.callinventory();
        }catch(Exception e){
        }
        
        obj.callapex();
        obj.cancel();
        obj.changeStatus();
        obj.changeStatusfromgrid();
        obj.FetchCityCountyPostcode();
        obj.FetchCityPostalcode();
        // obj.FetchMarketTypes();
        obj.FetchPostalcode();
        obj.stateSelected = 'NC';
        obj.CountySelected = new List<String>{'kalawao'};
        obj.CitySelected= new List<String>{'texas'};
        obj.FetchRoutingslottype();
        
        obj.MarketTypeselectedVal = 'County';
        obj.marketTextArea = '10001, 10003';
        obj.StatusselectedVal = 'Auth';
        obj.CC4digits = '123';
        obj.GenerateTable();
        obj.callinventory(); 
        
        obj.MarketTypeselectedVal = 'City';
        obj.marketTextArea = '10001, 10003';
        obj.GenerateTable();
        
        obj.postcodSelected= new List<String>{'10009'};
        obj.MarketTypeselectedVal = 'Postal Code';
        obj.marketTextArea = '10001, 10003';
        obj.GenerateTable();
        
        obj.queryCitys();
        obj.queryCountys();
        obj.queryDependecies();
        obj.querypostalcodes();
        obj.querypostalcodesforcities();
        
        
        Test.setMock(WebServiceMock.class, new WebServiceMockImplementation1());  
        //Test.setMock(WebServiceMock.class, new WebServiceMockVoidDocusign());
        //WebServiceMockVoidDocusign.callfrom = 'accounttrigger';   
        obj.Initialize();       
        obj.getStateOptions();
        obj.queryDependecies();
        obj.stateSelected = 'NC';
        obj.MarketTypeselectedVal = 'County';
        obj.FetchCityCountyPostcode();
        obj.queryCountys();
        obj.stateAbb = 'NC';
        obj.queryCitys(); 
        obj.MarketTypeselectedVal = 'City';
        obj.FetchCityCountyPostcode();
        obj.stateAbb = 'NC';
        obj.MarketTypeselectedVal = 'Postal Code';
        obj.FetchCityCountyPostcode();
        obj.FetchCityPostalcode();        
        obj.FetchPostalcode();
        obj.stateAbb = 'NC';              
        obj.querypostalcodes();
        obj.stateAbb = 'NC';
        obj.querypostalcodesforcities();
        // obj.getProductOptions(); 
        obj.MarketTypeselectedVal = 'City';
        obj.FetchCityPostalcode();
        obj.refresh();
        obj.MarketTypeselectedVal = 'County';
        obj.refresh();
        obj.callapex();            
        obj.changeStatus();             
        obj.cancel();
        obj.RefreshPage();
        obj.GenerateTable();            
        obj.TypeOptions =  new List<Selectoption>();
        obj.list2Options(tempStatus.values(),obj.TypeOptions);
        obj.addNoneOption(obj.list2Options(tempStatus.values(),obj.TypeOptions));
        obj.FetchRoutingslottype();
        obj.ProductselectedVal      = 'Local Expert City';
        obj.StatusselectedVal       = 'Pre-Auth';
        obj.MarketTypeselectedVal   = 'Postal Code';
        obj.DegreeselectedVal       = '';
        obj.LeadRoutingselectedVal  = 'Any';
        obj.Quantity = 6;
        obj.CC4digits = '0006';     
        obj.marketlist.add(mk); 
       // obj.marketlist.add(mk1); 
        
        obj.submit(); 
                  obj.addToMarketList('CBCE' ,false);

        List<SelectOption> temps = new List<SelectOption> ();
        for(integer i=0;i<1000;i++){
            temps.add(new SelectOption(String.valueOf(i),String.valueOf(i)));   
        }
        
        obj.handleMorecitys(temps);
        obj.handleMorePostcode(temps);
        obj.handleMorePostcode(temps);
          obj.handleMorecountys(temps);
        
        List<SelectOption> temps1 = new List<SelectOption> ();
        for(integer i=0;i<2010;i++){
            temps1.add(new SelectOption(String.valueOf(i),String.valueOf(i)));   
        }
        
        obj.handleMorecitys(temps1);
        obj.handleMorePostcode(temps1);
        obj.handleMorePostcode(temps1);
          obj.handleMorecountys(temps1);
        
         List<SelectOption> temps21 = new List<SelectOption> ();
        for(integer i=0;i<3010;i++){
            temps21.add(new SelectOption(String.valueOf(i),String.valueOf(i)));   
        }
        
        obj.handleMorecitys(temps21);
        obj.handleMorePostcode(temps21);
        obj.handleMorePostcode(temps21);
          obj.handleMorecountys(temps21);
        
        List<SelectOption> temps2 = new List<SelectOption> ();
        for(integer i=0;i<4010;i++){
            temps2.add(new SelectOption(String.valueOf(i),String.valueOf(i)));   
        }
        
        obj.handleMorecitys(temps2);
        obj.handleMorePostcode(temps1);
        obj.handleMorePostcode(temps1);
          obj.handleMorecountys(temps2);
        
        try{
            // obj.getProductOptions();
            obj.callinventory();
            
        }
        catch(Exception e){
            
        }
        try{
            obj.getProductOptions();
            obj.initProductChange();
            //  obj.callinventory();
            
        }
        catch(Exception e){
            
        }

        Test.stopTest(); 
        
    }  
    
       global static testMethod void main2(){
        Contact testContact2;    
       /* //Inserting Customsetting for Account 
DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
insert Dtrg; 
        Switch_AccountRelationshipTrigger__c arc = new Switch_AccountRelationshipTrigger__c(Name ='Set Overall Trigger Off1' , Set_Overall_Trigger_Off__c = True);
        insert arc;    */     
        Account newAccount = TestDataFactory.createAccount('TheTestAccount', null, false);
        newAccount.Primary_Email__c = 'theAcc@move.com';
        newAccount.party_id__c = '206084041';
        newAccount.Billing_Preference__c = 'Invoice-CC';  
          newAccount.billingstate=null;
           
           newAccount.Account_Sub_Type__c='Customer';
           newAccount.Type='Realtor Office';
        insert newAccount;
        
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
        c.Active__c = true;
        insert c; 
           Account_Relationship__c ar = new Account_Relationship__c();
           ar.Contact_To__c =c.Id ;
           ar.Parent_Account__c=newAccount.Id;
            ar.Contact_Role__c = 'Primary Contact';
           ar.Active__c = true;
           insert ar ;
           
           Product2 p =new Product2();
        //p.name = 'Test';
        p.name = 'TigerLead HL'; 
        p.S_No__c = 2;
        insert p;
        
        Waitlist__c  w = new Waitlist__c();
        w.Account__c= newAccount.id;
        w.Pre_Auth_Contact__c= c.id;
        w.Status__c='Active';
        w.Pre_Auth_Email__c='aj@gmail.com';
        insert w;
        
       Waitlist_Item__c wt = new Waitlist_Item__c();
    wt.Waitlist__c =w.id;
    wt.Original_Max_Spend__c=2000;
    wt.Status__c='Pending Pre-Auth Approval';
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

    waitlist_Item__c wt2 = new Waitlist_Item__c();
    wt2.Waitlist__c =w.id;
    wt2.Original_Max_Spend__c=2000;
    wt2.Status__c='Active';
    wt2.Market__c='test';
    wt2.Waitlist_ID__c='wwwww';
    wt2.Lead_Routing__c='Fast';
    wt2.Product__c=p.id;
    wt2.Account__c= newAccount.id;
    wt2.Market_Type__c='Postal Code';
    wt2.Waitlist_Expiration_Date__c=date.today();
    wt2.Product_Size__c='Full';
    wt2.Wailist_Type__c = 'Pre-Auth';
    wt2.Amendment_Status__c='Pending Pre-Auth Approval';
    
    insert wt2;
        
        CreateWaitlist__c cw = New CreateWaitlist__c();
        cw.Name ='231';
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
        
           
           PaymentProfiles__c pp = new PaymentProfiles__c();
        pp.Account__c = newAccount.id;
        //pp.PaymentMethodId__c = '44444444444444444444444444444444';
        pp.CreditCardType__c = 'Visa';
        pp.ExpirationDate__c ='10/2020';
        pp.CardholderName__c = 'Test holder';
        pp.Credit_Card_BIN__c = '123';
        pp.Payment_Method_Type__c = 'CreditCard';
        //insert pp;
           
           
        State_Abbreviations__c st = New State_Abbreviations__c();
        st.name='MTS';
        st.Full_Name__c = 'Montana';
        insert st;
        
        map<String,string> tempStatus = new map<String,string>();
        tempStatus.put(cw.Status__c, cw.Status__c);
        tempStatus.put(cw1.Status__c, cw1.Status__c);
        
          Test.startTest();      
        PageReference pgr=page.AccountCreateWaitlist;
        pgr.getParameters().put('id',newAccount.id);
        Test.SetCurrentPage(pgr);
                           Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorWlist());  

        ApexPages.StandardController sc = new ApexPages.standardController(newAccount);
           AccountCreateWaitlist obj ; 
        try{
            obj= new AccountCreateWaitlist(sc);  
            
        }
        catch(Exception e){
            
        }  
        obj.defaultterm = '12';
        obj.rowIndex= 1;
        obj.coloumHeader='';
           obj.PostalCodeselectedVal ='95051' ;
           obj.pymntprflerr=true ;
           
           obj.MaxSpend =500 ;
           obj.showstatuscolumns = true ;
           obj.showdeletecolumns = true ;
           
           
            CreateWaitlistWrapper cs = New CreateWaitlistWrapper();
        
            cs.waitlist_status = 'Active';
            cs.created_by = '';
            cs.quantity= 1;
            cs.lead_routing= '';
            cs.market_name= '';
            cs.market_type= '';
            cs.party_id= '';
            cs.product_type= '';
            cs.promo= '';
            cs.promo_expiration_date= '';
            cs.state= '';
            cs.owner_name= '';
            cs.comment= '';
            cs.waitlist_slot= '';
            cs.waitlist_type= '';
            cs.account_name= '';
            cs.account_sub_type= '';
            cs.bob_territory= '';
            cs.customer_id= '';
            cs.inventory_available_fast= 2;
            cs.inventory_available_flex= 2;
            cs.last_worked_date= '';
            cs.original_max_spend= '';
            cs.phone= '';
            cs.pre_auth_expiry_date= '';
            cs.pre_auth_status= '';
            cs.presales_available_date= '';
            cs.presales_available_fast= 3;
            cs.presales_available_flex= 3;
            cs.remnant_spend= '';
            cs.total_available_fast = 4;
            cs.total_available_flex = 4;
            cs.current_utilized_spend= '';
            cs.pricing_tier= '';

           
            AccountCreateWaitlist.marketWrapper mk = New AccountCreateWaitlist.marketWrapper
            (obj.ProductselectedVal, null, obj.TypeOptions,obj.MarketTypeselectedVal,obj.DegreeselectedVal,
             obj.LeadRoutingselectedVal, obj.LeadRoutingOptions, obj.Quantity, obj.Message, 'TigerLead' ,newAccount, obj.stateAbbrevation,
             obj.SlotSizeselectedVal, obj.SlotSizeOptions, obj.userntlogin, obj.Term,'6' ,null);
          mk.Status = null;
          /*
           AccountCreateWaitlist.marketWrapper mk1 = New AccountCreateWaitlist.marketWrapper
            (obj.ProductselectedVal, null, obj.TypeOptions,'CBC',obj.DegreeselectedVal,
             obj.LeadRoutingselectedVal, obj.LeadRoutingOptions, obj.Quantity, obj.Message, 'TigerLead' ,newAccount, obj.stateAbbrevation,
             obj.SlotSizeselectedVal, obj.SlotSizeOptions, obj.userntlogin, obj.Term,'12' ,null);
          mk1.Status = 'Pre-Auth';
           mk1.MaxSpend =0 ;
           mk1.quantity = 0 ;
            mk1.Product ='Turbo';
           */
           
          List<AccountCreateWaitlist.marketWrapper> wrper = new List<AccountCreateWaitlist.marketWrapper>();
           wrper.add(mk);
         //   wrper.add(mk1);
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorWlist());  
           Test.setMock(HttpCalloutMock.class, new AccountCreateWaitlist_test());
         obj.marketList =wrper; 
        obj.submit();  
           try{obj.callinventory(); }catch(Exception e){}
        obj.callapex();
           obj.totlaMaxPreAuthSpend=0.0;
        obj.cancel();
        obj.changeStatus();
        obj.changeStatusfromgrid();
        obj.FetchCityCountyPostcode();
        obj.FetchCityPostalcode();
        // obj.FetchMarketTypes();
        obj.FetchPostalcode();
        obj.stateSelected = 'NC';
        obj.CountySelected = new List<String>{'kalawao'};
        obj.CitySelected= new List<String>{'texas'};
        obj.FetchRoutingslottype();
        obj.GenerateTable();
        obj.queryCitys();
        obj.queryCountys();
        obj.queryDependecies();
        obj.querypostalcodes();
        obj.querypostalcodesforcities();
        obj.initProductChange();
        obj.changeStatusForRen();
        obj.deleteRow();
        
        Test.setMock(WebServiceMock.class, new WebServiceMockImplementation1());  
        //Test.setMock(WebServiceMock.class, new WebServiceMockVoidDocusign());
        //WebServiceMockVoidDocusign.callfrom = 'accounttrigger';   
        obj.Initialize();       
        obj.getStateOptions();
        obj.queryDependecies();
        obj.stateSelected = 'NC';
        obj.MarketTypeselectedVal = 'County';
        obj.FetchCityCountyPostcode();
        obj.queryCountys();
        obj.stateAbb = 'NC';
        obj.queryCitys(); 
        obj.MarketTypeselectedVal = 'City';
        obj.FetchCityCountyPostcode();
        obj.stateAbb = 'NC';
        obj.MarketTypeselectedVal = 'Postal Code';
        obj.FetchCityCountyPostcode();
        obj.FetchCityPostalcode();        
        obj.FetchPostalcode();
        obj.stateAbb = 'NC';              
        obj.querypostalcodes();
        obj.stateAbb = 'NC';
        obj.querypostalcodesforcities();
        // obj.getProductOptions(); 
        obj.MarketTypeselectedVal = 'City';
        obj.refresh();
        obj.MarketTypeselectedVal = 'County';
        obj.refresh();
        obj.callapex();            
        obj.changeStatus();             
        obj.cancel();
        obj.RefreshPage();
        obj.GenerateTable();            
        obj.TypeOptions =  new List<Selectoption>();
        obj.list2Options(tempStatus.values(),obj.TypeOptions);
        obj.addNoneOption(obj.list2Options(tempStatus.values(),obj.TypeOptions));
        obj.FetchRoutingslottype();
        obj.ProductselectedVal      = 'Connection for Co-Brokerage';
        obj.StatusselectedVal       = 'Pre-Auth';
        obj.MarketTypeselectedVal   = 'Postal Code';
        obj.DegreeselectedVal       = '';
        obj.LeadRoutingselectedVal  = 'Any';
        obj.Quantity = 6;
        obj.CC4digits = '0006';     
        obj.marketlist.add(mk);  
          obj.addToMarketList('CBCE' ,false);
           obj.GenerateTable();
           
        obj.submit(); 
        List<SelectOption> temps = new List<SelectOption> ();
        for(integer i=0;i<1000;i++){
            temps.add(new SelectOption(String.valueOf(i),String.valueOf(i)));   
        }
        
        obj.handleMorecitys(temps);
        obj.handleMorePostcode(temps);
        obj.handleMorePostcode(temps);
        obj.handleMorecountys(temps);
        List<SelectOption> temps1 = new List<SelectOption> ();
        for(integer i=0;i<2000;i++){
            temps1.add(new SelectOption(String.valueOf(i),String.valueOf(i)));   
        }
        
        obj.handleMorecitys(temps1);
        obj.handleMorePostcode(temps1);
        obj.handleMorePostcode(temps1);
        obj.handleMorecountys(temps1);
           List<SelectOption> temps21 = new List<SelectOption> ();
        for(integer i=0;i<3000;i++){
            temps21.add(new SelectOption(String.valueOf(i),String.valueOf(i)));   
        }
        
        obj.handleMorecitys(temps21);
        obj.handleMorePostcode(temps21);
        obj.handleMorePostcode(temps21);
        
        List<SelectOption> temps2 = new List<SelectOption> ();
        for(integer i=0;i<4000;i++){
            temps2.add(new SelectOption(String.valueOf(i),String.valueOf(i)));   
        }
        
        obj.handleMorecitys(temps2);
        obj.handleMorePostcode(temps1);
        obj.handleMorePostcode(temps1);
        obj.handleMorecountys(temps2);
           
  List<SelectOption> temps28 = new List<SelectOption> ();
        for(integer i=0;i<2500;i++){
            temps28.add(new SelectOption(String.valueOf(i),String.valueOf(i)));   
        }
                  obj.handleMorecountys(temps28);
           
            List<SelectOption> temps288 = new List<SelectOption> ();
        for(integer i=0;i<1500;i++){
            temps288.add(new SelectOption(String.valueOf(i),String.valueOf(i)));   
        }
                  obj.handleMorecountys(temps288);
           
           
           
 
        try{
            // obj.getProductOptions();
            obj.callinventory();
            
        }
        catch(Exception e){
            
        }
        try{
            obj.getProductOptions();
            //  obj.callinventory();
            
        }
        catch(Exception e){
            
        }
             //  System.assert(ApexPages.hasMessages(ApexPages.SEVERITY.ERROR));

        Test.stopTest();  
           
       }
    
    global HttpResponse respond( HttpRequest req){
         
       HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
          res.setBody('{"params":{"request":{"__type":"eai.waitlist.api.ServiceModel.WaitList.CreateWaitlist, eai.waitlist.api.ServiceModel","party_id":"4256221","market_name":"06021","market_type":"Postal Code","product_type":"Connection for Co-Brokerage","state":"CT","waitlist_type":"Pre-Auth","waitlist_slot":"Any","waitlist_status":"Pending Pre-Auth","lead_routing":"Any","quantity":1,"created_by":"MBARTELLI","owner_name":"MBARTELLI","account_name":"Mark Toledo","account_sub_type":"Customer","phone":"8603012339","original_max_spend":"12","remnant_spend":"12"}},"waitlist_guid":"103036cc-20b9-4cbf-a590-dc62581375f6","party_id":"4256221","product_type":"Connection for Co-Brokerage","market_type":"Postal Code","waitlist_slot":"Any","state":"CT","market_name":"06021","waitlist_type":"Pre-Auth","lead_routing":"Any","quantity":"1","owner_name":"MBARTELLI","created_by":"MBARTELLI","ranking":"0","account_name":"Mark Toledo","phone":"8603012339","last_worked_date":"","original_max_spend":"12","remnant_spend":"12","pre_auth_status_date":"","pre_auth_expiry_date":"","presales_available_date":"","inventory_available_flex":"0","presales_available_flex":"0","inventory_available_fast":"0","presales_available_fast":"0","total_available_flex":"0","total_available_fast":"0","account_sub_type":"Customer","waitlist_status":"Pending Pre-Auth","credit_risk":0}]');
        res.setStatusCode(201);
     return res;
            
        }
    private class WebServiceMockImplementation1 implements WebServiceMock{
        public void doInvoke(Object stub, Object request, Map<String, Object> response_map_x,String endpoint, String soapAction, String requestName,String responseNS, String responseName, String responseType)
        {
            DocuSignAPI.CreateAndSendEnvelopeResponse_element respElement = 
                new DocuSignAPI.CreateAndSendEnvelopeResponse_element ();
            DocuSignAPI.EnvelopeStatus SendEnvelopeResult  = new DocuSignAPI.EnvelopeStatus();
            SendEnvelopeResult.Status = 'Success';            
            SendEnvelopeResult.EnvelopeID = '12345';
            response_map_x.put('response_x', respElement);      
            
        }
        
        
        
    }
}