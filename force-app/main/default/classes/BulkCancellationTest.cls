@isTest(seeAllData =false)
public class BulkCancellationTest {
    public static testMethod void main() {
        DisabledTrigger__c Dtrg = new DisabledTrigger__c();
        Dtrg.Name = 'Disabled';
        Dtrg.TaskTrigger__c = 'Test@test.com';
        Dtrg.AssetTrigger__c = 'Test@test.com';
        insert Dtrg;
        
        MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
        Account newAccount = mtduc.CreateBrokerAccountSingle();
        Product2 newProduct = mtduc.CreateProductSingle();
        newProduct.EssentialsRequired__c = True;
        update newProduct;
        mtduc.CreatePricebookEntrySingle();   
        List<Asset> assets = new List<Asset>();
        Asset asset1 = new Asset();
        asset1.Name = 'test';        
        asset1.Asset_Type__c = 'Parent';
        asset1.AccountId = newAccount.id;
        asset1.Product2Id = newProduct.id;
        asset1.Fulfillment_Status__c = 'Fulfilled';
        asset1.Status = 'Active';        
        asset1.Start_Date__c = system.today();
        asset1.End_Date__c = system.today().addDays(10);
        asset1.Asset_Type__c = 'Parent';  
        asset1.Auto_Renewal__c = 'Yes';  
        asset1.Renewal_Status__c='Pending Fulfillment'; 
        assets.add(asset1);   
        
        Asset asset2 = new Asset();
        asset2.Name = 'test';        
        asset2.Asset_Type__c = 'Parent';
        asset2.AccountId = newAccount.id;
        asset2.Product2Id = newProduct.id;
        asset2.Fulfillment_Status__c = 'Fulfilled';
        asset2.Status = 'Cancelled';        
        asset2.Start_Date__c = system.today();
        asset2.End_Date__c = system.today().addDays(10);
        asset2.Asset_Type__c = 'Parent';  
        asset2.Auto_Renewal__c = 'Yes';   
        assets.add(asset2);
        
        Asset asset3 = new Asset();
        asset3.Name = 'test';        
        asset3.Asset_Type__c = 'Parent';
        asset3.AccountId = newAccount.id;
        asset3.Product2Id = newProduct.id;
        asset3.Fulfillment_Status__c = 'Fulfilled';
        asset3.Status = 'Active';        
        asset3.Start_Date__c = system.today();
        asset3.End_Date__c = system.today().addDays(10);
        asset3.Asset_Type__c = 'Parent';  
        asset3.Auto_Renewal__c = 'Yes';  
        asset3.Inflight_Quote__c = 'Renew'; 
        assets.add(asset3);
        insert assets;
        
        Asset asset4 = new Asset();
        asset4.Name = 'test';        
        asset4.Asset_Type__c = 'Fulfill To';
        asset4.AccountId = newAccount.id;
        asset4.Product2Id = newProduct.id;
        asset4.Fulfillment_Status__c = 'Fulfilled';
        asset4.Status = 'Active';        
        asset4.Start_Date__c = system.today();
        asset4.End_Date__c = system.today().addDays(10);
        asset4.Asset_Type__c = 'Parent';  
        asset4.Auto_Renewal__c = 'Yes';  
        asset4.Renewal_Status__c='Pending Fulfillment'; 
        asset4.Total_Net__c=0;
        asset4.Parent_Asset__c = asset1.Id;
        insert asset4;
        
        Asset asset5 = new Asset();
        asset5.Name = 'test';        
        asset5.Asset_Type__c = 'Fulfill To';
        asset5.AccountId = newAccount.id;
        asset5.Product2Id = newProduct.id;
        asset5.Fulfillment_Status__c = 'Fulfilled';
        asset5.Status = 'Active';        
        asset5.Start_Date__c = system.today();
        asset5.End_Date__c = system.today().addDays(10);
        asset5.Asset_Type__c = 'Parent';  
        asset5.Auto_Renewal__c = 'Yes';  
        asset5.Renewal_Status__c='Pending Fulfillment'; 
        asset5.Total_Net__c=0;
        asset5.Parent_Asset__c = asset4.Id;
        insert asset5;
        
        List<Bulk_Process__c> recs = new List<Bulk_Process__c>();
        Bulk_Process__c rec1 = new Bulk_Process__c(Asset__c=asset1.Id, Account__c=newAccount.Id, Renewal_Clearance_Status__c='New');
        recs.add(rec1);
        Bulk_Process__c rec2 = new Bulk_Process__c(Asset__c=asset2.Id, Account__c=newAccount.Id, Renewal_Clearance_Status__c='New');
        recs.add(rec2);
        Bulk_Process__c rec3 = new Bulk_Process__c(Asset__c=asset3.Id, Account__c=newAccount.Id, Renewal_Clearance_Status__c='New');
        recs.add(rec3);
        
        insert recs;
        BulkCancellationScheduler p = new BulkCancellationScheduler();
        String sch = '0 0 2 * * ?';
        test.StartTest();
        system.schedule('BulkCancellation', sch, p);
        test.StopTest();
    }
}