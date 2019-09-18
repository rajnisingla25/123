/********************************************************************************************
*   @Author :       Srinidhi M 
*   @Purpose:       To get Case History of Contact 
*   @Class          Case_History_List
*   @TestClass      Case_History_List_Test
*   @JIRA           
*   @CreatedDate:   May 23rd, 2018
*********************************************************************************************
   JIRA No      Date       Modified By         Description                                Tag No
*********************************************************************************************

*/

public class Case_History_List {
   
    public  Case currentCase{get; set;}
    public  string contactId;
    Public string currentcaseId;
   // public String query{get;set;}
    
     public List<Schema.FieldSetMember> getFields() {
    return SObjectType.Case.FieldSets.CaseHistory_Fields.getFields();
     }

        // Initialize setCon and return a list of records
          public List<Case> getCase() {
              try{
           //Set number of Record to be displayed in a Page
            setCon.setpagesize(10);
            return (List<Case>) setCon.getRecords();
              }
              catch(exception e){                  
                  system.debug('@@ in exception in getCase method'+e.getMessage());
                  return null;
              }
    }

    
    public ApexPages.StandardSetController setCon {
         get {
            if(setCon == null) {
                 CaseConsoleSidebarSetting__c[] settings = CaseConsoleSidebarSetting__c.getall().values();
                 Set<String>filterValues= New Set<String>();
                  //Custom setting to filter records based on Custom field value 
                   for(CaseConsoleSidebarSetting__c cs:settings){
                    if(cs.Case_Status__c!=NULL)
                   //Adds Custom filed Status__c values to filterValues
                  filterValues.add(cs.Case_Status__c);
                 }
                  //Gets the current Case Contact
                currentcaseId=ApexPages.currentPage().getParameters().get('Id');

                if(currentcaseId!=NULL){
                  currentCase=[SELECT Id, ContactId,CaseNumber, Status, Description, OwnerId FROM Case  Where Id=:currentcaseId]; 
                }
                if(currentCase!=NULL){
                contactId = currentCase.ContactId;
                }
                           
                //Constructs query which includes all the fields which are in fieldset
                        String query = 'SELECT ';
                        for(Schema.FieldSetMember f : this.getFields()) {
                        query += f.getFieldPath() + ', ';
                         }
                       query += 'ContactFax FROM Case Where Id!=:currentcaseId and ContactId=:contactId  and ContactId!=NULL and Status in:filterValues  Order by LastModifiedDate Desc ';
                
                   //If case is having contact then get all contact related Cases        
                    setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query));
                
            }
            return setCon;
        }
        set;
    }
  
    

}