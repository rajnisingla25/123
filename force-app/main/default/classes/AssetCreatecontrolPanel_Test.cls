@isTest
public class AssetCreatecontrolPanel_Test{
    static testMethod void method1(){
         DisabledTrigger__c Dtrg = new DisabledTrigger__c();
         Dtrg.TaskTrigger__c = 'datamigration@move.com.sit';
         Dtrg.AssetTrigger__c = 'datamigration@move.com.sit';
         Dtrg.AccountTrigger__c = 'datamigration@move.com.sit';
         Dtrg.Name = 'Disabled';
         insert Dtrg;
         //Account setup
          List<Account> accountList =new List<Account>();
        Account theTestAccount = TestDataFactory.createAccount('The Test Account', null, false);
        theTestAccount.Primary_Email__c = 'testEmail1@test.com';
        theTestAccount.Type = Constants.OFFICE_ACCOUNT_TYPE;
        theTestAccount.Account_Sub_Type__c = Constants.ACCOUNT_SUBTYPE_PROSPECT;
        //accountList.add(theTestAccount);
    
        test.StartTest();
            insert theTestAccount;
            AssetCreatecontrolPanel asst = new AssetCreatecontrolPanel();
            asst.CustID = 'test'; 
            asst.SFDCAccountID = theTestAccount.id; 
            asst.AccountType = 'test' ;
            asst.BOPCode = '123';                
            asst.ParentAssetId = 'test';
            asst.ProductPartNumber = 'test';
            asst.CDHOrgPartyId = 'test';
        test.StopTest();    
    }
}