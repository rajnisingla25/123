@IsTest(seealldata = false)
public class ExpireFiveStreetAssetschedule_Test {
  static testMethod  void ExpirationAndRenewal_Schedular_Execute_test1(){
    
    //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Collection_Users__c cu = new Collection_Users__c(Name = 'batchintegration user', Id__c=UserInfo.getUserId());
        insert cu;
       ZuoraSchedulesJobSetting__c Zsetting = new ZuoraSchedulesJobSetting__c(Name= 'Z_ZuoraJobsSchedular',Schedule_Time__c = system.now(), Execution_interval__c = 4, Last_execution__c = system.now().addminutes(-40),Is_Running__c = true);
        insert Zsetting;
       Schedule_Batch_Setting__c winbackrenewal = new  Schedule_Batch_Setting__c(Name= 'Win Back Process',Execution_Min__c=10,Is_Running__c=true,Execution_Time_hr__c = 0,Execution_End_Time_Hr__c = 24);
        insert winbackrenewal;
      Schedule_Batch_Setting__c scriptone = new  Schedule_Batch_Setting__c(Name= 'leadscoreclaculationscriptone',Execution_Min__c=11,Is_Running__c=true,Execution_Time_hr__c = 0,Execution_End_Time_Hr__c = 24);
        insert scriptone;
      Schedule_Batch_Setting__c scripttwo = new  Schedule_Batch_Setting__c(Name= 'leadscoreclaculationscripttwo',Execution_Min__c=15,Is_Running__c=true,Execution_Time_hr__c = 0,Execution_End_Time_Hr__c = 24);
        insert scripttwo;
      Schedule_Batch_Setting__c scriptthree = new  Schedule_Batch_Setting__c(Name= 'leadscoreclaculationscriptthree',Execution_Min__c=21,Is_Running__c=true,Execution_Time_hr__c = 0,Execution_End_Time_Hr__c = 24);
        insert scriptthree;
      Schedule_Batch_Setting__c scriptFour = new  Schedule_Batch_Setting__c(Name= 'leadscoreclaculationscriptfour',Execution_Min__c=31,Is_Running__c=true,Execution_Time_hr__c = 0,Execution_End_Time_Hr__c = 24);
        insert scriptFour;
        //Inserting Test Account     
         Account testAccount= TestDataFactory.createAccount('testAccount',null,false);
          testAccount.Primary_Email__c = 'testAccount@move.com';
          testAccount.Type = 'Broker';
          testAccount.party_id__c ='12345';
         testAccount.Create_Five_Street_Lead__c=true;
          testAccount.Total_Contract_Value__c  = 5000;
    
        insert testAccount; 
        
        Id theStandardPriceBookId = Test.getStandardPricebookId();  
   
       
        // Private Contact  
        contact c = new contact();
        c.lastname = 'test';
        c.FirstName = 'ravi';
        c.Title = 'sath';
        c.email ='ravi@gmail.com';
        c.Phone = '1234567895';
        c.MobilePhone= '1234567895';
        c.MailingState = 'California';
        c.MailingCountry = 'United States';
        c.MailingCity = 'knr';
        c.MailingStreet = 'test';
        c.MailingPostalCode = '524345';
        c.Preferred_Phone__c='1234567890';
        c.Active__c= true;
        insert c;         
        
        Account_Relationship__c ar = new Account_Relationship__c();
        ar.Contact_to__c = c.Id;
        ar.Billing_Contact__c = true;
        ar.Zuora_Bill_to_Contact_ID__c = c.Id;
        ar.Zuora_Ship_to_Contact_ID__c = c.Id;
        ar.Relationship_Type__c = 'Contact';
        ar.Active__c = true;
        ar.Parent_Account__c = testAccount.Id;
        ar.Contact_Role__c = 'Primary Contact';
        insert ar;
        
        Product2 newProduct = new Product2();
        newProduct.Name = 'TestProduct';      
        newProduct.S_No__c = 2;
        newProduct.ProductCode='COBROKE' ;
        insert newProduct;
          Product2 newProduct2 = new Product2();
        newProduct2.Name = 'TestProduct';      
        newProduct2.S_No__c = 2;
        newProduct2.ProductCode='FiveStreet' ;
        insert newProduct2;
        Asset assets = new Asset();
        assets.Name = 'test';        
        assets.Asset_Type__c = 'Parent';
        assets.AccountId = testAccount.id;
        assets.Fulfillment_Status__c = 'Fulfilled';
        assets.Status = 'Expired';     
        assets.Start_Date__c = system.today();
        assets.End_Date__c = System.today().addDays(-1);
        assets.Product2Id = newProduct.id;
       
        insert assets; 
        
         Asset assets1 = new Asset();
        assets1.Name = 'test';        
        assets1.Asset_Type__c = 'Parent';
        assets1.AccountId = testAccount.id;
        assets1.Fulfillment_Status__c = 'Fulfilled';
        assets1.Status = 'Active';     
        assets1.Start_Date__c = system.today();
        assets1.End_Date__c = System.today().addDays(11);
        assets1.Product2Id = newProduct2.id; 
        assets1.Extended_Net_Price__c = 0.00; 
      	assets1.Promotion__c = '1FREEFIVESTREETLICENSE';
        insert assets1; 
        
        Order  Orders = new Order();
        Orders.AccountId = testAccount.id;
        Orders.Fulfillment_Status__c = 'Fulfilled';
        Orders.Status = 'Created';
        Orders.Name = 'Test order'; 
        Orders.Pricebook2Id = theStandardPriceBookId ;
        Orders.EffectiveDate = system.today();
        Orders.EndDate = system.today().addDays(10);
        Orders.Run_OrderDecomp__c = true;
        insert Orders;
        
        OrderItem OrderItems = new OrderItem();
        OrderItems.UnitPrice = 789.62;
        OrderItems.Quantity = 6;
        OrderItems.Zuora_Status__c = '';
        OrderItems.Asset__c = assets1.id;
        OrderItems.OrderId = Orders.id;
        OrderItems.Auto_Renewal__c = 'Yes';
        OrderItems.PricebookEntryId = theStandardPriceBookId;
  
        Test.StartTest();
        ExpireFiveStreetAssetschedule sh1 = new ExpireFiveStreetAssetschedule();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);        
        String SCHEDULE_NAME = 'test'; 
        id cronid = System.schedule(SCHEDULE_NAME, '0 15 0-23 * * ?', new CleanupCronTriggers());            
        System.abortJob(cronid);
        Test.stopTest();
     }   
     
     
     static testMethod  void ExpirationAndRenewal_Schedular_Execute_test2(){
    
    //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        //Inserting Test Account     
          Collection_Users__c cu = new Collection_Users__c(Name = 'batchintegration user', Id__c=UserInfo.getUserId());
        insert cu;
         Account testAccount= TestDataFactory.createAccount('testAccount',null,false);
          testAccount.Primary_Email__c = 'testAccount@move.com';
          testAccount.Type = 'Broker';
          testAccount.party_id__c ='12345';
          testAccount.Create_Five_Street_Lead__c=true;
          testAccount.Total_Contract_Value__c  = 5000;
    
        insert testAccount; 
    
  
        // Private Contact  
        contact c = new contact();
        c.lastname = 'test';
        c.FirstName = 'ravi';
        c.Title = 'sath';
        c.email ='ravi@gmail.com';
        c.Phone = '1234567895';
        c.MobilePhone= '1234567895';
        c.MailingState = 'California';
        c.MailingCountry = 'United States';
        c.MailingCity = 'knr';
        c.MailingStreet = 'test';
        c.MailingPostalCode = '524345';
        c.Preferred_Phone__c='1234567890';
        c.Active__c= true;
        insert c;  
        
        Account_Relationship__c ar = new Account_Relationship__c();
        ar.Contact_to__c = c.Id;
        ar.Billing_Contact__c = true;
        ar.Zuora_Bill_to_Contact_ID__c = c.Id;
        ar.Zuora_Ship_to_Contact_ID__c = c.Id;
        ar.Relationship_Type__c = 'Contact';
        ar.Active__c = true;
        ar.Parent_Account__c = testAccount.Id;
        ar.Contact_Role__c = 'Primary Contact';
        insert ar;
        
        
        Test.StartTest();
        ExpireFiveStreetAssetschedule sh1 = new ExpireFiveStreetAssetschedule();   
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);        
        String SCHEDULE_NAME = 'test'; 
        id cronid = System.schedule(SCHEDULE_NAME, '0 15 0-23 * * ?', new CleanupCronTriggers());            
        System.abortJob(cronid);
        Test.stopTest();
     }   
  
  }