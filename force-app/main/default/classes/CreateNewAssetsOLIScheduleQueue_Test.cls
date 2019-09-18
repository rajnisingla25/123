@isTest(seeAllData =false)
public  class CreateNewAssetsOLIScheduleQueue_Test{
    // Private Data Member
    private static final Integer COUNTER = 20;
    public static testMethod void mainMethod1(){       
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;       
        Error_Notification_Email_Settings__c ent = new Error_Notification_Email_Settings__c(Name ='Email Addresses' ,Asset_Creation_Batch_Distribution__c = 'Test@test.com',Asset_Creation_Error_Emails__c = 'Test@test.com',View_Link__c = 'https://cs11.salesforce.com/02i?fcf=00BZ00000017ilI');
        insert ent; 
        Schedule_Batch_Setting__c Evga = new Schedule_Batch_Setting__c(Name ='Evergreeen Renewal Date',Date_Value__c = system.today().adddays(-300));
        insert Evga;
        Schedule_Batch_Setting__c set1 = new Schedule_Batch_Setting__c(Name ='Evergreen Prosoft Renewal',Is_Running__c = true);
        insert set1;
        //Inserting Test Account 
        OrderDecompController.stopCreatingAccount = true;      
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
        testAccount.Primary_Email__c = 'testAccount@move.com';
        testAccount.party_id__c = '123456';
        insert testAccount;    
        Product2 newProduct = new Product2();
        newProduct.Name = 'TestProduct';     
        newProduct.S_No__c = 2;
        newProduct.ProductCode='ADVANTAGE';
        newProduct.Renewal_Term_Type__c= 'termed';
        insert newProduct;    
        
        Product2 newProductt = new Product2();
        newProductt.Name = 'TURBO';     
        newProductt.S_No__c = 2;
        newProductt.ProductCode='TURBO';
        newProductt.Renewal_Term_Type__c= 'termed';
        insert newProductt;  
        
        Product2 newProduct12 = new Product2();
        newProduct12.Name = 'MARKET';     
        newProduct12.S_No__c = 2;
        newProduct12.ProductCode='TOPMKSNHT';
        newProduct12.Renewal_Term_Type__c= 'Evergreen';
        insert newProduct12; 
        // Inserting Assets.
        List<Asset> theTestAssets = new List<Asset>();
        for(Integer index = 0; index < COUNTER; index++) {
            theTestAssets.add(new Asset(
                Name = 'Test Asset - ' + index,
                AccountId = testAccount.Id,
                Price = 10,
                End_Date__c = Date.today().addDays(-1),
                Auto_Renewal__c = 'No',
                Status = 'Active',
                Renewal_Status__c = 'Renew',
                Asset_Type__c = 'Parent',       
                Fulfillment_Status__c = 'Waiting to Process',        
                Line_Type__c = 'Add',
                Billing_Period__c = 'Monthly',
                Start_Date__c = system.today()       
                
            ));
        }  
        insert theTestAssets;    
        theTestAssets[0].Fulfillment_Required__c = false ;
        update theTestAssets[0];   
        
        Id theStandardPriceBookId = Test.getStandardPricebookId(); 
        
        Order  Orders = new Order();
        Orders.AccountId = testAccount.id;
        Orders.Fulfillment_Status__c = 'Pending Fulfillment';
        Orders.Status = 'Created';
        Orders.EffectiveDate = System.today().addDays(-1) ;
        Orders.Is_OLI_Creation_Complete__c =false ;
        Orders.Type = 'New';
        Orders.Name = 'Test order'; 
        Orders.Pricebook2Id = theStandardPriceBookId ;
        Orders.EndDate = system.today().addDays(100);
        insert Orders;        
        PricebookEntry  thePricebookEntrie = new PricebookEntry();
        thePricebookEntrie.Pricebook2Id = theStandardPriceBookId;
        thePricebookEntrie.Product2Id = newProduct.id;
        thePricebookEntrie.UnitPrice = 1000;
        thePricebookEntrie.IsActive = true;
        Insert thePricebookEntrie;
        PricebookEntry  thePricebookEntriet = new PricebookEntry();
        thePricebookEntriet.Pricebook2Id = theStandardPriceBookId;
        thePricebookEntriet.Product2Id = newProductt.id;
        thePricebookEntriet.UnitPrice = 1000;
        thePricebookEntriet.IsActive = true;
        Insert thePricebookEntriet;
        
        List<OrderItem> lstOrderItem = new List<OrderItem>();
        OrderItem OrderItems = new OrderItem();
        OrderItems.UnitPrice = 789.62;
        OrderItems.Market__c = '345354';
        OrderItems.Quantity = 6;
        //OrderItems.StartDate = System.Today();
        OrderItems.ServiceDate = System.Today();
        OrderItems.EndDate = System.Today().AddDays(90);
        OrderItems.Asset__c = theTestAssets[0].Id;
        //OrderItems.Asset__c = CreateFullfilledAssetSingle().id;
        OrderItems.OrderId = Orders.id;
        OrderItems.Line_Type__c = 'Add';
        OrderItems.Auto_Renewal__c = 'Yes';
        OrderItems.Product_Type__c = 'Showcase';
        OrderItems.Fulfillment_Status__c = 'Pending Fulfillment';
        OrderItems.PricebookEntryId = thePricebookEntrie.id;
        lstOrderItem.add(OrderItems);
        //Insert OrderItems;
        
        OrderItem OrderItems1 = new OrderItem();
        OrderItems1.UnitPrice = 789.62;
        OrderItems1.Market__c = '345354';
        OrderItems1.Quantity = 6;
        //OrderItems.StartDate = System.Today();
        OrderItems1.ServiceDate = System.Today();
        OrderItems1.EndDate = System.Today().AddDays(90);
        OrderItems1.Asset__c = theTestAssets[0].Id;
        //OrderItems.Asset__c = CreateFullfilledAssetSingle().id;
        OrderItems1.OrderId = Orders.id;
        OrderItems1.Line_Type__c = 'Renew';
        OrderItems1.Auto_Renewal__c = 'Yes';
        OrderItems1.Product_Type__c = 'Turbo';
        OrderItems1.Fulfillment_Status__c = 'Pending Fulfillment';
        OrderItems1.PricebookEntryId = thePricebookEntriet.id;
        //Insert OrderItems;
        lstOrderItem.add(OrderItems1);
        Insert lstOrderItem;
        
        Test.startTest();
        try{
        Set<String> setTPandTigerCode = new Set<String>();
         Set<String> theproductcode = new Set<String>();
            Set<String> thePromotions = new Set<String>();
            CreateNewAssetsOLIScheduleQueue CNASch = new CreateNewAssetsOLIScheduleQueue();
            
            CNASch.AssetExpiration(setTPandTigerCode,theproductcode,thePromotions,theTestAssets);
            String myDateTime = String.Valueof(datetime.now().addseconds(10));
            String[] strs =myDateTime.split('-',5);      
            String[] strs2=strs[2].split(':',5);      
            String[] strs3=strs2[0].split(' ',3);     
            String schdul= strs2[2]+' '+strs2[1]+' '+strs3[1]+' '+strs3[0]+' '+strs[1]+' '+'?';    
            System.debug(schdul);            
            system.schedule('CreateNewAssetsOLIAssetJSONSchedule Job1',schdul,CNASch );    
            System.debug('Test Started'); 
        }catch(exception e){}
        Test.stopTest();
    }
    
