//CRM-3328 Zuora Process to Suspend and Resume all Active Current CoBroke Subscriptions.
public class Z_SuspendandResumeSubscriptions {  
    Public Integer size{get;set;} 
    Public Integer noOfRecords{get; set;}
    Public String statusvalue{get; set;}
    Public String Ascdesc{get; set;}
    Public String Fieldvalue;
    Public String caseId;
    Public Boolean haserror{get; set;}
    Public String Zuoraurl{get; set;} 
    public date EffectiveDate {get; set;}
    public Zuora__CustomerAccount__c  Zuoracustomeraccount {get; set; }
    Public String ActName{get; set;}
    Public String orderByColumn{get; set;}
    Public Boolean Selectall{get; set;}     
    public List<selectOption> status {get;set;} 
    public List<SelectOption> paginationSizeOptions {get;set;}
    public Boolean Autoapplycreditbalance { get; set; }    
    public static final Integer QUERY_LIMIT = 9000;
    public integer rowIndex{get;set;}    
    public case cs;
    public List <WrapperClass> wrapperRecordList{get;set;}
    Boolean valuechanged = false;  
    public ApexPages.StandardSetController setCon { get; set;}  
    //constructor calling init method.
    public Z_SuspendandResumeSubscriptions(){   
        haserror = false;
        statusvalue = 'ALL';
        Ascdesc = 'ASC';
        EffectiveDate = system.today();
        getselctoptions();          
        caseId =  ApexPages.currentPage().getParameters().get('id'); 
       // caseId = '5001h000002fTwc';
        Querycase();        
        if(cs!=null){
            getcustomeraccount();       
            ZuoraCustomeraccount();
           // Fieldvalue = '001j0000014FDXvAAO';
            init();               
        }else{
            haserror = true;
            ApexPages.Message msginfo = new ApexPages.Message(ApexPages.severity.Error, 'There are no Open Lead suspenion Cases on the account ');  
            ApexPages.addMessage(msginfo);       
        }
    }
    
