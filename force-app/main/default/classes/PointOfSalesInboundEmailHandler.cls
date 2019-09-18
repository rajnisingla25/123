/**
* Name : PointOfSalesInboundEmailHandler
* Test Class : PointOfSalesInboundEmailHandler_UT
* Description : This Apex Class is used to read the inbound email to salesforce from BI system . After reading the inbound email ,its
* going to create a Task and Attachements
* @author  Rajamohan Vakati
* @version 1.0
* @since   2016 July 28
*/
global class PointOfSalesInboundEmailHandler implements Messaging.InboundEmailHandler{
    global static boolean SkipForPOSExecution = false;
    /**
* This Method is used to parse email .
* @param email , envelope
* @return Messaging.InboundEmailResult .
* @exception N/A
*/
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,Messaging.InboundEnvelope envelope){
        SkipForPOSExecution = true;
        Messaging.InboundEmailResult result=new  Messaging.InboundEmailresult();
        
        try {
            
            // DisabledTrigger__c Dtrg= DisabledTrigger__c.getValues('Disabled');
            
            System.debug('email'+email);
            string ccAddressEmail=email.ccAddresses[0];
            String partyId = email.Subject.split('#')[1];
            String fromEmail = email.fromAddress;
            Account acc=[SELECT Id,
                         Name,
                         OwnerId,
                         Primary_Email__c,Email_Address__c,
                         Party_ID__c 
                         FROM 
                         Account
                         WHERE  
                         Party_ID__c=:partyId];

            if( fromEmail == System.Label.ODSEmail  ){
                // DisabledTrigger__c Dtrg= DisabledTrigger__c.getValues('Disabled');
                // Turn off trigger if the value of custom setting field is true. 
                System.debug('Demo  ===');
                Id salesActivitiesRecordTypeId = Schema.SObjectType.Task.RecordTypeInfosByName.get('Sales Activities').RecordTypeId;
                
                Task t=new  Task();
                t.OwnerId =acc.OwnerId;
                t.RecordTypeId =salesActivitiesRecordTypeId;
                t.ActivityDate =System.today();
                t.Subject=email.Subject;
                t.Priority='Normal';
                t.Status='Completed ';
                t.Type='Email';
                t.Outcome__c='Spoke To / Emailed Info';
                t.WhatId=acc.id; 
                t.Actual_End__c =System.today();
                t.Email__c  = acc.Email_Address__c;
                t.Parent_Account_Name__c  = acc.Name;   
                t.Description =email.subject+','+email.plainTextBody;
                Insert t;
                System.debug('========>>'+t);
                
                List<Attachment> attachementToBeInsert=new  List<Attachment>();
                if(email.binaryAttachments!=null&&email.binaryAttachments.size()>0){
                    for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                        Attachment attachment=new  Attachment();
                        attachment.ParentId=t.Id;
                        attachment.OwnerId =t.OwnerId ; 
                        attachment.Name=bAttachment.filename;
                        attachment.Body=bAttachment.body;
                        attachementToBeInsert.add(attachment);
                        
                    }
                }
                if(email.textAttachments!=null&&email.textAttachments.size()>0){
                    for(Messaging.Inboundemail.TextAttachment tAttachment:email.textAttachments){
                        Attachment attachment=new  Attachment();
                        attachment.Name=tAttachment.fileName;
                        attachment.Body=Blob.valueOf(tAttachment.body);
                        attachment.ParentId=t.Id;
                        attachment.OwnerId =t.OwnerId ; 
                        attachementToBeInsert.add(attachment);
                    }
                }
                if(attachementToBeInsert.size()>0)
                    Insert attachementToBeInsert;
                // }
                System.debug('============= Done ====='+attachementToBeInsert);
                
            }
        }Catch(Exception e){
            
        }
        return result;
    }
}