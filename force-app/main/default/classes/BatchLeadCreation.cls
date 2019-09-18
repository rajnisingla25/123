public class BatchLeadCreation implements Database.Batchable<sObject>
{
    //Select Id, AccountId__c, First_Name__c, Last_Name__c, Business_Unit__c, Campaign__c, Contact__c, Lead__c, 
    //Email__c, Hot_Lead__c, Ignore_Owner_Assignment__c, Lead_Origin__c, Lead_Owner__c, Company__c, Error_Description__c, 
    //Lead_Source__c, Phone__c, Product_Type__c, Record_Processed__c From Pre_Lead__c Where Record_Processed__c = False
  //Created By Pratik on 17th December 2018 for SFDC Lead Process Enhancements
  String query;
    
    public BatchLeadCreation(String strQuery)
    {
        query = strQuery;
    }
    
    public Database.querylocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<SObject> lstPreLead)
    {
        PreLeadProcess.processPreleadToLead(lstPreLead);
    }

    public void finish(Database.BatchableContext BC)
    {
    }
}