    public void Querycase(){ 
        try{
            cs =  [SELECT Id,Account.Name,CaseNumber, Status, SubStatus__c, AccountId, Type FROM  Case WHERE  Id = :caseId And Status != 'Closed' AND Type = 'Lead Suspension' LIMIT 1];   
        }catch(Exception ex) {            
        }       
    }
    public void getcustomeraccount(){
        Zuoracustomeraccount = [Select Id, Name ,Zuora__Account__c, AutoApplyCreditBalances__c, Zuora__Zuora_Id__c  From Zuora__CustomerAccount__c where Zuora__Account__c = :cs.AccountId and Zuora__Status__c = 'Active'];
        if(Zuoracustomeraccount!=null && Zuoracustomeraccount.AutoApplyCreditBalances__c == 'true')
            Autoapplycreditbalance = true;
        Fieldvalue= Zuoracustomeraccount.Zuora__Account__c;
    }
    //Init method which queries the records from standard set controller.
    public void init() {
        
        String qry = getqry();        
        wrapperRecordList = new List<WrapperClass>();
        integer i =0;
        if(setCon==null || valuechanged){
            system.debug('qry ' + qry);
            setCon = new ApexPages.StandardSetController(Database.getQueryLocator(qry));              
            setCon.setPageSize(size); 
            valuechanged = false;
        }
        for (Zuora__Subscription__c cont : (List<Zuora__Subscription__c>)setCon.getRecords()) {           
            system.debug('cont@: ' +cont+ ' rowN0@: '+ i+ ' recrodstatus@ ' );
            ActName = cont.Zuora__Account__r.name;
            if((cont.Zuora__Status__c == 'Active' && cont.Zuora__TermSettingType__c == 'TERMED' && cont.Zuora__TermEndDate__c!=null && cont.Zuora__TermEndDate__c >= system.today()) || (cont.Zuora__Status__c == 'Suspended') || (cont.Zuora__Status__c == 'Active' && cont.Zuora__TermSettingType__c == 'EVERGREEN'))
            {
                system.debug('cont@@: ' +cont+ ' rowN0@: '+ i+ ' recrodstatus@ ');
                wrapperRecordList.add(new WrapperClass(cont, Selectall, i));
                i++; 
            }
        }
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
    
    public void previous() {
        setCon.previous();
        init();
    }
    
    public void next() {
        setCon.next();
        init();
    }
    
    
    public PageReference ReturntoCase() {           
        PageReference returnUrl = new PageReference('/'+cs.Id);                 
        return returnUrl;
    }
    
    public PageReference refreshPageSize() {
        valuechanged = true;        
        init();      
        return null;
    }      
    
    public PageReference getthevalues() {
        valuechanged = true;
        init();        
        return null;
    } 
    
    public void ZuoraCustomeraccount() {
        
        Map<String,Object> zConfig = zqu.zQuoteUtil.getZuoraConfigInformation();
        String envEndpoint = (String)zConfig.get('apiurl__c');
        System.debug('envEndpoint:' + envEndpoint);
        String baseUrl = '';
        if(envEndpoint.contains('services4')){
            ZuoraUrl__c  sett = ZuoraUrl__c.getValues('Servicesurl');
            if(sett!=null)
                baseUrl = sett.ZuoraUrl__c;
        }else{
            ZuoraUrl__c  sett = ZuoraUrl__c.getValues('ProductionUrl');
            baseUrl = sett.ZuoraUrl__c;
        }
        this.Zuoraurl = baseUrl+Zuoracustomeraccount.Zuora__Zuora_Id__c;
        System.debug('baseUrl@ '+ baseUrl);
        
    }  
    public PageReference updateZuoraAccount() {
        Zuora.zApi zApi = Z_amendsubscription.zuoraApiAccess();
        List<Zuora.ZApi.SaveResult> updateAccResults = new List<Zuora.ZApi.SaveResult>();
        Zuora.ZObject updatedAccount = new Zuora.ZObject('Account');
        updatedAccount.setValue('Id', Zuoracustomeraccount.Zuora__Zuora_Id__c);
        if(Autoapplycreditbalance)
            updatedAccount.setValue('AutoApplyCreditBalances__c', 'True');
        else
            updatedAccount.setValue('AutoApplyCreditBalances__c', 'False');     
        try {
            if(!Test.isRunningTest()) {
                updateAccResults = zApi.zUpdate(new List<Zuora.ZObject>{updatedAccount});
                System.debug( 'SOAP Request = ' + Zuora.zApi.currentLogger.request );
                System.debug( 'SOAP Response = ' + Zuora.zApi.currentLogger.response );
            } else { 
                updateAccResults = new List<Zuora.ZApi.SaveResult>();
                Zuora.ZApi.SaveResult updateAccResult = new Zuora.ZApi.SaveResult();
                updateAccResult.Success = true;
                updateAccResults.add(updateAccResult);
            }
        } catch (Exception ex) {
            System.debug('Error occurred trying to create Account in Zuora: '+ex.getMessage());                     
        }
        Boolean updateAccountSuccess = false;
        String updateaccountResult = '';
        if (updateAccResults.size() > 0) {
            Zuora.ZApi.SaveResult updateAccResult = updateAccResults[0];
            updateAccountSuccess = (updateAccResult.Success != null) ? updateAccResult.Success : false;
            if(updateAccountSuccess)
                updateaccountResult = 'The Auto Apply Credit Balance has been updated in Zuora '; 
            else
                updateaccountResult = (updateAccResult.Errors != null && updateAccResult.Errors.size() > 0 && String.isNotBlank((String)updateAccResult.Errors[0].getValue('Message'))) ? (String)updateAccResult.Errors[0].getValue('Message') : '';
            ApexPages.Message msginfo = new ApexPages.Message(ApexPages.severity.INFO, updateaccountResult);
            ApexPages.addMessage(msginfo);                     
        }     
        return null;
    }  
    
    public string getqry(){
        String qry = 'SELECT Id,Name , Zuora__Account__r.name,Zuora__TermSettingType__c ,Status__c, Zuora__Account__c ,Asset__r.End_Date__c, Asset__c ,Zuora__Status__c  ,Zuora_Comment__c ,Zuora__CustomerAccount__c  ,Zuora__TermEndDate__c  ,Zuora__TermStartDate__c  ,Zuora__Zuora_Id__c  FROM Zuora__Subscription__c  ' ;
        String whrecalues = getwherecluase();            
        if(whrecalues!=null && !String.isEmpty(whrecalues)){
            qry =  qry + whrecalues;
        }
        return qry;
    }
    
    public String getwherecluase() { 
        
        system.debug('Fieldvalue@ ' +Fieldvalue);
        String Filter = '';
        if((Fieldvalue!=null &&!String.isEmpty(Fieldvalue)) || (statusvalue!=null && statusvalue!= 'All')){          
            Filter += 'Where ';
            if(Fieldvalue != null && !String.isEmpty(Fieldvalue)){
                Filter += 'Zuora__Account__c = \'' +  Fieldvalue.trim() + '\' and ';
                if((statusvalue!=null && statusvalue!= 'All')){
                    Filter += ' Zuora__Status__c = \'' + statusvalue + '\'  and ';    
                }
            }
            String productcode = 'COBROKE';
            Filter += ' Asset__r.Product2.ProductCode =  \'' + productcode + '\' ';
            
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
        return Filter;
    }
    
    public void Suspend(){
        ProcessRecords('Active' ,'SuspendSubscription');   
        valuechanged = true;
        init();  
    }
    
    public void Resume(){
        
        ProcessRecords('Suspended' , 'ResumeSubscription');  
        valuechanged = true;
        init();  
    }   
    public PageReference ProcessRecords(String Value, String Action){
        String Efctdate = getdatestring();
        List<Zuora__Subscription__c> sendlist = new List<Zuora__Subscription__c>();
         for(WrapperClass wrp : wrapperRecordList){
           if(wrp.isSelected && wrp.Subscription.Zuora__Status__c == Value){    
                    system.debug('sending ' + wrp.Subscription.Name);
                    Zuora__Subscription__c nn = new Zuora__Subscription__c();
                    nn.id = wrp.Subscription.id;
                    nn.Status__c  = 'Processing';
                    nn.Zuora_Comment__c = '';
                    nn.Name  = wrp.Subscription.Name;
                    nn.Zuora__Zuora_Id__c  = wrp.Subscription.Zuora__Zuora_Id__c;
                    sendlist.add(nn);                 
                }       
            }
        this.selectAll = false;
        //commented out the selectall functionality CRM-5384.
        /*if(Selectall){         
            String qry = getqry();
            List<Zuora__Subscription__c> mvg =  Database.query(qry);    
            system.debug('mvg@ '+mvg);
            for(Zuora__Subscription__c inloop: mvg){                      
                if(inloop.Zuora__Status__c == Value){            
                    Zuora__Subscription__c nn = new Zuora__Subscription__c();
                    nn.id = inloop.id;
                    nn.Status__c  = 'Processing';
                    nn.Zuora_Comment__c  = '';
                    nn.Name  = inloop.Name;
                    nn.Zuora__Zuora_Id__c  = inloop.Zuora__Zuora_Id__c;
                    sendlist.add(nn);                 
                }    
            }            
        }else{ */                
        //}
        
        Integer size = sendlist.size();
        if(size>0 || Test.isRunningtest()){          
            if(size>20){
                update sendlist;
                try{        
                    Database.executeBatch(new Z_SendamendmentstoZuoraJob('SELECT Id,Name ,Zuora__Status__c , Zuora__Account__r.name, Zuora__Account__c ,Asset__c ,Zuora_Comment__c ,Zuora__CustomerAccount__c  ,Zuora__TermEndDate__c  ,Zuora__TermStartDate__c  ,Zuora__Zuora_Id__c  FROM Zuora__Subscription__c Where Zuora__Account__c = \'' +  Fieldvalue.trim() + '\' and Status__c = \'Processing\'',Efctdate,Action ,cs.CaseNumber), 90);
                }catch(Exception ex){
                    ApexPages.Message msginfo = new ApexPages.Message(ApexPages.severity.Error, 'Failed to Execute batch Error: ' +ex +'  Please Retry  ');  
                    ApexPages.addMessage(msginfo);
                    return null;
                }
                ApexPages.Message msginfo = new ApexPages.Message(ApexPages.severity.INFO, 'Subscriptions Sent to Zuora: '+size);
                ApexPages.addMessage(msginfo);
                valuechanged = true;      
                init(); 
            }else{
                try{
                    List<Zuora__Subscription__c> Results =new  List<Zuora__Subscription__c>();
                    String Description = 'Amend from Lead suspension Case'; 
                    z_amendsubscription.zuoraApiAccess(); 
                    Integer RecordsFailed = 0;
                    Integer RecordsProcessed = 0;
                    Integer TotalNumberofRecords = 0; 
                    for(Zuora__Subscription__c inloop: sendlist){
                        TotalNumberofRecords++;
                        String Result ='';                                
                        system.debug('Sub ' + inloop + 'ectdate' + Efctdate + 'action' + Action);                    
                        Result = Z_amendsubscription.createAmendment(inloop.name,inloop.Zuora__Zuora_Id__c,Efctdate,Description, Action,'Leadsuspensioncase'); 
                        if(Result!=null && Result.contains('Failed to amend Subscription')){
                            RecordsFailed++;
                            Zuora__Subscription__c sub = new Zuora__Subscription__c();
                            Sub.Id = inloop.Id;
                            sub.Zuora_Comment__c = Result;
                            Sub.Status__c = 'Error';
                            Results.add(sub);
                        }else{
                            Zuora__Subscription__c sub = new Zuora__Subscription__c();
                            sub.Status__c = 'Processed';
                            sub.Id = inloop.Id;
                            Results.add(sub);
                            RecordsProcessed++;
                        }
                    }
                    
                    if(RecordsFailed > 0 || Test.isrunningtest()){
                        String toAddresses = UserInfo.getUserEmail();
                        String custAddresses = Error_Notification_Email_Settings__c.getInstance('SuspensionEmail').Suspension_Failure__c;   
                        if(custAddresses!=null)
                            toAddresses += ';'+custAddresses;
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                     
                        mail.setToAddresses(toAddresses.split(';'));
                        mail.setSubject('Suspend/Resume Failure '+ cs.CaseNumber);
                        String messageBody = '<html><body> Total Number of Records: ' +TotalNumberofRecords + '<br><br> Records Processed: ' +RecordsProcessed+ '<br><br> Records Failed: ' +RecordsFailed + '</body></html>';
                        mail.setHtmlBody(messageBody);       
                        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {mail};
                            Messaging.SendEmailResult[] resu= Messaging.sendEmail(messages);
                    }
                    if(Results.size()>0)
                        update Results;
                }catch(Exception ex){
                    ApexPages.Message msginfo = new ApexPages.Message(ApexPages.severity.Error, 'Not able to perform amendments due to ' + ex);
                    ApexPages.addMessage(msginfo);                   
                }
            }
        }else{
            ApexPages.Message msginfo = new ApexPages.Message(ApexPages.severity.Error, 'There are no subscriptions selected. Please select Valid Subscriptions to Amend');
            ApexPages.addMessage(msginfo);             
        }
        return null;
        
    }
    //wrapper class being used for checkbox showing.
    public class WrapperClass {
        public Boolean isSelected {get;set;}
        public integer rowNo {get;set;}
        public Zuora__Subscription__c Subscription {get;set;}
        
        public WrapperClass(Zuora__Subscription__c Sub, Boolean isSelected ,integer i) {
            this.Subscription = Sub;
            this.rowNo =i;
            this.isSelected = isSelected;
        }
    }
    public void getselctoptions (){
        
        //fileds for status change
        status = new List<SelectOption>();
        status.add(new SelectOption('All',' ALL ')); 
        status.add(new SelectOption('Active',' Active '));
        status.add(new SelectOption('Suspended',' Suspended '));
        
        if(size == null)
            this.size=999;
        paginationSizeOptions = new List<SelectOption>();
        paginationSizeOptions.add(new SelectOption('50','50'));
        paginationSizeOptions.add(new SelectOption('100','100'));
        paginationSizeOptions.add(new SelectOption('200','200'));
        paginationSizeOptions.add(new SelectOption('300','300'));
        paginationSizeOptions.add(new SelectOption('999','1000')); 
    }  
    
    public String getdatestring(){
        String[] Efctdate = String.valueOf(EffectiveDate).split('-',0);       
        return  Efctdate[0] + '-' + Efctdate[1] + '-' + Efctdate[2];
    }
    
    
}