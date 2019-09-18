trigger UserTrigger on User (Before update,After update) {
//Commissions_UserTriggerHandler Us = new Commissions_UserTriggerHandler();
    if(!SkipUserTrigger.skiptrigger){
    if(Trigger.isbefore){
         if(Trigger.IsUpdate){
           //  Us.TeamChange(Trigger.NewMap,Trigger.OldMap);
         }
    }  
    
    if(Trigger.IsAfter && Trigger.IsUpdate){
    String userName = UserInfo.getUserName();
    if(userName.contains('internalsystem.user@move.com') || Test.isRunningTest()){
    BatchProcessUserSalesLockEligibility bpul = new BatchProcessUserSalesLockEligibility();
    bpul.userId.addall(Trigger.NewMap.keyset());
    Database.executeBatch(bpul);
    SkipUserTrigger.setSkipTrgTrue();
    }
    }
    }
}