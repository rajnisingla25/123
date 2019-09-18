@isTest(seeAllData=false)
public class WaitlistItemtrigger_Test{
    public static testMethod void main(){
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
            insert Dtrg;
        id rectypid = [select id from RecordType where SobjectType = 'Account' and name = 'B2B'].id;
        Account actdata = new Account();
        actdata.RecordTypeId  = rectypid;
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

        id cntctrectypid = [select id from RecordType where SobjectType = 'Contact' and name = 'Standard'].id;
        Contact cntctdata = new Contact();
        cntctdata.RecordTypeId = cntctrectypid;
        cntctdata.AccountId = actdata.Id;
        cntctdata.FirstName = 'firstname';
        cntctdata.LastName = 'lastname';
        cntctdata.email = 's@s.com';
        Insert cntctdata;
        
        Waitlist__c wldata = new Waitlist__c();
        wldata.Account__c = actdata.id;
        wldata.Status__c = 'Created';
        wldata.Pre_Auth_Contact__c = cntctdata.Id;
        wldata.Pre_Auth_Email__c = cntctdata.Email;
        Insert wldata;
        
        Product2 prdctdata = new Product2();
        prdctdata.Name = 'product name';
        prdctdata.S_No__c = 2;
        insert prdctdata;
        
        Waitlist_Item__c wlidata1 = new Waitlist_Item__c();
        wlidata1.Waitlist__c    = wldata.Id;
        wlidata1.Waitlist_ID__c = '1234'; 
        wlidata1.Waitlist_Expiration_Date__c  = system.today();
        wlidata1.Original_Max_Spend__c = 100;
        wlidata1.Status__c = 'Pending Pre-Auth';
        wlidata1.Account__c = actdata.id;
        wlidata1.Product__c = prdctdata.id;
        wlidata1.Market__c = '30339';
        wlidata1.Market_Type__c = 'City';
        wlidata1.Product_Size__c = 'Full';
        wlidata1.rank__c = 0;
        insert wlidata1;
        
        Waitlist_Item__c wlidata2 = new Waitlist_Item__c();
        wlidata2.Waitlist__c    = wldata.Id;
        wlidata2.Waitlist_ID__c = '1234'; 
        wlidata2.Waitlist_Expiration_Date__c  = system.today();
        wlidata2.Original_Max_Spend__c = 100;
        wlidata2.Status__c = 'Active';
        wlidata2.Account__c = actdata.id;
        wlidata2.Product__c = prdctdata.id;
        wlidata2.Market__c = '30339';
        wlidata2.Market_Type__c = 'City';
        wlidata2.Product_Size__c = 'Full';
        wlidata2.rank__c = 1;
        insert wlidata2;
        
        Waitlist_Item__c wlidata3 = new Waitlist_Item__c();
        wlidata3.Waitlist__c    = wldata.Id;
        wlidata3.Waitlist_ID__c = '1234'; 
        wlidata3.Waitlist_Expiration_Date__c  = system.today();
        wlidata3.Original_Max_Spend__c = 100;
        wlidata3.Status__c = 'Active';
        wlidata3.Account__c = actdata.id;
        wlidata3.Product__c = prdctdata.id;
        wlidata3.Market__c = '30339';
        wlidata3.Market_Type__c = 'City';
        wlidata3.Product_Size__c = 'Full';
        wlidata3.rank__c = 0;
        insert wlidata3;

        Waitlist_Item__c wlidata4 = new Waitlist_Item__c();
        wlidata4.Waitlist__c    = wldata.Id;
        wlidata4.Waitlist_ID__c = '1234'; 
        wlidata4.Waitlist_Expiration_Date__c  = system.today();
        wlidata4.Original_Max_Spend__c = 100;
        wlidata4.Status__c = 'Active';
        wlidata4.Account__c = actdata.id;
        wlidata4.Product__c = prdctdata.id;
        wlidata4.Market__c = '30339';
        wlidata4.Market_Type__c = 'City';
        wlidata4.Product_Size__c = 'Full';
        wlidata4.rank__c = 0;
        insert wlidata4;
        
        List<SObject> updatewli = new List<SObject>();
        wlidata1.Status__c = 'Active';
        updatewli.add(wlidata1);
        wlidata2.Status__c = 'Fulfilled';
        updatewli.add(wlidata2);
        
        Test.startTest();
        update updatewli;
        Test.stopTest();
    }
}