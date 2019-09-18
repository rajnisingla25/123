global class ExpireFiveStreetAssetschedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        Integer numbtypemin = System.now().Minute();
        Integer numbtypehour = System.now().Hour();
        Boolean runNextprocess = true;
        Boolean Pendingorderprocess = true;
        Boolean firstscript = true;
        Boolean Secondscript = true;
        Boolean thirdscript = true;
        Boolean fourthscript = true;
        Boolean ZuoraErrorprocess = true;
        Boolean PendingFSassetprocess = true;
        Boolean ignoreFSowner = true;
        Boolean winbackprocess = true;
        Boolean PendingInvoiceprocess = true;
        Boolean CancellingTurboprocess = true;
        Integer winbackprocessStartTimehr = 5;
        Integer winbackprocessEndTimehr = 6;
        Integer scriptoneStartTimeMin = 1;
        Integer scripttwoStartTimeMin = 5;
        Integer scriptthreeStartTimeMin = 3;
        Integer scriptfourStartTimeMin = 7;
         Integer lmCount =0;
        // CRM-1787 - To update Private Contacts
        Boolean PendingContactProcess = true;
        Schedule_Batch_Setting__c conop = Schedule_Batch_Setting__c.getValues('Private Contact Process');
        // CRM-1787 end
        Schedule_Batch_Setting__c orderp = Schedule_Batch_Setting__c.getValues('Pending Order process');
        Schedule_Batch_Setting__c assetp = Schedule_Batch_Setting__c.getValues('Pending FS Asset Process');
        Schedule_Batch_Setting__c ignorep = Schedule_Batch_Setting__c.getValues('Ignore FS Owner');
        Schedule_Batch_Setting__c invoicep = Schedule_Batch_Setting__c.getValues('Invoice Process');
        Schedule_Batch_Setting__c turbop = Schedule_Batch_Setting__c.getValues('Turbo Cancellation Process');
        Schedule_Batch_Setting__c ZuoraErrorp = Schedule_Batch_Setting__c.getValues('Update Run Order Decomp');
        Schedule_Batch_Setting__c winbackpro = Schedule_Batch_Setting__c.getValues('Win Back Process');
        Schedule_Batch_Setting__c scriptone = Schedule_Batch_Setting__c.getValues('leadscoreclaculationscriptone');
        Schedule_Batch_Setting__c scripttwo = Schedule_Batch_Setting__c.getValues('leadscoreclaculationscripttwo');
        Schedule_Batch_Setting__c scriptthree = Schedule_Batch_Setting__c.getValues('leadscoreclaculationscriptthree');
        Schedule_Batch_Setting__c scriptfour = Schedule_Batch_Setting__c.getValues('leadscoreclaculationscriptfour');
        Schedule_Batch_Setting__c dm = Schedule_Batch_Setting__c.getValues('DailyMonitoring');    //CRM-6367
        
        Date winStartdate = System.today().AddDays(6);
        Date winEnddate = System.Date.today().toStartOfMonth().addMonths(1).addDays(-1);
        system.debug('winEnddate:'+winEnddate+'  winStartdate:'+winEnddate);
        Set<String> winproductcode = new Set<String>();
        if(System.Label.Winbackprocessproductcode!=null){
            winproductcode.addAll(System.Label.Winbackprocessproductcode.split(','));
        }
        Set<String> winbackrenewtypeam= new Set<String>();
        if(System.Label.winbackrenewtype!=null){
            winbackrenewtypeam.addAll(System.Label.winbackrenewtype.split(','));
        }
        Set<String> winbackrolenames= new Set<String>();
        if(System.Label.winbackrolename!=null){
            winbackrolenames.addAll(System.Label.winbackrolename.split(','));
        }
        if (winbackpro != null) {
            winbackprocess = winbackpro.Is_Running__c;
            winbackprocessStartTimehr = Integer.valueof(winbackpro.Execution_Time_hr__c);
            winbackprocessEndTimehr = Integer.valueof(winbackpro.Execution_End_Time_Hr__c);
        }
        if (scriptone != null) {
            firstscript = scriptone.Is_Running__c;
            scriptoneStartTimeMin = Integer.valueof(scriptone.Execution_Min__c);
        }
        if (scripttwo != null) {
            Secondscript = scripttwo.Is_Running__c;
            scripttwoStartTimeMin = Integer.valueof(scripttwo.Execution_Min__c);
        }
        if (scriptthree != null) {
            thirdscript = scriptthree.Is_Running__c;
            scriptthreeStartTimeMin = Integer.valueof(scriptthree.Execution_Min__c);
        }
        if (scriptfour != null) {
            fourthscript = scriptfour.Is_Running__c;
            scriptfourStartTimeMin = Integer.valueof(scriptfour.Execution_Min__c);
        }
        if (orderp != null) {
            Pendingorderprocess = orderp.Is_Running__c;
        }
        if (assetp != null) {
            PendingFSassetprocess = assetp.Is_Running__c;
        }
        if (ignorep != null) {
            IgnoreFSowner = ignorep.Is_Running__c;
        }
        if (invoicep != null) {
            PendingInvoiceprocess = invoicep.Is_Running__c;
        }
        if (turbop != null) {
            CancellingTurboprocess = turbop.Is_Running__c;
        }
        if (ZuoraErrorp != null) {
            ZuoraErrorprocess = ZuoraErrorp.Is_Running__c;
        }
        
        // CRM-1787 - To update Private Contacts
        if (conop != null) {
            PendingContactProcess = conop.Is_Running__c;
        }
        // CRM-1787 end
        
        // CRM-6367 - To run Daily Monitoring reports and Send Email to 
        if (dm != null && dm.Is_Running__c) {
             List<System_Monitoring_Category__c> cats = new List<System_Monitoring_Category__c>();
             for (System_Monitoring_Category__c cat : [SELECT Last_Scheduler_Run_Date_Time__c, Frequency_To_Send_Email_hr__c, Name FROM System_Monitoring_Category__c]) {
                Double lastRunBefore = 0;
                if (cat.Last_Scheduler_Run_Date_Time__c != null) {
                    lastRunBefore = (System.now().getTime()-cat.Last_Scheduler_Run_Date_Time__c.getTime())/3600000;
                }
                
                system.debug('lastRunBefore -- ' + lastRunBefore);
                if (lastRunBefore >= cat.Frequency_To_Send_Email_hr__c || (cat.Last_Scheduler_Run_Date_Time__c == null && numbtypehour == dm.Execution_Time_hr__c)) {
                    Database.executeBatch(new DailyMonitoringBatch(cat.Name), 1);
                    cat.Last_Scheduler_Run_Date_Time__c = System.now();
                    cats.add(cat);
                }
                if (!cats.isEmpty()) {
                    update cats;
                }
            }
        }     
        // CRM-6367 - End
        
        // CRM-2621 - Process stuck ZQuotes
        if((50 < numbtypemin && numbtypemin < 56 && runNextprocess && ZuoraErrorprocess) || Test.isRunningTest()){
            Datetime modifieddate = system.now().addHours(-1);
            //modifieddate = system.now();
            String s=System.Now().format('MM/dd/YYYY','PST');
            Date effect = date.parse(s);
            List<OrderItem>  OrderItems = [Select Id, orderId,Order.AccountId, Zuora_Comment__c, Zuora_Status__c 
                                           FROM OrderItem 
                                           WHERE Order.EffectiveDate = :effect and Order.Lastmodifieddate <= :modifieddate and Order.Fulfillment_Status__c = 'Fulfilled' and Order.Run_OrderDecomp__c = false and (Zuora_Status__c = '' or (Zuora_Status__c = 'Success' and (Zuora_Comment__c != 'Sent to Z-Billing' and Zuora_Comment__c != 'No Zuora Changes'))) LIMIT 300];
            Set<Order> Ordertoupdate =  new Set<Order>();
            List<Order> Orderlisttoupdate = new List<Order>();
            for(OrderItem inloop:OrderItems){
                Order ord = new Order(Id = inloop.orderId, Run_OrderDecomp__c = true);
                Ordertoupdate.add(Ord);                              
            }
            if(Ordertoupdate.size() > 0){
                runNextprocess = false;
                SkipOrderTrigger.setSkipTrgTrue();
                Orderlisttoupdate = new List<Order>(Ordertoupdate); 
                update Orderlisttoupdate;
            }
        }
        //CRM-2621 - end
        
        //CRM - 317 - Turbo Cancellation
        if (CancellingTurboprocess) {
            if ((runNextprocess) || Test.isRunningTest()) {
                
                List < Asset > lstAsset = [Select Id, Process_Turbo_Cancellation__c from Asset where Process_Turbo_Cancellation__c = true and asset_type__c = 'Parent'
                                           and product_code__c = 'TURBO' limit 1
                                          ];
                if (lstAsset.size() > 0) {
                    runNextprocess = false;
                    for (Asset ast: lstAsset) {
                        ast.Process_Turbo_Cancellation__c = false;
                    }
                    update lstAsset;
                }
            }
        }  
        //CRM - 317 - Turbo Cancellation
        
        Set<Id> setIds = new Set<Id>();
        DateTime ddtt = Datetime.now().addMinutes(-30);
  /* List<Inventory_Data__c> lstInvData = [Select Id from Inventory_Data__c where Error__c = True and LastModifiedDate >=:ddtt];
        if(!lstInvData.isEmpty()){
            if(lstInvData.size()>0 && lstInvData.size()<10)
                lmcount = 30;
            else if(lstInvData.size()>10 && lstInvData.size()<20)
                lmcount = 25;
            
            else if(lstInvData.size()>20 && lstInvData.size()<50)
                lmcount = 15;
            else
            lmcount = 1;
            System.debug('value coming Here');
                sendErrornotificationEmail();
        }
           else{
               lmcount = Integer.valueof(label.record_size);
           }  */
        lmcount = Integer.valueof(label.record_size);
        if((numbtypemin > 5 && numbtypemin < 10) || (numbtypemin > 20 && numbtypemin < 25) || (numbtypemin > 40 && numbtypemin < 45)){
           lmcount = 1; 
        }
        
        If ((firstscript && numbtypemin >scriptoneStartTimeMin && numbtypemin <scripttwoStartTimeMin) || test.isRunningTest()){
            System.debug('Limit value coming Here Script1' + lmcount);
            for(Inventory_Account__c iaaa:[SELECT waitlist_type__c,Account__r.Account_Sub_Type__c,Inventory_Data__r.lastmodifieddate,Inventory_Data__r.name,Inventory_Data__r.Waitlist_count__C,
                                           Inventory_Data__c,id,Eligibility_Flex__c,Eligibility__c,Fast_Price__c,Flex_Price__c FROM Inventory_Account__c WHERE (Eligibility_Flex__c <= 0 and Eligibility__c <=0)  AND 
                                           Having_waitlist__c = true AND Inventory_Data__r.is_available__c = true and Inventory_Data__r.Waitlist_Count__c>0  and Account__r.Account_Sub_Type__c='Prospect' order by waitlist_type__c,Inventory_Data__r.lastmodifieddate desc limit :lmcount]){
                                               setIds.add(iaaa.Inventory_Data__c);
                                           }
            System.debug(setIds.size());
            If(setIds.size()>0) {
                LeadScoreCalculationCls.pullInventoryWaitlistInformationRequest(setIds);    
            }
            setIds.Clear();
        }
        If((Secondscript &&  numbtypemin >scripttwoStartTimeMin && numbtypemin <scriptthreeStartTimeMin) || test.isRunningTest()){
            System.debug('Limit value coming Here Script2' + lmcount);
            for(Inventory_Account__c iaaa:[SELECT waitlist_type__c,Account__r.Account_Sub_Type__c,Inventory_Data__r.lastmodifieddate,Inventory_Data__r.name,Inventory_Data__r.Waitlist_count__C,Inventory_Data__c,id,
                                           Eligibility_Flex__c,Eligibility__c,Fast_Price__c,Flex_Price__c FROM Inventory_Account__c WHERE (Eligibility_Flex__c <= 0 and Eligibility__c <=0)  AND 
                                           Having_waitlist__c = true AND Inventory_Data__r.is_available__c = true and Inventory_Data__r.Waitlist_Count__c>0  and  (Inventory_Data__r.LastModifiedDate= today or Inventory_Data__r.LastModifiedDate= yesterday) 
                                           and Account__r.Account_Sub_Type__c='Customer' order by waitlist_type__c,Inventory_Data__r.lastmodifieddate desc limit :lmcount]){
                                               setIds.add(iaaa.Inventory_Data__c);
                                           }
            System.debug(setIds.size());
            If(setIds.size()>0) {
                LeadScoreCalculationCls.pullInventoryWaitlistInformationRequest(setIds);    
            }
            setIds.Clear();
        }
        If(thirdscript &&  numbtypemin >scriptthreeStartTimeMin && numbtypemin <scriptfourStartTimeMin){
            System.debug('Limit value coming Here Script3' + lmcount);
            for(Inventory_Account__c iaaa:[SELECT Inventory_Data__r.name, lastModifiedDate,Id,Inventory_Data__c FROM Inventory_Account__c WHERE Eligibility_Flex__c > 0 AND Having_waitlist__c = true AND 
                                           Inventory_Data__r.is_available__c = false order by Inventory_Data__c limit :lmcount]){
                                               setIds.add(iaaa.Inventory_Data__c);
                                           }
            System.debug(setIds.size());
            If(setIds.size()>0) {
                LeadScoreCalculationCls.pullInventoryWaitlistInformationRequest(setIds);
            }
            setIds.Clear();
        }
        If(fourthscript &&  numbtypemin >scriptfourStartTimeMin && numbtypemin < 60){
            System.debug('Limit value coming Here Script4' + lmcount);
            for(Inventory_Account__c iaaa:[SELECT Inventory_Data__r.name, lastModifiedDate,Id,Inventory_Data__c FROM Inventory_Account__c WHERE Eligibility__c > 0 AND Having_waitlist__c = true AND 
                                           Inventory_Data__r.is_available__c = false order by Inventory_Data__c limit :lmcount]){
                                               setIds.add(iaaa.Inventory_Data__c);
                                           }
            System.debug(setIds.size());
            If(setIds.size()>0) {
                LeadScoreCalculationCls.pullInventoryWaitlistInformationRequest(setIds);
            }
            setIds.Clear();
        }
        if (winbackprocess&& (numbtypehour >= winbackprocessStartTimehr) && (numbtypehour < winbackprocessEndTimehr)) {
            set<Id>setAccountIds = new set<id>();
            for(Asset ast:[Select Id,AccountId,Fulfillment_Status__c,Status,Line_Type__c,Start_Date__c,Asset_Type__c from Asset
                           where product_code__c =: winproductcode and Status = 'Active' and Asset_Type__c='Parent' 
                           and End_Date__c>=:winStartdate and End_Date__c <=: winEnddate and (not Inflight_Quote__c like '%Renew%') 
                           and Renewal_status__c = 'Do not Renew' and Renewal_Type__c =:winbackrenewtypeam and Account.owner.userrole.name NOT IN:winbackrolenames]){
                               setAccountIds.add(ast.AccountId);
                           }
            if(setAccountIds.size() > 0){
                winbackprocessupdateBatch wnbup= new winbackprocessupdateBatch(setAccountIds);
                database.executebatch(wnbup);
            }
        }
        
        if (Pendingorderprocess) {
            //CRM-4560 Duplicate subscriptions
            Integer remainder = math.mod(numbtypemin, 4);
            if ((numbtypemin < 40 && remainder == 0 && runNextprocess) || Test.isRunningTest()) {
                
                // CRM-1212 Start - Processing orders which could not be processed from trigger due to Scheduled Apex Job limitations.
                List < Order > ordersToUpdate = new List < Order > ();
                for (Order order: [SELECT id, AccountId, all_order_products_count__c FROM Order WHERE Run_OrderDecomp__c = true AND Fulfillment_Status__c = 'Fulfilled'
                                   LIMIT 1
                                  ]) {
                                      
                                      if (order.all_order_products_count__c > 0 || Test.isRunningTest()) {
                                          Integer jcount = [SELECT COUNT() FROM CronTrigger WHERE CronJobDetail.JobType = '7'];
                                          runNextprocess = false;
                                          if ((jcount <= 85) && (!Test.isRunningTest())){
                                              OrderDecompController controller = new OrderDecompController(order);
                                              SkipOrderTrigger.setSkipTrgTrue();
                                              order.Run_OrderDecomp__c = false;
                                              ordersToUpdate.add(order);
                                          } else {
                                              System.debug('Skipping this order due to limitation on apex schedule job, will be processed later - ' + jcount + '  ' + order.id);
                                              //order.Run_OrderDecomp__c = true;
                                          }
                                      }
                                  }
                
                if (ordersToUpdate.size() > 0) {
                    update ordersToUpdate;
                }
                // CRM-1212 End
            }
        }
        if (PendingFSassetprocess) {
            if (runNextprocess || Test.isRunningTest()) {
                
                // CRM-1860 - Commented below code
                List < Lead > leadlist = new List < Lead > ();  // CRM-5917 - Un-Commented
                
                List < Asset > FiveStreetExpire = new List < Asset > ();
                List < Asset > CBCAssete = new List < Asset > ();
                List < Asset > lstAssete = [Select Id, Name, FiveStreet_Expire_Date__c, AccountId, Fulfillment_Status__c, Status, Line_Type__c, Asset_Type__c from Asset where product_code__c = 'COBROKE'
                                            and(Status = 'Expired') and Asset_Type__c = 'Parent'
                                            and End_Date__c = Yesterday and FiveStreet_Expire_Date__c = null order by End_Date__c Desc
                                           ];
                List < Asset > lstAsset1e = [Select Id, Name, FiveStreet_Expire_Date__c, AccountId, Fulfillment_Status__c, Status, Line_Type__c, Asset_Type__c from Asset where product_code__c = 'COBROKE'
                                             and(Status = 'Cancelled') and Asset_Type__c = 'Parent'
                                             and Cancellation_Date__c = Today and FiveStreet_Expire_Date__c = null order by End_Date__c Desc
                                            ];
                List < Asset > lstAssetfivee = [Select Id, Name, FiveStreet_Expire_Date__c, AccountId, Fulfillment_Status__c, Status, Line_Type__c, Asset_Type__c from Asset where product_code__c = 'FiveStreet'
                                                and(Status != 'Cancelled'
                                                    AND Status != 'Expired') and Asset_Type__c = 'Parent'
                                                and FiveStreet_Expire_Date__c = YESTERDAY order by End_Date__c Desc
                                               ];
                set < Id > AccountIds = new set < Id > ();
                set < Id > CBCAccountIds = new set < Id > ();
                set < Id > FiveStreetAccountIds = new set < Id > ();
                for (Asset ast: lstAssete) {
                    AccountIds.add(ast.AccountId);
                }
                for (Asset ast: lstAsset1e) {
                    AccountIds.add(ast.AccountId);
                }
                if (AccountIds.size() > 0) {
                    date dt = system.today();
                    CBCAssete = [Select Id, Name, FiveStreet_Expire_Date__c, AccountId from Asset where product_code__c = 'COBROKE'
                                 AND Asset_Type__c = 'Parent'
                                 and AccountId IN: AccountIds and Status != 'Expired'
                                 AND Status != 'Cancelled'
                                 AND Status != 'Converted'
                                 and End_Date__c >= : dt
                                ];
                    for (Asset asst: CBCAssete) {
                        CBCAccountIds.add(asst.AccountId);
                    }
                }
                AccountIds.removeall(CBCAccountIds);
                System.debug(AccountIds + ' ---Total Ids---');
                if (AccountIds.size() > 0 || Test.isRunningTest()) {
                    date dt = system.today().AddDays(8);
                    FiveStreetExpire = [Select Account.Create_Five_Street_Lead__c, Id, Name, End_Date__c, FiveStreet_Expire_Date__c, AccountId, Account.name, Product2.Renewal_Term_Type__c, Renewal_Status__c, Delta_Price_w_o_Tax__c, Amend_Delta_Price__c, Fulfillment_Status__c, Status, Line_Type__c, Asset_Type__c from Asset
                                        where Status != 'Expired'
                                        and product_code__c = 'FiveStreet'
                                        AND Status != 'Cancelled'
                                        AND Status != 'Converted'
                                        and Asset_Type__c = 'Parent'
                                        and Extended_Net_Price__c < 0.01 and AccountId = : AccountIds and End_Date__c > : dt and FiveStreet_Expire_Date__c = null AND Promotion__c IN :Label.Five_Street_Expiration_Promotions.split(',') limit 2
                                       ];     // CRM-5917 check on Promotion__c
                }
                /*  CRM-5917 - Commented below SOQL
Group grp = [SELECT Id, Name, DeveloperName FROM Group where Type = 'Queue'
and Name = 'Sales - HYBRID INBOUND TEAM'
limit 1
];*/
                if (FiveStreetExpire.size() > 0) {
                    set < Id > FivestrAcc = new set < Id > ();
                    for (Asset ast: FiveStreetExpire) {
                        if (ast.Product2.Renewal_Term_Type__c != 'evergreen' || (ast.Product2.Renewal_Term_Type__c == 'evergreen' && ast.Renewal_Status__c == 'Do Not Renew')) {
                            ast.FiveStreet_Expire_Date__c = system.today().addDays(Integer.valueOf(Label.Five_Street_Expiration_Days));  //CRM-5917 - Changed days to Label
                            FivestrAcc.add(ast.AccountId);
                        }
                        
                        // CRM-1860 - Commented below code
                        // CRM-5917 - Un-Commented below code and added check on Account's field Create_Five_Street_Lead__c
                        if (ast.Account.Create_Five_Street_Lead__c) {
                            Lead led = New Lead();
                            led.Account__c = ast.AccountId;
                            //led.Five_Street_Asset_Expiration_Date__c = system.today().addDays(7);
                            led.Five_Street_Asset_Expiration_Date__c = ast.FiveStreet_Expire_Date__c;    // CRM-5917
                            led.status = 'New';
                            led.Company = ast.name;
                            led.LastName = ast.Account.name;
                            led.Marketing_Lead_Type__c = 'Five Street Conversion';
                            //led.Ownerid = grp.id;   // CRM-5917 - Commented owner assignment
                            // CRM-1432 :- Setting Ignore Owner Assignment to Yes
                            if (IgnoreFSowner) {
                                led.Ignore_Owner_Assignment__c = 'Yes';
                            }
                            // CRM-1432
                            leadlist.add(led);
                        }
                    }
                    if (FiveStreetExpire.size() > 0) {
                        SkipAssetTrigger.setSkipTrgTrue();
                        update FiveStreetExpire;
                    }
                    // CRM-1860 - Commented below code
                    // CRM-5917 - Un-Commented below code
                    if (leadlist.size() > 0) {
                        Database.DMLOptions dmo = new Database.DMLOptions();
                        dmo.assignmentRuleHeader.useDefaultRule = true;
                        Database.Insert(leadlist, dmo);
                        //upsert leadlist;
                    }
                    
                    Set < id > setconIds = new set < Id > ();
                    if (!FivestrAcc.isEmpty()) {
                        string RecordTypId = [SELECT id from RecordType where Name = 'Contact Relationship'].Id;
                        List < Account_Relationship__c > arList = new List < Account_Relationship__c > ([Select Id, Contact_To__c from Account_Relationship__c
                                                                                                         where Is_Parent_Primary__c = true and Active__c = true and RecordTypeId = : RecordTypId
                                                                                                         and(Billing_Contact__c = true or Contact_Role__c = 'Primary Contact') AND Parent_Account__c IN: FivestrAcc
                                                                                                        ]);
                        for (Account_Relationship__c ar: arList) {
                            setconIds.add(ar.Contact_To__c);
                        }
                        List < Contact > conList = new List < Contact > ([Select Id, Email from Contact where Id IN: setconIds]);
                        EmailTemplate Emailtemplate = [SELECT Id, Name FROM EmailTemplate where name = : 'Complimentary FiveStreet Expiring'
                                                       limit 1
                                                      ];
                        System.debug('Emailtemplate:' + Emailtemplate);
                        System.debug('conList:' + conList);
                        List < Messaging.SingleEmailMessage > listESSEmails = new List < Messaging.SingleEmailMessage > ();
                        for (Contact con: conList) {
                            System.debug('con:' + con);
                            Messaging.SingleEmailMessage essEmail = new Messaging.SingleEmailMessage();
                            essEmail.setTargetObjectId(con.Id);
                            essEmail.setTemplateId(Emailtemplate.id);
                            listESSEmails.add(essEmail);
                        }
                        Messaging.SendEmailResult[] res = Messaging.sendEmail(listESSEmails);
                    }
                }
                
                if (FiveStreetExpire.size() < 1) {
                    Set < Id > setFiveAccountids = new Set < Id > ();
                    for (Asset ast: lstAssetfivee) {
                        setFiveAccountids.add(ast.AccountId);
                    }
                    date dt = system.today();
                    Set < Id > FiveCBCAccountIds = new Set < Id > ();
                    List < Asset > FiveCBCAssete = [Select Id, Name, FiveStreet_Expire_Date__c, AccountId from Asset where product_code__c = 'COBROKE'
                                                    AND Asset_Type__c = 'Parent'
                                                    and AccountId IN: setFiveAccountids and Status != 'Expired'
                                                    AND Status != 'Cancelled'
                                                    AND Status != 'Converted'
                                                    and End_Date__c >= : dt
                                                   ];
                    for (Asset asst: FiveCBCAssete) {
                        FiveCBCAccountIds.add(asst.AccountId);
                    }
                    setFiveAccountids.removeall(FiveCBCAccountIds);
                    
                    List < Asset > lstAssetfiveSetExpire = [Select Extended_Net_Price__c, Id, Name, FiveStreet_Expire_Date__c, End_Date__c, AccountId, Fulfillment_Status__c, Status, Line_Type__c, Asset_Type__c from Asset where AccountId = : setFiveAccountids and product_code__c = 'FiveStreet'
                                                            and(Status != 'Cancelled'
                                                                AND Status != 'Expired') and Asset_Type__c = 'Parent'
                                                            and FiveStreet_Expire_Date__c = YESTERDAY order by End_Date__c Desc
                                                           ];
                    for (Asset ast: lstAssetfiveSetExpire) {
                        if (ast.Extended_Net_Price__c<0.01) {     // CRM-5917 
                            ast.End_Date__C = system.today().AddDays(-1);
                        }
                        ast.FiveStreet_Expire_Date__c = null;
                    }
                    // CRM-5917 - Clear FiveStreet_Expire_Date__c if account owns CBC
                    if (!FiveCBCAccountIds.isEmpty()) {
                        for (Asset fiveStreetAsset : [Select FiveStreet_Expire_Date__c from Asset where AccountId = : FiveCBCAccountIds and product_code__c = 'FiveStreet' AND (Status != 'Cancelled' AND Status != 'Expired') AND Asset_Type__c = 'Parent' AND FiveStreet_Expire_Date__c != null]) {
                            fiveStreetAsset.FiveStreet_Expire_Date__c = null;
                            lstAssetfiveSetExpire.add(fiveStreetAsset);
                        }
                    }
                    // CRM-5917 - End
                    update lstAssetfiveSetExpire;
                }
            }
            //Re-Scheduling JOB
            List < CronTrigger > listCronTriggerAsset = [select Id from CronTrigger where CronJobDetail.Name LIKE 'ExpireFiveStreetAssetschedule'
                                                         and State = 'DELETED'
                                                         and
                                                         nextfiretime = null limit 10
                                                        ];
            If(listCronTriggerAsset.size() > 0) {
                system.debug('Job Loop 1 :');
                For(Integer i = 0; i < listCronTriggerAsset.size(); i++) {
                    system.debug('Job Loop 2 :');
                    System.abortJob(listCronTriggerAsset[i].Id);
                }
            }
            Integer rcount = [SELECT count() FROM CronJobDetail WHERE Name LIKE 'ExpireFiveStreetAssetschedule'];
            system.debug('rcount : ' + rcount);
            if (rcount < 2) {
                system.debug('Job Execution Loop 1 :');
                ExpireFiveStreetAssetschedule p = new ExpireFiveStreetAssetschedule();
                Datetime dtt = System.now().addMinutes(1);
                String sch = dtt.Second() + ' ' + dtt.Minute() + ' ' + dtt.hour() + ' ' + dtt.day() + ' ' + dtt.Month() + ' ? ' + dtt.year();
                system.schedule('ExpireFiveStreetAssetschedule' + dtt, sch, p);
                
                List < CronTrigger > listCronTrigger = [select Id from CronTrigger where State = 'DELETED'
                                                        and nextfiretime = null limit 20
                                                       ];
                system.debug('listCronTrigger : ' + listCronTrigger.size());
                If(listCronTrigger.size() > 0) {
                    system.debug('Job Execution Loop 2 :');
                    For(Integer i = 0; i < listCronTrigger.size(); i++) {
                        system.debug('Job Execution Loop 3 :');
                        System.abortJob(listCronTrigger[i].Id);
                    }
                }
                listCronTrigger.clear();
            }
            listCronTriggerAsset.clear();
        }
        If(PendingInvoiceprocess) {
            // CRM-1294 Start - call invoice trigger if it couldn't executed when invoice was last updated.
            if (runNextprocess || Test.isRunningTest()) {
                Schedule_Batch_Setting__c invoiceProcess = Schedule_Batch_Setting__c.getValues('Invoice Paid');
                if (invoiceProcess != null && invoiceProcess.Is_Running__c) {
                    List < Zuora__ZInvoice__c > invoices = [SELECT Id, Invoice_Status__c, Zuora__Balance2__c FROM Zuora__ZInvoice__c WHERE Invoice_Status__c = 'Past Due'
                                                            and Zuora__Balance2__c <= 0 AND Zuora__Status__c = 'Posted'
                                                            AND SystemModstamp < : Datetime.now().addMinutes(-5) LIMIT 1
                                                           ];
                    if (invoices.size() > 0) {
                        runNextprocess = false;
                        update invoices;
                    }
                }
            }
            // CRM-1294 End
        } 
        // CRM-1787 - To update Private Contacts
        If(PendingContactProcess) {
            if ([SELECT Id FROM Contact WHERE AccountId = '' AND ID IN (SELECT Contact_To__c FROM Account_Relationship__c WHERE Parent_Account__c != '') AND Owner.IsActive=true LIMIT 1].size() > 0) {
                Database.executeBatch(new UpdatePrivateContactsAccountBatch(), 100);
            }
            
        }
        
        // CRM-1787 - end 
        // Rescheduling Zuora parent Job incase terminated.
        Set<integer> minutesToExecute = new Set<Integer>{20,40,59};
            if(minutesToExecute.contains(numbtypemin) || test.isRunningTest()){
                ZuoraSchedulesJobSetting__c Zsettings = ZuoraSchedulesJobSetting__c.getInstance('Z_ZuoraJobsSchedular');
                System.debug('Zsettings '+ Zsettings);
                if(Zsettings!= null && Zsettings.Last_execution__c != null && Zsettings.Last_execution__c < System.now().addminutes(-20)&&Zsettings.Is_Running__c){
                    List < CronTrigger > listCronTriggerZuora = [select Id from CronTrigger where CronJobDetail.Name LIKE 'Z_ZuoraJobsSchedular'
                                                                 and State = 'DELETED'
                                                                 and nextfiretime = null limit 10];
                    If(listCronTriggerZuora.size() > 0) {            
                        for(Integer i = 0; i < listCronTriggerZuora.size(); i++) {                    
                            System.abortJob(listCronTriggerZuora[i].Id);
                        }
                    }
                    Datetime dtime = System.now().addminutes(1);
                    String tt = dtime.Second() + ' ' + dtime.Minute() + ' ' + dtime.hour() + ' ' + dtime.day() + ' ' + dtime.Month() + ' ? ' + dtime.year();               
                    System.schedule('Z_ZuoraJobsSchedular-'+ dtime, tt, new Z_ZuoraJobsSchedular());  
                    
                }
            }
    }
    /*@testvisible private void sendErrornotificationEmail() {
        String theEmailAddresses = Error_Notification_Email_Settings__c.getInstance('Lead Score Calculation').Asset_Creation_Error_Emails__c;
        if (theEmailAddresses != null && theEmailAddresses != '') {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(theEmailAddresses.split(';'));
            mail.setSenderDisplayName(UserInfo.getName());
            mail.setSubject('Lead Score Calculation reached batch size 1 ');
            String messageBody = 'It reached to batch size 1 because we have more than 50 errors occured in the past 30 minuites. <br/>' ;
            messageBody += 'Please verify the errors and re-run the job.';
            mail.setHtmlBody(messageBody); 
            system.debug(mail );
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
        }
    } */
}