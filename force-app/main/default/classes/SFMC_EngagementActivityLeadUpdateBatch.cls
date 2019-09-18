/*
    Batch class: SFMC_EngagementActivityLeadUpdateBatch
    Purpose: Engagement Activity to be associate with Lead.
    Created by: Aparna (Brillio Technologies)
    Created date : 1/4/2018
*/
global with sharing class SFMC_EngagementActivityLeadUpdateBatch implements Database.Batchable<sObject>,Schedulable {
    
    String query;
    private boolean isBatchSkipped;
    
    global SFMC_EngagementActivityLeadUpdateBatch() {
        this.isBatchSkipped = false;
    }
    
    /*        
        Purpose: Start method of Batch, To fetch All EA which is not associate to lead        
    */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //code to determine is there any previous batch still running, if yes then skipped this batch run.
        if([SELECT count() FROM AsyncApexJob WHERE ApexClass.name in: SFMC_Constants.LEAD_SCORE_BATCH_NAME and status in : SFMC_Constants.BATCH_OPEN_STATUSES] > 1){
            isBatchSkipped = true;
            return Database.getQueryLocator([select id from Engagement_Activity__c where id = null limit 1]); // no record will return          
        }
        // Adding all the fields that need to be present when cloned 
        query='Select Contact_Method__c,Product__c,Campaign__r.Target_Product__c,Campaign__c,Campaign__r.Target_Account_Type__c,Lead_Check__c,Contact__c, Source__c,Name__c,Email__c,Activity_Date__c,Email_Subject__c,Engagement_Activity_Type__c, Journey_Id__c,Journey_Name__c,Mobile_Message_Tracking_ID__c from Engagement_Activity__c where Lead_Check__c = false and Contact_Method__c != null';
        if(Test.isRunningTest()){
           query = query+' LIMIT 200';
        }
        return Database.getQueryLocator(query);

    }
    /*        
        Purpose: Associate EA which lead        
    */
    global void execute(Database.BatchableContext BC, List<Engagement_Activity__c> scope) {
        // Collect Contact method ids
        List<Engagement_Activity__c> engagementActivityList2Upsert = new List<Engagement_Activity__c>();
        Set<Id> contactMethodIds = new Set<Id>();
        for(Engagement_Activity__c egActivity:scope){
            contactMethodIds.add(egActivity.Contact_Method__c);
        }

        // Collect all the leads with the contact method Ids
        Map<Id,List<Lead>> cmLeadMap = new Map<Id,List<Lead>>();
        Set<String> marketingLeadTypesToBeExcluded = new Set<String>{SFMC_Constants.MLT_EVENT, SFMC_Constants.MLT_AUTO_RENEW};

        //Get only the open leads with the contact method Id
        for(Lead l:[Select Id,Contact_Method__c,Account_Type__c 
                            from Lead 
                            where Contact_Method__c in :contactMethodIds 
                            and Status in :SFMC_Constants.LEAD_OPEN_STATUSES
                            AND Marketing_Lead_Type__c NOT IN: marketingLeadTypesToBeExcluded
                            AND RecordType.Name=:SFMC_Constants.LEAD_RECORD_TYPE_RDC]){
            List<Lead> lList =  new List<Lead>();
            if(cmLeadMap.containsKey(l.Contact_Method__c)){
                lList = cmLeadMap.get(l.Contact_Method__c);
            }
            lList.add(l);
            cmLeadMap.put(l.Contact_Method__c,lList);
        }

        for(Engagement_Activity__c egActivity:scope){
            if(egActivity.Product__c == null && egActivity.Campaign__c != null){
                egActivity.Product__c = egActivity.Campaign__r.Target_Product__c;
            }
            
            if(egActivity.Contact_Method__c!= null && cmLeadMap.containsKey(egActivity.Contact_Method__c)){
                List<Lead> leadList = cmLeadMap.get(egActivity.Contact_Method__c);
                if(leadList.size()==1){
                    egActivity.Lead__c = leadList.get(0).Id;
                }else{

                    // Handle case when there are more than one lead associated with the contact method Id
                    Integer countBasedOnType = 0;
                    List<Lead> leadsWithSameType = new List<Lead>();
                    if(egActivity.Campaign__c!=null && egActivity.Campaign__r.Target_Account_Type__c!=null){
                        if(egActivity.Campaign__r.Target_Account_Type__c == SFMC_Constants.TARGET_ACCOUNT_TYPE_AGENT){
                            
                            for(Lead ld:leadList){
                                if(ld.Account_Type__c == SFMC_Constants.ACCOUNT_TYPE_AGENT){
                                    countBasedOnType++;
                                    leadsWithSameType.add(ld);
                                }
                            }
                        }else{
                            for(Lead ld:leadList){
                                if(ld.Account_Type__c != SFMC_Constants.ACCOUNT_TYPE_AGENT){
                                    countBasedOnType++;
                                    leadsWithSameType.add(ld);
                                }
                            }

                        }
                    }
                    /*
                    for(Lead ld:leadList){
                        if(ld.Lead_Target_Account_Type__c == egActivity.Campaign__r.Target_Account_Type__c){
                            countBasedOnType++;
                            leadsWithSameType.add(ld);
                        }
                        
                    }
                    */
                    if(leadsWithSameType.size()>0){
                        egActivity.Lead__c = leadsWithSameType.remove(countBasedOnType-1).Id;
                        if(countBasedOnType>1){ 
                            engagementActivityList2Upsert.addAll(SFMC_EngagementActivityUtils.createEngagementActivitiesForLeads(egActivity,leadsWithSameType));
                        }
                    }else{
                        egActivity.Lead__c = leadList.remove(leadList.size()-1).Id;
                        engagementActivityList2Upsert.addAll(SFMC_EngagementActivityUtils.createEngagementActivitiesForLeads(egActivity,leadList));
                    }
                }

            }
            egActivity.Lead_Check__c=true;
        }

        engagementActivityList2Upsert.addAll(scope);


        //Save and Handle errors
        
        List<Database.UpsertResult> results = Database.upsert( engagementActivityList2Upsert, false );
        //List<
        for(Database.UpsertResult theResult:results) {
            if(!theResult.isSuccess()){
                String errMsg='';
                List<Database.Error> errors = theResult.getErrors();
                for(Database.Error theError:Errors) {
                    errMsg+=theError.getMessage() +'\n';
                }
            }

        }
        // Record Errors
        

    }
    /*        
        Purpose: Finish method to call lead EA scoring batch        
    */
    global void finish(Database.BatchableContext BC) {
        if(isBatchSkipped||Test.isRunningTest()){
            return;
        }
        Database.executeBatch(new SFMC_LeadScoreCalculationBatch(), Integer.valueOf(System.label.Lead_Cumulative_Score_Batch_Size));
        
    }
    /*        
        Purpose: scheduler execute method to run batch.        
    */
    public void execute(SchedulableContext SC){
        Database.executeBatch(new SFMC_EngagementActivityLeadUpdateBatch(), Integer.valueOf(System.label.Lead_Cumulative_Score_Batch_Size));
    }
}