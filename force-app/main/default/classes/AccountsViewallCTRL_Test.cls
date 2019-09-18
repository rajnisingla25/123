@isTest
public class AccountsViewallCTRL_Test {

static testMethod void testmethod_one() {
       //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
     Collection_Users__c cur = new Collection_Users__c(Name= 'batchintegration user');
        insert cur;
    Id accountRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Account Relationship').RecordTypeId;
    Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;

    // Inserting account records.
    Account parentAccount = TestDataFactory.createAccount('Parent Account', null, false);
    parentAccount.Primary_Email__c = 'parentAcc@move.com';
    parentAccount.Type = 'Broker';
    parentAccount.Party_ID__c  = '12345';
    parentAccount.Customer_Id__c  = '12345';
    parentAccount.BillingPostalCode  = '12345';
    parentAccount.BillingCity = 'newyork';
    parentAccount.MLS_Set_Id__c  = '12345';    

    
    insert parentAccount;
    
    Account childAccount = TestDataFactory.createAccount('Child Account',null,false);
    childAccount.Primary_Email__c = 'childacc@move.com';    
    childAccount.Type = 'Realtor Office';

    insert childAccount; 
    
    List<Account_Relationship__c> toBeInserted = new List<Account_Relationship__c>();
  
  
    //Create Account Relationship Records for Accounts
    Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship
                                                            (parentAccount.Id, childAccount.Id, null, null, true, false);
    accountRelation.RecordTypeId =  accountRelationshipRecordTypeId;
    accountRelation.Active__c = true;
    accountRelation.Is_Parent_Primary__c = true; 
    insert accountRelation;

        PageReference pageRef = Page.AccountsViewall;
        pageRef.getParameters().put('accid', String.valueOf(parentAccount.ID));
        Test.setCurrentPage(pageRef);
        
        accountsViewallCTRL testaccCTRL = new accountsViewallCTRL();  
        testaccCTRL.deleteRecordId = accountRelation.Id; 
        testaccCTRL.deleteRecord();         
        testaccCTRL.cancel();         
        testaccCTRL.ExportToExcel();         




}
}