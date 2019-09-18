//Name        : ARIIAccountUpdateBatch_Test
//Description : Test class for ARIIAccountUpdateBatch.
//Author      : Pallavi Tammana

@isTest(seeAllData =false)
private class ARIIAccountUpdateBatch_Test{
    static testMethod void method1(){
        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        Schedule_Batch_Setting__c autoacctProcess = new Schedule_Batch_Setting__c(Name = 'Auto Renewal Account Process',Is_Running__c = True);
        insert autoacctProcess;
        
        AR_Account_Renewal_Term__c acctRenew = new AR_Account_Renewal_Term__c(Name = '0', RoundRobin__c = 6);
        insert acctRenew;
        
        Product2 newProduct = new Product2();
        newProduct.Name = 'TestProduct';
        newProduct.Auto_Renewal__c = True;
        newProduct.ProductCode='SHOWCASE' ;
        newProduct.Orderable__c= true;
        newProduct.S_No__c = 3;
        insert newProduct;
        
        Set<Id> acctIdSet = new Set<Id>();
        list<Account> acctListids = new list<Account>();
        
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
            testAccount.Primary_Email__c = 'testAccount@move.com';
            testAccount.Account_Sub_Type__c = 'Customer';
            testAccount.Auto_Renewal__c = true;
            //testAccount.OwnerId = u.Id;
            testAccount.EssentialsStatus__c = 'Activated';
            insert testAccount;
            
        acctIdSet.add(testAccount.Id);
        acctListids.add(testAccount);
        
        Account testAccount1 = TestDataFactory.createAccount('Test Account12',null,false);
            testAccount1.Primary_Email__c = 'testAccount12@move.com';
            testAccount1.Account_Sub_Type__c = 'Customer';
            testAccount1.Auto_Renewal__c = true;
            //testAccount.OwnerId = u.Id;
            testAccount1.EssentialsStatus__c = 'Activated';
            insert testAccount1;
            
        acctIdSet.add(testAccount1.Id);
        acctListids.add(testAccount1);
               
        
         Asset assets1 = new Asset();
            assets1.Name = 'test';
            assets1.Renewal_Status__c = 'Renewed';
            assets1.Auto_Renewal__c = 'Yes';
            assets1.Asset_Type__c = 'Parent';
            assets1.AccountId = testAccount.id;
            assets1.Fulfillment_Status__c = 'Fulfilled';
            assets1.Status = 'Active';
            assets1.Line_Type__c = 'Backout Credit';
            assets1.Billing_Period__c = 'Monthly';
            assets1.Start_Date__c = system.today().addMonths(-1);
            assets1.End_Date__c = System.today().addMonths(2);
            assets1.Product2Id = newProduct.id;
            assets1.Haircut_Asset__c = false;
            assets1.Inflight_Quote__c = null;
            insert assets1;
        
         Asset assets = new Asset();
            assets.Name = 'test';
            assets.Renewal_Status__c = 'Renewed';
            assets.Auto_Renewal__c = 'Yes';
            assets.Asset_Type__c = 'Parent';
            assets.AccountId = testAccount1.id;
            assets.Fulfillment_Status__c = 'Fulfilled';
            assets.Status = 'Active';
            assets.Line_Type__c = 'Backout Credit';
            assets.Billing_Period__c = 'Monthly';
            assets.Start_Date__c = system.today().addMonths(-1);
            assets.End_Date__c = System.today();
            assets.Product2Id = newProduct.id;
            assets.Haircut_Asset__c = false;
            assets.Inflight_Quote__c = null;
            assets.Renewal_Status__c = 'Pending Fulfillment';
            insert assets;
            
         
        
        Test.startTest();
        ARIIAccountUpdateBatch ARAcctBatch = new ARIIAccountUpdateBatch(acctIdSet);       
        Database.BatchableContext bc;             
        ARAcctBatch.start(bc);
        ARAcctBatch.execute(bc,acctListids);
        ARAcctBatch.finish(bc);
          
        Test.stopTest();
        
    
    }
}