//**************************************************//
// Class Name : AsyncRecordProcessExecution
//
//Modified 29th Aug 2016  Author Name: Pallavi Tammana -- Modifed for JIRA STORY ADVP-2026
//
global class AsyncRecordProcessExecution implements Schedulable {
   public static Boolean skipessentials = false;
   global void execute(SchedulableContext sc) {
     //Expire Assets
     Map<String,Id> errorIdMaps = new Map<String,Id>();
     try{

        Set<String> setProrityMethods = new Set<String>{'AccountActivateEssentialStatus'};
     Map<Id,AsyncRecordProcessExecution__c> lstAsyncProcess = new Map<Id,AsyncRecordProcessExecution__c>([Select Id,Name,Is_Error__c,Records_To_Process_Ids__c,MethodName__c,Boolean_Param__c,Is_Processes__c,ClassName__c,Interface_Name__c from AsyncRecordProcessExecution__c where Is_Processes__c=false and MethodName__c=:setProrityMethods and Is_Error__c=false order by CreatedDate Asc limit 4]);
        Schedule_Batch_Setting__c orderp= Schedule_Batch_Setting__c.getValues('Async Process');
        Integer ExecutionNumber=3;
        if(orderp!=null){
            ExecutionNumber=Integer.valueof(orderp.Execution_Time_hr__c+'');
        }
            Boolean processExpireBrokerShowcase = true;
            Boolean processCreateUpdateAssetShowcase = true;
            Boolean processCallCreateUpdateProductExclusion = true;
            Boolean processShowCaseOfficeAgent = true;
            Boolean processAsyncaddRepToAccount = true;
            Boolean processDeleteProductExclusion = true;
            Boolean processProcessBackout = true;
            Boolean processMergeObjects = true;
            Boolean processAccountActivateEssentialStatus = true;
            Boolean processAsyncupdateOfficeAccounts = true;
            Boolean processAsyncOpportunityUpdate = true;
            Schedule_Batch_Setting__c varExpireBrokerShowcase = Schedule_Batch_Setting__c.getValues('ExpireBrokerShowcase');
            Schedule_Batch_Setting__c varCreateUpdateAssetShowcase = Schedule_Batch_Setting__c.getValues('CreateUpdateAssetShowcase');
            Schedule_Batch_Setting__c varCallCreateUpdateProductExclusion= Schedule_Batch_Setting__c.getValues('CallCreateUpdateProductExclusion');
            Schedule_Batch_Setting__c varShowCaseOfficeAgent = Schedule_Batch_Setting__c.getValues('ShowCaseOfficeAgent');
            Schedule_Batch_Setting__c varAsyncaddRepToAccount = Schedule_Batch_Setting__c.getValues('AsyncaddRepToAccount');
            Schedule_Batch_Setting__c varDeleteProductExclusion= Schedule_Batch_Setting__c.getValues('DeleteProductExclusion');
            Schedule_Batch_Setting__c varProcessBackout = Schedule_Batch_Setting__c.getValues('ProcessBackout');
            Schedule_Batch_Setting__c varMergeObjects = Schedule_Batch_Setting__c.getValues('MergeObjects');
            Schedule_Batch_Setting__c varAccountActivateEssentialStatus= Schedule_Batch_Setting__c.getValues('AccountActivateEssentialStatus');
            Schedule_Batch_Setting__c varAsyncupdateOfficeAccounts = Schedule_Batch_Setting__c.getValues('AsyncupdateOfficeAccounts');
            Schedule_Batch_Setting__c varAsyncOpportunityUpdate= Schedule_Batch_Setting__c.getValues('AsyncOpportunityUpdate');

     for(Integer ii=0;ii<ExecutionNumber;ii++){
     Boolean ExpireBrokerShowcaseAssetProductExclusionexecuted = false;
     Boolean CreateUpdateAssetShowcaseProductExclusionexecuted = false;
     Boolean CallCreateUpdateProductExclusionexecuted = false;
     Boolean ShowCaseOfficeAgentProductExclusion = false;
     Boolean caseAsyncaddRepToAccountTeamOnCaseClosure = false;
     Boolean ProcessBackoutexecuted = false;
     Boolean AsyncOpportunityUpdate = false;
     Boolean AccountActivateEssentialStatusexecuted = false;
     Boolean ProcessMergeExecuted = false;
     Boolean OfficeAccountProcessExecuted = false;
     Set<Id> setAccIdds = new Set<Id>();
        if(lstAsyncProcess.values().size()<2){
    for(AsyncRecordProcessExecution__c aspe:[Select Id,Name,Is_Error__c,Records_To_Process_Ids__c,MethodName__c,Boolean_Param__c,Is_Processes__c,ClassName__c,Interface_Name__c from AsyncRecordProcessExecution__c where Is_Processes__c=false and Is_Error__c=false order by CreatedDate Asc limit 10])
    {

     lstAsyncProcess.put(aspe.id,aspe);
    }
    }

  // List<AsyncRecordProcessExecution__c> lstAsyncProcess = [Select Id,Name,Is_Error__c,Records_To_Process_Ids__c,MethodName__c,Boolean_Param__c,Is_Processes__c,ClassName__c,Interface_Name__c from AsyncRecordProcessExecution__c where Is_Processes__c=false and Is_Error__c=false order by CreatedDate Asc limit 10];
    for(AsyncRecordProcessExecution__c asrde :lstAsyncProcess.values()){
    if(asrde.Records_To_Process_Ids__c==null){asrde.Is_Error__c=true; asrde.Is_Processes__c=true;}
    if(asrde.Is_Error__c!=true){
       errorIdMaps.put('Error',asrde.id);
    if(!ExpireBrokerShowcaseAssetProductExclusionexecuted && asrde.ClassName__c=='ProductExclusionTriggerHandler' && asrde.MethodName__c=='ExpireBrokerShowcaseAssetProductExclusion'){
    ProductExclusionTriggerHandler peth = new ProductExclusionTriggerHandler();
    if(asrde.Records_To_Process_Ids__c!=null){
    //Set<Id> setIds = new Set<Id>{asrde.Records_To_Process_Ids__c};
    List<String> strSet = asrde.Records_To_Process_Ids__c.remove('{').remove('}').remove(' ').split(',');
    Set<Id> setIdds = new Set<Id>();
    for(String str:strSet){
    if(str!=null && str!=''){
       setIdds.add(Id.valueOf(str));
       }
        }
        if(asrde.InterFace_Name__c=='AssetTrigger' || asrde.InterFace_Name__c=='OrderTrigger'){SkipProductRestrictionTriggerTrigger.setSkipTrgTrue();}
         if(processExpireBrokerShowcase){
         peth.ExpireBrokerShowcaseAssetProductExclusion(setIdds,asrde.Boolean_Param__c);
         asrde.Is_Processes__c = true;
         } else {   asrde.Is_Error__c = true; }
         ExpireBrokerShowcaseAssetProductExclusionexecuted = true;
         //if(asrde.InterFace_Name__c=='Asset Trigger'){SkipProductRestrictionTriggerTrigger.setSkipTrgTrue();}
       }
    }

    if(!CreateUpdateAssetShowcaseProductExclusionexecuted && asrde.ClassName__c=='ProductExclusionTriggerHandler' && asrde.MethodName__c=='CreateUpdateAssetShowcaseProductExclusion'){
    ProductExclusionTriggerHandler peth = new ProductExclusionTriggerHandler();
    if(asrde.Records_To_Process_Ids__c!=null){
    //Set<Id> setIds = new Set<Id>{asrde.Records_To_Process_Ids__c};
    List<String> strSet = asrde.Records_To_Process_Ids__c.remove('{').remove('}').remove(' ').split(',');
    Set<Id> setIdds = new Set<Id>();
    for(String str:strSet){
    if(str!=null && str!=''){
       setIdds.add(Id.valueOf(str));
       }
        }
        if(asrde.InterFace_Name__c=='AssetTrigger' || asrde.InterFace_Name__c=='OrderTrigger'){SkipProductRestrictionTriggerTrigger.setSkipTrgTrue();}
         if(processCreateUpdateAssetShowcase){
         peth.CreateUpdateAssetShowcaseProductExclusion(setIdds,asrde.Boolean_Param__c);
         asrde.Is_Processes__c = true;
         } else {   asrde.Is_Error__c = true; }
         CreateUpdateAssetShowcaseProductExclusionexecuted = true;
       }
    }

    if(!CallCreateUpdateProductExclusionexecuted && asrde.ClassName__c=='ProductExclusionTriggerHandler' && asrde.MethodName__c=='CallCreateUpdateProductExclusion'){
    ProductExclusionTriggerHandler peth = new ProductExclusionTriggerHandler();
    if(asrde.Records_To_Process_Ids__c!=null){
    //Set<Id> setIds = new Set<Id>{asrde.Records_To_Process_Ids__c};
    List<String> strSet = asrde.Records_To_Process_Ids__c.remove('{').remove('}').remove(' ').split(',');
    Set<Id> setIdds = new Set<Id>();
    for(String str:strSet){
    if(str!=null && str!=''){
       setIdds.add(Id.valueOf(str));
       }
        }
        if(asrde.InterFace_Name__c=='AssetTrigger' || asrde.InterFace_Name__c=='OrderTrigger'){SkipProductRestrictionTriggerTrigger.setSkipTrgTrue();}
         if(processCallCreateUpdateProductExclusion){
         peth.CallCreateUpdateProductExclusion(setIdds,asrde.Boolean_Param__c);
         asrde.Is_Processes__c = true;
         } else {   asrde.Is_Error__c = true; }
         CallCreateUpdateProductExclusionexecuted = true;
       }
    }

     if(!ShowCaseOfficeAgentProductExclusion && asrde.ClassName__c=='ProductExclusionTriggerHandler' && asrde.MethodName__c=='ShowCaseOfficeAgentProductExclusion'){
    ProductExclusionTriggerHandler peth = new ProductExclusionTriggerHandler();
    if(asrde.Records_To_Process_Ids__c!=null){
    //Set<Id> setIds = new Set<Id>{asrde.Records_To_Process_Ids__c};
    List<String> strSet = asrde.Records_To_Process_Ids__c.remove('{').remove('}').remove(' ').split(',');
    Set<Id> setIdds = new Set<Id>();
    for(String str:strSet){
    if(str!=null && str!=''){
       setIdds.add(Id.valueOf(str));
       }
        }
        if(asrde.InterFace_Name__c=='AssetTrigger' || asrde.InterFace_Name__c=='OrderTrigger'){SkipProductRestrictionTriggerTrigger.setSkipTrgTrue();}
         if(processShowCaseOfficeAgent){
         peth.ShowCaseOfficeAgentProductExclusion(setIdds);
         asrde.Is_Processes__c = true;
         } else {   asrde.Is_Error__c = true; }
         ShowCaseOfficeAgentProductExclusion = true;
       }
    }

    if(!ShowCaseOfficeAgentProductExclusion && asrde.ClassName__c=='CaseTriggerHandlerManager' && asrde.MethodName__c=='AsyncaddRepToAccountTeamOnCaseClosure'){
    CaseTriggerHandlerManager cthm = new CaseTriggerHandlerManager();
    if(asrde.Records_To_Process_Ids__c!=null){
    //Set<Id> setIds = new Set<Id>{asrde.Records_To_Process_Ids__c};
    List<String> strSet = asrde.Records_To_Process_Ids__c.remove('{').remove('}').remove(' ').split(',');
    Set<Id> setIdds = new Set<Id>();
    for(String str:strSet){
    if(str!=null && str!=''){
       setIdds.add(Id.valueOf(str));
       }
        }
        if(asrde.InterFace_Name__c=='CaseTrigger'){SkipProductRestrictionTriggerTrigger.setSkipTrgTrue();}

         cthm.AsyncaddRepToAccountTeamOnCaseClosure(setIdds);
         asrde.Is_Processes__c = true;
         //} else {     asrde.Is_Error__c = true; }
         caseAsyncaddRepToAccountTeamOnCaseClosure = true;
       }
    }

    if(false && asrde.ClassName__c=='ProductExclusionTriggerHandler' && asrde.MethodName__c=='DeleteProductExclusion'){
   /* ProductExclusionTriggerHandler peth = new ProductExclusionTriggerHandler();
    if(asrde.Records_To_Process_Ids__c!=null){
    //Set<Id> setIds = new Set<Id>{asrde.Records_To_Process_Ids__c};
    List<String> strSet = asrde.Records_To_Process_Ids__c.remove('{').remove('}').remove(' ').split(',');
    Set<Id> setIdds = new Set<Id>();
    for(String str:strSet){
    if(str!=null && str!=''){
       setIdds.add(Id.valueOf(str));
       }
        }
         //peth.DeleteProductExclusion(setIdds,asrde.Boolean_Param__c);
         asrde.Is_Processes__c = true;
       }*/
    }

    //Backout Process
    if(!ProcessBackoutexecuted && asrde.ClassName__c=='AssetTriggerHelper' && asrde.MethodName__c=='ProcessBackout'){
    AssetTriggerHelper peth = new AssetTriggerHelper();
    if(asrde.Records_To_Process_Ids__c!=null){
    //Set<Id> setIds = new Set<Id>{asrde.Records_To_Process_Ids__c};
    List<String> strSet = asrde.Records_To_Process_Ids__c.remove('{').remove('}').remove(' ').split(',');
    Set<Id> setIdds = new Set<Id>();
    for(String str:strSet){
    if(str!=null && str!=''){
       setIdds.add(Id.valueOf(str));
        }
        }
        if(processProcessBackout){
         peth.ProcessBackout(setIdds);
         asrde.Is_Processes__c = true;
         } else {   asrde.Is_Error__c = true; }
         ProcessBackoutexecuted = true;
       }
    }

   // MergeProcess
    if(!ProcessBackoutexecuted && asrde.ClassName__c=='MergeServiceSOAP'  && asrde.MethodName__c=='MergeObjects'){
    MergeServiceSOAP peth = new MergeServiceSOAP();
    if(asrde.Records_To_Process_Ids__c!=null){
    //Set<Id> setIds = new Set<Id>{asrde.Records_To_Process_Ids__c};
    List<String> strSet = asrde.Records_To_Process_Ids__c.remove('{').remove('}').remove(' ').split(',');
    List<Id> setIdds = new List<Id>();
    for(String str:strSet){
    if(str!=null && str!=''){
       setIdds.add(Id.valueOf(str));
        }
        }/*
        if(processMergeObjects){
      MergeServiceSOAP.MergeInput mi = new MergeServiceSOAP.MergeInput();
      mi.SurvivorPartyID = asrde.Interface_Name__c;
      mi.VictimPartyIDs = setIdds;
      mi.EntityName = asrde.Name;
      MergeServiceSOAP.MergeObjects(mi);
         //peth.MergeObjects(setIdds);

         asrde.Is_Processes__c = true;
         } else {   asrde.Is_Error__c = true; }
         ProcessMergeExecuted = true;*/
       }
    }
    //Modified 29th Aug 2016  Author Name: Pallavi Tammana -- Modifed for JIRA STORY ADVP-2026
    System.debug('Im Here');
        if(asrde.ClassName__c== 'AccountTriggerHandlerManager' && asrde.MethodName__c=='AccountActivateEssentialStatus') {
        if(asrde.Records_To_Process_Ids__c!=null){
            System.debug('Im Here asrde:'+asrde);
            List<String> strSet = asrde.Records_To_Process_Ids__c.remove('{').remove('}').remove(' ').split(',');
            for(String str:strSet){
                if(str!=null && str!=''){
                    setAccIdds.add(Id.valueOf(str));
                }
            }
            asrde.Is_Processes__c = true;
            AccountActivateEssentialStatusexecuted = true;
        }
    }

     //Modified 23th Oct 2016  Author Name: Sonu Sharma
    if(asrde.ClassName__c== 'orderTriggerHandlerManager' && asrde.MethodName__c=='AsyncupdateOfficeAccounts') {
        orderTriggerHandlerManager athm = new orderTriggerHandlerManager();
        if(asrde.Records_To_Process_Ids__c!=null){
            System.debug('Im Here asrde:'+asrde);
            List<String> strSet = asrde.Records_To_Process_Ids__c.remove('{').remove('}').remove(' ').split(',');
            Set<Id> setIdds = new Set<Id>();
            for(String str:strSet){
                if(str!=null && str!=''){
                    setIdds.add(Id.valueOf(str));
                }
            }
           // athm.AsyncupdateOfficeAccounts(setIdds);
            asrde.Is_Processes__c = true;
            AsyncOpportunityUpdate = true;
        }
    }

    //Modified 29th Sept 2016  Author Name: Sonu Sharma
    if(asrde.ClassName__c== 'AssetTriggerHandlerManager' && asrde.MethodName__c=='AsyncOpportunityUpdate') {
        AssetTriggerHandlerManager athm = new AssetTriggerHandlerManager();
        if(asrde.Records_To_Process_Ids__c!=null){
            System.debug('Im Here asrde:'+asrde);
            List<String> strSet = asrde.Records_To_Process_Ids__c.remove('{').remove('}').remove(' ').split(',');
            Set<Id> setIdds = new Set<Id>();
            for(String str:strSet){
                if(str!=null && str!=''){
                    setIdds.add(Id.valueOf(str));
                }
            }
            if(processAsyncOpportunityUpdate){
            athm.AsyncOpportunityUpdate(setIdds);
            asrde.Is_Processes__c = true;
            } else {    asrde.Is_Error__c = true; }
            AsyncOpportunityUpdate = true;
        }
    }
    }
    }

    if(!setAccIdds.isEmpty()) {
        AccountTriggerHandlerManager athm = new AccountTriggerHandlerManager();
        skipessentials = true;
        if(processAccountActivateEssentialStatus){
        athm.accountActivateEssentialStatus(setAccIdds);
        }
       // } else {  asrde.Is_Error__c = true; }
    }

    Update lstAsyncProcess.values();
    }

     List<CronTrigger> listCronTriggerAsset = [select Id from CronTrigger where CronJobDetail.Name LIKE 'AsyncRecordProcessJobA1A%' and State = 'DELETED' and nextfiretime = null limit 10];
                  If (listCronTriggerAsset.size() > 0)
                  {
                   For (Integer i = 0; i < listCronTriggerAsset.size(); i++)
                   { System.abortJob(listCronTriggerAsset[i].Id); }
                      }


     Integer rcount =[SELECT count() FROM CronJobDetail WHERE Name LIKE 'AsyncRecordProcessJobA1A%'];
     if(rcount<2){
     AsyncRecordProcessExecution p = new AsyncRecordProcessExecution();
                Datetime dtt = System.now().addMinutes(1).addSeconds(10);
                String sch = dtt.Second()+' '+dtt.Minute()+' '+dtt.hour()+' '+dtt.day()+' '+dtt.Month()+' ? '+dtt.year();
                system.schedule('AsyncRecordProcessJobA1A'+dtt, sch, p);

                List<CronTrigger> listCronTrigger = [select Id from CronTrigger where State = 'DELETED' and nextfiretime = null limit 20];
                  If (listCronTrigger.size() > 0)
                  {
                   For (Integer i = 0; i < listCronTrigger.size(); i++)
                   { System.abortJob(listCronTrigger[i].Id); }
                      }
                  }

                  } Catch(Exception Ex){
                  if(errorIdMaps.values().size()>0){
                  List<AsyncRecordProcessExecution__c> lstAsyncProcess = [Select Id,Error_Description__c,Is_Error__c,Name,Records_To_Process_Ids__c,MethodName__c,Boolean_Param__c,Is_Processes__c,ClassName__c,Interface_Name__c from AsyncRecordProcessExecution__c where Id=:errorIdMaps.values()];
                  for(AsyncRecordProcessExecution__c arpe:lstAsyncProcess){
                  arpe.Is_Error__c=true;
                  arpe.Error_Description__c =  ex.getMessage() + '---StackTrace----' + ex.getStackTraceString();
                  }
                  update lstAsyncProcess;

                  }
                   Integer rcount =[SELECT count() FROM CronJobDetail WHERE Name LIKE 'AsyncRecordProcessJobA1A%'];
     if(rcount<2){
     AsyncRecordProcessExecution p = new AsyncRecordProcessExecution();
                Datetime dtt = System.now().addMinutes(1).addSeconds(10);
                String sch = dtt.Second()+' '+dtt.Minute()+' '+dtt.hour()+' '+dtt.day()+' '+dtt.Month()+' ? '+dtt.year();
                system.schedule('AsyncRecordProcessJobA1A'+dtt, sch, p);
     }
                  }

   }
}