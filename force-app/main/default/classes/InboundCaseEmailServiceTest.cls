// (c) 2015 Appirio, Inc.  
//
// Class Name: InboundCaseEmailServiceTest
// Description: Test Class for InboundCaseEmailService
//
// 29th April 2015    Ravindra Shekhawat   Original (Task # T-382431)
//
@isTest(seeAllData=false)
private class InboundCaseEmailServiceTest {    
//Test Method for main class
   static Account testAccount;
   static Contact testContact;
   static Case theTestCases;
   Static Asset rcmAsset;
   Static Asset rcmAsset1;
   static List<Config_EmailToCase__c> configList;
   static testMethod void testinBoundEmail() {
      
      Switch_EmailMessageTrigger__c Dtrg = new Switch_EmailMessageTrigger__c(Name= 'Disabled');
      insert Dtrg; 
      createTestData();
      String[] toAddresses = new List<String>();
      toAddresses.add('ravindrasingh2411@gmail.com');
      list<case> cs = [select id from case where type='Collections' limit 1];
      Test.startTest();
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        
        // setup the data for the email
        email.subject = 'Create Case';
        email.fromAddress = 'venkata.valluru@move.com';
        email.plainTextBody = 'Test Description For Case';
        email.toAddresses = toAddresses;
  
        // call the email service class and test it with the data in the testMethod
        InboundCaseEmailService inboundCaseService = new InboundCaseEmailService();
        result = inboundCaseService.handleInboundEmail(email, env);
        
        // Assert that Case Creation was unsuccessful as there was no Congig_EmailToCase__C Custom Setting present
        System.assertEquals(result.success,false);  
             
        
        //Create the custom setting
        createCaseEmailConfig();    
        result = inboundCaseService.handleInboundEmail(email, env);      
        //Assert that the case was created
        List<Case> c = [Select ContactId,Id from Case where ContactId =: testContact.Id];
        // Assert that case was inserted usign the Contact Created Above
        System.assertEquals(c.size(),2);
        System.assert(result.success==true);
      
        toAddresses = new List<String>();
        toAddresses.add('ravindrasingh@gmail.com');
      
        // Check For Case With Urgent/ImportantK Keywords in the Subject
        email.subject = 'Create Case Urgent';
        email.fromAddress = 'venkata.valluru@move.com';
        email.plainTextBody = 'Test Description For Case';
        email.toAddresses = toAddresses;
        result = inboundCaseService.handleInboundEmail(email, env);
        //Check For Cases with 
        c = [Select ContactId,Id from Case where Priority ='Urgent'];
        // Assert that a case was created with Urgent Priority
        System.assertEquals(c.size(),1); 
      
        toAddresses = new List<String>();
        // Add An Email Address which is not Authorized for Email To Case
        toAddresses.add('Test@test.com');
        //Check For Validations
        email.subject = '';
        email.plainTextBody='ref:'+cs[0].id;
        email.fromAddress = 'venkata.valluru@move.com';
        email.toAddresses = toAddresses;
        result = inboundCaseService.handleInboundEmail(email, env);
      
        // Assert that Case Was not Created as Validtion will fail becuase of Empty Body and Empty Subject
        System.assertEquals(result.success,true);
      
        email.subject = 'Test Email Which is not Configured';
        email.plainTextBody='Test Body';
        result = inboundCaseService.handleInboundEmail(email, env);
        // Assert that Case Was not Created as Validtion will fail becuase of Empty Body and Empty Subject
        System.assertEquals(result.success,true);

        // added          
        toAddresses = new List<String>();
        // Add An Email Address which is not Authorized for Email To Case
        toAddresses.add('Test@test.com');
        //Check For Validations
        //email.subject = 'ref:'+cs[0].id;
        email.subject = '{"sfu":"'+[Select Alias FROM User WHERE Id =:UserInfo.getUserId()].alias+'","caseid":"'+cs[0].id+'","subject":"test", "from1":[{"display":"1@test.com", "address":"1@test.com", "is_group":"1@test.com"}], "to":[{"display":"1@test.com", "address":"1@test.com", "is_group":"1@test.com"}], "cc":[{"display":"1@test.com", "address":"1@test.com", "is_group":"1@test.com"}], "bcc":[{"display":"1@test.com", "address":"1@test.com", "is_group":"1@test.com"}]}';
        email.plainTextBody='ref:'+cs[0].id;
        email.fromAddress = 'c3tools@realtor.com';
        email.toAddresses = toAddresses;
        result = inboundCaseService.handleInboundEmail(email, env);
       
      
        // added          
        toAddresses = new List<String>();
        // Add An Email Address which is not Authorized for Email To Case
        toAddresses.add('Test@test.com');
        //Check For Validations
        email.subject = 'ref:'+cs[0].id;
        email.plainTextBody='ref:'+cs[0].id;
        email.fromAddress = 'customerresponse@realtor.com';
        email.toAddresses = toAddresses;
        result = inboundCaseService.handleInboundEmail(email, env);
        toAddresses = new List<String>();
        // Add An Email Address which is not Authorized for Email To Case
        toAddresses.add('Test@test.com');
        //Check For Validations
        email.subject = 'ref:'+cs[0].id;
        email.htmlBody = 'ref:'+cs[0].id;
        
        email.fromAddress = 'customerresponse@realtor.com';
        email.toAddresses = toAddresses;
        result = inboundCaseService.handleInboundEmail(email, env);
       
       InboundCaseEmailServiceHandler.fromaddrs temp = new InboundCaseEmailServiceHandler.fromaddrs();
       InboundCaseEmailServiceHandler.toaddrs temp1   = new InboundCaseEmailServiceHandler.toaddrs();
       InboundCaseEmailServiceHandler.ccaddrs  temp2  = new InboundCaseEmailServiceHandler.ccaddrs();
       InboundCaseEmailServiceHandler.bccaddrs temp3 =  new InboundCaseEmailServiceHandler.bccaddrs(); 
          
        email.plainTextBody = 'Add Cake Id below and Reply to this email to complete the Order. \n\n Asset SFDC Id: 02i1h000002EwSuAAK \n Asset Line Type: Add \n Cake Id:1234\n Download IO Document: \n Attached are account/contact details.';
        email.subject = 'Mortgage Add Order- Asset Id: ' + rcmAsset.id;
        email.fromAddress = 'move.com';
        email.toAddresses = toAddresses;
        result = inboundCaseService.handleInboundEmail(email, env);
        
        email.plainTextBody = 'Add Cake Id below and Reply to this email to complete the Order. \n\n Asset SFDC Id: 02i1h000002EwSuAAK \n Asset Line Type: Add \n Cake Id:1234\n Download IO Document: \n Attached are account/contact details.';
        email.subject = 'Mortgage Add Order- Asset Id: ' + rcmAsset1.id;
        email.fromAddress = 'move.com';
        email.toAddresses = toAddresses;
        result = inboundCaseService.handleInboundEmail(email, env);
        
        email.plainTextBody = 'Add Cake Id below and Reply to this email to complete the Order. \n\n Asset SFDC Id: 02i1h000002EwSuAAK \n Asset Line Type: Add \n CakeId:1234\n Download IO Document: \n Attached are account/contact details.';
        email.subject = 'Mortgage Add Order- AssetId: 02i1h000002EwSuAAK';
        email.fromAddress = 'move.com';
        email.toAddresses = toAddresses;
        result = inboundCaseService.handleInboundEmail(email, env);
        
       Test.stopTest();   
   }
   
