public class AccountBillingInsight{
    
    public string accountId;
    
    private transient list<BillingInsightAttributesClass>       biAttrHolderList;
    public  string                          billingInsightDataJson                  {get;set;}
    public  transient map<integer,string>               numberToMonthText;
    public  string baseUrl                                                                      {get;set;}
    public  Zuora__CustomerAccount__c                   billingAccount                          {get;set;}
    
    public  date                                        selectedStartDate                       {get;set;}
    public  date                                        selectedEndDate                         {get;set;}
    
    public  final string                                pastInvoiceType                         = 'Past Invoice';
    public  final string                                futureInvoiceType                       = 'Future Invoice';
    
    public  Boolean isError                                      {get;set;}
    public  Boolean isActiveBillingAccount                       {get;set;}
    public  Boolean noPastInvoices                               {get;set;}
    public  Boolean noFutureInvoices                             {get;set;}
    public  Boolean errorFutureInvoices                          {get;set;}
    public  string  errorFutureInvoicesMsg                       {get;set;}
    
    public  transient BillingInsightParentGroup topNodeList              {get;set;}
    
    @testvisible private transient list<ZuoraBillingPreviewapi.BillingPreviewResult> invoiceResultsZuora;
    
    public AccountBillingInsight( ApexPages.StandardController sc ){
        try{
            accountId   = sc.getId();
            baseUrl     = URL.getSalesforceBaseUrl().toExternalForm()+'/';
            isError = false;
            billingAccount = new Zuora__CustomerAccount__c();
            billingAccount = getBillingAccount();
            
            populateDefaultBillingInsightTable();
        }catch(Exception e){
            isError = true;
            saveException( e, 'Const: While generating report' );
            system.debug('Exception------- '+e.getStackTraceString());
        }
       
    }
    
    public void populateDefaultBillingInsightTable(){
        
        selectedStartDate       = Date.today() - 90;
        selectedEndDate         = Date.today() + 90;
        
        populateBillingInsightData();
    }
    
    public void populateBillingInsightTable(){
        try{
            string startDate            = ApexPages.currentPage().getParameters().get('startDate');
            string endDate              = ApexPages.currentPage().getParameters().get('endDate');
          
            selectedStartDate       = Date.valueOf(startDate);
            selectedEndDate         = Date.valueOf(endDate);
            
            populateBillingInsightData();
        }catch(Exception e){
            isError = true;
            saveException( e, 'While generating report' );
            system.debug('Exception------- '+e.getStackTraceString());
        }
    }
    
