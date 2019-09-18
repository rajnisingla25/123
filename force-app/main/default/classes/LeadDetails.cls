public with sharing class LeadDetails{




private  string mStatus ;
@Testvisible private  string mId ;
@Testvisible private  string mfollowup ;
@Testvisible private  string mRejReason ;
@Testvisible private  string mDescription;

private  string mCallbackDate;
private  string mCallbackTime;

public void setId(String newvalue) { mId = newvalue;}
        
public string getId(){ return mId ;}       

public void setStatus(String newvalue) { mStatus = newvalue;}
        
public string getStatus(){ return mStatus ;}       

public void setfollowup(String newvalue) { mfollowup = newvalue;}
        
public string getfollowup(){ return mfollowup ;}

public void setRejReason(String newvalue) { mRejReason = newvalue;}
        
public string getRejReason(){ return mRejReason ;} 

public void setDescription(String newvalue) { mDescription = newvalue;}
        
public string getDescription(){ return mDescription ;} 


// Added to Create Call Back Event
public void setCallbackDate(String newvalue) { mCallbackDate = newvalue;}
        
public string getCallbackDate(){ return mCallbackDate ;} 

public void setCallbackTime(String newvalue) { mCallbackTime = newvalue;}
        
public string getCallbackTime(){ return mCallbackTime ;} 

        

    public PageReference updateLead() {
    
        try
        { 

    
    Lead UpdLead = [select id,Status, Follow_Up_Status__c, Description, Last_Interaction_Date__c, AccountId__c,Account__r.Name, Contact__c,Notes_Left__c, Callback_Date__c, Callback_Time__c  from Lead where id=:mId limit 1];
    
    
    UpdLead.Status = mStatus;
    UpdLead.Follow_Up_Status__c= mfollowup;
    UpdLead.Rejected_Reason__c= mRejReason; 
    UpdLead.Description= mDescription ;
    
    UpdLead.Callback_Date__c = mCallbackDate;
    UpdLead.Callback_Time__c = mCallbackTime;
    
    Update UpdLead;
    
   }
   catch (exception e)
        {
            
            System.debug('An exception occurred during Web Service Call  Create/Update: ' + e.getMessage());
            
        }
        
     
        return null;
    }

// CK Added for inline Edit
public pageReference submit()
    {
       

        return null;
    }
    

    List<Lead> lstLead = new List<Lead>();
    List<Lead> selectedLeads = new List<Lead>();
    Set<Id> setLeadIds = new Set<Id>();
    

public LeadDetails(ApexPages.StandardSetController controller) {
     if(controller == null) {
                controller = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [SELECT Id,CFCB__c,Account__c,Account__r.Party_ID__c,Product__r.BigMachines__Part_Number__c,
                     Product__r.ProductCode FROM Lead limit 200]));
            }
    if(!test.isRunningTest()){
        controller.setPageSize(200);}
        controller.next();
            if(controller.getSelected().size()>0){
            lstLead = controller.getSelected();
            } else{
                    
            lstLead = controller.getRecords();
                
            }
           // return controller;
    for(Lead led:lstLead){
    setLeadIds.add(led.id); 
    }
    
    selectedLeads = [SELECT id,Name,AccountId__c,ContactId__c,Phone,Status,Email,Follow_Up_Status__c,Marketing_Lead_Type__c,Recent_Campaign__c,
Rejected_Reason__c,Description,Account__r.Name,Account__r.Type,Account__r.Phone,Account__r.Past_Due__c,Account__r.Party_id__c,Account__r.Parent_Broker__c,Account__r.Franchise_Type__c,Account__r.Total_Agents__c,Account__r.Total_CLC__c,Account__r.Total_Contract_Value__c,Account__r.Total_HLC__c,Account__r.Total_Offices__c,Account__r.Account_Time_Zone__c,Account__r.Account_Sub_Type__c, Account__r.ShippingPostalCode, CFCB__c,DAP__c,FAC_Comp_Qty__c,
FAC_MREC_Qty__c,FAC_LB_Qty__c,Last_Interaction_Date__c,Last_Interaction_Date_MM_DD_YYY__c, HandRaiser__c,Home_Search__c,Featured_CMA_SM__c,Callback_Date__c,Callback_Time__c   FROM Lead where id=:setLeadIds];

    
   }

public List<Lead> getselectedLeads(){
return selectedLeads;
}


}