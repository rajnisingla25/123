public class AccountConsolidatedBilling{
    public static String combinedDate;
    public static string month;
    public static Id Account_Id;
    public static string ErrorMessage;
    public static Boolean ErrorStatus;
    public static string ConsolidatedMessage;
    public static Map<string,Decimal> subscriptionId_Price;
    public static Map<string,string> subscriptionId_date;
    public static set<string> subscriptionIds_success;
    public static Zuora.zApi zApi;
    public AccountConsolidatedBilling(){
        ConsolidatedMessage='';
    }
  //CRM-4351 Accept the payment method at the subscription level.    
    @future(callout = true)
    Public static void UpdateCollectionHoldinZuora(ID AccountId, Boolean Collectionhold, Boolean issubscriptioncentric){ 
        try{
            String Accntsids = '';
        zApi = zuoraApiAccess();
        String ErrorMessage = 'Update Success with ' +Collectionhold;
         Zuora__CustomerAccount__c billingAccount = [select id, Zuora__Zuora_Id__c from Zuora__CustomerAccount__c where Zuora__Account__c=:AccountId LIMIT 1];
         List<Zuora.ZApi.SaveResult> updateAccResults = new List<Zuora.ZApi.SaveResult>();
                    Zuora.ZObject updatedAccount = new Zuora.ZObject('Account');
                    updatedAccount.setValue('Id', billingAccount.Zuora__Zuora_Id__c);
                    updatedAccount.setValue('CollectionsHold__c', Collectionhold);
        			updatedAccount.setValue('Subscription_payment__c', issubscriptioncentric);
        
        		try {
          			  updateAccResults = (!Test.isRunningTest()) ? zApi.zUpdate(new List<Zuora.ZObject>{updatedAccount}) : new List<Zuora.ZApi.SaveResult>{Z_TestFactory.createSaveResult(true)};
                } catch (Exception ex) {
                	ErrorMessage = 'Exception occured While updating Zuora Collection hold flag ' + ex.getmessage();
                   System.debug('Exception occured While updating Zuora Collection hold flag');
                }
        Boolean updateAccountSuccess = false;
        String updateAccountError = '';
        if (updateAccResults.size() > 0) {
            Zuora.ZApi.SaveResult updateAccResult = updateAccResults[0];
            updateAccountSuccess = (updateAccResult.Success != null) ? updateAccResult.Success : false; 
           updateAccountError = (updateAccResult.Errors != null && updateAccResult.Errors.size() > 0 && String.isNotBlank((String)updateAccResult.Errors[0].getValue('Message'))) ? (String)updateAccResult.Errors[0].getValue('Message') : ''; 
        if(!updateAccountSuccess)
            ErrorMessage = updateAccountError;
        }                          
        system_logs__c logss = new system_logs__c();
        logss.Record_ID__c = AccountId;
        logss.Object_Type__c = 'Collection Hold';
        logss.Message__c =ErrorMessage;
        insert logss;  
        }catch(exception ex){
            
        }
    }
    public static void consolidateAccountInZuora(ID AccountId, string timestamp){
        combinedDate = timestamp;
        system_logs__c logs = new system_logs__c();
        logs.Record_ID__c = AccountId;
        logs.Object_Type__c = 'Account';
        logs.Message__c ='Consolidated Billing Started for the Salesforce Account with Account Id: '+AccountId;
        insert logs; 
        if(!system.isfuture()&& !system.isbatch()){
            futureconsolidateAccountInZuora(AccountId,timestamp);
        }    
    }
    
    @future(callout=true)
    public static void futureconsolidateAccountInZuora(ID AccountId,string timestamp){
        subscriptionId_Price = new Map<string,Decimal>();
        subscriptionId_date = new Map<string,string>();
        String accIdss = '';
        String SubIdss= '';
        Account_Id = AccountId;
        combinedDate =timestamp;
        ConsolidatedMessage='';
        string zuora_Billing_Account_ids;
        List<AmendNew_wrapper> Amend_newList = new List<AmendNew_wrapper>();
        Map<string,string> removeAmend = new Map<string,string>();
        List<Zuora.zObject> zuora_Subs = new List<Zuora.zObject>();
        List<Zuora.zObject> Zuora_RatePlans = new List<Zuora.zObject>();
        List<Zuora.zObject> Zuora_RatePlans_set = new List<Zuora.zObject>();
        Set<String> ZuoraIds = new Set<String>();
        List<Zuora.ZApi.SaveResult> updateSubscriptionResults = new List<Zuora.ZApi.SaveResult>();
        list<string> subscriptionIdsList = new list<string>();
        List<Zuora.zObject> trueZuoraSubs = new List<Zuora.zObject>();
        List<Zuora.zObject> updateZuoraSubs = new List<Zuora.zObject>();
        List<Zuora.zObject> updateZuoraSubs_set2 = new List<Zuora.zObject>();
        List<Zuora.zObject> zuora_Subs_RatePlanCharge = new List<Zuora.zObject>();
        List<Zuora.zObject> zuora_Subs_RatePlanCharge_set = new List<Zuora.zObject>();
        Set<String> zuoraidsupdate = new Set<String>(); 
        subscriptionIds_success = new set<string>();
        List<Zuora__CustomerAccount__c> billingAccounts = [select id, Zuora__Zuora_Id__c from Zuora__CustomerAccount__c where Zuora__Account__c=:AccountId];
        
        for(Zuora__CustomerAccount__c Zuora_id: billingAccounts ){
            if(Zuora_id.Zuora__Zuora_Id__c!=null && Zuora_id.Zuora__Zuora_Id__c!=''){
                zuora_Billing_Account_ids = Zuora_id.Zuora__Zuora_Id__c;
            }
        }
		
        if((zuora_Billing_Account_ids!=''&&zuora_Billing_Account_ids!=null) || test.isrunningtest()){
           integer ii = 0;
            try{
                //if(!test.isRunningTest())
                    zApi = zuoraApiAccess();
            }catch(Exception ex){
                updateSystemLogs(true,'Failed to Obtain Zuora login access. Message: '+ex.getMessage()+' Stacktrace: '+ex.getStackTraceString());
                return;
            }
        
        
            String query ='SELECT Id, IsInvoiceSeparate, TermEndDate, Name FROM Subscription WHERE Status = \'Active\' AND AccountId = \''+zuora_Billing_Account_ids+'\'';         
            system.debug('query_Subscription_Zuora'+query);
            try{
                //Querying Zuora for the Subscription details based on the Account Id
                if(!test.IsRunningTest()){
                    zuora_Subs = zApi.zQuery(query);
                    system.debug('@@@###QuerySubscription');
                }   
                else {
                    
                    Zuora.zObject zSub = new Zuora.zObject('Subscription');
                    zSub.setValue('Id', '2c92a0ff56fe33f');
                    zSub.setValue('Name', combinedDate);
                    zSub.setValue('AccountId', zuora_Billing_Account_ids);
                    zSub.setValue('InitialTerm', '12 Months');
                    zSub.setValue('RenewalTerm', '12 Months');
                    zSub.setValue('ContractEffectiveDate', System.Today());
                    zSub.setValue('TermStartDate', System.Today());
                    zSub.setValue('ServiceActivationDate', System.Today());
                    zSub.setValue('ContractAcceptanceDate', System.Today());
                    zSub.setValue('IsInvoiceSeparate', true);
                    zuora_Subs.add(zSub);
                    zSub = new Zuora.zObject('Subscription');
                    zSub.setValue('Id', '2c92a0f5b99');
                    zSub.setValue('Name', combinedDate);
                    zSub.setValue('AccountId', zuora_Billing_Account_ids);
                    zSub.setValue('InitialTerm', '1 Months');
                    zSub.setValue('RenewalTerm', '1 Months');
                    zSub.setValue('ContractEffectiveDate', System.Today());
                    zSub.setValue('TermStartDate', System.Today());
                    zSub.setValue('ServiceActivationDate', System.Today());
                    zSub.setValue('ContractAcceptanceDate', System.Today());
                    zSub.setValue('IsInvoiceSeparate', true);
                    zuora_Subs.add(zSub);
                    
                }
            }catch(Exception ex){
                
                updateSystemLogs(true,'Query failed to run');
                return ;
            }
            system.debug('Zuora_Subscription_Query_Results'+zuora_Subs);
            //Iterating tthroug Zuora Subscrions and filtering the Subscription with  'IsInvoiceSeparate=true'   
            if(zuora_Subs.size()==0){
                ErrorMessage = 'No existing subscriptions associated in Zuora with the Salesforce AccountId: '+AccountId;
                ErrorStatus = true;
                updateSystemLogs(ErrorStatus,ErrorMessage);
                return ;
            }
            if(zuora_Subs.size()>400){
                ErrorMessage = 'Not able to process this Account for Consolidated billing as this Account has morethan 400 Active Subscriptions';
                ErrorStatus = true;
                updateSystemLogs(ErrorStatus,ErrorMessage);
                return ;
            }
            Integer subscriptionsCount=0;
            Integer itemcount=0;
            for(Zuora.zObject zuraSub : zuora_Subs){
                Date termEnddate;
                system.debug('@@@TermDate'+String.valueof(zuraSub.getValue('TermEndDate'))+string.valueOf(zuraSub.getValue('Id')));
                if(String.valueof(zuraSub.getValue('TermEndDate'))!=null && String.valueof(zuraSub.getValue('TermEndDate')).contains(' ')){
                    termEnddate = date.valueof(String.valueof(zuraSub.getValue('TermEndDate')).substringbefore(' '));
                system.debug('@@@TermDatefinal'+termEnddate+' '+string.valueOf(zuraSub.getValue('Id')));
                }
                if(String.valueof(zuraSub.getValue('TermEndDate'))==null || (termEnddate!=null && termEnddate>System.today())){
                    subscriptionIdsList.add(string.valueOf(zuraSub.getValue('Id')));
                    system.debug('Term End Date check done' + string.valueOf(zuraSub.getValue('Id')));
                
                    if(string.valueOf(zuraSub.getValue('IsInvoiceSeparate')).equalsignorecase('true')){
                        trueZuoraSubs.add(zuraSub);
                    }
                }   
                //system.debug('Subscriptions with IsInvoiceSeparate value equals True'+trueZuoraSubs.size());
            }

            
            
            if(subscriptionIdsList != null && subscriptionIdsList.size() >0){
                List<string> RatePlanIds;
                List<string> subscriptionIds;
                Map<string,string> RatePlan_Subscription_map = new Map<string,string>();
                List<string> RateIds = new List<string>();
                Map<string,List<string>> RatePlan_ProductRateCharge_map = new Map<string,List<string>>();
                List<string> Product_Rate_PlanChargeIds = new List<string>();
                Map<string,List<string>> CPQ_Subscription = new Map<string,List<string>>();
                Map<string,string> CPQ_new_old = new Map<string,string>();
                //Preparing Query String to fetch the RatePlan info based on the Subscription Ids
                String query_rateplan;
                
                Integer numberOfsets = calculatenumberofSets(subscriptionIdsList.size());
                system.debug('numberOfsets' +numberOfsets);
                integer counter=0;
                while(counter<numberOfsets){
                    system.debug('counter@@' +counter);
                    query_rateplan ='SELECT Id, SubscriptionId, ProductRatePlanId FROM RatePlan WHERE';
                    integer i=counter*200;
                    integer j=i;
                    integer size = (numberOfsets-counter)>1?200:(subscriptionIdsList.size()-i);
                    system.debug('subscriptionIdsList1 ' +subscriptionIdsList.size());
                    system.debug('size1 ' +size);
                    i=0;
                    for(; i < size; i++){
                        
                        
                        
                        if( (i+1) == size)
                            query_rateplan +=' SubscriptionId = \''+subscriptionIdsList[j]+'\'';
                        else
                           query_rateplan +=' SubscriptionId = \''+subscriptionIdsList[j]+'\' or ';
                       
                       j++;
                       system.debug('jsize' +j);
                       
                    }
                
                    try{
                        //Query to fetch the RatePlan info based on the Subscription Ids from Zuora
                        if(!test.isRunningTest()){
                            system.debug('query_rateplan1' +query_rateplan);
                            Zuora_RatePlans_set = zApi.zQuery(query_rateplan);
                            system.debug('@@@###QueryRatePlans');
                            system.debug('Zuora_RatePlans_set' +Zuora_RatePlans_set);
                            Zuora_RatePlans.addall(Zuora_RatePlans_set);
                            system.debug('Zuora_RatePlans ' +Zuora_RatePlans.size());
                         }   
                        else{
                            Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
                            ratePlan.setValue('Id', '2c92c0f956f9e18');
                            ratePlan.setValue('SubscriptionId', subscriptionIdsList[0]);
                            ratePlan.setValue('ProductRatePlanId', '2c92c0f956f9e18');
                            Zuora_RatePlans.add(ratePlan);
                        }
                    }catch(Exception ex){
                        ErrorMessage ='Exception Occured while fetching RatePlans details from Zuora. Exception Message: '+ex.getMessage()+' Stacktrace: '+ex.getStackTraceString();
                        ErrorMessage+= '\n'+'Input Query: '+query_rateplan;
                        ErrorStatus = true;
                        updateSystemLogs(ErrorStatus,ErrorMessage);
                        return ;
                    }
                    counter++;
                }
            
                system.debug('Zuora_RatePlans2' +Zuora_RatePlans);
                system.debug('Zuora_RatePlans2' +Zuora_RatePlans.size());
            
                if(Zuora_RatePlans.size()==0){
                    ErrorMessage ='No Rate Plans found in Zuora"';
                    ErrorMessage+= '\n'+'Input Query: '+query_rateplan;
                    ErrorStatus = true;
                    updateSystemLogs(ErrorStatus,ErrorMessage);
                    return ;
                }
                for(Zuora.zObject zuraSub : Zuora_RatePlans){
                    RateIds.add(string.valueOf(zuraSub.getValue('Id')));
                    RatePlan_Subscription_map.put(string.valueOf(zuraSub.getValue('Id')),string.valueOf(zuraSub.getValue('SubscriptionId')));
                }
                
                // String query = 'SELECT Id, Name, ProductRatePlanChargeId, ChargeType, RatePlanId FROM RatePlanCharge WHERE RatePlanId  =\'' + RateIds+ '\' AND BillCycleType!= "Default from customer"';
                String query_rateplanCharge;

                //Preparing Query String to fetch the RatePlanCharge info based on the RatePlanIds

                numberOfsets = calculatenumberofSets(RateIds.size());
                counter=0;
                while(counter<numberOfsets){
                    query_rateplanCharge = 'Select Id, BillCycleType,ProcessedThroughDate, ChargeType,BillingPeriod,Price, IsLastSegment, ProductRatePlanChargeId, RatePlanId From RatePlanCharge where ';
                    integer i=counter*200;
                    integer j=i;
                    integer size = (numberOfsets-counter)>1?200:(RateIds.size()-i);
                     system.debug('RateIds1 '+RateIds);
                    system.debug('size2 ' +size);
                    i=0;
                    for(; i <size; i++){
                        if( (i+1) == size){
                            query_rateplanCharge += 'RatePlanId =\'' + RateIds[j]+ '\'';
                        }
                        else{
                            query_rateplanCharge += 'RatePlanId  =\'' + RateIds[j]+ '\' or ';
                            }
                    j++;
                    } //try
                    system.debug('QueryStringToFetchRateplansFromZuora'+query_rateplanCharge);
                    try{
                        //Query to fetch the Zuora RatePlanCharge details
                        if(!test.isRunningTest()){
                            system.debug('query_rateplanCharge2'+query_rateplanCharge);
                            zuora_Subs_RatePlanCharge_set = zApi.zQuery(query_rateplanCharge);
                            system.debug('@@@###QueryRatePlanCharge');
                            zuora_Subs_RatePlanCharge.addall(zuora_Subs_RatePlanCharge_set);
                            
                        }
                        
                    }catch(Exception ex){
                        ErrorMessage ='Exception Occured while fetching RatePlanCharge details from Zuora. Exception Message: '+ex.getMessage()+' Stacktrace: '+ex.getStackTraceString();
                        ErrorMessage+='\n';
                        ErrorMessage+='Input Query: '+query_rateplanCharge;
                        ErrorStatus = true;
                        updateSystemLogs(ErrorStatus,ErrorMessage);
                        return ;
                    }
                    counter++;
                }
                if(Test.isrunningTest()){
                    Zuora.zObject rPlanCharge = new Zuora.zObject('RatePlanCharge');
                    rPlanCharge.setValue('Id', '2c92c0f856f9d5b');
                    rPlanCharge.setValue('BillCycleType','Chargetriggerday' );
                    rPlanCharge.setValue('ChargeType','Recurring' );
                    rPlanCharge.setValue('BillingPeriod','Month' );
                    rPlanCharge.setValue('IsLastSegment','true' );
                    //rPlanCharge.setValue('ChargeType','Usage' );
                    rPlanCharge.setValue('ProductRatePlanChargeId', '2c92abc856f9d5b');
                    rPlanCharge.setValue('Price', 20);
                    rPlanCharge.setValue('RatePlanId', RateIds[0]);
                    
                    zuora_Subs_RatePlanCharge.add(rPlanCharge);
                    
                    //insert product rate plan charge
                    zqu__ProductRatePlanCharge__c objPrpc = new zqu__ProductRatePlanCharge__c();
                    objPrpc.CPQID__c = 'CTest12';
                    objPrpc.zqu__ZuoraId__c = '2c92abc856f9d5b';
                    objPrpc.zqu__Deleted__c = false;
                    database.upsert(objPrpc, false);
                    
                    //insert product rate plan charge
                    zqu__ProductRatePlanCharge__c objPrpc1 = new zqu__ProductRatePlanCharge__c();
                    objPrpc1.CPQID__c = 'est12';
                    objPrpc1.zqu__ZuoraId__c = '2c77def123f9d5b';
                    objPrpc1.zqu__Deleted__c = false;
                     database.upsert(objPrpc1, false);
                    }
                system.debug('zuora_Subs_RatePlanCharge'+zuora_Subs_RatePlanCharge.size());
                system.debug('zuora_Subs_RatePlanCharge1'+zuora_Subs_RatePlanCharge);
                if(zuora_Subs_RatePlanCharge.size()==0){
                    
                    ErrorMessage ='No Rate Plan Charge Records found in Zuora';
                    ErrorMessage+= '\n'+'Input Query: '+query_rateplan;
                    ErrorStatus = true;
                    updateSystemLogs(ErrorStatus,ErrorMessage);
                    return ;
                }
                for(Zuora.zObject recRatePlan : zuora_Subs_RatePlanCharge){
                    if(string.valueOf(recRatePlan.getvalue('BillCycleType'))!=null && string.valueOf(recRatePlan.getvalue('BillingPeriod'))!=null){
                        
                        //for(Zuora.zObject recRatePlan : recRatePlans){
                            system.debug('recRatePlan2'+recRatePlan);
                            if(!string.valueOf(recRatePlan.getValue('BillCycleType')).equalsignorecase('Defaultfromcustomer') && string.valueOf(recRatePlan.getValue('ChargeType')).equalsignorecase('Recurring') && string.valueOf(recRatePlan.getValue('BillingPeriod')).equalsignorecase('Month') && string.valueOf(recRatePlan.getValue('IsLastSegment')).equalsignorecase('true')){
                                Product_Rate_PlanChargeIds.add(string.valueOf(recRatePlan.getValue('ProductRatePlanChargeId')));
                                if(RatePlan_ProductRateCharge_map.containskey(string.valueOf(recRatePlan.getValue('ProductRatePlanChargeId')))){
                                    RatePlanIds = RatePlan_ProductRateCharge_map.get(string.valueOf(recRatePlan.getValue('ProductRatePlanChargeId')));
                                }else{
                                    RatePlanIds = new List<string>();
                                    }
                                string ratePlanId_RPC = string.valueOf(recRatePlan.getValue('RatePlanId'));
                                string price = string.valueof(recRatePlan.getValue('Price'));
                                string processThroughDate = string.valueof(recRatePlan.getValue('ProcessedThroughDate'));
                                if(processThroughDate==null || processThroughDate=='')
                                    processThroughDate =combinedDate;
                                    System.debug('Process@@'+processThroughDate);
                                
                                decimal price_decimal;
                                if(price==null || price=='')
                                    price_decimal=0;
                                else
                                    price_decimal = Decimal.valueof(price).setScale(2);
                                RatePlanIds.add(ratePlanId_RPC);
                                if(RatePlan_Subscription_map.containskey(ratePlanId_RPC)){
                                    subscriptionId_Price.put(RatePlan_Subscription_map.get(ratePlanId_RPC),price_decimal);
                                   //CRM-1628 passing date fromet only after wsdl changes
                                    if(processThroughDate!=null){                                                                           
                                        processThroughDate= processThroughDate.left(10);                                       
                                    subscriptionId_date.put(RatePlan_Subscription_map.get(ratePlanId_RPC),processThroughDate);
                                    }
                                }
                                
                                //if(string.valueOf(recRatePlan.getValue('ProductRatePlanChargeId')!=null)
                                    system.debug(recRatePlan.getValue('ProductRatePlanChargeId')+ 'recrate');
                                RatePlan_ProductRateCharge_map.put(string.valueOf(recRatePlan.getValue('ProductRatePlanChargeId')),RatePlanIds);
                                
                            }
                        }
                    //}
                }
                set<string> remove_rateplanIds;
                system.debug('Product_Rate_PlanChargeIds'+Product_Rate_PlanChargeIds);
                Map<string,set<string>> remove_subscription_RatePlanids = new Map<string,set<string>>();
                List<zqu__ProductRatePlanCharge__c> Product_rate_PlanCharge_list = [SELECT Id, CPQID__c,zqu__ZuoraId__c FROM zqu__ProductRatePlanCharge__c WHERE zqu__Deleted__c = false and zqu__ZuoraId__c IN:Product_Rate_PlanChargeIds];
                system.debug('Product_rate_PlanCharge_list'+Product_rate_PlanCharge_list );
                if(Product_rate_PlanCharge_list.size()==0){
                    ErrorMessage = 'No Product Rate Plan Charge records found in Salesforce';
                    ErrorStatus=true;
                    updateSystemLogs(ErrorStatus,ErrorMessage);
                    return ;
                }
                
                for(zqu__ProductRatePlanCharge__c recPlanCharge :Product_rate_PlanCharge_list){
                    if(recPlanCharge.CPQID__c.startswithIgnorecase('CT')){
                        if(RatePlan_ProductRateCharge_map.containskey(recPlanCharge.zqu__ZuoraId__c)){
                            for(string rateplanId : RatePlan_ProductRateCharge_map.get(recPlanCharge.zqu__ZuoraId__c)){
                                string SubscriptionId='';
                                if(RatePlan_Subscription_map.containskey(rateplanId)){
                                    SubscriptionId = RatePlan_Subscription_map.get(rateplanId);
                                    if(remove_subscription_RatePlanids.containskey(SubscriptionId)){
                                        remove_rateplanIds = remove_subscription_RatePlanids.get(SubscriptionId);
                                    }else{
                                        remove_rateplanIds = new set<string>();
                                    }
                                    remove_rateplanIds.add(rateplanId);
                                    remove_subscription_RatePlanids.put(SubscriptionId,remove_rateplanIds);
                                }
                            }
                        }
                        
                        if(CPQ_Subscription.containskey(recPlanCharge.CPQID__c)){
                            subscriptionIds = CPQ_Subscription.get(recPlanCharge.CPQID__c);
                            for(string rateplanId : RatePlan_ProductRateCharge_map.get(recPlanCharge.zqu__ZuoraId__c)){
                                subscriptionIds.add(RatePlan_Subscription_map.get(rateplanId));
                            }
                        } else{
                            subscriptionIds = new List<string>();
                            for(string rateplanId : RatePlan_ProductRateCharge_map.get(recPlanCharge.zqu__ZuoraId__c)){
                                subscriptionIds.add(RatePlan_Subscription_map.get(rateplanId));
                            }
                        }
                        CPQ_Subscription.put(recPlanCharge.CPQID__c,subscriptionIds);
                        CPQ_new_old.put(recPlanCharge.CPQID__c.removeStartIgnoreCase('CT'),recPlanCharge.CPQID__c);
                    }
                }//for end
                if(CPQ_new_old.keyset().isempty()){
                    ErrorMessage = 'No Product Rate Plan Charge records exists with CPQ ID starting with CT';
                    ErrorStatus=true;
                    updateSystemLogs(ErrorStatus,ErrorMessage);
                    return ;
                }
                
                Map<string,List<AmendNew_wrapper>> add_Subscription_map = new Map<string,List<AmendNew_wrapper>>();
                List<AmendNew_wrapper> Amend_wrapperList;
                system.debug('Product_rate_PlanCharge_list'+Product_rate_PlanCharge_list);
                List<zqu__ProductRatePlanCharge__c> Product_rate_PlanCharge_new_list = [SELECT Id, zqu__ProductRatePlan__r.zqu__ZuoraId__c, zqu__ZuoraId__c,CPQID__c FROM zqu__ProductRatePlanCharge__c WHERE zqu__Deleted__c = false and CPQID__c IN: CPQ_new_old.keyset()];
                system.debug('Product_rate_PlanCharge_new_list '+Product_rate_PlanCharge_new_list);
                if(Product_rate_PlanCharge_new_list.size()==0 || Product_rate_PlanCharge_new_list.isempty()){
                    ErrorMessage = 'No Product Rate Plan Charge records found for the new CPQ Ids in Salesforce';
                    ErrorMessage+='\n'+ 'New CPQ IDs List: '+CPQ_new_old.keyset();
                    ErrorStatus=true;
                    updateSystemLogs(ErrorStatus,ErrorMessage);
                    return ;
                }
                
                for(zqu__ProductRatePlanCharge__c rec : Product_rate_PlanCharge_new_list){
                    if(CPQ_new_old.containskey(rec.CPQID__c)){
                        if(CPQ_Subscription.containskey(CPQ_new_old.get(rec.CPQID__c))){
                            for(String subscriptionId : CPQ_Subscription.get(CPQ_new_old.get(rec.CPQID__c))){
                                AmendNew_wrapper amendNew = new AmendNew_wrapper();
                                amendNew.SubscriptionId = subscriptionId;
                                amendNew.ProductRatePlanId = rec.zqu__ProductRatePlan__r.zqu__ZuoraId__c;
                                amendNew.ProductRatePlanChargeId =rec.zqu__ZuoraId__c;
                                if(add_Subscription_map.containskey(subscriptionId)){
                                    Amend_wrapperList = add_Subscription_map.get(subscriptionId);
                                }else{
                                    Amend_wrapperList = new List<AmendNew_wrapper>();
                                }
                                Amend_wrapperList.add(amendNew);
                                add_Subscription_map.put(SubscriptionId,Amend_wrapperList);
                                //Amend_newList.add(amendNew);
                            }
                        }
                    }
                }
            
                if(remove_subscription_RatePlanids.size()<=80){
               /* if(trueZuoraSubs != null && trueZuoraSubs.size() > 0){
                //Updating Subscriptions with IsInvoiceSeparate=False
                    integer Subs_Counter=0;
                    for(Zuora.zObject subs: trueZuoraSubs){           
                        if(remove_subscription_RatePlanids.containskey(string.valueof(subs.getvalue('Id')))){
                            subs.setValue('IsInvoiceSeparate', 'FALSE');
                            if(Subs_Counter<50) 
                                updateZuoraSubs.add(subs);
                            else
                                updateZuoraSubs_set2.add(subs);
                        Subs_Counter++;
                        }
                    }
                    try{
                        //Zuora update call to update IsInvoiceSeparate=False on the Subscriptions
                        if(!Test.isrunningTest()){
                            if(updateZuoraSubs.size()>0)
                            updateSubscriptionResults = zApi.zUpdate(updateZuoraSubs);
                        }else{
                            updateSubscriptionResults = new List<Zuora.ZApi.SaveResult>();
                            Zuora.ZApi.SaveResult updateSubResult = new Zuora.ZApi.SaveResult();
                            updateSubResult.Success = true;
                            updateSubResult.Id = 'testzuoraid0000000001';
                            updateSubResult.Errors = null;
                            updateSubscriptionResults.add(updateSubResult);
                        }
                        if(updateZuoraSubs_set2.size()>0)
                            updateSubscriptionResults = zApi.zUpdate(updateZuoraSubs_set2);
                        //TODO: Iterate through the Update results 
                    }catch(Exception ex){
                        ErrorMessage ='Exception Occured while updating IsInvoiceSeparate to False on Subscription(s). Exception Message: '+ex.getMessage()+' Stacktrace: '+ex.getStackTraceString();
                        ErrorStatus = true;
                        updateSystemLogs(ErrorStatus,ErrorMessage);
                        return ;
                    }
                    system.debug('updateSubscriptionResults'+updateSubscriptionResults);
                }*/
            
            
            
                for(string subscriptionId: remove_subscription_RatePlanids.keyset()){
                    List<Zuora.zObject> amendmentstoProcess = new List<Zuora.zObject>();
                    for(String rateplanId : remove_subscription_RatePlanids.get(subscriptionId)){
                        Zuora.zObject amendment = createAmendment('Removing a product' + System.currentTimeMillis(), subscriptionId, 'RemoveProduct'); 
                        amendment.setValue('RatePlanData', createSubscriptionRatePlanData(rateplanId));
                        amendmentstoProcess.add(amendment);
                    }
                    if(add_Subscription_map.containskey(subscriptionId)){
                        for(AmendNew_wrapper new_amend:add_Subscription_map.get(subscriptionId)){
                            Zuora.zObject amendment = createAmendment2('Add a Product 001' + System.currentTimeMillis(), subscriptionId, 'NewProduct');
                            amendment.setValue('RatePlanData', createRatePlanData(new_amend.productRatePlanId, new_amend.productRatePlanChargeId,subscriptionId));
                            amendmentstoProcess.add(amendment);
                        }
                    }
                    if(!amendmentstoProcess.isempty()&&amendmentstoProcess.size()>0){
                        ConsolidatedMessage+= '\n'+'Subscripton Id: '+subscriptionId+'  '+amendbatches(amendmentstoProcess,subscriptionId);
                    }
                }
                
                integer Subs_Counter=0;
                for(string sub_id: subscriptionIds_success){ 
                System.debug('subscriptionIds_success '+subscriptionIds_success);               
                    Zuora.ZObject subs = new Zuora.ZObject('Subscription');
                    subs.setValue('Id', sub_id);
                    subs.setValue('IsInvoiceSeparate', 'FALSE');
                        if(Subs_Counter<50){ 
                            updateZuoraSubs.add(subs);
                            System.debug('updateZuoraSubs '+updateZuoraSubs);
                        }
                        else
                            updateZuoraSubs_set2.add(subs);
                    Subs_Counter++;
                }
                System.debug('updateZuoraSubs '+updateZuoraSubs.size());
                System.debug('updateZuoraSubs_set2 '+updateZuoraSubs_set2.size());
                    
                try{
                    //Zuora update call to update IsInvoiceSeparate=False on the Subscriptions
                    if(!Test.isrunningTest()){
                        if(updateZuoraSubs.size()>0){
                            system.debug('@@@###invoiceupdate');
                        updateSubscriptionResults = zApi.zUpdate(updateZuoraSubs);
                        System.debug('updateSubscriptionResults '+updateSubscriptionResults);
                        
                        }
                    }else{
                        updateSubscriptionResults = new List<Zuora.ZApi.SaveResult>();
                        Zuora.ZApi.SaveResult updateSubResult = new Zuora.ZApi.SaveResult();
                        updateSubResult.Success = true;
                        updateSubResult.Id = 'testzuoraid0000000001';
                        updateSubResult.Errors = null;
                        updateSubscriptionResults.add(updateSubResult);
                    }
                    
                    
                    if(updateZuoraSubs_set2.size()>0){
                        updateSubscriptionResults = zApi.zUpdate(updateZuoraSubs_set2);
                    system.debug('@@@###Invoiceupdate2');
                    }
                    //TODO: Iterate through the Update results 
                    }catch(Exception ex){
                    ErrorMessage ='Exception Occured while updating IsInvoiceSeparate to False on Subscription(s). Exception Message: '+ex.getMessage()+' Stacktrace: '+ex.getStackTraceString();
                    ErrorStatus = true;
                    updateSystemLogs(ErrorStatus,ErrorMessage);
                    return ;
                }
                    
                 updateSystemLogs(false,ConsolidatedMessage);
                }else{
                    ErrorMessage ='Unable to Process Consolidated billing because the Account with Salesforce Account Id '+AccountId+'has morethan 80 Subscriptions to process.';
                    ErrorStatus = true;
                    updateSystemLogs(ErrorStatus,ErrorMessage);
                } 
             //updateZuoraAccount(zuora_Billing_Account_ids); 
            
            }else{
                ErrorMessage ='No Active Subscriptions found in Zuora for the Account with Salesforce Account Id:'+AccountId;
                ErrorStatus = true;
                updateSystemLogs(ErrorStatus,ErrorMessage);
            }
        }else{
            ErrorMessage ='Zuora Account not Available for the Salesforce Account Id:'+AccountId;
            ErrorStatus = true;
            updateSystemLogs(ErrorStatus,ErrorMessage);
        }
    }

    public class AmendNew_wrapper{
        public string SubscriptionId;
        public string ProductRatePlanId;
        public string ProductRatePlanChargeId;
    }    
    
    public static integer calculatenumberofSets(integer size){
        //integer multiple=0;
       // multiple = size/200;
        //decimal reminder =0.0;
        integer sets = 0;
        
        // reminder = math.mod(size,200);
        // system.debug('reminder'+reminder);
        // integer sets = multiple+ reminder>0?1:0;
        // system.debug('sets'+sets);
        
        if(size <200)
            sets = 1;
        else if (size <400)
            sets = 2;
        else if (size <600)
            sets = 3;
        else if (size <800)
            sets = 4;
        else if (size <1000)
            sets = 5;
        return sets;
    }
    public static Zuora.ZApi zuoraApiAccess(){
        system.debug('@@@###Login');
        final String FUNC_STR = 'zuoraApiAccess: ';
        zApi = new Zuora.ZApi();
        try {
            Zuora.ZApi.LoginResult loginResult = (!Test.isRunningTest()) ? zApi.zLogin() : new Zuora.ZApi.LoginResult();  
        } catch (Exception ex) {
            System.debug(FUNC_STR+' Login to Zuora failed. Message: '+ex.getMessage()+' Stacktrace: '+ex.getStackTraceString());
            throw ex;
        }
        return zApi;
    }
      
      
    public static string amendbatches(List<Zuora.zObject> amendmentList, string SubscriptionId){
        List<Zuora.zObject> amendmentBatch = new List<Zuora.zObject>();
        Zuora.zApi.AmendResult result = new Zuora.zApi.AmendResult();
        system.debug('listReceivedfrom Method'+amendmentList);
        if(amendmentList.size()>0){
            integer size = amendmentList.size()>10? 10 : amendmentList.size();
            for(integer i=0;i<size;i++){
                amendmentBatch.add(amendmentList[0]);
                amendmentList.remove(0);
            }
            system.debug('amendmentBatch'+amendmentBatch);
            try{
            result = amendApiCall(amendmentBatch);
            system.debug('@@@@!!###amendBatches');
            }catch(Exception ex){
                system.debug('Amendment Result Entered'+result);
                ErrorMessage ='Exception Occured while performing Amendment(New/Remove) Exception Message: '+ex.getMessage()+' Stacktrace: '+ex.getStackTraceString()+' Subscription Id: '+SubscriptionId;
                ErrorStatus = true;
                return ErrorMessage;
            }
            string new_subscriptionId;
            if(result.success){
                new_subscriptionId = result.SubscriptionId;
                if(!amendmentList.isempty() && amendmentList.size()>0){
                    List<Zuora.zObject> remainingList = new List<Zuora.zObject>();
                    for(Zuora.zObject amendment: amendmentList){
                        amendment.setValue('SubscriptionId', new_subscriptionId);              
                        remainingList.add(amendment);
                    } 
                    amendbatches(remainingList,new_subscriptionId);
                }   
                ErrorMessage = 'Consolidated Billing Processed Successfully for the Subscription Id:'+new_subscriptionId;
                ErrorStatus = false;
                subscriptionIds_success.add(new_subscriptionId);
                return ErrorMessage;
            }else{
                ErrorMessage = 'Consolidated Billing failed for the Subscription Id:'+SubscriptionId+' Error Details';
                List<Zuora.Zobject> Errorresponse= result.Errors;
                for(Zuora.zobject rec:  Errorresponse){
                    ErrorMessage+='\n';
                    ErrorMessage+=rec.getvalue('Message');
                }   
                ErrorStatus = true;
                return ErrorMessage;
            }
        }
    return ErrorMessage;
    } 
      
    public static Zuora.zObject createAmendment(String name, String subscriptionId, String amendType) {
        system.debug('---createAmendment entered--'+name+'====>'+subscriptionId+'------>'+amendType);
        string processthrough_date= subscriptionId_date.containskey(subscriptionId)? subscriptionId_date.get(subscriptionId):combinedDate;
        
        Zuora.zObject amendment = new Zuora.zObject('Amendment');
        //combinedDate = '2016-09-04T20:54:20'; 
        amendment.setValue('ContractEffectiveDate', processthrough_date);
        amendment.setValue('CustomerAcceptanceDate', processthrough_date);
        amendment.setValue('Description', 'Remove product amendment');
        amendment.setValue('EffectiveDate', processthrough_date);
        amendment.setValue('Name', name);
        amendment.setValue('ServiceActivationDate', processthrough_date);//'2011-01-01T20:44:54.718+05:30');
        amendment.setValue('Status', 'Completed');
        amendment.setValue('SubscriptionId', subscriptionId);
        amendment.setValue('Type', amendType);
    return amendment;
    }
    public static Zuora.zObject createSubscriptionRatePlanData(String amendmentSubscriptionRatePlanId) {
        system.debug('---createSubscriptionRatePlanData entered--'+amendmentSubscriptionRatePlanId);
        Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
        ratePlan.setValue('AmendmentSubscriptionRatePlanId', amendmentSubscriptionRatePlanId);

        Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
        ratePlanData.setValue('RatePlan', ratePlan);

        return ratePlanData;
    }
    public static void updateSystemLogs(Boolean status, String message){
        system.debug('Entered into System Logs');
        system_logs__c logs = new system_logs__c();
        logs.Record_ID__c = Account_Id;
        logs.Object_Type__c = 'Account';
        logs.Message__c =message;
        insert logs;
        
        list<Account> recAccount =[select id,Consolidated_Billing_Comment__c from Account where id =: Account_Id];
        if(recAccount != null && recAccount.size() > 0){
            recAccount[0].Consolidated_Billing_Comment__c = message;
            system.debug('Updatemessage'+message);
            update recAccount[0];
        }
    }
    /*public static void updateZuoraAccount(string zuora_accountId){
        Zuora.zApi zApi = zuoraApiAccess();
        Zuora.ZObject updatedAccount = new Zuora.ZObject('Account');
        updatedAccount.setValue('Id', zuora_accountId);
        updatedAccount.setValue('Batch', 'Batch1');
        List<Zuora.ZApi.SaveResult> updateAccResults = new list<Zuora.ZApi.SaveResult>();
        try{
            if(!test.isRunningTest())
                updateAccResults = zApi.zUpdate(new List<Zuora.ZObject>{updatedAccount});
            else{
                Zuora.ZApi.SaveResult res = new Zuora.ZApi.SaveResult();
                res.success = true;
                updateAccResults.add(res);
            }
        }catch(Exception ex){
            ErrorMessage = 'Error in Updating the "Batch" field on Zuora Account with Account Id: '+zuora_accountId+'Exception Message: '+ex.getMessage()+' Stacktrace: '+ex.getStackTraceString();
            ErrorStatus=true;
            ErrorMessage+= '\n';
            ErrorMessage+=ConsolidatedMessage;
            updateSystemLogs(ErrorStatus,ErrorMessage);
        }
        Zuora.ZApi.SaveResult result = (updateAccResults != null && updateAccResults.size() >0) ? updateAccResults[0] : new Zuora.ZApi.SaveResult();
        if(result.success){
            ErrorStatus=false;
            ErrorMessage = 'Zuora Account Batch field updated with Batch1';
            ErrorMessage+= '\n';
            ErrorMessage+=ConsolidatedMessage;
            updateSystemLogs(ErrorStatus,ErrorMessage);
        }else{
            ErrorStatus =true;
            ErrorMessage = 'Error in updating Zuora Account Batch field with Batch1';
            Errormessage+= '\n';
            Errormessage+=(result.Errors != null && result.Errors.size() > 0 && String.isNotBlank((String)result.Errors[0].getValue('Message'))) ? (String)result.Errors[0].getValue('Message') : '';
            ErrorMessage+='\n'+ConsolidatedMessage;
            updateSystemLogs(ErrorStatus,ErrorMessage);
        }
    }*/
    
    public static Zuora.zApi.AmendResult amendApiCall(List<Zuora.zObject> amendment) {
        system.debug('---amendApiCall entered--'+amendment);
        //Zuora.zApi zApi = zuoraApiAccess();
        system.debug('zApi Result'+zApi );

        Zuora.zApi.AmendRequest amendRequest = new Zuora.zApi.AmendRequest();
        Zuora.zObject[] amendments = amendment;
        amendRequest.amendments = amendments;

        Zuora.zApi.AmendOptions amendmentOption = new Zuora.zApi.AmendOptions();
        amendmentOption.GenerateInvoice = false;
        amendmentOption.ProcessPayments = false;

        amendRequest.amendOptions = amendmentOption;
        system.debug('---amendRequest before zament--'+amendRequest);
        
        Zuora.zApi.AmendResult result = new Zuora.zApi.AmendResult();
        if(!test.isRunningTest()){
            system.debug('@@@###zamend');
            result = zApi.zamend(new List < Zuora.zApi.AmendRequest > {
              amendRequest
            });
        }else{
            result.success = true;
        }

        // Print amend call 's result
         System.debug('result------>'+result);
        //System.assertEquals(null, result);

        return result;
      }
      
      
        public static Zuora.zObject createAmendment2(String name, String subscriptionId, String amendType) {
        Zuora.zObject amendment = new Zuora.zObject('Amendment');
        system.debug('---createAmendment entered--'+name+'====>'+subscriptionId+'------>'+amendType);
        string processthrough_date= subscriptionId_date.containskey(subscriptionId)? subscriptionId_date.get(subscriptionId):combinedDate;
        //String combinedDate = system.today().year()+'-08-'+system.today().day()+'T00:00:00';
        amendment.setValue('ContractEffectiveDate', processthrough_date);
        amendment.setValue('CustomerAcceptanceDate', processthrough_date);
        amendment.setValue('Description', 'new product amendment');
        amendment.setValue('EffectiveDate', processthrough_date);
        amendment.setValue('Name', name);
        amendment.setValue('ServiceActivationDate', processthrough_date);
        amendment.setValue('Status', 'Completed');
        amendment.setValue('SubscriptionId', subscriptionId);
        amendment.setValue('Type', amendType);

        return amendment;
      } 
        public static Zuora.zObject createRatePlanData(String productRatePlanId, String productRatePlanChargeId,string subscriptionId) {
        system.debug('---createSubscriptionRatePlanData entered--'+productRatePlanId);
        Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
        ratePlanData.setValue('RatePlan', createRatePlan(productRatePlanId));
        ratePlanData.setValue('RatePlanChargeData', new List < Zuora.zObject > {
          createRatePlanChargeDataForNewProduct(productRatePlanChargeId,subscriptionId)
        });
        return ratePlanData;
      }
      public static Zuora.zObject createRatePlan(String productRatePlanId) {
        Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
        ratePlan.setValue('ProductRatePlanId', productRatePlanId);
        return ratePlan;
      }
      public static Zuora.zObject createRatePlanChargeDataForNewProduct(String productRatePlanChargeId,string subscriptionId) {
        Zuora.zObject ratePlanChargeData = new Zuora.zObject('RatePlanChargeData');
        ratePlanChargeData.setValue('RatePlanCharge', createRatePlanCharge(productRatePlanChargeId,subscriptionId));
        return ratePlanChargeData;
      }
       public static Zuora.zObject createRatePlanCharge(String productRatePlanChargeId,string subscriptionId) {
        Zuora.zObject ratePlanCharge = new Zuora.zObject('RatePlanCharge');
        ratePlanCharge.setValue('ProductRatePlanChargeId', productRatePlanChargeId);
        if(subscriptionId_Price.containskey(subscriptionId))
            ratePlanCharge.setValue('Price', subscriptionId_Price.get(subscriptionId));
        return ratePlanCharge;
      }
  
}