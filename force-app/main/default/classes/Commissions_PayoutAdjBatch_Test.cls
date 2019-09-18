@isTest(seeAllData = false)
public class Commissions_PayoutAdjBatch_Test {
    /**
    public static testMethod void mainTest() {
       
         Profile p = [select id from profile where name='System Administrator'];
       
        Commissions_TestDataFactory CT = new Commissions_TestDataFactory();
        User user1 = Commissions_TestDataFactory.createUser(null,p.id,null,'test154@move.com','test154@move.com',true,'Broker Regional Directors sales Team');
     
      //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg; 
       
        id rectypidaccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        string type = Constants.OFFICE_ACCOUNT_TYPE;
        Account Acc = Commissions_TestDataFactory.createAccount('Name','theAcc@move.com',rectypidaccount,type,true);
      
        Period__c period = Commissions_TestDataFactory.Createperiod('Test',True,Date.today().toStartOfMonth());
       
        Quota__c  QuotaHandler = Commissions_TestDataFactory.CreateQuota(user1.id,period.id,true);
        Map<Id,Quota__c> currentMonthQuota =new Map<Id,Quota__c>();
        currentMonthQuota.put(QuotaHandler.id,QuotaHandler);        
        
        
        Date currentMonthDate =  Date.today(); 
        Date monthStartDate = currentMonthDate.toStartOfMonth();
        Date monthEndDate = monthStartDate.addDays(date.daysInMonth(currentMonthDate.year(),currentMonthDate.month()) - 1);
        
       // Payment_History__c ph= Commissions_TestDataFactory.CreatePaymentHistory('Name',user1.id,acc.id,true);
       
      //  Map<Id,Payment_History__c> PaymentHistory = new Map<Id,Payment_History__c>();
      //  PaymentHistory.put(ph.id,ph);
        
        Product2 prdctdata = Commissions_TestDataFactory.CreateProduct('Name',true);
        String RDTeam = Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM;
        
        id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get(RDTeam).getRecordTypeId(); 
        Payout__c pa= Commissions_TestDataFactory.CreatePayout('Component 1',rectypidp, null, null,10.00,100.00,2.25,1.05,2.02,3.00,true  );
        
        id rectypidq = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Payroll Adjustment').getRecordTypeId();  
        Commission__c  comm = Commissions_TestDataFactory.CreateComm(QuotaHandler.Id, prdctdata.Id,rectypidq,null,true);
      
        List<commission__c> comList = new List<commission__c>();
        comList.add(comm);
        
        Map<Id,List<commission__c>> mapUserCommissionList = new Map<Id,List<commission__c>>();
        mapUserCommissionList.put(comm.id,comList);

        Commissions_PayoutAdjBatch co = new Commissions_PayoutAdjBatch();
        Test.startTest();
       Database.executeBatch(co,200);
        Test.stopTest();
  
    }
    **/
    
}