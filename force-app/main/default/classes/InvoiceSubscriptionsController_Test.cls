@IsTest
Private class InvoiceSubscriptionsController_Test{
    static testMethod void InvoicePaymentProfilesController_Test(){    
     //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg; 
    Account theAccount = TestDataFactory.createAccount('The Test Account', null, false);
    theAccount.Primary_Email__c = 'theAcc@move.com';
    theAccount.Type = Constants.OFFICE_ACCOUNT_TYPE;
    insert theAccount;
    
    //Zuora__CustomerAccount__c act = [Select id,Name from Zuora__CustomerAccount__c limit 1];
      
    List<Zuora__ZInvoice__c> invoices = new List<Zuora__ZInvoice__c>();
      Zuora__ZInvoice__c inv = new Zuora__ZInvoice__c();
          inv.Name = 'TestInv';
          inv.Zuora__Status__c = 'Post Due';
          inv.Zuora__Account__c = theAccount.Id;
          //invoices.Add(inv);                    
           //insert invoices ;
           insert inv;
           
   List<Zuora__Subscription__c> Subscriptions = new List<Zuora__Subscription__c>();
           Zuora__Subscription__c sub = new Zuora__Subscription__c();
           sub.Name = 'Test';
           sub.Zuora__Account__c = inv.Zuora__Account__c;
           //sub.Zuora__CustomerAccount__c = act.id;
           sub.Zuora__SubscriptionStartDate__c = system.Today();  // 3/1/2015;
           sub.Zuora__SubscriptionEndDate__c = system.Today();  //4/1/2015;
           sub.Zuora__NextRenewalDate__c  = system.Today();     //4/1/2015;
           //Subscriptions.add(sub);
           //insert Subscriptions; 
           insert sub;
          
       List<Invoice_Item__c > invoiceitems = new List<Invoice_Item__c >();   
      /* 
       Invoice_Item__c invitem = new Invoice_Item__c();
       invitem.Name = 'Test';
       invitem.Invoice__c = inv.id;
       invitem.Subscription__c = sub.id;
       invoiceitems.add(invitem);
        insert invoiceitems;
       */    
         PageReference pgr = page.Subscriptions;
           pgr.getParameters().put('id',inv.id);
           Test.SetCurrentPage(pgr);
           ApexPages.StandardController sc = new ApexPages.standardController(inv);
           InvoiceSubscriptionsController IP = new InvoiceSubscriptionsController(Sc);
    IP.invoiceItem = invoiceitems;
    //IP.Subscriptions = Subscriptions;
      }
 }