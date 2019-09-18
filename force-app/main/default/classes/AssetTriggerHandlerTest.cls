@isTest(seeAllData=false)
public class AssetTriggerHandlerTest
{
    public static testmethod void testAsset() {
        OrderDecompController.stopCreatingAccount = true;
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Retention').getRecordTypeId();
        CaseRecordTypes__c crt = new CaseRecordTypes__c(name='Retention',Record_Type_Id__c=RecordTypeIdCase);
        insert crt;
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name = 'Disabled', TaskTrigger__c = 'Test@test.com', AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Switch_AssetTrigger__c srt = new Switch_AssetTrigger__c (Set_Overall_Trigger_Off__c = false);
        insert srt;
        Collection_Users__c coll = new Collection_Users__c(Name='batchintegration user', id__c= '005j000000CdBiE');
        insert coll;
        
        AssetTriggerHandler ath = new AssetTriggerHandler();
        Boolean Boolvar1 = ath.IsTriggerContext;
        Boolean Boolvar2 = ath.IsVisualforcePageContext;
        Boolean Boolvar3 = ath.IsWebServiceContext;
        Boolean Boolvar4 = ath.IsExecuteAnonymousContext;
        ath.ProcessTurboCancellation(null, null, null);
        
        MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
        Account a = mtduc.CreateBrokerAccountSingle();
        Product2 p = mtduc.CreateProductSingle();
        p.ProductCode = 'OPCITYCORE';
        p.Fulfillment_Required__c = true;
        update p;
        Contract c = mtduc.CreateContractSingle();
        Asset a1 = new Asset(Name = 'Test Asset1', Fulfillment_Status__c = 'Manual', AccountId = a.id, 
                            product2ID = p.ID, Status='In-Active',Line_Type__c = 'Add', Suppress_Welcome_Calls__c = false, Asset_Type__c ='Parent', 
                            Product_Type__c='Showcase',Credit_Status__c='In Progress', Contract__c = c.Id,ConfigOptions__c = 'withoutAgents',Record_Processed_for_commission__c = False);
        insert a1;
        SkipAssetTrigger.skiptrigger=false;
        Asset a2 = new Asset(Name = 'Test Asset1', Fulfillment_Status__c = 'Manual', AccountId = a.id, Parent_Asset__c=a1.Id,
                            Product2ID = p.ID, Status='In-Active',Line_Type__c = 'Add', Suppress_Welcome_Calls__c = false, Asset_Type__c ='Fulfill To', 
                            Product_Type__c='Showcase',Credit_Status__c='In Progress', Contract__c = c.Id,ConfigOptions__c = 'withoutAgents',Record_Processed_for_commission__c = False);
        insert a2;
        SkipAssetTrigger.skiptrigger=false;
        a2.Fulfillment_Status__c = 'Fulfilled';
        update a2;
        
    }
}