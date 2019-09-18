@isTest
private class ProcessOLIAssetJSONSchedulable_Test{
    static testMethod void method1(){
           //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg; 
        Asset assets = new Asset(
        Name = 'test',
        Fulfillment_Status__c = 'Waiting to Process',
        Status = 'In Active',
        Start_Date__c = system.today(),
        End_Date__c = system.today().addDays(10));
       insert Assets;    
        
  test.startTest();
        ProcessOLIAssetJSONSchedulable sh1 = new ProcessOLIAssetJSONSchedulable();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
   
  }
}