/*
Author : Shraddha Kabade
Purpose : Serves as a controller for sd_serviceDashboard's lightning components
JIRA : CRM-2267
*/
public class ServiceDashboardController {
    
    @AuraEnabled
    public static List<Account_Relationship__c> fetchBrokerExclusions(Id recordId){
        Account a = [Select id, type from Account where id = :recordId limit 1];
        Set<String> parentAccounts = new Set<String>();
        if(a.Type == Constants.AGENT_ACCOUNT_TYPE) { 
             for(Account_Relationship__c accountRelationship: [SELECT Parent_Account__c,Active__c FROM Account_Relationship__c
                                          WHERE Child_Account__c =: a.Id AND Parent_Account__r.Type =: Constants.OFFICE_ACCOUNT_TYPE]){
                    System.debug('AGENT ACCOUNT TYPE : '+accountRelationship);
                    if(accountRelationship.Active__c) {                     
                        parentAccounts.add(accountRelationship.Parent_Account__c);
                    }
             } 
        } else if(a.Type == Constants.OFFICE_ACCOUNT_TYPE ){
            parentAccounts.add(a.id);
        }
        
        return  [SELECT Parent_Account__c,Active__c, Parent_Account__r.Exclusion_Notes__c, Parent_Account__r.Sales_Calls__c,
                 Parent_Account__r.Name, Parent_Account__r.Customer_Care_Calls__c, Parent_Account__r.Marketing_Emails__c ,
                 Parent_Account__r.Agent_SLE__c FROM Account_Relationship__c
                 WHERE ((Child_Account__c IN : parentAccounts) AND Active__c = true AND
                        (Parent_Account__r.Type =: Constants.BROKER_ACCOUNT_TYPE OR
                         Parent_Account__r.Type =: Constants.REGION_ACCOUNT_TYPE OR
                         Parent_Account__r.Type =: Constants.BROKERCOUNCIL_ACCOUNT_TYPE OR
                         Parent_Account__r.Type =: Constants.REALESTCORP_ACCOUNT_TYPE OR
                         Parent_Account__r.Type =: Constants.ADAGENCY_ACCOUNT_TYPE OR
                         Parent_Account__r.Type =: Constants.REALESTNETWORK_ACCOUNT_TYPE OR
                         Parent_Account__r.Type =: Constants.CORPORATEGROUP_ACCOUNT_TYPE))];
    }
    @AuraEnabled
    public static Account fetchAccountInfo(Id recordId) {
        system.debug('recordId--->'+recordId);
        return [Select Id,Name,Phone,Email_Address__c,Billing_status__c,Owner.Extension, Rating__c,
                    Owner.name,MLS_Set_Id__c,SSO_Email__c,Advertiserid__c,Type, Party_id__c, ImpersonationLink__c
                    FROM Account WHERE ID =: recordId limit 1];
    }
    
    @AuraEnabled
    public static Account_Relationship__c fetchRelationshipInfo(Id recordId) {
        system.debug('recordId--->'+recordId);
        List<Account_Relationship__c> accRelList = [Select Id,Parent_Account__r.Name, Parent_Account__c
                                                    FROM Account_Relationship__c WHERE Child_Account__c =: recordId and Active__c = true order by Start_Date__c desc, Is_Parent_Primary__c desc];
        if(!accRelList.isEmpty()){
            return accRelList[0];
        }
        return null;
    }
    
    /*
    @AuraEnabled
    public static List<case> fetchCases(Id recordId, String caseStatus){
        Set<String> statusSet = new Set<String>{'Closed','Assets Cancelled', 'Assets Canceled', 'Pending Development'};
        if(caseStatus == 'Closed'){
            return [Select Id, Type, Area__c, Status, SubStatus__c, Sub_area__c, caseNumber,
                          Owner_Name__c, Format(Last_Worked__c) Last_Worked__c, Followup_Status__c, Format(CreatedDate) CreatedDate
                          from Case WHERE accountId =: recordId and status IN ('Closed','Assets Cancelled', 'Assets Canceled', 'Pending Development')];
                
        } else {
           return [Select Id, Type, Area__c, Status, SubStatus__c, Sub_area__c, caseNumber,
                          Owner_Name__c, Format(Last_Worked__c) Last_Worked__c, Followup_Status__c, Format(CreatedDate) CreatedDate
                          from Case WHERE accountId =: recordId and status NOT IN ('Closed','Assets Cancelled', 'Assets Canceled', 'Pending Development')];

        }
    }*/
    
