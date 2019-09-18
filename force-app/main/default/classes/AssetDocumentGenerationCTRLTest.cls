@istest
public class AssetDocumentGenerationCTRLTest {

    static testmethod void assetDocumentGenerationTest()
    {
        
       DisabledTrigger__c Dtrg = new DisabledTrigger__c();
     Dtrg.TaskTrigger__c = 'datamigration@move.com.sit';
     Dtrg.AssetTrigger__c = 'datamigration@move.com.sit';
     Dtrg.AccountTrigger__c = 'datamigration@move.com.sit';
     Dtrg.Name = 'Disabled';
       insert Dtrg; 
        
         Account theTestAccount = TestDataFactory.createAccount('The Test Account', null, false);
    theTestAccount.Primary_Email__c = 'testEmail1@test.com';
    theTestAccount.Type = Constants.OFFICE_ACCOUNT_TYPE;
    theTestAccount.Account_Sub_Type__c = Constants.ACCOUNT_SUBTYPE_PROSPECT;
        insert theTestAccount;
        Asset a= new Asset(
             Name = 'Test Asset -',
             AccountId = theTestAccount.Id,
             Price = 10,
             End_Date__c = Date.today().addDays(10),
             Auto_Renewal__c = 'No',
             Product_Logins__c='www.login.salesforce.com/',
             Status = 'Active'
            );
 insert a;
        Test.startTest();
        apexpages.currentPage().getParameters().put('parentID',a.id);
        AssetDocumentGenerationCTRL controller = new AssetDocumentGenerationCTRL();
        Test.stopTest();
    }
}