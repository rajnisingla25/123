global class Commissions_QuotaupdateSchClass implements Schedulable{
    global void execute(SchedulableContext sc) {
        List<Quota__c> lstQuotas = [select id,Name,Collection_Target_Amount__c,User__c,User__r.CreatedDate,CreatedDate,User__r.Name,User_Team__c,
                            Target_Amount__c,Total_Sale__c,Total_Sale_2__c,User__r.Payout_Rate_Month_1__c,User__r.Payout_Rate_Month_2__c,
                            User__r.Payout_Rate_Month_3__c,Quota_Percentage__c,Componet2A2BRollUpValue__c,Componet2C2DRollUpValue__c,Collection_Total_Sale__c,
                            Collection_Quota_Percentage__c,Period_Name__c,TP_Units_Sold__c,No_Of_Tiger_Leads__c,Is_Kicker__c,RD_Team_Qualifier__c,
                            RD_Total_Commission__c,RD_Payout__c,TP_Units_Sold_RollUp__c,No_Of_Tiger_Leads_RollUp__c,TIGER_Commissionable_Amount4A_RollUp__c
                            from Quota__c where Record_Processed__c = false and Payment_Status__c != 'Ready for Payroll'
                            order by LastModifiedDate Desc limit 1]; 
        system.debug('lstQuotas  :'+lstQuotas );  
        if(lstQuotas.size() > 0){
            Commissions_QuotaupdateHandlerClass Commission = new Commissions_QuotaupdateHandlerClass();
            Map<id,Quota__c> quotaMap_Update = new Map<id,Quota__c>();
            for(Quota__c quotaRecord :  lstQuotas){
                quotaMap_Update.put(quotaRecord.Id,quotaRecord);     
            }            
            if(quotaMap_Update.size() > 0){
                Commission.updateQuotaCommissions(quotaMap_Update);
            }
            quotaMap_Update.clear();lstQuotas.clear();
        }
        
        //Re-Scheduling JOB
        List<CronTrigger> listCronTriggerAsset = [select Id from CronTrigger where CronJobDetail.Name LIKE 'CommissionQuotaCalJob1A1%' and State = 'DELETED' and 
                            nextfiretime = null limit 10];
        
        If(listCronTriggerAsset.size() > 0){
            system.debug('Job Loop 1 :');
            For(Integer i = 0; i < listCronTriggerAsset.size(); i++){ 
                system.debug('Job Loop 2 :');
                System.abortJob(listCronTriggerAsset[i].Id); 
            }
        }                           
        Integer rcount =[SELECT count() FROM CronJobDetail WHERE Name LIKE 'CommissionQuotaCalJob1A1%'];
        system.debug('rcount : '+rcount);
        if(rcount < 2){
            system.debug('Job Execution Loop 1 :');
            Commissions_QuotaupdateSchClass p = new Commissions_QuotaupdateSchClass();
            Datetime dtt = System.now().addMinutes(1);     
            String sch = dtt.Second()+' '+dtt.Minute()+' '+dtt.hour()+' '+dtt.day()+' '+dtt.Month()+' ? '+dtt.year();
            system.schedule('CommissionQuotaCalJob1A1'+dtt, sch, p);

            List<CronTrigger> listCronTrigger = [select Id from CronTrigger where State = 'DELETED' and nextfiretime = null limit 20];
            system.debug('listCronTrigger : '+listCronTrigger.size());
            If (listCronTrigger.size() > 0){
                system.debug('Job Execution Loop 2 :');
                For (Integer i = 0; i < listCronTrigger.size(); i++){ 
                    system.debug('Job Execution Loop 3 :');
                    System.abortJob(listCronTrigger[i].Id); 
                }
            }
            listCronTrigger.clear(); 
        }
        listCronTriggerAsset.clear(); 
              
    }        
}