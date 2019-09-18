// Apex Test Class Name: AccountStatement_Test
// For Testing: AccountStatement.cls
// 
// 22nd May 2017   Sonu Sharma 
@isTest
Public class AccountStatement_Test {
@testSetup static void setup() {
     DisabledTrigger__c disabledTriggerCustomSetting = new DisabledTrigger__c();
        disabledTriggerCustomSetting.Name = 'Disabled';
        disabledTriggerCustomSetting.Zuora_Invoice__c = 'testdatamigration@move.com.eut';
        insert disabledTriggerCustomSetting;
 		
        Account newAccount = new Account();
        newAccount.name = 'XYZ';
        newAccount.Phone = '1234567890';
        newAccount.BillingStreet = 'Am Tierpark 16';
        newAccount.BillingCity = 'Cologne';
        newAccount.BillingPostalCode = '54321';
        newAccount.BillingState = 'Nordrhein-Westfalen';
        newAccount.BillingCountry = 'Germany';
        newAccount.Primary_Email__c = 'ra@gmail.com';
        newAccount.Home_Phone__c = '1234567890';
        newAccount.Work_Phone__c = '1234567890';
        newAccount.Mobile1__c = '1234567890';
        newAccount.Mobile2_Other__c = '1245787';
        newAccount.party_id__c = '206084041';   
        newAccount.EssentialsStatus__c = 'Activated';
    	insert newAccount;
            
            Account_Balance__c abb = new Account_Balance__c();
            abb.BalanceMonthYear__c = '052017';
            abb.Total_Balance__c = 100;
            abb.Account__c = newAccount.id;
            insert abb;
            
       Zuora__CustomerAccount__c b = new Zuora__CustomerAccount__c();
       b.Past_Due_Balance__c= 60;
       b.Zuora__Account__c = newAccount.Id;
       insert b;
       
       Zuora__ZInvoice__c a = new Zuora__ZInvoice__c();
       a.Invoice_Status__c='Paid';
       a.Zuora__Balance2__c= 40;
       a.Zuora__TotalAmount__c = 30;
       a.Zuora__BillingAccount__c = b.Id;
       a.Zuora__Account__c = newAccount.id;
       insert a;
       System.debug(a);
       
       List< Product2 > productList = new list < Product2 > ();
        productList.add(new Product2(Name = 'H00-062',Product_abbreviation__c='TPC', Family = 'Professional Development', ProductCode = 'TOPCRM', S_No__c = 1));
        productList.add(new Product2(Name = 'H00-062', Product_abbreviation__c='SC', Family = 'SHOWCASE', ProductCode = 'SHOWCASE', S_No__c = 1));
        insert productList;
        
        List<Asset> lstAsset = new List<Asset>();
        
        Asset objAsset = new Asset();
        objAsset.Name = 'Test Asset';
        objAsset.Status = 'Active';
        objAsset.Fulfillment_Status__c = 'Fulfilled';
        objAsset.AccountId = newAccount.id;
        objAsset.Product2ID = productList[0].Id;
        objAsset.Line_Type__c = 'Add';
        objAsset.Commerce_Group__c = 'Broker Marketing Solution';
        objAsset.Suppress_Welcome_Calls__c = false;
        lstAsset.add(objAsset);
        //insert objAsset;
        
        Asset objAsset1 = new Asset();
        objAsset1.Name = 'Test Asset';
        objAsset1.Status = 'Active';
        objAsset1.Fulfillment_Status__c = 'Fulfilled';
        objAsset1.AccountId = newAccount.id;
        //objAsset.Order_Line_Item__c = orderItems[1].id;
        objAsset1.Product2ID = productList[0].Id;
        objAsset1.Line_Type__c = 'Add';
        objAsset1.Commerce_Group__c = 'Agent Marketing Solution';
        objAsset1.Suppress_Welcome_Calls__c = false;
        lstAsset.add(objAsset1);
        //insert objAsset;
            Insert lstAsset;
        
       List<Invoice_Item__c> lstItem = new List<Invoice_Item__c>();
       for(Integer ii=1;ii<10;ii++){
       Invoice_Item__c InvItem = new Invoice_Item__c();
       InvItem.Invoice__c = a.id;
       InvItem.Amount_with_Adjustments__c = 10;
       
       InvItem.asset__c = lstAsset[0].id;
       if(ii==1 || ii==5){InvItem.Charge_Amount__c = -100;
       InvItem.Name = 'Credit issued';
       }
       InvItem.Charge_Amount__c = 100;
       if(ii==1 || ii==8){InvItem.asset__c = lstAsset[1].id;}
       InvItem.Tax_Amount__c=10;
       
       lstItem.add(InvItem);
       }
       insert lstItem;
       a.Invoice_Status__c= 'Past Due';
       update a;      
       
       Zuora__Payment__c zpp = new Zuora__Payment__c();
       zpp.Zuora__Status__c='Processed';
       zpp.Zuora__Account__c = newAccount.id;
       zpp.Zuora__BillingAccount__c = b.Id;
       zpp.Zuora__Amount__c = 70;
       insert zpp;
       
       Zuora__PaymentInvoice__c zpi = new Zuora__PaymentInvoice__c();
       zpi.Zuora__ApplyAmount__c = 100;
       zpi.Zuora__Invoice__c = a.id;
       zpi.Zuora__Payment__c = zpp.id;
       insert zpi;
       
       Zuora__Refund__c reff = new Zuora__Refund__c();
       reff.Zuora__Account__c = newAccount.Id;
       reff.Zuora__BillingAccount__c = b.Id;
       reff.Zuora__Amount__c = 10;
       insert reff;
       //Test.setCreatedDate(reff.Id, Date.today() + 2);
       
       Zuora__RefundInvoicePayment__c zpif = new Zuora__RefundInvoicePayment__c();
       zpif.Zuora__RefundAmount__c = 100;
       //zpif.Zuora__Invoice__c = a.id;
       zpif.Zuora__Refund__c = reff.id;
       zpif.Zuora__InvoicePayment__c = zpi.id;
       insert zpif;
       
       Invoice_Item_Adjustment__c IIA = new Invoice_Item_Adjustment__c();
       IIA.Invoice__c = a.id;
       IIA.Amount__c = 50;
       IIA.Type__c='Credit';
       insert IIA;
    
        Suppress_in_Customer_Statements_Settings__c custStatementSetting = new Suppress_in_Customer_Statements_Settings__c();
         custStatementSetting.Name = 'Customer';
         custStatementSetting.Product_Code__c = 'RSRESPOND';
         custStatementSetting.Promo_Codes__c = 'FREEBUNDLERSRESPOND';
         insert custStatementSetting;
    }
    
 static testMethod void testAccountStatementFunctionality() {
     PageReference pgr = page.AccountStatementNew;
     pgr.getParameters().put('Id',[Select Id from Account limit 1].id);
     //pgr.getParameters().put('startdate', Date.today().format());
     //pgr.getParameters().put('enddate', Date.today().format());
     Test.SetCurrentPage(pgr);
     //ApexPages.StandardController sc = new ApexPages.standardController(Led);  
     AccountStatement ascont = new AccountStatement();
     ascont.getlstAccountInvoiceWrapper();
     ascont.getlstIvoiceProductZips();
     ascont.getlstAccountInvoiceWrapper1();
     List < InvoiceWrapper > lstInvoiceWrapper = ascont.lstInvoiceWrapper1;
     Double dOffset = ascont.offset;
     ascont.verifyCommunityUserAccount([Select Id from Account limit 1].id);
     ascont.validateCommunityUser();
     System.debug(ascont.BillingPeriodStartDate+'************'+ascont.BillingPeriodEndDate);
 }
 }