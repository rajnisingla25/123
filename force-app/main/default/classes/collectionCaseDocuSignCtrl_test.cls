@isTest
public class collectionCaseDocuSignCtrl_test {
    public static testMethod void testDocusign(){
        
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        DocuSignCredentials__c DocSignCredentials = new DocuSignCredentials__c();
        DocSignCredentials.AccountId__c='sdasadsadsadsad-sdsadsadsd-dasd';
        DocSignCredentials.UserId__c='005dfdffdfdf';
        DocSignCredentials.Password__c='sddsd';
        DocSignCredentials.IntegratorsKey__c='sdadasdsadsad';
        DocSignCredentials.WebServiceUrl__c='sdadsadsadsadsad';
        DocSignCredentials.Name='sdadsadsadsadsad';
        insert DocSignCredentials;
        
        String billingAddress ;
        List<String> paymentsAndDueDate = new list<String>();
        paymentsAndDueDate.add(String.valueOf(3000)+';'+String.valueOf(System.Today()));
        paymentsAndDueDate.add(String.valueOf(5000)+';'+String.valueOf(System.Today()));
        paymentsAndDueDate.add(String.valueOf(8000)+';'+String.valueOf(System.Today()));
        
        Account newAccount = new Account();
        newAccount.name = 'XYZ';
        newAccount.Phone = '+49-12345';
        newAccount.BillingStreet = 'Am Tierpark 16';
        newAccount.BillingCity = 'Cologne';
        newAccount.BillingPostalCode = '54321';
        newAccount.BillingState = 'GA';
        newAccount.BillingCountry = 'Germany';
        newAccount.Primary_Email__c = 'ra@gmail.com';
        newAccount.Email_Address__c = 'ra@gmail.com';
        newAccount.Home_Phone__c = '1234567890 ';
        newAccount.Work_Phone__c = '1234567890 ';
        newAccount.Mobile1__c = '1234567890 ';
        newAccount.Mobile2_Other__c = '1234567890 ';
        newAccount.party_id__c = '206084041';
        insert newAccount;
        billingAddress+=(newAccount.BillingStreet!=null)?newAccount.BillingStreet+',':'';
        billingAddress+=(newAccount.BillingCity!=null)?newAccount.BillingCity+',':'';
        billingAddress+=(newAccount.BillingState!=null)?newAccount.BillingState+',':'';
        billingAddress+=(newAccount.BillingCountry!=null)?newAccount.BillingCountry+',':'';
        billingAddress+=(newAccount.BillingPostalCode!=null)?newAccount.BillingPostalCode:'';
        billingAddress=billingAddress.remove('null');
        
        Contact theContact = new Contact(FirstName = 'firstName',
                                         LastName = 'lastName',
                                         AccountId = newAccount.Id,
                                         Email='sda@gmail.com',
                                         Active__c = true); 
        insert theContact;
        System.assertNotEquals( theContact.id,null);
        insert new CaseRecordTypes__c(name='Retention',Record_Type_Id__c='042j0990040PMBb');
        Case caseRec = TestDataFactory.createCase('Invalid Rights','Open','Collections' ,'Test Description', theContact.Id,newAccount.Id,false);
        insert caseRec;
         System.assertNotEquals( caseRec.id,null);
          System.assertNotEquals( caseRec.contactid,null);
           System.assertNotEquals( caseRec.accountid,null);
        List<Product2> productList=new List<Product2>();
        productList.add(new Product2(Name='dssfsd',isActive=true));
        insert productList;
        System.assertNotEquals( productList,null);
        PageReference tpageRef = Page.collectionCaseDocuSign;
        Test.setCurrentPage(tpageRef);

        ApexPages.currentPage().getParameters().put('Id', caseRec.Id);

        System.assertEquals( caseRec.id,ApexPages.currentPage().getParameters().get('Id'));
        
         collectionCaseDocuSignCtrl cott = new collectionCaseDocuSignCtrl();
         ApexPages.currentPage().getParameters().put('Id', caseRec.Id);
         cott.caseId=caseRec.id;
         cott.caseRec=caseRec;
         System.assertEquals( caseRec,cott.caseRec);
         cott.getProducts();
         cott.paymentMthd = 'Credit Card';
         cott.unpaidAmnt = 6000.00;
         cott.contractsType = 'Payment plan canceled contract';
         cott.product1 = 'Reessio';
        cott.Products2 = 'CFCB';
        cott.Product3 = 'CFCB';
         Test.starttest();  
         
        Test.setMock(WebServiceMock.class, new WebServiceMockImplementation1());
        cott.sendDataForDocusign();
        //sendDocusignForPaymentPlan.SendNow(newAccount.ID,newAccount.name,  newAccount.Primary_Email__c, billingAddress,payMethd,unpadAmnt, contractType, product1, Products2, Product3, paymentsAndDueDate );
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