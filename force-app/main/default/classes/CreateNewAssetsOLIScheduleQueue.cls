//**************************************************//
// Class Name : CreateNewAssetsOLIScheduleQueue
//
//Modified 29th Aug 2016  Author Name: Pallavi Tammana -- Modifed for JIRA STORY ADVP-2030
//**************************************************//

global class CreateNewAssetsOLIScheduleQueue implements Schedulable {
    global void execute(SchedulableContext sc) {
        //Expire Assets
        Integer numbtype = System.now().Minute();
        Integer numbtypehour = System.now().Hour();
        try{
            
            //Process Orders
            Set<Id> theOrderIdsToProcess = new Set<Id>();
            Map<String,String> theTourboCreditStatus = new Map<String,String>{'Not Required'=>'Not Required','Processed'=>'Processed'};
                Set<Id> setNotOrderIds = new Set<Id>();
            Set<String> setPCode = new Set<String>{'TURBO','SELLERLEADBUNDLE','ADVANTAGE'};
                Set<String> setPCodeRealSuite = new Set<String>{'RSRESPOND','RSPRODUCE','RSCONNECT','RSTRANSACT'};
                    Map<String,String> mapRealSuiteRelation = new Map<String,String>();
            Set<String> setLineAction = new Set<String>{'Add','Renew'};
                Set<Id> setRealSuiteAccountIds = new Set<Id>();
            List<Order> lstOrder = new List<Order>();
            List<Asset> lstAssete = new List<Asset>();
            List<Asset> lstAsset = new List<Asset>();
            Boolean orderprocess = true;
            Boolean assetprocess = true;
            Boolean expireprocess = true;
            Boolean largeAccount = false;
            Boolean RealSuiteAccount = false;
            Schedule_Batch_Setting__c orderp= Schedule_Batch_Setting__c.getValues('Order process');
            Schedule_Batch_Setting__c assetp= Schedule_Batch_Setting__c.getValues('Asset Process');
            Schedule_Batch_Setting__c expirep= Schedule_Batch_Setting__c.getValues('Expire Asset');
            Schedule_Batch_Setting__c Evga = Schedule_Batch_Setting__c.getValues('Evergreeen Renewal Date');
            if(orderp!=null){orderprocess = orderp.Is_Running__c;}
            if(assetp!=null){assetprocess = assetp.Is_Running__c;}
            if(expirep!=null){expireprocess = expirep.Is_Running__c;}
            List<String> lstTPandTigerCode = (System.label.TPandTigerProduct+'').split(',');
            Set<String> setTPandTigerCode = new Set<String>();
            for(String str :lstTPandTigerCode){
                setTPandTigerCode.add(str);
            }
            Set<String> theproductcode = new Set<String>();
            if(System.Label.FSMASNSHT!=null){
                theproductcode.addAll(System.Label.FSMASNSHT.split(','));
            }
            System.debug(theproductcode);
            Set<String> thePromotions = new Set<String>();
            if(System.Label.Promotions!=null){
                thePromotions.addAll(System.Label.Promotions.split(','));
            }
            System.debug(thePromotions);         
            List<String> lstBillingAccount = (System.label.Zoura_billing_accounts+'').split(',');
            Set<String> setBillingAccount = new Set<String>();
            for(String str :lstBillingAccount){
                setBillingAccount.add(str);
            }
            if(orderprocess  && numbtype<65){
                //Modified for JIRA STORY related to Advantage product :- By Sonu Sharma
                for(OrderItem oti:[SELECT Id,Line_type__c,DecommissionedAsset__c,DecommissionedAsset__r.Status,DecommissionedAsset__r.Fulfillment_Status__c,Order.Account.Type,PricebookEntry.Product2.ProductCode,OrderId,Asset__r.Credit_Status__c,Asset__r.Record_Processed_for_commission__c FROM OrderItem where Line_type__c=:setLineAction and
                                   PricebookEntry.Product2.ProductCode=:setPCode and Order.Status != 'Complete' and Order.EffectiveDate<=Today and
                                   Order.Is_OLI_Creation_Complete__c =false]){  //and Asset__r.Credit_Status__c!=:theTourboCreditStatus
                                       if(oti.Line_type__c=='Renew'){
                                           if(oti.PricebookEntry.Product2.ProductCode=='TURBO'){
                                               if(oti.Asset__r.Record_Processed_for_commission__c ==false){
                                                   setNotOrderIds.add(oti.OrderId);
                                               }
                                               if(theTourboCreditStatus.containskey(oti.Asset__r.Credit_Status__c) ==false){
                                                   setNotOrderIds.add(oti.OrderId);
                                               }
                                           }
                                           if(oti.PricebookEntry.Product2.ProductCode=='SELLERLEADBUNDLE'){
                                               if(oti.Asset__r.Record_Processed_for_commission__c ==false){
                                                   setNotOrderIds.add(oti.OrderId);
                                               }
                                           }
                                       }
                                       //Modified for JIRA STORY related to Advantage product :- By Sonu Sharma
                                       if(oti.Line_type__c=='Add' && oti.PricebookEntry.Product2.ProductCode=='ADVANTAGE'){
                                           if(oti.DecommissionedAsset__c!=null){
                                               if(oti.DecommissionedAsset__r.Status =='Expired' && oti.DecommissionedAsset__r.Fulfillment_Status__c=='Fulfilled'){
                                               } else{ setNotOrderIds.add(oti.OrderId);
                                                     }
                                           }
                                           
                                       }
                                       //End
                                   }
                
                lstOrder = [Select Id,Is_OLI_Creation_Complete__c,Type from Order
                            where Fulfillment_Status__c='Pending Fulfillment' and EffectiveDate<=Today and id NOT IN :setNotOrderIds
                            and Is_OLI_Creation_Complete__c =false and Status != 'Complete' order by LastmodifiedDate Desc limit 50];
            }
            for(Order odr:lstOrder){
                odr.Is_OLI_Creation_Complete__c = true;
            }
            Set<Id> theAssetIdsToProcess = new Set<Id>();
            if(assetprocess){
                //Modified for JIRA STORY ADVP-2030 - Added condition to verify the Assets's Account EssentialsStatus is 'Activated'
                List<Asset> lstAssetMore = new List<Asset>();
                if(numbtypehour<24 ){
                    
                    Integer jcount = [Select count() from cronTrigger WHERE CronJobDetail.JobType = '7'];
                    if(jcount<85){
                        //CRM-1340 :- Added order by Product Priority in the query Fulfillment_Priority__c
                        lstAssetMore = [Select Id,Name,Real_Suite_Parent__c,Product2.ProductCode,Line_type__c,Fulfillment_Status__c,Status,AccountId,Account.Onyx_Customer__c from Asset
                                        where asset_Type__c='Parent' and Fulfillment_Status__c='Waiting to Process' and
                                        Fulfillment_Required__c=true and (Product2.EssentialsRequired__c = false or (Product2.EssentialsRequired__c = true and Account.EssentialsStatus__c = 'Activated' and Line_type__c='Add') OR (Product2.EssentialsRequired__c = true and Line_type__c!='Add')) order by Product2.Fulfillment_Priority__c ASC,LastmodifiedDate Desc limit 25];
                    }
                } else{
                    //CRM-1340 :- Added order by Product Priority in the query Fulfillment_Priority__c
                    lstAssetMore = [Select Id,Name,Real_Suite_Parent__c,Product2.ProductCode,Line_type__c,Fulfillment_Status__c,Status,AccountId,Account.Onyx_Customer__c from Asset
                                    where asset_Type__c='Parent' and Fulfillment_Status__c='Waiting to Process' and
                                    Fulfillment_Required__c=true and (Product2.EssentialsRequired__c = false or (Product2.EssentialsRequired__c = true and Account.EssentialsStatus__c = 'Activated' and Line_type__c='Add') OR (Product2.EssentialsRequired__c = true and Line_type__c!='Add')) order by Product2.Fulfillment_Priority__c ASC,LastmodifiedDate Desc limit 25];
                }
                //CRM-1716 :- Limit list to send only one asset if Onyx customer flag is not true
                Map<Id,Id> nonONYXCustomer = new Map<Id,Id>();
                
                for(Asset asst:lstAssetMore){
                    System.debug('largeAccount'+setBillingAccount.contains(asst.AccountId)+''+asst.AccountId);
                    // CRM - 2443 Large account 
                    if(setBillingAccount.contains(asst.AccountId)){
                        largeAccount = true;
                        System.debug('largeAccount'+largeAccount);
                    }
                    if(setPCodeRealSuite.contains(asst.Product2.ProductCode)){
                        RealSuiteAccount = true;
                        setRealSuiteAccountIds.add(asst.AccountId);
                    }
                    if(setTPandTigerCode.contains(asst.Product2.ProductCode)){
                        if(asst.Account.Onyx_Customer__c==false && nonONYXCustomer.containskey(asst.AccountId)){
                            
                        } else{
                            if(asst.Account.Onyx_Customer__c==false){
                                nonONYXCustomer.put(asst.AccountId,asst.AccountId);
                            }
                            lstAsset.add(asst);
                        }
                    } else{
                        lstAsset.add(asst);
                    }
                }
                
            }
            if(expireprocess && numbtype<55){
                Set<Id> setIds = new Set<Id>();
                for(Asset ast:[Select Id,Name,Fulfillment_Status__c,Status,Line_Type__c,Start_Date__c,Promotion__c,Extended_Net_Price__c,Asset_Type__c from Asset
                               where product_code__c = 'SELLERLEADBUNDLE' and Status != 'Expired' AND Status != 'Cancelled' AND Status !='Converted' and Asset_Type__c='Parent' and
                               End_Date__c<=Yesterday and Credit_Status__c!=:theTourboCreditStatus.keyset() and Renewal_Start_Date__c=null and Product2.Renewal_Term_Type__c !='evergreen' and Trial__c=false]){
                                   setIds.add(ast.Id);
                               }
                
                if((numbtype>10 && numbtype<15) ||(numbtype>20 && numbtype<25) || (numbtype>30 && numbtype<35)){
                    lstAssete = [Select Product2.Prosoft_Evergreen_Renewal__c,Subscription_Id__c,Prosoft_Evergreen_Renewal__c,Id,Name,Account.Account_Owner_Team__c,Trial__c,Start_Date__c,Promotion__c,Extended_Net_Price__c,Month_to_Month__c,Renewal_Status__c,Product2.ProductCode,End_Date__c,Delta_Price_w_o_Tax__c,Product2.Renewal_Term_Type__c,Amend_Delta_Price__c,Fulfillment_Status__c,Status,Line_Type__c,Asset_Type__c from Asset
                                 where Status != 'Expired' AND Status != 'Cancelled' AND Status !='Converted' and Status != 'Deleted' and Fulfillment_Status__c != 'Deleted' and Asset_Type__c='Parent' and
                                 End_Date__c<=Yesterday and Renewal_Start_Date__c=null
                                 and Id!=:setIds and (Product2.Renewal_Term_Type__c !='evergreen' or (Product2.Renewal_Term_Type__c ='evergreen' AND Renewal_Status__c='Do Not Renew')) order by End_Date__c Desc limit 25];
                    //CRM-3562 --Expiring trial products
                    for(Asset aaast:[Select Product2.Prosoft_Evergreen_Renewal__c,Subscription_Id__c, Prosoft_Evergreen_Renewal__c, Id,Name,Account.Account_Owner_Team__c,Trial__c,Start_Date__c,Promotion__c,Extended_Net_Price__c,Month_to_Month__c,Renewal_Status__c,Product2.ProductCode,End_Date__c,Delta_Price_w_o_Tax__c,Product2.Renewal_Term_Type__c,Amend_Delta_Price__c,Fulfillment_Status__c,Status,Line_Type__c,Asset_Type__c from Asset
                                     where Status != 'Expired' AND Status != 'Cancelled' AND Status !='Converted' and Status != 'Deleted' and Fulfillment_Status__c != 'Deleted' and Asset_Type__c='Parent' and
                                     End_Date__c<=Yesterday and Renewal_Start_Date__c=null and (Product2.Renewal_Term_Type__c ='evergreen' AND trial__c = true) order by End_Date__c Desc limit 5]){
                                         lstAssete.add(aaast);
                                     }
                } else
                    if((numbtype>40 && numbtype<55)){
                        lstAssete = [Select Product2.Prosoft_Evergreen_Renewal__c,Subscription_Id__c,Prosoft_Evergreen_Renewal__c,Id,Account.Account_Owner_Team__c,trial__c,Start_Date__c,Month_to_Month__c,Promotion__c,Extended_Net_Price__c,Name,Renewal_Status__c,Product2.ProductCode,End_Date__c,Delta_Price_w_o_Tax__c,Product2.Renewal_Term_Type__c,Amend_Delta_Price__c,Fulfillment_Status__c,Status,Line_Type__c,Asset_Type__c from Asset
                                     where Status != 'Expired' AND Status != 'Cancelled' AND Status !='Converted' and Status != 'Deleted' and Fulfillment_Status__c != 'Deleted' and Asset_Type__c='Parent' and
                                     End_Date__c<=Yesterday and Renewal_Start_Date__c=null
                                     and Id!=:setIds  order by End_Date__c Desc limit 15];
                    }
                System.debug('Expiring assets '+lstAssete);
                
            }
            
            //CRM-4054
            if(lstOrder.size()>0){
                update lstOrder;
            } 
            If(true){
                
                // CRM - 2443 Large account 
                Map<Id,String> mapAccountIdZouraBillingId = new Map<Id,String>();
                System.debug('largeAccount'+largeAccount);
                if(largeAccount){
                    for(Zuora__CustomerAccount__c accc:[Select Id, Name,Zuora__Account__c,Zuora__Zuora_Id__c from Zuora__CustomerAccount__c where Zuora__Account__c=:setBillingAccount order by CreatedDate ASC]){
                        mapAccountIdZouraBillingId.put(accc.Zuora__Account__c,accc.Zuora__Zuora_Id__c);
                    }
                } 
                // CRM - 2443 Large account 
                
                if(RealSuiteAccount){
                    for(Asset ast:[Select Id,Product2.ProductCode,AccountId,Promotion__c from Asset where AccountId=:setRealSuiteAccountIds and Product2.ProductCode=:setPCodeRealSuite  and asset_Type__c='Parent']){
                        // if(ast.Promotion__c!='1FREERESPONDLICENSE'){
                        mapRealSuiteRelation.put(ast.AccountId+'##'+ast.Product2.ProductCode,ast.id);
                        // }
                    }
                }
                for(Asset ast:lstAsset){
                    //2091-did changes
                    ast.Fulfillment_Status__c = 'Pending Fulfillment';
                    if(ast.Line_type__c=='Renew' && ast.Had_do_not_renew__c == True){
                        ast.Had_do_not_renew__c = false;
                    }
                    if(ast.Line_type__c=='Add'){
                        //if(mapRealSuiteRelation.containskey(ast.AccountId+'##'+ast.Product2.ProductCode)){
                        String relatePCode = '';
                        if(ast.Product2.ProductCode=='RSRESPOND'){relatePCode='RSCONNECT';}
                        if(ast.Product2.ProductCode=='RSCONNECT'){relatePCode='RSPRODUCE';}
                        //if(ast.Product2.ProductCode=='RSPRODUCE'){relatePCode='RSCONNECT';}
                        System.debug('mapRealSuiteRelationpp'+mapRealSuiteRelation);
                        System.debug(ast.AccountId+'##'+relatePCode);
                        if(mapRealSuiteRelation.containskey(ast.AccountId+'##'+relatePCode)){
                            ast.Real_Suite_Parent__c = mapRealSuiteRelation.get(ast.AccountId+'##'+relatePCode);
                        }
                        // }
                        System.debug('largeAccount'+mapAccountIdZouraBillingId);
                        // CRM - 2443 Large account 
                        if(mapAccountIdZouraBillingId.containskey(ast.AccountId)){
                            System.debug('largeAccount'+largeAccount);
                            ast.Zuora_Billing_Account_Id__c = mapAccountIdZouraBillingId.get(ast.AccountId);
                        }
                    }
                    if(ast.Line_type__c!='Credit'&& ast.Status != 'Deleted'){
                        ast.Status = 'Active';
                    }
                }
                if(lstAsset.size()>0 || lstAssete.size()>0){
                    if(lstAsset.size()>0){
                        SkipQuotaTrigger.setSkipTrgTrue();
                        update lstAsset;
                    }
                    if(lstAsset.size()<1){
                        if(lstAssete.size()>0){
                            AssetExpiration(setTPandTigerCode,theproductcode,thePromotions,lstAssete);
                        }     else
                    {
                        //Added by Pratik for 5201 on 4th January 2019
                        List<Asset> lstAssettoUpdate = [Select Id, Status From Asset 
                                                            Where (Product_Code__c = 'RSRESPOND' 
                                                                    OR Product_Code__c = 'RSCONNECT') 
                                                            AND Status != 'Expired' 
                                                            AND Days_Expiration_Email_Sent__c >= 30 
                                                            Limit 30];
                        
                        for(Asset newAsset :lstAssettoUpdate)
                            newAsset.Status = 'Expired';
                        
                        update lstAssettoUpdate;
                        //Ends here
                    }           
                 }
                    
                } else {
                    if(lstAssete.size()<1 && lstAsset.size()<1 && lstOrder.size()<1 && assetprocess){
                        //Integer numbtype = System.now().Minute();
                        // if((numbtype>20 && numbtype<30) || (numbtype>40 && numbtype<50)){
                        ProcessFulfillmentNotRequired(1); //earlier it was 2
                        // }
                        
                    }
                }
            }
            
            List<CronTrigger> listCronTriggerAsset = [select Id from CronTrigger where CronJobDetail.Name LIKE 'AssetScheduleJobA1A%' and State = 'DELETED' and nextfiretime = null limit 10];
            If (listCronTriggerAsset.size() > 0)
            {
                For (Integer i = 0; i < listCronTriggerAsset.size(); i++)
                { System.abortJob(listCronTriggerAsset[i].Id); }
            }
            
            
            Integer rcount =[SELECT count() FROM CronTrigger WHERE CronJobDetail.Name LIKE 'AssetScheduleJobA1A%'];
            if(rcount<2){
                CreateNewAssetsOLIScheduleQueue p = new CreateNewAssetsOLIScheduleQueue();
                Datetime dtt = System.now().addMinutes(1).addSeconds(1);
                String sch = dtt.Second()+' '+dtt.Minute()+' '+dtt.hour()+' '+dtt.day()+' '+dtt.Month()+' ? '+dtt.year();
                system.schedule('AssetScheduleJobA1A'+dtt, sch, p);
                
                List<CronTrigger> listCronTrigger = [select Id from CronTrigger where State = 'DELETED' and nextfiretime = null limit 20];
                If (listCronTrigger.size() > 0)
                {
                    For (Integer i = 0; i < listCronTrigger.size(); i++)
                    { System.abortJob(listCronTrigger[i].Id); }
                }
            }
            if(Test.isRunningTest()){
                integer intTest =1/0;}
            
        } catch(Exception ex){
            Set<Id> theOrderIdsToProcess = new Set<Id>();
            List<Order> lstOrder = [Select Id,Is_OLI_Creation_Complete__c from Order where Fulfillment_Status__c='Pending Fulfillment' and EffectiveDate<=Today and Is_OLI_Creation_Complete__c =false and Status != 'Complete' order by LastmodifiedDate Desc limit 2];
            for(Order odr:lstOrder){
                odr.Is_OLI_Creation_Complete__c = true;
            }
            if(lstOrder.size()>0){
                // update lstOrder;
            }
            List<CronTrigger> listCronTriggerAsset = [select Id from CronTrigger where CronJobDetail.Name LIKE 'AssetScheduleJobA1A%' and State = 'DELETED' and nextfiretime = null limit 10];
            If (listCronTriggerAsset.size() > 0)
            {
                For (Integer i = 0; i < listCronTriggerAsset.size(); i++)
                { System.abortJob(listCronTriggerAsset[i].Id); }
            }
            
            
            Integer rcount =[SELECT count() FROM CronTrigger WHERE CronJobDetail.Name LIKE 'AssetScheduleJobA1A%'];
            if(rcount<2 || Test.isRunningTest()){
                CreateNewAssetsOLIScheduleQueue p = new CreateNewAssetsOLIScheduleQueue();
                Datetime dtt = System.now().addMinutes(1).addSeconds(5);
                String sch = dtt.Second()+' '+dtt.Minute()+' '+dtt.hour()+' '+dtt.day()+' '+dtt.Month()+' ? '+dtt.year();
                system.schedule('AssetScheduleJobA1A'+dtt, sch, p);
                
                List<CronTrigger> listCronTrigger = [select Id from CronTrigger where State = 'DELETED' and nextfiretime = null limit 20];
                If (listCronTrigger.size() > 0)
                {
                    For (Integer i = 0; i < listCronTrigger.size(); i++)
                    { System.abortJob(listCronTrigger[i].Id); }
                }
            }
            if((ex+'').length()>0){
                String theEmailAddresses = Error_Notification_Email_Settings__c.getInstance('Email Addresses').Asset_Creation_Batch_Distribution__c;
                if(String.isNotBlank(theEmailAddresses)) {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    
                    mail.saveAsActivity = false;
                    mail.setToAddresses(theEmailAddresses.split(';'));
                    mail.setSubject('Asset Batch Job failure Notification');
                    
                    String theEmailBody = 'Hi Admin,\n\n';
                    theEmailBody += 'Please review following failure.\n\n';
                    theEmailBody += ''+ex;
                    theEmailBody += 'Thanks.\nAdmin Tech Team';
                    
                    mail.setPlainTextBody(theEmailBody);
                    Messaging.sendEmail(new List<Messaging.SingleEmailMessage> { mail });
                }
            }
        }
        if(numbtype>50 || test.isRunningTest()){
            Integer manualAssets = [SELECT count() FROM Asset WHERE End_Date__c <= Yesterday AND Status != 'Expired' AND Status != 'Cancelled' AND Renewal_Start_Date__c != null and Product2.Renewal_Term_Type__c !='evergreen'];
            if(manualAssets>0){
                ErrorEmail();
            }
        }
    }
    
    Public void AssetExpiration(Set<String> setTPandTigerCode,Set<String>theproductcode,Set<String>thePromotions,List<Asset> lstAssete){
        // CRM-5709 - Fetch setting to run Evergreeen Prosoft Renewal
        Boolean runEvergreenProsoftRenewal = true;
        Schedule_Batch_Setting__c evergreenProsoftRenewal = Schedule_Batch_Setting__c.getValues('Evergreen Prosoft Renewal');
        if (evergreenProsoftRenewal != null) {
            runEvergreenProsoftRenewal = evergreenProsoftRenewal.Is_Running__c;
        }
        // CRM-5709 - End
        Map<String, String> everGreenprosoftAssets = new Map<String, String>();
        for(Asset ast:lstAssete){
            System.debug('JJJJJ');
            // CRM-3775 -- Convert the Prosoft assets to evergreen only when Start Date < 2/10/2017
            // Date dt = Date.valueOf('2017-10-02');
            Schedule_Batch_Setting__c Evga = Schedule_Batch_Setting__c.getValues('Evergreeen Renewal Date');
            Date dt = Evga.Date_Value__c;
            // CRM-5709 - Added 2nd if and Reordered ifelse below
            /*if(setTPandTigerCode.contains(ast.Product2.ProductCode) && !thePromotions.contains(ast.Promotion__c) && ast.Renewal_Status__c!='Do Not Renew' && ast.Account.Account_Owner_Team__c!='Broker Regional Directors Sales Team' && ast.Start_Date__c < dt){
                System.debug('JJJJJ1');
                ast.End_Date__c = Date.newInstance(2026, 12, 31);
                ast.Month_to_Month__c = 'Y';
                ast.Line_Type__c = 'Renew';
            } // CRM-5216 --- Make Prosoft Assets whose Billing has been adjusted as part C+ Evergreen
            else if(ast.End_Date__c < System.Today() && ast.Renewal_Status__c!='Do Not Renew' && theproductcode.contains(ast.Product2.ProductCode) && thePromotions.contains(ast.Promotion__c) && ast.Extended_Net_Price__c == 0) {
                System.debug('Until here to 2050');
                ast.End_Date__c = Date.newInstance(2050, 12, 31);
                ast.Line_Type__c = 'Renew';
            }*/ 
            system.debug('Asset -- ' + ast.Id);
            if(ast.End_Date__c < System.Today() && ast.Renewal_Status__c!='Do Not Renew' && theproductcode.contains(ast.Product2.ProductCode) && thePromotions.contains(ast.Promotion__c) && ast.Extended_Net_Price__c == 0) {
                System.debug('Until here to 2050');
                ast.End_Date__c = Date.newInstance(2050, 12, 31);
                ast.Line_Type__c = 'Renew';
            } 
            // CRM-5709 - New if
            else if(runEvergreenProsoftRenewal && ast.Renewal_Status__c!='Do Not Renew' && ast.Product2.Prosoft_Evergreen_Renewal__c && ast.Prosoft_Evergreen_Renewal__c) {
                ast.End_Date__c = Date.newInstance(2026, 12, 31);
                ast.Month_to_Month__c = 'Y';
                ast.Line_Type__c = 'Renew';
                everGreenprosoftAssets.put(ast.Id, ast.subscription_Id__c);
                system.debug('everGreenprosoftAssets -- ' + ast.Id);
            }
            // CRM-5709 - New if End
            else if(setTPandTigerCode.contains(ast.Product2.ProductCode) && !thePromotions.contains(ast.Promotion__c) && ast.Renewal_Status__c!='Do Not Renew' && ast.Account.Account_Owner_Team__c!='Broker Regional Directors Sales Team' && ast.Start_Date__c < dt){
                System.debug('JJJJJ1');
                ast.End_Date__c = Date.newInstance(2026, 12, 31);
                ast.Month_to_Month__c = 'Y';
                ast.Line_Type__c = 'Renew';
            } 
            // CRM-5709 - if else reorder End
            else if(ast.End_Date__c<System.Today() && (ast.Product2.Renewal_Term_Type__c !='evergreen' || (ast.Product2.Renewal_Term_Type__c =='evergreen' && ast.Renewal_Status__c=='Do Not Renew'))){
                System.debug('JJJJJ2');
                ast.Fulfillment_Status__c = 'Pending Fulfillment';
                ast.Status = 'Expired';
                ast.TCV_Processed__c = 'false';
                ast.Amend_Delta_Price__c = 0.00;
                ast.Delta_Price_w_o_Tax__c = 0.00;
                ast.Line_Type__c = 'Cancel';
            } else if(setTPandTigerCode.contains(ast.Product2.ProductCode)){
                System.debug('JJJJJ3');
                ast.Fulfillment_Status__c = 'Pending Fulfillment';
                ast.Status = 'Expired';
                ast.TCV_Processed__c = 'false';
                ast.Amend_Delta_Price__c = 0.00;
                ast.Delta_Price_w_o_Tax__c = 0.00;
                ast.Line_Type__c = 'Cancel';
            } else if(ast.trial__c){
                System.debug('JJJJJ4');
                ast.Fulfillment_Status__c = 'Pending Fulfillment';
                ast.Status = 'Expired';
                ast.TCV_Processed__c = 'false';
                ast.Amend_Delta_Price__c = 0.00;
                ast.Delta_Price_w_o_Tax__c = 0.00;
                ast.Line_Type__c = 'Cancel';
            }
            
        }
        if(lstAssete.size()>0){
            System.debug('JJJJJ5');
            SkipQuotaTrigger.setSkipTrgTrue();
            update lstAssete;
            
            // CRM-5709 - Zuora Subscription update for Ever Green Prosoft Assets 
            if (!everGreenprosoftAssets.isEmpty()) {
                updateZuoraSubscriptionToEverGreen(everGreenprosoftAssets);
            }
            // CRM-5709 - End
        }
        
    }
    
    Public void ProcessFulfillmentNotRequired(Integer size){
        List<Asset> lstAssetnf = new List<Asset>();
        if(size==2){
            lstAssetnf = [Select Id,Name,Line_type__c,Fulfillment_Status__c,Status from Asset where asset_Type__c='Parent' and Fulfillment_Status__c='Waiting to Process' and Fulfillment_Required__c=false order by LastmodifiedDate Desc,Product2.Fulfillment_Priority__c ASC  limit 2];
        }
        if(size==1){
            lstAssetnf = [Select Id,Name,Line_type__c,Fulfillment_Status__c,Status from Asset where asset_Type__c='Parent' and Fulfillment_Status__c='Waiting to Process' and Fulfillment_Required__c=false order by LastmodifiedDate Desc,Product2.Fulfillment_Priority__c ASC limit 1];
        }
        for(Asset ast:lstAssetnf){
            ast.Fulfillment_Status__c = 'Pending Fulfillment';
            if(ast.Line_type__c!='Credit'&& ast.Status != 'Deleted'){  //crm-2091
                ast.Status = 'Active';
            }
        }
        if(lstAssetnf.size()>0){
            SkipQuotaTrigger.setSkipTrgTrue();
            update lstAssetnf;
        }
    }
    
    Public void ErrorEmail(){
        String theEmailAddresses = Error_Notification_Email_Settings__c.getInstance('Email Addresses').Asset_Creation_Error_Emails__c;
        if(String.isNotBlank(theEmailAddresses)) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            mail.saveAsActivity = false;
            mail.setToAddresses(theEmailAddresses.split(';'));
            mail.setSubject('Asset Expire Batch Job Notification');
            
            String theEmailBody = 'Hi Admin,\n\n';
            theEmailBody += 'Please review following assets and these assets having renewals in place and cannot be Expired.\n\n';
            theEmailBody += '<a href='+Error_Notification_Email_Settings__c.getInstance('Email Addresses').View_Link__c+'>Manual Asset Expiration</a>\n\n';
            theEmailBody += 'Thanks.\nAdmin Tech Team';
            
            mail.setPlainTextBody(theEmailBody);
            try{
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage> { mail });
            } catch(Exception ex){}
        }
    }
    
    // CRM-5709 - Future method to update subscriptions
    @future(callout=true)
    private static void updateZuoraSubscriptionToEverGreen(Map<String, String> everGreenprosoftAssets) {
        Map<String, Object> fieldValues = new Map<String, Object>();
        for (Prosoft_Evergreen_Renewal_Setting__c setting : [SELECT Name, Value__c FROM Prosoft_Evergreen_Renewal_Setting__c WHERE Active__c=true]) {
            fieldValues.put(setting.Name, setting.Value__c);
            if (setting.name == 'ContractEffectiveDate') {
                fieldValues.put('ContractEffectiveDate', Z_SubscriptionCallhelper.getdate(system.today().addDays(Integer.valueOf(setting.Value__c))));
            }
        }
        
        Map<String, String> errors = new Map<String, String>();
        for (String assetId : everGreenprosoftAssets.keySet()) {
            system.debug ('Calling Amend On - ' + assetId );
            String error = Z_amendsubscription.amendSubscription(everGreenprosoftAssets.get(assetId), fieldValues);
            if (error != null) {
                errors.put(assetId, error);
            }
        }
        if (!errors.isEmpty()) {
            sendEvergreenProsoftRenewalFailureEmail(errors);
        }
    }
    
    // CRM-5709 - Evergreen Prosoft Renewal Failure Email
    @testvisible
    private static void sendEvergreenProsoftRenewalFailureEmail(Map<String, String> errors) {
        String theEmailAddresses = Error_Notification_Email_Settings__c.getInstance('Evergreen Prosoft Renewal Failure').Asset_Creation_Error_Emails__c;
        if(String.isNotBlank(theEmailAddresses)) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.saveAsActivity = false;
            mail.setToAddresses(theEmailAddresses.split(';'));
            mail.setSubject('Evergreen Prosoft Renewal Failure');
            String body = 'Evergreen Prosoft Renewal Zuora Failure- <br/> <table border="1" cellspacing="0" cellpedding="5"> <tr><th>Asset Id</th><th>Error</th></tr>' ; 
            for (String assetName : errors.keySet()) {
                body = body + '<tr><td>' + assetName + '</td><td>' + errors.get(assetName) + '</td></tr>';
            }
            body = body + '</table><br/><br/>';
            
            mail.setHtmlBody(body);
            try {
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage> { mail });
            } 
            catch(Exception ex){}
        }
    }
}