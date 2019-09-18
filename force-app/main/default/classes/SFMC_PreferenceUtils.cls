/********************************************************************************************
*   @Author :       Varun Agarwal(Brillio Technologies) 
*   @Purpose:       Methods and Actions on Contact Method custom Object for preference
*   @TestClass      SFMC_PreferenceUtils_Test
*   @Class          SFMC_PreferenceUtils
*   @JIRA           SMCI-392
*   @CreatedDate:   2-5-2019
*********************************************************************************************
   JIRA No      Date       Modified By         Description                                Tag No
***********************************************************************************************
*/
public with sharing class SFMC_PreferenceUtils {
    /**
     Purpose : update preference field of contact method when form is submission
     created by : Varun 
    **/
    public static void updateContactMethodPreference(set<id> formSubmissionIds){
        if(formSubmissionIds != null && !formSubmissionIds.isEmpty()){
            Map<Id,set<String>> businessUnitMapByContactMethodId = new Map<Id,set<String>>();
            List<Form_Submission__c> formSubmissionObjs = SFMC_PreferenceUtils.getFormSubmissionRecords(formSubmissionIds);
            for(Form_Submission__c formSubmissionObject :formSubmissionObjs){
                if(formSubmissionObject.Contact_Method_Id__c != null && formSubmissionObject.Business_Unit__c != null){
                    set<String> businessUnitLists = new set<String>();
                    if(businessUnitMapByContactMethodId.containskey(formSubmissionObject.Contact_Method_Id__c)){
                        businessUnitLists = businessUnitMapByContactMethodId.get(formSubmissionObject.Contact_Method_Id__c);
                    }
                    businessUnitLists.add(formSubmissionObject.Business_Unit__c);
                    businessUnitMapByContactMethodId.put(formSubmissionObject.Contact_Method_Id__c,businessUnitLists);
                }
            }
            
            if(!businessUnitMapByContactMethodId.isEmpty()){                
                List<ContactMethod__c> contactMethodForUpdate = SFMC_PreferenceUtils.populateContactMethodForEmailUpdate(businessUnitMapByContactMethodId);
                if(!contactMethodForUpdate.isEmpty()){
                    SFMC_Utility.recordDatabaseErrors(Database.update(contactMethodForUpdate,false),'ContactMethod__c','Preference update on FormSubmission');
                }
            }
        }
    }
    /**
     Purpose : get form submission record as per ids
     created by : Varun 
    **/
    public static List<Form_Submission__c> getFormSubmissionRecords(set<id> formSubmissionIds){             
        return [Select Contact_Method_Id__c,Product_Type__c,Business_Unit__c from Form_Submission__c where id in :formSubmissionIds ];
    }
    /**
     Purpose : get Contact Method record as per ids
     created by : Varun 
    **/
    public static List<ContactMethod__c> getContactMethodRecords(set<id> contactMethodIds){
        return [SELECT RDC_Event_OptIn__c,RDC_Info_OptIn__c,RDC_Promo_OptIn__c,TP_Event_OptIn__c,TP_Info_OptIn__c,TP_Promo_OptIn__c,Type__c FROM ContactMethod__c where id in: contactMethodIds];
    }
    /**
     Purpose : populate contact method with updated preference field value. This method is only for Email
     created by : Varun 
    **/
    public static List<ContactMethod__c> populateContactMethodForEmailUpdate(Map<Id,set<String>> businessUnitMapByContactMethodId){
        List<ContactMethod__c> contactMethodObjs = SFMC_PreferenceUtils.getContactMethodRecords(businessUnitMapByContactMethodId.keyset());
        
        List<ContactMethod__c> updatedContactMethods = new List<ContactMethod__c>();
        
        String rdcBUValue = Business_Unit_From_Domain__c.getValues(SFMC_Constants.BUSINESS_UNIT_REALTOR) != null ? Business_Unit_From_Domain__c.getValues(SFMC_Constants.BUSINESS_UNIT_REALTOR).Business_Unit__c : null;
        String tpBUValue = Business_Unit_From_Domain__c.getValues(SFMC_Constants.BUSINESS_UNIT_TOP_PRODUCER) != null ? Business_Unit_From_Domain__c.getValues(SFMC_Constants.BUSINESS_UNIT_TOP_PRODUCER).Business_Unit__c : null ;
        
        for(ContactMethod__c contactMethodObj : contactMethodObjs){
            set<String> businessUnitSet = businessUnitMapByContactMethodId.get(contactMethodObj.id);
            if(contactMethodObj.Type__c == SFMC_Constants.TYPE_EMAIL && businessUnitSet != null && !businessUnitSet.isEmpty()){
                boolean isToBeUpdated = false;
                if(rdcBUValue != null && businessUnitSet.contains(rdcBUValue) && (!(contactMethodObj.RDC_Event_OptIn__c && contactMethodObj.RDC_Info_OptIn__c && contactMethodObj.RDC_Promo_OptIn__c))){
                    contactMethodObj.RDC_Event_OptIn__c = true;
                    contactMethodObj.RDC_Info_OptIn__c = true;
                    contactMethodObj.RDC_Promo_OptIn__c = true;
                    
                    isToBeUpdated = true;
                }
                if(tpBUValue != null && businessUnitSet.contains(tpBUValue) && (!(contactMethodObj.TP_Event_OptIn__c && contactMethodObj.TP_Info_OptIn__c && contactMethodObj.TP_Promo_OptIn__c))){
                    contactMethodObj.TP_Event_OptIn__c = true;
                    contactMethodObj.TP_Info_OptIn__c = true;
                    contactMethodObj.TP_Promo_OptIn__c = true;
                    
                    isToBeUpdated = true;
                }
                
                if(isToBeUpdated){
                    updatedContactMethods.add(contactMethodObj);
                }
            }
        }
        return updatedContactMethods;
    }
        
}