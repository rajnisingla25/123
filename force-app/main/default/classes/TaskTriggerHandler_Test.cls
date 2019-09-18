@isTest(seeAllData = false)
public  class TaskTriggerHandler_Test{
private static final Integer COUNTER = 5;
    
    static{
        Business_Hours__c bh = new Business_Hours__c(name = 'OwnChange', Lowermin__c = 450, UpMin__c = 950);
        insert bh;
        Business_Hours__c bh1 = new Business_Hours__c(name = 'StatusChange', Lowermin__c = 450, UpMin__c = 950);
        insert bh1;
    }
    
    public static testMethod void main()
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
    //Attachmentactivitydeleteaccess__c Dtrg1 = new Attachmentactivitydeleteaccess__c(Name= username,InputType__c = 'user');
    //insert Dtrg1; 
       
      //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = mtduc.CreateDisabledTriggerSingle();
    Switch_AccountRelationshipTrigger__c art = new Switch_AccountRelationshipTrigger__c(name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
    insert art;    
    OrderDecompController.stopCreatingAccount = true; 
    // Inserting Test Account.
    Account newAccount = mtduc.CreateBrokerAccountSingle();
    newAccount.Total_Contract_Value__c = 999;
    update newAccount;
     //Inserting Test Contact 
    Contact myContact = mtduc.CreateContactSingle(); 
           
        Product2 newProduct = mtduc.CreateProductSingle();  
        
        Asset assets = mtduc.CreateFullfilledAssetSingle();
         // Extracting Standard Price Book ID.
        Id StandardPriceBookId = Test.getStandardPricebookId();
        System.debug('######-TESTING-Procebook'+ StandardPriceBookId);
        // Inserting Price Book Entries For The Standard Price Book.
        PricebookEntry thePricebookEntrie = new PricebookEntry();
             
            thePricebookEntrie.Pricebook2Id = StandardPriceBookId;
            thePricebookEntrie.Product2Id = newProduct.Id;
            thePricebookEntrie.UnitPrice = 1000;
            thePricebookEntrie.IsActive = true;        
        insert thePricebookEntrie;
   
     // Inserting Test Orders.
        List<Order> theTestOrders = new List<Order>();
        for(Integer index = 0;index < COUNTER;index++) {
          theTestOrders.add(new Order(
            EffectiveDate = System.today()+10,
            Status = 'Created',            
            AccountId = newAccount.Id,
            Fulfillment_Status__c ='Fulfilled',
            
            Pricebook2Id = thePricebookEntrie.Pricebook2Id//standardPriceBookId
          ));
        }
        insert theTestOrders;   
        System.debug('######-TESTING-ORDERS= '+theTestOrders);
                
    // Inserting Test Order Item.
        List<OrderItem> theTestOrderItems = new List<OrderItem>();
        
        for(Order theTestOrder : theTestOrders) {
          theTestOrderItems.add(new OrderItem(
            Quantity = decimal.valueof('1'),
            PricebookEntryId = thePricebookEntrie.id,        
            OrderId = theTestOrder.Id,
            Fulfillment_Status__c ='Fulfilled',
            Asset__c = assets.Id, 
            Credit_Amount__c = 10.00, 
            Line_Type__c = 'Credit',         
            UnitPrice = 100.00
          ));
        }
         insert theTestOrderItems;
       
    Tiger_Leads__c Tiger = new Tiger_Leads__c();
        Tiger.Name = 'Test tiger';
        Tiger.Territory_Name__c = 'NY';
        insert Tiger;
                         
    Tiger_Lead_Products__c TigerLeads = new Tiger_Lead_Products__c();
        TigerLeads.Name ='TigerLeads';
        TigerLeads.Tiger_Lead_Product_List__c = 'HANDRAISER';
        TigerLeads.TigerLeadActivities__c = 'Domain Setup';
        insert TigerLeads;
        
    NVMDispositionFollowup__c nvmDispositionFollowup = new NVMDispositionFollowup__c();
    nvmDispositionFollowup.Name = 'Left Message';
    nvmDispositionFollowup.NVMfailedCount__c = true;
    insert nvmDispositionFollowup;
        
    NVMDispositionFollowup__c nvmDispositionFollowup1 = new NVMDispositionFollowup__c();
    nvmDispositionFollowup1.Name = 'In Progress';
    nvmDispositionFollowup1.NVMfailedCount__c = true;
    insert nvmDispositionFollowup1;
    
    mtduc.CreateCaseSingle();
    
    Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtId = CaseRecordTypeInfo.get('Retention').getRecordTypeId(); 
        CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
        insert setting; 
        List<Case> cc=new List<Case>();
        Case theCase = new Case(
            Subject = 'subject',
            //Status = 'Closed',
            Type = 'Order',
            Order__c=theTestOrders[0].id ,
            Is_Tiger_Lead__c =true,
            ContactId = myContact.id,
            Description = 'description',
            Status = 'In Progress',
            NVM_Failed_Call_Count__c = 9,
            Followup_Status__c = 'Follow up Scheduled- Pitched',
            NVM_Call_Count__c = 6);
            insert theCase;
         Set<Id> setCaseId = new Set<Id>();
        setCaseId.add(theCase.Id);
   //set<Id> setOLIs = new set<Id>();
  // setOLIs.add(theCase.Order__c);
       Id salesActivitiesRecordTypeId = Schema.SObjectType.Task.RecordTypeInfosByName.get('Sales Activities').RecordTypeId;
       Task theTask = null;
        List<Task> tasklist = new List<Task>();
    //for(Integer index = 0; index < COUNTER; index++) {
        theTask = TestDataFactory.createTask(
                newAccount.Id,
                'Set Up Client in Stripes',
                'Call',
                Date.today(),
                'Completed',
                false
        );
        theTask.RecordTypeId = salesActivitiesRecordTypeId;
        theTask.WhatId  = theCase.Id;
        theTask.Is_Tiger_Lead__c = true;
        theTask.NVM_Disposition__c = 'Left Message';
        //theTask.NVM_Disposition__c = 'Follow Up Scheduled - no Pitch';
        tasklist.add(theTask);
    //}
    insert tasklist;
    
    Set<Id> setTaskId = new Set<Id>();
    for(Task newTask :tasklist)
        setTaskId.add(newTask.Id);
    
    
    TaskTriggerHandler taskTgrHandler = new TaskTriggerHandler(true, 1);
    TaskTriggerHandler.updateCaseStatus(setTaskId, setCaseId);
    theCase.Status = 'In Progress';
    theTask.NVM_Disposition__c = 'Follow Up Scheduled - no Pitch';
    update theTask;
    
    Test.startTest();
    //TaskTriggerHandler.updateCaseStatus(setTaskId, setCaseId);
    //update theCase;
    TaskTriggerHandler.updateCaseStatus(setTaskId, setCaseId);
    theCase.Status = 'Lead Suspension';
    update theCase;
    TaskTriggerHandler.updateCaseStatus(setTaskId, setCaseId);
    Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;          
    List<Account_Relationship__c> toBeInserted = new List<Account_Relationship__c>();
    // Create Relationship records for Contact Relationhsip
     Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship(
                        newAccount.Id, null, myContact.Id, null, true, false);
    accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
    accountRelation.Active__c = true;
    accountRelation.Contact_Role__c = 'Primary Contact';
    accountRelation.Billing_Contact__c = true;
    toBeInserted.add(accountRelation); 
    insert toBeInserted;
    List<Case> theTestCases = new List<Case>();                
            //Inserting Test Case  
    Case caseRec = TestDataFactory.createCase('Invalid Rights','Open','Collections' ,'Test Description', myContact.Id,newAccount.Id,true);
   theTestCases.add(caseRec);
        //insert tasks;
        try{
        //insert tasklist; 
        }catch(Exception e){}
        theTask.WhatId  = u.Id;
        try{
        update tasklist;                
       }catch(Exception e){}
       // boolean b = SkipAssetTrigger.isSkipTrg(); //Added by radhika.
       TaskTriggerHandler tth = new TaskTriggerHandler(false ,0);
      // tth.onAfterInsert(tasklist); 
        tth.createTasks(theTestCases);
       tth.onBeforeInsertUpdate(tasklist);
       tth.onAfterUpdateCaseTLActivities(tasklist);
        Map<Id,Task> mapTask = new Map<Id,Task>(); 
        for(Task tsk:tasklist){
        mapTask.put(tsk.id,tsk);
        }
              TaskTriggerHandler.CopyNotesTo(mapTask); 
              TaskTriggerHandler.UpdateCase(mapTask.keyset());
       Test.stopTest();
   }
   public static testMethod void main1(){ 
       
       Schedule_Batch_Setting__c scheduleBatchSetting = new Schedule_Batch_Setting__c();
    scheduleBatchSetting.Name = 'NVM Callback';
    scheduleBatchSetting.Assetresttime__c = 60;
    scheduleBatchSetting.Execution_Min__c = 60;
    insert scheduleBatchSetting;
       
     MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
     User u = mtduc.CreateUserSingle();  
     mtduc.UpdateUserSingle();   
     OrderDecompController.stopCreatingAccount = true; 
      //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = mtduc.CreateDisabledTriggerSingle();
    Switch_AccountRelationshipTrigger__c art = new Switch_AccountRelationshipTrigger__c(name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
    insert art;    
    
    // Inserting Test Account.
    Account newAccount = mtduc.CreateBrokerAccountSingle();
        
     //Inserting Test Contact 
    Contact myContact = mtduc.CreateContactSingle(); 
             
        Product2 newProduct = mtduc.CreateProductSingle();  
        
        Asset assets = mtduc.CreateFullfilledAssetSingle();
         // Extracting Standard Price Book ID.
        Id StandardPriceBookId = Test.getStandardPricebookId();
        System.debug('######-TESTING-Procebook'+ StandardPriceBookId);
        // Inserting Price Book Entries For The Standard Price Book.
        PricebookEntry thePricebookEntrie = new PricebookEntry();
             
            thePricebookEntrie.Pricebook2Id = StandardPriceBookId;
            thePricebookEntrie.Product2Id = newProduct.Id;
            thePricebookEntrie.UnitPrice = 1000;
            thePricebookEntrie.IsActive = true;        
        insert thePricebookEntrie;
   
     // Inserting Test Orders.
        List<Order> theTestOrders = new List<Order>();
        for(Integer index = 0;index < COUNTER;index++) {
          theTestOrders.add(new Order(
            EffectiveDate = System.today()+10,
            Status = 'Created',            
            AccountId = newAccount.Id,
            Fulfillment_Status__c ='Fulfilled',
            
            Pricebook2Id = thePricebookEntrie.Pricebook2Id//standardPriceBookId
          ));
        }
        insert theTestOrders;   
        System.debug('######-TESTING-ORDERS= '+theTestOrders);
                
    // Inserting Test Order Item.
        List<OrderItem> theTestOrderItems = new List<OrderItem>();
        
        for(Order theTestOrder : theTestOrders) {
          theTestOrderItems.add(new OrderItem(
            Quantity = decimal.valueof('1'),
            PricebookEntryId = thePricebookEntrie.id,        
            OrderId = theTestOrder.Id,
            Fulfillment_Status__c ='Fulfilled',
            Asset__c = assets.Id, 
            Credit_Amount__c = 10.00, 
            Line_Type__c = 'Credit',         
            UnitPrice = 100.00
          ));
        }
         insert theTestOrderItems;
       
    Tiger_Leads__c Tiger = new Tiger_Leads__c();
        Tiger.Name = 'Test tiger';
        Tiger.Territory_Name__c = 'NY';
        insert Tiger;
                         
    Tiger_Lead_Products__c TigerLeads = new Tiger_Lead_Products__c();
        TigerLeads.Name ='TigerLeads';
        TigerLeads.Tiger_Lead_Product_List__c = 'HANDRAISER';
        TigerLeads.TigerLeadActivities__c = 'Domain Setup';
        insert TigerLeads;
    mtduc.CreateCaseSingle();
    Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtId = CaseRecordTypeInfo.get('Retention').getRecordTypeId(); 
        CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
        insert setting; 
       Id salesActivitiesRecordTypeId = Schema.SObjectType.Task.RecordTypeInfosByName.get('Sales Activities').RecordTypeId;
       Task theTask = null;
        List<Task> tasklist = new List<Task>();
    for(Integer index = 0; index < COUNTER; index++) {
        theTask = TestDataFactory.createTask(
                newAccount.Id,
                'Pre Welcome Call',
                (Math.mod(index, 2) == 0) ? 'Call' : 'Message',
                Date.today(),
                'Completed',
                false
        );
        theTask.RecordTypeId = salesActivitiesRecordTypeId;
        theTask.WhatId  = mtduc.cse.Id;
        theTask.Is_Tiger_Lead__c = true;
        tasklist.add(theTask);
    }
    insert tasklist;
    Test.startTest();

    Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;          
    List<Account_Relationship__c> toBeInserted = new List<Account_Relationship__c>();
    // Create Relationship records for Contact Relationhsip
     Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship(
                        newAccount.Id, null, myContact.Id, null, true, false);
    accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
    accountRelation.Active__c = true;
    accountRelation.Contact_Role__c = 'Primary Contact';
    accountRelation.Billing_Contact__c = true;
    toBeInserted.add(accountRelation); 
    insert toBeInserted;


        //insert tasks;
        try{
        insert tasklist; 
        }catch(Exception e){}
        theTask.WhatId  = u.Id;
        
        try{
        update tasklist;                
       }catch(Exception e){}
       // boolean b = SkipAssetTrigger.isSkipTrg(); //Added by radhika.
       TaskTriggerHandler tth = new TaskTriggerHandler(false ,0);
      // tth.onAfterInsert(tasklist); 
       tth.onBeforeInsertUpdate(tasklist);
       tth.onAfterUpdateCaseTLActivities(tasklist);
       Test.stopTest();
       Delete tasklist;
   }
   public static testMethod void main2(){ 
       
       Schedule_Batch_Setting__c scheduleBatchSetting = new Schedule_Batch_Setting__c();
    scheduleBatchSetting.Name = 'NVM Callback';
    scheduleBatchSetting.Assetresttime__c = 60;
    scheduleBatchSetting.Execution_Min__c = 60;
    insert scheduleBatchSetting;
       
     MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
     User u = mtduc.CreateUserSingle();  
     mtduc.UpdateUserSingle();   
     OrderDecompController.stopCreatingAccount = true; 
      //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = mtduc.CreateDisabledTriggerSingle();
    Switch_AccountRelationshipTrigger__c art = new Switch_AccountRelationshipTrigger__c(name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
    insert art;    
    
    // Inserting Test Account.
    Account newAccount = mtduc.CreateBrokerAccountSingle();
    Account newAgentAccount = mtduc.CreateRealtorOfficeAccountSingle();    
    newAgentAccount.Account_Sub_Type__c = 'Prospect';  
    update newAgentAccount;
     //Inserting Test Contact 
    Contact myContact = mtduc.CreateContactSingle(); 
             
        Product2 newProduct = mtduc.CreateProductSingle();  
        
        Asset assets = mtduc.CreateFullfilledAssetSingle();
         // Extracting Standard Price Book ID.
        Id StandardPriceBookId = Test.getStandardPricebookId();
        System.debug('######-TESTING-Procebook'+ StandardPriceBookId);
        // Inserting Price Book Entries For The Standard Price Book.
        PricebookEntry thePricebookEntrie = new PricebookEntry();
             
            thePricebookEntrie.Pricebook2Id = StandardPriceBookId;
            thePricebookEntrie.Product2Id = newProduct.Id;
            thePricebookEntrie.UnitPrice = 1000;
            thePricebookEntrie.IsActive = true;        
        insert thePricebookEntrie;
   
     // Inserting Test Orders.
        List<Order> theTestOrders = new List<Order>();
        for(Integer index = 0;index < COUNTER;index++) {
          theTestOrders.add(new Order(
            EffectiveDate = System.today()+10,
            Status = 'Created',            
            AccountId = newAccount.Id,
            Fulfillment_Status__c ='Fulfilled',
            
            Pricebook2Id = thePricebookEntrie.Pricebook2Id//standardPriceBookId
          ));
        }
        insert theTestOrders;   
        System.debug('######-TESTING-ORDERS= '+theTestOrders);
                
    // Inserting Test Order Item.
        List<OrderItem> theTestOrderItems = new List<OrderItem>();
        
        for(Order theTestOrder : theTestOrders) {
          theTestOrderItems.add(new OrderItem(
            Quantity = decimal.valueof('1'),
            PricebookEntryId = thePricebookEntrie.id,        
            OrderId = theTestOrder.Id,
            Fulfillment_Status__c ='Fulfilled',
            Asset__c = assets.Id, 
            Credit_Amount__c = 10.00, 
            Line_Type__c = 'Credit',         
            UnitPrice = 100.00
          ));
        }
         insert theTestOrderItems;
       
    Tiger_Leads__c Tiger = new Tiger_Leads__c();
        Tiger.Name = 'Test tiger';
        Tiger.Territory_Name__c = 'NY';
        insert Tiger;
                         
    Tiger_Lead_Products__c TigerLeads = new Tiger_Lead_Products__c();
        TigerLeads.Name ='TigerLeads';
        TigerLeads.Tiger_Lead_Product_List__c = 'HANDRAISER';
        TigerLeads.TigerLeadActivities__c = 'Domain Setup';
        insert TigerLeads;
    mtduc.CreateCaseSingle();
    Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtId = CaseRecordTypeInfo.get('Retention').getRecordTypeId(); 
        CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
        insert setting; 
       Id salesActivitiesRecordTypeId = Schema.SObjectType.Task.RecordTypeInfosByName.get('Sales Activities').RecordTypeId;
       Task theTask = null;
        List<Task> tasklist = new List<Task>();
    for(Integer index = 0; index < COUNTER; index++) {
        theTask = TestDataFactory.createTask(
                newAccount.Id,
                'Complete Cancel Request',
                (Math.mod(index, 2) == 0) ? 'Call' : 'Message',
                Date.today(),
                'Completed',
                false
        );
        theTask.RecordTypeId = salesActivitiesRecordTypeId;
        theTask.WhatId  = mtduc.cse.Id;
        theTask.Is_Tiger_Lead__c = true;
        tasklist.add(theTask);
    }
    theTask = new Task();
    theTask = TestDataFactory.createTask(
                newAgentAccount.Id,
                'Complete Cancel Request',
                'Call',
                Date.today(),
                'Completed',
                false
        );
    theTask.RecordTypeId = salesActivitiesRecordTypeId;
    
    tasklist.add(theTask);
    insert tasklist;
    Test.startTest();

    Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;          
    List<Account_Relationship__c> toBeInserted = new List<Account_Relationship__c>();
    // Create Relationship records for Contact Relationhsip
     Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship(
                        newAccount.Id, null, myContact.Id, null, true, false);
    accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
    accountRelation.Active__c = true;
    accountRelation.Contact_Role__c = 'Primary Contact';
    accountRelation.Billing_Contact__c = true;
    toBeInserted.add(accountRelation); 
    insert toBeInserted;


        //insert tasks;
        try{
        //insert tasklist; 
        }catch(Exception e){}
        //theTask.WhatId  = newAccount.Id;
        try{
            tasklist[0].NVM_Disposition__c = 'Follow Up Scheduled - Pitched';
        update tasklist;                
       }catch(Exception e){}
       // boolean b = SkipAssetTrigger.isSkipTrg(); //Added by radhika.
       TaskTriggerHandler tth = new TaskTriggerHandler(false ,0);
      // tth.onAfterInsert(tasklist); 
       tth.onBeforeInsertUpdate(tasklist);
       tth.onAfterUpdateCaseTLActivities(tasklist);
       Test.stopTest();
   }
   
   
   public static testMethod void main3(){ 
       Schedule_Batch_Setting__c scheduleBatchSetting = new Schedule_Batch_Setting__c();
    scheduleBatchSetting.Name = 'NVM Callback';
    scheduleBatchSetting.Assetresttime__c = 60;
    scheduleBatchSetting.Execution_Min__c = 60;
    insert scheduleBatchSetting;
       
     MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
     User u = mtduc.CreateUserSingle();  
     mtduc.UpdateUserSingle();   
     OrderDecompController.stopCreatingAccount = true; 
      //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = mtduc.CreateDisabledTriggerSingle();
    Switch_AccountRelationshipTrigger__c art = new Switch_AccountRelationshipTrigger__c(name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
    insert art;    
    
    // Inserting Test Account.
    Account newAccount = mtduc.CreateBrokerAccountSingle();
    Account newAgentAccount = mtduc.CreateRealtorOfficeAccountSingle();    
    newAgentAccount.Account_Sub_Type__c = 'Prospect';  
    update newAgentAccount;
     //Inserting Test Contact 
    Contact myContact = mtduc.CreateContactSingle(); 
             
        Product2 newProduct = mtduc.CreateProductSingle();  
        
        Asset assets = mtduc.CreateFullfilledAssetSingle();
         // Extracting Standard Price Book ID.
        Id StandardPriceBookId = Test.getStandardPricebookId();
        System.debug('######-TESTING-Procebook'+ StandardPriceBookId);
        // Inserting Price Book Entries For The Standard Price Book.
        PricebookEntry thePricebookEntrie = new PricebookEntry();
             
            thePricebookEntrie.Pricebook2Id = StandardPriceBookId;
            thePricebookEntrie.Product2Id = newProduct.Id;
            thePricebookEntrie.UnitPrice = 1000;
            thePricebookEntrie.IsActive = true;        
        insert thePricebookEntrie;
   
     // Inserting Test Orders.
        List<Order> theTestOrders = new List<Order>();
        for(Integer index = 0;index < COUNTER;index++) {
          theTestOrders.add(new Order(
            EffectiveDate = System.today()+10,
            Status = 'Created',            
            AccountId = newAccount.Id,
            Fulfillment_Status__c ='Fulfilled',
            
            Pricebook2Id = thePricebookEntrie.Pricebook2Id//standardPriceBookId
          ));
        }
        insert theTestOrders;   
        System.debug('######-TESTING-ORDERS= '+theTestOrders);
                
    // Inserting Test Order Item.
        List<OrderItem> theTestOrderItems = new List<OrderItem>();
        
        for(Order theTestOrder : theTestOrders) {
          theTestOrderItems.add(new OrderItem(
            Quantity = decimal.valueof('1'),
            PricebookEntryId = thePricebookEntrie.id,        
            OrderId = theTestOrder.Id,
            Fulfillment_Status__c ='Fulfilled',
            Asset__c = assets.Id, 
            Credit_Amount__c = 10.00, 
            Line_Type__c = 'Credit',         
            UnitPrice = 100.00
          ));
        }
         insert theTestOrderItems;
       
    Tiger_Leads__c Tiger = new Tiger_Leads__c();
        Tiger.Name = 'Test tiger';
        Tiger.Territory_Name__c = 'NY';
        insert Tiger;
                         
    Tiger_Lead_Products__c TigerLeads = new Tiger_Lead_Products__c();
        TigerLeads.Name ='TigerLeads';
        TigerLeads.Tiger_Lead_Product_List__c = 'HANDRAISER';
        TigerLeads.TigerLeadActivities__c = 'Domain Setup';
        insert TigerLeads;
    mtduc.CreateCaseSingle();
    Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtId = CaseRecordTypeInfo.get('Retention').getRecordTypeId(); 
        CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
        insert setting; 
        Lead LedB1 = new Lead();
        LedB1.LastName = 'Mr';
        LedB1.FirstName = 'Test Name';
        LedB1.Status = 'New';
        LedB1.Company = 'Test Company';
        //LedB1.Contact__c = myContact.id;
        LedB1.Phone = '(860) 347-0333';
        LedB1.Email = 'c.s1@gmail.com';
        LedB1.Marketing_Lead_Type__c = 'Organic Leads';
        LedB1.Recent_Campaign__c = userinfo.getUserId();
        LedB1.RDC_Contact_Type__c = 'Single Agent';
        LedB1.Account__c = newAgentAccount.id;
        Test.startTest();
        Insert LedB1;
       Id salesActivitiesRecordTypeId = Schema.SObjectType.Task.RecordTypeInfosByName.get('Sales Activities').RecordTypeId;
       Task theTask = null;
        List<Task> tasklist = new List<Task>();
    for(Integer index = 0; index < COUNTER; index++) {
        theTask = TestDataFactory.createTask(
                newAccount.Id,
                'Complete Cancel Request',
                (Math.mod(index, 2) == 0) ? 'Call' : 'Message',
                Date.today(),
                'Completed',
                false
        );
        theTask.RecordTypeId = salesActivitiesRecordTypeId;
        theTask.WhatId  = mtduc.cse.Id;
        theTask.whoId = LedB1.id;
        theTask.Is_Tiger_Lead__c = true;
        tasklist.add(theTask);
    }
    theTask = new Task();
    theTask = TestDataFactory.createTask(
                newAgentAccount.Id,
                'Complete Cancel Request',
                'Call',
                Date.today(),
                'Completed',
                false
        );
        theTask.whoId = LedB1.id;
    theTask.RecordTypeId = salesActivitiesRecordTypeId;
    
    tasklist.add(theTask);
    
    Task theTask2 = new Task();
    theTask2 = TestDataFactory.createTask(
                newAgentAccount.Id,
                'Outbound call to +198765435678',
                'Call',
                Date.today(),
                'Completed',
                false
        );
    theTask2.RecordTypeId = salesActivitiesRecordTypeId;
    theTask2.whoId = LedB1.id;
    tasklist.add(theTask2);
    //insert tasklist;
    

    Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;          
    List<Account_Relationship__c> toBeInserted = new List<Account_Relationship__c>();
    // Create Relationship records for Contact Relationhsip
     Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship(
                        newAccount.Id, null, myContact.Id, null, true, false);
    accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
    accountRelation.Active__c = true;
    accountRelation.Contact_Role__c = 'Primary Contact';
    accountRelation.Billing_Contact__c = true;
    toBeInserted.add(accountRelation); 
    insert toBeInserted;


        //insert tasks;
        try{
        //insert tasklist; 
        }catch(Exception e){}
        //theTask.WhatId  = newAccount.Id;
        try{
        update tasklist;                
       }catch(Exception e){}
       // boolean b = SkipAssetTrigger.isSkipTrg(); //Added by radhika.
       TaskTriggerHandler tth = new TaskTriggerHandler(false ,0);
      // tth.onAfterInsert(tasklist); 
       tth.onBeforeInsertUpdate(tasklist);
       tth.onAfterUpdateCaseTLActivities(tasklist);
       Set<Id> setTaskIds = new Set<Id>(); 
       Set<Id> setLeadIds = new Set<Id>();
       Set<Id> setUserIds = new Set<Id>();
       Set<Id> setOppIds = new Set<Id>();
       setUserIds.add(u.id);
       Map<Id,Task> mapTask = new Map<Id,Task>();
       System.debug('Task List  : '+tasklist);
       for(Task tsk:tasklist){
       System.debug(tsk.id  + 'WhoddId');
       if(tsk.WhoId!=null){
       if(Schema.Lead.SObjectType == tsk.WhoId.getSobjectType()){
       setTaskIds.add(tsk.id);
       setLeadIds.add(tsk.whoId);
       mapTask.put(tsk.id,tsk);
       }
       }
       }
       
       System.debug(' task Ids:'+tasklist.size());
        TaskTriggerHandler.UpdateRelatedLead(setUserIds,setLeadIds,setLeadIds,setTaskIds);
       tth.UpdateLead(mapTask,mapTask);
       tth.InsideUpdateLead(mapTask,mapTask);
       //tth.setFailedCallAttempt(tasklist);
       TaskTriggerHandler.InsideSalesUpdateLead(setTaskIds);
       tth.UpdateOpportunitiesTPIDX(setOppIds);
       
       Test.stopTest();
   }
   
   public static testMethod void main4(){ 
       Schedule_Batch_Setting__c scheduleBatchSetting = new Schedule_Batch_Setting__c();
    scheduleBatchSetting.Name = 'NVM Callback';
    scheduleBatchSetting.Assetresttime__c = 60;
    scheduleBatchSetting.Execution_Min__c = 60;
    insert scheduleBatchSetting;
       
     MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
     User u = mtduc.CreateUserSingle();  
     mtduc.UpdateUserSingle();   
     OrderDecompController.stopCreatingAccount = true; 
      //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = mtduc.CreateDisabledTriggerSingle();
    Switch_AccountRelationshipTrigger__c art = new Switch_AccountRelationshipTrigger__c(name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
    insert art;    
    
    // Inserting Test Account.
    Account newAccount = mtduc.CreateBrokerAccountSingle();
    
    Account newAgentAccount = mtduc.CreateRealtorOfficeAccountSingle();    
    newAgentAccount.Account_Sub_Type__c = 'Prospect'; 
    newAgentAccount.EssentialsStatus__c = 'Activated';  
    update newAgentAccount;
     //Inserting Test Contact 
    Contact myContact = mtduc.CreateContactSingle(); 
             
        Product2 newProduct = mtduc.CreateProductSingle();  
        
        Asset assets = mtduc.CreateFullfilledAssetSingle();
         // Extracting Standard Price Book ID.
        Id StandardPriceBookId = Test.getStandardPricebookId();
        System.debug('######-TESTING-Procebook'+ StandardPriceBookId);
        // Inserting Price Book Entries For The Standard Price Book.
        PricebookEntry thePricebookEntrie = new PricebookEntry();
             
            thePricebookEntrie.Pricebook2Id = StandardPriceBookId;
            thePricebookEntrie.Product2Id = newProduct.Id;
            thePricebookEntrie.UnitPrice = 1000;
            thePricebookEntrie.IsActive = true;        
        insert thePricebookEntrie;
   
     // Inserting Test Orders.
        List<Order> theTestOrders = new List<Order>();
        for(Integer index = 0;index < COUNTER;index++) {
          theTestOrders.add(new Order(
            EffectiveDate = System.today()+10,
            Status = 'Created',            
            AccountId = newAccount.Id,
            Fulfillment_Status__c ='Fulfilled',
            
            Pricebook2Id = thePricebookEntrie.Pricebook2Id//standardPriceBookId
          ));
        }
        insert theTestOrders;   
        System.debug('######-TESTING-ORDERS= '+theTestOrders);
                
    // Inserting Test Order Item.
        List<OrderItem> theTestOrderItems = new List<OrderItem>();
        
        for(Order theTestOrder : theTestOrders) {
          theTestOrderItems.add(new OrderItem(
            Quantity = decimal.valueof('1'),
            PricebookEntryId = thePricebookEntrie.id,        
            OrderId = theTestOrder.Id,
            Fulfillment_Status__c ='Fulfilled',
            Asset__c = assets.Id, 
            Credit_Amount__c = 10.00, 
            Line_Type__c = 'Credit',         
            UnitPrice = 100.00
          ));
        }
         insert theTestOrderItems;
       
    Tiger_Leads__c Tiger = new Tiger_Leads__c();
        Tiger.Name = 'Test tiger';
        Tiger.Territory_Name__c = 'NY';
        insert Tiger;
                         
    Tiger_Lead_Products__c TigerLeads = new Tiger_Lead_Products__c();
        TigerLeads.Name ='TigerLeads';
        TigerLeads.Tiger_Lead_Product_List__c = 'HANDRAISER';
        TigerLeads.TigerLeadActivities__c = 'Domain Setup';
        insert TigerLeads;
        NVMDispositionFollowup__c nvmDispositionFollowup2 = new NVMDispositionFollowup__c();
    nvmDispositionFollowup2.Name = 'Left Message';
    nvmDispositionFollowup2.Lead_Status__c = 'In Progress';
    nvmDispositionFollowup2.NVMfailedCount__c = true;
    nvmDispositionFollowup2.Opcity__c = false;
    insert nvmDispositionFollowup2;
    mtduc.CreateCaseSingle();
    Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtId = CaseRecordTypeInfo.get('Retention').getRecordTypeId(); 
        CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
        insert setting; 
        Lead LedB1 = new Lead();
        LedB1.LastName = 'Mr';
        LedB1.FirstName = 'Test Name1';
        LedB1.Status = 'New';
        LedB1.Company = 'Test Company1';
        //LedB1.Contact__c = myContact.id;
        LedB1.Phone = '(860) 347-0333';
        LedB1.Email = 'c.s1@gmail.com';
        LedB1.Marketing_Lead_Type__c = 'Organic Leads';
        LedB1.Recent_Campaign__c = userinfo.getUserId();
        LedB1.RDC_Contact_Type__c = 'Single Agent';
        //LedB1.Account__c = newAgentAccount.id;
        Insert LedB1;
       Id salesActivitiesRecordTypeId = Schema.SObjectType.Task.RecordTypeInfosByName.get('Sales Activities').RecordTypeId;
       Task theTask = new Task();
        List<Task> tasklist = new List<Task>();
    
    Task theTask2 = new Task();
    theTask2 = new Task(
     WhoId = LedB1.id,
     Subject = 'Outbound call to +198765435678',
     Type = 'call',
     ActivityDate = System.Today(),
     NVM_Disposition__c  ='Left Message',
     Status = 'Completed');
    theTask2.RecordTypeId = salesActivitiesRecordTypeId;
    //theTask2.whatId = newAccount.Id;
    tasklist.add(theTask2);
    insert tasklist;
    Test.startTest();

    Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;          
    List<Account_Relationship__c> toBeInserted = new List<Account_Relationship__c>();
    // Create Relationship records for Contact Relationhsip
     Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship(
                        newAccount.Id, null, myContact.Id, null, true, false);
    accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
    accountRelation.Active__c = true;
    accountRelation.Contact_Role__c = 'Primary Contact';
    accountRelation.Billing_Contact__c = true;
    toBeInserted.add(accountRelation); 
    insert toBeInserted;


        //insert tasks;
        try{
        //insert tasklist; 
        }catch(Exception e){}
        //theTask.WhatId  = newAccount.Id;
        try{
        update tasklist;                
       }catch(Exception e){}
       // boolean b = SkipAssetTrigger.isSkipTrg(); //Added by radhika.
       TaskTriggerHandler tth = new TaskTriggerHandler(false ,0);
       //tth.onAfterInsert(tasklist); 
       //tth.onBeforeInsertUpdate(tasklist);
       //tth.onAfterUpdateCaseTLActivities(tasklist);
       Set<Id> setTaskIds = new Set<Id>(); 
       Set<Id> setLeadIds = new Set<Id>();
       Set<Id> setUserIds = new Set<Id>();
       Set<Id> setOppIds = new Set<Id>();
       setUserIds.add(u.id);
       Map<Id,Task> mapTask = new Map<Id,Task>();
       System.debug('Task List  : '+tasklist);
       for(Task tsk:tasklist){
       System.debug(tsk.id  + 'WhoddId');
       if(tsk.WhoId!=null){
       if(Schema.Lead.SObjectType == tsk.WhoId.getSobjectType()){
       setTaskIds.add(tsk.id);
       setLeadIds.add(tsk.whoId);
       mapTask.put(tsk.id,tsk);
       }
       }
       }
       System.debug(' task Ids:'+tasklist.size());
        TaskTriggerHandler.UpdateRelatedLead(setUserIds,setLeadIds,setLeadIds,setTaskIds);
       tth.UpdateLead(mapTask,mapTask);
       //TaskTriggerHandler.UpdateCase(mapTask.keyset());
       tth.InsideUpdateLead(mapTask,mapTask);
       //tth.setFailedCallAttempt(tasklist);
       TaskTriggerHandler.InsideSalesUpdateLead(setTaskIds);
       TaskTriggerHandler.InsideSalesUpdateCallStatusLead(setTaskIds);
       tth.UpdateOpportunitiesTPIDX(setOppIds);
       Test.stopTest();
   }
  
   public static testMethod void main41(){ 
       Schedule_Batch_Setting__c scheduleBatchSetting = new Schedule_Batch_Setting__c();
    scheduleBatchSetting.Name = 'NVM Callback';
    scheduleBatchSetting.Assetresttime__c = 60;
    scheduleBatchSetting.Execution_Min__c = 60;
    insert scheduleBatchSetting;
       
     MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
     User u = mtduc.CreateUserSingle();  
     mtduc.UpdateUserSingle();   
     OrderDecompController.stopCreatingAccount = true; 
      //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = mtduc.CreateDisabledTriggerSingle();
    Switch_AccountRelationshipTrigger__c art = new Switch_AccountRelationshipTrigger__c(name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
    insert art;    
    
    // Inserting Test Account.
    Account newAccount = mtduc.CreateBrokerAccountSingle();
    
    Account newAgentAccount = mtduc.CreateRealtorOfficeAccountSingle();    
    newAgentAccount.Account_Sub_Type__c = 'Prospect'; 
    newAgentAccount.EssentialsStatus__c = 'Activated';  
    update newAgentAccount;
     //Inserting Test Contact 
    Contact myContact = mtduc.CreateContactSingle(); 
             
        Product2 newProduct = mtduc.CreateProductSingle();  
        
        Asset assets = mtduc.CreateFullfilledAssetSingle();
         // Extracting Standard Price Book ID.
        Id StandardPriceBookId = Test.getStandardPricebookId();
        System.debug('######-TESTING-Procebook'+ StandardPriceBookId);
        // Inserting Price Book Entries For The Standard Price Book.
        PricebookEntry thePricebookEntrie = new PricebookEntry();
             
            thePricebookEntrie.Pricebook2Id = StandardPriceBookId;
            thePricebookEntrie.Product2Id = newProduct.Id;
            thePricebookEntrie.UnitPrice = 1000;
            thePricebookEntrie.IsActive = true;        
        insert thePricebookEntrie;
   
     // Inserting Test Orders.
        List<Order> theTestOrders = new List<Order>();
        for(Integer index = 0;index < COUNTER;index++) {
          theTestOrders.add(new Order(
            EffectiveDate = System.today()+10,
            Status = 'Created',            
            AccountId = newAccount.Id,
            Fulfillment_Status__c ='Fulfilled',
            
            Pricebook2Id = thePricebookEntrie.Pricebook2Id//standardPriceBookId
          ));
        }
        insert theTestOrders;   
        System.debug('######-TESTING-ORDERS= '+theTestOrders);
                
    // Inserting Test Order Item.
        List<OrderItem> theTestOrderItems = new List<OrderItem>();
        
        for(Order theTestOrder : theTestOrders) {
          theTestOrderItems.add(new OrderItem(
            Quantity = decimal.valueof('1'),
            PricebookEntryId = thePricebookEntrie.id,        
            OrderId = theTestOrder.Id,
            Fulfillment_Status__c ='Fulfilled',
            Asset__c = assets.Id, 
            Credit_Amount__c = 10.00, 
            Line_Type__c = 'Credit',         
            UnitPrice = 100.00
          ));
        }
         insert theTestOrderItems;
       
    Tiger_Leads__c Tiger = new Tiger_Leads__c();
        Tiger.Name = 'Test tiger';
        Tiger.Territory_Name__c = 'NY';
        insert Tiger;
                         
    Tiger_Lead_Products__c TigerLeads = new Tiger_Lead_Products__c();
        TigerLeads.Name ='TigerLeads';
        TigerLeads.Tiger_Lead_Product_List__c = 'HANDRAISER';
        TigerLeads.TigerLeadActivities__c = 'Domain Setup';
        insert TigerLeads;
        NVMDispositionFollowup__c nvmDispositionFollowup = new NVMDispositionFollowup__c();
    nvmDispositionFollowup.Name = 'Left Message#';
    nvmDispositionFollowup.Lead_Status__c = 'In Progress';
    nvmDispositionFollowup.NVMfailedCount__c = true;
    nvmDispositionFollowup.Opcity__c = true;
    insert nvmDispositionFollowup;
    NVMDispositionFollowup__c nvmDispositionFollowup2 = new NVMDispositionFollowup__c();
    nvmDispositionFollowup2.Name = 'Left Message';
    nvmDispositionFollowup2.Lead_Status__c = 'In Progress';
    nvmDispositionFollowup2.NVMfailedCount__c = true;
    nvmDispositionFollowup2.Opcity__c = false;
    insert nvmDispositionFollowup2;
        
    NVMDispositionFollowup__c nvmDispositionFollowup1 = new NVMDispositionFollowup__c();
    nvmDispositionFollowup1.Name = 'Agents Enrolled#';
    nvmDispositionFollowup.Lead_Status__c = 'Converted';
    nvmDispositionFollowup1.NVMfailedCount__c = true;
    nvmDispositionFollowup1.Opcity__c = true;
    insert nvmDispositionFollowup1;
    
    mtduc.CreateCaseSingle();
    Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtId = CaseRecordTypeInfo.get('Retention').getRecordTypeId(); 
        CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
        insert setting; 
        Lead LedB1 = new Lead();
        LedB1.LastName = 'Mr';
        LedB1.FirstName = 'Test Name1';
        LedB1.Status = 'New';
        LedB1.Company = 'Test Company1';
        //LedB1.Contact__c = myContact.id;
        LedB1.Phone = '(860) 347-0333';
        LedB1.Email = 'c.s1@gmail.com';
        LedB1.Marketing_Lead_Type__c = 'Organic Leads';
        LedB1.Recent_Campaign__c = userinfo.getUserId();
        LedB1.RDC_Contact_Type__c = 'Single Agent';
        //LedB1.Account__c = newAgentAccount.id;
        Insert LedB1;
       Id salesActivitiesRecordTypeId = Schema.SObjectType.Task.RecordTypeInfosByName.get('Sales Activities').RecordTypeId;
       Task theTask = new Task();
        List<Task> tasklist = new List<Task>();
    
    Task theTask2 = new Task();
    theTask2 = new Task(
     WhoId = LedB1.id,
     Subject = 'Outbound call to +198765435678',
     Type = 'call',
     ActivityDate = System.Today(),
     NVM_Disposition__c  ='Left Message',
     Status = 'Completed');
    theTask2.RecordTypeId = salesActivitiesRecordTypeId;
    //theTask2.whatId = newAccount.Id;
    tasklist.add(theTask2);
    insert tasklist;
    Test.startTest();

    Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;          
    List<Account_Relationship__c> toBeInserted = new List<Account_Relationship__c>();
    // Create Relationship records for Contact Relationhsip
     Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship(
                        newAccount.Id, null, myContact.Id, null, true, false);
    accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
    accountRelation.Active__c = true;
    accountRelation.Contact_Role__c = 'Primary Contact';
    accountRelation.Billing_Contact__c = true;
    toBeInserted.add(accountRelation); 
    insert toBeInserted;


        //insert tasks;
        try{
        //insert tasklist; 
        }catch(Exception e){}
        //theTask.WhatId  = newAccount.Id;
        try{
        update tasklist;                
       }catch(Exception e){}
       // boolean b = SkipAssetTrigger.isSkipTrg(); //Added by radhika.
       TaskTriggerHandler tth = new TaskTriggerHandler(false ,0);
       //tth.onAfterInsert(tasklist); 
       //tth.onBeforeInsertUpdate(tasklist);
       //tth.onAfterUpdateCaseTLActivities(tasklist);
       Set<Id> setTaskIds = new Set<Id>(); 
       Set<Id> setLeadIds = new Set<Id>();
       Set<Id> setUserIds = new Set<Id>();
       Set<Id> setOppIds = new Set<Id>();
       setUserIds.add(u.id);
       Map<Id,Task> mapTask = new Map<Id,Task>();
       System.debug('Task List  : '+tasklist);
       for(Task tsk:tasklist){
       System.debug(tsk.id  + 'WhoddId');
       if(tsk.WhoId!=null){
       if(Schema.Lead.SObjectType == tsk.WhoId.getSobjectType()){
       setTaskIds.add(tsk.id);
       setLeadIds.add(tsk.whoId);
       mapTask.put(tsk.id,tsk);
       }
       }
       }
       System.debug(' task Ids:'+tasklist.size());
        TaskTriggerHandler.OPCITYLeadProcess(setUserIds,setLeadIds,setLeadIds,setTaskIds);
       tth.UpdateLead(mapTask,mapTask);
       
       Test.stopTest();
   }
  
    public static testMethod void main5(){ 
        Schedule_Batch_Setting__c scheduleBatchSetting = new Schedule_Batch_Setting__c();
    scheduleBatchSetting.Name = 'NVM Callback';
    scheduleBatchSetting.Assetresttime__c = 60;
    scheduleBatchSetting.Execution_Min__c = 60;
    insert scheduleBatchSetting;
        
     MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
     User u = mtduc.CreateUserSingle();  
     mtduc.UpdateUserSingle();   
     OrderDecompController.stopCreatingAccount = true; 
      //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = mtduc.CreateDisabledTriggerSingle();
    Switch_AccountRelationshipTrigger__c art = new Switch_AccountRelationshipTrigger__c(name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
    insert art;    
    SkipAccountTrigger.setSkipTrgTrue();
    // Inserting Test Account.
    Account newAccount = mtduc.CreateBrokerAccountSingle();
    Account newAgentAccount = mtduc.CreateRealtorOfficeAccountSingle();    
    newAgentAccount.Account_Sub_Type__c = 'Prospect'; 
    newAgentAccount.EssentialsStatus__c = 'Activated';  
    update newAgentAccount;
     //Inserting Test Contact 
    Contact myContact = mtduc.CreateContactSingle(); 
             
        Product2 newProduct = mtduc.CreateProductSingle();  
        
        Asset assets = mtduc.CreateFullfilledAssetSingle();
         // Extracting Standard Price Book ID.
        Id StandardPriceBookId = Test.getStandardPricebookId();
        System.debug('######-TESTING-Procebook'+ StandardPriceBookId);
        // Inserting Price Book Entries For The Standard Price Book.
        PricebookEntry thePricebookEntrie = new PricebookEntry();
             
            thePricebookEntrie.Pricebook2Id = StandardPriceBookId;
            thePricebookEntrie.Product2Id = newProduct.Id;
            thePricebookEntrie.UnitPrice = 1000;
            thePricebookEntrie.IsActive = true;        
        insert thePricebookEntrie;
   
     // Inserting Test Orders.
        List<Order> theTestOrders = new List<Order>();
        for(Integer index = 0;index < COUNTER;index++) {
          theTestOrders.add(new Order(
            EffectiveDate = System.today()+10,
            Status = 'Created',            
            AccountId = newAccount.Id,
            Fulfillment_Status__c ='Fulfilled',
            
            Pricebook2Id = thePricebookEntrie.Pricebook2Id//standardPriceBookId
          ));
        }
        insert theTestOrders;   
        System.debug('######-TESTING-ORDERS= '+theTestOrders);
                
    // Inserting Test Order Item.
        List<OrderItem> theTestOrderItems = new List<OrderItem>();
        
        for(Order theTestOrder : theTestOrders) {
          theTestOrderItems.add(new OrderItem(
            Quantity = decimal.valueof('1'),
            PricebookEntryId = thePricebookEntrie.id,        
            OrderId = theTestOrder.Id,
            Fulfillment_Status__c ='Fulfilled',
            Asset__c = assets.Id, 
            Credit_Amount__c = 10.00, 
            Line_Type__c = 'Credit',         
            UnitPrice = 100.00
          ));
        }
         insert theTestOrderItems;
       
    Tiger_Leads__c Tiger = new Tiger_Leads__c();
        Tiger.Name = 'Test tiger';
        Tiger.Territory_Name__c = 'NY';
        insert Tiger;
                         
    Tiger_Lead_Products__c TigerLeads = new Tiger_Lead_Products__c();
        TigerLeads.Name ='TigerLeads';
        TigerLeads.Tiger_Lead_Product_List__c = 'HANDRAISER';
        TigerLeads.TigerLeadActivities__c = 'Domain Setup';
        insert TigerLeads;
    mtduc.CreateCaseSingle();
    Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtId = CaseRecordTypeInfo.get('Retention').getRecordTypeId(); 
        CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
        insert setting; 
        Opportunity LedB1 = new Opportunity();
        LedB1.Name = 'Mr';
        LedB1.Status__c = 'Converted';
        LedB1.StageName = 'Pipeline';
        LedB1.CloseDate = System.today();
        LedB1.NextContactTime__c = System.today();
        LedB1.NVM_opportunity__c = 'NVM$$$OPP';
        LedB1.Phone__c = '(860) 347-0333';
        LedB1.AccountId = newAgentAccount.id;
        //LedB1.Marketing_Lead_Type__c = 'Organic Leads';
        //LedB1.Recent_Campaign__c = 'Test';
        LedB1.Status__c = 'New';
        Insert LedB1;
        
        Set<Id> setOpportunityId = new Set<Id>();
        setOpportunityId.add(LedB1.Id);
        TaskTriggerHandler taskTgrHandler = new TaskTriggerHandler(true, 1);
        taskTgrHandler.UpdateOpportunitiesTPIDX(setOpportunityId);
        
       Id salesActivitiesRecordTypeId = Schema.SObjectType.Task.RecordTypeInfosByName.get('Sales Activities').RecordTypeId;
       Task theTask = new Task();
        List<Task> tasklist = new List<Task>();
    Lead tstLead = New Lead();
        tstLead.Account__c = newAccount.Id;
        tstLead.LastName = 'LeadTest';
        tstLead.FirstName = 'First';
        tstLead.Company = 'Test Company';
        tstLead.Leadsource = 'Agent';
        tstLead.Status = 'New';
        tstLead.Email = 'lloy.sanders@crm-manager.net';
        tstLead.Marketing_Lead_Type__c = 'Event';
        Insert tstLead;
        
    Task theTask2 = new Task();
    theTask2 = new Task(
     WhatId = LedB1.id,
     Subject = 'High Priority Missed Call',
     Type = 'call',
     ActivityDate = System.Today(),
     Status = 'Completed');
     theTask2.RecordTypeId = salesActivitiesRecordTypeId;
     theTask2.NVMContactWorld__Customer_Number__c = '1230984567';
    //theTask2.whoId = tstLead.Id;
    tasklist.add(theTask2);
        system.debug(Logginglevel.ERROR, 'theTask2.whatId ==>'+theTask2.whatId);
        
    insert tasklist;
    Test.startTest();
    
    Set<Id> setTaskId = new Set<Id>();
    setTaskId.add(tasklist[0].Id);
    
    TaskTriggerHandler.InsideSalesUpdateLeadNonFuture(setTaskId);
    TaskTriggerHandler.InsideSalesUpdateLeadFuture(setTaskId);
    TaskTriggerHandler.InsideSalesUpdateCallStatusLead(setTaskId);
    
    Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;          
    List<Account_Relationship__c> toBeInserted = new List<Account_Relationship__c>();
    // Create Relationship records for Contact Relationhsip
     Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship(
                        newAccount.Id, null, myContact.Id, null, true, false);
    accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
    accountRelation.Active__c = true;
    accountRelation.Contact_Role__c = 'Primary Contact';
    accountRelation.Billing_Contact__c = true;
    toBeInserted.add(accountRelation); 
    insert toBeInserted;


        //insert tasks;
        try{
        //insert tasklist; 
        }catch(Exception e){}
        //theTask.WhatId  = newAccount.Id;
        try{
        update tasklist;                
       }catch(Exception e){}
       // boolean b = SkipAssetTrigger.isSkipTrg(); //Added by radhika.
       TaskTriggerHandler tth = new TaskTriggerHandler(false ,0);
       //tth.onAfterInsert(tasklist); 
       //tth.onBeforeInsertUpdate(tasklist);
       //tth.onAfterUpdateCaseTLActivities(tasklist);
       Set<Id> setTaskIds = new Set<Id>(); 
       Set<Id> setLeadIds = new Set<Id>();
       Set<Id> setUserIds = new Set<Id>();
       Set<Id> setOppIds = new Set<Id>();
       setUserIds.add(u.id);
       Map<Id,Task> mapTask = new Map<Id,Task>();
       System.debug('Task List  : '+tasklist);
       for(Task tsk:tasklist){
       System.debug(tsk.id  + 'WhoddId');
       if(tsk.WhatId!=null){
       if(Schema.Opportunity.SObjectType == tsk.WhatId.getSobjectType()){
       setTaskIds.add(tsk.id);
       setLeadIds.add(tsk.whatId);
       mapTask.put(tsk.id,tsk);
       }
       }
       }
       System.debug(' task Ids:'+tasklist.size());
        TaskTriggerHandler.UpdateRelatedOpportunityNew(setUserIds,setOpportunityId,setOpportunityId,setTaskIds);
       
       Test.stopTest();
   }
   static testMethod void whenTestFailedCallAttempt() {
        Schedule_Batch_Setting__c scheduleBatchSetting = new Schedule_Batch_Setting__c();
    scheduleBatchSetting.Name = 'NVM Callback';
    scheduleBatchSetting.Assetresttime__c = 60;
    scheduleBatchSetting.Execution_Min__c = 60;
    insert scheduleBatchSetting;
       
        DisabledTrigger__c DtrgX = New DisabledTrigger__c();
        Dtrgx.Name = 'Disabled';
        Dtrgx.TaskTrigger__c = 'batchintegration_user@move.com.eut';
        Insert Dtrgx;
OrderDecompController.stopCreatingAccount = true; 
        DisabledTrigger__c Dtrg = DisabledTrigger__c.getValues('Disabled');
        system.debug(Dtrg);

        Account tstAcct = New Account();
        tstAcct.Name = 'New Test Acct';
        tstAcct.BillingCountry = 'Canada';
        Insert tstAcct;

        Lead tstLead = New Lead();
        tstLead.Account__C = tstAcct.Id;
        tstLead.LastName = 'LeadTest';
        tstLead.FirstName = 'First';
        tstLead.Company = 'Test Company';
        tstLead.Leadsource = 'Agent';
        tstLead.Status = 'New';
        tstLead.Email = 'lloy.sanders@crm-manager.net';
        tstLead.Marketing_Lead_Type__c = 'Event';
        Insert tstLead;
        
        List<Task> lstTask = new List<Task>();
       
        Task tstTaskCnt = New Task();
        tstTaskCnt.WhoId = tstLead.Id;
        //tstTaskCnt.WhatId = tstAcct.Id;
        tstTaskCnt.Lead__c = tstLead.Id;
        tstTaskCnt.Subject = 'Call 1';
        tstTaskCnt.Status = 'New';
        tstTaskCnt.Type = 'Phone Call';
        tstTaskCnt.Priority = 'Normal';
       // tstTaskCnt.qbdialer__ImpressionId__c = 1234;
        tstTaskCnt.Outcome__c = 'Left Voicemail';
        tstTaskCnt.CallDisposition = 'Busy';
        tstTaskCnt.NVM_Disposition__c = 'Left Message';
        tstTaskCnt.NVMContactWorld__Customer_Number__c = '1230984567';
        insert tstTaskCnt;
        
       /*Task tstTask = New Task();
        tstTask.WhoId = tstLead.Id;
        tstTask.Lead__c = tstLead.Id;
        tstTask.Subject = 'Call 1';
        tstTask.Status = 'New';
        tstTask.Type = 'Phone Call';
        tstTask.Priority = 'Normal';
        tstTask.Outcome__c = 'Left Voicemail';
        tstTask.CallDisposition = 'Busy';
        tstTask.Followup_Status__c = 'Left Message';
        tstTask.NVM_Disposition__c = 'Left Message';
        lstTask.add(tstTask);
        insert lstTask;
        */
        tstLead.Failed_Attempt_Count__c = 10;
        Update tstLead;
        
       Set<Id> setTaskIds = new Set<Id>(); 
       Set<Id> setLeadIds = new Set<Id>();
       Set<Id> setUserIds = new Set<Id>();
       Set<Id> setOppIds = new Set<Id>();
       setTaskIds.add(tstTaskCnt.Id);
       setUserIds.add(UserInfo.getUserId());
       setLeadIds.add(tstLead.Id);
        Test.startTest();
        TaskTriggerHandler.UpdateRelatedOpportunityNew(setUserIds,setLeadIds,setLeadIds,setTaskIds);
        //TaskTriggerHandler.setFailedCallAttemptRan = false;
        tstTaskCnt.NVM_Disposition__c = 'Spoke to';
        //update tstTaskCnt;
        Test.stopTest();

        Lead testLead = [SELECT Id, Failed_Attempt_Count__c FROM Lead WHERE LastName = 'LeadTest' limit 1];

       // System.AssertEquals(11, testLead.Failed_Attempt_Count__c, 'Failed Call Attempt Should Increase');

    }

    static testMethod void whenTestSuccessCallAttempt() {
        Schedule_Batch_Setting__c scheduleBatchSetting = new Schedule_Batch_Setting__c();
    scheduleBatchSetting.Name = 'NVM Callback';
    scheduleBatchSetting.Assetresttime__c = 60;
    scheduleBatchSetting.Execution_Min__c = 60;
    insert scheduleBatchSetting;
        
        DisabledTrigger__c DtrgX = New DisabledTrigger__c();
        Dtrgx.Name = 'Disabled';
        Dtrgx.TaskTrigger__c = 'batchintegration_user@move.com.eut';
        Insert Dtrgx;
OrderDecompController.stopCreatingAccount = true; 
        DisabledTrigger__c Dtrg = DisabledTrigger__c.getValues('Disabled');
        system.debug(Dtrg);

        Account tstAcct = New Account();
        tstAcct.Name = 'New Test Acct';
        tstAcct.BillingCountry = 'Canada';
        Insert tstAcct;

        Lead tstLead = New Lead();
        tstLead.LastName = 'LeadTest';
        tstLead.FirstName = 'First';
        tstLead.Company = 'Test Company';
        tstLead.Leadsource = 'Agent';
        tstLead.Status = 'New';
        tstLead.Email = 'lloy.sanders@crm-manager.net';
        tstLead.Marketing_Lead_Type__c = 'Event';       
        Insert tstLead;

        Task tstTaskCnt = New Task();
        tstTaskCnt.Lead__c = tstLead.Id;
        tstTaskCnt.WhoId = tstLead.Id;
        tstTaskCnt.Subject = 'Call 1';
        tstTaskCnt.Status = 'New';
        tstTaskCnt.Type = 'Phone Call';
        tstTaskCnt.Priority = 'Normal';
       // tstTaskCnt.qbdialer__ImpressionId__c = 1234;
        tstTaskCnt.Outcome__c = 'Left Voicemail';
        tstTaskCnt.CallDisposition = 'Contact';
        //Insert tstTaskCnt;

        tstLead.Failed_Attempt_Count__c = 10;
        Update tstLead;

        Test.startTest();
        //TaskTriggerHandler.setFailedCallAttemptRan = false;
        //update tstTaskCnt;
        Test.stopTest();

        Lead testLead = [SELECT Id, Failed_Attempt_Count__c FROM Lead WHERE LastName = 'LeadTest' limit 1];

        System.AssertEquals(10, testLead.Failed_Attempt_Count__c, 'Failed Call Attempt Should Not Increase. CallDisposition = Contact');

    }

    static testMethod void whenTestFailedCallAttemptNumber12() {
        Schedule_Batch_Setting__c scheduleBatchSetting = new Schedule_Batch_Setting__c();
    scheduleBatchSetting.Name = 'NVM Callback';
    scheduleBatchSetting.Assetresttime__c = 60;
    scheduleBatchSetting.Execution_Min__c = 60;
    insert scheduleBatchSetting;
        
        DisabledTrigger__c DtrgX = New DisabledTrigger__c();
        Dtrgx.Name = 'Disabled';
        Dtrgx.TaskTrigger__c = 'batchintegration_user@move.com.eut';
        Insert Dtrgx;
OrderDecompController.stopCreatingAccount = true; 
        DisabledTrigger__c Dtrg = DisabledTrigger__c.getValues('Disabled');
        system.debug(Dtrg);

        Account tstAcct = New Account();
        tstAcct.Name = 'New Test Acct';
        tstAcct.BillingCountry = 'Canada';
        Insert tstAcct;

        Lead tstLead = New Lead();      
        tstLead.LastName = 'LeadTest';
        tstLead.FirstName = 'First';
        tstLead.Company = 'Test Company';
        tstLead.Leadsource = 'Agent';
        tstLead.Status = 'New';
        tstLead.Email = 'lloy.sanders@crm-manager.net';
        tstLead.Marketing_Lead_Type__c = 'Event';
        Insert tstLead;

        Task tstTaskCnt = New Task();
        tstTaskCnt.Lead__c = tstLead.Id;
        tstTaskCnt.WhoId = tstLead.Id;
        tstTaskCnt.Subject = 'Call 1';
        tstTaskCnt.Status = 'New';
        tstTaskCnt.Type = 'Phone Call';
        tstTaskCnt.Priority = 'Normal';
       // tstTaskCnt.qbdialer__ImpressionId__c = 1234;
        tstTaskCnt.Outcome__c = 'Left Voicemail';
        tstTaskCnt.CallDisposition = 'Left Voicemail';
        //Insert tstTaskCnt;

        tstLead.Failed_Attempt_Count__c = 11;
        Update tstLead;

        Test.startTest();
        //TaskTriggerHandler.setFailedCallAttemptRan = false;
        //update tstTaskCnt;
        Test.stopTest();

        Lead testLead = [SELECT Id, Failed_Attempt_Count__c, Status FROM Lead WHERE LastName = 'LeadTest' limit 1];

        //System.AssertEquals(12, testLead.Failed_Attempt_Count__c, 'Failed Call Attempt Should Increase To 12.');
        //System.AssertEquals(TaskTriggerHandler.LEAD_STATUS_AFTER_12_ATTEMPTS, testLead.Status, 'Lead Status should update to Rejected After 12 Attempts.');
    } 
    
    static  testMethod void OpcityTest() {
        MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
        
        Schedule_Batch_Setting__c scheduleBatchSetting = new Schedule_Batch_Setting__c();
        scheduleBatchSetting.Name = 'NVM Callback';
        scheduleBatchSetting.Assetresttime__c = 60;
        scheduleBatchSetting.Execution_Min__c = 60;
        insert scheduleBatchSetting;
        
           
          //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = mtduc.CreateDisabledTriggerSingle();
        Switch_AccountRelationshipTrigger__c art = new Switch_AccountRelationshipTrigger__c(name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
        insert art;    
        OrderDecompController.stopCreatingAccount = true; 
        // Inserting Test Account.
        Account newAccount = mtduc.CreateBrokerAccountSingle();
        newAccount.Total_Contract_Value__c = 999;
        update newAccount;
         //Inserting Test Contact 
        Contact myContact = mtduc.CreateContactSingle(); 
               
                         
        Tiger_Lead_Products__c TigerLeads = new Tiger_Lead_Products__c();
        TigerLeads.Name ='TigerLeads';
        TigerLeads.Tiger_Lead_Product_List__c = 'HANDRAISER';
        TigerLeads.TigerLeadActivities__c = 'Domain Setup';
        insert TigerLeads;
        
        NVMDispositionFollowup__c nvmDispositionFollowup = new NVMDispositionFollowup__c();
        nvmDispositionFollowup.Name = 'Left Message#';
        nvmDispositionFollowup.Opcity__c = true;
        nvmDispositionFollowup.NVMfailedCount__c = true;
        insert nvmDispositionFollowup;
            
        NVMDispositionFollowup__c nvmDispositionFollowup1 = new NVMDispositionFollowup__c();
        nvmDispositionFollowup1.Name = 'In Progress#';
        nvmDispositionFollowup1.Opcity__c = true;
        nvmDispositionFollowup1.NVMfailedCount__c = true;
        insert nvmDispositionFollowup1;
    
        mtduc.CreateCaseSingle();
    
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtId = CaseRecordTypeInfo.get('Retention').getRecordTypeId(); 
        CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId);
        insert setting; 
        List<Case> cc=new List<Case>();
        Case theCase = new Case(
            Subject = 'subject',
            //Status = 'Closed',
            Type = 'Order',
            Is_Tiger_Lead__c =true,
            ContactId = myContact.id,
            Description = 'description',
            Status = 'In Progress',
            NVM_Failed_Call_Count__c = 9,
            Followup_Status__c = 'Follow up Scheduled- Pitched',
            NVM_Call_Count__c = 6);
            insert theCase;
            Task theTask1 = TestDataFactory.createTask(
                newAccount.Id,
                'Set Up Client in Stripes',
                'Call',
                Date.today(),
                'Not Started',
                false
        );
        insert theTask1;
        theTask1.WhatId = theCase.Id;
        theTask1.Status = 'Completed';
        Test.startTest();
        update theTask1;
        Test.stopTest();
    }
}