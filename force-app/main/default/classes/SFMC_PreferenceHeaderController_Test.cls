@isTest
public class SFMC_PreferenceHeaderController_Test {
    
     @isTest
    static void testPreferenceHeaderController() {
        insert new Business_Unit_From_Domain__c(Name = 'Top Producer');

        String bu = SFMC_PreferenceHeaderController.businessUnit('');
    }

}