@isTest
private class MyWaitListTest_Test {

 @isTest(seeAllData=false) 
 static void testMyWaitListFunctionality() {
         
    PageReference pageRef = Page.MyWaitListTest;
    Test.setCurrentPageReference(pageRef); 
    MyWaitListTest controller = new MyWaitListTest();
    controller.searchstring= 'test';
    controller.getIndexes();
  }

}