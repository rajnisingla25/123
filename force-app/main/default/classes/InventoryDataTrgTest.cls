@istest
public class InventoryDataTrgTest {

    public static testMethod void test1(){
         DisabledTrigger__c Dtrg = new DisabledTrigger__c();
        Dtrg.Name = 'Disabled';
        Dtrg.TaskTrigger__c = 'Test@test.com';
        Dtrg.AssetTrigger__c = 'Test@test.com';
        insert Dtrg;
        
        Inventory_Data__c id = new Inventory_Data__c(
               name='1789',
               Median_Market_Price__c=45454.00
               );
        insert id;
        id.City__c = 'Sunnyvale';
        update id;
    }
}