@isTest
public class BatchProcessQuoteQuickFulfill_Test
{
	public static testmethod void testBatchReal()
    {
        Account parentAccount = TestDataFactory.createAccount('Parent Account1', null, false);
        parentAccount.Primary_Email__c = 'parentAcc@move.com';
        parentAccount.Type = 'Broker';
        parentAccount.Party_ID__c  = '12345';
        parentAccount.Customer_Id__c  = '12345';
        parentAccount.BillingPostalCode  = '12345';
        parentAccount.BillingCity = 'newyork';
        parentAccount.MLS_Set_Id__c  = '12345';
        parentAccount.Account_Sub_Type__c = 'Customer';
      
      	parentAccount.Sales_lock_Date__c = date.today() -1;
      
        insert parentAccount;
        
        
        Set<Id> setAccId = new Set<Id>();
        setAccId.add(parentAccount.Id);
        
        BatchProcessQuoteQuickFulfill batchProcessQuoteQuickFulfill = new BatchProcessQuoteQuickFulfill();
        batchProcessQuoteQuickFulfill.setAccIds = setAccId;
        batchProcessQuoteQuickFulfill.setBMQIds = setAccId;
        Test.startTest();
        Database.executeBatch(batchProcessQuoteQuickFulfill, 1);
        Test.stopTest();
    }
}