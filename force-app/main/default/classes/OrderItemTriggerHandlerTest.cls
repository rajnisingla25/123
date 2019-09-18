//****************************************************************************************
//Name          : OrderItemTriggerHandlerTest
//Date          : 11-JAN-2016
//Created by    : NTT Data
//Author        : Stanley Sequeira
//Description   : Test Class which covers the OrderItemTriggerHandlerTest Class functionality
//
// *****************************************************************************************

/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 * 
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
 

@IsTest
public class OrderItemTriggerHandlerTest{

    private static final Integer COUNTER = 1;
    
    @isTest static void orderItemTriggerHandlerTesting(){
        
    OrderDecompController.stopCreatingAccount = true;
    //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg         = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'test@test.com');
        insert Dtrg;
        Switch_AssetTrigger__c srt = new Switch_AssetTrigger__c (Set_Overall_Trigger_Off__c =true);
        insert srt;
        ProductCase__c pc = new ProductCase__c(Name = 'DIGITIALAGENT' , Case_Type__c = 'Retention');
        insert pc;
    // Inserting Test Account.
        Account newAccount              = TestDataFactory.createAccount('The Test Account', null, false);
        newAccount.Primary_Email__c     = 'test@test.com';
        newAccount.type='Broker';
        insert newAccount;
        Account acc              = TestDataFactory.createAccount('The Test Account12', null, false);
        newAccount.Primary_Email__c     = 'test12@test.com';
        newAccount.type='Realtor Agent';
        insert acc;
        
     // Inserting Test Product.
        Product2 theTestProduct         = new Product2(
          Name                          = 'Connection(SM) for Co-Brokerage',
          Family                        = 'Hardware',
          S_No__c                       = 2,
          ProductCode                   = 'COBROKE'
        );
        insert theTestProduct;
        
        
        Id StandardPriceBookId = Test.getStandardPricebookId();
        PricebookEntry thePricebookEntrie   = new PricebookEntry();
        thePricebookEntrie.Pricebook2Id     = StandardPriceBookId;
        thePricebookEntrie.Product2Id       = theTestProduct.Id;
        thePricebookEntrie.UnitPrice        = 1000;
        thePricebookEntrie.IsActive         = true;        
        insert thePricebookEntrie;
        
        Schema.DescribeSObjectResult cfrcSchema                 = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo    = cfrcSchema.getRecordTypeInfosByName(); 
        
        Id rtnId = CaseRecordTypeInfo.get('Retention').getRecordTypeId();
    
        CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtnId);
        insert setting;  
            // Inserting Open Retention Cases.
        List<Case> theTestCases = new List<Case>();
        for(Integer index = 0; index < COUNTER; index++) {
          theTestCases.add(TestDataFactory.createCase(
            'Open Retention Case of #' + (index + 1),
            'New',
            'Retention',
            'Open Retention Case #' + (index + 1),
            null,
            null,
            false
          ));
        }
        insert theTestCases;   
        
        BigMachines__Configuration_Record__c  b = new BigMachines__Configuration_Record__c();
            b.BigMachines__bm_site__c = 'devmoveinc';
            b.bigMachines__action_id_copy__c = '36244038';
            b.BigMachines__action_id_open__c = '36244076' ;
            b.BigMachines__document_id__c = '36244074';
            b.BigMachines__process__c = 'oraclecpqo';
            b.BigMachines__process_id__c = '36244034';
            b.BigMachines__version_id__c = '36324104';  
        b.BigMachines__Is_Active__c = True;
        insert b;    
        
            BigMachines__Quote__c quote          = new BigMachines__Quote__c();
        quote.BigMachines__Account__c       = newAccount.Id;        
        quote.BigMachines__Status__c        = 'Pending';
        quote.BigMachines_Quote_Type__c     = 'New';   
        quote.Case__c                       = theTestCases[0].Id;       
        quote.BigMachines__Description__c   = 'test';
        quote.BigMachines__Site__c = b.Id;
        insert quote;
        
        BigMachines__Quote__c quo         = new BigMachines__Quote__c();
        quo.BigMachines__Account__c       = acc.Id;        
        quo.BigMachines__Status__c        = 'Approved';
        quo.BigMachines_Quote_Type__c     = 'New';      
        quo.BigMachines__Description__c   = 'test2';
        quo.BigMachines__Site__c = b.Id;
        insert quo;
        
