/********************************************************************************************
*   @Author :       Aparna Shankar(Brillio Technologies) 
*   @Purpose:       Methods and Actions on Engagement Activity custom Object
*   @TestClass      SFMC_EngagementActivityUtils_Test
*   @Class          AccountContactMappingHandler
*   @JIRA           SMCI-52
*   @CreatedDate:   12-13-2018
*********************************************************************************************
   JIRA No      Date       Modified By         Description                                Tag No
***********************************************************************************************
*/
global with sharing class SFMC_EngagementActivityUtils {

    
    @future 
    public static void createEGAforFormSubmission(Set<Id> formObjectIds){

        Boolean isError = false;
        String errMessage = '';
        List<Engagement_Activity__c> egaTobeCreated = new List<Engagement_Activity__c>();
        List<Engagement_Activity__c> egaWithoutAccount = new List<Engagement_Activity__c>();

        
        Map<String,Engagement_Activity_Type__c> eaTypeMap = getEngagementActivityTypes();
        Map<String,Engagement_Activity__c> contactMethodCookieMap = new Map<String,Engagement_Activity__c>();
        if(eaTypeMap.size()==0){
            isError=true;
            errMessage =  errMessage+'Cannot find the Engagement activity type for Form Submission \n';
        }

        List<Form_Submission__c> formObjects = [Select Contact_Method_Id__c,Contact_Id__c,Campaign_Id__c,Lead__c,Product_Type__c, CreatedDate,Email__c,Phone__c,URL__c,Source__c,Form_Type__c,UF_Cookie_ID__c from Form_Submission__c where id in :formObjectIds ]    ;           
        
        Set<Id> contMetIdSet = new Set<Id>();
        
        if(formObjects.size()==0){
            isError=true;
            errMessage =  errMessage+'Cannot find the Form Submission data \n';
        }else{
            Set<Id> cmIdSet = new Set<Id>();
            for(Form_Submission__c fObj : formObjects){
                cmIdSet.add(fObj.Contact_Method_Id__c);
            }

            Map<Id,ContactMethod__c> cmMap = new Map<Id,ContactMethod__c>([Select Contact__c,Contact__r.AccountId from ContactMethod__c where Id in :cmIdSet]);

            for(Form_Submission__c fObj : formObjects){
                System.debug('fObj.Source__c >>>'+fObj.Source__c);
                System.debug('eaTypeMap >>>'+eaTypeMap);
                Engagement_Activity_Type__c eatype = eaTypeMap.get(fObj.Form_Type__c);
                ContactMethod__c cm = cmMap.get(fObj.Contact_Method_Id__c);
                String err = isValidFSObject(eatype,cm,fObj);
                if(err.length()==0){
                    Engagement_Activity__c tempEngagActivity = new Engagement_Activity__c();
                    if(cm.Contact__r.AccountId  != null){
                        tempEngagActivity = createEga(fObj,eatype.Id,cm.Contact__c);
                        egaTobeCreated.add(tempEngagActivity);
                    }
                    else{
                        tempEngagActivity = createEga(fObj,eatype.Id,cm.Contact__c);
                        egaWithoutAccount.add(tempEngagActivity);
                    }
                    if(fObj.Form_Type__c == SFMC_Constants.UBERFLIP_FORM && fObj.Contact_Method_Id__c != null && fObj.UF_Cookie_ID__c != null){
                        contactMethodCookieMap.put(fObj.Contact_Method_Id__c+fObj.UF_Cookie_ID__c, tempEngagActivity);
                        contMetIdSet.add(fObj.Contact_Method_Id__c);
                    }
                }else{
                    errMessage = errMessage+err;
                }
            }

        }

        Database.SaveResult[] results = null;
        try{
            if(!isError&&egaTobeCreated.size()>0){
                                
                results = Database.insert(egaTobeCreated);
            }
            if(!isError&&egaWithoutAccount.size()>0){
                CreateEAWithoutAccountClass objCreateEAWithoutAccountClass = new CreateEAWithoutAccountClass();
                results = objCreateEAWithoutAccountClass.createEAWithoutAccount(egaWithoutAccount);
            }
            recordErrors(results,'Create EngagementActivity from Form Submission',errMessage);

        }catch (Exception e){
            System.debug('A exception occured when the Engagement activity is created :'+e.getStackTraceString());
            System.debug('A exception occured when the Engagement activity is created :'+e.getMessage());
            String errMsg = e.getMessage()+errMessage;
            Error__c errObj = new Error__c(Entity_Id__c ='Engagement_Activity__c', 
                                        Interface_Name__c = 'Create EngagementActivity from Form Submission', 
                                        Error_Description__c = errMsg);
            insert errObj;
                    
        }

    }
    // Create Engagement Activities Without Account
    public without sharing class CreateEAWithoutAccountClass{
        public Database.SaveResult[] createEAWithoutAccount(List<Engagement_Activity__c> eaListWithoutAccount){
           Database.SaveResult[] resultsWithoutAccount = Database.insert(eaListWithoutAccount);
            
            return resultsWithoutAccount;   
        }
    }
    
    private static String isValidFSObject(Engagement_Activity_Type__c eatype,ContactMethod__c cm,Form_Submission__c fObj){
        String error = '';
        if(fObj.Contact_Method_Id__c==null){
            error =  error+'There is no Contact Method Id on the Form Submission for:'+fObj.Id+'\n';
        }
        if(eatype==null){
            error =  error+'There is no Engagement Activity Type identified for the Form Submission :'+fObj.Id+'\n';
        }
        if(cm==null||cm.Contact__c==null){
            error =  error+'Cannot find the contact for the Form Submission :'+fObj.Id+'for the contact method Id:'+fObj.Contact_Method_Id__c+'\n';
        }
        return error;
    }
    private static Map<String,Engagement_Activity_Type__c> getEngagementActivityTypes(){
        Map<String,Engagement_Activity_Type__c> eaTypeMap = new Map<String,Engagement_Activity_Type__c>();
        List<Engagement_Activity_Type__c> eatList = [Select Id,Type__c from Engagement_Activity_Type__c 
                                                        where Channel__c= :SFMC_Constants.ENGAGEMENT_ACTIVITY_TYPE_CHANNEL_FORM_SUBMISSION];
        for(Engagement_Activity_Type__c eaType:eatList){
            eaTypeMap.put(eaType.Type__c, eaType);
        }
        return eaTypeMap;
    }

    private static Engagement_Activity__c createEga(Form_Submission__c fsObject,Id egTypeId,Id contactId){
        Engagement_Activity__c ea = new Engagement_Activity__c();
        ea.Contact_Method__c = fsObject.Contact_Method_Id__c;
        ea.Engagement_Activity_Type__c = egTypeId;
        ea.Contact__c = fsObject.Contact_Id__c ;
        ea.Campaign__c = fsObject.Campaign_Id__c;
        ea.Lead__c = fsObject.Lead__c;
        ea.Product__c = fsObject.Product_Type__c;
        //ea.Product_Type__c = fsObject.Product_Type__c;
        ea.Activity_Date__c = fsObject.CreatedDate;
        ea.Form_Submission_URL__c = fsObject.URL__c;
        ea.Phone__c = fsObject.Phone__c;
        ea.Email__c = fsObject.Email__c;
        ea.Source__c = fsObject.Form_Type__c;
        ea.Cookie_Id__c = fsObject.UF_Cookie_ID__c;
        ea.Lead_Check__c =  true;
        return ea;
    }

    public static void recordErrors(Database.SaveResult[] results,String interfaceName,String errMsg){
        List<Error__c> errList = new List<Error__c>();
        if(errMsg.length()>0){
            Error__c e = new Error__c(Entity_Id__c ='Engagement_Activity__c', Interface_Name__c = interfaceName, Error_Description__c = errMsg);
            errList.add(e);
        }
        if(results!=null){
            for(Database.SaveResult res : results){
                if(!res.isSuccess()){
                    String errorMessage = '';
                    for(Database.Error error : res.getErrors()){
                        errorMessage += error.getMessage() +'\n';
                    }
                    Error__c e = new Error__c(Entity_Id__c ='Engagement_Activity__c', Interface_Name__c = interfaceName, Error_Description__c = errorMessage);
                    errList.add(e);
                }

            }

        }
        
        insert errList;

        System.debug(errList);
    }
    
    public static List<Engagement_Activity__c> createEngagementActivitiesForLeads(Engagement_Activity__c ega,List<Lead> leadList){
        //Skip the last Lead
        List<Engagement_Activity__c> clonedEga = new List<Engagement_Activity__c>();
        for(Lead ld:leadList){
            Engagement_Activity__c newEga = ega.clone();
            newEga.Lead__c = ld.Id;
            newEga.Lead_Check__c = true;
            clonedEga.add(newEga);
        }

        return clonedEga;
    }
    

        
}