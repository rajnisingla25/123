@isTest(Seealldata = false)
private class VoidDocuSign_Test{
    public static testMethod void main1(){
        
        Profile p = [select id from profile where name='Move Data Integration'];
        User u = new User(alias = 'standt', email='standarduser@testorg.com',
                          emailencodingkey='UTF-8', lastname='Someone', languagelocalekey='en_US', 
                          localesidkey='en_US', profileid = p.Id,
                          timezonesidkey='America/New_York', username='Someone@test.com'); 
        insert u;
        system.runas(u){
            DisabledTrigger__c Dtrg = new DisabledTrigger__c();
            Dtrg.Name                       = 'Disabled';
            Dtrg.TaskTrigger__c             = 'Test@test.com';
            Dtrg.AssetTrigger__c            = 'Test@test.com';
            insert Dtrg;
            
            DocuSignCredentials__c dcscredentials   = new DocuSignCredentials__c();
            dcscredentials.Name                     = 'test';
            dcscredentials.AccountId__c             = 'test';
            dcscredentials.UserId__c                = 'test'; 
            dcscredentials.Password__c              = 'test';
            dcscredentials.IntegratorsKey__c        = 'test';
            dcscredentials.WebServiceUrl__c         = 'test';
            insert dcscredentials;
            
            Account newAccount              = new Account();
            newAccount.name                 = 'XYZ';
            newAccount.Phone                = '+49-12345';
            newAccount.BillingStreet        = 'Am Tierpark 16';
            newAccount.BillingCity          = 'Cologne';
            newAccount.BillingPostalCode    = '54321';
            newAccount.BillingState         = 'GA';
            newAccount.BillingCountry       = 'Germany';
            newAccount.Primary_Email__c     = 'ra@gmail.com';
            newAccount.Home_Phone__c        = '1234567890 ';
            newAccount.Work_Phone__c        = '1234567890 ';
            newAccount.Mobile1__c           = '1234567890 ';
            newAccount.Mobile2_Other__c     = '1234567890 ';
            newAccount.party_id__c          = '206084041';
            insert newAccount;
            
            contact c                       = new contact();
            c.lastname                      = 'test';
            c.accountid                     = newAccount.id;
            c.FirstName                     = 'ravi';
            c.Title                         = 'sath';
            c.email                         = 'ravi@gmail.com';
            c.Phone                         = '1234567895';
            c.MobilePhone                   = '1234567895';
            c.MailingState                  = 'California';
            c.MailingCountry                = 'United States';
            c.MailingCity                   = 'knr';
            c.MailingStreet                 = 'test';
            c.MailingPostalCode             = '524345';
            c.Preferred_Phone__c            = '1234567890';
            c.Active__c                     =true;
            c.Type__c                       ='Agent';
            insert c;
            
            Waitlist__c w                   = new Waitlist__c();
            w.Account__c                    = newAccount.id;
            w.Pre_Auth_Contact__c           = c.id;
            w.Status__c                     = 'Created';
            w.Pre_Auth_Email__c             = 'aj@gmail.com';
            insert w;
            
            Waitlist_Item__c wt             = new Waitlist_Item__c();
            wt.Waitlist__c                  = w.id;
            wt.Original_Max_Spend__c        = 2000;
            wt.Status__c                    = 'Created';
            wt.Market__c                    = 'test';
            wt.Waitlist_ID__c               = '345678';
            wt.Lead_Routing__c              = 'Fast';
            //wt.Product__c = p.id;
            wt.Account__c                   = newAccount.id;
            wt.Market_Type__c               = 'Postal Code';
            wt.Waitlist_Expiration_Date__c  = date.today();
            wt.Product_Size__c              = 'Full';
            insert wt;
            
            List<String> m                  = new List<String>();
            m.add(wt.Waitlist_ID__c);
            
            dsfs__DocuSign_Status__c d      = new dsfs__DocuSign_Status__c();
            d.dsfs__DocuSign_Envelope_ID__c = '12345';
            d.Waitlist__c                   = w.Id;
            insert d;

            Test.setMock(WebServiceMock.class, new WebServiceMockVoidDocusign());
            WebServiceMockVoidDocusign.callfrom = 'voiddocusign';
            VoidDocuSign.VoidEnvelope(m);
        }
    }
}