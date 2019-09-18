@isTest
public  class AssetCreateCPandLogin_Schedule_Test{
      Public static testmethod void testschedules(){
    Integer COUNTER = 1;        
         DisabledTrigger__c settings = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert settings;
   Account testAcc = TestDataFactory.createAccount('The Test Account', null, True);  
    test.startTest();
    List<Asset> theTestAssets = new List<Asset>();
    for(Integer index = 0; index < COUNTER; index++) {
        theTestAssets.add(new Asset(
         Name = 'Test Asset - ' + index,
         AccountId = testAcc.Id,
         Asset_Type__c='Parent',
         Get_CP_Login_Status__c = 'Ready',
         Fulfillment_Status__c = 'Fulfilled'
        ));
    }
    // insert theTestAssets;           
       //AssetCreateCPandLogin_Schedule sh1 = new AssetCreateCPandLogin_Schedule();
        String sch = '0 0 23 * * ?'; 
        //system.schedule('Test Activate Future Asset',sch,sh1);
        
        AssetCreateCPandLogin_Schedule sh1 = new AssetCreateCPandLogin_Schedule();
  String jobId = System.schedule('AssetCreateCPandLogin_ScheduleTest',
      sch, 
         new AssetCreateCPandLogin_Schedule());


  }
  Public static testmethod void testschedule(){
  
  }
}