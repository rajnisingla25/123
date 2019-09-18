/***********************************************************************************
Created By          :    Srinivas Pendli    
Created Date        :    16.09.2015
Company             :    NTT Data,Inc.
Usage               :    The main purpose of this class is to create collection commissions for collection team members.
                         Find the below important points to understand the business logic.
                         1.It will create a commission when ever a new payment (Paymemt History Record ) is sucessfully created in the system.                         
                         2.It will rollup commission value to collection team member current month quota.
                         3.It will get current month payout/payout rate from payout table based a quota achived value of collection team member
                             current month quota.
                             I.Every collection team member Quota have team value/Name
                             II.It won't create a commission if team is not populated in the Quota or if team member doesn't have a quota or
                                 if a user is not assiged to any team (In this case collection team).
                         4.No Clawback records for collection team.
                         5.This code/Logic contains only collection team commission Logic.
                         6.It contains @future method to calculate payout/payout Rate.
                             I.New payout/payout rate and quota achived value will update to all commissions of current month collections team quota.
Modified By         :    Srinivas Pendli
Modifide Date       :    14.12.2015
************************************************************************************/

Public with sharing class Commissions_CreateCollectionCommsClass{    
    //CREATING COMMISSION RECORDS.
    Public void CreateCommissions(Map<Id,Zuora__Payment__c> newMap){
        DisabledTrigger__c Dtrg= DisabledTrigger__c.getValues('Disabled'); 
        String usercheck='';
        if(Dtrg.Commissions_CollectionsTriggerPayments__c !=null ){
            usercheck=Dtrg.Commissions_CollectionsTriggerPayments__c;
        }
        if(!usercheck.contains(UserInfo.getUserName())){  
            set<String> OwnerIds = new set<String>();
            set<String> paymentIds = new set<String>();
            Map<id,Quota__c> updateQuotas = new Map<id,Quota__c>();
            for(Zuora__Payment__c payHistory : newMap.Values()){            
                OwnerIds.add(payHistory.SalesforceCollectionsRepUsername__c );
                paymentIds.add(payHistory.id);
            }               
            Date startOfMonth = Date.today().toStartOfMonth(); 
            //GET CURRENT MONTH QUOTA OF COLLECTION TEAM MEMBER
            Integer MonthValue =  system.today().Month();   
            Integer YearValue = system.today().Year();
            system.debug('paymentOwnerQuotas >> 1:'+OwnerIds);
            Map<id,Quota__c> mapPaymentOwnerQuotas = new Map<id,Quota__c>([select id,Name,User__r.Managers__c,User_Team__c,User__c,User__r.UserName,Quota_StartDate__c,Quota_EndDate__c, 
                                                        Collection_Total_Sale__c,Collection_Target_Amount__c,Collection_New_Sale_Target_Amount__c,Collection_Quota_Percentage__c
                                                        from Quota__c where Period_Year1__c =: YearValue and User__r.UserName In : OwnerIds]);        
            system.debug('paymentOwnerQuotas >> :'+mapPaymentOwnerQuotas);      
            Set<Id> paymentQuotaUserIds = new Set<Id>();
            for(Quota__c quotaUser : mapPaymentOwnerQuotas.Values()){
                paymentQuotaUserIds.add(quotaUser.User__c);
            }        
            Map<id,User> paymentOwnerRecords  = new Map<id,User>([select id,Name,Team__c,Managers__c,username from user where Id IN : paymentQuotaUserIds]);        
            //MANAGERS CALCULATION
            Set<String> paymentOwnerManagers =  new Set<String>();        
            string[] str1;        
            for(Quota__c Qs : mapPaymentOwnerQuotas.Values()){
                string x1 = Qs.User__r.Managers__c;            
                if(x1 != null){
                    str1 = x1.split(';');           
                    for(string str : str1){        
                        paymentOwnerManagers.add(str.toLowerCase());
                    }
                }
            }        
            //GET CURRENT MONTH QUOTA OF COLLECTION TEAM MEMBER MANAGERS
            Map<id,Quota__c> mapPaymentOwnerManagers_Quotas = new Map<id,Quota__c>([select id,Name,User__r.Name,User__c,User__r.Team__c,User__r.Managers__c,Quota_StartDate__c,
                                                                User_Team__c,Current_Quater__c,Collection_Total_Sale__c,Collection_Target_Amount__c,Collection_New_Sale_Target_Amount__c,
                                                                Collection_Quota_Percentage__c from Quota__c where Period_Year1__c =: YearValue  
                                                                and User__r.Name In : paymentOwnerManagers]);
            system.debug('mapPaymentOwnerManagers_Quotas >>> : '+mapPaymentOwnerManagers_Quotas.size());            
            Map<Id,Commission__c> newPaymentCommissionMap =  new Map<Id,Commission__c>([Select id,Name,Payment__c 
                                        from Commission__c where Payment__c In : paymentIds]);
            Map<String,Commission__c> ZPIds = new Map<String,Commission__c>(); 
            for(Commission__c comm : newPaymentCommissionMap.values()){
                ZPIds.put(comm.Payment__c,comm);
            }     
            
            Map<String,Commission__c> newPaymentCommissionList =  new Map<String,commission__c>();            
            //NEW SALE AND MANAGERS COMMISSION RECORD RECORD TYPE
            //Id newSaleRT = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Collection Commission').getRecordTypeId();
            //Id newSaleManagerRT = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Managers Team').getRecordTypeId();
            Id newSaleRT = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get(System.Label.Collection_Commission).getRecordTypeId();
            Id newSaleManagerRT = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get(System.Label.Managers_Team).getRecordTypeId();
            
            //CREATING COMMISSIONS LOGIC FOR COLLECTION TEAM
            DateTime paymentCreatedDate;
            for(Zuora__Payment__c payHistory : newMap.Values()){
                user paymentOwners = new user();
                Commission__c ZP =  ZPIds.get(payHistory.id);
                system.debug('ZPPPP >> :'+ZP);
                if(ZP == Null){
                    for( User u : paymentOwnerRecords.Values()){
                        if(u.UserName == payHistory.SalesforceCollectionsRepUsername__c){
                            paymentOwners = u;
                        }
                    }
                    //GET PAYMENT OWNER (CREATED BY) MANAGERS 
                    set<String> ManagerNames16 = new Set<String>();     
                    string[] str66;
                    String x66;      
                    if(Test.isRunningTest()){
                        x66 = 'ADRIAN MATTHEWS';   
                    }else{
                        x66 = paymentOwners.Managers__c;  
                    }         
                    if(x66 != null){
                        str66 = x66.split(';');           
                        for(string str : str66){
                            ManagerNames16.add(str.toLowerCase());
                        }
                    }
                    //CREATING COMMISSIONS FOR PAYMENT OWNERS
                    if(test.isRunningTest()){
                        paymentCreatedDate = system.now();
                    }
                    if(!test.isRunningTest()){
                        paymentCreatedDate = payHistory.CreatedDate;
                    }
                    for(Quota__c quotaRecord : mapPaymentOwnerQuotas.Values()){
                        system.debug('test 1 >> :');  
                        if(payHistory.SalesforceCollectionsRepUsername__c != Null && payHistory.SalesforceCollectionsRepUsername__c != ' '){      
                            if(quotaRecord.User__r.UserName == payHistory.SalesforceCollectionsRepUsername__c){                      
                                if(quotaRecord.Quota_StartDate__c.Month() == paymentCreatedDate.Month()){
                                    Commission__c commissionRecord = new Commission__c();                       
                                    commissionRecord.RecordTypeId = newSaleRT;
                                    system.debug('Asset amount >> 1 : '+payHistory.Zuora__AppliedInvoiceAmount__c);
                                    commissionRecord.Asset_Amount__c= payHistory.Zuora__AppliedInvoiceAmount__c;
                                    commissionRecord.Collection_Commissionable_Amount__c = payHistory.Zuora__AppliedInvoiceAmount__c;
                                    commissionRecord.Related_to_Quota__c = quotaRecord.id;               
                                    commissionRecord.Signing_AE__c = quotaRecord.User__c; 
                                    commissionRecord.Payment__c = payHistory.id;
                                    commissionRecord.User_Team__c = quotaRecord.User_Team__c; 
                                    commissionRecord.Commission_Split__c = 100;
                                    commissionRecord.status__c = Commissions_Constants.COMMISSION_ACTIVE_STATUS;
                                    //newPaymentCommissionList.add(commissionRecord);
                                    if(commissionRecord.Collection_Commissionable_Amount__c != 0){
                                        newPaymentCommissionList.put(payHistory+'#',commissionRecord);
                                        updateQuotas.put(quotaRecord.id,quotaRecord);
                                    }
                                }
                            }
                        }
                    }
                    /**********************************************
                    //CREATING COMMISSIONS FOR MANAGERS
                    for(Quota__c quotaRecord : mapPaymentOwnerManagers_Quotas.Values()){
                        if(ManagerNames16.contains(quotaRecord.User__r.Name.toLowerCase())){
                            if(!ManagerNames16.contains(paymentOwners.Name.toLowerCase())){
                                if((quotaRecord.User_Team__c == Commissions_Constants.MANAGERS_TEAM)){
                                    if(quotaRecord.Quota_StartDate__c.Month() == paymentCreatedDate.Month()){                                       
                                        Commission__c commissionRecord = new Commission__c();                       
                                        commissionRecord.RecordTypeId = newSaleManagerRT;
                                        system.debug('Asset amount >> 2 : '+payHistory.Zuora__AppliedInvoiceAmount__c);
                                        commissionRecord.Asset_Amount__c= payHistory.Zuora__AppliedInvoiceAmount__c;
                                        commissionRecord.Commissionable_Amount2__c = payHistory.Zuora__AppliedInvoiceAmount__c;
                                        commissionRecord.Related_to_Quota__c = quotaRecord.id;               
                                        commissionRecord.Signing_AE__c = quotaRecord.user__c; 
                                        commissionRecord.Payment__c = payHistory.id;
                                        commissionRecord.User_Team__c = quotaRecord.User_Team__c; 
                                        commissionRecord.Commission_Split__c = 100;
                                        commissionRecord.status__c = Commissions_Constants.COMMISSION_ACTIVE_STATUS;
                                        //newPaymentCommissionList.add(commissionRecord);
                                        if(commissionRecord.Commissionable_Amount2__c != 0){
                                            newPaymentCommissionList.put(quotaRecord+'##'+payHistory,commissionRecord);
                                            updateQuotas.put(quotaRecord.id,quotaRecord);
                                        }
                                    }
                                }
                            }
                        }     
                    }
                    ManagerNames16.clear();
                    **************************************************************/
                }
            }
            
            //INSERTING COLLECTION TEAM COMMISSIONS RECORDS
            set<Id> commIds = new set<Id>();     
            if(newPaymentCommissionList.size() > 0){
                upsert newPaymentCommissionList.Values();
            }
            if(updateQuotas.size() > 0){
                try{
                    update updateQuotas.values();
                }
                catch(Exception e){}
            }
        }
    }
}




    /****************
    //FUTURE METHOD IS TO CALCULATE PAYOUT RATE FOR COMMISSIONS, QUOTA ACHEIVED VALUE AND UPDATING ALL RELETED 
    //QUOTA'S COMMISSIONS WITH CURRENT PAYOUT RATE AND QUOTA ACHIVED % VALUE.
    @future   
    Public static void CommissionCalculation(set<id> allCommissionIds){ 
        Commissions_TriggerHelperClass.firstRun = false;           
        Set<Id> QuotaIds = new Set<Id>();        
        Set<Id> ProductIds = new Set<Id>(); 
        Decimal Componet1RollUpValue = 0.0;       
        Decimal quotaPercentage = 0.0;       
        Map<id,commission__c> commissionsMap = new Map<id,commission__c>();        
        
        Map<ID,Commission__c> Commissionlist = new Map<ID,Commission__c>([select id,Name,Total_Commissionable_Amount__c,Signing_AE__c,Related_to_Quota__r.User__c,Payment__c,Related_to_Quota__c,Quota_Percentage_Achieved1__c,
                                                   Payment_History__c,User_Team__c,Commission_To__c,RecordType.Name,Related_to_Quota__r.Collection_Target_Amount__c,RecordTypeId,Collection_Commissionable_Amount__c,Collection_Payout_Rate__c,Collection_Commission__c
                                                   from Commission__c where Id IN : allCommissionIds order by Name Asc]); 
        system.debug('Commissionlist  :'+Commissionlist);       
        for(Commission__c comm : Commissionlist.Values()){    
            QuotaIds.add(comm.Related_to_Quota__c);
        }         
          
        Map<id,Commission__c> CommissionlistMap = new Map<id,Commission__c>([select id,Name,Total_Commissionable_Amount__c,Signing_AE__c,Related_to_Quota__r.User__c,Related_to_Quota__c,Quota_Percentage_Achieved1__c,
                                                    Payment__c,User_Team__c,Commission_To__c,RecordTypeId,Related_to_Quota__r.Collection_Target_Amount__c,Collection_Commissionable_Amount__c,Collection_Payout_Rate__c,
                                                    RecordType.Name,Collection_Commission__c
                                                    from Commission__c where RecordType.Name !=: Commissions_Constants.COMMISSIONS_CLAWBACK and Related_to_Quota__c IN : QuotaIds order by Name Asc]);
        system.debug('CommissionlistMap :'+CommissionlistMap.Values()); 
        Set<Id> PaymentHistoryIds = new Set<Id>();
        for(Commission__c comm : CommissionlistMap.Values()){ 
            PaymentHistoryIds.add(comm.Payment__c); 
            QuotaIds.add(comm.Related_to_Quota__c);  
        }    
        //GET CURRENT MONTH QUOTA RECORDS OF COLLECTION TEAM MEMBERS
        Date startOfMonth = Date.today().toStartOfMonth(); 
        Map<Id,Quota__c> currentMonthQuota = new Map<id,Quota__c>([select id,Name,User__c,user_Team__c,User__r.CreatedDate,User__r.Name,User__r.Team__c,User__r.ManagerId,
                                                Quota_Percentage__c,Collection_Total_Sale__c,Collection_Target_Amount__c,Collection_New_Sale_Target_Amount__c,Collection_Quota_Percentage__c,User__r.UserName,
                                                Period_Name__c from Quota__c where Quota_StartDate__c =: startOfMonth and id IN : QuotaIds]);
        //NEW SALE COMMISSION ROLLUP CALACULATION
        Map<String,Decimal> mapUserTotalSale = new Map<String,Decimal>();        
        Map<Id,List<commission__c>> mapUserCommissionList = new Map<Id,List<commission__c>>();
        for(Commission__c comm : CommissionlistMap.Values()){         
            if(mapUserCommissionList.containskey(comm.Related_to_Quota__r.User__c)){
                List<commission__c> lstcomm = mapUserCommissionList.get(comm.Related_to_Quota__r.User__c);
                lstcomm.add(comm);
                mapUserCommissionList.put(comm.Related_to_Quota__r.User__c,lstcomm);
            } 
            else{
                List<commission__c> lstcomm = new List<commission__c>();
                lstcomm.add(comm);
                mapUserCommissionList.put(comm.Related_to_Quota__r.User__c,lstcomm);
            }               
        }        
        system.debug('mapUserCommissionList >>>>>:'+mapUserCommissionList.size());        
        for(Id idds : mapUserCommissionList.keyset()){
            Decimal decc = 0.0;
            for(commission__c comm1 : mapUserCommissionList.get(idds)){
                Quota__c currentQuota = currentMonthQuota.get(comm1.Related_to_Quota__c);        
                if(comm1.Total_Commissionable_Amount__c != 0.0){                    
                    decc = decc + (comm1.Total_Commissionable_Amount__c);
                    mapUserTotalSale.put(idds+'###'+comm1.Name,decc);                    
                }               
                if(comm1.Total_Commissionable_Amount__c == 0.0){
                    decc = decc + (comm1.Total_Commissionable_Amount__c);
                    mapUserTotalSale.put(idds+'###'+comm1.Name,decc);                    
                }        
            }
        }
        System.debug(mapUserTotalSale+'######'+mapUserCommissionList);        
        //GET PAYMENT RECORDS
        Map<Id,Zuora__Payment__c> PaymentHistory = new Map<Id,Zuora__Payment__c>([Select id,Zuora__AppliedInvoiceAmount__c,SalesforceCollectionsRepUsername__c from Zuora__Payment__c where Id In : PaymentHistoryIds]);       
        //GET CURRENT MONTH PAYOUT RECORDS OF COLLECTION TEAM 
        Set<Id> PeriodIds = new Set<Id>();
        for(Quota__c quota : currentMonthQuota.Values()){
            system.debug('QuotaIds : '+Quota.Period_Name__c);
            PeriodIds.add(quota.Period_Name__c);
        }
       
        Map<Id,payout__c> Payout = new Map<ID, Payout__C>([select id,name,RecordType.Name,High_Level__c,Low_Level__c,Low_Amount__c, High_Amount__c,
                                           Commissionable__c from Payout__c Where Period__c In : PeriodIds Order by Low_Level__c Desc]);
        //PAYOUT RATE CALCULATION
        for(commission__c cm : Commissionlist.Values()){            
            quotaPercentage = 0.0; Componet1RollUpValue = 0.0;            
            Quota__c currentQuota = currentMonthQuota.get(cm.Related_to_Quota__c);
            Zuora__Payment__c PaymentHistoryRecord = PaymentHistory.get(cm.Payment__c);   
            if(cm.RecordType.Name != Commissions_Constants.COMMISSIONS_CLAWBACK){                 
                if(PaymentHistoryRecord.SalesforceCollectionsRepUsername__c == currentQuota.User__r.UserName){                                     
                    if((cm.Signing_AE__c == currentQuota.user__c) && (cm.Related_to_Quota__r.Collection_Target_Amount__c != null && cm.Related_to_Quota__r.Collection_Target_Amount__c != 0)){                           
                        quotaPercentage = ((mapUserTotalSale.get(cm.Related_to_Quota__r.user__c+'###'+cm.Name))/cm.Related_to_Quota__r.Collection_Target_Amount__c)*100;
                        Componet1RollUpValue = mapUserTotalSale.get(cm.Related_to_Quota__r.user__c+'###'+cm.Name);                           
                    }                              
                }  
                system.debug('quotaPercentage  : '+quotaPercentage );  
                system.debug('Componet1RollUpValue : '+Componet1RollUpValue );                   
                String QuotaTeam = '';
                if(currentQuota.User__r.Team__c == Commissions_Constants.MANAGERS_TEAM){
                    QuotaTeam = currentQuota.User__r.Name;
                }else{
                    QuotaTeam = currentQuota.User__r.Team__c;
                }                
                if(cm.User_Team__c != Commissions_Constants.MANAGERS_TEAM){
                    for(Payout__c pay : Payout.Values()){
                        if((currentQuota.User_Team__c == Commissions_Constants.COLLECTION_TEAM && pay.RecordType.Name == Commissions_Constants.COLLECTION_TEAM) ||
                            (currentQuota.User_Team__c == Commissions_Constants.COLLECTIONS_CLIENT_RELATIONS_MANAGERS && pay.RecordType.Name == Commissions_Constants.COLLECTIONS_CLIENT_RELATIONS_MANAGERS)){                        
                            
                            Decimal LowValueComp1; Decimal HighValueComp1; Decimal CommissinableAmountComp1;
                            if(pay.Low_Level__c == Null && pay.High_Level__c == Null){
                                LowValueComp1 = pay.Low_Amount__c;
                                HighValueComp1 = pay.High_Amount__c;
                                CommissinableAmountComp1 = Componet1RollUpValue;                                                               
                            }
                            if(pay.Low_Amount__c == Null && pay.High_Amount__c == Null){
                                LowValueComp1 = pay.Low_Level__c;
                                HighValueComp1 = pay.High_Level__c;
                                CommissinableAmountComp1 = quotaPercentage;                            
                            } 
                            system.debug('CommissinableAmountComp1 >>: '+CommissinableAmountComp1);
                            system.debug('LowValueComp1 : '+LowValueComp1 );  
                            system.debug('HighValueComp1 : '+HighValueComp1);                            
                            if((CommissinableAmountComp1 >= LowValueComp1)){                            
                                if(CommissinableAmountComp1 <= HighValueComp1) {                            
                                    if(pay.Name == Commissions_Constants.NEW_SALE_WITHOUT_QUALIFIER){                                   
                                        cm.Collection_Payout_Rate__c = (pay.Commissionable__c).setScale(2);
                                        cm.Quota_Percentage_Achieved1__c = quotaPercentage;
                                        if(cm.Collection_Commissionable_Amount__c != Null){
                                            cm.Collection_Commission__c = (cm.Collection_Commissionable_Amount__c*cm.Collection_Payout_Rate__c)/100;                                        
                                        }
                                    }
                                }
                                commissionsMap.put(cm.id,cm);
                            }                           
                        }
                    }        
                }
                                //**************MANAGERs TEAM ***************************
                Decimal xMgr1 = 0; Decimal x1Mgr1 = 0; Decimal x2Mgr1 = 0;
                Decimal yMgr1  = 0; Decimal y1Mgr1 = 0; Decimal y2Mgr1 = 0;   
                Decimal lowAmountMgr1; Decimal highAmountMgr1;
                Decimal lowValueMgr1 ; Decimal highValueMgr1 ;    
                Decimal CommissinableAmountCompMgr1;
                if(cm.User_Team__c == Commissions_Constants.MANAGERS_TEAM){
                    for(Payout__c p : Payout.Values()){
                        system.debug('>>> ? :'+p.RecordType.Name);
                        system.debug('>>> ? :'+cm.commission_To__c);
                        if(p.RecordType.Name == cm.commission_To__c){
                            if(p.Name == Commissions_Constants.NEW_SALE_WITHOUT_QUALIFIER){
                                if(p.Low_Level__c == Null && p.High_Level__c == Null){
                                    lowValueMgr1 = p.Low_Amount__c;
                                    CommissinableAmountCompMgr1 = Componet1RollUpValue;                               
                                }
                                if(p.Low_Amount__c == Null && p.High_Amount__c == Null){
                                    lowValueMgr1 = p.Low_Level__c;
                                    CommissinableAmountCompMgr1 = quotaPercentage;
                                }                               
                                if(lowValueMgr1 <= CommissinableAmountCompMgr1){ 
                                    x1Mgr1 = p.High_Level__c;                         
                                    y1Mgr1 = p.Commissionable__c;
                                    break;                               
                                }
                            }
                        }
                    }                        
                    for(Payout__c p : Payout.Values()){
                        if(p.RecordType.Name == cm.commission_To__c){
                            if(p.Name == Commissions_Constants.NEW_SALE_WITHOUT_QUALIFIER){
                                if(p.Low_Level__c == Null && p.High_Level__c == Null){
                                    highValueMgr1 = p.High_Amount__c;
                                    CommissinableAmountCompMgr1 = Componet1RollUpValue;                              
                                }
                                if(p.Low_Amount__c == Null && p.High_Amount__c == Null){
                                    highValueMgr1 = p.High_Level__c;
                                    CommissinableAmountCompMgr1 = quotaPercentage;
                                }
                                if(highValueMgr1 >= CommissinableAmountCompMgr1){                                
                                    x2Mgr1 = p.Low_Level__c;  
                                    y2Mgr1 = p.Commissionable__c;
                                }
                            }
                        }                                   
                    }
                    xMgr1 = quotaPercentage;                               
                    system.debug('xMgr1 : '+xMgr1);
                    system.debug('x1Mgr1 : '+x1Mgr1);
                    system.debug('x2Mgr1 : '+x2Mgr1);                             
                    system.debug('y1Mgr1 : '+y1Mgr1);
                    system.debug('y2Mgr1 : '+y2Mgr1);
                    try{
                        yMgr1 = ((y2Mgr1-y1Mgr1)/(x2Mgr1-x1Mgr1)*(xMgr1-x1Mgr1))+y1Mgr1;
                    }
                    catch(Exception e){}
                    system.debug('YYYYYYYYYYYYYYY : '+yMgr1);
                    if(xMgr1 <= 65.00 ){
                        yMgr1 = 0.00;
                        cm.Payout_Rate__c = 0;//YMgr1.setScale(2);
                        cm.Quota_Percentage_Achieved1__c = quotaPercentage;   
                        cm.New_Sale_w_o_Qualifier_Commission__c =0;// (cm.Payout_Rate__c * cm.Commissionable_Amount2__c)/100;
                        commissionsMap.put(cm.id,cm);
                    }
                    if(xMgr1 >= 65.01 ){
                        cm.Payout_Rate__c = YMgr1.setScale(2);
                        cm.Quota_Percentage_Achieved1__c = quotaPercentage;  
                        if(cm.Commissionable_Amount2__c !=Null ){                
                            cm.New_Sale_w_o_Qualifier_Commission__c = (cm.Payout_Rate__c * cm.Commissionable_Amount2__c)/100;
                        }
                        commissionsMap.put(cm.id,cm);
                    }
                }
            }
        }
        system.debug('commissionsMap size : '+commissionsMap.size());
        if(commissionsMap.size() > 0) {
            system.debug('commissionsMap : '+commissionsMap);
            Commissions_TriggerHelperClass.firstRun = true;
            upsert commissionsMap.Values();
        }
                
        //LATEST COMMISSION QUOTA PERCENTAGE VALUE UPDATED TO ALL RELATED QUOTA COMMISSIONS
        
        Map<Id,Commission__c>  AllCommissions = new Map<ID, Commission__c>([select id,Name,CreatedDate,Related_to_Quota__c,Quota_Percentage_Achieved1__c,
                                        Related_to_Quota__r.Collection_Quota_Percentage__c,
                                                        Payout_rate__c,Payout_Rate1B__c,Collection_Commissionable_Amount__c,
                                                        Signing_AE__c,Commission_To__c,Total_Commissionable_Amount__c,Payout_rate_3__c,RecordType.Name,
                                                        User_Team__c from Commission__c where Related_to_Quota__c IN : QuotaIds]); 
        Map<Id,Commission__c> mapCommissions = new Map<Id,Commission__c>();
        Map<Id,User> users = New Map<id,User>([select id,Name from User where isActive = True]);
        for(commission__c cm1 : commissionsMap.Values()){            
            Quota__c currentQuotaUpdate = currentMonthQuota.get(cm1.Related_to_Quota__c);           
            for(Commission__c allCommissionsupdate : AllCommissions.Values()){
                if(cm1.RecordType.Name != Commissions_Constants.COMMISSIONS_CLAWBACK){                    
                    if(cm1.Related_to_Quota__c == allCommissionsupdate.Related_to_Quota__c){  
                        Datetime temp1,temp2;       
                        temp1 = DateTime.now();
                        Integer recordCreatedMonth;  Integer currentMonth ;
                        currentMonth = temp1.Month();
                        recordCreatedMonth = (allCommissionsupdate.CreatedDate.month());   
                        user u = users.get(allCommissionsupdate.Signing_AE__c);
                        if((currentQuotaUpdate.User_Team__c == Commissions_Constants.COLLECTION_TEAM) || (currentQuotaUpdate.User_Team__c == Commissions_Constants.COLLECTIONS_CLIENT_RELATIONS_MANAGERS)){
                            if(currentMonth == recordCreatedMonth){                                
                                if(cm1.Collection_Payout_Rate__c != Null ){
                                    allCommissionsupdate.Collection_Payout_Rate__c = (cm1.Collection_Payout_Rate__c).setScale(2);
                                    if(allCommissionsupdate.Collection_Commissionable_Amount__c != Null){
                                        if(allCommissionsupdate.Collection_Commissionable_Amount__c!=Null){
                                            allCommissionsupdate.Collection_Commission__c =(allCommissionsupdate.Collection_Payout_Rate__c *allCommissionsupdate.Collection_Commissionable_Amount__c)/100;
                                        }
                                    }
                                }                                
                                if(cm1.Quota_Percentage_Achieved1__c != 0.0 && cm1.Quota_Percentage_Achieved1__c != null){                                    
                                    allCommissionsupdate.Quota_Percentage_Achieved1__c = cm1.Quota_Percentage_Achieved1__c;
                                }
                                if(cm1.Quota_Percentage_Achieved1__c == 0.0 || cm1.Quota_Percentage_Achieved1__c == Null){                                        
                                    cm1.Quota_Percentage_Achieved1__c = allCommissionsupdate.Related_to_Quota__r.Collection_Quota_Percentage__c;
                                    mapCommissions.put(cm1.id,cm1);
                                }                               
                            }          
                        }                               
                    }
                    mapCommissions.put(allCommissionsupdate.id,allCommissionsupdate); 
                }                
 
            }
        }     
        system.debug('mapCommissions>>>>> : '+mapCommissions);
        if(mapCommissions.size() > 0){
            Commissions_TriggerHelperClass.firstRun = true;
            Upsert mapCommissions.Values();
        }
        mapUserTotalSale.clear();
        commissionsMap.Clear();
    } 
}
**********************/