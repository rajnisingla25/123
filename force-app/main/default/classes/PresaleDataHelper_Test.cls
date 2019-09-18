@isTest
public  class PresaleDataHelper_Test{
   
    
    static testmethod void movetestdata(){
        
         MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass(); 
        
          account     testAcc       = mtduc.newaccount;
          account     testBroker    = mtduc.newBrokerAccount;
          account     testRealtor   = mtduc.newRealtorOfficeAccount;  
          Account    testRealAgent = mtduc.newRealtorAgentAccount; 
          Product_Restriction_Flag__c prod = mtduc.newProductRestrictionFlag;
          Account_Relationship__c     accRelation = mtduc.primarycntct;
          Contact        contact   = mtduc.myContact;
          opportunity    testOppor = mtduc.theOpportunity;
          lead           testLead  = mtduc.led;
          Asset          testAssest = mtduc.assets;
        Product2  testProd          = mtduc.newProduct;
        Commission__c testComm      = mtduc.Commission1;
        Contract TestContract = mtduc.myContract; 
        
    
        PricebookEntry  testPbc = mtduc.thePricebookEntrie;
        Order  testOrder = mtduc.Orders;
        OrderItem  testOrderItem = mtduc.OrderItems;
        BigMachines__Quote__c  testBMQ = mtduc.OracleQuote;
        BigMachines__Quote_Product__c  testBMQP = mtduc.QuoteProduct;
    
        Order_Product_And_Parent_Asset_Fields__c  testOPPAF = mtduc.oppaf; 

        
        account mtdAccount       = mtduc.CreateBrokerAccountSingle();
        account mtdrelAccount    = mtduc.CreateRealtorOfficeAccountSingle();
        account mtdRelAgent      = mtduc.CreateRealtorAgentAccountSingle();
        contact mtdContact = mtduc.CreateContactSingle();
        Opportunity OppSingle = mtduc.CreateOppurtunitySingle();
        contract mtdContract     = mtduc.CreateContractSingle();
  
  test.startTest();
        account_relationship__c  mtdBrokAccount  = mtduc.CreateBrockerOfficeAccountRelationshipSingle();
        account_relationship__c  mtdRealAccount  = mtduc.CreateRealtorAgentAccountRelationshipSingle();
        product2   testMtduProd        =   mtduc.CreateProductSingle();
        Product_Restriction_Flag__c testProdRestriction = mtduc.CreateProductRestrictionFlagSingle();
        Product_Restriction_Flag__c testUpdateProductRestriction = mtduc.UpdateProductRestrictionFlagSingle();
        Asset testAssetSingle = mtduc.CreateFullfilledAssetSingle();
        Quota__c testQuotaSingle = mtduc.CreateQuotaSingle();
   
         Order testOrderSingle = mtduc.CreateOrderSingle();
       Order testOrderNoQuote = mtduc.CreateOrderNoQuoteSingle();
         //OrderItem testOrderItemQuote = mtduc.CreateOrderItemNoQuoteSingle();
       
         Product2 newProduct         = new Product2();
        newProduct.Name           = 'Test Product';
        newProduct.Commission_Category__c   = 'Normal';    
        newProduct.Normalization_factor__c   = 1.10;
        newProduct.Commission_Category__c   = 'CFCB';
        newProduct.Fulfillment_Type__c     = 'Manual';
        newProduct.Auto_Renewal__c       = True;
        newProduct.ProductCode        ='SHOWCASE' ;
        newProduct.S_No__c           = 2;
        insert newProduct;
       
       BigMachines__Quote__c OracleQuote= new BigMachines__Quote__c();
         OracleQuote.BigMachines__Account__c = mtdAccount.id;
         OracleQuote.BigMachines__Status__c = 'In Progress';
         OracleQuote.BigMachines_Quote_Type__c   = 'Modify';                
        insert OracleQuote; 
        System.debug('**** Quote'+OracleQuote);
      
       List<BigMachines__Quote_Product__c> biglist = new List<BigMachines__Quote_Product__c>();
        BigMachines__Quote_Product__c bquoteAddModify  = new BigMachines__Quote_Product__c();
        bquoteAddModify.BigMachines__Quote__c       = OracleQuote.Id;
        bquoteAddModify.Line_Type__c           = 'Add';
        bquoteAddModify.BigMachines__Product__c     = newProduct.Id;
        bquoteAddModify.BigMachines__Quantity__c     = 1;
        bquoteAddModify.BigMachines__Sales_Price__c   = 10;
        bquoteAddModify.Available_Presale_Inventory__c = '10';  
        biglist.add(bquoteAddModify);
        try{
        insert biglist;
         PresaleDataHelper.splitString(biglist);
        }catch(Exception e){}
       
        test.stopTest();
    }
    
    
    static testmethod void presaleTests(){
        string str = '12 05 2015 12:15 PM';
      datetime d =  PresaleDataHelper.getConvertDateTime(str);
    } 
        
    
}