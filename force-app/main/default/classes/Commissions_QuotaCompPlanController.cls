public without sharing class Commissions_QuotaCompPlanController {
    public List<Quota__c> quotaList {get;set;}
    public ApexPages.StandardSetController stdController{get;set;}
    public Integer size{get;set;}
    public Integer noOfRecords{get; set;}
    public static final Integer PAGE_SIZE = 300;
    public String listviewURL {get;set;}
    public Boolean selectedAllQuotas {get;set;}
    public Set<Id> quotaIds {get;set;}
    public string quotaRecordId {get;set;}    
    public List <WrapperClass> wrapperRecordList{get;set;}
    public boolean hasAccessToSend{get;set;}
    public Set<String> setProfileNames = new Set<String>{'System Administrator','Sales Commissions Analyst','VP of Finance','Move BA','Move Developer','Admin Read Only'};
    
    public Commissions_QuotaCompPlanController(ApexPages.StandardSetController standardController){
        
        Profile profile = [Select Id,Name From Profile Where Id = :UserInfo.getProfileId() LIMIT 1];
        if(setProfileNames.contains(profile.Name))
          hasAccessToSend = true;
        else
            hasAccessToSend = false;
        
        this.stdController = standardController;        
        quotaList = new List<Quota__c>();
        quotaIds = new Set<Id>();
        stdController = new ApexPages.StandardSetController((List<Quota__c>)this.stdController.getSelected());
        stdController.setPageSize(PAGE_SIZE);        
        init();        
        listviewURL = ApexPages.currentPage().getParameters().get('retURL'); 
        List<Quota__c> lst = stdController.getRecords();
    }
    
    public void init() {
        Set<Id> setSelectedQuotaIds = new Set<Id>();
        for (Quota__c quota : (List<Quota__c>)stdController.getRecords()){ 
            setSelectedQuotaIds.add(quota.Id);
        }        
        wrapperRecordList = new List<WrapperClass>();
        quotaList = new List<Quota__c>([SELECT Id,User__c,User__r.Name,Name,User_Team__c,Period_Name__c,Target_Amount__c,Total_Sale_Renewal__c,Target_Amount_Renewal__c,Collection_Target_Amount__c,(Select Id,dsfs__Sent_Date_Time__c,dsfs__Envelope_Status__c From DocuSign_Status__r ORDER BY dsfs__Sent_Date_Time__c DESC LIMIT 1) FROM Quota__c WHERE ID IN: setSelectedQuotaIds order by User_Team__c] );
        system.debug('quotaList='+quotaList);       
        List<WrapperClass> quotaWraps = new List<WrapperClass>();
        Integer selectedQuotaNumber = 0;
        for (Quota__c quota : quotaList)
        {
            WrapperClass currentWrap = new WrapperClass(quota);
            
            //for the checkbox:
            if(quotaIds != null) 
            {
                if(quotaIds.contains(quota.Id)){
                    currentWrap.isSelected = true;
                    selectedQuotaNumber ++; //show the checkbox selected count
                }
                else{
                    currentWrap.isSelected = false;
                }
            }
            wrapperRecordList.add(currentWrap);
        }
        selectedAllQuotas = selectedQuotaNumber == wrapperRecordList.size() ? true: false; 
        noOfRecords = stdController.getResultSize();
        size = PAGE_SIZE;
        
    }
    
    /** handle quota selected */
    public void doSelectQuotaRecord()
    { 
        this.quotaIds.add(this.quotaRecordId);
    }
    
    /** handle quota deselected */
    public void doDeselectQuotaRecord()
    {
        this.quotaIds.remove(this.quotaRecordId);
    }
    
    public void isSelectedAll(){
        for (Quota__c quota : (List<Quota__c>)stdController.getRecords()){ 
            if(selectedAllQuotas)
                quotaIds.add(quota.Id);
            else
                quotaIds.remove(quota.Id); 
        }
    }
    
    public Integer getSelectedCount()
    {
        return this.quotaIds.size();
    } 
    
    /** indicates whether there are more records after the current page set.*/
    public Boolean hasNext {
        get {
            return stdController.getHasNext();
        }
        set;
    }
    
    /** indicates whether there are more records before the current page set.*/
    public Boolean hasPrevious {
        get {
            return stdController.getHasPrevious();
        }
        set;
    }
    
    /** returns the page number of the current page set*/
    public Integer pageNumber {
        get {
            return stdController.getPageNumber();
        }
        set;
    }
    
    /** return total number of pages for page set*/
    Public Integer getTotalPages(){
        Decimal totalSize = stdController.getResultSize();
        Decimal pageSize = stdController.getPageSize();
        Decimal NoOfpages = totalSize/pageSize;
        return (Integer)NoOfpages.round(System.RoundingMode.UP);       
    }
    
    /** returns the first page of the page set*/
    public void first() {
        stdController.first();
        init();
    }
    
    /** returns the last page of the page set*/
    public void last() {
        stdController.last();
        init();
    }
    
    /** returns the previous page of the page set*/
    public void previous() {
        stdController.previous();
        init();
    }
    
    /** returns the next page of the page set*/
    public void next() {
        stdController.next();
        init();
    }
    
    public PageReference confirmCompensationPlan(){
        List<Quota__c> lstQuotaToUpdate = new List<Quota__c>();
        List<Quota__c> lstSelectedQuotas = [Select Id,Send_Comp_Plan__c From Quota__c Where Id IN :quotaIds];
        system.debug('lstSelectedQuotas=='+lstSelectedQuotas.size());
        system.debug('soql=='+Limits.getQueries());
        if(lstSelectedQuotas.size() > 0 ){
            for(Quota__c q : lstSelectedQuotas){
                if(!q.Send_Comp_Plan__c){
                    Quota__c quotaToUpdate = new Quota__c();
                    quotaToUpdate.Id = q.Id;
                    quotaToUpdate.Send_Comp_Plan__c = true;  
                    lstQuotaToUpdate.add(quotaToUpdate);
                } 
            }
        }
        system.debug('lstQuotaToUpdate=='+lstQuotaToUpdate.size());
        system.debug('listviewURL=='+listviewURL);
        if(lstQuotaToUpdate.size() > 0){
            Database.SaveResult[] results = Database.update(lstQuotaToUpdate);
            if(results[0].isSuccess()){
                PageReference pageRef = new PageReference(listviewURL);
                return pageRef;
            }
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info,'It seems compensation plan is in progress for the selected quotas.Please select other quotas.'));
        }
        return null;
    }
    
    public PageReference goBackandSelectMore(){
        PageReference pageRef = new PageReference(listviewURL);
        return pageRef;
    }
    
    public class WrapperClass {
        public Boolean isSelected {get;set;}
        public Quota__c quotaRecord {get;set;}        
        public WrapperClass(Quota__c quotaRecord) {
            this.quotaRecord = quotaRecord;
            this.isSelected = false;
        }
    }
    
}