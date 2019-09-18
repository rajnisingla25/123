@isTest(seealldata=false)
global class DataController_Test implements HttpCalloutMock{
    private static Account newAccount;
    private static Account newAccount1;
    
    Boolean bMyWaitList=false;
    global static testMethod void main1(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DataController_Test());
        
        DisabledTrigger__c Dtrg  = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'test@test.com');
        insert Dtrg;
        BigMachineUrls__c bgm= new BigMachineUrls__c(Name='WLBM',BigmachineInstance__c='trnmoveinc',Bigmachine_Url__c='https://trnmoveinc.bigmachines.com/bmfsweb/trnmoveinc',DefaultPassword__c='csE7342(H4',DefaultUserName__c='sonusharma',Salesforce_Instance__c='https://bigmachines.cs11.visual.force.com');
        insert bgm;
        Waitlist_Urls__c wlu = new Waitlist_Urls__c(Name = 'CPQURL',URL__c = 'https://devmoveinc.bigmachines.com/commerce/buyside/document.jsp?bm_cm_process_id=36244034&formaction=performAction&document_id=36244074&action_id=36244076&version_id=36306984&id=');
        insert wlu;
        Waitlist_Urls__c wlu1 = new Waitlist_Urls__c(Name = 'CPQFULLURL',URL__c = 'https://devmoveinc.bigmachines.com/commerce/buyside/document.jsp?bm_cm_process_id=36244034&formaction=performAction&document_id=36244074&action_id=36244076&version_id=36306984&id=36942314');
        insert wlu1;
        Waitlist_Urls__c wlu2 = new Waitlist_Urls__c(Name = 'SOACUD' , URL__c = 'http://206.131.186.15:80/soa-infra/services/INV/SyncWaitListInventory/syncwaitlistinventoryservice_ep');
        insert wlu2;
        Waitlist_Urls__c wlu3 = new Waitlist_Urls__c(Name = 'accountOwnerChange',replacement_parameter__c='sreson@move.com');
        insert wlu3;
        //Ravi
        Waitlist_Limit__c wl1 = new Waitlist_Limit__c(Name = 'Max Number of Records',Value__c=10);
        insert wl1;
        //End 
        Schedule_Batch_Setting__c sbs = new Schedule_Batch_Setting__c(Name = 'Limit waitlist result',   Execution_Time_hr__c=4000);
        Insert sbs;
        newAccount = new Account();
        newAccount.name = 'XYZ';
        newAccount.Phone = '+49-12345';
        newAccount.BillingStreet = 'Am Tierpark 16';
        newAccount.BillingCity = 'Cologne';
        newAccount.BillingPostalCode = '54321';
        newAccount.BillingState = 'Nordrhein-Westfalen';
        newAccount.BillingCountry = 'Germany';
        newAccount.Primary_Email__c = 'ra@gmail.com';
        newAccount.Home_Phone__c = '1234567890 ';
        newAccount.Work_Phone__c = '1234567890 ';
        newAccount.Mobile1__c = '1234567890 ';
        newAccount.Mobile2_Other__c = '1234567890 ';
        newAccount.party_id__c = '95085343';
        Database.insert(newAccount);
        
        newAccount1 = new Account();
        newAccount1=newAccount;
        
         id cntctrectypid = [select id from RecordType where SobjectType = 'Contact' and name = 'Standard'].id;
        Contact cntctdata = new Contact();
        cntctdata.RecordTypeId = cntctrectypid;
        cntctdata.AccountId = newAccount.Id;
        cntctdata.FirstName = 'firstname';
        cntctdata.LastName = 'lastname';
        cntctdata.email = 's@s.com';
        Insert cntctdata;
        
        
        Waitlist__c wldata = new Waitlist__c();
        wldata.Account__c = newAccount.id;
        wldata.Status__c = 'Created';
        wldata.Pre_Auth_Contact__c = cntctdata.Id;
        wldata.Pre_Auth_Email__c = cntctdata.Email;
        Insert wldata;
        
        Product2 prdctdata = new Product2();
        prdctdata.Name = 'product name';
        prdctdata.S_No__c = 2;
        insert prdctdata;
        
        Waitlist_Item__c wlidata1 = new Waitlist_Item__c();
        wlidata1.Waitlist__c    = wldata.Id;
        wlidata1.Waitlist_ID__c = '7255ef36-ede7-4994-bc11-63f439fecf75'; 
        wlidata1.Waitlist_Expiration_Date__c  = system.today();
        wlidata1.Original_Max_Spend__c = 100;
        wlidata1.Status__c = 'Pending Pre-Auth';
        wlidata1.Account__c = newAccount.id;
        wlidata1.Product__c = prdctdata.id;
        wlidata1.Market__c = '30339';
        wlidata1.Market_Type__c = 'City';
        wlidata1.Product_Size__c = 'Full';
        wlidata1.rank__c = 0;
        insert wlidata1;
        
        //12a1-584a-4f56-bbc6-8a9be646d689
        //
        //
        
         Waitlist_Item__c wlidata12 = new Waitlist_Item__c();
        wlidata12.Waitlist__c    = wldata.Id;
        wlidata12.Waitlist_ID__c = '12a1-584a-4f56-bbc6-8a9be646d689'; 
        wlidata12.Waitlist_Expiration_Date__c  = system.today();
        wlidata12.Original_Max_Spend__c = 100;
        wlidata12.Status__c = 'Pending Pre-Auth';
        wlidata12.Account__c = newAccount.id;
        wlidata12.Product__c = prdctdata.id;
        wlidata12.Market__c = '30339';
        wlidata12.Market_Type__c = 'City';
        wlidata12.Product_Size__c = 'Full';
        wlidata12.rank__c = 0;
        insert wlidata12;
        
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
        
        
        Task ts = New Task(
            ActivityDate = Date.today().addDays(7),
            Subject='Sample Task',
            WhatId = newAccount.Id,
            OwnerId = UserInfo.getUserId(),
            Status='In Progress', 
            WaitlistGUIID__c = 'TEST123w',
            Priority = 'Normal');
        insert ts;
        
        List<Account> accList = new List<Account>();
        List<Map<String,Account>> accMap = new List<Map<String,Account>>(); 
        Map<String,Account> tempMap = new Map<String,Account>();
        tempMap.put('String1',newaccount1);
        accMap.add(tempMap);
        
        /*Map<String, Account> tempMap1 = new Map<String, Account>();
tempMap1.put('String2',newAccount1);
accMap.add(tempMap1);*/
        //accMap.add('Account',newAccount);
        //accList.add(accMap.get('Account'));  
        Waitlist_Urls__c wUrl = new Waitlist_Urls__c();
        wUrl.Name = 'waitlistLimit';
        wUrl.replacement_parameter__c = '5000';
        insert wurl;
        
        DataController obj = new DataController();
        
        //Ravi
        obj.showallactive = true;
        
       // obj.expireFIlter ='';
         //   obj.canceledFilter = '';
        obj.GlobalWaitlist = true ;
      //  obj.showcancel=true ;
        //obj.showexpired=true ;
        //obj.showfulfilled=true ;
        obj.opptId='';
       // obj.mFilterType=null;
       obj.MyUserNamePROFILE='' ;
        obj.MyUserNameLoginId = '';
        obj.CPQLoginDetails='';
        obj.CPQLogiURL='';
        
        
        obj.mFilterType='Owner';
        obj.mFilterType='Created By';
        obj.mFilterType='Market';
        obj.mFilterType='Waitlist Type';
        obj.mFilterType='Pre-Auth status';
        obj.mFilterType='Inventory Available Flex';
        obj.mFilterType='Inventory Available Fast';
        
