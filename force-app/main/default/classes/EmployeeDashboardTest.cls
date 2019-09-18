@isTest
public class EmployeeDashboardTest {
   
    static void init(){
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Collection_Users__c coll = new Collection_Users__c(Name= 'batchintegration user');
        insert coll;
        Collection_Users__c cu = new Collection_Users__c(Name= 'Binder account user', Id__c='005j000000FRRST');
        insert cu;
        Waitlist_Urls__c wlu = new Waitlist_Urls__c(Name='SOAFulfillmentAPIForBinder', URL__c = 'http://abc.com');
        insert wlu;
        Waitlist_Urls__c wlu2 = new Waitlist_Urls__c(Name='EmpDashMfarURL', URL__c = 'http://abc1.com');
        insert wlu2;

        Account mlsAcct = new Account(name ='BINDER1') ;
        mlsAcct.type = 'MLS Account';
        mlsAcct.Customer_Id__c = 'B1CA';
        insert mlsAcct;
      
    }
    
    static testMethod void test1(){
        init();
        test.startTest();
        EmployeeDashboardController.createAccounts('Agent',1,1,1);
        List<Account> offAccts = EmployeeDashboardController.getAllOffices();
        List<Account> offAct = [Select id from Account where Type = 'Realtor Office' limit 1];
        List<Id> offId = new List<Id>();
        for(Account oa: offAccts){
            offId.add(oa.id);
        }
        List<Account> a = EmployeeDashboardController.getAllParentAccounts(false);
        EmployeeDashboardController.getNumberOfAgents(offAct[0].Id);
        EmployeeDashboardController.hasMainAgent();
        List<Id> idList = new List<Id>();
        EmployeeDashboardController.getProducts(idList);
        idList.add(a[0].id);
        EmployeeDashboardController.getAcctsFromIds(idList);
        test.stopTest();
    }
     static testMethod void test2(){
        init();
        test.startTest();
        EmployeeDashboardController.createAccounts('Agent',1,1,1);
        List<Account> offAct = [Select id from Account where Type = 'Realtor Office' limit 1];
        EmployeeDashboardController.addAccount('Agent', offAct[0].id, '1', '1', '1');
        
        test.stopTest();
    }
    
    static testMethod void test3(){
        init();
        test.startTest();
        EmployeeDashboardController.createAccounts('Broker',1,1,1);
        EmployeeDashboardController.fulfillmentReq freq = new  EmployeeDashboardController.fulfillmentReq();
        Id actId = [Select id from Account where Type = 'Broker' limit 1].id;
        freq.accountName = 'testacct1';
        freq.accountId = actId;
        freq.accountType = 'Broker';
        freq.action = 'add';
        freq.co_relation_id = 'test11';
        freq.market = '';
        freq.partNumber = 'BETARESPOND';
        freq.quantity = 10;
        List<EmployeeDashboardController.fulfillmentReq> list1 = new List<EmployeeDashboardController.fulfillmentReq> {freq};
        EmployeeDashboardController.sendToFulfillment1(list1);
        test.stopTest();
    }
    
    static testMethod void test3DeleteJob(){
        init(); 
        List<Account> accs = new List<Account>();
        Account testAccount1 = TestDataFactory.createAccount('Test Account1', null, false);
        testAccount1.Primary_Email__c = 'testAccount@move.com';
        testAccount1.type = 'Broker';
        testAccount1.isBinder__c = true;
        testAccount1.Binder_account_active_till_date__c = date.today();
        
        Account testAccount2 = TestDataFactory.createAccount('Test Account1', null, false);
        testAccount2.Primary_Email__c = 'testAccount@move.com';
        testAccount2.type = 'Realtor Office';
        testAccount2.isBinder__c = true;
        
        accs.add(testAccount1);
        accs.add(testAccount2);
        insert accs;
      
        
        Account_Relationship__c ar = TestDataFactory.createAccountRelationship(testAccount1.id, testAccount2.id, null, null, true, false);
        insert ar;
        
        Test.StartTest();
        EmployeeDashboardController.deleteAll(testAccount1.id, 'broker');
        EmployeeDashboardAccountDeleteJobSch ej = new EmployeeDashboardAccountDeleteJobSch();
        System.schedule('EmployeeDashboardAccountDeleteJob', '0 0 * * * ?', new EmployeeDashboardAccountDeleteJobSch());
        Test.StopTest();
    }
    
}