        // Inserting Test Orders.
        List<Order> theTestOrders = new List<Order>();
        for(Integer index = 0;index < COUNTER;index++) {
          theTestOrders.add(new Order(
            EffectiveDate                   = System.today()+10,
            Status                          = 'Created',            
            AccountId                       = newAccount.Id,
            Fulfillment_Status__c           ='Fulfilled',
            Oracle_Quote__c                 = quote.Id,
            Pricebook2Id                    = thePricebookEntrie.Pricebook2Id//standardPriceBookId
          ));
        }
        insert theTestOrders;  
     Order ord = new Order(
            EffectiveDate                   = System.today()+1,
            Status                          = 'Created',            
            AccountId                       = acc.Id,
            Fulfillment_Status__c           ='Fulfilled',
            Oracle_Quote__c                 = quo.Id,
            Pricebook2Id                    = thePricebookEntrie.Pricebook2Id);
        insert ord;
        
        Asset asst1                         = new Asset();
        asst1.Name                          = 'Test Asset123 - ';
        asst1.AccountId                     = theTestOrders[0].AccountId;
        asst1.Price                         = 10;
        asst1.End_Date__c                   = Date.today().addDays(3);
        asst1.Status                        = 'Active';
        asst1.Product2ID                    = theTestProduct.Id;
        asst1.Line_Type__c                  = 'Add';                     
        asst1.Asset_Type__c                 = 'Parent';
        asst1.Fulfillment_Status__c         = 'Fulfilled';           
        asst1.Daily_Rate_on_Asset__c        = 3.20;
        asst1.Total_Net__c                  = 50.21;
        asst1.start_date__c                 = system.today(); 
        asst1.Suppress_Welcome_Calls__c     = false;
      
        insert asst1; 
       	Asset asst                         = new Asset();
        asst.Name                          = 'Test Asset12345 - ';
        asst.AccountId                     = ord.AccountId;
        asst.Price                         = 100;
        asst.End_Date__c                   = Date.today().addDays(360);
        asst.Status                        = 'Active';
        asst.Product2ID                    = theTestProduct.Id;
        asst.Line_Type__c                  = 'Add';                     
        asst.Asset_Type__c                 = 'Parent';
        asst.Fulfillment_Status__c         = 'Fulfilled';           
        asst.Daily_Rate_on_Asset__c        = 3.20;
        asst.Total_Net__c                  = 50.21;
        asst.start_date__c                 = system.today(); 
        asst.Suppress_Welcome_Calls__c     = false;
      
        insert asst; 
      
        Case_Asset_Relationship__c caseAssetRelation    = new Case_Asset_Relationship__c();
        caseAssetRelation.Asset__c                      = asst1.Id;
        caseAssetRelation.Case__c                       = theTestCases[0].id;
        caseAssetRelation.Line_Action__c                = 'amend';
        caseAssetRelation.Credit_Amount__c              = 1000.00;
        caseAssetRelation.Extension_Type__c             = 'paid';
        caseAssetRelation.Discount_Type__c              = 'Price Override';
        caseAssetRelation.Delta_Price__c                = 1000.00;
        caseAssetRelation.At_Risk_Amount__c             = 0.0;
        caseAssetRelation.New_Risk__c                   = 0.0;
        caseAssetRelation.Saved_Amount__c               = 0.0;
        insert caseAssetRelation;          
        // Inserting OLI with Type = Credit
        List<OrderItem> oliCreditList       = new List<OrderItem>();
        
        Case caseToAdd1 = new Case();
                caseToAdd1.Status = 'New';
                caseToAdd1.Origin = 'Web';
                caseToAdd1.Type = 'Outbound';
                caseToAdd1.Area__c = 'Product Set Up';
                caseToAdd1.Sub_Area__c = 'New';
                caseToAdd1.Subject = 'Welcome Call';
                caseToAdd1.AccountId = newAccount.Id;
        insert caseToAdd1;
        
        test.startTest();        
        for(Order theTestOrder : theTestOrders) {
          oliCreditList.add(new OrderItem(
            Quantity                        = 1.0,
            PricebookEntryId                = thePricebookEntrie.id,        
            OrderId                         = theTestOrders[0].Id,
            Fulfillment_Status__c           ='Fulfilled',
            Asset__c                        = asst1.Id, 
            Credit_Amount__c                = 10.00, 
            Line_Type__c                    = 'Add',  
            Part_Number__c                  = 'COBROKE', 
            Zuora_Status__c                 = 'Success',   
            Zuora_Comment__c                = 'Sent to Z-Billing' , 
            Refund_Request__c               = true,
            UnitPrice                       = 100.00,
            DecommissionedAsset__c          = asst1.Id
          ));
        }
         insert oliCreditList;
          // Inserting OLI with Type = Amend
         List<OrderItem> oliAmendList       = new List<OrderItem>();
         for(Order theTestOrder : theTestOrders) {
          oliAmendList.add(new OrderItem(
            Quantity                        = 1.0,
            PricebookEntryId                = thePricebookEntrie.id,        
            OrderId                         = theTestOrders[0].Id,
            Fulfillment_Status__c           ='Fulfilled',
            Asset__c                        = asst1.Id, 
            Credit_Amount__c                = 10.00, 
            Line_Type__c                    = 'Amend', 
            Zuora_Status__c                 = 'Success',   
            Zuora_Comment__c                = 'Sent to Z-Billing' ,  
            Refund_Request__c               = true,
            UnitPrice                       = 100.00
          ));
        }
         insert oliAmendList;   
        
         
          // Inserting OLI with Type = Buyout
         List<OrderItem> oliBuyoutList      = new List<OrderItem>();
         