//        obj
        obj.MYID=newAccount.id;
        //obj.mSetting_CPQUSER = 'csE7342(H4';
        obj.getMyUserName1();
        String WaitlistStatus;
        String n = WaitlistStatus;
        String newValue;
        String m = newValue;
        String mFilterType;
        String o = mFilterType;
        String MyValue;
        String p = MyValue;        
        obj.setPhone(m);
        obj.getPhone();
        obj.setBOB(m);
        obj.getBOB();
        obj.getTZ();
        obj.setTZ(m);
        
        ApexPages.StandardController sc1 = new ApexPages.standardController(newAccount);
        DataController obj1 = new DataController(sc1);
          PageReference pageRef = Page.AccountWaitlist;
        Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('MyWaitlist','MyWaitlist');

        ApexPages.currentPage().getParameters().put('id',newAccount.Id);
        Test.setMock(HttpCalloutMock.class, new DataController_Test());

        obj1.GlobalWaitlist = false ;
        
        //obj1.mFilterType=null ;
        //obj1.mFilterType=null;
       // obj1.showcancel = true ; 
        //obj1.showfulfilled = true ; 
        //bj1.showexpired = true ;
        
        obj1.mCustomerName = newAccount.name;
        obj1.mPhone = newAccount.Phone;
        obj1.mBOB_Territory ='';
        obj1.createtask = true;
        obj1.taskdata.add(ts);
        obj1.StoreMainParameters();
        obj1.setToken(m);
        obj1.getToken();
        obj1.setDegree(m);
        obj1.getDegree();
        obj1.setSlotSize(m);
        obj1.getSlotSize();
        obj1.setLeadRoutingType(m);
        obj1.getLeadRoutingType();
        obj1.setStatus(m);
        obj1.getStatus();
        obj1.setJson(m);
        obj1.getJson();
        obj1.setAccountId(m);
        obj1.getAccountId();
        obj1.setNotes(m);
        obj1.getNotes();
        obj1.setqtyinterested(m);
        obj1.getqtyinterested();
        obj1.setoperation(m);
        obj1.getoperation();
        obj1.getMyOrderBy();
        obj1.setMyOrderBy(m);
        obj1.getMyFilter();
        obj1.setMyFilter(m);
        obj1.getMyLimit();
        obj1.setMyLimit(m);
        obj1.getWaitlistStatus();
        obj1.getAccountName();
        n = '';
        obj1.setWaitlistStatus(n);
        obj1.makeSOACallforGet();
        o = 'Assigned AE';
        obj1.setFilterType(o);
        o = 'Waitlist Status';
        obj1.setFilterType(o);
        
        o = 'Waitlist Type';
        obj1.setFilterType(o);
        o = 'Inventory Available Flex';
        p = 'Greater%20than%20Zero';
        obj1.setInputValue(p);
        p = 'Greater%20than%201';
        obj1.setInputValue(p);
        p = 'Greater%20than%205';
        obj1.setInputValue(p);
        p = 'Greater%20than%2010';
        obj1.setInputValue(p);
        p = 'Greater%20than%2050';
        obj1.setInputValue(p);
        p = 'Greater%20than%2025';
        obj1.setInputValue(p);
        obj1.setFilterType(o);
        obj1.setInputValue(p);
        o = 'Inventory Available Fast';
        p = 'Greater%20than%20Zero';
        obj1.setInputValue(p);
        p = 'Greater%20than%201';
        obj1.setInputValue(p);
        p = 'Greater%20than%205';
        obj1.setInputValue(p);
        p = 'Greater%20than%2010';
        obj1.setInputValue(p);
        p = 'Greater%20than%2050';
        obj1.setInputValue(p);
        p = 'Greater%20than%2025';
        obj1.setInputValue(p);
        obj1.setFilterType(o);
        obj1.setInputValue(p);
        o = 'Presales Available Flex';
        p = 'Greater%20than%20Zero';
        obj1.setInputValue(p);
        p = 'Greater%20than%201';
        obj1.setInputValue(p);
        p = 'Greater%20than%205';
        obj1.setInputValue(p);
        p = 'Greater%20than%2010';
        obj1.setInputValue(p);
        p = 'Greater%20than%2050';
        obj1.setInputValue(p);
        p = 'Greater%20than%2025';
        obj1.setInputValue(p);
        obj1.setFilterType(o);
        obj1.setInputValue(p);
        o = 'Presales Available Fast';
        p = 'Greater%20than%20Zero';
        obj1.setInputValue(p);
        p = 'Greater%20than%201';
        obj1.setInputValue(p);
        p = 'Greater%20than%205';
        obj1.setInputValue(p);
        p = 'Greater%20than%2010';
        obj1.setInputValue(p);
        p = 'Greater%20than%2050';
        obj1.setInputValue(p);
        p = 'Greater%20than%2025';
        obj1.setInputValue(p);
        obj1.setFilterType(o);
        obj1.setInputValue(p);
        o = 'Product';
        obj1.setFilterType(o);
        o = 'Input AE';
        obj1.setFilterType(o);
        o = 'No of Records';
        obj1.setFilterType(o);
        o = 'Market';
        obj1.setFilterType(o);
        o = 'Customer';
        obj1.setFilterType(o);
        obj1.getWaitlistStatusItems();
        
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Waitlist Type','Waitlist Type'));
        options.add(new SelectOption('Pre-Auth status','Pre-Auth status'));
        
      
        obj1.refreshPage();
        
        //obj1.getFilterList();
        obj1.getFilterType();
        
        obj1.setFilterType(o);
        obj1.getInputList();
        obj1.getInputType();
        obj1.setInputType(m);
        obj1.getInputValue();
        m = '';
        obj1.setInputValue(m);
        obj1.AssignFilterValue(p);
        // obj.mFilterType='Owner';
        
        //obj1.mParty_Id = '12345';
        obj1.GenerateWLforSOACall('token','market','markettype','95085343','status','degree','leadroutingtype','slotsize','marketspend','notes','qtyinterested','json','operation','CBC');
        obj1.makeSOACall();
        obj1.submit();
        obj1.SetPageSize();
        obj1.GenerateWLforSOACall('token','market','markettype','95085343','status','degree','leadroutingtype','slotsize','marketspend','notes','qtyinterested','json','delete','CBC');
        DataController.GUidclass guidClass = new DataController.GUidclass();
        guidClass.token='12a1-584a-4f56-bbc6-8a9be646d689';
        
        DataController.CancelPreAuth(new List<DataController.GUidclass>{guidClass});
        try{
                   DataController.ProcessCancelPreAuth(new Set<String>{guidClass.token});
 
        }catch(Exception e){
            
        }
        //DataController.getAccountWLs(null,null);
        DataController.Waitlist robj = new DataController.Waitlist();
        robj.account_party_id='95085343';
        
      //  WLJson WLJ = new WLJson('party_id','product_type','market_name','market_type','market_subtype','waitlist_slot','territory','waitlist_status','waitlist_degree','lead_routing','quantity','owner_name','created_by','created_date','updated_by','updated_date','comment','ranking','customer_id','account_name','bob_territory','inventory_available_flex','presales_available_flex','inventory_available_fast','presales_available_fast','total_available_flex','waitlist_guid','max_spend_per_month','waitlist_type','phone','utilized_spend_per_month','remnant_spend_per_month');
        
        //WLJ.party_id = '1345';
        //WLJ.product_type = 'Connection for Co-Brokerage';
        //obj1.WLJsonlist.add(WLJ);
        //DataController.Hotlist WLH = new DataController.Hotlist('authorization_status','authorization_date','authorization_expiration','promotion','promotion_expiration_date','max_spend_per_month','utilized_spend_per_month','phone','remnant_spend_per_month','waitlist_status_change_date','last_call_status','last_worked_date','pre_auth_status','pre_auth_status_date','pre_auth_expiry_date','monthly_spend_original','monthly_spend_current','monthly_spend_remaining');
        DataController.WLMaster WLobj = new DataController.WLMaster('offset','total',null,null);
       // DataController.GUidclass = new DataController.GUidclass();
        
        insert new DocuSignCredentials__c(Name='ravinder4a2@gmail.com', IntegratorsKey__c = 'MOVE-d2cdaebb-3c48-4868-a026-c9409ce57faf', UserId__c = 'ravinder4a2@gmail.com', AccountId__c = 'e7bee96b-5fcf-4d0d-8d67-c91349b4a2dd', Password__c = 'believe4a2', WebServiceUrl__c = 'https://demo.docusign.net/api/3.0/dsapi.asmx' );
        
        
        
      //  DataController.waitlists(accMap);
        obj1.getWLsAjax();
        
        
        DataController.Waitlist DC = new DataController.Waitlist();
        List<DataController.Waitlist> WD = new List<DataController.Waitlist>();
         Error__c error = new Error__c();
            error.Name = 'Class - Datacontroller';
            error.Entity_Id__c = 'Method - ProcessCancelPreAuth';
            error.Interface_Name__c = 'While updating Waitlist_Item__c Object';
            error.Error_Description__c = 'Message:';
        insert error ;
        
        //     WD.add(DC);
        
        
        // if  (obj.GetWaitlistfromWebService() !=null)
        //  {}
        DataController.Waitlist DF = new DataController.Waitlist();
        DF.account_party_id = '95085343';
        List<DataController.Waitlist> DF1 = new List<DataController.Waitlist>();
        DF1.add(DF);
        Set<String> partylist1 = new Set<String>();
        List<String> partylist2 = new List<String>{'95085343'};
        partylist1.addAll(partylist2);
        DF1 = obj1.FillAccountValues(DF1,partylist1);
        
        //  DataController.Hotlist HL = new DataController.Hotlist();
        DataController.Hotlist HL1 = new DataController.Hotlist(
            'Test' ,
            'Test' ,
            'authorization_expiration' ,
            'promotion' ,
            'string promotion_expiration_date' ,
            'string original_max_spend' ,
            'string remnant_spend' ,
            'string current_utilized_spend' ,
            'string phone' ,
            'string remnant_spend_per_month',
            'string waitlist_status_change_date' ,
            'string last_call_status',
            'string last_worked_date' ,
            'string pre_auth_status' ,
            'string pre_auth_status_date' ,
            'string pre_auth_expiry_date' ,
            'string monthly_spend_original' ,
            'string monthly_spend_current' ,
            'string monthly_spend_remaining' );
        
        
        
        
        DataController.Waitlist WL = new DataController.Waitlist();
        WL.token = 'XXX';
        
        WL.product = 'CBC';
        WL.geo  = 'XXX';
        WL.status = 'XXX';
        WL.geotype = 'XXX';
        WL.geosubtype ='XXX';
        WL.leadroutingtype = 'XXX';
        WL.slotsize = 'XXX';
        
        WL.qtyinterested = 'XXX';
        
        
        WL.degree = 'XXX' ;
        
        //WL.createddate = obj1.created_date; // need to convert date time
        WL.notes='XXX';
        WL.rank ='XXX'; 
        WL.invtotalavailable = 'XXX' ;// + obj1.presalestotalavailableflex;
        WL.invtotalavailableflex = 'XXX';
        WL.invtotalavailablefast ='XXX';
        //  WL.presalesavailable {get;set;} // Pre Sales Available 
        // WL.presalestotalavailable {get;set;} // Total Presales
        WL.presalestotalavailableflex = 'XXX';
        WL.presalestotalavailablefast = 'XXX';
        WL.presalesavailable ='XXX';
        WL.presalestotalavailable = 'XXX';
        WL.presalesavailabledate = 'XXX';
        WL.preauthstatus = 'XXX';
        WL.preauthstatusdate= 'XXX';
        WL.createddate = 'XXX';
        WL.lastupdated= 'XXX';
        WL.phone= 'XXX';
        //   WL.presalesavailabledate {get;set;} // Presales Available Date 
        
        //  WL.preauthstatus = obj1.Hotlist.pre_auth_status; // Commented out
        
        
        // WL.preauthstatusdate = obj1.pre_auth_status_date; // need conversion
        // WL.lastupdated =obj1.updated_date ; //same as above
        WL.account_party_id = 'XXX' ;
        WL.marketspend = 'XXX';
        WL.utilspend = 'XXX';
        WL.remnantspend = 'XXX';
        WL.waitlist_type = 'XXX';
        WL.ownername = 'XXX';
        WL.createdby = 'XXX';
        
        WL.bob = 'XXX';
        WL.sfdc_account_id = 'XXX' ;
        WL.accountname = 'XXX';
        WL.accountsubtype = 'XXX' ;
        List<SelectOption> options1 = new List<SelectOption>();
        
        options1.add(new SelectOption('',''));
        //options.add(new SelectOption('Pending Configuration','Pending Configuration'));
        options1.add(new SelectOption('Pending Pre-Auth','Pending Pre-Auth'));
        options1.add(new SelectOption('Pending Pre-Auth Approval','Pending Pre-Auth Approval'));
        //options.add(new SelectOption('Pending Inventory','Pending Inventory'));
        options1.add(new SelectOption('Fulfilled','Fulfilled'));
        options1.add(new SelectOption('Active','Active'));
        options1.add(new SelectOption('Created','Created'));
        options1.add(new SelectOption('Pre-Auth','Pre-Auth'));
        options1.add(new SelectOption('Hot','Hot'));
        options1.add(new SelectOption('Warm','Warm'));
        options1.add(new SelectOption('Pipeline','Pipeline'));
        options1.add(new SelectOption('Connection for Co-Brokerage','Connection for Co-Brokerage'));
        //options.add(new SelectOption('Feature Home','Feature Home'));
        //options.add(new SelectOption('FAC','FAC'));
        options1.add(new SelectOption('DAP','Digital Ad Package'));
        options1.add(new SelectOption('TigerLead HS','TigerLead Home Search'));
        options1.add(new SelectOption('TigerLead HL','TigerLead Hand Raiser'));
        
        options1.add(new SelectOption('Please type user NT Login ID in right cell','Please type user NT Login ID in right cell'));
        options1.add(new SelectOption('Please type user NT Login ID','Please type user NT Login ID in right cell'));
        options1.add(new SelectOption('Please type market value','Please type market value in right cell'));
        options1.add(new SelectOption('500','500'));
        options1.add(new SelectOption('1000','1000'));
        options1.add(new SelectOption('1500','1500'));
        options1.add(new SelectOption('2000','2000'));                
        options1.add(new SelectOption('Please type market value','Please type market value in right cell'));
        options1.add(new SelectOption('Please type customer name','Please type customer name in right cell'));
        options1.add(new SelectOption('Please type customerCustomer Id','Please type customerCustomer Id in right cell'));
        
        //   List<SelectOption> SO =   obj1.getFilterList();
        
        set<string> GUidset = new set<string>();
        GUidset.add('XXX');
        
        obj1.Sendjson='XXX';
        obj1.MyUserProfileManagerId ='XXX';
        obj1.MyUserTimezone ='XXX';
        
        insert new Waitlist_Urls__c(Name='Inventory Read', URL__c = 'https://dev-es-wls.api.move.com/search.json?');
        // DataController.Waitlist[] wlArr = new DataController.Waitlist[]{};
        
        DataController.Response WLArra = new DataController.Response(12 ,12, null);
         
        
        obj1.accountwaitlist =   obj1.GetWaitlistfromWebService();
        if(obj1.accountwaitlist !=null)
        {}
        obj1.accountwaitlist = null ;
        if(obj1.accountwaitlist ==null)
        {}
        obj1.setFilterType('Pre-Auth status');
        obj1.getWaitlistStatusItems();
        obj1.setWaitlistStatus('Pre-Auth status');
        obj1.setFilterType('Waitlist Type');
        obj1.getWaitlistStatusItems();
        obj1.setWaitlistStatus('Hot');
        obj1.setFilterType('Product'); 
        obj1.getWaitlistStatusItems();
        obj1.setWaitlistStatus('Product');
        obj1.setFilterType('Owner'); 
        obj1.getWaitlistStatusItems();
        obj1.setWaitlistStatus('Owner');
        
        obj1.setFilterType('Created By');
        obj1.getWaitlistStatusItems();
        obj1.setWaitlistStatus('Created By');
        
        obj1.setFilterType('No of Records');
        obj1.getWaitlistStatusItems();
        obj1.setWaitlistStatus('10');
        
        obj1.setFilterType('Market');
        obj1.getWaitlistStatusItems();
        obj1.setWaitlistStatus('94536');
        
        obj1.setFilterType('Customer Id');
        
        obj1.setFilterType('Assigned AE');
        obj1.getWaitlistStatusItems();
        obj1.MyGroupName='Hybrid Inbound Team';
        obj1.setWaitlistStatus('Assigned AE');
        
        
        obj1.setFilterType('Input AE');
        obj1.getWaitlistStatusItems();
        obj1.setWaitlistStatus('Input AE');
        
        obj1.getFilterList();
        
        obj1.setFilterType('Inventory Available Fast');
        obj1.AssignFilterValue('Greater%20than%20Zero');
        obj1.AssignFilterValue('Greater%20than%20One');
        obj1.AssignFilterValue('Greater%20than%201');
        obj1.AssignFilterValue('Greater%20than%205');
        obj1.AssignFilterValue('Greater%20than%2010');
        obj1.AssignFilterValue('Greater%20than%2050');
        obj1.AssignFilterValue('Greater%20than%2025');
        
        obj1.setFilterType('Presales Available Fast');
        obj1.AssignFilterValue('Greater%20than%20Zero');
        obj1.AssignFilterValue('Greater%20than%20One');
        obj1.AssignFilterValue('Greater%20than%201');
        obj1.AssignFilterValue('Greater%20than%205');
        obj1.AssignFilterValue('Greater%20than%2010');
        obj1.AssignFilterValue('Greater%20than%2050');
        obj1.AssignFilterValue('Greater%20than%2025');
        
        
        obj1.setFilterType('Inventory Available Flex');
        obj1.AssignFilterValue('Greater%20than%20Zero');
        obj1.AssignFilterValue('Greater%20than%20One');
        obj1.AssignFilterValue('Greater%20than%201');
        obj1.AssignFilterValue('Greater%20than%205');
        obj1.AssignFilterValue('Greater%20than%2010');
        obj1.AssignFilterValue('Greater%20than%2050');
        obj1.AssignFilterValue('Greater%20than%2025');
        
        obj1.setFilterType('Presales Available Flex');
        obj1.AssignFilterValue('Greater%20than%20Zero');
        obj1.AssignFilterValue('Greater%20than%20One');
        obj1.AssignFilterValue('Greater%20than%201');
        obj1.AssignFilterValue('Greater%20than%205');
        obj1.AssignFilterValue('Greater%20than%2010');
        obj1.AssignFilterValue('Greater%20than%2050');
        obj1.AssignFilterValue('Greater%20than%2025');
        
        String[] columns = new List<String>();
        columns.add('Phone');
        columns.add('Market');
        
        String[] sortColumns = new List<String>();
        sortColumns.add('ASC');
        sortColumns.add('DESC');
        
        Integer[] sortColumnsDi = new List<Integer>();
        sortColumnsDi.add(12);
        
        
        
        //DataController.Params pamersm = new DataController.Params(1,10,20,columns,sortColumns,sortColumnsDi);
        
        Set<String> waitListGUI = new Set<String>();
        waitListGUI.add('7255ef36-ede7-4994-bc11-63f439fecf75');
        waitListGUI.add('c0c35d04-b66d-4507-afc5-927d6e47cbff');
        waitListGUI.add('7255ef36-ede7-4994-bc11-63f439fecf75');
        
        //DataController.VoidEnvelope(new List<DataController.GUidclass>{guidClass});
        
        
        
        
       