    private Zuora__CustomerAccount__c getBillingAccount(){
       isActiveBillingAccount = true;
       list<Zuora__CustomerAccount__c> zcaList = new list<Zuora__CustomerAccount__c>(); 
       zcaList = [  select  Zuora__BillToName__c,
                            Zuora__BillCycleDay__c,
                            Zuora__Batch__c,
                            Zuora__Zuora_Id__c
                    from    
                        Zuora__CustomerAccount__c 
                    where 
                        Zuora__Status__c = 'Active' 
                        AND 
                        Zuora__Account__c = :accountId
                    limit 1];
       if( zcaList != null && zcaList.size() > 0 ){
           return zcaList[0];
       }else{
           isActiveBillingAccount = false;
           return null;
       }
       
    }
    public void populateBillingInsightData(){
        try{
            populateNumberToMonthTextData();
            billingInsightDataJson                                      = '';
            biAttrHolderList        = new list<BillingInsightAttributesClass>();
            BillingInsightAttributesClass biAttrHolder                  = new BillingInsightAttributesClass();
            
            biAttrHolderList.addAll(populatePastInvoices());
            biAttrHolderList.addAll(populateFutureInvoices());
           
            billingInsightDataJson = JSON.serialize(biAttrHolderList);
        }catch( Exception e){
            isError = true;
            saveException( e, 'While generating report' );
            system.debug('Exception------- '+e.getStackTraceString());
        }
        
    }
    private list<BillingInsightAttributesClass> populatePastInvoices(){
        noPastInvoices = false;
        list<BillingInsightAttributesClass> pastInvDetailList = new list<BillingInsightAttributesClass>();
        BillingInsightAttributesClass pastInvDetail = new BillingInsightAttributesClass();
       
        list<Invoice_Item__c> invoiceItemList = [   select      Name,
                                                                Charge_Date__c,
                                                                Charge_Amount__c,
                                                                Service_End_Date__c,
                                                                Service_Start_Date__c,
                                                                Tax_Amount__c,
                                                                Unit_Price__c,
                                                                Asset__r.Id,
                                                                Asset__r.Name,
                                                                Asset__r.Asset_Number__c,
                                                                Asset__r.Billing_Period__c,
                                                                Invoice__r.Id,
                                                                Invoice__r.Name
                                                    From    Invoice_Item__c
                                                    WHERE 
                                                        Invoice__c != null
                                                        AND
                                                        Invoice__r.Zuora__Account__c != null
                                                        AND
                                                        Invoice__r.Zuora__Account__r.Id = :accountId
                                                        AND
                                                        Charge_Date__c >= :selectedStartDate
                                                        AND
                                                        Charge_Date__c <= :selectedEndDate
                                                    order by Charge_Date__c
                                                    limit: Limits.GetLimitQueryRows() - Limits.GetQueryRows()];
        
        if( invoiceItemList != null && invoiceItemList.size() > 0 ){
            for( Invoice_Item__c invItem : invoiceItemList){
                pastInvDetail.invoiceType                   = pastInvoiceType;
                
                pastInvDetail.invoiceItemDetail             = new RecordDetailClass();
                pastInvDetail.invoiceItemDetail.name        = invItem.Name;
                pastInvDetail.invoiceItemDetail.id          = invItem.Id;
                
                pastInvDetail.invoiceDetail                 = new RecordDetailClass();
                pastInvDetail.invoiceDetail.name            = invItem.Invoice__r.Name;
                pastInvDetail.invoiceDetail.id              = invItem.Invoice__r.Id;
                
                pastInvDetail.invoiceSeparately             = 'NA';    
                
                pastInvDetail.assetDetail                = new RecordDetailClass();
                pastInvDetail.assetDetail.Name           = invItem.Asset__r.Name;
                pastInvDetail.assetDetail.id             = invItem.Asset__r.Id;
                pastInvDetail.AssetNumber                = invItem.Asset__r.Asset_Number__c;
                pastInvDetail.chargeDate                 = string.valueOf(invItem.Charge_Date__c) ;
                pastInvDetail.servicePeriodStartDate     = string.valueOf(invItem.Service_Start_Date__c);
                pastInvDetail.servicePeriodEndDate       = string.valueOf(invItem.Service_End_Date__c);
                
                pastInvDetail.unitPrice                  = invItem.Unit_Price__c != null ? string.valueOf(invItem.Unit_Price__c.setScale(2)):'0.00';
                pastInvDetail.ChargeAmount               = invItem.Charge_Amount__c != null ? string.valueOf(invItem.Charge_Amount__c.setScale(2)):'0.00';
                pastInvDetail.tax                        = invItem.Tax_Amount__c != null ? string.valueOf(invItem.Tax_Amount__c.setScale(2)):'0.00';
                
                pastInvDetail.billingPeriod              = invItem.Asset__r.Billing_Period__c != null ? invItem.Asset__r.Billing_Period__c: '';
                pastInvDetail.monthAndYear               = string.valueOf(invItem.Charge_Date__c.toStartOfMonth());
                pastInvDetail.monthAndYearString          = string.valueOf( numberToMonthText.get( invItem.Charge_Date__c.Month()) + ' ' + invItem.Charge_Date__c.Year() );
                pastInvDetailList.add( pastInvDetail );
                pastInvDetail = new BillingInsightAttributesClass();
            }
        }else{
            noPastInvoices = true;
        }
        
        return pastInvDetailList;
        
    }
    @TestVisible private list<BillingInsightAttributesClass> populateFutureInvoices(){
        noFutureInvoices = false;
        errorFutureInvoices = false;
        list<BillingInsightAttributesClass> futureInvDetailList = new list<BillingInsightAttributesClass>();
        map<string,list<BillingInsightAttributesClass>> subscriptionIdTofutureInvDetailList = new map<string,list<BillingInsightAttributesClass>>();
        
        
        if( billingAccount == null || string.isBlank(billingAccount.Zuora__Zuora_Id__c)){
            //Error Billing account is null or Zuora Id is missing
        }else{
        
            BillingInsightAttributesClass futureInvDetail = new BillingInsightAttributesClass();
            
            Z_BillingPreview billPreview = new Z_BillingPreview();
           
            if( !Test.isRunningTest() ){
                 invoiceResultsZuora = new list<ZuoraBillingPreviewapi.BillingPreviewResult>();
                 // CRM-1629 Passing Date value only to billing previewApi
                 invoiceResultsZuora = billPreview.billingPreview(billingAccount.Zuora__Zuora_Id__c,
                                                                                                 selectedEndDate);
                 
            }
            
            if(billPreview.errorStatus){
                errorFutureInvoices = true;
                errorFutureInvoicesMsg = billPreview.errorMessage;
            }else{
                if(invoiceResultsZuora != null && !invoiceResultsZuora.isEmpty()){
                        ZuoraBillingPreviewapi.Error[] errors = invoiceResultsZuora[0].Errors;
                        ZuoraBillingPreviewObject.InvoiceItem[] invoiceItems = invoiceResultsZuora[0].InvoiceItem;
                        
                        if( invoiceItems != null && !invoiceItems.isEmpty()){
                            
                            for(ZuoraBillingPreviewObject.InvoiceItem invItem : invoiceItems){
                                
                                if( (invItem.ServiceStartDate != null && invItem.ServiceStartDate>= selectedStartDate) ){
                                    //    && 
                                    //(invItem.ServiceEndDate != null && invItem.ServiceEndDate.date() <= selectedEndDate) ){
                                    
                                    futureInvDetail.invoiceType                 = futureInvoiceType;
                                    
                                    futureInvDetail.invoiceItemDetail           = new RecordDetailClass();
                                    futureInvDetail.invoiceItemDetail.name      = '';
                                    futureInvDetail.invoiceItemDetail.id        = '';
                                    
                                    futureInvDetail.invoiceDetail               = new RecordDetailClass();
                                    futureInvDetail.invoiceDetail.name          = 'NA';
                                    futureInvDetail.invoiceDetail.id            = '';
                                    
                                    futureInvDetail.invoiceSeparately           = string.valueOf(invItem.SubscriptionInvoiceSeparately);    
                                    
                                    futureInvDetail.assetDetail                 = new RecordDetailClass();
                                    futureInvDetail.assetDetail.Name            = '';
                                    futureInvDetail.assetDetail.id              = '';
                                    futureInvDetail.AssetNumber                 = '';
                                    futureInvDetail.chargeDate                  = '';
                                    // CRM-1629 Parsing Date value only to billing previewApi
                                    futureInvDetail.servicePeriodStartDate      = string.valueOf(invItem.ServiceStartDate);
                                    futureInvDetail.servicePeriodEndDate        = string.valueOf(invItem.ServiceEndDate);
                                    
                                    futureInvDetail.unitPrice                  = invItem.UnitPrice != null ? string.valueOf(invItem.UnitPrice.setScale(2)):'0.00';
                                    futureInvDetail.ChargeAmount               = invItem.ChargeAmount != null ? string.valueOf(invItem.ChargeAmount.setScale(2)):'0.00';
                                    futureInvDetail.tax                        = invItem.TaxAmount != null ? string.valueOf(invItem.TaxAmount.setScale(2)):'0.00';
                                    
                                    futureInvDetail.billingPeriod               = '';
                                    futureInvDetail.monthAndYear                = string.valueOf(invItem.ServiceStartDate.toStartOfMonth());
                                    futureInvDetail.monthAndYearString          = string.valueOf( numberToMonthText.get( invItem.ServiceStartDate.Month()) + ' ' + invItem.ServiceStartDate.Year() );
                                    
                                    
                                    if( !subscriptionIdTofutureInvDetailList.containsKey( invItem.SubscriptionId ) ){
                                        subscriptionIdTofutureInvDetailList.put( invItem.SubscriptionId, new list<BillingInsightAttributesClass>());
                                    }
                                    
                                    subscriptionIdTofutureInvDetailList.get( invItem.SubscriptionId ).add( futureInvDetail );
                                    futureInvDetail = new BillingInsightAttributesClass();  
                                    
                                    
                                }
                            }//end invoice items loop
                            
                            if( !subscriptionIdTofutureInvDetailList.isEmpty() ){
                                for( Zuora__Subscription__c subscription : [    select  Zuora__Zuora_Id__c,
                                                                                        Asset__r.Id,
                                                                                        Asset__r.Name,
                                                                                        Asset__r.Asset_Number__c,
                                                                                        Asset__r.Billing_Period__c
                                                                                from Zuora__Subscription__c 
                                                                                where 
                                                                                    Zuora__Zuora_Id__c != null
                                                                                    AND
                                                                                    Asset__c != null
                                                                                    AND
                                                                                    Zuora__Zuora_Id__c in :subscriptionIdTofutureInvDetailList.keyset()
                                                                                limit: Limits.GetLimitQueryRows() - Limits.GetQueryRows()]){
                                                                                    
                                    if( subscriptionIdTofutureInvDetailList.containsKey( subscription.Zuora__Zuora_Id__c ) ){
                                        integer totalInvoiceItem = subscriptionIdTofutureInvDetailList.get( subscription.Zuora__Zuora_Id__c ).size();
                                        for( integer count = 0; count < totalInvoiceItem; count++ ){
                                            subscriptionIdTofutureInvDetailList.get( subscription.Zuora__Zuora_Id__c )[count].assetDetail.Name          = subscription.Asset__r.Name;
                                            subscriptionIdTofutureInvDetailList.get( subscription.Zuora__Zuora_Id__c )[count].assetDetail.id            = subscription.Asset__r.Id;
                                            subscriptionIdTofutureInvDetailList.get( subscription.Zuora__Zuora_Id__c )[count].AssetNumber               = subscription.Asset__r.Asset_Number__c;
                                            subscriptionIdTofutureInvDetailList.get( subscription.Zuora__Zuora_Id__c )[count].billingPeriod             
                                                                                                = subscription.Asset__r.Billing_Period__c != null ? subscription.Asset__r.Billing_Period__c: '';
                                        }
                                    }                                                
                                }//end Suncription query loop
                                
                               for( string subsId : subscriptionIdTofutureInvDetailList.keyset() ){
                                   futureInvDetailList.addAll( subscriptionIdTofutureInvDetailList.get( subsId ) );
                               }
                               
                               
                            }// end !subscriptionIdTofutureInvDetailList.isEmpty() check
                        }// end invoiceItems != null && !invoiceItems.isEmpty() check                    
                }
            }
        }
        if( !errorFutureInvoices && (futureInvDetailList == null || futureInvDetailList.size() <= 0) ){
             noFutureInvoices = true;
        }
        return futureInvDetailList;
    }
    
