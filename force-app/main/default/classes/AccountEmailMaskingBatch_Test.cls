@isTest
public class AccountEmailMaskingBatch_Test {

@isTest
    static void testMe(){
        
        list<Account> accts = new list<Account>();
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
         testAccount.Email_Address__c = 'testAccount@move.com';
        //TestDataFactory.createAccount ();
        AccountEmailMaskingBatch aem = new AccountEmailMaskingBatch();
           List<Account> accounts = [select Id, Email_Address__c, Primary_Email__c, Other2_Email__c, Other1_Email__c, MLS_Email__c, Do_Not_Email__c,Advertiser_Email__c FROM Account];           
            for(Account a: accounts){
             System.assertEquals(a.Email_Address__c, 'testAccount@masked.move.com');               
            }
        
        Test.startTest();
        AccountEmailMaskingBatch aem1 = new AccountEmailMaskingBatch();     
        Database.BatchableContext bc;             
        aem1.start(bc);
        aem1.execute(bc,accounts);
        aem1.finish(bc);
          
        Test.stopTest();
        
            }
}