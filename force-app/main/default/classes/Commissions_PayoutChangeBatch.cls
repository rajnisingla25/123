/***********************************************************************************
Created By          :    Srinivas Pendli    
Created Date        :    24.08.2015
Company             :    NTT Data,Inc.
Usage               :    The main purpose of this batch class is to get modified payout records and update all Payout values of related Period 
                         and Quota Commissions,with the new payout value.
                         This batch will execute every day 3 times from scheduled class(PayoutChangeBatchScheduled).                                                  
Modified By         :    Srinivas Pendli
Modifide Date       :    06.04.2016

************************************************************************************/
public class Commissions_PayoutChangeBatch{
/**
global class Commissions_PayoutChangeBatch implements Database.Batchable<sObject> {
    //START METHOD 
    //RETRIVING MODIFIED PAYOUTS RECORDS FROM PAYOUT(Payout__c) OBJECT WHERE STATUS (Payout Change Status) APPROVED AND NOT PROCESSED RECORDS(Record Processed = FALSE)
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([select id,Name,Period__c,Commissionable__c,Sale_Type__c,High_Amount__c,High_Level__c,Is_Kicker_Qualified__c,Low_Amount__c,Low_Level__c,
                                        RecordType.Name from Payout__c where Payout_Change_Status__c = 'Approved' and Record_Processed__c = FALSE]);
    }
    //EXECUTE METHOD
    global void execute(Database.BatchableContext BC, List<Payout__c> scope) {
        set<id> PeriodIds = new set<id>();
        set<Id> quotaIds = new set<Id>();
        Map<id,Commission__c> commissionsMap =  new  Map<id,Commission__c>();
        //COLLECTING PERIOD RECORDS RELETED TO PROCESSED PAYOUT RECORD
        for(Payout__c PayOut : Scope){
            PeriodIds.add(PayOut.Period__c);    
        }
        //GETTING PAYOUT RELATED (RETRIVED/ UPDATED PAYOUTS) QUOTA RECORDS
        Map<Id,Quota__c> allQuotas = new Map<id,Quota__c>([select id,Name,RD_Team_Qualifier__c,Componet2A2BRollUpValue__c,Quota_Percentage__c,
                         Is_Kicker__c from Quota__c where Period_Name__c In : PeriodIds]);
        for(Quota__c quota : allQuotas.Values()){
            quotaIds.add(quota.id);    
        }
        //GETTING COMMISSION RECORDS RELATED TO ABOVE RETRIVED QUOTA RECORDS 
        Map<ID,Commission__c> allCommissions = new Map<ID,Commission__c>([select id,Name,Related_to_Quota__c,Quota_Percentage_Achieved1__c,User_Team__c,Commission_To__c,Asset_Amount__c,
                                                RecordType.Name,Commissionable_Amount2__c,CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c,CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c,CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c,
                                                CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c,Commissionable_Amount3__c,Payout_Rate__c,CFCB_NEW_w_Qualifier_Payout_Rate2A__c,
                                                CFCB_New_w_o_Qualifier_Payout_Rate2B__c,CFCB_RNW_w_Qualifier_Payout_Rate2C__c,CFCB_RNW_w_o_Qualifier_Payout_Rate2D__c,Payout_rate_3__c
                                                from Commission__c where Related_to_Quota__c IN : quotaIds order by Name Desc]);
        //UPDATING PAYOUT RATES OF ABOVE RETRIVED COMMISSIONS (allCommissions)
        //PAYOUT CALCULATION FOR ALL USER TEAMS EXCEPT BROKER REGIONAL DIRECTORS TEAM AND MANAGERS TEAM
        for(Commission__c cm : allCommissions.values()){
            quota__c quotaRecord = allQuotas.get(cm.Related_to_Quota__c);
            for(Payout__c pay : Scope){
                
                if(cm.User_Team__c != Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM ){                   
                    if(Pay.RecordType.Name == cm.User_Team__c){                    
                        Decimal LowValue;Decimal HighValue;
                        if(pay.Low_Level__c == Null && pay.High_Level__c == Null){
                            LowValue = pay.Low_Amount__c;
                            HighValue = pay.High_Amount__c;
                        }
                        if(pay.Low_Amount__c == Null && pay.High_Amount__c == Null){
                            LowValue = pay.Low_Level__c;
                            HighValue = pay.High_Level__c;
                        }                                     
                        //COMPONENT 1 CALCULATION
                        system.debug('>>>>> 12: '+quotaRecord.Quota_Percentage__c);
                        system.debug('>>>>> 13: '+LowValue);
                        system.debug('>>>>> 14: '+HighValue);
                      
                        if((quotaRecord.Quota_Percentage__c >= LowValue)){
                            if(quotaRecord.Quota_Percentage__c <= HighValue) {
                                system.debug('>>>>> Pay 1: '+Pay.RecordType.Name);
                                system.debug('>>>>> Comm: '+cm.User_Team__c);
                                system.debug('>>>>> Pay 2: '+Pay.Name);
                                if(pay.Name == Commissions_Constants.NEW_SALE_WITHOUT_QUALIFIER){
                                    if(pay.Commissionable__c != Null){
                                        cm.Payout_Rate__c = (pay.Commissionable__c).setScale(2);
                                        cm.New_Sale_w_o_Qualifier_Commission__c = (cm.Commissionable_Amount2__c * cm.Payout_Rate__c)/100; 
                                    }
                                }
                            }
                            commissionsMap.put(cm.id,cm);
                        }                      
                        //COMPONENT 2 CALCULATION  
                        //COMPONENT 2A CALCULATION                      
                        if((QuotaRecord.Componet2A2BRollUpValue__c >= LowValue)){
                            if(QuotaRecord.Componet2A2BRollUpValue__c <= HighValue) { 
                                system.debug('>>>>> Pay 11: '+QuotaRecord.Is_Kicker__c);
                                system.debug('>>>>> Pay 22: '+Pay.Name);
                                if(QuotaRecord.Is_Kicker__c == TRUE && pay.Name == Commissions_Constants.CFCB_NEW_SALE_WITH_QUALIFIER){
                                    if(pay.Commissionable__c != Null){
                                        cm.CFCB_NEW_w_Qualifier_Payout_Rate2A__c = pay.Commissionable__c;
                                        cm.CFCB_NEW_w_Qualifier_Commission2A__c = (cm.CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c *  cm.CFCB_NEW_w_Qualifier_Payout_Rate2A__c)/100;
                                    }
                                }
                            } 
                            commissionsMap.put(cm.id,cm);
                        }
                        //COMPONENT 2B CALCULATION  
                        if((QuotaRecord.Componet2A2BRollUpValue__c >= LowValue)){
                            if(QuotaRecord.Componet2A2BRollUpValue__c <= HighValue) { 
                                if(QuotaRecord.Is_Kicker__c == FALSE && pay.Name == Commissions_Constants.CFCB_NEW_SALE_WITHOUT_QUALIFIER){
                                    if(pay.Commissionable__c != Null){
                                        cm.CFCB_New_w_o_Qualifier_Payout_Rate2B__c = pay.Commissionable__c;
                                        cm.CFCB_New_w_o_Qualifier_Commission2B__c = (cm.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c * cm.CFCB_New_w_o_Qualifier_Payout_Rate2B__c)/100;
                                    }
                                }
                            } 
                            commissionsMap.put(cm.id,cm);
                        }
                        //COMPONENT 2C CALCULATION  
                        if((QuotaRecord.Componet2A2BRollUpValue__c >= LowValue)){
                            if(QuotaRecord.Componet2A2BRollUpValue__c <= HighValue) { 
                                if(QuotaRecord.Is_Kicker__c == TRUE && pay.Name == Commissions_Constants.CFCB_NEW_RENEWAL_WITH_QUALIFIER){
                                    if(pay.Commissionable__c != Null){
                                        cm.CFCB_RNW_w_Qualifier_Payout_Rate2C__c = pay.Commissionable__c;
                                        cm.CFCB_RNW_w_Qualifier_Commission2C__c = (cm.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c *  cm.CFCB_RNW_w_Qualifier_Payout_Rate2C__c)/100;
                                    }
                                }
                            } 
                            commissionsMap.put(cm.id,cm);
                        }
                        //COMPONENT 2D CALCULATION  
                        if((QuotaRecord.Componet2A2BRollUpValue__c >= LowValue)){
                            if(QuotaRecord.Componet2A2BRollUpValue__c <= HighValue) { 
                                if(QuotaRecord.Is_Kicker__c == FALSE && pay.Name == Commissions_Constants.CFCB_NEW_RENEWAL_WITHOUT_QUALIFIER){
                                    if(pay.Commissionable__c != Null){
                                        cm.CFCB_RNW_w_o_Qualifier_Payout_Rate2D__c = pay.Commissionable__c;
                                        cm.CFCB_RNW_w_o_Qualifier_Commission2D__c = (cm.CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c * cm.CFCB_RNW_w_o_Qualifier_Payout_Rate2D__c)/100;
                                    }
                                }
                            } 
                            commissionsMap.put(cm.id,cm);
                        }
                        //COMPONENT 3 CALCULATION   
                        if((quotaRecord.Quota_Percentage__c >= LowValue)){
                            if(quotaRecord.Quota_Percentage__c <= HighValue) {
                                if(pay.Commissionable__c != Null){
                                    cm.Payout_Rate_3__c = (pay.Commissionable__c).setScale(2);
                                    cm.Asset_Owner_Commission__c = (cm.Commissionable_Amount3__c * cm.Payout_Rate_3__c)/100;
                                }
                            }
                            commissionsMap.put(cm.id,cm);
                        }                       
                    }
                }
                string PayoutName = '<td>'+pay.Name+'</td>';
                string commissionableValue= '<td>'+pay.Commissionable__c+'</td>';
                //Details+='<tr>'+PayoutName +commissionableValue+'</tr>';                      
            }               
        }
        //PAYOUT CALCULATION FOR MANAGERS TEAM AND COMPONENT 1 ONLY 
        for(Commission__c cm : allCommissions.values()){
            quota__c quotaRecord = allQuotas.get(cm.Related_to_Quota__c);
            Decimal xMgr1 = 0; Decimal x1Mgr1 = 0; Decimal x2Mgr1 = 0;
            Decimal yMgr1  = 0; Decimal y1Mgr1 = 0; Decimal y2Mgr1 = 0;   
            Decimal lowAmountMgr1; Decimal highAmountMgr1;
            Decimal lowValueMgr1 ; Decimal highValueMgr1 ;   
            if(cm.User_Team__c == Commissions_Constants.MANAGERS_TEAM){
                for(Payout__c pay : scope){
                    system.debug('>>>>> : '+pay.RecordType.Name);
                    system.debug('<<<<<< : '+cm.commission_To__c);
                    if(pay.RecordType.Name == cm.commission_To__c){
                        if(pay.Name == Commissions_Constants.NEW_SALE_WITHOUT_QUALIFIER){
                            if(pay.Low_Level__c == Null && pay.High_Level__c == Null){
                                lowValueMgr1 = pay.Low_Amount__c;                                                          
                            }
                            if(pay.Low_Amount__c == Null && pay.High_Amount__c == Null){
                                lowValueMgr1 = pay.Low_Level__c;                               
                            }                               
                            if(lowValueMgr1 <=  quotaRecord.Quota_Percentage__c){ 
                                x1Mgr1 = pay.High_Level__c;                         
                                y1Mgr1 = pay.Commissionable__c;
                                break;                               
                            }
                        }
                    }
                }                        
                for(Payout__c pay : scope){
                    if(pay.RecordType.Name == cm.commission_To__c){                       
                        if(pay.Name == Commissions_Constants.NEW_SALE_WITHOUT_QUALIFIER){
                            if(pay.Low_Level__c == Null && pay.High_Level__c == Null){
                                highValueMgr1 = pay.High_Amount__c;                                                         
                            }
                            if(pay.Low_Amount__c == Null && pay.High_Amount__c == Null){
                                highValueMgr1 = pay.High_Level__c;                                
                            }
                            if(highValueMgr1 >=  quotaRecord.Quota_Percentage__c){                                
                                x2Mgr1 = pay.Low_Level__c;  
                                y2Mgr1 = pay.Commissionable__c;
                            }
                        }
                    }                                   
                }
                xMgr1 = quotaRecord.Quota_Percentage__c;                               
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
                    cm.Payout_Rate__c = YMgr1.setScale(2);
                    commissionsMap.put(cm.id,cm);
                }
                if(xMgr1 >= 65.01 ){
                    cm.Payout_Rate__c = YMgr1.setScale(2);
                    commissionsMap.put(cm.id,cm);
                }
            }                
        }
        //PAYOUT CALCULATION FOR BROKER REGIONAL DIRECTORS TEAM AND COMPONENT 1A AND 1B ONLY 
        for(Commission__c cm : allCommissions.values()){
             quota__c quotaRecord = allQuotas.get(cm.Related_to_Quota__c);
            if(cm.User_Team__c == Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM){  
                Decimal lowAmountRD; Decimal highAmountRD;
                Decimal lowValueRD ; Decimal highValueRD ;    
                Decimal CommissinableAmountCompRD;
                //LINEAR CURVE EQUATION FOR REGIONAL DIRECTORS TEAM AND EVENTS TEAM
                Decimal x  = 0;   Decimal x1 = 0;   Decimal x2 = 0;
                Decimal y  = 0;   Decimal y1 = 0;   Decimal y2 = 0;   
                for(Payout__c p : scope){
                    if(p.Name == Commissions_Constants.NEW_SALE_WITHOUT_QUALIFIER){
                        if(p.Low_Level__c == Null && p.High_Level__c == Null){
                            lowValueRD = p.Low_Amount__c;
                        }
                        if(p.Low_Amount__c == Null && p.High_Amount__c == Null){
                            lowValueRD = p.Low_Level__c;
                        }
                        if(lowValueRD <= quotaRecord.Quota_Percentage__c){                                                                            
                            system.debug('Payout >>>> : '+p.Id);
                            x1 = p.High_Level__c;                         
                            y1 = p.Commissionable__c;
                            break;                               
                        }
                    }                           
                }                        
                for(Payout__c p : scope){
                    if(p.Name == Commissions_Constants.NEW_SALE_WITHOUT_QUALIFIER){
                        if(p.Low_Level__c == Null && p.High_Level__c == Null){
                            highValueRD = p.High_Amount__c;
                        }
                        if(p.Low_Amount__c == Null && p.High_Amount__c == Null){
                            highValueRD = p.High_Level__c;
                        }
                        if(highValueRD >= quotaRecord.Quota_Percentage__c){                                
                            x2 = p.Low_Level__c;  
                            y2 = p.Commissionable__c; 
                        }
                    }                            
                }                        
                x = quotaRecord.Quota_Percentage__c;                             
                try{
                    y = ((y2-y1)/(x2-x1)*(x-x1))+y1;
                }                       
                catch(Exception e){}
                system.debug('x  >> : '+x);
                system.debug('x1 >> : '+x1);
                system.debug('x2 >> : '+x2);
                system.debug('y1 >> : '+y1);
                system.debug('y2 >> : '+y2);
                system.debug('YYYYYYYYYYYYYYY : '+y);
                cm.Payout_Rate__c = Y.setScale(2);
                commissionsMap.put(cm.id,cm);
            
                //****COMPONENT 3 CALCULATION FOR REGIINAL DIRECTORS TEAM AND EVENTS TEAM ****
                Decimal xRD  = 0;   Decimal x1RD = 0;   Decimal x2RD = 0;
                Decimal yRD  = 0;   Decimal y1RD = 0;   Decimal y2RD = 0;  
                Decimal lowAmountRD3; Decimal highAmountRD3;
                Decimal lowValueRD3 ; Decimal highValueRD3 ;   
                Decimal CommissinableAmountCompRD3;
                for(Payout__c p : scope){
                    if(p.Name == Commissions_Constants.ASSET_OWNER_COMPONENTS){
                        if(p.Low_Level__c == Null && p.High_Level__c == Null){
                            lowValueRD3 = p.Low_Amount__c;
                        }
                        if(p.Low_Amount__c == Null && p.High_Amount__c == Null){
                            lowValueRD3 = p.Low_Level__c;
                        }
                        if(lowValueRD <= quotaRecord.Quota_Percentage__c){                                                                            
                            x1RD = p.High_Level__c;                         
                            y1RD = p.Commissionable__c;
                            //break;                               
                        }
                    }                           
                } 
                        
                for(Payout__c p : scope){
                    if(p.Name == Commissions_Constants.ASSET_OWNER_COMPONENTS){
                        if(p.Low_Level__c == Null && p.High_Level__c == Null){
                            highValueRD3 = p.High_Amount__c;
                        }
                        if(p.Low_Amount__c == Null && p.High_Amount__c == Null){
                            highValueRD3 = p.High_Level__c;
                        }
                        if(cm.Quota_Percentage_Achieved1__c > 0){
                            if(highValueRD3 >= quotaRecord.Quota_Percentage__c){                                
                                x2RD = p.Low_Level__c;  
                                y2RD = p.Commissionable__c; 
                            }
                        }
                    }                            
                }
                xRD = quotaRecord.Quota_Percentage__c;   
                system.debug('xRD  >> : '+xRD);
                system.debug('x1RD >> : '+x1RD);
                system.debug('x2RD >> : '+x2RD);
                system.debug('y1RD >> : '+y1RD);
                system.debug('y2RD >> : '+y2RD);                                                 
                try{
                    yRD = ((y2RD-y1RD)/(x2RD-x1RD)*(xRD-x1RD))+y1RD;
                }
                catch(Exception e){}
                cm.Payout_Rate_3__c = YRD.setScale(2);
                commissionsMap.put(cm.id,cm);   
            }
        }
        system.debug('commissionsMap :'+commissionsMap.size());
        //UPDATING COMMISSION RECORDS PAYOUT VALUE WITH NEW VALUE 
        if(commissionsMap.size() > 0){
            try{
                update commissionsMap.Values();
            }
            catch(Exception e){}
        }
        //UPDATING PROCESSED PAYOUT RECORDS WITH TRUE VALUE
        Map<id,Payout__c> mapPayout = new Map<id,Payout__c>();
        for(Payout__c payoutRecord : scope){
            payoutRecord.Record_Processed__c = TRUE;
            mapPayout.put(payoutRecord.id,payoutRecord);            
        }
        if(mapPayout.size() > 0){
            update mapPayout.values();
        }
    }   
    //FINISH METHOD
    global void finish(Database.BatchableContext BC) {
        /*
        Datetime currentDate = datetime.newInstanceGmt(datetime.now().year(), datetime.now().month(), datetime.now().day()-1, 0, 0,1);
        //RETRIVING RECORDS FROM PAYOUT MODIFIED ON CURRENT DAY ONLY  
        Map<id,Payout__c> Payout = new Map<id,Payout__c>([select id,Name,Period__c,Period__r.Name,Commissionable__c,Sale_Type__c,High_Amount__c,High_Level__c,Is_Kicker_Qualified__c,Low_Amount__c,Low_Level__c,RecordType.Name from Payout__c
                                        where LastModifiedDate >=: currentDate]);
        //COLLECTING LIST OF PAYOUTS CHANGED TODAY/CURRENT DAY
        for(Payout__c pay : Payout.Values()){ 
            string PayoutName = '<td align="center">'+pay.Name+'</td>';
            String RecordType = '<td >'+Pay.RecordType.Name+'</td>';
            String Period = '<td align="center">'+Pay.Period__r.Name+'</td>';
            string commissionableValue= '<td align="center">'+pay.Commissionable__c+'</td>';
            Details+='<tr>'+PayoutName+ RecordType + Period +commissionableValue+'</tr>'; 
        }
        
        //EMAIL BODY
        string emailMessage ='<font face="Verdana" size ="2">Hello,<br/><br/>'
        +'Please find the below list of Payout values changed.<br/><br/>'
        +'<table border="1" ><Th>Payout Name </Th><Th>User Team Name </Th><Th>Period</Th><Th>Commissionable Value </Th>'+ Details+'</table> </font><br/><br/>'
      
        + 'Thank You, <br/> '
        + 'Move, Inc. <br/> </font>';
        //EMAIL METHODS
        List<Messaging.SingleEmailMessage> Allemails = new List<Messaging.SingleEmailMessage>();        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'srinivas.pendli@nttdata.com','sandeep.meka@move.com','sudhakar-reddy.lekkala@nttdata.com'};
        //String[] toAddresses = new String[] {Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Move, Inc.');
        mail.setHTMLBody(emailMessage);     
        Allemails.add(mail);       
        Messaging.SendEmailResult [] res = Messaging.sendEmail(Allemails);
        */
    
   
}