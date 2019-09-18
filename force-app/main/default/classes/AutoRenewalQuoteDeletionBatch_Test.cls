//Name        : AutoRenewalQuoteDeletionBatch_Test
//Description : Test Class for AutoRenewalQuoteDeletionBatch.
//Author      : Pallavi Tammana

@isTest(seeAllData =false)
private class AutoRenewalQuoteDeletionBatch_Test{
    static testMethod void method1(){
    
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',QuoteTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;

        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
        testAccount.Primary_Email__c = 'testAccount@move.com';
        testAccount.Account_Sub_Type__c = 'Customer';
        testAccount.Auto_Renewal__c = true;
        insert testAccount;       
            
        Set<Id> bmqIdSet = new Set<Id>();
        list<BigMachines__Quote__c> bmqListids = new list<BigMachines__Quote__c>();
        
        BigMachines__Quote__c quoteauto = new BigMachines__Quote__c();
        quoteauto.BigMachines__Account__c = testAccount.Id;        
        quoteauto.BigMachines__Status__c = 'In Progress';
        quoteauto.BigMachines_Quote_Type__c = 'Auto-Renew';
        quoteauto.Name = '2020-201345';
        insert quoteauto;
        
        BigMachines__Quote__c quoteauto1 = new BigMachines__Quote__c();
        quoteauto1.BigMachines__Account__c = testAccount.Id;        
        quoteauto1.BigMachines__Status__c = 'In Progress';
        quoteauto1.BigMachines_Quote_Type__c = 'Auto-Renew';
        quoteauto1.Name = '2020-201346';
        insert quoteauto1;
        
        bmqIdSet.add(quoteauto.Id);
        bmqListids.add(quoteauto);
        
        bmqIdSet.add(quoteauto1.Id);
        bmqListids.add(quoteauto1);
               
        Test.startTest();
        AutoRenewalQuoteDeletionBatch arqdb = new AutoRenewalQuoteDeletionBatch(bmqIdSet);
        Database.BatchableContext bc;             
        arqdb.start(bc);
        arqdb.execute(bc,bmqListids);
        arqdb.finish(bc);         
        Test.stopTest();
    
    }
}