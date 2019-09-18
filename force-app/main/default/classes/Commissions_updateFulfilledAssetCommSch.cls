global class Commissions_updateFulfilledAssetCommSch implements Schedulable{
    global void execute(SchedulableContext sc) {       
        Map<id,OrderItem> lstOrderItems = new Map<id,OrderItem>([Select Id,Fulfillment_Status__c,Line_Type__c ,Asset__c,Commissions_are_calculated__c ,OrderId,CreatedById,PricebookEntryId,Product_Commission_Category__c ,Total_Net__c,CreatedDate from OrderItem
                    where Commissions_are_calculated__c = true and Product_Commission_Category__c ='Tiger' order by CreatedDate Desc limit 20]);
        system.debug('lstOrderItems 1: '+lstOrderItems);
        if(lstOrderItems.size()>0){
             system.debug('lstOrderItems 2: '+lstOrderItems);
            Set<Id> OrderItemIds = new Set<Id>();
            for(OrderItem OrderItemRecord : lstOrderItems.values()){
                OrderItemIds.add(OrderItemRecord.id);
            }
            Map<Id,Commission__c> orderItemCommissions = new Map<Id,Commission__c>([Select id,Name,Order_Product__c,Related_to_Asset__c from Commission__c
                                        where Order_Product__c In : OrderItemIds]);
            Map<Id,Asset> orderItemParentAssets = new Map<Id,Asset>([Select id,Name,Order_Line_Item__c,Fulfillment_Status__c from asset
                                where Fulfillment_Status__c ='Fulfilled' and Order_Line_Item__c In : OrderItemIds]);
            Map<Id,Commission__c> commissionMap = new Map<Id,Commission__c>();
            for(Commission__c commissionRecord : orderItemCommissions.Values()){
                OrderItem OrderItemRecord = lstOrderItems.get(commissionRecord.Order_Product__c);
                if(OrderItemRecord != Null){
                    Asset assetRecord = orderItemParentAssets.get(OrderItemRecord.Asset__c);
                    if(assetRecord != Null){
                        commissionRecord.Related_to_Asset__c = assetRecord.id;                      
                        commissionMap.put(commissionRecord.id,commissionRecord);
                    }
                }
            }
            if(commissionMap.size() > 0){
                update commissionMap.values();
            }     
        }
        //Re-Scheduling JOB
        List<CronTrigger> listCronTriggerAsset = [select Id from CronTrigger where CronJobDetail.Name LIKE 'CommissionFulfilledAssetJob1A1%' and State = 'DELETED' and 
                            nextfiretime = null limit 10];
        system.debug('listCronTriggerAsset : '+listCronTriggerAsset.size());
        If(listCronTriggerAsset.size() > 0){
            system.debug('Job Loop 1 :');
            For(Integer i = 0; i < listCronTriggerAsset.size(); i++){ 
                system.debug('Job Loop 2 :');
                System.abortJob(listCronTriggerAsset[i].Id); 
            }
        }
                           
        Integer rcount =[SELECT count() FROM CronJobDetail WHERE Name LIKE 'CommissionFulfilledAssetJob1A1%'];
        system.debug('rcount : '+rcount);
        if(rcount < 4){
            system.debug('Job Execution Loop 1 :');
            Commissions_updateFulfilledAssetCommSch p = new Commissions_updateFulfilledAssetCommSch();
            Datetime dtt = System.now().addMinutes(1);     
            String sch = dtt.Second()+' '+dtt.Minute()+' '+dtt.hour()+' '+dtt.day()+' '+dtt.Month()+' ? '+dtt.year();
            system.schedule('CommissionFulfilledAssetJob1A1'+dtt, sch, p);

            List<CronTrigger> listCronTrigger = [select Id from CronTrigger where State = 'DELETED' and nextfiretime = null limit 20];
            system.debug('listCronTrigger : '+listCronTrigger.size());
            If (listCronTrigger.size() > 0){
                For (Integer i = 0; i < listCronTrigger.size(); i++){ 
                    System.abortJob(listCronTrigger[i].Id); 
                }
            }
        }        
            
    }    
}