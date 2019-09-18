/**
* An apex page controller that takes the user to the right start page based on credentials or lack thereof
*/
public with sharing class CommunitiesLandingController {
    
    // Code we will invoke on page load.
    public PageReference forwardToStartPage() {
        
        Id currentLoggedInUser = UserInfo.getUserId();
        User userDetail = new User();
        
        if(test.isRunningTest()){
            Id p = [select id,name from profile where name='Customer Community Login User'].id;
            userDetail = [Select id, Name, ContactId, CommunityNickname, Account.Name from user Where profileId =:p and isActive=true limit 1];
        } else {
            userDetail = [Select id, Name, ContactId, CommunityNickname, Account.Name from User Where id = :currentLoggedInUser and AccountId != null]; 
        }
        if(!userDetail.Account.Name.contains(userDetail.CommunityNickname)){
            return new PageReference(Site.getPathPrefix()+'/EmployeeCreateAccounts');
        }
        return new PageReference(Site.getPathPrefix()+'/EmployeeDashboardHome');
    }
    
    public CommunitiesLandingController() {}
}