    public static testMethod void mainMethod2(){   
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;   
        Error_Notification_Email_Settings__c ent = new Error_Notification_Email_Settings__c(Name ='Email Addresses' ,Asset_Creation_Batch_Distribution__c = 'Test@test.com',Asset_Creation_Error_Emails__c = 'Test@test.com',View_Link__c = 'https://cs11.salesforce.com/02i?fcf=00BZ00000017ilI');
        insert ent; 
          Schedule_Batch_Setting__c Evga = new Schedule_Batch_Setting__c(Name ='Evergreeen Renewal Date',Date_Value__c = system.today().adddays(-300));
        insert Evga;
      
        Product2 newProduct = new Product2();
        newProduct.Name = 'TestProduct';     
        newProduct.S_No__c = 2;
        newProduct.Renewal_Term_Type__c= 'termed';
        insert newProduct;   
        // Inserting Assets.
        List<Asset> theTestAssets = new List<Asset>();
        for(Integer index = 0; index < COUNTER; index++) {
            theTestAssets.add(new Asset(
                Name = 'Test Asset - ' + index,         
                Status = 'Active',         
                Asset_Type__c = 'Parent',       
                Fulfillment_Status__c = 'Waiting to Process',        
                Line_Type__c = 'Add',  
                End_Date__c = System.today().adddays(-2), 
                Product2Id =  newProduct.Id,  
                Fulfillment_Required__c = false      
            ));
        }  
        insert theTestAssets; 
        update  theTestAssets;  
        
        Test.startTest();        
        CreateNewAssetsOLIScheduleQueue CNASch = new CreateNewAssetsOLIScheduleQueue();  
        try{
                  
            String myDateTime = String.Valueof(datetime.now().addseconds(10));
            String[] strs =myDateTime.split('-',5);      
            String[] strs2=strs[2].split(':',6);      
            String[] strs3=strs2[0].split(' ',3);     
            String schdul= strs2[2]+' '+strs2[1]+' '+strs3[1]+' '+strs3[0]+' '+strs[1]+' '+'?';    
            System.debug(schdul);          
            system.schedule('CreateNewAssetsOLIAssetJSONSchedule Job2',schdul,CNASch );   
        }catch(exception e){} 
        CNASch.ProcessFulfillmentNotRequired(2);
        Test.stopTest();
    }
    
    
    public static testMethod void mainMethod4(){   
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;   
        Error_Notification_Email_Settings__c ent = new Error_Notification_Email_Settings__c(Name ='Email Addresses' ,Asset_Creation_Batch_Distribution__c = 'Test@test.com',Asset_Creation_Error_Emails__c = 'Test@test.com',View_Link__c = 'https://cs11.salesforce.com/02i?fcf=00BZ00000017ilI');
        insert ent; 
        Schedule_Batch_Setting__c Evga = new Schedule_Batch_Setting__c(Name ='Evergreeen Renewal Date',Date_Value__c = system.today().adddays(-300));
        insert Evga;
        Product2 newProduct = new Product2();
        newProduct.Name = 'Test1';     
        newProduct.S_No__c = 3;
       // newProduct.Renewal_Term_Type__c= 'evergreen';
        newProduct.ProductCode='COBROKE';
        insert newProduct;   
        // Inserting Assets.
        List<Asset> theTestAssets = new List<Asset>();
        for(Integer index = 0; index < COUNTER; index++) {
            theTestAssets.add(new Asset(
                Name = 'Test Asset - ' + index,         
                Status = 'Expired',  
                trial__c = true,
                Asset_Type__c = 'Parent',  
                Renewal_Status__c ='Do Not Renew',
                Fulfillment_Status__c = 'Waiting to Process',        
                Line_Type__c = 'Cancel',  
                End_Date__c = System.Today().adddays(-1), 
                TCV_Processed__c = 'false',
                Delta_Price_w_o_Tax__c = 0.00,
                Amend_Delta_Price__c = 0.00,
                Product2Id =  newProduct.Id,  
                Fulfillment_Required__c = true        
            ));
        }  
        insert theTestAssets; 
        update  theTestAssets;  
        
        Test.startTest();        
        CreateNewAssetsOLIScheduleQueue CNASch = new CreateNewAssetsOLIScheduleQueue();  
        try{
                  
            String myDateTime = String.Valueof(datetime.now().addseconds(10));
            String[] strs =myDateTime.split('-',5);      
            String[] strs2=strs[2].split(':',6);      
            String[] strs3=strs2[0].split(' ',3);     
            String schdul= strs2[2]+' '+strs2[1]+' '+strs3[1]+' '+strs3[0]+' '+strs[1]+' '+'?';    
            System.debug(schdul);          
            system.schedule('CreateNewAssetsOLIAssetJSONSchedule Job44',schdul,CNASch );   
        }catch(exception e){} 
       CNASch.ProcessFulfillmentNotRequired(3);
        Test.stopTest();
    }
    
