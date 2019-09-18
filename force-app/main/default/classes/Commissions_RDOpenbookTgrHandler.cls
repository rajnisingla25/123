Public class Commissions_RDOpenbookTgrHandler{
    Public void openBookCommission(Map<Id,commission__c> commissionMap){        
        set<Id> quotaIds = new set<id>();
        set<Id> periodIds = new set<id>();
        system.debug('commissionMap : '+commissionMap);
        for(commission__c commission : commissionMap.Values()){
            quotaIds.add(commission.Related_to_Quota__c);                    
        }
        Map<Id,Quota__c> quotaMap = new Map<id,Quota__c>([select id,Name,User__c,Target_Amount__c,Total_Sale__c,RD_Team_Qualifier__c,Quota_Percentage__c,
                    Period_Name__c,Current_Quater__c from Quota__c where id IN : QuotaIds]);
        for(Quota__c Quota : quotaMap.Values()){           
            periodIds.add(Quota.Period_Name__c);              
        }
        system.debug('periodIds: '+periodIds);
        Map<Id,Commission__c> commissionMapupdate = new Map<Id,Commission__c>();
        /*Map<Id,Payout__C> Payout = new Map<ID, Payout__C>([select id ,name,RecordType.Name,High_Level__c,Low_Level__c,Low_Amount__c, High_Amount__c,
                                           Commissionable__c from Payout__c where RecordType.Name =: Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM and 
                                           Name =: Commissions_Constants.OPEN_SALE_COMPONENT and Period__c In : PeriodIds]);          
        */
        Map<Id,Payout__C> Payout = new Map<ID, Payout__C>([select id ,name,RecordType.Name,High_Level__c,Low_Level__c,Low_Amount__c, High_Amount__c,
                                           Commissionable__c from Payout__c where RecordType.Name =: Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM and 
                                           Name =: Commissions_Constants.OPEN_SALE_COMPONENT and Period__c In : PeriodIds]);
        system.debug('Payout : '+Payout );
        for(commission__c commissionRecord : commissionMap.Values()){
            if((commissionRecord.User_team__c == Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM ) && 
                (commissionRecord.OpenBook_New_Sale_Comm_ble_Amount__c != 0.0 && commissionRecord.OpenBook_New_Sale_Comm_ble_Amount__c !=Null)){
                Decimal LowValueComp; Decimal HighValueComp; Decimal CommissinableAmountComp;Decimal quotaPercentage;
                Quota__c quotaRecord = quotaMap.get(commissionRecord.Related_to_Quota__c); 
                if(quotaRecord != Null && quotaRecord.Target_Amount__c !=Null && quotaRecord.Target_Amount__c != 0.0)
                quotaPercentage = ((commissionRecord.OpenBook_New_Sale_Comm_ble_Amount__c)/(quotaRecord.Target_Amount__c))*100;
                for(Payout__c pay : Payout.Values()){
                    
                    if((commissionRecord.User_Team__c == Pay.RecordType.Name)){
                        system.debug('Pay : '+Pay);
                        if(pay.Low_Level__c == Null && pay.High_Level__c == Null){
                            LowValueComp = pay.Low_Amount__c;
                            HighValueComp = pay.High_Amount__c;
                            CommissinableAmountComp = quotaPercentage;                                
                        }
                        if(pay.Low_Amount__c == Null && pay.High_Amount__c == Null){
                            LowValueComp = pay.Low_Level__c;
                            HighValueComp = pay.High_Level__c;
                            CommissinableAmountComp = quotaPercentage;
                        }
                        system.debug('CommissinableAmountComp :'+CommissinableAmountComp );
                        system.debug('LowValueComp:'+LowValueComp);
                        system.debug('HighValueComp :'+HighValueComp);
                        
                        if((CommissinableAmountComp >= LowValueComp)){
                            system.debug('loop 1 :');
                            if(CommissinableAmountComp <= HighValueComp) {
                                system.debug('loop 2 :');
                                if(pay.Name == Commissions_Constants.OPEN_SALE_COMPONENT){ 
                                    system.debug('loop 3 :');
                                    commissionRecord.OpenBook_New_Sale_Payout__c = (pay.Commissionable__c).setScale(6);
                                    commissionRecord.OpenBook_New_Sale_Commission__c = (commissionRecord.OpenBook_New_Sale_Comm_ble_Amount__c * commissionRecord.OpenBook_New_Sale_Payout__c)/100;
                                    system.debug('Payout Rate : '+commissionRecord.OpenBook_New_Sale_Payout__c);
                                    commissionRecord.Payout_Rate1B__c = 0.0;
                                    commissionRecord.Payout_Rate__c = 0.0;
                                    commissionRecord.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c = 0.0;                       
                                    commissionMapupdate.put(commissionRecord.id,commissionRecord);
                                }
                                //commissionRecord.Quota_Percentage_Achieved1__c = currentQuota.Quota_Percentage__c;
                                commissionMapupdate.put(commissionRecord.id,commissionRecord);
                            }
                        }
                        
                    }
                }
            }
        }
        if(commissionMapupdate.size() > 0){
            system.debug('Payout Rate : '+commissionMapupdate);  
            //update commissionMapupdate.Values();
        }   
    }
}