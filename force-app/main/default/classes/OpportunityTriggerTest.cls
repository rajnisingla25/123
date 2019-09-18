@istest
public class OpportunityTriggerTest
{
    public static testMethod void test1()
    {
        DisabledTrigger__c Dtrg = new DisabledTrigger__c();
        Dtrg.Name = 'Disabled';
        Dtrg.TaskTrigger__c = 'Test@test.com';
        Dtrg.AssetTrigger__c = 'Test@test.com';
        insert Dtrg;
        
        Set<Id> bmqSetId = new Set<Id>();
        
        MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
        //Account newAccount = mtduc.CreateBrokerAccountSingle();
        Product2 newProduct = mtduc.CreateProductSingle();
        newProduct.EssentialsRequired__c = True;
        update newProduct;
        mtduc.CreatePricebookEntrySingle();       
        Opportunity theOpportunity = mtduc.CreateOppurtunitySingle();
        mtduc.CreateOpportunityProductSingle();
        
        Account newAccount = new Account();
        newAccount.name = 'XYZ';
        newAccount.Phone = '+49-12345';
        newAccount.BillingStreet = 'Am Tierpark 16';
        newAccount.BillingCity = 'Cologne';
        newAccount.BillingPostalCode = '54321';
        newAccount.BillingState = 'Nordrhein-Westfalen';
        newAccount.BillingCountry = 'Germany';
        newAccount.Primary_Email__c = 'ra@gmail.com';
        newAccount.Home_Phone__c = '967622877';
        newAccount.Work_Phone__c = '456789';
        newAccount.Mobile1__c = '1234566';
        newAccount.Mobile2_Other__c = '1245787';
        newAccount.party_id__c = '206084041';
        newAccount.Type = 'Broker';
        newAccount.Auto_Renewal__c = True;
        newAccount.Territories__c = 'test';
        insert newAccount;
        
        Contact myContact = new Contact ();
        myContact.FirstName='Joe';
        myContact.LastName='Schmoe';
        myContact.Email='Joe.Schmoe@test.de';
        myContact.Account = newAccount;
        /*myContact.MailingStreet= newAccount.BillingStreet;
        myContact.MailingState = newAccount.BillingState;
        myContact.MailingCity=newAccount.BillingCity;
        myContact.MailingPostalCode=newAccount.BillingPostalCode;
        myContact.MailingCountry = newAccount.BillingCountry;*/
        myContact.Phone = newAccount.Phone;
        myContact.Type__c = 'Other';
        myContact.Active__c = true;
        insert myContact;
        
        BigMachines__Quote__c OracleQuote = new BigMachines__Quote__c();
        OracleQuote.BigMachines_authorization_status__c = 'Success';
        OracleQuote.BigMachines_authorization_amount__c = 10.00;
        OracleQuote.BigMachines_first_month_payment__c = 30.00;
        OracleQuote.BigMachines__Account__c = newAccount.id;
        OracleQuote.BigMachines__Opportunity__c = theOpportunity.id;
        OracleQuote.BigMachines__Is_Primary__c = true;
        OracleQuote.BigMachines_Quote_Type__c = 'New';
        OracleQuote.BigMachines__Status__c = 'In Progress';
        OracleQuote.tigerLeadProductExists__c = true;
        OracleQuote.BigMachines__Site__c = Label.BigMachineSite; 

        insert OracleQuote;
        
        Business_Hours__c bh = new Business_Hours__c(name = 'OwnChange', Lowermin__c = 450, UpMin__c = 950);
        insert bh;
        Business_Hours__c bh1 = new Business_Hours__c(name = 'StatusChange', Lowermin__c = 450, UpMin__c = 950);
        insert bh1;
        
        Lead LedB1 = new Lead();
        LedB1.LastName = 'Mr';
        LedB1.FirstName = 'Test';
        LedB1.Status = 'New';
        LedB1.Company = 'Test';
        LedB1.Contact__c = myContact.id;
        LedB1.Phone = '(860) 347-0333';
        LedB1.Email = 'c.s1@gmail.com';
        LedB1.Marketing_Lead_Type__c = 'Organic Leads';
        LedB1.Recent_Campaign__c = 'Test';
        LedB1.RDC_Contact_Type__c = 'Single Agent';
        LedB1.Account__c = newAccount.id;
        LedB1.Facebook_Lead_ID__c = '1234';
        insert LedB1; 
        
        theOpportunity = new Opportunity();
        theOpportunity.Name = 'The Opportunity';
        theOpportunity.StageName = 'Closed Won - Fulfilled';
        theOpportunity.CloseDate = system.today();
        theOpportunity.AccountId = newAccount.id;
        theOpportunity.Account_Type__c = 'Inside';
        theOpportunity.Is_Renewal_Opp__c = true;
        theOpportunity.Bigmachine_Quote_ID1__c = OracleQuote.Id;
        theOpportunity.Follow_up_status__c = 'LM 1st Attempt';
        theOpportunity.NextContactTime__c = Date.today();
        theOpportunity.Lead__c = LedB1.Id;
        insert theOpportunity;
        
        theOpportunity.Name = 'test last';
        theOpportunity.StageName = 'Closed Won - Fulfilled';
        theOpportunity.Follow_up_status__c = 'Follow up Scheduled- no Pitch';
        theOpportunity.NVM_Callback_DateTime__c = Date.today();
        update theOpportunity;
        
        Task task = new Task();
        task.Description = 'test';
        task.Status = 'Completed';
        task.Priority = 'Normal';
        task.Subject = 'For the Renewal Opportunity';
        task.WhatId = theOpportunity.Id;
        task.Outcome__c ='Left Message';
        task.Type = 'Call - Outbound';
        task.ActivityDate = system.today();
        insert task;
        
        map<ID,Opportunity> mapOppty = new map<ID,Opportunity>();
        mapOppty.put(theOpportunity.Id, theOpportunity);
        OpportunityTriggerhandler.AfterUpdate(mapOppty, mapOppty);
    }

}