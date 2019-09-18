/*
    Class: Contact method helper for preference update and so all.
    Created by: Varun Agarwal (Brillio Technologies)
    Created date : 02/12/2019
*/
public with sharing class SFMC_ContactMethodTriggerHelper {
    /*
        Purpose: Method to check if any changes in preference field and if then update same which have same email address.
        Created by : Varun Agarwal (Brillio Technologies) 
    */
    public static void CheckAndUpdatePreferenceOfContactMethod(Map<Id, ContactMethod__c> newContactMethodMap,Map<Id, ContactMethod__c> oldContactMethodMap){
        CheckRecursiveTrigger.executeTriggerOnce = true; //used Move team variable as it is already being used in CM trigger.
        Map<String,ContactMethod__c> preferenceChangesContactMethodMapForEmail = new Map<String,ContactMethod__c>();
        set<id> existingCMIDs = new set<id>(); 
        for(String contactMethodId : newContactMethodMap.keyset()){
            ContactMethod__c newContactMethodObj = newContactMethodMap.get(contactMethodId);
            if(newContactMethodObj.Type__c == SFMC_Constants.TYPE_EMAIL && newContactMethodObj.Email__c != null){
                if(oldContactMethodMap != null){
                    ContactMethod__c oldContactMethodObj = oldContactMethodMap.get(contactMethodId);
                    if(oldContactMethodObj != null){
                        if( oldContactMethodObj.RDC_Event_OptIn__c != newContactMethodObj.RDC_Event_OptIn__c ||
                            oldContactMethodObj.RDC_Info_OptIn__c != newContactMethodObj.RDC_Info_OptIn__c || 
                            oldContactMethodObj.RDC_Promo_OptIn__c != newContactMethodObj.RDC_Promo_OptIn__c ||
                            oldContactMethodObj.TP_Event_OptIn__c != newContactMethodObj.TP_Event_OptIn__c ||
                            oldContactMethodObj.TP_Info_OptIn__c != newContactMethodObj.TP_Info_OptIn__c ||
                            oldContactMethodObj.TP_Promo_OptIn__c != newContactMethodObj.TP_Promo_OptIn__c 
                        ){
                            preferenceChangesContactMethodMapForEmail.put(newContactMethodObj.Email__c,newContactMethodObj);
                            existingCMIDs.add(contactMethodId);
                        }
                    }
                }
            }
        }
        
        if(!preferenceChangesContactMethodMapForEmail.isEmpty()){
            SFMC_ContactMethodTriggerHelper.updatePreferenceForEmail(preferenceChangesContactMethodMapForEmail,existingCMIDs);
        }
    }
    
    /*
        Purpose: Method to update preference which have same email address.
        Created by : Varun Agarwal (Brillio Technologies) 
    */
    public static void updatePreferenceForEmail(Map<String,ContactMethod__c> preferenceChangesContactMethodMapForEmail,set<id> existingCMIDs){
        List<ContactMethod__c> matchesContactMethodList = [select id,RDC_Event_OptIn__c,RDC_Info_OptIn__c,RDC_Promo_OptIn__c,TP_Event_OptIn__c,TP_Info_OptIn__c,TP_Promo_OptIn__c,Email__c From ContactMethod__c where Email__c in: preferenceChangesContactMethodMapForEmail.keyset() And id not in : existingCMIDs AND Type__c =: SFMC_Constants.TYPE_EMAIL];
        if(!matchesContactMethodList.isEmpty()){
            for(ContactMethod__c matchesContactMethodObj : matchesContactMethodList){
                ContactMethod__c existingCMObj = preferenceChangesContactMethodMapForEmail.get(matchesContactMethodObj.Email__c);
                if(existingCMObj != null){
                    matchesContactMethodObj.RDC_Event_OptIn__c = existingCMObj.RDC_Event_OptIn__c;
                    matchesContactMethodObj.RDC_Info_OptIn__c = existingCMObj.RDC_Info_OptIn__c;
                    matchesContactMethodObj.RDC_Promo_OptIn__c = existingCMObj.RDC_Promo_OptIn__c;
                    matchesContactMethodObj.TP_Event_OptIn__c = existingCMObj.TP_Event_OptIn__c;
                    matchesContactMethodObj.TP_Info_OptIn__c = existingCMObj.TP_Info_OptIn__c;
                    matchesContactMethodObj.TP_Promo_OptIn__c = existingCMObj.TP_Promo_OptIn__c;
                }
            }
            
            SFMC_Utility.recordDatabaseErrors(Database.update(matchesContactMethodList,false),'ContactMethod__c','Trigger for update preference of same email address');
        }
    }
    
}