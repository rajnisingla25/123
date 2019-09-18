//
// (c) 2015 Appirio, Inc.
//
// Apex Test Class Name: AccountTrigger_Test
// For Testing: AccountTrigger.trigger, AccountTriggerHandler.cls and AccountTriggerHandlerManager.cls
//
// 8th April 2015     Kirti Agarwal           (Task # T-376543)
//
@isTest
private class AccountTrigger_Test {

    private static final Integer COUNTER = 5;
    private static Id b2bRecordTypeId;
    private static Id b2cRecordTypeId;
    static testMethod void accountCDHWebService_Test() {
	
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        List<Account> theAccounts = new List<Account>();
        Account theAccount;
        for(Integer index = 0; index < COUNTER; index++) {
                theAccount = TestDataFactory.createAccount(
                'The Test Account' + index,
                null,
                false
              );
            theAccount.Primary_Email__c =  'testEmail'+index+'@testClass.com';
            theAccounts.add(theAccount);
        }
        insert theAccounts;

        Integer i = 0;
        for(Account acc : theAccounts){
            if(i == 0) {
                acc.Home_Phone__c = '7943693';
            }else if(i == 1) {
                acc.Advertiser_Email__c = 'test@test.com';
            }
            else if(i == 2) {
                acc.ShippingStreet = 'shipping test';
            }
            else if(i == 3) {
                acc.BillingStreet = 'billing test';
            }
            else if(i == 4) {
                acc.Name = 'test name';
            }
            i++;
        }
        update theAccounts;      
    }
    
    static testMethod void testAgentBrokerAssociation(){
           //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
       List<Account> theAccounts = new List<Account>();
       Account theAccount;
       Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
       Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
       for(Integer i=0;i<2;i++) {
             theAccount = TestDataFactory.createAccount(
                          'The Test Account' + i,
                          null,
                          false
             );
       theAccount.RecordTypeId = AccountRecordTypeInfo.get('B2B').getRecordTypeId();
       theAccount.Primary_Email__c =  'testEmail'+i+'@b2b.com';
       theAccount.Agent_Broker__c = true;
       theAccount.Type='Broker';
       theAccounts.add(theAccount);
       
      }
       for(Integer i=2;i<4;i++) {
             theAccount = TestDataFactory.createAccount(
                          'The Test Account' + i,
                          null,
                          false
             );
       theAccount.RecordTypeId = AccountRecordTypeInfo.get('B2C').getRecordTypeId();
       theAccount.Primary_Email__c = 'Email'+i+'@b2c.com';
       theAccount.Agent_Broker__c = true;
       theAccount.Type ='Realtor Agent';
       theAccounts.add(theAccount);
      }
    insert theAccounts;
    
    // GEt A Broker Account
    List<Account> brokerAccounts = [Select Id,Associated_Agent_Account__c from Account where RecordTypeId =: AccountRecordTypeInfo.get('B2B').getRecordTypeId() order by CreatedDate desc];
    // Get An Agent Account
    List<Account> agentAccounts = [Select Id,Associated_Broker_Account__c from Account where RecordTypeId =: AccountRecordTypeInfo.get('B2C').getRecordTypeId() order by CreatedDate desc];
    brokerAccounts.get(0).Associated_Agent_Account__c = agentAccounts.get(0).Id;
    brokerAccounts.get(1).Associated_Agent_Account__c = agentAccounts.get(1).Id;
    update brokerAccounts;
    
    List<Account> listAgents = [Select Id,Associated_Broker_Account__c from Account where  RecordTypeId =: AccountRecordTypeInfo.get('B2C').getRecordTypeId() order by CreatedDate desc];
    //System.assert(listAgents.get(0).Associated_Broker_Account__c == brokerAccounts.get(0).Id);  
    
    listAgents.get(1).Associated_Broker_Account__c = null;
    update listAgents;
    
    brokerAccounts = [Select Id,Associated_Agent_Account__c from Account where RecordTypeId =: AccountRecordTypeInfo.get('B2B').getRecordTypeId() order by CreatedDate desc];
    //System.assert(brokerAccounts.get(1).Associated_Agent_Account__c == null);
    
    theAccount = TestDataFactory.createAccount('The Test Account123',null,false);
    theAccount.RecordTypeId = AccountRecordTypeInfo.get('B2C').getRecordTypeId();
    theAccount.Type='Realtor Agent';
    theAccount.Primary_Email__c = 'Email12@b2c.com';
    theAccount.Agent_Broker__c = true;
    theAccount.Associated_Broker_Account__c = brokerAccounts.get(1).Id;
    insert theAccount;
       
    brokerAccounts = [Select Id,Associated_Agent_Account__c from Account where RecordTypeId =: AccountRecordTypeInfo.get('B2B').getRecordTypeId() order by CreatedDate desc];
   }
    
    static testMethod void testDeleteBinder(){
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Account theAccount;
        theAccount = TestDataFactory.createAccount(
            'The Test Account',
            null,
            false
        );
        theAccount.Primary_Email__c =  'testEmail@testClass.com';
        theAccount.isBinder__c = true;
        insert theAccount;
        delete theAccount;
    }
}