/********************************************************************************************
*   @Author :       Srinidhi M 
*   @Purpose:       To get Assets that are tied to a Case's Accounts
*   @Class          Case_Assets_List
*   @TestClass      Case_Assets_List_Test
*   @JIRA           SEP-103
*   @CreatedDate:   June 04th, 2018
*********************************************************************************************
   JIRA No      Date       Modified By         Description                                Tag No
*********************************************************************************************

*/

public class Case_Assets_List {
    public  Case currentCase{get; set;}
    public  string accountId; 
    
    public List<Schema.FieldSetMember> getFields() {
    return SObjectType.Asset.FieldSets.CaseAsset_Fields.getFields();
     }
    
    // Initialize setAsset and return a list of  asset records
    public List<Asset> getAssets() {
    //Set number of Record to be displayed in a Page
              try{
                  
                  setAsset.setpagesize(10);
                  return (List<Asset>) setAsset.getRecords();
                  
                }
                  catch(exception e){                  
                  system.debug('@@ in exception in getCase method'+e.getMessage());
                  return null;
              }
    }

    
    public ApexPages.StandardSetController setAsset {
        get {
            if(setAsset == null) {
            //Custom Setting to filter records based on Asset Status value
                 CaseConsoleSidebarSetting__c[] settings = CaseConsoleSidebarSetting__c.getall().values();
                 Set<String>filterValues= New Set<String>();
        
                    for(CaseConsoleSidebarSetting__c cs:settings){
                    if(cs.Case_Asset_Status__c!=NULL)
                    //Adds Custom filed Case_Asset_Status__c values to filterValues
                    filterValues.add(cs.Case_Asset_Status__c);
                    }  
                    //Gets the current Case Account
                        if(ApexPages.currentPage().getParameters().get('Id')!=NULL){
                      currentCase=[SELECT Id,AccountId,ContactId,CaseNumber, Status, Description, OwnerId FROM Case  Where Id=:ApexPages.currentPage().getParameters().get('Id')]; 
                        }
                        if(currentCase!=NULL){
                        accountId = currentCase.AccountId;
                        }
     
                     //Constructs query which includes all the fields which are in fieldset
                        String query = 'SELECT ';
                        for(Schema.FieldSetMember f : this.getFields()) {
                        query += f.getFieldPath() + ', ';
                         }
                       query += 'LastViewedDate FROM Asset where  AccountId=:accountId and AccountId!=NULL and Asset_Type__c = \'Parent\' and Status in: filterValues Order by LastModifiedDate Desc ';


                       //If case is having account then get all account related Asset
                      setAsset = new ApexPages.StandardSetController(Database.getQueryLocator(query));

         }
            return setAsset;
        }
        set;
    }

    


}