@isTest
private class LegacyProsoftBundleFlagupdate_test
{
 static testmethod void schedulerTest() 
    {
   list<Asset> Astlist = new list<Asset>();
  list<Asset> Astlist1 = new list<Asset>();
    Account account = Z_LegacyTestFactory.makeAccount(); 
        String CRON_EXP = '0 0 0 15 3 ? *';
  DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name = 'Disabled', TaskTrigger__c = 'Test@test.com', AssetTrigger__c = 'Test@test.com');
    insert Dtrg;
  System.assertNotEquals(null, Dtrg.Id);

      List < Product2 > productList = new list < Product2 > ();
       productList.add(new Product2(Name = 'H00-062', Family = 'Prosoft', ProductCode = 'TOPCRM', S_No__c = 1));
       productList.add(new Product2(Name = 'H00-062', Family = 'Prosoft', ProductCode = 'FIVESTREET', S_No__c = 1));
       productList.add(new Product2(Name = 'H00-062', Family = 'Prosoft', ProductCode = 'TOPMRKSNP', S_No__c = 1));
        insert productList;
        for(integer i=0;i<=2;i++){
            Asset Ast = new Asset(Name = 'Tst'+i,AccountId = account.id,
                              Fulfillment_status__c = 'Fulfilled',Is_Bundled__c = False,Promotion__c = 'Testpromo'+i,Total_Discount__c =100+i,Combined_Discount_Percent__c = 99-i,Line_Type__c = 'Add',Status ='Active',Product2ID = productList[i].ID,Asset_Type__c = 'Parent');
            Astlist.add(Ast);
        }
        insert Astlist;
        for(integer i=0;i<=2;i++){
            Asset Ast = new Asset(Name = 'Test'+i,AccountId = account.id,
                              Fulfillment_status__c = 'Fulfilled',Is_Bundled__c = False,Promotion__c = 'Testpromo'+i,Combined_Discount__c =100+i,Combined_Discount_Percent__c = 99-i,Line_Type__c = 'Renew',Status ='Active',Product2ID = productList[i].ID,Asset_Type__c = 'Parent');
            Astlist1.add(Ast);
        }
        insert Astlist1;
       
        Test.startTest();

            String jobId = System.schedule('LegacyProsoftBundleFlagupdateTest',  CRON_EXP, new LegacyProsoftBundleFlagupdate());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);
          System.assertEquals(False, Astlist[0].Is_Bundled__c);
          System.assertEquals(False, Astlist1[0].Is_Bundled__c);
        Test.stopTest();
        
    }
}