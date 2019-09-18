global Class EssentialsComponentController {
    public String conName {get;set;}
    public String accId ;
    
    //CRM-3350: Added getter and setter method to get accountId value.
    public string getaccId(){
        return accId;
    }
    public void setaccId(String value){
        accId = value;   
        ContactName(accId); 
    }
    
    public void ContactName(String accountId){
        system.debug('********************** accountId:'+accountId);
        Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;
        //CRM-3350 Removing extra query for contact record and added Contact_To__r.FirstName.
        List<Account_Relationship__c> arList = [  SELECT Contact_To__c, Contact_To__r.FirstName FROM 
                                                Account_Relationship__c WHERE 
                                                Parent_Account__c =: accountId
                                                AND
                                                RecordTypeId = :contactRelationshipRecordTypeId
                                                AND
                                                Is_Parent_Primary__c =  :True 
                                                limit 1];
        if( arList != null && !arList.isEmpty()){                                                                                                        
                conName = arList[0].Contact_To__r.FirstName;
        }
            System.debug('***************** conName:'+conName);
   }
}