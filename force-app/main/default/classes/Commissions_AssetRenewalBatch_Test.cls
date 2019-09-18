@isTest(seeAllData = false)
public class Commissions_AssetRenewalBatch_Test{
    public static testMethod void mainTest() {
        Profile p = [select id from profile where name='System Administrator'];
        User user1 = Commissions_TestDataFactory.createUser(null,p.id,null,'test154@move.com','test154@move.com',true,'Collection Team');
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg; 
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        Account Acc = Commissions_TestDataFactory.createAccount('Name','theAcc@move.com',rectypidaccount,type,true);
        
        Product2 prod = Commissions_TestDataFactory.CreateProduct('Name',true);         
        id rectypidasset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        
        Asset assets = new Asset();
        assets.RecordTypeId = rectypidasset;
        assets.Name = 'test';
        assets.Ownerid=user1.id;
        assets.Renewal_Status__c = 'Renew';
        assets.Auto_Renewal__c = 'No';
        assets.Asset_Type__c = 'Constants.ASSET_TYPE';
        assets.Product2Id = prod.id;
        assets.Fulfillment_Status__c = 'Constants.FULFILLMENT_STATUS';
        assets.Status = 'Constants.ACTIVE_STATUS';
        assets.At_Risk__c = false;
        assets.Billing_Period__c = 'Monthly';
        assets.Start_Date__c = system.today();
        assets.End_Date__c = system.today().addDays(10);
        assets.Asset_Type__c = 'Parent';
        assets.Auto_Renewal__c  = 'Yes';
        assets.Line_Type__c = 'renew';
        assets.Price = 10.00;
        assets.Sign_in_AE__c=user1.id;
        assets.Commission_field__c='ignore';
        insert assets;
        
        List<Zuora__ZInvoice__c> invoices = new List<Zuora__ZInvoice__c>();
        Zuora__ZInvoice__c inv = new Zuora__ZInvoice__c();
        inv.Name = 'TestInv';
        inv.Zuora__Status__c = 'Paid';
        inv.Zuora__Account__c = Acc.Id;
        insert inv; 
        
        List<Zuora__Subscription__c> Subscriptions = new List<Zuora__Subscription__c>();
        Zuora__Subscription__c sub = new Zuora__Subscription__c();
        sub.Name = 'Test';
        sub.Zuora__Account__c = acc.id;        
        sub.Zuora__SubscriptionStartDate__c = system.Today();  
        sub.Zuora__SubscriptionEndDate__c = system.Today();  
        sub.Zuora__NextRenewalDate__c  = system.Today();    
        sub.Asset__c = assets.id;       
        insert sub;
        
                  
           
        List<Invoice_Item__c > invoiceitems = new List<Invoice_Item__c >();   
        Invoice_Item__c invitem = new Invoice_Item__c();
        invitem.Name = 'Test';
        invitem.Invoice__c = inv.id;
        invitem.Subscription__c = sub.id;
        invoiceitems.add(invitem);
        insert invoiceitems;
        
        Commissions_AssetRenewalBatch co = new Commissions_AssetRenewalBatch ();
        Test.startTest();
            Database.executeBatch(co,200);
        Test.stopTest();  
    }
}