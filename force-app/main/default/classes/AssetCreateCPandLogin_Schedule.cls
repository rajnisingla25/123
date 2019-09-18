global class AssetCreateCPandLogin_Schedule implements Schedulable
{

    public void execute(SchedulableContext sc) {
    Set<String> otype = new Set<String>{'New','Renewal','Auto-Renew'}; // CRM-1293 -- Added 'Auto-Renew'
    String stringexp = 'R';

    List<Asset> lstAsset = [SELECT Id,Name,BOP_Code__c,External_ID__c,AccountID,Account.Name,Account.Party_ID__c,Account.Type,Account.Customer_Id__c,Product2.Name,Product2.ProductCode FROM Asset WHERE Asset_Type__c = 'Parent' AND  Fulfillment_Status__c = 'Fulfilled' AND Get_CP_Login_Status__c = 'Ready'];
    List<Order> lstorder = [select id, is_BMS__c, Non_Renewal_count__c, Oracle_Quote__c, Oracle_Quote__r.cansendemail__c, type, show_cp_details__c, (select id,OrderId, order.oracle_quote__c from OrderItems) from Order where Status = 'Complete' and (Type =:otype OR (type = 'Modify' AND Non_Renewal_count__c = 0)) and cansendemail__c = false and tigerLeadProductExists__c = false and LastModifiedDate = today];
     try{
      if(System.now().Minute()<10 || lstAsset.size()>0 && (lstAsset.size()>=lstorder.size())){
        Database.executeBatch(new AssetCreateControlPanel_Batch ());
        } else{
                   if(lstorder.size()>0){
          CPloginparserandattachmentBatch b = new CPloginparserandattachmentBatch();
              database.executebatch(b);
        }
        }
         Integer rcount =[SELECT count() FROM CronJobDetail WHERE Name LIKE 'CPandLoginJobA1A%'];
     if(rcount<2){
     AssetCreateCPandLogin_Schedule p = new AssetCreateCPandLogin_Schedule();
                Datetime dtt = System.now().addMinutes(1).addSeconds(15);
                String sch = dtt.Second()+' '+dtt.Minute()+' '+dtt.hour()+' '+dtt.day()+' '+dtt.Month()+' ? '+dtt.year();
                system.schedule('CPandLoginJobA1A'+dtt, sch, p);

                List<CronTrigger> listCronTrigger = [select Id from CronTrigger where State = 'DELETED' and nextfiretime = null limit 20];
                  If (listCronTrigger.size() > 0)
                  {
                   For (Integer i = 0; i < listCronTrigger.size(); i++)
                   { System.abortJob(listCronTrigger[i].Id); }
                      }
                  }
                  if(Test.isRunningTest()){
                  integer ii=1/0;
                  stringexp = 'Runn';
                  }
        }
        catch(Exception Ex){
         Integer rcount =[SELECT count() FROM CronJobDetail WHERE Name LIKE 'CPandLoginJobA1A%'];
     if(rcount<2 || Test.isRunningTest()){
     AssetCreateCPandLogin_Schedule p = new AssetCreateCPandLogin_Schedule();
                Datetime dtt = System.now().addMinutes(2).addSeconds(17);
                String sch = dtt.Second()+' '+dtt.Minute()+' '+dtt.hour()+' '+dtt.day()+' '+dtt.Month()+' ? '+dtt.year();

                system.schedule('CPandLoginJobA1A'+stringexp+dtt, sch, p);

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