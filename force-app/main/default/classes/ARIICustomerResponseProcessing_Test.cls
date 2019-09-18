//Name        : ARIICustomerResponseProcessing_Test
//Description : Test class for ARCustomerResponseProcessing.
//Author      : Pallavi Tammana

@isTest(seeAllData =false)
public  class ARIICustomerResponseProcessing_Test {

    public static testMethod void mainMethod1() {
        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        Business_Hours__c bh = new Business_Hours__c(name = 'OwnChange', Lowermin__c = 450, UpMin__c = 950);
        insert bh;
        Business_Hours__c bh1 = new Business_Hours__c(name = 'StatusChange', Lowermin__c = 450, UpMin__c = 950);
        insert bh1;
        
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
        testAccount.Primary_Email__c = 'testAccount@move.com';
        testAccount.Account_Sub_Type__c = 'Customer';
        testAccount.Auto_Renewal__c = true;
        insert testAccount;
        
        Contact myContact2 = new Contact ();
        myContact2.FirstName='Joe2';
        myContact2.LastName='Schmoe2';
        myContact2.Email='Joe.Schmoe2@test.de';
        myContact2.Account= testAccount;
        myContact2.Phone= '2131231233';
        myContact2.Type__c = 'Other';
        myContact2.Active__c = true;
        insert myContact2;
            
        Product2 newProduct                 = new Product2();
        newProduct.Name                     = 'Test Product';
        newProduct.Commission_Category__c   = 'Normal';    
        newProduct.Normalization_factor__c  = 1.10;
        newProduct.Commission_Category__c   = 'CFCB';
        newProduct.Fulfillment_Type__c      = 'Manual';
        newProduct.Auto_Renewal__c          = True;
        newProduct.ProductCode              ='SELLERLEADBUNDLE' ;
        newProduct.S_No__c                  = 2;
        newProduct.Orderable__c             = True;
        insert newProduct;
        
         Asset assets = new Asset();
            assets.Name = 'test';
            assets.Renewal_Status__c = 'Renew';
            assets.Auto_Renewal__c = 'Yes';
            assets.Asset_Type__c = 'Parent';
            assets.AccountId = testAccount.id;
            assets.Fulfillment_Status__c = 'Fulfilled';
            assets.Status = 'Active';
            assets.Line_Type__c = 'Backout Credit';
            assets.Billing_Period__c = 'Monthly';
            assets.Start_Date__c = system.today();
            assets.End_Date__c = System.today().addMonths(1);
            assets.Product2Id = newProduct.id;
            assets.Inflight_Quote__c = null;
            assets.AutoRenewalPicked__c = true;
            assets.Renewal_Type__c = 'Auto';
            assets.Follow_Up_Status__c = '';
            insert assets;       
        
        List<Lead> LedAutoRenewal = new List<Lead>();
        Test.startTest();
        
        Lead ld = new Lead();
        ld.LastName = 'Mr';
        ld.FirstName = 'Test';
        ld.Status = 'New';
        ld.Company = 'Test';
        ld.Contact__c = myContact2.id;
        ld.Phone = '(860) 347-0333';
        ld.Email = 'c.s1@gmail.com';
        ld.Marketing_Lead_Type__c = 'Auto-Renew';
      //  ld.CustomerResponse__c = assets.Id+',50.00,100.00,Renew: Pay-in-full,3,CBC10OFF51PLUS,10,CBC10OFF51PLUS,10,No;';
        ld.CustomerResponse__c = assets.Id+',66.00,712.80,Renew,12,CBC10OFF51PLUS,10.00,6.60,,,,,,No,792.00;';
        ld.CustomerResponseProcessed__c = false;
        LedAutoRenewal.add(ld);       
        //insert ld;
        
        insert LedAutoRenewal;
        
        Test.stopTest();
     
     }
     
