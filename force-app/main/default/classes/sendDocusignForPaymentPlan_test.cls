@isTest(seealldata = true)
public class sendDocusignForPaymentPlan_test {
    public static testMethod void testDocusign(){
        String payMethd = 'Credit Card';
        Double unpadAmnt = 6000.00;
        String contractType = 'Payment plan canceled contract';
        String product1 = 'Reessio';
        String Products2 = 'CFCB';
        String Product3 = 'CFCB';
        String billingAddress ;
        String contrTypeselected = 'a contract';
        List<String> paymentsAndDueDate = new list<String>();
        paymentsAndDueDate.add(String.valueOf(3000)+';'+String.valueOf(date.today()));
        paymentsAndDueDate.add(String.valueOf(5000)+';'+String.valueOf(date.today()));
        paymentsAndDueDate.add(String.valueOf(8000)+';'+String.valueOf(date.today()));
        paymentsAndDueDate.add(String.valueOf(8000)+';'+String.valueOf(date.today()));
        paymentsAndDueDate.add(String.valueOf(8000)+';'+String.valueOf(date.today()));
        paymentsAndDueDate.add(String.valueOf(8000)+';'+String.valueOf(date.today()));
        
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
        
        case caseRec = TestDataFactory.createCase ('Payment Plan','new', 'Collections', 'Payment plan case', null,
                                newAccount.Id, true);

        billingAddress+=(newAccount.BillingStreet!=null)?newAccount.BillingStreet+',':'';
        billingAddress+=(newAccount.BillingCity!=null)?newAccount.BillingCity+',':'';
        billingAddress+=(newAccount.BillingState!=null)?newAccount.BillingState+',':'';
        billingAddress+=(newAccount.BillingCountry!=null)?newAccount.BillingCountry+',':'';
        billingAddress+=(newAccount.BillingPostalCode!=null)?newAccount.BillingPostalCode:'';
        billingAddress=billingAddress.remove('null');
        
        //Define Docusign Credentials
        DocuSignCredentials__c DocSignCredentials = DocuSignCredentials__c.getAll().values();
        String accountId        = DocSignCredentials.AccountId__c;
        String userId           = DocSignCredentials.UserId__c;
        String password         = DocSignCredentials.Password__c;
        String integratorsKey   = DocSignCredentials.IntegratorsKey__c;
        String webServiceUrl    = DocSignCredentials.WebServiceUrl__c; 
        
        //1. Initiate Docusign API
        DocuSignAPI.APIServiceSoap dsApiSend = new DocuSignAPI.APIServiceSoap();
        dsApiSend.endpoint_x = webServiceUrl;
        dsApiSend.timeout_x=120000;
        
         //1.1 Set Authentication
        String auth = '<DocuSignCredentials><Username>'+ userId 
            +'</Username><Password>' + password 
            + '</Password><IntegratorKey>' + integratorsKey 
            + '</IntegratorKey></DocuSignCredentials>';
        
        dsApiSend.inputHttpHeaders_x = new Map<String, String>();
        dsApiSend.inputHttpHeaders_x.put('X-DocuSign-Authentication',auth);
        
        Test.starttest();        
        Test.setMock(WebServiceMock.class, new WebServiceMockImplementation1());  
        sendDocusignForPaymentPlan.SendNow(newAccount.ID,newAccount.name,  newAccount.Primary_Email__c, billingAddress,payMethd,contrTypeselected,unpadAmnt, contractType, product1, Products2, Product3, paymentsAndDueDate,caseRec.ID );
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