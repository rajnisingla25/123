//Name        : ARIIAssettPriceUpdateBatch_Test 
//Description : Test class for ARIIAssettPriceUpdateBatch.
//Author      : Pallavi Tammana

@isTest(seeAllData =false)
public  class ARIIAssettPriceUpdateBatch_Test {

    public static testMethod void mainMethod1() {
        list<Asset> li2 = new list<Asset>();
        
        set<id> accids = new set<id>();
        list<Account> accListids = new list<Account>();
           
        Profile p = [select id from profile where name='Move Field Sales Rep'];
        User u = new User(alias = 'standt', email='standarduser@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/New_York', username='autorenewaluser@test.com'); 
        insert u;
    
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        AutoRenewal__c ar = new AutoRenewal__c(Name='Move Field Sales Rep', AccountType__c='RD Account',ProductCodes__c='SHOWCASE');
        insert ar;
        
        AutoRenewalNextEndDate__c autoDate = new AutoRenewalNextEndDate__c(Name = 'Auto Renewal End Date', SubmitDays__c = 5, Next_Month_Start_Date__c = System.today().addMonths(1),Next_Month_End_Date__c = System.today().addMonths(1).addDays(30));
        insert autoDate;
        
        Schedule_Batch_Setting__c priceUpdate = new Schedule_Batch_Setting__c(Name = 'ARII Price Update',Is_Running__c = True);
        insert priceUpdate;
        
        Schedule_Batch_Setting__c autoReset = new Schedule_Batch_Setting__c(Name = 'ARII Reset Asset',Is_Running__c = True , Assetresttime__c = -1);
        insert autoReset;
               
        Product2 newProduct = new Product2();
        newProduct.Name = 'TestProduct';
        newProduct.Commission_Category__c = 'Normal';    
        newProduct.Normalization_factor__c = 1.10;
        newProduct.Commission_Category__c = 'CFCB';
        newProduct.Fulfillment_Type__c = 'Manual';
        newProduct.Auto_Renewal__c = True;
        newProduct.ProductCode='ADVANTAGE' ;
        newProduct.Orderable__c= true;
        newProduct.S_No__c = 2;
        newProduct.AR_Max_Discount_Threshold__c = 90;
        insert newProduct;
        
        Product2 newProduct2 = new Product2();
        newProduct2.Name = 'TestProduct1';
        newProduct2.Auto_Renewal__c = True;
        newProduct2.ProductCode = 'SHOWCASE' ;
        newProduct2.Orderable__c= true;
        newProduct2.S_No__c = 2;
        newProduct2.AR_Max_Discount_Threshold__c = 90;
        insert newProduct2;        
        
        System.runAs(u) {
        
            //Inserting Test Account       
            Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
            testAccount.Primary_Email__c = 'testAccount@move.com';
            testAccount.Account_Sub_Type__c = 'Customer';
            testAccount.Auto_Renewal__c = true;
            testAccount.OwnerId = u.Id;
            insert testAccount; 
            accListids.add(testAccount);
            
            BigMachines__Quote__c quoteauto = new BigMachines__Quote__c();
            quoteauto.BigMachines__Account__c = testAccount.Id;        
            quoteauto.BigMachines__Status__c = 'InProgress';
            quoteauto.BigMachines_Quote_Type__c = 'Auto-Renew';
            quoteauto.Name = '2020-201345';
            insert quoteauto;
            
                  
            Asset assets = new Asset();
            assets.Name = 'test';
            assets.Renewal_Status__c = 'Renew';
            assets.Auto_Renewal__c = 'Yes';
            assets.Asset_Type__c = 'Parent';
            assets.AccountId = testAccount.id;
            assets.Fulfillment_Status__c = 'Fulfilled';
            assets.Status = 'Active';
            assets.ConfigOptions__c = 'Residential';
            assets.Line_Type__c = 'Backout Credit';
            assets.Billing_Period__c = 'Monthly';
            assets.Start_Date__c = system.today();
            assets.End_Date__c = System.today().addMonths(1);
            assets.Product2Id = newProduct.id;
            assets.Haircut_Asset__c = false;
            assets.Inflight_Quote__c = null;
            assets.Last_Order_Activity_Date__c = null;
            assets.AutoRenewalPicked__c = True;  
            assets.renewal_type__c = 'Auto';
            insert assets;
            
            Asset_AR_Association__c arAsst= new Asset_AR_Association__c();
            arAsst.Asset_Id__c = assets.Id;
            arAsst.External_ID__c = '1234-78979';
            insert arAsst;
            
            Asset ass = new Asset();
            ass.Name = 'test';
            ass.Renewal_Status__c = 'Renew';
            ass.Auto_Renewal__c = 'Yes';
            ass.Asset_Type__c = 'Parent';
            ass.AccountId = testAccount.id;
            ass.Fulfillment_Status__c = 'Fulfilled';
            ass.Status = 'Active';
            ass.ConfigOptions__c = 'Residential';
            ass.Line_Type__c = 'Backout Credit';
            ass.Billing_Period__c = 'Monthly';
            ass.Start_Date__c = system.today();
            ass.End_Date__c = System.today().addMonths(1);
            ass.Product2Id = newProduct2.id;
            ass.Haircut_Asset__c = false;
            ass.Inflight_Quote__c = null;
            ass.Last_Order_Activity_Date__c = null;
            ass.AutoRenewalPicked__c = True;
            ass.AR_Oversold_Flag__c = True;
            assets.renewal_type__c = 'Auto';


            insert ass;           
                      
            Asset_AR_Association__c ars = new Asset_AR_Association__c();
            ars.Error_Flag__c = true;
            ars.Asset_Id__c = ass.id;
            insert ars;
            
            accids.add(testAccount.id);    
                   
            //li2.add(assets);
        }
        
                   
        ARIIAssettPriceUpdateBatch ARQCB = new  ARIIAssettPriceUpdateBatch(accids);
                
        
        Test.startTest();

        Database.BatchableContext bc;
      //  ARQCB.session(null,null);           
        ARQCB.start(bc);
        ARQCB.execute(bc,accListids);
        ARQCB.finish(bc);               
          
        Test.stopTest();
       
   }
   
