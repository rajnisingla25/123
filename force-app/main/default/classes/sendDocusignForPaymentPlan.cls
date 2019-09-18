Global with sharing class sendDocusignForPaymentPlan {
    @Future(callout=true)
    Global static void SendNow(id accID,String custName,String custEmail,String custAddress,String payMethd,String contrtys,decimal unpadAmnt,String contractType,String product1,String Products2,String Product3,List<String> paymentsAndDueDate,id caseID){
        //Date Formatting
        string mydate1;
        string mydate2;
        string mydate3;
        
        // CRM-3476 - New Date Variables
        string mydate4;
        string mydate5;
        string mydate6;
        // CRM-3476 - End
        
        String reprole = [SELECT UserRole.Name FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1].UserRole.Name; 
        if(paymentsAndDueDate[0].split(';')[1]!= null && paymentsAndDueDate[0].split(';')[1]!='null'){
            Date dt1 = Date.valueOf(''+paymentsAndDueDate[0].split(';')[1]);
            mydate1 = dt1.format();
            
        }
        else{
            mydate1 = '-';
        }
        system.debug('paymentsAndDueDate###'+paymentsAndDueDate);
        if(paymentsAndDueDate[1]!= null ){
        List<string> datelsy = paymentsAndDueDate[1].split(';');
            if(datelsy[1]!=null && datelsy[1]!='null'){
            Date dt2 = Date.valueOf(''+datelsy[1]);
            mydate2 = dt2.format();
            }
            else{
             mydate2 = '-';
            }
            
        }
        if(paymentsAndDueDate[2].split(';')[1]!=null && paymentsAndDueDate[2].split(';')[1]!='null'){
            Date dt3 = Date.valueOf(''+paymentsAndDueDate[2].split(';')[1]);
            mydate3 = dt3.format();
           
        }
        else{
             mydate3 = '-';
        }
        
        // CRM-3476 Assign Due Date Values
        if(paymentsAndDueDate[3]!= null ){
            List<string> datelsy = paymentsAndDueDate[3].split(';');
            if(datelsy[1]!=null && datelsy[1]!='null'){
                Date dt2 = Date.valueOf(''+datelsy[1]);
                mydate4 = dt2.format();
            }
            else{
                mydate4 = '-';
            }
        }
        if(paymentsAndDueDate[4]!= null ){
            List<string> datelsy = paymentsAndDueDate[4].split(';');
            if(datelsy[1]!=null && datelsy[1]!='null'){
                Date dt2 = Date.valueOf(''+datelsy[1]);
                mydate5 = dt2.format();
            }
            else{
                mydate5 = '-';
            }
        }
        if(paymentsAndDueDate[5]!= null ){
            List<string> datelsy = paymentsAndDueDate[5].split(';');
            if(datelsy[1]!=null && datelsy[1]!='null'){
                Date dt2 = Date.valueOf(''+datelsy[1]);
                mydate6 = dt2.format();
            }
            else{
                mydate6 = '-';
            }
        }   
        // CRM-3476 - End
        
        decimal inter= (decimal)unpadAmnt.setScale(2);
        String envelopeId;
        Integer I = 0;        
        Blob SignDocument= Blob.valueOf(' ');
        integer numberofproducts;
        string shortname;
        document oatt;
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
        
        DocuSignAPI.Envelope envelope = new DocuSignAPI.Envelope();
        envelope.Subject    = 'Please Sign Payment Plan Form'; 
        envelope.EmailBlurb = 'Review all products in the form before signing';
        envelope.BrandId    =    System.Label.Payment_Plan_brand_Id;
        envelope.AccountId  = accountId;
        
        //Get the Document
        if(contractType=='Cancelled Contracts'){
            SignDocument = [SELECT Body FROM Document WHERE Name = 'Payment Plan Canceled Contract'].Body;
        }
        else if(contractType=='Past Due Contracts'){
            SignDocument = [SELECT Body FROM Document WHERE Name = 'Payment Plan Past Due Contract'].Body;
        }
        else{
            //todo nothing
        }
            
        
        //Initiate Docusign Document
        DocuSignAPI.Document document = new DocuSignAPI.Document();
        document.ID = 1;
        document.pdfBytes  = EncodingUtil.base64Encode(SignDocument);
        document.Name      = 'Payment Plan';
        document.FileExtension  = '.doc';
        
        envelope.Documents  = new DocuSignAPI.ArrayOfDocument();
        envelope.Documents.Document     = new DocuSignAPI.Document[1];
        envelope.Documents.Document[0]  = document;
        System.debug('======>>document====>>'+document);
        
        DocuSignAPI.Recipient recipient = new DocuSignAPI.Recipient();
        recipient.ID            = 1;
        recipient.Type_x        = 'Signer';
        recipient.RoutingOrder  = 1;
        recipient.Email         = custEmail;
        recipient.UserName      = custName;
        recipient.SignerName    = custName;
        
        // Copy Account AE
        DocuSignAPI.Recipient recipient1 = new DocuSignAPI.Recipient();
        recipient1.ID           = 2;
        recipient1.Type_x       = 'CarbonCopy';
        recipient1.RoutingOrder = 1;
        recipient1.UserName = UserInfo.getFirstName()+' '+ UserInfo.getLastName();
        recipient1.Email =  UserInfo.getUserEmail(); 
        boolean skipOne = true ; 
        if(custEmail == UserInfo.getUserEmail()){
           skipOne =false ;  
         }
                 
         // This setting required
        recipient.RequireIDLookup = false;  
        
        envelope.Recipients                 = new DocuSignAPI.ArrayOfRecipient();
        envelope.Recipients.Recipient       = new DocuSignAPI.Recipient[3];
        envelope.Recipients.Recipient[0]    = recipient;
        envelope.Recipients.Recipient[1]    = recipient1;
        
         // Tabs
        DocuSignAPI.Tab tab1                = new DocuSignAPI.Tab();
        tab1.Type_x                         = 'SignHere';
        tab1.RecipientID                    = 1;
        tab1.DocumentID                     = 1;
        tab1.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
        tab1.AnchorTabItem.AnchorTabString  = 'signaturetag';
        
        DocuSignAPI.Tab tab2                = new DocuSignAPI.Tab();
        tab2.Type_x                         = 'Custom';
        tab2.value                          = custName;
        tab2.RecipientID                    = 1;
        tab2.DocumentID                     = 1;
        tab2.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
        tab2.AnchorTabItem.AnchorTabString  = 'custName';
        
        DocuSignAPI.Tab tab3                = new DocuSignAPI.Tab();
        tab3.Type_x                         = 'Custom';
        if(product1!=null && product1!=''){
        tab3.value                          = product1; 
        }
        else{
        tab3.value                          ='-'; 
        }
        tab3.RecipientID                    = 1;
        tab3.DocumentID                     = 1;
        tab3.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
        tab3.AnchorTabItem.AnchorTabString  = 'prod1';
    
        DocuSignAPI.Tab tab4                = new DocuSignAPI.Tab();
        tab4.Type_x                         = 'Custom';
        if(products2!=null&& products2 !=''){
        tab4.value                          = products2; 
        }
        else{
        tab4.value                          ='-'; 
        }
        tab4.RecipientID                    = 1;
        tab4.DocumentID                     = 1;
        tab4.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
        tab4.AnchorTabItem.AnchorTabString  = 'prod2';
        
        DocuSignAPI.Tab tab5                = new DocuSignAPI.Tab();
        tab5.Type_x                         = 'Custom';
        if(product3!=null&&product3!=''){
        tab5.value                          = product3; 
        }
        else{
        tab5.value                          ='-'; 
        }
        tab5.RecipientID                    = 1;
        tab5.DocumentID                     = 1;
        tab5.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
        tab5.AnchorTabItem.AnchorTabString  = 'prod3';
       
        DocuSignAPI.Tab tab6                = new DocuSignAPI.Tab();
        tab6.Type_x                         = 'Custom';
        tab6.value                          = string.valueOf(inter);
        tab6.RecipientID                    = 1;
        tab6.DocumentID                     = 1;
        tab6.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
        tab6.AnchorTabItem.AnchorTabString  = 'unAmount';
        
        DocuSignAPI.Tab tab7                = new DocuSignAPI.Tab();
        tab7.Type_x                         = 'Custom';
        tab7.value                          = payMethd;
        tab7.RecipientID                    = 1;
        tab7.DocumentID                     = 1;
        tab7.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
        tab7.AnchorTabItem.AnchorTabString  = 'payMethod';
        
        DocuSignAPI.Tab tab8                = new DocuSignAPI.Tab();
        tab8.Type_x                         = 'Custom';
        tab8.value                          = '$'+string.valueof(paymentsAndDueDate[0].split(';')[0]);
        tab8.RecipientID                    = 1;
        tab8.DocumentID                     = 1;
        tab8.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
        tab8.AnchorTabItem.AnchorTabString  = 'amount1';
        
        DocuSignAPI.Tab tab9                = new DocuSignAPI.Tab();
        tab9.Type_x                         = 'Custom';
        tab9.value                          = '$'+string.valueof(paymentsAndDueDate[1].split(';')[0]);
        tab9.RecipientID                    = 1;
        tab9.DocumentID                     = 1;
        tab9.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
        tab9.AnchorTabItem.AnchorTabString  = 'amount2';
        
        DocuSignAPI.Tab tab10                = new DocuSignAPI.Tab();
        tab10.Type_x                         = 'Custom';
        tab10.value                          = '$'+string.valueof(paymentsAndDueDate[2].split(';')[0]);
        tab10.RecipientID                    = 1;
        tab10.DocumentID                     = 1;
        tab10.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
        tab10.AnchorTabItem.AnchorTabString  = 'amount3';
        
        // CRM-3476 new amount tabs
        DocuSignAPI.Tab tab11                = new DocuSignAPI.Tab();
        tab11.Type_x                         = 'Custom';
        tab11.value                          = '$'+string.valueof(paymentsAndDueDate[3].split(';')[0]);
        tab11.RecipientID                    = 1;
        tab11.DocumentID                     = 1;
        tab11.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
        tab11.AnchorTabItem.AnchorTabString  = 'amount4';
        
        DocuSignAPI.Tab tab12                = new DocuSignAPI.Tab();
        tab12.Type_x                         = 'Custom';
        tab12.value                          = '$'+string.valueof(paymentsAndDueDate[4].split(';')[0]);
        tab12.RecipientID                    = 1;
        tab12.DocumentID                     = 1;
        tab12.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
        tab12.AnchorTabItem.AnchorTabString  = 'amount5';
        
        DocuSignAPI.Tab tab13                = new DocuSignAPI.Tab();
        tab13.Type_x                         = 'Custom';
        tab13.value                          = '$'+string.valueof(paymentsAndDueDate[5].split(';')[0]);
        tab13.RecipientID                    = 1;
        tab13.DocumentID                     = 1;
        tab13.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
        tab13.AnchorTabItem.AnchorTabString  = 'amount6';
        // CRM-3476 - End
        
        DocuSignAPI.Tab tab1111                = new DocuSignAPI.Tab();
        tab1111.Type_x                         = 'Custom';
        tab1111.value                          = mydate1; //paymentsAndDueDate[0].split(';')[1];
        tab1111.RecipientID                    = 1;
        tab1111.DocumentID                     = 1;
        tab1111.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
        tab1111.AnchorTabItem.AnchorTabString  = 'DueDt1';
        
        DocuSignAPI.Tab tab1222                = new DocuSignAPI.Tab();
        tab1222.Type_x                         = 'Custom';
        tab1222.value                          = mydate2; //paymentsAndDueDate[1].split(';')[1];
        tab1222.RecipientID                    = 1;
        tab1222.DocumentID                     = 1;
        tab1222.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
        tab1222.AnchorTabItem.AnchorTabString  = 'DueDt2';
        
        DocuSignAPI.Tab tab1333                = new DocuSignAPI.Tab();
        tab1333.Type_x                         = 'Custom';
        tab1333.value                          = mydate3; //paymentsAndDueDate[2].split(';')[1];
        tab1333.RecipientID                    = 1;
        tab1333.DocumentID                     = 1;
        tab1333.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
        tab1333.AnchorTabItem.AnchorTabString  = 'DueDt3';
        
        // CRM-3476 new DueDate tabs
        DocuSignAPI.Tab tab1444                = new DocuSignAPI.Tab();
        tab1444.Type_x                         = 'Custom';
        tab1444.value                          = mydate4; //paymentsAndDueDate[3].split(';')[1];
        tab1444.RecipientID                    = 1;
        tab1444.DocumentID                     = 1;
        tab1444.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
        tab1444.AnchorTabItem.AnchorTabString  = 'DueDt4';
        
        DocuSignAPI.Tab tab1555                = new DocuSignAPI.Tab();
        tab1555.Type_x                         = 'Custom';
        tab1555.value                          = mydate5; //paymentsAndDueDate[4].split(';')[1];
        tab1555.RecipientID                    = 1;
        tab1555.DocumentID                     = 1;
        tab1555.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
        tab1555.AnchorTabItem.AnchorTabString  = 'DueDt5';
        
        DocuSignAPI.Tab tab1666                = new DocuSignAPI.Tab();
        tab1666.Type_x                         = 'Custom';
        tab1666.value                          = mydate6; //paymentsAndDueDate[5].split(';')[1];
        tab1666.RecipientID                    = 1;
        tab1666.DocumentID                     = 1;
        tab1666.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
        tab1666.AnchorTabItem.AnchorTabString  = 'DueDt6';
        // CRM-3476 - End
        
        DocuSignAPI.Tab tab14                = new DocuSignAPI.Tab();
        tab14.Type_x                         = 'Custom';
        tab14.value                          = UserInfo.getFirstName()+' '+ UserInfo.getLastName();
        tab14.RecipientID                    = 1;
        tab14.DocumentID                     = 1;
        tab14.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
        tab14.AnchorTabItem.AnchorTabString  = 'Repname';
        
        DocuSignAPI.Tab tab15                = new DocuSignAPI.Tab();
        tab15.Type_x                         = 'Custom';
        tab15.value                          = custAddress;
        tab15.RecipientID                    = 1;
        tab15.DocumentID                     = 1;
        tab15.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
        tab15.AnchorTabItem.AnchorTabString  = 'bAddress';
        
        DocuSignAPI.Tab tab16                = new DocuSignAPI.Tab();
        tab16.Type_x                         = 'Custom';
        tab16.value                          = custEmail;//custEmail;
        tab16.RecipientID                    = 1;
        tab16.DocumentID                     = 1;
        tab16.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
        tab16.AnchorTabItem.AnchorTabString  = 'conEmail';
        
        DocuSignAPI.Tab tab17                = new DocuSignAPI.Tab();
        tab17.Type_x                         = 'Custom';
        tab17.value                          = system.today().format();
        tab17.RecipientID                    = 1;
        tab17.DocumentID                     = 1;
        tab17.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
        tab17.AnchorTabItem.AnchorTabString  = 'todayDate';
        
        DocuSignAPI.Tab tab18                = new DocuSignAPI.Tab();
        tab18.Type_x                         = 'Custom';
        if(reprole !=''&& reprole!=null){
        tab18.value                          = reprole; }
        else{
        tab18.value                          ='--';
        }
        tab18.RecipientID                    = 1;
        tab18.DocumentID                     = 1;
        tab18.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
        tab18.AnchorTabItem.AnchorTabString  = 'reprole';
        
        DocuSignAPI.Tab tab19                = new DocuSignAPI.Tab();
        tab19.Type_x                         = 'Custom';
        if(contrtys == 'one contract'){
        tab19.value                          = 'a contract';
        }
        else{
        tab19.value                          = 'several contracts';
        }
        tab19.RecipientID                    = 1;
        tab19.DocumentID                     = 1;
        tab19.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
        tab19.AnchorTabItem.AnchorTabString  = 'contrtype';
        
        DocuSignAPI.Tab tab20                = new DocuSignAPI.Tab();
        tab20.Type_x                         = 'Custom';
        if(contrtys == 'one contract'){
        tab20.value                          ='which contract has';
        }
        else{
        tab20.value                          ='all of which contracts have';
        }
        tab20.RecipientID                    = 1;
        tab20.DocumentID                     = 1;
        tab20.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
        tab20.AnchorTabItem.AnchorTabString  = 'contrtys';
        
        envelope.Tabs                       = new DocuSignAPI.ArrayOfTab();
        envelope.Tabs.Tab                   = new DocuSignAPI.Tab[624];
        envelope.Tabs.Tab[0]                = tab1;        
        envelope.Tabs.Tab[1]                = tab2;       
        envelope.Tabs.Tab[2]                = tab3;       
        envelope.Tabs.Tab[3]                = tab4;       
        envelope.Tabs.Tab[4]                = tab5;
        envelope.Tabs.Tab[5]                = tab6;
        envelope.Tabs.Tab[6]                = tab7;
        envelope.Tabs.Tab[7]                = tab8;
        envelope.Tabs.Tab[8]                = tab9;
        envelope.Tabs.Tab[9]                = tab10;
        envelope.Tabs.Tab[10]               = tab1111;
        envelope.Tabs.Tab[11]               = tab1222;
        envelope.Tabs.Tab[12]               = tab1333;
        envelope.Tabs.Tab[13]               = tab14;
        envelope.Tabs.Tab[14]               = tab15;
        envelope.Tabs.Tab[16]               = tab16;
        envelope.Tabs.Tab[17]               = tab17;
        envelope.Tabs.Tab[18]               = tab18;
        envelope.Tabs.Tab[19]               = tab19;
        if(contractType=='Cancelled Contracts'){
        envelope.Tabs.Tab[20]               = tab20;}
        
        // CRM-3476 Add Tabs
        envelope.Tabs.Tab[21]               = tab11;
        envelope.Tabs.Tab[22]               = tab12;
        envelope.Tabs.Tab[23]               = tab13;
        envelope.Tabs.Tab[24]               = tab1444;
        envelope.Tabs.Tab[25]               = tab1555;
        envelope.Tabs.Tab[26]               = tab1666;
        // CRM-3476 - End
        
        try {
            //sending Envelope
            System.debug('Came into try ====='+envelope);
            DocuSignAPI.EnvelopeStatus EnvStatus = dsApiSend.CreateAndSendEnvelope(envelope);
            if ( !Test.isRunningTest() ){
                envelopeId = EnvStatus.EnvelopeID;
            } else{
                envelopeId = '12345';
            }
            System.debug('EnvStatus====='+EnvStatus); 
            //attaching DocuSign status object to Account object
            System.debug('============ ATTACHING ======================');
            List<dsfs__DocuSign_Status__c> DocStatuslst = new List<dsfs__DocuSign_Status__c>();
            dsfs__DocuSign_Status__c DocStatus      = new dsfs__DocuSign_Status__c();
            DocStatus.dsfs__DocuSign_Envelope_ID__c = envelopeId;
            DocStatus.dsfs__Sender__c               = userinfo.getusername();
            DocStatus.dsfs__Sender_Email__c         = userinfo.getuseremail();
            DocStatus.dsfs__Subject__c              = envelope.Subject;
            DocStatus.dsfs__Company__c              = accID;
            DocStatus.dsfs__Case__c                 = caseID;
            if ( !Test.isRunningTest() ){
                DocStatus.dsfs__Envelope_Status__c  = EnvStatus.status;
            } else{
                DocStatus.dsfs__Envelope_Status__c  = 'Sent';
            }
            DocStatuslst.add(DocStatus);
            if(DocStatuslst!=null && DocStatuslst.size()>0){
                Database.SaveResult[] srList = Database.insert(DocStatuslst, false);
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted docusign Doc. doc ID: ' + sr.getId());
                        Case cs = new Case();
                        cs.Id = caseID;
                        cs.Followup_Status__c = 'Payment Plan';
                        Update cs;
                    }
                }
            }
             
        } catch ( CalloutException error) {
            envelopeId = 'Exception - ' + error;
            Error__c logerror               = new Error__c();
            logerror.Name                   = 'Payment Plan ';
            logerror.Entity_Id__c           = 'payment Plan';
            logerror.Error_Description__c   = string.valueof(error);
            logerror.Interface_Name__c      = 'DocuSign';
            Insert logerror;
        }  
        
        
        
    }

}