     public static testMethod void mainMethod2() {
        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        Business_Hours__c bh = new Business_Hours__c(name = 'OwnChange', Lowermin__c = 450, UpMin__c = 950);
        insert bh;
        Business_Hours__c bh1 = new Business_Hours__c(name = 'StatusChange', Lowermin__c = 450, UpMin__c = 950);
        insert bh1;
        
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
        testAccount.Primary_Email__c = 'testAccount@move.com';
        testAccount.Account_Sub_Type__c = 'Customer';
        testAccount.Auto_Renewal__c = true;
        insert testAccount;
        
        Contact myContact2 = new Contact ();
        myContact2.FirstName='Joe2';
        myContact2.LastName='Schmoe2';
        myContact2.Email='Joe.Schmoe2@test.de';
        myContact2.Account= testAccount;
        myContact2.Phone= '2131231233';
        myContact2.Type__c = 'Other';
        myContact2.Active__c = true;
        insert myContact2;
            
        Product2 newProduct                 = new Product2();
        newProduct.Name                     = 'Test Product';
        newProduct.Commission_Category__c   = 'Normal';    
        newProduct.Normalization_factor__c  = 1.10;
        newProduct.Commission_Category__c   = 'CFCB';
        newProduct.Fulfillment_Type__c      = 'Manual';
        newProduct.Auto_Renewal__c          = True;
        newProduct.ProductCode              ='SELLERLEADBUNDLE' ;
        newProduct.S_No__c                  = 2;
        newProduct.Orderable__c             = True;
        insert newProduct;
        
         Asset assets = new Asset();
            assets.Name = 'test';
            assets.Auto_Renewal__c = 'Yes';
            assets.Asset_Type__c = 'Parent';
            assets.AccountId = testAccount.id;
            assets.Status = 'Active';
            assets.Line_Type__c = 'Backout Credit';
            assets.Billing_Period__c = 'Monthly';
            assets.Start_Date__c = system.today();
            assets.End_Date__c = System.today().addMonths(1);
            assets.Product2Id = newProduct.id;
            assets.Inflight_Quote__c = null;
            assets.AutoRenewalPicked__c = true;
            assets.Renewal_Type__c = 'Auto';
            assets.Follow_Up_Status__c = '';
            insert assets;
        
        List<Lead> LedAutoRenewal = new List<Lead>();
        Test.startTest();
        
        Lead ld1 = new Lead();
        ld1.LastName = 'Mr';
        ld1.FirstName = 'Test';
        ld1.Status = 'New';
        ld1.Company = 'Test';
        ld1.Contact__c = myContact2.id;
        ld1.Phone = '(860) 347-0333';
        ld1.Email = 'c.s1@gmail.com';
        ld1.Marketing_Lead_Type__c = 'Auto-Renew';
       // ld1.CustomerResponse__c = assets.Id+',50.00,100.00,Renew,3,CBC10OFF51PLUS,10,CBC10OFF51PLUS,10,Yes;';
       ld1.CustomerResponse__c = assets.Id+',66.00,712.80,Renew,12,CBC10OFF51PLUS,10.00,6.60,,,,,,No,792.00;';//02ij0000004DjOiAAK,154.00,1663.20,Renew,12,CBC10OFF51PLUS,10.00,15.40,,,,,,No,1848.00;02ij00000043Zp2AAE,178.00,1922.40,Renew,12,CBC10OFF51PLUS,10.00,17.80,,,,,,No,2136.00;02ij00000043Zj9AAE,40.00,432.00,Renew,12,CBC10OFF51PLUS,10.00,4.00,,,,,,No,480.00;02ij00000043ZnGAAU,161.00,1738.80,Renew,12,CBC10OFF51PLUS,10.00,16.10,,,,,,No,1932.00;02ij00000043ZeOAAU,78.00,842.40,Renew,12,CBC10OFF51PLUS,10.00,7.80,,,,,,No,936.00;02ij0000004358bAAA,321.00,6933.60,Renew,12,CBC10OFF51PLUS,10.00,32.10,,,,,,No,7704.00;02ij0000004357xAAA,240.00,5184.00,Renew,12,CBC10OFF51PLUS,10.00,24.00,,,,,,No,5760.00;02ij00000043ZbSAAU,120.00,1296.00,Renew,12,CBC10OFF51PLUS,10.00,12.00,,,,,,No,1440.00;02ij00000043ZY1AAM,213.00,2300.40,Renew,12,CBC10OFF51PLUS,10.00,21.30,,,,,,No,2556.00;02ij00000043ZbPAAU,98.00,1058.40,Renew,12,CBC10OFF51PLUS,10.00,9.80,,,,,,No,1176.00;
        ld1.CustomerResponseProcessed__c = false;
        LedAutoRenewal.add(ld1);
        //insert ld1;
        
        
        insert LedAutoRenewal;
        
        Test.stopTest();
     
     }
     