   public static testMethod void mainMethod2() {
        list<Asset> li2 = new list<Asset>();
        
        set<id> accids = new set<id>();
        list<Account> accListids = new list<Account>();
           
        Profile p = [select id from profile where name='Move Field Sales Rep'];
        User u = new User(alias = 'standt', email='standarduser@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/New_York', username='autorenewaluser@test.com'); 
        insert u;
    
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        AutoRenewal__c ar = new AutoRenewal__c(Name='Move Field Sales Rep', AccountType__c='RD Account',ProductCodes__c='SHOWCASE');
        insert ar;
        
        AutoRenewalNextEndDate__c autoDate = new AutoRenewalNextEndDate__c(Name = 'Auto Renewal End Date', SubmitDays__c = 5, Next_Month_Start_Date__c = System.today().addMonths(1),Next_Month_End_Date__c = System.today().addMonths(1).addDays(30));
        insert autoDate;
        
        Schedule_Batch_Setting__c priceUpdate = new Schedule_Batch_Setting__c(Name = 'ARII Price Update',Is_Running__c = True);
        insert priceUpdate;
        
        Schedule_Batch_Setting__c autoReset = new Schedule_Batch_Setting__c(Name = 'ARII Reset Asset',Is_Running__c = True , Assetresttime__c = -1);
        insert autoReset;
        
        BigMachineUrls__c bmUrl = new BigMachineUrls__c(Name = 'Test1', BigmachineInstance__c = '', Bigmachine_Url__c = 'https://moveinc--dev.cs79.visual.force.com​', DefaultPassword__c = 'testPrice', DefaultUserName__c = 'testPrice@move.com', Parallel_Processing_User__c = True, Salesforce_Instance__c = 'https://moveinc--dev.cs79.visual.force.com​');
        insert bmUrl;
        
        BigMachineUrls__c bmUrl2 = new BigMachineUrls__c(Name = 'Test2', BigmachineInstance__c = '', Bigmachine_Url__c = 'https://moveinc--dev.cs79.visual.force.com​', DefaultPassword__c = 'testPrice', DefaultUserName__c = 'testPrice@move.com', Parallel_Processing_User__c = True, Salesforce_Instance__c = 'https://moveinc--dev.cs79.visual.force.com​');
        insert bmUrl2;       
        
        
        Product2 newProduct = new Product2();
        newProduct.Name = 'TestProduct';
        newProduct.Commission_Category__c = 'Normal';    
        newProduct.Normalization_factor__c = 1.10;
        newProduct.Commission_Category__c = 'CFCB';
        newProduct.Fulfillment_Type__c = 'Manual';
        newProduct.Auto_Renewal__c = True;
        newProduct.ProductCode='ADVANTAGE' ;
        newProduct.Orderable__c= true;
        newProduct.S_No__c = 2;
        newProduct.AR_Max_Discount_Threshold__c = 90;
        insert newProduct;
        
        Product2 newProduct2 = new Product2();
        newProduct2.Name = 'TestProduct1';
        newProduct2.Auto_Renewal__c = True;
        newProduct2.ProductCode = 'SHOWCASE' ;
        newProduct2.Orderable__c= true;
        newProduct2.S_No__c = 2;
        newProduct2.AR_Max_Discount_Threshold__c = 90;
        insert newProduct2;        
        Set<Id> accountIds = new Set<Id>();

        System.runAs(u) {
        
            //Inserting Test Account       
            Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
            testAccount.Primary_Email__c = 'testAccount@move.com';
            testAccount.Account_Sub_Type__c = 'Customer';
            testAccount.Auto_Renewal__c = true;
            testAccount.OwnerId = u.Id;
            insert testAccount; 
            accListids.add(testAccount);
            accountIds.add(testAccount.Id);
            
             Account testAccount2 = TestDataFactory.createAccount('Test Account',null,false);
            testAccount2.Primary_Email__c = 'testAccount@move.com';
            testAccount2.Account_Sub_Type__c = 'Customer';
            testAccount2.Auto_Renewal__c = true;
            testAccount2.OwnerId = u.Id;
            insert testAccount2; 
            accListids.add(testAccount2);
             accountIds.add(testAccount2.Id);
            
             Account testAccount3 = TestDataFactory.createAccount('Test Account',null,false);
            testAccount3.Primary_Email__c = 'testAccount@move.com';
            testAccount3.Account_Sub_Type__c = 'Customer';
            testAccount3.Auto_Renewal__c = true;
            testAccount3.OwnerId = u.Id;
            insert testAccount3; 
            accListids.add(testAccount3);
             accountIds.add(testAccount3.Id);
            
             Account testAccount4 = TestDataFactory.createAccount('Test Account',null,false);
            testAccount4.Primary_Email__c = 'testAccount@move.com';
            testAccount4.Account_Sub_Type__c = 'Customer';
            testAccount4.Auto_Renewal__c = true;
            testAccount4.OwnerId = u.Id;
            insert testAccount4; 
            accListids.add(testAccount4);
             accountIds.add(testAccount4.Id);
            
            BigMachines__Quote__c quoteauto = new BigMachines__Quote__c();
            quoteauto.BigMachines__Account__c = testAccount.Id;        
            quoteauto.BigMachines__Status__c = 'InProgress';
            quoteauto.BigMachines_Quote_Type__c = 'Auto-Renew';
            quoteauto.Name = '2020-201345';
            insert quoteauto;
            
                  
            Asset assets = new Asset();
            assets.Name = 'test';
            assets.Renewal_Status__c = 'Renew';
            assets.Auto_Renewal__c = 'Yes';
            assets.Asset_Type__c = 'Parent';
            assets.AccountId = testAccount.id;
            assets.Fulfillment_Status__c = 'Fulfilled';
            assets.Status = 'Active';
            assets.ConfigOptions__c = 'Residential';
            assets.Line_Type__c = 'Backout Credit';
            assets.Billing_Period__c = 'Monthly';
            assets.Start_Date__c = system.today();
            assets.End_Date__c = System.today().addMonths(1);
            assets.Product2Id = newProduct.id;
            assets.Haircut_Asset__c = false;
            assets.Inflight_Quote__c = null;
            assets.Last_Order_Activity_Date__c = null;
            assets.AutoRenewalPicked__c = True;  
            assets.renewal_type__c = 'Auto';
            insert assets;
            
            Asset_AR_Association__c arAsst= new Asset_AR_Association__c();
            arAsst.Asset_Id__c = assets.Id;
            arAsst.External_ID__c = '1234-78979';
            insert arAsst;
            
            Asset ass = new Asset();
            ass.Name = 'test';
            ass.Renewal_Status__c = 'Renew';
            ass.Auto_Renewal__c = 'Yes';
            ass.Asset_Type__c = 'Parent';
            ass.AccountId = testAccount.id;
            ass.Fulfillment_Status__c = 'Fulfilled';
            ass.Status = 'Active';
            ass.ConfigOptions__c = 'Residential';
            ass.Line_Type__c = 'Backout Credit';
            ass.Billing_Period__c = 'Monthly';
            ass.Start_Date__c = system.today();
            ass.End_Date__c = System.today().addMonths(1);
            ass.Product2Id = newProduct2.id;
            ass.Haircut_Asset__c = false;
            ass.Inflight_Quote__c = null;
            ass.Last_Order_Activity_Date__c = null;
            ass.AutoRenewalPicked__c = True;
            ass.AR_Oversold_Flag__c = True;
            assets.renewal_type__c = 'Auto';


            insert ass;           
                      
            Asset_AR_Association__c ars = new Asset_AR_Association__c();
            ars.Error_Flag__c = true;
            ars.Asset_Id__c = ass.id;
            insert ars;
            
            accids.add(testAccount.id);    
                   
            //li2.add(assets);
        }
        
                   
       // ARIIAssettPriceUpdateBatch ARQCB = new  ARIIAssettPriceUpdateBatch(accids);                        
        Test.startTest();
      //  Database.BatchableContext bc;           
      //  ARQCB.start(bc);
      //  ARQCB.execute(bc,accListids);
        
        Account testAccount1 = TestDataFactory.createAccount('Test Account',null,false);
            testAccount1.Primary_Email__c = 'testAccount@move.com';
            testAccount1.Account_Sub_Type__c = 'Customer';
            testAccount1.Auto_Renewal__c = true;
            insert testAccount1; 
            accListids.add(testAccount1);
        
         Asset ass1 = new Asset();
            ass1.Name = 'test';
            ass1.Renewal_Status__c = 'Renew';
            ass1.Auto_Renewal__c = 'Yes';
            ass1.Asset_Type__c = 'Parent';
            ass1.AccountId = testAccount1.id;
            ass1.Fulfillment_Status__c = 'Fulfilled';
            ass1.Status = 'Active';
            ass1.ConfigOptions__c = 'Residential';
            ass1.Line_Type__c = 'Backout Credit';
            ass1.Billing_Period__c = 'Monthly';
            ass1.Start_Date__c = system.today();
            ass1.End_Date__c = System.today().addMonths(1);
            ass1.Product2Id = newProduct2.id;
            ass1.Haircut_Asset__c = false;
            ass1.Inflight_Quote__c = null;
            ass1.Last_Order_Activity_Date__c = null;
            ass1.AutoRenewalPicked__c = True;
            ass1.AR_Oversold_Flag__c = True;
            ass1.renewal_type__c = 'Auto';
            insert ass1;           
                      
            Asset_AR_Association__c ars1 = new Asset_AR_Association__c();
            ars1.Error_Flag__c = true;
            ars1.Asset_Id__c = ass1.id;
            insert ars1;
        
        ARIIUtility.parallelProcessAccountsForPriceUpdate(accountIds);
      //  ARIIAssettPriceUpdateBatch ARQCB1 = new  ARIIAssettPriceUpdateBatch(accids,bmUrl);
      //  ARQCB1.finish(bc);
          
        Test.stopTest();
       
   }
}