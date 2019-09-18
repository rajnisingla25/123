@isTest
public  class BatchProcessUserSalesLockE_Test{
    public static testMethod void mainMethod(){       
        
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Switch_AssetTrigger__c sc = new Switch_AssetTrigger__c (Set_Overall_Trigger_Off__c = True);
        insert sc; 
        Profile p = [select id from profile where name='Move Agent Sales Rep' limit 1];
         User theUser = new User(
            ProfileId = p.id,
            Alias = 'theUser',
            Email = 'sonusharmacs@gmail.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'First',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'kjhtfrdegsonusharmacs@gmail.com',
            Payout_Rate_Month_1__c=1,
            Payout_Rate_Month_2__c=2,
            Payout_Rate_Month_3__c=3,
            Team__c=Commissions_Constants.WLV_TERRITORY_TEAM,
            Managers__c ='ADRIAN MATTHEWS'
        );
   
      insert theUser;

       // BatchProcessUserSalesLockEligibility BCQCB = new BatchProcessUserSalesLockEligibility ();
       // Database.executeBatch(BCQCB,5);      

    }
    
    }