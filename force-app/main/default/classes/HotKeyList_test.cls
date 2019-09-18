/********************************************************************************************
*   @Author :       Srinidhi M 
*   @Purpose:       Test Class for HotkeyList 
*   @Class          HotKeyList
*   @TestClass      HotKeyList_Test
*   @JIRA           
*   @CreatedDate:   July 3rd, 2018
*********************************************************************************************
   JIRA No      Date       Modified By         Description                                Tag No
*********************************************************************************************

*/

@isTest
private class HotKeyList_test{  
    static testMethod void testMethod_Qt(){  
        QuickText qt=new QuickText();
        qt.Name='Add Listing Photos (R-ALP) ';
        qt.Category='Listing Issue';
        qt.Message='We have made it easy for you to add  photos to each of your listings on realtor.com photos/.';
        insert qt;
        
        Test.StartTest();
        //Creating Page Reference for VF page 
        PageReference pageRef = Page.QuickTextjavascript; 
        pageRef.getParameters().put('Id', String.valueOf(qt.Id));
        system.Test.setCurrentPage(pageRef);

        HotKeyList chl = new HotKeyList(); 
        Test.setCurrentPage(pageRef);

        Test.StopTest();
    }
    
    
}