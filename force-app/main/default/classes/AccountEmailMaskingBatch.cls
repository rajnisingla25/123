global class AccountEmailMaskingBatch implements Database.Batchable<sObject>{
       global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id,Email_Address__c,Primary_Email__c,SSO_Email__c,Other2_Email__c, Other1_Email__c,Advertiser_Email__c,MLS_Email__c,Do_Not_Email__c FROM Account';
        return Database.getQueryLocator(query);
    }
   global void execute(Database.BatchableContext BC, List<Account> scope){
        for(Account loops : scope){
            //Commented as part of Jira SMCI-554
           /* If (loops.Primary_Email__c != null  && !loops.Primary_Email__c.contains('masked.')){
            loops.Primary_Email__c        =  'masked.' + loops.Primary_Email__c;           
            }*/
            If (loops.Email_Address__c != null  && !loops.Email_Address__c.contains('masked.')){
            loops.Email_Address__c        =  'masked.' + loops.Email_Address__c;           
            }
            /*If (loops.SSO_Email__c != null  && !loops.SSO_Email__c.contains('masked.')){
            loops.SSO_Email__c        =  'masked.' + loops.SSO_Email__c;           
            }
            If (loops.Other2_Email__c != null  && !loops.Other2_Email__c.contains('masked.')){
            loops.Other2_Email__c        =  'masked.' + loops.Other2_Email__c;           
            }
            If (loops.Other1_Email__c != null  && !loops.Other1_Email__c.contains('masked.')){
            loops.Other1_Email__c        =  'masked.' + loops.Other1_Email__c;           
            }
            If (loops.Advertiser_Email__c != null  && !loops.Advertiser_Email__c.contains('masked.')){
            loops.Advertiser_Email__c        =  'masked.' + loops.Advertiser_Email__c;           
            }
            If (loops.MLS_Email__c != null  && !loops.MLS_Email__c.contains('masked.')){
            loops.MLS_Email__c        =  'masked.' + loops.MLS_Email__c;           
            }
            If (loops.Do_Not_Email__c != null  && !loops.Do_Not_Email__c.contains('masked.')){
            loops.Do_Not_Email__c        =  'masked.' + loops.Do_Not_Email__c;           
            }*/
                  }
        update scope;
    }
  
    global void finish(Database.BatchableContext BC){
    }
}