     public static testMethod void mainMethod3() {
        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        Business_Hours__c bh = new Business_Hours__c(name = 'OwnChange', Lowermin__c = 450, UpMin__c = 950);
        insert bh;
        Business_Hours__c bh1 = new Business_Hours__c(name = 'StatusChange', Lowermin__c = 450, UpMin__c = 950);
        insert bh1;
        
        AssetNotRenewReason__c asstRenew = new AssetNotRenewReason__c(Name = 'INSROI', Reason_Name__c = 'Insufficient ROI');
        insert asstRenew;
        
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
        testAccount.Primary_Email__c = 'testAccount@move.com';
        testAccount.Account_Sub_Type__c = 'Customer';
        testAccount.Auto_Renewal__c = true;
        insert testAccount;
        
        Contact myContact2 = new Contact ();
        myContact2.FirstName='Joe2';
        myContact2.LastName='Schmoe2';
        myContact2.Email='Joe.Schmoe2@test.de';
        myContact2.Account= testAccount;
        myContact2.Phone= '2131231233';
        myContact2.Type__c = 'Other';
        myContact2.Active__c = true;
        insert myContact2;
            
        Product2 newProduct                 = new Product2();
        newProduct.Name                     = 'Test Product';
        newProduct.Commission_Category__c   = 'Normal';    
        newProduct.Normalization_factor__c  = 1.10;
        newProduct.Commission_Category__c   = 'CFCB';
        newProduct.Fulfillment_Type__c      = 'Manual';
        newProduct.Auto_Renewal__c          = True;
        newProduct.ProductCode              ='SELLERLEADBUNDLE' ;
        newProduct.S_No__c                  = 2;
        newProduct.Orderable__c             = True;
        insert newProduct;
        
         Asset assets = new Asset();
            assets.Name = 'test';
            assets.Renewal_Status__c = 'Renew';
            assets.Auto_Renewal__c = 'Yes';
            assets.Asset_Type__c = 'Parent';
            assets.AccountId = testAccount.id;
            assets.Status = 'Active';
            assets.Billing_Period__c = 'Monthly';
            assets.Start_Date__c = system.today();
            assets.End_Date__c = System.today().addMonths(1);
            assets.Product2Id = newProduct.id;
            assets.Inflight_Quote__c = null;
            assets.AutoRenewalPicked__c = true;
            assets.Renewal_Type__c = 'Auto';
            assets.Follow_Up_Status__c = '';
            insert assets;
        
        
        List<Lead> LedAutoRenewal = new List<Lead>();
        Test.startTest();
        
        Lead ld2 = new Lead();
        ld2.LastName = 'Mr';
        ld2.FirstName = 'Test';
        ld2.Status = 'New';
        ld2.Company = 'Test';
        ld2.Contact__c = myContact2.id;
        ld2.Phone = '(860) 347-0333';
        ld2.Email = 'c.s1@gmail.com';
        ld2.Marketing_Lead_Type__c = 'Auto-Renew';
       // ld2.CustomerResponse__c = assets.Id+',50.00,100.00,Do Not Renew@INSROI,3,CBC10OFF51PLUS,10,CBC10OFF51PLUS,10,No;';
              ld2.CustomerResponse__c = assets.Id+',66.00,712.80,Renew,12,CBC10OFF51PLUS,10.00,6.60,,,,,,No,792.00;';//02ij0000004DjOiAAK,154.00,1663.20,Renew,12,CBC10OFF51PLUS,10.00,15.40,,,,,,No,1848.00;02ij00000043Zp2AAE,178.00,1922.40,Renew,12,CBC10OFF51PLUS,10.00,17.80,,,,,,No,2136.00;02ij00000043Zj9AAE,40.00,432.00,Renew,12,CBC10OFF51PLUS,10.00,4.00,,,,,,No,480.00;02ij00000043ZnGAAU,161.00,1738.80,Renew,12,CBC10OFF51PLUS,10.00,16.10,,,,,,No,1932.00;02ij00000043ZeOAAU,78.00,842.40,Renew,12,CBC10OFF51PLUS,10.00,7.80,,,,,,No,936.00;02ij0000004358bAAA,321.00,6933.60,Renew,12,CBC10OFF51PLUS,10.00,32.10,,,,,,No,7704.00;02ij0000004357xAAA,240.00,5184.00,Renew,12,CBC10OFF51PLUS,10.00,24.00,,,,,,No,5760.00;02ij00000043ZbSAAU,120.00,1296.00,Renew,12,CBC10OFF51PLUS,10.00,12.00,,,,,,No,1440.00;02ij00000043ZY1AAM,213.00,2300.40,Renew,12,CBC10OFF51PLUS,10.00,21.30,,,,,,No,2556.00;02ij00000043ZbPAAU,98.00,1058.40,Renew,12,CBC10OFF51PLUS,10.00,9.80,,,,,,No,1176.00;

        ld2.CustomerResponseProcessed__c = false;
        LedAutoRenewal.add(ld2);
        //insert ld2;
        
        insert LedAutoRenewal;
        
        Test.stopTest();
     
     }
     
