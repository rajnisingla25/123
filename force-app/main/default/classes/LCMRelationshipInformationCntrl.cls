/**
* LCM-67, LCM-239: Controller for LCMRelationshipInformationComp
* Used to send notifications to agents and lenders when comarketing relationship is added, amended and cancelled.
* Test class:LCMRelationshipInformationCntrlTest
**/
global class LCMRelationshipInformationCntrl {
    
    public Id relId;
    public List<Account_Relationship__c> acctRelList {get;set;}
    public String acctType {get;set;}
    public String actionType {get;set;}
    public String partnerActType {get;set;}
    public List<Comarketing_Relationship__c> comarRels {get;set;}
    public List<Comarketing_Relationship__c> amendComarRels {get;set;}
    public String getRelId(){
        return relId;
    }
    
    
    public void setRelId(string value){
        relId = value;
        comarRels = new List<Comarketing_Relationship__c>();
        amendComarRels = new List<Comarketing_Relationship__c>();
        acctRelList = [Select id, Child_Account__r.Name, total_relationship_assets_price__c, comarketer_Actual_Spend__c, Initial_comarketer_spend_percent__c, Comarketing_Status__c,
                       Comarketing_Cancellation_Date__c, Comarketing_Cancellation_Description__c , Comarketing_cancellation_reason__c,Comarketing_start_date__c,
                       Current_Comarketer_Spend_Percent__c, relationship_CAP__c, Start_Date__c, Total_comarketing_assets__c, Parent_Account__r.Name from Account_Relationship__c where Id = :relId limit 1];
        getComarketingRel();
    }
    
    public void getComarketingRel(){
        List<Comarketing_Relationship__c> cRels = [Select id, Cancellation_Reason__c, Agent_Account__r.Name, Lender_account__c, Cancellation_Date__c,Lender_Asset_Monthly_Contribution__c,CFCB_Asset__r.Asset_Number__c,CFCB_Asset__r.Quantity__c, CFCB_Asset__r.Lead_Type__c,
                                                   CFCB_Asset__r.Market__c, Lender_Account__r.Name, Start_Date__c, Lender_Cancellation_Date__c,Agent_Asset_Monthly_Contribution__c,Lender_Percentage_Contribution__c,Agent_Total_Contribution__c,CFCB_Asset__r.End_date__c,Cancel_Description__c,
                                                   Amendment_description__c, Amendment_effective_date__c, sent_cancellation_email__c, status__c from Comarketing_Relationship__c where Relationship__c = :relId and Sent_cancellation_email__c = false];
        for(Comarketing_Relationship__c cr : cRels){
            if(actionType == 'Amend'){
                if((cr.Amendment_description__c != null && cr.Amendment_description__c != '') || (cr.Cancel_Description__c != null && cr.Cancel_Description__c  != '')){
                    amendComarRels.add(cr);
                }            }
            if(cr.status__c == 'Active'){
                comarRels.add(cr);
            }
        }
    }
    
}