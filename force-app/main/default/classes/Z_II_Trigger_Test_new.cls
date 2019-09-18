@isTest()
public class Z_II_Trigger_Test_new{
    public static testMethod void method1(){
        
          //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg; 
        
        Account theAccount = TestDataFactory.createAccount('The Test Account', null, false);
            theAccount.Primary_Email__c = 'theAcc@move.com';
            theAccount.Type = Constants.OFFICE_ACCOUNT_TYPE;
        insert theAccount;
        Zuora__ZInvoice__c inv = new Zuora__ZInvoice__c();
            inv.Name = 'TestInv';
            inv.Zuora__Status__c = 'Post Due';
            inv.Zuora__Account__c = theAccount.Id;
        Insert inv;
        
        Zuora__Subscription__c sub = new Zuora__Subscription__c();
           sub.Name = 'Test';
           sub.Zuora__Account__c = inv.Zuora__Account__c;
           sub.Zuora__SubscriptionStartDate__c = system.Today();
           sub.Zuora__SubscriptionEndDate__c = system.Today();  
           sub.Zuora__NextRenewalDate__c  = system.Today();     
        insert sub;
        Invoice_Item__c invitem = new Invoice_Item__c();
           invitem.Name = 'Test';
           invitem.Invoice__c = inv.id;
           invitem.Subscription__c = sub.id;
        insert invitem ;
          
    
    }
}