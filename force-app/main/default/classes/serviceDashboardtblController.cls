/*
Author : Srinivas Vadla
Purpose : Serves as a controller for serviceDashboardtable lightning component
JIRA : CRM-2266
*/
public class serviceDashboardtblController {
@AuraEnabled
    public static list <Case> fetchcaseInfo(string message) {
        List<case> caseList = new List<case>();
          if(message == 'New Issues'){
              system.debug('message value : '+message);
              caseList= [SELECT Id,Type,Area__c,Sub_Area__c,CaseNumber,JiraCaseNumber__c, 
                             Subject,Priority,Child_cases__c,Status,Case_Age__c,SubStatus__c,
                             CreatedDate,Date_of_Last_Added_Child_Case__c,Description
                             FROM Case 
                             WHERE recordtype.name = 'Global'
                             AND Status != 'Closed'
                             AND TYPE IN ('Resolution','MLS Support')
                             ORDER BY CreatedDate DESC LIMIT 20];
         
          }
          else if(message == 'Top Issues'){
              system.debug('message value : '+message);
              caseList= [SELECT Id,Type,Area__c,Sub_Area__c,CaseNumber,JiraCaseNumber__c,
                             Subject,Priority,Child_cases__c,Status,Case_Age__c,SubStatus__c,
                             CreatedDate,Date_of_Last_Added_Child_Case__c,Description
                             FROM Case 
                             WHERE recordtype.name = 'Global'
                             AND TYPE IN ('Resolution','MLS Support')
                             AND Top_Issue__c = TRUE
                             AND Status != 'Closed'
                             ORDER BY Priority_Number__c ASC,  Child_cases__c DESC LIMIT 500];
              }
          else if(message == 'Known Issues'){
              system.debug('message value : '+message);
              caseList= [SELECT Id,Type,Area__c,Sub_Area__c,CaseNumber,JiraCaseNumber__c,
                             Subject,Priority,Child_cases__c,Status,Case_Age__c,SubStatus__c,
                             CreatedDate,Date_of_Last_Added_Child_Case__c,Description
                             FROM Case 
                             WHERE recordtype.name = 'Global'
                             AND Status != 'Closed'
                             AND TYPE IN ('Resolution','MLS Support')
                             ORDER BY Type DESC, Area__c ASC, Sub_Area__c ASC LIMIT 500];
          }
    
          else if(message == 'Resolved Issues'){
              system.debug('message value : '+message);
              caseList= [SELECT Id,Type,Area__c,Sub_Area__c,CaseNumber,JiraCaseNumber__c,
                             Subject,Priority,Child_cases__c,Status,Case_Age__c,SubStatus__c,
                             CreatedDate,Date_of_Last_Added_Child_Case__c,Description
                             FROM Case 
                             WHERE recordtype.name = 'Global'
                             AND Status = 'Closed'
                             AND TYPE IN ('Resolution','MLS Support')
                             ORDER BY ClosedDate DESC LIMIT 100];
          }
      system.debug('caseList size'+caseList.size());
      return caseList;
    }
@AuraEnabled
     public static List < String > getselectOptions(sObject objObject, string fld) {
      system.debug('objObject --->' + objObject);
      system.debug('fld --->' + fld);
      List < String > allOpts = new list < String > ();
      // Get the object type of the SObject.
      Schema.sObjectType objType = objObject.getSObjectType();
     
      // Describe the SObject using its object type.
      Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
     
      // Get a map of fields for the SObject
      map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
     
      // Get the list of picklist values for this field.
      list < Schema.PicklistEntry > values =
       fieldMap.get(fld).getDescribe().getPickListValues();
     
      // Add these values to the selectoption list.
      for (Schema.PicklistEntry a: values) {
       allOpts.add(a.getValue());
      }
      system.debug('allOpts ---->' + allOpts);
      //allOpts.sort();
      return allOpts;
     }
}