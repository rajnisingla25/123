/*
Apex class :AccountStatement
Purpose :- AccountStatement class is used to develop account statment
CRM - OTC-208
Author :- Sonu Sharma, Move Inc
*/
Public class AccountStatement {

    Public List < InvoiceWrapper > lstInvoiceWrapper {
        get;
        set;
    }
    Public List < InvoiceWrapper > lstInvoiceWrapper1 {
        get;
        set;
    }
    Public List<List<AccountInvoiceWrapper>> lstlstAccInvoiceWrapper {
    get;
        set;
    }
    Public string AccountName {
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
    Public Decimal totalfinalBalance {
        get;
        set;
    }
    Public Decimal totalBalance {
        get;
        set;
    }
    Public Decimal totalRefund {
        get;
        set;
    }
    Public Decimal totalCreditAdjustment {
        get;
        set;
    }
    Public Decimal totalDebitAdjustment {
        get;
        set;
    }
    Public Decimal totalBalanceBegining {
        get;
        set;
    }
    Public Decimal totalInvoiceBalance {
        get;
        set;
    }
    
     Public Decimal totalCreditAmount {
        get;
        set;
    }
    Public Decimal totalPayment {
        get;
        set;
    }
    Public Decimal totalBalanceEnding {
        get;
        set;
    }
    Public Decimal pastdueBalance {
        get;
        set;
    }
    Public Date InvoiceGenerateDate {
        get;
        set;
    }
    Public Datetime BillingPeriodStartDate {
        get;
        set;
    }
    Public DateTime BillingPeriodEndDate {
        get;
        set;
    }
    String billingaccount;
    Map < Integer, AccountInvoiceWrapper > mapAccountInvoiceWrapper = new Map < Integer, AccountInvoiceWrapper > ();
    Map < DateTime, Integer > mapDateTimeInteger = new Map < DateTime, Integer > ();
    Map< Id,Decimal> mapInvoiceRefund = new Map< Id,Decimal>();
    Map< Id,Decimal> mapInvoiceCredit = new Map< Id,Decimal>();
    Map< Id,Decimal> mapIIA = new Map< Id,Decimal>();
    Map<String,InvoiceProductZipWrapper> lstIPW = new Map<String,InvoiceProductZipWrapper>();
    Map<String,List<InvoiceProductZipWrapper>> lstIPWnew = new Map<String,List<InvoiceProductZipWrapper>>();
    Map<Id,Zuora__Payment__c> mapPaymentIds = new Map<Id,Zuora__Payment__c>();
    Set<Integer> setArrangeInteger = new Set<Integer>();
    Public AccountStatement() {
        String AccountId = '001j000000000';
        totalfinalBalance = 0;
        pastdueBalance = 0;
        totalRefund = 0;
        totalBalance = 0;
        totalBalanceBegining = 0;
        totalInvoiceBalance = 0;
        totalCreditAmount = 0;
        totalPayment = 0;
        totalBalanceEnding = 0;
        totalCreditAdjustment = 0;
        totalDebitAdjustment = 0;
        InvoiceGenerateDate = System.today();

        BillingPeriodStartDate = System.today().addDays(-30);
        BillingPeriodEndDate = System.today();
        if (Test.isRunningTest()) {
            BillingPeriodEndDate = System.today().addDays(2);
        }
        if (ApexPages.currentPage().getParameters().get('startdate') != null) {
            BillingPeriodStartDate = Date.valueOf(ApexPages.currentPage().getParameters().get('startdate'));
            BillingPeriodStartDate = BillingPeriodStartDate.AddHours(7);
        }
        if (ApexPages.currentPage().getParameters().get('enddate') != null) {
        
            Date myDate = Date.valueOf(ApexPages.currentPage().getParameters().get('enddate'));
            BillingPeriodEndDate = Date.newInstance(myDate.Year(), myDate.Month(), (myDate.Day()+1));
            BillingPeriodEndDate = BillingPeriodEndDate.AddHours(7);
            System.debug(BillingPeriodEndDate+'#######');
            //BillingPeriodEndDate.AddDays(1);
            System.debug(BillingPeriodEndDate+'#######');
        }
        if (ApexPages.currentPage().getParameters().get('id') != null) {
            AccountId = ApexPages.currentPage().getParameters().get('id');
        }

        lstInvoiceWrapper = new List < InvoiceWrapper > ();
        Map < Id, InvoiceWrapper > mapInvoiceIdWrapper = new Map < Id, InvoiceWrapper > ();
        Map < String, Account_Balance__c > mapAccountBalance = new Map < String, Account_Balance__c > ();
        Map <String,String> mapProductCodes = new Map <String,String>();
        for (Account_Balance__c ab: [Select id, name, BalanceMonthYear__c, Total_Balance__c from Account_Balance__c where Account__c =: AccountId order by CreatedDate ASC]) {
            mapAccountBalance.put(ab.BalanceMonthYear__c, ab);
            //totalBalanceBegining = ab.Total_Balance__c;
            string monthstring = (BillingPeriodStartDate.addDays(2).month()+'').leftPad(2,'0');
            String YearString = BillingPeriodStartDate.YEAR()+'';
            if(monthstring=='01'){YearString = (BillingPeriodStartDate.YEAR()+1)+'';}
            System.debug(ab.BalanceMonthYear__c +'=='+ monthstring + '' + YearString);
            if (ab.BalanceMonthYear__c == monthstring + '' + YearString) {
                totalBalanceBegining = ab.Total_Balance__c;
            }
            if (ab.BalanceMonthYear__c == BillingPeriodEndDate.month() + '' + YearString) {
                totalBalanceEnding = ab.Total_Balance__c;
            }
        }

        for (Account acc: [Select Id, name, party_Id__c from Account where Id =: AccountId order by CreatedDate ASC]) {
            //pastdueBalance = Zinv.Zuora__BillingAccount__r.Past_Due_Balance__c;
            AccountName = acc.name;
            //InvoiceName = zinv.Name;
            partyId = acc.party_Id__c;
        }
            Integer kkk=0;
        Map<Id,List<Invoice_Item__c>> mapInvoiceInvoiceItemList = new Map<Id,List<Invoice_Item__c>>();
        Map<String,Map<String,String>> mapProductCodeMarket = new Map<String,Map<String,String>>();
        
        //Added by Pratik on 20th July 2018 for issue CRM-4330
        Suppress_in_Customer_Statements_Settings__c custStatementSetting = Suppress_in_Customer_Statements_Settings__c.getInstance('Customer');
        List<String> lstProductCode = custStatementSetting.Product_Code__c.split(';');
        List<String> lstPromoCode = custStatementSetting.Promo_Codes__c.split(';');
        system.debug('lstProductCode2 =='+lstProductCode);
        system.debug('lstPromoCode2 =='+lstPromoCode);
        system.debug('List2 =='+[Select Id From Invoice_Item__c where Invoice__r.Zuora__Account__c =: AccountId and Invoice__r.CreatedDate >=: BillingPeriodStartDate and Invoice__r.CreatedDate <=: BillingPeriodEndDate AND Asset__r.Product2.ProductCode NOT IN :lstProductCode AND Asset__r.Promotion__c NOT IN :lstPromoCode]);
        
        //for(Invoice_Item__c IItem:[Select Id,Invoice__c,name,Asset__c,Asset__r.Product2.productcode,Asset__r.Product2.Product_abbreviation__c,Asset__r.Market__c from Invoice_Item__c where  Invoice__r.Zuora__Account__c =: AccountId and Invoice__r.CreatedDate >=: BillingPeriodStartDate and Invoice__r.CreatedDate <=: BillingPeriodEndDate order by CreatedDate ASC]){ //Asset__r.Product2.Product_abbreviation__c!=null and
        for(Invoice_Item__c IItem:[Select Id,Invoice__c,name,Asset__c,Asset__r.Product2.productcode,Asset__r.Product2.Product_abbreviation__c,Asset__r.Market__c from Invoice_Item__c where Invoice__r.Zuora__Account__c =: AccountId and Invoice__r.CreatedDate >=: BillingPeriodStartDate and Invoice__r.CreatedDate <=: BillingPeriodEndDate AND ((Asset__r.Product2.ProductCode NOT IN :lstProductCode AND Asset__r.Promotion__c NOT IN :lstPromoCode) OR (Asset__r.Product2.ProductCode IN :lstProductCode AND Charge_Amount__c >0)) order by CreatedDate ASC]){
        //Ends here
            String CodeZipString = '';
        if(IItem.Invoice__c!=null && IItem.Asset__c!=null){
        if(IItem.Asset__r.Product2.Product_abbreviation__c==null || IItem.Asset__r.Product2.Product_abbreviation__c==''){
        IItem.Asset__r.Product2.Product_abbreviation__c = IItem.Asset__r.Product2.productcode;
        }
        if(IItem.Asset__r.Market__c==null){IItem.Asset__r.Market__c='';}
        System.debug(IItem.Invoice__c + '****ppMarketCode*****'+IItem.Asset__r.Product2.Product_abbreviation__c);
        if(mapProductCodeMarket.containskey(IItem.Invoice__c)){
        System.debug(IItem.Invoice__c + '****ppMarketCode*****'+IItem.Asset__r.Product2.Product_abbreviation__c);
        Map<String,String> mapPPCodeMarket = new Map<String,String>();
        mapPPCodeMarket = mapProductCodeMarket.get(IItem.Invoice__c);
        if(mapPPCodeMarket.containskey(IItem.Asset__r.Product2.Product_abbreviation__c)){
        System.debug(IItem.Invoice__c + '****ppMarketCode*****'+IItem.Asset__r.Product2.Product_abbreviation__c);
        String ppMarketCode = '';
        ppMarketCode = mapPPCodeMarket.get(IItem.Asset__r.Product2.Product_abbreviation__c);
        IF((ppMarketCode+'').length()<2){ppMarketCode='';}
        System.debug(ppMarketCode + '****ppMarketCode*****');
        ppMarketCode = ppMarketCode+(ppMarketCode.contains(IItem.Asset__r.Market__c) ?'' :','+IItem.Asset__r.Market__c);
        if((ppMarketCode+'').length()>115 && (ppMarketCode+'').length()<120){
        System.debug('This is working now!');
        ppMarketCode = ppMarketCode+'\r\n';}
        if((ppMarketCode+'').length()>235 && (ppMarketCode+'').length()<240){ppMarketCode = ppMarketCode+'\n';}
        if((ppMarketCode+'').length()>355 && (ppMarketCode+'').length()<360){ppMarketCode = ppMarketCode+'\r\n';}
        if((ppMarketCode+'').length()>475 && (ppMarketCode+'').length()<480){ppMarketCode = ppMarketCode+'\r\n';}
        //System.debug(IItem.Asset__r.Market__c+'$$$$$$$'+ppMarketCode);
        mapPPCodeMarket.put(IItem.Asset__r.Product2.Product_abbreviation__c,ppMarketCode);
        } else {
        mapPPCodeMarket.put(IItem.Asset__r.Product2.Product_abbreviation__c,IItem.Asset__r.Market__c);
        }
        } else {
        if(IItem.Asset__r.Product2.Product_abbreviation__c!=null && IItem.Asset__r.Product2.Product_abbreviation__c!=''){
        Map<String,String> mapPPCodeMarket = new Map<String,String>();
        mapPPCodeMarket.put(IItem.Asset__r.Product2.Product_abbreviation__c,IItem.Asset__r.Market__c);
        mapProductCodeMarket.put(IItem.Invoice__c,mapPPCodeMarket);
        }
        }
        }
        //mapProductCodeMarket.put(IItem.Invoice__c,CodeZipString);
        }    
        System.debug(mapProductCodeMarket+' KKKKKKKK '+mapProductCodeMarket.values());
        Integer finalkeyval=0;
        //Updated By Pratik on 14th August 2018 for CRM-4330
        Set<Id> setInvoiceId = new Set<Id>();
        for(Invoice_Item__c IItem:[Select Invoice__c From Invoice_Item__c Where Invoice__r.Zuora__Account__c =: AccountId and Invoice__r.CreatedDate >=: BillingPeriodStartDate and Invoice__r.CreatedDate <=: BillingPeriodEndDate AND ((Asset__r.Product2.ProductCode NOT IN :lstProductCode AND Asset__r.Promotion__c NOT IN :lstPromoCode) OR (Asset__r.Product2.ProductCode IN :lstProductCode AND Charge_Amount__c >0))]){
            setInvoiceId.add(IItem.Invoice__c);
        }
        //Where Asset__r.Product2.Product_abbreviation__c!=null 
        //for (Zuora__ZInvoice__c Zinv: [Select Id, name,(Select Id,name,Asset__r.Product2.Product_abbreviation__c,Asset__r.Market__c from Invoice_Items__r where Asset__r.Product2.Product_abbreviation__c!=null ), Date_Number__c, CreatedDate, Zuora__DueDate__c,Zuora__BillingAccount__c, Zuora__Account__r.party_Id__c, Zuora__Account__r.name, Zuora__BillingAccount__r.Past_Due_Balance__c, Zuora__Balance2__c, Zuora__TotalAmount__c from Zuora__ZInvoice__c where Zuora__Account__c =: AccountId and CreatedDate >=: BillingPeriodStartDate and CreatedDate <=: BillingPeriodEndDate order by CreatedDate ASC]) {
        for (Zuora__ZInvoice__c Zinv: [Select Id, name,(Select Id,Charge_Amount__c ,name,ProductRatePlanCharge__r.zqu__Type__c ,Asset__r.Product2.Product_abbreviation__c,Asset__r.Market__c from Invoice_Items__r), Date_Number__c, CreatedDate, Zuora__DueDate__c,Zuora__BillingAccount__c, Zuora__Account__r.party_Id__c, Zuora__Account__r.name, Zuora__BillingAccount__r.Past_Due_Balance__c, Zuora__Balance2__c, Zuora__TotalAmount__c from Zuora__ZInvoice__c where Id IN:setInvoiceId order by CreatedDate ASC]) {
           
        //Ends here
            InvoiceWrapper Iwww = new InvoiceWrapper();
            mapInvoiceIdWrapper.put(Zinv.Id,Iwww);
            Integer finalkey=0;
            kkk = kkk + 1;
            if(mapDateTimeInteger.containskey(Zinv.CreatedDate)){
            finalkey = mapDateTimeInteger.get(Zinv.CreatedDate)+1;
            while(setArrangeInteger.contains(finalkey)){
            finalkey = finalkey+1;
            
            }
            setArrangeInteger.add(finalkey);
            mapDateTimeInteger.put(Zinv.CreatedDate, finalkey);
            } else {
            mapDateTimeInteger.put(Zinv.CreatedDate,Integer.valueof(Zinv.Date_Number__c)+kkk);
            }
						            
            billingaccount = Zinv.Zuora__BillingAccount__c;
            pastdueBalance = Zinv.Zuora__BillingAccount__r.Past_Due_Balance__c;
            AccountName = Zinv.Zuora__Account__r.name;
            InvoiceName = zinv.Name;
            System.debug(mapDateTimeInteger.get(Zinv.CreatedDate)+ ' PPPP '+Zinv.Name+'VVVV'+Zinv.Date_Number__c);
            partyId = zinv.Zuora__Account__r.party_Id__c;
            Integer ii = ((Zinv.CreatedDate.Year()-2015)* 1000000 + Zinv.CreatedDate.Month() * Zinv.CreatedDate.Day() * 86400 + Zinv.CreatedDate.Day() * 86400 + Zinv.CreatedDate.Hour() * 3600 + Zinv.CreatedDate.Minute() * 60 + Zinv.CreatedDate.second())*100 + kkk;
            
            AccountInvoiceWrapper aiw = new AccountInvoiceWrapper();
            aiw.ProductAB = '';
            aiw.ProductAB1 = '';
            aiw.ProductAB2 = '';
            aiw.ProductAB3 = '';
            aiw.ProductAB4 = '';
            aiw.ProductAB5 = '';
            aiw.ProductAB6 = '';
            aiw.ProductAB7 = '';
            aiw.ProductAB8 = '';
            aiw.ProductAB9 = '';
            aiw.ProductAB10 = '';
            aiw.ProductAB11 = '';
            aiw.ProductAB12 = '';
            system.debug(Zinv.CreatedDate+'$$$$$$'+mapDateTimeInteger.get(Zinv.CreatedDate));
            
            if(mapProductCodeMarket.containskey(Zinv.Id)){
            InvoiceProductZipWrapper IPZW = new InvoiceProductZipWrapper();
            Map<String,String> mapPPCodeMarket = new Map<String,String>();
            mapPPCodeMarket = mapProductCodeMarket.get(Zinv.Id);
            IPZW.InvoiceName = Zinv.Name;
            IPZW.ProductCode = '';
            IPZW.MarketCode = '';
            IPZW.RecordNumber = 0;
            IPZW.InvoiceId = '';
            for(String sttr:mapPPCodeMarket.keyset()){
            System.debug(Zinv.Id+'   '+sttr +' ********# '+ mapPPCodeMarket.get(sttr));
            if(mapPPCodeMarket.get(sttr).length()>24){
            IPZW.ProductCode = sttr;
            IPZW.MarketCode = mapPPCodeMarket.get(sttr);
            lstIPW.put(Zinv.Name+'##'+sttr,IPZW);
            }
            if(mapPPCodeMarket.get(sttr).length()<25 && mapPPCodeMarket.get(sttr).length()>2){
            System.debug(sttr +' ******** '+ aiw.ProductAB);
            aiw.ProductAB = aiw.ProductAB+ (aiw.ProductAB==''?'' :',')+sttr+(mapPPCodeMarket.get(sttr) != null ? ':'+mapPPCodeMarket.get(sttr).substring(0,(mapPPCodeMarket.get(sttr).length()>24 ? 24:(mapPPCodeMarket.get(sttr).length()))) : '') ;
            } else {
            aiw.ProductAB = aiw.ProductAB +(aiw.ProductAB==''?'' :',')+sttr;
            }
            //if(mapPPCodeMarket.get(sttr).length()>24){aiw.ProductAB1 = (aiw.ProductAB1==''?'' :',')+(mapPPCodeMarket.get(sttr) != null ? ''+mapPPCodeMarket.get(sttr).substring(24,(mapPPCodeMarket.get(sttr).length()>54 ? 54:(mapPPCodeMarket.get(sttr).length()-1))) : '\n') ;}
            //if(mapPPCodeMarket.get(sttr).length()>54){aiw.ProductAB2 = (aiw.ProductAB2==''?'' :'')+(mapPPCodeMarket.get(sttr) != null ? ''+mapPPCodeMarket.get(sttr).substring(54,(mapPPCodeMarket.get(sttr).length()>84 ? 84:(mapPPCodeMarket.get(sttr).length()-1))) : '\n') ;}
            //if(mapPPCodeMarket.get(sttr).length()>84){aiw.ProductAB3 = (aiw.ProductAB3==''?'' :'')+(mapPPCodeMarket.get(sttr) != null ? ''+mapPPCodeMarket.get(sttr).substring(84,(mapPPCodeMarket.get(sttr).length()>114 ? 114:(mapPPCodeMarket.get(sttr).length()-1))) : '\n') ;}
            //if(mapPPCodeMarket.get(sttr).length()>114){aiw.ProductAB4 = (aiw.ProductAB4==''?'' :'')+(mapPPCodeMarket.get(sttr) != null ? ''+mapPPCodeMarket.get(sttr).substring(114,(mapPPCodeMarket.get(sttr).length()>144 ? 144:(mapPPCodeMarket.get(sttr).length()-1))) : '\n') ;}
            //if(mapPPCodeMarket.get(sttr).length()>144){aiw.ProductAB5 = (aiw.ProductAB5==''?'' :'')+(mapPPCodeMarket.get(sttr) != null ? ''+mapPPCodeMarket.get(sttr).substring(144,(mapPPCodeMarket.get(sttr).length()>174 ? 174:(mapPPCodeMarket.get(sttr).length()-1))) : '\n') ;}
            //if(mapPPCodeMarket.get(sttr).length()>174){aiw.ProductAB6 = (aiw.ProductAB6==''?'' :'')+(mapPPCodeMarket.get(sttr) != null ? ''+mapPPCodeMarket.get(sttr).substring(174,(mapPPCodeMarket.get(sttr).length()>204 ? 204:(mapPPCodeMarket.get(sttr).length()-1))) : '\n') ;}
            //aiw.ProductAB7 = (aiw.ProductAB1==''?'' :',')+(mapPPCodeMarket.get(sttr) != null ? ''+mapPPCodeMarket.get(sttr).substring(204,mapPPCodeMarket.get(sttr).lenght()) : '\n') ;
            System.debug(aiw.ProductAB+'$$$$$$');
            }
            }
            if((aiw.ProductAB+'').length()<2){aiw.ProductAB='';} else {aiw.ProductAB=(aiw.ProductAB).replaceAll(',null', '');}
            aiw.RecordNumber = mapDateTimeInteger.get(Zinv.CreatedDate);
            system.debug('aiw.RecordNumber'+aiw.RecordNumber);
            aiw.CreatedDate = Zinv.CreatedDate;
            aiw.Description = Zinv.Name;
            aiw.InvoiceId = Zinv.id;
            aiw.PaymentMethod = 'CC';
            //aiw.Amount = Zinv.Zuora__BillingAccount__r.Past_Due_Balance__c;
           aiw.Amount = Zinv.Zuora__TotalAmount__c;
            aiw.Balance = Zinv.Zuora__BillingAccount__r.Past_Due_Balance__c;
            Decimal creditAmount = 0.00;
            Decimal chargeAmount = 0.00;
            //CRM-5598 Updated by praveen March 25 2019.
            for(Invoice_Item__c  inloop: Zinv.Invoice_Items__r){
                if(inloop.ProductRatePlanCharge__r.zqu__Type__c =='One-Time' && inloop.Charge_Amount__c < 0 ){
                     creditAmount += inloop.Charge_Amount__c;
                }else{
                   chargeAmount += inloop.Charge_Amount__c; 
                }             
            }
            //aiw.Amount = chargeAmount;
             totalCreditAmount += creditAmount;
            //System.debug('#### '+totalInvoiceBalance + Zinv.Zuora__TotalAmount__c + creditAmount);
            totalInvoiceBalance = totalInvoiceBalance + chargeAmount;
            mapAccountInvoiceWrapper.put(aiw.RecordNumber, aiw);
            system.debug('aiw.RecordNumber'+aiw.RecordNumber);
            finalkeyval = aiw.RecordNumber;
        }
        System.debug(lstIPW+'*******');
        totalfinalBalance = (totalBalance != null ? totalBalance : 0) +  (pastdueBalance != null ? pastdueBalance : 0);
        
        for(Zuora__Payment__c zpp:[Select Id,name, DoNotConsider__c, Zuora__BillingAccount__c,Zuora__AppliedInvoiceAmount__c,Zuora__AppliedCreditBalanceAmount__c, Zuora__Invoice__c, CreatedDate ,Credit_Card_Holder_name__c,Zuora__Comment__c,Zuora__Effective_Date__c,Zuora__Status__c,Zuora__PaymentMethod__c,Zuora__Amount__c from Zuora__Payment__c where Zuora__Account__c=:AccountId and Zuora__Status__c = 'Processed' and DoNotConsider__c!='Ignore' and CreatedDate >=: BillingPeriodStartDate and CreatedDate <=: BillingPeriodEndDate order by CreatedDate ASC]){
        billingaccount = zpp.Zuora__BillingAccount__c;
        mapPaymentIds.put(zpp.Id,zpp);
        }

        Integer jjj=1;
        for (Zuora__PaymentInvoice__c zpi: [Select Id,Zuora__Payment__r.Zuora__BillingAccount__c, Date_Number__c, Zuora__ApplyAmount__c ,CreatedDate, Zuora__Invoice__r.Name,Zuora__Payment__c,Zuora__Payment__r.DoNotConsider__c, Zuora__Payment__r.Credit_Card_Holder_name__c, Zuora__Invoice__c, name, Zuora__Payment__r.Zuora__Comment__c, Zuora__Payment__r.Zuora__Effective_Date__c, Zuora__Payment__r.Zuora__Amount__c, Zuora__Payment__r.Zuora__Status__c, Zuora__Payment__r.Zuora__PaymentMethod__c from Zuora__PaymentInvoice__c where Zuora__Payment__r.Zuora__Account__c =: AccountId and Zuora__Payment__r.DoNotConsider__c!='Ignore' and Zuora__Payment__r.Zuora__Status__c = 'Processed'
                and CreatedDate >=: BillingPeriodStartDate and CreatedDate <=: BillingPeriodEndDate order by CreatedDate ASC
            ]) {
            if(mapPaymentIds.containskey(zpi.Zuora__Payment__c) && mapPaymentIds.get(zpi.Zuora__Payment__c).Zuora__AppliedCreditBalanceAmount__c<0.01){
            if(!Test.isRunningTest()){mapPaymentIds.remove(zpi.Zuora__Payment__c);}
            }
            Integer finalkey=0;
            kkk = kkk + 1;
            if(mapDateTimeInteger.containskey(zpi.CreatedDate)){
            finalkey = mapDateTimeInteger.get(zpi.CreatedDate)+1;
            while(setArrangeInteger.contains(finalkey)){
            finalkey = finalkey+1;
            
            }
            setArrangeInteger.add(finalkey);
            //if(!setArrangeInteger.contains(finalkey)){setArrangeInteger.add(finalkey);}
            
            mapDateTimeInteger.put(zpi.CreatedDate, finalkey);
            } else {               
            finalkey = Integer.valueof(zpi.Date_Number__c)+kkk;//mapDateTimeInteger.get(zrip.CreatedDate)+1;
            while(setArrangeInteger.contains(finalkey)){
            finalkey = finalkey+1;
            }
            setArrangeInteger.add(finalkey);
            mapDateTimeInteger.put(zpi.CreatedDate,Integer.valueof(zpi.Date_Number__c)+kkk);
               
            }
            System.debug(zpi.Zuora__Invoice__c+ ' PPPP '+zpi.CreatedDate);
            Integer ii = zpi.CreatedDate.Year() * 1000000 + zpi.CreatedDate.Month() * 10000 + zpi.CreatedDate.Day() * 1000 + zpi.CreatedDate.Hour() * 60 + zpi.CreatedDate.Minute() * 1 + Integer.valueOf(zpi.CreatedDate.second() *(0.1)) + jjj;
            AccountInvoiceWrapper aiw = new AccountInvoiceWrapper();
            aiw.RecordNumber = mapDateTimeInteger.get(zpi.CreatedDate);
            system.debug('aiw.RecordNumber'+aiw.RecordNumber);
            aiw.INVType = 'Payment';
            aiw.CreatedDate = zpi.CreatedDate;
            aiw.Description = zpi.Name;
            aiw.InvoiceId = zpi.Zuora__Invoice__c;
            billingaccount = zpi.Zuora__Payment__r.Zuora__BillingAccount__c;
            aiw.InvoiceName = zpi.Zuora__Invoice__r.name;
            System.debug(aiw.InvoiceName +' = '+zpi.Zuora__Invoice__r.name);
            //aiw.InvoiceName = null;
            aiw.PaymentMethod = zpi.Zuora__Payment__r.Zuora__PaymentMethod__c;
            aiw.CardHolderName = zpi.Zuora__Payment__r.Credit_Card_Holder_name__c;
            aiw.Amount = zpi.Zuora__ApplyAmount__c;
            aiw.Balance = zpi.Zuora__Payment__r.Zuora__Amount__c;
            aiw.DoNotConsider = (zpi.Zuora__Payment__r.DoNotConsider__c=='Yes'? true :false);
            if(zpi.Zuora__Payment__r.DoNotConsider__c!='Yes'){totalPayment = totalPayment + zpi.Zuora__ApplyAmount__c; System.debug(zpi.ID);}
            if(zpi.Zuora__Payment__r.DoNotConsider__c=='Yes'){totalCreditAdjustment = totalCreditAdjustment + zpi.Zuora__ApplyAmount__c;}
            system.debug('aiw.RecordNumber'+totalPayment);
            mapAccountInvoiceWrapper.put(aiw.RecordNumber, aiw);
            finalkeyval = aiw.RecordNumber;
        }
        Map<Id,Zuora__RefundInvoicePayment__c> mapRefundPayments = new Map<Id,Zuora__RefundInvoicePayment__c>();
        for (Zuora__RefundInvoicePayment__c zrip: [Select Id, Date_Number__c ,CreatedDate,Zuora__InvoicePayment__r.Zuora__Payment__r.Zuora__PaymentMethod__c, Zuora__Refund__c,Zuora__Refund__r.Do_Not_Consider__c, Zuora__Refund__r.Zuora__PaymentMethod__c, name,Zuora__InvoicePayment__r.Zuora__Payment__r.Credit_Card_Holder_name__c, Zuora__RefundAmount__c,Zuora__InvoicePayment__r.Zuora__Invoice__r.Name, Zuora__InvoicePayment__r.Zuora__Invoice__c from Zuora__RefundInvoicePayment__c where  Zuora__InvoicePayment__r.Zuora__Invoice__r.Zuora__Account__c =: AccountId and Zuora__Refund__r.Do_Not_Consider__c!='Ignore' and CreatedDate >=: BillingPeriodStartDate and CreatedDate <=: BillingPeriodEndDate]) { //Zuora__InvoicePayment__r.Zuora__Invoice__c =: mapInvoiceIdWrapper.keyset()]){//
            //mapInvoiceIdWrapper.get(zrip.Zuora__InvoicePayment__r.Zuora__Invoice__c).zinvrefund.add(zrip);
            //mapInvoiceIdWrapper.get(zrip.Zuora__InvoicePayment__r.Zuora__Invoice__c).zinvrefund.add(zrip);
            //mapInvoiceRefund.put(zrip.Zuora__InvoicePayment__r.Zuora__Invoice__c,zrip.Zuora__RefundAmount__c);
            
            mapRefundPayments.put(zrip.Zuora__Refund__c,zrip);
            Integer finalkey=0;
            kkk = kkk + 1;
            if(mapDateTimeInteger.containskey(zrip.CreatedDate)){
            finalkey = mapDateTimeInteger.get(zrip.CreatedDate)+1;
            while(setArrangeInteger.contains(finalkey)){
            finalkey = finalkey+1;
            }
            setArrangeInteger.add(finalkey);
            
            mapDateTimeInteger.put(zrip.CreatedDate, finalkey);
            } else {
            finalkey = Integer.valueof(zrip.Date_Number__c)+kkk;//mapDateTimeInteger.get(zrip.CreatedDate)+1;
            while(setArrangeInteger.contains(finalkey)){
            finalkey = finalkey+1;
            }
            setArrangeInteger.add(finalkey);
            mapDateTimeInteger.put(zrip.CreatedDate,finalkey);
            }
            //System.debug(zpi.Zuora__Invoice__c+ ' PPPP '+zpi.CreatedDate);
            Integer ii = zrip.CreatedDate.Year() * 1000000 + zrip.CreatedDate.Month() * 10000 + zrip.CreatedDate.Day() * 1000 + zrip.CreatedDate.Hour() * 60 + zrip.CreatedDate.Minute() * 1 + Integer.valueOf(zrip.CreatedDate.second() *(0.1)) + jjj;
            AccountInvoiceWrapper aiw = new AccountInvoiceWrapper();
            aiw.RecordNumber = mapDateTimeInteger.get(zrip.CreatedDate);
            aiw.INVType = 'Refund';
            system.debug('aiw.RecordNumber'+aiw.RecordNumber);
            aiw.CreatedDate = zrip.CreatedDate;
            aiw.Description = zrip.Name;
            aiw.InvoiceId = zrip.Zuora__InvoicePayment__r.Zuora__Invoice__c;
            aiw.InvoiceName = zrip.Zuora__InvoicePayment__r.Zuora__Invoice__r.name;
            //System.debug(aiw.InvoiceName +' = '+zpi.Zuora__Invoice__r.name);
            //aiw.InvoiceName = null;
            aiw.PaymentMethod = (zrip.Zuora__InvoicePayment__r.Zuora__Payment__r.Zuora__PaymentMethod__c==null?'' :zrip.Zuora__InvoicePayment__r.Zuora__Payment__r.Zuora__PaymentMethod__c);//zrip.Zuora__Refund__r.Zuora__PaymentMethod__c;
            aiw.CardHolderName = (zrip.Zuora__InvoicePayment__r.Zuora__Payment__r.Credit_Card_Holder_name__c==null?'' :zrip.Zuora__InvoicePayment__r.Zuora__Payment__r.Credit_Card_Holder_name__c);// zrip.Zuora__InvoicePayment__r.Zuora__Payment__r.Credit_Card_Holder_name__c;
            aiw.Amount = zrip.Zuora__RefundAmount__c;
            aiw.Balance = zrip.Zuora__RefundAmount__c;
            aiw.DoNotConsider = (zrip.Zuora__Refund__r.Do_Not_Consider__c=='Yes'? true :false);
            if(zrip.Zuora__Refund__r.Do_Not_Consider__c=='Yes'){totalDebitAdjustment = totalDebitAdjustment + zrip.Zuora__RefundAmount__c;}
            if(zrip.Zuora__Refund__r.Do_Not_Consider__c!='Yes'){totalRefund = totalRefund + zrip.Zuora__RefundAmount__c;}
            //totalPayment = totalPayment;// + zrip.Zuora__RefundAmount__c;
            system.debug('aiw.RecordNumber'+aiw.DoNotConsider+'KKK'+aiw.InvoiceName);
            mapAccountInvoiceWrapper.put(aiw.RecordNumber, aiw);
            finalkeyval = aiw.RecordNumber;
        }
        
        for (Zuora__Payment__c zpp: mapPaymentIds.values()) {
            
            Integer ii = zpp.CreatedDate.Year() * 1000000 + zpp.CreatedDate.Month() * 10000 + zpp.CreatedDate.Day() * 1000 + zpp.CreatedDate.Hour() * 60 + zpp.CreatedDate.Minute() * 1 + Integer.valueOf(zpp.CreatedDate.second() *(0.1)) + jjj;
            kkk = kkk + 1;
            if(mapDateTimeInteger.containskey(zpp.CreatedDate)){
            finalkeyval = mapDateTimeInteger.get(zpp.CreatedDate)+1;
            while(setArrangeInteger.contains(finalkeyval)){
            finalkeyval = finalkeyval+1;
            }
            setArrangeInteger.add(finalkeyval);
            
            mapDateTimeInteger.put(zpp.CreatedDate, finalkeyval);
            } else {
                 //CRM-5889 Praveen Payment without invoice is not displaying in Account statement.Start
            finalkeyval = ii+kkk;
            while(setArrangeInteger.contains(finalkeyval)){
            finalkeyval = finalkeyval+1;
            }
            setArrangeInteger.add(finalkeyval);
            mapDateTimeInteger.put(zpp.CreatedDate,finalkeyval);
                //End
            }
            AccountInvoiceWrapper aiw = new AccountInvoiceWrapper();
            aiw.RecordNumber = finalkeyval;//mapDateTimeInteger.get(zpp.CreatedDate);
            system.debug('aiw.RecordNumber'+aiw.RecordNumber);
            aiw.INVType = 'Payment';
            aiw.CreatedDate = zpp.CreatedDate;
            aiw.Description = zpp.Name;
            aiw.InvoiceId = zpp.Zuora__Invoice__c;
            aiw.InvoiceName = zpp.name;
            //System.debug(aiw.InvoiceName +' = '+zpp.Zuora__Invoice__r.name);
            //aiw.InvoiceName = null;
            aiw.PaymentMethod = zpp.Zuora__PaymentMethod__c;
            aiw.CardHolderName = zpp.Credit_Card_Holder_name__c;
            aiw.Amount = (zpp.Zuora__AppliedCreditBalanceAmount__c>0? zpp.Zuora__AppliedCreditBalanceAmount__c :zpp.Zuora__Amount__c);
            aiw.Balance = (zpp.Zuora__AppliedCreditBalanceAmount__c>0? zpp.Zuora__AppliedCreditBalanceAmount__c :zpp.Zuora__Amount__c);
            
            aiw.DoNotConsider = (zpp.DoNotConsider__c=='Yes'? true :false);
            if(zpp.DoNotConsider__c=='Yes'){totalCreditAdjustment = totalCreditAdjustment + (zpp.Zuora__AppliedCreditBalanceAmount__c>0? zpp.Zuora__AppliedCreditBalanceAmount__c :zpp.Zuora__Amount__c);}
             if(zpp.DoNotConsider__c!='Yes'){totalPayment = totalPayment + (zpp.Zuora__AppliedCreditBalanceAmount__c>0? zpp.Zuora__AppliedCreditBalanceAmount__c :zpp.Zuora__Amount__c);}
            system.debug('aiw.RecordNumber'+totalPayment);
            mapAccountInvoiceWrapper.put(aiw.RecordNumber, aiw);
            //finalkeyval = finalkeyval+1;
        }
        
        for (Zuora__Refund__c refund: [Select Id, name, Zuora__Amount__c,Do_Not_Consider__c, CreatedDate from Zuora__Refund__c where Zuora__Account__c =: AccountId and Do_Not_Consider__c!='Ignore' and CreatedDate >=: BillingPeriodStartDate and CreatedDate <=: BillingPeriodEndDate and Id!=:mapRefundPayments.keyset()]) {
           // totalRefund = totalRefund + refund.Zuora__Amount__c;
            
           
            //System.debug(zpi.Zuora__Invoice__c+ ' PPPP '+zpi.CreatedDate);
            Integer ii = refund.CreatedDate.Year() * 1000000 + refund.CreatedDate.Month() * 10000 + refund.CreatedDate.Day() * 1000 + refund.CreatedDate.Hour() * 60 + refund.CreatedDate.Minute() * 1 + Integer.valueOf(refund.CreatedDate.second() *(0.1)) + jjj;
            Integer finalkey=0;
            kkk = kkk + 1;
            if(mapDateTimeInteger.containskey(refund.CreatedDate)){
            finalkey = mapDateTimeInteger.get(refund.CreatedDate)+1;
            while(setArrangeInteger.contains(finalkey)){
            finalkey = finalkey+1;
            }
            setArrangeInteger.add(finalkey);
            
            mapDateTimeInteger.put(refund.CreatedDate, finalkey);
            } else {
            //mapDateTimeInteger.put(refund.CreatedDate,Integer.valueof(refund.Date_Number__c)+kkk);
            }
            AccountInvoiceWrapper aiw = new AccountInvoiceWrapper();
            aiw.RecordNumber = ii;mapDateTimeInteger.get(refund.CreatedDate);
            aiw.INVType = 'Refund';
            system.debug('aiw.RecordNumber'+aiw.RecordNumber);
            aiw.CreatedDate = refund.CreatedDate;
            aiw.Description = refund.Name;
            // CRM-5140: Assigning invoiceid to "null" instead of '' (To fix Invalid Id error)
            aiw.InvoiceId = null;
            //aiw.InvoiceName = refund.Zuora__InvoicePayment__r.Zuora__Invoice__r.name;
            //System.debug(aiw.InvoiceName +' = '+zpi.Zuora__Invoice__r.name);
            //aiw.InvoiceName = null;
            aiw.PaymentMethod = 'Other';//(zrip.Zuora__InvoicePayment__r.Zuora__Payment__r.Zuora__PaymentMethod__c==null?'' :zrip.Zuora__InvoicePayment__r.Zuora__Payment__r.Zuora__PaymentMethod__c);//zrip.Zuora__Refund__r.Zuora__PaymentMethod__c;
            //aiw.CardHolderName = (zrip.Zuora__InvoicePayment__r.Zuora__Payment__r.Credit_Card_Holder_name__c==null?'' :zrip.Zuora__InvoicePayment__r.Zuora__Payment__r.Credit_Card_Holder_name__c);// zrip.Zuora__InvoicePayment__r.Zuora__Payment__r.Credit_Card_Holder_name__c;
            aiw.Amount = refund.Zuora__Amount__c;
            aiw.Balance = refund.Zuora__Amount__c;
            aiw.DoNotConsider = (refund.Do_Not_Consider__c=='Yes'? true :false);
            if(aiw.DoNotConsider==true){totalDebitAdjustment = totalDebitAdjustment + refund.Zuora__Amount__c;}
            if(aiw.DoNotConsider==false){totalRefund = totalRefund + refund.Zuora__Amount__c;}
            System.debug(totalDebitAdjustment+'HHHHHHHHHH'+totalRefund +'Id'+refund.id);
            //totalPayment = totalPayment;// + zrip.Zuora__RefundAmount__c;
            system.debug('aiw.RecordNumber'+totalPayment);
            mapAccountInvoiceWrapper.put(aiw.RecordNumber, aiw);
            finalkeyval = aiw.RecordNumber;
            
        }
        for (CreditBalanceAdjustment__c zrip: [Select Id, CreatedDate,Source__c, Adjustment_Date__c, AdjustmentStatus__c,Invoice__c, Zuora_Amount__c, name  from CreditBalanceAdjustment__c where Invoice__c =: mapInvoiceIdWrapper.keyset() and CreatedDate >=: BillingPeriodStartDate and CreatedDate <=: BillingPeriodEndDate]) {
            mapInvoiceRefund.put(zrip.Invoice__c,zrip.Zuora_Amount__c);
        }
        for(Invoice_Item_Adjustment__c iia:[Select Id,name,Invoice__r.name, CreatedDate, Adjustment_Date__c ,Amount__c, Type__c ,Invoice_Item__c,Invoice__c from Invoice_Item_Adjustment__c where Invoice_Item__r.Billing_Account__c =:billingaccount and CreatedDate >=: BillingPeriodStartDate and CreatedDate <=: BillingPeriodEndDate]){ // Invoice__c=: mapInvoiceIdWrapper.keyset()
        Integer ii = iia.CreatedDate.Year() * 1000000 + iia.CreatedDate.Month() * 10000 + iia.CreatedDate.Day() * 1000 + iia.CreatedDate.Hour() * 60 + iia.CreatedDate.Minute() * 1 + Integer.valueOf(iia.CreatedDate.second() *(0.1)) + jjj;
            AccountInvoiceWrapper aiw = new AccountInvoiceWrapper();
            aiw.RecordNumber = finalkeyval+1;//mapDateTimeInteger.get(zpp.CreatedDate);
            system.debug('aiw.RecordNumber'+aiw.RecordNumber);
            aiw.INVType = 'IIA';
            aiw.CreatedDate = iia.CreatedDate;
            aiw.Description = iia.Name;
            aiw.InvoiceId = iia.Invoice__c;
            aiw.InvoiceName = iia.Invoice__r.name;
            //System.debug(aiw.InvoiceName +' = '+zpp.Zuora__Invoice__r.name);
            //aiw.InvoiceName = null;
            aiw.PaymentMethod = 'CC';//iia.Zuora__PaymentMethod__c;
            aiw.CardHolderName = '';//iia.Credit_Card_Holder_name__c;
            aiw.Amount = iia.Amount__c;
            aiw.Balance = iia.Amount__c;
            if(iia.Type__c=='Credit'){
            aiw.Amount = iia.Amount__c*-1;
            aiw.Balance = iia.Amount__c*-1;
            }
            
            //totalPayment = totalPayment + iia.Amount__c;
            system.debug('aiw.RecordNumber'+totalPayment);
            mapAccountInvoiceWrapper.put(aiw.RecordNumber, aiw);
            finalkeyval = finalkeyval+1;
        
        Decimal iiamount = 0;
        iiamount = iia.Amount__c;
        System.debug(iia.Amount__c+'LLLL');
        if(iia.Type__c=='Credit'){iiamount = -iia.Amount__c;}
        totalInvoiceBalance = totalInvoiceBalance + iiamount;
        if(mapIIA.containskey(iia.Invoice__c)){
        Decimal Amtt = mapIIA.get(iia.Invoice__c);
        Amtt = Amtt + iiamount;
        mapIIA.put(iia.Invoice__c,Amtt);
        } else {
        mapIIA.put(iia.Invoice__c,iiamount);
        }
        }
        System.debug(mapIIA.values()+'LLLL');
        System.debug(totalCreditAdjustment+'Total Adjustments'+totalDebitAdjustment);
        lstInvoiceWrapper = mapInvoiceIdWrapper.values();
        
        lstlstAccInvoiceWrapper = getMYlstAccountInvoiceWrapper();
    }
    
    Public List<InvoiceProductZipWrapper> getlstIvoiceProductZips(){
        system.debug(lstIPW.keyset()+'PPPPPP'+lstIPW.values().size());
        Map<String,InvoiceProductZipWrapper> mapNewWrapper = new Map<String,InvoiceProductZipWrapper>();
        List<String> lstMaketCodeadd = new List<String>();
        for(InvoiceProductZipWrapper ipz:lstIPW.values()){
        system.debug(lstIPW.keyset()+'PPPPPP'+ipz.MarketCode.length());
        if(ipz.MarketCode.length()<200){
        lstMaketCodeadd.add(ipz.MarketCode);
        } else if(ipz.MarketCode.length()>200){
        for(Integer ii=0;ii<ipz.MarketCode.length();ii+1){
        Integer jj = (ii+131);
        if(jj>ipz.MarketCode.length()){jj=ipz.MarketCode.length();}
        lstMaketCodeadd.add(ipz.MarketCode.substring(ii, jj));
        ii=ii+131;
        }
        } 
        ipz.lstMarketCode.AddAll(lstMaketCodeadd);
        mapNewWrapper.put(ipz.InvoiceName+''+ipz.ProductCode,ipz);
        }
    
        return mapNewWrapper.values();
    }
    
    Public List<List < AccountInvoiceWrapper >> getlstAccountInvoiceWrapper() {
    return lstlstAccInvoiceWrapper;
    }
    Public List<List < AccountInvoiceWrapper >> getMYlstAccountInvoiceWrapper() {
        List<List<AccountInvoiceWrapper>> lstlstAccInvoiceWrapper = new List<List<AccountInvoiceWrapper>>();
        List < AccountInvoiceWrapper > lstAccInvoiceWrapper = new List < AccountInvoiceWrapper > ();
        List < Integer > lstIntegers = new List < Integer > ();
        lstIntegers.addAll(mapAccountInvoiceWrapper.keyset());
        lstIntegers.sort();
        Integer firstIndex;
        System.debug(lstIntegers+'LLLLL');
        if(lstIntegers.size()>0){firstIndex = lstIntegers[0];}
        Decimal TotalBalanceCalculated = 0;
        for (Integer ii: lstIntegers) {
            System.debug(firstIndex +'PPPPPPPP'+ii);
            
            AccountInvoiceWrapper accInvWrapper = mapAccountInvoiceWrapper.get(ii);
            System.debug(accInvWrapper.Amount + 'MMMMM');
            if(mapIIA.containskey(accInvWrapper.InvoiceId)){System.debug(accInvWrapper.InvoiceId+'Yes IIA'+mapIIA.get(accInvWrapper.InvoiceId));//accInvWrapper.Amount = accInvWrapper.Amount+mapIIA.get(accInvWrapper.InvoiceId);
                                                           }
            System.debug(accInvWrapper.Amount + 'MMMMM');
            System.debug(accInvWrapper.Balance +'PPPPPP'+ accInvWrapper.RecordNumber);
            if(firstIndex==ii){
                System.debug(TotalBalanceCalculated + 'MYTotalBalanceCalculated');
                if(accInvWrapper.InvoiceName!=null && accInvWrapper.INVType!='Payment'){TotalBalanceCalculated = totalBalanceBegining + accInvWrapper.Amount;}
                if(accInvWrapper.InvoiceName!=null && accInvWrapper.INVType=='Payment'){TotalBalanceCalculated = totalBalanceBegining - accInvWrapper.Amount;
                                                                                        System.debug(TotalBalanceCalculated + 'MYTotalBalanceCalculated');
                                                                                       } 
                //System.debug(TotalBalanceCalculated + 'MYTotalBalanceCalculated');
                else{
                    TotalBalanceCalculated = accInvWrapper.Amount+totalBalanceBegining;
                    System.debug(TotalBalanceCalculated + 'MYTotalBalanceCalculated');
                }
            }
            else {
                if(accInvWrapper.InvoiceName!=null){
                    if(accInvWrapper.INVType =='Refund' || accInvWrapper.INVType =='IIA'){
                        TotalBalanceCalculated = TotalBalanceCalculated + accInvWrapper.Amount;
                        System.debug(TotalBalanceCalculated + 'MYTotalBalanceCalculated');
                    }
                    else {
                        TotalBalanceCalculated = TotalBalanceCalculated - accInvWrapper.Amount;
                        System.debug(TotalBalanceCalculated + 'MYTotalBalanceCalculated');
                    }
                }
                else{
                    TotalBalanceCalculated = TotalBalanceCalculated + accInvWrapper.Amount;
                    System.debug(TotalBalanceCalculated + 'MYTotalBalanceCalculated');
                }
            }
            System.debug(TotalBalanceCalculated + 'MYTotalBalanceCalculated');
            accInvWrapper.Balance = TotalBalanceCalculated;
            accInvWrapper.PaymentMethod = (accInvWrapper.PaymentMethod+'').replace('Credit Card ','');
            totalBalanceEnding = TotalBalanceCalculated;
            System.debug(TotalBalanceCalculated + 'MYTotalBalanceCalculated'+totalBalanceEnding);
            accInvWrapper.RefundIssued = 0;accInvWrapper.CreditIssued = 0;
            if(mapInvoiceRefund.containskey(accInvWrapper.InvoiceId)){accInvWrapper.RefundIssued = mapInvoiceRefund.get(accInvWrapper.InvoiceId);}
            if(mapInvoiceCredit.containskey(accInvWrapper.InvoiceId)){accInvWrapper.CreditIssued = mapInvoiceCredit.get(accInvWrapper.InvoiceId);}
            
            lstAccInvoiceWrapper.add(accInvWrapper);
            if(lstAccInvoiceWrapper.size()==999){
                lstlstAccInvoiceWrapper.add(lstAccInvoiceWrapper);
                lstAccInvoiceWrapper.clear();
            }
            
        }
        if(lstAccInvoiceWrapper.size()<999){
            lstlstAccInvoiceWrapper.add(lstAccInvoiceWrapper);
            //lstAccInvoiceWrapper.clear();
        }
        return lstlstAccInvoiceWrapper;
    }
    
    Public List < AccountInvoiceWrapper > getlstAccountInvoiceWrapper1() {
        List < AccountInvoiceWrapper > lstAccInvoiceWrapper = new List < AccountInvoiceWrapper > ();
       
        return lstAccInvoiceWrapper;
    }
    
    
     //CRM-3254: If logged in user is community user, then verify if user account is same as accountId passed in parameter.
     public pageReference validateCommunityUser(){
        String accId = '001j000000000';
        if (ApexPages.currentPage().getParameters().get('id') != null) {
            accId = ApexPages.currentPage().getParameters().get('id');
        }
        return verifyCommunityUserAccount(accId);
    }
    
    public pageReference verifyCommunityUserAccount(Id accId){
        // 'FederationIdentifier' field is used to store the account advertiser Id
        List<User> ul = [Select id, FederationIdentifier from User where id = :userInfo.getUserId() and Profile.name = :Label.CustomerDashboardProfile];
        if(ul.size() > 0){
            List<Account> accL = [Select id, Advertiserid__c from Account where Advertiserid__c =:ul[0].FederationIdentifier and Id =:accId];
            If(accL.size() == 0){
                PageReference pr = new PageReference(Label.CustomerCommunityDomain +'/CustomerDashboardErrorPage');
                pr.setRedirect(true);
                return pr;
            }
        }
        return null;
    }
    public Double offset{get{
        TimeZone tz = UserInfo.getTimeZone();
        //Milliseconds to Day
        return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
    }}
}