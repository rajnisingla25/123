/*
  Class: Batch class to update score corresponding to dormancy. This batch will be schedule once in a day.
  Created by: Varun
  Created date : 12/20/2018
  Modified date : 12/27/2018
  Modified By : Atul Rakate //Added code to schedule batch
*/
public with sharing class SFMC_DormancyScoreCalcBatch implements Database.Batchable<sObject>, Schedulable{
    public Database.QueryLocator start(Database.BatchableContext bc){
        //fetch records whose activity date is less than last 15 days
        return Database.getQueryLocator(
            'SELECT Id, Name, Activity_Date__c, Score__c,Score_Formula__c FROM Engagement_Activity__c WHERE Activity_Date__c <= LAST_N_DAYS:15'
        );
    }
    public void execute(Database.BatchableContext bc, List<Engagement_Activity__c> scope){
        List<Engagement_Activity__c> engagementActivityList = new List<Engagement_Activity__c>();
        List<Engagement_Activity__c> engagementActivityToDelete = new List<Engagement_Activity__c>();
                    
        //Iterate through all the engagement activity records and update them
        for(Engagement_Activity__c objEngagementActivity : scope){
            if(objEngagementActivity.Score__c != objEngagementActivity.Score_Formula__c){
              objEngagementActivity.Score__c = objEngagementActivity.Score_Formula__c;
              engagementActivityList.add(objEngagementActivity);
            }
            if(objEngagementActivity.Activity_Date__c != null){
                Long milliseconds = DateTime.now().getTime() - (objEngagementActivity.Activity_Date__c).getTime();
                Long seconds = milliseconds / 1000;
                Long minutes = seconds / 60;
                Long hours = minutes / 60;
                Long days = hours / 24;
                Long deleteEngagementActAfter = Long.valueOf(Label.Delete_Engagement_Activity_After_Days);
                if(days > deleteEngagementActAfter){
                    engagementActivityToDelete.add(objEngagementActivity);
                }
            }
            
        }
        // update engagement records
        if(!engagementActivityList.isEmpty()){                
            SFMC_Utility.recordDatabaseErrors(Database.update(engagementActivityList, false),'Dormancy score calc batch','Dormancy score calc batch');
        }
        if(!engagementActivityToDelete.isEmpty()){
            Database.DeleteResult[] drList = Database.delete(engagementActivityToDelete, false);
        }

    }

    public void finish(Database.BatchableContext BC){

    }

    public void execute(SchedulableContext SC){
        Database.executeBatch(new SFMC_DormancyScoreCalcBatch(), Integer.valueOf(System.label.Dormancy_Score_Calculation_Batch));
    } 


}