//Name        : BatchProcessOpportunityDialList 
//Description : NVM Renewal opportunity Creation.
//Author      : Sonu Sharma 
// Date       : May 2018
// CRM-3937   :

global class BatchProcessOpportunityDialList implements Database.Batchable<sObject>{
global String Query;
global Set<Id> setAccountIds = new Set<Id>();
   global date rendat =System.Date.today().toStartOfMonth().addMonths(1).addDays(-1);
   global date todayDate =system.today();
   global set<String> setNotPromo = new set<String>{'RSBUNDLEFIVESTREET','RSBUNDLETOPMRKSNP','RSBUNDLESTDFIVESTREET','RSBUNDLESTDTOPMRKSNP'};
   
    //setNotPromo.add('RSBUNDLETOPMRKSNP');
    //setNotPromo.add('RSBUNDLESTDFIVESTREET');
    //setNotPromo.add('RSBUNDLESTDTOPMRKSNP');
   global Integer monthval=1;
   global Boolean runningNVMCM=false;
   global BatchProcessOpportunityDialList(){
            // Query=q;
             //rendat= system.today().addDays(-60);
             //system.debug('####'+rendat);
             Query = 'Select Id,Name from Account where Id=:setAccountIds';
                   Schedule_Batch_Setting__c nvmRenewalJob = Schedule_Batch_Setting__c.getValues('NVM Renewal Job Month');
if (nvmRenewalJob != null) {
            monthval = Integer.valueof(nvmRenewalJob.Execution_Min__c);
            rendat =System.Date.today().toStartOfMonth().addMonths(monthval).addDays(-1);
        }
        Schedule_Batch_Setting__c nvmRenewalJobCM = Schedule_Batch_Setting__c.getValues('NVM Renewal Job Contact Method');
if (nvmRenewalJobCM != null) {
            runningNVMCM = nvmRenewalJobCM.is_running__c;
        }
        
               }

   global Database.QueryLocator start(Database.BatchableContext BC){
      system.debug('####'+query);
      return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, 
                       List<Account> accscope){
                         Set<Id> setmyAccountId = new Set<Id>();
                         for(Account acscp:accscope){
                           setmyAccountId.add(acscp.id);
                         }
                          Set<String> setAccountType = new Set<String>();
                            setAccountType.add('Realtor Agent');
                            setAccountType.add('Broker');
                         Set<String> setRenewalStatus = new Set<String>();
                         setRenewalStatus.add('Do Not Renew');
                         setRenewalStatus.add('Pending Fulfillment');
                      String  AssQuery = 'Select id,name,Opportunity__c,Parent_Asset__c,Had_do_not_renew__c, Total_Net__c ,Account.OwnerId,AccountId,Account.phone,Account.Mobile1__c,Account.Home_Phone__c,Account.Work_Phone__c,Product2Id,Product2.ProductCode,Status,';
                         AssQuery += 'Asset_Stage__c,Quantity,Auto_Renewal__c,BOP_Code__c,Email__c,Net_Price__c,inflight_quote__c,';
                         AssQuery += 'End_Date__c,Lead_Type__c,Line_Type__c,List_Price__c,Market_Zip__c,';
                         
                         AssQuery += 'Market__c,Market_Tier__c,Ultimate_Parent__c from Asset where Account.Type=:setAccountType and Asset_Type__c=\'Parent\' and Renewal_Type__c!=\'Auto\' and Haircut_Asset__c=false and Product2.Beta__c=false' ;
                         AssQuery += ' and End_Date__c<:rendat and Promotion__c!=:setNotPromo and AccountId=:setmyAccountId and End_Date__c>=:todayDate and Status = \'Active\' and Fulfillment_Status__c=\'Fulfilled\' and Renewal_Status__c!=:setRenewalStatus' ;
                         AssQuery += ' and Prosoft_Evergreen_Renewal__c!=true'; // CRM-5745 - Exclude Prosoft Evergreen assets
						 AssQuery += ' and No_Term_Sale__c!=true'; // CRM-6105 - Exclude Month-to-Month assets from Manual Renewal Opportunities
                         //AssQuery += 'Market__c,Market_Tier__c,Ultimate_Parent__c from Asset Where (Product2.ProductCode != \'FIVESTREET\' AND Account.Type=\'Realtor Agent\' and Asset_Type__c=\'Parent\' and Renewal_Type__c!=\'Auto\' and Haircut_Asset__c=false and Product2.Beta__c=false';
                         //AssQuery += ' and End_Date__c<:rendat and AccountId=:setmyAccountId and End_Date__c>=:todayDate and Renewal_Start_Date__c=null and Status = \'Active\' and Fulfillment_Status__c=\'Fulfilled\' and Renewal_Status__c!=:setRenewalStatus) OR (Product2.ProductCode = \'FIVESTREET\' AND Total_Net__c > 0)';
                        System.debug(AssQuery+' myQuery');
                         List<Asset> scope = Database.query(AssQuery);
                       Map<Id,Set<Id>> AccountAssetIds = new Map<Id,Set<Id>>();
                       Map<Id,String> mapAccountInflightStatus = new Map<Id,String>();
                       Map<Id,Decimal> setAccountIds = new Map<Id,Decimal>();
                       Map<Id,Boolean> mapHaveCBC = new Map<Id,Boolean>();
                       Map<Id,Date> mapAssetEndDate = new Map<Id,Date>();
                       Map<Id,OpportunityDialWrapper> mapOpportunityDial = new Map<Id,OpportunityDialWrapper>();
                       for(Asset ass:scope){
                           //Updated by Pratik on 13th August for CRM-4562
                           if(ass.Product2.ProductCode == 'FIVESTREET' && ass.Total_Net__c <= 0)
                               continue;
                           //ends here
                       OpportunityDialWrapper odw = new OpportunityDialWrapper();
                       odw.AccountId = '';
                       odw.InflightStatus = '';
                       odw.Havecbc = false;
                       odw.HasAssetDonotrenew = false;
                       odw.HaveDap = false;
                       odw.Haveadvantage = false;
                       odw.phonenumber = '';
                       odw.Mobilenumber = '';
                       odw.Preferrednumber = '';
                       odw.HomePhonenumber = '';
                       odw.Officenumber = '';
                       odw.ExpiryDate = null;
                       odw.ExpiryCBCDate = null;
                       odw.ExpiryDAPDate = null;
                       odw.ExpiryAdvantageDate = null;
                       
                       if(mapOpportunityDial.containskey(ass.AccountId)){
                        odw =mapOpportunityDial.get(ass.AccountId);
                        //odw.ExpiryDate = (odw.ExpiryDate==null ? System.today().addDays(1) : odw.ExpiryDate);
                       //odw.ExpiryCBCDate = (odw.ExpiryCBCDate==null ? System.today().addDays(1) : odw.ExpiryCBCDate);
                       //odw.ExpiryDAPDate = (odw.ExpiryDAPDate==null ? System.today().addDays(1) : odw.ExpiryDAPDate);
                       //odw.ExpiryAdvantageDate = (odw.ExpiryAdvantageDate==null ? System.today().addDays(1) : odw.ExpiryAdvantageDate);                      
                       }
                       
                       Decimal amounnt = odw.totalAmount==null ? 0 : odw.totalAmount ;
                       if(ass.Total_Net__c==null){ass.Total_Net__c=0;}
                       amounnt = amounnt +ass.Total_Net__c;
                       odw.totalAmount = amounnt;
                       odw.OwnerId = ass.Account.ownerId;
                       odw.phonenumber = ass.Account.phone;
                       odw.Mobilenumber = ass.Account.Mobile1__c;
                       odw.Preferrednumber = ass.Account.phone;
                       odw.HomePhonenumber = ass.Account.Home_Phone__c;
                       odw.Officenumber = ass.Account.Work_Phone__c;
                       String Inflightstatus = odw.InflightStatus;
                       if(ass.inflight_quote__c!=null){
                       Inflightstatus = Inflightstatus + (Inflightstatus.length()<180 ? ass.inflight_quote__c : '');
                       }
                       odw.InflightStatus = Inflightstatus;
                        if(ass.Had_do_not_renew__c == true){
                           odw.HasAssetDonotrenew = true;
                       }
                       if(ass.End_date__c!=null){
                         //updated by Pratik for CRM-5525 on 30th January 2019
                         if((odw.ExpiryDate == null) || (odw.ExpiryDate > ass.End_date__c))
                           odw.ExpiryDate = ass.End_date__c;
                         //Ends Here
                       }
                       
                        if(ass.Product2.ProductCode=='COBROKE'){
                       odw.Havecbc = true;
                       if(ass.End_date__c!=null){
                          //updated by Pratik for CRM-5525 on 30th January 2019
                         if((odw.ExpiryCBCDate == null) || (odw.ExpiryCBCDate > ass.End_date__c))
                             odw.ExpiryCBCDate = ass.End_date__c;
                         //odw.ExpiryCBCDate = ass.End_date__c<odw.ExpiryCBCDate ? ass.End_date__c : odw.ExpiryCBCDate;
                         //Ends here
                       }
                       }
                       if(ass.Product2.ProductCode=='DIGITALAGENT'){
                       odw.HaveDap = true;
                        if(ass.End_date__c!=null){
                         if(odw.ExpiryDAPDate ==null ){odw.ExpiryDAPDate = ass.End_date__c;}
                       odw.ExpiryDAPDate = ass.End_date__c<odw.ExpiryDAPDate ? ass.End_date__c : odw.ExpiryDAPDate;
                        }
                       }
                       if(ass.Product2.ProductCode=='ADVANTAGE'){
                       odw.Haveadvantage = true;
                        if(ass.End_date__c!=null){
                         if(odw.ExpiryAdvantageDate ==null ){odw.ExpiryAdvantageDate = ass.End_date__c;}
                       odw.ExpiryAdvantageDate = ass.End_date__c<odw.ExpiryAdvantageDate ? ass.End_date__c : odw.ExpiryAdvantageDate;
                        }
                       }
                       odw.NVMUniqueString = 'NVM$$$OPPMY';
                       mapOpportunityDial.put(ass.AccountId,odw);
                       
                     
                       }
                       Set<String> setString = new Set<String>();
                       setString.add('NVM$$$OPPMY');
                       //}
                      Map<Id,Opportunity> mapOpportunity = createOpportunity(mapOpportunityDial);
                      for(Asset ass:scope){
                         if(ass.Product2.ProductCode == 'FIVESTREET' && ass.Total_Net__c <= 0)
                               continue;
                              ass.Opportunity__c = mapOpportunity.get(ass.AccountId).Id;
                              ass.NVM_opportunity_Id__c = mapOpportunity.get(ass.AccountId).Id;
                       }
                       
           update scope;
   }
   Public Map<Id,Opportunity> createOpportunity(Map<Id,OpportunityDialWrapper> mapOpportunityDial) {
   
        Map<Id,Opportunity> lstOpportunity = new Map<Id,Opportunity>(); 
        Map<Id,Account> mapAccount = new Map<Id,Account>();
        for(Account acct:[Select Id,name,ownerId from Account where Id=:mapOpportunityDial.keyset()]){
        mapAccount.put(acct.Id,acct);
        }
        String NVMOPP = 'NVM$$$OPPMY';
        Set<String> setStatusString= new Set<String>();
        setStatusString.Add('New');
        setStatusString.Add('In Progress');
        for(Opportunity Opp:[Select Id,name,NVM_opportunity__c,NVM_Opportunity_Amount__c,Has_Asset_Do_Not_Renew__c,AccountId from opportunity where AccountId=:mapOpportunityDial.keyset() and NVM_opportunity__c=:NVMOPP and Status__c=:setStatusString]){
         //Opp.NVM_Opportunity_Amount__c = Opp.NVM_Opportunity_Amount__c;//+ mapOpportunityDial.get(Opp.AccountId).totalAmount;
         Opp.Have_CBC__c = mapOpportunityDial.get(Opp.AccountId).Havecbc;
         opp.Has_Asset_Do_Not_Renew__c = mapOpportunityDial.get(Opp.AccountId).HasAssetDonotrenew;
         opp.Have_DAP__c = mapOpportunityDial.get(Opp.AccountId).HaveDap;
         opp.Have_advantage__c = mapOpportunityDial.get(Opp.AccountId).Haveadvantage;
                Opp.Have_inflight__c = mapOpportunityDial.get(Opp.AccountId).InflightStatus;
                //Opp.CloseDate = system.today()+30;
                Opp.Expiry_Date__c = mapOpportunityDial.get(Opp.AccountId).ExpiryDate;
                opp.Advantage_Expiry__c = mapOpportunityDial.get(Opp.AccountId).ExpiryAdvantageDate;
                opp.CBC_expiry__c = mapOpportunityDial.get(Opp.AccountId).ExpiryCBCDate;
                if(mapOpportunityDial.get(Opp.AccountId).ExpiryDAPDate!=null){
                opp.DAP_expiry__c = mapOpportunityDial.get(Opp.AccountId).ExpiryDAPDate;
                }
                opp.RecordTypeId = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('NVM Opportunity').RecordTypeId;
        lstOpportunity.put(Opp.AccountId,Opp);
        }
       
            for(Id AccId:mapOpportunityDial.keyset()){
                Opportunity theOpportunity = new Opportunity();
                theOpportunity.Name = 'The Opportunity';
                theOpportunity.StageName = 'Prospecting';
                theOpportunity.Status__c = 'New';
                if(lstOpportunity.containskey(AccId)){
                  theOpportunity = lstOpportunity.get(AccId);
                  
                } else{
                  theOpportunity.ownerId = mapOpportunityDial.get(AccId).ownerId;
                }
                theOpportunity.Have_CBC__c = mapOpportunityDial.get(AccId).Havecbc;
                theOpportunity.Have_DAP__c = mapOpportunityDial.get(AccId).HaveDap;
                theOpportunity.Has_Asset_Do_Not_Renew__c = mapOpportunityDial.get(AccId).HasAssetDonotrenew;
                theOpportunity.Have_advantage__c = mapOpportunityDial.get(AccId).Haveadvantage;
                theOpportunity.Have_inflight__c = mapOpportunityDial.get(AccId).InflightStatus;
                theOpportunity.CloseDate = system.today()+30;
                theOpportunity.Expiry_Date__c = mapOpportunityDial.get(AccId).ExpiryDate;
                theOpportunity.Advantage_Expiry__c = mapOpportunityDial.get(AccId).ExpiryAdvantageDate;
                theOpportunity.CBC_expiry__c = mapOpportunityDial.get(AccId).ExpiryCBCDate;
                theOpportunity.DAP_expiry__c = mapOpportunityDial.get(AccId).ExpiryDAPDate;
               
                theOpportunity.NVM_opportunity__c = 'NVM$$$OPPMY';
                theOpportunity.AccountId = AccId;
                theOpportunity.Phone__C = mapOpportunityDial.get(AccId).phonenumber;
                theOpportunity.mobile_Phone__C = mapOpportunityDial.get(AccId).Mobilenumber;
                theOpportunity.Other_Phone__c = mapOpportunityDial.get(AccId).Officenumber;
                theOpportunity.RecordTypeId = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('NVM Opportunity').RecordTypeId;
                theOpportunity.Home_Phone__c = mapOpportunityDial.get(AccId).homephonenumber;
                //preferred_Phone__C = mapOpportunityDial.get(AccId).phonenumber,
                theOpportunity.NVM_Opportunity_Amount__c = mapOpportunityDial.get(AccId).totalAmount;
                theOpportunity.Is_Renewal_Opp__c = true;
                theOpportunity.Account_Type__c = 'Renewal';
                lstOpportunity.put(theOpportunity.AccountId,theOpportunity); 
               
                }
                if(!lstOpportunity.values().isempty() && lstOpportunity.values().size()>0 && runningNVMCM){
                MoveUtility.updatePhoneFields(lstOpportunity.values(),lstOpportunity.keyset());
                }
        
        
        upsert lstOpportunity.values();
        if(Test.isRunningTest()){
        // Integer ii = 1/0;
        }
       
       // }
       /* catch(Exception e) {
            system.debug('TRACE: Exception Occurred - ' + e.getStackTraceString());
       
        }*/
    
     return lstOpportunity;
  }
  
  Public void processAssets(List<Asset> lstAsset){
    Set<String> setStatus  = new Set<String>();
   Set<String> setOppIds  = new Set<String>();
    for(Asset ast:lstAsset){
          ast.Opportunity__c = null;
          setOppIds.add(ast.NVM_opportunity_Id__c);
          }
          update lstAsset;
          Set<String> setStatusString= new Set<String>();
        setStatusString.Add('New');
        setStatusString.Add('In Progress');
       
          for(Asset oppt:[SELECT Id,Opportunity__c FROM Asset where Opportunity__r.Status__c=:setStatusString and Follow_Up_Status__c!='Will Not Renew' and end_date__c>=today and Status='Active' order by LastModifiedDate DESC]){
            //setAssetOppIds.add(oppt.Opportunity__c);    
            setOppIds.remove(oppt.Opportunity__c);      
          }
          if(setOppIds.size()>0){
            List<Opportunity> lstAllOpportunity = [Select Id,name,Status__c from opportunity where Id=:setOppIds];
          
            for(opportunity opp:lstAllOpportunity){
              opp.Status__c = 'Rejected';
            }
            update lstAllOpportunity;
          }
  }
   global void finish(Database.BatchableContext BC){
   String NVMOPP = 'NVM$$$OPPMY';
   Set<String> setStatus  = new Set<String>();
   Set<String> setOppIds  = new Set<String>();
   setStatus.add('Expired');
   setStatus.add('Cancelled');
    List<Asset> lstAsset = [Select Id,Opportunity__c, NVM_opportunity_Id__c from Asset where Opportunity__r.NVM_opportunity__c=:NVMOPP and Opportunity__r.Status__c!='Expired' and Status=:setStatus limit 50];
       if(lstAsset.size()>0){
          processAssets(lstAsset);
          } else{
          Set<String> setLineType = new Set<String>();
          Set<Id> setAssetOppIds = new Set<Id>();
          Map<Id,Boolean> mapOppId = new Map<Id,Boolean>();
          Set<Id> setAssetId = new Set<Id>();
          DateTime mydtTime = System.now().AddDays(-18);
          setLineType.add('renew');
          setLineType.add('Renew');
          Set<String> setExcludeStatus = new Set<String>();
          setExcludeStatus.add('Converted');
          setExcludeStatus.add('Rejected');
          List<BigMachines__Quote_Product__c> lstQuoteProduct = [Select Id,name,Asset__c,Asset__r.Opportunity__c from BigMachines__Quote_Product__c where Asset__r.Opportunity__r.NVM_opportunity__c=:NVMOPP and BigMachines__Quote__r.BigMachines__Status__c ='Ordered' and Line_Type__c=:setLineType and Asset__r.Opportunity__r.status__c!=:setExcludeStatus and LastModifiedDate>=:mydtTime];
          for(BigMachines__Quote_Product__c bqp:lstQuoteProduct){
            setAssetOppIds.add(bqp.Asset__r.Opportunity__c);
            mapOppId.put(bqp.Asset__r.Opportunity__c,true);
            setAssetId.add(bqp.Asset__c);
          }
          
          Set<Id> setFinalOppIds = new Set<Id>();
          //setAssetOppIds;
          map<Id,Opportunity> lstOpportunity = new map<Id,Opportunity>();// [Select Id,name,Status__c from opportunity where Id=:setAssetOppIds and Status__c != 'Converted' and NVM_opportunity__c=:NVMOPP];
         /* for(Opportunity opp:lstOpportunity){
            opp.Status__c = 'Converted';
          }*/
          Set<String> setStatusString= new Set<String>();
        setStatusString.Add('New');
        setStatusString.Add('In Progress');
       
          for(Asset oppt:[SELECT Id,Opportunity__c FROM Asset where Opportunity__r.Status__c=:setStatusString and Follow_Up_Status__c='Will Not Renew' and end_date__c>=today and Status='Active' order by LastModifiedDate DESC limit 300]){
            setAssetOppIds.add(oppt.Opportunity__c);          
          }
          Set<Id> setHaveAsset =  new Set<Id>();
           Set<String> setFollowUpStatus= new Set<String>();
           setFollowUpStatus.add('Will Not Renew');
           setFollowUpStatus.add('Renewed');
          for(Asset assopp:[Select Id,Name,Follow_Up_Status__c,Opportunity__c from Asset where Id!=:setAssetId and Opportunity__c=:setAssetOppIds and Follow_Up_Status__c!=:setFollowUpStatus]){
            setHaveAsset.add(assopp.Opportunity__c);
          }
          setAssetOppIds.removeAll(setHaveAsset);
          for(Opportunity opp:[Select Id,status__c from Opportunity where Id=:setAssetOppIds and NVM_opportunity__c=:NVMOPP and Status__c!=:setExcludeStatus]){
            if(mapOppId.containskey(opp.Id)){
              opp.Status__c = 'Converted';
            } else {
            opp.Status__c = 'Rejected';
            }
            lstOpportunity.put(opp.id,opp);
          }
          DateTime dt = System.now().AddDays(1);
          Schedule_Batch_Setting__c NVMNextContTime = Schedule_Batch_Setting__c.getValues('NVM Next Contact Time');
          Integer MinTime=60;
          if(NVMNextContTime!=null){
            MinTime = 30+Integer.valueof(NVMNextContTime.Execution_Min__c);
          }
          DateTime dtm = System.now().AddMinutes(-MinTime);
          if(Test.isRunningTest()){dtm = dtm.AddHours(2);}
            //List<Opportunity> RemovecallbackOpportunity = ;
              for(Opportunity oppt:[SELECT NextContactTime__c,Id FROM Opportunity WHERE NextContactTime__c != null and NVM_contact_timestamp__c<=:dtm order by LastModifiedDate ASC limit 25]){
                oppt.NextContactTime__c= null;
                oppt.NVM_contact_timestamp__c = null;
                lstOpportunity.put(oppt.id,oppt);
              }
          update lstOpportunity.values();
          }
          BatchProcessUpdateInterestedMarketz BPUIM = new BatchProcessUpdateInterestedMarketz();
          BPUIM.setAccountIds = setAccountIds;
          Database.executeBatch(BPUIM,1);
          }
               
}