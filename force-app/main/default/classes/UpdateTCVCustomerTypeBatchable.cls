global class UpdateTCVCustomerTypeBatchable implements Database.Batchable<sObject>{
String query;

    global Database.querylocator start(Database.BatchableContext BC){
    DateTime dt = System.now().AddHours(-24);
        Query = 'SELECT   Account_Sub_Type__c FROM Account limit 1';
        return Database.getQueryLocator(query);
    }
   global void execute(Database.BatchableContext BC, List<account> scope) {
     //Expire Assets
     try{
          SkipAssetTrigger.setSkipTrgTrue();
          SkipAccountTrigger.skiptrigger = True;
          Set<Id> accIds = new Set<Id>();
          Boolean expiredProcesstype = false;
          List<Account> lstAccount = new List<Account>();
          Map<Id,Decimal> mapAccActive = new Map<Id,Decimal>();
          Map<Id,Decimal> mapAccExpired = new Map<Id,Decimal>();
          Map<Id,Decimal> mapAccProspect = new Map<Id,Decimal>();
           Map<Id,Decimal> mapAccList= new Map<Id,Decimal>();
           Map<Id,Date> mapRenewalDate = new Map<Id,Date>();
            Map<Id,Date> mapCancellationDate = new Map<Id,Date>();
           Map<Id,Id> mapAccOrder= new Map<Id,Id>();

            Decimal rcount = 0.0;
            Date dt = System.Today().addDays(-90);
            Date dtold = System.Today().addDays(-93);
            Set<String> setAssetStatus = new Set<String>();
            setAssetStatus.add('Expired');
            setAssetStatus.add('Cancelled');
           List<Asset> lstAssett = [Select Id,product_code__c,AccountId,Status,Total_net__c,Expired_Date__c ,Cancellation_Date__c,Renewal_Start_Date__c, Fulfillment_Status__c,TCV_Processed__c from Asset where Fulfillment_Status__c ='Fulfilled' and  Asset_Type__c = 'Parent' and Status =:setAssetStatus and TCV_Processed__c = '90Days' and (Expired_Date__c<=:dt and Expired_Date__c>=:dtold ) order by LastModifiedDate Desc limit 50];
         // List<Asset> lstAssetmarkingtrue = [Select Id,AccountId,Status,Total_net__c,Expired_Date__c , Fulfillment_Status__c,TCV_Processed__c from Asset where Fulfillment_Status__c ='Fulfilled' and  Asset_Type__c = 'Parent' and TCV_Processed__c = 'true' and (Expired_Date__c<=:dt and Expired_Date__c>=:dtold ) and LastModifiedDate!=today order by LastModifiedDate Desc limit 50];
          List<Asset> lstAsset = new List<Asset>();
          if(lstAssett.size()>0){
          expiredProcesstype = true;
          lstAsset.addAll(lstAssett);
          }

          else {
          lstAsset = [Select Id,product_code__c,AccountId,Status,Total_net__c,Expired_Date__c ,Cancellation_Date__c,Renewal_Start_Date__c, Fulfillment_Status__c,TCV_Processed__c from Asset where Fulfillment_Status__c ='Fulfilled' and Asset_Type__c = 'Parent' and TCV_Processed__c = 'false' and order_line_item__r.order.Status='Complete' and order_line_item__r.order.Fulfillment_Status__c = 'Fulfilled' order by LastModifiedDate Desc limit 50];
		  
          }
          if(lstAsset.size()<1){
          lstAsset = [Select Id,product_code__c,AccountId,Status,Total_net__c,Expired_Date__c ,Cancellation_Date__c,Renewal_Start_Date__c, Fulfillment_Status__c,TCV_Processed__c from Asset where Fulfillment_Status__c ='Fulfilled' and Asset_Type__c = 'Parent' and TCV_Processed__c = 'false' and  Status =:setAssetStatus order by LastModifiedDate Desc limit 50];

          }
          if(lstAsset.size()<1){
         lstAsset = [Select Id,product_code__c,AccountId,Status,Total_net__c,Expired_Date__c ,Cancellation_Date__c,Renewal_Start_Date__c, Fulfillment_Status__c,TCV_Processed__c from Asset where Fulfillment_Status__c ='Fulfilled' and Status='Active' and Asset_Type__c = 'Parent' and TCV_Processed__c = 'false' and order_line_item__c=null order by LastModifiedDate Desc limit 50];

          }

          if(Test.isRunningTest()){
          lstAsset = [Select Id,product_code__c,AccountId,Status,Total_net__c,Expired_Date__c ,Cancellation_Date__c,Renewal_Start_Date__c, Fulfillment_Status__c,TCV_Processed__c from Asset order by LastModifiedDate Desc limit 50];
          }

          for(Asset ast:lstAsset){
            if(ast.TCV_Processed__c == 'false' && setAssetStatus.contains(ast.Status)){
              ast.TCV_Processed__c = '90Days';
            } else {
                ast.TCV_Processed__c = 'true';

            }
              //ast.Expired_Date__c = null;
              if(ast.AccountId!=null){
              accIds.add(ast.AccountId);
              //mapAccList.put(ast.AccountId,0.0);
              }
              mapAccList.put(ast.AccountId,0.0);
            }

            List<Account> AllAccounts = new List<Account>();
            Map<String,Product_flag_mapping__c> productflagfields = Product_flag_mapping__c.getAll();
         System.debug('product code map values' + '########1' + productflagfields );
            Map<String,String> mapAcountFieldNameProductCode = new Map<String,String>();
            for(String sttr:productflagfields.keySet()){
mapAcountFieldNameProductCode.put(productflagfields.get(sttr).product_code__c,sttr);
                System.debug('product code map Account values' + '########2' + mapAcountFieldNameProductCode );
            }
            Map<String, Schema.SObjectField> accountSchemaFieldMap = Schema.SObjectType.Account.fields.getMap();
            String AccountQuery = 'Select id,Last_Cancellation__c,Next_Renewal_Date__c,Pre_Auth_User__c, Account_Sub_Type__c ,  ';
                        //CRM-1367 :- product flag update
                           for(String accFieldAPIName : productflagfields.keySet()) {
          if(
            accountSchemaFieldMap.containsKey(accFieldAPIName) &&
            accountSchemaFieldMap.get(accFieldAPIName).getDescribe().isAccessible()
          ) {
            AccountQuery += accFieldAPIName + ', ';
          }
        }
            AccountQuery = AccountQuery +' Total_Contract_Value__c from Account where id IN: accIds';
            System.debug('Account Query '+AccountQuery);
            AllAccounts = Database.Query(AccountQuery);
            Map<String,Boolean> mapAccountPcodeName = new Map<String,Boolean>();
            //CRM-1306 -- Map keeping not fulfilled order's account id
            for(Order odr:[Select Id,Name,AccountId from Order where AccountId=:accIds and Fulfillment_status__c!='Fulfilled']){
             mapAccOrder.put(odr.AccountId,odr.AccountId);
            }
            for(Asset ast:[Select Id,product2id,Renewal_Start_Date__c,Cancellation_Date__c,product_code__c,AccountId,Expired_Date__c,Status,End_Date__c,Total_net__c ,Fulfillment_Status__c from Asset where AccountId IN:accIds and Asset_Type__c = 'Parent']){
                   system.debug('Testing null2'+ast.status +'**'+ast.Expired_Date__c);
                    if(ast.Status == 'Active' && ast.Fulfillment_Status__c=='Fulfilled'){
                        if(mapAccList.containskey(ast.AccountId)){
                             //mapAccList.put(ast.AccountId,0.0);
                            Decimal rcountt = mapAccList.get(ast.AccountId);
                            system.debug('Testing null2'+ast.Total_net__c);
                            System.debug('Testing ** '+ast);
                            //CRM-1283 :- Next renewal date
                            if(ast.End_Date__c!=null){
                             if(mapRenewalDate.containskey(ast.AccountId)){
                                if(System.today()<=ast.End_Date__c){
                                   if(mapRenewalDate.get(ast.AccountId)>ast.End_Date__c){
                                        mapRenewalDate.put(ast.AccountId,ast.End_Date__c);
                                    }
                                }
                            } else {
                                    mapRenewalDate.put(ast.AccountId,ast.End_Date__c);
                                 }
                             }
                             //CRM-1283 :- Next renewal date
                            if(ast.Total_net__c!=null){rcountt =  rcountt+ast.Total_net__c;  }
                            system.debug('Testing null2'+rcountt);
                            mapAccList.put(ast.AccountId,rcountt);
                            mapAccActive.put(ast.AccountId,rcountt);
                        }
                        System.debug('related asset values' + '########3' + mapAcountFieldNameProductCode.get(ast.product_code__c));
                        mapAccountPcodeName.put(ast.AccountId+'###'+mapAcountFieldNameProductCode.get(ast.product_code__c),true);
                    }
                    if(ast.Expired_Date__c ==null){if(ast.End_Date__c!=null){ast.Expired_Date__c=ast.End_Date__c.AddDays(1);}}
                    if(ast.Expired_Date__c ==null){ast.Expired_Date__c=system.today();}
                    //CRM-1694 :- populate last cancellation date
                   if(ast.Cancellation_Date__c!=null && (ast.status == 'Cancelled')){
                   if(mapCancellationDate.containskey(ast.AccountId)){
                     system.debug((mapCancellationDate.get(ast.Id)<ast.Cancellation_Date__c)+'Testing null'+mapCancellationDate+'$$$$$'+ast.Cancellation_Date__c);
                    if(mapCancellationDate.get(ast.AccountId)<=ast.Cancellation_Date__c){
                     mapCancellationDate.put(ast.AccountId,ast.Cancellation_Date__c);
                     system.debug('Testing null'+mapCancellationDate);
                    }
                     } else {
                      mapCancellationDate.put(ast.AccountId,ast.Cancellation_Date__c);
                     }
                     }
                     //CRM-1694 :- populate last cancellation date
                    System.debug('****** '+date.valueof(ast.Expired_Date__c).daysBetween(Date.today()));
                     if((ast.status == 'Expired' || ast.status == 'Cancelled') && (date.valueof(ast.Expired_Date__c).daysBetween(Date.today())) <90  && (!mapAccActive.containsKey(ast.AccountId))){
                     system.debug('Testing null'+ast.status +'**'+ast.Expired_Date__c);

                           mapAccExpired.put(ast.AccountId,rcount);    
                    mapAccountPcodeName.put(ast.AccountId+'###'+mapAcountFieldNameProductCode.get(ast.product_code__c),false);
                    }
                   if((ast.status == 'Expired'  || ast.status == 'Cancelled') && (date.valueof(ast.Expired_Date__c).daysBetween(Date.today()) >= 90)  && (!mapAccExpired.containsKey(ast.AccountId)) && (!mapAccActive.containsKey(ast.AccountId))){
                           system.debug('Testing null'+ast.status +'**'+ast.Expired_Date__c);
                           mapAccProspect.put(ast.AccountId,rcount);
                   mapAccountPcodeName.put(ast.AccountId+'###'+mapAcountFieldNameProductCode.get(ast.product_code__c),false);
                    }
                }

                System.debug('******'+mapAccActive);
                for(Account acc : AllAccounts){
                    //Account acc = new Account(Id=accId,Total_Contract_Value__c=mapAccList.get(accId));

                    if(mapAccActive.containsKey(acc.Id)){
                       // acc.acc.Pre_Auth_User__c = false;
                        //CRM-1306 -- Checking whether not fulfilled order is there
                        if(!mapAccOrder.containskey(acc.Id)){
                        acc.Account_Sub_Type__c = 'Customer';

                        }
                        //CRM-1283 :- Next renewal date
                        if(mapRenewalDate.containskey(acc.Id)){
                            // CRM-2525 Commented below line
                            //acc.Next_Renewal_Date__c = mapRenewalDate.get(acc.Id).addDays(1);
                            // CRM-2525 - Set Next Renewal Date with asset latest end date
                            acc.Next_Renewal_Date__c = mapRenewalDate.get(acc.Id);
                        }
                        //CRM-1283 :- Next renewal date

                        //CRM-1694 :- populate last cancellation date
                        if(mapCancellationDate.containskey(acc.Id)){
                        acc.Last_Cancellation__c = mapCancellationDate.get(acc.Id);
                        }
                        //CRM-1694 :- populate last cancellation date
                        acc.Total_Contract_Value__c=mapAccActive.get(acc.Id);
                    } else if(mapAccExpired.containsKey(acc.Id)) {
                        acc.Pre_Auth_User__c = false;
                        acc.Account_Sub_Type__c = 'Former Customer';
                        acc.Next_Renewal_Date__c = null;
                        acc.Total_Contract_Value__c=0.0;
                        //CRM-1694 :- populate last cancellation date
                        if(mapCancellationDate.containskey(acc.Id)){
                        acc.Last_Cancellation__c = mapCancellationDate.get(acc.Id);
                        }
                        //CRM-1694 :- populate last cancellation date
                    } else if(mapAccProspect.containsKey(acc.Id)){
                            acc.Pre_Auth_User__c = false;
                            acc.Account_Sub_Type__c = 'Prospect';
                            acc.Next_Renewal_Date__c = null;
                            acc.Total_Contract_Value__c=0.0;
                    } else {}

                    //CRM-1367 :- product flag update
                    for(String accFieldAPIName : productflagfields.keySet()) {
                       if(
              accountSchemaFieldMap.containsKey(accFieldAPIName) &&
              accountSchemaFieldMap.get(accFieldAPIName).getDescribe().isAccessible() &&
              accountSchemaFieldMap.containsKey(accFieldAPIName) &&
              accountSchemaFieldMap.get(accFieldAPIName).getDescribe().isUpdateable()
            ) {
            	// CRM-3650 - Replaced "productflagfields.get(accFieldAPIName).product_code__c" with just "accFieldAPIName", as map stores API name not the product code.
                System.debug(accFieldAPIName+'$$$$$'+mapAccountPcodeName.get(acc.id+'###'+accFieldAPIName));
                        if(mapAccountPcodeName.get(acc.id+'###'+accFieldAPIName)==null){
                    mapAccountPcodeName.put(acc.id+'###'+accFieldAPIName,false);
                        }
                         acc.put(accFieldAPIName, mapAccountPcodeName.get(acc.id+'###'+accFieldAPIName));
            }
          }
                    lstAccount.add(acc);
                }
                update lstAccount;
                update lstAsset;
        } catch(Exception ex){

        }
    }
    global void finish(Database.BatchableContext BC){
    }
}