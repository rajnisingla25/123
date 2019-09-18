public class AttachmentTriggerHandlerManager {
    
    
    public void oppSendtoDocusign(map<Id,Attachment> newmap)
    {
        set<ID> oppParentIDs = new set<ID>();
        set<ID> attachmentIds = new set<ID>();
        set<String> attachmentNames = new set<String>();
        for(String oStr : label.Docusign_Attachment_Names.split(',')){
            attachmentNames.add(oStr);
        }
        
        for(Attachment oAttach: newmap.values()){
            if(Schema.Opportunity.getSObjectType() == oattach.parentID.getsobjectType()){
                system.debug('**oAttach.ContentType'+oAttach.ContentType);
                system.debug('**oAttach.ContentType'+oAttach.Name);            
                system.debug('**oAttach.ContentType'+attachmentNames.contains(oAttach.Name));
                //oAttach.ContentType == 'application/pdf' && 
                if(attachmentNames.contains(oAttach.Name)){
                    oppParentIDs.add(oAttach.parentID);
                    attachmentIds.add(oAttach.ID); 
                }
            }
        }
        list<BigMachines__Quote__c> quoteList = [SELECT BigMachines_Quote_Type__c,BigMachines__Opportunity__c,Suppress_Docusign__c,BigMachines__Status__c,Id,Owner.Email,Owner.Name FROM BigMachines__Quote__c WHERE BigMachines__Is_Primary__c = true and BigMachines__Status__c = 'Approved' and BigMachines__Opportunity__c IN: oppParentIDs ];        
        boolean isValidQline = false; 
        if(!quoteList.isEmpty() )       
            for(BigMachines__Quote_Product__c Qline : [SELECT ID,Line_Type__c FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c =: quoteList.get(0).ID ])        
        {
            if(Qline.Line_Type__c == 'Renew' || Qline.Line_Type__c == 'Add'  )    
            {
                isValidQline = true;
            }    
        }
        system.debug('***quoteList****'+quoteList);
        
        
        if(!oppParentIDs.isEmpty() && isValidQline ){        
            if(!quoteList.isEmpty()){
                system.debug('***quoteList****'+quoteList.get(0).BigMachines__Status__c); 
                if( quoteList.get(0).BigMachines_Quote_Type__c == 'New' || quoteList.get(0).BigMachines_Quote_Type__c == 'Modify')
                    if(quoteList.get(0).Suppress_Docusign__c == false)
                    sendDocNow(attachmentIds);
                system.debug('sentemail******');
            }
        }
    }
    
    
    @Future(callout=true)
    public static void sendDocNow(set<ID> attachmentIDS)
    {
        map<ID,Opportunity> oattachMap = new map<ID,Opportunity>();
        set<ID> parentIDs = new set<ID>();
        set<String> emails = new set<String>();
        boolean isInsertionOrder = false;
        for(Attachment oatt: [SELECT ID,ParentId FROM Attachment WHERE ID IN: attachmentIDS]){
            parentIDs.add(oatt.ParentID);
        }
        
        oattachMap = new map<ID,Opportunity>([SELECT Account.Billing_Preference__c,Id,AccountID,Account.Name,Account.Owner.Name,Account.Owner.Email,Account.primary_email__c FROM Opportunity WHERE ID IN: parentIDS]);
        
        
        for(Attachment  oattachment : [SELECT ID,ParentId,Name FROM Attachment WHERE ID IN: attachmentIDS]){
           Integer ii=0;
            Opportunity oppObj = oattachMap.get(oattachment.ParentId); 
            if(oattachment.Name == 'InsertionOrder.pdf')
                isInsertionOrder = true;                        
            else
                isInsertionOrder = false;            
            
            String envelopeId;
            
            //  Docusign Credentials 
            DocuSignCredentials__c DocSignCredentials = DocuSignCredentials__c.getAll().values();
            String accountId        = DocSignCredentials.AccountId__c;
            String userId           = DocSignCredentials.UserId__c;
            String password         = DocSignCredentials.Password__c;
            String integratorsKey   = DocSignCredentials.IntegratorsKey__c;
            String webServiceUrl    = DocSignCredentials.WebServiceUrl__c; 
            
            DocuSignAPI.APIServiceSoap dsApiSend 
                = new DocuSignAPI.APIServiceSoap();
            dsApiSend.endpoint_x = webServiceUrl;
            
            //Set Authentication
            
            String auth = '<DocuSignCredentials><Username>'+ userId 
                +'</Username><Password>' + password 
                + '</Password><IntegratorKey>' + integratorsKey 
                + '</IntegratorKey></DocuSignCredentials>';
            System.debug('Setting authentication to: ' + auth);
            
            dsApiSend.inputHttpHeaders_x = new Map<String, String>();
            dsApiSend.inputHttpHeaders_x.put('X-DocuSign-Authentication', 
                                             auth);
            
            DocuSignAPI.Envelope envelope = new DocuSignAPI.Envelope();
            envelope.AccountId  = accountId;      
              envelope.BrandId= System.Label.DocuSignRealtorBrand;
            /*
            envelope.Subject = 'Order Confirmation';             
            envelope.EmailBlurb = 'This is my new eSignature service,'+ 
            ' it allows me to get your signoff without having to fax, ' +
            'scan, retype, refile and wait forever';
            envelope.AccountId  = accountId;
            */
            
            Blob pdfBlob = [SELECT Body FROM Attachment WHERE Id =: oattachment.ID].Body;    
            
            // Document
            DocuSignAPI.Document document = new DocuSignAPI.Document();
            document.ID = 1;
            document.pdfBytes = EncodingUtil.base64Encode(pdfBlob);
            document.Name = oattachment.Name;
            document.FileExtension = '.PDF';
            envelope.Documents = new DocuSignAPI.ArrayOfDocument();
            envelope.Documents.Document = new DocuSignAPI.Document[1];
            envelope.Documents.Document[0] = document;
            
            DocuSignAPI.Reminders Reminders = new DocuSignAPI.Reminders();
            Reminders.ReminderEnabled = true;
            Reminders.ReminderDelay = 1;
            //Reminders.ReminderFrequency = 1;
        
            list<BigMachines__Quote__c> quotes = [SELECT Owner.ID,Owner.Title,BigMachines__Opportunity__c,Suppress_Docusign__c,Id,Owner.Email,Owner.Name FROM BigMachines__Quote__c WHERE BigMachines__Is_Primary__c = true and BigMachines__Opportunity__c =: oppObj.ID];  
              
            DocuSignAPI.Expirations  Expirations  = new DocuSignAPI.Expirations();      
            Expirations.ExpireEnabled = true;
            if(isInsertionOrder)
            {
                user loggedinuser = [select id,profile.name,userrole.name from user where id = : quotes.get(0).Owner.ID];
                if(loggedinuser.profile.name.contains('Move Field Sales') || loggedinuser.profile.name.contains('Move Broker Account Manager') || loggedinuser.userrole.name == 'Broker Account Manager - Westlake')
                {
                    Expirations.ExpireAfter = 90;
                    Expirations.ExpireWarn = 90;
                }
                else{
                    Expirations.ExpireAfter = 7;
                    Expirations.ExpireWarn = 7;
                }
            }    
            else
            {
                Expirations.ExpireAfter = 1;
                Expirations.ExpireWarn = 1;            
            }
            
            
            DocuSignAPI.Notification Notification = new DocuSignAPI.Notification();
            Notification.UseAccountDefaults = false;
            Notification.Reminders = Reminders;
            Notification.Expirations = Expirations;
            
            
            // Recipient 1 - Account Primary Email
            
            List<Account_Relationship__c> accrelation = [SELECT Contact_To__r.Name,Contact_To__r.Email, Parent_Account__c, Parent_Account__r.Email_Address__c FROM Account_Relationship__c WHERE Parent_Account__c = :oppobj.accountid AND RecordType.DeveloperName = 'Contact_Relationship' AND Active__c = true AND Contact_Role__c = 'Primary Contact' limit 1];
            string contactname = '';
            string contactemail = '';
            if(!accrelation.Isempty())
            {
                contactname = accrelation.get(0).Contact_To__r.Name;
                contactemail = accrelation.get(0).Parent_Account__r.Email_Address__c;
            }
            else
            {
                contactname = oppObj.Account.Name;
                
            }
            DocuSignAPI.Recipient recipient = new DocuSignAPI.Recipient();
            recipient.ID = 1;
            recipient.Type_x = 'Signer';
            recipient.RoutingOrder = 1;
            //recipient.Email = 'ravinder.rallagudam@move.com'; //oppObj.Account.Primary_Email__C; 
            recipient.Email = contactemail;
            // emails.add('ravinder.rallagudam@move.com');//oppObj.Account.Primary_Email__C; 
            emails.add(contactemail);            
            recipient.UserName = contactname;//oppObj.Account.Name;
            
            //  Recepient 2 - Account owner
            
            DocuSignAPI.Recipient recipient2 = new DocuSignAPI.Recipient();
            recipient2.ID = 2;
            recipient2.Type_x = 'CarbonCopy';
            recipient2.RoutingOrder = 1;
            recipient2.Email = oppObj.Account.Owner.Email;          
            emails.add('oppObj.Account.Owner.Email');//oppObj.Account.Owner.Email;                      
            
            
            recipient2.UserName = oppObj.Account.Owner.Name;          
            list<BigMachines__Quote_Product__c> qProducts = new list<BigMachines__Quote_Product__c>();
            string ProductName = '';    
            string ProductNameDesc = '';
            string customerName = ''+  oppObj.Account.Owner.Name;  
            string companyName =  ''+ oppObj.Account.Name;
            
            if( !quotes.isEmpty()){
                qProducts = [SELECT ID,Name,BigMachines__Description__c FROM BigMachines__Quote_Product__c WHERE BigMachines__Sales_Price__c != null AND BigMachines__Quote__c =: quotes.get(0).ID LIMIT 1];                                        
                if(!qProducts.isEmpty())                    
                    ProductName = qProducts[0].Name;
                if(qProducts[0].BigMachines__Description__c != null && qProducts[0].BigMachines__Description__c != '' )
                    ProductNameDesc = qProducts[0].BigMachines__Description__c;
            }
            
            string blankspace = ' ';
            string nextline = '\n \n';
            string singleline = '\n';
            if(isInsertionOrder){
                if(OppObj.Account.Billing_Preference__c == 'Arrears-Invoice' || oppObj.Account.Billing_Preference__c == 'Invoice-Terms' ){
                    //envelope.Subject = ' Please DocuSign: ' + companyName  + blankspace + blankspace + system.today().month() + system.today().year() + blankspace + ProductName ; 
                    envelope.Subject = companyName + blankspace + blankspace + 'DocuSign Action Required  - realtor.com Order' ; 
                    envelope.EmailBlurb = companyName  + ' , ' + blankspace + nextline + ' Please e-sign and return at your earliest convenience. ' ;  
                }
                else
                    return;
                
            }
            else{
                string tigerLeadBody = '';
                tigerLeadBody  = ' Hi '+ companyName + ',' + nextline +
                    
                    'Attached is your TigerLead License Agreement.'+nextline +
                    
                    'To get started, click "Review Document" above.'+nextline +
                    
                    'When prompted, check the box next to “I agree to use Electronics Records and Signatures," to give your consent to use DocuSign.'+nextline +
                    
                    'Next click “Continue” to the right of the page. This will take you to the License Agreement. '+nextline +
                    
                    'Follow the prompts to initial and sign the agreement and click "Finish" to complete the process. '+nextline +
                    
                    'Upon completion of this form your credit card on file will be charged the "One Time Set Up Fee" as noted in the Contract. '+nextline +
                    
                    'Regards, '+singleline +
                    customerName  + singleline +
                    'Move, Inc. '+singleline +
                    oppObj.Account.Owner.Email + '';
                
                
                if(ProductNameDesc.contains('Search and Paws')){
                    envelope.Subject = companyName  + blankspace + 'DocuSign Action Required - Tigerlead';                        
                    envelope.EmailBlurb = tigerLeadBody ;
                    envelope.BrandId= System.Label.DocuSignTigerBrand;                     
                }
                else if(ProductNameDesc.contains('Home Search')){
                    // envelope.Subject = 'TigerLead Home Search Agreement for ' + companyName  + '(Action Required / Time Sensitive)'; 
                    envelope.Subject = companyName  + blankspace + 'DocuSign Action Required - Tigerlead';                    
                    envelope.EmailBlurb = tigerLeadBody ;
                    envelope.BrandId= System.Label.DocuSignTigerBrand;                       
                }
                else if(ProductNameDesc.contains('HandRaiser')){
                    // envelope.Subject = 'TigerLead Hand Raiser Agreement for ' + companyName  + '(Action Required / Time Sensitive)'; 
                    envelope.Subject = companyName  + blankspace +  'DocuSign Action Required - Tigerlead';                    
                    envelope.EmailBlurb = tigerLeadBody ;
                    envelope.BrandId= System.Label.DocuSignTigerBrand;                       
                }
                else{
                    envelope.Subject = 'Order Confirmation';             
                    envelope.EmailBlurb = 'This is my new eSignature service,'+ 
                        ' it allows me to get your signoff without having to fax, ' +
                        'scan, retype, refile and wait forever';
                }
            }
            
            
           //  if(quote !=null && quote.get(0).Suppress_Docusign__c == true)
            //     return;
            
            // Recepient 3 - Quote Owner
            
            DocuSignAPI.Recipient recipient3 = new DocuSignAPI.Recipient();
            recipient3.ID = 2;
            recipient3.Type_x = 'CarbonCopy';
            recipient3.RoutingOrder = 1;
            recipient3.Email =  quotes.get(0).Owner.Email; 
            if(!emails.contains(quotes.get(0).Owner.Email))
                emails.add(quotes.get(0).Owner.Email);             
            recipient3.UserName = quotes.get(0).Owner.Name; 
            
            
            envelope.Recipients = new DocuSignAPI.ArrayOfRecipient();
            envelope.Recipients.Recipient = new DocuSignAPI.Recipient[4];
            if(!quotes.isEmpty() && quotes.get(0).Suppress_Docusign__c){
                envelope.Recipients.Recipient[0] = recipient;
                recipient2.Id = 1;
                recipient3.Id = 2;
                if(recipient2.Email  != recipient3.Email ){
                    envelope.Recipients.Recipient[1] = recipient2;
                    envelope.Recipients.Recipient[2] = recipient3;     
                } else {
                    envelope.Recipients.Recipient[1] = recipient2;
                }
            }else{
                envelope.Recipients.Recipient[0] = recipient;
                envelope.Recipients.Recipient[1] = recipient2;
                if(recipient2.Email  != recipient3.Email )
                    envelope.Recipients.Recipient[2] = recipient3;        
            }
            // Recepient 4 - Account Team Member role - Account Manager
            set<ID> userIds = new set<ID>();
            
            for(AccountTeamMember oaccTeam: [SELECT Id,AccountID,TeamMemberRole,UserID FROM AccountTeamMember WHERE AccountID =: oppObj.AccountID AND TeamMemberRole = 'Account Manager']){
                userIds.add(oaccTeam.userId);
            }
            for(user ouser: [SELECT Id,Email,Name FROM USER WHERE ID IN: userids]){
                DocuSignAPI.Recipient recipient4 = new DocuSignAPI.Recipient();
                recipient4.ID = 2;
                recipient4.Type_x = 'CarbonCopy';
                recipient4.RoutingOrder = 1;
                recipient4.Email =  ouser.Email;
                recipient4.UserName = ouser.Name; 
                if(recipient2.Email  != recipient4.Email && recipient3.Email  != recipient4.Email && !emails.contains(ouser.Email))           
                {                
                    emails.add(quotes.get(0).Owner.Email);                                             
                    envelope.Recipients.Recipient[3] = recipient4;                    
                }
            }
            
            // Tab
            DocuSignAPI.Tab tab1 = new DocuSignAPI.Tab();
            // tab1.Type_x = 'SignHere';
            tab1.Type_x   = 'Custom';
            tab1.RecipientID = 1;
            tab1.DocumentID = 1;
            tab1.value    =  quotes.get(0).Owner.Name;        
            tab1.AnchorTabItem = new DocuSignAPI.AnchorTab();
            tab1.AnchorTabItem.AnchorTabString = '\\s2\\'; 
            // tab1.AnchorTabItem.AnchorTabString = '\\s2\\';
            tab1.AnchorTabItem.XOffset = 100;
            
            //tab1.AnchorTabItem.
            
            DocuSignAPI.Tab tab2 = new DocuSignAPI.Tab();
            //tab2.Type_x = 'Title';
            tab2.Type_x   = 'Custom';
            tab2.value    =  quotes.get(0).Owner.Title;
            tab2.RecipientID = 1;
            tab2.DocumentID = 1;
            tab2.AnchorTabItem = new DocuSignAPI.AnchorTab();
            // tab2.AnchorTabItem.AnchorTabString = '\\t1\\'; 
            tab2.AnchorTabItem.AnchorTabString = '\\t2\\';
            
            DocuSignAPI.Tab tab3= new DocuSignAPI.Tab();
            tab3.Type_x = 'DateSigned';
            tab3.RecipientID = 1;
            tab3.DocumentID = 1;
            tab3.AnchorTabItem = new DocuSignAPI.AnchorTab();
            tab3.AnchorTabItem.AnchorTabString = '\\d1\\';      
            
            DocuSignAPI.Tab tab4= new DocuSignAPI.Tab();
            //tab4.Type_x = 'FullName';
            tab4.Type_x = 'Custom';
            // Added for default value on 09/25/15
            tab4.RecipientID = 1;
            tab4.DocumentID = 1;
            tab4.value    =  quotes.get(0).Owner.Name;
            tab4.AnchorTabItem = new DocuSignAPI.AnchorTab();
            // tab4.AnchorTabItem.AnchorTabString = '\\n1\\';  
            tab4.AnchorTabItem.AnchorTabString = '\\n2\\';
            
            DocuSignAPI.Tab tab5 = new DocuSignAPI.Tab();
            tab5.Type_x = 'SignHere';
            tab5.RecipientID = 1;
            tab5.DocumentID = 1;
            tab5.AnchorTabItem = new DocuSignAPI.AnchorTab();
            tab5.AnchorTabItem.AnchorTabString = '\\s1\\';
            tab5.AnchorTabItem.XOffset = 100;
            
            
            DocuSignAPI.Tab tab6 = new DocuSignAPI.Tab();
            tab6.Type_x = 'Title';
            tab6.RecipientID = 1;
            tab6.DocumentID = 1;
            tab6.AnchorTabItem = new DocuSignAPI.AnchorTab();
            tab6.AnchorTabItem.AnchorTabString = '\\t1\\';
            
            DocuSignAPI.Tab tab7 = new DocuSignAPI.Tab();
            tab7.Type_x = 'DateSigned';
            tab7.RecipientID = 1;
            tab7.DocumentID = 1;
            tab7.AnchorTabItem = new DocuSignAPI.AnchorTab();
            tab7.AnchorTabItem.AnchorTabString = '\\d2\\';      
            
            DocuSignAPI.Tab tab8 = new DocuSignAPI.Tab();
            tab8.Type_x = 'FullName';
            tab8.RecipientID = 1;
            tab8.DocumentID = 1;
            tab8.AnchorTabItem = new DocuSignAPI.AnchorTab();
            tab8.AnchorTabItem.AnchorTabString = '\\n1\\'; 
            
            DocuSignAPI.Tab tab9 = new DocuSignAPI.Tab();
            tab9.Type_x = 'InitialHere';
            tab9.RecipientID = 1;
            tab9.DocumentID = 1;
            tab9.AnchorTabItem = new DocuSignAPI.AnchorTab();
            tab9.AnchorTabItem.AnchorTabString = '\\i2\\';
            
            DocuSignAPI.Tab tab10 = new DocuSignAPI.Tab();
            tab10.Type_x = 'SignHere';
            tab10.RecipientID = 1;
            tab10.DocumentID = 1;
            tab10.AnchorTabItem = new DocuSignAPI.AnchorTab();
            tab10.AnchorTabItem.AnchorTabString = 'By:';
            
            DocuSignAPI.Tab tab11 = new DocuSignAPI.Tab();
            tab11.Type_x = 'Custom';
            tab11.RecipientID = 1;
            tab11.DocumentID = 1;
            tab11.AnchorTabItem = new DocuSignAPI.AnchorTab();
            tab11.AnchorTabItem.AnchorTabString = '\\n3\\'; 
            
            envelope.Tabs = new DocuSignAPI.ArrayOfTab();
            system.debug('****Attachment Name***'+oattachment.Name);
            if(!isInsertionOrder){
                envelope.Tabs.Tab = new DocuSignAPI.Tab[10];
                envelope.Tabs.Tab[0] = tab1;        
                envelope.Tabs.Tab[1] = tab2; 
                envelope.Tabs.Tab[2] = tab3;  
                envelope.Tabs.Tab[3] = tab4; 
                envelope.Tabs.Tab[4] = tab5; 
                envelope.Tabs.Tab[5] = tab6; 
                envelope.Tabs.Tab[6] = tab7; 
                envelope.Tabs.Tab[7] = tab8; 
                envelope.Tabs.Tab[8] = tab9;
                envelope.Tabs.Tab[9] = tab11;
                
            }
            else{
                // envelope.Tabs.Tab = new DocuSignAPI.Tab[2];
                //envelope.Tabs.Tab[0] = tab1; 
                // envelope.Tabs.Tab[0] = tab10; 
                envelope.Tabs.Tab = new DocuSignAPI.Tab[7];
                envelope.Tabs.Tab[0] = tab1;   // s1     
                envelope.Tabs.Tab[1] = tab2;   // t2
                envelope.Tabs.Tab[2] = tab3;   // d1
                envelope.Tabs.Tab[3] = tab4;  // n2
                envelope.Tabs.Tab[4] = tab5;  // s1
                // envelope.Tabs.Tab[5] = tab6;  // t1
                envelope.Tabs.Tab[5] = tab7;  // d2
                envelope.Tabs.Tab[6] = tab8;  // n1
                // envelope.Tabs.Tab[8] = tab9;  // i2
                
            }
            
            envelope.Notification = Notification;
            System.debug('Calling the API'+envelope);
            try {
                DocuSignAPI.EnvelopeStatus es = dsApiSend.CreateAndSendEnvelope(envelope);
                if ( !Test.isRunningTest() ){
                    envelopeId = es.EnvelopeID;
                } else{
                    envelopeId = '12345';
                }
                system.debug('****envelopeId****'+envelopeId);
                /* try {
DocuSignAPI.EnvelopeStatus es = dsApiSend.CreateAndSendEnvelope(envelope);
envelopeId = es.EnvelopeID;
system.debug('****envelopeId****'+envelopeId); */
                
                dsfs__DocuSign_Status__c doc = new dsfs__DocuSign_Status__c();
                doc.dsfs__DocuSign_Envelope_ID__c = envelopeId;
                doc.dsfs__Sender__c = userinfo.getusername();
                doc.dsfs__Sender_Email__c = userinfo.getuseremail();
                doc.dsfs__Subject__c = envelope.Subject;
                doc.dsfs__Opportunity__c = oppObj.ID;
                doc.dsfs__Company__c  = oppObj.AccountID;
                if ( !Test.isRunningTest() ){
                    doc.dsfs__Envelope_Status__c = es.status;
                } else{
                    doc.dsfs__Envelope_Status__c  = 'Sent';
                }
                doc.Attachment_Type__c = oattachment.Name;
                insert doc;
                /*    Commented by Ravinder    
                doc.dsfs__Envelope_Status__c = es.status;
                doc.Attachment_Type__c = oattachment.Name;
                insert doc;*/ //Commented by Ravinder
                
                list<Attachment> attachmentsList = new list<Attachment>();
                for(Attachment oatt: [SELECT ID,ParentId,Body,BodyLength,ContentType,Description,IsPrivate,Name,OwnerId FROM Attachment WHERE ID IN: attachmentIDS])
                {
                    Attachment temp = new Attachment();
                    temp = oatt.clone(false,false);
                    temp.parentID = doc.ID;
                    attachmentsList.add(temp);              
                }
                insert  attachmentsList;
                system.debug('*****docID***'+doc.ID);    
                // system.debug('****envolopeStatus***'+es.status);
            } catch ( CalloutException e) {
                System.debug('Exception - ' + e );
                envelopeId = 'Exception - ' + e;
                Error__c logerror               = new Error__c();
                logerror.Name                   = EnvelopeID.substring(1, 70);
                logerror.Entity_Id__c           = 'Send Email - Docusign';
                logerror.Error_Description__c   = string.valueof(e);
                logerror.Interface_Name__c      = 'DocuSign';
                Insert logerror;
            } 
        }       
    }
}