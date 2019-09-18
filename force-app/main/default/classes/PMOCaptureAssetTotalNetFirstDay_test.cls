@IsTest
private class PMOCaptureAssetTotalNetFirstDay_test{
    static testMethod void runtest(){
        DisabledTrigger__c dt = new DisabledTrigger__c();
        dt.Name='Disabled';
        dt.TaskTrigger__c = 'test@test.com';
        dt.AssetTrigger__c = 'test@test.com';
        dt.AccountTrigger__c = 'test@test.com';
        insert dt;
            
        Asset a = new Asset();
        a.Name = 'TestAsset';
        a.End_Date__c = System.today();
        a.Total_Net__c = 100;
        insert a;
        
        PMOCaptureAssetTotalNetFirstDay p = new PMOCaptureAssetTotalNetFirstDay();
        Database.executeBatch(p);
    }
}