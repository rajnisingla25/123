public class createtasksforwaitlist {
    
    @future
    public static void inserttask(string acctid,string notes,string token){
        id rectypid = [SELECT Id FROM RecordType WHERE DeveloperName = 'Waitlist_Notes'].id;
        Task InsertTask             = new Task();
        InsertTask.recordtypeid     = rectypid;
        InsertTask.Subject          = 'Waitlist Notes';
        InsertTask.WhatId           = acctid;    
        InsertTask.Description      = notes;
        InsertTask.OwnerId          = userinfo.getUserId();
        InsertTask.Status           = 'Completed';
        InsertTask.WaitlistGUIID__c = token;
        InsertTask.Priority         = 'Normal';
        insert InsertTask;
    }
}