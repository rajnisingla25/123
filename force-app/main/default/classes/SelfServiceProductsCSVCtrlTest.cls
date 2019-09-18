/*****************************************************************************
* Class Name: SelfServiceProductsCSVCtrlTest
* Author: Shraddha Kabade
* Purpose: Test class for SelfServiceProductsCSVController
* JIRA : LCM-435
****************************************************************************/
@isTest
public class SelfServiceProductsCSVCtrlTest {
    
      public static testMethod void CustAccSumPDFPage(){
        
        //Inserting Customsettings 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Suppress_in_Customer_Statements_Settings__c scs = new Suppress_in_Customer_Statements_Settings__c(Name='Customer',Promo_Codes__c='FREERS;FREEC');
        insert scs;
         OrderDecompController.stopCreatingAccount = true;
        //Inserting account
        Account testAccount = TestDataFactory.createAccount('The Test Account', null, false);
        testAccount.Primary_Email__c = 'ssk112233@gmail.com';
        testAccount.Email_Address__c = 'ssk112233@gmail.com';
        testAccount.ShippingState  = 'CA';
        testAccount.ShippingCountry  = 'USA';
        insert testAccount;
        
        Opportunity testopp = new Opportunity(      Name = 'The Opportunity',
                                              StageName = 'Prospecting',
                                              CloseDate = system.today(),
                                              AccountId = testAccount.Id,
                                              Opportunity_Short_Description__c = 'sDesc',
                                              Amount = 0.00);
        
        Account_Listing__c alist = new Account_Listing__c();
        alist.City__c = 'Fremont';
        alist.Account_Name__c = testAccount.Id;
        insert alist;
        
        
        Product2 testProduct = Commissions_TestDataFactory.CreateProduct('COBROKE Prod',false);
        testProduct.ProductCode = 'COBROKE';   
        insert testProduct;
        
        Product2 testProduct1 = Commissions_TestDataFactory.CreateProduct('TOPIDX Prod',false);
        testProduct1.ProductCode = 'TOPIDX';   
        insert testProduct1;
        
        PricebookEntry thePricebookEntrie1 = new PricebookEntry();             
        thePricebookEntrie1.Pricebook2Id = Test.getStandardPricebookId();
        thePricebookEntrie1.Product2Id = testProduct1.Id;
        thePricebookEntrie1.UnitPrice = 1000;
        thePricebookEntrie1.IsActive = true;          
        insert thePricebookEntrie1;
        
        BigMachines__Quote__c quote = new BigMachines__Quote__c();
        quote.BigMachines__Account__c  = testAccount.id;        
        quote.BigMachines__Status__c  = 'Ordered';
        quote.BigMachines_Quote_Type__c  = 'New';
        quote.BigMachines__Site__c = Label.BigMachineSite;
        insert quote;               
        
        
        Order theTestOrder = new Order();        
        theTestOrder.EffectiveDate = Date.today();
        theTestOrder.Status = 'Created';
        theTestOrder.Type = 'New';    
        theTestOrder.Is_BMS__c = true;
        theTestOrder.AccountId = testAccount.Id;
        theTestOrder.opportunityId = testopp.Id;
        theTestOrder.Pricebook2Id = Test.getStandardPricebookId();
        theTestOrder.Fulfillment_Status__c ='Pending Fulfillment';   
        theTestOrder.Oracle_Quote__c   =   quote.Id;  
        theTestOrder.tigerLeadProductExists__c =false ;
        insert theTestOrder;        
        // Inserting Order Line Items.        
        OrderItem theOrderItem = new OrderItem();           
        theOrderItem.Quantity = 1.00;         
        theOrderItem.PricebookEntryId = thePricebookEntrie1.id;
        theOrderItem.OrderId = theTestOrder.Id;
        theOrderItem.UnitPrice = 1000;
        theOrderItem.Start_Date__c = Date.today();
        theOrderItem.Inactivate_Date__c = Date.today();             
        theOrderItem.Line_Type__c  = 'Add';
        theOrderItem.Fulfillment_Status__c ='Pending Fulfillment';          
        insert theOrderItem;  
        
        // Inserting Assets
        List<Asset> assets = new List<Asset>();
        Asset asset1 = new Asset(Order_Line_Item__c = theOrderItem.Id, Product2Id = testProduct.id, Extended_Net_Price__c = 100, Start_date__c = date.today(), End_date__c = date.today(), Name = 'Asset1', Commerce_Group__c = 'Broker Marketing Solution',Asset_Type__c='Parent', status = 'Active',price =250,Fulfillment_Status__c = 'Fulfilled', AccountId = testAccount.ID, Order_type__c='New');
        Asset asset2 = new Asset(Order_Line_Item__c = theOrderItem.Id,  Product2Id = testProduct1.id, Extended_Net_Price__c = 100,Name = 'Asset2', Start_date__c = date.today(), End_date__c = date.today() ,Asset_Type__c='Parent', status = 'Active',price =250,Fulfillment_Status__c = 'Fulfilled', AccountId = testAccount.ID, Order_type__c='Renewal');
        assets.add(asset1);
        assets.add(asset2);
        insert assets;
        
        PageReference pageRef = Page.SelfServiceMyProductsCSV;
        pageRef.getParameters().put('id', String.valueOf(testAccount.ID));
        Test.setCurrentPage(pageRef);
        SelfServiceProductsCSVController testaccCTRL = new SelfServiceProductsCSVController();
    }

}