     @AuraEnabled
    public static List<case> fetchOpenCases(Id recordId){
        List<case> lc = [Select Id, Type, Area__c, Status, SubStatus__c, Sub_area__c, caseNumber,
                          Owner_Name__c, Format(Last_Worked__c) Last_Worked__c, Followup_Status__c, Format(CreatedDate) CreatedDate
                          from Case WHERE accountId =: recordId and status NOT IN ('Closed','Assets Cancelled', 'Assets Canceled', 'Pending Development')];
        return lc;
    }

    @AuraEnabled
    public static List<case> fetchIssues(Id recordId){
        List<MLS__c> actMls = [Select Id, Status__c, MLS__c from MLS__c 
                               where Status__c = 'Active' and (Agent__c =: recordId Or Office__c =: recordId) ];
        Set<Id> mlsActSet = new Set<Id>();
        for(MLS__c m: actMls){
            mlsActSet.add(m.MLS__c);
        }
        system.debug('mlsActSet--->'+mlsActSet);
        Id recTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get('Global').RecordTypeId;
        List<case> lc = [Select Id, Type, Area__c, Status, SubStatus__c, Sub_area__c, CaseNumber, Subject, Description, Format(CreatedDate) CreatedDate
                        from Case WHERE accountId IN : mlsActSet and status != 'Closed' and RecordTypeId = :recTypeId and Type = 'MLS Support'];

        return lc;
    }
    
    @AuraEnabled
    public static String fetchSsoDetails(Id recordId){
        Account a = [Select Id, AdvertiserId__c, Type, Party_Id__c from Account where Id =:recordId];
        String endPointUrl = '';
        Waitlist_Urls__c wlu= Waitlist_Urls__c.getValues('GetBrokerSsoDetail');
        if(a.Type != 'Broker'){
            wlu= Waitlist_Urls__c.getValues('GetAgnOffSsoDetail');
        }
        endPointUrl = wlu.URL__c+a.AdvertiserId__c;
        return sendWebserviceCall(endPointUrl, 'GET');
    }
    
    @AuraEnabled
    public static String resetLoginAttempts(String email){
        String endPointUrl = '';
        Waitlist_Urls__c wlu= Waitlist_Urls__c.getValues('ResetSSOAttempts');
        endPointUrl = wlu.URL__c+email;
        return sendWebserviceCall(endPointUrl, 'DELETE');
    }
    
    @AuraEnabled
    public static String releaseEmailForAdvId(String advId){
        String endPointUrl = '';
        Waitlist_Urls__c wlu= Waitlist_Urls__c.getValues('ReleaseSSOEmail');
        System.debug('Anydatatype_msg'+advId);
        endPointUrl = wlu.URL__c+advId;
        //endPointUrl = wlu.URL__c+'1164655';
        return sendWebserviceCall(endPointUrl, 'DELETE');
    }
    
    public static String sendWebserviceCall(String endPointUrl, String method){
        try{
            HttpRequest req = new HttpRequest(); 
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            req.setMethod(method);
            req.setEndpoint(endPointUrl);
            System.debug('endpoint-->>'+endPointUrl);
            req.setHeader('Accept', 'application/json');
            res = http.send(req);
            system.debug('Response --->>'+res.getBody());
            return res.getBody();
        } catch(Exception e){
            System.debug('Exception --->>'+e);
            return null;
        }
         return null;
    }
    
    @AuraEnabled
    public static String fetchListings(Id recordId){
        Account a = fetchAccountInfo(recordId);
        String endPointUrl = '';
        Waitlist_Urls__c wlu= Waitlist_Urls__c.getValues('ListingsAPI');
        endPointUrl = wlu.URL__c.replace('{AdvId}',a.Advertiserid__c);
        return sendWebserviceCall(endPointUrl, 'GET');
    }
}