     public static testMethod void mainMethod4() {
        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        Business_Hours__c bh = new Business_Hours__c(name = 'OwnChange', Lowermin__c = 450, UpMin__c = 950);
        insert bh;
        Business_Hours__c bh1 = new Business_Hours__c(name = 'StatusChange', Lowermin__c = 450, UpMin__c = 950);
        insert bh1;
        
        AssetNotRenewReason__c asstRenew = new AssetNotRenewReason__c(Name = 'INSROI', Reason_Name__c = 'Insufficient ROI');
        insert asstRenew;
        
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
        testAccount.Primary_Email__c = 'testAccount@move.com';
        testAccount.Account_Sub_Type__c = 'Customer';
        testAccount.Auto_Renewal__c = true;
        insert testAccount;
        
        Contact myContact2 = new Contact ();
        myContact2.FirstName='Joe2';
        myContact2.LastName='Schmoe2';
        myContact2.Email='Joe.Schmoe2@test.de';
        myContact2.Account= testAccount;
        myContact2.Phone= '2131231233';
        myContact2.Type__c = 'Other';
        myContact2.Active__c = true;
        insert myContact2;
            
        Product2 newProduct                 = new Product2();
        newProduct.Name                     = 'Test Product';
        newProduct.Commission_Category__c   = 'Normal';    
        newProduct.Normalization_factor__c  = 1.10;
        newProduct.Commission_Category__c   = 'CFCB';
        newProduct.Fulfillment_Type__c      = 'Manual';
        newProduct.Auto_Renewal__c          = True;
        newProduct.ProductCode              ='SELLERLEADBUNDLE' ;
        newProduct.S_No__c                  = 2;
        newProduct.Orderable__c             = True;
        insert newProduct;
        
         Asset assets = new Asset();
            assets.Name = 'test';
            assets.Renewal_Status__c = 'Renew';
            assets.Auto_Renewal__c = 'Yes';
            assets.Asset_Type__c = 'Parent';
            assets.AccountId = testAccount.id;
            assets.Fulfillment_Status__c = 'Fulfilled';
            assets.Status = 'Active';
            assets.Line_Type__c = 'Backout Credit';
            assets.Billing_Period__c = 'Monthly';
            assets.Start_Date__c = system.today();
            assets.End_Date__c = System.today().addMonths(1);
            assets.Product2Id = newProduct.id;
            assets.Haircut_Asset__c = false;
            assets.Inflight_Quote__c = null;
            assets.AutoRenewalPicked__c = true;
            assets.Renewal_Type__c = 'Auto';
            assets.Follow_Up_Status__c = '';
            insert assets; 
            
        Asset assets1 = new Asset();
            assets1.Name = 'test1';
            assets1.Renewal_Status__c = 'Renew';
            assets1.Auto_Renewal__c = 'Yes';
            assets1.Asset_Type__c = 'Parent';
            assets1.AccountId = testAccount.id;
            assets1.Fulfillment_Status__c = 'Fulfilled';
            assets1.Status = 'Active';
            assets1.Line_Type__c = 'Backout Credit';
            assets1.Billing_Period__c = 'Monthly';
            assets1.Start_Date__c = system.today();
            assets1.End_Date__c = System.today().addMonths(1);
            assets1.Product2Id = newProduct.id;
            assets1.Haircut_Asset__c = false;
            assets1.Inflight_Quote__c = null;
            assets1.AR_Oversold_Flag__c = True;
            assets1.AutoRenewalPicked__c = true;
            assets1.Renewal_Type__c = 'Auto';
            assets1.Follow_Up_Status__c = '';
            insert assets1; 
                
        
        List<Lead> LedAutoRenewal = new List<Lead>();
        Test.startTest();       
        
        Lead ld2 = new Lead();
        ld2.LastName = 'Mr';
        ld2.FirstName = 'Test';
        ld2.Status = 'New';
        ld2.Company = 'Test';
        ld2.Contact__c = myContact2.id;
        ld2.Phone = '(860) 347-0333';
        ld2.Email = 'c.s1@gmail.com';
        ld2.Marketing_Lead_Type__c = 'Auto-Renew';
       // ld2.CustomerResponse__c = assets.Id+',50.00,100.00,Renew,3,CBC10OFF51PLUS,10,CBC10OFF51PLUS,10,Yes;';
        ld2.CustomerResponse__c = assets.Id+',66.00,712.80,Do Not Renew@INSROI,12,CBC10OFF51PLUS,10.00,6.60,,,,,,No,792.00;';//02ij0000004DjOiAAK,154.00,1663.20,Renew,12,CBC10OFF51PLUS,10.00,15.40,,,,,,No,1848.00;02ij00000043Zp2AAE,178.00,1922.40,Renew,12,CBC10OFF51PLUS,10.00,17.80,,,,,,No,2136.00;02ij00000043Zj9AAE,40.00,432.00,Renew,12,CBC10OFF51PLUS,10.00,4.00,,,,,,No,480.00;02ij00000043ZnGAAU,161.00,1738.80,Renew,12,CBC10OFF51PLUS,10.00,16.10,,,,,,No,1932.00;02ij00000043ZeOAAU,78.00,842.40,Renew,12,CBC10OFF51PLUS,10.00,7.80,,,,,,No,936.00;02ij0000004358bAAA,321.00,6933.60,Renew,12,CBC10OFF51PLUS,10.00,32.10,,,,,,No,7704.00;02ij0000004357xAAA,240.00,5184.00,Renew,12,CBC10OFF51PLUS,10.00,24.00,,,,,,No,5760.00;02ij00000043ZbSAAU,120.00,1296.00,Renew,12,CBC10OFF51PLUS,10.00,12.00,,,,,,No,1440.00;02ij00000043ZY1AAM,213.00,2300.40,Renew,12,CBC10OFF51PLUS,10.00,21.30,,,,,,No,2556.00;02ij00000043ZbPAAU,98.00,1058.40,Renew,12,CBC10OFF51PLUS,10.00,9.80,,,,,,No,1176.00;

        ld2.CustomerResponseProcessed__c = false;
        LedAutoRenewal.add(ld2);
        
        Lead ld3 = new Lead();
        ld3.LastName = 'Mr1';
        ld3.FirstName = 'Test11';
        ld3.Status = 'New';
        ld3.Company = 'Test';
        ld3.Contact__c = myContact2.id;
        ld3.Phone = '(860) 347-0333';
        ld3.Email = 'c.s12@gmail.com';
        ld3.Marketing_Lead_Type__c = 'Auto-Renew';
        //ld3.CustomerResponse__c = assets1.Id+',50.00,100.00,Do Not Renew@INSROI,3,CBC10OFF51PLUS,10,CBC10OFF51PLUS,10,No;';
        ld3.CustomerResponse__c = assets1.Id+',66.00,712.80,Renew,12,CBC10OFF51PLUS,10.00,6.60,,,,,,No,792.00;';//02ij0000004DjOiAAK,154.00,1663.20,Renew,12,CBC10OFF51PLUS,10.00,15.40,,,,,,No,1848.00;02ij00000043Zp2AAE,178.00,1922.40,Renew,12,CBC10OFF51PLUS,10.00,17.80,,,,,,No,2136.00;02ij00000043Zj9AAE,40.00,432.00,Renew,12,CBC10OFF51PLUS,10.00,4.00,,,,,,No,480.00;02ij00000043ZnGAAU,161.00,1738.80,Renew,12,CBC10OFF51PLUS,10.00,16.10,,,,,,No,1932.00;02ij00000043ZeOAAU,78.00,842.40,Renew,12,CBC10OFF51PLUS,10.00,7.80,,,,,,No,936.00;02ij0000004358bAAA,321.00,6933.60,Renew,12,CBC10OFF51PLUS,10.00,32.10,,,,,,No,7704.00;02ij0000004357xAAA,240.00,5184.00,Renew,12,CBC10OFF51PLUS,10.00,24.00,,,,,,No,5760.00;02ij00000043ZbSAAU,120.00,1296.00,Renew,12,CBC10OFF51PLUS,10.00,12.00,,,,,,No,1440.00;02ij00000043ZY1AAM,213.00,2300.40,Renew,12,CBC10OFF51PLUS,10.00,21.30,,,,,,No,2556.00;02ij00000043ZbPAAU,98.00,1058.40,Renew,12,CBC10OFF51PLUS,10.00,9.80,,,,,,No,1176.00;

        ld3.CustomerResponseProcessed__c = false;
        LedAutoRenewal.add(ld3);
        
        //insert ld2;
        
        insert LedAutoRenewal;
        
        Test.stopTest();
     
     }

}