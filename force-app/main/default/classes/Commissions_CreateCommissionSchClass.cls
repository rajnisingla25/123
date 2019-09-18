global class Commissions_CreateCommissionSchClass implements Schedulable{
    global void execute(SchedulableContext sc) {       
        //CREATING COMMISSIONS FROM ASSETS
        List<Asset> lstAssets = [select id,Name,accountId,Product2Id,Sign_in_AE__c,OwnerId,Asset_Type__c,Fulfillment_Status__c,Status,Account_Type__c,
                             LastModifiedDate,Delta_Price__c,CreatedDate,Line_Type__c,Legacy_Created_Date__c,End_Date__c,Billing_Period__c,Total_Net__c,Renewal_Type__c,
                             Commission_field__c,Sign_in_AE__r.Team__c,Start_Date__c,Commissions_are_calculated__c,Order_Line_Item__c,Order_Line_Item__r.Product_Commission_Category__c 
                             from asset where Fulfillment_Status__c =:Constants.FULFILLMENT_STATUS and Asset_Type__c =: Constants.ASSET_TYPE and 
                             (Commission_field__c = 'Calculate' Or Commission_field__c = ' ' Or Commission_field__c = Null) and 
                             Commissions_are_calculated__c = false and (Status = 'Active' Or Status = 'Cancelled') and Line_Type__c !=Null and
                             Order_Line_Item__r.Product_Commission_Category__c != 'tiger' and Record_Processed_for_commission__c = false and    
                             Account_Type__c != 'Franchise Company'
                             order by LastModifiedDate Desc limit 3];                                                          
                      
        if(lstAssets.size()>0){
            Commissions_CreateCommissionsHandler Commission = new Commissions_CreateCommissionsHandler();//Trigger.oldMap,Trigger.newMap);
            Map<id,asset> assetNewMap_Update = new Map<id,asset>();
            for(asset assetRecord :  lstAssets){
                assetNewMap_Update.put(assetRecord.Id,assetRecord);     
            }
            system.debug('assetNewMap_Update :'+assetNewMap_Update.size());
            if(assetNewMap_Update.size() > 0){
                system.debug('assetNewMap_Update Loop :');
                Commission.UpdateCommissions(assetNewMap_Update);
            }
            assetNewMap_Update.clear();
        }
        lstAssets.clear();
        //Re-Scheduling JOB
        List<CronTrigger> listCronTriggerAsset = [select Id from CronTrigger where CronJobDetail.Name LIKE 'CommissionNewSaleJob1A1%' and State = 'DELETED' and 
                            nextfiretime = null limit 10];
        system.debug('listCronTriggerAsset : '+listCronTriggerAsset.size());
        If(listCronTriggerAsset.size() > 0){
            system.debug('Job Loop 1 :');
            For(Integer i = 0; i < listCronTriggerAsset.size(); i++){ 
                system.debug('Job Loop 2 :');
                System.abortJob(listCronTriggerAsset[i].Id); 
            }
        }
                           
        Integer rcount =[SELECT count() FROM CronJobDetail WHERE Name LIKE 'CommissionNewSaleJob1A1%'];
        system.debug('rcount : '+rcount);
        if(rcount < 2){
            system.debug('Job Execution Loop 1 :');
            Commissions_CreateCommissionSchClass p = new Commissions_CreateCommissionSchClass();
            Datetime dtt = System.now().addMinutes(1);     
            String sch = dtt.Second()+' '+dtt.Minute()+' '+dtt.hour()+' '+dtt.day()+' '+dtt.Month()+' ? '+dtt.year();
            system.schedule('CommissionNewSaleJob1A1'+dtt, sch, p);

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