    public void populateBillingInsightDataForExport(){
        try{
            topNodeList         = new BillingInsightParentGroup();
            BillingInsightGroupClass_Level1 grpLevel1   = new BillingInsightGroupClass_Level1();
            BillingInsightGroupClass_Level2 grpLevel2   = new BillingInsightGroupClass_Level2();
            BillingInsightGroupClass_Level3 grpLevel3   = new BillingInsightGroupClass_Level3();
            
            set<string> groupLevel1Key = new set<string>();
            map<string,map<string,map<string,list<BillingInsightAttributesClass>>>> groupData = new map<string,map<string,map<string,list<BillingInsightAttributesClass>>>>();
            
            biAttrHolderList = new list<BillingInsightAttributesClass>();
            biAttrHolderList = ( list<BillingInsightAttributesClass> )JSON.deserialize( billingInsightDataJson, list<BillingInsightAttributesClass>.class );
            
            if( biAttrHolderList != null && biAttrHolderList.size() > 0 ){
                for( BillingInsightAttributesClass biAttr : biAttrHolderList){
                    if( string.isBlank( biAttr.invoiceDetail.name ) ){
                        biAttr.invoiceDetail.name = 'NA';
                    }
                    if( !groupData.containsKey( biAttr.invoiceType ) ){
                        groupData.put(  biAttr.invoiceType,
                                        new map<string,map<string,list<BillingInsightAttributesClass>>>() );
                        groupLevel1Key.add( biAttr.invoiceType );
                    }
                    if( !groupData.get( biAttr.invoiceType ).containsKey( biAttr.monthAndYearString ) ){
                        groupData.get( biAttr.invoiceType ).put(    biAttr.monthAndYearString,
                                                                    new map<string,list<BillingInsightAttributesClass>>() );
                    }
                    if( !groupData.get( biAttr.invoiceType ).get( biAttr.monthAndYearString ).containsKey( biAttr.invoiceDetail.name ) ){
                        groupData.get( biAttr.invoiceType ).get( biAttr.monthAndYearString ).put(   biAttr.invoiceDetail.name ,
                                                                    new list<BillingInsightAttributesClass>() );
                    }
                    groupData.get( biAttr.invoiceType ).get( biAttr.monthAndYearString ).get( biAttr.invoiceDetail.name ).add( biAttr );
                }
            }
            
            decimal chargeAmount;
            decimal unitPrice;
            decimal tax;
            if( !groupData.isEmpty() ){
                for( string levelKey_1 : groupLevel1Key ){
                    integer i = 0; 
                    grpLevel1 = new BillingInsightGroupClass_Level1();
                    grpLevel1.elementName = levelKey_1;
                    map<string,map<string,list<BillingInsightAttributesClass>>> level1Data = groupData.get( levelKey_1 );
                    
                        for( string levelKey_2 : level1Data.keySet()){
                            
                            map<string,list<BillingInsightAttributesClass>> level2Data = groupData.get( levelKey_1 ).get( levelKey_2 );
                            grpLevel2 = new BillingInsightGroupClass_Level2();
                            grpLevel2.elementName = levelKey_2;
                            for( string levelKey_3 : level2Data.keySet() ){
                                
                                list<BillingInsightAttributesClass> level3Data = groupData.get( levelKey_1 ).get( levelKey_2 ).get( levelKey_3 );   
                                grpLevel3 = new BillingInsightGroupClass_Level3();
                                grpLevel3.elementName = levelKey_3;
                                
                                for( BillingInsightAttributesClass leafNode : level3Data){
                                    
                                    chargeAmount    = leafNode.chargeAmount != null ?  decimal.valueOf(leafNode.chargeAmount): 0.0;
                                    unitPrice       = leafNode.unitPrice != null ?  decimal.valueOf(leafNode.unitPrice): 0.0;
                                    tax             = leafNode.tax != null ?  decimal.valueOf(leafNode.tax): 0.0;
                                    
                                    grpLevel1.totalChargeAmount         += chargeAmount;
                                    grpLevel2.totalChargeAmount         += chargeAmount;
                                    grpLevel3.totalChargeAmount         += chargeAmount;
                                    
                                    grpLevel1.totalUnitPrice            += unitPrice;
                                    grpLevel2.totalUnitPrice            += unitPrice;
                                    grpLevel3.totalUnitPrice            += unitPrice;
                                    
                                    grpLevel1.totalTax                  += tax;
                                    grpLevel2.totalTax                  += tax;
                                    grpLevel3.totalTax                  += tax;
                                    
                                    grpLevel3.leafNodes.add( leafNode );    
                                }
                                
                                grpLevel2.childNodes.add( grpLevel3 );
                            }// levelKey_3
                            grpLevel1.childNodes.add( grpLevel2 );
                        }// levelKey_2
                        topNodeList.rootNode.add( grpLevel1 ); 
                }//end  groupLevel1Key
                
            }//end if
        }catch( exception e){
            system.debug('------Exception------'+e.getStackTraceString() );
            saveException( e, 'On Export' );
        }
        
    }
    
