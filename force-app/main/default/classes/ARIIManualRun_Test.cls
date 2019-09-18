//Name        : ARIIManualRun_Test
//Description : Test class for ARIIManualRun.
//Author      : Pallavi Tammana

@isTest(seeAllData =false)
public  class ARIIManualRun_Test {

    public static testMethod void mainMethod1() {
           
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
        
        AutoRenewalNextEndDate__c autoDate = new AutoRenewalNextEndDate__c(Name = 'Auto Renewal End Date',Next_Month_Start_Date__c = System.today().addMonths(1),Next_Month_End_Date__c = System.today().addMonths(1).addDays(30));
        insert autoDate;
        
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
        
        Product2 newProduct1 = new Product2();
        newProduct1.Name = 'TestProduct1';
        newProduct1.Auto_Renewal__c = True;
        newProduct1.ProductCode='SELLERLEADS' ;
        newProduct1.Orderable__c= false;
        newProduct1.S_No__c = 2;
        insert newProduct1;
        
        Product2 newProduct2 = new Product2();
        newProduct2.Name = 'TestProduct1';
        newProduct2.Auto_Renewal__c = True;
        newProduct2.ProductCode = 'SHOWCASE' ;
        newProduct2.Orderable__c= true;
        newProduct2.S_No__c = 2;
        newProduct2.AR_Max_Discount_Threshold__c = 90;
        insert newProduct2;
        
        Product2 newProduct21 = new Product2();
        newProduct21.Name = 'TestProduct11';
        newProduct21.Auto_Renewal__c = True;
        newProduct21.ProductCode = 'SHOWCASE1' ;
        newProduct21.Orderable__c= true;
        newProduct21.S_No__c = 2;
        insert newProduct21;          
        
        //Inserting Test Account       
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
        testAccount.Primary_Email__c = 'testAccount@move.com';
        testAccount.Account_Sub_Type__c = 'Customer';
        testAccount.Auto_Renewal__c = true;
        testAccount.OwnerId = u.Id;
        testAccount.EssentialsStatus__c = 'Activated';
        insert testAccount;
        
        Account testAccount1 = TestDataFactory.createAccount('Test Account',null,false);
        testAccount1.Primary_Email__c = 'testAccount@move.com';
        testAccount1.Account_Sub_Type__c = 'Customer';
        testAccount1.Auto_Renewal__c = true;
        testAccount1.OwnerId = u.Id;
        testAccount1.EssentialsStatus__c = 'Activated';

        insert testAccount1;
        
        Account testAccount11 = TestDataFactory.createAccount('Test Account',null,false);
        testAccount11.Primary_Email__c = 'testAccount@move.com';
        testAccount11.Account_Sub_Type__c = 'Customer';
        testAccount11.Auto_Renewal__c = true;
        testAccount11.OwnerId = u.Id;
        testAccount11.EssentialsStatus__c = 'Activated';

        insert testAccount11;
        
        Account testAccount12 = TestDataFactory.createAccount('Test Account',null,false);
        testAccount12.Primary_Email__c = 'testAccount@move.com';
        testAccount12.Account_Sub_Type__c = 'Customer';
        testAccount12.Auto_Renewal__c = true;
        testAccount12.OwnerId = u.Id;
        testAccount12.EssentialsStatus__c = 'Activated';

        insert testAccount12;
         
        Account testAccount13 = TestDataFactory.createAccount('Test Account',null,false);
        testAccount13.Primary_Email__c = 'testAccount@move.com';
        testAccount13.Account_Sub_Type__c = 'Customer';
        testAccount13.Auto_Renewal__c = true;
        testAccount13.OwnerId = u.Id;
                testAccount13.EssentialsStatus__c = 'Activated';

        insert testAccount13;

         System.runAs(u) {   
                  
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
            assets.Last_Order_Activity_Date__c = null;
            assets.List_Price__c = 60;
            assets.Total_Net__c = 50;
            assets.Total_List_Price__c = 30;            
            insert assets;
            
            Asset asset1 = new Asset();
            asset1.Name = 'test';
            asset1.Renewal_Status__c = 'Renew';
            asset1.Auto_Renewal__c = 'Yes';
            asset1.Asset_Type__c = 'Parent';
            asset1.AccountId = testAccount1.id;
            asset1.Fulfillment_Status__c = 'Fulfilled';
            asset1.Status = 'Active';
            asset1.Line_Type__c = 'Backout Credit';
            asset1.Billing_Period__c = 'Monthly';
            asset1.Start_Date__c = system.today();
            asset1.End_Date__c = System.today().addMonths(1);
            asset1.Product2Id = newProduct21.id;
            asset1.Haircut_Asset__c = false;
            asset1.Inflight_Quote__c = null;
            asset1.Last_Order_Activity_Date__c = null;
            assets.List_Price__c = 60;
            assets.Total_Net__c = 50;
            assets.Total_List_Price__c = 30; 
            insert asset1;
            
            Asset ass1 = new Asset();
            ass1.Name = 'test';
            ass1.Renewal_Status__c = 'Renew';
            ass1.Auto_Renewal__c = 'Yes';
            ass1.Asset_Type__c = 'Parent';
            ass1.AccountId = testAccount11.id;
            ass1.Fulfillment_Status__c = 'Fulfilled';
            ass1.Status = 'Active';
            ass1.Line_Type__c = 'Backout Credit';
            ass1.Billing_Period__c = 'Monthly';
            ass1.Start_Date__c = system.today();
            ass1.End_Date__c = System.today().addMonths(1);
            ass1.Product2Id = newProduct2.id;
            ass1.Haircut_Asset__c = false;
            ass1.Inflight_Quote__c = null;
            ass1.Last_Order_Activity_Date__c = null; 
            insert ass1; 
            
            Asset asset = new Asset();
            asset.Name = 'test';
            asset.Renewal_Status__c = 'Renew';
            asset.Auto_Renewal__c = 'Yes';
            asset.Asset_Type__c = 'Parent';
            asset.AccountId = testAccount12.id;
            asset.Fulfillment_Status__c = 'Fulfilled';
            asset.Status = 'Active';
            asset.Line_Type__c = 'Backout Credit';
            asset.Billing_Period__c = 'Monthly';
            asset.Start_Date__c = system.today();
            asset.End_Date__c = System.today().addMonths(1);
            asset.Product2Id = newProduct1.id;
            asset.Haircut_Asset__c = false;
            asset.Inflight_Quote__c = null;
            asset.Last_Order_Activity_Date__c = null;
            insert asset;
            
            Asset ass = new Asset();
            ass.Name = 'test';
            ass.Renewal_Status__c = 'Renew';
            ass.Auto_Renewal__c = 'Yes';
            ass.Asset_Type__c = 'Parent';
            ass.AccountId = testAccount13.id;
            ass.Fulfillment_Status__c = 'Fulfilled';
            ass.Status = 'Active';
            ass.Line_Type__c = 'Backout Credit';
            ass.Billing_Period__c = 'Monthly';
            ass.Start_Date__c = system.today();
            ass.End_Date__c = System.today().addMonths(1);
            ass.Product2Id = newProduct2.id;
            ass.Haircut_Asset__c = false;
            ass.Inflight_Quote__c = null;
            ass.Last_Order_Activity_Date__c = null; 
            ass.Total_Net__c = 0;
            insert ass;
        }                
        
        Test.startTest();
       // ARIIManualrun.ARAssetmethod(testAccount.id);
        ARIIManualrun.ARAssetmethod(testAccount1.id);
        ARIIManualrun.ARAssetmethod(testAccount11.id);
        ARIIManualrun.ARAssetmethod(testAccount12.id);
        ARIIManualrun.ARAssetmethod(testAccount13.id);  
        Test.stopTest();
       
   }
   
