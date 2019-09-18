@isTest() 
public class MoveRuleTester {
private static testMethod void testSearch() {
        system.debug('**testMethod Start test');
        // ANI to search on
        string ActiveDnis = '2222';
        string inActiveDnis = '3333';
       string aMatch = '444555';
        string lMatch = '555666';
        string cMatch = '666777';
        string alMatch = '777888';
        string acMatch = '888999';
        string alcMatch = '111222';
    
        
        
        //Contact contact = StevenSimpliCTIRecordCreater.createContact('StevenTest','SimpliCTIScrpopRuleManagerTest',meta_cv9); 
        //Account tAccount1 = StevenSimpliCTIRecordCreater.createAccount('SimpAccountTest1', meta_cv6); 
        //Account tAccount2 = StevenSimpliCTIRecordCreater.createAccount('SimpAccountTest2', meta_cv7); 
        //Case tCase = StevenSimpliCTIRecordCreater.createCase(); 
        //
        //
        try {
            DisabledTrigger__c Dtrg = new DisabledTrigger__c();
        Dtrg.Name = 'Disabled';
        Dtrg.TaskTrigger__c = 'Test@test.com';
        Dtrg.AssetTrigger__c = 'Test@test.com';
        insert Dtrg;
            
    
            
            //-------------- S1 string aMatch = '444555';
            //create Account
            List<Account> lstAccount = new List<Account>();
            Account aAccount = new Account();
            //tAccount.FirstName = 'test';
            //tAccount.LastName = 'test';
            aAccount.Phone = aMatch;
            aAccount.Name = 'test';
            aAccount.Account_Status__c ='Active';
            lstAccount.add(aAccount);
            //insert aAccount;
            
            
             //--------------S2 string alMatch = '777888';
            //create Account
            Account alAccount = new Account();
            //tAccount.FirstName = 'test';
            //tAccount.LastName = 'test';
            alAccount.Phone = alMatch;
            alAccount.Home_Phone__c = alMatch;
            alAccount.Name = 'test';
            alAccount.Account_Status__c ='Active';
            lstAccount.add(alAccount);
            //insert alAccount;
            
            
            //create Account
            Account al2Account = new Account();
            //tAccount.FirstName = 'test';
            //tAccount.LastName = 'test';
            al2Account.Phone = alMatch;
            al2Account.Home_Phone__c = alMatch;
            al2Account.Name = 'test';
            al2Account.Account_Status__c ='Active';
            lstAccount.add(al2Account);
            insert lstAccount;
            String al2AccountId = al2Account.Id;
            system.debug('**createAccount  Id=' + al2AccountId);
            
            String aAccountId = aAccount.Id;
            system.debug('**createAccount  Id=' + aAccountId);
            
            String alAccountId = alAccount.Id;
            system.debug('**createAccount  Id=' + alAccountId);
            
           /* Account atempAccount = [SELECT ID FROM Account WHERE Id = :aAccountId];
            if(atempAccount == null)
            {
                system.debug('*********IsItATaskWithInfo atempAccount = null');
            
            }
            system.debug('*********IsItATaskWithInfo 1');
            */
            //--------------S3 string lMatch = '555666';
            
            List<Lead> lstLead = new List<Lead>(); 
            //create Lead
            Lead lLead = new Lead();
            lLead.FirstName = 'testLead';
            lLead.LastName = 'testLead';
            lLead.Status = 'In Progress';
            lLead.Phone = lMatch;
            lLead.Company = 'test';
            lstLead.add(lLead);
            //insert lLead;
            
            Lead alLead = new Lead();
            alLead.FirstName = 'testLead';
            alLead.LastName = 'testLead';
            alLead.Status = 'In Progress';
            alLead.Phone = alMatch;
            alLead.Company = 'test';
            lstLead.add(alLead);
            //insert alLead;
            
            Lead aclLead = new Lead();
            aclLead.FirstName = 'testLead';
            aclLead.LastName = 'testLead';
            aclLead.Status = 'In Progress';
            aclLead.Phone = acMatch;
            aclLead.Company = 'test';
            lstLead.add(aclLead);
            
             //create Lead
            Lead acl2Lead = new Lead();
            acl2Lead.FirstName = 'testLead';
            acl2Lead.LastName = 'testLead';
            acl2Lead.Status = 'In Progress';
            acl2Lead.Phone = acMatch;
            acl2Lead.Company = 'test';
            lstLead.add(acl2Lead);
            
            Insert lstLead;
            
            String lLeadId = lLead.Id;
            system.debug('**createLead  Id=' + lLeadId);
            
            //create Lead
            
            String alLeadId = alLead.Id;
            system.debug('**createLead  Id=' + alLeadId);
            
            String aclLeadId = aclLead.Id;
            system.debug('**createLead  Id=' + aclLeadId);
           
            String acl2LeadId = acl2Lead.Id;
            system.debug('**createLead  Id=' + acl2LeadId);
            
            
            system.debug('*********IsItATaskWithInfo 2');
            //--------------S5 string cMatch = '666777';
            //create contact
            Contact cContact = new Contact();
            cContact.FirstName = 'test';
            cContact.LastName = 'test';
            cContact.Active__c = true;
            cContact.Phone = cMatch;
            insert cContact;
            String cContactId = cContact.Id;
            system.debug('**createContact  Id=' + cContactId);
            
            
            
           
            
            
            
            
           
            
            Contact alContact = new Contact();
            alContact.FirstName = 'test2';
            alContact.LastName = 'test2';
            alContact.Active__c = true;
            alContact.Phone = alMatch;
            insert alContact;
            String alContactId = alContact.Id;
            system.debug('**createContact  Id=' + alContactId);
        
            
            
            Contact aclContact = new Contact();
            aclContact.FirstName = 'test2';
            aclContact.LastName = 'test2';
            aclContact.Active__c = true;
            aclContact.Phone = acMatch;
            insert aclContact;
            String aclContactId = aclContact.Id;
            system.debug('**createContact  Id=' + aclContactId);
            
            
            //--------------S6 string alcMatch = '111222'
            
            //create contact
            Contact a11cContact = new Contact();
            a11cContact.FirstName = 'test';
            a11cContact.LastName = 'test';
            a11cContact.Active__c = true;
            a11cContact.Phone = alcMatch;
            insert a11cContact;
            String a11cContactId = a11cContact.Id;
            system.debug('**createContact  Id=' + a11cContactId);
            
            
            //create contact
            Contact a22cContact = new Contact();
            a22cContact.FirstName = 'test';
            a22cContact.LastName = 'test';
            a22cContact.Active__c = true;
            a22cContact.Phone = alcMatch;
            insert a22cContact;
            String a22cContactId = a22cContact.Id;
            system.debug('**createContact  Id=' + a22cContactId);
           
            
            //---------------------------------------------------------------------
            
          
            //create Active Campaign
            Campaign tCampaign= new Campaign();
            tCampaign.IsActive = true;
            //tCampaign.DNIS__c = ActiveDnis;
            tCampaign.Name = 'test';
            insert tCampaign;
            String CampaignId = tCampaign.Id;
            system.debug('**createCampaign Id=' + CampaignId);
            
         
            system.debug('*********IsItATaskWithInfo 7');
            //create InActive Campaign
            Campaign tCampaign2= new Campaign();
            tCampaign2.IsActive = true;
           // tCampaign2.DNIS__c = inActiveDnis; - Comm
            tCampaign2.Name = 'test';
            insert tCampaign2;
            String CampaignId2 = tCampaign2.Id;
            system.debug('**createCampaign Id=' + CampaignId2);
           
            
            Id [] fixedSearchResults;
      
            fixedSearchResults = new Id[]{aAccountId,CampaignId};
            Test.setFixedSearchResults(fixedSearchResults);
            String run1 = MoveSalesScrpopRulephase2.search('params=dnis=' + ActiveDnis +',ani=' + aMatch);
            system.debug('**testMethod  run1:' + run1);
            
            
            fixedSearchResults = new Id[]{lLeadId};
            Test.setFixedSearchResults(fixedSearchResults);
            String run2 = MoveSalesScrpopRulephase2.search('params=dnis=' + ActiveDnis +',ani=' + lMatch);
            system.debug('**testMethod run2' + run2);
            
            
            fixedSearchResults = new Id[]{cContactId};
            Test.setFixedSearchResults(fixedSearchResults);
            String run3 = MoveSalesScrpopRulephase2.search('params=dnis=' + ActiveDnis +',ani=' + cMatch);
            system.debug('**testMethod run3' + run3);
            
            
            fixedSearchResults = new Id[]{aclLeadId,acl2LeadId,aclContactId};
            Test.setFixedSearchResults(fixedSearchResults);
            String run4 = MoveSalesScrpopRulephase2.search('params=dnis=' + ActiveDnis +',ani=' + acMatch);
            system.debug('**testMethod run4' + run4);
            

            fixedSearchResults = new Id[]{lLeadId,cContactId,alAccountId,al2AccountId,alLeadId,alContactId,aclLeadId,acl2LeadId,aclContactId,a11cContactId,a22cContactId};
            Test.setFixedSearchResults(fixedSearchResults);
            
            PageReference pageRef = Page.AdvancedScreenPopClientAppMode;
            Test.setCurrentPage(pageRef);

            ApexPages.currentPage().getParameters().put('params', 'dnis=' + ActiveDnis +',ani=' + alcMatch);
            ApexPages.currentPage().getParameters().put('params', 'dnis=3678,ani=12341234');
            
            MoveSalesScrpopRulephase2 controller = new MoveSalesScrpopRulephase2();
            controller.doRedirect();
            


        } 
        catch(Exception e)
        {
          system.debug('**testMethod Exception caught:' + e.getMessage());
        }
        finally {

        }
    }
}