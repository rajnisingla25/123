public class DocuSignAgreementClass {

       public void AgreementMethod(List<Waitlist__c> WAids,Set<Id> Wids,Map<id,Waitlist__c> WAMap){
   
       List<Waitlist__c> wApps = new List<Waitlist__c>();
        for( Waitlist__c wA : WAids ) {
            Waitlist__c oldWAMap = new Waitlist__c();
            oldWAMap = WAMap.get(wA.Id);

            if((wA.Status__c == 'Pending Pre-Auth') && (wA.Status__c != oldWAMap.Status__c)){ 
                wApps.add(wA);
            }
            
   
       if(WA.Pre_Auth_Email__c != null){
       List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> sendTo = new List<String>();
        sendTo.add(WA.Pre_Auth_Email__c);
        String body = 'Hi....Test Email ' ;
        mail.setHtmlBody(body);
        mail.setToAddresses(sendTo);
        mail.setSenderDisplayName('Docusign Email Sender');
        mails.add(mail);
         Messaging.sendEmail(mails);
         
         
         
  /*    Document document = [SELECT Name, Body, BodyLength, ContentType, Type, Description from Document where (Id='015W0000000DjQH') limit 1 ]; 
      List<Attachment> attachments = new List<Attachment>(); 
 
 //for(Attachment at : attachments)
 
 
   
     
  Attachment attachment = new Attachment();
  attachment.Body = document.Body;
  attachment.Description = document.Description;
  attachment.ContentType = document.ContentType;
  attachment.Name = document.Name + ( document.Type == null ? '' : '.' + document.Type);
  attachments.add(attachment);   
           
        
     
   
     
 
   insert attachments; */     
        }
        
        }
        }
        }