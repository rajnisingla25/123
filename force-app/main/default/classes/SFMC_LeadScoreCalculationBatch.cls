/*
    Class: Batch class to calculate lead cumulative score. This batch will be call from SFMC_EngagementActivityLeadUpdateBatch.
    Created by: Varun
    Created date : 12/20/2018
*/
public with sharing class SFMC_LeadScoreCalculationBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    private DateTime runBatchTimestamp;
    @TestVisible private boolean isAnyError;
    private boolean isBatchSkipped;
    private boolean isHeapThresholdHit;
                    
    public SFMC_LeadScoreCalculationBatch(){     
        this.isAnyError = false;
        this.isBatchSkipped = false;
        this.isHeapThresholdHit = false;
    }
    /*
    @Purpose: Check if any update happen in EA, if so then fetch corresponding lead for calculation of cumulative score.
    */    
    public Database.QueryLocator start(Database.BatchableContext BC){
        DateTime lastBatchTimestamp; 
        Boolean isRunQueryByTimestamp = false; //variable to determine wether we have to run complete batch or based on last timestamp.
        set<id> leadIds = new set<id>();
        
        //code to determine is there any previous batch still running, if yes then skipped this batch run.
        if([SELECT count() FROM AsyncApexJob WHERE ApexClass.name in : SFMC_Constants.LEAD_SCORE_BATCH_NAME and status in : SFMC_Constants.BATCH_OPEN_STATUSES] > 1){
            isBatchSkipped = true;
            return Database.getQueryLocator([select id from Lead where id = null limit 1]); // no record will return            
        }
        
        //code to check last time stamp.
        LeadScoreManageRun__c leadScoreManageRunObj = SFMC_LeadScoreCalculationHelper.getLeadScoreManageRunRecord();
        lastBatchTimestamp = leadScoreManageRunObj.LastRunDate__c;      
        runBatchTimestamp = System.now();
        
        //code to fetch lead ids from Engagement activity based on last time stamp.
        if(lastBatchTimestamp != null){
            if([SELECT count() FROM Engagement_Activity__c WHERE Lead__c != null And (LastModifiedDate >: lastBatchTimestamp OR Engagement_Activity_Type__r.LastModifiedDate >:lastBatchTimestamp)] < (Limits.getLimitQueryRows() - Limits.getQueryRows() - 1) ){
                isRunQueryByTimestamp = true;
                List<Engagement_Activity__c> engagementActivities = [SELECT Lead__c  FROM Engagement_Activity__c WHERE Lead__c != null And (LastModifiedDate >: lastBatchTimestamp OR Engagement_Activity_Type__r.LastModifiedDate >:lastBatchTimestamp)];
                for(Engagement_Activity__c engagementActivityObj : engagementActivities){
                    leadIds.add(engagementActivityObj.Lead__c);
                }               
            }
        }
        
        List<String> leadOpenStatuses = new List<String>();
        leadOpenStatuses.addAll(SFMC_Constants.LEAD_OPEN_STATUSES);     
        String startQuery = 'select LeadScore__c,id,Last_Engagement_Activity_Date__c,Engagement_Score_Reset_Date__c from Lead Where Status in : leadOpenStatuses ';        
        if(isRunQueryByTimestamp == true){
            startQuery += ' And id in : leadIds ' ;
        }
        System.debug('-->> startQuery = ' + startQuery);
        return Database.getQueryLocator(startQuery);
    }
    /*
    @Purpose: Calculate the EA score of lead.
    */
    public void execute(Database.BatchableContext BC, List<Lead> scopeLeads){
        if(SFMC_LeadScoreCalculationHelper.isHeapSizeLimitThreshold()){
            isAnyError = true;
            isHeapThresholdHit = true;
        }else{
            try{                
                //code to populate existing lead into map.
                Map<Id,Lead> updatedLeadScoreMapForLead = new Map<Id,Lead>();
                Map<id,Lead> existingLeadMapForLeadId = new Map<id,Lead>();
                Map<Id, Lead> engagementScoreResetLeads = new Map<Id, Lead>();
                for(Lead existingLeadObj :scopeLeads){  
                    if (existingLeadObj.Engagement_Score_Reset_Date__c  == null){
                        existingLeadMapForLeadId.put(existingLeadObj.id, existingLeadObj);
                    }else{
                        engagementScoreResetLeads.put(existingLeadObj.id, existingLeadObj);
                    }               
                }
                
                //code to fetch new lead score and populate in updatedLeadScoreMapForLead map for update.
                AggregateResult[] groupedResults = [Select sum(ScoreWithWeightage__c) leadScore,Max(Activity_Date__c) latestActivityDate, Lead__c from Engagement_Activity__c where Lead__c = :existingLeadMapForLeadId.keyset() Group by Lead__c];
                
                for (AggregateResult ar : groupedResults)  {
                    String currentLeadId = String.valueOf(ar.get('Lead__c'));
                    Decimal currentLeadScore = Decimal.valueOf(String.valueOf(ar.get('leadScore') != null ? ar.get('leadScore') : 0.0));
                    Datetime currentLeadLastEADate = Datetime.valueOf(ar.get('latestActivityDate'));
                    if(currentLeadId != null){
                        Lead existingLeadObj  = existingLeadMapForLeadId.get(currentLeadId);
                        if(existingLeadObj != null){
                            Decimal existingLeadScore = existingLeadObj.LeadScore__c != null ? existingLeadObj.LeadScore__c : 0.0; 
                            Boolean isRecordUpdate = false;
                            if(existingLeadScore != currentLeadScore){
                                existingLeadObj.LeadScore__c = currentLeadScore;
                                isRecordUpdate = true;                              
                            }
                            if(existingLeadObj.Last_Engagement_Activity_Date__c != currentLeadLastEADate){
                                existingLeadObj.Last_Engagement_Activity_Date__c = currentLeadLastEADate;
                                isRecordUpdate = true;
                            }
                            if(isRecordUpdate){
                                updatedLeadScoreMapForLead.put(currentLeadId,existingLeadObj);
                            }
                        }
                    }
                }
                List<Engagement_Activity__c> egaLeadsResetDate = [Select ScoreWithWeightage__c, Activity_Date__c, Lead__c,Lead__r.Engagement_Score_Reset_Date__c from Engagement_Activity__c where Lead__c = :engagementScoreResetLeads.keySet()];
                Map<Id,Decimal> leadEngagementScoreMap = new Map<Id,Decimal>();
                Map<Id,DateTime> leadEngagementLastDateMap = new Map<Id,DateTime>();
                for(Engagement_Activity__c ega:egaLeadsResetDate){

                    if(ega.Activity_Date__c>=ega.Lead__r.Engagement_Score_Reset_Date__c){
                        Decimal score = ega.ScoreWithWeightage__c;
                        if(leadEngagementScoreMap.containsKey(ega.Lead__c)){
                            score = score+leadEngagementScoreMap.get(ega.Lead__c);
                        }
                        leadEngagementScoreMap.put(ega.Lead__c,score);
                        DateTime actDate = ega.Activity_Date__c;
                        if(leadEngagementLastDateMap.containsKey(ega.Lead__c)&&leadEngagementLastDateMap.get(ega.Lead__c)>actDate){
                            actDate = leadEngagementLastDateMap.get(ega.Lead__c);
                        }
                        leadEngagementLastDateMap.put(ega.Lead__c,actDate);
                    }
                }

                for(Lead leadObj:engagementScoreResetLeads.values()){
                    Id leadId = leadObj.id;
                    Boolean isRecordUpdate = false;
                    if(leadEngagementScoreMap.containsKey(leadId)&&leadObj.LeadScore__c!=leadEngagementScoreMap.get(leadId)){
                        leadObj.LeadScore__c=leadEngagementScoreMap.get(leadObj.id);
                        isRecordUpdate = true;
                    }
                    if(leadEngagementLastDateMap.containsKey(leadId)&&leadObj.Last_Engagement_Activity_Date__c!=leadEngagementLastDateMap.get(leadId)){
                        leadObj.Last_Engagement_Activity_Date__c=leadEngagementLastDateMap.get(leadObj.id);
                        isRecordUpdate = true;
                    }
                    if (isRecordUpdate){
                        updatedLeadScoreMapForLead.put(leadId,leadObj);
                    }
                }

                if(!updatedLeadScoreMapForLead.isEmpty()){                  
                    SFMC_LeadScoreCalculationHelper.recordErrors(Database.update(updatedLeadScoreMapForLead.values(),false),updatedLeadScoreMapForLead.keyset());
                }           
                    
            }catch(Exception ex){
                isAnyError = true;
                Error__c logError = new Error__c(Entity_Id__c ='Lead score calculation batch', Interface_Name__c = 'Lead score calculation batch', Error_Description__c = ex.getMessage());
                insert logError;
                System.debug('-->> Exception occur with below description = '+ ex.getMessage());            
            }
        }
    }
    /*
    @Purpose: update the custom setting last batch run date.
    */
    public void finish(Database.BatchableContext BC){       
        if(isBatchSkipped || isHeapThresholdHit || isAnyError){
            return;
        }      
                
        SFMC_LeadScoreCalculationHelper.updateManageRunOnFinish(runBatchTimestamp,isAnyError);
        
    }
    
}