@isTest
public class batchToUpdateAllactAstsToActMLS_Test {
    static testmethod void test() {
        List<Account> accs = new List<Account>();
        List<MLS__c>  mlsList = new List<MLS__c>();
        List<Asset>  astList = new List<Asset>();
        List<Asset>  astListUpdate = new List<Asset>();
        
        DisabledTrigger__c disabledTriggerCustomSetting = new DisabledTrigger__c();
        disabledTriggerCustomSetting.Name = 'Disabled';
        disabledTriggerCustomSetting.AccountTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.AssetTrigger__c = 'testdatamigration@move.com.sit';
        insert disabledTriggerCustomSetting;
        
        Account testAccount = TestDataFactory.createAccount('Test Account', null, false);
        testAccount.Primary_Email__c = 'testAccount@move.com';
        testAccount.Party_ID__c = 'PartyId';
        testAccount.type = 'Realtor Office';
        accs.add(testAccount);
        if(!accs.isEmpty()){
            insert accs;
        }
        for(Account oacc:accs){
            if(oacc.type != null){
                MLS__c mlsInsert = new MLS__c();
                mlsInsert.Name = 'testMLS'+oacc.type;
                mlsInsert.MLS__c = oacc.ID;
                mlsInsert.Status__c  = 'Inactive';
                if(oacc.type == 'Realtor Office'){
                    mlsInsert.Office__c = oacc.ID;
                    mlsInsert.Primary_MLS_Set__c = false; 
                }
             mlsList.add(mlsInsert);     
            }
        }
        for(Account oacc:accs){
            if(oacc.type != null){
                MLS__c mlsInsert = new MLS__c();
                mlsInsert.Name = 'testMLS'+oacc.type;
                mlsInsert.MLS__c = oacc.ID;
                mlsInsert.Status__c  = 'active';
                if(oacc.type == 'Realtor Office'){
                    mlsInsert.Office__c = oacc.ID;
                    mlsInsert.Primary_MLS_Set__c = true; 
                }
                mlsList.add(mlsInsert);      
                system.debug('mlsList'+mlsList);
            }
        }
        if(!mlsList.isEmpty()){
            insert mlsList;
        }
        Asset asset2 = new Asset(Name = 'Asset2', 
                         status = 'Active',
                         Asset_Type__c = 'Participant', 
                         AccountId = testAccount.id, 
                         MLS_Set__c = mlsList[0].Id,
                         UsageEndDate = date.Today(), 
                         Start_Date__c = date.Today().addDays(-10), 
                         End_Date__c = date.Today().addDays(10));
        Asset asset3 = new Asset(Name = 'Asset3', 
                         status = 'Active',
                         Asset_Type__c = 'Participant', 
                         AccountId = testAccount.id, 
                         MLS_Set__c = mlsList[0].Id,
                         UsageEndDate = date.Today(), 
                         Start_Date__c = date.Today().addDays(-10), 
                         End_Date__c = date.Today().addDays(10));
        astList.add(asset2);
        astList.add(asset3);
        
        if(!astList.isEmpty()){
            Insert astList;
        }
        
       Test.StartTest();
       batchToUpdateAllActiveAssetsToActiveMLS amdp = new batchToUpdateAllActiveAssetsToActiveMLS();
       Database.executeBatch(amdp);
       //batchToUpdateAllActiveAssetsToActiveMLS.executeBatch();
       Test.StopTest();
       List<Asset> assetList = [select Id, MLS_Set__c from Asset where MLS_Set__c =:mlsList[1].Id];
       System.assertEquals(2, assetList.size());

    }
}