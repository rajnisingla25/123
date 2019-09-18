@isTest
public class ProductInformationControllerTest {
    
    public static testMethod void method1(){   
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        //Inserting Test Account       
        Account newAccount = TestDataFactory.createAccount('Test Account',null,false);
        newAccount.Primary_Email__c = 'testAccount@move.com';
        newAccount.Party_ID__c = 'PartyId';
        insert newAccount; 
        OrderDecompController.stopCreatingAccount = true;
        Order newOrder = new Order();
        newOrder.accountId = newAccount.id;
        newOrder.status = 'Created';
        newOrder.effectiveDate = Date.NewInstance(2020, 10, 10);
        newOrder.Pricebook2Id = Test.getStandardPriceBookId();
        newOrder.products__c = 'COBROKE1';
        insert newOrder;
        
        Product2 p2 = new Product2();
        p2.Name='test prod';
        p2.s_no__c = 2;
        p2.ProductCode = 'testProd';
        insert p2;
        
        PricebookEntry pe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = p2.Id, UnitPrice = 1);
        
        insert pe;
        
        List<OrderItem> items = new List<OrderItem>();
        
        OrderItem newOrderProduct = new OrderItem();
        newOrderProduct.orderId = newOrder.id;
        newOrderProduct.Commerce_Group__c = 'Agent Marketing Solution';
        newOrderProduct.PricebookEntryId = pe.id;
        newOrderProduct.quantity = 2;
        newOrderProduct.unitPrice = 10;
        newOrderProduct.Total_Net_Price__c = 10;
        newOrderProduct.Total_Net__c = 10;
        items.add(newOrderProduct);
        
        OrderItem newOrderProduct1 = new OrderItem();
        newOrderProduct1.orderId = newOrder.id;
        newOrderProduct1.Commerce_Group__c = 'Broker Marketing Solution';
        newOrderProduct1.PricebookentryId = pe.id;
        newOrderProduct1.quantity = 2;
        newOrderProduct1.unitPrice = 10;
        newOrderProduct1.Total_Net_Price__c = 10;
        newOrderProduct1.Total_Net__c = 10;
        items.add(newOrderProduct1);
        
        OrderItem newOrderProduct3 = new OrderItem();
        newOrderProduct3.orderId = newOrder.id;
        newOrderProduct3.Commerce_Group__c = 'Broker Marketing Solution';
        newOrderProduct3.PricebookentryId = pe.id;
        newOrderProduct3.quantity = 2;
        newOrderProduct3.unitPrice = 10;
        newOrderProduct3.Total_Net_Price__c = 10;
        newOrderProduct3.Total_Net__c = 10;
        items.add(newOrderProduct3);
        
        OrderItem newOrderProduct2 = new OrderItem();
        newOrderProduct2.orderId = newOrder.id;    
        newOrderProduct2.PricebookentryId = pe.id;
        newOrderProduct2.quantity = 3;
        newOrderProduct2.unitPrice = 10;
        items.add(newOrderProduct2);
        
        insert items;
        test.startTest();
        ProductInformationController ctrl = new ProductInformationController();
        ctrl.displayRSModifyTable = false;
        ctrl.setOrdId(newOrder.id);
        ctrl.getOrdId();
        test.stopTest();
        
        
        
    }
}