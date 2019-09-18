Public class Commissions_QuotaTriggerHandler{
    Public void Kicker(Map<Id,Quota__c> KickerQuotas){
        Decimal QualifierAmount = 0.00;  Decimal BOBAmount = 0.00;
        Set<Id> QuotaIds = new set<Id>();
        Set<Id> PeriodIds = new set<Id>();
        Map<Id,Quota__c> updateQuota = new Map<Id,Quota__c>();
        updateQuota.clear();
        for(Quota__c Quota : KickerQuotas.Values()){
            quotaIds.add(Quota.id);
            PeriodIds.add(Quota.Period_Name__c);
        }
        System.debug(LoggingLevel.ERROR, 'Heap Size Kicker Loop >>: ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize());
        
        Map<Id,Commission__c> topProducerCommissions = new Map<id,Commission__c>([select id,Name,Other_Product__c,Product__r.Commission_Category__c,
                    Related_to_Asset__c,Related_to_Asset__r.Fulfillment_Status__c,Related_to_Asset__r.Name,Related_to_Quota__c,OpenBook_New_Sale_Comm_ble_Amount__c,
                    Payout_Rate__c,Payout_Rate1B__c,Payout_Rate_3__c,Commissionable_Amount1B__c,Commissionable_Amount2__c,TIGER_Commissionable_Amount4A__c from Commission__c where 
                    Related_to_Quota__c In : quotaIds]);          
        Map<id,Period__c> periodRecords = new Map<id,Period__c>([select id,Name,Start_Date__c,TP_Units_Sold__c,No_Of_Tiger_Leads__c,BOBAmount__c,
                            Tiger_Lead_Qualifier_Amount__c from Period__c where id IN : PeriodIds]); 
        
        for(Quota__c quota : KickerQuotas.Values()){           
            if(Quota.User_Team__c == Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM){
                period__c pr = periodRecords.get(quota.Period_Name__c);
                if((pr != Null) && (quota.QualifierAmount_RollUp__c >=  pr.Tiger_Lead_Qualifier_Amount__c && quota.BOBAmount_RollUp__c >= pr.BOBAmount__c)){
                    Quota.RD_Team_Qualifier__c = True;
                }
                else{
                    Quota.RD_Team_Qualifier__c = false;
                }                    
                //RD Total Commission Calculation
                for(Commission__c comm : topProducerCommissions.Values()){  
                    if(quota.id == comm.Related_to_Quota__c && (comm.OpenBook_New_Sale_Comm_ble_Amount__c == 0.0 || comm.OpenBook_New_Sale_Comm_ble_Amount__c == NULL) ){                           
                        if(comm.Payout_Rate__c != Null && comm.Payout_Rate__c != 0.0){                                   
                            Quota.RD_Total_Commission__c = (Quota.RD_Payout__c * comm.Payout_Rate__c)/100;                                    
                        }
                        if(comm.Payout_Rate1B__c != Null && comm.Payout_Rate1B__c != 0.0){                                  
                            Quota.RD_Total_Commission__c = (Quota.RD_Payout__c * comm.Payout_Rate1B__c)/100;
                        }
                        if(comm.Payout_Rate_3__c != Null && comm.Payout_Rate_3__c != 0.0){                                    
                            Quota.RD_Total_Commission__c = (Quota.RD_Payout__c * comm.Payout_Rate_3__c)/100;
                        }
                        updateQuota.put(Quota.Id,Quota);
                        Break;
                    }                    
                }
                updateQuota.put(Quota.Id,Quota);
            }
        }
        system.debug('updateQuota : '+updateQuota);
        System.debug(LoggingLevel.ERROR, 'Heap Size Kicker Loop 1: ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize()); 
        QuotaIds.clear();topProducerCommissions.clear(); KickerQuotas.clear(); periodRecords.clear();PeriodIds.clear();
        System.debug(LoggingLevel.ERROR, 'Heap Size Kicker Loop 2: ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize());                            
    }
    
    public void RDTeamSplitRatio(Map<id,Quota__c> RDQuotas){       
        Set<Id> RDQuotaIds = new set<Id>();
        Set<Id> PeriodIds = new set<Id>();
        for(Quota__c Q : RDQuotas.Values()){
            RDQuotaIds.add(Q.id);
            PeriodIds.add(Q.Period_Name__c);
        }
        Map<id,commission__c> RDCommissions = new Map<id,commission__c>();
        system.debug('RDCommissions 1: '+RDCommissions);
        if(RDQuotas.size() > 0){
            Map<Id,Commission__c> RDPayoutCommissions = new Map<id,Commission__c>([select id,Name,RD_Split_Ratio__c,Related_to_Quota__c,Commissionable_Amount2__c,Commissionable_Amount1B__c,
                                                        Commissionable_Amount3__c,Payout_Rate__c,Payout_Rate1B__c,Payout_Rate_3__c,New_Sale_w_o_Qualifier_Commission__c,New_Sale_w_Qualifier_Commission__c,
                                                        Asset_Owner_Commission__c,OpenBook_New_Sale_Comm_ble_Amount__c,OpenBook_New_Sale_Commission__c 
                                                        from Commission__c where Related_to_Quota__c In : RDQuotaIds]);
            for(Quota__c Quota : RDQuotas.Values()){                
                for(commission__c comm : RDPayoutCommissions.values()){ 
                    if(quota.id == comm.Related_to_Quota__c && quota.Total_Sale__c != null && quota.Total_Sale__c !=0.0 && quota.RD_Total_Commission__c!= Null && (comm.OpenBook_New_Sale_Comm_ble_Amount__c == 0.0 || comm.OpenBook_New_Sale_Comm_ble_Amount__c == NULL)){                       
                        if(comm.Commissionable_Amount2__c !=0.0 && comm.Commissionable_Amount2__c != Null ){                            
                            comm.RD_Split_Ratio__c = (comm.Commissionable_Amount2__c / quota.Total_Sale__c).setScale(6);                           
                            system.debug('Ratio 1: '+comm.Name);
                            system.debug('Ratio 2: '+comm.RD_Split_Ratio__c);
                            system.debug('Ratio 3: '+quota.RD_Total_Commission__c);
                            comm.New_Sale_w_o_Qualifier_Commission__c = (comm.RD_Split_Ratio__c * quota.RD_Total_Commission__c);                           
                            RDCommissions.put(comm.id,comm);
                        }
                        if(comm.Commissionable_Amount1B__c != 0.0 && comm.Commissionable_Amount1B__c != Null){
                            
                            comm.RD_Split_Ratio__c = (comm.Commissionable_Amount1B__c / quota.Total_Sale__c).setScale(6);
                            comm.New_Sale_w_Qualifier_Commission__c =  (comm.RD_Split_Ratio__c * quota.RD_Total_Commission__c);
                            RDCommissions.put(comm.id,comm);
                            system.debug('Ratio 1: '+comm.Name);
                            system.debug('Ratio 2: '+comm.RD_Split_Ratio__c);
                            system.debug('Ratio 3: '+quota.RD_Total_Commission__c);
                        }
                        if(comm.Commissionable_Amount3__c != 0.0 && comm.Commissionable_Amount3__c != Null){
                            comm.RD_Split_Ratio__c = (comm.Commissionable_Amount3__c / quota.Total_Sale__c).setScale(6);
                            comm.Asset_Owner_Commission__c = (comm.RD_Split_Ratio__c * quota.RD_Total_Commission__c);                           
                            RDCommissions.put(comm.id,comm);
                        }
                        if(comm.OpenBook_New_Sale_Comm_ble_Amount__c != 0.0 && comm.OpenBook_New_Sale_Comm_ble_Amount__c != Null){
                            comm.RD_Split_Ratio__c = (comm.OpenBook_New_Sale_Comm_ble_Amount__c / quota.Total_Sale__c).setScale(6);
                            comm.OpenBook_New_Sale_Commission__c = (comm.RD_Split_Ratio__c * quota.RD_Total_Commission__c);
                            RDCommissions.put(comm.id,comm);
                        }            
                    }
                }
            }      
            Map<Id,Payout__c> pay1 = new Map<ID, Payout__c>([select id, name, Low_level__c, High_Level__c,Low_Amount__c,High_Amount__c, Commissionable__c, RecordType.Name from Payout__c 
                                                where Period__c In : PeriodIds and (RecordType.Name =: Commissions_Constants.BROKER_REGIONAL_DIRECTORS_SALES_TEAM ) ORDER BY High_Level__c DESC ]);
            Decimal quotaPercentage ;Decimal y  = 0; Decimal yf  = 0;
            Decimal CommissionableAmount1A; Decimal CommissionableAmount1B;
            Decimal x  = 0;   Decimal x1 = 0;   Decimal x2 = 0;   Decimal y1 = 0;   Decimal y2 = 0;  
            Decimal xf = 0;   Decimal x1f = 0;  Decimal x2f = 0;  Decimal y1f = 0;  Decimal y2f = 0;
            Decimal lowAmountRD; Decimal highAmountRD; Decimal lowValueRD ; Decimal highValueRD ;  Decimal CommissinableAmountCompRD;
            Decimal lowAmountRDf; Decimal highAmountRDf; Decimal lowValueRDf ; Decimal highValueRDf ; Decimal CommissinableAmountCompRDf;
            for(Quota__c quota : RDQuotas.Values()){
                x  = 0; x1 = 0;  x2 = 0;  y1 = 0;  y2 = 0;  
                xf = 0; x1f = 0; x2f = 0; y1f = 0; y2f = 0;
                lowAmountRD = 0; highAmountRD = 0; lowValueRD =0;highValueRD =0;CommissinableAmountCompRD=0;
                lowAmountRDf = 0; highAmountRDf=0; lowValueRDf=0 ; highValueRDf =0; CommissinableAmountCompRDf=0;               
                if((Quota.User_Team__c == Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM)){          
                    for(Payout__c p : pay1.Values()){                                
                        if(Quota.User_Team__c == p.Recordtype.Name && quota.RD_Team_Qualifier__c == TRUE){                                
                            if(p.Name ==Commissions_Constants.NEW_SALE_WITH_QUALIFIER){                                        
                                if(p.Low_Level__c == Null && p.High_Level__c == Null){
                                    lowValueRD = p.Low_Amount__c;
                                    CommissinableAmountCompRD = Quota.Total_Sale__c;
                                }
                                if(p.Low_Amount__c == Null && p.High_Amount__c == Null){
                                    lowValueRD = p.Low_Level__c;
                                    CommissinableAmountCompRD = Quota.Quota_Percentage__c;
                                }
                                if(lowValueRD <= CommissinableAmountCompRD){                                
                                    system.debug('>>> pay 1  : '+p.Id);
                                    x1 = p.High_Level__c;                         
                                    y1 = p.Commissionable__c;
                                    break;                               
                                }
                            }
                        }
                        if(Quota.User_Team__c == p.Recordtype.Name && quota.RD_Team_Qualifier__c == FALSE){                                
                            if(p.Name ==Commissions_Constants.NEW_SALE_WITHOUT_QUALIFIER){                                        
                                if(p.Low_Level__c == Null && p.High_Level__c == Null){
                                    lowValueRDf = p.Low_Amount__c;
                                    CommissinableAmountCompRDf = Quota.Total_Sale__c;
                                }
                                if(p.Low_Amount__c == Null && p.High_Amount__c == Null){
                                    lowValueRDf = p.Low_Level__c;
                                    CommissinableAmountCompRDf = Quota.Quota_Percentage__c;
                                }
                                if(lowValueRDf <= CommissinableAmountCompRDf){                                
                                    system.debug('>>> pay 2  : '+p.Id);
                                    x1f = p.High_Level__c;                         
                                    y1f = p.Commissionable__c;
                                    break;                               
                                }
                            }
                        }      
                    }                        
                    for(Payout__c p : pay1.Values()){
                        if(Quota.User_Team__c == p.Recordtype.Name && quota.RD_Team_Qualifier__c == TRUE){
                            if(p.Name == Commissions_Constants.NEW_SALE_WITH_QUALIFIER ){
                                if(p.Low_Level__c == Null && p.High_Level__c == Null){
                                    highValueRD = p.High_Amount__c;
                                    CommissinableAmountCompRD = Quota.Total_Sale__c;                             
                                }
                                if(p.Low_Amount__c == Null && p.High_Amount__c == Null){
                                    highValueRD = p.High_Level__c;
                                    CommissinableAmountCompRD = Quota.Quota_Percentage__c;
                                }
                                if(highValueRD >= CommissinableAmountCompRD){                                
                                    system.debug('>>> pay 3  : '+p.Id);
                                    x2 = p.Low_Level__c;  
                                    y2 = p.Commissionable__c;                                    
                                }
                            }
                        }
                        if(Quota.User_Team__c == p.Recordtype.Name && quota.RD_Team_Qualifier__c == FALSE){
                            if(p.Name == Commissions_Constants.NEW_SALE_WITHOUT_QUALIFIER){
                                if(p.Low_Level__c == Null && p.High_Level__c == Null){
                                    highValueRDf = p.High_Amount__c;
                                    CommissinableAmountCompRDf = Quota.Total_Sale__c;                             
                                }
                                if(p.Low_Amount__c == Null && p.High_Amount__c == Null){
                                    highValueRDf = p.High_Level__c;
                                    CommissinableAmountCompRDf = Quota.Quota_Percentage__c;
                                }
                                if(highValueRDf >= CommissinableAmountCompRDf){                                
                                    system.debug('>>> pay 4  : '+p.Id);
                                    x2f = p.Low_Level__c;  
                                    y2f = p.Commissionable__c; 
                                }
                            }
                        }  
                    }                            
                }
                system.debug('>>> x  : '+x);
                system.debug('>>> y  : '+y);
                system.debug('>>> x1 : '+x1);
                system.debug('>>> x2 : '+x2);
                system.debug('>>> y1 : '+y1);
                system.debug('>>> y2 : '+y2);                                           
                x = CommissinableAmountCompRD;
                   
                system.debug('>>> xf : '+xf);
                system.debug('>>> yf : '+yf);
                system.debug('>>> x1f : '+x1f);
                system.debug('>>> x2f : '+x2f);
                system.debug('>>> y1f : '+y1f);
                system.debug('>>> y2f : '+y2f);
                   
                xf = CommissinableAmountCompRDf;                    
                try{
                    if(quota.RD_Team_Qualifier__c == TRUE){
                        y = ((y2-y1)/(x2-x1)*(x-x1))+y1;
                    }
                    if(quota.RD_Team_Qualifier__c == FALSE){
                        yf = ((y2f-y1f)/(x2f-x1f)*(xf-x1f))+y1f;
                    }
                }                       
                catch(Exception e){}
                system.debug('y >> : '+y);
                system.debug('yf >> :'+yf);
                       
                for(Commission__c comm : RDPayoutCommissions.Values()){
                    CommissionableAmount1A =0.0; CommissionableAmount1B = 0.0;                
                    if(Quota.id == comm.Related_to_Quota__c && quota.RD_Team_Qualifier__c == true){                    
                        comm.Quota_Percentage_Achieved1__c = Quota.Quota_Percentage__c;
                        comm.Payout_Rate1B__c = Y.setScale(6);               
                        if(comm.Commissionable_Amount1B__c == 0.0){
                            comm.Commissionable_Amount1B__c = comm.Commissionable_Amount2__c;
                        }                   
                        //comm.New_Sale_w_Qualifier_Commission__c = (comm.RD_Split_Ratio__c * quota.RD_Total_Commission__c)/100;  
                        comm.Commissionable_Amount2__c = 0.0 ;                                        
                        comm.New_Sale_w_o_Qualifier_Commission__c = 0.0;
                        comm.Payout_Rate__c = 0.0;            
                        RDCommissions.put(comm.id,comm);                          
                    }                    
                    if(Quota.id == comm.Related_to_Quota__c && quota.RD_Team_Qualifier__c == false){ 
                        comm.Quota_Percentage_Achieved1__c = Quota.Quota_Percentage__c;
                        comm.Payout_Rate__c = Yf.setScale(6);                   
                        system.debug('comm.Payout_Rate__c : '+comm.Name);                       
                        if(comm.Commissionable_Amount2__c== 0.0){
                            comm.Commissionable_Amount2__c = comm.Commissionable_Amount1B__c;
                        }          
                        //comm.New_Sale_w_o_Qualifier_Commission__c = (comm.RD_Split_Ratio__c * quota.RD_Total_Commission__c)/1000;        
                        comm.Payout_Rate1B__c = 0.0;
                        comm.Commissionable_Amount1B__c = 0.0;
                        comm.New_Sale_w_Qualifier_Commission__c = 0.0;           
                        RDCommissions.put(comm.id,comm);                          
                    }                                  
                }                           
            }
            if(RDCommissions.size() > 0){
                system.debug('RDCommissions 2: '+RDCommissions);
                 if(Commissions_TriggerHelperClass.quotaTriggerRDCheck1 == false){
                    Commissions_TriggerHelperClass.quotaTriggerRDCheck1 = true;
                    update RDCommissions.values();                      
                }
            }
            System.debug(LoggingLevel.ERROR, 'Heap Size RD Loop 1: ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize()); 
            RDQuotas.clear();RDCommissions.clear();RDPayoutCommissions.clear();RDQuotaIds.clear();PeriodIds.clear();pay1.clear();
            System.debug(LoggingLevel.ERROR, 'Heap Size RD Loop 2: ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize());            
        }     
    }
}