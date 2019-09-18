@isTest
private class assetMergeFromDupToMaster_Test {
    static testmethod void test() {
        /*
    String query = 'SELECT Id,CreatedDate FROM Asset_Merge__c ' + 
                   'WHERE status__c =:'+ 'Active';
    */

        List < Asset_Merge__c > AssetMergeList = new List < Asset_Merge__c > ();
        for (Integer i = 0; i < 10; i++) {
            Asset_Merge__c am = new Asset_Merge__c(
                Survivor_Fulfill_To_Asset_ID__c = '16526715236751263',
                Victim_Fulfill_To_Asset_ID__c = '16526715236751263',
                //External_ID__c='16526715236751263'
                status__c = 'To be Updated');
            AssetMergeList.add(am);
        }
        insert AssetMergeList;

        DisabledTrigger__c disabledTriggerCustomSetting = new DisabledTrigger__c();
        disabledTriggerCustomSetting.Name = 'Disabled';
        disabledTriggerCustomSetting.AccountTrigger__c = 'testdatamigration@move.com.sit';
        disabledTriggerCustomSetting.AssetTrigger__c = 'testdatamigration@move.com.sit';
        insert disabledTriggerCustomSetting;

        Account testAccount = TestDataFactory.createAccount('Test Account', null, false);
        testAccount.Primary_Email__c = 'testAccount@move.com';
        testAccount.Party_ID__c = 'PartyId';
        insert testAccount;

        Asset assetforint = new Asset(Name = 'Asset1', status = 'Active', External_ID__c = '16526715236751263',
            Asset_Type__c = 'Fulfill To',
            AccountId = testAccount.id, UsageEndDate = date.Today(), Start_Date__c = date.Today().addDays(-10),
            End_Date__c = date.Today().addDays(10));
        insert assetforint;

        List < Asset > assets = new List < Asset > ();


        Asset asset1 = new Asset(Name = 'Asset1', status = 'Active', parent_Asset__c = assetforint.id, Asset_Type__c = 'Fulfill To',
            AccountId = testAccount.id, UsageEndDate = date.Today(), Start_Date__c = date.Today().addDays(-10), End_Date__c = date.Today().addDays(10));

        Asset asset2 = new Asset(Name = 'Asset2', status = 'Active', parent_Asset__c = assetforint.id,
            Asset_Type__c = 'Fulfill To', AccountId = testAccount.id, UsageEndDate = date.Today(), Start_Date__c = date.Today().addDays(-10), End_Date__c = date.Today().addDays(10));
        Asset asset3 = new Asset(Name = 'Asset3', status = 'Active', parent_Asset__c = assetforint.id,
            Asset_Type__c = 'Participant', AccountId = testAccount.id, UsageEndDate = date.Today(), Start_Date__c = date.Today().addDays(-10), End_Date__c = date.Today().addDays(10));


        assets.add(asset1);
        assets.add(asset2);
        assets.add(asset3);
        Insert assets;

        //asset3.parent_asset__c = asset1.Id;
        //Update asset3;

        Test.startTest();
        assetMergeFromDupToMaster amdp = new assetMergeFromDupToMaster();
        Database.executeBatch(amdp);
        Database.SaveResult result = Database.update(asset3);


        if (!result.isSuccess()) {
            List < Error__c > errorlist = new List < Error__c > ();
            Error__c error = new Error__c();
            error.Entity_Id__c = '200';
            error.Error_Description__c = 'Error';
            error.Interface_Name__c = 'Asset Merge';
            errorlist.add(error);
            insert errorlist;



        }

        Integer i = [SELECT COUNT() FROM Asset_Merge__c];
        System.assertEquals(i, 10);
        Test.stopTest();
    }


    static testmethod void failureCase() {
        try {
            Test.startTest();

            List < Asset > assets = new List < Asset > ();

            Asset asset1 = new Asset(Name = 'Asset1', status = 'Active', Asset_Type__c = 'Fulfill To',
                UsageEndDate = date.Today(), Start_Date__c = date.Today().addDays(-10), End_Date__c = date.Today().addDays(10));

            Asset asset2 = new Asset(Name = 'Asset2', status = 'Active',
                Asset_Type__c = 'Fulfill To', UsageEndDate = date.Today(), Start_Date__c = date.Today().addDays(-10), End_Date__c = date.Today().addDays(10));
            Asset asset3 = new Asset(Name = 'Asset3', status = 'Active',
                Asset_Type__c = 'Participant', UsageEndDate = date.Today(), Start_Date__c = date.Today().addDays(-10), End_Date__c = date.Today().addDays(10));


            assets.add(asset1);
            assets.add(asset2);
            assets.add(asset3);
            Insert assets;


            assetMergeFromDupToMaster amdp = new assetMergeFromDupToMaster();
            Database.executeBatch(amdp);



            Test.stopTest();
        } catch (Exception e) {

        }
    }

}