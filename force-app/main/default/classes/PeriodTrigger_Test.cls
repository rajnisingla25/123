@isTest
public class PeriodTrigger_Test {
    public static testMethod void mainTest1() {    
    
          Commissions_TestDataFactory CT = new Commissions_TestDataFactory();
       
     Period__c period = Commissions_TestDataFactory.Createperiod('Test',true,Date.today().toStartOfMonth());
     Period__c period1 = Commissions_TestDataFactory.Createperiod('Test',true,System.Today().addMonths(-1));
     Period__c period2 = Commissions_TestDataFactory.Createperiod('Test',true,System.Today().addMonths(4));
     Period__c period3 = Commissions_TestDataFactory.Createperiod('Test',true,System.Today().addMonths(6));
 
 }
 
}