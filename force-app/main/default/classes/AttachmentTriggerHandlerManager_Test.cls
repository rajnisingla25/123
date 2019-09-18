@isTest(seealldata = True)
public class AttachmentTriggerHandlerManager_Test{
    
    static Testmethod Void AtachmentInsertionTestingNeagtive(){
    MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
        //Inserting Customsetting
        string username = userinfo.getUserName();
        Attachmentactivitydeleteaccess__c Dtrg1 = new Attachmentactivitydeleteaccess__c(Name= username,InputType__c = 'user');
        insert Dtrg1; 
        
        //ProductExclusionTrigger
        //mtduc.CreateDisabledTriggerSingle();
        
       // Account theAccount = TestDataFactory.createAccount('The Test Account', null, false);
        //    theAccount.Primary_Email__c = 'theAcc@move.com';
          //  theAccount.Type = Constants.OFFICE_ACCOUNT_TYPE;
            //theAccount.Party_ID__C = '12345';
            //theAccount.Billing_Preference__c = 'Arrears-Invoice';
       // insert theAccount;        
       Account theAccount = mtduc.CreateBrokerAccountSingle();
        AccountTeamMember atm = new AccountTeamMember();
        atm.AccountID = theAccount.Id;
        atm.TeamMemberRole = 'Account Manager';
        atm.UserID = userinfo.getUserId();
        insert atm;        
        
        Schema.DescribeSObjectResult OppSchema = Schema.SObjectType.Opportunity; 
        Map<String,Schema.RecordTypeInfo> OppRecType= OppSchema.getRecordTypeInfosByName(); 
        Id opprtId = OppRecType.get('Broker Field Sales').getRecordTypeId(); 
        Opportunity op = New Opportunity();
         op.name = 'TESTING BY BOSS';
         op.AccountId = theAccount.id;
         op.Opportunity_Short_Description__c = 'Testing BY BOSS';
         op.CloseDate = System.today().addDays(28);
         op.StageName = 'Qualify Opportunity';
         op.ForecastCategoryName = 'Pipeline';
         op.RecordTypeId = opprtId;
        Insert op;
        
        BigMachines__Quote__c quote         = new BigMachines__Quote__c();
            quote.BigMachines__Account__c       = theAccount.Id;        
            quote.BigMachines__Status__c        = 'Approved';
            quote.BigMachines_Quote_Type__c     = 'New';   
            quote.BigMachines__Is_Primary__c    = true;
            quote.BigMachines__Opportunity__c   = op.id;
        insert quote;
        Product2 newProduct = new Product2();
            newProduct.Name = 'Showcase(SM) Listing Enhancements';
            newProduct.Commission_Category__c = 'Normal';    
            newProduct.Normalization_factor__c = 1.10;
            newProduct.Commission_Category__c = 'CFCB';
            newProduct.Fulfillment_Type__c = 'Manual';
            newProduct.Auto_Renewal__c = True;
            newProduct.BigMachines__Part_Number__c ='SHOWCASE' ;
            newProduct.ProductCode='SHOWCASE' ;
            newProduct.S_No__c = 2;
        //insert newProduct;
        PricebookEntry thePricebookEntrie = [Select id,Name,Product2Id from PricebookEntry where Product2.ProductCode='SHOWCASE'];

       
        OpportunityLineItem opl = new  OpportunityLineItem();
        opl.PricebookEntryId = thePricebookEntrie.id;
        opl.Quantity = 1;
        opl.TotalPrice = 1000;
        opl.OpportunityId=op.id;
        insert opl;
        
        BigMachines__Quote_Product__c bquote = new BigMachines__Quote_Product__c();
            bquote.BigMachines__Quote__c = quote.Id;
            bquote.Line_Type__c = 'Renew';
            bquote.BigMachines__Product__c = thePricebookEntrie.Product2Id;
            bquote.BigMachines__Quantity__c = 1;
            bquote.BigMachines__Sales_Price__c = 10; 
            bquote.Product_Account__c  = theAccount.id;
            bquote.BigMachines__Description__c = 'Search and Paws';     
        insert bquote;
        
        Blob pdfPageBlob =Blob.valueOf('Unit Test Attachment Body');
        Attachment a = new Attachment(); 
            a.Body = pdfPageBlob; 
            a.ParentID = op.id; 
            a.Name = 'InsertionOrder.pdf'; 
            a.Description = 'TestDescription1'; 
        insert a;
        Blob pdfPageBlob1 =Blob.valueOf('Unit Test Attachment Body');
        Attachment a1 = new Attachment(); 
            a1.Body = pdfPageBlob1; 
            a1.ParentID = op.id; 
            a1.Name = 'InsertionOrder1.pdf'; 
            a1.Description = 'TestDescription1'; 
        insert a1;
        
        Attachment a2 = new Attachment(); 
            a2.Body = pdfPageBlob1; 
            a2.ParentID = op.id; 
            a2.Name = 'Xyz.pjpdasp'; 
            a2.Description = 'desc475'; 
        insert a2;
        
        map<Id,Attachment> newmap = new map<Id,Attachment>();
        newmap.put(a.id, a);
        newmap.put(a1.id, a1);
        newmap.put(a2.id, a2);
        set<ID> attachmentIDS = New set<ID>();
        attachmentIDS.add(a.id);
        attachmentIDS.add(a1.id);
        attachmentIDS.add(a2.id);
       
        Test.starttest();        
       // Test.setMock(WebServiceMock.class, new WebServiceMockImplementation1());  
        AttachmentTriggerHandlerManager att = New AttachmentTriggerHandlerManager();         
        att.oppSendtoDocusign(newmap);
        AttachmentTriggerHandlerManager.sendDocNow(attachmentIDS);
        Test.stoptest();
    }
    
