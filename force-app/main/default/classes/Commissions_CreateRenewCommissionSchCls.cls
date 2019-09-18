/*******************************************************************************
Created By      :   Srinivas Pendli
Created Date    :   04-Nov-2015
Usage           :   It is schedule class and it will run every 1 minute.
                    The main purpose of this class is to collect and send asset into Handler class,commissions are creating from handler class.
                        * Batch size for this schedule job is 4.
                        * Schedule Job Name is 'CommissionsRenewalDynamic1' - Parent Job and 'CommissionRenewalJob1A1___' - Child Job
                        * Parent Job  runs every hour and child job runs every 2 minute.
                        * Parent Job and child jobs are inter related, child job execute from parent job only.
                        * if any exception occurs in child job(Record),will take that record from next run job. 
                        * Execution code : System.schedule('CommissionsRenewalDynamic1', '0 5 * * * ?', new Commissions_CreateRenewCommissionSchCls());
                        * Handler class name - 'Commissions_CreateRenewalCommissions'
Modified By     :   Srinivas Pendli
Modified Date   :   04-Nov-2015
Modified By  :   Sudhakar Reddy Lekkala on 26-May-2016 @ Line no 23 // LEAP-8492, Removed "Delta_Price__c" field from lstAssets Query.
********************************************************************************/
global class Commissions_CreateRenewCommissionSchCls implements Schedulable{
    //EXECUTE METHOD
    global void execute(SchedulableContext sc) {       
        //CREATING COMMISSIONS FROM ASSETS -
        //IT WILL FETCH ASSET RECORDS BASED ON THE CONDITIONS
        //CUSTOM SETTING TO DEFINE BATCH SIZE     
        Commission_Jobs_Batch_Size__c jobSize = Commission_Jobs_Batch_Size__c.getValues('Commission Jobs Size'); 
        
        List<Asset> lstAssets = [select id,Name,accountId,Product2Id,Sign_in_AE__c,OwnerId,Asset_Type__c,Fulfillment_Status__c,Status,Account_Type__c,
                             LastModifiedDate,CreatedDate,Owner.Profile.Name,Line_Type__c,Legacy_Created_Date__c,End_Date__c,Billing_Period__c,Total_Net__c,Renewal_Type__c,
                             Commission_field__c,Sign_in_AE__r.Team__c,Delta_Price_w_o_Tax__c,Start_Date__c,Commissions_are_calculated__c,Order_Line_Item__c,Order_Line_Item__r.Product_Commission_Category__c 
                             from asset where Fulfillment_Status__c =:Constants.FULFILLMENT_STATUS and Asset_Type__c =: Constants.ASSET_TYPE and 
                             (Commission_field__c = 'Calculate' Or Commission_field__c = ' ' Or Commission_field__c = Null) and 
                             Commissions_are_calculated__c = false and (Status = 'Active' Or Status = 'Cancelled') and Line_Type__c = 'Renew' and
                             Order_Line_Item__r.Product_Commission_Category__c != 'tiger' and Record_Processed_for_commission__c = false and    
                             Account_Type__c != 'Franchise Company'
                             order by LastModifiedDate Desc limit :Integer.ValueOf(jobSize.Renew_Job_Size__c)];                                                          
                      
        if(lstAssets.size()>0){
            Commissions_CreateRenewalCommissions Commission = new Commissions_CreateRenewalCommissions();
            Map<id,asset> assetNewMap_Update = new Map<id,asset>();
            //COLLECTIING ASSET IDS
            for(asset assetRecord :  lstAssets){
                assetNewMap_Update.put(assetRecord.Id,assetRecord);     
            }            
            //SENDING ASSET IDS INTO HANDLER CLASS-Commissions_CreateCommissionsHandler
            if(assetNewMap_Update.size() > 0){                
                Commission.CreateCommissions(assetNewMap_Update);
            }
            assetNewMap_Update.clear();
        }
        lstAssets.clear();
        //Re-Scheduling JOB
        List<CronTrigger> listCronTriggerAsset = [select Id from CronTrigger where CronJobDetail.Name LIKE 'CommissionRenewalJob1A1%' and State = 'DELETED' and 
                            nextfiretime = null limit 10];        
        //ABORTING/DELETING ALL JOBS WHICH ARE NO NEXT RUN(NEXT SCHEDULED TIME)
        If(listCronTriggerAsset.size() > 0){            
            For(Integer i = 0; i < listCronTriggerAsset.size(); i++){                 
                System.abortJob(listCronTriggerAsset[i].Id); 
            }
        }
                           
        Integer rcount =[SELECT count() FROM CronJobDetail WHERE Name LIKE 'CommissionRenewalJob1A1%'];        
        //RE-SUBMITING THE COMMISSIONS JOB-IT WILL EXECUTE EVERY 1 MINUTE-EVERY DAY 
        if(rcount < 2){            
            Commissions_CreateRenewCommissionSchCls p = new Commissions_CreateRenewCommissionSchCls();
            Datetime dtt = System.now().addSeconds(20);     
            String sch = dtt.Second()+' '+dtt.Minute()+' '+dtt.hour()+' '+dtt.day()+' '+dtt.Month()+' ? '+dtt.year();            
            system.schedule('CommissionRenewalJob1A1'+dtt, sch, p);
            //ABORTING/DELETING ALL JOBS WHICH ARE NO NEXT RUN(NEXT SCHEDULED TIME)
            List<CronTrigger> listCronTrigger = [select Id from CronTrigger where State = 'DELETED' and nextfiretime = null limit 20];            
            If (listCronTrigger.size() > 0){                
                For (Integer i = 0; i < listCronTrigger.size(); i++){                    
                    System.abortJob(listCronTrigger[i].Id); 
                }
            }
            listCronTrigger.clear(); 
        }
        listCronTriggerAsset.clear();              
    }        
}