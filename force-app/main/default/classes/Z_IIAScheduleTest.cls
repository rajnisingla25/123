@isTest(seealldata = true)
public class Z_IIAScheduleTest {    
    public static testMethod void TestMethodOne() {        
        Account theAccount = TestDataFactory.createAccount('The Test Account', null, false);
        theAccount.Primary_Email__c = 'hsingh@appirio.com';
        theAccount.Type = 'Lender Individual';
        theAccount.Name = 'Broker2';
       // theAccount.Primary_Email__c = 'parentAcc@move.com';
        theAccount.Customer_Care_Calls__c = 'Yes';
        theAccount.Sales_Calls__c = 'Yes';
        theAccount.Marketing_Emails__c = 'Yes';
        theAccount.Agent_SLE__c = 'Yes';
        theAccount.MLS_Set_Id__c  = '67890';  
            theAccount.nmls_Id__c = '123456'; 
        theAccount.Total_Contract_Value__c = 15000;
        theAccount.Exclusion_Notes__c = 'Test Exclusion Notes.';
        insert theAccount;
        
        Zuora__CustomerAccount__c BiilAccount = new Zuora__CustomerAccount__c();
        BiilAccount.Zuora__Account__c = theAccount.Id;
        insert BiilAccount;
        
        Zuora__ZInvoice__c inv = new Zuora__ZInvoice__c();
        inv.Name = 'TestInv';
        inv.Zuora__Status__c = '';
        inv.Zuora__Account__c = theAccount.Id;
        inv.Zuora__DueDate__c = system.today();
        inv.Zuora__Balance2__c = 5;
        inv.Invoice_Status__c = 'Cancelled';
        inv.Zuora__External_Id__c = '1211122121212';
        inv.Zuora__Zuora_Id__c= '1211122121212';
        
        insert inv;
        Product2 theTestProduct         = new Product2(
            Name                          = 'Connection(SM) for Co-Brokerage',
            Family                        = 'Hardware',
            S_No__c                       = 2,
            ProductCode                   = 'COBROKE'
        );
        insert theTestProduct;
        //return theTestProduct;
        Asset myAsset = new Asset();
        myAsset.Name = 'test asset';
        myAsset.AccountId =theAccount.Id;     
        myAsset.Fulfillment_Status__c = 'Success';
        myAsset.Asset_Type__c = 'Parent';
        myAsset.Product2ID   = theTestProduct.Id;
        // myAsset.Payment_Profile__c = pp;
        myAsset.price__c = 30;
        // myAsset.ContactId = Contactid;
        myAsset.Subscription_Id__c = '323232323232323232323232323';
        //insert myAsset;
         Account_Relationship__c ar = new Account_Relationship__c();
            ar.parent_account__c = theAccount.Id;
            //ar.child_account__c = lenderAcc.id;
            ar.relationship_type__c = 'Partner';
            ar.comarketing_status__c= 'Active';
            ar.comarketer_spend__c = 100;
            ar.comarketer_actual_spend__c = 100;
            ar.total_connections_price__c = 5000;
            ar.total_relationship_assets_price__c = 5000;
            ar.Initial_comarketer_spend_percent__c = 10;
            //ar.relationship_CAP__c = 280;
            insert ar;
        
        comarketing_relationship__c cr = new comarketing_relationship__c();
        cr.status__c = 'Active';
        //cr.cfcb_asset__c = myAsset.id;
        cr.Agent_Zuora_Status__c = 'Pending Update';
        cr.Lender_Zuora_Status__c ='Pending Update';
        cr.Action__c = 'Add';
        cr.Amendment_Effective_Date__c = Date.today();
        cr.Lender_Asset_Monthly_Contribution__c = 20;
        cr.Lender_Cancellation_Date__c = date.today();
        cr.Agent_Cancellation_Date__c = date.today();
        cr.Credit__c = 20;
        cr.relationship__c = ar.id;
        cr.Agent_Lender_Asset_Id__c ='12312312312313';
        insert cr;
        
        String zID = '44444444444444444444444444444444';          
        Zuora__Subscription__c  Sub= new Zuora__Subscription__c();
        Sub.Zuora__Account__c = theAccount.Id;
        Sub.Name = '283838';
        Sub.PaymentMethodId__c = zID;
        sub.CMRelationship__c = cr.id;
        insert Sub;
        system.debug('subId ' + Sub);
        
        Zuora__Payment__c  Payment= new Zuora__Payment__c();
        Payment.Zuora__Account__c = theAccount.Id;
        Payment.Zuora__Status__c = 'Error';
        Payment.ZPaymentMethodId__c = zID;
        Payment.Zuora__BillingAccount__c = BiilAccount.Id;
        insert Payment;
        
        Zuora__PaymentInvoice__c Invpay = new Zuora__PaymentInvoice__c();       
        Invpay.Zuora__Invoice__c = inv.Id;
        Invpay.Zuora__Payment__c = Payment.Id;
        Invpay.Zuora__ApplyAmount__c = 2;
        //Status__c ='Error'
        insert Invpay;
        
        Invoice_Item__c Invitem= new Invoice_Item__c();
        Invitem.Invoice__c = inv.Id;
        Invitem.Subscription__c = Sub.Id;   
        Invitem.Invoice_Item_Zuora_ID__c = '12121313131131313';
        Invitem.Charge_Amount__c = 20;
        Invitem.Service_Start_Date__c = date.today();
        Invitem.Service_End_Date__c = date.today();
        Invitem.RPC_Zuora_ID__c = 'Test Insert SPC';
        Invitem.Subscription_Zuora_ID__c = 'Test Insert Sub';
        Invitem.Invoice_Zuora_ID__c = '1211122121212';
        Invitem.Account_Zuora_ID__c = 'Test Insert Bacc';
        Invitem.Product_Zuora_ID__c = 'Test Insert Product';
        Invitem.PRP_Zuora_ID__c = 'Test Insert PRP';
        Invitem.PRPC_Zuora_ID__c = 'Test Insert PRPC';
        Invitem.Asset_In_Zuora__c = '21212121212121212';
        insert Invitem;
        Z_IIASchedule.IIAadjustments();
        Z_IIASchedule.updatelogs('Error');
    }         
    
}