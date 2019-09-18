/*
	Class: SFMC_PreferenceHeaderController.
	Purpose: Controller method for datastedward and preference 
	Created by: Atul (Brillio)
	Created date : 12/02/2018
*/
public with sharing class SFMC_PreferenceHeaderController {
    //Set Business unit value from custom settings
    @AuraEnabled
    public static String businessUnit(String pageURL){
        List<Business_Unit_From_Domain__c> settings = Business_Unit_From_Domain__c.getall().values();
        String bu;
        for(Business_Unit_From_Domain__c obj : settings){
            if(pageURL.equals(obj.Community_URL__c)){
                bu = obj.Business_Unit__c;
            }
        }
        return bu;
    }
}