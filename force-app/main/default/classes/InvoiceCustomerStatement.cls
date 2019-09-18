/*
Apex class :InvoiceCustomerStatement
Purpose :- InvoiceCustomerStatement class is used to develop invoice statment
CRM - OTC-208
Author :- Sonu Sharma, Move Inc
*/
Public class InvoiceCustomerStatement {
    //Added by Pratik for CRM-4920 on 18th Oct 2018
    public Boolean IsSubscriptionPayment {get;set;}
    //Ends here
    Public List < InvoiceWrapper > lstInvoiceWrapper {
        get;
        set;
    }
    Public string AccountName {
        get;
        set;
    }
    Public string AccountType {
        get;
        set;
    }
    Public string InvoiceName {
        get;
        set;
    }
    Public string partyId {
        get;
        set;
    }
    Public Decimal pastDueDays {
        get;
        set;
    }
    Public Decimal totalfinalBalance {
        get;
        set;
    }
    Public Decimal totalBalance {
        get;
        set;
    }
    Public Decimal pastdueBalance {
        get;
        set;
    }
    Public DateTime InvoiceGenerateDate {
        get;
        set;
    }
    Public DateTime InvoiceDueDate {
        get;
        set;
    }
    Public Date BillingPeriodStartDate {
        get;
        set;
    }
    Public Date BillingPeriodEndDate {
        get;
        set;
    }
  
    Map<String,List < Invoice_Item__c >> mapProductBundle = new Map<String,List < Invoice_Item__c >>();
    
    Public InvoiceCustomerStatement() {
        String AccountId = '001j000000000';
        
        // CRM - 2993
        totalfinalBalance = 0.0;
        pastdueBalance = 0.0;
        totalBalance = 0.0;
        InvoiceGenerateDate = System.today();

        BillingPeriodStartDate = System.today().addDays(-30);
        BillingPeriodEndDate = System.today();
        if (ApexPages.currentPage().getParameters().get('startdate') != null) {
            BillingPeriodStartDate = Date.valueOf(ApexPages.currentPage().getParameters().get('startdate'));
        }
        
        if (ApexPages.currentPage().getParameters().get('startdate') != null) {
            BillingPeriodEndDate = Date.valueOf(ApexPages.currentPage().getParameters().get('startdate'));
        }
        if (ApexPages.currentPage().getParameters().get('id') != null) {
            AccountId = ApexPages.currentPage().getParameters().get('id');
        }

        lstInvoiceWrapper = new List < InvoiceWrapper > ();
        Map < Id, InvoiceWrapper > mapInvoiceIdWrapper = new Map < Id, InvoiceWrapper > ();
        Map <Id,Decimal> mapinvLine = new Map <Id,Decimal>();
        Map <Id,Decimal> mapinvPositiveLine = new Map <Id,Decimal>();
        for (Zuora__ZInvoice__c Zinv: [Select Id, name, CreatedDate,Days_Past_Due__c, Zuora__DueDate__c, Zuora__Account__r.party_Id__c, Zuora__Account__r.name, Zuora__Account__r.Type, Zuora__BillingAccount__r.Past_Due_Balance__c, Zuora__Balance2__c, Zuora__TotalAmount__c, Zuora__Account__r.Subscription_payment__c from Zuora__ZInvoice__c where Id =: AccountId]) {
            pastdueBalance = Zinv.Zuora__BillingAccount__r.Past_Due_Balance__c;
            system.debug('pastdueBalance'+Zinv.Zuora__BillingAccount__r.Past_Due_Balance__c+Zinv.Id);
            AccountName = Zinv.Zuora__Account__r.name;
            //LCM-156
            AccountType = Zinv.Zuora__Account__r.type;
            //Added by Pratik for CRM-4920 on 18th Oct 2018
            IsSubscriptionPayment = Zinv.Zuora__Account__r.Subscription_payment__c;
            //Ends here
            InvoiceName = zinv.Name;
            InvoiceDueDate = zinv.Zuora__DueDate__c;
            pastDueDays = zinv.Days_Past_Due__c;
            InvoiceGenerateDate = zinv.CreatedDate.AddHours(-7);
            partyId = zinv.Zuora__Account__r.party_Id__c;
            InvoiceWrapper invw = new InvoiceWrapper();
            List < Invoice_Item__c > lstInv1 = new List < Invoice_Item__c > ();
            List < Invoice_Item__c > lstInv2 = new List < Invoice_Item__c > ();
            List < Invoice_Item__c > lstInv3 = new List < Invoice_Item__c > ();
            List < Invoice_Item__c > lstInv4 = new List < Invoice_Item__c > ();
            List < Invoice_Item__c > lstInv5 = new List < Invoice_Item__c > ();
            List < Zuora__PaymentInvoice__c > zinvp = new List < Zuora__PaymentInvoice__c > ();
            List < Zuora__RefundInvoicePayment__c > zrefund = new List < Zuora__RefundInvoicePayment__c > ();
            List < CreditBalanceAdjustment__c > zcredit = new List < CreditBalanceAdjustment__c > ();
            invw.zinv = zinv;
            invw.InvlineList1 = lstInv1;
            invw.InvlineList2 = lstInv2;
            invw.InvlineList3 = lstInv3;
            invw.InvlineList4 = lstInv4;
            invw.InvlineList5 = lstInv5;
            invw.zinvpayment = zinvp;
            invw.zinvrefund = zrefund;
            invw.zinvCredit  = zcredit ;
            invw.subtotal = 0;
            invw.creditapplied = 0;
            invw.total = 0;
            invw.DueDate = null;
            invw.paymentStatus = '';
            invw.Balance = zinv.Zuora__Balance2__c;
            totalBalance = totalBalance + zinv.Zuora__Balance2__c;
            invw.paid = 0.0;//(zinv.Zuora__TotalAmount__c - zinv.Zuora__Balance2__c);
            invw.Refund = 0.0;
            invw.Applied = 0;
            invw.Adjustment = 0;
            totalfinalBalance = zinv.Zuora__TotalAmount__c;
            mapInvoiceIdWrapper.put(zinv.id, invw);
        }
        //totalfinalBalance = totalBalance; //+ pastdueBalance;
        Map<Id,Id> mapInvoiceIds = new Map<Id,Id>();
        
        //Added by Pratik on 19th July 2018 for issue CRM-4330
        Suppress_in_Customer_Statements_Settings__c custStatementSetting = Suppress_in_Customer_Statements_Settings__c.getInstance('Customer');
        List<String> lstProductCode = custStatementSetting.Product_Code__c.split(';');
        List<String> lstPromoCode = custStatementSetting.Promo_Codes__c.split(';');
        
        //for (Invoice_Item__c iItem: [select id,Tax_Exempt_Amount__c, name, Subscription_Product_Charge__c, Subscription_Product_Charge__r.Zuora__Type__c, Charge_Amount__c, Charge_Name__c, Charge_Date__c, Asset__r.Order_Line_Item__r.Order.OrderNumber, Asset__r.Market__c, Asset__r.Market_key__c, Asset__r.Product2.Name, Asset__r.Asset_Number__c, Asset__r.Name,Asset__r.Id, Asset__r.Lead_Type__c, Asset__r.start_date__c, Asset__r.end_date__c, Invoice__c, Service_Start_Date__c, Amount_with_Adjustments__c, Unit_Price__c, Tax_Amount__c, Service_End_Date__c from Invoice_Item__c where Invoice__c =: mapInvoiceIdWrapper.keyset()]) {
        // CRM-5078: Updated WHERE condition in below query
        for (Invoice_Item__c iItem: [select id,Tax_Exempt_Amount__c, name, Subscription_Product_Charge__c, Subscription_Product_Charge__r.Zuora__Type__c, Charge_Amount__c, Charge_Name__c,  Subscription__r.CMRelationship__c,
                                     Subscription__r.CMRelationship__r.Agent_Account__r.name , Subscription__r.CMRelationship__r.Agent_Asset_Monthly_Contribution__c, Subscription__r.CMRelationship__r.start_date__c,
                                     Charge_Date__c, Asset__r.Order_Line_Item__r.Order.OrderNumber, Asset__r.Market__c, Asset__r.Market_key__c, Asset__r.Product2.Name, Asset__r.Product2.ProductCode,
                                     Asset__r.Asset_Number__c, Asset__r.Name,Asset__r.Id,Asset__r.product_type__c, Asset__r.Lead_Type__c, Asset__r.start_date__c, Asset__r.end_date__c, Invoice__c,
                                     Service_Start_Date__c, Amount_with_Adjustments__c, Unit_Price__c, Tax_Amount__c, Service_End_Date__c, Subscription__r.CMRelationship__r.Lender_Account__r.name, Agent_Paid_Amount_LCM__c
                                     from Invoice_Item__c where Invoice__c =: mapInvoiceIdWrapper.keyset() 
                                     AND (Asset__r.Promotion__c NOT IN :lstPromoCode OR (Asset__r.Promotion__c IN :lstPromoCode AND Charge_Amount__c>0))]) {
            //Ends here
            // LCM: Updated code to use comarketing Id, as Asset Id will be NULL on the invoice item
            // "iItem.Asset__r.Id" is replaced with "assetOrComarId"
            Id assetOrComarId = iItem.Asset__r.Id;
            if(assetOrComarId == null && iItem.Subscription__r.CMRelationship__c != null){
                   assetOrComarId = iItem.Subscription__r.CMRelationship__c;
            }
            if(assetOrComarId!=null){
            if(iItem.Charge_Amount__c<0.0){
                mapInvoiceIds.put(iItem.id,iItem.id);
            
                if(mapinvLine.containskey(assetOrComarId)){
                    Decimal chrgeamount = mapinvLine.get(assetOrComarId);
                    chrgeamount = chrgeamount+iItem.Charge_Amount__c;
                    mapinvLine.put(assetOrComarId,chrgeamount);
                } else {
                    mapinvLine.put(assetOrComarId,iItem.Charge_Amount__c);
                }
            } else {
                if(mapinvPositiveLine.containskey(assetOrComarId)){
                    Decimal chargeamt = mapinvPositiveLine.get(assetOrComarId);
                    chargeamt = chargeamt + iItem.Charge_Amount__c;
                    mapinvPositiveLine.put(assetOrComarId,chargeamt);
                } else {
                    mapinvPositiveLine.put(assetOrComarId,iItem.Charge_Amount__c);
                }
            }
            }
            // LCM - END
         }

         System.debug(mapinvLine + '$$$$$$$$$$$$'+mapinvPositiveLine);
         
         Integer BMSIndexNumber = 10000;
         Integer AMSIndexNumber = 10000;
         Integer RecordNumber = 0;
         Map<Id,Id> mapDuplicateCredit = new Map<Id,Id>();
         //Added by Pratik on 19th July 2018 for issue CRM-4330
         // Added Comarketing fields in the query for LCM 
            //for (Invoice_Item__c iItem: [select id,Tax_Exempt_Amount__c, name, Subscription_Product_Charge__c, Subscription_Product_Charge__r.Zuora__Type__c, Charge_Amount__c, Charge_Name__c, Charge_Date__c,Asset__r.Net_Price__c,Asset__c, Asset__r.Order_Line_Item__r.Order.OrderNumber,Asset__r.Product2.Renewal_Term_Type__c,Asset__r.Market__c,Asset__r.Quantity__c, Asset__r.Commerce_Group__c, Asset__r.Market_key__c, Asset__r.Product2.Name, Asset__r.Asset_Number__c, Asset__r.Name,Asset__r.Id,Asset__r.Contract_Term__c, Asset__r.Lead_Type__c, Asset__r.start_date__c, Asset__r.end_date__c, Invoice__c, Service_Start_Date__c, Amount_with_Adjustments__c, Unit_Price__c, Tax_Amount__c, Service_End_Date__c from Invoice_Item__c where Invoice__c =: mapInvoiceIdWrapper.keyset()]) {
            // CRM-5078: Updated WHERE condition in below query    
            for (Invoice_Item__c iItem: [select id,Tax_Exempt_Amount__c, name, Subscription__r.CMRelationship__r.Agent_Account__r.name, Subscription__r.CMRelationship__r.Agent_Account__r.type , Subscription__r.CMRelationship__r.Agent_Asset_Monthly_Contribution__c, Subscription_Product_Charge__c, Subscription__r.CMRelationship__r.start_date__c,  Asset__r.Product2.ProductCode,CreatedDate,
                                         Subscription__r.CMRelationship__r.Lender_Account__r.name, Subscription__r.CMRelationship__r.Lender_Asset_Monthly_Contribution__c,Agent_Credit_Amount_LCM__c,Agent_Paid_Amount_LCM__c,Lender_Paid_Amount_LCM__c,Asset_Monthly_Price_LCM__c,
                                         Subscription_Product_Charge__r.Zuora__Type__c, Charge_Amount__c, Charge_Name__c, Charge_Date__c,Asset__r.Net_Price__c, Billing_Account__r.Zuora__Account__r.Type, Asset__c, Asset__r.Order_Line_Item__r.Order.OrderNumber, Subscription__r.CMRelationship__r.CFCB_Asset__r.Quantity__c,ProductRatePlanCharge__r.zqu__Type__c,
                                         Asset__r.Product2.Renewal_Term_Type__c,Asset__r.Market__c,Asset__r.Quantity__c, Asset__r.Commerce_Group__c, Asset__r.Market_key__c, Asset__r.Product2.Name, Asset__r.product_type__c, Asset__r.Asset_Number__c, Asset__r.Name, Subscription__r.CMRelationship__r.CFCB_Asset__r.Market__c,
                                         Asset__r.Id,Asset__r.Contract_Term__c, Asset__r.Lead_Type__c, Asset__r.start_date__c, Asset__r.end_date__c, Invoice__c, Service_Start_Date__c, Amount_with_Adjustments__c, Unit_Price__c, Tax_Amount__c, Service_End_Date__c ,Subscription__r.CMRelationship__r.CFCB_Asset__r.Lead_Type__c
                                         from Invoice_Item__c where Invoice__c =: mapInvoiceIdWrapper.keyset() 
                                         AND (Asset__r.Promotion__c NOT IN :lstPromoCode OR (Asset__r.Promotion__c IN :lstPromoCode AND Charge_Amount__c>0))]) {
            Decimal chargeamount = 0.0;
            
            // LCM: Updated code to use comarketing Id, as Asset Id will be NULL on invoice item
            // "iItem.Asset__r.Id" is replaced with "assetOrComarId"
            Id assetOrComarId = iItem.Asset__r.Id;
            if(assetOrComarId == null && iItem.Subscription__r.CMRelationship__c != null){
                   assetOrComarId = iItem.Subscription__r.CMRelationship__c;
            }
            
            if(assetOrComarId!=null){
            if(iItem.Charge_Amount__c>=0.0 || !mapinvPositiveLine.containskey(assetOrComarId)){
            chargeamount = iItem.Charge_Amount__c;
            System.debug(iItem.Charge_Amount__c+'@@@@@@'+!mapinvPositiveLine.containskey(assetOrComarId));
            if(!mapDuplicateCredit.containskey(assetOrComarId)){
            if(iItem.Charge_Amount__c<0 && !mapinvPositiveLine.containskey(assetOrComarId)){mapDuplicateCredit.put(assetOrComarId,assetOrComarId);}
            
            if(((mapinvLine.containskey(assetOrComarId)) &&  (!(iItem.name+'').contains('Credit') || (iItem.name).contains('Co-Marketing')) ) || !mapinvPositiveLine.containskey(assetOrComarId)){
            iItem.Charge_Name__c = 'CreditIssued';
            System.debug(mapinvLine + '$$$$$$$$$$$$');
            iItem.Tax_Exempt_Amount__c = -mapinvLine.get(assetOrComarId);
            
            IF(!mapinvPositiveLine.containskey(assetOrComarId)){
            iItem.Charge_Amount__c = 0.0;
            }
            }
            if (iItem.Amount_with_Adjustments__c == null) {
                iItem.Amount_with_Adjustments__c = 0;
            }
            if (mapInvoiceIdWrapper.containskey(iItem.Invoice__c)) {
            System.debug('Running this');
            if(mapProductBundle.containskey(iItem.Asset__r.Commerce_Group__c) && iItem.Asset__r.Commerce_Group__c!=' '){
            System.debug('KKKK'+iItem.Asset__r.Commerce_Group__c+'JJJJJ');
            List < Invoice_Item__c > lstInvoice = mapProductBundle.get(iItem.Asset__r.Commerce_Group__c);
            lstInvoice.add(iItem);
            mapProductBundle.put(iItem.Asset__r.Commerce_Group__c,lstInvoice);
            } else {
            System.debug('Running this');
            List < Invoice_Item__c > lstInvoice = new List < Invoice_Item__c >();
            lstInvoice.add(iItem);
            
            if(BMSIndexNumber>9999){BMSIndexNumber = RecordNumber;}
            if(AMSIndexNumber>9999){AMSIndexNumber = RecordNumber;}
            if(iItem.Asset__r.Commerce_Group__c=='Broker Marketing Solution' || iItem.Asset__r.Commerce_Group__c=='Agent Marketing Solution'){
            mapProductBundle.put(iItem.Asset__r.Commerce_Group__c,lstInvoice);
            }
            
             List < Invoice_Item__c > lstAdd = new List < Invoice_Item__c > ();
                if (mapInvoiceIdWrapper.get(iItem.Invoice__c).InvlineList1.size() < 990) {
                mapInvoiceIdWrapper.get(iItem.Invoice__c).DisplayInvoice=true;
                    mapInvoiceIdWrapper.get(iItem.Invoice__c).InvlineList1.add(iItem);
                    System.debug(mapInvoiceIdWrapper.get(iItem.Invoice__c).subtotal + '*******' + iItem + '*****' + iItem.Amount_with_Adjustments__c);
                    //mapInvoiceIdWrapper.get(iItem.Invoice__c).subtotal = mapInvoiceIdWrapper.get(iItem.Invoice__c).subtotal + iItem.Charge_Amount__c +iItem.Tax_Amount__c;//iItem.Amount_with_Adjustments__c;
                } else if (mapInvoiceIdWrapper.get(iItem.Invoice__c).InvlineList2.size() < 990) {
                    mapInvoiceIdWrapper.get(iItem.Invoice__c).InvlineList2.add(iItem);
                    //mapInvoiceIdWrapper.get(iItem.Invoice__c).subtotal = mapInvoiceIdWrapper.get(iItem.Invoice__c).subtotal + iItem.Charge_Amount__c +iItem.Tax_Amount__c;//iItem.Amount_with_Adjustments__c;
                } else if (mapInvoiceIdWrapper.get(iItem.Invoice__c).InvlineList3.size() < 990) {
                    mapInvoiceIdWrapper.get(iItem.Invoice__c).InvlineList3.add(iItem);
                    //mapInvoiceIdWrapper.get(iItem.Invoice__c).subtotal = mapInvoiceIdWrapper.get(iItem.Invoice__c).subtotal + iItem.Charge_Amount__c +iItem.Tax_Amount__c;//iItem.Amount_with_Adjustments__c;
                } else if (mapInvoiceIdWrapper.get(iItem.Invoice__c).InvlineList4.size() < 990) {
                    mapInvoiceIdWrapper.get(iItem.Invoice__c).InvlineList4.add(iItem);
                    //mapInvoiceIdWrapper.get(iItem.Invoice__c).subtotal = mapInvoiceIdWrapper.get(iItem.Invoice__c).subtotal + iItem.Charge_Amount__c +iItem.Tax_Amount__c;//iItem.Amount_with_Adjustments__c;
                } else if (mapInvoiceIdWrapper.get(iItem.Invoice__c).InvlineList5.size() < 990) {
                    mapInvoiceIdWrapper.get(iItem.Invoice__c).InvlineList5.add(iItem);
                 }
            }
               }
            }
            }
            System.debug(mapInvoiceIdWrapper+'PPPPPLLL');
            System.debug(chargeamount+'LLLLLLLL'+iItem.Tax_Amount__c);
            if(mapInvoiceIds.containskey(iItem.id)){
            chargeamount = 0;
            }
            mapInvoiceIdWrapper.get(iItem.Invoice__c).subtotal = mapInvoiceIdWrapper.get(iItem.Invoice__c).subtotal + chargeamount +iItem.Tax_Amount__c-(iItem.Charge_Name__c == 'CreditIssued' ? iItem.Tax_Exempt_Amount__c : 0);//iItem.Amount_with_Adjustments__c;
         }
        }
        
          for(String sttr:mapProductBundle.keyset()){
          System.debug(sttr+'PPPPP');
            if(sttr=='Broker Marketing Solution'){   
            Integer bmsIndex = 0;
            for(Invoice_Item__c iItems:mapProductBundle.get(sttr)){
            if(bmsIndex>0){
            mapInvoiceIdWrapper.get(AccountId).InvlineList1[BMSIndexNumber].Charge_Amount__c = mapInvoiceIdWrapper.get(AccountId).InvlineList1[BMSIndexNumber].Charge_Amount__c + iItems.Charge_Amount__c;
            mapInvoiceIdWrapper.get(AccountId).InvlineList1[BMSIndexNumber].Tax_Amount__c = mapInvoiceIdWrapper.get(AccountId).InvlineList1[BMSIndexNumber].Tax_Amount__c + iItems.Tax_Amount__c;
            mapInvoiceIdWrapper.get(AccountId).InvlineList1[BMSIndexNumber].Service_Start_Date__c = mapInvoiceIdWrapper.get(AccountId).InvlineList1[BMSIndexNumber].Service_Start_Date__c;
            mapInvoiceIdWrapper.get(AccountId).InvlineList1[BMSIndexNumber].Service_End_Date__c = mapInvoiceIdWrapper.get(AccountId).InvlineList1[BMSIndexNumber].Service_End_Date__c;

            }
            bmsIndex++;
            }
            }
            if(sttr=='Agent Marketing Solution'){   
            Integer amsIndex = 0;
            for(Invoice_Item__c iItems:mapProductBundle.get(sttr)){
            if(amsIndex>0){
            mapInvoiceIdWrapper.get(AccountId).InvlineList1[BMSIndexNumber].Charge_Amount__c =mapInvoiceIdWrapper.get(AccountId).InvlineList1[BMSIndexNumber].Charge_Amount__c + iItems.Charge_Amount__c;
            mapInvoiceIdWrapper.get(AccountId).InvlineList1[BMSIndexNumber].Tax_Amount__c =mapInvoiceIdWrapper.get(AccountId).InvlineList1[BMSIndexNumber].Tax_Amount__c + iItems.Tax_Amount__c;
            mapInvoiceIdWrapper.get(AccountId).InvlineList1[BMSIndexNumber].Service_Start_Date__c = mapInvoiceIdWrapper.get(AccountId).InvlineList1[BMSIndexNumber].Service_Start_Date__c;
            mapInvoiceIdWrapper.get(AccountId).InvlineList1[BMSIndexNumber].Service_End_Date__c = mapInvoiceIdWrapper.get(AccountId).InvlineList1[BMSIndexNumber].Service_End_Date__c;
            }
            amsIndex++;
            }
            }
            }
            Decimal AdjustmentAmount = 0.0;
        Decimal AppliedAmount = 0.0;
        Decimal paymentAmount = 0.0;
        Decimal refundAmount = 0.0;
        for (Zuora__PaymentInvoice__c zpi: [Select Id, Credit_Card_Name__c, Effective_Date__c ,Split_Percentage__c, name, Zuora__Invoice__c, Submitted_On__c, Zuora__ApplyAmount__c, Status__c, Payment_Method__c, Zuora__Payment__c, Zuora__RefundAmount__c from Zuora__PaymentInvoice__c where Zuora__Invoice__c =: mapInvoiceIdWrapper.keyset() and Status__c = 'Processed']) {
            //zpi.Submitted_On__c = zpi.Effective_Date__c;
            paymentAmount = paymentAmount + zpi.Zuora__ApplyAmount__c;
            mapInvoiceIdWrapper.get(zpi.Zuora__Invoice__c).DisplayPayment = true;
            mapInvoiceIdWrapper.get(zpi.Zuora__Invoice__c).zinvpayment.add(zpi);
            mapInvoiceIdWrapper.get(zpi.Zuora__Invoice__c).Paid = paymentAmount;
        }
        for (Zuora__RefundInvoicePayment__c zrip: [Select Id, CreatedDate, Zuora__Refund__c,Zuora__InvoicePayment__r.Payment_Method__c, Zuora__Refund__r.Zuora__PaymentMethod__c, Zuora__InvoicePayment__r.Credit_Card_Name__c, name, Zuora__RefundAmount__c, Zuora__InvoicePayment__r.Zuora__Invoice__c from Zuora__RefundInvoicePayment__c where Zuora__InvoicePayment__r.Zuora__Invoice__c =: mapInvoiceIdWrapper.keyset() and Zuora__Refund__r.Zuora__Status__c='Processed']) {
            refundAmount = refundAmount + zrip.Zuora__RefundAmount__c;
            mapInvoiceIdWrapper.get(zrip.Zuora__InvoicePayment__r.Zuora__Invoice__c).DisplayRefund = true;
            mapInvoiceIdWrapper.get(zrip.Zuora__InvoicePayment__r.Zuora__Invoice__c).zinvrefund.add(zrip);
            mapInvoiceIdWrapper.get(zrip.Zuora__InvoicePayment__r.Zuora__Invoice__c).Refund = refundAmount;
        }
        
        for (CreditBalanceAdjustment__c zrip: [Select Id, CreatedDate,Source__c, Reason_Code__c, Adjustment_Type__c, Adjustment_Date__c, AdjustmentStatus__c,Invoice__c, Zuora_Amount__c, name  from CreditBalanceAdjustment__c where Invoice__c =: mapInvoiceIdWrapper.keyset()]) {
            //if(){
            Decimal appAmount = 0.0;
            if(zrip.Adjustment_Type__c=='Decrease'){appAmount = zrip.Zuora_Amount__c*-1;} else {appAmount = zrip.Zuora_Amount__c;}
            AppliedAmount = AppliedAmount + appAmount;
            mapInvoiceIdWrapper.get(zrip.Invoice__c).DisplayCredit=true;
            mapInvoiceIdWrapper.get(zrip.Invoice__c).zinvCredit.add(zrip);
            mapInvoiceIdWrapper.get(zrip.Invoice__c).Applied = AppliedAmount;
           // }
        }
         for(Invoice_Item_Adjustment__c iia:[Select Id,name,CreatedDate,Amount__c,Adjustment_Date__c, Type__c ,Invoice_Item__c,Invoice__c from Invoice_Item_Adjustment__c where Invoice__c=: mapInvoiceIdWrapper.keyset()]){
        Decimal iiamount = 0.0;
        iiamount = iia.Amount__c;
        
        if(iia.Type__c=='Credit'){iiamount = -iia.Amount__c;}
        AdjustmentAmount = AdjustmentAmount + iiamount;
        CreditBalanceAdjustment__c cba = new CreditBalanceAdjustment__c();
        cba.CreatedDate = iia.CreatedDate;
        cba.Zuora_Amount__c = iiamount;
        cba.Adjustment_Date__c = iia.Adjustment_Date__c;
        cba.Source__c = iia.Type__c;
        cba.Invoice__c = iia.Invoice__c;
        cba.Reason_Code__c = 'Adjustment';
        mapInvoiceIdWrapper.get(iia.Invoice__c).DisplayCredit = true;
        mapInvoiceIdWrapper.get(iia.Invoice__c).zinvCredit.add(cba);
        mapInvoiceIdWrapper.get(iia.Invoice__c).Adjustment = AdjustmentAmount*-1;
        }
        pastdueBalance = paymentAmount;
        lstInvoiceWrapper = mapInvoiceIdWrapper.values();
        System.debug(lstInvoiceWrapper+'****');
    }
    
    public Map<String,List < Invoice_Item__c >> mapRetProductBundle {
    get {
        return mapProductBundle;
    }
    set;
}
    
    //CRM-3254: If logged in user is community user, then verify if user account is same as the account associated to invoice id passed in parameter.
     public pageReference validateCommunityUser(){
        String invId = '001j000000000';
        if (ApexPages.currentPage().getParameters().get('id') != null) {
            invId = ApexPages.currentPage().getParameters().get('id');
        }
        Id accId = [Select id, Zuora__Account__c from Zuora__ZInvoice__c where Id = :invId limit 1].Zuora__Account__c;
        AccountStatement acctSt = new AccountStatement();
        return acctSt.verifyCommunityUserAccount(accId);
    }
}