    static Testmethod Void AtachmentInsertionTesting(){
        MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
        //Inserting Customsetting
        string username = userinfo.getUserName();
        Attachmentactivitydeleteaccess__c Dtrg1 = new Attachmentactivitydeleteaccess__c(Name= username,InputType__c = 'user');
        insert Dtrg1; 
        
        //ProductExclusionTrigger
        //mtduc.CreateDisabledTriggerSingle();
        
       // Account theAccount = TestDataFactory.createAccount('The Test Account', null, false);
        //    theAccount.Primary_Email__c = 'theAcc@move.com';
          //  theAccount.Type = Constants.OFFICE_ACCOUNT_TYPE;
            //theAccount.Party_ID__C = '12345';
            //theAccount.Billing_Preference__c = 'Arrears-Invoice';
       // insert theAccount;        
       Account theAccount = mtduc.CreateBrokerAccountSingle();
        AccountTeamMember atm = new AccountTeamMember();
        atm.AccountID = theAccount.Id;
        atm.TeamMemberRole = 'Account Manager';
        atm.UserID = userinfo.getUserId();
        insert atm;        
        
        Schema.DescribeSObjectResult OppSchema = Schema.SObjectType.Opportunity; 
        Map<String,Schema.RecordTypeInfo> OppRecType= OppSchema.getRecordTypeInfosByName(); 
        Id opprtId = OppRecType.get('Broker Field Sales').getRecordTypeId(); 
        Opportunity op = New Opportunity();
         op.name = 'TESTING BY BOSS';
         op.AccountId = theAccount.id;
         op.Opportunity_Short_Description__c = 'Testing BY BOSS';
         op.CloseDate = System.today().addDays(28);
         op.StageName = 'Qualify Opportunity';
         op.ForecastCategoryName = 'Pipeline';
         op.RecordTypeId = opprtId;
        Insert op;
        
        BigMachines__Quote__c quote         = new BigMachines__Quote__c();
            quote.BigMachines__Account__c       = theAccount.Id;        
            quote.BigMachines__Status__c        = 'Approved';
            quote.BigMachines_Quote_Type__c     = 'New';   
            quote.BigMachines__Is_Primary__c    = true;
            quote.BigMachines__Opportunity__c   = op.id;
        insert quote;
        Product2 newProduct = new Product2();
            newProduct.Name = 'Showcase(SM) Listing Enhancements';
            newProduct.Commission_Category__c = 'Normal';    
            newProduct.Normalization_factor__c = 1.10;
            newProduct.Commission_Category__c = 'CFCB';
            newProduct.Fulfillment_Type__c = 'Manual';
            newProduct.Auto_Renewal__c = True;
            newProduct.BigMachines__Part_Number__c ='SHOWCASE' ;
            newProduct.ProductCode='SHOWCASE' ;
            newProduct.S_No__c = 2;
        //insert newProduct;
        PricebookEntry thePricebookEntrie = [Select id,Name,Product2Id from PricebookEntry where Product2.ProductCode='SHOWCASE'];

       
        OpportunityLineItem opl = new  OpportunityLineItem();
        opl.PricebookEntryId = thePricebookEntrie.id;
        opl.Quantity = 1;
        opl.TotalPrice = 1000;
        opl.OpportunityId=op.id;
        insert opl;
        
        BigMachines__Quote_Product__c bquote = new BigMachines__Quote_Product__c();
            bquote.BigMachines__Quote__c = quote.Id;
            bquote.Line_Type__c = 'Renew';
            bquote.BigMachines__Product__c = thePricebookEntrie.Product2Id;
            bquote.BigMachines__Quantity__c = 1;
            bquote.BigMachines__Sales_Price__c = 10; 
            bquote.Product_Account__c  = theAccount.id;
            bquote.BigMachines__Description__c = 'Search and Paws';     
        insert bquote;
        
        Blob pdfPageBlob =Blob.valueOf('Unit Test Attachment Body');
        Attachment a = new Attachment(); 
            a.Body = pdfPageBlob; 
            a.ParentID = op.id; 
            a.Name = 'InsertionOrder.pdf'; 
            a.Description = 'TestDescription1'; 
        insert a;
        Blob pdfPageBlob1 =Blob.valueOf('Unit Test Attachment Body');
        Attachment a1 = new Attachment(); 
            a1.Body = pdfPageBlob1; 
            a1.ParentID = op.id; 
            a1.Name = 'InsertionOrder1.pdf'; 
            a1.Description = 'TestDescription1'; 
        insert a1;
        
        Attachment a2 = new Attachment(); 
            a2.Body = pdfPageBlob1; 
            a2.ParentID = op.id; 
            a2.Name = 'Xyz.pjpdasp'; 
            a2.Description = 'desc475'; 
        insert a2;
        
        map<Id,Attachment> newmap = new map<Id,Attachment>();
        newmap.put(a.id, a);
        newmap.put(a1.id, a1);
        newmap.put(a2.id, a2);
        set<ID> attachmentIDS = New set<ID>();
        attachmentIDS.add(a.id);
        attachmentIDS.add(a1.id);
        attachmentIDS.add(a2.id);
       
        Test.starttest();        
        Test.setMock(WebServiceMock.class, new WebServiceMockImplementation1());  
        AttachmentTriggerHandlerManager att = New AttachmentTriggerHandlerManager();         
        att.oppSendtoDocusign(newmap);
        AttachmentTriggerHandlerManager.sendDocNow(attachmentIDS);
        //delete a;
        //set<ID> attachmentIDS1 = New set<ID>();
        //AttachmentTriggerHandlerManager.sendDocNow(attachmentIDS1);
        Test.stoptest();
        set<ID> attachmentIDS1 = New set<ID>();
        attachmentIDS1.add(a2.id);
        AttachmentTriggerHandlerManager.sendDocNow(attachmentIDS1);
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