    public void saveException( Exception ex, string msg){
        Error__c error = new Error__c();
        error.Name = 'Billing Insight Report';
        error.Entity_Id__c = 'For Acc: ' + accountId + '. '+msg;
        error.Interface_Name__c = 'AccountBillingInsight';
        error.Error_Description__c = 'Exception: ' + ex.getMessage() + '------StackTraceString: ---' + ex.getStackTraceString();
        insert error;
    }
    
    private void populateNumberToMonthTextData(){
        numberToMonthText = new map<integer,string>();
        numberToMonthText.put(1,'January');
        numberToMonthText.put(2,'February');
        numberToMonthText.put(3,'March');
        numberToMonthText.put(4,'April');
        numberToMonthText.put(5,'May');
        numberToMonthText.put(6,'June');
        numberToMonthText.put(7,'July');
        numberToMonthText.put(8,'August');
        numberToMonthText.put(9,'September');
        numberToMonthText.put(10,'October');
        numberToMonthText.put(11,'November');
        numberToMonthText.put(12,'Decembder');
    }
    
    public class BillingInsightAttributesClass{
        public string                       invoiceType                     {get;set;}// either pastInvoice or FutureInvoice
        public RecordDetailClass            invoiceDetail                   {get;set;}
        public RecordDetailClass            invoiceItemDetail               {get;set;}
        public RecordDetailClass            assetDetail                     {get;set;}
        public string                       assetNumber                     {get;set;}
        public string                       chargeDate                      {get;set;}
        public string                       servicePeriodStartDate          {get;set;}
        public string                       servicePeriodEndDate            {get;set;}
        public string                       unitPrice                       {get;set;}
        public string                       chargeAmount                    {get;set;}
        public string                       tax                             {get;set;}
        public string                       billingPeriod                   {get;set;}
        public string                       monthAndYear                    {get;set;}
        public string                       monthAndYearString              {get;set;}
        public string                       invoiceSeparately               {get;set;}
    }
    
