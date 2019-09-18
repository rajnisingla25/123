// Trigger Name: MoveInvoiceTrigger  
// On SObject: Zuora__ZInvoice__c 
// Description: Invoice assignment to a open Collection case which have any Past Due Invoices.
trigger MoveInvoiceTrigger on Zuora__ZInvoice__c(before update, after update) {
    
    // CRM-1294 Adding trigger inside custom setting DisabledTrigger__c 
    DisabledTrigger__c Dtrg = DisabledTrigger__c.getValues('Disabled');
    String usercheck='';
    if (Dtrg.Zuora_Invoice__c !=null ) {
        usercheck = Dtrg.Zuora_Invoice__c;
    }
    if(!usercheck.contains(UserInfo.getUserName())) {
    
         if(Trigger.isbefore && Trigger.isupdate){       
             if(!SkipAssetTrigger.skiptrigger){     
                    if(InvoiceCaseCloserNew.invoiceTriggerRun){
                        InvoiceCaseCloserNew.invoiceTriggerRun                          = false;
                        InvoiceCaseClosernew theHandlernew                              = new InvoiceCaseClosernew();
                        theHandlernew.CaseCloser(Trigger.New); 
                    }           
             }
             SkipAssetTrigger.setSkipTrgTrue();
             
         }   
         
         // CRM-1119 populate the total past due balance on billing account 
         if(Trigger.isupdate&& Trigger.isafter){
         List<Zuora__CustomerAccount__c> billingAccountstoUpdate = new List<Zuora__CustomerAccount__c>();
         Set<Id> billing_AccountIds = new Set<Id>();  
            for(Zuora__ZInvoice__c Invoice: Trigger.new)
            {
            //CRM-1602 added one more condition to trigger calculation for balance change also.
              if(Trigger.oldMap.get(Invoice.id).Invoice_Status__c!= Invoice.Invoice_Status__c || Trigger.oldMap.get(Invoice.id).Zuora__Balance2__c!= Invoice.Zuora__Balance2__c)
              {
                billing_AccountIds.add(Invoice.Zuora__BillingAccount__c);
              }
            }
            
            List<Zuora__CustomerAccount__c> Billing = [Select id, Past_Due_Balance__c, (Select Id, Zuora__Balance2__c from Zuora__ZInvoices__r where Invoice_Status__c = 'Past Due')  From Zuora__CustomerAccount__c where Id IN:billing_AccountIds];
            if(!Billing.isempty()){
                for(Zuora__CustomerAccount__c a: Billing ){
                Decimal InvoiceBalance = 0;
                for(Zuora__ZInvoice__c c: a.Zuora__ZInvoices__r){
                        InvoiceBalance += c.Zuora__Balance2__c;
                }
                a.Past_Due_Balance__c= InvoiceBalance;
                billingAccountstoUpdate.add(a);
                }
              update billingAccountstoUpdate;
            }
         
         }
         
    }
}