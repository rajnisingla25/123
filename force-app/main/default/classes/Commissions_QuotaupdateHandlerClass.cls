Public Class Commissions_QuotaupdateHandlerClass{
     Public void updateQuotaCommissions(Map<id,Quota__c> quotaMap){
        set<Id> quotaIds = new Set<Id>();
        set<Id> relatedcommissionIds = new Set<Id>();
        set<id> periodIds = new set<Id>();
        set<String> RTNames = new set<String>();
        Integer TigerLeadCount = 0;  Integer topProducercommCount = 0; 
        Decimal QualifierAmount = 0.00;    Decimal BOBAmount = 0.00;
        Decimal PayoutRate1A = 0.0; Decimal PayoutRate2A = 0.0; Decimal PayoutRate2B = 0.0;  Decimal PayoutRate2C = 0.0;
        Decimal PayoutRate2D = 0.0; Decimal quotaPercentage = 0.0;Decimal PayoutRate3 = 0.0; Decimal PayoutRate4A = 0.0;
        Decimal Componet1RollUpValue = 0.0;Decimal Componet2RollUpValue = 0.0;Decimal OpenBookPayout = 0.0;
        Decimal Componet2A2BRollUpValue = 0.0;Decimal Componet2C2DRollUpValue = 0.0;Decimal Componet4ARollUpValue = 0.0;
        Decimal xMgr1 = 0; Decimal x1Mgr1 = 0; Decimal x2Mgr1 = 0;
        Decimal yMgr1  = 0; Decimal y1Mgr1 = 0; Decimal y2Mgr1 = 0;
        Decimal LowValueComp1 ; Decimal HighValueComp1 ;Decimal CommissinableAmountComp1;
        Decimal denominator = 0.0;
        String TeamName= ''; 
        for(Quota__c quota : quotaMap.values()){
            quotaIds.add(quota.id);
            periodIds.add(quota.Period_Name__c);
            RTNames.add(quota.User_Team__c);
            RTNames.add(quota.User__r.Name);
        }  

        Map<Id,Quota__c> updateQuota = new Map<Id,Quota__c>();
        Map<ID,Commission__c> commissionMap = new Map<ID,Commission__c>([select id,Name,Related_to_Asset__c,Related_to_Quota__c,Product__c,Related_Commission__r.Related_to_Quota__c,Related_Commission__c,User_Team__c,Commission_To__c,RecordType.Name,
                                                    Quota_Percentage_Achieved1__c,Commissionable_Amount2__c,CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c,CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c,
                                                    CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c,CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c,Commissionable_Amount3__c,Payout_Rate__c,Payout_Rate1B__c,CFCB_NEW_w_Qualifier_Payout_Rate2A__c,
                                                    CFCB_New_w_o_Qualifier_Payout_Rate2B__c,CFCB_RNW_w_Qualifier_Payout_Rate2C__c,CFCB_RNW_w_o_Qualifier_Payout_Rate2D__c,Payout_rate_3__c,OpenBook_New_Sale_Comm_ble_Amount__c,
                                                    OpenBook_New_Sale_Payout__c,New_Sale_w_o_Qualifier_Commission__c,New_Sale_w_Qualifier_Commission__c,CFCB_NEW_w_Qualifier_Commission2A__c,CFCB_New_w_o_Qualifier_Commission2B__c,
                                                    CFCB_RNW_w_Qualifier_Commission2C__c,Commissionable_Amount1B__c,RD_Payout_Rate__c,CFCB_RNW_w_o_Qualifier_Commission2D__c,Asset_Owner_Commission__c,Collection_Commission__c,
                                                    OpenBook_New_Sale_Commission__c,Product__r.Commission_Category__c,Related_to_Asset__r.Renewal_Type__c,
                                                    Other_Product__c,Related_to_Asset__r.Fulfillment_Status__c,Related_to_Asset__r.Name,Related_to_Asset__r.License_Tier__c,TIGER_Payout_Rate4A__c,TIGER_Commissionable_Amount4A__c,TIGER_Commission4A__c                                                                                                     
                                                    from Commission__c where RecordType.Name !=: Commissions_Constants.RETENTION_TEAM and Related_to_Quota__c IN : quotaIds ]);
        quotaIds.clear();
        Map<id,Period__c> periodRecords = new Map<id,Period__c>([select id,Name,Start_Date__c,TP_Units_Sold__c,No_Of_Tiger_Leads__c,BOBAmount__c,
                            Tiger_Lead_Qualifier_Amount__c from Period__c where id IN : PeriodIds]);
        Map<Id,Payout__C> Payout = new Map<ID, Payout__C>([select id ,name,RecordType.Name,High_Level__c,Low_Level__c,Low_Amount__c, High_Amount__c,
                                           Commissionable__c from Payout__c where RecordType.Name in : RTNames and 
                                           Period__c In : PeriodIds Order by Low_Level__c Desc]);
       
        periodIds.clear();RTNames.clear();          
        for(Commission__c comm : commissionMap.Values()){
            relatedcommissionIds.add(comm.Related_Commission__c);
        }                
        Map<Id,Commission__c> relatedClawbackCommissions = new Map<Id,Commission__c>([select id,Name,RecordType.Name,Related_Commission__c,Related_to_Quota__c,Payout_Rate_3__c,
                                        Quota_Percentage_Achieved1__c,Payout_Rate__c,Payout_Rate1B__c,RD_Payout_Rate__c,Commissionable_Amount2__c,Commissionable_Amount1B__c,New_Sale_w_o_Qualifier_Commission__c,
                                        New_Sale_w_Qualifier_Commission__c,CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c,CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c,CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c,Commissionable_Amount3__c,Asset_Owner_Commission__c,
                                        CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c,CFCB_NEW_w_Qualifier_Payout_Rate2A__c,CFCB_New_w_o_Qualifier_Payout_Rate2B__c,CFCB_RNW_w_Qualifier_Payout_Rate2C__c,CFCB_RNW_w_o_Qualifier_Payout_Rate2D__c,
                                        CFCB_NEW_w_Qualifier_Commission2A__c,CFCB_New_w_o_Qualifier_Commission2B__c,CFCB_RNW_w_Qualifier_Commission2C__c,CFCB_RNW_w_o_Qualifier_Commission2D__c,TIGER_Payout_Rate4A__c,TIGER_Commissionable_Amount4A__c,TIGER_Commission4A__c 
                                        from commission__c where RecordType.Name !=: Commissions_Constants.RETENTION_TEAM and Id In : relatedcommissionIds]);
        relatedcommissionIds.clear();
        Map<id,commission__c> mapCommissions = new Map<id,Commission__c>();    
        for(Quota__c currentQuota : quotaMap.values()){
            period__c pr = periodRecords.get(currentQuota.Period_Name__c);
            system.debug('currentQuota 1:'+currentQuota.id);
            if(currentQuota.User_Team__c != Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM && currentQuota.User_Team__c != Commissions_Constants.MANAGERS_TEAM){
                system.debug('currentQuota 2:'+currentQuota.id);
                if((currentQuota.TP_Units_Sold_RollUp__c > = currentQuota.TP_Units_Sold__c) && (currentQuota.No_Of_Tiger_Leads_RollUp__c >= currentQuota.No_Of_Tiger_Leads__c)){
                    system.debug('currentQuota 4:'+currentQuota.id);               
                    currentQuota.Is_Kicker__c = true;                       
                }
                else{ 
                    system.debug('currentQuota 5:'+currentQuota.id);                       
                    currentQuota.Is_Kicker__c = false;                     
                }
            }            
            
            quotaPercentage = 0.0;PayoutRate1A = 0.0;PayoutRate2A = 0.0;PayoutRate2B = 0.0;PayoutRate2C = 0.0;PayoutRate2D = 0.0;PayoutRate3 = 0.0;PayoutRate4A = 0.0;
            Componet1RollUpValue = 0.0; Componet2A2BRollUpValue = 0.0; Componet2C2DRollUpValue = 0.0; CommissinableAmountComp1 =0.0;Componet4ARollUpValue = 0.0;
            TeamName= ''; OpenBookPayout = 0.0;     
            xMgr1 = 0;x1Mgr1 = 0;x2Mgr1 = 0;yMgr1 = 0;y1Mgr1 = 0;y2Mgr1 = 0;
            LowValueComp1 = 0.0; HighValueComp1 =0.0;   
            quotaPercentage = currentQuota.Quota_Percentage__c;
            Componet1RollUpValue = currentQuota.Total_Sale__c;
            Componet2A2BRollUpValue =currentQuota.Componet2A2BRollUpValue__c;
            Componet2C2DRollUpValue =currentQuota.Componet2C2DRollUpValue__c; 
            Componet4ARollUpValue =currentQuota.TIGER_Commissionable_Amount4A_RollUp__c; 
            //NEW HIRE TEAM         
            if((currentQuota.User_Team__c == Commissions_Constants.NEW_HIRE_TEAM)){
                if(currentQuota.user__r.CreatedDate.addmonths(1).month() == currentQuota.CreatedDate.month()){
                    if(currentQuota.user__r.Payout_Rate_Month_1__c != Null){
                        PayoutRate1A= (currentQuota.user__r.Payout_Rate_Month_1__c).setScale(2);
                    }
                }                    
                if(currentQuota.user__r.CreatedDate.addmonths(2).month() == currentQuota.CreatedDate.month()){
                    if(currentQuota.user__r.Payout_Rate_Month_2__c != Null){
                        PayoutRate1A= (currentQuota.user__r.Payout_Rate_Month_2__c).setScale(2);
                    }
                }                                 
                if(currentQuota.user__r.CreatedDate.addmonths(3).month() == currentQuota.CreatedDate.month()){
                    if(currentQuota.user__r.Payout_Rate_Month_3__c != Null){
                        PayoutRate1A= (currentQuota.user__r.Payout_Rate_Month_3__c).setScale(2);
                    }
                }
            }                   
            String QuotaTeam = '';
            if(currentQuota.User_Team__c == Commissions_Constants.MANAGERS_TEAM ){
                QuotaTeam = currentQuota.User__r.Name;
            }else{
                QuotaTeam = currentQuota.User_Team__c;
            }                       
            for(Payout__c pay : Payout.Values()){              
                if((QuotaTeam  == Pay.RecordType.Name) && (currentQuota.User_Team__c != Commissions_Constants.COLLECTION_TEAM && 
                    currentQuota.User_Team__c != Commissions_Constants.COLLECTIONS_CLIENT_RELATIONS_MANAGERS && 
                    currentQuota.User_Team__c != Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM)){
                    
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
                    if((CommissinableAmountComp1 != 0.0) && (CommissinableAmountComp1 >= LowValueComp1)){                                       
                        if(CommissinableAmountComp1 <= HighValueComp1) {                                       
                            if(pay.Name == Commissions_Constants.NEW_SALE_WITHOUT_QUALIFIER){                                           
                                PayoutRate1A = (pay.Commissionable__c).setScale(2);
                            }
                        }
                    }                     
                    //Calculating component 2 for all team
                    if(pay.Name == Commissions_Constants.CFCB_NEW_SALE_WITH_QUALIFIER && currentQuota.Is_Kicker__c == TRUE){
                        if((Componet2A2BRollUpValue != 0.0) && (Componet2A2BRollUpValue >= pay.Low_Amount__c)){
                            if(Componet2A2BRollUpValue <= pay.High_Amount__c) {
                                PayoutRate2A = pay.Commissionable__c;
                            }                                       
                        }
                    }                               
                    if(pay.Name == Commissions_Constants.CFCB_NEW_SALE_WITHOUT_QUALIFIER && currentQuota.Is_Kicker__c == FALSE){
                        if((Componet2A2BRollUpValue != 0.0) && (Componet2A2BRollUpValue >= pay.Low_Amount__c)){
                            if(Componet2A2BRollUpValue <= pay.High_Amount__c) {
                                PayoutRate2B = pay.Commissionable__c;
                            }                                       
                        }
                    }                                             
                    if(pay.Name == Commissions_Constants.CFCB_NEW_RENEWAL_WITH_QUALIFIER && currentQuota.Is_Kicker__c == TRUE){
                        if((Componet2C2DRollUpValue != 0.0) && (Componet2C2DRollUpValue >= pay.Low_Amount__c)){
                            if(Componet2C2DRollUpValue <= pay.High_Amount__c) {                                            
                                PayoutRate2C = pay.Commissionable__c;
                            }                                   
                        }
                    }                                            
                    if(pay.Name == Commissions_Constants.CFCB_NEW_RENEWAL_WITHOUT_QUALIFIER && currentQuota.Is_Kicker__c == FALSE){
                        if((Componet2C2DRollUpValue != 0.0) && (Componet2C2DRollUpValue >= pay.Low_Amount__c)){
                            if(Componet2C2DRollUpValue <= pay.High_Amount__c) {                                            
                                PayoutRate2D = pay.Commissionable__c;
                            }                                   
                        }
                    }                              
                    if((CommissinableAmountComp1 != 0.0) && (CommissinableAmountComp1 >= LowValueComp1)){                                       
                        if(CommissinableAmountComp1 <= HighValueComp1) {                                       
                            if(pay.Name == Commissions_Constants.ASSET_OWNER_COMPONENTS){                                           
                                PayoutRate3 = (pay.Commissionable__c).setScale(2);
                            }
                        }
                    }
                    if((Componet4ARollUpValue != 0.0) && (Componet4ARollUpValue >= LowValueComp1)){                                       
                        if(Componet4ARollUpValue <= HighValueComp1) {                                       
                            if(pay.Name == Commissions_Constants.TIGER_LEAD_SALE){                                           
                                PayoutRate4A = (pay.Commissionable__c).setScale(2);
                            }
                        }
                    }                   
                }
                       
                //**************MANAGERs TEAM ***************************                
                if(currentQuota.User_Team__c == Commissions_Constants.MANAGERS_TEAM && pay.RecordType.Name == currentQuota.User__r.Name){
                    CommissinableAmountComp1=0.0;
                    if(pay.RecordType.Name == currentQuota.User__r.Name && pay.Name == Commissions_Constants.NEW_SALE_WITHOUT_QUALIFIER){
                        if(pay.Low_Level__c == Null && pay.High_Level__c == Null){
                            LowValueComp1 = pay.Low_Amount__c;
                            CommissinableAmountComp1 = Componet1RollUpValue;                               
                        }
                        if(pay.Low_Amount__c == Null && pay.High_Amount__c == Null){
                            LowValueComp1 = pay.Low_Level__c;
                            CommissinableAmountComp1 = quotaPercentage;
                        }                               
                        if(LowValueComp1 <= CommissinableAmountComp1){
                            x1Mgr1 = 0;y1Mgr1 = 0;
                            system.debug('pay 1 : '+pay.id);
                            x1Mgr1 = pay.High_Level__c;                         
                            y1Mgr1 = pay.Commissionable__c;
                            break;                                                    
                        }
                    }
                    if(pay.RecordType.Name == currentQuota.User__r.Name && pay.Name == Commissions_Constants.NEW_SALE_WITHOUT_QUALIFIER){
                        if(pay.Low_Level__c == Null && pay.High_Level__c == Null){
                            HighValueComp1 = pay.High_Amount__c;
                            CommissinableAmountComp1 = Componet1RollUpValue;                              
                        }
                        if(pay.Low_Amount__c == Null && pay.High_Amount__c == Null){
                            HighValueComp1 = pay.High_Level__c;
                            CommissinableAmountComp1 = quotaPercentage;
                        }
                        if(HighValueComp1 >= CommissinableAmountComp1){                                
                            x2Mgr1 = 0.0;y2Mgr1=0.0;
                            x2Mgr1 = pay.Low_Level__c;  
                            y2Mgr1 = pay.Commissionable__c;
                            system.debug('pay 2 : '+pay.id);
                        }
                    }                    
                    system.debug('xMgr1 >> 1:'+xMgr1);
                    system.debug('x1Mgr1 >> 1:'+x1Mgr1); 
                    system.debug('x2Mgr1 >> 1:'+x2Mgr1);                
                    system.debug('y1Mgr1 >> 1:'+y1Mgr1);
                    system.debug('y2Mgr1 >> 1:'+y2Mgr1);                              
                    xMgr1 = quotaPercentage;                           
                    denominator = (x2Mgr1-x1Mgr1)*(xMgr1-x1Mgr1);
                    if(denominator != 0){
                        yMgr1 = ((y2Mgr1-y1Mgr1)/(denominator))+y1Mgr1;
                    }
                    system.debug('yMgr1 >> :'+yMgr1);                
                    if(xMgr1 <= 65.00 ){
                        yMgr1 = 0.00;
                        PayoutRate1A = YMgr1.setScale(2);
                    }
                    if(xMgr1 >= 65.01 ){
                        PayoutRate1A = YMgr1.setScale(2);
                    }
                }   
                //Openbook                
                if((currentQuota.User_team__c == Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM || (currentQuota.User_team__c == Commissions_Constants.COLLECTION_TEAM || 
                    currentQuota.User_team__c == Commissions_Constants.COLLECTIONS_CLIENT_RELATIONS_MANAGERS))){ 
                    if(currentQuota.User_team__c == Commissions_Constants.COLLECTION_TEAM || currentQuota.User_team__c == Commissions_Constants.COLLECTIONS_CLIENT_RELATIONS_MANAGERS){
                        if(currentQuota.Collection_Target_Amount__c != 0.0){
                            quotaPercentage = ((currentQuota.Collection_Total_Sale__c)/(currentQuota.Collection_Target_Amount__c))*100;
                            TeamName = Commissions_Constants.NEW_SALE_WITH_QUALIFIER;
                        }
                    }else{
                        //quotaPercentage = ((currentQuota.OpenBook_New_Sale_Comm_ble_Amount__c)/(currentQuota.Target_Amount__c))*100;
                        TeamName = Commissions_Constants.OPEN_SALE_COMPONENT;
                    }                 
                    if((currentQuota.User_Team__c == pay.RecordType.Name)){
                        if(pay.Low_Level__c == Null && pay.High_Level__c == Null){
                            LowValueComp1 = pay.Low_Amount__c;
                            HighValueComp1 = pay.High_Amount__c;
                            CommissinableAmountComp1 = quotaPercentage;                                
                        }
                        if(pay.Low_Amount__c == Null && pay.High_Amount__c == Null){
                            LowValueComp1 = pay.Low_Level__c;
                            HighValueComp1 = pay.High_Level__c;
                            CommissinableAmountComp1 = quotaPercentage;
                        }                            
                        if((CommissinableAmountComp1 >= LowValueComp1)){
                            if(CommissinableAmountComp1 <= HighValueComp1) {
                                if(pay.Name == TeamName){ 
                                    if(currentQuota.User_team__c == Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM){
                                        OpenBookPayout = (pay.Commissionable__c).setScale(6);
                                    }                                   
                                }
                            }
                        }
                    }                               
                }   
            } 
            Payout.clear();
            system.debug('PayoutRate1A :'+PayoutRate1A);
            //system.debug('PayoutRate1B :'+PayoutRate1B);
            system.debug('PayoutRate2A :'+PayoutRate2A);
            system.debug('PayoutRate2B :'+PayoutRate2B);
            system.debug('PayoutRate2C :'+PayoutRate2C);
            system.debug('PayoutRate2D :'+PayoutRate2D);
            system.debug('PayoutRate3 :'+PayoutRate3);
            system.debug('PayoutRate4A :'+PayoutRate4A);
            system.debug('OpenBookPayout :'+OpenBookPayout);
            
            for(Commission__c commissionRecord : commissionMap.Values()){                
                if(((commissionRecord.RecordType.Name != Commissions_Constants.COMMISSIONS_CLAWBACK) || (commissionRecord.RecordType.Name == Commissions_Constants.COMMISSIONS_CLAWBACK && commissionRecord.Related_Commission__c == Null)) && (commissionRecord.Related_to_Quota__c == currentQuota.id)){  
                    commissionRecord.Quota_Percentage_Achieved1__c = currentQuota.Quota_Percentage__c;
                    if((commissionRecord.Commissionable_Amount2__c != 0.0 && commissionRecord.Commissionable_Amount2__c != Null)){       
                        commissionRecord.Payout_rate__c = PayoutRate1A.setScale(2);                                    
                        commissionRecord.New_Sale_w_o_Qualifier_Commission__c = (commissionRecord.Payout_Rate__c * commissionRecord.Commissionable_Amount2__c)/100;
                    }
                    if(commissionRecord.Commissionable_Amount3__c != 0.0 && commissionRecord.Commissionable_Amount3__c != Null){                                    
                        commissionRecord.Payout_Rate_3__c = PayoutRate3.setScale(2);                                         
                        commissionRecord.Asset_Owner_Commission__c = (commissionRecord.Commissionable_Amount3__c * commissionRecord.Payout_Rate_3__c)/100;
                        mapCommissions.put(commissionRecord.id,commissionRecord); 
                    }
                    if(commissionRecord.TIGER_Commissionable_Amount4A__c != 0.0 && commissionRecord.TIGER_Commissionable_Amount4A__c != Null){                                    
                        commissionRecord.TIGER_Payout_Rate4A__c = PayoutRate4A.setScale(2);                                         
                        commissionRecord.TIGER_Commission4A__c = (commissionRecord.TIGER_Commissionable_Amount4A__c * commissionRecord.TIGER_Payout_Rate4A__c)/100;
                        mapCommissions.put(commissionRecord.id,commissionRecord); 
                    }
                    //RD Open and Collection Team
                    if(commissionRecord.OpenBook_New_Sale_Comm_ble_Amount__c != 0.0 && commissionRecord.OpenBook_New_Sale_Comm_ble_Amount__c != Null){
                        if(commissionRecord.User_Team__c == Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM || commissionRecord.User_Team__c == Commissions_Constants.COLLECTION_TEAM || commissionRecord.User_Team__c == Commissions_Constants.COLLECTIONS_CLIENT_RELATIONS_MANAGERS){
                            commissionRecord.OpenBook_New_Sale_Payout__c = OpenBookPayout.setScale(2);
                            commissionRecord.OpenBook_New_Sale_Commission__c = (commissionRecord.OpenBook_New_Sale_Comm_ble_Amount__c * commissionRecord.OpenBook_New_Sale_Payout__c)/100;
                        }
                        else{
                            commissionRecord.OpenBook_New_Sale_Payout__c = PayoutRate1A.setScale(2);
                            commissionRecord.OpenBook_New_Sale_Commission__c = (commissionRecord.OpenBook_New_Sale_Comm_ble_Amount__c * commissionRecord.OpenBook_New_Sale_Payout__c)/100;
                        }
                    }                               
                    if(commissionRecord.Product__r.Commission_Category__c == 'CFCB'){
                        if(currentQuota.Is_Kicker__c == TRUE && commissionRecord.Related_to_Asset__r.Renewal_Type__c == NULL){
                            if(commissionRecord.CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c == 0.0){
                                commissionRecord.CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c = commissionRecord.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c;
                            }
                            if(commissionRecord.CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c != 0.0 && commissionRecord.CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c != Null){
                                commissionRecord.CFCB_NEW_w_Qualifier_Payout_Rate2A__c = (PayoutRate2A).setScale(2);
                                commissionRecord.CFCB_NEW_w_Qualifier_Commission2A__c = (commissionRecord.CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c * commissionRecord.CFCB_NEW_w_Qualifier_Payout_Rate2A__c)/100;
                                commissionRecord.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c = 0.0;
                                commissionRecord.CFCB_New_w_o_Qualifier_Commission2B__c = 0.0;
                                commissionRecord.CFCB_New_w_o_Qualifier_Payout_Rate2B__c = 0.0;
                            }
                        }
                        if(currentQuota.Is_Kicker__c == FALSE && commissionRecord.Related_to_Asset__r.Renewal_Type__c == NULL){
                            if(commissionRecord.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c == 0.0){
                                commissionRecord.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c = commissionRecord.CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c;
                            }
                            if(commissionRecord.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c != 0.0 && commissionRecord.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c != Null){
                                commissionRecord.CFCB_New_w_o_Qualifier_Payout_Rate2B__c = (PayoutRate2B).setScale(2);
                                commissionRecord.CFCB_New_w_o_Qualifier_Commission2B__c = (commissionRecord.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c * commissionRecord.CFCB_New_w_o_Qualifier_Payout_Rate2B__c)/100;
                                commissionRecord.CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c = 0.0;
                                commissionRecord.CFCB_NEW_w_Qualifier_Payout_Rate2A__c =0.0;
                                commissionRecord.CFCB_NEW_w_Qualifier_Commission2A__c=0.0;
                            }
                        }
                        if(currentQuota.Is_Kicker__c == TRUE && (commissionRecord.Related_to_Asset__r.Renewal_Type__c == 'Auto' || commissionRecord.Related_to_Asset__r.Renewal_Type__c == 'Manual')){
                            if(commissionRecord.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c == 0.0){
                                commissionRecord.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c = commissionRecord.CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c;
                            }
                            if(commissionRecord.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c != 0.0 && commissionRecord.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c != Null){
                                commissionRecord.CFCB_RNW_w_Qualifier_Payout_Rate2C__c = (PayoutRate2C).setScale(2);
                                commissionRecord.CFCB_RNW_w_Qualifier_Commission2C__c = (commissionRecord.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c * commissionRecord.CFCB_RNW_w_Qualifier_Payout_Rate2C__c)/100;
                                commissionRecord.CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c = 0.0;
                                commissionRecord.CFCB_RNW_w_o_Qualifier_Payout_Rate2D__c = 0.0;
                                commissionRecord.CFCB_RNW_w_o_Qualifier_Commission2D__c = 0.0;
                            }
                        }
                        if(currentQuota.Is_Kicker__c == FALSE && (commissionRecord.Related_to_Asset__r.Renewal_Type__c == 'Auto' || commissionRecord.Related_to_Asset__r.Renewal_Type__c == 'Manual')){
                            if(commissionRecord.CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c == 0.0){
                                commissionRecord.CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c = commissionRecord.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c;
                            }
                            if(commissionRecord.CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c != 0.0 && commissionRecord.CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c!= Null){
                                commissionRecord.CFCB_RNW_w_o_Qualifier_Payout_Rate2D__c = PayoutRate2D.setScale(2);
                                commissionRecord.CFCB_RNW_w_o_Qualifier_Commission2D__c = (commissionRecord.CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c * commissionRecord.CFCB_RNW_w_o_Qualifier_Payout_Rate2D__c)/100;
                                commissionRecord.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c = 0.0;
                                commissionRecord.CFCB_RNW_w_Qualifier_Payout_Rate2C__c =0.0;
                                commissionRecord.CFCB_RNW_w_Qualifier_Commission2C__c=0.0;
                            }
                        }
                    }                            
                    if(commissionRecord.OpenBook_New_Sale_Comm_ble_Amount__c != Null && commissionRecord.OpenBook_New_Sale_Comm_ble_Amount__c != 0.0 && commissionRecord.User_Team__c != Commissions_Constants.BROKER_REGIONAL_DIRECTORS_SALES_TEAM  ){
                        if(commissionRecord.id != commissionRecord.id && commissionRecord.User_team__c != Commissions_Constants.COLLECTION_TEAM && commissionRecord.User_team__c != Commissions_Constants.COLLECTIONS_CLIENT_RELATIONS_MANAGERS){
                            if(commissionRecord.Payout_rate__c != 0.0 || commissionRecord.Payout_rate__c != Null){
                                commissionRecord.OpenBook_New_Sale_Payout__c = (commissionRecord.Payout_rate__c);
                            }
                            if(commissionRecord.Payout_Rate1B__c != 0.0 || commissionRecord.Payout_Rate1B__c != Null){
                                commissionRecord.OpenBook_New_Sale_Payout__c = (commissionRecord.Payout_Rate1B__c);
                            }
                            if(commissionRecord.Payout_Rate_3__c != 0.0 || commissionRecord.Payout_Rate_3__c != Null){
                                commissionRecord.OpenBook_New_Sale_Payout__c = (commissionRecord.Payout_Rate_3__c);
                            }
                            commissionRecord.OpenBook_New_Sale_Commission__c = (commissionRecord.OpenBook_New_Sale_Payout__c * commissionRecord.OpenBook_New_Sale_Comm_ble_Amount__c)/100;                                 
                        }                                                              
                    }                   
                    mapCommissions.put(commissionRecord.id,commissionRecord);                   
                }               
                if(commissionRecord.RecordType.Name == Commissions_Constants.COMMISSIONS_CLAWBACK && commissionRecord.Related_Commission__c != Null){
                    commission__c relatedCommission = relatedClawbackCommissions.get(commissionRecord.Related_Commission__c);
                    if(relatedCommission != Null){
                        commissionRecord.Quota_Percentage_Achieved1__c = relatedCommission.Quota_Percentage_Achieved1__c;
                        if(commissionRecord.User_Team__c != Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM){
                            if(relatedCommission.Payout_Rate__c != Null && relatedCommission.Payout_Rate__c != 0.0){                  
                                commissionRecord.Payout_rate__c = (relatedCommission.Payout_rate__c);
                                if(commissionRecord.Commissionable_Amount2__c != 0.0 &&commissionRecord.Commissionable_Amount2__c!= Null){
                                    commissionRecord.New_Sale_w_o_Qualifier_Commission__c = (commissionRecord.Payout_Rate__c * commissionRecord.Commissionable_Amount2__c)/100;
                                    mapCommissions.put(commissionRecord.id,commissionRecord);
                                }                              
                            }
                            if(relatedCommission.TIGER_Payout_Rate4A__c != Null && relatedCommission.TIGER_Payout_Rate4A__c != 0.0){                  
                                commissionRecord.TIGER_Payout_Rate4A__c = (relatedCommission.TIGER_Payout_Rate4A__c);
                                if(commissionRecord.TIGER_Commissionable_Amount4A__c != 0.0 && commissionRecord.TIGER_Commissionable_Amount4A__c!= Null){
                                    commissionRecord.TIGER_Commission4A__c = (commissionRecord.TIGER_Payout_Rate4A__c * commissionRecord.TIGER_Commissionable_Amount4A__c)/100;
                                    mapCommissions.put(commissionRecord.id,commissionRecord);
                                }                               
                            }                                         
                            
                            if(relatedCommission.Payout_Rate_3__c != Null && relatedCommission.Payout_Rate_3__c != 0.0){                  
                                commissionRecord.Payout_Rate_3__c = (relatedCommission.Payout_Rate_3__c);
                                if(commissionRecord.Commissionable_Amount3__c != 0.0 &&commissionRecord.Commissionable_Amount3__c != Null){
                                    commissionRecord.Asset_Owner_Commission__c = (commissionRecord.Payout_Rate_3__c * commissionRecord.Commissionable_Amount3__c)/100;                                        
                                    mapCommissions.put(commissionRecord.id,commissionRecord);
                                }                               
                            }                       
                        }
                        if(commissionRecord.User_Team__c == Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM){
                            if(relatedCommission.RD_Payout_Rate__c != Null && relatedCommission.RD_Payout_Rate__c != 0.0){                  
                                commissionRecord.Payout_rate__c = (relatedCommission.Payout_rate__c);
                                commissionRecord.Payout_Rate1B__c = (relatedCommission.Payout_Rate1B__c);
                                if(commissionRecord.Commissionable_Amount2__c != 0.0 &&commissionRecord.Commissionable_Amount2__c!= Null){
                                    commissionRecord.New_Sale_w_o_Qualifier_Commission__c = (commissionRecord.RD_Payout_Rate__c * commissionRecord.Commissionable_Amount2__c)/100;
                                    mapCommissions.put(commissionRecord.id,commissionRecord);
                                }
                                if(commissionRecord.Commissionable_Amount1B__c != 0.0 &&commissionRecord.Commissionable_Amount1B__c!= Null){                              
                                    commissionRecord.New_Sale_w_Qualifier_Commission__c = (commissionRecord.RD_Payout_Rate__c * commissionRecord.Commissionable_Amount1B__c)/100;                                        
                                    mapCommissions.put(commissionRecord.id,commissionRecord);
                                }   
                            }
                        }
                        if(commissionRecord.Product__r.Commission_Category__c == 'CFCB'){  
                            if(relatedCommission.CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c != 0.0 && relatedCommission.CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c != Null){
                                commissionRecord.CFCB_NEW_w_Qualifier_Payout_Rate2A__c = (relatedCommission.CFCB_NEW_w_Qualifier_Payout_Rate2A__c);
                                commissionRecord.CFCB_NEW_w_Qualifier_Commission2A__c = (commissionRecord.CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c * commissionRecord.CFCB_NEW_w_Qualifier_Payout_Rate2A__c)/100;                                        
                                mapCommissions.put(commissionRecord.id,commissionRecord);
                            }
                            if(relatedCommission.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c != 0.0 && relatedCommission.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c != Null){
                                commissionRecord.CFCB_New_w_o_Qualifier_Payout_Rate2B__c = (relatedCommission.CFCB_New_w_o_Qualifier_Payout_Rate2B__c);
                                commissionRecord.CFCB_New_w_o_Qualifier_Commission2B__c = (commissionRecord.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c * commissionRecord.CFCB_New_w_o_Qualifier_Payout_Rate2B__c)/100;                                   
                                mapCommissions.put(commissionRecord.id,commissionRecord);
                            }
                            if(relatedCommission.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c != 0.0 && relatedCommission.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c != Null){
                                commissionRecord.CFCB_RNW_w_Qualifier_Payout_Rate2C__c = (relatedCommission.CFCB_RNW_w_Qualifier_Payout_Rate2C__c);
                                commissionRecord.CFCB_RNW_w_Qualifier_Commission2C__c = (commissionRecord.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c * commissionRecord.CFCB_RNW_w_Qualifier_Payout_Rate2C__c)/100;                                 
                                mapCommissions.put(commissionRecord.id,commissionRecord);
                            }
                            if(relatedCommission.CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c != 0.0 && relatedCommission.CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c != Null){
                                commissionRecord.CFCB_RNW_w_o_Qualifier_Payout_Rate2D__c = (relatedCommission.CFCB_RNW_w_o_Qualifier_Payout_Rate2D__c);
                                commissionRecord.CFCB_RNW_w_o_Qualifier_Commission2D__c = (commissionRecord.CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c * commissionRecord.CFCB_RNW_w_o_Qualifier_Payout_Rate2D__c)/100;                                   
                                mapCommissions.put(commissionRecord.id,commissionRecord);
                            }                                                       
                        }                        
                    }
                }                
            }
            currentQuota.Record_Processed__c = true;
            quotaMap.put(currentQuota.id,currentQuota);
            commissionMap.clear();
        }                
        //commissionMap.clear();       
        if(mapCommissions.size() > 0){
            update mapCommissions.Values();
            update quotaMap.values();               
        }        
        System.debug(LoggingLevel.ERROR, 'Heap Size: ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize());
        mapCommissions.clear();quotaIds.clear();relatedcommissionIds.clear();periodRecords.clear();
        periodIds.clear();commissionMap.clear();Payout.clear();relatedClawbackCommissions.clear();mapCommissions.clear();
        quotaMap.clear();updateQuota.clear();
    }
}