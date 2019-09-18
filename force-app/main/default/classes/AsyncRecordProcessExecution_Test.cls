@isTest
private class AsyncRecordProcessExecution_Test { 
    public static Switch_AccountTrigger__c sa;
    static {
        sa = new Switch_AccountTrigger__c (Set_Overall_Trigger_Off__c = True) ;
        insert sa;
    }
   
    private static testMethod void AsyncRecordProcessExecution_Test () {         
        MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();  
        mtduc.CreateDisabledTriggerSingle();
        mtduc.CreateBrokerAccountSingle();  
        mtduc.CreateProductSingle(); 
        Product_Restriction_Flag__c spl = mtduc.CreateProductRestrictionFlagSingle();
        Product_Restriction_Flag__c sple = mtduc.UpdateProductRestrictionFlagSingle();
        Product_Restriction_Flag__c sple1 = mtduc.UpdateProductRestrictionFlagSingle();   
        mtduc.DeleteProductRestrictionFlagSingle();
        
        test.startTest(); 
        AsyncRecordProcessExecution sh1 = new AsyncRecordProcessExecution ();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
      
    private static testMethod void AsyncRecordProcessExecution_Test1 () {  
        AsyncRecordProcessExecution__c arp = new AsyncRecordProcessExecution__c();
        arp.Name = 'Test'; 
        arp.Interface_Name__c = 'AssetTrigger';
        arp.ClassName__c = 'ProductExclusionTriggerHandler';
        arp.MethodName__c  = 'ExpireBrokerShowcaseAssetProductExclusion';
        arp.Records_To_Process_Ids__c = ('{sple.Id , sple1.Id , spl.Id }');
        arp.Boolean_Param__c = True;
        insert arp;  
        
        test.startTest(); 
        AsyncRecordProcessExecution sh1 = new AsyncRecordProcessExecution ();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
    
    private static testMethod void AsyncRecordProcessExecution_Test2 () {  
        AsyncRecordProcessExecution__c arp = new AsyncRecordProcessExecution__c();
        arp.Name = 'Test'; 
        arp.Interface_Name__c = 'AssetTrigger';
        arp.ClassName__c = 'ProductExclusionTriggerHandler';
        arp.MethodName__c  = 'DeleteProductExclusion';
        arp.Records_To_Process_Ids__c = ('{sple.Id , sple1.Id , spl.Id }');
        arp.Boolean_Param__c = True;
        insert arp; 
        
        test.startTest(); 
        AsyncRecordProcessExecution sh1 = new AsyncRecordProcessExecution ();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
    
    private static testMethod void AsyncRecordProcessExecution_Test3 () {    
        AsyncRecordProcessExecution__c arp1 = new AsyncRecordProcessExecution__c();
        arp1.Name = 'Test'; 
        arp1.Interface_Name__c = 'AssetTrigger';
        arp1.ClassName__c = 'ProductExclusionTriggerHandler';
        arp1.MethodName__c  = 'CreateUpdateAssetShowcaseProductExclusion';
        arp1.Records_To_Process_Ids__c = ('{sple.Id , sple1.Id , spl.Id }');
        arp1.Boolean_Param__c = True;
        insert arp1;  
        
        test.startTest(); 
        AsyncRecordProcessExecution sh1 = new AsyncRecordProcessExecution ();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
    private static testMethod void AsyncRecordProcessExecution_Test4 () {    
        AsyncRecordProcessExecution__c arp1 = new AsyncRecordProcessExecution__c();
        arp1.Name = 'Test'; 
        arp1.Interface_Name__c = 'AssetTrigger';
        arp1.ClassName__c = 'ProductExclusionTriggerHandler';
        arp1.MethodName__c  = 'ShowCaseOfficeAgentProductExclusion';
        arp1.Records_To_Process_Ids__c = ('{sple.Id , sple1.Id , spl.Id }');
        arp1.Boolean_Param__c = True;
        arp1.InterFace_Name__c='AssetTrigger';
        insert arp1;  
        
        test.startTest(); 
        AsyncRecordProcessExecution sh1 = new AsyncRecordProcessExecution ();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
    private static testMethod void AsyncRecordProcessExecution_Test5 () {   
        
        MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();  
        mtduc.CreateDisabledTriggerSingle();
        mtduc.CreateBrokerAccountSingle();  
        mtduc.CreateProductSingle(); 
        Product_Restriction_Flag__c spl = mtduc.CreateProductRestrictionFlagSingle();
        Product_Restriction_Flag__c sple = mtduc.UpdateProductRestrictionFlagSingle();
        Product_Restriction_Flag__c sple1 = mtduc.UpdateProductRestrictionFlagSingle();   
        mtduc.DeleteProductRestrictionFlagSingle();

        AsyncRecordProcessExecution__c arp1 = new AsyncRecordProcessExecution__c();
        arp1.Name = 'Test'; 
        arp1.Interface_Name__c = 'CaseTrigger';
        arp1.ClassName__c = 'CaseTriggerHandlerManager';
        arp1.MethodName__c  = 'AsyncaddRepToAccountTeamOnCaseClosure';
         arp1.Records_To_Process_Ids__c = ('{'+ sple.Id +','+ sple1.Id + ',' + spl.Id + '}');
       // arp1.Records_To_Process_Ids__c = ('{sple.Id , sple1.Id , spl.Id }');
        arp1.Boolean_Param__c = True;
        insert arp1;  
        
        test.startTest(); 
        AsyncRecordProcessExecution sh1 = new AsyncRecordProcessExecution ();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
    private static testMethod void AsyncRecordProcessExecution_Test6 () {
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
        mtduc.CreateBrokerAccountSingle();
        mtduc.CreateProductSingle();
        Asset spl1 = mtduc.CreateFullfilledAssetSingle();
        Asset spl2 = mtduc.CreateFullfilledAssetSingle();
        Asset spl3 = mtduc.CreateFullfilledAssetSingle();
          
        AsyncRecordProcessExecution__c arp1 = new AsyncRecordProcessExecution__c();
        arp1.Name = 'Test'; 
        arp1.Interface_Name__c = 'AssetTrigger';
        arp1.ClassName__c = 'AssetTriggerHelper';
        arp1.MethodName__c  = 'ProcessBackout';
        arp1.Records_To_Process_Ids__c = ('{spl1.Id , spl2.Id , spl3.Id }');
        arp1.Boolean_Param__c = True;
        insert arp1;  
        
        test.startTest(); 
        AsyncRecordProcessExecution sh1 = new AsyncRecordProcessExecution ();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
    private static testMethod void AsyncRecordProcessExecution_Test7 () {
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
         MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
         mtduc.CreateBrokerAccountSingle();
         mtduc.CreateOppurtunitySingle();
         BigMachines__Quote__c spl1 = mtduc.CreateOracleQuoteSingle();
         BigMachines__Quote__c spl2 = mtduc.CreateOracleQuoteSingle();
         BigMachines__Quote__c spl3 = mtduc.CreateOracleQuoteSingle();
               
        AsyncRecordProcessExecution__c arpe = new AsyncRecordProcessExecution__c();
        arpe.Name = 'Account Trigger';
        arpe.Interface_Name__c = 'AccountTrigger';
        arpe.ClassName__c = 'AccountTriggerHandlerManager';
        arpe.MethodName__c = 'AccountActivateEssentialStatus';
        arpe.Boolean_Param__c = true;
        arpe.Records_To_Process_Ids__c = ('{spl1.Id , spl2.Id , spl3.Id }');
        insert arpe;  
        
        test.startTest(); 
        AsyncRecordProcessExecution sh1 = new AsyncRecordProcessExecution ();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
    private static testMethod void AsyncRecordProcessExecution_Test8 () {
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
         MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
         mtduc.CreateBrokerAccountSingle();
         mtduc.CreateOppurtunitySingle();
         
               
        AsyncRecordProcessExecution__c arpe = new AsyncRecordProcessExecution__c();
        arpe.Name = 'OrderTrigger';
        arpe.Interface_Name__c = 'MergeServiceSOAP';
        arpe.ClassName__c = 'MergeServiceSOAP';
        arpe.MethodName__c = 'MergeObjects';
        arpe.Boolean_Param__c = true;
        arpe.Records_To_Process_Ids__c = ('sdfsdfs');
        insert arpe;  
        
        test.startTest(); 
        AsyncRecordProcessExecution sh1 = new AsyncRecordProcessExecution ();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
    private static testMethod void AsyncRecordProcessExecution_Test9 () {
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
         MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
         mtduc.CreateBrokerAccountSingle();
         mtduc.CreateOppurtunitySingle();
         
               
        AsyncRecordProcessExecution__c arpe = new AsyncRecordProcessExecution__c();
        arpe.Name = 'OrderTrigger';
        arpe.Interface_Name__c = 'orderTriggerHandlerManager';
        arpe.ClassName__c = 'orderTriggerHandlerManager';
        arpe.MethodName__c = 'AsyncupdateOfficeAccounts';
        arpe.Boolean_Param__c = true;
        arpe.Records_To_Process_Ids__c = ('sdfsdfs');
        insert arpe;  
        
        test.startTest(); 
        AsyncRecordProcessExecution sh1 = new AsyncRecordProcessExecution ();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
    
    private static testMethod void AsyncRecordProcessExecution_Test10 () {
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
         MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
         mtduc.CreateBrokerAccountSingle();
         mtduc.CreateOppurtunitySingle();
         
               
        AsyncRecordProcessExecution__c arpe = new AsyncRecordProcessExecution__c();
        arpe.Name = 'AssetTrigger';
        arpe.Interface_Name__c = 'AssetTriggerHandlerManager';
        arpe.ClassName__c = 'AssetTriggerHandlerManager';
        arpe.MethodName__c = 'AsyncOpportunityUpdate';
        arpe.Boolean_Param__c = true;
        arpe.Records_To_Process_Ids__c = ('sdfsdfs');
        insert arpe;  
        
        test.startTest(); 
        AsyncRecordProcessExecution sh1 = new AsyncRecordProcessExecution ();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
    private static testMethod void AsyncRecordProcessExecution_Test11 () {  
       
           MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();  
        mtduc.CreateDisabledTriggerSingle();
        mtduc.CreateBrokerAccountSingle();  
        mtduc.CreateProductSingle(); 
        Product_Restriction_Flag__c spl = mtduc.CreateProductRestrictionFlagSingle();
        Product_Restriction_Flag__c sple = mtduc.UpdateProductRestrictionFlagSingle();
        Product_Restriction_Flag__c sple1 = mtduc.UpdateProductRestrictionFlagSingle();   
        mtduc.DeleteProductRestrictionFlagSingle();
        AsyncRecordProcessExecution__c arp1 = new AsyncRecordProcessExecution__c();
        arp1.Name = 'Test'; 
        arp1.Interface_Name__c = 'CaseTrigger';
        arp1.ClassName__c = 'CaseTriggerHandlerManager';
        arp1.MethodName__c  = 'AsyncaddRepToAccountTeamOnCaseClosure';
     arp1.Records_To_Process_Ids__c = ('{'+ sple.Id +','+ sple1.Id + ',' + spl.Id + '}');
            //    arp1.Records_To_Process_Ids__c = ('{sple.Id , sple1.Id , spl.Id }');
        arp1.Boolean_Param__c = True;
        insert arp1;  
      
        
        test.startTest(); 
        AsyncRecordProcessExecution sh1 = new AsyncRecordProcessExecution ();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
}