/***********************************************************************
 Class       : Related_ListController_Test
 Author     : Appirio
 Descritption   : Provide test coverage to Related_ListController.cls
 ************************************************************************/
@isTest
private class Related_ListController_Test {
  
  static Account account;
  // Method to test search functionality
    static testMethod void testSearchListFunctionality() {
        
        createTestData();
        
        Test.startTest();
        
          Related_ListController controller = new Related_ListController();
          // Setting attributes for searching
          controller.fieldsCSV = 'FirstName,LastName,Account.Owner.FirstName';
          controller.sortDirection = 'asc';
          controller.objectName = 'Contact';
          controller.pageSize = 5;
          controller.searchFieldName = 'AccountId';
          controller.searchFieldValue = account.id;
          controller.orderByFieldName = 'LastName';
          controller.sortByField  = 'LastName';
          controller.filter = '';
          controller.title = 'Contacts';
          controller.returnUrl = '/003/0';

          // Calling search method
          //controller.getRecords();
          List<sObject> records = controller.getRecords();
          system.assertEquals(records.size(), 5, 'Search method should return 5 records.');
          
          
          controller.getShowNewButton();
          controller.sortByFieldAction();
          
          controller.deleteRecordId = controller.getRecords().get(0).id;
          controller.deleteRecord();
          system.assertEquals(controller.getRecords().size(), 4, 'After delete, size of the record list should be 4.');
          
        Test.stopTest();
    }
    
    // Method to test validations
    static testMethod void testValidation() {
      createTestData();
      Test.startTest();
        Related_ListController controller = new Related_ListController();
        // Setting attributes for searching
          controller.objectName = 'Contact';
          controller.pageSize = 5;
          controller.searchFieldName = 'AccountId';
          controller.searchFieldValue = '';
          controller.orderByFieldName = 'LastName';
          controller.sortByField  = 'LastName';
          controller.filter = '';
          controller.title = 'Contacts';
          controller.returnUrl = '/003/0';
        
        // Calling search method without field list
          controller.getRecords();
        System.assert(ApexPages.getMessages().get(0).getSummary().contains('fieldList or fieldsCSV attribute must be defined.') );
        
        // Setting field list
        List<String> fieldList = new List<String>();
        fieldList.add('FirstName');
        fieldList.add('LastName');
        controller.fieldsList = fieldList;
        
        // Calling search method with incorrect sortDirection
        controller.sortDirection = 'xyz';
        controller.getRecords();
        System.assert(ApexPages.getMessages().get(1).getSummary().contains('sortDirection attribute must have value of "asc" or "desc"') );
        
        controller.sortDirection = 'asc';
        controller.getRecords();
      
      Test.stopTest();
      
    }
    
    
    // Method to create test data
    private static void createTestData(){
      //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;    
      account = TestDataFactory.createAccount('The Test Account', null, false);
    account.Primary_Email__c = 'theAcc@move.com';
    account.Type = Constants.OFFICE_ACCOUNT_TYPE;
      insert account;
      
      List<Contact> listContact = new List<Contact>();
      for(Integer indx=1; indx <= 5; indx ++){
        Contact contact = new Contact(
          FirstName = 'Test' + String.valueOf(indx),
          LastName = 'Test' + String.valueOf(indx),
          AccountId = account.id,
          Email = 'test' + indx + '@test.com'
        );
        listContact.add(contact);
      }
      insert listContact;
    }
}