@isTest
public class Commissions_UserTriggerHandler_Test {
    public static testMethod void mainTest1() {    
        Map<id,User> NewUserMaps = new Map<id,User>();
        Map<id,User> OldUserMaps = new Map<id,User>();    
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(alias = 'standt', email='standarduser@testorg.com',
                            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                            localesidkey='en_US', profileid = p.Id,timezonesidkey='America/New_York', 
                            username='standarduser465@test.com',Team__c='Collections Team');
        insert u;
        //u.lastname='Testing';
        //u.Team__c='Collections Team';  
        OldUserMaps.put(u.id , u);
        system.debug('OldUserMaps :'+OldUserMaps);        
        u.lastname='Testing1';
        u.Team__c='WLV Territory Team';       
        try{
            Update u;
        }
        catch(Exception e){}
        NewUserMaps.put(u.id , u);        
        Commissions_UserTriggerHandler sit = new Commissions_UserTriggerHandler();
        sit.TeamChange(NewUserMaps,OldUserMaps); 
    }    
}