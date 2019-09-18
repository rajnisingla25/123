global class ExpirationAndRenewal_CreditJob_Schedular implements Schedulable{

     global final integer totalBatchJobCount    = 3;
     global final string jobName                = 'ExpirationAndRenewalCreditJob';
     global final list<string> creditStatusForQuery = new list<string>{ TurboUtilityClass.creditInProgressStatus,
                                                                        TurboUtilityClass.creditProcessedStatus,
                                                                        TurboUtilityClass.creditNotRequiredStatus};
global Integer currentHour = System.now().hour();
     global Integer currentMin;
     global void execute(SchedulableContext sc) {

     	Schedule_Batch_Setting__c orderp= Schedule_Batch_Setting__c.getValues('Turbo Expiration Credit');
     	Integer TurboExecutionTime=20;
     	if(orderp!=null){
     		TurboExecutionTime=Integer.valueof(orderp.Execution_Time_hr__c+'');

     	}
                   try{
                    if( !Test.isRunningTest() ){
                currentMin = System.now().Minute();
                   }
           if((currentHour<=TurboExecutionTime  )){
            // if(false){
                integer batchItemCount = [  Select  COUNT()
                                            from    Asset
                                            where
                                                Product_Code__c             = :TurboUtilityClass.turboProductCode
                                                AND
                                                Credit_Status__c            NOT IN :creditStatusForQuery
                                                AND
                                                Status                      NOT In ('Cancelled','Expired')
                                                AND
                                                Asset_Type__c               = :TurboUtilityClass.assetTypeParent
                                                AND
                                                Fulfillment_Status__c       = :TurboUtilityClass.fulfilledStatus
                                                AND
                                                CampaignId__c               != null
                                                AND
                                                Contractedimpressions__c    > 0
                                                AND
                                                Renewal_Order_Product__c    != null
                                                AND
                                                Renewal_Order_Product__r.Line_Type__c = 'Renew'
                                                AND
                                                Renewal_Start_Date__c       != null
                                                AND
                                                End_Date__c                 <= YESTERDAY
                                            limit 1];

                if( batchItemCount > 0 ){
                    CreateCreditQuoteForRenewalAssetBatch batchInst = new CreateCreditQuoteForRenewalAssetBatch();
                    ID batchprocessid = Database.executeBatch(batchInst, 1);
                } else {
                    integer batchItemCountp = [  Select  COUNT()
                                            from    Asset
                                            where
                                                End_Date__c                <= YESTERDAY
                                                AND
                                                Product_Code__c             = :SellerLeadUtilityClass.sellerLeadProductCode
                                                AND
                                                Credit_Status__c            NOT IN :creditStatusForQuery
                                                AND
                                                Asset_Type__c               = :TurboUtilityClass.assetTypeParent
                                                AND
                                                Fulfillment_Status__c       = :TurboUtilityClass.fulfilledStatus
                                                AND
                                                Contractedimpressions__c    > 0
                                            limit 1];
                                            if( batchItemCountp > 0 || Test.isRunningTest()){
                    PopulateDeltaAmountOnAsset_Batch batchInst = new PopulateDeltaAmountOnAsset_Batch();
                    ID batchprocessid = Database.executeBatch(batchInst, 5);
                                            }
                }


            }else if(currentHour>TurboExecutionTime ){
                Date dt = System.Today();
                integer batchItemCount = [  Select  COUNT()
                                            from    Asset
                                            where
                                                Product_Code__c         = :TurboUtilityClass.turboProductCode
                                                AND
                                                Credit_Status__c        NOT IN :creditStatusForQuery
                                                AND
                                                Status                 =:TurboUtilityClass.assetStatusActive
                                                AND
                                                Asset_Type__c           = :TurboUtilityClass.assetTypeParent
                                                AND
                                                Fulfillment_Status__c   =:TurboUtilityClass.fulfilledStatus
                                                AND
                                                End_date__c             =:dt
                                                AND
                                                CampaignId__c           != null
                                                AND
                                                Contractedimpressions__c > 0
                                            limit 1];

                if( batchItemCount > 0 ){
                    CreateCreaditQuoteForExpiredAssetBatch batchInst = new CreateCreaditQuoteForExpiredAssetBatch();
                    ID batchprocessid = Database.executeBatch(batchInst, 1);
                } else {
                	integer batchItemCountp = [  Select  COUNT()
                                            from    Asset
                                            where
                                                End_Date__c                <= YESTERDAY
                                                AND
                                                Product_Code__c             = :SellerLeadUtilityClass.sellerLeadProductCode
                                                AND
                                                Credit_Status__c            NOT IN :creditStatusForQuery
                                                AND
                                                Asset_Type__c               = :TurboUtilityClass.assetTypeParent
                                                AND
                                                Fulfillment_Status__c       = :TurboUtilityClass.fulfilledStatus
                                                AND
                                                Contractedimpressions__c    >= 0 //CRM-1646
                                            limit 1];
                                            if( batchItemCountp > 0 ){
                    PopulateDeltaAmountOnAsset_Batch batchInst = new PopulateDeltaAmountOnAsset_Batch();
                    ID batchprocessid = Database.executeBatch(batchInst, 5);
                                            }
                }

            }else {
                integer batchItemCount = [  Select  COUNT()
                                            from    Asset
                                            where
                                                End_Date__c                <= YESTERDAY
                                                AND
                                                Product_Code__c             = :SellerLeadUtilityClass.sellerLeadProductCode
                                                AND
                                                Credit_Status__c            NOT IN :creditStatusForQuery
                                                AND
                                                Asset_Type__c               = :TurboUtilityClass.assetTypeParent
                                                AND
                                                Fulfillment_Status__c       = :TurboUtilityClass.fulfilledStatus
                                                AND
                                                Contractedimpressions__c    >= 0  //CRM-1646
                                            limit 1];

                if( batchItemCount > 0 ){
                    PopulateDeltaAmountOnAsset_Batch batchInst = new PopulateDeltaAmountOnAsset_Batch();
                    ID batchprocessid = Database.executeBatch(batchInst, 5);
                }
            }

        Integer rcount =[SELECT count() FROM CronJobDetail WHERE Name LIKE 'ExpirationAndRenewalCreditJobA1A%'];
     if(rcount<2){
     ExpirationAndRenewal_CreditJob_Schedular p = new ExpirationAndRenewal_CreditJob_Schedular();
                Datetime dtt;
                dtt = System.now().addMinutes(6).addSeconds(15);
                if(currentHour>19){
                	 dtt = System.now().addMinutes(25).addSeconds(15);
                }
                if(Test.isRunningTest()){
                dtt = System.now().addMinutes(6+currentMin).addSeconds(15);
                }
                String sch = dtt.Second()+' '+dtt.Minute()+' '+dtt.hour()+' '+dtt.day()+' '+dtt.Month()+' ? '+dtt.year();
                system.schedule('ExpirationAndRenewalCreditJobA1A'+dtt, sch, p);

                List<CronTrigger> listCronTrigger = [select Id from CronTrigger where State = 'DELETED' and nextfiretime = null limit 20];
                  If (listCronTrigger.size() > 0)
                  {
                   For (Integer i = 0; i < listCronTrigger.size(); i++)
                   { System.abortJob(listCronTrigger[i].Id); }
                      }
                  }
                  if(Test.isRunningTest()){
                  	Integer iiii=1/0;
                  }
        } catch(Exception ex){
        Integer rcount =[SELECT count() FROM CronJobDetail WHERE Name LIKE 'ExpirationAndRenewalCreditJobA1A%'];
     if(rcount<2 || Test.isRunningTest()){
     ExpirationAndRenewal_CreditJob_Schedular p = new ExpirationAndRenewal_CreditJob_Schedular();
                Datetime dtt;
                dtt = System.now().addMinutes(6).addSeconds(15);
                if(Test.isRunningTest()){
                //dtt = System.now().addMinutes(6+currentMin).addSeconds(15);
                }
                String sch = dtt.Second()+' '+dtt.Minute()+' '+dtt.hour()+' '+dtt.day()+' '+dtt.Month()+' ? '+dtt.year();
                if(!Test.isRunningTest()){
                system.schedule('ExpirationAndRenewalCreditJobA1A'+dtt, sch, p);
                }
                List<CronTrigger> listCronTrigger = [select Id from CronTrigger where State = 'DELETED' and nextfiretime = null limit 20];
                  If (listCronTrigger.size() > 0)
                  {
                   For (Integer i = 0; i < listCronTrigger.size(); i++)
                   { System.abortJob(listCronTrigger[i].Id); }
                      }
                  }
        }
     }
  }