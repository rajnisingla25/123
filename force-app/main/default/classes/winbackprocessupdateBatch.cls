/* 
Name        : winbackprocessupdateBatch
Description : Processes the Do not renew Assets to Manual to reach the customers and renew te assets.
Author      : Venu Ravilla
*/
global class winbackprocessupdateBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful{
    global set<ID> AcctIdset = new set<ID>();
    Exception[] errors = new Exception[0];
    set<ID> setIds1 = new set<ID>();
    List<Asset_AR_Association__c> aralist = new list<Asset_AR_Association__c>();
    list<Asset> astupdlist = new list<Asset>();
    global String Query;
    global winbackprocessupdateBatch(set<ID> AccIdset) {
        AcctIdset.addall(AccIdset);
    }
    List<Asset> AsstUpdList = new List<Asset>();
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        Set<String> winproductcode = new Set<String>();
        Date winStartdate = System.today().AddDays(6);
        date wndate =System.Date.today().toStartOfMonth().addMonths(1).addDays(-1);
        if(System.Label.Winbackprocessproductcode!=null){
            winproductcode.addAll(System.Label.Winbackprocessproductcode.split(','));
        }
        Query = 'Select Id,Name,Fulfillment_Status__c,CustResp_AutoOrder__c,Renewal_Type__c,Had_do_not_renew__c,Status,Line_Type__c,Start_Date__c,Asset_Type__c from Asset where AccountId In:AcctIdset and Status = \'Active\' and Asset_Type__c=\'Parent\' and fulfillment_status__c = \'Fulfilled\' and End_Date__c>=:winStartdate and End_Date__c <=:wndate and (not Inflight_Quote__c like \'%Renew%\') and Haircut_Asset__c = false and No_Term_Sale__c = false';
        System.debug('The Global Query' +Query);
        return Database.getQueryLocator(Query);
    }   
    global void execute(Database.BatchableContext BC, List<Asset> scope) {   
        for(Asset theAsset: scope) {
            Asset ast = new Asset(Id = theAsset.Id);
            ast.Renewal_status__c = null;
            if(theAsset.Renewal_Type__c == 'Auto'){
                ast.Follow_up_Status__c = 'Manual Renewal'; 
                ast.KickoutReason__c = 'Converted to Manual'; 
                ast.Renewal_Type__c = 'Manual';
                setIds1.add(theAsset.Id);
            } 
           else if(theAsset.Renewal_Type__c == 'Manual'){
                ast.Follow_up_Status__c = ''; 
                ast.KickoutReason__c = ''; 
            }
            ast.Reason__c = null;
            ast.Reason_Details__c = null;
            ast.Had_do_not_renew__c = True; 
            ast.CustResp_AppliesSpotPromo__c = null; 
            ast.CustResp_AR_Promotion__c = null; 
            ast.CustResp_AR_Strategic_Promotion__c = null; 
            ast.CustResp_AR_Strategic_Promotion_age__c = null; 
            ast.CustResp_AR_Strategic_Promotion_code__c = null; 
            ast.CustResp_AutoOrder__c = 'No'; 
            ast.CustResp_Contract_Term__c = null; 
            ast.CustResp_List_Price__c = null; 
            ast.CustResp_Promo_age__c = null; 
            ast.CustResp_Promotion__c = null; 
            ast.CustResp_Reason__c = null; 
            ast.CustResp_Renewal_Option__c = null; 
            ast.CustResp_Spot_Promotion__c = null; 
            ast.CustResp_Spot_Promotion_age__c = null; 
            ast.CustResp_TotalListPrice__c = null; 
            ast.CustResp_Total_Net__c = null; 
            astupdlist.add(ast);
        }
        Try{
            If(!astupdlist.isEmpty())
                update astupdlist;
        }
        Catch(Exception Exc){
            System.Debug('Error in Processing the winbackprocess Assets'+Exc);
            errors.add(Exc);
        }
        System.debug('The filtered Asset Ids are '+setIds1);
            For(Asset_AR_Association__c Ar: [Select id,AR_Price_Info__c,Asset_Id__c from Asset_AR_Association__c where Asset_Id__c In:setIds1]){
            if(Ar.AR_Price_Info__c!=null)
            Ar.AR_Price_Info__c = null;
            aralist.add(Ar);
            }
            try{
            update aralist;
            }
            Catch(Exception ec){
            system.debug('Error Message'+ ec.getmessage());
            errors.add(ec);}
    }
    global void finish(Database.BatchableContext BC) {    
        if(!errors.isEmpty()) {
            String theEmailAddresses = Error_Notification_Email_Settings__c.getInstance('OpcityAssetRenewal').Asset_Creation_Error_Emails__c;
            if (theEmailAddresses != null && theEmailAddresses != '') {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(theEmailAddresses.split(';'));
                mail.setSenderDisplayName(UserInfo.getName());
                String theEmailBody = 'Hi Admin,\n\n';
                theEmailBody += 'Please review the Asset winbackprocess failures.\n\n';
                theEmailBody += ''+errors;
                theEmailBody += 'Thanks.\nAdmin Tech Team';
                mail.setHtmlBody(theEmailBody); 
                system.debug(mail);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
    }
}