    public class RecordDetailClass{
        public string   name        {get;set;}
        public string   id          {get;set;}
    }
    
    public class BillingInsightParentGroup{
        public list<BillingInsightGroupClass_Level1>                rootNode                     {get;set;}
        
        public BillingInsightParentGroup(){
            rootNode = new list<BillingInsightGroupClass_Level1>();
        }
    }
    
    public class BillingInsightGroupClass_Level1{
         public string                                                  elementName                  {get;set;}
         public decimal                                                 totalUnitPrice               {get;set;}
         public decimal                                                 totalChargeAmount            {get;set;}
         public decimal                                                 totalTax                     {get;set;}
         public list<BillingInsightGroupClass_Level2>                   childNodes                   {get;set;}
         
         public BillingInsightGroupClass_Level1(){
            childNodes          = new list<BillingInsightGroupClass_Level2>();
            totalUnitPrice      = 0.0;
            totalChargeAmount   = 0.0;
            totalTax            = 0.0;
        }
         
    }
    public class BillingInsightGroupClass_Level2{
         public string                                                  elementName                  {get;set;}
         public decimal                                                 totalUnitPrice               {get;set;}
         public decimal                                                 totalChargeAmount            {get;set;}
         public decimal                                                 totalTax                     {get;set;}
         public list<BillingInsightGroupClass_Level3>                   childNodes                   {get;set;}
         
         public BillingInsightGroupClass_Level2(){
            childNodes = new list<BillingInsightGroupClass_Level3>(); 
            totalUnitPrice      = 0.0;
            totalChargeAmount   = 0.0;
            totalTax            = 0.0;
        }
    }
    public class BillingInsightGroupClass_Level3{
         public string                                                  elementName                  {get;set;}
         public decimal                                                 totalUnitPrice               {get;set;}
         public decimal                                                 totalChargeAmount            {get;set;}
         public decimal                                                 totalTax                     {get;set;}
         public list<BillingInsightAttributesClass>                     leafNodes                    {get;set;}
         
         public BillingInsightGroupClass_Level3(){
            leafNodes = new list<BillingInsightAttributesClass>();
            totalUnitPrice      = 0.0;
            totalChargeAmount   = 0.0;
            totalTax            = 0.0;
        }
    }
    
}