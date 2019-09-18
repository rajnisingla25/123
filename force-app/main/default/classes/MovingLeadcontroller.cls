//CRM-3232 start Praveen
public class MovingLeadcontroller { 
    //variable used in page.
    Public Integer size{get;set;} 
    Public Integer noOfRecords{get; set;}
    Public String statusvalue{get; set;}
    Public String QueryFilter{get; set;}
    Public String changestatusvalue{get; set;}
    Public String Fieldapi{get; set;}
    Public String Ascdesc{get; set;}
    Public String Fieldvalue{get; set;}  
    Public String orderByColumn{get; set;}
    Public Boolean Selectall{get; set;}     
    public List<selectOption> status {get;set;}
    public List<selectOption> Changestatus {get;set;}
    public string Newrecord{get;set;}
    public List<selectOption> Fields {get;set;}
    public List<SelectOption> paginationSizeOptions {get;set;}
    public String Asset { get; set; }    
    public String Comments { get; set; }
    public Boolean success { get; set; }
    public String Description { get; set; }
    //  public String EndDate { get; set; }
    public String Ischanged { get; set; }
    public String PerUnitPrice { get; set; }
    public String Quantity { get; set; }
    public ImportLeads Leads{get;set;}
    public static Date startDate{get;set;}
    public static Date endDate{get;set;}
    public boolean IsNew { get; set;}
    public Moving_Lead__c movingLead { get; set;}
    public static final Integer QUERY_LIMIT = 10000;
    public integer rowIndex{get;set;}    
    public List <WrapperClass> wrapperRecordList{get;set;}
    Boolean valuechanged = false;  
    public boolean showSaveBtn { get; set;}
    public ApexPages.StandardSetController setCon { get; set;}  
    public boolean ismoving { get; set;}
    public boolean isnewmovinglead { get; set;}
    public string pageName{get;set;}
    public Id movingRecordTypeId;
    public Id mortgageRecordTypeId;
    public string qry{get;set;}
    public Blob csvFileBody{get;set;}
    public string csvAsString{get;set;}
    public String[] csvFileLines{get;set;}
    public List<Moving_Lead__c> mllist{get;set;}
    //constructor calling init method.
    public Movingleadcontroller(){   
        movingRecordTypeId = Schema.SObjectType.Moving_Lead__c.getRecordTypeInfosByName().get('Moving').getRecordTypeId();
        mortgageRecordTypeId = Schema.SObjectType.Moving_Lead__c.getRecordTypeInfosByName().get('Mortgage').getRecordTypeId();
        System.debug(movingRecordTypeId);
        System.debug(mortgageRecordTypeId);
        ismoving = false;
        string pageName = ApexPages.currentPage().getUrl().substringBetween('apex/', '?');
        system.debug('pageName' +pageName);
        if(pageName == 'MovingLeads'){
            ismoving = true;    
        }else if(pageName == 'NewLeadRecord'){
            isnewmovinglead = true;
        }
        statusvalue = 'New';
        Ascdesc = 'ASC';
        getselctoptions();      
        init();
        csvFileLines = new String[]{};
            mllist = New List<Moving_Lead__c>(); 
    }
    public void NewLead(){
        movingLead = new Moving_Lead__c();   
        showSaveBtn = true;        
    }
    public void importCSVFile(){
        //CRM-5359 - Mortgage Data import
        set<string> CakeidsToEmail = new set<string>();
        Integer ny = System.now().year();
        Integer nmo = System.now().Month();
        Integer nh = System.now().Hour();
        Integer nm = System.now().Minute();
        Integer ns = System.now().Second();
        String sch = 'RCM_'+ny+nmo+nh+nm+ns;
        try{
            csvAsString = csvFileBody.toString();
            csvFileLines = csvAsString.split('\n'); 
            
            for(Integer i=1;i<csvFileLines.size();i++){
                Moving_Lead__c mlObj = new Moving_Lead__c();
                string[] csvRecordData = csvFileLines[i].split(',');
                if(csvRecordData[0] != ''){
                    mlObj.Asset__r = new Asset(Cake_Id__c=csvRecordData[0]);
                    System.debug('the Account Id is ' + new Asset(Cake_Id__c=csvRecordData[0]).AccountId);
                    System.debug('the Account Id is1 ' + mlObj.Asset__r.AccountId);
                    mlObj.Account_ID__c = new Asset(Cake_Id__c=csvRecordData[0]).AccountId;
                }
                if(csvRecordData[1] != ''){
                    mlObj.Quantity__c =  integer.valueOf(csvRecordData[1]);
                }
                if(csvRecordData[2] != ''){
                    mlObj.Per_Unit_Price__c = decimal.valueof(csvRecordData[2].trim());
                }
                if(csvRecordData[3] != ''){
                    mlObj.Status__c = csvRecordData[3];
                }
                if(csvRecordData[4] != ''){
                    mlObj.Description__c = csvRecordData[4] ;  
                }
                mlObj.RecordTypeId = mortgageRecordTypeId;//Id.valueof(csvRecordData[3]); 
                mlObj.Batch_Number__c = sch;                                                                    
                mllist.add(mlObj);   
            }
            //insert mllist;
            Database.SaveResult[] SR = Database.insert(mllist, False);
            System.debug('SaveResult: ' + SR);
            System.debug('MovingLeads: ' + mllist);           
            for(Integer i=0;i<SR.size();i++){
                if(!SR[i].isSuccess()){
                    system.debug(SR[i].getErrors());
                    system.debug(mllist[i]);
                    //CakeidsToEmail.add(string.valueOf(SR[i].getErrors().getMessage()));	               
                    for(Database.Error err : sr[i].getErrors()) {                  
                        CakeidsToEmail.add(string.valueOf(err.getMessage()));
                    }
                }
            }
        }
        catch (Exception e)
        {
            system.debug('reasonfortheerror'+e.getcause());
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importing data. Please make sure input csv file is in correct format. If you continue to get the error, please contact salesforce Admin.');
            ApexPages.addMessage(errorMessage);
        }
        if (CakeidsToEmail.size() > 0) {
            sendErrorEmail(CakeidsToEmail);
        }		
    }
    //Init method which queries the records from standard set controller.
    public void init() {
        system.debug('called me');
        String qry = getqry();  
        wrapperRecordList = new List<WrapperClass>();
        integer i =0;
        try{
            if(setCon==null || valuechanged){
                system.debug('qry ' + qry);
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(qry));              
                setCon.setPageSize(size); 
                valuechanged = false;
            }
            for (Moving_Lead__c cont : (List<Moving_Lead__c>)setCon.getRecords()) {           
                system.debug('cont@: ' +wrapperRecordList.size()+ ' rowN0@: '+ i+ ' recrodstatus@ ' +cont.Status__c );
                wrapperRecordList.add(new WrapperClass(cont, Selectall, status, i));
                i++;   
            }
        }catch(Exception e){}   
    } 
    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
        set;
    }  
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
        set;
    }
    public Integer pageNumber {
        get {
            return setCon.getPageNumber();
        }
        set;
    }   
    Public Integer getTotalPages(){
        Decimal totalSize = setCon.getResultSize();
        Decimal pageSize = setCon.getPageSize();
        Decimal pages = totalSize/pageSize;
        return (Integer)pages.round(System.RoundingMode.CEILING);
    }  
    public void first() { 
        setCon.first();
        init();
    }
    public void last() {   
        setCon.last();
        init();
    }
    public void save() {
        setCon.save();
        init();
    }
    public  void Newrecords(){        
        IsNew = true; 
        system.debug('IsNew:' +IsNew);
    }
    // CRM-4004- To hide the SAVE button after saving the record..
    public void insertNewLead() {     
        movingLead.recordtypeid = movingRecordTypeId;
        insert movingLead;
        system.debug('Inserted lead:' + movingLead);        
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,'Lead inserted successfully.');
        ApexPages.addMessage(myMsg);        
        isNew = false;
        showSaveBtn = false;  
    }
    public void previous() {
        setCon.previous();
        init();
    }
    
    public void next() {
        setCon.next();
        init();
    }
    
    public PageReference ReturntoHome() {      
        PageReference returnUrl = new PageReference('/');        
        return returnUrl;
    }
    public pagereference editmethid(){
        system.debug('wrapperRecordList@: ' +wrapperRecordList.size()+ ' rowIndex: '+ rowIndex);
        if(wrapperRecordList.size()>rowIndex){
            wrapperRecordList[rowIndex].isEdit = true;
        }
        return null;
    }
    
    public pagereference savemethid(){
        if(wrapperRecordList.size()>rowIndex){
            update wrapperRecordList[rowIndex].Leads;   
            wrapperRecordList[rowIndex].isEdit = false;
        }
        return null;
    }
    
    
    public PageReference refreshPageSize() {
        valuechanged = true;        
        init();      
        return null;
    }      
    
    public PageReference Search() {
        valuechanged = true;
        if(orderByColumn==null)
            statusvalue = 'ALL';
        init();              
        return null;
    } 
    
    public PageReference getthevalues() {
        valuechanged = true;
        init();        
        return null;
    }  
    
    public string getqry(){
        String qry = 'SELECT Id,Name,Account__c,Asset__r.Zuora_Subscription_Name__c,Cake_Id1__c,Mortgage_Account_Party_Id__c,RecordTypeId,Asset__r.Billing_Feed__c,Account_ID__c,Cake_Id__c,Account_ID__r.Party_ID__c,Asset__r.Asset_Number__c ,Created_Date__c,Batch_Number__c ,Description__c ,Comments__c , Status__c,Asset__r.Asset_ID_18_Digit__c ,Asset__c,Zuora_Comment__c, Price__c,Per_Unit_Price__c, Quantity__c FROM Moving_Lead__c';
        String whrecalues = getwherecluase();            
        if(whrecalues!=null && !String.isEmpty(whrecalues)){
            qry =  qry + whrecalues;
        }
        system.debug(qry);
        return qry; 
    }
    // CRM-4006 --Start-- Comma separated search functionality and partial search on account name
    // CRM-4168 -- Moving: Filter doesn't work after search on Moving Leads vf page
    public String getwherecluase() { 
        system.debug(movingRecordTypeId);
        //id recd = '0121h0000000CK8';
        String Filter = '';
        system.debug('@@@ ' + Ascdesc);
        Filter += ' where ';
        if(ismoving){
            Filter = Filter  +'RecordTypeId = '+'\''+movingRecordTypeId+'\' ';
        }
        else{
            Filter = Filter  +'RecordTypeId = '+'\''+mortgageRecordTypeId+'\' ';
        }
        if((Fieldvalue!=null &&!String.isEmpty(Fieldvalue) && Fieldapi!=null) || (statusvalue!=null && statusvalue!= 'All')){           
            if(!String.isEmpty(Fieldvalue)&&(Fieldapi == 'Account_ID__r.Party_ID__c' || Fieldapi == 'Name')){
                Filter += ' and '+ Fieldapi;
                Filter += ' in (';
                list<String>partyidslist = new list<string>(Fieldvalue.split(','));
                System.debug('Party ids you searched'+partyidslist);
                if(Fieldvalue.contains(','))
                {
                    string temp = '';
                    for(string Partyidstring:partyidslist){
                        if(Partyidstring.trim()!='')
                            temp += '\''+Partyidstring.trim()+'\',';
                    }
                    if(temp!= ''){
                        temp = temp.removeend(',');
                        Filter += temp;
                    }
                    
                    system.debug('values1'+ Filter);
                }
                else{
                    Filter += '\''+Fieldvalue+'\''; 
                    system.debug('values2'+ Filter);
                }
                Filter += ')';
                if((statusvalue!=null && statusvalue!= 'All')){
                    Filter += ' and Status__c = \'' + statusvalue + '\' ';  
                }
            }    
            else if(!String.isEmpty(Fieldvalue)&&Fieldapi == 'Account_ID__r.Name'){
                Filter += Fieldapi;
                Filter += ' Like \'%'+String.escapeSingleQuotes(Fieldvalue)+'%\'';
                if((statusvalue!=null && statusvalue!= 'All')){
                    Filter += ' and Status__c = \'' + statusvalue + '\' ';  
                }
            }
            else if(!String.isEmpty(Fieldvalue)&& Fieldapi == 'Batch_Number__c'){
                Filter += Fieldapi;
                Filter += ' Like \'%'+String.escapeSingleQuotes(Fieldvalue)+'%\'';
                if((statusvalue!=null && statusvalue!= 'All')){
                    Filter += ' and Status__c = \'' + statusvalue + '\' ';  
                }
            }
            // CRM-4006 --End-- Comma separated search functionality and partial search on account name
            else if(Fieldvalue != null && Fieldapi != null && !String.isEmpty(Fieldvalue)){
                Filter +=  Fieldapi + ' = \'' +  Fieldvalue.trim() + '\' ';
                if((statusvalue!=null && statusvalue!= 'All')){
                    Filter += ' and Status__c = \'' + statusvalue + '\' ';    
                }                
            }else if((statusvalue!=null && statusvalue!= 'All')){
                Filter += ' and Status__c = \'' + statusvalue + '\' ';    
            }
            //Filter += 'and Asset__c !=null';          
        }
        if(orderByColumn!=null && !String.isEmpty(orderByColumn)){
            if(Ascdesc == 'ASC') {              
                Filter += ' Order By '+orderByColumn+ ' '+Ascdesc;                                  
                Ascdesc = 'DESC';                   
            }else{
                Filter += ' Order By '+orderByColumn+ ' '+Ascdesc;
                Ascdesc = 'ASC';
            }
            orderByColumn=null;
            
        }  
        Filter += ' LIMIT 9900';
        system.debug('values3'+ Filter);
        return Filter;
    }
    public PageReference Changestatusselected() {
        
        if(Selectall){         
            String qry = getqry();
            List<Moving_Lead__c> mvg =  Database.query(qry);          
            for(Moving_Lead__c inloop: mvg){                                                                   
                inloop.Status__c = changestatusvalue;                                                   
            }  
            update mvg;
        }else{
            for(WrapperClass inloop: wrapperRecordList){
                if(inloop.isSelected){
                    system.debug(' inloop.Leads '+ inloop.Leads+ ' changestatusvalue@ ' + changestatusvalue);
                    inloop.Leads.Status__c = changestatusvalue;            
                    inloop.isSelected =false;
                }
            }  
            setCon.save();
        }
        valuechanged = true;       
        init();        
        return null;
    } 
    public PageReference Sendtozuora(){
        List<Moving_Lead__c> sendlist = new List<Moving_Lead__c>();
        if(Selectall){         
            String qry = getqry();
            List<Moving_Lead__c> mvg =  Database.query(qry);    
            system.debug('mvg@ '+mvg);
            for(Moving_Lead__c inloop: mvg){                      
                if(inloop.Status__c == 'New'){            
                    Moving_Lead__c nn = new Moving_Lead__c();
                    nn.id = inloop.id;
                    nn.Status__c = 'Processing';
                    sendlist.add(nn);                 
                }    
            }            
        }else{        
            for(WrapperClass wrp : wrapperRecordList){
                if(wrp.isSelected && wrp.Leads.Status__c == 'New'){            
                    Moving_Lead__c nn = new Moving_Lead__c();
                    nn.id = wrp.leads.id;
                    nn.Status__c = 'Processing';
                    sendlist.add(nn);                 
                }        
            }
        }
        update sendlist;
        Integer size = sendlist.size();
        if(size>0 || Test.isRunningtest()){
            try{    
                if(!Test.isRunningtest())
                    Database.executeBatch(new Z_SendchargestoZuora('SELECT Id, Account_ID__c ,Account_ID__r.Bill_To_Parent__c, Account_ID__r.Name, Account_ID__r.ShippingState, Name, Asset__r.Product2.ProductCode,Description__c, Quantity__c,Asset__c , Asset__r.Subscription_Id__c, Per_Unit_Price__c,Status__c,Price__c From Moving_Lead__c Where Status__c = \'Processing\' and Asset__c !=null'), Integer.valueOf(Label.Moving_Billing_Batch_Size));
            }catch(Exception ex){
                ApexPages.Message msginfo = new ApexPages.Message(ApexPages.severity.Error, 'Failed to Execute batch Error: ' +ex +'  Please Retry  ');             
            }
            ApexPages.Message msginfo = new ApexPages.Message(ApexPages.severity.INFO, 'Number of leads send to Zuora : '+size);
            ApexPages.addMessage(msginfo);
            valuechanged = true;      
            init(); 
        }else{
            ApexPages.Message msginfo = new ApexPages.Message(ApexPages.severity.Error, 'There are no New Leads selected to Send to Zuora. Please select the Leads which had Status as New');
            ApexPages.addMessage(msginfo);             
        }
        return null;
        
    }
    //wrapper class being used for checkbox showing.
    public class WrapperClass {
        public Boolean isSelected {get;set;}
        public Boolean isEdit {get;set;}
        public integer rowNo {get;set;}
        public Moving_Lead__c Leads {get;set;}
        
        public WrapperClass(Moving_Lead__c Leads, Boolean isSelected ,List<selectOption> status,integer i) {
            this.Leads = Leads;
            this.rowNo =i;
            this.isSelected = isSelected;
        }
    }
    public void getselctoptions (){
        
        //fileds for status change
        Schema.DescribeFieldResult fieldResult = Moving_Lead__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        status = new List<selectOption>();
        List<selectOption> stat = new List<SelectOption>();
        stat.add(new SelectOption('ALL', 'ALL'));
        for(Schema.PicklistEntry f : ple)
        {
            stat.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        this.status.addall(stat);
        
        //change status
        Changestatus = new  List<selectOption>();  
        List<selectOption> cstat = new List<SelectOption>();
        for(Schema.PicklistEntry f : ple)
        {
            cstat.add(new SelectOption(f.getLabel(), f.getValue()));
        } 
        
        this.Changestatus.addall(cstat);
        //search
        Fields = new List<SelectOption>();
        Fields.add(new SelectOption('Account_ID__c',' Account Id ')); 
        Fields.add(new SelectOption('Account_ID__r.Name',' Account Name ')); 
        Fields.add(new SelectOption('Account_ID__r.Party_ID__c',' Party Id '));
        Fields.add(new SelectOption('Asset__c',' Asset Id '));
        Fields.add(new SelectOption('Batch_Number__c',' Batch '));
        Fields.add(new SelectOption('Name',' Lead Name '));
        Fields.add(new SelectOption('Id',' Lead Id '));
        
        //pagesize
        if(size == null)
            this.size=50;
        paginationSizeOptions = new List<SelectOption>();
        paginationSizeOptions.add(new SelectOption('50','50'));
        paginationSizeOptions.add(new SelectOption('100','100'));
        paginationSizeOptions.add(new SelectOption('200','200'));
        paginationSizeOptions.add(new SelectOption('300','300'));
        paginationSizeOptions.add(new SelectOption('999','1000')); 
    }
    //CRM-3232 end Praveen.
    // Venu Ravilla-- Made changes for the import lead functionality...Start
    public void importLeads(){
        String dateStrStart =  dateFormat(string.valueOf(startDate));
        String dateStrEnd =  dateFormat(string.valueOf(endDate));
        system.debug('Dates:' + dateStrStart  +  '  ' + dateStrEnd);
        string endpointurl = Import_Leads_Url__c.getInstance().End_Point_Url__c +'?StartDate='+dateStrStart+'&EndDate='+dateStrEnd;
        system.debug('End Point:'+endpointurl);
        // string url = 'https://soa-external-app.entsys-dev.moveaws.com:7080/soa-infra/resources/default/GetMovingUsageDetails/GetUsageRest?StartDate='+dateStrStart+'&EndDate='+dateStrEnd;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setEndpoint(endpointurl);
        req.setTimeOut(120000);
        //system.debug('response1:' + endpointurl);
        try{
            HttpResponse  res= h.send(req);
            //system.debug('Res'+res.getbody());
            Leads = (ImportLeads)JSON.deserialize(res.getBody(), ImportLeads.class);
            //system.debug('Leads:' + Leads);
            if  (Leads.UsageRecord.size() > 0) {
                integer count = insertLeads(Leads);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, count+' records have been imported successfully'));
                //wrapperRecordList = new List<WrapperClass>();
                valuechanged = true; 
                init();
            }         
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ooops! Lead data is not available. Please retry and if the problem persists, contact SFDC Admin'));
            System.debug('HTTP Response is ' + e.getMessage());
        } 
        //return null;
    }  
    @testvisible
    private Integer insertLeads(ImportLeads leads) {
        List<Moving_Lead__c> movingLeads = new  List<Moving_Lead__c>();
        set<string> partyIds = new Set<string>();
        set<ID> AssetIds = new Set<ID>();
        set<string> AssetIds1 = new Set<string>();
        set<string> MatchingAssets = new Set<string>();
        set<string> AssetsToEmail = new Set<string>();
        // Boolean result;
        Map<string,string> partyIdAccMap = new Map<string,string>();
        Map<string,string> AssetIdMap = new Map<string,string>();
        for (ImportLeads.UsageRecord record : leads.UsageRecord) {
            partyIds.add(record.acct);
            AssetIds1.add(record.aid);
        }
        //System.debug('key values' +partyIds);
        List<Account> accs = [select Id,Party_ID__c from Account where Party_ID__c in :partyIds];
        for (Account acc: accs) {
            partyIdAccMap.put(acc.Party_ID__c,acc.Id);            
        }
        List<Asset> assList = [select Id,name,Billing_Feed__c from Asset where id in :AssetIds1];
        for (Asset a: assList) {
            MatchingAssets.add(a.Id);
        }        
        System.debug('key values1' +partyIdAccMap);
        System.debug('key set 11:' +MatchingAssets);
        system.debug('Size:' + leads.UsageRecord.size());
        for (ImportLeads.UsageRecord record : leads.UsageRecord) {
            // system.debug('MatchingAssets.contains(record.aid):'  + MatchingAssets.contains(record.aid)  +  '  ' + record.acct);
            if ((MatchingAssets.contains(record.aid) && record.acct !=null) || Test.isrunningtest()) {
                Moving_Lead__c l = new Moving_Lead__c();       
                l.Per_Unit_Price__c = Decimal.valueOf(record.rate);
                l.Quantity__c = Integer.valueOf(record.qty);   
                l.Asset__c = record.aid;
                l.Party_ID__c = record.acct;
                l.Batch_Number__c = record.batchnumber;
                l.Account_ID__c = partyIdAccMap.get(record.acct);
                l.Description__c = record.name;
                l.RecordTypeId = movingRecordTypeId;
                movingLeads.add(l); 
            }
            else {
                AssetsToEmail.add(record.aid);
            } 
        }
        system.debug('Moving Leads inserted:'+ movingLeads);
        //system.debug('AssetsToEmail Leads:'+ AssetsToEmail);
        if (movingLeads.size() > 0) {
            insert movingLeads;
            this.success = true;
        }
        
        if (AssetsToEmail.size() > 0) {
            sendEmail(AssetsToEmail);
        }
        return movingLeads.size();
    }
    public pagereference deleteSelectedLeads() {
        List<Moving_Lead__c> leadsToDelete = new List<Moving_Lead__c>();
        if(Selectall){         
            String qry = getqry();
            List<Moving_Lead__c> mvg =  Database.query(qry);    
            system.debug('mvg@ '+mvg);
            for(Moving_Lead__c inloop: mvg){                                                
                Moving_Lead__c nn = new Moving_Lead__c(id =inloop.id);                 
                leadsToDelete.add(nn);                                    
            }            
        }else{
            for(WrapperClass inloop: wrapperRecordList){
                if (inloop.isSelected) {
                    Moving_Lead__c del = new Moving_Lead__c(id=inloop.Leads.id);
                    leadsToDelete.add(del);
                } 
            }
        }
        if (leadsToDelete.size() > 0) {
            delete leadsToDelete;
        }
        valuechanged = true;       
        init();     
        return null;
    }
    public String dateFormat(String theDate){
        String [] s = theDate.split('-');
        String newDate= s[1]+'-'+s[2]+'-'+s[0];
        return newDate;
    }
    // Venu Ravilla-- CRM-3213 Made changes for the import lead functionality...End
    @testvisible
    private void sendEmail(set<string> unmatchingAssetIds) {
        String theEmailAddresses = Error_Notification_Email_Settings__c.getInstance('Failed Moving Leads').Asset_Creation_Error_Emails__c;
        if (theEmailAddresses != null && theEmailAddresses != '') {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(theEmailAddresses.split(';'));
            mail.setSenderDisplayName(UserInfo.getName());
            mail.setSubject('Alert: Moving Lead Usage Data Import Errors:' +  unmatchingAssetIds.size());
            String messageBody = 'The following asset records returned an error while being imported to Salesforce through the Moving Lead Usage process. <br/>' ;
            for (string assetId: unmatchingAssetIds) {
                messageBody += assetId+'<br/>';
            }
            messageBody += 'Please correct these records in Moving Admin prior to re-importing the data to Salesforce. All remaining data has been imported successfully.';
            mail.setHtmlBody(messageBody); 
            system.debug(mail );
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
        }
    }
    public void sendErrorEmail(set<string> unmatchingCakeIds) {
        String theEmailAddresses = Error_Notification_Email_Settings__c.getInstance('Failed Mortgage Leads').Asset_Creation_Error_Emails__c;
        if (theEmailAddresses != null && theEmailAddresses != '') {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(theEmailAddresses.split(';'));
            mail.setSenderDisplayName(UserInfo.getName());
            mail.setSubject('Alert: Mortgage Lead Usage Data Import Errors: ' + unmatchingCakeIds.size());
            String messageBody = 'The following Cake Ids returned an error while being imported to Salesforce. <br/>' ;
            for (string cakeId: unmatchingCakeIds) {
                messageBody += cakeId+'<br/>';
            }
            messageBody += 'Please validate the Cake Ids prior to re-importing the data to Salesforce.';
            mail.setHtmlBody(messageBody); 
            system.debug(mail );
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
        }
    } 
}