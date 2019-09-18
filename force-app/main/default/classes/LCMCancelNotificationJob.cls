/**
* Author: Shraddha Kabade
* Purpose: To sent notifications when comarketing relationships are cancelled but account relationship is active
* JIRA : LCM-67, LCM-239
* Test class:LCMRelationshipInformationCntrlTest
**/
public class LCMCancelNotificationJob implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query='Select id,Relationship__c, Relationship__r.Child_account_email__c,Relationship__r.parent_account_email__c from comarketing_relationship__c where Status__c = \'Cancelled\' and Sent_cancellation_email__c = false and Relationship__r.Comarketing_Status__c != \'Cancelled\'';
        system.debug('query'+query);
        return Database.getQueryLocator(query);
    } 
    
    public void execute(Database.BatchableContext BC, List<comarketing_relationship__c> comarRels){
        System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@Batch execute'+comarRels);
        String fromEmail = System.Label.LCMCancelEmailFromAddress;
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = :fromEmail];
        EmailTemplate[] templates = [Select id,name from EmailTemplate where name IN ('LCM Agent Amend Relationship', 'LCM Lender Amend Relationship') limit 2];
        // Get any contact as there are no contact merge fields used in template.
        Contact[] dummyContact = [Select Id From Contact Where Email != null Limit 1];
        Set<String> processedIds = new Set<String>();
        Set<comarketing_relationship__c> updComarSet = new Set<comarketing_relationship__c>();
        List<comarketing_relationship__c> updComarList = new List<comarketing_relationship__c>();
        Set<account_relationship__c> updRelSet = new Set<account_relationship__c>();
        List<account_relationship__c> updRelList = new List<account_relationship__c>();
        for(comarketing_relationship__c crel: comarRels){
             system.debug('processedIds---'+processedIds);
            if(!processedIds.contains(crel.Relationship__c) && crel.Relationship__r.Child_account_email__c != null && crel.Relationship__r.Parent_account_email__c != null){
                //Send different email templates to lender and agent
                
                processedIds.add(crel.Relationship__c);
                for(EmailTemplate et: templates){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                    mail.setTemplateID(et.Id); 
                    mail.setTargetObjectId(dummyContact[0].id);
                    mail.setTreatTargetObjectAsRecipient(false);
                    mail.setSaveAsActivity(false);
                    mail.setWhatId(crel.Relationship__c);
                    if ( owea.size() > 0 ) {
                        mail.setOrgWideEmailAddressId(owea.get(0).Id);
                    }
                    if(et.name == 'LCM Lender Amend Relationship'){
                        mail.setToAddresses(new List<String>{crel.Relationship__r.Child_account_email__c});
                    } else {
                        mail.setToAddresses(new List<String>{crel.Relationship__r.Parent_account_email__c});
                    }
                    
                    Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
                }
            }
            if(processedIds.contains(crel.Relationship__c)){
                crel.Sent_cancellation_email__c = true;
                updComarSet.add(crel);
            }
        }
        for(Id arid : processedIds){
            Account_Relationship__c ar = new Account_Relationship__c();
            ar.id = arid;
            ar.Suppress_Comarketing_Email__c = false;
            ar.Sent_LCM_amend_notification_date__c = datetime.now();
            updRelSet.add(ar);
        }
        if(!updComarSet.isEmpty()){
            updComarList.addAll(updComarSet);
            update updComarList;
        }
        if(!updRelSet.isEmpty()){
            updRelList.addAll(updRelSet);
            update updRelList;
        }
        
    }
    
    public void finish(Database.BatchableContext BC){
        System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@Batch finished');
    }
    
}