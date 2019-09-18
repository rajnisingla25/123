//Name        : LeadManualCreationController
//Description : Controller for Visualforce Page - LeadManualCreation.
//Frequencey  : New Lead created manually from Account using Button
//Author      : Pallavi Tammana

public without sharing class LeadManualCreationController {

    public ApexPages.StandardController controller; 


    Public Lead ld = new Lead();
    public Set<Id> setAccId = new Set<Id>();
    public Set<Id> setLeadId = new Set<Id>();
    public Map<Id, String> MapAccType = new Map<Id, String>();
    public Lead getld()
    {
        return ld;
    }

    Public String FirstName {get; set;}
    Public String LastName {get; set;}
    Public String Email {get; set;}  
    Public String Phone {get; set;}
    public string AccId {get;set;}
    

    public LeadManualCreationController(ApexPages.StandardController Controller)
    {
        ld = (Lead)Controller.getRecord(); 
        this.controller=Controller;
        AccId = ApexPages.currentPage().getParameters().get('AccountId');
        ld.Account__c = ApexPages.currentPage().getParameters().get('AccountId');
        List<Account_Relationship__c> ArrList = new List<Account_Relationship__c>([Select id, Parent_Account__r.Type,Parent_Account__r.ownerId, Parent_Account__r.Email_Address__c, Contact_To__c,Parent_Account__r.Phone,Contact_To__r.FirstName, Contact_To__r.LastName 
                                                        from Account_Relationship__c where Parent_Account__c=:AccId and Contact_Role__c='Primary Contact' limit 1]);
        if(!ArrList.isEmpty()){
            Account_Relationship__c arr = ArrList[0];
            ld.FirstName = arr.Contact_To__r.FirstName;
            ld.LastName = arr.Contact_To__r.LastName;
            ld.Lead_origin__c = 'C3 - TNT/Sales Opportunity';
            ld.Business_Unit__c = 'Realtor.com';
            //ld.Marketing_Lead_Type__c = 'C3 - TNT/Sales Opportunity';
            ld.Ignore_Owner_Assignment__c = 'No';
            if(arr.Parent_Account__r.Email_Address__c != null){
                ld.Email = arr.Parent_Account__r.Email_Address__c;
            }else{            
                ld.Email = ApexPages.currentPage().getParameters().get('Email');            
            }
            if(arr.Parent_Account__r.Phone != null){
                ld.Phone = arr.Parent_Account__r.Phone;
            }else{
                ld.Phone = ApexPages.currentPage().getParameters().get('Phone');
            }
            ld.Contact__c = arr.Contact_To__r.Id;
            if(arr.Parent_Account__r.Type == 'Broker' || arr.Parent_Account__r.Type == 'Realtor Office'){
                MapAccType.put(arr.Parent_Account__r.Id, arr.Parent_Account__r.Type);
            }
        }else{            
            ld.Email = ApexPages.currentPage().getParameters().get('Email');            
            ld.Phone = ApexPages.currentPage().getParameters().get('Phone');
        }    
        
    }
    public pageReference cancel()
    {
        return new PageReference('/'+AccId);
    }
    public PageReference save() {
    
    Pagereference page;
    List<Pre_Lead__c> lstPreLead = new List<Pre_Lead__c>();
        ld.company = ld.LastName;
        ld.LeadSource = 'Customer Care';
        if(MapAccType.get(ld.Account__c) == 'Broker' || MapAccType.get(ld.Account__c) == 'Realtor Office') {
            //ld.OwnerId = Label.Lead_Broker_Queue;
            ld.Ignore_Owner_Assignment__c = 'Yes';
            //Fetching the assignment rules on case
            AssignmentRule AR = new AssignmentRule();
            AR = [select id from AssignmentRule where SobjectType = 'Lead' and Active = true limit 1];
            
            //Creating the DMLOptions for "Assign using active assignment rules" checkbox
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
            ld.setOptions(dmlOpts);
        }
        String LeadrecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('RDC').getRecordTypeId();
        
        Pre_Lead__c pl = new Pre_Lead__c();
        pl.Account__c = ld.Account__c;
        pl.AccountId__c = ld.Account__c;
        pl.Business_Unit__c = ld.Business_Unit__c;
        //pl.Campaign__c = ld.campaignId;
        //pl.Campaign_Id__c = 
        //pl.Contact_Method_Id__c = 
        pl.Company__c = ld.LastName; 
        pl.Contact__c = ld.Contact__c;
        pl.ContactId__c = ld.Contact__c;
        pl.Email__c = ld.Email;
        pl.Hot_Lead__c = true;
        pl.Ignore_Owner_Assignment__c = (ld.Ignore_Owner_Assignment__c == 'Yes' ? true : false);
        pl.Last_Name__c = ld.LastName ;
        pl.First_Name__c = ld.FirstName ;
        pl.Record_Type_Id__c = LeadrecordTypeId;
        pl.Lead_Origin__c = ld.Lead_origin__c;
        pl.Lead_Owner__c =  (ld.ownerId != null ? ld.ownerId : UserInfo.getUserId());
        pl.Lead_Source__c = 'Manual';
        pl.Phone__c = ld.Phone;
        pl.Product_Type__c = ld.Product_Type__c;
        
        map<Id,Id> mapCMCId = new map<Id,Id>();
        List<AccountContactMatch.RecordInfoWrapper> lstWrapper = new List<AccountContactMatch.RecordInfoWrapper>();
        AccountContactMatch.RecordInfoWrapper RecordInfoWrap = new AccountContactMatch.RecordInfoWrapper();
        RecordInfoWrap.AccountId = ld.Account__c;
        //RecordInfoWrap.Campaign = '701q0000000i8gnAAA';
        RecordInfoWrap.ContactId =ld.Contact__c;
        RecordInfoWrap.Email=ld.Email;
        RecordInfoWrap.Phone=ld.Phone;
        lstWrapper.add(RecordInfoWrap);
        if(lstWrapper[0].CMId!=null){
        pl.Contact_Method_Id__c = lstWrapper[0].CMId;
        }
        if(pl.Business_Unit__c=='' || pl.Business_Unit__c==null || pl.Lead_origin__c=='' || pl.Lead_origin__c == null || pl.Product_Type__c==null || pl.Product_Type__c==''){
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please select required fields.'));
            } else {
        Insert pl;
       
        if(pl!=null){
        lstPreLead.add(pl);
        PreLeadProcess.processPreleadToLead(lstPreLead);
        }
        //insert ld; 
        
        setAccId.add(ld.Account__c);
        setLeadId.add(ld.Id);
        if(!setAccId.isEmpty()){
           // LeadFutureReject(setAccId, setLeadId);
           }
        page = new PageReference('/'+AccId);
        }
       return page;
    }
    
    @future
    Public static void LeadFutureReject(Set<Id> setLeadAccs, Set<Id> setLeadIds){
        LeadReject(setLeadAccs, setLeadIds);
    }
     
    Public static void LeadReject(Set<Id> setLeadAccs, Set<Id> setLeadIds){
        Set<String> setStatus = new Set<String>{'Converted','Rejected'};
        Set<String> setMarketType = new Set<String>{'Event','Auto-Renew','Opcity'};
        Set<Lead> UpdLeads = new Set<Lead>();
        List<Lead> Leadlst= new List<Lead>();
        for(Lead led:[Select Id,name,Status,Rejected_Reason__c from Lead where Account__c IN: setLeadAccs and Marketing_Lead_Type__c != :setMarketType and status!=:setStatus and Id NOT IN: setLeadIds]){
            led.Status = 'Rejected';
            led.Rejected_Reason__c = 'Duplicate Lead';
            UpdLeads.add(led);
        }
        if(!UpdLeads.isEmpty()) {
            Leadlst.addAll(UpdLeads);
            System.debug('Leadlst:'+Leadlst);
            update Leadlst;
        }
    }
}