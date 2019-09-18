@IsTest
public class UserTriggerTest {

    public static testMethod void userTriggerTesting() {   
    
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(alias = 'standt', email='standarduser@testorg.com',
                            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                            localesidkey='en_US', profileid = p.Id,timezonesidkey='America/New_York', 
                            username='standarduser1234@test.com',Team__c='Collections Team');
        insert u;
       
        u.lastname='Testing1';
        u.Team__c='WLV Territory Team';       
        try{
            Update u;
        }
        catch(Exception e){}   
        
        /*User uId =[select Id from User where IsActive=true Limit 1];
           User usr =[select Id,Username,LastName,ProfileId from User where Id =: uId.Id];          
           usr.LastName='Test';           
           update usr;
       
        System.runAs(usr) {
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId()); 
        }*/
    }
}