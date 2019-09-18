//Name        : ARIIQuoteCreationSchedulable_Test
//Description : Test class for ARIIQuoteCreationSchedulable.
//Author      : Pallavi Tammana

@isTest(seeAllData =false)
private class ARIIQuoteCreationSchedulable_Test{
    static testMethod void method1(){
        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        Schedule_Batch_Setting__c acctProcess = new Schedule_Batch_Setting__c(Name = 'ARII Account Process',Is_Running__c = True);
        insert acctProcess;
        Schedule_Batch_Setting__c priceUpdate = new Schedule_Batch_Setting__c(Name = 'ARII Price Update',Is_Running__c = false);
        insert priceUpdate;
        Schedule_Batch_Setting__c asstProcess = new Schedule_Batch_Setting__c(Name = 'ARII Asset Process',Is_Running__c = false);
        insert asstProcess;
        Schedule_Batch_Setting__c autoQuote = new Schedule_Batch_Setting__c(Name = 'ARII Quote Creation',Is_Running__c = false);
        insert autoQuote;
        Schedule_Batch_Setting__c autoReset = new Schedule_Batch_Setting__c(Name = 'ARII Reset Asset',Is_Running__c = false, Assetresttime__c = -1);
        insert autoReset;
        AutoRenewalNextEndDate__c autoDate = new AutoRenewalNextEndDate__c(Name = 'Auto Renewal End Date',Next_Month_Start_Date__c = System.today().addMonths(1),Next_Month_End_Date__c = System.today().addMonths(1).addDays(30),SubmitDays__c = 5);
        insert autoDate;
        BigMachineUrls__c p1 = new BigMachineUrls__c();
        p1.Name = 'Integration User 1';
        p1.Parallel_Processing_User__c = true;
        insert p1;
        BigMachineUrls__c p2 = new BigMachineUrls__c();
        p2.Name = 'Integration User 2';
        p2.Parallel_Processing_User__c = true;
        insert p2;


        Product2 newProduct = new Product2();
        newProduct.Name = 'TestProduct';
        newProduct.Auto_Renewal__c = True;
        newProduct.ProductCode='SHOWCASE' ;
        newProduct.Orderable__c= true;
        newProduct.S_No__c = 3;
        insert newProduct;
        
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
            testAccount.Primary_Email__c = 'testAccount@move.com';
            testAccount.Account_Sub_Type__c = 'Customer';
            testAccount.Auto_Renewal__c = true;
            testAccount.Asset_Earliest_End_Date__c = System.today().addDays(5);
            testAccount.essentialsstatus__c = 'Activated';
            //testAccount.OwnerId = u.Id;
            insert testAccount;
        
        // Asset Nighlty Price Update    
        Asset asst = new Asset();
            asst.Name = 'test';
            asst.Auto_Renewal__c = 'Yes';
            asst.Asset_Type__c = 'Parent';
            asst.AccountId = testAccount.id;
            asst.Fulfillment_Status__c = 'Fulfilled';
            asst.Status = 'Active';
            asst.Line_Type__c = 'Backout Credit';
            asst.Billing_Period__c = 'Monthly';
            asst.Start_Date__c = system.today();
            asst.End_Date__c = System.today().addMonths(1).addDays(2);
            asst.Product2Id = newProduct.id;
            asst.Haircut_Asset__c = false;
            asst.Inflight_Quote__c = null;
            asst.AutoRenewalPicked__c = true;
            insert asst;
           
        //Auto Quote Creation and Submit
        Asset assts1 = new Asset();
            assts1.Name = 'test';
            assts1.Renewal_Type__c = 'Auto';
            assts1.Auto_Renewal__c = 'Yes';
            assts1.Asset_Type__c = 'Parent';
            assts1.AccountId = testAccount.id;
            assts1.Fulfillment_Status__c = 'Fulfilled';
            assts1.Status = 'Active';
            //assts1.Line_Type__c = 'Backout Credit';
            assts1.Billing_Period__c = 'Monthly';
            assts1.Start_Date__c = system.today();
            assts1.End_Date__c = System.today().addDays(5);
            assts1.Product2Id = newProduct.id;
            assts1.Haircut_Asset__c = false;
            assts1.Inflight_Quote__c = null;
            assts1.AutoRenewalPicked__c = true;
            insert assts1;
        System.debug('assts1:'+assts1);
        
        Asset_AR_Association__c arAsst= new Asset_AR_Association__c();
            arAsst.Asset_Id__c = assts1.Id;
            arAsst.AR_Config_Options__c = 'Land';
            arAsst.AR_Lead_PPL__c = 1;
            arAsst.AR_Brand_PPL__c = 1;
            arAsst.AR_AMLC_Residential__c = 1;
            arAsst.AR_AMLC_Land__c = 1;
            arAsst.AR_AMLC_Rental__c = 1;
            arAsst.AR_PPL_Override__c = 1;
            arAsst.External_ID__c = '1234-78979';
            arAsst.AR_Price_Info__c = '12^0.0^ASR_A/R_NewOrder_CBC10_Off^10.0^0.0^KWCBC25^10.0^0.0^0.0^0.0^0.0#';
            insert arAsst;
        
        //Asset Reset
        Asset asst1 = new Asset();
            asst1.Name = 'test';
            asst1.Renewal_Status__c = 'Renewed';
            asst1.Auto_Renewal__c = 'Yes';
            asst1.Asset_Type__c = 'Parent';
            asst1.AccountId = testAccount.id;
            asst1.Fulfillment_Status__c = 'Fulfilled';
            asst1.Status = 'Active';
            asst1.Line_Type__c = 'Backout Credit';
            asst1.Billing_Period__c = 'Monthly';
            asst1.Start_Date__c = System.today().addMonths(-1);
            asst1.End_Date__c = System.today().addMonths(1);
            asst1.Product2Id = newProduct.id;
            asst1.Haircut_Asset__c = false;
            asst1.Inflight_Quote__c = null;
            asst1.Follow_Up_Status__c = 'Renewed';
            insert asst1;
        
        
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
            insert assets;
            
        Asset assets1 = new Asset();
            assets1.Name = 'test';
            assets1.Renewal_Status__c = 'Renewed';
            assets1.Auto_Renewal__c = 'Yes';
            assets1.Asset_Type__c = 'Parent';
            assets1.AccountId = testAccount.id;
            assets1.Fulfillment_Status__c = 'Fulfilled';
            assets1.Status = 'Active';
            assets1.Line_Type__c = 'Backout Credit';
            assets1.Billing_Period__c = 'Monthly';
            assets1.Start_Date__c = system.today().addMonths(-1);
            assets1.End_Date__c = System.today().addMonths(2);
            assets1.Product2Id = newProduct.id;
            assets1.Haircut_Asset__c = false;
            assets1.Inflight_Quote__c = null;
            insert assets1;       
        
        test.startTest();
        ARIIQuoteCreationSchedulable sh1 = new ARIIQuoteCreationSchedulable();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
    static testMethod void method2(){
        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        Schedule_Batch_Setting__c acctProcess = new Schedule_Batch_Setting__c(Name = 'ARII Account Process',Is_Running__c = false);
        insert acctProcess;
        Schedule_Batch_Setting__c priceUpdate = new Schedule_Batch_Setting__c(Name = 'ARII Price Update',Is_Running__c = True);
        insert priceUpdate;
        Schedule_Batch_Setting__c asstProcess = new Schedule_Batch_Setting__c(Name = 'ARII Asset Process',Is_Running__c = false);
        insert asstProcess;
        Schedule_Batch_Setting__c autoQuote = new Schedule_Batch_Setting__c(Name = 'ARII Quote Creation',Is_Running__c = false);
        insert autoQuote;
        Schedule_Batch_Setting__c autoReset = new Schedule_Batch_Setting__c(Name = 'ARII Reset Asset',Is_Running__c = false, Assetresttime__c=-1);
        insert autoReset;
        AutoRenewalNextEndDate__c autoDate = new AutoRenewalNextEndDate__c(Name = 'Auto Renewal End Date',Next_Month_Start_Date__c = System.today().addMonths(1),Next_Month_End_Date__c = System.today().addMonths(1).addDays(30),SubmitDays__c = 5);
        insert autoDate;
        BigMachineUrls__c p1 = new BigMachineUrls__c();
        p1.Name = 'Integration User 1';
        p1.Parallel_Processing_User__c = true;
        insert p1;
        BigMachineUrls__c p2 = new BigMachineUrls__c();
        p2.Name = 'Integration User 2';
        p2.Parallel_Processing_User__c = true;
        insert p2;
        
        Product2 newProduct = new Product2();
        newProduct.Name = 'TestProduct';
        newProduct.Auto_Renewal__c = True;
        newProduct.ProductCode='SHOWCASE' ;
        newProduct.Orderable__c= true;
        newProduct.S_No__c = 3;
        insert newProduct;
        
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
            testAccount.Primary_Email__c = 'testAccount@move.com';
            testAccount.Account_Sub_Type__c = 'Customer';
            testAccount.Auto_Renewal__c = true;
            testAccount.Asset_Earliest_End_Date__c = System.today().addDays(5);
                        testAccount.essentialsstatus__c = 'Activated';

            //testAccount.OwnerId = u.Id;
            insert testAccount;
            
            Account testAccount2 = TestDataFactory.createAccount('Test Account',null,false);
            testAccount2.Primary_Email__c = 'testAccount@move.com';
            testAccount2.Account_Sub_Type__c = 'Customer';
            testAccount2.Auto_Renewal__c = true;
            testAccount2.Asset_Earliest_End_Date__c = System.today().addDays(5);
                        testAccount2.essentialsstatus__c = 'Activated';

            //testAccount.OwnerId = u.Id;
            insert testAccount2;
        Account testAccount3 = TestDataFactory.createAccount('Test Account',null,false);
        testAccount3.Primary_Email__c = 'testAccount@move.com';
            testAccount3.Account_Sub_Type__c = 'Customer';
            testAccount3.Auto_Renewal__c = true;
            testAccount3.Asset_Earliest_End_Date__c = System.today().addDays(5);
                        testAccount3.essentialsstatus__c = 'Activated';

            //testAccount.OwnerId = u.Id;
            insert testAccount3;
        // Asset Nighlty Price Update    
        Asset asst65 = new Asset();
            asst65.Name = 'test';
            asst65.Auto_Renewal__c = 'Yes';
            asst65.Asset_Type__c = 'Parent';
            asst65.AccountId = testAccount2.id;
            asst65.Fulfillment_Status__c = 'Fulfilled';
            asst65.Status = 'Active';
            asst65.Line_Type__c = 'Backout Credit';
            asst65.Billing_Period__c = 'Monthly';
            asst65.Start_Date__c = system.today();
            asst65.End_Date__c = System.today().addMonths(1).addDays(2);
            asst65.Product2Id = newProduct.id;
            asst65.Haircut_Asset__c = false;
            asst65.Inflight_Quote__c = null;
            asst65.AutoRenewalPicked__c = true;
            insert asst65;
           

        
        // Asset Nighlty Price Update    
        Asset asst = new Asset();
            asst.Name = 'test';
            asst.Auto_Renewal__c = 'Yes';
            asst.Asset_Type__c = 'Parent';
            asst.AccountId = testAccount.id;
            asst.Fulfillment_Status__c = 'Fulfilled';
            asst.Status = 'Active';
            asst.Line_Type__c = 'Backout Credit';
            asst.Billing_Period__c = 'Monthly';
            asst.Start_Date__c = system.today();
            asst.End_Date__c = System.today().addMonths(1).addDays(2);
            asst.Product2Id = newProduct.id;
            asst.Haircut_Asset__c = false;
            asst.Inflight_Quote__c = null;
            asst.AutoRenewalPicked__c = true;
            insert asst;
           
        //Auto Quote Creation and Submit
        Asset assts1 = new Asset();
            assts1.Name = 'test';
            assts1.Renewal_Type__c = 'Auto';
            assts1.Auto_Renewal__c = 'Yes';
            assts1.Asset_Type__c = 'Parent';
            assts1.AccountId = testAccount3.id;
            assts1.Fulfillment_Status__c = 'Fulfilled';
            assts1.Status = 'Active';
            //assts1.Line_Type__c = 'Backout Credit';
            assts1.Billing_Period__c = 'Monthly';
            assts1.Start_Date__c = system.today();
            assts1.End_Date__c = System.today().addDays(5);
            assts1.Product2Id = newProduct.id;
            assts1.Haircut_Asset__c = false;
            assts1.Inflight_Quote__c = null;
            assts1.AutoRenewalPicked__c = true;
            insert assts1;
        System.debug('assts1:'+assts1);
        
        Asset_AR_Association__c arAsst= new Asset_AR_Association__c();
            arAsst.Asset_Id__c = assts1.Id;
            arAsst.AR_Config_Options__c = 'Land';
            arAsst.AR_Lead_PPL__c = 1;
            arAsst.AR_Brand_PPL__c = 1;
            arAsst.AR_AMLC_Residential__c = 1;
            arAsst.AR_AMLC_Land__c = 1;
            arAsst.AR_AMLC_Rental__c = 1;
            arAsst.AR_PPL_Override__c = 1;
            arAsst.External_ID__c = '1234-78979';
            arAsst.AR_Price_Info__c = '12^0.0^ASR_A/R_NewOrder_CBC10_Off^10.0^0.0^KWCBC25^10.0^0.0^0.0^0.0^0.0#';
            insert arAsst;
        
        //Asset Reset
        Asset asst1 = new Asset();
            asst1.Name = 'test';
            asst1.Renewal_Status__c = 'Renewed';
            asst1.Auto_Renewal__c = 'Yes';
            asst1.Asset_Type__c = 'Parent';
            asst1.AccountId = testAccount.id;
            asst1.Fulfillment_Status__c = 'Fulfilled';
            asst1.Status = 'Active';
            asst1.Line_Type__c = 'Backout Credit';
            asst1.Billing_Period__c = 'Monthly';
            asst1.Start_Date__c = System.today().addMonths(-1);
            asst1.End_Date__c = System.today().addMonths(1);
            asst1.Product2Id = newProduct.id;
            asst1.Haircut_Asset__c = false;
            asst1.Inflight_Quote__c = null;
            asst1.Follow_Up_Status__c = 'Renewed';
            insert asst1;
        
        
        Asset assets = new Asset();
            assets.Name = 'test';
            assets.Renewal_Status__c = 'Renew';
            assets.Auto_Renewal__c = 'Yes';
            assets.Asset_Type__c = 'Parent';
            assets.AccountId = testAccount2.id;
            assets.Fulfillment_Status__c = 'Fulfilled';
            assets.Status = 'Active';
            assets.Line_Type__c = 'Backout Credit';
            assets.Billing_Period__c = 'Monthly';
            assets.Start_Date__c = system.today();
            assets.End_Date__c = System.today().addMonths(1);
            assets.Product2Id = newProduct.id;
            assets.Haircut_Asset__c = false;
            assets.Inflight_Quote__c = null;
            insert assets;
            
        Asset assets1 = new Asset();
            assets1.Name = 'test';
            assets1.Renewal_Status__c = 'Renewed';
            assets1.Auto_Renewal__c = 'Yes';
            assets1.Asset_Type__c = 'Parent';
            assets1.AccountId = testAccount3.id;
            assets1.Fulfillment_Status__c = 'Fulfilled';
            assets1.Status = 'Active';
            assets1.Line_Type__c = 'Backout Credit';
            assets1.Billing_Period__c = 'Monthly';
            assets1.Start_Date__c = system.today().addMonths(-1);
            assets1.End_Date__c = System.today().addMonths(2);
            assets1.Product2Id = newProduct.id;
            assets1.Haircut_Asset__c = false;
            assets1.Inflight_Quote__c = null;
            insert assets1;       
        
        test.startTest();
        ARIIQuoteCreationSchedulable sh1 = new ARIIQuoteCreationSchedulable();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
    static testMethod void method3(){
        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        Schedule_Batch_Setting__c acctProcess = new Schedule_Batch_Setting__c(Name = 'ARII Account Process',Is_Running__c = false);
        insert acctProcess;
        Schedule_Batch_Setting__c priceUpdate = new Schedule_Batch_Setting__c(Name = 'ARII Price Update',Is_Running__c = false);
        insert priceUpdate;
        Schedule_Batch_Setting__c asstProcess = new Schedule_Batch_Setting__c(Name = 'ARII Asset Process',Is_Running__c = True);
        insert asstProcess;
        Schedule_Batch_Setting__c autoQuote = new Schedule_Batch_Setting__c(Name = 'ARII Quote Creation',Is_Running__c = false);
        insert autoQuote;
        Schedule_Batch_Setting__c autoReset = new Schedule_Batch_Setting__c(Name = 'ARII Reset Asset',Is_Running__c = false, Assetresttime__c=-1);
        insert autoReset;
        AutoRenewalNextEndDate__c autoDate = new AutoRenewalNextEndDate__c(Name = 'Auto Renewal End Date',Next_Month_Start_Date__c = System.today().addMonths(1),Next_Month_End_Date__c = System.today().addMonths(1).addDays(30),SubmitDays__c = 5);
        insert autoDate;
        BigMachineUrls__c p1 = new BigMachineUrls__c();
        p1.Name = 'Integration User 1';
        p1.Parallel_Processing_User__c = true;
        insert p1;
        BigMachineUrls__c p2 = new BigMachineUrls__c();
        p2.Name = 'Integration User 2';
        p2.Parallel_Processing_User__c = true;
        insert p2;
        
        Product2 newProduct = new Product2();
        newProduct.Name = 'TestProduct';
        newProduct.Auto_Renewal__c = True;
        newProduct.ProductCode='SHOWCASE' ;
        newProduct.Orderable__c= true;
        newProduct.S_No__c = 3;
        insert newProduct;
        
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
            testAccount.Primary_Email__c = 'testAccount@move.com';
            testAccount.Account_Sub_Type__c = 'Customer';
            testAccount.Auto_Renewal__c = true;
            testAccount.Asset_Earliest_End_Date__c = System.today().addDays(5);
                        testAccount.essentialsstatus__c = 'Activated';

            //testAccount.OwnerId = u.Id;
            insert testAccount;
        
        // Asset Nighlty Price Update    
        Asset asst = new Asset();
            asst.Name = 'test';
            asst.Auto_Renewal__c = 'Yes';
            asst.Asset_Type__c = 'Parent';
            asst.AccountId = testAccount.id;
            asst.Fulfillment_Status__c = 'Fulfilled';
            asst.Status = 'Active';
            asst.Line_Type__c = 'Backout Credit';
            asst.Billing_Period__c = 'Monthly';
            asst.Start_Date__c = system.today();
            asst.End_Date__c = System.today().addMonths(1).addDays(2);
            asst.Product2Id = newProduct.id;
            asst.Haircut_Asset__c = false;
            asst.Inflight_Quote__c = null;
            asst.AutoRenewalPicked__c = true;
            insert asst;
           
        //Auto Quote Creation and Submit
        Asset assts1 = new Asset();
            assts1.Name = 'test';
            assts1.Renewal_Type__c = 'Auto';
            assts1.Auto_Renewal__c = 'Yes';
            assts1.Asset_Type__c = 'Parent';
            assts1.AccountId = testAccount.id;
            assts1.Fulfillment_Status__c = 'Fulfilled';
            assts1.Status = 'Active';
            //assts1.Line_Type__c = 'Backout Credit';
            assts1.Billing_Period__c = 'Monthly';
            assts1.Start_Date__c = system.today();
            assts1.End_Date__c = System.today().addDays(5);
            assts1.Product2Id = newProduct.id;
            assts1.Haircut_Asset__c = false;
            assts1.Inflight_Quote__c = null;
            assts1.AutoRenewalPicked__c = true;
            insert assts1;
        System.debug('assts1:'+assts1);
        
        Asset_AR_Association__c arAsst= new Asset_AR_Association__c();
            arAsst.Asset_Id__c = assts1.Id;
            arAsst.AR_Config_Options__c = 'Land';
            arAsst.AR_Lead_PPL__c = 1;
            arAsst.AR_Brand_PPL__c = 1;
            arAsst.AR_AMLC_Residential__c = 1;
            arAsst.AR_AMLC_Land__c = 1;
            arAsst.AR_AMLC_Rental__c = 1;
            arAsst.AR_PPL_Override__c = 1;
            arAsst.External_ID__c = '1234-78979';
            arAsst.AR_Price_Info__c = '12^0.0^ASR_A/R_NewOrder_CBC10_Off^10.0^0.0^KWCBC25^10.0^0.0^0.0^0.0^0.0#';
            insert arAsst;
        
        //Asset Reset
        Asset asst1 = new Asset();
            asst1.Name = 'test';
            asst1.Renewal_Status__c = 'Renewed';
            asst1.Auto_Renewal__c = 'Yes';
            asst1.Asset_Type__c = 'Parent';
            asst1.AccountId = testAccount.id;
            asst1.Fulfillment_Status__c = 'Fulfilled';
            asst1.Status = 'Active';
            asst1.Line_Type__c = 'Backout Credit';
            asst1.Billing_Period__c = 'Monthly';
            asst1.Start_Date__c = System.today().addMonths(-1);
            asst1.End_Date__c = System.today().addMonths(1);
            asst1.Product2Id = newProduct.id;
            asst1.Haircut_Asset__c = false;
            asst1.Inflight_Quote__c = null;
            asst1.Follow_Up_Status__c = 'Renewed';
            insert asst1;
        
        
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
            insert assets;
            
        Asset assets1 = new Asset();
            assets1.Name = 'test';
            assets1.Renewal_Status__c = 'Renewed';
            assets1.Auto_Renewal__c = 'Yes';
            assets1.Asset_Type__c = 'Parent';
            assets1.AccountId = testAccount.id;
            assets1.Fulfillment_Status__c = 'Fulfilled';
            assets1.Status = 'Active';
            assets1.Line_Type__c = 'Backout Credit';
            assets1.Billing_Period__c = 'Monthly';
            assets1.Start_Date__c = system.today().addMonths(-1);
            assets1.End_Date__c = System.today().addMonths(2);
            assets1.Product2Id = newProduct.id;
            assets1.Haircut_Asset__c = false;
            assets1.Inflight_Quote__c = null;
            insert assets1;       
        
        test.startTest();
        ARIIQuoteCreationSchedulable sh1 = new ARIIQuoteCreationSchedulable();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
    static testMethod void method4(){
        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        Schedule_Batch_Setting__c acctProcess = new Schedule_Batch_Setting__c(Name = 'ARII Account Process',Is_Running__c = false);
        insert acctProcess;
        Schedule_Batch_Setting__c priceUpdate = new Schedule_Batch_Setting__c(Name = 'ARII Price Update',Is_Running__c = false);
        insert priceUpdate;
        Schedule_Batch_Setting__c asstProcess = new Schedule_Batch_Setting__c(Name = 'ARII Asset Process',Is_Running__c = false);
        insert asstProcess;
        Schedule_Batch_Setting__c autoQuote = new Schedule_Batch_Setting__c(Name = 'ARII Quote Creation',Is_Running__c = True);
        insert autoQuote;
        Schedule_Batch_Setting__c autoReset = new Schedule_Batch_Setting__c(Name = 'ARII Reset Asset',Is_Running__c = false, Assetresttime__c=-1);
        insert autoReset;
        AutoRenewalNextEndDate__c autoDate = new AutoRenewalNextEndDate__c(Name = 'Auto Renewal End Date',Next_Month_Start_Date__c = System.today().addMonths(1),Next_Month_End_Date__c = System.today().addMonths(1).addDays(30),SubmitDays__c = 5);
        insert autoDate;
        BigMachineUrls__c p1 = new BigMachineUrls__c();
        p1.Name = 'Integration User 1';
        p1.Parallel_Processing_User__c = true;
        insert p1;
        BigMachineUrls__c p2 = new BigMachineUrls__c();
        p2.Name = 'Integration User 2';
        p2.Parallel_Processing_User__c = true;
        insert p2;
        
        Product2 newProduct = new Product2();
        newProduct.Name = 'TestProduct';
        newProduct.Auto_Renewal__c = True;
        newProduct.ProductCode='SHOWCASE' ;
        newProduct.Orderable__c= true;
        newProduct.S_No__c = 3;
        insert newProduct;
        
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
            testAccount.Primary_Email__c = 'testAccount@move.com';
            testAccount.Account_Sub_Type__c = 'Customer';
            testAccount.Auto_Renewal__c = true;
            testAccount.Asset_Earliest_End_Date__c = System.today().addDays(5);
                        testAccount.essentialsstatus__c = 'Activated';

            //testAccount.OwnerId = u.Id;
            insert testAccount;
        
        // Asset Nighlty Price Update    
        Asset asst = new Asset();
            asst.Name = 'test';
            asst.Auto_Renewal__c = 'Yes';
            asst.Asset_Type__c = 'Parent';
            asst.AccountId = testAccount.id;
            asst.Fulfillment_Status__c = 'Fulfilled';
            asst.Status = 'Active';
            asst.Line_Type__c = 'Backout Credit';
            asst.Billing_Period__c = 'Monthly';
            asst.Start_Date__c = system.today();
            asst.End_Date__c = System.today().addMonths(1).addDays(2);
            asst.Product2Id = newProduct.id;
            asst.Haircut_Asset__c = false;
            asst.Inflight_Quote__c = null;
            asst.AutoRenewalPicked__c = true;
            insert asst;
           
        //Auto Quote Creation and Submit
        Asset assts1 = new Asset();
            assts1.Name = 'test';
            assts1.Renewal_Type__c = 'Auto';
            assts1.Auto_Renewal__c = 'Yes';
            assts1.Asset_Type__c = 'Parent';
            assts1.AccountId = testAccount.id;
            assts1.Fulfillment_Status__c = 'Fulfilled';
            assts1.Status = 'Active';
            //assts1.Line_Type__c = 'Backout Credit';
            assts1.Billing_Period__c = 'Monthly';
            assts1.Start_Date__c = system.today();
            assts1.End_Date__c = System.today().addDays(5);
            assts1.Product2Id = newProduct.id;
            assts1.Haircut_Asset__c = false;
            assts1.Inflight_Quote__c = null;
            assts1.AutoRenewalPicked__c = true;
            insert assts1;
        System.debug('assts1:'+assts1);
        
        Asset_AR_Association__c arAsst= new Asset_AR_Association__c();
            arAsst.Asset_Id__c = assts1.Id;
            arAsst.AR_Config_Options__c = 'Land';
            arAsst.AR_Lead_PPL__c = 1;
            arAsst.AR_Brand_PPL__c = 1;
            arAsst.AR_AMLC_Residential__c = 1;
            arAsst.AR_AMLC_Land__c = 1;
            arAsst.AR_AMLC_Rental__c = 1;
            arAsst.AR_PPL_Override__c = 1;
            arAsst.External_ID__c = '1234-78979';
            arAsst.AR_Price_Info__c = '12^0.0^ASR_A/R_NewOrder_CBC10_Off^10.0^0.0^KWCBC25^10.0^0.0^0.0^0.0^0.0#';
            insert arAsst;
        
        //Asset Reset
        Asset asst1 = new Asset();
            asst1.Name = 'test';
            asst1.Renewal_Status__c = 'Renewed';
            asst1.Auto_Renewal__c = 'Yes';
            asst1.Asset_Type__c = 'Parent';
            asst1.AccountId = testAccount.id;
            asst1.Fulfillment_Status__c = 'Fulfilled';
            asst1.Status = 'Active';
            asst1.Line_Type__c = 'Backout Credit';
            asst1.Billing_Period__c = 'Monthly';
            asst1.Start_Date__c = System.today().addMonths(-1);
            asst1.End_Date__c = System.today().addMonths(1);
            asst1.Product2Id = newProduct.id;
            asst1.Haircut_Asset__c = false;
            asst1.Inflight_Quote__c = null;
            asst1.Follow_Up_Status__c = 'Renewed';
            insert asst1;
        
        
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
            insert assets;
            
        Asset assets1 = new Asset();
            assets1.Name = 'test';
            assets1.Renewal_Status__c = 'Renewed';
            assets1.Auto_Renewal__c = 'Yes';
            assets1.Asset_Type__c = 'Parent';
            assets1.AccountId = testAccount.id;
            assets1.Fulfillment_Status__c = 'Fulfilled';
            assets1.Status = 'Active';
            assets1.Line_Type__c = 'Backout Credit';
            assets1.Billing_Period__c = 'Monthly';
            assets1.Start_Date__c = system.today().addMonths(-1);
            assets1.End_Date__c = System.today().addMonths(2);
            assets1.Product2Id = newProduct.id;
            assets1.Haircut_Asset__c = false;
            assets1.Inflight_Quote__c = null;
            insert assets1;       
        
        test.startTest();
        ARIIQuoteCreationSchedulable sh1 = new ARIIQuoteCreationSchedulable();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
    static testMethod void method5(){
        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        Schedule_Batch_Setting__c acctProcess = new Schedule_Batch_Setting__c(Name = 'ARII Account Process',Is_Running__c = false);
        insert acctProcess;
        Schedule_Batch_Setting__c priceUpdate = new Schedule_Batch_Setting__c(Name = 'ARII Price Update',Is_Running__c = false);
        insert priceUpdate;
        Schedule_Batch_Setting__c asstProcess = new Schedule_Batch_Setting__c(Name = 'ARII Asset Process',Is_Running__c = false);
        insert asstProcess;
        Schedule_Batch_Setting__c autoQuote = new Schedule_Batch_Setting__c(Name = 'ARII Quote Creation',Is_Running__c = false);
        insert autoQuote;
        Schedule_Batch_Setting__c autoReset = new Schedule_Batch_Setting__c(Name = 'ARII Reset Asset',Is_Running__c = True, Assetresttime__c=-1);
        insert autoReset;
        AutoRenewalNextEndDate__c autoDate = new AutoRenewalNextEndDate__c(Name = 'Auto Renewal End Date',Next_Month_Start_Date__c = System.today().addMonths(1),Next_Month_End_Date__c = System.today().addMonths(1).addDays(30),SubmitDays__c = 5);
        insert autoDate;
        BigMachineUrls__c p1 = new BigMachineUrls__c();
        p1.Name = 'Integration User 1';
        p1.Parallel_Processing_User__c = true;
        insert p1;
        BigMachineUrls__c p2 = new BigMachineUrls__c();
        p2.Name = 'Integration User 2';
        p2.Parallel_Processing_User__c = true;
        insert p2;
        
        Product2 newProduct = new Product2();
        newProduct.Name = 'TestProduct';
        newProduct.Auto_Renewal__c = True;
        newProduct.ProductCode='SHOWCASE' ;
        newProduct.Orderable__c= true;
        newProduct.S_No__c = 3;
        insert newProduct;
        
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
            testAccount.Primary_Email__c = 'testAccount@move.com';
            testAccount.Account_Sub_Type__c = 'Customer';
            testAccount.Auto_Renewal__c = true;
            testAccount.Asset_Earliest_End_Date__c = System.today().addDays(5);
                        testAccount.essentialsstatus__c = 'Activated';

            //testAccount.OwnerId = u.Id;
            insert testAccount;
        
        // Asset Nighlty Price Update    
        Asset asst = new Asset();
            asst.Name = 'test';
            asst.Auto_Renewal__c = 'Yes';
            asst.Asset_Type__c = 'Parent';
            asst.AccountId = testAccount.id;
            asst.Fulfillment_Status__c = 'Fulfilled';
            asst.Status = 'Active';
            asst.Line_Type__c = 'Backout Credit';
            asst.Billing_Period__c = 'Monthly';
            asst.Start_Date__c = system.today();
            asst.End_Date__c = System.today().addMonths(1).addDays(2);
            asst.Product2Id = newProduct.id;
            asst.Haircut_Asset__c = false;
            asst.Inflight_Quote__c = null;
            asst.AutoRenewalPicked__c = true;
            insert asst;
           
        //Auto Quote Creation and Submit
        Asset assts1 = new Asset();
            assts1.Name = 'test';
            assts1.Renewal_Type__c = 'Auto';
            assts1.Auto_Renewal__c = 'Yes';
            assts1.Asset_Type__c = 'Parent';
            assts1.AccountId = testAccount.id;
            assts1.Fulfillment_Status__c = 'Fulfilled';
            assts1.Status = 'Active';
            //assts1.Line_Type__c = 'Backout Credit';
            assts1.Billing_Period__c = 'Monthly';
            assts1.Start_Date__c = system.today();
            //assts1.End_Date__c = System.today().addDays(5);
            assts1.Product2Id = newProduct.id;
            assts1.Haircut_Asset__c = false;
            assts1.Inflight_Quote__c = null;
            assts1.AutoRenewalPicked__c = true;
            insert assts1;
        System.debug('assts1:'+assts1);
        
        Asset_AR_Association__c arAsst= new Asset_AR_Association__c();
            arAsst.Asset_Id__c = assts1.Id;
            arAsst.AR_Config_Options__c = 'Land';
            arAsst.AR_Lead_PPL__c = 1;
            arAsst.AR_Brand_PPL__c = 1;
            arAsst.AR_AMLC_Residential__c = 1;
            arAsst.AR_AMLC_Land__c = 1;
            arAsst.AR_AMLC_Rental__c = 1;
            arAsst.AR_PPL_Override__c = 1;
            arAsst.External_ID__c = '1234-78979';
            arAsst.AR_Price_Info__c = '12^0.0^ASR_A/R_NewOrder_CBC10_Off^10.0^0.0^KWCBC25^10.0^0.0^0.0^0.0^0.0#';
            insert arAsst;
        
        //Asset Reset
        Asset asst1 = new Asset();
            asst1.Name = 'test';
            asst1.Renewal_Status__c = 'Renewed';
            asst1.Auto_Renewal__c = 'Yes';
            asst1.Asset_Type__c = 'Parent';
            asst1.AccountId = testAccount.id;
            asst1.Fulfillment_Status__c = 'Fulfilled';
            asst1.Status = 'Active';
            asst1.Line_Type__c = 'Backout Credit';
            asst1.Billing_Period__c = 'Monthly';
            asst1.Start_Date__c = System.today().addMonths(-1);
            asst1.End_Date__c = System.today().addMonths(1);
            asst1.Product2Id = newProduct.id;
            asst1.Haircut_Asset__c = false;
            asst1.Inflight_Quote__c = null;
            asst1.Follow_Up_Status__c = 'Renewed';
            insert asst1;
        
        
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
            insert assets;
            
        Asset assets1 = new Asset();
            assets1.Name = 'test';
            assets1.Renewal_Status__c = 'Renewed';
            assets1.Auto_Renewal__c = 'Yes';
            assets1.Asset_Type__c = 'Parent';
            assets1.AccountId = testAccount.id;
            assets1.Fulfillment_Status__c = 'Fulfilled';
            assets1.Status = 'Active';
            assets1.Line_Type__c = 'Backout Credit';
            assets1.Billing_Period__c = 'Monthly';
            assets1.Start_Date__c = system.today().addMonths(-1);
            assets1.End_Date__c = System.today().addMonths(2);
            assets1.Product2Id = newProduct.id;
            assets1.Haircut_Asset__c = false;
            assets1.Inflight_Quote__c = null;
            insert assets1;       
        
        test.startTest();
        ARIIQuoteCreationSchedulable sh1 = new ARIIQuoteCreationSchedulable();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
    static testMethod void method6(){
        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        Schedule_Batch_Setting__c acctProcess = new Schedule_Batch_Setting__c(Name = 'ARII Account Process',Is_Running__c = false);
        insert acctProcess;
        Schedule_Batch_Setting__c priceUpdate = new Schedule_Batch_Setting__c(Name = 'ARII Price Update',Is_Running__c = True);
        insert priceUpdate;
        Schedule_Batch_Setting__c asstProcess = new Schedule_Batch_Setting__c(Name = 'ARII Asset Process',Is_Running__c = false);
        insert asstProcess;
        Schedule_Batch_Setting__c autoQuote = new Schedule_Batch_Setting__c(Name = 'ARII Quote Creation',Is_Running__c = false);
        insert autoQuote;
        Schedule_Batch_Setting__c autoReset = new Schedule_Batch_Setting__c(Name = 'ARII Reset Asset',Is_Running__c = false, Assetresttime__c=-1);
        insert autoReset;
        AutoRenewalNextEndDate__c autoDate = new AutoRenewalNextEndDate__c(Name = 'Auto Renewal End Date',Next_Month_Start_Date__c = System.today().addMonths(1),Next_Month_End_Date__c = System.today().addMonths(1).addDays(30),SubmitDays__c = 5);
        insert autoDate;
        BigMachineUrls__c p1 = new BigMachineUrls__c();
        p1.Name = 'BM';
        insert p1;
        
        
        Product2 newProduct = new Product2();
        newProduct.Name = 'TestProduct';
        newProduct.Auto_Renewal__c = True;
        newProduct.ProductCode='SHOWCASE' ;
        newProduct.Orderable__c= true;
        newProduct.S_No__c = 3;
        insert newProduct;
        
        
        
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
            testAccount.Primary_Email__c = 'testAccount@move.com';
            testAccount.Account_Sub_Type__c = 'Customer';
            testAccount.Auto_Renewal__c = true;
            testAccount.Asset_Earliest_End_Date__c = System.today().addDays(5);
                        testAccount.essentialsstatus__c = 'Activated';

            //testAccount.OwnerId = u.Id;
            insert testAccount;
        
        // Asset Nighlty Price Update    
        Asset asst = new Asset();
            asst.Name = 'test';
            asst.Auto_Renewal__c = 'Yes';
            asst.Asset_Type__c = 'Parent';
            asst.AccountId = testAccount.id;
            asst.Fulfillment_Status__c = 'Fulfilled';
            asst.Status = 'Active';
            asst.Line_Type__c = 'Backout Credit';
            asst.Billing_Period__c = 'Monthly';
            asst.Start_Date__c = system.today();
            asst.End_Date__c = System.today().addMonths(1).addDays(2);
            asst.Product2Id = newProduct.id;
            asst.Haircut_Asset__c = false;
            asst.Inflight_Quote__c = null;
            asst.AutoRenewalPicked__c = true;
            insert asst;
           
        //Auto Quote Creation and Submit
        Asset assts1 = new Asset();
            assts1.Name = 'test';
            assts1.Renewal_Type__c = 'Auto';
            assts1.Auto_Renewal__c = 'Yes';
            assts1.Asset_Type__c = 'Parent';
            //assts1.AccountId = testAccount.id;
            assts1.Fulfillment_Status__c = 'Fulfilled';
            assts1.Status = 'Active';
            //assts1.Line_Type__c = 'Backout Credit';
            assts1.Billing_Period__c = 'Monthly';
            assts1.Start_Date__c = system.today();
            assts1.End_Date__c = System.today().addDays(5);
            assts1.Product2Id = newProduct.id;
            assts1.Haircut_Asset__c = false;
            assts1.Inflight_Quote__c = null;
            assts1.AutoRenewalPicked__c = true;
            insert assts1;
        System.debug('assts1:'+assts1);
        
        Asset_AR_Association__c arAsst= new Asset_AR_Association__c();
            arAsst.Asset_Id__c = assts1.Id;
            arAsst.AR_Config_Options__c = 'Land';
            arAsst.AR_Lead_PPL__c = 1;
            arAsst.AR_Brand_PPL__c = 1;
            arAsst.AR_AMLC_Residential__c = 1;
            arAsst.AR_AMLC_Land__c = 1;
            arAsst.AR_AMLC_Rental__c = 1;
            arAsst.AR_PPL_Override__c = 1;
            arAsst.External_ID__c = '1234-78979';
            arAsst.AR_Price_Info__c = '12^0.0^ASR_A/R_NewOrder_CBC10_Off^10.0^0.0^KWCBC25^10.0^0.0^0.0^0.0^0.0#';
            insert arAsst;
        
        //Asset Reset
        Asset asst1 = new Asset();
            asst1.Name = 'test';
            asst1.Renewal_Status__c = 'Renewed';
            asst1.Auto_Renewal__c = 'Yes';
            asst1.Asset_Type__c = 'Parent';
            asst1.AccountId = testAccount.id;
            asst1.Fulfillment_Status__c = 'Fulfilled';
            asst1.Status = 'Active';
            asst1.Line_Type__c = 'Backout Credit';
            asst1.Billing_Period__c = 'Monthly';
            asst1.Start_Date__c = System.today().addMonths(-1);
            asst1.End_Date__c = System.today().addMonths(1);
            asst1.Product2Id = newProduct.id;
            asst1.Haircut_Asset__c = false;
            asst1.Inflight_Quote__c = null;
            asst1.Follow_Up_Status__c = 'Renewed';
            insert asst1;
        
        
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
            insert assets;
            
        Asset assets1 = new Asset();
            assets1.Name = 'test';
            assets1.Renewal_Status__c = 'Renewed';
            assets1.Auto_Renewal__c = 'Yes';
            assets1.Asset_Type__c = 'Parent';
            assets1.AccountId = testAccount.id;
            assets1.Fulfillment_Status__c = 'Fulfilled';
            assets1.Status = 'Active';
            assets1.Line_Type__c = 'Backout Credit';
            assets1.Billing_Period__c = 'Monthly';
            assets1.Start_Date__c = system.today().addMonths(-1);
            assets1.End_Date__c = System.today().addMonths(2);
            assets1.Product2Id = newProduct.id;
            assets1.Haircut_Asset__c = false;
            assets1.Inflight_Quote__c = null;
            insert assets1;       
        
        test.startTest();
        ARIIQuoteCreationSchedulable sh1 = new ARIIQuoteCreationSchedulable();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
}