   public static testMethod void mainMethod2() {
           
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
        
        AutoRenewalNextEndDate__c autoDate = new AutoRenewalNextEndDate__c(Name = 'Auto Renewal End Date',Next_Month_Start_Date__c = System.today().addMonths(1),Next_Month_End_Date__c = System.today().addMonths(1).addDays(30));
        insert autoDate;
        
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
         
        Account testAccount1 = TestDataFactory.createAccount('Test Account',null,false);
        testAccount1.Primary_Email__c = 'testAccount@move.com';
        testAccount1.Account_Sub_Type__c = 'Customer';
        testAccount1.Auto_Renewal__c = true;
        testAccount1.OwnerId = UserInfo.getUserId();
        testAccount1.EssentialsStatus__c = 'Activated';

        insert testAccount1;        
                
          System.runAs(u) {  
             BigMachines__Quote__c quoteauto = new BigMachines__Quote__c();
                quoteauto.BigMachines__Account__c = testAccount1.Id;        
                quoteauto.BigMachines__Status__c = 'InProgress';
                quoteauto.BigMachines_Quote_Type__c = 'Auto-Renew';
                quoteauto.Name = '2020-201345';
                insert quoteauto;                    
            
            Asset assets = new Asset();
                assets.Name = 'test';
                assets.Renewal_Status__c = 'Renew';
                assets.Auto_Renewal__c = 'Yes';
                assets.Asset_Type__c = 'Parent';
                assets.AccountId = testAccount1.id;
                assets.Fulfillment_Status__c = 'Fulfilled';
                assets.Status = 'Active';
                assets.Line_Type__c = 'Backout Credit';
                assets.Billing_Period__c = 'Monthly';
                assets.Start_Date__c = system.today();
                assets.End_Date__c = System.today().addMonths(1);
                assets.Product2Id = newProduct.id;
                assets.Haircut_Asset__c = false;
                assets.Inflight_Quote__c = null;
                assets.Last_Order_Activity_Date__c = null;
                assets.AutoRenewalPicked__c = True;
                assets.External_ID__c = '1234-78979';
                assets.ConfigOptions__c = 'Rental;';        
                insert assets;
                
            Asset ass = new Asset();
                ass.Name = 'test';
                ass.Renewal_Status__c = 'Renew';
                ass.Auto_Renewal__c = 'Yes';
                ass.Asset_Type__c = 'Parent';
                ass.AccountId = testAccount1.id;
                ass.Fulfillment_Status__c = 'Fulfilled';
                ass.Status = 'Active';
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
                ass.External_ID__c = '1234-789791';
                insert ass; 
        }          
        Test.startTest();
        ARIIManualrun.ARNightlymethod(testAccount1.id);
          
        Test.stopTest();
       
   }
}