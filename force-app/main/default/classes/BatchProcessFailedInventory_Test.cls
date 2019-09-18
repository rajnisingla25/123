@isTest
public  class BatchProcessFailedInventory_Test
{
    static {
        BigMachines__Configuration_Record__c site = new BigMachines__Configuration_Record__c(BigMachines__Is_Active__c=true, BigMachines__action_id_copy__c='test', BigMachines__action_id_open__c='test', BigMachines__bm_site__c='test', BigMachines__document_id__c='test', BigMachines__process__c='test', BigMachines__process_id__c='test',BigMachines__version_id__c='test');
        insert site;
   }
      public static testmethod void Main1()
      {
        Integer COUNTER = 12;
        DisabledTrigger__c settings = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert settings;
        Schedule_Batch_Setting__c settingsbatch1 = new Schedule_Batch_Setting__c(Name= 'User process',Execution_Min__c=2,Is_Running__c=true,Execution_Time_hr__c = 22,Execution_End_Time_Hr__c = 23);
        insert settingsbatch1;
        Schedule_Batch_Setting__c settingsbatch2 = new Schedule_Batch_Setting__c(Name= 'Waitlist Expire Process',Execution_Min__c=2,Is_Running__c=true,Execution_Time_hr__c = 22,Execution_End_Time_Hr__c = 23);
        insert settingsbatch2;
        Schedule_Batch_Setting__c settingsbatch3 = new Schedule_Batch_Setting__c(Name= 'TCV Process',Execution_Min__c=2,Is_Running__c=true,Execution_Time_hr__c = 22,Execution_End_Time_Hr__c = 23);
        insert settingsbatch3;
        Schedule_Batch_Setting__c settingsbatch4 = new Schedule_Batch_Setting__c(Name= 'Update Account Primary Email Process',Execution_Min__c=1,Is_Running__c=true,Execution_Time_hr__c = 0,Execution_End_Time_Hr__c = 23);
        insert settingsbatch4;
        
       Account testAcc = TestDataFactory.createAccount('The Test Account', null, True);
       List<Inventory_Data__c> lstInventory = new List<Inventory_Data__c>();
          Inventory_Data__c Inv1 = new Inventory_Data__c();
          Inv1.Name = '878998';
          Inv1.Inventory_Count_Half__c = 5;
          Inv1.Error__c = true;
          lstInventory.add(Inv1);
          
          Inventory_Data__c Inv2 = new Inventory_Data__c();
          Inv2.Name = '878998';
          Inv2.Inventory_Count_Half__c = 3;
          Inv2.SOA_Error_Half_Count__c = 0;
          Inv2.SOA_Error_Full_Count__c = 0;
          Inv2.Error__c = true;
          lstInventory.add(Inv2);
          Insert lstInventory;
          List<Inventory_Account__c> lstInterestedMarket = new List<Inventory_Account__c>();
          Inventory_Account__c InterestedMarket1 = new Inventory_Account__c();
          InterestedMarket1.Inventory_Data__c = lstInventory[0].id;
          InterestedMarket1.Account__c = testAcc.id;
          lstInterestedMarket.add(InterestedMarket1);
          Insert InterestedMarket1;
          BatchProcessFailedInventory bps = new BatchProcessFailedInventory();
          DataBase.executeBatch(bps,2);
       }
       
 }