    public static testMethod void mainMethod41(){  
        Product2 newProduct1 = new Product2();
        newProduct1.Name = 'Evergreen';     
        newProduct1.S_No__c = 7;
        newProduct1.ProductCode='FIVESTREET';
        newProduct1.Renewal_Term_Type__c= 'Evergreen';
        insert newProduct1; 
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;   
        Error_Notification_Email_Settings__c ent = new Error_Notification_Email_Settings__c(Name ='Email Addresses' ,Asset_Creation_Batch_Distribution__c = 'Test@test.com',Asset_Creation_Error_Emails__c = 'Test@test.com',View_Link__c = 'https://cs11.salesforce.com/02i?fcf=00BZ00000017ilI');
        insert ent; 
        Schedule_Batch_Setting__c Evga = new Schedule_Batch_Setting__c(Name ='Evergreeen Renewal Date',Date_Value__c = system.today().adddays(-300));
        insert Evga;
        Product2 newProduct = new Product2();
        newProduct.Name = 'Test1';     
        newProduct.S_No__c = 5;
        newProduct.Renewal_Term_Type__c ='termed';
        newProduct.ProductCode='TOPIDX';
        insert newProduct;   
        // Inserting Assets.
        List<Asset> theTestAssets = new List<Asset>();
        for(Integer index = 0; index < COUNTER; index++) {
            theTestAssets.add(new Asset(
                Name = 'Test Asset - ' + index,         
                Status = 'Active',    
                Month_to_Month__c = 'Y',
                Asset_Type__c = 'Parent',
                Fulfillment_Status__c = 'Waiting to Process',        
                Line_Type__c = 'Renew',  
                Start_Date__c =  Date.newInstance(2016, 02, 11),
                End_Date__c = Date.newInstance(2026, 12, 31),
                Product2Id =  newProduct.Id,  
                Fulfillment_Required__c = true      
            ));
        }  
        for(Integer index = 0; index < COUNTER; index++) {
            theTestAssets.add(new Asset(
                Name = 'Test Asset01 - ' + index,         
                Status = 'Active',    
                Asset_Type__c = 'Parent',
                Fulfillment_Status__c = 'Fulfilled',        
                Line_Type__c = 'Add',  
                Start_Date__c =  System.today().addDays(-360),
                End_Date__c = System.today(),
                Product2Id =  newProduct1.Id,  
                Fulfillment_Required__c = true,
                TCV_Processed__c = 'false',
                Delta_Price_w_o_Tax__c = 0.00,
                Amend_Delta_Price__c = 0.00
            ));
        }        
        insert theTestAssets; 
        
        Test.startTest();        
        CreateNewAssetsOLIScheduleQueue CNASch = new CreateNewAssetsOLIScheduleQueue();
        try{
                  
            String myDateTime = String.Valueof(datetime.now().addseconds(10));
            String[] strs =myDateTime.split('-',5);      
            String[] strs2=strs[2].split(':',6);      
            String[] strs3=strs2[0].split(' ',3);     
            String schdul= strs2[2]+' '+strs2[1]+' '+strs3[1]+' '+strs3[0]+' '+strs[1]+' '+'?';    
            System.debug(schdul);          
            system.schedule('CreateNewAssetsOLIAssetJSONSchedule Job44',schdul,CNASch );   
        }catch(exception e){} 
        CNASch.ProcessFulfillmentNotRequired(5);
        List<String> lstTPandTigerCode = (System.label.TPandTigerProduct+'').split(',');
        Set<String> setTPandTigerCode = new Set<String>();
        for(String str :lstTPandTigerCode){
            setTPandTigerCode.add(str);
        }
        CNASch.AssetExpiration(setTPandTigerCode, new Set<String>(), new Set<String>(), theTestAssets);
        theTestAssets[0].End_Date__c = System.today() + 1;
        update theTestAssets; 
        CNASch.AssetExpiration(setTPandTigerCode, new Set<String>(), new Set<String>(), theTestAssets);
        newProduct.Renewal_Term_Type__c = 'evergreen';
        update newProduct;
        //theTestAssets[0].End_Date__c = System.today() - 1;
        //update theTestAssets; 
        CNASch.AssetExpiration(setTPandTigerCode, new Set<String>(), new Set<String>(), theTestAssets);
        Test.stopTest();
    }
    public static testMethod void mainMethod3(){   
        //Inserting Customsetting for Account 
        Error_Notification_Email_Settings__c ent = new Error_Notification_Email_Settings__c(Name ='Email Addresses' ,Asset_Creation_Batch_Distribution__c = 'Test@test.com',Asset_Creation_Error_Emails__c = 'Test@test.com',View_Link__c = 'https://cs11.salesforce.com/02i?fcf=00BZ00000017ilI');
        insert ent; 
        Error_Notification_Email_Settings__c ent1 = new Error_Notification_Email_Settings__c(Name ='Evergreen Prosoft Renewal Failure' ,Asset_Creation_Batch_Distribution__c = 'Test@test.com',Asset_Creation_Error_Emails__c = 'Test@test.com',View_Link__c = 'https://cs11.salesforce.com/02i?fcf=00BZ00000017ilI');
        insert ent1;
          Schedule_Batch_Setting__c Evga = new Schedule_Batch_Setting__c(Name ='Evergreeen Renewal Date',Date_Value__c = system.today().adddays(-300));
        insert Evga;
      
        Test.startTest();  
        try{
            CreateNewAssetsOLIScheduleQueue CNASch = new CreateNewAssetsOLIScheduleQueue();          
            String myDateTime = String.Valueof(datetime.now().addseconds(10));
            String[] strs =myDateTime.split('-',5);      
            String[] strs2=strs[2].split(':',6);      
            String[] strs3=strs2[0].split(' ',3);     
            String schdul= strs2[2]+' '+strs2[1]+' '+strs3[1]+' '+strs3[0]+' '+strs[1]+' '+'?';    
            System.debug(schdul);          
            system.schedule('CreateNewAssetsOLIAssetJSONSchedule Job2',schdul,CNASch );  
            CNASch.ErrorEmail(); 
            CreateNewAssetsOLIScheduleQueue.sendEvergreenProsoftRenewalFailureEmail(new Map<String, String> {'id'=> 'error'});
        }catch(exception e){} 
        Test.stopTest();
    }
    