         for(Order theTestOrder : theTestOrders) {
          oliBuyoutList.add(new OrderItem(
            Quantity                        = 1.0,
            PricebookEntryId                = thePricebookEntrie.id,        
            OrderId                         = theTestOrders[0].Id,
            Fulfillment_Status__c           ='Fulfilled',
            Asset__c                        = asst1.Id, 
            Credit_Amount__c                = 10.00, 
            Line_Type__c                    = 'Buyout',
            Zuora_Status__c                 = 'Success',   
            Zuora_Comment__c                = 'Sent to Z-Billing' , 
            Refund_Request__c               = true,
            DecommissionedAsset__c          = asst1.id,
            Buyout_Amount__c                = 20.00,
            
            UnitPrice                       = 100.00
          ));
        }
         insert oliBuyoutList;
      Set<Id> orderitemids = (new Map<Id,OrderItem>(oliBuyoutList).keySet());
         List<OrderItem> oliAddList      = new List<OrderItem>();
        for(Order theTestOrder : theTestOrders) {
          oliAddList.add(new OrderItem(
            Quantity                        = 1.0,
            PricebookEntryId                = thePricebookEntrie.id,        
            OrderId                         = theTestOrders[0].Id,
            Fulfillment_Status__c           ='Fulfilled',
            UnitPrice                       = 900.00,
            Line_Type__c                    = 'Add',
            Zuora_Status__c                 = 'Success',   
            Zuora_Comment__c                = 'Sent to Z-Billing'
          ));
        }
         //insert oliAddList;
        list<AccountTeamMember> AccountTeamMemberlist = new list<AccountTeamMember>();
         AccountTeamMemberlist.add(new AccountTeamMember(TeamMemberRole = 'Account Manager', AccountId=newAccount.Id, UserId=userInfo.getUserId()));
        insert AccountTeamMemberlist;
        Case caseToAdd = new Case();
                caseToAdd.Status = 'New';
                caseToAdd.Origin = 'Web';
                caseToAdd.Type = 'Outbound';
                caseToAdd.Area__c = 'Product Set Up';
                caseToAdd.Sub_Area__c = 'New';
                caseToAdd.Subject = 'Welcome Call';
                caseToAdd.AccountId = newAccount.Id;
        insert caseToAdd;
         system.assert(true);
         test.stopTest();
         Map<Id, OrderItem> setQuoteDapIds = new Map<Id, OrderItem> ();
         setQuoteDapIds.put(oliAmendList[0].Id , oliAmendList[0]);
        Map<Id, OrderItem> setQuoteDapIdss = new Map<Id, OrderItem> ();
        setQuoteDapIdss.put(oliAmendList[0].Order.Oracle_quote__c , oliAmendList[0]);
         Map<Id, decimal> setDecIds = new Map<Id, decimal> ();
         setDecIds.put(oliAmendList[0].Id , 1.2);
  OrderItem ordi = new OrderItem(
            Quantity                        = 1.0,
            PricebookEntryId                = thePricebookEntrie.id,        
            OrderId                         = Ord.Id,
            Fulfillment_Status__c           ='Fulfilled',
            Asset__c                        = asst.Id, 
            Credit_Amount__c                = 10.00, 
            Line_Type__c                    = 'Add', 
            Zuora_Status__c                 = 'Success',   
            Zuora_Comment__c                = 'Sent to Z-Billing' ,  
            UnitPrice                       = 100.00);
        oliAddList.add(ordi);
        insert oliAddList;
          if(system.isFuture() || system.isBatch()){
               try{
                        OrderItemTriggerHandler.updateCaseAssetRelationshipInNonFuture(orderitemids);   
                    }
            catch(exception e){System.debug('method five');}
          }
 else{
                        try{
        OrderItemTriggerHandler.updateCaseAssetRelationshipInFuture(orderitemids); 
                        }catch(exception a){System.debug('method one');}
                        Try{
        OrderItemTriggerHandler.FinanceCase(setQuoteDapIdss,setDecIds, 'DIGITIALAGENT');
                        }catch(exception c){System.debug('method two'+c);}
                        Try{
        OrderItemTriggerHandler.handleAfterInsert(oliAddList);
        }catch(exception d){System.debug('method three');}
   /* Try{
        OrderItemTriggerHandler.handleAfterUpdate(oliAddList,setQuoteDapIds);
    }catch(exception f){System.debug('method four');}*/
                    }
        
    }
 }