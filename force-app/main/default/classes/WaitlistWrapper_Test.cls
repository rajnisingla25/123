@isTest
private class WaitlistWrapper_Test{
    private static Account newAccount;
    public static testMethod void main1(){
       DocuSignCredentials__c DocSignCredentials = new  DocuSignCredentials__c(AccountId__c='e7bee96b-5fcf-4d0d-8d67-c91349b4a2dd', UserId__c='ravinder4a2@gmail.com',  IntegratorsKey__c='MOVE-d2cdaebb-3c48-4868-a026-c9409ce57faf', Name='ravinder4a2@gmail.com', WebServiceUrl__c='https://demo.docusign.net/api/3.0/dsapi.asmx', Password__c='believe4a2');
        insert DocSignCredentials;
        //Inserting Customsetting for Account 
    	DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;  
        newAccount = new Account();
        newAccount.name = 'XYZ';
        newAccount.Phone = '+49-12345';
        newAccount.BillingStreet = 'Am Tierpark 16';
        newAccount.BillingCity = 'Cologne';
        newAccount.BillingPostalCode = '54321';
        newAccount.BillingState = 'GA';
        newAccount.BillingCountry = 'Germany';
        newAccount.Primary_Email__c = 'ra@gmail.com';
        newAccount.Home_Phone__c = '1234567890 ';
        newAccount.Work_Phone__c = '1234567890 ';
        newAccount.Mobile1__c = '1234567890 ';
        newAccount.Mobile2_Other__c = '1234567890 ';
        newAccount.party_id__c = '206084041';
        insert newAccount;
        
        contact c = new contact();
        c.lastname = 'test';
        c.accountid = newAccount.id;
        c.FirstName = 'ravi';
        c.Title = 'sath';
        c.email = 'ravi@gmail.com';
        c.Phone = '1234567895';
        c.MobilePhone = '1234567895';
        c.MailingState = 'California';
        c.MailingCountry = 'United States';
        c.MailingCity = 'knr';
        c.MailingStreet = 'test';
        c.MailingPostalCode = '524345';
        c.Preferred_Phone__c = '1234567890';
        c.Active__c=true;
        c.Type__c='Agent';
        insert c;
    	List <Waitlist__c> wl = new List<Waitlist__c>();
        for(integer i=0;i<3;i++)
        {
            Waitlist__c w = new Waitlist__c();
            w.Account__c = newAccount.id;
            w.Pre_Auth_Contact__c = c.id;
            w.Status__c = 'Created';
            w.Pre_Auth_Email__c = 'aj@gmail.com';        
            wl.add(w);
        }
        
        insert wl;
        
        DataController.Waitlist DW = new DataController.Waitlist();        
        DW.token = 'abc';
        DW.geo = 'asc';
        String sortdirection = 'asc';
        String sortbycolumn = 'status';
        String sortby = 'token asc';
        DataController.Waitlist DW1 = new DataController.Waitlist();        
        DW1.token = wl[1].Id;
        DW1.geo = 'asc';
        String sortdirection1 = 'asc';
        String sortbycolumn1 = 'status';
        String sortby1 = 'token asc';
        
        List<WaitlistWrapper> lstWaitlistWrapper = new List<WaitlistWrapper>();
        WaitlistWrapper obj1 = new WaitlistWrapper(DW1,sortbycolumn1,sortdirection1,sortby1);
        obj1.WL = DW1;
        WaitlistWrapper obj = new WaitlistWrapper(DW,sortbycolumn,sortdirection,sortby);
        obj.WL = DW;
        lstWaitlistWrapper.add(obj1);
        lstWaitlistWrapper.add(obj);
        lstWaitlistWrapper.sort();
        
        DW = new DataController.Waitlist();        
        DW.token = 'abc';
        DW.geo = 'asc';
        sortdirection = 'desc';
        sortbycolumn = 'geo';
        sortby = 'token desc';
        
        DW1 = new DataController.Waitlist();        
        DW1.token = wl[1].Id;
        DW1.geo = 'asc';
        sortdirection1 = 'desc';
        sortbycolumn1 = 'geo';
        sortby1 = 'token desc';
        
        lstWaitlistWrapper = new List<WaitlistWrapper>();
        obj1 = new WaitlistWrapper(DW1,sortdirection1,sortbycolumn1,sortby1);
        obj1.WL = DW1;
        obj = new WaitlistWrapper(DW,sortdirection,sortbycolumn,sortby);
        obj.WL = DW;
        lstWaitlistWrapper.add(obj1);
        lstWaitlistWrapper.add(obj);
        lstWaitlistWrapper.sort();
        
        DW = new DataController.Waitlist();        
        DW.token = wl[0].Id;
        DW.geo = 'desc';
        sortdirection = 'desc';
        sortbycolumn = 'geo';
        sortby = 'geo desc';
        
        DW1 = new DataController.Waitlist();        
        DW1.token = 'abc';
        DW1.geo = 'asc';
        sortdirection1 = 'desc';
        sortbycolumn1 = 'geo';
        sortby1 = 'geo desc';
        
        lstWaitlistWrapper = new List<WaitlistWrapper>();
        obj1 = new WaitlistWrapper(DW1,sortdirection1,sortbycolumn1,sortby1);
        obj1.WL = DW1;
        obj = new WaitlistWrapper(DW,sortdirection,sortbycolumn,sortby);
        obj.WL = DW;
        lstWaitlistWrapper.add(obj1);
        lstWaitlistWrapper.add(obj);
        lstWaitlistWrapper.sort();
        
        DW = new DataController.Waitlist();        
        DW.token = wl[0].Id;
        DW.geo = 'desc';
        sortdirection = 'desc';
        sortbycolumn = 'geo';
        sortby = 'geo asc';
        
        DW1 = new DataController.Waitlist();        
        DW1.token = 'abc';
        DW1.geo = 'asc';
        sortdirection1 = 'desc';
        sortbycolumn1 = 'geo';
        sortby1 = 'geo asc';
        
        lstWaitlistWrapper = new List<WaitlistWrapper>();
        obj1 = new WaitlistWrapper(DW1,sortdirection1,sortbycolumn1,sortby1);
        obj1.WL = DW1;
        obj = new WaitlistWrapper(DW,sortdirection,sortbycolumn,sortby);
        obj.WL = DW;
        lstWaitlistWrapper.add(obj1);
        lstWaitlistWrapper.add(obj);
        lstWaitlistWrapper.sort();
    }
    
