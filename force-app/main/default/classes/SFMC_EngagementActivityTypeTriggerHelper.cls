/*
    class: SFMC_EngagementActivityTypeTriggerHelper.
    Purpose: Helper class for EngagementActivityType Trigger
    Created by: Varun
    Created date : 1/4/2018
*/
public with sharing class SFMC_EngagementActivityTypeTriggerHelper {
    /*
        Method : checkForLeadScoreCalBatch.
        Purpose: Check if any score value changes, if so then update/call lead scoring batch.
        Created by: Varun
        Created date : 1/4/2018
    */
    public static void checkForLeadScoreCalBatch(Map<id,Engagement_Activity_Type__c> oldMap, Map<id,Engagement_Activity_Type__c> newMap){
        boolean isBatchCallForLeadScore = false;
        for(id recordId : oldMap.keyset()){
            Engagement_Activity_Type__c oldRecord = oldMap.get(recordId);
            Engagement_Activity_Type__c newRecord = newMap.get(recordId);
            //check only when dormancy score/weightage/score is changes.
            if(oldRecord.Score__c != newRecord.Score__c || oldRecord.Weightage__c != newRecord.Weightage__c || oldRecord.Dormancy_Score_After_15_Days__c != newRecord.Dormancy_Score_After_15_Days__c
            || oldRecord.Dormancy_Score_After_30_Days__c != newRecord.Dormancy_Score_After_30_Days__c || oldRecord.Dormancy_Score_After_60_Days__c != newRecord.Dormancy_Score_After_60_Days__c ){
                isBatchCallForLeadScore = true;
                break;
            }
        }
        
        if(isBatchCallForLeadScore){
            //code to check active batch limit exceed. If not then run lead scoring batch.
            if([SELECT count() FROM AsyncApexJob WHERE ApexClass.name in : SFMC_Constants.LEAD_SCORE_BATCH_NAME and status in : SFMC_Constants.BATCH_OPEN_STATUSES] == 0){
                if([SELECT count() FROM AsyncApexJob WHERE JobType= : SFMC_Constants.BATCH_APEX AND status in : SFMC_Constants.BATCH_OPEN_STATUSES] < 5){
                    system.debug('-->> lead score batch called');
                    Database.executeBatch(new SFMC_LeadScoreCalculationBatch(), Integer.valueOf(System.label.Lead_Cumulative_Score_Batch_Size));
                }
            }
        }
    }
}