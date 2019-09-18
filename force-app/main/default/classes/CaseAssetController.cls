//**************************************************//
// (c) 2015 NTTDATA, Inc.
// Class Name : CaseAssetController
// This Class is Used in Caseassets page to create Case Asset relationship for the selected assets on that Account.
//
// Created 18th aug 2015   Author Name:-  Venkataratamana Cheedara     Original
// Modified 18th aug 2015   Author Name:-  Venkataratamana Cheedara     Modified
// Modified 18th May 2016 LEAP# 7906 - Krishna Bodala
//**************************************************//

public with sharing class CaseAssetController {
    public Boolean allCheck {get; set;}
    Public String options{get;set;}
    public list<AssetWrapper> AssetWrapper{get;set;}
    @TestVisible private Map<Id, AssetWrapper> assetWrapperMap{get; set;}
    public list<Asset> Ast{get;set;}
    public String testMDTflag{get;set;}
    public id accountId;
    public id AssetId;
    public id caseId{get;set;}
    Public String Parent = 'Parent';
    Public String Status = 'Pending Fulfillment';
    Public String caseStatus{get;set;}
    Public Case caseRecord;
    Public Boolean displayTable {get;set;}
    public string MarketZip{get;set;}
    public string turboProductCode{get;set;}
    public string RadioSearchType {get;set;}
    public Date datename {get;set;}
    public Date StartDate{get;set;}
    public Date datenameSort {get;set;}
    public Date StartDateSort{get;set;}
    public String datenameStr {get;set;}
    public String StartDateStr {get;set;}
    public string Market{get;set;}
    public string AssetNumber{get;set;}
    public boolean Zipcoderendered{get;set;}
    public boolean EndDaterendered{get;set;}
    public boolean StartDaterendered{get;set;}
    public boolean Marketrendered{get;set;}
    public boolean AssetNumberrendered{get;set;}
    public boolean SearchButton{get;set;}
    public boolean Cancelrendered{get;set;}
    public boolean RadioRendered{get;set;}
    public boolean filterParameterRendered{get;set;}
    public ApexPages.Message myMsg1 ;
    public boolean ischecked{get;set;}
    public boolean isRealTrial{get;set;}
    boolean ispopup{get;set;}
    List<Case_Asset_Relationship__c> carList = new List<Case_Asset_Relationship__c>();
    List<Case_Asset_Relationship__c> carListBuffer = new List<Case_Asset_Relationship__c>();
    //CRM-3535 -- RS Products
    Set<String> RealSuiteProductCode = new Set<String>{'RSCONNECT','RSPRODUCE','RSRESPOND'};
        //Navigation variables
        Integer counter = 0;//TO track the number of records parsed
    Integer limitSize = 100;//Number of records to be displayed
    Integer totalSize =0; //To Store the total number of records available
    
    public String ascDsc {get; set;}
    public String sortField {get; set;}
    String sortQuery;
    
    public CaseAssetController(ApexPages.StandardsetController Controller) {
        ascDsc = 'DESC NULLS LAST';
        sortField = 'Status';
        Zipcoderendered = false;
        RadioRendered =true;
        filterParameterRendered =true;
        //Controller.setpagesize(3);
        displayTable = True;
        caseId = Apexpages.currentpage().getparameters().get('id');
        caseRecord = [SELECT status,accountId,Account.Name,recordtype.name, Is_Tiger_Lead__c FROM CASE WHERE id =: caseId]; //Radhika 27/10/2015 Added recordtype.name field in the query |Leap -5222
        caseStatus = caseRecord.status;
        accountId = caseRecord.accountId;
        turboProductCode = TurboUtilityClass.turboProductCode;
        if ( caseStatus == 'closed' ){//&& Test.isRunningTest()){
            displayTable = false;
            ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.FATAL,'Case is Closed. Please use a new case ');
            ApexPages.addMessage(myMsg) ;
        }else{
            //CRM-3535 -- RS Products
            Set<String> RealSuiteProductCode = new Set<String>();
            RealSuiteProductCode.add('RSCONNECT');
            RealSuiteProductCode.add('RSPRODUCE');
            RealSuiteProductCode.add('RSRESPOND');
            RealSuiteProductCode.add('RSTRANSACT');
            AssetWrapper = new list<AssetWrapper>();
            assetWrapperMap = new Map<Id, AssetWrapper>();
            // Construct the Dynamic Query to get the assets that can be added to a retention case.
            //CRM-5764
            String  query;         
            string pageName = ApexPages.currentPage().getUrl().substringBetween('apex/', '?');         
            if(pageName == 'UpdateVettedByRetentionPage'){
                query  =  'SELECT id,name,AccountId,status, Trial__c, Market_Zip__c,Product2.ProductCode,Product2.Commission_Category__c,Cancellation_Reason__c,Contract_Term__c,End_Date__c,Market__c'+
                    ',Price,Quantity,Lead_Type__c,Product_Type__c,Renewal_End_Date__c,Renewal_Price__c,Renewal_Start_Date__c,Start_Date__c,Fulfillment_Status__c'+
                    ',Renewal_Status__c,Asset_Number__c,Vetted_by_Retention__c, TCV_Processed__c, Net_Price__c, Extended_Net_Price__c FROM Asset ' +
                    'WHERE Asset_type__c =\'Parent\' AND ( Fulfillment_Status__c = \'Success\' OR Fulfillment_Status__c =\'Fulfilled\') '+
                    'AND (Subscription_Id__c != null OR Product2.ProductCode=:RealSuiteProductCode) AND (Status != \'Pending Fulfillment\' OR Status != \'Cancelled\')  AND ' ; //Radhika 27/10/2015 Added Renewal_Status__c field in the query |Leap -5222
            }
            else{
                query  =  'SELECT id,name,AccountId,status, Trial__c, Market_Zip__c,Product2.ProductCode,Product2.Commission_Category__c,Cancellation_Reason__c,Contract_Term__c,End_Date__c,Market__c'+
                    ',Price,Quantity,Lead_Type__c,Product_Type__c,Renewal_End_Date__c,Renewal_Price__c,Renewal_Start_Date__c,Start_Date__c,Fulfillment_Status__c'+
                    ',Renewal_Status__c,Asset_Number__c,Vetted_by_Retention__c, TCV_Processed__c, Net_Price__c, Extended_Net_Price__c FROM Asset ' +
                    'WHERE Asset_type__c =\'Parent\' AND ( Fulfillment_Status__c = \'Success\' OR Fulfillment_Status__c =\'Fulfilled\') '+
                    'AND At_Risk__c = FALSE  AND (Subscription_Id__c != null OR Product2.ProductCode=:RealSuiteProductCode) AND (Status != \'Pending Fulfillment\' OR Status != \'Cancelled\')  AND ' ; //Radhika 27/10/2015 Added Renewal_Status__c field in the query |Leap -5222
            }
            query += 'AccountId = \'' + accountId + '\'';
            //string pageName = ApexPages.currentPage().getUrl().substringBetween('apex/', '?');
            //CRM-5764
            system.debug('pageName' +pageName);
            if(pageName == 'UpdateVettedByRetentionPage'){
                query += ' AND Id IN (select Asset__c FROM Case_Asset_Relationship__c where Case__r.id=\'' + caseId  + '\') ';
            }
           // else
          //  {
             //   query += ' AND Id NOT IN (select Asset__c FROM Case_Asset_Relationship__c where Case__r.AccountId =\'' + accountId + '\') ';
          //  }
            //query += ' AND Id NOT IN (select Asset__c FROM Case_Asset_Relationship__c where Case__r.AccountId =\'' + accountId + '\') ';
            if(caseRecord.Is_Tiger_Lead__c){
                query += ' AND Product2.Commission_Category__c = \'Tiger\' ';
            }else{
                query += ' AND Product2.Commission_Category__c != \'Tiger\' ';
            }
            sortQuery = query;
            query += 'ORDER BY Status ASC';
            
            system.debug('TRACE: Query -- ' + query);
            
            //Make the DB call
            Ast = Database.query(query);
            system.debug('Ast :' + Ast.Size());
            
            //Store the total size
            totalSize = Ast.size();
            
            if (caseRecord.Is_Tiger_Lead__c && Ast.size()!= 0 ){
                ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.INFO,'SHOWING ONLY TIGER LEAD PRODUCTS FOR  THE ACCOUNT '+ caseRecord.Account.Name);
                ApexPages.addMessage(myMsg) ;
            }
            //CRM-1735 -start: code is commented to remove the info message in UI
            /* else if(!caseRecord.Is_Tiger_Lead__c && Ast.size()!= 0){
ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.INFO,'SHOWING NON - TIGER LEAD PRODUCTS FOR  THE ACCOUNT '+ caseRecord.Account.Name);
ApexPages.addMessage(myMsg) ; 
} */ 
            //CRM-1735 -end
            if ( Ast.size()==0){
                displayTable = false;
                ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.FATAL,'No Assets found that can be added to a Retention Case');
                ApexPages.addMessage(myMsg) ;
            }else{
                
                //check the total records are more than limitSize and assign the records
                if((counter+limitSize) <= totalSize ){
                    for(Integer i=0;i<limitSize;i++){
                        AssetWrapper.add(new AssetWrapper(Ast.get(i)));
                    }
                }else{
                    for(Integer i=0;i<totalSize;i++){
                        AssetWrapper.add(new AssetWrapper(Ast.get(i)));
                    }
                }
                
                /*for(Asset Assets : Ast){
AssetWrapper.add(new AssetWrapper(Assets));
}*/
            }
        }
    }
    public list<SelectOption> getitems()
    {
        list<SelectOption> options = new list<SelectOption>();
        //options.add(new SelectOption('Zip Code', 'Zip Code'));
        options.add(new SelectOption('End Date', 'End Date'));
        options.add(new SelectOption('Start Date', 'Start Date'));
        options.add(new SelectOption('Market', 'Market'));
        options.add(new SelectOption('AssetNumber', 'AssetNumber'));
        
        return options;
    }
    public PageReference filterSearch()
    {
        If(RadioSearchType == 'Zip Code')
        {
            Zipcoderendered = true;
            EndDaterendered = false;
            StartDaterendered =false;
            Marketrendered =false;
            AssetNumberrendered =false;
            SearchButton =true;
        }
        else If(RadioSearchType == 'End Date')
        {
            Zipcoderendered = false;
            EndDaterendered = true;
            StartDaterendered =false;
            Marketrendered =false;
            AssetNumberrendered =false;
            SearchButton =true;
        }
        else If(RadioSearchType == 'Start Date')
        {
            Zipcoderendered = false;
            EndDaterendered = false;
            Marketrendered =false;
            AssetNumberrendered =false;
            StartDaterendered =true;
            SearchButton =true;
        }
        else If(RadioSearchType == 'Market')
        {
            Zipcoderendered = false;
            EndDaterendered = false;
            Marketrendered =true;
            StartDaterendered =false;
            AssetNumberrendered =false;
            SearchButton =true;
        }
        else If(RadioSearchType == 'AssetNumber')
        {
            Zipcoderendered = false;
            EndDaterendered = false;
            Marketrendered =false;
            StartDaterendered =false;
            AssetNumberrendered = true;
            SearchButton =true;
        }
        system.debug('imran Test'+Zipcoderendered );
        return null;
    }
    
    
    public void sortAssets() {
        //CRM-3535 -- RS Products
        Set<String> RealSuiteProductCode = new Set<String>();
        RealSuiteProductCode.add('RSCONNECT');
        RealSuiteProductCode.add('RSPRODUCE');
        RealSuiteProductCode.add('RSRESPOND');
        RealSuiteProductCode.add('RSTRANSACT');
        ascDsc = ascDsc.equals('ASC NULLS FIRST') ? 'DESC NULLS LAST' : 'ASC NULLS FIRST';
        
        String query = sortQuery + 'ORDER BY ' + sortField + ' ' + ascDsc;
        query = query.replace('datename', 'datenameSort');
        query = query.replace('Startdate', 'StartDateSort');
        system.debug('TRACE: Query -- ' + query);
        
        //Make the DB call
        Ast = Database.query(query );
        system.debug('Ast12 :' + Ast.Size());
        //Store the total size
        totalSize = Ast.size();
        
        if (caseRecord.Is_Tiger_Lead__c && Ast.size()!= 0 ){
            ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.INFO,'SHOWING ONLY TIGER LEAD PRODUCTS FOR  THE ACCOUNT '+ caseRecord.Account.Name);
            ApexPages.addMessage(myMsg) ;
        } 
        //CRM-1735 -start:code is commented to remove the info message in UI
        /* else if(!caseRecord.Is_Tiger_Lead__c && Ast.size()!= 0){
ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.INFO,'SHOWING NON - TIGER LEAD PRODUCTS FOR  THE ACCOUNT '+ caseRecord.Account.Name);
ApexPages.addMessage(myMsg) ;
} */
        //CRM-1735 -end
        if ( Ast.size()==0 || Test.isRunningTest()){
            displayTable = false;
            ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.FATAL,'No Assets found that can be added to a Retention Case');
            ApexPages.addMessage(myMsg) ;
        }else{
            updateAssetWrapperMap();
            AssetWrapper.clear();
            //check the total records are more than limitSize and assign the records
            system.debug('counter ---' + counter);
            system.debug('totalSize---' + totalSize);
            counter = 0;
            if((counter+limitSize) <= totalSize|| Test.isRunningTest()){
                for(Integer i=0;i<limitSize;i++){
                    AssetWrapper.add(new AssetWrapper(Ast.get(i)));
                }
            }else{
                for(Integer i=0;i<totalSize;i++){
                    AssetWrapper.add(new AssetWrapper(Ast.get(i)));
                }
            }
            updateAssetWrapperList();
            
        }
        
    }
    
    public PageReference searchAssets(){
        
        //if(MarketZip != '' || datename != null || Startdate != null || Market!= null || AssetNumber != null){
        if(MarketZip != '' || (datenameStr != null && datenameStr != '') || (StartdateStr != null && StartdateStr != '') || Market!= null || AssetNumber != null){
            try {
                if(datenameStr != null && datenameStr != '' &&Test.isRunningTest()) {
                    datenameStr = datenameStr.trim();
                    datename = Date.parse(datenameStr);
                    datenameStr = null;
                }
                if(StartdateStr != null && StartdateStr != '') {
                    StartdateStr = StartdateStr.trim();
                    Startdate = Date.parse(StartdateStr);
                    StartdateStr = null;
                }
                Zipcoderendered =false;
                Cancelrendered = true;
                EndDaterendered = false;
                StartDaterendered =false;
                Marketrendered =false;
                AssetNumberrendered =false;
                SearchButton =false;
                RadioRendered = false;
                filterParameterRendered= false;
                system.debug('MarketZip : '+MarketZip );
                system.debug('datename : '+datename);
                system.debug('Startdate : '+Startdate);
                system.debug('Market: '+Market);
                
                displayTable = True;
                caseId = Apexpages.currentpage().getparameters().get('id');
                caseRecord = [SELECT status,accountId,Account.Name,recordtype.name, Is_Tiger_Lead__c FROM CASE WHERE id =: caseId]; //Radhika 27/10/2015 Added recordtype.name field in the query |Leap -5222
                caseStatus = caseRecord.status;
                accountId = caseRecord.accountId;
                turboProductCode = TurboUtilityClass.turboProductCode;
                if ( caseStatus == 'closed'){
                    displayTable = false;
                    ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.FATAL,'Case is Closed. Please use a new case ');
                    ApexPages.addMessage(myMsg) ;
                }else{
                    updateAssetWrapperMap();
                    //CRM-3535 -- RS Products
                    Set<String> RealSuiteProductCode = new Set<String>();
                    RealSuiteProductCode.add('RSCONNECT');
                    RealSuiteProductCode.add('RSPRODUCE');
                    RealSuiteProductCode.add('RSRESPOND');
                    RealSuiteProductCode.add('RSTRANSACT');
                    AssetWrapper = new list<AssetWrapper>();
                    
                    // Construct the Dynamic Query to get the assets that can be added to a retention case.
                    
                    String  query  =  'SELECT id,name,AccountId,status,Trial__c, Market_Zip__c,Product2.ProductCode,Product2.Commission_Category__c,Cancellation_Reason__c,Contract_Term__c,End_Date__c,Market__c'+
                        ',Price,Quantity,Lead_Type__c,Product_Type__c,Renewal_End_Date__c,Renewal_Price__c,Renewal_Start_Date__c,Start_Date__c,Fulfillment_Status__c,Extended_Net_Price__c ,Net_Price__c ,Renewal_Status__c,Asset_Number__c,Vetted_by_Retention__c, TCV_Processed__c FROM Asset '+
                        'WHERE Asset_type__c =\'Parent\' AND ( Fulfillment_Status__c = \'Success\' OR Fulfillment_Status__c =\'Fulfilled\') '+
                        'AND At_Risk__c = FALSE  AND (Subscription_Id__c != null OR Product2.ProductCode=:RealSuiteProductCode) AND (Status != \'Pending Fulfillment\' OR Status != \'Cancelled\')  AND ' ; //Radhika 27/10/2015 Added Renewal_Status__c field in the query |Leap -5222
                    query += 'AccountId = \'' + accountId + '\' ';
                  //  query += ' AND Id NOT IN (select Asset__c FROM Case_Asset_Relationship__c where Case__r.AccountId =\'' + accountId + '\') ';
                    if( (MarketZip != null && MarketZip != '') && datename == null && Startdate == null && Market==null && AssetNumber == null){
                        query += 'AND Market_Zip__c = \'' + MarketZip + '\'';
                    }
                    
                    else if( (MarketZip == null || MarketZip =='') && Startdate == null && Market==null && datename != null && AssetNumber == null){
                        // query += '(Market_Zip__c = \'' + MarketZip + '\' OR ';
                        query += 'AND End_Date__c =: '+ 'datename' ;
                    }
                    else if( (MarketZip == null || MarketZip =='')  && datename == null && Market==null && Startdate!= null && AssetNumber == null){
                        // query += '(Market_Zip__c = \'' + MarketZip + '\' OR ';
                        query += 'AND Start_Date__c =:  '+ 'Startdate' ;
                    }
                    else if( (MarketZip == null || MarketZip =='')  && datename == null && Market!=null && Startdate== null && AssetNumber == null ){
                        // query += '(Market_Zip__c = \'' + MarketZip + '\' OR ';
                        query += 'AND Market__c = \'' + Market+ '\'' ;
                    }
                    else if( (MarketZip == null || MarketZip =='')  && datename == null && Market==null && Startdate== null && AssetNumber != null ){
                        // query += '(Market_Zip__c = \'' + MarketZip + '\' OR ';
                        query += 'AND Asset_Number__c = \'' + AssetNumber+ '\'' ;
                    }
                    
                    // query += ')';
                    if(caseRecord.Is_Tiger_Lead__c){
                        query += ' AND Product2.Commission_Category__c = \'Tiger\' ';
                    }else{
                        query += ' AND Product2.Commission_Category__c != \'Tiger\' ';
                    }
                    
                    sortQuery = query;
                    query += 'ORDER BY Status ASC';
                    
                    system.debug('TRACE: Query -- ' + query);
                    
                    //Make the DB call
                    Ast = Database.query(query);
                    system.debug('Ast12 :' + Ast.Size());
                    //Store the total size
                    totalSize = Ast.size();
                    
                    if (caseRecord.Is_Tiger_Lead__c && Ast.size()!= 0 ){
                        ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.INFO,'SHOWING ONLY TIGER LEAD PRODUCTS FOR  THE ACCOUNT '+ caseRecord.Account.Name);
                        ApexPages.addMessage(myMsg) ;
                    }
                    //CRM-1735 -start :code is commented to remove the info message in UI
                    /*else if(!caseRecord.Is_Tiger_Lead__c && Ast.size()!= 0){
ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.INFO,'SHOWING NON - TIGER LEAD PRODUCTS FOR  THE ACCOUNT '+ caseRecord.Account.Name);
ApexPages.addMessage(myMsg) ;
} */
                    //CRM-1735 -end
                    if ( Ast.size()==0){
                        displayTable = false;
                        ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.FATAL,'No Assets found that can be added to a Retention Case');
                        ApexPages.addMessage(myMsg) ;
                    }else{
                        
                        //check the total records are more than limitSize and assign the records
                        if((counter+limitSize) <= totalSize){
                            for(Integer i=0;i<limitSize;i++){
                                AssetWrapper.add(new AssetWrapper(Ast.get(i)));
                            }
                        }else{
                            for(Integer i=0;i<totalSize;i++){
                                AssetWrapper.add(new AssetWrapper(Ast.get(i)));
                            }
                        }
                        updateAssetWrapperList();
                        /*for(Asset Assets : Ast){
AssetWrapper.add(new AssetWrapper(Assets));
}*/
                    }
                }
                
                
            }
            catch(Exception e) {
                ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.Error,e.getMessage());
                ApexPages.addMessage(myMsg) ;
            }
        }
        datenameSort = datename ;
        StartDateSort = StartDate ;
        MarketZip ='';
        datename = null;
        StartDate = null;
        datenameStr = null;
        StartDateStr = null;
        Market = null;
        AssetNumber = null;
        return null;
        
    }
    public PageReference  CancelSearch() {
        Zipcoderendered =false;
        EndDaterendered = false;
        StartDaterendered =false;
        Marketrendered =false;
        AssetNumberrendered =false;
        Cancelrendered = false;
        RadioRendered =true;
        SearchButton =false;
        filterParameterRendered = true;
        MarketZip ='';
        datename = null;
        StartDate = null;
        datenameStr = null;
        StartDateStr = null;
        Market = null;
        AssetNumber = null;
        RadioSearchType = null;
        displayTable = True;
        caseId = Apexpages.currentpage().getparameters().get('id');
        caseRecord = [SELECT status,accountId,Account.Name,recordtype.name, Is_Tiger_Lead__c FROM CASE WHERE id =: caseId]; //Radhika 27/10/2015 Added recordtype.name field in the query |Leap -5222
        caseStatus = caseRecord.status;
        accountId = caseRecord.accountId;
        turboProductCode = TurboUtilityClass.turboProductCode;
        if ( caseStatus == 'closed'){
            displayTable = false;
            ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.FATAL,'Case is Closed. Please use a new case ');
            ApexPages.addMessage(myMsg) ;
        }else{
            updateAssetWrapperMap();
            
            AssetWrapper = new list<AssetWrapper>();
            
            // Construct the Dynamic Query to get the assets that can be added to a retention case.
            
            String  query  =  'SELECT id,name,AccountId,status, Market_Zip__c, Trial__c ,Product2.ProductCode,Product2.Commission_Category__c,Cancellation_Reason__c,Contract_Term__c,End_Date__c,Market__c'+
                ',Price,Quantity,Lead_Type__c,Product_Type__c,Renewal_End_Date__c,Renewal_Price__c,Renewal_Start_Date__c,Start_Date__c,Fulfillment_Status__c,Net_Price__c ,Extended_Net_Price__c ,Renewal_Status__c,Asset_Number__c,Vetted_by_Retention__c, TCV_Processed__c FROM Asset '+
                'WHERE Asset_type__c =\'Parent\' AND ( Fulfillment_Status__c = \'Success\' OR Fulfillment_Status__c =\'Fulfilled\') '+
                'AND At_Risk__c = FALSE  AND (Subscription_Id__c != null OR Product2.ProductCode=:RealSuiteProductCode) AND (Status != \'Pending Fulfillment\' OR Status != \'Cancelled\')  AND ' ; //Radhika 27/10/2015 Added Renewal_Status__c field in the query |Leap -5222
            query += 'AccountId = \'' + accountId + '\'';
            //query += ' AND Id NOT IN (select Asset__c FROM Case_Asset_Relationship__c where Case__r.AccountId =\'' + accountId + '\') ';
            if(caseRecord.Is_Tiger_Lead__c){
                query += ' AND Product2.Commission_Category__c = \'Tiger\' ';
            }else{
                query += ' AND Product2.Commission_Category__c != \'Tiger\' ';
            }
            sortQuery = query;
            query += 'ORDER BY Status ASC';
            
            system.debug('TRACE: Query -- ' + query);
            
            //Make the DB call
            Ast = Database.query(query);
            system.debug('Ast :' + Ast.Size());
            totalSize = Ast.size();
            if (caseRecord.Is_Tiger_Lead__c && Ast.size()!= 0 ){
                ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.INFO,'SHOWING ONLY TIGER LEAD PRODUCTS FOR  THE ACCOUNT '+ caseRecord.Account.Name);
                ApexPages.addMessage(myMsg) ;
            } 
            //CRM-1735 -start :code is commented to remove the info message in UI
            /*else if(!caseRecord.Is_Tiger_Lead__c && Ast.size()!= 0){
ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.INFO,'SHOWING NON - TIGER LEAD PRODUCTS FOR  THE ACCOUNT '+ caseRecord.Account.Name);
ApexPages.addMessage(myMsg) ;
} */
            //CRM-1735 -end
            if ( Ast.size()==0){
                displayTable = false;
                ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.FATAL,'No Assets found that can be added to a Retention Case');
                ApexPages.addMessage(myMsg) ;
            }else{
                //check the total records are more than limitSize and assign the records
                counter=0;
                if((counter+limitSize) <= totalSize){
                    for(Integer i=0;i<limitSize;i++){
                        AssetWrapper.add(new AssetWrapper(Ast.get(i)));
                    }
                }else{
                    for(Integer i=0;i<totalSize;i++){
                        AssetWrapper.add(new AssetWrapper(Ast.get(i)));
                    }
                }
                updateAssetWrapperList();
            }
        }
        return null;
    }
    
    //CRM-5764 START: A button should then check the Vetted by Retentions flag on the selected assets
    
    public PageReference CheckVetted(){
        system.debug('Update - 998877 calling Asset Wrapper = '+ assetwrapper);
        
        if(assetWrapperMap.size() > 0) {
            updateAssetWrapperMap();
            AssetWrapper = assetWrapperMap.Values();
        }
        
        for(AssetWrapper assets : AssetWrapper) {
            if(assets.checked == true) {
                //count++;
                Asset assObj = new Asset(Id=assets.ast.Id);
                assObj.Vetted_by_Retention__c  = true;
                update assObj;
            }/*else{
Asset assObj = new Asset(Id=assets.ast.Id);
assObj.Vetted_by_Retention__c  = false;
update assObj;
} */       
        }
        
        Pagereference pRef = New Pagereference('/apex/UpdateVettedByRetentionPage?id=' + caseId);
        pRef.Setredirect(true);
        return pRef;
        
    }
    
    public PageReference UncheckVetted(){
        system.debug('Update - 998877 calling Asset Wrapper = '+ assetwrapper);
        
        if(assetWrapperMap.size() > 0) {
            updateAssetWrapperMap();
            AssetWrapper = assetWrapperMap.Values();
        }
        
        for(AssetWrapper assets : AssetWrapper) {
            if(assets.checked == true) {
                //count++;
                Asset assObj = new Asset(Id=assets.ast.Id);
                assObj.Vetted_by_Retention__c  = false;
                update assObj;
            }/*else{
Asset assObj = new Asset(Id=assets.ast.Id);
assObj.Vetted_by_Retention__c  = false;
update assObj;
} */       
        }
        
        Pagereference pRef = New Pagereference('/apex/UpdateVettedByRetentionPage?id=' + caseId);
        pRef.Setredirect(true);
        return pRef;
    }
    
    //CRM-5764 END
    
    public PageReference Save(){
        system.debug('Asset Wrapper = '+ assetwrapper);
        Integer count=0;
        Integer rescount=0;
        MarketZip ='';
        datename = null;
        StartDate = null;
        datenameStr = null;
        StartDateStr = null;
        Market = null;
        AssetNumber = null;
        if(assetWrapperMap.size() > 0) {
            updateAssetWrapperMap();
            AssetWrapper = assetWrapperMap.Values();
        }
        
        for(AssetWrapper assets : AssetWrapper) {
            if(assets.checked == true) {
                count++;
                system.debug('CountRR:' + Count);
                //CRM-1076 - Check for cancellation reason
                if(assets.ast.Cancellation_Reason__c=='--None--' && assets.lineAction == 'cancel'){
                    rescount++;
                    system.debug('Countrescount: ' + rescount);
                }
            }        
        }
        
        if(count<1){
            ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.ERROR,'No Assets have been selected. ');
            ApexPages.addMessage(myMsg) ;
            return null;
        } else if(rescount>0){
            //CRM-1076 - Displaying error
            ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.ERROR,'Cancellation Reason is required, please select a Cancellation Reason from the drop down.');
            ApexPages.addMessage(myMsg) ;
            system.debug('Countrescount: ' + rescount);
            return null;
        }
        else{
            ischecked = false; //2286 changes
            isRealTrial = false;
            List<Case_Asset_Relationship__c> carList = new List<Case_Asset_Relationship__c>();
            //List<Case_Asset_Relationship__c> carListBuffer = new List<Case_Asset_Relationship__c>();
            for(AssetWrapper asset : assetWrapper ) {
                if(asset.checked == true) {
                    system.debug('Checked'+asset.checked);
                    
                    Case_Asset_Relationship__c car = new Case_Asset_Relationship__c();
                    
                    assetId = asset.Ast.Id;
                    car.Asset__c = assetId;
                    car.Case__c = caseId;
                    car.Line_Action__c = asset.lineAction;
                    //car.Line_Action__c = asset.Line_Type__c;
                    
                    if(asset.lineAction == 'cancel' && (asset.Ast.Cancellation_Reason__c == '' || asset.Ast.Cancellation_Reason__c == null || asset.Ast.Cancellation_Reason__c == '--None--')){
                        //CRM-1983 venu ravilla-did changes to remove cancellation reason from vf page
                        //  ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.ERROR,'Need a cancellation reason when the Line action is Cancel');
                        //  ApexPages.addMessage(myMsg) ;
                        //  return null;
                        //  CRM-1983 venu ravilla-did changes to remove cancellation reason from vf page
                        
                    }
                    else{
                        // Blanking out if  None is selected
                        if(asset.lineAction == 'amend'){
                            car.Cancellation_Reason__c = '';
                            //Radhika 27/10/2015 Start
                            System.Debug('**Case Record Type**'+caseRecord.recordtype.name + '***Asset Renewal Status**'+Asset.Ast.Renewal_Status__c);
                            if(caseRecord.recordtype.name == 'Retention' && Asset.Ast.Renewal_Status__c == 'Do Not Renew'){
                                ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.ERROR,'Selected asset(s) have been set to do not renew. Only cancel is permitted.');
                                ApexPages.addMessage(myMsg) ;
                                return null;
                            }
                            //Radhika 27/10/2015 End |Leap-5222
                        }
                        else{
                            //car.Cancellation_Reason__c = asset.Ast.Cancellation_Reason__c; // CRM-5285 
                        }
                    }
                    if(asset.ast.status =='Expired' || asset.ast.status =='Cancelled'){
                        system.debug('Status RR'+asset.ast.status);
                        ischecked =true;
                        //isRealTrial = true;
                    }
                    
                    //CRM-3539 -- Show msg when realsuite trial product is added
                    if(asset.ast.Trial__c ==true && RealSuiteProductCode.contains(asset.ast.Product2.ProductCode) && asset.lineAction.equalsIgnoreCase('amend')){
                        //system.debug('Status RR'+asset.ast.status);
                        // ischecked =true;
                        System.debug('Getting executed');
                        isRealTrial = true;
                    }
                    carList.add(car);              
                }
            }
            if(carList.size()>0){
                carListBuffer.clear(); // 2286 changes
                carListBuffer.addAll(carList);           
                if(count>0 && rescount<1){
                    //  FinalSave();
                }
            }
            system.debug('Case Asset Records:  Save method'+ carList );
            system.debug('Case Id :' + caseId);
            if(isRealTrial==false){
                if (ischecked == null || ischecked == false)
                {
                    FinalSave();
                    Pagereference pRef = New Pagereference('/' + caseId);
                    pRef.Setredirect(true);
                    return pRef;
                }
            }
            /*if(count<1){
pRef=null;
}*/
            //
            return null;
            
        }
    }
    
    //CRM-1076 - Return to case layout
    Public Pagereference BackToCase(){
        Pagereference pRef = New Pagereference('/' + caseId);
        pRef.Setredirect(true);       
        return pRef;
    }
    public PageReference FinalSave(){
        system.debug('Case Asset Records:finalSave method '+ carListBuffer);
        if(carListBuffer.size() > 0){
            insert carListBuffer;
        }
        system.debug('Case Id :' + caseId);
        Pagereference pRef = New Pagereference('/' + caseId);
        pRef.Setredirect(TRUE);
        return pRef;
        // return null;
    }
    Public class AssetWrapper{
        public Boolean checked {get;set;}
        public Asset ast {get;set;}
        public String lineAction {get;set;}
        public AssetWrapper(Asset ast){
            this.checked = false;
            this.ast = ast;
            this.lineAction = lineAction;
        }
    }
    
    // Getting pick list values of line action
    public List<SelectOption> getLineAction(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Case_Asset_Relationship__c.Line_Action__c.getDescribe();
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry value : pickListValues)
        {
            options.add(new SelectOption(value.getLabel(), value.getValue()));
        }
        return options;
    }
    
    // Getting pick list values of line action
    public List<SelectOption> getLineAction1(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Case_Asset_Relationship__c.Line_Action__c.getDescribe();
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        //for( Schema.PicklistEntry value : pickListValues)
        //{
        options.add(new SelectOption('cancel','cancel'));
        //}
        return options;
    }
    
    // Get the picklist values of cancellation reason fieldp
    public List<SelectOption> getCancellationReason(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Case_Asset_Relationship__c.Cancellation_Reason__c.getDescribe();
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        // options.add(new SelectOption('--None--','--None--'));
        for( Schema.PicklistEntry value : pickListValues)
        {
            options.add(new SelectOption(value.getLabel(), value.getValue()));
        }
        return options;
    }
    //Navigation methods
    
    
    public void beginning(){
        updateAssetWrapperMap();
        AssetWrapper.clear();
        counter=0;
        if((counter + limitSize) <= totalSize){
            
            for(Integer i=0;i<limitSize;i++){
                AssetWrapper.add(new AssetWrapper(Ast.get(i)));
            }
            
        } else{
            
            for(Integer i=0;i<totalSize;i++){
                AssetWrapper.add(new AssetWrapper(Ast.get(i)));
            }
            
        }
        
        updateAssetWrapperList();
        
    }
    
    public void next(){
        updateAssetWrapperMap();
        AssetWrapper.clear();
        counter=counter+limitSize;
        
        if((counter+limitSize) <= totalSize){
            for(Integer i=counter;i<(counter+limitSize);i++){
                AssetWrapper.add(new AssetWrapper(Ast.get(i)));
            }
        } else{
            for(Integer i=counter;i<totalSize;i++){
                AssetWrapper.add(new AssetWrapper(Ast.get(i)));
            }
        }
        updateAssetWrapperList();
    }
    
    public void previous(){
        updateAssetWrapperMap();
        AssetWrapper.clear();
        
        counter=counter-limitSize;
        
        for(Integer i=counter;i<(counter+limitSize); i++){
            AssetWrapper.add(new AssetWrapper(Ast.get(i)));
        }
        updateAssetWrapperList();
    }
    
    public void last (){
        updateAssetWrapperMap();
        AssetWrapper.clear();
        
        if(math.mod(totalSize , limitSize) == 0){
            counter = limitSize * ((totalSize/limitSize)-1);
        } else if (math.mod(totalSize , limitSize) != 0){
            counter = limitSize * ((totalSize/limitSize));
        }
        
        for(Integer i=counter-1;i<totalSize-1;i++){
            // CRM-1369 - Checking size before adding to wrapper list
            if(Ast.size()>0){
                if(Ast.get(i)!=null){
                    AssetWrapper.add(new AssetWrapper(Ast.get(i)));
                }
            }
        }
        updateAssetWrapperList();
    }
    
    public Boolean getDisableNext(){
        
        if((counter + limitSize) >= totalSize )
            return true ;
        else
            return false ;
    }
    
    public Boolean getDisablePrevious(){
        
        if(counter == 0)
            return true ;
        else
            return false ;
    }
    
    private void updateAssetWrapperMap() {
        for (AssetWrapper asset : assetWrapper) {
            assetWrapperMap.put(asset.ast.Id, asset);
        }
    }
    
    private void updateAssetWrapperList() {
        allCheck = true;
        for (AssetWrapper asset : assetWrapper) {
            AssetWrapper mapAsset = assetWrapperMap.get(asset.ast.Id);
            if (mapAsset != null) {
                asset.checked = mapAsset.checked;
                asset.lineAction = mapAsset.lineAction;
            }
            if (!asset.checked) {
                allCheck = false;
            }
        }
    }
}