global class scheduledSalesLockTCVWaitlistExpire implements Schedulable {
    global void execute(SchedulableContext sc) {
        // Implement any logic to be scheduled
        //CRM-1594 :- Configuration variables starts
        Boolean userprocess = true;
        Integer userExecutionStartTimehr = 5;
        Integer userExecutionEndTimehr = 6;
        Integer userExecutionTimemin = 40;
        Boolean waitlistexpireprocess = true;
        Integer waitlistexpireExecutionStartTimehr = 2;
        Integer waitlistexpireExecutionEndTimehr = 3;
        Integer waitlistexpireExecutionTimemin = 20;
        Boolean ZouraAccountBalanceprocess = true;
        Integer ZouraAccountBalanceExecutionStartTimehr = 0;
        Integer ZouraAccountBalanceExecutionEndTimehr = 1;
        Integer ZouraAccountBalanceExecutionTimemin = 20;
        Boolean TCVprocess = true;
        Integer TCVExecutionStartTimehr = 5;
        Integer TCVExecutionEndTimehr = 6;
        Integer TCVExecutionTimemin = 40;
        Boolean opcityrenewalsprocess = true;
        Integer opcityrenewalsExeStartTimehr = 9;
        Integer opcityrenewalsExeEndTimehr = 11;
        Integer opcityrenewalsExeTimemin = 20;
        Integer lcmProcessExeTimehr = 11;
        Integer lcmProcessExeTimemin = 11;
        Integer lcmProcessExeTimehr2 = 22; //LCM-260
        Schedule_Batch_Setting__c userp = Schedule_Batch_Setting__c.getValues('User process');
        Schedule_Batch_Setting__c waitlistp = Schedule_Batch_Setting__c.getValues('Waitlist Expire Process');
        Schedule_Batch_Setting__c tcvp = Schedule_Batch_Setting__c.getValues('TCV Process');
        Schedule_Batch_Setting__c zacbp = Schedule_Batch_Setting__c.getValues('Zoura Process');
        Schedule_Batch_Setting__c aysncJobp = Schedule_Batch_Setting__c.getValues('Monitor Async Apex Job');
        Schedule_Batch_Setting__c inventoryJobp = Schedule_Batch_Setting__c.getValues('Inventory Error Process Job');
        Schedule_Batch_Setting__c cfbRSJobp = Schedule_Batch_Setting__c.getValues('CFB RS Job');
        Schedule_Batch_Setting__c opcityrenewals = Schedule_Batch_Setting__c.getValues('OpcityAssetRenewalProcess');
        Schedule_Batch_Setting__c opcityofficeRollup = Schedule_Batch_Setting__c.getValues('OpcityScoreRollUp');
        Schedule_Batch_Setting__c batchLeadPreleadCreation = Schedule_Batch_Setting__c.getValues('PreLeadBatchProcess');
        Schedule_Batch_Setting__c lcmNotifications = Schedule_Batch_Setting__c.getValues('LCM Cancel Notification');
       // Schedule_Batch_Setting__c lcmDataValidation = Schedule_Batch_Setting__c.getValues('LCM Data Validation'); //LCM-260
        
        set<string> incomplteStatuses = new set<string>{'Queued', 'Preparing', 'Processing', 'Holding'};
        Boolean InvJobp = true;
        Boolean CFBRSjob = true;
        Boolean caseprocess = true;
        Boolean lcmProcess = true;
        Boolean runBatchProcessOfficeJob = true;
        
       // Boolean lcmProcess2 = true; //LCM-260
        Boolean Jsaassetprocess = true;
        Integer CFBMinutecount = 240;
        Integer caseExecutionStartTimehr = 5;
        Integer caseExecutionEndTimehr = 6;
        Integer caseExecutionTimemin = 45;
        Date JSendDate = System.today().AddDays(Integer.valueOf(Label.end_date_days));
        Set<String> thepartyid = new Set<String>();
        if(System.Label.Jasonpartyid!=null){
            thepartyid.addAll(System.Label.Jasonpartyid.split(','));
        }
        Schedule_Batch_Setting__c casep = Schedule_Batch_Setting__c.getValues('Case Process');
        //Added by Pratik on 4th October 2018 for CRM-4871
        if(DateTime.now().hour() == 1)
        {
            BatchCaseUpdate newBatchCaseUpdate = new BatchCaseUpdate('Select Id From Case Where Status = \'Pending Cancel\' AND Pending_Cancellation_Date__c = YESTERDAY');
            Database.executeBatch(newBatchCaseUpdate);
        }
        //Ends here
        
        //Added by Pratik on 6th February 2019
      /*  if(DateTime.now().hour() == 4)
        {
            String cmQuery = 'Select Id, Email, Contact_Method__c, Contact_Method__r.Email__c, Contact_Method__r.Contact__c From Lead Where Last_Interaction_Date__c = YESTERDAY AND Contact_Method__c != Null ';
            ContactMethodCreationBatch newContactMethodCreationBatch = new ContactMethodCreationBatch(cmQuery);
            Database.executeBatch(newContactMethodCreationBatch);
        }
        */
        //Ends here
        
        Integer jcount = [Select count() from AsyncApexJob WHERE Status = 'Holding'];
        //Added by Pratik on 8th August 2018 for CRM-4542
        Schedule_Batch_Setting__c quotepurge = Schedule_Batch_Setting__c.getInstance('Quote Purge');
        
        if(quotepurge.Is_Running__c)
        {
            List<BigMachines__Quote__c> lstQuote = [Select Id From BigMachines__Quote__c 
                                                    Where NotEligibleForBundling__c = TRUE 
                                                    AND CreatedDate <= YESTERDAY];
            
            if(!lstQuote.isEmpty())
            {
                //delete lstQuote;
                QuotePurgeBatch quotePurgeBatch = new QuotePurgeBatch();
                Database.executeBatch(quotePurgeBatch);
            }
        }
        //ends here
        
        Boolean runLeadCreationBatch = true;
        Integer runLeadCreationBatchSize = 30;
         if (batchLeadPreleadCreation != null) {
            runLeadCreationBatch = batchLeadPreleadCreation.Is_Running__c;
            runLeadCreationBatchSize = Integer.valueof(batchLeadPreleadCreation.Execution_Min__c);
            
        }
        Integer minNumber = System.now().Minute();
        if(minNumber==0){minNumber=3;}
        if(runLeadCreationBatch  && (math.mod(System.now().Minute(), 3)==0)  || Test.isRunningTest()){
        //Added by Pratik on 16th January 2019 for SFMC Lead Processes
        Set<String> setBatchApexClass = new Set<String> {'BatchLeadCreation','ContactMethodCreationBatch'};
        Set<String> setRunningApexJobClass = new Set<String>(); 
        
        for(AsyncApexJob incompleteBatchJob : [SELECT ApexClass.Name 
                                                    FROM AsyncApexJob 
                                                    WHERE JobType = 'BatchApex' 
                                                    AND Status IN :incomplteStatuses
                                                    AND ApexClass.Name IN :setBatchApexClass 
                                                    ])
                                                {
                                                    setRunningApexJobClass.add(incompleteBatchJob.ApexClass.Name);
                                                }
        
        if(!setRunningApexJobClass.contains('BatchLeadCreation'))
        {
            string strQuery = 'Select Id, AccountId__c,Account__c, First_Name__c, Last_Name__c, Business_Unit__c, Campaign__c, Contact__c, Lead__c, Email__c, Hot_Lead__c, Contact_Method_Id__c,Ignore_Owner_Assignment__c, Lead_Origin__c, Lead_Owner__c, Company__c, Error_Description__c,Lead_Source__c, Phone__c, Product_Type__c, Record_Processed__c,Record_Type_Id__c ,Campaign_Name__c,Referring_Agent_PartyId__c,Referring_Agent_Email__c,Referring_Agent_Name__c,Referring_Agent_Phone__c From Pre_Lead__c Where Record_Processed__c = False';
            BatchLeadCreation batchLeadCreation = new BatchLeadCreation(strQuery);
            Database.executeBatch(batchLeadCreation, runLeadCreationBatchSize);
        }
        
        if(!setRunningApexJobClass.contains('ContactMethodCreationBatch'))
        {
             if(DateTime.now().hour() == 4 || Test.isRunningTest()){
            String cmQuery = 'Select Id, Email, Contact_Method__c, Contact_Method__r.Email__c, Contact_Method__r.Contact__c,Contact_Method__r.Contact__r.FirstName,Contact_Method__r.Contact__r.LastName From Lead Where Last_Interaction_Date__c = YESTERDAY AND Contact_Method__c != Null';
            ContactMethodCreationBatch newContactMethodCreationBatch = new ContactMethodCreationBatch(cmQuery);
            Database.executeBatch(newContactMethodCreationBatch,100);
            }
        }
        
        }
        //Ends Here
        
        //Added by Pratik on 10th August 2018 for CRM-4542
        if((Date.today() == Date.today().toStartOfWeek() && Datetime.now().hour() > 4) || Test.isRunningTest())
        {
            set<string> setBatchApexClassNames = new set<string>{'BatchProcessMLSAccountRealSuite'};
            Map<string,string> mapRunningApexJobClassNames = new Map<string,string>(); 
                
            Datetime myDateTime = Datetime.now();
            Datetime targetDate = Datetime.now().adddays(-7);
            
            for(AsyncApexJob  incompleteBatchJob : [SELECT ApexClass.Name ,TotalJobItems
                                                    FROM AsyncApexJob 
                                                    WHERE JobType = 'BatchApex' 
                                                    //AND Status IN :incomplteStatuses
                                                    AND ApexClass.Name IN :setBatchApexClassNames 
                                                    //AND CreatedDate >=:myDateTime
                                                    AND CreatedDate >=:targetDate]){
                                                        mapRunningApexJobClassNames.put(incompleteBatchJob.ApexClass.Name,incompleteBatchJob.ApexClass.Name);
                                                    }

            if(!mapRunningApexJobClassNames.containsKey('BatchProcessMLSAccountRealSuite'))
            {
                BatchProcessMLSAccountRealSuite batchProcessMLSAccount = new BatchProcessMLSAccountRealSuite();
                Database.executeBatch(batchProcessMLSAccount,1);
            }
        }
        //ends here
        
        if (userp != null) {
            userprocess = userp.Is_Running__c;
            userExecutionStartTimehr = Integer.valueof(userp.Execution_Time_hr__c);
            userExecutionEndTimehr = Integer.valueof(userp.Execution_End_Time_Hr__c);
            userExecutionTimemin = Integer.valueof(userp.Execution_Min__c);
        }
        if (waitlistp != null) {
            waitlistexpireprocess = waitlistp.Is_Running__c;
            waitlistexpireExecutionStartTimehr = Integer.valueof(waitlistp.Execution_Time_hr__c);
            waitlistexpireExecutionEndTimehr = Integer.valueof(waitlistp.Execution_End_Time_Hr__c);
            waitlistexpireExecutionTimemin = Integer.valueof(waitlistp.Execution_Min__c);
        }
        if (casep != null) {
            Caseprocess = casep.Is_Running__c;
        }
        if(opcityofficeRollup!=null){
        runBatchProcessOfficeJob = opcityofficeRollup.Is_Running__c;
        }
        if(lcmNotifications != null){
            lcmProcess = lcmNotifications.Is_Running__c;
            lcmProcessExeTimehr = Integer.valueof(lcmNotifications.Execution_Time_hr__c);
            lcmProcessExeTimemin = Integer.valueof(lcmNotifications.Execution_Min__c);
        }
        //LCM-260
       /* if(lcmDataValidation != null){
            lcmProcess2 = lcmDataValidation.Is_Running__c;
            lcmProcessExeTimehr2 = Integer.valueof(lcmDataValidation.Execution_Time_hr__c);
        }  */
        if (tcvp != null) {
            TCVprocess = tcvp.Is_Running__c;
        }
        if (inventoryJobp != null) {
            InvJobp = inventoryJobp.Is_Running__c;
        }
        if (cfbRSJobp != null) {
            CFBRSjob = cfbRSJobp.Is_Running__c;
            if(cfbRSJobp.Execution_Min__c!=null){
            CFBMinutecount = Integer.valueof(cfbRSJobp.Execution_Min__c);
            }
        }
        if (zacbp != null) {
            ZouraAccountBalanceprocess = zacbp.Is_Running__c;
            ZouraAccountBalanceExecutionStartTimehr = Integer.valueof(zacbp.Execution_Time_hr__c);
            ZouraAccountBalanceExecutionEndTimehr = Integer.valueof(zacbp.Execution_End_Time_Hr__c);
            ZouraAccountBalanceExecutionTimemin = Integer.valueof(zacbp.Execution_Min__c);
        }
        if (opcityrenewals != null) {
           opcityrenewalsprocess = opcityrenewals.Is_Running__c;
           opcityrenewalsExeStartTimehr = Integer.valueof(opcityrenewals.Execution_Time_hr__c);
           opcityrenewalsExeEndTimehr = Integer.valueof(opcityrenewals.Execution_End_Time_Hr__c);
           opcityrenewalsExeTimemin = Integer.valueof(opcityrenewals.Execution_Min__c);
        }
        
        //CRM-1594 :- Configuration variables end
        
        // We now call the batch class to be scheduled
        try {
            Integer numbtype = System.now().Minute();
            Integer numbtypehour = System.now().Hour();
            Integer numbtypeDay = System.now().Day();
            Date DateA = System.today(); 
            date DateB = DateA.toStartofWeek();
            Integer numbtypeWeekDay =DateB.daysBetween(DateA);
            
            DateTime dt = System.now();
            Date myDate = date.newinstance(dT.year(), dT.month(), (dT.day()));
            
            if (zacbp != null && zacbp.Last_Execution__c!=null) {
                DateTime dtZoura = zacbp.Last_Execution__c;
                myDate = date.newinstance(dtZoura.year(), dtZoura.month(), (dtZoura.day()));
            }
            
            List < Account > lstAccount = [SELECT Account_Sub_Type__c, Lock_Expiration_Date__c, Sales_Lock_User__c FROM Account WHERE Sales_lock_Date__c <= : dt limit 25];
            
            //Updated by Pratik on 27th July 2018 for CRM-4375
            Schedule_Batch_Setting__c NVMNextContTime = Schedule_Batch_Setting__c.getValues('NVM Next Contact Time');
            Integer MinTime = 60;
            Integer minutes = 5;
            
            if(NVMNextContTime != Null)
            {
                MinTime = Integer.valueof(NVMNextContTime.Execution_Min__c);
                
                if(NVMNextContTime.Assetresttime__c > 0)
                    minutes = Integer.valueof(NVMNextContTime.Assetresttime__c);
            }
            DateTime currentDateTime = System.now();
            DateTime nowVal = currentDateTime.AddMinutes(-MinTime);
            DateTime newDateTime = currentDateTime.AddMonths(6);
            DateTime nowValNew = currentDateTime.AddMinutes(-minutes);
            List<Lead> lstLead = [SELECT NVMConnect__NextContactTime__c,Id FROM Lead WHERE ( NVM_Callback_DateTime__c <:nowValNew) OR (LastModifiedDate <=:nowVal AND NVMConnect__NextContactTime__c >:newDateTime)  order by LastModifiedDate ASC limit 25];
            //if((numbtype<10 && lstLead.size()>0 ) || (numbtype<20 && lstLead.size()>0)){
            if(lstLead.size() > 0)
            {  
                BatchProcessLead b = new BatchProcessLead();
                database.executebatch(b, 25);
            }
            //Ends here
            //Updated by Pratik on 24th September 2018 for CRM-4814
            List<Case> lstCase = [SELECT NVMConnect__NextContactTime__c, Id FROM Case WHERE ( Callback_Date__c <:nowValNew) OR (LastModifiedDate <=:nowVal AND NVMConnect__NextContactTime__c >:newDateTime)  Order By LastModifiedDate ASC limit 25];
            if(lstCase.size() > 0)
            {  
                BatchProcessCase batchCase = new BatchProcessCase();
                database.executebatch(batchCase, 25);
            }
            //Ends here
            // CRM-4973 -Start-Salesforce change for opcity assets renewals.
 if (opcityrenewalsprocess && (numbtypehour >= opcityrenewalsExeStartTimehr) && (numbtypehour < opcityrenewalsExeEndTimehr) && (numbtype > opcityrenewalsExeTimemin)) {           
            set<ID> AsstIDs = New set<ID>();
            For(Asset Asstdata:[select Id,AccountId,Asset_Type__c,Start_Date__c,End_Date__c,Line_Type__c,Order_Line_Item__c,Renewal_Start_Date__c,
                                Extended_List__c,Total_Net__c,Total_List_Price__c,Extended_Net_Price__c,Fulfillment_status__c from Asset where 
                                Fulfillment_status__c = 'Fulfilled' and 
                                Status = 'Active' and 
                                Asset_Type__c = 'Parent' and  
                                Renewal_Status__c != 'Do Not Renew' and 
                                Follow_Up_Status__c != 'Will Not Renew' and 
                                End_Date__c <: JSendDate and 
                                Account.Party_ID__c =: thepartyid limit 25]){
                                    AsstIDs.add(Asstdata.Id);  
                                } 
            if(AsstIDs.size() > 0){
                OpcityAssetRenewalupdateBatch JSUpd= new OpcityAssetRenewalupdateBatch(AsstIDs);
                database.executebatch(JSUpd);
            } 
 }

            //CRM-4973 - End-Salesforce change for opcity assets renewals
            //CRM-2121
            if(Caseprocess && numbtypeWeekDay==7 && (numbtypehour>11 && numbtypehour<12)){
                Caseupdate caseUpd= new Caseupdate();
                database.executebatch(caseUpd, 25);
            } 
            //LCM-67 LCM-264: added exe mins
            if(lcmProcess && numbtypehour == lcmProcessExeTimehr && numbtype < lcmProcessExeTimemin){
                LCMCancelNotificationJob lcmJob = new LCMCancelNotificationJob();
                database.executebatch(lcmJob, 10);
               
            }
            //LCM-260
         /*   if((lcmProcess2 && numbtypehour == lcmProcessExeTimehr2)|| test.isRunningTest()){
                LCM_ValidateData_batch lcmJob2 = new LCM_ValidateData_batch();
                database.executebatch(lcmJob2,10);
            } */
            //CRM-1594
            if ((userprocess) && (numbtypehour >= userExecutionStartTimehr && numbtypehour < userExecutionEndTimehr && numbtype > userExecutionTimemin)) {
                BatchProcessUserSalesLockEligibility b = new BatchProcessUserSalesLockEligibility();
                database.executebatch(b);
                
            } //CRM-1594
            else if ((waitlistexpireprocess) && (numbtypehour >= waitlistexpireExecutionStartTimehr) && (numbtypehour < waitlistexpireExecutionEndTimehr) && (numbtype > waitlistexpireExecutionTimemin)) {
                WaitlistExpireBatch WLBatch = new WaitlistExpireBatch();
                database.executebatch(WLBatch, 1);
                
            }  else {
                if (lstAccount.size() > 0) {
                    BatchProcessAccount b = new BatchProcessAccount();
                    database.executebatch(b, 25);
                    /*Commented by Pratik for CRM-4375 on 27th July 2018
BatchProcessLead bp = new BatchProcessLead();
database.executebatch(bp, 25);
*/
                } else {
                    //Commented by Pratik on 27th July 2018 for CRM-4375
                    // else - ends here
                    if (TCVprocess) {
                        UpdateTCVCustomerTypeBatchable b = new UpdateTCVCustomerTypeBatchable();
                        database.executebatch(b, 25);
                    }
                }
            }
            Integer rcount = [SELECT count() FROM CronJobDetail WHERE Name LIKE 'SalesLockTCVA1A%'];
            if (rcount < 2  || Test.isRunningTest()) {
                scheduledSalesLockTCVWaitlistExpire p = new scheduledSalesLockTCVWaitlistExpire();
                Datetime dtt = System.now().addMinutes(1).addSeconds(15);
                String sch = dtt.Second() + ' ' + dtt.Minute() + ' ' + dtt.hour() + ' ' + dtt.day() + ' ' + dtt.Month() + ' ? ' + dtt.year();
                system.schedule('SalesLockTCVA1A' + dtt, sch, p);
                
                List < CronTrigger > listCronTrigger = [select Id from CronTrigger where State = 'DELETED'
                                                        and nextfiretime = null limit 20
                                                       ];
                If(listCronTrigger.size() > 0) {
                    For(Integer i = 0; i < listCronTrigger.size(); i++) {
                        System.abortJob(listCronTrigger[i].Id);
                    }
                }
            }
            System.debug('Working now');
            //CRM-3199
            if((numbtype>0 && numbtype<60) && (math.mod(numbtypehour, 2)==0)  || Test.isRunningTest()){
                List<Account> lstAccountAcc =[SELECT Id,NextContactTime__c FROM Account WHERE NextContactTime__c > 2020-12-30T15:22:00.000Z limit 10];
                for(Account  Acc:lstAccountAcc){
                    Acc.NextContactTime__c = null;
                }
                if(lstAccountAcc.size()>0){
                    update lstAccountAcc;
                }
            }
            
             set<string> incomplteStatuses2 = new set<string>{'Queued', 'Preparing', 'Processing', 'Holding'};
                    set<string> batchApexClassNames2 = new set<string>{'BatchProcessOpportunityDialList','BatchProcessOfficeScore','BatchProcessFailedInventory','BatchZouraAccountBalance'};
                        
                        Map<string,string> runningApexJobClassNames2 = new Map<string,string>();
                DateTime twoHrsEarlier = Datetime.now().addHours(-2);
                for(AsyncApexJob  incompleteBatchJob : [SELECT ApexClass.Name 
                                                        FROM AsyncApexJob 
                                                        WHERE JobType = 'BatchApex' 
                                                        AND Status IN :incomplteStatuses2
                                                        AND ApexClass.Name IN :batchApexClassNames2
                                                        AND CreatedDate >= :twoHrsEarlier]){
                                                            runningApexJobClassNames2.put(incompleteBatchJob.ApexClass.Name,incompleteBatchJob.ApexClass.Name);
                                                        }
            
            //CRM-3182 - increasing frequency
            if(InvJobp && ((numbtypehour >=6 && numbtypehour<=8) || ((numbtypehour >=11 && numbtypehour<=12))) || Test.isRunningTest()){
                 if(!runningApexJobClassNames2.containsKey('BatchProcessFailedInventory') ||  numbtype>56){
                    if(jcount<20){
                System.debug('Working now');Database.executeBatch(new BatchProcessFailedInventory(), 1);
                    }
                }
            } else{
                if(InvJobp &&((numbtype>0 && numbtype<4) || (numbtype>11 && numbtype<14) || (numbtype>19 && numbtype<22) || (numbtype>26 && numbtype<30) || (numbtype>35 && numbtype<38) || (numbtype>43 && numbtype<47) || (numbtype>52 && numbtype<55))){
                if(!runningApexJobClassNames2.containsKey('BatchProcessFailedInventory') ||  numbtype>56){
                    if(jcount<20){
                System.debug('Working now');Database.executeBatch(new BatchProcessFailedInventory(), 1);
                    }
                }
                }
            }
            //  if(InvJobp && (numbtypehour >=6 && numbtypehour<=18)){
            if(InvJobp &&((numbtype>0 && numbtype<4) || (numbtype>20 && numbtype<24)  || (numbtype>40 && numbtype<44)) || Test.isRunningTest()){ 
                //date rendat =system.today().addDays(60);
                date rendat =System.Date.today().toStartOfMonth().addMonths(1).addDays(-1);
                date todayDate =system.today();
                // Query=q;
                //rendat= system.today().addDays(-60);
                //system.debug('####'+rendat);
                Set<String> setAccountType = new Set<String>();
                setAccountType.add('Realtor Agent');
                setAccountType.add('Broker');
                set<String> setNotPromo = new set<String>{'RSBUNDLEFIVESTREET','RSBUNDLETOPMRKSNP','RSBUNDLESTDFIVESTREET','RSBUNDLESTDTOPMRKSNP'};
                String  Query = 'Select id,AccountId,';
                query += 'Market__c from Asset where Account.Type=:setAccountType and Asset_Type__c=\'Parent\' and Promotion__c!=:setNotPromo and Renewal_Type__c!=\'Auto\' and Haircut_Asset__c=false  and Product2.Beta__c=false' ;
                query += ' and End_Date__c<:rendat and End_Date__c>:todayDate and Status = \'Active\' and Fulfillment_Status__c=\'Fulfilled\' ' ;//  and Follow_Up_Status__c!=\'Will Not Renew\'
                List<Asset> sobjList = Database.query(Query);
                Set<Id> setAccountId = new Set<Id>();
                for(Asset ast:sobjList){
                    //System.debug(''+sobjList.size());
                    setAccountId.add(ast.AccountId);
                }
                //System.debug(setAccountId.size());        
               
                if(!runningApexJobClassNames2.containsKey('BatchProcessOpportunityDialList')){
                    if(jcount<20){
                    BatchProcessOpportunityDialList BpQDL = new BatchProcessOpportunityDialList();
                    BpQDL.setAccountIds = setAccountId;
                    System.debug('Working now');Database.executeBatch(BpQDL, 30);
                    }
                }
            }
            //  }
            
            if(CFBRSjob &&((numbtype>0 && numbtype<4) || (numbtype>20 && numbtype<24)  || (numbtype>40 && numbtype<44))  || Test.isRunningTest()){ 
                date rendat =system.today().addDays(90);
                date todayDate =system.today();
                set<String> setProductCodeAdd = new set<String>{'RSRESPOND','RSCONNECT','RSTRANSACT'};
                    // Query=q;
                    //rendat= system.today().addDays(-60);
                    //system.debug('####'+rendat);
                    String  Query = 'Select id,Order.Account.Name,Order.Account.ownerId,order.AccountId,Order.Oracle_Quote__c,Order.Oracle_Quote__r.Name,Order.Oracle_Quote__r.BigMachines__Transaction_Id__c,';
                query += 'Order.EffectiveDate from OrderItem where Order.Account.Type=\'Realtor Agent\' and Order.Status=\'Complete\' and Line_Type__c =\'Renew\'' ;
                query += '  and Order.EffectiveDate=Today and Order.Fulfillment_Status__c=\'Fulfilled\' and PricebookEntry.Product2.productCode=\'COBROKE\'' ;//l and Renewal_End_Date__c=null';// and id=\'02ig0000005qMQc\'';
                List<OrderItem> sobjList = Database.query(Query);
                Set<Id> setAccountId = new Set<Id>();
                Map<String,Id> mapQuoteNumberAccount = new Map<String,Id>();
                Map<Id,String> mapQuoteAccount = new Map<Id,String>();
                Map<Id,String> mapAccount = new Map<Id,String>();
                Map<Id,Id> mapAccountowner = new Map<Id,Id>();
                Set<Id> setRSHavingAccountId = new Set<Id>();
                Set<String> promoBundle = new Set<String>();
                promoBundle.add('FREEBUNDLERSRESPOND');
                promoBundle.add('FREEBUNDLERSCONNECT');
                promoBundle.add('FREEBUNDLERSTRANSACT');
                for(OrderItem ast:sobjList){
                    //System.debug(''+sobjList.size());
                    if(ast.Order.Oracle_Quote__r.Name!=''){
                        mapQuoteNumberAccount.put(ast.Order.Oracle_Quote__r.BigMachines__Transaction_Id__c,ast.order.AccountId);
                        mapQuoteAccount.put(ast.Order.AccountId,ast.Order.Oracle_Quote__r.BigMachines__Transaction_Id__c);
                        
                    }
                    setAccountId.add(ast.Order.AccountId);
                    mapAccountowner.put(ast.Order.AccountId,ast.Order.Account.ownerId);
                    mapAccount.put(ast.Order.AccountId,ast.Order.Account.Name);
                }
                for(Asset ast:[Select Id,AccountId from asset where AccountId=:setAccountId and Product2.ProductCode=:setProductCodeAdd and promotion__c=:promoBundle and Asset_type__c='Parent' and Status='Active']){
                    setRSHavingAccountId.add(ast.AccountId);
                }
                //System.debug(setAccountId.size());    
                setAccountId.removeAll(setRSHavingAccountId);  
                for(BigMachines__Quote__c bqqq:[Select Id,name,BigMachines__Transaction_Id__c,ParentQuote__c from BigMachines__Quote__c where ParentQuote__c=:mapQuoteNumberAccount.keyset()]){
                    if(mapQuoteNumberAccount.get(bqqq.ParentQuote__c)!=null){
                        if(setAccountId.contains(mapQuoteNumberAccount.get(bqqq.ParentQuote__c))){
                            setAccountId.remove(mapQuoteNumberAccount.get(bqqq.ParentQuote__c));
                        }
                    }
                }  
                
                    set<string> batchApexClassNames = new set<string>{'BatchRealSuiteBundleRenewalProcess','BatchProcessOfficeScore'};
                        Map<string,string> runningApexJobClassNames = new Map<string,string>();
                DateTime min10Earlier = Datetime.now().addMinutes(-CFBMinutecount);
                DateTime h2hoursEarlier = Datetime.now().addMinutes(-120);
                DateTime nowTimeEarlier = Datetime.now();
                Boolean runRSBundleJob = true;
                
                for(AsyncApexJob  incompleteBatchJob : [SELECT ApexClass.Name ,TotalJobItems,CreatedDate
                                                        FROM AsyncApexJob 
                                                        WHERE JobType = 'BatchApex' 
                                                        //AND Status IN :incomplteStatuses
                                                        AND ApexClass.Name IN :batchApexClassNames
                                                        AND CreatedDate <= :nowTimeEarlier AND CreatedDate > :min10Earlier]){
                                                            if(incompleteBatchJob.TotalJobItems>70){runRSBundleJob = false;}
                                                            runningApexJobClassNames.put(incompleteBatchJob.ApexClass.Name,incompleteBatchJob.ApexClass.Name);
                                                        }
                if(runRSBundleJob && !runningApexJobClassNames.containsKey('BatchRealSuiteBundleRenewalProcess')){
                    if(setAccountId.size()>0 || Test.isRunningTest()){
                        Map<Id,Id> mapAccountOpp = new   Map<Id,Id>();
                        List<Opportunity> lstOpportunity = new List<Opportunity>();
                        for(Id iddd:setAccountId){
                            Opportunity theOpportunity = new Opportunity();
                            theOpportunity.Name            = mapAccount.get(iddd).replace(' ','-') + '-' + Datetime.now().format('yyyy-MM-dd');
                            theOpportunity.StageName       = 'Prospecting';
                            theOpportunity.CloseDate       = system.today();
                            theOpportunity.AccountId       = iddd;
                            theOpportunity.Account_Type__c = 'Short';
                            theOpportunity.ownerId = mapAccountowner.get(iddd);
                            lstOpportunity.add(theOpportunity);
                        }
                        insert lstOpportunity;
                        for(Opportunity opp:lstOpportunity){
                            mapAccountOpp.put(opp.AccountId,opp.id);
                        }
                        // }
                        System.debug('My Match'+mapQuoteAccount);
                        BatchRealSuiteBundleRenewalProcess BpQDL = new BatchRealSuiteBundleRenewalProcess(mapAccountOpp);
                        BpQDL.mapQuoteNumber = mapQuoteAccount;
                        System.debug('Working now');Database.executeBatch(BpQDL,1);
                    }
                }
            }
            //Added /Updated by Pratik on 30th October 2018
            /*
            set<string> incomplteStatuses = new set<string>{'Queued', 'Preparing', 'Processing', 'Holding'};
            set<string> batchApexClassNames = new set<string>{'BatchZouraAccountBalance'};
            Map<string,string> runningApexJobClassNames = new Map<string,string>();
            DateTime twoHrsEarlier = Datetime.now().addDays(-7);
            for(AsyncApexJob  incompleteBatchJob : [SELECT ApexClass.Name 
                                                        FROM AsyncApexJob 
                                                        WHERE JobType = 'BatchApex' 
                                                        AND Status IN :incomplteStatuses
                                                        AND ApexClass.Name IN :batchApexClassNames
                                                        AND CreatedDate <= :twoHrsEarlier]){
                                                            runningApexJobClassNames.put(incompleteBatchJob.ApexClass.Name,incompleteBatchJob.ApexClass.Name);
                                                        }
            
            //if ((true && (numbtypeDay==1) && (ZouraAccountBalanceprocess) && (numbtypehour >= ZouraAccountBalanceExecutionStartTimehr) && (numbtypehour < ZouraAccountBalanceExecutionEndTimehr) && (numbtype < ZouraAccountBalanceExecutionTimemin))  || Test.isRunningTest()) {
              if ((!runningApexJobClassNames.containsKey('BatchZouraAccountBalance') 
                    && (numbtypeDay==1) && (ZouraAccountBalanceprocess) && (numbtypehour >= ZouraAccountBalanceExecutionStartTimehr) 
                    && (numbtypehour < ZouraAccountBalanceExecutionEndTimehr) 
                    && (numbtype < ZouraAccountBalanceExecutionTimemin)) || Test.isRunningTest()) {
              //ends here
              */
            // Added IF
            if ((true && (numbtypeDay==1) && (ZouraAccountBalanceprocess) && (numbtypehour >= ZouraAccountBalanceExecutionStartTimehr) && (numbtypehour < ZouraAccountBalanceExecutionEndTimehr) && (numbtype < ZouraAccountBalanceExecutionTimemin))  || Test.isRunningTest()) {
              
              if(!runningApexJobClassNames2.containsKey('BatchZouraAccountBalance')){
                BatchZouraAccountBalance WLBatch = new BatchZouraAccountBalance();
                database.executebatch(WLBatch, 1800);
                if(zacbp != null){
                    Schedule_Batch_Setting__c ssbss = [Select Id,Name,Last_Execution__c from Schedule_Batch_Setting__c where Name='Zoura Process'];
                    ssbss.Last_Execution__c = System.now();
                    update ssbss;
                }
                }
            }
            if(runBatchProcessOfficeJob && !runningApexJobClassNames2.containsKey('BatchProcessOfficeScore')){
                              Set<Id> stIds = new Set<Id>();
                for(Account acct:[SELECT Id FROM Account WHERE Opcity_Score_Date_Time__c = Yesterday and Type='Realtor office' and (LastModifiedDate=Yesterday OR LastModifiedDate=Today)]){
                stIds.add(acct.id);
                }
                if(stIds.size()<1){
                for(Account acct:[SELECT Id FROM Account WHERE Opcity_Score_Date_Time__c = Today and Type='Realtor office' and (LastModifiedDate=Yesterday OR LastModifiedDate=Today)]){
                stIds.add(acct.id);
                }
                }
                if(stIds.size()<1){
                for(Account acct:[SELECT Id FROM Account WHERE Opcity_Score_Date_Time__c = Yesterday and Type='Broker' and (LastModifiedDate=Yesterday OR LastModifiedDate=Today)]){
                stIds.add(acct.id);
                }
                }
                if(stIds.size()<1){
                for(Account acct:[SELECT Id FROM Account WHERE Opcity_Score_Date_Time__c = Today and Type='Broker' and (LastModifiedDate=Yesterday OR LastModifiedDate=Today)]){
                stIds.add(acct.id);
                }
                }
                if(stIds.size()>1){
                BatchProcessOfficeScore BPOS = new BatchProcessOfficeScore();
                BPOS.setIds = stIds;
                Database.executeBatch(BPOS,10);
                }
                }

        } catch (Exception ex) {
            Integer rcount = [SELECT count() FROM CronJobDetail WHERE Name LIKE 'SalesLockTCVA1A%'];
            if (rcount < 2 ) { 
                scheduledSalesLockTCVWaitlistExpire p = new scheduledSalesLockTCVWaitlistExpire();
                Datetime dtt = System.now().addMinutes(1).addSeconds(17);
                Integer rand = Math.round(Math.random()*100);
                String sch = dtt.Second()  + ' ' + dtt.Minute() + ' ' + dtt.hour() + ' ' + dtt.day() + ' ' + dtt.Month() + ' ? ' + dtt.year();

                List < CronTrigger > listCronTrigger = [select Id from CronTrigger where State = 'DELETED'
                                                        and nextfiretime = null limit 20 ];
                If(listCronTrigger.size() > 0) {
                    For(Integer i = 0; i < listCronTrigger.size(); i++) {
                        System.abortJob(listCronTrigger[i].Id);
                    }
                }
            }
        }
        
        DateTime dt = aysncJobp.Last_Execution__c;
        system.debug('Date Async:' + dt);
        if (datetime.now() > dt.addHours(4) && !test.isRunningTest()) {
            MonitorAsyncApexJobController obj = new MonitorAsyncApexJobController();     
            obj.monitorAsyncApexJobandSendEmail();
            aysncJobp.Last_Execution__c = Datetime.now();
            update aysncJobp; 
        }
    }
}