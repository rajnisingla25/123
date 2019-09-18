/*******************************************************************************
Created By         :   Srinivas Pendli
Created Date       :   04-Nov-2015
Usage              :   It is schedule class and it will run every 1 minute.
                       The main purpose of this class is to collect and send asset into Handler class,commissions are creating from handler class.
                         * Batch size for this schedule job is 4.
                         * Schedule Job Name is 'CommissionsNewSaleDynamic1' - Parent Job and 'CommissionNewSaleJob1A1___' - Child Job
                         * Parent Job  runs every hour and child job runs every 1 minute.
                         * Parent Job and child jobs are inter related, child job execute from parent job only.
                         * if any exception occurs in child job(Record),will pic that record from next run job. 
                         * Execution code : System.schedule('CommissionsNewSaleDynamic1', '0 1 * * * ?', new CommissionsNewSaleDynamic1());
                         * Handler class name - 'Commissions_CreateNewCommissionsHandler'
CODE MODIFICATION DETAILS :                    
1. Modified By     :   Srinivas Pendli on 25-MAY-2016 // added code comments
2. Modified By     :   Sudhakar Reddy Lekkala on 26-May-2016 @ Line no 23 // LEAP-8492, Removed "Delta_Price__c" field from lstAssets Query.
********************************************************************************/
global class Commissions_CreateNewCommissionSchClass implements Schedulable{
    //EXECUTE METHOD
    global void execute(SchedulableContext sc) {       
        //CREATING COMMISSIONS FROM ASSETS -
        //IT WILL FETCH ASSET RECORDS BASED ON THE CONDITIONS   
        //CUSTOM SETTING TO DEFINE BATCH SIZE     
        Commission_Jobs_Batch_Size__c jobSize = Commission_Jobs_Batch_Size__c.getValues('Commission Jobs Size');  
       
        List<Asset> lstAssets = [select id,Name,accountId,Product2Id,Sign_in_AE__c,OwnerId,Asset_Type__c,Fulfillment_Status__c,Status,Account_Type__c,
                             LastModifiedDate,CreatedDate,Line_Type__c,Legacy_Created_Date__c,End_Date__c,Billing_Period__c,Total_Net__c,Renewal_Type__c,
                             Commission_field__c,Sign_in_AE__r.Team__c,Delta_Price_w_o_Tax__c,Start_Date__c,Commissions_are_calculated__c,Order_Line_Item__c, Owner.Profile.Name, Order_Line_Item__r.Product_Commission_Category__c 
                             from asset where Fulfillment_Status__c =:Constants.FULFILLMENT_STATUS and Asset_Type__c =: Constants.ASSET_TYPE and 
                             (Commission_field__c = 'Calculate' Or Commission_field__c = ' ' Or Commission_field__c = Null) and 
                             Commissions_are_calculated__c = false and (Status = 'Active' Or Status = 'Cancelled') and Line_Type__c = 'Add' and
                             Order_Line_Item__r.Product_Commission_Category__c != 'tiger' and Record_Processed_for_commission__c = false and    
                             Account_Type__c != 'Franchise Company'
                             order by LastModifiedDate Desc limit :Integer.ValueOf(jobSize.New_Sale_Job_Size__c)];
                                                                                
                      
        if(lstAssets.size()>0){
            Commissions_CreateNewCommissionsHandler Commission = new Commissions_CreateNewCommissionsHandler();
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
        List<CronTrigger> listCronTriggerAsset = [select Id from CronTrigger where CronJobDetail.Name LIKE 'CommissionNewSaleJob1A1%' and State = 'DELETED' and 
                            nextfiretime = null limit 10];        
        //ABORTING/DELETING ALL JOBS WHICH ARE NO NEXT RUN(NEXT SCHEDULED TIME)
        If(listCronTriggerAsset.size() > 0){            
            For(Integer i = 0; i < listCronTriggerAsset.size(); i++){                 
                System.abortJob(listCronTriggerAsset[i].Id); 
            }
        }
                           
        Integer rcount =[SELECT count() FROM CronJobDetail WHERE Name LIKE 'CommissionNewSaleJob1A1%'];        
        //RE-SUBMITING THE COMMISSIONS JOB-IT WILL EXECUTE EVERY 1 MINUTE-EVERY DAY 
        if(rcount < 2){            
            Commissions_CreateNewCommissionSchClass p = new Commissions_CreateNewCommissionSchClass();
            Datetime dtt = System.now().addSeconds(15);     
            String sch = dtt.Second()+' '+dtt.Minute()+' '+dtt.hour()+' '+dtt.day()+' '+dtt.Month()+' ? '+dtt.year();            
            system.schedule('CommissionNewSaleJob1A1'+dtt, sch, p);
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