    public static testMethod void main2(){
       DocuSignCredentials__c DocSignCredentials = new  DocuSignCredentials__c(AccountId__c='e7bee96b-5fcf-4d0d-8d67-c91349b4a2dd', UserId__c='ravinder4a2@gmail.com',  IntegratorsKey__c='MOVE-d2cdaebb-3c48-4868-a026-c9409ce57faf', Name='ravinder4a2@gmail.com', WebServiceUrl__c='https://demo.docusign.net/api/3.0/dsapi.asmx', Password__c='believe4a2');
        insert DocSignCredentials;
        //Inserting Customsetting for Account 
    	DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;  
        newAccount = new Account();
        newAccount.name = 'XYZ';
        newAccount.Phone = '+49-12345';
        newAccount.BillingStreet = 'Am Tierpark 16';
        newAccount.BillingCity = 'Cologne';
        newAccount.BillingPostalCode = '54321';
        newAccount.BillingState = 'GA';
        newAccount.BillingCountry = 'Germany';
        newAccount.Primary_Email__c = 'ra@gmail.com';
        newAccount.Home_Phone__c = '1234567890 ';
        newAccount.Work_Phone__c = '1234567890 ';
        newAccount.Mobile1__c = '1234567890 ';
        newAccount.Mobile2_Other__c = '1234567890 ';
        newAccount.party_id__c = '206084041';
        insert newAccount;
        
        contact c = new contact();
        c.lastname = 'test';
        c.accountid = newAccount.id;
        c.FirstName = 'ravi';
        c.Title = 'sath';
        c.email = 'ravi@gmail.com';
        c.Phone = '1234567895';
        c.MobilePhone = '1234567895';
        c.MailingState = 'California';
        c.MailingCountry = 'United States';
        c.MailingCity = 'knr';
        c.MailingStreet = 'test';
        c.MailingPostalCode = '524345';
        c.Preferred_Phone__c = '1234567890';
        c.Active__c=true;
        c.Type__c='Agent';
        insert c;
    	List <Waitlist__c> wl = new List<Waitlist__c>();
        for(integer i=0;i<3;i++)
        {
            Waitlist__c w = new Waitlist__c();
            w.Account__c = newAccount.id;
            w.Pre_Auth_Contact__c = c.id;
            w.Status__c = 'Created';
            w.Pre_Auth_Email__c = 'aj@gmail.com';        
            wl.add(w);
        }
        
        insert wl;
        
        DataController.Waitlist DW = new DataController.Waitlist();        
        DW.token = wl[0].Id;
        DW.status = 'abc';
        String sortdirection = 'desc';
        String sortbycolumn = 'geo';
        String sortby = 'status asc';
        
        DataController.Waitlist DW1 = new DataController.Waitlist();        
        DW1.token = 'abc';
        DW1.status = 'abcd';
        String sortdirection1 = 'desc';
        String sortbycolumn1 = 'geo';
        String sortby1 = 'status asc';
        
        List<WaitlistWrapper> lstWaitlistWrapper = new List<WaitlistWrapper>();
        WaitlistWrapper obj1 = new WaitlistWrapper(DW1,sortbycolumn1,sortdirection1,sortby1);
        obj1.WL = DW1;
        WaitlistWrapper obj = new WaitlistWrapper(DW,sortbycolumn,sortdirection,sortby);
        obj.WL = DW;
        lstWaitlistWrapper.add(obj1);
        lstWaitlistWrapper.add(obj);
        lstWaitlistWrapper.sort();
        
        DW = new DataController.Waitlist();        
        DW.token = wl[0].Id;
        DW.status = 'abc';
        sortdirection = 'desc';
        sortbycolumn = 'geo';
        sortby = 'status desc';
        
        DW1 = new DataController.Waitlist();        
        DW1.token = 'abc';
        DW.status = 'abcd';
        sortdirection1 = 'desc';
        sortbycolumn1 = 'geo';
        sortby1 = 'status desc';
        
        lstWaitlistWrapper = new List<WaitlistWrapper>();
        obj1 = new WaitlistWrapper(DW1,sortbycolumn1,sortdirection1,sortby1);
        obj1.WL = DW1;
        obj = new WaitlistWrapper(DW,sortbycolumn,sortdirection,sortby);
        obj.WL = DW;
        lstWaitlistWrapper.add(obj1);
        lstWaitlistWrapper.add(obj);
        lstWaitlistWrapper.sort();
    }
}