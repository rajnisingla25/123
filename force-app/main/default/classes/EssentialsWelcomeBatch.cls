global class EssentialsWelcomeBatch implements Database.Batchable<sObject>, Schedulable {

    
    global Database.QueryLocator start(Database.BatchableContext BC) {

        return Database.getQueryLocator([ SELECT  Id, Name, EssentialsStatus__c FROM Account WHERE EssentialsStatus__c = 'Activated' AND Type = 'Broker']);
    }
    
    
    global void execute(Database.BatchableContext BC, List<Account> accountsInScope) {
        Set<id> setEssAccIds = new set<Id>();
        Set<id> setconIds = new set<Id>();
        Map<Id, String> conEmailMap = new Map<Id, String>();
        System.debug('accountsInScope:'+accountsInScope);
        try{
            List<Asset> assList = new List<Asset>([Select Id, AccountId, Product2.EssentialsRequired__c from Asset 
                               where Product2.EssentialsRequired__c = true AND AccountId In :accountsInScope]);
            System.debug('assList:'+assList);
                for(Asset ass : assList) {
                    setEssAccIds.add(ass.AccountId);
                }                
           System.debug('setEssAccIds:'+setEssAccIds);
           if(!setEssAccIds.isEmpty()) {
               string RecordTypId = [SELECT id from RecordType where Name ='Contact Relationship'].Id;
               List<Account_Relationship__c> arList = new List<Account_Relationship__c>([Select Id, Contact_To__c, Parent_Account__c, Parent_Account__r.Email_Address__c from Account_Relationship__c 
                                           where Is_Parent_Primary__c = true and Active__c = true and RecordTypeId = :RecordTypId 
                                           and (Billing_Contact__c = true or Contact_Role__c = 'Primary Contact') AND Parent_Account__c IN:setEssAccIds]);
                   for(Account_Relationship__c ar : arList) {
                       setconIds.add(ar.Contact_To__c);
                       conEmailMap.put(ar.Contact_To__c, ar.Parent_Account__r.Email_Address__c);
                   }
               List<Contact> conList = new List<Contact>([Select Id, Email from Contact where Id IN:setconIds]);                     
               EmailTemplate Emailtemplate=[SELECT Id, Name FROM EmailTemplate where name=:'Essentials Welcome Email Onetime'];
               System.debug('Emailtemplate:'+Emailtemplate);
               System.debug('conList:'+conList);
               List<Messaging.SingleEmailMessage>  listESSEmails = new List<Messaging.SingleEmailMessage>();
               for(Contact con : conList) {
                   System.debug('con:'+con);                  
                   Messaging.SingleEmailMessage essEmail = new Messaging.SingleEmailMessage();
                   String[] toAddresses = new String[] {conEmailMap.get(con.Id)};
        		   essEmail.setToAddresses(toAddresses);
                   essEmail.setTargetObjectId(con.Id);
                   essEmail.setTreatTargetObjectAsRecipient(false);
                   essEmail.setTemplateId(Emailtemplate.id);
                   listESSEmails.add(essEmail);       
               }
               Messaging.SendEmailResult [] res = Messaging.sendEmail(listESSEmails);
           }
        
        }catch(Exception e){
            system.debug( 'Exception: '+e.getStackTraceString());
        }
    
    }
    
    
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new EssentialsWelcomeBatch(), 200);
    }
    
    global void finish(Database.BatchableContext BC){
     }

}