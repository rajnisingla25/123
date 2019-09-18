@isTest(seealldata = true)
//@isTest
public class Z_CreditBalanceAdjestmet_Test{
    
   
    
    static testMethod void TestScenario1(){
        Datetime Adjust = System.today();
        string adjustdate = string.valueof(Adjust).left(10);
        test.startTest();
        
            Z_CreditBalanceAdjestmet_Schedule.CreditAdjustment(adjustdate);
            Z_CreditBalanceAdjestmet_Schedule.updateSystemLogs( true , 'testmethod' );          
        test.stopTest();
    }
    }