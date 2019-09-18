@isTest
public class SelectPresentedClidByTableAreaCode_Test
{
	static testMethod void testSelectPresentedClidByTableAreaCode()
    {
        List<NVMContactWorld__CLID_Prefix_Mapping__c> lstMapping = new List<NVMContactWorld__CLID_Prefix_Mapping__c>();
        NVMContactWorld__CLID_Prefix_Mapping__c prefixMapping = new NVMContactWorld__CLID_Prefix_Mapping__c();
        prefixMapping.Name = 'a4jf1000000laOU';
        prefixMapping.NVMContactWorld__Call_Recording_Enabled__c = true;
        prefixMapping.NVMContactWorld__Prefix__c = '201';
        prefixMapping.NVMContactWorld__Presented_CLID__c = '+12014742397';
        lstMapping.add(prefixMapping);
        
        prefixMapping = new NVMContactWorld__CLID_Prefix_Mapping__c();
        prefixMapping.Name = 'a4jf1000000laRT';
        prefixMapping.NVMContactWorld__Call_Recording_Enabled__c = true;
        prefixMapping.NVMContactWorld__Prefix__c = '202';
        prefixMapping.NVMContactWorld__Presented_CLID__c = '+12014742398';
        lstMapping.add(prefixMapping);
        
        prefixMapping = new NVMContactWorld__CLID_Prefix_Mapping__c();
        prefixMapping.Name = 'a4jf1000000laOV';
        prefixMapping.NVMContactWorld__Call_Recording_Enabled__c = true;
        prefixMapping.NVMContactWorld__Prefix__c = '212';
        prefixMapping.NVMContactWorld__Presented_CLID__c = '+12024742398';
        lstMapping.add(prefixMapping);
        
        List<Call_Prefix_Mapping__c> lstCallPrefixMapping = new List<Call_Prefix_Mapping__c>();
        Call_Prefix_Mapping__c callPrefixMapping = new Call_Prefix_Mapping__c();
        callPrefixMapping.Name = '020';
        callPrefixMapping.Call_Recording_Enabled__c = true;
        callPrefixMapping.Presented_Callback_Number__c = '202';
        callPrefixMapping.Description__c = '+12024742399';
        lstCallPrefixMapping.add(callPrefixMapping);
        
        callPrefixMapping = new Call_Prefix_Mapping__c();
        callPrefixMapping.Name = '201';
        callPrefixMapping.Call_Recording_Enabled__c = true;
        callPrefixMapping.Presented_Callback_Number__c = '202';
        callPrefixMapping.Description__c = '+12024742399';
        lstCallPrefixMapping.add(callPrefixMapping);
        
        callPrefixMapping = new Call_Prefix_Mapping__c();
        callPrefixMapping.Name = '217';
        callPrefixMapping.Call_Recording_Enabled__c = true;
        callPrefixMapping.Presented_Callback_Number__c = '202';
        callPrefixMapping.Description__c = '+12024742399';
        lstCallPrefixMapping.add(callPrefixMapping);
        
        insert lstMapping;
        insert lstCallPrefixMapping;
        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        Account parentAccount = TestDataFactory.createAccount('Parent Account1', userinfo.getUserId(), true);
        parentAccount.Primary_Email__c = 'testSender@move.com';
        parentAccount.Type = 'Broker';
        parentAccount.Party_ID__c  = '12345';
        parentAccount.Customer_Id__c  = '12345';
        //parentAccount.BillingPostalCode  = '12345';
        //parentAccount.BillingCity = 'newyork';
        parentAccount.MLS_Set_Id__c  = '12345';    
        parentAccount.Advertiser_Email__c = 'testSender@move.com';
        parentAccount.Account_sub_type__c = 'Customer';
        upsert parentAccount;  
        
        Lead theLead = TestDataFactory.CreateLead('Test', 'Test', 'New', parentAccount.Id, null, 'Test', false); 
        theLead.Ignore_Owner_Assignment__c = 'No';
        theLead.Status = 'New';
        insert theLead;
        
        SelectPresentedClidByTableAreaCode objSelectAreaCode = new SelectPresentedClidByTableAreaCode();
        objSelectAreaCode.randomWithLimit(1);
        objSelectAreaCode.GetPresentedClid('{"number": "+10201703585", "objectId": "' +parentAccount.Id+'"}');
        objSelectAreaCode.GetPresentedClid('{"number": "+1.2017035885"}');
        objSelectAreaCode.GetPresentedClid('{"number": "+1201703585"}');
        objSelectAreaCode.GetPresentedClid('{"number": "+1(201,703,5885)"}');
        objSelectAreaCode.GetPresentedClid('{"number": "+44202035885"}');
        objSelectAreaCode.GetPresentedClid('{"number": "+21202035885"}');
        
        objSelectAreaCode.GetPresentedClid('{"number": "+10301703585"}');
        objSelectAreaCode.GetPresentedClid('{"number": "+1.4017035885"}');
        objSelectAreaCode.GetPresentedClid('{"number": "+1(501,703,5885)"}');
        objSelectAreaCode.GetPresentedClid('{"number": "+44602035885"}');
        objSelectAreaCode.GetPresentedClid('{"number": "+21702035885"}');
    }
}