global class BatchProcessUserSalesLockEligibility implements Database.Batchable<sObject>{
global String query;
global Set<Id> userId = new Set<Id>();

    global Database.querylocator start(Database.BatchableContext BC){
        String profilelist =  label.Sales_lock_Profile;
        List<String> setUserProfile = profilelist.split(',');
        Query = 'SELECT   Id,UserName,Name,IsActive,Profile.Name,Vacation_Start_Date__c,Vacation_End_Date__c,Sales_Lock_User__c FROM User where Profile.Name =:setUserProfile';
        if(userId.size()>0){
        Query = Query + ' and id=:userId';
        System.debug('Query  '+Query);
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<User> scope){
       List<User> UserList = new List<User>();
       Set<Id> setIds = new Set<Id>();
       Map<Id,Boolean> mapUseroldSaleLockStatus = new Map<Id,Boolean>();

       Map<Id,String> mapQuotaProfiles = new Map<Id,String>();
        for(User usr : scope){
        mapUseroldSaleLockStatus.put(usr.id,usr.Sales_Lock_User__c);
       if(usr.IsActive ){
       setIds.add(usr.id);
       }
       }
       List<Quota__c> lstQuota = [Select Id,Name,User__c,User_Team__c,Period_Name__c from Quota__c where User__c = :setIds and Period_Name__r.Start_Date__c<=Today and Period_Name__r.End_Date__c>=Today];
       for(Quota__c qt:lstQuota){
       if(qt.User_Team__c =='Collections Team' || qt.User_Team__c =='Retention Team' || qt.User_Team__c =='Managers Team'){
       mapQuotaProfiles.put(qt.User__c,qt.User_Team__c);
       }
       }

       for(User usr : scope){
       if(usr.IsActive){
           usr.Sales_Lock_User__c = true;
           if((usr.Vacation_Start_Date__c<System.Today() && usr.Vacation_End_Date__c>System.Today()) || mapQuotaProfiles.containskey(usr.id)){
           usr.Sales_Lock_User__c = false;
           }
           } else{
           usr.Sales_Lock_User__c = false;

           }
           if(usr.Sales_Lock_User__c!=mapUseroldSaleLockStatus.get(usr.id)){
           UserList.add(usr);
           }

       }
       if(UserList.size()>0){
       SkipUserTrigger.setSkipTrgTrue();
       update UserList ;
       }
    }

    global void finish(Database.BatchableContext BC){
    }
}