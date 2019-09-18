@isTest(seealldata=false)
public  class CreateAssetsFromOrderLineJSON_Test{
    public static testMethod void testCreateAssetsOrderLineAssetJSON(){
         MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
          //ProductExclusionTrigger
          mtduc.CreateDisabledTriggerSingle();
          Switch_AccountRelationshipTrigger__c arc = new Switch_AccountRelationshipTrigger__c(Name ='Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
           insert arc;  
           
          List<Order_Product_And_Parent_Asset_Fields__c> lstOPPA = new List<Order_Product_And_Parent_Asset_Fields__c>();
          Set<String> setIds = new Set<String>{'Auto_Renewal__c','UnitPrice','Billing_Period__c', 'Broker_Plan_Affiliation__c', 'Buyout_Amount__c', 'Buyout_Discount__c', 'Cancellation_Date__c', 'Cancellation_Effective_Date__c', 'Cancellation_Reason__c', 'Choice_Lead_Form__c', 'Combined_Discount_Percent__c', 'Combined_Discount__c', 'Commerce_Group__c', 'Contract_Term__c', 'Create_Broker_Tools__c', 'Credit_Amount__c', 'Delta_Price__c', 'Description', 'Discount_Type__c', 'End_Date__c', 'Est_Tax__c', 'Est_Total_Tax__c', 'Extended_List__c', 'Extended_Net_Price__c', 'Extension_Type__c', 'Ext_Days__c', 'Featured_Mortgage__c', 'HLC_Override__c', 'HLC__c', 'Inventory_Status__c', 'Inventory_Transaction_ID__c', 'Lead_Type__c', 'License_Tier_Range__c', 'License_Tier__c', 'Line_Type__c', 'Manual_Discount_Amount__c', 'Manual_Discount_Type__c', 'Manual_Discount__c', 'Market_Tier__c', 'Market__c', 'NAR_Membership__c', 'Net_Price__c', 'Override_Term__c', 'Product_Account__c', 'Product_Email__c', 'Product_Type__c', 'Promotion_Amount__c', 'Promotion_Discount__c', 'Promotion__c', 'Promo_Description__c', 'Quantity', 'Quote_Discount_Percent__c', 'Quote_Transaction_ID__c', 'Refund_Request__c', 'Remaining_Amount__c', 'Renewal_Status__c', 'Start_Date__c', 'Strategic_Discount_dollar__c', 'Strategic_Discount_Percent__c', 'Strategic_Discount__c', 'Suppress_Welcome_Calls__c', 'Top_Connector__c', 'Price', 'Total_Discount_Amount__c', 'Total_Discount_Percent__c', 'Total_Discount__c', 'Total_List_Price__c', 'Total_Net_Price__c', 'Total_Net__c', 'Total_Price_WithTax__c', 'List_Price__c'};
          for(String str:setIds)
          {          Order_Product_And_Parent_Asset_Fields__c OPPA = new Order_Product_And_Parent_Asset_Fields__c();
          OPPA.Name = str;
          OPPA.Asset_Field_API_Name__c=str;
          lstOPPA.add(OPPA);
          }
          insert lstOPPA;
          
          List<Parent_Asset_And_FulfillTo_Asset_Fields__c> lstParentAsset = new List<Parent_Asset_And_FulfillTo_Asset_Fields__c>(); 
          Set<String> setParentFulfillString = new Set<String>{'Cancellation_Reason__c','Choice_Lead_Form__c','Cost_Per_Action__c','Create_Broker_Tools__c','Description','End_Date__c','Featured_Mortgage__c','Parent_Asset__c','Inventory_Transaction_ID__c','Legacy_Siebel_Asset_ID__c','Line_Type__c','List_Price__c','Market__c','Order_Line_Item__c','Price','Product2Id','Product_Email__c','Product_Type__c','Quantity','Sign_in_AE__c','Start_Date__c','Suppress_Welcome_Calls__c','Top_Connector__c'};
          for(String str:setParentFulfillString)
          {
            Parent_Asset_And_FulfillTo_Asset_Fields__c cspf = New Parent_Asset_And_FulfillTo_Asset_Fields__c();
            cspf.Name =str;
            cspf.FulfillTo_Asset_Field_API_Name__c =str;
            lstParentAsset.add(cspf);
            }
        insert lstParentAsset;
        
        List<FulfillTo_Asset_And_MLS_Asset_Fields__c> lstFulfillParticipant = new List<FulfillTo_Asset_And_MLS_Asset_Fields__c>();
        Set<String> setFulfillParticipant = new Set<String>{'Broker_Plan_Affiliation__c','Cancellation_Reason__c','Create_Broker_Tools__c','Description','End_Date__c','Featured_Mortgage__c','Parent_Asset__c','Inventory_Transaction_ID__c','Legacy_Siebel_Asset_ID__c','Line_Type__c','Market__c','Order_Line_Item__c','Product2Id','Product_Type__c','Sign_in_AE__c','Start_Date__c','Suppress_Welcome_Calls__c','Top_Connector__c'};
        for(String str:setFulfillParticipant)
          {
        FulfillTo_Asset_And_MLS_Asset_Fields__c csFa = New FulfillTo_Asset_And_MLS_Asset_Fields__c();
            csFa.Name = str;
            csFa.Participant_Asset_Field_API_Name__c = str;
            lstFulfillParticipant.add(csFa);
            }
        insert lstFulfillParticipant;   
        
         CreateAssetsFromOrderLineItemsAssetJSON cafolia = New CreateAssetsFromOrderLineItemsAssetJSON();     
          mtduc.CreateBrokerAccountSingle();
          mtduc.CreateRealtorOfficeAccountSingle();
          mtduc.CreateRealtorAgentAccountSingle();
          mtduc.CreateContractSingle();
          mtduc.CreateBrockerOfficeAccountRelationshipSingle();
          mtduc.CreateRealtorAgentAccountRelationshipSingle();
          mtduc.CreateProductSingle();
          mtduc.CreatePricebookEntrySingle();
          mtduc.CreateFullfilledAssetSingle();
          mtduc.CreateFulfilltoFullfilledAssetSingle();
          mtduc.CreateParticipantFulfilltoFullfilledAssetSingle();
          OrderDecompController.stopCreatingAccount = true;   
          mtduc.CreateOrderNoQuoteSingle();
          mtduc.CreateOrderItemNoQuoteSingle();
          mtduc.CreateOrderItemRemoveSingle();
          mtduc.UpdateOrderNoQuoteSingle();
          mtduc.CreateOrderItemRenewSingle();
          List<Order> lstOrder = new List<Order>();
          lstOrder.add(mtduc.orders);
          //CreateAssetsFromOrderLineItemsAssetJSON cafolia = New CreateAssetsFromOrderLineItemsAssetJSON();
            Error_Notification_Email_Settings__c sc = new Error_Notification_Email_Settings__c();
            sc.Asset_Creation_Error_Emails__c = 'sonu.sharma@move.com';
            sc.name = 'Email Addresses';
            sc.View_Link__c ='https://cs11.salesforce.com/02i?fcf=00BZ00000017ilI';
            insert sc;                
        cafolia.sendErrorNotification(lstOrder);
        Map<Id,Id> mapdelAssetIds = new Map<Id,Id>();
        Set<Id> setIIds = new Set<Id>();
        Map<Integer,Asset> mapParentAssetMap = new Map<Integer,Asset>();
        map<String,product2> mapProdFulfill = new map<String,product2>();
        map<Id,orderitem> mapOrderItemstoprocess = new map<Id,orderitem>();
        mapdelAssetIds.put(mtduc.assets.id,mtduc.assets.id);
        map<String,Order_Product_And_Parent_Asset_Fields__c> theParentAssetMappingData= new map<String,Order_Product_And_Parent_Asset_Fields__c>();
        setIIds.add(mtduc.assets.Accountid);
        mapParentAssetMap.put(1,mtduc.assets);
        cafolia.DeleteAssets(setIIds,mapParentAssetMap,mapdelAssetIds,mapProdFulfill,mapOrderItemstoprocess,theParentAssetMappingData);
    Database.executebatch(cafolia,10);
    }
    
 }