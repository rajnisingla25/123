@IsTest(seealldata = false)
public class ExpirationAndRenewal_Schedular_Test {
  static testMethod  void ExpirationAndRenewal_Schedular_Execute_test1(){
  
      Test.StartTest();
            ExpirationAndRenewal_CreditJob_Schedular schInst1 = new ExpirationAndRenewal_CreditJob_Schedular();
            schInst1.currentMin = 2;
            schInst1.execute(null);

            
      Test.StopTest();
  }
   static testMethod  void ExpirationAndRenewal_Schedular_Execute_test2(){
  
      Test.StartTest();

            ExpirationAndRenewal_CreditJob_Schedular schInst2 = new ExpirationAndRenewal_CreditJob_Schedular();
            schInst2.currentMin = 8;
            schInst2.execute(null);

            
      Test.StopTest();
  }
   static testMethod  void ExpirationAndRenewal_Schedular_Execute_test3(){
  
      Test.StartTest();

            
            ExpirationAndRenewal_CreditJob_Schedular schInst3 = new ExpirationAndRenewal_CreditJob_Schedular();
            schInst3.currentMin = 14;
            schInst3.execute(null);
            
      Test.StopTest();
  }
     static testMethod  void ExpirationAndRenewal_Schedular_Execute_test4(){
  
      Test.StartTest();

            
            ExpirationAndRenewal_CreditJob_Schedular schInst4 = new ExpirationAndRenewal_CreditJob_Schedular();
            schInst4.currentMin = 1;
            schInst4.execute(null);
            
      Test.StopTest();
  }
      static testMethod  void ExpirationAndRenewal_Schedular_Execute_test5(){
  
      Test.StartTest();
             
               
            ExpirationAndRenewal_CreditJob_Schedular schInst5 = new ExpirationAndRenewal_CreditJob_Schedular();
            schInst5.currentHour=21;
            schInst5.currentMin = 20;
            schInst5.execute(null);
      Test.StopTest();
  }
   static testMethod  void ExpirationAndRenewal_Schedular_Execute_test6(){
  
      Test.StartTest();
             
               
            ExpirationAndRenewal_CreditJob_Schedular schInst6 = new ExpirationAndRenewal_CreditJob_Schedular();
            schInst6.currentHour=1;
            schInst6.currentMin = 20;
            schInst6.execute(null);
      Test.StopTest();
  }     
}