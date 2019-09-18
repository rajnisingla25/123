@isTest
public class CollectionCasesBatch_Test {
public static testMethod void mainTest() {

            // Inserting Test Account.
        Account theAccount = TestDataFactory.createAccount('The Test Account', null, false);
        theAccount.Primary_Email__c = 'hsingh@appirio.com';
        theAccount.Type = 'Broker';
        theAccount.Customer_Care_Calls__c = 'Yes';
        theAccount.Sales_Calls__c = 'Yes';
        theAccount.Marketing_Emails__c = 'Yes';
        theAccount.Agent_SLE__c = 'Yes';
        theAccount.Exclusion_Notes__c = 'Test Exclusion Notes.';

        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'test@test.com');
        insert Dtrg;
        insert theAccount;

        Zuora__ZInvoice__c inv = new Zuora__ZInvoice__c();
        inv.Name = 'TestInv';
        inv.Zuora__Status__c = 'Past Due';
        inv.Zuora__Account__c = theAccount.Id;
        inv.Zuora__DueDate__c = System.today().adddays(-5);
        inv.Zuora__Balance2__c = 5;
        inv.Invoice_Status__c = 'Cancelled';
        //inv.Days_Past_Due__c = 6;
         
        Insert Inv;
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtId = AccountRecordTypeInfo.get('Collections').getRecordTypeId();
        CaseRecordTypes__c settings = new CaseRecordTypes__c(Name = 'Collection' , Record_Type_Id__c = rtId);
        insert settings;
        
        Profile p = [select id from profile where name='System Administrator'];
        User user1 = Commissions_TestDataFactory.createUser(null,p.id,null,'test154@move.com','test154@move.com',true,'Collection Team');
        
        AccountTeamMember at =new AccountTeamMember();
        at.AccountId= theaccount.id;
        at.UserId=user1.id;
        at.TeamMemberRole = 'Collection rep';
        insert at;
        
        CollectionCasesBatch co = new CollectionCasesBatch();
        Test.startTest();
            Database.executeBatch(co,200);
        Test.stopTest();  

}
}