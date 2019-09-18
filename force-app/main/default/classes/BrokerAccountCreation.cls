// Extension Class Name: BrokerAccountCreation
// For Apex Page: BrokerAccountCreation
// Description: This extension class is used to create Broker Account using custom Utils class.
//
// 16th June 2015    Rao Move.com

public with sharing class BrokerAccountCreation {
    public Account acc {get;set;}
    public Id Id {get; set;}
    
    
    public BrokerAccountCreation(ApexPages.StandardController controller) {
        acc = (Account)controller.getRecord();
        Id = acc.Id;
    }

    public PageReference brokerAccCreate() {
        String id1 = 'id =\'' + Id + '\'';
        String soql = Utils.getCreatableFieldsSOQL('Account', id1 );
        Account ac1 = (Account)Database.query(soql);
        Account ac2 = ac1.clone(false, true);
        ac2.Name = ac1.Name + '-Broker';
        ac2.Type = 'Broker';
        ac2.Party_ID__c=ac2.Customer_Id__c=ac2.Broker_NAR_Id__c=ac2.Account_NAR_Id__c=ac2.MLS_Set_Id__c=ac2.Ship_To_External_Id__c=ac2.Bill_To_External_Id__c=ac2.website_row_id__c=ac2.Fax_Row_Id__c = '';  
        ac2.MLS_Brokerage_Id__c= ac1.MLS_Set_Id__c;
        insert ac2; 
        ac1.Parent_Broker__c = ac2.Id;
        update ac1;
        List<Account_Relationship__c> AccRelationships = [Select Active__c, Child_Account__c, Contact_Role__c,Is_Parent_Primary__c,Relationship_Type__c, Contact_To__c FROM Account_Relationship__c WHERE Parent_Account__c =:Id AND Relationship_Type__c = 'Contact'];
        system.debug('Contact relations: ' + AccRelationships);
        Id RecordTypeId = Schema.SObjectType.Account_Relationship__c.getRecordTypeInfosByName().get('Account Relationship').getRecordTypeId();
        Id ContactRecordTypeId = Schema.SObjectType.Account_Relationship__c.getRecordTypeInfosByName().get('Contact Relationship').getRecordTypeId();
      
        for(Account_Relationship__c AR : AccRelationships){
            Account_Relationship__c newBrokerRel = new Account_Relationship__c (Contact_To__c=AR.Contact_To__c,Contact_Role__c=AR.Contact_Role__c,Is_Parent_Primary__c=AR.Is_Parent_Primary__c, Is_Sent_to_CDH__c=false, Parent_Account__c=ac2.Id, Relationship_Type__c='Contact', Active__c=AR.Active__c, RecordTypeId=ContactRecordTypeId);
            insert newBrokerRel;          
        }    
        Account_Relationship__c newBrokerRel = new Account_Relationship__c (Child_Account__c=ac1.Id,Is_Parent_Primary__c=true, Is_Sent_to_CDH__c=false, Parent_Account__c=ac2.Id, Relationship_Type__c='Parent/Child', Active__c=true);
        insert newBrokerRel;
        PageReference pageRef = new PageReference('/'+ac2.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
 
}