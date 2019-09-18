@isTest
global class Commissions_QuotaupdateSchClass_Test {
    static testMethod void method1(){
        Profile p = [select id from profile where name='System Administrator'];
       
        User user1 = Commissions_TestDataFactory.createUser(null,p.id,null,'test154@move.com','test154@move.com',false,'WLV Territory Team');
        user1.Vacation_Start_Date__c = Date.today();
        user1.Vacation_End_Date__c = Date.today();
        user1.managers__c = 'First Name';
        insert user1;     
        Quota__c  QuotaHandler = Commissions_TestDataFactory.CreateQuota(user1.id,null,false);
        QuotaHandler.Target_Amount__c = 1000;
        QuotaHandler.User_Team__c = user1.team__c;
        QuotaHandler.Record_Processed__c = true;
            
        insert QuotaHandler;        
      test.startTest();
        Commissions_QuotaupdateSchClass sh1 = new Commissions_QuotaupdateSchClass ();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
    Test.stopTest();
  }
}