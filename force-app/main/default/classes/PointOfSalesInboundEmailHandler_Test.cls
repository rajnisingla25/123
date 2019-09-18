@isTest(seealldata=true)
private class PointOfSalesInboundEmailHandler_Test {
    static testMethod void TestinBoundEmail()
    {
        
        Profile p = [select id from profile where name = 'System Administrator'];
        User usr = new User(alias = 'standt', email = 'standarduser321@testorg.com',
                            emailencodingkey = 'UTF-8', lastname = 'Testing321', languagelocalekey = 'en_US',
                            localesidkey = 'en_US', profileid = p.Id,Sales_Lock_User__c =true ,
                            timezonesidkey = 'America/New_York', username = 'rajmaohanvakati_movetesting@test.com');
        insert usr;
        
        System.runAs(usr){
            
            
            Account testAccount = TestDataFactory.createAccount('Test Account 12BI',null,false);
            testAccount.Party_ID__c 			= '12345';
            testAccount.Primary_Email__c 		= 'rajamohan.vakati@move.com';
            testAccount.Account_Sub_Type__c 	='Prospect';
            testAccount.Type = 'Broker';
            insert testAccount; 
            
            
            Messaging.InboundEmail email = new Messaging.InboundEmail() ;
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
            email.subject = 'POS Report#12345';
            email.ccAddresses=new String[]{'rajamohan.vakati@Move.com'};
            //    email.fromAddress = 'rajamohan.vakati@move.com';
            email.fromAddress =  System.Label.ODSEmail;
            email.plainTextBody = 'Test Message';
            
            Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
            attachment.body = blob.valueOf('my attachment text');
            attachment.fileName = 'textfileone.txt';
            attachment.mimeTypeSubType = 'text/plain';
            
            Messaging.InboundEmail.BinaryAttachment attachment1 = new Messaging.InboundEmail.BinaryAttachment();
            attachment1.body = blob.valueOf('my attachment text');
            attachment1.fileName = 'textfileone.txt';
            attachment1.mimeTypeSubType = 'text/plain';
            
            
            email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment,attachment1 };
                
                
                
                Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
            attachmenttext.body = 'my attachment text';
            attachmenttext.fileName = 'textfiletwo3.txt';
            attachmenttext.mimeTypeSubType = 'texttwo/plain';
            email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
                Attachment attachmnt =new Attachment();
            attachmnt.name='textfileone.txt';
            attachmnt.body =blob.valueOf('my attachment text');
            attachmnt.ParentId =testAccount.Id;
            insert  attachmnt ;
            
            // try{
            System.Test.startTest();
            
            PointOfSalesInboundEmailHandler  testInbound=new PointOfSalesInboundEmailHandler ();
            testInbound.handleInboundEmail(email, env);  
            
            System.Test.stopTest();
            
            
            
            
            // }  catch(Exception e){
            
            //}
            
        }     
        
        
    }
    
    
    
}