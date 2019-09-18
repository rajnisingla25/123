public with sharing class CustomerReferralsCon
{
    public String SposorId {get; set;}
    public String SposoredIds {get; set;}
    public List<CustomerReferralsWrapper> LstCustomerReferral {get; set;}
    public String accId {get; set;}
    Public set<Id> childaccIds {get;set;}
    String accName;
    String accEmail;
    String accPhone;
    
    public CustomerReferralsCon(ApexPages.StandardController controller)
    {
        accId = ApexPages.currentPage().getParameters().get('Id');
        if(accId!=null){
            for(Account act:[Select Id,Party_ID__c, Name, Email_Address__c, Phone from Account where Id=:accId]){
                SposorId = act.Party_ID__c;
                accName = act.Name;
                accEmail = act.Email_Address__c;
                accPhone = act.Phone;
            }
        }
        
    }
    
    public Pagereference searchAccounts()
    {
        LstCustomerReferral = new List<CustomerReferralsWrapper>();
        childaccIds = new set<Id>();
        List<String> lstPartyId = SposoredIds.split(',');
        //lstPartyId.add(SposorId);
        
        List<Account_Relationship__c> lstAccReln = [Select Id, Contact_Role__c, Parent_Account__c, Parent_Account__r.Name, 
                                                        Parent_Account__r.PrimaryEmail_CMId__c,Broker_of_Record__c, Parent_Account__r.Party_ID__c, Parent_Account__r.OwnerId, 
                                                        Parent_Account__r.Owner.Name, Parent_Account__r.Credit_Status__c, Parent_Account__r.Status__c, 
                                                        Parent_Account__r.Account_Sub_Type__c, Parent_Account__r.BillingState, Contact_To__c, 
                                                        Contact_To__r.FirstName, Contact_To__r.LastName, Contact_To__r.Email, 
                                                        Contact_To__r.Preferred_Phone_Number__c 
                                                        From Account_Relationship__c 
                                                        Where Contact_Role__c = 'Primary Contact' 
                                                        AND Active__c = true AND Parent_Account__r.Party_ID__c IN :lstPartyId];
                                                        
        for(Account_Relationship__c accRelationship :lstAccReln)
        {
        childaccIds.add(accRelationship.Parent_Account__c);
            CustomerReferralsWrapper custReferralsWrapper = new CustomerReferralsWrapper();
            custReferralsWrapper.IsSelected = false;
            custReferralsWrapper.AccountRelationship = accRelationship;
            if(accRelationship.Parent_Account__r.Party_ID__c == SposorId)
                custReferralsWrapper.Referral = 'Sponsor';
            else
                custReferralsWrapper.Referral = 'Sponsored';
            LstCustomerReferral.add(custReferralsWrapper);
        }
        if(childaccIds.size()>0){
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'This account doesnt have primary contact. Please create one before creating lead'));
        }
        return null;
    }
    
    public Pagereference clearPage()
    {
        SposorId = '';
        SposoredIds = '';
        LstCustomerReferral = new List<CustomerReferralsWrapper>();
        return null;
    }
    //CRM-6229: New button to redirect to Account
    public pageReference backToAccount() {
        return new PageReference('/'+accId);
    }
    
    public Pagereference createReferrals()
    {
        List<Pre_Lead__c> lstPreLead = new List<Pre_Lead__c>();
        Pre_Lead__c preLead;
        Integer leadCount = 0;
        String displayErrorMsg = '';
        set<String> setStatus = new set<String>{'New','In Progress'};
        set<String> setMLT = new set<String>{'Event','Auto-Renew','Opcity'};
        for(Lead led:[Select id,Name from Lead where Status=:setStatus and Account__c=:childaccIds and Marketing_Lead_Type__c != :setMLT]){
        leadCount = leadCount+1;
        }
        
        for(CustomerReferralsWrapper customerReferral :LstCustomerReferral)
        {
            if(customerReferral.IsSelected && customerReferral.AccountRelationship.Parent_Account__r.Account_Sub_Type__c!='Customer' && leadCount<1)
            {
                preLead = new Pre_Lead__c();
                preLead.AccountId__c = customerReferral.AccountRelationship.Parent_Account__c;
                preLead.Company__c = customerReferral.AccountRelationship.Parent_Account__r.Name;
                preLead.ContactId__c = customerReferral.AccountRelationship.Contact_To__c;
                preLead.Email__c = customerReferral.AccountRelationship.Contact_To__r.Email;
                preLead.First_Name__c = customerReferral.AccountRelationship.Contact_To__r.FirstName;
                preLead.Last_Name__c = customerReferral.AccountRelationship.Contact_To__r.LastName;
                preLead.Phone__c = customerReferral.AccountRelationship.Contact_To__r.Preferred_Phone_Number__c;
                preLead.Lead_Owner__c = UserInfo.getUserId();
                preLead.Account__c = customerReferral.AccountRelationship.Parent_Account__c;
                preLead.Contact__c = customerReferral.AccountRelationship.Contact_To__c;
                preLead.Product_Type__c = 'Referral';
                preLead.Lead_Origin__c = 'Sales Referral';
                preLead.Ignore_Owner_Assignment__c = true;
                preLead.Contact_Method_Id__c = customerReferral.AccountRelationship.Parent_Account__r.PrimaryEmail_CMId__c;
                preLead.Referring_Agent_Name__c = accName;
                preLead.Referring_Agent_Email__c = accEmail;
                preLead.Referring_Agent_Phone__c = accPhone;
                preLead.Referring_Agent_PartyId__c = SposorId;
                lstPreLead.add(preLead);
            } else {
            if(leadCount>0){
            displayErrorMsg = 'You cannot refer an existing customer or open lead through the referral lead form.';
            } else 
            if(customerReferral.AccountRelationship.Parent_Account__r.Account_Sub_Type__c=='Customer'){
            displayErrorMsg = 'You cannot refer an existing customer or open lead through the referral lead form.';
            } else
            if(!customerReferral.IsSelected){
            displayErrorMsg = displayErrorMsg + 'Please select atlest one record';
            }
        }
        }
        
        Pagereference page;
        
        if(!lstPreLead.isEmpty() && displayErrorMsg==''){
        insert lstPreLead;
        PreLeadProcess.processPreleadToLead(lstPreLead);
            page = new Pagereference('/'+accId);
        } else
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, displayErrorMsg));
        }
        
        return page;
    }
    
    public class CustomerReferralsWrapper
    {
        public Boolean IsSelected {get; set;}
        public String Referral {get; set;}
        public Account_Relationship__c AccountRelationship {get; set;}
    }
}