@IsTest(seeAllData=true)
//@IsTest
public class Z_SuspendandResumeSubscriptionstest {
    static testMethod void testmethodone() {
        Account sfdcAccount = Z_LegacyTestFactory.makeAccount();
        Contact testContact = Z_LegacyTestFactory.makeContact(sfdcAccount);
        Zuora__CustomerAccount__c billingAccount = Z_LegacyTestFactory.makeBillingAccount(sfdcAccount);
        
         Product2 theTestProduct         = new Product2(
          Name                          = 'Connection(SM) for Co-Brokerage',
          Family                        = 'Hardware',
          S_No__c                       = 2,
          ProductCode                   = 'COBROKE'
        );
        insert theTestProduct;
        
        Asset myAsset = new Asset();
        myAsset.Name = 'test asset';
        myAsset.AccountId =sfdcAccount.Id;     
        myAsset.Fulfillment_Status__c = 'Success';
        myAsset.Asset_Type__c = 'Parent';
        myAsset.Product2ID   = theTestProduct.Id;
        myAsset.ContactId = testContact.Id;
        myAsset.Subscription_Id__c = '323232323232323232323232323';
        insert myAsset;
        List<Zuora__Subscription__c> subs = new List<Zuora__Subscription__c>();
        Zuora__Subscription__c zuoraSub = new Zuora__Subscription__c();
        zuoraSub.Name = 'Test';
        zuoraSub.Zuora__Account__c =  sfdcAccount.Id;
        zuoraSub.Zuora__SubscriptionStartDate__c = system.Today(); 
        zuoraSub.Zuora__SubscriptionEndDate__c = system.Today();  
        zuoraSub.Zuora__NextRenewalDate__c  = system.Today(); 
        zuoraSub.Zuora__Status__c = 'Active';
        zuoraSub.Status__c = 'Processing';
         zuoraSub.Zuora__TermSettingType__c = 'TERMED';
        zuoraSub.Zuora__TermStartDate__c = system.today().addDays(2);
        zuoraSub.Zuora__TermEndDate__c = system.today().addDays(9);
        zuoraSub.Asset__c = myAsset.Id; 
        zuoraSub.AssetID__c = myAsset.Id;
        subs.add(zuoraSub);
              
        Zuora__Subscription__c zuoraSub2 = new Zuora__Subscription__c();
        zuoraSub2.Name = 'Test2';
        zuoraSub2.Zuora__Account__c =  sfdcAccount.Id;
        zuoraSub2.Zuora__SubscriptionStartDate__c = system.Today(); 
        zuoraSub2.Zuora__SubscriptionEndDate__c = system.Today();  
        zuoraSub2.Zuora__Status__c = 'Active';
        zuoraSub2.Status__c = 'Processing';
        zuoraSub2.Zuora__NextRenewalDate__c  = system.Today();  
        zuoraSub2.Zuora__TermStartDate__c = system.today().addDays(2);
        zuoraSub2.Zuora__TermEndDate__c = system.today().addDays(9);
        zuoraSub2.Asset__c = myAsset.Id; 
        zuoraSub2.AssetID__c = myAsset.Id;
        subs.add(zuoraSub2);
        insert subs;
        
        
         Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtId = AccountRecordTypeInfo.get('Service Request').getRecordTypeId();
        
        CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Lead Suspension' , Record_Type_Id__c = rtId);
        insert setting;
        case cse = new case();
        cse.AccountId  = sfdcAccount.Id;
        cse.recordTypeId = rtId;
        cse.Status = 'New';
        cse.Origin = 'Web';
        cse.Type = 'Lead Suspension';
        cse.Subject = '1st Invoice did not Collect on Asset';
        cse.CreatedDate  = System.today();     
        
        insert cse;
         String Efctdate = String.valueof(system.today());
        String Action = 'SuspendSubscription';
        String Fieldvalue = sfdcAccount.id;
      // Z_SendamendmentstoZuoraJob obj = new Z_SendamendmentstoZuoraJob('SELECT Id,Name ,Zuora__Status__c , Zuora__Account__r.name, Zuora__Account__c ,Asset__c ,Zuora_Comment__c ,Zuora__CustomerAccount__c  ,Zuora__TermEndDate__c  ,Zuora__TermStartDate__c  ,Zuora__Zuora_Id__c  FROM Zuora__Subscription__c Where Zuora__Account__c = \'' +  Fieldvalue.trim() + '\' and Status__c = \'Processing\'',Efctdate,Action ,cse.CaseNumber);
        Z_SendamendmentstoZuoraJob obj = new Z_SendamendmentstoZuoraJob('SELECT Id,Name ,Zuora__Status__c , Zuora__Account__r.name, Zuora__Account__c ,Asset__c ,Zuora_Comment__c ,Zuora__CustomerAccount__c  ,Zuora__TermEndDate__c  ,Zuora__TermStartDate__c  ,Zuora__Zuora_Id__c  FROM Zuora__Subscription__c Where Zuora__Status__c = \'Cancelled\' LIMIT 1',Efctdate,Action ,cse.CaseNumber);
        
        test.startTest();
        DataBase.executeBatch(obj);
        Test.setCurrentPageReference(new PageReference('Page.ManageSubscription'));
        System.currentPageReference().getParameters().put('id', cse.Id);
        
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(subs);
        stdSetController.setSelected(subs);
        
        Z_SuspendandResumeSubscriptions ext = new Z_SuspendandResumeSubscriptions();  
        ext.Autoapplycreditbalance =true;
        ext.Selectall = true;
        ext.orderByColumn = 'Name';
        ext.Ascdesc = 'ASC';
        ext.getTotalPages();
        ext.save();
        ext.ReturntoCase();
        ext.getthevalues();
        ext.previous(); 
        ext.first(); 
        ext.last(); 
        ext.next(); 
        ext.refreshPageSize();
        ext.hasNext = false;
        ext.hasPrevious = false;
        ext.pageNumber  =20;
        ext.Suspend();
        ext.Resume();
        ext.updateZuoraAccount();
        
        Z_amendsubscription.amendSubscription('', new Map<String, Object>{'Name'=>'test'});
        test.stopTest();
        
    }
}