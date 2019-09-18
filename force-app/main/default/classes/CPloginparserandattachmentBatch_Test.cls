@istest
public class CPloginparserandattachmentBatch_Test {
    
    public static testMethod void main1(){
       
        DisabledTrigger__c Dtrg = new DisabledTrigger__c();
        Dtrg.Name                       = 'Disabled';
        Dtrg.TaskTrigger__c             = 'Test@test.com';
        Dtrg.AssetTrigger__c            = 'Test@test.com';
        insert Dtrg;
        
      //Inserting Test Account
    Account brokerAccount = TestDataFactory.createAccount('Broker Account', null, false);
        brokerAccount.RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('B2B').RecordTypeId;
        brokerAccount.Type = 'Broker';
        brokerAccount.Primary_Email__c = 'brokerAccount@b2b.com';
        insert brokerAccount;   
     
       List<String> theProductNames = new List<String> {
        'Connection(SM) for Co-Brokerage',
        'Digital Ad Package',
        'Market Builder',
        'Top Producer IDX','ADVANTAGE'
      };
      // Inserting Products.
        List<Product2> theTestProducts = new List<Product2>();
        for(String theProductName : theProductNames) {
         if(theProductName=='ADVANTAGE'){ theTestProducts.add(new Product2(
            Name = theProductName,
            S_No__c = 2,
            ProductCode = 'ADVANTAGE'
          ));} else {
          theTestProducts.add(new Product2(
            Name = theProductName,
            S_No__c = 2
           // ProductCode = 'ADVANTAGE'
          ));}
        }
        insert theTestProducts;
        
        System.debug('theTestProducts:');


        // Extracting Standard Price Book ID.
        Id theStandardPriceBookId = Test.getStandardPricebookId();
        
        
        // Inserting Price Book Entries For The Standard Price Book.
        PricebookEntry thePricebookEntrie1 = new PricebookEntry();
             
            thePricebookEntrie1.Pricebook2Id = theStandardPriceBookId;
            thePricebookEntrie1.Product2Id = theTestProducts[4].Id;
            thePricebookEntrie1.UnitPrice = 1000;
            thePricebookEntrie1.IsActive = true;
          
        insert thePricebookEntrie1;
        System.debug('theTestProducts:' + thePricebookEntrie1.id);
        
        
        //inserting quote
        BigMachines__Quote__c bq = new BigMachines__Quote__c();
        bq.name = 'testQuote';
        insert bq;
        
        // Inserting Test Orders.
        //Order theTestOrder = [Select id from Order where Status = 'Complete' limit 1];
        Order theTestOrder = new Order();  
      
        theTestOrder.EffectiveDate = Date.today();
            theTestOrder.Status = 'Created';
            theTestOrder.Type = 'New';
            theTestOrder.cansendemail__c = false;
            theTestOrder.is_BMS__c = true;
           // theTestOrder.Case__c = testCase.Id;
            theTestOrder.AccountId = brokerAccount.Id;
            theTestOrder.Pricebook2Id = theStandardPriceBookId;
            theTestOrder.Is_OLI_Creation_Complete__c = false;
            //theTestOrder.ContractId = c.id;
            theTestOrder.Fulfillment_Status__c ='Fulfilled';
            theTestOrder.Oracle_Quote__c = bq.id;
            theTestOrder.EndDate = date.today().addDays(1);
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
          theOrderItem.Fulfillment_Status__c ='Fulfilled';
          //theOrderItem.Product2Id = thePricebookEntrie1.Product2Id;
      insert theOrderItem;    
      System.debug('theOrderItems:' + theOrderItem.id );
      
        
        List<order> orderdata = New List<order>();
        orderdata.add(theTestOrder);        
        System.debug('theTestOrders:' + theTestOrder.id );
        
         // Inserting Test Assets.
         
        Asset theTestAsset = new Asset();
        
          theTestAsset.Name = 'The Test Asset';
            theTestAsset.Status = 'Active';
            theTestAsset.AccountId = brokerAccount.Id;
            theTestAsset.At_Risk__c = false;
            theTestAsset.Product2Id = thePricebookEntrie1.Product2Id;
            theTestAsset.Fulfillment_Status__c = 'Fulfilled';
            theTestAsset.Asset_Type__c = 'Parent';
            theTestAsset.Order_Line_Item__c = theOrderItem.Id;
            //theTestAsset.product_code__c = 'ADVANTAGE';
            theTestAsset.Get_CP_Login_Status__c = 'Complete';
            //theTestAsset.Product_Logins__c = '<?xml version="1.0"?><ResultSet xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:yahoo:maps" xsi:schemaLocation="urn:yahoo:maps http://api.local.yahoo.com/MapsService/V1/GeocodeResponse.xsd"><Result precision="address"><Latitude>37.416397</Latitude><Longitude>-122.025055</Longitude><Address>701 1st Ave</Address><City>Sunnyvale</City><State>CA</State><Zip>94089-1019</Zip><Country>US</Country></Result></ResultSet>';
           theTestAsset.Product_Logins__c = '<CPLoginInfoResponse xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://schemas.datacontract.org/2004/07/FulfillmentServiceEntities"> <AccountType>Broker</AccountType> <BOPCode>6103</BOPCode> <CDHOrgPartyID>257542</CDHOrgPartyID> <CPLoginList> <CPLoginInfo> <AccountType>O</AccountType> <AssetID i:nil="true"/> <CustID>93065</CustID> <MlsID>117</MlsID> <MlsName>Pueblo</MlsName> <Name>Re/Max Pueblo-Central </Name> <Password/> <SSOEmail/> </CPLoginInfo> </CPLoginList> <CustID>5739</CustID> <ParentAssetID>02iZ0000001Mpn4</ParentAssetID> <ProductPartNumber>SHOWCASE</ProductPartNumber> <RsultStatus> <Message/> <Status>Success</Status> <StatusCode>Success</StatusCode> </RsultStatus> </CPLoginInfoResponse>';            
       insert theTestAsset;
        
        Test.StartTest();  
      // CRM-1932 updated test case      
        theTestOrder.Status = 'Complete';       
       // theTestAsset.End_Date__c = date.today().addDays(1);
       // update theTestAsset;
       Update theTestOrder;
        CPloginparserandattachmentBatch cpbatch = new CPloginparserandattachmentBatch();
        CPloginparserandattachmentBatch.CPDetailsWrapper wrap = New CPloginparserandattachmentBatch.CPDetailsWrapper(theTestOrder.Id,bq.id,'Broker','Cust123','Msid123','AccName','Testing','Test@123','Test@test.com', false); 
         try{    
        Database.executeBatch(cpbatch,200);  
        }catch(Exception e){}
           
         Test.StopTest();  
        }
       
    }