   /**
   * This method creates the Test Data
   */
   private static void createTestData(){
      OrderDecompController.stopCreatingAccount = true;
     
      //Inserting Customsetting for Account     
      DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');        
      insert Dtrg;
      FromEmailAddresses__c frmadd = new FromEmailAddresses__c(Name='Collections',FromAddress__c='paymentcenter@realtor.com');
      insert frmadd;
      //Inserting Customsetting for Case     
      Switch_CaseTrigger__c casetrg = new Switch_CaseTrigger__c(Set_Overall_Trigger_Off__c= true);        
      insert casetrg;
      //inserting Customsetting for From Address
      FromEmailAddresses__c fromaddress = new FromEmailAddresses__c(name = 'FromEmailAddresses' ,FromAddress__c = 'Test@test.com');
      insert fromaddress;
      testAccount = TestDataFactory.createAccount('TestAccount', null,false);
      testAccount.ShippingStreet = '2537 ROUTE 52 STE 10 # 10';
      testAccount.ShippingCity = 'HOPEWELL JUNCTION'; 
      testAccount.ShippingState = 'NY'; 
      testAccount.ShippingPostalCode = '12533';
      testAccount.Primary_Email__c = 'testEmail@test.com';
      insert testAccount;
      
      testContact = TestDataFactory.createContact('testFirst','testLast',testAccount.Id, true,false);
      testContact.Email = 'venkata.valluru@move.com';
      insert testContact;
      
      MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
      mtduc.CreateBrokerAccountSingle();
      Product2 p = mtduc.CreateProductSingle();
      p.ProductCode = 'RCM';
      update p;
      
      Order o = mtduc.CreateOrderNoQuoteSingle();
      mtduc.CreatePricebookEntrySingle();
      OrderItem oi = new OrderItem(OrderId=o.id,Quantity=1.0,PricebookEntryId=mtduc.thePricebookEntrie.Id,unitPrice=1000,Inventory_Transaction_Id__c = o.Id,Fulfillment_Status__c = 'Pending Fulfillment');
      insert oi;
      rcmAsset = mtduc.CreateFullfilledAssetSingle();
      rcmAsset.Product2Id = p.Id;
      rcmAsset.Order_Line_Item__c=oi.Id;
      rcmAsset.Cake_Id__c='12345';
      update rcmAsset;
      
      rcmAsset1 = mtduc.CreateFullfilledAssetSingle();
      rcmAsset1.Product2Id = p.Id;
      rcmAsset1.Order_Line_Item__c=oi.Id;
      update rcmAsset1;
      
      theTestCases = TestDataFactory.createCase('test','test','test','Test',null,null,false);
      theTestCases.AccountId = testAccount.id;
      theTestCases.ContactId = testContact.id;
      theTestCases.Type = 'Collections';
      insert theTestCases;
      
      Case newCase = TestDataFactory.createCase('test','test','test','Test',null,null,false);
      newCase.AccountId = mtduc.newAccount.id;
      newCase.Type = 'Order';
      newCase.Order__c = o.Id;
      insert newCase;
   }
   
   
   /**
   * This Method Creates the Config_EmailToCase__c custom setting
   */
   private static void createCaseEmailConfig(){
    //Create Custom Setting Config_EmailToCase__c    
      configList = new List<Config_EmailToCase__c>();
      configList.add(new Config_EmailToCase__c(Name='TestConfig',                                                          
                                                               Name__c='TestConfig',
                                                               Priority__c='Medium',
                                                               Case_Type__c='Collections',
                                                               Queue_Name__c='Collections - Open',
                                                               Email_Address__c='ravindrasingh2411@gmail.com'
                                                               ));
      configList.add(new Config_EmailToCase__c(Name='TestConfig1',                                                          
                                                               Name__c='TestConfig1',
                                                               Priority__c='Medium',
                                                               Case_Type__c='Collections',
                                                               Queue_Name__c='Collections - OpenTest',
                                                               Email_Address__c='ravindrasingh@gmail.com'
                                                               ));
                 
      insert configList;
   }
}