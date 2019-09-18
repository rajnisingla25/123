@isTest
public class OrderResendEmailHandler_test{

    static testmethod void method1(){  
        DisabledTrigger__c Dtrg = new DisabledTrigger__c();
        Dtrg.Name= 'Disabled';
        Dtrg.TaskTrigger__c = 'Test@test.com';
        Dtrg.AssetTrigger__c = 'Test@test.com';
        insert Dtrg;
      Switch_AccountRelationshipTrigger__c art = new Switch_AccountRelationshipTrigger__c(name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
      insert art;    
    
        MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();  
        mtduc.CreateBrokerAccountSingle();
        mtduc.CreateOppurtunitySingle();
        
        test.startTest();   
        OrderResendEmailHandler.UpdateSentEmailFlagQuote(mtduc.CreateOracleQuoteSingle().id);
        OrderResendEmailHandler.UpdateSentEmailFlag(mtduc.CreateOrderSingle().id);
        Test.stopTest();     
    }
}