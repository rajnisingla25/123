/*
Class: SFMC_PreferenceCenterController.
Purpose: Fetch and save preference on contactMethod record.
Created by: Varun
Created date : 12/31/2018
*/
public with sharing class SFMC_PreferenceCenterController {
    
    /*
	* Modified by:	Sarang D
	* Purpose:		Replaced ACP references with Contact method.
	*/
    @AuraEnabled
    public static ContactMethod__c getPreferenceRecord(Id contactMethodId){
        if(contactMethodId != null){
            String survivorContactMethodId = SFMC_Utility.checkAndGetLatestContactMethodId(contactMethodId);
            System.debug('-->> survivorContactMethodId = ' + survivorContactMethodId);
            if(survivorContactMethodId != null){
	            List<ContactMethod__c> cmObjList = [select id,Email__c,RDC_Promo_OptIn__c,RDC_Info_OptIn__c,RDC_Event_OptIn__c,TP_Promo_OptIn__c,TP_Info_OptIn__c,TP_Event_OptIn__c from ContactMethod__c where id = :survivorContactMethodId and Type__c =: SFMC_Constants.TYPE_EMAIL and Active__c = true];
	            if(!cmObjList.isEmpty()){
	                return cmObjList.get(0);
	            }    		
            }
        }
        return null;
    }
    
    @AuraEnabled
    public static boolean savePreferenceRecord(Id contactMethodId, String brandType,Boolean optInForInformational, Boolean optInForPromotional, Boolean optInForEvents){
        boolean isRecordSave = false;
        boolean isOptOut = false;
        
        system.debug('optInForEvents : ' + optInForEvents);
        
        if(brandType != null){
            List<ContactMethod__c> updatecontactMethodObjList = new List<ContactMethod__c>();
            if(contactMethodId != null){
                List<ContactMethod__c> contactMethodObjList = [select id,RDC_Promo_OptIn__c,RDC_Info_OptIn__c,RDC_Event_OptIn__c,TP_Promo_OptIn__c,TP_Info_OptIn__c,TP_Event_OptIn__c,Email__c from ContactMethod__c where id = :contactMethodId];
                if(!contactMethodObjList.isEmpty()){
                    ContactMethod__c contactMethodObj = contactMethodObjList.get(0);	    			                    
                    
                    if(brandType.equalsIgnoreCase(SFMC_Constants.REALTOR_COM)){
                        contactMethodObj.RDC_Promo_OptIn__c = optInForInformational;
                        contactMethodObj.RDC_Info_OptIn__c = optInForPromotional;
                        contactMethodObj.RDC_Event_OptIn__c = optInForEvents;
                        
                    }else if(brandType.equalsIgnoreCase(SFMC_Constants.TOP_PRODUCER)){
                        contactMethodObj.TP_Promo_OptIn__c = optInForInformational ;
                        contactMethodObj.TP_Info_OptIn__c = optInForPromotional;
                        contactMethodObj.TP_Event_OptIn__c = optInForEvents;
                    }
                    
                    updatecontactMethodObjList.add(contactMethodObj);    				
                    
                    
                    if(!updatecontactMethodObjList.isEmpty()){
                        isRecordSave = SFMC_PreferenceCenterController.recordErrors(Database.update(updatecontactMethodObjList,false));
                    }
                }    		
            }
        }
        return isRecordSave;
    }
    
    /*
     * Created by:	Sarang D
     * Description:	To save preferences set by Data steward from lightning community page for both TP and RDC.
     * Params:		Contact method Id and preferences for RDC and TP.
	*/
    @AuraEnabled
    public static boolean saveDataStewardPreferenceRecord(Id contactMethodId,Boolean optInForRDCInformational, Boolean optInForRDCPromotional,Boolean optInForRDCWebinars,Boolean optInForTPInformational, Boolean optInForTPPromotional,Boolean optInForTPWebinars){
        boolean isRecordSave = false;
        List<ContactMethod__c> updatecontactMethodObjList = new List<ContactMethod__c>();
        if(contactMethodId != null){
            List<ContactMethod__c> contactMethodObjList = [select id,RDC_Promo_OptIn__c,RDC_Info_OptIn__c,RDC_Event_OptIn__c,TP_Promo_OptIn__c,TP_Info_OptIn__c,TP_Event_OptIn__c,Email__c from ContactMethod__c where id = :contactMethodId];
            if(!contactMethodObjList.isEmpty()){
                ContactMethod__c contactMethodObj = contactMethodObjList.get(0);	    			
                
                
                contactMethodObj.RDC_Promo_OptIn__c = optInForRDCInformational;
                contactMethodObj.RDC_Info_OptIn__c = optInForRDCPromotional;
                contactMethodObj.RDC_Event_OptIn__c = optInForRDCWebinars;
                contactMethodObj.TP_Promo_OptIn__c = optInForTPInformational;
                contactMethodObj.TP_Info_OptIn__c = optInForTPPromotional;
                contactMethodObj.TP_Event_OptIn__c = optInForTPWebinars;
                
                
                updatecontactMethodObjList.add(contactMethodObj);    		
                
                if(!updatecontactMethodObjList.isEmpty()){
                    isRecordSave = SFMC_PreferenceCenterController.recordErrors(Database.update(updatecontactMethodObjList,false));
                }
            }    		
        }
        return isRecordSave;
    }
    
    
    private static boolean recordErrors(Database.SaveResult[] results){
        List<Error__c> errorList = new List<Error__c>();
        Boolean isCompleteRecordSave = true;
        if(results!=null){
            for(Database.SaveResult res : results){
                system.debug('res : ' + res);
                if(!res.isSuccess()){
                    isCompleteRecordSave = false;
                    String errorMessage = '';
                    for(Database.Error error : res.getErrors()){
                        errorMessage += error.getMessage() +'\n';
                    }
                    Error__c e = new Error__c(Entity_Id__c =res.getId(), Interface_Name__c = 'Preference Center opt in/out', Error_Description__c = errorMessage);
                    errorList.add(e);
                }
            }
        }
        
        insert errorList;
        return isCompleteRecordSave;
    }
	
    /*
	* Created by:	Atul Rakate
	* Purpose:		Get currently logged in user type
	*/
    @AuraEnabled
    public static String getUserType(Id userId){
        User u;
        String userType;
        if(userId != null){
            u = [SELECT UserType,Profile.Name FROM User WHERE Id =:  userId];
            Data_Stewerds_and_Pref_Center_Profile__mdt  dataStewardPrefSetting = new Data_Stewerds_and_Pref_Center_Profile__mdt();
            dataStewardPrefSetting = [SELECT MasterLabel, QualifiedApiName, Accessible_Profiles__c FROM Data_Stewerds_and_Pref_Center_Profile__mdt limit 1];
            if(dataStewardPrefSetting != null){
                List <String> profileList = dataStewardPrefSetting.Accessible_Profiles__c.split(',');
                if(profileList.contains((String)u.Profile.Name)){
                    userType = 'Standard';
                }
            }
            
        }
        else{
            userType = 'Guest';
        }
        return userType;
    }

    @AuraEnabled
    public static String getBusinessUnit(String communityDomain){
        String bu;
        List<Business_Unit_From_Domain__c> settings = Business_Unit_From_Domain__c.getall().values();
       for(Business_Unit_From_Domain__c obj : settings){
            if(communityDomain.equals(obj.Community_URL__c)){
                bu = obj.Business_Unit__c;
            }
       }
        return bu;
    }
}