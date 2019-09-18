@isTest
public class createtasksforwaitlist_Test{
    Static TestMethod void createtasks(){       
        
        /*
        Task InsertTask       = new Task();
        InsertTask.recordtypeid   = rectypid;
        InsertTask.Subject       = 'Waitlist Notes';
        InsertTask.WhatId       = acctid;    
        InsertTask.Description     = notes;
        InsertTask.OwnerId      = userinfo.getUserId();
        InsertTask.Status      = 'Completed';
        InsertTask.WaitlistGUIID__c = token; 
                   
        Schema.DescribeSObjectResult cfrcSchema = Schema.SObjectType.Task; 
        Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrcSchema.getRecordTypeInfosByName(); 
        Id rtnId = CaseRecordTypeInfo.get('Retention').getRecordTypeId();
       */
       DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
       insert Dtrg;   
       
         Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
          testAccount.Primary_Email__c = 'testAccount@move.com';
        insert testAccount; 
     
        createtasksforwaitlist ctf = New createtasksforwaitlist();
        createtasksforwaitlist.inserttask(testAccount.id,'TESTING DONE','Hi123');
        
    }
    
    static  testmethod void createwaitlistQuoteWrapperTest(){
        
        createwaitlistquotewrapper controller = new createwaitlistquotewrapper();
        controller.uniqueRecordId='1234567890';
    controller.LeadType='Test';
    controller.ProductCode='Pro-123';
    controller.InventoryPool='Regular';
    controller.MarketID='123456';
    controller.MarketKey='12345';
    controller.MarketStateID='123451';
    controller.productSize='14574';
    controller.productType='regular';
    controller.Quantity =2;
    controller.Email ='abc@mailinator.com';
    controller.Term =4;
    controller.priceTier=2;
    }

    static testmethod void createwaitlistTest(){
        
        CreateWaitlistWrapper controller = new CreateWaitlistWrapper();
        
        
    }    

}