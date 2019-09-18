// (c) 2015 Appirio, Inc.
//
// Class Name: CaseCommentsControllerTest
// Description: TestClass  for CaseCommentsComponentController & CaseCommentExtension
//
// 27th March 2015    Ravindra Shekhawat   Original (Task # T-T-373931)
//

@isTest(seeAllData=false)
public class PublicGroupQueueManagementControllerTest {
    
  static testMethod void testGroupQueueMgmtFunctionality() {
    
    Profile p = [SELECT id FROM Profile WHERE Name = 'Move Service Super Rep'];
      DisabledTrigger__c Dtrg = new DisabledTrigger__c();
      Dtrg.Name = 'Disabled';
      Dtrg.TaskTrigger__c = 'Test@test.com';
      Dtrg.AssetTrigger__c = 'Test@test.com';
      insert Dtrg;
    Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
    testAccount.Primary_Email__c = 'testAcc@move.com';
    insert testAccount;
    Contact testContact = TestDataFactory.createContact('Test Contact','TestL',testAccount.Id,true,false);
    testContact.Email ='testCont@email.com';
    insert testContact;
    
    // Create A Group
    Group collectionGroup = TestDataFactory.createPublicGroup('CC Collections Team',true);
    // Create Users to be Added to Public Group Or Queue
    List<User> userList = new List<User>();
    userList.add(TestDataFactory.createUser(null,p.Id,null,'testemail@hsb.com','testemail@hsb.com',false));
    userList.add(TestDataFactory.createUser(null,p.Id,null,'testemail1@hsb.com','testemail1@hsb.com',false));
    userList.add(TestDataFactory.createUser(null,p.Id,null,'adminuser@hsb.com','adminuser@hsb.com',false));
    
    insert userList;
    List<Id> userIds = new List<Id>();
    List<Id> userIds1 = new List<Id>();
    
    /*// Create A Queue
    Group testQueue = new Group(Name='Default Queue', type='Queue');
    insert testQueue;
    */
    System.runAs(new User(Id = UserInfo.getUserId())){
    // Associate User to Public Group Created Earlier
    TestDataFactory.createPublicGroupMember(userList.get(0).Id,collectionGroup.Id,true);
    }
    
    System.runAs(userList.get(2)) {
    
    userIds1.add(userList.get(1).Id);
    userIds.add(userList.get(0).Id);
    Test.startTest();
      
      PublicGroupQueueManagementController controller = new PublicGroupQueueManagementController();
      // Get Groups To Search ( User can Search For Users and Public Group)
      System.assertEquals(controller.getGroupsToSearch().size(),2);
      // Load All Queues and Public Groups, Assert that Get Items return A list of size Greater than Zero
      System.assert(controller.getItems().size()>0);
     
      // Give Search Criteria as %, It should return all Users as we have not given SearchIn values, So By Default it will search for all users
      controller.searchCriteria='%';
      // Assert That Users are returned 
      controller.search();
      System.assert(controller.leftvalues.size()>0);
      
      //Assert that no user With name test
      controller.searchCriteria='randomstring';
      controller.search();
      System.assert(controller.leftvalues.size() == 0); 
      
      // Set the SearchIn for Groups
      controller.searchCriteria='%';
      controller.SearchIn = 'Public Groups';
      controller.search();
      // Assert that  Public Group is Returned
      System.assert(controller.leftvalues.size()>0);
     
      // Set Current GroupId of the Controller
      controller.g = collectionGroup.Id;
      controller.getGroupMembers(); 
      // Assert that GroupMembers are returned for CurrentGroup
      System.assert(controller.GroupMemberIds.size()>0);
     
      // Get Members Based on GroupMemberIds
      controller.SearchIn = 'Users';
      controller.getMembers();
      // Assert Member is Returned 
      System.assert(controller.rightvalues.size()>0); 
      
      controller.SearchIn = 'Public Groups';
      // Serach for The Group Now
      controller.getMembers(); 
      // Size should be Zero as we don't have any Public Group assigned to Group
      System.assert(controller.rightvalues.size()==0); 
      
      controller.rightSelected = userIds;
      //Assign the Users which are not assigned in the Group
      controller.leftSelected = userIds1;
      // Assert the Selected Values are not Null
      System.assert(controller.getSelectedValues()!=null);
      //Assert the Unselected Values is None, As we have values in leftSelected and Right Selected
      System.assertEquals(controller.getunSelectedValues().size(),0);
      
      // Assert that Options2 and Option3 doens't have values as we have less than 1000 items in Group/Queue/Users     
      System.assert(controller.getOptions2().size() == 0);
      System.assert(controller.getOptions3().size() == 0);
      
      //Assert that Selected Values in The Left is Added to Right Values
      controller.addClick();
      System.assert(controller.rightValues.contains(userIds1.get(0)));
     
      userIds.add(userList.get(0).Id);
      controller.rightSelected = userIds;
      controller.removeClick();
      //Assert that Selected Values in The right is Added to left Values
      System.assert(controller.leftValues.contains(userIds.get(0)));
     
      controller.save();
      System.assert(TestDataFactory.wasMessageAdded(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Your Changes has been saved Successfully!')));
      System.assert(controller.GoHome()!=null);
      
    Test.stopTest();
  }
 }
}