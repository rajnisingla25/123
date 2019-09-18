//Name        : MLSMergeController_Test 
//Description : Test class for MLSMergeController.
//Author      : Pallavi Tammana

@isTest(seeAllData =false)
public  class MLSMergeController_Test {

    public static testMethod void mainMethod1() {
    
        test.startTest();
        MLSMergeController mls = new MLSMergeController();
        PageReference pageRef = Page.MLSAssociationMerge;
        mls.redirect();
        Test.setCurrentPage(pageRef);
        //pageRef.getParameters().put('id',testOppty.id);
        //ApexPages.StandardController sc = new ApexPages.standardController(testOppty);
        List<SelectOption> options = mls.getInsertOptions();
        
    }
    
}