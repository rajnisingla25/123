global with sharing class WebServiceExecutePreLeadBatches{
   WebService static string ExecuteProfitProcessData(){
    string q = 'Select Id, AccountId__c,Account__c, First_Name__c, Last_Name__c, Business_Unit__c, Campaign__c, Contact__c, Lead__c, Email__c, Hot_Lead__c, Ignore_Owner_Assignment__c, Lead_Origin__c, Lead_Owner__c, Company__c, Error_Description__c,Lead_Source__c, Phone__c, Product_Type__c, Record_Processed__c,Record_Type_Id__c ,Campaign_Name__c,Referring_Agent_PartyId__c,Referring_Agent_Email__c,Referring_Agent_Name__c,Referring_Agent_Phone__c From Pre_Lead__c Where Record_Processed__c = False';
     BatchLeadCreation b = new BatchLeadCreation(q);
        ID batchprocessid=Database.executeBatch(b,30); 
        return batchprocessid;
   }
}