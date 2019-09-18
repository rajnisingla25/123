//
// (c) 2015 NTT Data, Inc.
//
// Apex Class Name: GetAssetHierarchy
// Description: Its a webservice class to extract asset hierarchy.
//
// 31th May 2015    Sonu Sharma
// 25th July 2015   Rajamohan Vakati        Modified  (JIRA Number ADVP-2061) - Passing configoptions__c filed to SOA .
// 15th AUG 2016    Nevil        Modified  (as a part of Seller Lead for Broker development ) - Added forecastedLead and pricePerLead in the parent and fulfillto asset class
//
global class GetAssetHierarchy {
  // Request Inner Class - AssetIdType
  global class AssetIdType {
    webservice String AssetId;
    webservice Boolean SubmitFlag;
  }

  // Response Inner Classes - ParentAsset
  global class ParentAsset {
    webservice List<ParentAssetType> ParentAsset;
  }

  // Response Inner Classes - ParentAssetType
  global class ParentAssetType {
    webservice String SalesRep;          //CRM-3294
    webservice String NTLoginId;         // CRM-3294
    webservice String ProductFamily;     // CRM-3294
    webservice String BillingFeed;       // CRM-3294
    webservice String ProductDescription;
    webservice String Action;
    webservice String CorelationID;
    webservice Account SoldToAccount;
    webservice String FranchiseType;
    webservice String LoginUserName;
    webservice String AssetID;
    //webservice String AccountID;
    webservice String BOPCode;
    webservice String ContractDate;
    webservice String StartDate;
    webservice String ExpirationDate;
    webservice String AffiliationID;
    webservice BrokerContact Contact;
    webservice String ProductPartNumber;
    webservice Integer Quantity;
    webservice Integer LicenseQuantity;
    webservice String ProductType;
    webservice Decimal ContractValue;
    webservice Boolean TopConnector;
    webservice Boolean FeaturedMortgage;
    webservice Boolean CreateBrokerTools;
    webservice String SiebelLegacyID;
    webservice String ProductEmail;
    webservice String parentExternalID;
    webservice String InvTransactionID;
    webservice String InvLineItemID;
    webservice String SfdcOrderID  ;
    webservice String SfdcQuoteID  ;
    webservice Boolean EnableShowcaseChoice;
    webservice Boolean Trial;
    webservice Decimal netPrice;
    webservice String SoldtoAccountToken;
    webservice String configOptions;
    webservice List<FulfillToAsset> FulfillToAsset;

    //Added below fields By Nevil: For Seller Lead Broker
    webservice decimal  forecastedLead;
    webservice decimal  pricePerLead;
    webservice Date     cancellationDate;
    webservice Date     cancellationEffectiveDate;
    
    // CRM-2096
    webservice String productEligibility;
  }

  // Response Inner Classes - BrokerContact
  global class BrokerContact {
    webservice String ContactID;
    webservice String FirstName;
    webservice String LastName;
    webservice String EmailAddress;
    webservice String Phone;
    webservice String PhoneExtension;
    webservice String CDHPersonPartyID;
    webservice String Address1;
    webservice String City;
    webservice String State;
    webservice String Country;
    webservice String PostalCode;
  }

  // Response Inner Classes - Account
  global class Account {
    webservice String BillingFeed;              // CRM-3294
    webservice String AdminCompanyId;           // CRM-3294
    webservice String ParentAccountPartyId;      // CRM-3294
   // webservice String AccountID; 
    webservice String CDHOrgPartyID;
    webservice String AccountName;
    webservice String AccountType;
    webservice String MLSSetID;
    webservice String CustomerID;
    webservice String Address1;
    webservice String City;
    webservice String State;
    webservice String Country;
    webservice String PostalCode;
  }

  // Response Inner Classes - FulfillToAssetType
  global class FulfillToAssetType {
    webservice String Action;
    webservice String AssetID;
    webservice String ParentAssetID;
    webservice Integer Quantity;
    webservice Integer LicenseQuantity;
    webservice String FirstName;
    webservice String LastName;
    webservice String Address1;
    webservice String City;
    webservice String State;
    webservice Boolean EnableShowcaseChoice;
    webservice String Country;
    webservice String PostalCode;
    webservice String AgentMlsCode;
    webservice String OfficeMlsCode;
    webservice Account FulfillToAccount;
    webservice String Email;
    webservice String Phone;
    webservice String ProductEmail;
    webservice Account ProductAccount;
    webservice String WebsiteUrl;
    webservice String StartDate;
    webservice String EndDate;
    webservice String fulfilltoExternalID;
    webservice String InvTransactionID;
    webservice String InvLineItemID;
    webservice String CancelReason;
    webservice String MarketName;
    webservice String LeadType;
    webservice Boolean CreateBrokerTools;
    webservice Boolean Trial;
    webservice Boolean TopConnector;
    webservice Boolean FeaturedMortgage;
    webservice Mls Mls;
    // Added by Rajamohan Vakati - JIRA ADVP-2061
    //webservice String configOptions ;
     //Added below fields By Nevil: For Seller Lead Broker
    webservice decimal forecastedLead;
    webservice decimal pricePerLead;
    webservice Date     cancellationDate;
    webservice Date     cancellationEffectiveDate;
  }

  // Response Inner Classes - FulfillToAsset
  global class FulfillToAsset {
    webservice List<FulfillToAssetType> OfficeAsset;
  }

  // Response Inner Classes - Mls
  global class Mls {
    webservice List<MlsType> Mls;
  }

  // Response Inner Classes - MlsType
  global class MlsType {
    webservice String Action;
    webservice String MlsSetID;
    webservice String MlsAssetID;
    webservice String MlsExternalID;
  }

  /*
  @method      : getAssetHierarchy()
  @description : Webservice call to extract asset hierarchy.
  @params      : AssetIdType AssetId
  @returns     : ParentAsset
  */
  webservice static ParentAsset getAssetHierarchyDetails(String AssetId, Boolean SubmitFlag) {
        // Exception Handling.
        if(String.isBlank(AssetId)) {
            system.debug('TRACE: AssetId Not Found. END.');
            return null;
        }

        try {
            // The Parent Asset - Parent Response Object.
            ParentAsset theParentAssetObject = new ParentAsset();
            Id movingRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Moving').getRecordTypeId();  // CRM-3294
            Account theAccount = null;
            BrokerContact theBrokerContact = null;
            ParentAssetType theParentAssetType = null;
            List<ParentAssetType> theParentAssetTypeList = new List<ParentAssetType>();
            List<Asset> AllrelaventAssets = new List<Asset>();
            Set<String> setStatus = new set<String>{'Expired','Cancelled'};
            Set<String> setFulfillmentStatus = new Set<String>();
            AllrelaventAssets = [SELECT Id, Sign_In_AE__r.Name,Total_Net__c,Trial__c,Sign_in_AE__r.NT_Login_ID__c,Product2.Description,Product2.Family, Account.Billing_Preference__c, Account.Admin_Company_Id__c, Account.RecordTypeId, Billing_Feed__c, Name, product2.Product_Elig__c, order_line_item__r.Order.Type,order_line_item__r.Order.Oracle_Quote__r.Name, Create_Broker_Tools__c,Line_Type__c,Sold_To_Account_Token__c, Override_Term__c ,Choice_Lead_Form__c, Account.Party_ID__c,Status, Account.Name, Account.Type, Account.Customer_Id__c,
                                                                    Account.Franchise_Type__c,CreatedBy.NT_Login_ID__c, BOP_Code__c, PurchaseDate, Start_Date__c, End_Date__c,
                                                                    Broker_Plan_Affiliation__c, ContactId, Contact.FirstName, Contact.LastName, Contact.Email, Account.MLS_Set_Id__c,
                                                                    Contact.Preferred_Phone__c, Contact.HomePhone,Contact.Phone, Contact.MobilePhone, Contact.Work_Phone__c, Contact.OtherPhone,
                                                                    Contact.Work_Phone_Ext__c,Account.Phone, Contact.Contact_Party_ID__c, Account.BillingStreet, Account.BillingCity,
                                                                    Product_Account__c,Product_Account__r.Name,Product_Account__r.Party_ID__c,Product_Account__r.Type,
                                                                    Product_Account__r.MLS_Set_Id__c,Product_Account__r.Customer_Id__c,MLS_Set__r.MLS_Set_ID__c,Ext_Days__c,
                                                                    Product_Account__r.BillingStreet,Product_Account__r.BillingCity,Product_Account__r.BillingState,Quantity,
                                                                    Product_Account__r.BillingCountry,Product_Account__r.BillingPostalCode,order_line_item__r.OrderId,order_line_item__r.Order.Oracle_Quote__c,
                                                                    Account.BillingState, Account.BillingCountry, Account.BillingPostalCode, Product2.ProductCode, External_ID__c,
                                                                    Product_Type__c, Account.Total_Contract_Value__c, Fulfillment_Status__c, Product_Email__c, Price, Top_Connector__c,ConfigOptions__c,
                                                                    Quote_Transaction_ID__c, Featured_Mortgage__c, Inventory_Transaction_ID__c,License_Tier__c,Contractedimpressions__c,PricePerImpressionSold__c,Cancellation_Date__c,Cancellation_Effective_Date__c, (SELECT Id, Name, Line_Type__c,
                                                                    Top_Connector__c, Featured_Mortgage__c, Create_Broker_Tools__c, Quantity, Account.BillingStreet, Account.BillingCity,
                                                                    Account.BillingState, Inventory_Transaction_ID__c, Account.MLS_Set_Id__c, Product_Account__r.MLS_Set_Id__c,
                                                                    Account.BillingCountry, Account.BillingPostalCode, Account.Party_ID__c, Account.Name, Account.Type,
                                                                    Account.Customer_Id__c,Account.Email_Address__c, Account.Primary_Email__c, Account.Preferred_Phone__c, Account.Home_Phone__c,
                                                                    Account.Work_Phone__c,Account.Phone, Account.Mobile1__c,Account.Phone_Extension__c, Account.Mobile2_Other__c, Product_Email__c,ConfigOptions__c,
                                                                    Product_Account__r.Party_ID__c, Product_Account__r.Name, Product_Account__r.Type,order_line_item__r.Order.Oracle_Quote__c,
                                                                    Start_Date__c,End_Date__c,Product_Account__r.Customer_Id__c, Account.Website, Quote_Transaction_ID__c, Cancellation_Reason__c,
                                                                    Market__c,Trial__c,Configure_Ad_URL__c,External_ID__c, Lead_Type__c, Asset_Type__c, AccountId, Fulfillment_Status__c,Contractedimpressions__c,PricePerImpressionSold__c,Cancellation_Date__c,Cancellation_Effective_Date__c FROM Assets__r
                                                                    WHERE Asset_Type__c = 'Fulfill To' and (Status!=:setStatus) and Fulfillment_Status__c!='Fulfilled') FROM Asset WHERE Id = :AssetId AND Asset_Type__c = 'Parent' limit 1];


                      if(AllrelaventAssets[0].Line_type__c!=null){
                      if(AllrelaventAssets[0].Line_type__c!='Add'){
                      Set<String> setRenewFulfillmentStatus = new Set<String>{'Active','Converted','Pending Fulfillment','Fulfilled'};
                      if(AllrelaventAssets[0].Line_type__c.equalsIgnoreCase('Renew') || AllrelaventAssets[0].Line_type__c.equalsIgnoreCase('Cancel') || AllrelaventAssets[0].Ext_Days__c>0 || AllrelaventAssets[0].Override_Term__c>0){
                     // if(AllrelaventAssets[0].Line_type__c.equalsIgnoreCase('Cancel')){setRenewFulfillmentStatus.add('Expired');setRenewFulfillmentStatus.add('Cancelled');}
                      AllrelaventAssets = [SELECT Id,Sign_In_AE__r.Name,Total_Net__c,Trial__c,Sign_in_AE__r.NT_Login_ID__c,Product2.Description,Product2.Family, Account.Billing_Preference__c, Account.Admin_Company_Id__c, Account.RecordTypeId, Billing_Feed__c, product2.Product_Elig__c,order_line_item__r.Order.Type,order_line_item__r.Order.Oracle_Quote__r.Name, Name,Create_Broker_Tools__c, Line_Type__c,Sold_To_Account_Token__c,Choice_Lead_Form__c, Account.Party_ID__c,Status,Account.Name, Override_Term__c ,Account.Type, Account.Customer_Id__c,
                                                                    Account.Franchise_Type__c,CreatedBy.NT_Login_ID__c, BOP_Code__c, PurchaseDate, Start_Date__c, End_Date__c,
                                                                    Broker_Plan_Affiliation__c, ContactId, Contact.FirstName,Contact.Phone, Contact.LastName, Contact.Email, Account.MLS_Set_Id__c,
                                                                    Contact.Preferred_Phone__c,Quantity, Contact.HomePhone, Contact.MobilePhone, Contact.Work_Phone__c, Contact.OtherPhone,
                                                                    Contact.Work_Phone_Ext__c,Account.Phone, Contact.Contact_Party_ID__c, Account.BillingStreet, Account.BillingCity,
                                                                    Product_Account__c,Product_Account__r.Name,Product_Account__r.Party_ID__c,Product_Account__r.Type,Ext_Days__c,
                                                                    Product_Account__r.MLS_Set_Id__c,Product_Account__r.Customer_Id__c,MLS_Set__r.MLS_Set_ID__c,
                                                                    Product_Account__r.BillingStreet,Product_Account__r.BillingCity,Product_Account__r.BillingState,
                                                                    Product_Account__r.BillingCountry,Product_Account__r.BillingPostalCode,order_line_item__r.OrderId,order_line_item__r.Order.Oracle_Quote__c,
                                                                    Account.BillingState, Account.BillingCountry, Account.BillingPostalCode, Product2.ProductCode, External_ID__c,
                                                                    Product_Type__c, Account.Total_Contract_Value__c, Fulfillment_Status__c, Product_Email__c, Price, Top_Connector__c,ConfigOptions__c,
                                                                    Quote_Transaction_ID__c,License_Tier__c, Featured_Mortgage__c, Inventory_Transaction_ID__c,Contractedimpressions__c,PricePerImpressionSold__c,Cancellation_Date__c,Cancellation_Effective_Date__c, (SELECT Id, Name, Line_Type__c,
                                                                    Top_Connector__c, Featured_Mortgage__c, Create_Broker_Tools__c, Quantity, Account.BillingStreet, Account.BillingCity,
                                                                    Account.BillingState, Inventory_Transaction_ID__c, Account.MLS_Set_Id__c, Product_Account__r.MLS_Set_Id__c,
                                                                    Account.BillingCountry, Account.BillingPostalCode, Account.Party_ID__c, Account.Name, Account.Type,
                                                                    Account.Customer_Id__c,Account.Phone,Account.Email_Address__c, Account.Primary_Email__c, Account.Preferred_Phone__c, Account.Home_Phone__c,
                                                                    Account.Work_Phone__c,License_Tier__c, Account.Mobile1__c,Account.Phone_Extension__c, Account.Mobile2_Other__c, Product_Email__c,ConfigOptions__c,
                                                                    Product_Account__r.Party_ID__c,External_ID__c, Product_Account__r.Name, Product_Account__r.Type,order_line_item__r.Order.Oracle_Quote__c,
                                                                    Start_Date__c,End_Date__c,Product_Account__r.Customer_Id__c, Account.Website, Quote_Transaction_ID__c, Cancellation_Reason__c,
                                                                    Market__c,Configure_Ad_URL__c,Trial__c, Lead_Type__c, Asset_Type__c, AccountId, Fulfillment_Status__c,Contractedimpressions__c,PricePerImpressionSold__c,Cancellation_Date__c,Cancellation_Effective_Date__c FROM Assets__r
                                                                    WHERE Asset_Type__c = 'Fulfill To' and (Status!=:setStatus) and Status=:setRenewFulfillmentStatus) FROM Asset WHERE Id = :AssetId AND Asset_Type__c = 'Parent' limit 1];

                      }
                      }

                      if(AllrelaventAssets[0].Line_type__c=='Amend' || AllrelaventAssets[0].Line_type__c=='Credit'){
                           AllrelaventAssets = [SELECT Id, Sign_In_AE__r.Name,Total_Net__c,Trial__c,Sign_in_AE__r.NT_Login_ID__c,Product2.Description,Product2.Family, Account.Billing_Preference__c, Account.Admin_Company_Id__c, Account.RecordTypeId, Billing_Feed__c, product2.Product_Elig__c,order_line_item__r.Order.Type,order_line_item__r.Order.Oracle_Quote__r.Name, Name,Create_Broker_Tools__c, Line_Type__c,Sold_To_Account_Token__c,Choice_Lead_Form__c, Account.Party_ID__c,Status,Account.Name, Override_Term__c ,Account.Type, Account.Customer_Id__c,
                                                                    Account.Franchise_Type__c,CreatedBy.NT_Login_ID__c, BOP_Code__c, PurchaseDate, Start_Date__c, End_Date__c,
                                                                    Broker_Plan_Affiliation__c, ContactId, Contact.FirstName, Contact.LastName, Contact.Email, Account.MLS_Set_Id__c,
                                                                    Contact.Preferred_Phone__c,Quantity, Contact.HomePhone,Contact.Phone, Contact.MobilePhone, Contact.Work_Phone__c, Contact.OtherPhone,
                                                                    Contact.Work_Phone_Ext__c,Account.Phone, Contact.Contact_Party_ID__c, Account.BillingStreet, Account.BillingCity,
                                                                    Product_Account__c,Product_Account__r.Name,Product_Account__r.Party_ID__c,Product_Account__r.Type,Ext_Days__c,
                                                                    Product_Account__r.MLS_Set_Id__c,Product_Account__r.Customer_Id__c,MLS_Set__r.MLS_Set_ID__c,
                                                                    Product_Account__r.BillingStreet,Product_Account__r.BillingCity,Product_Account__r.BillingState,
                                                                    Product_Account__r.BillingCountry,Product_Account__r.BillingPostalCode,order_line_item__r.OrderId,order_line_item__r.Order.Oracle_Quote__c,
                                                                    Account.BillingState, Account.BillingCountry, Account.BillingPostalCode, Product2.ProductCode, External_ID__c,
                                                                    Product_Type__c, Account.Total_Contract_Value__c, Fulfillment_Status__c, Product_Email__c, Price, Top_Connector__c,ConfigOptions__c,
                                                                    Quote_Transaction_ID__c,License_Tier__c, Featured_Mortgage__c, Inventory_Transaction_ID__c,Contractedimpressions__c,PricePerImpressionSold__c,Cancellation_Date__c,Cancellation_Effective_Date__c, (SELECT Id, Name, Line_Type__c,
                                                                    Top_Connector__c, Featured_Mortgage__c, Create_Broker_Tools__c, Quantity, Account.BillingStreet, Account.BillingCity,
                                                                    Account.BillingState, Inventory_Transaction_ID__c, Account.MLS_Set_Id__c, Product_Account__r.MLS_Set_Id__c,
                                                                    Account.BillingCountry, Account.BillingPostalCode, Account.Party_ID__c, Account.Name, Account.Type,
                                                                    Account.Customer_Id__c,Account.Email_Address__c, Account.Primary_Email__c, Account.Preferred_Phone__c, Account.Home_Phone__c,
                                                                    Account.Work_Phone__c,Account.Phone,License_Tier__c, Account.Mobile1__c,Account.Phone_Extension__c, Account.Mobile2_Other__c, Product_Email__c,ConfigOptions__c,
                                                                    Product_Account__r.Party_ID__c,External_ID__c, Product_Account__r.Name, Product_Account__r.Type,order_line_item__r.Order.Oracle_Quote__c,
                                                                    Start_Date__c,End_Date__c,Product_Account__r.Customer_Id__c, Account.Website, Quote_Transaction_ID__c, Cancellation_Reason__c,
                                                                    Market__c,Trial__c,Configure_Ad_URL__c, Lead_Type__c, Asset_Type__c, AccountId, Fulfillment_Status__c,Contractedimpressions__c,PricePerImpressionSold__c,Cancellation_Date__c,Cancellation_Effective_Date__c FROM Assets__r
                                                                    WHERE Asset_Type__c = 'Fulfill To'  and (Status!=:setStatus)) FROM Asset WHERE Id = :AssetId AND Asset_Type__c = 'Parent' limit 1];


                      }
                      if(AllrelaventAssets[0].Line_type__c=='Amend' && (AllrelaventAssets[0].Product2.ProductCode =='TOPCRM' || AllrelaventAssets[0].Product2.ProductCode =='TOPMRKSNP' || (AllrelaventAssets[0].Product2.ProductCode =='SHOWCASE' && !(AllrelaventAssets[0].Ext_Days__c>0 || AllrelaventAssets[0].Override_Term__c>0)))){
                           AllrelaventAssets = [SELECT Id, Sign_In_AE__r.Name,Total_Net__c,Trial__c,Sign_in_AE__r.NT_Login_ID__c,Product2.Description,Product2.Family, Account.Billing_Preference__c, Account.Admin_Company_Id__c, Account.RecordTypeId, Billing_Feed__c, product2.Product_Elig__c,order_line_item__r.Order.Type,order_line_item__r.Order.Oracle_Quote__r.Name, Name,Create_Broker_Tools__c, Line_Type__c,Sold_To_Account_Token__c,Choice_Lead_Form__c, Account.Party_ID__c,Status,Account.Name, Override_Term__c ,Account.Type, Account.Customer_Id__c,
                                                                    Account.Franchise_Type__c,CreatedBy.NT_Login_ID__c, BOP_Code__c, PurchaseDate, Start_Date__c, End_Date__c,
                                                                    Broker_Plan_Affiliation__c,Account.Phone, ContactId, Contact.FirstName,Contact.Phone, Contact.LastName, Contact.Email, Account.MLS_Set_Id__c,
                                                                    Contact.Preferred_Phone__c,Quantity, Contact.HomePhone, Contact.MobilePhone, Contact.Work_Phone__c, Contact.OtherPhone,
                                                                    Contact.Work_Phone_Ext__c, Contact.Contact_Party_ID__c, Account.BillingStreet, Account.BillingCity,
                                                                    Product_Account__c,Product_Account__r.Name,Product_Account__r.Party_ID__c,Product_Account__r.Type,Ext_Days__c,
                                                                    Product_Account__r.MLS_Set_Id__c,Product_Account__r.Customer_Id__c,MLS_Set__r.MLS_Set_ID__c,
                                                                    Product_Account__r.BillingStreet,Product_Account__r.BillingCity,Product_Account__r.BillingState,
                                                                    Product_Account__r.BillingCountry,Product_Account__r.BillingPostalCode,order_line_item__r.OrderId,order_line_item__r.Order.Oracle_Quote__c,
                                                                    Account.BillingState, Account.BillingCountry, Account.BillingPostalCode, Product2.ProductCode, External_ID__c,
                                                                    Product_Type__c, Account.Total_Contract_Value__c, Fulfillment_Status__c, Product_Email__c, Price, Top_Connector__c,ConfigOptions__c,
                                                                    Quote_Transaction_ID__c,License_Tier__c, Featured_Mortgage__c, Inventory_Transaction_ID__c,Contractedimpressions__c,PricePerImpressionSold__c,Cancellation_Date__c,Cancellation_Effective_Date__c, (SELECT Id, Name, Line_Type__c,
                                                                    Top_Connector__c, Featured_Mortgage__c, Create_Broker_Tools__c, Quantity, Account.BillingStreet, Account.BillingCity,
                                                                    Account.BillingState, Inventory_Transaction_ID__c, Account.MLS_Set_Id__c, Product_Account__r.MLS_Set_Id__c,
                                                                    Account.BillingCountry, Account.BillingPostalCode, Account.Party_ID__c, Account.Name, Account.Type,
                                                                    Account.Customer_Id__c,Account.Email_Address__c, Account.Primary_Email__c, Account.Preferred_Phone__c, Account.Home_Phone__c,
                                                                    Account.Work_Phone__c,Account.Phone,License_Tier__c, Account.Mobile1__c,Account.Phone_Extension__c, Account.Mobile2_Other__c, Product_Email__c,ConfigOptions__c,
                                                                    Product_Account__r.Party_ID__c,External_ID__c, Product_Account__r.Name, Product_Account__r.Type,order_line_item__r.Order.Oracle_Quote__c,
                                                                    Start_Date__c,End_Date__c,Product_Account__r.Customer_Id__c, Account.Website, Quote_Transaction_ID__c, Cancellation_Reason__c,
                                                                    Market__c,Trial__c,Configure_Ad_URL__c, Lead_Type__c, Asset_Type__c, AccountId, Fulfillment_Status__c,Contractedimpressions__c,PricePerImpressionSold__c,Cancellation_Date__c,Cancellation_Effective_Date__c FROM Assets__r
                                                                    WHERE Asset_Type__c = 'Fulfill To'  and (Status!=:setStatus) and Fulfillment_Status__c!='Fulfilled') FROM Asset WHERE Id = :AssetId AND Asset_Type__c = 'Parent' limit 1];


                      }
                      if(AllrelaventAssets[0].Line_type__c=='Amend' && (AllrelaventAssets[0].Product2.ProductCode =='TOPMRKSNP' && (AllrelaventAssets[0].Ext_Days__c>0 || AllrelaventAssets[0].Override_Term__c>0))){
                           AllrelaventAssets = [SELECT Id, Sign_In_AE__r.Name,Total_Net__c,Trial__c,Sign_in_AE__r.NT_Login_ID__c,Product2.Description,Product2.Family, Account.Billing_Preference__c, Account.Admin_Company_Id__c, Account.RecordTypeId, Billing_Feed__c, product2.Product_Elig__c,order_line_item__r.Order.Type,order_line_item__r.Order.Oracle_Quote__r.Name, Name,Create_Broker_Tools__c, Line_Type__c,Sold_To_Account_Token__c,Choice_Lead_Form__c, Account.Party_ID__c,Status,Account.Name, Override_Term__c ,Account.Type, Account.Customer_Id__c,
                                                                    Account.Franchise_Type__c,Account.Phone,CreatedBy.NT_Login_ID__c, BOP_Code__c, PurchaseDate, Start_Date__c, End_Date__c,
                                                                    Broker_Plan_Affiliation__c, ContactId, Contact.FirstName,Contact.Phone, Contact.LastName, Contact.Email, Account.MLS_Set_Id__c,
                                                                    Contact.Preferred_Phone__c,Quantity, Contact.HomePhone, Contact.MobilePhone, Contact.Work_Phone__c, Contact.OtherPhone,
                                                                    Contact.Work_Phone_Ext__c, Contact.Contact_Party_ID__c, Account.BillingStreet, Account.BillingCity,
                                                                    Product_Account__c,Product_Account__r.Name,Product_Account__r.Party_ID__c,Product_Account__r.Type,Ext_Days__c,
                                                                    Product_Account__r.MLS_Set_Id__c,Product_Account__r.Customer_Id__c,MLS_Set__r.MLS_Set_ID__c,
                                                                    Product_Account__r.BillingStreet,Product_Account__r.BillingCity,Product_Account__r.BillingState,
                                                                    Product_Account__r.BillingCountry,Product_Account__r.BillingPostalCode,order_line_item__r.OrderId,order_line_item__r.Order.Oracle_Quote__c,
                                                                    Account.BillingState, Account.BillingCountry, Account.BillingPostalCode, Product2.ProductCode, External_ID__c,
                                                                    Product_Type__c, Account.Total_Contract_Value__c, Fulfillment_Status__c, Product_Email__c, Price, Top_Connector__c,ConfigOptions__c,
                                                                    Quote_Transaction_ID__c,License_Tier__c, Featured_Mortgage__c, Inventory_Transaction_ID__c,Contractedimpressions__c,PricePerImpressionSold__c,Cancellation_Date__c,Cancellation_Effective_Date__c, (SELECT Id, Name, Line_Type__c,
                                                                    Top_Connector__c, Featured_Mortgage__c, Create_Broker_Tools__c, Quantity, Account.BillingStreet, Account.BillingCity,
                                                                    Account.BillingState, Inventory_Transaction_ID__c, Account.MLS_Set_Id__c, Product_Account__r.MLS_Set_Id__c,
                                                                    Account.BillingCountry, Account.BillingPostalCode, Account.Party_ID__c, Account.Name, Account.Type,
                                                                    Account.Customer_Id__c,Account.Email_Address__c, Account.Primary_Email__c, Account.Preferred_Phone__c, Account.Home_Phone__c,
                                                                    Account.Work_Phone__c,Account.Phone,License_Tier__c, Account.Mobile1__c,Account.Phone_Extension__c, Account.Mobile2_Other__c, Product_Email__c,ConfigOptions__c,
                                                                    Product_Account__r.Party_ID__c,External_ID__c, Product_Account__r.Name, Product_Account__r.Type,order_line_item__r.Order.Oracle_Quote__c,
                                                                    Start_Date__c,End_Date__c,Product_Account__r.Customer_Id__c, Account.Website, Quote_Transaction_ID__c, Cancellation_Reason__c,
                                                                    Market__c,Trial__c,Configure_Ad_URL__c, Lead_Type__c, Asset_Type__c, AccountId, Fulfillment_Status__c,Contractedimpressions__c,PricePerImpressionSold__c,Cancellation_Date__c,Cancellation_Effective_Date__c FROM Assets__r
                                                                    WHERE Asset_Type__c = 'Fulfill To'  and (Status!=:setStatus)) FROM Asset WHERE Id = :AssetId AND Asset_Type__c = 'Parent' limit 1];


                      }
                      if(AllrelaventAssets[0].Line_type__c=='Amend' && (AllrelaventAssets[0].Account.Type =='Realtor Agent' && AllrelaventAssets[0].Product2.ProductCode =='SHOWCASE')){
                           AllrelaventAssets = [SELECT Id, Sign_In_AE__r.Name,Total_Net__c,Trial__c, Sign_in_AE__r.NT_Login_ID__c,Product2.Description,Product2.Family, Account.Billing_Preference__c, Account.Admin_Company_Id__c, Account.RecordTypeId, Billing_Feed__c, product2.Product_Elig__c,order_line_item__r.Order.Type,order_line_item__r.Order.Oracle_Quote__r.Name, Name,Create_Broker_Tools__c, Line_Type__c,Sold_To_Account_Token__c,Choice_Lead_Form__c, Account.Party_ID__c,Status,Account.Name, Override_Term__c ,Account.Type, Account.Customer_Id__c,
                                                                    Account.Franchise_Type__c,Account.Phone,CreatedBy.NT_Login_ID__c, BOP_Code__c, PurchaseDate, Start_Date__c, End_Date__c,
                                                                    Broker_Plan_Affiliation__c, ContactId, Contact.FirstName,Contact.Phone, Contact.LastName, Contact.Email, Account.MLS_Set_Id__c,
                                                                    Contact.Preferred_Phone__c,Quantity, Contact.HomePhone, Contact.MobilePhone, Contact.Work_Phone__c, Contact.OtherPhone,
                                                                    Contact.Work_Phone_Ext__c, Contact.Contact_Party_ID__c, Account.BillingStreet, Account.BillingCity,
                                                                    Product_Account__c,Product_Account__r.Name,Product_Account__r.Party_ID__c,Product_Account__r.Type,Ext_Days__c,
                                                                    Product_Account__r.MLS_Set_Id__c,Product_Account__r.Customer_Id__c,MLS_Set__r.MLS_Set_ID__c,
                                                                    Product_Account__r.BillingStreet,Product_Account__r.BillingCity,Product_Account__r.BillingState,
                                                                    Product_Account__r.BillingCountry,Product_Account__r.BillingPostalCode,order_line_item__r.OrderId,order_line_item__r.Order.Oracle_Quote__c,
                                                                    Account.BillingState, Account.BillingCountry, Account.BillingPostalCode, Product2.ProductCode, External_ID__c,
                                                                    Product_Type__c, Account.Total_Contract_Value__c, Fulfillment_Status__c, Product_Email__c, Price, Top_Connector__c,ConfigOptions__c,
                                                                    Quote_Transaction_ID__c,License_Tier__c, Featured_Mortgage__c, Inventory_Transaction_ID__c,Contractedimpressions__c,PricePerImpressionSold__c,Cancellation_Date__c,Cancellation_Effective_Date__c, (SELECT Id, Name, Line_Type__c,
                                                                    Top_Connector__c, Featured_Mortgage__c, Create_Broker_Tools__c, Quantity, Account.BillingStreet, Account.BillingCity,
                                                                    Account.BillingState, Inventory_Transaction_ID__c, Account.MLS_Set_Id__c, Product_Account__r.MLS_Set_Id__c,
                                                                    Account.BillingCountry, Account.BillingPostalCode, Account.Party_ID__c, Account.Name, Account.Type,
                                                                    Account.Customer_Id__c,Account.Phone,Account.Email_Address__c, Account.Primary_Email__c, Account.Preferred_Phone__c, Account.Home_Phone__c,
                                                                    Account.Work_Phone__c,License_Tier__c, Account.Mobile1__c,Account.Phone_Extension__c, Account.Mobile2_Other__c, Product_Email__c,ConfigOptions__c,
                                                                    Product_Account__r.Party_ID__c,External_ID__c, Product_Account__r.Name, Product_Account__r.Type,order_line_item__r.Order.Oracle_Quote__c,
                                                                    Start_Date__c,End_Date__c,Product_Account__r.Customer_Id__c, Account.Website, Quote_Transaction_ID__c, Cancellation_Reason__c,
                                                                    Market__c,Trial__c,Configure_Ad_URL__c, Lead_Type__c, Asset_Type__c, AccountId, Fulfillment_Status__c,Contractedimpressions__c,PricePerImpressionSold__c,Cancellation_Date__c,Cancellation_Effective_Date__c FROM Assets__r
                                                                    WHERE Asset_Type__c = 'Fulfill To' and (Status!=:setStatus)) FROM Asset WHERE Id = :AssetId AND Asset_Type__c = 'Parent' limit 1];


                      }

                      }



                       if((AllrelaventAssets[0].Line_type__c!='Credit' && AllrelaventAssets[0].Status=='Expired') || AllrelaventAssets[0].Line_type__c=='AssetSync'){
                      AllrelaventAssets = [SELECT Id, Sign_In_AE__r.Name,Total_Net__c,Trial__c, Sign_in_AE__r.NT_Login_ID__c,Product2.Description,Product2.Family, Account.Billing_Preference__c, Account.Admin_Company_Id__c, Account.RecordTypeId, Billing_Feed__c, Name,product2.Product_Elig__c,order_line_item__r.Order.Type,order_line_item__r.Order.Oracle_Quote__r.Name,Create_Broker_Tools__c, Line_Type__c, Override_Term__c ,Sold_To_Account_Token__c,Choice_Lead_Form__c, Account.Party_ID__c,Status,Account.Name, Account.Type, Account.Customer_Id__c,
                                                                    Account.Franchise_Type__c,Account.Phone,CreatedBy.NT_Login_ID__c, BOP_Code__c, PurchaseDate, Start_Date__c, End_Date__c,
                                                                    Broker_Plan_Affiliation__c, ContactId, Contact.FirstName,Contact.Phone, Contact.LastName, Contact.Email, Account.MLS_Set_Id__c,
                                                                    Contact.Preferred_Phone__c,Quantity, Contact.HomePhone, Contact.MobilePhone, Contact.Work_Phone__c, Contact.OtherPhone,
                                                                    Contact.Work_Phone_Ext__c, Contact.Contact_Party_ID__c, Account.BillingStreet, Account.BillingCity,
                                                                    Product_Account__c,Product_Account__r.Name,Product_Account__r.Party_ID__c,Product_Account__r.Type,
                                                                    Product_Account__r.MLS_Set_Id__c,Product_Account__r.Customer_Id__c,MLS_Set__r.MLS_Set_ID__c,
                                                                    Product_Account__r.BillingStreet,Product_Account__r.BillingCity,Product_Account__r.BillingState,order_line_item__r.Order.Oracle_Quote__c,
                                                                    Product_Account__r.BillingCountry,Product_Account__r.BillingPostalCode,order_line_item__r.OrderId,Ext_Days__c,
                                                                    Account.BillingState, Account.BillingCountry, Account.BillingPostalCode, Product2.ProductCode, External_ID__c,
                                                                    Product_Type__c, Account.Total_Contract_Value__c, Fulfillment_Status__c, Product_Email__c ,Price, Top_Connector__c,ConfigOptions__c,
                                                                    Quote_Transaction_ID__c,License_Tier__c, Featured_Mortgage__c, Inventory_Transaction_ID__c,Contractedimpressions__c,PricePerImpressionSold__c,Cancellation_Date__c,Cancellation_Effective_Date__c, (SELECT Id, Name, Line_Type__c,
                                                                    Top_Connector__c, Featured_Mortgage__c, Create_Broker_Tools__c, Quantity, Account.BillingStreet, Account.BillingCity,
                                                                    Account.BillingState, Inventory_Transaction_ID__c, Account.MLS_Set_Id__c, Product_Account__r.MLS_Set_Id__c,
                                                                    Account.BillingCountry, Account.BillingPostalCode, Account.Party_ID__c, Account.Name, Account.Type,
                                                                    Account.Customer_Id__c,Account.Email_Address__c, Account.Primary_Email__c, Account.Preferred_Phone__c, Account.Home_Phone__c,
                                                                    Account.Work_Phone__c,Account.Phone,License_Tier__c,Account.Phone_Extension__c, Account.Mobile1__c, Account.Mobile2_Other__c, Product_Email__c,ConfigOptions__c,
                                                                    Product_Account__r.Party_ID__c,External_ID__c, Product_Account__r.Name, Product_Account__r.Type,order_line_item__r.Order.Oracle_Quote__c,
                                                                    Start_Date__c,End_Date__c,Product_Account__r.Customer_Id__c, Account.Website, Quote_Transaction_ID__c, Cancellation_Reason__c,
                                                                    Market__c,Trial__c,Configure_Ad_URL__c, Lead_Type__c, Asset_Type__c, AccountId, Fulfillment_Status__c,Contractedimpressions__c,PricePerImpressionSold__c,Cancellation_Date__c,Cancellation_Effective_Date__c FROM Assets__r
                                                                    WHERE Asset_Type__c = 'Fulfill To' and (Status!=:setStatus)) FROM Asset WHERE Id = :AssetId AND Asset_Type__c = 'Parent' limit 1];
                // and Line_Type__c!='Amend'
                      }
                      // CRM-1362 :- Return null if parent asset is already fulfilled
                      if(AllrelaventAssets[0].Fulfillment_Status__c=='Fulfilled') {
            system.debug('Asset is already Fulfilled.');
            return null;
        }

            for(Asset theParentAsset : AllrelaventAssets) {
                if(
                    !SubmitFlag &&
                    String.isNotBlank(theParentAsset.Fulfillment_Status__c) &&
                    theParentAsset.Fulfillment_Status__c.equalsIgnoreCase('Success')
                ) {
                    system.debug('TRACE: Parent Asset Fulfillment Status - Success. END.');
                    return theParentAssetObject;
                }

                system.debug('TRACE: Parent Asset - ' + theParentAsset);
                system.debug('TRACE: Child Assets - ' + theParentAsset.Assets__r);

                theParentAssetType = new ParentAssetType();
                
                // CRM-3294 Assign new fields added for this ticket
                theParentAssetType.NTLoginId = theParentAsset.Sign_in_AE__r.NT_Login_ID__c;
                theParentAssetType.SalesRep = theParentAsset.Sign_in_AE__r.Name;
                theParentAssetType.ProductFamily = theParentAsset.Product2.Family;
                theParentAssetType.ProductDescription = theParentAsset.Product2.Description;
                theParentAssetType.BillingFeed = theParentAsset.Billing_Feed__c;
                // Local expert
                theParentAssetType.netPrice = theParentAsset.Total_Net__c;
                // CRM-3294 End
                
                // CRM-2096
                theParentAssetType.productEligibility = theParentAsset.product2.Product_Elig__c;
                theParentAssetType.Action = theParentAsset.Line_Type__c;
                theParentAssetType.CorelationID = null;

                //Added By Nevil as a part of seller lead bundle product development
                theParentAssetType.forecastedLead               = theParentAsset.Contractedimpressions__c;
                theParentAssetType.pricePerLead                 = theParentAsset.PricePerImpressionSold__c;
                theParentAssetType.cancellationDate             = theParentAsset.Cancellation_Date__c;
                theParentAssetType.cancellationEffectiveDate    = theParentAsset.Cancellation_Effective_Date__c;


                // Asset Account Details.
                theAccount = new Account();
                // CRM-3294 Assign BillingFeed, AdminCompanyId and AccountID
                theAccount.BillingFeed = theParentAsset.Account.Billing_Preference__c;
                theAccount.AdminCompanyId = theParentAsset.Account.Admin_Company_Id__c;
               // theAccount.AccountID = theParentAsset.Account.Id;
               // CRM-3294 - If asset account is moving account, then assign parent account party id
               if (theParentAsset.Account.RecordTypeId == movingRecordTypeId) {
                    List<Account_Relationship__c> relationships = [SELECT Parent_Account__r.Party_id__c FROM Account_Relationship__c WHERE Child_Account__c =:theParentAsset.AccountId AND Parent_Account__c != null LIMIT 1];
                    if (relationships.size() > 0) {
                        theAccount.ParentAccountPartyId = relationships[0].Parent_Account__r.Party_id__c;
                    }
               }
               // CRM-3294 End
               
                theAccount.CDHOrgPartyID = theParentAsset.Account.Party_ID__c;
                theAccount.AccountName = theParentAsset.Account.Name;
                theAccount.AccountType = theParentAsset.Account.Type;
    //            theAccount.MLSSetID = theParentAsset.Account.MLS_Set_Id__c != null ? Integer.valueOf(theParentAsset.Account.MLS_Set_Id__c) : null;
                theAccount.MLSSetID = theParentAsset.Account.MLS_Set_Id__c != null ? theParentAsset.Account.MLS_Set_Id__c : null;
                theAccount.CustomerID = theParentAsset.Account.Customer_Id__c;
                theParentAssetType.SoldToAccount = theAccount;
                //theParentAssetType.AccountID  = theParentAsset.Account.Id;
                theParentAssetType.configOptions  = theParentAsset.ConfigOptions__c;
                theParentAssetType.FranchiseType = theParentAsset.Account.Franchise_Type__c;
                theParentAssetType.LoginUserName = theParentAsset.CreatedBy.NT_Login_ID__c;
                theParentAssetType.AssetID = theParentAsset.Id;
                theParentAssetType.CreateBrokerTools = theParentAsset.Create_Broker_Tools__c;
                theParentAssetType.BOPCode = theParentAsset.BOP_Code__c;
                theParentAssetType.ContractDate = String.valueOf(theParentAsset.PurchaseDate);
                theParentAssetType.StartDate = String.valueOf(theParentAsset.Start_Date__c);
                theParentAssetType.ExpirationDate = String.valueOf(theParentAsset.End_Date__c);
                theParentAssetType.AffiliationID = theParentAsset.Broker_Plan_Affiliation__c;
                theParentAssetType.ProductEmail = theParentAsset.Product_Email__c;
                theParentAssetType.EnableShowcaseChoice = theParentAsset.Choice_Lead_Form__c;
                theParentAssetType.trial = theParentAsset.Trial__c;
                theParentAssetType.SoldtoAccountToken = theParentAsset.Sold_To_Account_Token__c;

                theParentAssetType.SfdcOrderID   = theParentAsset.order_line_item__r.OrderId;
                theParentAssetType.SfdcQuoteID = theParentAsset.order_line_item__r.Order.Oracle_Quote__r.Name;
                theparentAssetType.Quantity = theParentAsset.Quantity != null ? Integer.valueOf(theParentAsset.Quantity) : 0;
                theparentAssetType.LicenseQuantity = theParentAsset.License_Tier__c != null ? Integer.valueOf(theParentAsset.License_Tier__c) : 0;//Integer.valueof(theParentAsset.License_Tier__c);
                // Asset Contact Details.
                theBrokerContact = new BrokerContact();
                for(Account_Relationship__c accRelation:[Select Id,Name,Contact_To__c,Contact_To__r.FirstName,Contact_To__r.LastName,Contact_To__r.Preferred_Phone__c,
                                                         Contact_To__r.HomePhone,Contact_To__r.Phone,Contact_To__r.MobilePhone,Contact_To__r.Work_Phone__c,Contact_To__r.OtherPhone
                                                         ,Contact_To__r.Contact_Party_ID__c,Contact_To__r.Work_Phone_Ext__c,Contact_To__r.Email from Account_Relationship__c where Contact_Role__c='Primary Contact' and Contact_To__c!=null and Parent_Account__c=:theParentAsset.AccountId limit 1]){
                theBrokerContact.ContactID = accRelation.Contact_To__c;
                theBrokerContact.FirstName = accRelation.Contact_To__r.FirstName;
                theBrokerContact.LastName = accRelation.Contact_To__r.LastName;
                theBrokerContact.EmailAddress = accRelation.Contact_To__r.Email;

                // Determining Parent Asset Contact Preferred Phone.
                if(String.isNotBlank(accRelation.Contact_To__r.Phone)) {
                    String theContactPreferredPhone = accRelation.Contact_To__r.Phone;
                    if(theContactPreferredPhone.equalsIgnoreCase('Home')) {
                        theBrokerContact.Phone = accRelation.Contact_To__r.Phone;
                    }
                    else if(theContactPreferredPhone.equalsIgnoreCase('Mobile')) {
                        theBrokerContact.Phone = accRelation.Contact_To__r.Phone;
                    }
                    else if(theContactPreferredPhone.equalsIgnoreCase('Work')) {
                        theBrokerContact.Phone = accRelation.Contact_To__r.Phone;
                    }
                    else if(theContactPreferredPhone.equalsIgnoreCase('Other')) {
                        theBrokerContact.Phone = accRelation.Contact_To__r.Phone;
                    }
                    else {
                        theBrokerContact.Phone = accRelation.Contact_To__r.Phone;
                    }
                    theBrokerContact.PhoneExtension = accRelation.Contact_To__r.Work_Phone_Ext__c;
                    System.debug('$$$$$$$'+accRelation.Contact_To__r.Contact_Party_ID__c);
                //

                }
                theBrokerContact.CDHPersonPartyID = accRelation.Contact_To__r.Contact_Party_ID__c;
                theBrokerContact.Address1 = theParentAsset.Account.BillingStreet;
                theBrokerContact.City = theParentAsset.Account.BillingCity;
                theBrokerContact.State = theParentAsset.Account.BillingState;
                theBrokerContact.Country = theParentAsset.Account.BillingCountry;
                theBrokerContact.PostalCode = theParentAsset.Account.BillingPostalCode;
                }
                theParentAssetType.Contact = theBrokerContact;
                theParentAssetType.parentExternalID = theParentAsset.External_ID__c;
                theParentAssetType.ProductPartNumber = theParentAsset.Product2.ProductCode;
                theParentAssetType.ProductType = theParentAsset.Product_Type__c;
                theParentAssetType.ContractValue = theParentAsset.Price;
                theParentAssetType.TopConnector = theParentAsset.Top_Connector__c;
                theParentAssetType.FeaturedMortgage = theParentAsset.Featured_Mortgage__c;
                theParentAssetType.SiebelLegacyID = theParentAsset.External_ID__c;
                theParentAssetType.InvTransactionID = theParentAsset.Inventory_Transaction_ID__c;
                theParentAssetType.InvLineItemID = theParentAsset.Quote_Transaction_ID__c;
                if(theParentAsset.Line_type__c=='Credit' && (theParentAsset.Ext_Days__c>0 || theParentAsset.override_term__c>0)){
                theParentAssetType.Action = 'Amend';
                }

                // Extracting Child Asset Account Ids.
                List<Asset> theFilteredChildAssets = new List<Asset>();
                Map<Id, Id> childAssetIdsAndAccountIds = new Map<Id, Id>();
                for(Asset theChildAsset : theParentAsset.Assets__r) {
                  /*  if(
                        !SubmitFlag &&
                        String.isNotBlank(theChildAsset.Fulfillment_Status__c) &&
                        theChildAsset.Fulfillment_Status__c.equalsIgnoreCase('Fulfilled')) {
                        continue;
                    }*/
                    theFilteredChildAssets.add(theChildAsset);
                    childAssetIdsAndAccountIds.put(theChildAsset.Id, theChildAsset.AccountId);
                }

                // Extracting Primary Contact First Name And Last Name.
                Map<Id, Map<String, String>> accountIdAndContactNameMapping = new Map<Id, Map<String, String>>();
                for(Account_Relationship__c theAccountRelationship : [SELECT Parent_Account__c, Contact_To__r.FirstName, Contact_To__r.LastName FROM
                                                                                                                            Account_Relationship__c WHERE Parent_Account__c IN
                                                                                                                            :childAssetIdsAndAccountIds.values() AND Contact_Role__c = 'Primary Contact']) {
                    accountIdAndContactNameMapping.put(
                        theAccountRelationship.Parent_Account__c,
                        new Map<String, String> {
                            'FirstName' => theAccountRelationship.Contact_To__r.FirstName,
                            'LastName' => theAccountRelationship.Contact_To__r.LastName
                        }
                    );
                }

                // Extracting Child Participant Assets.
                Map<Id, List<Asset>> theParticipantAssets = new Map<Id, List<Asset>>();
                for(Asset theParticipantAsset : [SELECT Id, Parent_Asset__c,Quantity,Account.Website,External_ID__c, Line_Type__c,Configure_Ad_URL__c,Account.MLS_Set_Id__c,MLS_Set__c,MLS_Set__r.MLS_Set_ID__c FROM Asset WHERE
                                                                                 Parent_Asset__c IN :childAssetIdsAndAccountIds.keySet() AND (Status!=:setStatus) and Asset_Type__c = 'Participant']) { // and Line_Type__c!='Amend'
                    if(!theParticipantAssets.containsKey(theParticipantAsset.Parent_Asset__c)) {
                        theParticipantAssets.put(theParticipantAsset.Parent_Asset__c, new List<Asset>());
                    }
                    theParticipantAssets.get(theParticipantAsset.Parent_Asset__c).add(theParticipantAsset);
                }
                system.debug('TRACE: Participant Assets - ' + theParticipantAssets);

                 System.debug('5555555'+theFilteredChildAssets);
                // Processing Child Assets.
                FulfillToAssetType theFulfillToAssetType = null;
                List<FulfillToAssetType> OfficeAsset = new List<FulfillToAssetType>();
                for(Asset theChildAsset : theFilteredChildAssets) {
                    theFulfillToAssetType = new FulfillToAssetType();
                    theFulfillToAssetType.Action = theChildAsset.Line_Type__c;
                    if(theParentAssetType.Action=='AssetSync'){theFulfillToAssetType.Action='AssetSync';}
                    if(theParentAsset.Status=='Expired' && theParentAsset.order_line_item__r.Order.Type!='Auto-Credit'){theFulfillToAssetType.Action='Cancel';}

                    if(theFulfillToAssetType.Action==null){theFulfillToAssetType.Action=theParentAssetType.Action;}
                    if(theParentAsset.Status=='Expired'){theFulfillToAssetType.Action='Cancel';}
                    if(theParentAsset.Line_type__c=='Credit' && (theParentAsset.Ext_Days__c>0 || theParentAsset.override_term__c>0)){
                    theFulfillToAssetType.Action = 'Amend';
                    }

                    //Added By Nevil as a part of seller lead bundle product development
                    theFulfillToAssetType.forecastedLead                = theChildAsset.Contractedimpressions__c;
                    theFulfillToAssetType.pricePerLead                  = theChildAsset.PricePerImpressionSold__c;
                    theFulfillToAssetType.cancellationDate              = theParentAsset.Cancellation_Date__c;
                    theFulfillToAssetType.cancellationEffectiveDate     = theParentAsset.Cancellation_Effective_Date__c;

                    theFulfillToAssetType.CreateBrokerTools = theChildAsset.Create_Broker_Tools__c;
                    //theFulfillToAssetType.Quantity = theChildAsset.Quantity != null ? Integer.valueOf(theChildAsset.Quantity) : null;
                    theFulfillToAssetType.Address1 = theChildAsset.Account.BillingStreet;
                    theFulfillToAssetType.City = theChildAsset.Account.BillingCity;
                    theFulfillToAssetType.EnableShowcaseChoice = theParentAsset.Choice_Lead_Form__c;
                    theFulfillToAssetType.State = theChildAsset.Account.BillingState;
                    theFulfillToAssetType.Country = theChildAsset.Account.BillingCountry;
                    theFulfillToAssetType.PostalCode = theChildAsset.Account.BillingPostalCode;
                    theFulfillToAssetType.AgentMlsCode = null;
                    theFulfillToAssetType.OfficeMlsCode = null;
                    //Added by Rajamohan Vakati - JIRA ADVP-2061
                    //theFulfillToAssetType.configOptions =  theChildAsset.ConfigOptions__c;
                    theFulfillToAssetType.WebsiteUrl   = theChildAsset.Account.Website;
                    theFulfillToAssetType.LeadType = theChildAsset.Lead_Type__c;
                    theFulfillToAssetType.MarketName = theChildAsset.Market__c;
                    theFulfillToAssetType.CancelReason = theChildAsset.Cancellation_Reason__c;
                    theFulfillToAssetType.InvTransactionID = theChildAsset.Inventory_Transaction_ID__c;
                    theFulfillToAssetType.InvLineItemID = theChildAsset.Quote_Transaction_ID__c;
                    theFulfillToAssetType.EndDate = String.valueOf(theChildAsset.End_Date__c);
                    theFulfillToAssetType.StartDate = String.valueOf(theChildAsset.Start_Date__c);
                    theFulfillToAssetType.WebsiteUrl = theChildAsset.Account.Website;
                    theFulfillToAssetType.ProductEmail = theChildAsset.Product_Email__c;
                    theFulfillToAssetType.Email = theChildAsset.Account.Email_Address__c;
                    theFulfillToAssetType.TopConnector = theChildAsset.Top_Connector__c;
                    theFulfillToAssetType.FeaturedMortgage = theChildAsset.Featured_Mortgage__c;
                    theFulfillToAssetType.trial = theParentAsset.Trial__c;
                    theFulfillToAssetType.fulfilltoExternalID = theChildAsset.External_ID__c;
                   // theFulfillToAssetType.Quantity = theChildAsset.Quantity != null ? Integer.valueOf(theChildAsset.Quantity) : null;//Integer.valueof(theChildAsset.Quantity);
                 //   theFulfillToAssetType.LicenseQuantity = theChildAsset.License_Tier__c != null ? Integer.valueOf(theChildAsset.License_Tier__c) : null; //Integer.valueof(theChildAsset.License_Tier__c);
                    // Determining Child Asset Account Preferred Phone.
                    if(String.isNotBlank(theChildAsset.Account.Preferred_Phone__c)) {
                        String theAccountPreferredPhone = theChildAsset.Account.Phone;
                        if(theAccountPreferredPhone.equalsIgnoreCase('Home Phone') || theAccountPreferredPhone.equalsIgnoreCase('Home')) {
                            theFulfillToAssetType.Phone = theChildAsset.Account.Phone;
                        }
                        else if(theAccountPreferredPhone.equalsIgnoreCase('Work') || theAccountPreferredPhone.equalsIgnoreCase('Work Phone')) {
                            theFulfillToAssetType.Phone = theChildAsset.Account.Phone;
                        }
                        else if(theAccountPreferredPhone.equalsIgnoreCase('Mobile')) {
                            theFulfillToAssetType.Phone = theChildAsset.Account.Phone;
                        }
                        else if(theAccountPreferredPhone.equalsIgnoreCase('Other')) {
                            theFulfillToAssetType.Phone = theChildAsset.Account.Phone;
                        }
                        else {
                            theFulfillToAssetType.Phone = theChildAsset.Account.Phone;
                        }
                    }

                    theFulfillToAssetType.AssetID = theChildAsset.Id;
                    theFulfillToAssetType.ParentAssetID = theParentAsset.Id;

                    // Child Asset Product Account Details.
                    Account theProductAccount = new Account();
                    if(theParentAsset.Product_Account__c!=null){
                    theProductAccount.CDHOrgPartyID = theParentAsset.Product_Account__r.Party_ID__c;
                    theProductAccount.AccountName = theParentAsset.Product_Account__r.Name;
                    theProductAccount.AccountType = theParentAsset.Product_Account__r.Type;
                    theProductAccount.MLSSetID = theParentAsset.Product_Account__r.MLS_Set_Id__c != null ?
                                                 theParentAsset.Product_Account__r.MLS_Set_Id__c : null;
                    theProductAccount.CustomerID = theParentAsset.Product_Account__r.Customer_Id__c;
                    theProductAccount.Address1 = theParentAsset.Product_Account__r.BillingStreet;
                    theProductAccount.City = theParentAsset.Product_Account__r.BillingCity;
                    theProductAccount.State = theParentAsset.Product_Account__r.BillingState;
                    theProductAccount.Country = theParentAsset.Product_Account__r.BillingCountry;
                    theProductAccount.PostalCode = theParentAsset.Product_Account__r.BillingPostalCode;
                    }

                    theFulfillToAssetType.ProductAccount = theProductAccount;

                    // Child Asset Account Details.
                    Account theChildAssetAccount = new Account();
                    theChildAssetAccount.CDHOrgPartyID = theChildAsset.Account.Party_ID__c;
                    theChildAssetAccount.AccountName = theChildAsset.Account.Name;
                    theChildAssetAccount.AccountType = theChildAsset.Account.Type;
                    theChildAssetAccount.MLSSetID = theChildAsset.Account.MLS_Set_Id__c != null ?
                                                    theChildAsset.Account.MLS_Set_Id__c : null;
                    theChildAssetAccount.CustomerID = theChildAsset.Account.Customer_Id__c;
                    theFulfillToAssetType.FulfillToAccount = theChildAssetAccount;

                    // Child Asset - Account - Account Relationship - Primary Contact First Name And Last Name.
                    theFulfillToAssetType.FirstName = null;
                    theFulfillToAssetType.LastName = null;
                    if(accountIdAndContactNameMapping.containsKey(theChildAsset.AccountId)) {
                        theFulfillToAssetType.FirstName = accountIdAndContactNameMapping.get(theChildAsset.AccountId).get('FirstName');
                        theFulfillToAssetType.LastName = accountIdAndContactNameMapping.get(theChildAsset.AccountId).get('LastName');
                    }
                    System.debug(theFulfillToAssetType.FirstName+'########'+theFulfillToAssetType.LastName);
                    // Processing Child Asset - Participant Assets.
                    MlsType theMlsType = null;
                    List<MlsType> theParticipants = new List<MlsType>();
                    if(theParticipantAssets.containsKey(theChildAsset.Id)) {
                        for(Asset theParticipant : theParticipantAssets.get(theChildAsset.Id)) {
                            theMlsType = new MlsType();
                            theMlsType.Action = theParticipant.Line_Type__c;
                            if(theParentAssetType.Action=='AssetSync'){theMlsType.Action='AssetSync';}
                            if(theParentAssetType.Action=='Cancel'){theMlsType.Action='Cancel';}
                            if(theMlsType.Action==null){theMlsType.Action=theParentAssetType.Action;}
                            if(theParentAsset.Status=='Expired'){theFulfillToAssetType.Action='Cancel';}
                            if(theParentAsset.Line_type__c=='Credit' && (theParentAsset.Ext_Days__c>0 || theParentAsset.override_term__c>0)){
                            theMlsType.Action = 'Amend';
                            }
                            theMlsType.MlsSetID = theParticipant.MLS_Set__r.MLS_Set_ID__c;
                            theMlsType.MlsAssetID = theParticipant.Id;
                            System.debug(theParticipant.External_ID__c+'  ABABABAB');
                            theMlsType.MlsExternalID = theParticipant.External_ID__c;
                            theParticipants.add(theMlsType);
                        }
                    }

                    Mls theMls = new Mls();
                    theMls.Mls = theParticipants;
                    theFulfillToAssetType.Mls = theMls;

                    OfficeAsset.add(theFulfillToAssetType);
                }

                FulfillToAsset theFulfillToAssetObject = new FulfillToAsset();
                theFulfillToAssetObject.OfficeAsset = OfficeAsset;

                theParentAssetType.FulfillToAsset = new List<FulfillToAsset>{ theFulfillToAssetObject };

            }

            theParentAssetObject.ParentAsset = new List<ParentAssetType>{ theParentAssetType };

            system.debug('TRACE: Final Response - ' + theParentAssetObject);
            return theParentAssetObject;


        }
        catch(Exception e) {
      system.debug('TRACE: Exception Occurred - ' + e.getMessage());
      system.debug('TRACE: Exception Stack Trace - ' + e.getStackTraceString());
            return null;
        }
  }
}