//   DataController.Waitlist sob  = new  DataController.Waitlist[]();
DataController.Waitlist[] WLs90 = new DataController.Waitlist[] {};
//  String formattedDt = myDateTime.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
//String formattedDt = myDateTime.format('MM-dd-yyyy');


for (Integer i=1;i<=20;i++)
{ 
DataController.Waitlist tmp = new DataController.Waitlist();
tmp.account_party_id = '95085343';
tmp.accountname ='BCBS';
tmp.rateCardPrice ='12';
//WLs.add(tmp);    
}


        
        wwwMoveCom obj90 = new wwwMoveCom();
        wwwMoveCom.WaitListType obj199 = new wwwMoveCom.WaitListType();
        wwwMoveCom.request_element obj299 = new wwwMoveCom.request_element();
        wwwMoveCom.waitlist obj399 = new wwwMoveCom.waitlist();
        wwwMoveCom.params_element obj499 = new wwwMoveCom.params_element();
        wwwMoveCom.SyncWaitListRes_element obj599 = new wwwMoveCom.SyncWaitListRes_element();
        
        
        DataController.Waitlist[] WLs = new DataController.Waitlist[] {};
            datetime myDateTime = datetime.now();
        String formattedDt = myDateTime.format('MM-dd-yyyy');
        
        
        for (Integer i=1;i<=20;i++)
        { 
            DataController.Waitlist tmp = new DataController.Waitlist();
            tmp.account_party_id = '95085343';
            tmp.accountname ='BCBS';
            
            WLs.add(tmp);    
        }
        
        List<Map<String, Object>> request1 = new List<Map<String, Object>>();
        Map<String, Object> Mp1 = new Map<String, Object>();
        Mp1.put('String' ,WLs);
        request1.add(Mp1);
        try{
            DataController.waitlists(request1) ;
             Profile p12 = [select id from profile where name='Read Only'];
        User u12 = new User(alias = 'standt', email='standarduser@testorg.com',
                          emailencodingkey='UTF-8', lastname='Someone', languagelocalekey='en_US', 
                          localesidkey='en_US', profileid = p12.Id,
                          timezonesidkey='America/New_York', username='So12121meone@test.com'); 
        insert u12;
            System.runAs(u12){
                   DataController.ProcessCancelPreAuth(new Set<String>{guidClass.token,guidClass.token,null ,'1212121212'});
//DataController.CancelPreAuth(new Set<String>{guidClass.token});
          DataController.CancelPreAuth(new List<DataController.GUidclass>{guidClass,guidClass,guidClass,guidClass});
//DataController.VoidEnvelope(new List<DataController.GUidclass>{guidClass,guidClass,guidClass});
                
                }
           // DataController.CancelPreAuth(null) ;
            //DataController.VoidEnvelope(null) ;
            
        }catch(Exception e){
            
        }
        
         Profile profileadmin = [select id from profile where name='Admin Read Only'];
        User adminUser = new User(alias = 'axyb', email='standarduser@testorg.com',
                          emailencodingkey='UTF-8', lastname='Someone', languagelocalekey='en_US', 
                          localesidkey='en_US', profileid = profileadmin.Id,
                          timezonesidkey='America/New_York', username='adminuseruniquevalue@test.com'); 
        insert adminUser;
           
        User u = [SELECT id FROM user WHERE isactive=true and profile.name=  'Admin Read Only' LIMIT 1];
         DataController.GUidclass var1 = new DataController.GUidclass();
        var1.token = '7255ef36-ede7-4994-bc11-63f439fecf75';     
        DataController.GUidclass var2 = new DataController.GUidclass();
        var2.token = 'c0c35d04-b66d-4507-afc5-927d6e47cbff'; 
        DataController.GUidclass var3 = new DataController.GUidclass();
        var3.token = '12a1-584a-4f56-bbc6-8a9be646d689';       
        
        
        System.runAs(u){
        
        wldata = new Waitlist__c();
        wldata.Account__c = newAccount.id;
        wldata.Status__c = 'Created';
        wldata.Pre_Auth_Contact__c = cntctdata.Id;
        wldata.Pre_Auth_Email__c = cntctdata.Email;
        Insert wldata;

        
        wlidata1 = new Waitlist_Item__c();
        wlidata1.Waitlist__c    = wldata.Id;
        wlidata1.Waitlist_ID__c = '7255ef36-ede7-4994-bc11-63f439fecf75'; 
        wlidata1.Waitlist_Expiration_Date__c  = system.today();
        wlidata1.Original_Max_Spend__c = 100;
        wlidata1.Status__c = 'Pending Pre-Auth';
        wlidata1.Account__c = newAccount.id;
        wlidata1.Product__c = prdctdata.id;
        wlidata1.Market__c = '30339';
        wlidata1.Market_Type__c = 'City';
        wlidata1.Product_Size__c = 'Full';
        wlidata1.rank__c = 0;
        insert wlidata1;
        
        //12a1-584a-4f56-bbc6-8a9be646d689
        //
        //
        
        wlidata12 = new Waitlist_Item__c();
        wlidata12.Waitlist__c    = wldata.Id;
        wlidata12.Waitlist_ID__c = '12a1-584a-4f56-bbc6-8a9be646d689'; 
        wlidata12.Waitlist_Expiration_Date__c  = system.today();
        wlidata12.Original_Max_Spend__c = 100;
        wlidata12.Status__c = 'Pending Pre-Auth';
        wlidata12.Account__c = newAccount.id;
        wlidata12.Product__c = prdctdata.id;
        wlidata12.Market__c = '30339';
        wlidata12.Market_Type__c = 'City';
        wlidata12.Product_Size__c = 'Full';
        wlidata12.rank__c = 0;
        insert wlidata12;
        
       
        try{
            DataController.VoidEnvelope(new List<DataController.GUidclass>{var1, var2, var3});
            DataController.CancelPreAuth(new List<DataController.GUidclass>{var1, var2, var3});
            
        }catch(Exception e){
            
        }
        
        }
         DataController.VoidEnvelope(new List<DataController.GUidclass>{var1, var2, var3});
        
        Test.stopTest();
    }
    
    global HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setStatus('Success');
