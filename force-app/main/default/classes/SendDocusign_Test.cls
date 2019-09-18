@isTest(Seealldata = true)
private class SendDocusign_Test{
    
    public static testMethod void main1(){
        /*        
        DocuSignCredentials__c  DSC = new DocuSignCredentials__c();
        DSC.Name = 'test';
        DSC.AccountId__c = 'Test Account';
        DSC.IntegratorsKey__c = 'Test Key';
        DSC.Password__c = 'Test Password';
        DSC.UserId__c = 'Test USerID';
        DSC.WebServiceUrl__c = 'https://www.google.com';
        insert DSC;
        
        Blob b = Blob.valueOf('015g0000000cqqf'); 
        Document d = new Document();
        d.Name = 'test doc';
        d.Body = b;
        d.FolderId = '00lg0000000MQIe';
        insert d;*/
        
      List<product2> prddata = [select id from product2 where name ='Connection(SM) for Co-Brokerage'];
        
      Account newAccount = new Account();
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

        Waitlist__c w = new Waitlist__c();
        w.Account__c = newAccount.id;
        w.Pre_Auth_Contact__c = c.id;
        w.Status__c = 'Created';
        w.Pre_Auth_Email__c = 'aj@gmail.com';
        w.cc4digits__c  = '1234';
        w.Submitted_Date__c = date.today();

        insert w;  
        
        list<Waitlist_Item__c> wlidata = new list<Waitlist_Item__c>();
        for(integer I =0; I < 100; I++){
           Waitlist_Item__c wt = new Waitlist_Item__c();
            wt.Waitlist__c = w.id;
            wt.Original_Max_Spend__c = I;
            wt.Status__c = 'Active';
            wt.Market__c = 'test';
            wt.Waitlist_ID__c = 'wwwww';
            wt.Lead_Routing__c = 'Fast' + I;
            wt.Product__c = prddata[0].id;
            wt.Original_Max_Spend__c=10 ;
            wt.Term__c='12';
            wt.Account__c = newAccount.id;
            wt.Market_Type__c = 'Postal Code';
            wt.Waitlist_Expiration_Date__c = date.today().addDays(90);
            wt.Product_Size__c = 'Full';
            wlidata.add(wt);
        }
        system.debug('wlidatas:' + wlidata);
        insert wlidata;     
        
        Test.starttest();        
        Test.setMock(WebServiceMock.class, new WebServiceMockImplementation1());  
        
        SendDocusign.getDsShortName('Co Broker for Connection');
        SendDocusign.SendNow(w.Id);                 
        
        Test.stoptest();
    }
     private class WebServiceMockImplementation1 implements WebServiceMock{
        public void doInvoke(Object stub, Object request, Map<String, Object> response_map_x,String endpoint, String soapAction, String requestName,String responseNS, String responseName, String responseType)
        {
           DocuSignAPI.CreateAndSendEnvelopeResponse_element respElement = 
          new DocuSignAPI.CreateAndSendEnvelopeResponse_element ();
     DocuSignAPI.EnvelopeStatus SendEnvelopeResult  = new DocuSignAPI.EnvelopeStatus();
     SendEnvelopeResult.Status = 'Success';            
               SendEnvelopeResult.EnvelopeID = '12345';
       response_map_x.put('response_x', respElement);      
        
        }
    }
}