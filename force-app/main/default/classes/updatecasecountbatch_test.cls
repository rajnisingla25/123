@isTest(seeAllData = false)
public class updatecasecountbatch_test {
    public static testMethod void main() {
        // Insert Custom Setting for Case Trigger
        Switch_CaseTrigger__c testSetting = new Switch_CaseTrigger__c(Set_Overall_Trigger_Off__c = True);
        insert testSetting;
        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c();
        Dtrg.Name = 'Disabled';
        Dtrg.TaskTrigger__c = 'Test@test.com';
        Dtrg.AssetTrigger__c = 'Test@test.com';
        insert Dtrg;
        
        //insert account
        id rectypid = [select id from RecordType where SobjectType = 'Account'
            and developerName = 'B2B'
        ].id;
        Account actdata = new Account();
        actdata.RecordTypeId = rectypid;
        actdata.Name = 'name';
        actdata.Type = 'Broker';
        actdata.Display_Name__c = 'Display Name';
        actdata.BillingCity = 'city';
        actdata.BillingCountry = 'country';
        actdata.BillingPostalCode = '30339';
        actdata.BillingState = 'state';
        actdata.BillingStreet = 'street';
        actdata.Email_Address__c = 's@s.com';
        actdata.Marketing_Emails__c = 's@s.com';
        actdata.MLS_Email__c = 's@s.com';
        actdata.Other1_Email__c = 's@s.com';
        actdata.Other2_Email__c = 's@s.com';
        actdata.Primary_Email__c = 's@s.com';
        insert actdata;
        system.debug('*************' + actdata);

        id cntctrectypid = [select id from RecordType where SobjectType = 'Contact'
            and name = 'Standard'
        ].id;
        
        
        //insert contact
        Contact cntctdata = new Contact();
        cntctdata.RecordTypeId = cntctrectypid;
        cntctdata.AccountId = actdata.Id;
        cntctdata.FirstName = 'firstname';
        cntctdata.LastName = 'lastname';
        cntctdata.email = 's@s.com';
        Insert cntctdata;
        
        //insert parent case
        Case parentcase = new case();
        parentcase.Type = 'FIND';
        parentcase.Status = 'New';
        parentcase.Area__c = 'Billing';
        parentcase.Origin = 'Email';
        parentcase.contactid = cntctdata.id;
        parentcase.Subject = 'test class subject';
        parentcase.Description = 'test class Description';
        insert parentcase;
        
        //insert child case
        Case childcase = new case();
        childcase.Type = 'FIND';
        childcase.Status = 'New';
        childcase.Parentid = parentcase.id;
        childcase.Area__c = 'Billing';
        childcase.Origin = 'Email';
        childcase.contactid = cntctdata.id;
        childcase.Subject = 'test class subject';
        childcase.Description = 'test class Description';
        insert childcase;

        Updatecasecountbatch bw = new Updatecasecountbatch();
        Test.startTest();
        ID batchprocessid = Database.executeBatch(bw);
        Test.stopTest();
    }
}