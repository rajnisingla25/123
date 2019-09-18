@isTest
private class ExpireOldAssetchedule_Test{
    private static final Integer COUNTER = 10;
    static testMethod void method1(){
     DisabledTrigger__c settings = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert settings;
   Error_Notification_Email_Settings__c emailSettings = new Error_Notification_Email_Settings__c(name='Email Addresses',  
                                                            Asset_Creation_Error_Emails__c='test@mailinator.com',View_Link__c='https://cs11.salesforce.com/02i?fcf=00BZ00000017ilI');
     insert emailSettings;   
   Account testAcc = TestDataFactory.createAccount('The Test Account', null, True);        
   
    test.startTest();
    List<Asset> theTestAssets = new List<Asset>();
    for(Integer index = 0; index < COUNTER; index++) {
        theTestAssets.add(new Asset(
         Name = 'Test Asset - ' + index,
         AccountId = testAcc.Id,
         Price = 10,       
         Auto_Renewal__c = 'Yes',
         Asset_Type__c='Parent',
        // Renewal_Start_Date__c=system.today(),
         End_Date__c =  system.today().addDays(-10),
         Status = 'Active'
        ));
    }
    try{
      insert theTestAssets;
      List<asset> lstAssete = New List<asset>();
        for(Asset ast: theTestAssets){
          ast.Fulfillment_Status__c = 'Pending Fulfillment';
          ast.Status = 'Expired';
          ast.Line_Type__c = 'Cancel';
        }
        if(lstAssete.size()>0){
         update lstAssete;
        }
           
      }catch(exception e){}
        
        ExpireOldAssetchedule sh1 = new ExpireOldAssetchedule();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
    static testMethod void method2(){
     DisabledTrigger__c settings = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert settings;
   Error_Notification_Email_Settings__c emailSettings = new Error_Notification_Email_Settings__c(name='Email Addresses',  
                                                            Asset_Creation_Error_Emails__c='test@mailinator.com',View_Link__c='https://cs11.salesforce.com/02i?fcf=00BZ00000017ilI');
     insert emailSettings;   
   Account testAcc = TestDataFactory.createAccount('The Test Account', null, True);        
   
    test.startTest();
    List<Asset> theTestAssets = new List<Asset>();
    for(Integer index = 0; index < COUNTER; index++) {
        theTestAssets.add(new Asset(
         Name = 'Test Asset - ' + index,
         AccountId = testAcc.Id,
         Price = 10,       
         Auto_Renewal__c = 'Yes',
         Asset_Type__c='Parent',
         Renewal_Start_Date__c=system.today(),
         End_Date__c =  system.today().addDays(-10),
         Status = 'Active'
        ));
    }
    try{
      insert theTestAssets;
      List<asset> lstAssete = New List<asset>();
        for(Asset ast: theTestAssets){
          ast.Fulfillment_Status__c = 'Pending Fulfillment';
          ast.Status = 'Created';
          ast.Line_Type__c = 'Cancel';
        }
        if(lstAssete.size()>0){
         update lstAssete;
        }
           
      }catch(exception e){}
        
        ExpireOldAssetchedule sh1 = new ExpireOldAssetchedule();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
}