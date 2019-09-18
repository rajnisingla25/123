public  class MoveTestDataUtilClass {
    Public Account newAccount {get; set;}
    Public Account newBrokerAccount {get; set;}
    Public Account newRealtorOfficeAccount {get; set;}
    Public Account newRealtorAgentAccount {get; set;}
    Public Product_Restriction_Flag__c newProductRestrictionFlag {get; set;}
    public Account_Relationship__c primarycntct {get; set;}
    Public Contact myContact {get; set;}
    Public Opportunity theOpportunity {get; set;}
    Public OpportunityLineItem theOpportunityProduct {get; set;}
    Public Lead led {get; set;}
    Public Asset assets {get; set;}
    Public Asset fulfillassets {get; set;}
    Public Asset participantfulfillassets {get; set;}
    Public Product2 newProduct {get; set;}
    Public Product2 newProduct1 {get; set;}
    Public Product2 newProductManual {get; set;}
    Public Contract myContract {get; set;}
    Public Commission__c Commission1 {get; set;}
    Public Campaign Campaigns {get; set;}
    Public Campaign_History__c Campaignhist {get; set;}
    Public Quota__c QuotaHandler {get; set;}
    Public PricebookEntry thePricebookEntrie {get; set;}
    Public Order Orders {get; set;}
    Public OrderItem OrderItems {get; set;}
    Public BigMachines__Quote__c OracleQuote {get; set;}
    Public BigMachines__Quote_Product__c QuoteProduct {get; set;}
    Public BigMachines__Quote_Product__c QuoteProductManual {get; set;}
    Public BigMachines__Quote_Product__c QuoteProductPreSale {get; set;}
    Public Tiger_Lead_Products__c TigerLead {get; set;}
   // Public Tiger_Lead_Product_List__c LeadProduct{get;set;}
    Public Case cse {get; set;}
    Public Waitlist__c w {get; set;}
    Public Waitlist_Item__c wt {get; set;}
    Public  DisabledTrigger__c Dtrg {get; set;}
//Public TigerLeadActivities__c LeadActivity{get;set;}
    Public BigMachineUrls__c bmurls {get; set;}
    Public  Order_Product_And_Parent_Asset_Fields__c oppaf {get; set;}
    Public  User usr {get; set;}
    Public Presale_Available_Inventory__c presaleavail {get; set;}
    Public Id theStandardPriceBookId {get; set;}

    Public MoveTestDataUtilClass() {
        theStandardPriceBookId = Test.getStandardPricebookId();
        System.debug('theStandardPriceBookId777' + theStandardPriceBookId);
    }

    Public User CreateUserSingle() {
        Profile p = [select id from profile where name = 'System Administrator'];
        usr = new User(alias = 'standt', email = 'standarduser321@testorg.com',
                       emailencodingkey = 'UTF-8', lastname = 'Testing321', languagelocalekey = 'en_US',
                       localesidkey = 'en_US', profileid = p.Id,
                       timezonesidkey = 'America/New_York', username = 'standarduser321@test.com');
        insert usr;
        return usr;
    }
    Public User UpdateUserSingle() {
        update usr;
        return usr;
    }
    Public  BigMachineUrls__c CreateBMURLSingle() {
        bmurls = new BigMachineUrls__c();
        bmurls.Name = 'BM';
        bmurls.BigmachineInstance__c = 'devmoveinc';
        bmurls.Bigmachine_Url__c = 'https://devmoveinc.bigmachines.com/bmfsweb/devmoveinc';
        bmurls.DefaultPassword__c = 'asdfgvc';
        bmurls.DefaultUserName__c = 'SOSHARMA';
        bmurls.Salesforce_Instance__c = 'https://bigmachines.cs11.visual.force.com';
        //Dtrg.Bigmachine_Url__c = 'Test@test.com';
        insert bmurls;
        return bmurls;
    }

    Public  DisabledTrigger__c CreateDisabledTriggerSingle() {
        Dtrg = new DisabledTrigger__c();
        Dtrg.Name = 'Disabled';
        Dtrg.TaskTrigger__c = 'Test@test.com';
        Dtrg.AssetTrigger__c = 'Test@test.com';
        insert Dtrg;
        return Dtrg;
    }

    Public List<Order_Product_And_Parent_Asset_Fields__c> CreateOrderProductAndParentAssetCSSingle() {
        List<Order_Product_And_Parent_Asset_Fields__c> lstOPPAF = new List<Order_Product_And_Parent_Asset_Fields__c>();
        Map<String, String> mapOPPAS = new Map<String, String>();
        oppaf = new Order_Product_And_Parent_Asset_Fields__c();
        oppaf.Name = 'Disabled';
        oppaf.Asset_Field_API_Name__c = 'Test@test.com';
        insert oppaf;
        return lstOPPAF;
    }
    Public Account CreateBrokerAccountSingle() {
        newAccount = new Account();
        newAccount.name = 'XYZ';
        newAccount.Phone = '+49-12345';
        newAccount.BillingStreet = 'Am Tierpark 16';
        newAccount.BillingCity = 'Cologne';
        newAccount.BillingPostalCode = '54321';
        newAccount.BillingState = 'Nordrhein-Westfalen';
        newAccount.BillingCountry = 'Germany';
        newAccount.Primary_Email__c = 'ra@gmail.com';
        newAccount.Home_Phone__c = '967622877';
        newAccount.Work_Phone__c = '456789';
        newAccount.Mobile1__c = '1234566';
        newAccount.Mobile2_Other__c = '1245787';
        newAccount.party_id__c = '206084041';
        newAccount.Type = 'Broker';
        newAccount.Auto_Renewal__c = True;
        newAccount.Territories__c = 'test';
        insert newAccount;
        return newAccount;
    }
    Public Account CreateRealtorOfficeAccountSingle() {
        newRealtorOfficeAccount = new Account();
        newRealtorOfficeAccount.name = 'XYZ';
        newRealtorOfficeAccount.Phone = '+49-12345';
        newRealtorOfficeAccount.BillingStreet = 'Am Tierpark 16';
        newRealtorOfficeAccount.BillingCity = 'Cologne';
        newRealtorOfficeAccount.BillingPostalCode = '54321';
        newRealtorOfficeAccount.BillingState = 'Nordrhein-Westfalen';
        newRealtorOfficeAccount.BillingCountry = 'Germany';
        newRealtorOfficeAccount.Primary_Email__c = 'ra@gmail.com';
        newRealtorOfficeAccount.Home_Phone__c = '967622877';
        newRealtorOfficeAccount.Work_Phone__c = '456789';
        newRealtorOfficeAccount.Mobile1__c = '1234566';
        newRealtorOfficeAccount.Mobile2_Other__c = '1245787';
        newRealtorOfficeAccount.party_id__c = '206084041';
        newRealtorOfficeAccount.Type = 'Realtor Office';
        newRealtorOfficeAccount.Auto_Renewal__c = True;
        newRealtorOfficeAccount.Territories__c = 'test';
        insert newRealtorOfficeAccount;
        return newRealtorOfficeAccount;
    }
    Public Account CreateRealtorAgentAccountSingle() {
        newRealtorAgentAccount = new Account();
        newRealtorAgentAccount.name = 'XYZ';
        newRealtorAgentAccount.Phone = '+49-12345';
        newRealtorAgentAccount.BillingStreet = 'Am Tierpark 16';
        newRealtorAgentAccount.BillingCity = 'Cologne';
        newRealtorAgentAccount.BillingPostalCode = '54321';
        newRealtorAgentAccount.BillingState = 'Nordrhein-Westfalen';
        newRealtorAgentAccount.BillingCountry = 'Germany';
        newRealtorAgentAccount.Primary_Email__c = 'ra@gmail.com';
        newRealtorAgentAccount.Home_Phone__c = '967622877';
        newRealtorAgentAccount.Work_Phone__c = '456789';
        newRealtorAgentAccount.Mobile1__c = '1234566';
        newRealtorAgentAccount.Mobile2_Other__c = '1245787';
        newRealtorAgentAccount.party_id__c = '206084041';
        newRealtorAgentAccount.Type = 'Realtor Agent';
        newRealtorAgentAccount.Auto_Renewal__c = True;
        newRealtorAgentAccount.Territories__c = 'test';
        insert newRealtorAgentAccount;
        return newRealtorAgentAccount;
    }
    public Account_Relationship__c CreateBrockerOfficeAccountRelationshipSingle() {
        Account_Relationship__c AccRelationShip = new Account_Relationship__c();
        AccRelationShip.Parent_Account__c = newAccount.id;
        AccRelationShip.Child_Account__c = newRealtorOfficeAccount.id;
        AccRelationShip.Relationship_Type__c = 'Parent/Child';
        //AccRelationShip.Name = 'My Relationship';
        //AccRelationShip.Parent_Account__c =
        insert AccRelationShip;
        return AccRelationShip;
    }

    public Account_Relationship__c CreateRealtorAgentAccountRelationshipSingle() {
        Account_Relationship__c AccRelationShip = new Account_Relationship__c();
        AccRelationShip.Parent_Account__c = newRealtorOfficeAccount.id;
        AccRelationShip.Child_Account__c = newRealtorAgentAccount.id;
        AccRelationShip.Relationship_Type__c = 'Parent/Child';
        //AccRelationShip.Name = 'My Relationship';
        //AccRelationShip.Parent_Account__c =
        insert AccRelationShip;
        return AccRelationShip;
    }

    Public contact CreateContactSingle() {
        myContact = new Contact ();
        myContact.FirstName = 'Joe';
        myContact.LastName = 'Schmoe';
        myContact.Email = 'Joe.Schmoe@test.de';
        myContact.AccountId = newAccount.Id;
        myContact.MailingStreet = newAccount.BillingStreet;
        myContact.MailingState = newAccount.BillingState;
        myContact.MailingCity = newAccount.BillingCity;
        myContact.MailingPostalCode = newAccount.BillingPostalCode;
        myContact.MailingCountry = newAccount.BillingCountry;
        myContact.Phone = newAccount.Phone;

        myContact.Type__c = 'Other';
        myContact.Active__c = true;
        insert myContact;
        return myContact;
    }
    Public Opportunity CreateOppurtunitySingle() {
        theOpportunity = new Opportunity();
        theOpportunity.Name = 'The Opportunity';
        theOpportunity.StageName = 'Prospecting';
        theOpportunity.CloseDate = system.today();
        theOpportunity.AccountId = CreateBrokerAccountSingle().id;
        theOpportunity.Account_Type__c = 'Inside';
        theOpportunity.Is_Renewal_Opp__c = true;
        insert theOpportunity;
        return theOpportunity;
    }

    Public OpportunityLineItem CreateOpportunityProductSingle() {
        theOpportunityProduct = new OpportunityLineItem();
        //theOpportunityProduct.Name = 'The Opportunity Product';
        theOpportunityProduct.PricebookEntryId = thePricebookEntrie.id;
        //theOpportunityProduct.CloseDate = system.today();
        theOpportunityProduct.OpportunityId = theOpportunity.id;
        theOpportunityProduct.Quantity = 10;
        theOpportunityProduct.TotalPrice = 1000;
        //theOpportunityProduct.Is_Renewal_Opp__c = true;
        insert theOpportunityProduct;
        return theOpportunityProduct;
    }

    Public Contract CreateContractSingle() {
        myContract = new Contract();
        myContract.AccountId = newAccount.id;
        myContract.Name = 'test contract';
        //myContract.Status = 'Activated';
        myContract.Pricebook2Id = theStandardPriceBookId;
        myContract.ContractTerm = 600;
        myContract.StartDate = system.today().AddDays(-1);
        insert myContract;
        myContract.Status = 'Active';
        update myContract;
        return myContract;
    }
    Public Lead CreateLeadSingle() {
        Led = new Lead();
        Led.LastName = 'Mr';
        Led.FirstName = 'Test';
        Led.Status = 'New';
        Led.Company = 'Test';
        Led.Account__c = CreateBrokerAccountSingle().id;
        Led.Contact__c = CreateContactSingle().id;
        Insert Led;
        return Led;
    }
    Public Product2 CreateProductManualSingle() {
        newProductManual = new Product2();
        newProductManual.Name = 'TestProduct';
        newProductManual.Commission_Category__c = 'Normal';
        newProductManual.Normalization_factor__c = 1.10;
        newProductManual.Commission_Category__c = 'CFCB';
        newProductManual.Fulfillment_Type__c = 'Manual';
        newProductManual.Auto_Renewal__c = True;
        newProduct.ProductCode = 'DAP' ;
        newProductManual.S_No__c = 2;
        newProductManual.isActive = true;
        insert newProductManual;
        return newProductManual;
    }

    Public Product2 CreateProductSingle() {
        newProduct = new Product2();
        newProduct.Name = 'TestProduct';
        newProduct.Commission_Category__c = 'Normal';
        newProduct.Normalization_factor__c = 1.10;
        newProduct.Commission_Category__c = 'CFCB';
        newProduct.Fulfillment_Type__c = 'Manual';
        newProduct.Auto_Renewal__c = True;
        newProduct.ProductCode = 'HOMESRCH' ;
        newProduct.S_No__c = 2;
        newProduct.isActive = true;

        insert newProduct;
        return newProduct;
    }

    Public Presale_Available_Inventory__c CreatePresaleAvailable() {

        presaleavail = new Presale_Available_Inventory__c();
        presaleavail.Presale_Quantity__c = 6;
        presaleavail.Inventory_Transaction_Id__c = '2342121';
        presaleavail.End_date__c = System.today();
        insert presaleavail;
        return presaleavail;

    }

    Public Product_Restriction_Flag__c CreateProductRestrictionFlagSingle() {
        newProductRestrictionFlag = new Product_Restriction_Flag__c();
        //newProductRestrictionFlag.Name = 'TestProduct';
        newProductRestrictionFlag.Is_Active__c = true;
        newProductRestrictionFlag.Account__c = newAccount.Id;
        newProductRestrictionFlag.Product__c = newProduct.id;
        //newProductRestrictionFlag.Fulfillment_Type__c = 'Manual';
        //newProductRestrictionFlag.Auto_Renewal__c = True;
        //newProductRestrictionFlag.ProductCode='SHOWCASE' ;
        //newProductRestrictionFlag.S_No__c = 2;
        insert newProductRestrictionFlag;
        return newProductRestrictionFlag;
    }

    Public Product_Restriction_Flag__c UpdateProductRestrictionFlagSingle() {
        //newProductRestrictionFlag = new Product_Restriction_Flag__c();
        //newProductRestrictionFlag.Name = 'TestProduct';
        newProductRestrictionFlag.Is_Active__c = false;
        //newProductRestrictionFlag.Account__c = newAccount.Id;
        //newProductRestrictionFlag.Product__c = newProduct.id;
        //newProductRestrictionFlag.Fulfillment_Type__c = 'Manual';
        //newProductRestrictionFlag.Auto_Renewal__c = True;
        //newProductRestrictionFlag.ProductCode='SHOWCASE' ;
        //newProductRestrictionFlag.S_No__c = 2;
        update newProductRestrictionFlag;
        return newProductRestrictionFlag;
    }
    Public void DeleteProductRestrictionFlagSingle() {
        //newProductRestrictionFlag = new Product_Restriction_Flag__c();
        //newProductRestrictionFlag.Name = 'TestProduct';
        newProductRestrictionFlag.Is_Active__c = true;
        //newProductRestrictionFlag.Account__c = newAccount.Id;
        //newProductRestrictionFlag.Product__c = newProduct.id;
        //newProductRestrictionFlag.Fulfillment_Type__c = 'Manual';
        //newProductRestrictionFlag.Auto_Renewal__c = True;
        //newProductRestrictionFlag.ProductCode='SHOWCASE' ;
        //newProductRestrictionFlag.S_No__c = 2;
        delete newProductRestrictionFlag;
        //return newProductRestrictionFlag;
    }

    Public Asset CreateFullfilledAssetSingle() {
        assets = new Asset();
        assets.Name = 'test';
        assets.Renewal_Status__c = 'Renew';
        assets.Auto_Renewal__c = 'No';
        assets.Asset_Type__c = 'Parent';
        assets.AccountId = newAccount.id;
        //assets.ContactId = CreateContactSingle().id;
        assets.Product2Id = newProduct.id;
        assets.Fulfillment_Status__c = 'Fulfilled';
        assets.Renewal_Start_Date__c = system.today();
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
        //assets.Order_Line_Item__c = CreateOrderItemSingle().id;
        insert assets;
        return assets;
    }

    Public Asset CreateFulfilltoFullfilledAssetSingle() {
        fulfillassets = new Asset();
        fulfillassets.Name = 'test';
        fulfillassets.Renewal_Status__c = 'Renew';
        fulfillassets.Auto_Renewal__c = 'No';
        fulfillassets.Asset_Type__c = 'Fulfill To';
        fulfillassets.AccountId = newAccount.id;
        fulfillassets.parent_asset__c = assets.id;
        fulfillassets.Ultimate_Parent_Id_Text__c = assets.id;
        //assets.ContactId = CreateContactSingle().id;
        fulfillassets.Product2Id = newProduct.id;
        fulfillassets.Fulfillment_Status__c = 'Fulfilled';
        fulfillassets.Renewal_Start_Date__c = system.today();
        fulfillassets.Status = 'Active';
        fulfillassets.At_Risk__c = false;
        fulfillassets.Quantity = 10;
        fulfillassets.Billing_Period__c = 'Monthly';
        fulfillassets.Start_Date__c = system.today();
        fulfillassets.End_Date__c = system.today().addDays(10);
        //fulfillassets.Asset_Type__c = 'Parent';
        fulfillassets.Auto_Renewal__c  = 'Yes';
        fulfillassets.Line_Type__c = 'renew';
        fulfillassets.Price = 10.00;
        //assets.Order_Line_Item__c = CreateOrderItemSingle().id;
        insert fulfillassets;
        return fulfillassets;
    }

    Public Asset CreateParticipantFulfilltoFullfilledAssetSingle() {
        participantfulfillassets = new Asset();
        participantfulfillassets.Name = 'test';
        participantfulfillassets.Renewal_Status__c = 'Renew';
        participantfulfillassets.Auto_Renewal__c = 'No';
        participantfulfillassets.Asset_Type__c = 'Participant';
        participantfulfillassets.AccountId = newAccount.id;
        participantfulfillassets.parent_asset__c = fulfillassets.id;
        participantfulfillassets.Ultimate_Parent_Id_Text__c = assets.id;
        //assets.ContactId = CreateContactSingle().id;
        participantfulfillassets.Product2Id = newProduct.id;
        participantfulfillassets.Fulfillment_Status__c = 'Fulfilled';
        participantfulfillassets.Renewal_Start_Date__c = system.today();
        participantfulfillassets.Status = 'Active';
        participantfulfillassets.At_Risk__c = false;
        participantfulfillassets.Quantity = 10;
        participantfulfillassets.Billing_Period__c = 'Monthly';
        participantfulfillassets.Start_Date__c = system.today();
        participantfulfillassets.End_Date__c = system.today().addDays(10);
        //participantfulfillassets.Asset_Type__c = 'Parent';
        participantfulfillassets.Auto_Renewal__c  = 'Yes';
        participantfulfillassets.Line_Type__c = 'renew';
        participantfulfillassets.Price = 10.00;
        //assets.Order_Line_Item__c = CreateOrderItemSingle().id;
        insert participantfulfillassets;
        return participantfulfillassets;
    }

    Public Asset CreatefailureFullfilledAssetSingle() {
        //assets = new Asset();
        assets.Asset_Type__c = 'Parent';
        assets.AccountId = newAccount.id;
        //assets.ContactId = CreateContactSingle().id;
        assets.Product2Id = newProduct.id;
        assets.Fulfillment_Status__c = 'Failure';
        assets.Status = 'Active';
        update assets;
        return assets;
    }

    Public Quota__c CreateQuotaSingle() {
        QuotaHandler = new Quota__c();
        QuotaHandler.Target_Amount__c = 10;
        QuotaHandler.User__c = Userinfo.getUserId();
        insert QuotaHandler;
        return QuotaHandler;
    }
    Public Commission__c CreateCommissionSingle() {
        commission1 = new Commission__c();
        commission1.Related_to_Asset__r.Id = CreateFullfilledAssetSingle().id;
        commission1.Related_to_Quota__r.Id = CreateQuotaSingle().id;
        commission1.Product__c = CreateProductSingle().id;
        commission1.Billing_Type__c = CreateFullfilledAssetSingle().id;
        insert commission1;
        return commission1;
    }
    Public Campaign CreateCampaignSingle() {
        Campaigns = new Campaign();
        Campaigns.Name = 'test';
        insert Campaigns;
        return Campaigns;
    }
    Public Campaign_History__c CreateCampaignHistorySingle() {
        Campaignhist = new Campaign_History__c();
        Campaignhist.Account__c = CreateBrokerAccountSingle().id;
        Campaignhist.Contact__c = CreateContactSingle().id;
        Campaignhist.Lead__c = CreateLeadSingle().id;
        Campaignhist.Campaign__c = CreateCampaignSingle().id;
        insert Campaignhist;
        return Campaignhist;
    }
    Public Order CreateOrderSingle() {
        Orders = new Order();
        Orders.AccountId = newAccount.id;
        Orders.Fulfillment_Status__c = 'Pending Fulfilled';
        Orders.Status = 'Created';
        Orders.Type = 'New';
        //Orders.Name = 'Test order';
        Orders.Pricebook2Id = theStandardPriceBookId;
        Orders.EffectiveDate = system.today();
        Orders.Oracle_Quote__c = CreateOracleQuoteSingle().id;
        Orders.tigerLeadProductExists__c = true;
        Orders.TL_Quote_Product_Reference__c  = '';
        Insert Orders;
        Orders.EndDate = system.today().addDays(10);
        return Orders;
    }
    Public Order CreateOrderModifySingle() {
        Orders = new Order();
        Orders.AccountId = newAccount.id;
        Orders.Fulfillment_Status__c = 'Pending Fulfilled';
        Orders.Status = 'Created';
        Orders.Type = 'Modify';
        //Orders.Name = 'Test order';
        Orders.Pricebook2Id = theStandardPriceBookId;
        Orders.EffectiveDate = system.today();
        Orders.Oracle_Quote__c = CreateOracleQuoteSingle().id;
        Orders.tigerLeadProductExists__c = true;
        Orders.TL_Quote_Product_Reference__c  = '';
        Insert Orders;
        Orders.EndDate = system.today().addDays(10);
        return Orders;
    }
    Public Order CreateOrderNoQuoteSingle() {
        Orders = new Order();
        Orders.AccountId = newAccount.id;
        Orders.Fulfillment_Status__c = 'Pending Fulfillment';
        Orders.Status = 'Created';
        Orders.Type = 'New';
        //Orders.Name = 'Test order';
        Orders.Pricebook2Id = theStandardPriceBookId;
        Orders.EffectiveDate = system.today();
        //Orders.Oracle_Quote__c = CreateOracleQuoteSingle().id;
        Orders.EndDate = system.today().addDays(100);
        Insert Orders;
        return Orders;
    }

    Public OrderItem CreateOrderItemSingle() {
        OrderItems = new OrderItem();
        OrderItems.UnitPrice = 789.62;
        OrderItems.Quantity = 6;
        //OrderItems.Asset__c = CreateFullfilledAssetSingle().id;
        OrderItems.OrderId = Orders.id;
        OrderItems.Auto_Renewal__c = 'Yes';
        OrderItems.Line_Type__c = 'Add';
        OrderItems.Fulfillment_Status__c = 'Pending Fulfillment';
        OrderItems.PricebookEntryId = thePricebookEntrie.id;
        OrderItems.Asset_Structure__c = '{ "parent": [ {"Type": "Add", "SoldToaccountId": "' + newAccount.Id + '", "assetId": "", "HLC": "0", "HLCOverride": "0", "fulfillTo" : [ { "Type": "Add", "assetId": "", "FulfillToaccountId": "' + newRealtorOfficeAccount.id + '", "participant" : [ { "Type": "Add", "participantaccountId": "' + newRealtorAgentAccount.id + '", "assetId": "", "MLSSETID": "a22Z000000FhXdwIAF", "HLC": "0.0" } ] } ] } ] }';
        OrderItems.Market__c = '345354';
        //OrderItems.Start_Date__c = system.today();
        OrderItems.End_Date__c = system.today();
        Insert OrderItems;
        return OrderItems;
    }
    Public OrderItem CreateOrderModifyItemSingle() {
        OrderItems = new OrderItem();
        OrderItems.UnitPrice = 789.62;
        OrderItems.Quantity = 6;
        //OrderItems.Asset__c = CreateFullfilledAssetSingle().id;
        OrderItems.OrderId = Orders.id;
        OrderItems.Auto_Renewal__c = 'Yes';
        OrderItems.Line_Type__c = 'Add';
        OrderItems.Fulfillment_Status__c = 'Pending Fulfillment';
        OrderItems.PricebookEntryId = thePricebookEntrie.id;
        //OrderItems.Asset_Structure__c = '{ "parent": [ {"Type": "Add", "SoldToaccountId": "' + newAccount.Id + '", "assetId": "", "HLC": "0", "HLCOverride": "0", "fulfillTo" : [ { "Type": "Add", "assetId": "", "FulfillToaccountId": "' + newRealtorOfficeAccount.id + '", "participant" : [ { "Type": "Add", "participantaccountId": "' + newRealtorAgentAccount.id + '", "assetId": "", "MLSSETID": "a22Z000000FhXdwIAF", "HLC": "0.0" } ] } ] } ] }';
        OrderItems.Market__c = '345354';
        //OrderItems.Start_Date__c = system.today();
        OrderItems.End_Date__c = system.today();
        Insert OrderItems;
        return OrderItems;
    }
    Public OrderItem CreateOrderItemRemoveSingle() {
        OrderItems = new OrderItem();
        OrderItems.UnitPrice = 789.62;
        OrderItems.Quantity = 6;
        //OrderItems.Asset__c = CreateFullfilledAssetSingle().id;
        OrderItems.OrderId = Orders.id;
        OrderItems.Auto_Renewal__c = 'Yes';
        OrderItems.Line_Type__c = 'Cancel';
        OrderItems.Fulfillment_Status__c = 'Pending Fulfillment';
        OrderItems.PricebookEntryId = thePricebookEntrie.id;
        OrderItems.Asset_Structure__c = '{ "parent": [ {"Type": "Remove", "SoldToaccountId": "' + newAccount.Id + '", "assetId": "' + assets.id + '", "HLC": "0", "HLCOverride": "0", "fulfillTo" : [ { "Type": "Remove", "assetId": "' + fulfillassets.id + '", "FulfillToaccountId": "' + newRealtorOfficeAccount.id + '", "participant" : [ { "Type": "Remove", "participantaccountId": "' + newRealtorAgentAccount.id + '", "assetId": "' + participantfulfillassets.id + '", "MLSSETID": "a22Z000000FhXdwIAF", "HLC": "0.0" } ] } ] } ] }';
        OrderItems.Market__c = '345354';
        Insert OrderItems;
        return OrderItems;
    }
    Public OrderItem CreateOrderItemNoQuoteSingle() {
        OrderItems = new OrderItem();
        OrderItems.UnitPrice = 789.62;
        OrderItems.Market__c = '345354';
        OrderItems.Quantity = 6;
        OrderItems.ServiceDate = System.Today();
        OrderItems.EndDate = System.Today().AddDays(40);
        //OrderItems.Asset__c = CreateFullfilledAssetSingle().id;
        OrderItems.OrderId = Orders.id;
        OrderItems.Line_Type__c = 'Add';
        OrderItems.Auto_Renewal__c = 'Yes';
        OrderItems.Product_Type__c = 'Showcase';
        OrderItems.Fulfillment_Status__c = 'Pending Fulfillment';
        OrderItems.PricebookEntryId = thePricebookEntrie.id;
        OrderItems.Asset_Structure__c = '{ "parent": [ {"Type": "Add", "SoldToaccountId": "' + newAccount.Id + '", "assetId": "", "HLC": "0", "HLCOverride": "0", "fulfillTo" : [ { "Type": "Add", "assetId": "", "FulfillToaccountId": "' + newRealtorOfficeAccount.id + '", "participant" : [ { "Type": "Add", "participantaccountId": "' + newRealtorAgentAccount.id + '", "assetId": "", "MLSSETID": "a22Z000000FhXdwIAF", "HLC": "0.0" } ] } ] } ] }';
        System.debug('Order Item ' + OrderItems);
        Insert OrderItems;
        return OrderItems;
    }

    Public OrderItem CreateOrderItemRenewSingle() {
        OrderItems = new OrderItem();
        OrderItems.UnitPrice = 789.62;
        OrderItems.Market__c = '345354';
        OrderItems.Quantity = 6;
        OrderItems.ServiceDate = System.Today();
        OrderItems.EndDate = System.Today().AddDays(40);
        //OrderItems.Asset__c = CreateFullfilledAssetSingle().id;
        OrderItems.OrderId = Orders.id;
        OrderItems.Line_Type__c = 'Renew';
        OrderItems.Auto_Renewal__c = 'Yes';
        OrderItems.Product_Type__c = 'Showcase';
        OrderItems.Fulfillment_Status__c = 'Pending Fulfillment';
        OrderItems.PricebookEntryId = thePricebookEntrie.id;
        OrderItems.Asset_Structure__c = '{ "parent": [ {"Type": "Add", "SoldToaccountId": "' + newAccount.Id + '", "assetId": "", "HLC": "0", "HLCOverride": "0", "fulfillTo" : [ { "Type": "Add", "assetId": "", "FulfillToaccountId": "' + newRealtorOfficeAccount.id + '", "participant" : [ { "Type": "Add", "participantaccountId": "' + newRealtorAgentAccount.id + '", "assetId": "", "MLSSETID": "a22Z000000FhXdwIAF", "HLC": "0.0" } ] } ] } ] }';
        System.debug('Order Item ' + OrderItems);
        Insert OrderItems;
        return OrderItems;
    }
    
    Public Order UpdateOrderNoQuoteSingle() {
        //Orders = new Order();
        Orders.Is_OLI_Creation_Complete__c = true;
        Update Orders;
        return Orders;
    }

    Public PricebookEntry CreatePricebookEntrySingle() {
        thePricebookEntrie = new PricebookEntry();
        thePricebookEntrie.Pricebook2Id = theStandardPriceBookId;
        thePricebookEntrie.Product2Id = newProduct.id;
        thePricebookEntrie.UnitPrice = 1000;
        thePricebookEntrie.IsActive = true;
        Insert thePricebookEntrie;
        return thePricebookEntrie;
    }
    Public PricebookEntry CreatePricebookEntryManualSingle() {
        thePricebookEntrie = new PricebookEntry();
        thePricebookEntrie.Pricebook2Id = theStandardPriceBookId;
        thePricebookEntrie.Product2Id = newProductManual.id;
        thePricebookEntrie.UnitPrice = 1000;
        thePricebookEntrie.IsActive = true;
        Insert thePricebookEntrie;
        return thePricebookEntrie;
    }
    Public BigMachines__Quote__c CreateOracleQuoteSingle() {
        OracleQuote = new BigMachines__Quote__c();
        OracleQuote.BigMachines_authorization_status__c = 'Success';
        OracleQuote.BigMachines_authorization_amount__c = 10.00;
        OracleQuote.BigMachines_first_month_payment__c = 30.00;
        OracleQuote.BigMachines__Account__c = newAccount.id;
        OracleQuote.BigMachines__Opportunity__c = theOpportunity.id;
        OracleQuote.BigMachines__Is_Primary__c = true;
        OracleQuote.BigMachines_Quote_Type__c = 'New';
        OracleQuote.BigMachines__Status__c = 'In Progress';
        OracleQuote.tigerLeadProductExists__c = true;
        
        //OracleQuote.BigMachines__Status__c = 'Document Expired';
        insert OracleQuote;
        return OracleQuote;
    }

    Public BigMachines__Quote__c UpdateOracleQuoteSingle() {

        OracleQuote.BigMachines__Status__c = 'Approved';
        update OracleQuote;
        return OracleQuote;
    }

    Public BigMachines__Quote_Product__c CreateQuoteProductSingle() {
        QuoteProduct = new BigMachines__Quote_Product__c();
        QuoteProduct.BigMachines__Quote__c = OracleQuote.id;
        QuoteProduct.BigMachines__Sales_Price__c = 10.00;
        QuoteProduct.BigMachines__Quantity__c = 10;
        QuoteProduct.Need_Manual_Renew__c = false;
        QuoteProduct.BigMachines__Description__c = 'test';
        QuoteProduct.BigMachines__Product__c = newProduct.id;
        QuoteProduct.Line_Type__c = 'Add';
        QuoteProduct.Inventory_Transaction_Id__c = '877349535';
        QuoteProduct.Market_Tier__c = '100';
        QuoteProduct.Available_Presale_Inventory__c = '1@@12/5/2016 12:00:00 AM +00:00@@279635';
        QuoteProduct.Commerce_Group__c = 'test';

        insert QuoteProduct;
        return QuoteProduct;
    }

    Public BigMachines__Quote_Product__c CreateQuoteProductSingleManual() {
        QuoteProductManual = new BigMachines__Quote_Product__c();
        QuoteProductManual.BigMachines__Quote__c = OracleQuote.id;
        QuoteProductManual.BigMachines__Sales_Price__c = 10.00;
        QuoteProductManual.BigMachines__Quantity__c = 10;
        QuoteProductManual.Need_Manual_Renew__c = false;
        QuoteProductManual.BigMachines__Description__c = 'test';
        QuoteProductManual.BigMachines__Product__c = newProductManual.id;
        QuoteProductManual.Line_Type__c = 'Add';
        QuoteProductManual.Market_Tier__c = '100';
        QuoteProduct.Inventory_Transaction_Id__c = '877349538';
        QuoteProductManual.Available_Presale_Inventory__c = '1@@12/5/2016 12:00:00 AM +00:00@@279635';
        QuoteProductManual.Commerce_Group__c = 'test';

        insert QuoteProductManual;
        return QuoteProductManual;
    }

    Public List<BigMachines__Quote_Product__c> CreateQuoteProductSingleAndManual() {
        List<BigMachines__Quote_Product__c> lstQouteProduct = new List<BigMachines__Quote_Product__c>();
        QuoteProduct = new BigMachines__Quote_Product__c();
        QuoteProduct.BigMachines__Quote__c = OracleQuote.id;
        QuoteProduct.BigMachines__Sales_Price__c = 10.00;
        QuoteProduct.BigMachines__Quantity__c = 10;
        QuoteProduct.Need_Manual_Renew__c = false;
        QuoteProduct.BigMachines__Description__c = 'test';
        QuoteProduct.BigMachines__Product__c = newProduct.id;
        QuoteProduct.Line_Type__c = 'Add';
        QuoteProduct.Commerce_Group__c = 'test';
        QuoteProduct.Market_Tier__c = '100';
       //QuoteProduct.Available_Presale_Inventory__c = '1@@12/5/2016 12:00:00 AM +00:00@@279635';
        lstQouteProduct.add(QuoteProduct);
        //insert QuoteProduct;

        QuoteProductManual = new BigMachines__Quote_Product__c();
        QuoteProductManual.BigMachines__Quote__c = OracleQuote.id;
        QuoteProductManual.BigMachines__Sales_Price__c = 10.00;
        QuoteProductManual.BigMachines__Quantity__c = 10;
        QuoteProductManual.Need_Manual_Renew__c = false;
        QuoteProductManual.BigMachines__Description__c = 'test';
        QuoteProductManual.BigMachines__Product__c = newProductManual.id;
        QuoteProductManual.Line_Type__c = 'Add';
        QuoteProductManual.Commerce_Group__c = 'test';
        QuoteProductManual.Market_Tier__c = '100';
        //QuoteProductManual.Available_Presale_Inventory__c = '1@@12/5/2016 12:00:00 AM +00:00@@279635';
        lstQouteProduct.add(QuoteProductManual);
        //insert QuoteProductManual;
        insert lstQouteProduct;
        return lstQouteProduct;
    }


    Public List<BigMachines__Quote_Product__c> CreateQuoteProductSingleAndManual2() {
        List<BigMachines__Quote_Product__c> lstQouteProduct = new List<BigMachines__Quote_Product__c>();
        QuoteProduct = new BigMachines__Quote_Product__c();
        QuoteProduct.BigMachines__Quote__c = OracleQuote.id;
        QuoteProduct.BigMachines__Sales_Price__c = 10.00;
        QuoteProduct.BigMachines__Quantity__c = 10;
        QuoteProduct.Need_Manual_Renew__c = false;
        QuoteProduct.BigMachines__Description__c = 'test';
        QuoteProduct.BigMachines__Product__c = newProduct.id;
        QuoteProduct.Line_Type__c = 'Add';
        QuoteProduct.Commerce_Group__c = 'Agent Marketing Solution';
        QuoteProduct.Market_Tier__c = '100';
        QuoteProduct.Available_Presale_Inventory__c = '1@@12/5/2016 12:00:00 AM +00:00@@279635';
        lstQouteProduct.add(QuoteProduct);
        //insert QuoteProduct;

        QuoteProductManual = new BigMachines__Quote_Product__c();
        QuoteProductManual.BigMachines__Quote__c = OracleQuote.id;
        QuoteProductManual.BigMachines__Sales_Price__c = 10.00;
        QuoteProductManual.BigMachines__Quantity__c = 10;
        QuoteProductManual.Need_Manual_Renew__c = false;
        QuoteProductManual.BigMachines__Description__c = 'test';
        QuoteProductManual.BigMachines__Product__c = newProductManual.id;
        QuoteProductManual.Line_Type__c = 'Add';
        QuoteProductManual.Commerce_Group__c = 'test';
        QuoteProductManual.Market_Tier__c = '100';
        QuoteProductManual.Available_Presale_Inventory__c = '1@@12/5/2016 12:00:00 AM +00:00@@279635';
        lstQouteProduct.add(QuoteProductManual);
        //insert QuoteProductManual;
        insert lstQouteProduct;
        return lstQouteProduct;
    }

    Public BigMachines__Quote_Product__c CreateQuoteProductPresaleSingle() {
        QuoteProductPreSale = new BigMachines__Quote_Product__c();
        QuoteProductPreSale.BigMachines__Quote__c = OracleQuote.id;
        QuoteProductPreSale.BigMachines__Sales_Price__c = 10.00;
        QuoteProductPreSale.BigMachines__Quantity__c = 10;
        QuoteProductPreSale.Need_Manual_Renew__c = false;
        QuoteProductPreSale.BigMachines__Description__c = 'test';
        QuoteProductPreSale.BigMachines__Product__c = newProductManual.id;
        QuoteProductPreSale.Line_Type__c = 'Add';
        QuoteProductPreSale.Market_Tier__c = '100';
        QuoteProductPreSale.Available_Presale_Inventory__c = '1@@12/5/2016 12:00:00 AM +00:00@@279635';
        QuoteProductPreSale.Commerce_Group__c = 'test';
        

        insert QuoteProductPreSale;
        return QuoteProductPreSale;
    }

    Public Tiger_Lead_Products__c CreateTigerLeadSingle() {
        TigerLead = new Tiger_Lead_Products__c ();
        TigerLead.Name = 'TigerLeads';
        TigerLead.Tiger_Lead_Product_List__c = 'HOMESRCH';
        TigerLead.TigerLeadActivities__c = 'test activity';
        // Tiger.Territory_Name__c = 'NY';
        insert TigerLead;
        return TigerLead;
    }

    public Tiger_Lead_Products__c CreateTigerLeadSingle2() {
        TigerLead = new Tiger_Lead_Products__c ();
        TigerLead.Name = 'Tiger Leads';
        TigerLead.Tiger_Lead_Product_List__c = 'HOMESRCH';
        TigerLead.TigerLeadActivities__c = 'test activity';
        // Tiger.Territory_Name__c = 'NY';
        insert TigerLead;
        return TigerLead;
    }

    Public Case CreateCaseSingle() {
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case;
        Map<String, Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        Id rtId = CaseRecordTypeInfo.get('Standard').getRecordTypeId();

        CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
        insert setting;

    Cse = new case ();
        //testCase.recordTypeId = rtId;
        Cse.Status = 'New';
        Cse.Origin = 'Phone';
        Cse.AccountId = newAccount.Id;
        Cse.Is_Pre_Welcome_Call__c = true;
        Cse.Subject = 'Complete Cancel Request';
        //Cse.Is_Tiger_Lead__c = true;
        //testcase.Ownership_Type__c='User';
        //testCase.ownerId = u.id;
        Insert Cse;
        return Cse;
    }
    Public Case CreateCaseSingle2() {
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case;
        Map<String, Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        Id rtId = CaseRecordTypeInfo.get('Standard').getRecordTypeId();

        CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
        insert setting;

    Cse = new case ();
        //testCase.recordTypeId = rtId;
        Cse.Status = 'New';
        Cse.Origin = 'Phone';
        Cse.AccountId = newAccount.Id;
     
        //Cse.Is_Tiger_Lead__c = true;
        //testcase.Ownership_Type__c='User';
        //testCase.ownerId = u.id;
        Insert Cse;
        return Cse;
    }
    /*
     Public Tiger_Lead_Product_List__c CreateLeadProductSingle(){
         LeadProduct = new Tiger_Lead_Product_List__c();
         LeadProduct.Name = 'test product';
         TigerLeads.Tiger_Lead_Product_List__c = 'HANDRAISER';
         TigerLeads.TigerLeadActivities__c = 'Domain Setup';
         insert LeadProduct;
         return LeadProduct;
     }
     
     Public TigerLeadActivities__c CreateLeadActivitySingle(){
         w = new Waitlist__c();
         w.Account__c = newAccount.id;
         w.Pre_Auth_Contact__c = myContact.id;
         w.Status__c = 'Created';
         w.Pre_Auth_Email__c = 'aj@gmail.com';
         insert w;
         return w;
     }
     Public Waitlist_Item__c CreateWaitlistItemSingle(){
         wt = new Waitlist_Item__c();
         wt.Waitlist__c = w.id;
         wt.Original_Max_Spend__c = 2000;
         wt.Status__c = 'Fulfilled';
         wt.Market__c = 'test';
         wt.Waitlist_ID__c = 'wwwww';
         wt.Lead_Routing__c = 'Fast';
         wt.Product__c = newProduct.id;
         wt.Account__c = newAccount.id;
         wt.Rank__c = 0;
         wt.Market_Type__c = 'Postal Code';
         wt.Waitlist_Expiration_Date__c = date.today();
         wt.Product_Size__c = 'Full';
         insert wt;
         return wt;
     }
     public Account_Relationship__c CreateAccountRelationshipSingle(){
         LeadActivity = new TigerLeadActivities__c ();
         primarycntct.Child_Account__c = newAccount.id;
         primarycntct .Contact_To__c = myContact.id;
         primarycntct.Contact_Role__c = 'Primary Contact';
         primarycntct.Entity_Name__c = 'abc';
         primarycntct.Is_Parent_Primary__c = true;
         primarycntct.Parent_Account__c = newAccount.id;
         LeadActivity.Name = 'tets activity';
         primarycntct.Relationship_Type__c = 'Member';
         primarycntct.Zuora_Bill_to_Contact_ID__c = 'test';
         primarycntct.Zuora_Ship_to_Contact_ID__c = 'testing';
         primarycntct.Zuora_Sync__c = true;
         insert LeadActivity;
         return LeadActivity;
     } */
}