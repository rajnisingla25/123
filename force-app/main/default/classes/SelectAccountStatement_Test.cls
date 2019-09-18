// Apex Test Class Name: InvoiceCustomerStatement_Test
// For Testing: InvoiceCustomerStatement.cls
//
// 22nd May 2017   Sonu Sharma 
//
@isTest
Public class SelectAccountStatement_Test {
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
        
        list < Product2 > productList = new list < Product2 > ();
        productList.add(new Product2(Name = 'H00-062', Family = 'Professional Development', ProductCode = 'TOPCRM', S_No__c = 1));
        productList.add(new Product2(Name = 'H00-062', Family = 'SHOWCASE', ProductCode = 'SHOWCASE', S_No__c = 1));
        insert productList;
        
        List<Asset> lstAsset = new List<Asset>();
        
        Asset objAsset = new Asset();
        objAsset.Name = 'Test Asset';
        objAsset.Status = 'Active';
        objAsset.Fulfillment_Status__c = 'Fulfilled';
        objAsset.AccountId = newAccount.id;
        //objAsset.Order_Line_Item__c = orderItems[1].id;
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
            
       Zuora__CustomerAccount__c b = new Zuora__CustomerAccount__c();
       b.Past_Due_Balance__c= 60;
       b.Zuora__Account__c = newAccount.Id;
       insert b;
       
       Zuora__ZInvoice__c a = new Zuora__ZInvoice__c();
       a.Invoice_Status__c='Paid';
       a.Zuora__Balance2__c= 40;
       a.Zuora__TotalAmount__c = 30;
       a.Zuora__BillingAccount__c = b.Id;
       //a.subtotal = 0;
       insert a;
       
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
    }
    
 static testMethod void testSelectAccountStatementFunctionality() {
 PageReference pgr = page.SelectAccountStatement;
    pgr.getParameters().put('Id',[Select Id from Account limit 1].id);
    Test.SetCurrentPage(pgr);    
     //ApexPages.StandardController sc = new ApexPages.standardController(Led);  
 SelectAccountStatement Ics = new SelectAccountStatement();
 Ics.RedirectToAccountStatementPrevious0();
 Ics.RedirectToAccountStatementPrevious1();
 Ics.RedirectToAccountStatementPrevious2();
 Ics.RedirectToAccountStatementPrevious3();
 Ics.RedirectToAccountStatementPrevious4();
 Ics.RedirectToAccountStatementPrevious5();
 Ics.RedirectToAccountStatementPrevious6();
 
 }
 }