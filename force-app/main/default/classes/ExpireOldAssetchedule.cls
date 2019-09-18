global class ExpireOldAssetchedule implements Schedulable {
   global void execute(SchedulableContext sc) {
   try{
   List<Order> lstOrder = [Select Id,Is_OLI_Creation_Complete__c from Order where Fulfillment_Status__c='Pending Fulfillment' and EffectiveDate<=Today and Is_OLI_Creation_Complete__c =false and Status != 'Complete' order by LastmodifiedDate Desc limit 10];
  if(lstOrder.size()==0){ 
List<Asset> lstAssete = [Select Id,Name,Fulfillment_Status__c,Status,Line_Type__c,Asset_Type__c from Asset where Status != 'Expired' AND Status != 'Cancelled' AND Status !='Converted' and Asset_Type__c='Parent' and End_Date__c<=Yesterday and Renewal_Start_Date__c=null and Product2.Renewal_Term_Type__c !='evergreen' order by End_Date__c Desc limit 25];
      for(Asset ast:lstAssete){
      ast.Fulfillment_Status__c = 'Pending Fulfillment';
      ast.Status = 'Expired';
      ast.Line_Type__c = 'Cancel';
      }
     if(lstAssete.size()>0){
     update lstAssete;
     }
     }
} catch(Exception ex){
List<Asset> lstAssete = [Select Id,Name,Fulfillment_Status__c,Status,Line_Type__c,Asset_Type__c  from Asset where Status != 'Expired' AND Status != 'Cancelled' AND Status !='Converted' and Asset_Type__c='Parent' and End_Date__c<=Yesterday and Renewal_Start_Date__c=null and Product2.Renewal_Term_Type__c !='evergreen' order by End_Date__c Desc limit 10];
      for(Asset ast:lstAssete){
      ast.Fulfillment_Status__c = 'Pending Fulfillment';
      ast.Status = 'Expired';
      ast.Line_Type__c = 'Cancel';
update ast;
      }

}
Integer manualAssets = [SELECT count() FROM Asset WHERE End_Date__c <= Yesterday AND Status != 'Expired' AND Status != 'Cancelled' AND Renewal_Start_Date__c != null and Product2.Renewal_Term_Type__c !='evergreen'];
  if(manualAssets>0){
   String theEmailAddresses = Error_Notification_Email_Settings__c.getInstance('Email Addresses').Asset_Creation_Error_Emails__c;
      if(String.isNotBlank(theEmailAddresses)) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.saveAsActivity = false;
        mail.setToAddresses(theEmailAddresses.split(';'));
        mail.setSubject('Asset Expire Batch Job Notification');

        String theEmailBody = 'Hi Admin,\n\n';
        theEmailBody += 'Please review following assets and these assets having renewals in place and cannot be Expired.\n\n';
        theEmailBody += '<a href='+Error_Notification_Email_Settings__c.getInstance('Email Addresses').View_Link__c+'>Manual Asset Expiration</a>\n\n';
        theEmailBody += 'Thanks.\nAdmin Tech Team';

        mail.setPlainTextBody(theEmailBody);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage> { mail });
  }
   }
   }
   }