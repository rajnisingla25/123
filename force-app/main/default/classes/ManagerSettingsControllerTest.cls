@isTest(seeAllData=true)
public class ManagerSettingsControllerTest {

    static testMethod void ManageUserTest(){
        profile u =[select id from profile where name='Dev System Admin'];
        User theUser = new User(
            ProfileId = u.id,
            Alias = 'theUser',
            Email = 'test@move.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'First',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuser@move.com'
    );
        insert theuser;
        system.runAs(theuser){
            
            ManagerSettingsController controller = new ManagerSettingsController();
            controller.changeProfile();
            controller.setToDefault();
        }
    }
}