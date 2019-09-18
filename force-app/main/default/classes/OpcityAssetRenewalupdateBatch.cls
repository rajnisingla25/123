/* 
Name        : OpcityAssetRenewalupdateBatch
Description : Processes the Opcity Assets which are going to Renew by the following days.
Author      : Venu Ravilla
*/
global class OpcityAssetRenewalupdateBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful{
    global set<ID> AsstIdset = new set<ID>();
    Map<Id, Date> assetsWithStartDate = new Map<Id, Date>();
    Map<Id, Date> assetsWithEndDate = new Map<Id, Date>();
    Exception[] errors = new Exception[0];
    global String Query;
    global OpcityAssetRenewalupdateBatch(set<ID> AsstIds) {
        AsstIdset.addall(AsstIds);
    }
    List<Asset> AsstUpdList = new List<Asset>();
    global Database.QueryLocator start(Database.BatchableContext BC) {  
        Query = 'select Id,AccountId,Asset_Type__c,Start_Date__c,End_Date__c,Renewal_Start_Date__C,Line_Type__c,Order_Line_Item__c,Extended_List__c,Total_Net__c,Total_List_Price__c,Extended_Net_Price__c,Fulfillment_status__c from Asset where Id IN :AsstIdset';
        return Database.getQueryLocator(Query);
    }   
    global void execute(Database.BatchableContext BC, List<Asset> scope) {         
        for(Asset theParentAsset: scope) {
            assetsWithStartDate.put(theParentAsset.id, theParentAsset.Start_Date__c);
            assetsWithEndDate.put(theParentAsset.id, theParentAsset.End_Date__c);
        }
        for(Asset fulfillToAsset : [SELECT Id,Start_Date__c,End_Date__c,Renewal_Start_Date__C,Line_Type__c,Order_Line_Item__c,Extended_List__c,Total_Net__c,Total_List_Price__c,Extended_Net_Price__c, (Select Id,Start_Date__c,End_Date__c FROM Assets__r WHERE Asset_Type__c = 'Participant') FROM Asset WHERE Parent_Asset__c IN :assetsWithEndDate.keySet() AND Asset_Type__c = 'Fulfill To']) {
            assetsWithStartDate.put(fulfillToAsset.id, fulfillToAsset.Start_Date__c);
            assetsWithEndDate.put(fulfillToAsset.id, fulfillToAsset.End_Date__c);
            If(fulfillToAsset.Assets__r.size()>0){
                for (Asset participantAsset : fulfillToAsset.Assets__r) {	 
                    assetsWithStartDate.put(participantAsset.id, participantAsset.Start_Date__c);
                    assetsWithEndDate.put(participantAsset.id, participantAsset.End_Date__c);
                }
            }	
        }  
        for(Id ast: assetsWithEndDate.keySet()) {
            Asset asst = new Asset(Id=ast);
            asst.Start_Date__c = assetsWithStartDate.get(ast).addMonths(12);
            asst.End_Date__c = assetsWithEndDate.get(ast).addMonths(12);
            asst.Renewal_Start_Date__C = assetsWithEndDate.get(ast).addMonths(12).AddDays(1);
            asst.Line_Type__c = 'Renew';
            asst.Total_Net__c = 0;
            asst.Extended_Net_Price__c = 0;
            asst.Total_List_Price__c = 0;
            asst.Extended_List__c = 0;
            asst.Order_Line_Item__c = Null;
            asst.Renewal_Order_Product__c = Null;
            AsstUpdList.add(asst); 
        }
        Try{
        If(!AsstUpdList.isEmpty())
            update AsstUpdList;
    }
        Catch(Exception Exc){
            System.Debug('Error in Processing the Opcity Assets'+Exc);
            errors.add(Exc);
        }
    }
    global void finish(Database.BatchableContext BC) {    
       if(!errors.isEmpty()) {
        String theEmailAddresses = Error_Notification_Email_Settings__c.getInstance('OpcityAssetRenewal').Asset_Creation_Error_Emails__c;
        if (theEmailAddresses != null && theEmailAddresses != '') {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(theEmailAddresses.split(';'));
            mail.setSenderDisplayName(UserInfo.getName());
             String theEmailBody = 'Hi Admin,\n\n';
                    theEmailBody += 'Please review the Opcity Asset Renewal failures.\n\n';
                    theEmailBody += ''+errors;
                    theEmailBody += 'Thanks.\nAdmin Tech Team';
            mail.setHtmlBody(theEmailBody); 
            system.debug(mail );
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        }
    }
}