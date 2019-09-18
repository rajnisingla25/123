/*
    Class: Helper class for lead cumulative score calculation batch.
    Created by: Varun
    Created date : 12/20/2018
*/
public with sharing class SFMC_LeadScoreCalculationHelper {
    /*
        Method to fetch leadScoreManageRun custom setting record.
    */
    public static LeadScoreManageRun__c getLeadScoreManageRunRecord(){
        LeadScoreManageRun__c leadScoreManageRunObj = LeadScoreManageRun__c.getInstance(SFMC_Constants.LEAD_SCORE_BATCH);
        if(leadScoreManageRunObj == null){
            leadScoreManageRunObj = new LeadScoreManageRun__c();
            leadScoreManageRunObj.name = SFMC_Constants.LEAD_SCORE_BATCH;                       
        }
        return leadScoreManageRunObj;
    }
      
    /*
        Method to update leadScoreManageRun custom setting record with lastRunDate if no error occur. 
    */
    public static void updateManageRunOnFinish(DateTime lastRunDate,Boolean isAnyError){
        LeadScoreManageRun__c leadScoreManageRunObj = SFMC_LeadScoreCalculationHelper.getLeadScoreManageRunRecord();     
        if(!isAnyError){
            leadScoreManageRunObj.LastRunDate__c = lastRunDate;
        }
        
        if(leadScoreManageRunObj != null){
            upsert leadScoreManageRunObj Name;
        }       
    }
    
    /*
        Method to handle error handling while exception in update called. 
    */
    public static void recordErrors(Database.SaveResult[] SaveResultList,Set<id> allIds){
        //Error__c[] logErrorList = new Error__c[]{};
        List<id> errorIds = new List<id>();
        set<id> successIds = new set<id>();
        for(Database.SaveResult saveResultRecord : SaveResultList){         
            if(saveResultRecord.isSuccess()){               
                successIds.add(saveResultRecord.getId());
            }
        }
        
        if(!allIds.isEmpty() && successIds.size() != allIds.size()){
            for(id recordid:allIds){
                if(!successIds.contains(recordid)){
                    errorIds.add(recordid);
                }
            }
        }
        if(!errorIds.isEmpty()){
            List<Engagement_Activity__c> engagementActivityListForFailureLead = new  List<Engagement_Activity__c>();
            List<Lead> leadFailureRecords =  [select id,(select id from Engagement_Activities__r limit 1) from Lead where id in: errorIds];
            for(Lead leadFailureRecord : leadFailureRecords){
                engagementActivityListForFailureLead.add(leadFailureRecord.Engagement_Activities__r);
            }
            update engagementActivityListForFailureLead;
        }
    
        System.debug('errorIds ' + errorIds);
    }
    public static void checkHeapSize(){
        System.debug('$$ Heap size used ' + Limits.getHeapSize()  + ' from total ' + Limits.getLimitHeapSize());
    }
    /*
        Method to check if heap size is almost full to threshold. 
    */
    public static boolean isHeapSizeLimitThreshold(){
        boolean isThreshold = false;
        if((Limits.getLimitHeapSize() - Limits.getHeapSize()) <= SFMC_Constants.HEAP_LIMIT_THRESHOLD){
            isThreshold = true;
        }
        return isThreshold;
    }
}