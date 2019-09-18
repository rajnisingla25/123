@isTest (seeAllData=false)
Public class IncludeAssetstoAccountController_Test {
    @testSetup
    static void dataSetup() {
        //IncludeAssetstoAccountDetails__c setting = new IncludeAssetstoAccountDetails__c(name='IncludeAssetsToAccount',CBC_Record_Selection_Message__c='1', Default_Sort_Field__c='End_Date__c', Default_Sorting_Order__c='DESC', DML_Error_More_Than_10K_Records__c='2',No_Records_Found_Message__c='3', No_Selected_Assets_Message__c='4',Page_Size__c=100,Save_Success_Message__c='5',Uncheck_All_Message__c='6');
        //insert setting;
        Switch_AccountRelationshipTrigger__c arc = new Switch_AccountRelationshipTrigger__c(Name ='Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
        insert arc;     
        MoveTestDataUtilClass  mtduc = new MoveTestDataUtilClass();
        mtduc.CreateDisabledTriggerSingle();
        mtduc.CreateBrokerAccountSingle();
        mtduc.CreateRealtorOfficeAccountSingle();
        mtduc.CreateRealtorAgentAccountSingle();
        mtduc.CreateBrockerOfficeAccountRelationshipSingle();
        mtduc.CreateRealtorAgentAccountRelationshipSingle();
        mtduc.CreateProductSingle();
        mtduc.CreatePricebookEntrySingle();
        mtduc.CreateFullfilledAssetSingle();
        mtduc.CreateFulfilltoFullfilledAssetSingle();
        mtduc.CreateParticipantFulfilltoFullfilledAssetSingle();
        ApexPages.CurrentPage().getparameters().put('id', mtduc.newAccount.Id);
        
    }
    
    static testMethod void testSearch1() {
        Test.StartTest();
        IncludeAssetstoAccountController obj = new IncludeAssetstoAccountController();
       // obj.StartDateBegin = '7/16/17';
      //  obj.StartDateEnd = '12/16/17';
       // obj.EndDateBegin = '7/15/18';
       // obj.EndDateEnd = '12/15/18';
        obj.search();
        Test.StopTest();        
    }
    
    
     static testMethod void testSearch3() {
        Test.StartTest();
        ApexPages.CurrentPage().getparameters().put('id', '123');
        IncludeAssetstoAccountController obj = new IncludeAssetstoAccountController();
       IncludeAssetstoAccountController.StartDateBegin = system.today().addmonths(-12);
       IncludeAssetstoAccountController.StartDateEnd = system.today().addmonths(-6);
       IncludeAssetstoAccountController.EndDateBegin = system.today().addmonths(6);
       IncludeAssetstoAccountController.EndDateEnd = system.today().addmonths(12);
        obj.assetNumber = 'A-01588548';
        obj.market = '50078';
        obj.search();
        Test.StopTest();    
    }
    static testMethod void testSearch4() {
        Test.StartTest();        
        IncludeAssetstoAccountController obj = new IncludeAssetstoAccountController();
       IncludeAssetstoAccountController.StartDateBegin = system.today().addmonths(-12);
       IncludeAssetstoAccountController.StartDateEnd = system.today().addmonths(-6);
       IncludeAssetstoAccountController.EndDateBegin = system.today().addmonths(6);
       IncludeAssetstoAccountController.EndDateEnd = system.today().addmonths(12);
        obj.assetNumber = 'A-01588548';
        obj.market = '50078';
        obj.search();
        IncludeAssetstoAccountController.getStringDate(date.today());
        
        Test.StopTest();    
    }

    static testMethod void testSearch2() {
    
    Test.StartTest();
        IncludeAssetstoAccountController obj = new IncludeAssetstoAccountController();
         obj.assetNumber = 'A-0123456678';
        obj.market = '56678';
        obj.search();
        Test.StopTest(); 
    }
    
    static testMethod void testCheckUnCheckActiveSuspendedCBC() {
        Test.StartTest();
        MoveTestDataUtilClass  mtduc = new MoveTestDataUtilClass();
        mtduc.CreateDisabledTriggerSingle();
        mtduc.CreateBrokerAccountSingle();
        mtduc.CreateRealtorOfficeAccountSingle();
        mtduc.CreateRealtorAgentAccountSingle();
        mtduc.CreateBrockerOfficeAccountRelationshipSingle();
        mtduc.CreateRealtorAgentAccountRelationshipSingle();
        mtduc.CreateProductSingle();
        mtduc.CreatePricebookEntrySingle();
        mtduc.CreateFullfilledAssetSingle();
        mtduc.CreateFulfilltoFullfilledAssetSingle();
        mtduc.CreateParticipantFulfilltoFullfilledAssetSingle();
        ApexPages.CurrentPage().getparameters().put('id', mtduc.newAccount.Id);
        IncludeAssetstoAccountController obj = new IncludeAssetstoAccountController();
        obj.search();
        obj.checkSuspendedCBC();
        obj.checkActiveCBC();
        obj.checkActiveLocalExperts();
        obj.unCheckAllAssets();
        boolean b = obj.hasNext;
        b = obj.hasPrevious;
        obj.first();
        obj.last();
        obj.save();
        obj.previous();
        obj.next();
        
     
        Test.StopTest();
         
    }
}