public with sharing class AccountLeadSelectionClassController {
    public list<LeadWrapper> LeadWrapper{get;set;}
    public list<Lead> led{get;set;}
    public id accId;
    public id leadId;
    Set<Id> setLeadId = new Set<Id>();
    public AccountLeadSelectionClassController(ApexPages.StandardController controller) {
    	LeadWrapper= new list<LeadWrapper>();
        Set<String> setMarketType = new Set<String>{'Opcity'};
        accId = String.valueOf(ApexPages.CurrentPage().getParameters().get('id')); 
            Led = [select id,name, Recent_Campaign__c , Rejected_Reason__c, Marketing_Lead_Type__c ,Account__c,Contact__c,status from Lead where (status = 'New' OR status = 'In Progress') and Marketing_Lead_Type__c != :setMarketType and Account__c=:accId and OwnerId=:UserInfo.getUserId()];
            for(Lead Leads : led){
                //Leads.Account__C = accId;
                LeadWrapper.add(new LeadWrapper(Leads));           
        }
    }
    public Pagereference Save(){
    
    Integer count=0;
    for(LeadWrapper Leads : LeadWrapper) {
        if(Leads.checked == true) {
            count++;
        }
    }
    if(count>1){
        ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.ERROR,'Please select one lead only');
        ApexPages.addMessage(myMsg) ;
        return null;
    }
    else {
        List<Lead> leadAccountChange = new List<Lead>();
        for(LeadWrapper Leads : LeadWrapper) {
            if(Leads.checked == true) {
            leadId = Leads.led.Id;
                leads.led.status = 'In Progress';
                leadAccountChange.add(Leads.Led);
            } else {
            //leadId = Leads.led.Id;
                leads.led.status = 'Rejected';
                 leads.led.Rejected_Reason__c = 'Closed for Multiple Leads';
                leadAccountChange.add(Leads.Led);
            }
        }
        if(leadAccountChange.size() > 0){
            update leadAccountChange;
        }
        Pagereference pg = New Pagereference('/apex/CreateQuote?accountId='+accId+'&leadid='+leadId);
        pg.Setredirect(TRUE);
        return pg;
        }
    
    }
    Public PageReference SaveQuote(){
        Pagereference pg = New Pagereference('/apex/CreateQuote?accountId='+accId+'&leadid='+leadId);
        pg.Setredirect(TRUE);
        return pg;
    }
    Public class LeadWrapper{
        public Boolean checked {get;set;}
        public Lead led {get;set;}
        public LeadWrapper(Lead led){
            this.checked = false;
            this.led = led;
        }
    }
}