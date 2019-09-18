global class Commissions_CreateTigerLeadCommissionSch implements Schedulable{
    global void execute(SchedulableContext sc) {       
        List<OrderItem> lstOrderItems = [Select Id,Fulfillment_Status__c,Status__c,Line_Type__c ,Commissions_are_calculated__c ,OrderId,CreatedById,PricebookEntryId,Product_Commission_Category__c ,Total_Net__c,CreatedDate from OrderItem
                    where Commissions_are_calculated__c = false and Product_Commission_Category__c ='Tiger' and Commissions_are_calculated__c = FALSE order by CreatedDate Desc limit 10];
        system.debug('lstOrderItems :'+lstOrderItems.size());
        if(lstOrderItems.size()>0){
            Commissions_OrderProductHandler tigerLeadCommissions = new Commissions_OrderProductHandler();
            if(Commissions_TriggerHelperClass.secondRun == false){                    
                Commissions_TriggerHelperClass.secondRun = true;
                Map<id,OrderItem> orderItemNewMap = new Map<id,OrderItem>();
                for(orderItem orderItemRecord :  lstOrderItems){
                    orderItemNewMap.put(orderItemRecord.Id,orderItemRecord );     
                }
                system.debug('orderItem :'+orderItemNewMap.size());
                if(orderItemNewMap.size() > 0){
                    system.debug('orderItem Loop :');
                    tigerLeadCommissions.UpdateCommissions(orderItemNewMap);
                }                                      
            }     
        }
        //Re-Scheduling JOB
        List<CronTrigger> listCronTriggerAsset = [select Id from CronTrigger where CronJobDetail.Name LIKE 'CommissionTigerLeadJob1A1%' and State = 'DELETED' and 
                            nextfiretime = null limit 10];
        system.debug('listCronTriggerAsset : '+listCronTriggerAsset.size());
        If(listCronTriggerAsset.size() > 0){
            system.debug('Job Loop 1 :');
            For(Integer i = 0; i < listCronTriggerAsset.size(); i++){ 
                system.debug('Job Loop 2 :');
                System.abortJob(listCronTriggerAsset[i].Id); 
            }
        }
                           
        Integer rcount =[SELECT count() FROM CronJobDetail WHERE Name LIKE 'CommissionTigerLeadJob1A1%'];
        system.debug('rcount : '+rcount);
        if(rcount < 2){
            system.debug('Job Execution Loop 1 :');
            Commissions_CreateTigerLeadCommissionSch p = new Commissions_CreateTigerLeadCommissionSch();
            Datetime dtt = System.now().addMinutes(4);     
            String sch = dtt.Second()+' '+dtt.Minute()+' '+dtt.hour()+' '+dtt.day()+' '+dtt.Month()+' ? '+dtt.year();
            system.schedule('CommissionTigerLeadJob1A1'+dtt, sch, p);

            List<CronTrigger> listCronTrigger = [select Id from CronTrigger where State = 'DELETED' and nextfiretime = null limit 20];
            system.debug('listCronTrigger : '+listCronTrigger.size());
            If (listCronTrigger.size() > 0){
                system.debug('Job Execution Loop 2 :');
                For (Integer i = 0; i < listCronTrigger.size(); i++){ 
                    system.debug('Job Execution Loop 3 :');
                    System.abortJob(listCronTrigger[i].Id); 
                }
            }
        }        
            
    }    
}