    public static testMethod void mainMethod5(){  
        Prosoft_Evergreen_Renewal_Setting__c setting = new Prosoft_Evergreen_Renewal_Setting__c(Name='ContractEffectiveDate', value__c='0', Active__c=true);
        insert setting;
        Product2 newProduct1 = new Product2();
        newProduct1.Name = 'Evergreen';     
        newProduct1.S_No__c = 7;
        newProduct1.ProductCode='FIVESTREET';
        newProduct1.Prosoft_Evergreen_Renewal__c= true;
        insert newProduct1; 
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;   
        Error_Notification_Email_Settings__c ent = new Error_Notification_Email_Settings__c(Name ='Email Addresses' ,Asset_Creation_Batch_Distribution__c = 'Test@test.com',Asset_Creation_Error_Emails__c = 'Test@test.com',View_Link__c = 'https://cs11.salesforce.com/02i?fcf=00BZ00000017ilI');
        insert ent; 
        Schedule_Batch_Setting__c Evga = new Schedule_Batch_Setting__c(Name ='Evergreeen Renewal Date',Date_Value__c = system.today().adddays(-300));
        insert Evga;
        List<Asset> theTestAssets = new List<Asset>();
        for(Integer index = 0; index < 1; index++) {
            theTestAssets.add(new Asset(
                Name = 'Test Asset01 - ' + index,         
                Status = 'Active',    
                Asset_Type__c = 'Parent',
                Fulfillment_Status__c = 'Fulfilled',        
                Line_Type__c = 'Add',  
                Start_Date__c =  System.today().addDays(-360),
                End_Date__c = System.today(),
                Product2Id =  newProduct1.Id,  
                Fulfillment_Required__c = true,
                TCV_Processed__c = 'false',
                Delta_Price_w_o_Tax__c = 0.00,
                Amend_Delta_Price__c = 0.00,
                Prosoft_Evergreen_Renewal__c=true
            ));
        }        
        insert theTestAssets; 
        List<Asset> assets = [Select Subscription_Id__c, product2.Prosoft_Evergreen_Renewal__c, Prosoft_Evergreen_Renewal__c, Id,Name,Account.Account_Owner_Team__c,Trial__c,Start_Date__c,Promotion__c,Extended_Net_Price__c,Month_to_Month__c,Renewal_Status__c,Product2.ProductCode,End_Date__c,Delta_Price_w_o_Tax__c,Product2.Renewal_Term_Type__c,Amend_Delta_Price__c,Fulfillment_Status__c,Status,Line_Type__c,Asset_Type__c from Asset
                               WHERE id = :theTestAssets[0].Id];
        Test.startTest();        
        CreateNewAssetsOLIScheduleQueue CNASch = new CreateNewAssetsOLIScheduleQueue();
        try{
        CNASch.AssetExpiration(new Set<String>(), new Set<String>(), new Set<String>(), assets);
        Test.stopTest();}
        catch(exception e){} 
    }
}