public with sharing class InvoicePaymentProfilesController {

    public List < PaymentProfiles__c > payments {
        get;
        set;
    }
    public List < Zuora__ZInvoice__c > invoice {
        get;
        set;
    }
    public String InvoiceId;
    public String CaseId;

    public InvoicePaymentProfilesController(ApexPages.StandardController controller) {

        InvoiceId = String.valueOf(ApexPages.CurrentPage().getParameters().get('id'));
        Map < Id, List < PaymentProfiles__c >> mapZoura = new Map < Id, List < PaymentProfiles__c >> ();
        List < Zuora__ZInvoice__c > invoicelst = [select id, Zuora__Status__c, Case__c, Zuora__Account__c from Zuora__ZInvoice__c where Id = : InvoiceId];
        Set < Id > setAccountIds = new Set < Id > ();
        for (Zuora__ZInvoice__c invoice: invoicelst) {
            setAccountIds.add(invoice.Zuora__Account__c);
        }
        for (PaymentProfiles__c invoice: [SELECT id, Name, Account__c, Account__r.name, ExpirationDate__c, CardholderName__c, MaskNumber__c, CreditCardType__c, Payment_Method_Type__c, SplitPercentage__c
        FROM PaymentProfiles__c WHERE PaymentProfiles__c.Account__c = : setAccountIds]) {
            if (mapZoura.containskey(invoice.Account__c)) {
                List < PaymentProfiles__c > lstZaura = mapZoura.get(invoice.Account__c);
                lstZaura.add(invoice);
                mapZoura.put(invoice.Account__c, lstZaura);
            } else {
                List < PaymentProfiles__c > lstZaura = new List < PaymentProfiles__c > ();
                lstZaura.add(invoice);
                mapZoura.put(invoice.Account__c, lstZaura);
            }
        }

        for (Zuora__ZInvoice__c Z: invoicelst) {
            payments = mapZoura.get(Z.Zuora__Account__c);

        }
    }

    public PageReference BillingAccountManager() {
        Zuora__ZInvoice__c Invoice = [select id, Zuora__Status__c, Case__c, Zuora__Account__c,Zuora__BillingAccount__c from Zuora__ZInvoice__c where Id = : InvoiceId];        
        PageReference newpage = new PageReference('/apex/Manage_Billing_Account?id=' + Invoice.Zuora__BillingAccount__c);
        newpage.setRedirect(true);
        return newpage;
    }
    public PageReference CaseBillingManager() {
        CaseId = String.valueOf(ApexPages.CurrentPage().getParameters().get('id'));
        Case case1 = [Select id,Account.name,AccountId from case where id =:CaseId ];
        Zuora__CustomerAccount__c CustomerAccount = [select id, Zuora__Account__c from Zuora__CustomerAccount__c where Zuora__Account__c = : case1.AccountId limit 1];
        PageReference newpage = new PageReference('/apex/Manage_Billing_Account?id=' + CustomerAccount.Id);
        newpage.setRedirect(true);
        return newpage;
      }
    }