res.setStatusCode(200);
res.setBody('{"offset":0,"total":4,"results":[{"party_id":"95085343","waitlist_status":"Active","product_type":"Connection for Co-Brokerage","market_type":"Postal Code","waitlist_slot":"Any","state_id":"CO","market_name":"80005","waitlist_type":"Pre-Auth","waitlist_status_change_date":"5/6/2016 9:35:06 PM +00:00","waitlist_degree":"Warm 1","lead_routing":"Any","quantity":"0","call_status":"Waitlisted","ranking":"900","promo_expiration_date":"1/1/0001 12:00:00 AM +00:00","owner_name":"MBARTELLI","created_by":"MBARTELLI","created_date":"5/6/2016 9:35:06 PM +00:00","updated_by":"rajamohan.vakati@move.com.sit","updated_date":"11/17/2016 11:06:00 PM +00:00","comment":"Aa","account_name":"Jeff Boyce","account_sub_type":"Prospect","last_worked_date":"1/1/0001 12:00:00 AM +00:00","original_max_spend":"295","current_utilized_spend":"0.0","remnant_spend":"295.00","pre_auth_status_date":"1/1/0001 12:00:00 AM +00:00","pre_auth_expiry_date":"1/1/0001 12:00:00 AM +00:00","presales_available_date":"1/1/0001 12:00:00 AM +00:00","inventory_available_flex":"1","presales_available_flex":"0","inventory_available_fast":"3","presales_available_fast":"0","total_available_flex":"1","total_available_fast":"3","markets":[{"waitlist_id":196375,"waitlist_guid":"7255ef36ede74994bc1163f439fecf75","historical_tier_price_number":248,"historical_flex_unit_price":644.0000,"historical_fast_unit_price":332.0000,"market_id":27064,"market_key":"80005&#124;CO&#124;COBROKE&#124;POSTALCODE&#124;FULL","current_tier_price_number":248,"current_flex_unit_price":644.0000,"current_fast_unit_price":332.0000},{"waitlist_id":196375,"waitlist_guid":"7255ef36ede74994bc1163f439fecf75","historical_tier_price_number":268,"historical_flex_unit_price":322.0000,"historical_fast_unit_price":166.0000,"market_id":59201,"market_key":"80005&#124;CO&#124;COBROKE&#124;POSTALCODE&#124;HALF","current_tier_price_number":268,"current_flex_unit_price":322.0000,"current_fast_unit_price":166.0000}],"waitlist_id":196375,"waitlist_guid":"7255ef36-ede7-4994-bc11-63f439fecf75"},{"party_id":"268728239","waitlist_status":"Active","product_type":"Connection for Co-Brokerage","market_type":"Postal Code","waitlist_slot":"Any","state_id":"FL","market_name":"34103","waitlist_type":"Hot","waitlist_status_change_date":"4/25/2016 9:15:44 PM +00:00","lead_routing":"Flex","quantity":"1","call_status":"Waitlisted","ranking":"0","promo_expiration_date":"1/1/0001 12:00:00 AM +00:00","owner_name":"MBARTELLI","created_by":"TONEAL","created_date":"4/25/2016 9:15:44 PM +00:00","account_name":"Mike Shoaff","account_sub_type":"Customer","last_worked_date":"1/1/0001 12:00:00 AM +00:00","original_max_spend":"0","remnant_spend":"0","pre_auth_status_date":"1/1/0001 12:00:00 AM +00:00","pre_auth_expiry_date":"1/1/0001 12:00:00 AM +00:00","presales_available_date":"1/1/0001 12:00:00 AM +00:00","inventory_available_flex":"1","presales_available_flex":"0","inventory_available_fast":"0","presales_available_fast":"0","total_available_flex":"1","total_available_fast":"0","markets":[{"waitlist_id":191336,"waitlist_guid":"c0c35d04b66d4507afc5927d6e47cbff","historical_tier_price_number":242,"historical_flex_unit_price":1120.0000,"historical_fast_unit_price":578.0000,"market_id":11335,"market_key":"34103&#124;FL&#124;COBROKE&#124;POSTALCODE&#124;FULL","current_tier_price_number":242,"current_flex_unit_price":1120.0000,"current_fast_unit_price":578.0000},{"waitlist_id":191336,"waitlist_guid":"c0c35d04b66d4507afc5927d6e47cbff","historical_tier_price_number":262,"historical_flex_unit_price":560.0000,"historical_fast_unit_price":289.0000,"market_id":43472,"market_key":"34103&#124;FL&#124;COBROKE&#124;POSTALCODE&#124;HALF","current_tier_price_number":262,"current_flex_unit_price":560.0000,"current_fast_unit_price":289.0000}],"waitlist_id":191336,"waitlist_guid":"c0c35d04-b66d-4507-afc5-927d6e47cbff"},{"party_id":"214723712","waitlist_status":"Pending Pre-Auth Approval","product_type":"Connection for Co-Brokerage","market_type":"Postal Code","waitlist_slot":"Any","state_id":"WA","market_name":"98368","waitlist_type":"Pre-Auth","waitlist_status_change_date":"3/25/2016 10:33:07 PM +00:00","waitlist_degree":"Warm 1","lead_routing":"Fast","quantity":"0","call_status":"Waitlisted","ranking":"11","promo_expiration_date":"1/1/0001 12:00:00 AM +00:00","owner_name":"MBARTELLI","created_by":"MBARTELLI","created_date":"3/25/2016 10:33:07 PM +00:00","updated_by":"rajamohan.vakati@move.com.sit","updated_date":"11/18/2016 9:01:40 AM +00:00","comment":"ASDAS","account_name":"Brian Becker","account_sub_type":"Prospect","phone":"(360) 385-6499","last_worked_date":"1/1/0001 12:00:00 AM +00:00","original_max_spend":"210","current_utilized_spend":"0.0","remnant_spend":"210.00","pre_auth_status_date":"1/1/0001 12:00:00 AM +00:00","pre_auth_expiry_date":"1/1/0001 12:00:00 AM +00:00","presales_available_date":"1/1/0001 12:00:00 AM +00:00","inventory_available_flex":"0","presales_available_flex":"0","inventory_available_fast":"3","presales_available_fast":"0","total_available_flex":"0","total_available_fast":"3","markets":[{"waitlist_id":177503,"waitlist_guid":"c8db14effb6a4c448375f8f585b795cd","historical_tier_price_number":10,"historical_flex_unit_price":216.0000,"historical_fast_unit_price":112.0000,"market_id":31643,"market_key":"98368&#124;WA&#124;COBROKE&#124;POSTALCODE&#124;FULL","current_tier_price_number":10,"current_flex_unit_price":216.0000,"current_fast_unit_price":112.0000},{"waitlist_id":177503,"waitlist_guid":"c8db14effb6a4c448375f8f585b795cd","historical_tier_price_number":30,"historical_flex_unit_price":108.0000,"historical_fast_unit_price":56.0000,"market_id":63780,"market_key":"98368&#124;WA&#124;COBROKE&#124;POSTALCODE&#124;HALF","current_tier_price_number":30,"current_flex_unit_price":108.0000,"current_fast_unit_price":56.0000}],"waitlist_id":177503,"waitlist_guid":"c8db14ef-fb6a-4c44-8375-f8f585b795cd"},{"party_id":"61275111","waitlist_status":"Created","product_type":"Connection for Co-Brokerage","market_type":"Postal Code","waitlist_slot":"full","state_id":"FL","market_name":"32136","waitlist_type":"Hot","waitlist_status_change_date":"1/30/2016 1:39:13 AM +00:00","waitlist_degree":"Warm 1","lead_routing":"fast","quantity":"1","call_status":"Waitlisted","ranking":"5","owner_name":"MBARTELLI","created_by":"bburrett","created_date":"1/30/2016 1:39:13 AM +00:00","updated_by":"rajamohan.vakati@move.com.sit","updated_date":"11/17/2016 10:29:57 PM +00:00","comment":"na re wl","account_name":"ROBERT ELSBREE","account_sub_type":"Customer","bob_territory":"150006","phone":"(386) 569-1913","last_worked_date":"11/30/2015 7:00:00 AM +00:00","pre_auth_status_date":"1/1/0001 12:00:00 AM +00:00","pre_auth_expiry_date":"1/1/0001 12:00:00 AM +00:00","presales_available_date":"1/1/0001 12:00:00 AM +00:00","inventory_available_flex":"0","presales_available_flex":"0","inventory_available_fast":"1","presales_available_fast":"0","total_available_flex":"0","total_available_fast":"1","markets":[{"waitlist_id":107455,"waitlist_guid":"b92712a1584a4f56bbc68a9be646d689","historical_tier_price_number":89,"historical_flex_unit_price":370.0000,"historical_fast_unit_price":191.0000,"market_id":10525,"market_key":"32136&#124;FL&#124;COBROKE&#124;POSTALCODE&#124;FULL","current_tier_price_number":89,"current_flex_unit_price":370.0000,"current_fast_unit_price":191.0000}],"waitlist_id":107455,"waitlist_guid":"b92712a1-584a-4f56-bbc6-8a9be646d689"}]}');
        return res ;
        
        
    }
}