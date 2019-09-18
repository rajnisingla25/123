@IsTest
public class CancelDocusignExtension_Test{
    Static TestMethod void DocuSignMethod(){
    
         Profile p = [select id from profile where name='Move Data Integration'];
        User u = new User(alias = 'standt', email='standarduser@testorg.com',
                          emailencodingkey='UTF-8', lastname='Someone', languagelocalekey='en_US', 
                          localesidkey='en_US', profileid = p.Id,
                          timezonesidkey='America/New_York', username='Someone@test.com'); 
        insert u;
        system.runas(u){
           //Inserting Customsetting
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
            DocuSignCredentials__c dcscredentials   = new DocuSignCredentials__c();
            dcscredentials.Name                     = 'test';
            dcscredentials.AccountId__c             = 'test';
            dcscredentials.UserId__c                = 'test'; 
            dcscredentials.Password__c              = 'test';
            dcscredentials.IntegratorsKey__c        = 'test';
            dcscredentials.WebServiceUrl__c         = 'test';
            insert dcscredentials;
            
            // Inserting account record.
        Account newAccount = TestDataFactory.createAccount('The Test Account', null, false);
         newAccount.Primary_Email__c = 'theaccount@b2b.com';
            newAccount.party_id__c          = '206084041';
            insert newAccount;
             Contact c = null;
           c = TestDataFactory.createContact('The Test', 'Contact 1', null, true, false);
            c.Phone = '9876543210';
            c.Email = 'hsingh@appirio.com';
            c.Type__c = 'Agent';
            c.Contact_Party_ID__c = '28993488';
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
        dsfs__DocuSign_Status__c ds = new dsfs__DocuSign_Status__c();
        
         ds.Waitlist__c                   = w.Id;
        ds.dsfs__DocuSign_Envelope_ID__c = 'ET12434';
        Insert ds;
        
        Test.setMock(WebServiceMock.class, new WebServiceMockVoidDocusign());
            WebServiceMockVoidDocusign.callfrom = 'voiddocusign';
            VoidDocuSign.VoidEnvelope(m);
          ApexPages.StandardController stdController = New ApexPages.StandardController(ds);
        CancelDocusignExtension cde = New CancelDocusignExtension(stdController);
        cde.cancelDocusign();        
        cde.cancel();
    } 
  }  
}