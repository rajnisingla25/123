@isTest
public class CPQHeatMapController_Test {
    public Static testMethod void method1(){
        boolean isInsert = true;
        boolean isUpdate = true;
        boolean isDelete = true;
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg; 
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
            testAccount.Primary_Email__c = 'testAccount@move.com';
            testAccount.ShippingState  = 'CA';
            testAccount.ShippingCountry  = 'USA';
            testAccount.Party_ID__c = '11158132';
            testAccount.ShippingPostalCode = '28546';
        insert testAccount;
        BigMachines__Configuration_Record__c  b = new BigMachines__Configuration_Record__c();
            b.BigMachines__bm_site__c = 'devmoveinc';
            b.bigMachines__action_id_copy__c = '36244038';
            b.BigMachines__action_id_open__c = '36244076' ;
            b.BigMachines__document_id__c = '36244074';
            b.BigMachines__process__c = 'oraclecpqo';
            b.BigMachines__process_id__c = '36244034';
            b.BigMachines__version_id__c = '36324104';  
        insert b;    
        
        Test.Starttest();
              PageReference pageRef = Page.CPQHeatMap;
              Test.setCurrentPage(pageRef);
              ApexPages.StandardController stdController = new ApexPages.StandardController(testAccount);
              CPQHeatMapController ext = new CPQHeatMapController (stdController);
        Test.Stoptest();
    }
}