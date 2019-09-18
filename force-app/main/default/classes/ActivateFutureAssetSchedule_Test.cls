@IsTest
public class ActivateFutureAssetSchedule_Test {

    public static testMethod void testschedule() {
        Test.StartTest();
        ActivateFutureAssetchedule sh1 = new ActivateFutureAssetchedule();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Activate Future Asset',sch,sh1);
        Test.stopTest(); 
    }
    //
    Public static testmethod void testschedules(){
    Integer COUNTER = 12;
        
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
         Renewal_Start_Date__c=system.today().addDays(-2),
            Start_Date__c=system.today(),
         End_Date__c =  system.today().addDays(-10),
         Status = 'Future Dated',
         Product_Type__c = 'Full',
         Lead_Type__c ='Fast Follow-Up',
         Commission_field__c='Calculate',
         Cancellation_Reason__c='Non-Payment',
         Commerce_Group__c='Agent Marketing Solution',
         Billing_Period__c='Monthly',
         Renewal_Status__c='Renew',
         Renewal_Type__c='Auto'
        ));
    }
    try{
      insert theTestAssets;
           
      }
     catch(exception e){}
       
        ActivateFutureAssetchedule sh1 = new ActivateFutureAssetchedule();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Activate Future Asset',sch,sh1);
        sh1.CatchExceptionProcessRemaining();
        Test.stopTest(); 
    
    }
 
}