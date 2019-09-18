public with sharing class ListingMarket{




private  string mStatus ;
private  string mId ;
private  string mfollowup ;
private  string mRejReason ;
private  string mDescription;
private  string LeadId ;



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


    public PageReference makeSOACall() {
         
        try
        { 
    
    //Lead UpdLead = [select id from Lead where id=:setLIds limit 1];
    Lead UpdLead = [select id,AccountId__c,Contact__c  from Lead where id=:mId limit 1];
    
    UpdLead.Status = mStatus;
    UpdLead.Follow_Up_Status__c= mfollowup;
    UpdLead.Rejected_Reason__c= mRejReason;
    UpdLead.Description= mDescription ;
    
    Update UpdLead;
    
    // Create Task
    String userId = UserInfo.getUserId();

    Task t = new Task();
    t.OwnerId = userId;
    t.Lead__c = mId;
    t.Subject = mDescription;
    t.Status = 'Completed';
    t.Priority = 'Normal';
    t.WhatId = UpdLead.AccountId__c;
    t.WhoId = UpdLead.Contact__c;
    t.Outcome__c = mfollowup;
    t.Issue__c = mRejReason;
    
    System.debug('TRACE' + t);
    insert t;
    
    
    //sLeads.clear();

    //Lead l1 = new Lead(Id=mId, Status=mStatus, Follow_Up_Status__c=mfollowup, Rejected_Reason__c=mRejReason);
    //sLeads.add(l1);
                  
    //upsert sLeads;
    
        
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
    
// Inline Edit ends


    // Adding a Wrapper Class - Wrapper Class to display info from 2 objects

    class WrapperClass implements Comparable {
        // Defining first Object
        public Lead object1 {get; set;}
        
        //Defining second Object
        public Account_Listing__c object2 {get; set;}
        
        // Defining boolean for checkbox in VFP
        public Boolean selected {get; set;}

        //Wrapper constructer - this will be called from th Main class constructor

        public WrapperClass(Lead object1,Account_Listing__c object2) {

            this.object1 = object1 ;

            this.object2 = object2 ;
            
            this.selected = false;
        }
        
        // Added for Sorting only for one object defined in Wrapperclass - Object2 (Account Listing Object)
        public Integer compareTo(Object vObj)  
        {  
            WrapperClass objToComp = (WrapperClass)vObj;  
        
            if((String)object2.get(compareField) > (String)objToComp.object2.get(compareField))  
            return sortOrder.equals('asc') ? 1 : 0;  
            else  
            return sortOrder.equals('asc') ? 0 : 1;  
            }
        
    }
    
    // Will be used to perfrom Sort 
    public void sortWrpLst()  
    {  
        wrapperList.sort();  
    }  
    
    // Define Wrapper class in Main Class

    public List<WrapperClass> wrapperList { get; set;}
    
    // Added for Sorting
    public static String compareField {get; set;}
    public static String sortOrder{get; set;}

     //the collection of sObjects to display - Added for Sorting
  public List<Lead> lstLead {get;set;}
  public List<Lead> lstAcc {get;set;}
  public Set<Id> setLeadIds {get;set;}
  public Set<Id> setAccIds {get;set;}
  public List< Account_Listing__c > g_Listings {get;set;}
  public List< Account> g_Accounts {get;set;}
    

    public ListingMarket(ApexPages.StandardSetController controller) {
    
      // Initiate variables inside main class - controller    
      lstLead = new List<Lead>();
      lstAcc = new List<Lead>();
      setLeadIds = new Set<Id>();
      setAccIds = new Set<Id>();
      g_Listings = New List <Account_Listing__c>();
      g_Accounts = new List<Account>();
         
       // Defining Wrapper Class variable
        wrapperList = new List<WrapperClass>() ;
   
    
     if(controller == null) {
                controller = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [SELECT Id,Available_inventory__c,Account__c,Account__r.Party_ID__c,Product__r.BigMachines__Part_Number__c,Product__r.ProductCode FROM Lead limit 200]));
            }
        controller.setPageSize(200);
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

    
    lstAcc = [SELECT id,Name,AccountId__c,Phone,Status,Email,Follow_Up_Status__c,Marketing_Lead_Type__c,Recent_Campaign__c,
              Rejected_Reason__c,Description FROM Lead where id=:setLeadIds];
    system.debug('TRACE :'+lstAcc);
    
            //create a wrapper for the data to display
            // integger i defined to get specific Contact list while calling wrapper constructor
            integer i = 0;
            // starting contact loop for all contacts returned from SOQL
            for(Lead led : lstAcc)
            {
            // defining Account listing and Lead Sobject variable

            Lead le;
            Account_Listing__c als;

            
            if(lstAcc.size() > i)
             le = lstAcc.get(i);
           
            g_Listings = [SELECT id,Account_Name__c,Account_Type__c,Zip__c,City__c,State__c,
                  County__c,Country__c,Market_Tier__c,Listing_Type__c,Listing_Count__c,
                  CFCB_Full_Fast__c,CFCB_Full_Flex__c,CFCB_Half_Fast__c,CFCB_Half_Flex__c,
                  CFCB_City_Fast__c,CFCB_City_Flex__c,CFCB_FULL_TIER__c,CFCB_HALF_TIER__c,
                  CFCB_CITY_TIER__c,CFCB_CITYHALF_TIER__c,DAP__c,FAC_COMP_Qty__c,FAC_LB_Qty__c,
                  FAC_MREC_Qty__c,FH__c,Hand_Raiser__c,Account_Name__r.Name,Account_Name__r.Past_Due__c,
                  Account_Name__r.Collections_Hold__c,Account_Name__r.Parent_Broker__c,
                  Account_Name__r.Franchise_Type__c,Account_Name__r.Total_Agents__c,
                  Account_Name__r.Total_CLC__c,Account_Name__r.Total_Contract_Value__c,
                  Account_Name__r.Total_HLC__c,Account_Name__r.Total_Offices__c,Account_Name__r.Account_Time_Zone__c,
                  Account_Name__r.Account_Sub_Type__c, Account_Name__r.Own_Co_Broke__c,Account_Name__r.Own_CoShow__c,Account_Name__r.Own_SLE__c
                  FROM Account_Listing__c where Parent_Agent_Broker__c=:le.AccountId__c];
           
           
                  
            // integger j defined to get all accounts matching Contact list while calling wrapper constructor
            integer j = 0;
            for(Account_Listing__c a : g_Listings){
            als = g_Listings.get(j);
            wrapperList.add(new WrapperClass(le,als));
            j++;
            } 
    
   
             i++;
            }                  

    
   

    }

// For inline update
public PageReference UpdateLead() {
    // initiate contact list variable for the contact which will be selcted in VFP
    List<Lead> selectedLeads = new List<Lead>();

    // Populated selected contact list in VFP    
    for(WrapperClass c: wrapperList) {
        if(c.selected == true) {
            selectedLeads.add(c.object1);
            upsert selectedLeads;
        }
    }
    
    return null;
}


public List<Account_Listing__c> getAccountListing(){
return g_Listings;
}



public pageReference  ExportToExcel(){
    return new PageReference('/apex/AccountListingExportToExcel');
}

}