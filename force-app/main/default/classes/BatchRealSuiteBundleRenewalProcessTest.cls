@isTest
public class BatchRealSuiteBundleRenewalProcessTest
{
    public static testmethod void testBatchReal()
    {
        MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
        DisabledTrigger__c Dtrg = mtduc.CreateDisabledTriggerSingle();
        
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
        
        
        map<Id,Id> mapAccountIds = new map<Id,Id>();
        mapAccountIds.put(parentAccount.Id, parentAccount.Id);
        
        mtduc.newAccount = parentAccount;
        Product2 newProduct = mtduc.CreateProductSingle();  
        
        Asset assets = mtduc.CreateFullfilledAssetSingle();
        
        List<Asset> theTestAssets = new List<Asset>();
    	for(Integer index = 0; index < 5; index++)
        {
            theTestAssets.add(new Asset(
             Name = 'Test Asset - ' + index,
             AccountId = parentAccount.Id,
             Asset_Type__c='Parent',
             Get_CP_Login_Status__c = 'Ready',
             Fulfillment_Status__c = 'Fulfilled'
            ));
        }
        
     	insert theTestAssets;
        
        BatchRealSuiteBundleRenewalProcess batch = new BatchRealSuiteBundleRenewalProcess(mapAccountIds);
        batch.setProductCodeAmend.add(newProduct.ProductCode);
        batch.setProductCodeAdd.add(newProduct.ProductCode);
        Test.startTest();
        
        Database.executeBatch(batch, 1);
        List<CreateWaitlistQuoteWrapper> lstCreateWaitlistQuoteWrapper = new List<CreateWaitlistQuoteWrapper>();
        BatchRealSuiteBundleRenewalProcess.InsertOpportunity(lstCreateWaitlistQuoteWrapper, parentAccount);
        
        Test.stopTest();
    }
}