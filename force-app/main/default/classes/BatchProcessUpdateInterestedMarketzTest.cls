@isTest
public class BatchProcessUpdateInterestedMarketzTest
{
    static testMethod void testBatch()
    {
        Schedule_Batch_Setting__c scheduleBatchSetting = new Schedule_Batch_Setting__c();
        scheduleBatchSetting.Name = 'NVM Callback';
        scheduleBatchSetting.Assetresttime__c = 60;
        scheduleBatchSetting.Execution_Min__c = 60;
        insert scheduleBatchSetting;
        
        MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
        User u = mtduc.CreateUserSingle();  
        mtduc.UpdateUserSingle();   

        //Inserting Customsetting
        string username = userinfo.getUserName();
       
         //Inserting Customsetting for Account 
         DisabledTrigger__c Dtrg = mtduc.CreateDisabledTriggerSingle();
         Switch_AccountRelationshipTrigger__c art = new Switch_AccountRelationshipTrigger__c(name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
         insert art;    
         OrderDecompController.stopCreatingAccount = true; 
         // Inserting Test Account.
         Account newAccount = mtduc.CreateBrokerAccountSingle();
        
         //Inserting Test Contact 
         Contact myContact = mtduc.CreateContactSingle(); 
           
        Product2 newProduct = new Product2();
        newProduct.Name = 'TestProduct';
        newProduct.Commission_Category__c = 'Normal';
        newProduct.Normalization_factor__c = 1.10;
        newProduct.Commission_Category__c = 'CFCB';
        newProduct.Fulfillment_Type__c = 'Manual';
        newProduct.Auto_Renewal__c = True;
        newProduct.ProductCode = 'COBROKE';
        newProduct.S_No__c = 2;
        newProduct.isActive = true;
        insert newProduct;
        
        Asset assets = new Asset();
        assets.Name = 'test';
        assets.Renewal_Status__c = 'Renew';
        assets.Auto_Renewal__c = 'No';
        assets.Asset_Type__c = 'Parent';
        assets.AccountId = newAccount.id;
        //assets.ContactId = CreateContactSingle().id;
        assets.Product2Id = newProduct.id;
        assets.Fulfillment_Status__c = 'Fulfilled';
        assets.Renewal_Start_Date__c = System.today();
        assets.Status = 'Active';
        assets.At_Risk__c = false;
        assets.Quantity = 10;
        assets.Billing_Period__c = 'Monthly';
        assets.Start_Date__c = system.today();
        assets.End_Date__c = system.today().addDays(10);
        assets.Asset_Type__c = 'Parent';
        assets.Auto_Renewal__c  = 'Yes';
        assets.Line_Type__c = 'renew';
        assets.Price = 10.00;
        assets.Last_order_activity_date__c = System.today();
        assets.Market__c = '17890';
        //assets.Order_Line_Item__c = CreateOrderItemSingle().id;
        insert assets;
        
       List<Inventory_Data__c> invDataList = new List<Inventory_Data__c>();
        List<Inventory_Account__c> invAccList=new List<Inventory_Account__c>();
        
        for(integer i=0;i<5;i++){
           invDataList.add(new Inventory_Data__c(
               name='1789'+i,
               Median_Market_Price__c=45454.00,
               Inventory_Count__c=2,
               Inventory_Count_Half__c=1 
               )); 
        }
        
        insert invDataList;
        
        for(integer i=0;i<5;i++){
           invAccList.add(new Inventory_Account__c(
               Inventory_Data__c=invDataList[i].id,
               City__c='Mexico',
               State__c='US',
               Number_of_Listings__c=2,
               Number_of_Buy_Side_Transactions__c=3,
               Listing__c = TRUE,
               Account__c= newAccount.id
               )); 
        }
        
        insert invAccList;
        
         Test.startTest();
         
         BatchProcessUpdateInterestedMarketz batch = new BatchProcessUpdateInterestedMarketz();
         batch.Query = 'Select Id, Name From Account ';
         database.executebatch(batch, 1);
        
         Test.stopTest();
    }
    static testMethod void testBatch2()
    {
        Schedule_Batch_Setting__c scheduleBatchSetting = new Schedule_Batch_Setting__c();
        scheduleBatchSetting.Name = 'NVM Callback';
        scheduleBatchSetting.Assetresttime__c = 60;
        scheduleBatchSetting.Execution_Min__c = 60;
        insert scheduleBatchSetting;
        
        MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
        User u = mtduc.CreateUserSingle();  
        mtduc.UpdateUserSingle();   

        //Inserting Customsetting
        string username = userinfo.getUserName();
       
         //Inserting Customsetting for Account 
         DisabledTrigger__c Dtrg = mtduc.CreateDisabledTriggerSingle();
         Switch_AccountRelationshipTrigger__c art = new Switch_AccountRelationshipTrigger__c(name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
         insert art;    
         OrderDecompController.stopCreatingAccount = true; 
         // Inserting Test Account.
         Account newAccount = mtduc.CreateBrokerAccountSingle();
        
         //Inserting Test Contact 
         Contact myContact = mtduc.CreateContactSingle(); 
           
        Product2 newProduct = new Product2();
        newProduct.Name = 'TestProduct';
        newProduct.Commission_Category__c = 'Normal';
        newProduct.Normalization_factor__c = 1.10;
        newProduct.Commission_Category__c = 'CFCB';
        newProduct.Fulfillment_Type__c = 'Manual';
        newProduct.Auto_Renewal__c = True;
        newProduct.ProductCode = 'LOCALEXPERTCITY';
        newProduct.S_No__c = 2;
        newProduct.isActive = true;
        insert newProduct;
        
        Asset assets = new Asset();
        assets.Name = 'test';
        assets.Renewal_Status__c = 'Renew';
        assets.Auto_Renewal__c = 'No';
        assets.Asset_Type__c = 'Parent';
        assets.AccountId = newAccount.id;
        //assets.ContactId = CreateContactSingle().id;
        assets.Product2Id = newProduct.id;
        assets.Fulfillment_Status__c = 'Fulfilled';
        assets.Renewal_Start_Date__c = System.today();
        assets.Status = 'Active';
        assets.At_Risk__c = false;
        assets.Quantity = 10;
        assets.Billing_Period__c = 'Monthly';
        assets.Start_Date__c = system.today();
        assets.End_Date__c = system.today().addDays(10);
        assets.Asset_Type__c = 'Parent';
        assets.Auto_Renewal__c  = 'Yes';
        assets.Line_Type__c = 'renew';
        assets.Price = 10.00;
        assets.Last_order_activity_date__c = System.today();
        assets.Market__c = 'testcity0, teststate';
        //assets.Order_Line_Item__c = CreateOrderItemSingle().id;
        insert assets;
        
        
        Asset  ASSETS2 = new Asset();
         ASSETS2.Name = 'test';
         ASSETS2.Renewal_Status__c = 'Renew';
         ASSETS2.Auto_Renewal__c = 'No';
         ASSETS2.Asset_Type__c = 'Parent';
         ASSETS2.AccountId = newAccount.id;
        // ASSETS2.ContactId = CreateContactSingle().id;
         ASSETS2.Product2Id = newProduct.id;
         ASSETS2.Fulfillment_Status__c = 'Fulfilled';
         ASSETS2.Renewal_Start_Date__c = System.today();
         ASSETS2.Status = 'Active';
         ASSETS2.At_Risk__c = false;
         ASSETS2.Quantity = 10;
         ASSETS2.Billing_Period__c = 'Monthly';
         ASSETS2.Start_Date__c = system.today();
         ASSETS2.End_Date__c = system.today().addDays(10);
         ASSETS2.Asset_Type__c = 'Parent';
         ASSETS2.Auto_Renewal__c  = 'Yes';
         ASSETS2.Line_Type__c = 'renew';
         ASSETS2.Price = 10.00;
         ASSETS2.Last_order_activity_date__c = System.today();
         ASSETS2.Market__c = 'testcity2, teststate';
        // ASSETS2.Order_Line_Item__c = CreateOrderItemSingle().id;
        insert  ASSETS2;
        
        Asset   ASSETS3 = new Asset();
          ASSETS3.Name = 'test';
          ASSETS3.Renewal_Status__c = 'Renew';
          ASSETS3.Auto_Renewal__c = 'No';
          ASSETS3.Asset_Type__c = 'Parent';
          ASSETS3.AccountId = newAccount.id;
        //  ASSETS3.ContactId = CreateContactSingle().id;
          ASSETS3.Product2Id = newProduct.id;
          ASSETS3.Fulfillment_Status__c = 'Fulfilled';
          ASSETS3.Renewal_Start_Date__c = System.today();
          ASSETS3.Status = 'Active';
          ASSETS3.At_Risk__c = false;
          ASSETS3.Quantity = 10;
          ASSETS3.Billing_Period__c = 'Monthly';
          ASSETS3.Start_Date__c = system.today();
          ASSETS3.End_Date__c = system.today().addDays(10);
          ASSETS3.Asset_Type__c = 'Parent';
          ASSETS3.Auto_Renewal__c  = 'Yes';
          ASSETS3.Line_Type__c = 'renew';
          ASSETS3.Price = 10.00;
          ASSETS3.Last_order_activity_date__c = System.today()-1;
          ASSETS3.Market__c = 'testcity1, teststate';
        //  ASSETS3.Order_Line_Item__c = CreateOrderItemSingle().id;
        insert   ASSETS3;
        
        
       List<Inventory_Data__c> invDataList = new List<Inventory_Data__c>();
        List<Inventory_Account__c> invAccList=new List<Inventory_Account__c>();
        
        for(integer i=0;i<5;i++){
           invDataList.add(new Inventory_Data__c(
               name='teststate-testcity'+i,
               Median_Market_Price__c=45454.00,
               Inventory_Count__c=2,
               Inventory_Count_Half__c=1 
               )); 
        }
        
        insert invDataList;
        
        for(integer i=0;i<5;i++){
           invAccList.add(new Inventory_Account__c(
               Inventory_Data__c=invDataList[i].id,
               City__c='Mexico',
               State__c='US',
               Number_of_Listings__c=2,
               Number_of_Buy_Side_Transactions__c=3,
               Listing__c = TRUE,
               Account__c= newAccount.id
               )); 
        }
        
        insert invAccList;
        
         Test.startTest();
         
         BatchProcessUpdateInterestedMarketz batch = new BatchProcessUpdateInterestedMarketz();
         batch.Query = 'Select Id, Name From Account ';
         database.executebatch(batch, 1);
        
         Test.stopTest();
    }
}