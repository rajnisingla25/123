/*
Added - LEAP#3336
Owner - Ravinder Reddy
Created - 08/17/2015 */

public with sharing class AccountsViewallCTRL {

public string accID {get;set;}
public Id deleteRecordId {get; set;}
public string accName {get;set;}
public list<Account_Relationship__c> accRelationList {get;set;}
public accountsViewallCTRL()
{
    accRelationList = new list<Account_Relationship__c>();
    accId = ApexPages.currentPage().getParameters().get('accid');
    if(!String.isempty(accId))
    accName = MakeValidFileName([SELECT ID,Name FROM Account WHERE ID=: accID].Name);
    populatedata();
}

public static string MakeValidFileName(string name)
    {
        system.debug('****'+name.replaceAll('\\W', ''));
        return name.replaceAll('\\W', ' ');
    }
    
public void populatedata()
{
    if(!string.isEmpty(accId)){
     accRelationList = [SELECT ID,Child_Account__c,Child_Account__r.Party_ID__c,Child_Account__r.Green__c,Child_Account__r.Red_score__c,Child_Account__r.Yellow_score__c,Child_Account__r.Type,Child_Account__r.MLS_Set_Id__c,Child_Account__r.Phone,Child_Account__r.Email_Address__c,Relationship_Type__c,Child_Account__r.BillingStreet,Child_Account__r.BillingCity,Child_Account__r.BillingState,Child_Account__r.BillingPostalCode,Child_Account__r.BillingCountry,Active__c,Is_Active__c FROM Account_Relationship__c WHERE Parent_Account__c =: accId AND RecordType.DeveloperName = 'Account_Relationship' order by Name asc limit 49999];
    }
    
}
public void deleteRecord()
{
        //Delete the selected object
        for(Account_Relationship__c obj : accRelationList ){
            if(obj.id == deleteRecordId){
                delete obj;
                break;              
            }
}
}
        

public pageReference cancel()
{
    
    return new PageReference('/'+accID);
}

public pageReference  ExportToExcel(){
    return new PageReference('/apex/accountExportToExcel?accID='+accID);
}

}