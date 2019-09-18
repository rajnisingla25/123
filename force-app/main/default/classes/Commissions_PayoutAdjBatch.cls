public class Commissions_PayoutAdjBatch{
/***
global class Commissions_PayoutAdjBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {        
        Date currentMonthDate =  Date.today(); 
        Date monthStartDate = currentMonthDate.toStartOfMonth();
        Date monthEndDate = monthStartDate.addDays(date.daysInMonth(currentMonthDate.year(),currentMonthDate.month()) - 1);
        system.debug('monthStartDate : '+monthStartDate);
        system.debug('monthEndDate : '+monthEndDate);
        
        return Database.getQueryLocator([select id,Name,Signing_AE__c,Commission__c,Related_to_Quota__c,CreatedDate,Commissionable_Amount2__c,Quota_Percentage_Achieved1__c,RecordType.Name,
                                        User_Team__c,Total_Commissionable_Amount__c,Product__c,Payout_Rate__c from Commission__c where (User_Team__c =: Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM) 
                                        and CreatedDate >=: monthStartDate and  CreatedDate <=: monthEndDate Order by Name Desc]);
    }   
    global void execute(Database.BatchableContext BC, List<Commission__c> scope) {
        system.debug('Scope : '+Scope);
        set<Id> QuotaIds = new Set<Id>();
        for(Commission__c com : Scope){
            QuotaIds.add(com.Related_to_Quota__c);
        } 
        Date startOfMonth = Date.today().toStartOfMonth(); 
        Map<Id,Quota__c> currentMonthQuota = new Map<id,Quota__c>([select id,Name,Total_Commission_Amount__c,Period_Name__c,User__c,User_Team__c,
                                                 Target_Amount__c,Total_Sale__c,Total_Sale_2__c,Quota_Percentage__c from Quota__c where id IN : QuotaIds]);
        
        Map<Id,Quota__c> currentMonthQuota = new Map<id,Quota__c>([select id,Name,Total_Commission_Amount__c,Period_Name__c,User__c,User_Team__c,
                                                 Target_Amount__c,Total_Sale__c,Total_Sale_2__c,Quota_Percentage__c from Quota__c where id =: 'a2EZ0000000cfuKMAQ']);
        
        system.debug('currentMonthQuota : '+currentMonthQuota);        
        Map<Id,Commission__c> PayoutAdjustCommissions = new Map<Id,Commission__c>([select id,Name,Signing_AE__c,Commission__c,Related_to_Quota__c,CreatedDate,Commissionable_Amount2__c,
                                    Quota_Percentage_Achieved1__c,RecordType.Name,User_Team__c,Total_Commissionable_Amount__c,Product__c,Payout_Rate__c
                                    from Commission__c where User_Team__c =: Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM and RecordType.Name =: 'Payroll Adjustment' and Related_to_Quota__c IN : QuotaIds Order by CreatedDate Desc]);
        system.debug('PayoutAdjustCommissions :'+PayoutAdjustCommissions);        
        
        List<commission__c> comList = new List<commission__c>();
        Id PayoutRT = Schema.SObjectType.commission__c.getRecordTypeInfosByName().get('Payroll Adjustment').getRecordTypeId();
        Decimal Payout = 0.0;
        Decimal commission = 0.0;
        for(Quota__c quota : currentMonthQuota.Values()){
            commission = 0.0;
            Payout = 0.0;
            for(commission__c comm : PayoutAdjustCommissions.Values()){
                if(quota.id == comm.Related_to_Quota__c){                   
                    Payout = comm.Payout_Rate__c;
                    //commission = quota.Total_Commission_Amount__c;
                    commission = comm.Commission__c;
                    system.debug('Payout 1 : '+Payout);
                    system.debug('Payout 1 : '+Payout);                 
                    system.debug('commission 1 : '+commission);
                    Break;
                }
            }  
            system.debug('Payout 2: '+Payout);
            system.debug('commission 2: '+commission);
            for(commission__c comm : scope){
                if(quota.id == comm.Related_to_Quota__c){
                    if(comm.RecordType.Name != Commissions_Constants.COMMISSIONS_CLAWBACK){ 
                        commission__c com = new commission__c();
                        com.Quota_Percentage_Achieved1__c = comm.Quota_Percentage_Achieved1__c;                     
                        com.Related_to_Quota__c= quota.id;
                        com.RecordTypeId = PayoutRT;
                        com.Signing_AE__c = quota.User__c;
                        com.User_Team__c = comm.User_Team__c;                        
                        com.Payout_Rate__c = (comm.Payout_Rate__c - Payout);
                        system.debug('commission 21: '+commission);
                        system.debug('commission 22: '+quota.Total_Commission_Amount__c);
                        com.Commission__c = (quota.Total_Commission_Amount__c - commission);
                        comList.add(com);
                        Break;
                    }
                }
            }
        }
        Insert comList;
        system.debug('comList : '+comList);
    }                
    
    global void finish(Database.BatchableContext BC) {
    }
    ***/
}