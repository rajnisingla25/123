/***********************************************************************************
Created By          :    Srinivas Pendli    
Created Date        :    28.07.2015
Company             :    NTT Data,Inc.
Usage               :    This class contains below functional scenarios for Commission calculation of Move,Inc..
                         1.Condtional Matrix for all Teams including Managers Team
                         2.update new quota percenta to all releted Quota commissions.
                         3.Rollup logic for all New Sale Commissions
                         4.Rollup Calculation for Claw Back commissions
                         5.Linear curve Logic for Regional Directors Team
                         6.Its calculate commission,payout and quota percentage for component 1,2A,2B,2C,2B,3 and 4A(Only for Tiger Lead).
                         7.the entire logic in @future method to override the Salesforce.com Goverar limit.
                         
Modified By         :    Srinivas Pendli
Modifide Date       :    10.10.2015
************************************************************************************/

Public with sharing class Commissions_TriggerHandlerClass{    
 
    Public static void OnIsinsert(set<id> allCommissionIds,Boolean IsUpdate){       
         /****
          Commissions_TriggerHelperClass.firstRun = false;
        Set<Id> UserIds = new Set<Id>();              
        Set<Id> AssetIds = new Set<Id>();            
        Set<Id> QuotaIds = new Set<Id>(); 
        Set<Id> ProductIds = new Set<Id>();     
        Decimal Componet1RollUpValue = 0.0;
        String TeamName;
        Decimal Componet2RollUpValue = 0.0;
        Decimal ComponetManagerRollUpValue = 0.0;
        Decimal Componet3RollUpValue = 0.0;     
        Decimal quotaPercentage = 0.0;                     
        Decimal quotaPercentage3 = 0.0; 
        Decimal quotaPercentage4 = 0.0;
        Decimal quotaPercentageManager = 0.0;   
        Decimal AssetAmount = 0;   
        Map<id,commission__c> commissionsMap = new Map<id,commission__c>();
        Map<String,Decimal> mapUserTotalSale = new Map<String,Decimal>();
        Map<String,Decimal> mapUserTotalSale2A = new Map<String,Decimal>();
        Map<String,Decimal> mapUserTotalSale2B = new Map<String,Decimal>();
        Map<String,Decimal> mapUserTotalSale2C = new Map<String,Decimal>();
        Map<String,Decimal> mapUserTotalSale2D = new Map<String,Decimal>();
        Map<String,Decimal> mapUserTotalSale3 = new Map<String,Decimal>();
        Map<Id,List<commission__c>> mapUserCommissionList = new Map<Id,List<commission__c>>();        
        
        Map<ID,Commission__c> Commissionlist = new Map<ID,Commission__c>([select id,Name,Signing_AE__c,Signing_AE__r.Name,Related_to_Quota__r.User__c,Related_to_Asset__r.OwnerId,Related_to_Quota__r.Target_Amount__c,
                                                    Related_to_Asset__c,Related_to_Quota__c,CreatedDate,Product__c,Related_Commission__c,Asset_Amount__c,User_Team__c,Manager_Of__c,Commission_To__c,RecordType.Name,
                                                    Quota_Percentage_Achieved1__c,Total_Commissionable_Amount__c,Commissionable_Amount2__c,CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c,CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c,
                                                    CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c,CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c,Commissionable_Amount3__c,Payout_Rate__c,Payout_Rate1B__c,CFCB_NEW_w_Qualifier_Payout_Rate2A__c,
                                                    CFCB_New_w_o_Qualifier_Payout_Rate2B__c,CFCB_RNW_w_Qualifier_Payout_Rate2C__c,CFCB_RNW_w_o_Qualifier_Payout_Rate2D__c,Payout_rate_3__c,OpenBook_New_Sale_Comm_ble_Amount__c,OpenBook_New_Sale_Payout__c,
                                                    New_Sale_w_o_Qualifier_Commission__c,New_Sale_w_Qualifier_Commission__c,CFCB_NEW_w_Qualifier_Commission2A__c,CFCB_New_w_o_Qualifier_Commission2B__c,
                                                    CFCB_RNW_w_Qualifier_Commission2C__c,RD_Payout_Rate__c,CFCB_RNW_w_o_Qualifier_Commission2D__c,Asset_Owner_Commission__c,TIGER_Commission4A__c,Collection_Commission__c,
                                                    Retention_Commission__c,OpenBook_New_Sale_Commission__c
                                                    from Commission__c where Id IN : allCommissionIds order by Name Asc]);     
        
        system.debug('Commissionlist  :'+Commissionlist);       
        for(Commission__c comm : Commissionlist.Values()){    
            QuotaIds.add(comm.Related_to_Quota__c);
        }         
        Id clawBackRT = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Clawback').getRecordTypeId();
        Map<id,Commission__c> Commissionlist1 = new Map<id,Commission__c>([select id,Name,Related_to_Quota__r.User__c,Related_to_Asset__r.OwnerId,Related_to_Quota__r.Target_Amount__c,
                                                    Related_to_Quota__c,Product__c,User_Team__c,RecordType.Name,Total_Commissionable_Amount__c,CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c,CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c,
                                                    CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c,CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c,Commissionable_Amount3__c from Commission__c 
                                                    where RecordTypeId !=: Commissions_Constants.COMMISSIONS_CLAWBACK and User_Team__c !=: Commissions_Constants.COLLECTION_TEAM and User_team__c !=: Commissions_Constants.COLLECTIONS_CLIENT_RELATIONS_MANAGERS and 
                                                    Related_to_Quota__c IN : QuotaIds 
                                                    order by Name Asc]);
        system.debug('Commissionlist1 :'+Commissionlist1.Values()); 
        for(Commission__c comm : Commissionlist1.Values()){ 
            AssetIds.add(comm.Related_to_Asset__c);               
        }
        system.debug('QuotaIds : '+QuotaIds);
        Map<Id,Asset> Assetlist1 = new Map<ID, Asset>([select id,Renewal_Type__c,Sign_in_AE__c,Sign_in_AE__r.Team__c,Sign_in_AE__r.ManagerId,Name,Price,Line_Type__c,End_Date__c,
                                                    CreatedDate,Start_Date__c, OwnerId, Account.OwnerId,Total_Net__c FROM Asset WHERE id In : AssetIds]);
        
        Date startOfMonth = Date.today().toStartOfMonth(); 
        Map<Id,Quota__c> currentMonthQuota = new Map<id,Quota__c>([select id,Name,Is_Kicker__c,Collection_Target_Amount__c,User__c,User__r.CreatedDate,User__r.Name,User_Team__c,User__r.ManagerId,Target_Amount__c,
                                                Total_Sale__c,Total_Sale_2__c,RD_Team_Qualifier__c, User__r.Payout_Rate_Month_1__c,User__r.Payout_Rate_Month_2__c,User__r.Payout_Rate_Month_3__c,Quota_Percentage__c,  
                                                Period_Name__r.Sigh_In_AE__c,Current_Quater__c,Collection_Total_Sale__c,Collection_Quota_Percentage__c,Period_Name__r.Asset_Owner__c,Period_Name__c,RD_Payout__c from Quota__c where id IN : QuotaIds]);
        
        Set<Id> PeriodIds = new Set<Id>();
        for(Quota__c quota : currentMonthQuota.Values()){
            system.debug('QuotaIds : '+Quota.Period_Name__c);
            PeriodIds.add(quota.Period_Name__c);
        }
        //NEW SALE COMMISSION ROLLUP CALACULATION
        Id newSaleRT = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('New Sale').getRecordTypeId(); 
        for(Commission__c comm : Commissionlist1.Values()){    
            if(comm.RecordType.Name != Commissions_Constants.COMMISSIONS_CLAWBACK || (comm.RecordTypeId == newSaleRT && comm.User_Team__c != Commissions_Constants.COLLECTION_TEAM && comm.User_team__c != Commissions_Constants.COLLECTIONS_CLIENT_RELATIONS_MANAGERS)){
                UserIds.add(comm.Related_to_Asset__r.OwnerId);            
                ProductIds.add(comm.Product__c);       
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
        }        
        system.debug('mapUserCommissionList >>>>>:'+mapUserCommissionList.size());        
        for(Id idds : mapUserCommissionList.keyset()){
            Decimal decc = 0.0;Decimal decc2A = 0.0;Decimal decc2B = 0.0;Decimal decc2C = 0.0;Decimal decc2D = 0.0;Decimal decc3 = 0.0;
            for(commission__c comm1 : mapUserCommissionList.get(idds)){
                Quota__c currentQuota = currentMonthQuota.get(comm1.Related_to_Quota__c);         
                if((comm1.Total_Commissionable_Amount__c != 0.0) && (comm1.Total_Commissionable_Amount__c != Null)){
                    decc = decc + (comm1.Total_Commissionable_Amount__c);
                    mapUserTotalSale.put(idds+'###'+comm1.Name,decc);                    
                }    
                if((comm1.Total_Commissionable_Amount__c == 0.0)){
                    decc = decc + (comm1.Total_Commissionable_Amount__c);
                    mapUserTotalSale.put(idds+'###'+comm1.Name,decc);                    
                }               
                if((comm1.CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c != null) && (comm1.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c != null )){
                    decc2A = decc2A + comm1.CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c;
                    decc2A = decc2A + comm1.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c;
                    mapUserTotalSale2A.put(idds+'###'+comm1.Name,decc2A);                    
                }        
                if((comm1.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c != null ) && (comm1.CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c != Null)){
                    decc2C = decc2C + comm1.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c;
                    decc2C = decc2C + comm1.CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c;
                    mapUserTotalSale2C.put(idds+'###'+comm1.Name,decc2C);                    
                }               
                if((comm1.Commissionable_Amount3__c != 0.0) && (comm1.Commissionable_Amount3__c != Null)){
                    decc3 = decc3 + ((comm1.Commissionable_Amount3__c));
                    mapUserTotalSale3.put(idds+'###'+comm1.Name,decc3);                    
                }  
            }
        }
        System.debug(mapUserTotalSale+'######'+mapUserCommissionList);     
    
        Map<Id,Payout__C> Payout = new Map<ID, Payout__C>([select id ,name,RecordType.Name,High_Level__c,Low_Level__c,Low_Amount__c, High_Amount__c,
                                           Commissionable__c from Payout__c where Period__c In : PeriodIds Order by Low_Level__c Desc]);          
        Map<Id,Product2> ListProduct = new Map<ID, Product2>([select id,Name,Commission_Category__c from Product2 where id In : ProductIds]); 
        system.debug('PeriodIds : '+PeriodIds);                                      
        Map<Id,Payout__c> pay1 = new Map<ID, Payout__c>([select id, name, Low_level__c, High_Level__c,Low_Amount__c,High_Amount__c, Commissionable__c, RecordType.Name from Payout__c 
                                            where Period__c In : PeriodIds and (RecordType.Name =: Commissions_Constants.BROKER_REGIONAL_DIRECTORS_SALES_TEAM ) ORDER BY High_Level__c DESC ]);
        system.debug('pay1 : '+pay1.size());  
        for(commission__c cm : Commissionlist.Values()){            
            quotaPercentage = 0.0;quotaPercentage3 = 0.0;quotaPercentage4=0.0;  quotaPercentageManager = 0.0;
            Componet1RollUpValue = 0.0;Componet2RollUpValue = 0.0;ComponetManagerRollUpValue = 0.0;
            asset assets = Assetlist1.get(cm.Related_to_Asset__c);
            if(assets != Null){
                Quota__c currentQuota = currentMonthQuota.get(cm.Related_to_Quota__c);
                Product2 Product = ListProduct.get(cm.Product__c);
            
                if(cm.RecordType.Name != Commissions_Constants.COMMISSIONS_CLAWBACK && (cm.OpenBook_New_Sale_Comm_ble_Amount__c == 0.0 || cm.OpenBook_New_Sale_Comm_ble_Amount__c == Null)){
                    if(currentQuota.Id != Null && cm.Asset_Amount__c != 0.0 ){                                
                                             
                        if((assets.Sign_in_AE__c != Null && assets.OwnerId !=Null)){
                            if((assets.Sign_in_AE__c == assets.OwnerId)){
                                if((assets.Sign_in_AE__c == currentQuota.user__c) && (cm.Related_to_Quota__r.Target_Amount__c != null && cm.Related_to_Quota__r.Target_Amount__c != 0.0)){                           
                                    //100 % to the asset Owner                            
                                    quotaPercentage = ((mapUserTotalSale.get(cm.Related_to_Quota__r.user__c+'###'+cm.Name))/cm.Related_to_Quota__r.Target_Amount__c)*100;
                                    Componet1RollUpValue = mapUserTotalSale.get(cm.Related_to_Quota__r.user__c+'###'+cm.Name);
                                
                                    //COMMISSION CALCULATION FOR COMPONENT 2 - ONLY FOR CFCB and TL PRODUCTS
                                    if((Product.Commission_Category__c == 'CFCB') || (Product.Commission_Category__c == 'TL')){ 
                                        if(assets.Renewal_Type__c == Null && (currentQuota.Is_Kicker__c == FALSE || currentQuota.Is_Kicker__c == TRUE)){                                    
                                            Componet2RollUpValue = mapUserTotalSale2A.get(cm.Related_to_Quota__r.user__c+'###'+cm.Name);                                    
                                        }                                                                
                                        if((assets.Renewal_Type__c == 'Auto' || assets.Renewal_Type__c == 'Manual') && (currentQuota.Is_Kicker__c == FALSE || currentQuota.Is_Kicker__c == TRUE)){  
                                            Componet2RollUpValue = mapUserTotalSale2C.get(cm.Related_to_Quota__r.user__c+'###'+cm.Name);                                    
                                        }                      
                                    }        
                                }
                            }                              
                        }                    
                        
                        if(assets.Sign_in_AE__c != assets.OwnerId){
                            //COMMISSION CALCULATION FOR SIGN IN AE CODE OPEN
                            try{
                                if((assets.Sign_in_AE__c == currentQuota.user__c) && (cm.Related_to_Quota__r.Target_Amount__c != null && cm.Related_to_Quota__r.Target_Amount__c != 0)){
                                    quotaPercentage = ((mapUserTotalSale.get(cm.Related_to_Quota__r.user__c+'###'+cm.Name))/cm.Related_to_Quota__r.Target_Amount__c)*100;
                                    Componet1RollUpValue = mapUserTotalSale.get(cm.Related_to_Quota__r.user__c+'###'+cm.Name);                       
                            
                                    //COMMISSION CALCULATION FOR COMPONENT 2 - ONLY FOR CFCB and TL PRODUCTS
                                    if((Product.Commission_Category__c == 'CFCB') || (Product.Commission_Category__c == 'TL')){ 
                                        if(assets.Renewal_Type__c == Null && (currentQuota.Is_Kicker__c == FALSE || currentQuota.Is_Kicker__c == TRUE)){                                    
                                            Componet2RollUpValue = mapUserTotalSale2A.get(cm.Related_to_Quota__r.user__c+'###'+cm.Name);                                    
                                        }                                                               
                                        if((assets.Renewal_Type__c == 'Auto' || assets.Renewal_Type__c == 'Manual') && (currentQuota.Is_Kicker__c == FALSE || currentQuota.Is_Kicker__c == TRUE)){  
                                            Componet2RollUpValue = mapUserTotalSale2C.get(cm.Related_to_Quota__r.user__c+'###'+cm.Name);                                    
                                        }                     
                                    }                           
                                }                 
                                //COMMISSION CALCULATION FOR ACCOUNT OWNER CODE OPEN
                        
                                if((assets.Sign_in_AE__c != currentQuota.user__c) && (cm.Related_to_Quota__r.Target_Amount__c != null && cm.Related_to_Quota__r.Target_Amount__c != 0)){
                                    //quotaPercentage = ((mapUserTotalSale.get(cm.Related_to_Quota__r.user__c+'###'+cm.Name))/cm.Related_to_Quota__r.Target_Amount__c)*100;
                                    quotaPercentage3 = ((mapUserTotalSale.get(cm.Related_to_Quota__r.user__c+'###'+cm.Name))/cm.Related_to_Quota__r.Target_Amount__c)*100;
                                    Componet3RollUpValue = mapUserTotalSale3.get(cm.Related_to_Quota__r.user__c+'###'+cm.Name);                            
                                }
                            }
                            catch(exception e){}
                        }
                        system.debug('commission Name >>: '+cm.Name);
                        system.debug('Componet1RollUpValue >>: '+Componet1RollUpValue);                 
                        system.debug('quotaPercentage >>: '+quotaPercentage);
                        system.debug('Componet2RollUpValue >>: '+Componet2RollUpValue);
                        system.debug('Componet3RollUpValue >>: '+Componet3RollUpValue);
                        system.debug('quotaPercentage3 >>: '+quotaPercentage3);
                    
                        //NEW HIRE TEAM         
                        if((currentQuota.User_Team__c == Commissions_Constants.NEW_HIRE_TEAM)){
                            if(currentQuota.user__r.CreatedDate.addmonths(1).month() == cm.CreatedDate.month()){
                                if(currentQuota.user__r.Payout_Rate_Month_1__c != Null){
                                    cm.Payout_Rate__c = (currentQuota.user__r.Payout_Rate_Month_1__c).setScale(2);
                                    if((product.Commission_Category__c == 'CFCB')|| (product.Commission_Category__c == 'TL')){
                                        cm.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c = 0;                                    
                                        cm.Quota_Percentage_Achieved1__c = 0;    
                                    }
                                }
                            }                    
                            if(currentQuota.user__r.CreatedDate.addmonths(2).month() == cm.CreatedDate.month()){
                                if(currentQuota.user__r.Payout_Rate_Month_2__c != Null){
                                    cm.Payout_Rate__c = (currentQuota.user__r.Payout_Rate_Month_2__c).setScale(2);
                                    cm.New_Sale_w_o_Qualifier_Commission__c = (cm.Payout_Rate__c * cm.Commissionable_Amount2__c)/100;
                                    cm.Quota_Percentage_Achieved1__c = 0;    
                                }
                            }                                 
                            if(currentQuota.user__r.CreatedDate.addmonths(3).month() == cm.CreatedDate.month()){
                                if(currentQuota.user__r.Payout_Rate_Month_3__c != Null){
                                    cm.Payout_Rate__c = (currentQuota.user__r.Payout_Rate_Month_3__c).setScale(2);
                                    cm.New_Sale_w_o_Qualifier_Commission__c = (cm.Payout_Rate__c * cm.Commissionable_Amount2__c)/100;
                                    cm.Quota_Percentage_Achieved1__c = 0;                               
                                }
                            }
                            commissionsMap.put(cm.id,cm);
                        }                                 
                           
                        String QuotaTeam = '';
                        if(currentQuota.User_Team__c == Commissions_Constants.MANAGERS_TEAM ){
                            QuotaTeam = currentQuota.User__r.Name;
                        }else{
                            QuotaTeam = currentQuota.User_Team__c;
                        } 
                        
                        for(Payout__c pay : Payout.Values()){
                            if((QuotaTeam  == Pay.RecordType.Name) && (currentQuota.User_Team__c != Commissions_Constants.COLLECTION_TEAM && currentQuota.User_Team__c != Commissions_Constants.COLLECTIONS_CLIENT_RELATIONS_MANAGERS)){ 
                                if((currentQuota.User_Team__c != Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM)){ 
                                    if((cm.User_Team__c == Pay.RecordType.Name)){
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
                                        if((CommissinableAmountComp1 != 0.0) && (CommissinableAmountComp1 >= LowValueComp1)){                                       
                                            if(CommissinableAmountComp1 <= HighValueComp1) {                                       
                                                if(pay.Name == Commissions_Constants.NEW_SALE_WITHOUT_QUALIFIER){                                           
                                                    cm.Payout_Rate__c = (pay.Commissionable__c).setScale(2);
                                                    cm.New_Sale_w_o_Qualifier_Commission__c = (cm.Payout_Rate__c * cm.Commissionable_Amount2__c)/100;
                                                    cm.Quota_Percentage_Achieved1__c = quotaPercentage+quotaPercentage3;
                                                }
                                            }
                                            commissionsMap.put(cm.id,cm);
                                        }
                                        //Calculating component 2 for all team
                                        if((product.Commission_Category__c == 'CFCB') || (product.Commission_Category__c == 'TL')){
                                            if(assets.Renewal_Type__c == Null && currentQuota.Is_Kicker__c == TRUE){                                    
                                                if(pay.Name == Commissions_Constants.CFCB_NEW_SALE_WITH_QUALIFIER){
                                                    if((Componet2RollUpValue != 0.0) && (Componet2RollUpValue >= pay.Low_Amount__c)){
                                                        if(Componet2RollUpValue <= pay.High_Amount__c) {
                                                            cm.CFCB_NEW_w_Qualifier_Payout_Rate2A__c = pay.Commissionable__c;
                                                            cm.CFCB_NEW_w_Qualifier_Commission2A__c = (cm.CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c * cm.CFCB_NEW_w_Qualifier_Payout_Rate2A__c )/100;
                                                            commissionsMap.put(cm.id,cm);
                                                        }                                       
                                                    }
                                                }                               
                                            }
                                            if(assets.Renewal_Type__c == Null && currentQuota.Is_Kicker__c == FALSE){  
                                               if(pay.Name == Commissions_Constants.CFCB_NEW_SALE_WITHOUT_QUALIFIER){
                                                    if((Componet2RollUpValue != 0.0) && (Componet2RollUpValue >= pay.Low_Amount__c)){
                                                        if(Componet2RollUpValue <= pay.High_Amount__c) {
                                                            cm.CFCB_New_w_o_Qualifier_Payout_Rate2B__c = pay.Commissionable__c;
                                                            cm.CFCB_New_w_o_Qualifier_Commission2B__c = (cm.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c * cm.CFCB_New_w_o_Qualifier_Payout_Rate2B__c )/100;
                                                            commissionsMap.put(cm.id,cm);   
                                                        }                                       
                                                    }
                                                }                                             
                                            } 
                                            if((assets.Renewal_Type__c == 'Auto' || assets.Renewal_Type__c == 'Manual') && currentQuota.Is_Kicker__c == TRUE){  
                                                if(pay.Name == Commissions_Constants.CFCB_NEW_RENEWAL_WITH_QUALIFIER){
                                                    if((Componet2RollUpValue != 0.0) && (Componet2RollUpValue >= pay.Low_Amount__c)){
                                                        if(Componet2RollUpValue <= pay.High_Amount__c) {                                            
                                                            cm.CFCB_RNW_w_Qualifier_Payout_Rate2C__c= pay.Commissionable__c;
                                                            cm.CFCB_RNW_w_Qualifier_Commission2C__c = (cm.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c * cm.CFCB_RNW_w_Qualifier_Payout_Rate2C__c )/100;
                                                            commissionsMap.put(cm.id,cm);
                                                        }                                   
                                                    }
                                                }                                            
                                            }
                                            if((assets.Renewal_Type__c == 'Auto' || assets.Renewal_Type__c == 'Manual') && currentQuota.Is_Kicker__c == FALSE){  
                                                if(pay.Name == Commissions_Constants.CFCB_NEW_RENEWAL_WITHOUT_QUALIFIER ){
                                                    if((Componet2RollUpValue != 0.0) && (Componet2RollUpValue >= pay.Low_Amount__c)){
                                                        if(Componet2RollUpValue <= pay.High_Amount__c) {                                            
                                                            cm.CFCB_RNW_w_o_Qualifier_Payout_Rate2D__c= pay.Commissionable__c;
                                                            cm.CFCB_RNW_w_o_Qualifier_Commission2D__c = (cm.CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c * cm.CFCB_RNW_w_o_Qualifier_Payout_Rate2D__c )/100;
                                                            commissionsMap.put(cm.id,cm);
                                                        }                                   
                                                    }
                                                }                                           
                                            }                           
                                        }
                                        //COMPONENT 3 CALCULATION
                                        Decimal LowValueComp3; Decimal HighValueComp3; Decimal CommissinableAmountComp3;
                                        if(pay.Low_Level__c == Null && pay.High_Level__c == Null){
                                            LowValueComp3 = pay.Low_Amount__c;
                                            HighValueComp3 = pay.High_Amount__c;
                                            CommissinableAmountComp3 = Componet1RollUpValue;                                
                                        }
                                        if(pay.Low_Amount__c == Null && pay.High_Amount__c == Null){
                                            LowValueComp3 = pay.Low_Level__c;
                                            HighValueComp3 = pay.High_Level__c;
                                            CommissinableAmountComp3 = quotaPercentage3;
                                        }
                                        if((CommissinableAmountComp3 != 0.0 ) && (CommissinableAmountComp3 >= LowValueComp3)){
                                            if(CommissinableAmountComp3 <= HighValueComp3) {
                                                if(pay.Name == Commissions_Constants.ASSET_OWNER_COMPONENTS){  
                                                    cm.Payout_Rate_3__c = Pay.Commissionable__c.setScale(2);
                                                    cm.Asset_Owner_Commission__c =(cm.Commissionable_Amount3__c * cm.Payout_Rate_3__c)/100;
                                                    cm.Quota_Percentage_Achieved1__c = quotaPercentage3;
                                                }
                                            }
                                            commissionsMap.put(cm.id,cm);
                                        }
                                    }
                                }   
                            }
                        }
                    
                        //LINEAR CURVE EQUATION FOR REGIONAL DIRECTORS TEAM AND EVENTS TEAM
                        Decimal x  = 0;   Decimal x1 = 0;   Decimal x2 = 0;
                        Decimal y  = 0;   Decimal y1 = 0;   Decimal y2 = 0;   
                           
                        if((currentQuota.User_Team__c == Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM)){               
                            if(cm.Commission_To__c == cm.Signing_AE__r.Name){
                                Decimal lowAmountRD; Decimal highAmountRD;
                                Decimal lowValueRD ; Decimal highValueRD ;    
                                Decimal CommissinableAmountCompRD;
                                for(Payout__c p : pay1.Values()){
                                    if(cm.User_Team__c == p.Recordtype.Name){
                                        if(p.Name ==Commissions_Constants.NEW_SALE_WITHOUT_QUALIFIER){
                                            if(p.Low_Level__c == Null && p.High_Level__c == Null){
                                                lowValueRD = p.Low_Amount__c;
                                                CommissinableAmountCompRD = Componet1RollUpValue;                               
                                            }
                                            if(p.Low_Amount__c == Null && p.High_Amount__c == Null){
                                                lowValueRD = p.Low_Level__c;
                                                CommissinableAmountCompRD = quotaPercentage+quotaPercentage3;
                                            }
                                            if(lowValueRD <= CommissinableAmountCompRD){                                                                            
                                                system.debug('Payout >>>> : '+p.Id);
                                                x1 = p.High_Level__c;                         
                                                y1 = p.Commissionable__c;
                                                break;                               
                                            }
                                        }
                                    }                           
                                }                        
                                for(Payout__c p : pay1.Values()){
                                    if(cm.User_Team__c == p.Recordtype.Name){
                                        if(p.Name == Commissions_Constants.NEW_SALE_WITHOUT_QUALIFIER){
                                            if(p.Low_Level__c == Null && p.High_Level__c == Null){
                                                highValueRD = p.High_Amount__c;
                                                CommissinableAmountCompRD = Componet1RollUpValue;                               
                                            }
                                            if(p.Low_Amount__c == Null && p.High_Amount__c == Null){
                                                highValueRD = p.High_Level__c;
                                                CommissinableAmountCompRD = quotaPercentage+quotaPercentage3;
                                            }
                                        
                                            if(highValueRD >= CommissinableAmountCompRD){                                
                                                x2 = p.Low_Level__c;  
                                                y2 = p.Commissionable__c; 
                                            }
                                        }
                                    }                            
                                }                        
                                x = quotaPercentage+quotaPercentage3;                             
                                try{
                                    y = ((y2-y1)/(x2-x1)*(x-x1))+y1;
                                }                       
                                catch(Exception e){}
                                if((currentQuota.User_Team__c == Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM)){
                                    if(currentQuota.RD_Team_Qualifier__c == false){
                                        cm.Payout_Rate__c = Y.setScale(6);
                                        cm.New_Sale_w_o_Qualifier_Commission__c = (cm.Payout_Rate__c * cm.Commissionable_Amount2__c)/100;
                                    }
                                    if(currentQuota.RD_Team_Qualifier__c == true){
                                        cm.Payout_Rate1B__c = Y.setScale(6);
                                        cm.New_Sale_w_o_Qualifier_Commission__c = (cm.Payout_Rate1B__c * cm.Commissionable_Amount2__c)/100;
                                    }                               
                                }                            
                                cm.Quota_Percentage_Achieved1__c = quotaPercentage+quotaPercentage3;
                                commissionsMap.put(cm.id,cm);                          
                            }
                        
                            //****COMPONENT 3 CALCULATION FOR REGIINAL DIRECTORS TEAM AND EVENTS TEAM ****
                            Decimal xRD  = 0;   Decimal x1RD = 0;   Decimal x2RD = 0;
                            Decimal yRD  = 0;   Decimal y1RD = 0;   Decimal y2RD = 0;  
                            Decimal lowAmountRD3; Decimal highAmountRD3;
                            Decimal lowValueRD3 ; Decimal highValueRD3 ;   
                            Decimal CommissinableAmountCompRD3;                        
                            if(cm.Commission_To__c != cm.Signing_AE__r.Name){                          
                                for(Payout__c p : pay1.Values()){
                                    if(cm.User_Team__c == p.Recordtype.Name){
                                        if(p.Name == Commissions_Constants.ASSET_OWNER_COMPONENTS){
                                            if(p.Low_Level__c == Null && p.High_Level__c == Null){
                                                lowValueRD3 = p.Low_Amount__c;
                                                CommissinableAmountCompRD3 = Componet3RollUpValue;                              
                                            }
                                            if(p.Low_Amount__c == Null && p.High_Amount__c == Null){
                                                lowValueRD3 = p.Low_Level__c;
                                                CommissinableAmountCompRD3 = quotaPercentage+quotaPercentage3;
                                            }                                           
                                            if(lowValueRD3 <= CommissinableAmountCompRD3){      
                                                x1RD = p.High_Level__c;                         
                                                y1RD = p.Commissionable__c;
                                                break;                               
                                            }
                                        }
                                    }                           
                                } 
                            
                                for(Payout__c p : pay1.Values()){
                                    if(cm.User_Team__c == p.Recordtype.Name){
                                        if(p.Name == Commissions_Constants.ASSET_OWNER_COMPONENTS){
                                            if(p.Low_Level__c == Null && p.High_Level__c == Null){
                                                highValueRD3 = p.High_Amount__c;
                                                CommissinableAmountCompRD3 = Componet3RollUpValue;                              
                                            }
                                            if(p.Low_Amount__c == Null && p.High_Amount__c == Null){
                                                highValueRD3 = p.High_Level__c;
                                                CommissinableAmountCompRD3 = quotaPercentage+quotaPercentage3;
                                            }
                                            if(CommissinableAmountCompRD3 > 0){
                                                if(highValueRD3 >= CommissinableAmountCompRD3){                                
                                                    x2RD = p.Low_Level__c;  
                                                    y2RD = p.Commissionable__c; 
                                                }
                                            }
                                        }
                                    }                               
                                }
                                xRD = quotaPercentage+quotaPercentage3;   
                                try{
                                    yRD = ((y2RD-y1RD)/(x2RD-x1RD)*(xRD-x1RD))+y1RD;
                                }
                                catch(Exception e){}
                                cm.Payout_Rate_3__c = YRD.setScale(6);
                                cm.Asset_Owner_Commission__c =(cm.Commissionable_Amount3__c * cm.Payout_Rate_3__c)/100;
                                cm.Quota_Percentage_Achieved1__c = quotaPercentage3+quotaPercentage;// Componet3RollUpValue
                                commissionsMap.put(cm.id,cm);
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
                                if(p.RecordType.Name == cm.commission_To__c){
                                    if(p.Name == Commissions_Constants.NEW_SALE_WITHOUT_QUALIFIER){
                                        if(p.Low_Level__c == Null && p.High_Level__c == Null){
                                            lowValueMgr1 = p.Low_Amount__c;
                                            CommissinableAmountCompMgr1 = Componet1RollUpValue;                               
                                        }
                                        if(p.Low_Amount__c == Null && p.High_Amount__c == Null){
                                            lowValueMgr1 = p.Low_Level__c;
                                            CommissinableAmountCompMgr1 = quotaPercentage+quotaPercentage3;
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
                                            CommissinableAmountCompMgr1 = quotaPercentage+quotaPercentage3;
                                        }
                                        if(highValueMgr1 >= CommissinableAmountCompMgr1){                                
                                            x2Mgr1 = p.Low_Level__c;  
                                            y2Mgr1 = p.Commissionable__c;
                                        }
                                    }
                                }                                   
                            }
                            xMgr1 = quotaPercentage+quotaPercentage3;                
                            try{
                                yMgr1 = ((y2Mgr1-y1Mgr1)/(x2Mgr1-x1Mgr1)*(xMgr1-x1Mgr1))+y1Mgr1;
                            }
                            catch(Exception e){}
                        
                            if(xMgr1 <= 65.00 ){
                                yMgr1 = 0.00;
                                cm.Payout_Rate__c = YMgr1.setScale(2);
                                cm.Quota_Percentage_Achieved1__c = quotaPercentage+quotaPercentage3;   
                                cm.New_Sale_w_o_Qualifier_Commission__c = (cm.Payout_Rate__c * cm.Commissionable_Amount2__c)/100;
                                commissionsMap.put(cm.id,cm);
                            }
                            if(xMgr1 >= 65.01 ){
                                cm.Payout_Rate__c = YMgr1.setScale(2);
                                cm.Quota_Percentage_Achieved1__c = quotaPercentage+quotaPercentage3;                  
                                cm.New_Sale_w_o_Qualifier_Commission__c = (cm.Payout_Rate__c * cm.Commissionable_Amount2__c)/100;
                                commissionsMap.put(cm.id,cm);
                            }
                        }
                    } 
                }
                if((cm.RecordType.Name == Commissions_Constants.COMMISSIONS_CLAWBACK) || (cm.OpenBook_New_Sale_Comm_ble_Amount__c != 0.0 && cm.OpenBook_New_Sale_Comm_ble_Amount__c !=Null)){
                    commissionsMap.put(cm.id,cm);
                }
                if((cm.User_team__c == Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM || (cm.User_team__c == Commissions_Constants.COLLECTION_TEAM || cm.User_team__c == Commissions_Constants.COLLECTIONS_CLIENT_RELATIONS_MANAGERS)) 
                    && (cm.OpenBook_New_Sale_Comm_ble_Amount__c != 0.0 && cm.OpenBook_New_Sale_Comm_ble_Amount__c !=Null)){
                    Decimal LowValueComp4; Decimal HighValueComp4; Decimal CommissinableAmountComp4;
                    if(cm.User_team__c == Commissions_Constants.COLLECTION_TEAM || cm.User_team__c == Commissions_Constants.COLLECTIONS_CLIENT_RELATIONS_MANAGERS){
                        //quotaPercentage4 = currentQuota.Collection_Quota_Percentage__c;
                        quotaPercentage4 = ((currentQuota.Collection_Total_Sale__c)/(currentQuota.Collection_Target_Amount__c))*100;
                        TeamName = Commissions_Constants.NEW_SALE_WITH_QUALIFIER;
                    }else{
                        quotaPercentage4 = ((cm.OpenBook_New_Sale_Comm_ble_Amount__c)/(currentQuota.Target_Amount__c))*100;
                        TeamName = Commissions_Constants.OPEN_SALE_COMPONENT;
                    }                
                    for(Payout__c pay : Payout.Values()){
                        if((cm.User_Team__c == Pay.RecordType.Name)){
                            if(pay.Low_Level__c == Null && pay.High_Level__c == Null){
                                LowValueComp4 = pay.Low_Amount__c;
                                HighValueComp4 = pay.High_Amount__c;
                                CommissinableAmountComp4 = quotaPercentage4;                                
                            }
                            if(pay.Low_Amount__c == Null && pay.High_Amount__c == Null){
                                LowValueComp4 = pay.Low_Level__c;
                                HighValueComp4 = pay.High_Level__c;
                                CommissinableAmountComp4 = quotaPercentage4;
                            }
                            
                            if((CommissinableAmountComp4 >= LowValueComp4)){
                                if(CommissinableAmountComp4 <= HighValueComp4) {
                                    if(pay.Name == TeamName){ //Commissions_Constants.OPEN_SALE_COMPONENT) 
                                        if(cm.User_team__c == Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM){
                                            cm.OpenBook_New_Sale_Payout__c = (pay.Commissionable__c).setScale(6);
                                            cm.OpenBook_New_Sale_Commission__c = (cm.OpenBook_New_Sale_Comm_ble_Amount__c * cm.OpenBook_New_Sale_Payout__c)/100;
                                            cm.Quota_Percentage_Achieved1__c = quotaPercentage4;
                                        }
                                        if(cm.User_team__c == Commissions_Constants.COLLECTION_TEAM || cm.User_team__c == Commissions_Constants.COLLECTIONS_CLIENT_RELATIONS_MANAGERS ){
                                            cm.OpenBook_New_Sale_Payout__c = (pay.Commissionable__c).setScale(2);
                                            cm.OpenBook_New_Sale_Commission__c = (cm.OpenBook_New_Sale_Comm_ble_Amount__c * cm.OpenBook_New_Sale_Payout__c)/100;
                                            cm.Quota_Percentage_Achieved1__c = quotaPercentage4;
                                        }                                   
                                        commissionsMap.put(cm.id,cm);
                                    }
                                    cm.Quota_Percentage_Achieved1__c = quotaPercentage4;
                                    commissionsMap.put(cm.id,cm);
                                }
                            }
                        }
                    }
                }
            }
        }        
        system.debug('commissionsMap : >>> '+commissionsMap.size());
        if(commissionsMap.size() > 0) {
            system.debug('commissionsMap : <<< '+commissionsMap);
            Commissions_TriggerHelperClass.firstRun = true;
            upsert commissionsMap.Values();
        }
        system.debug('Limit : '+limits.getHeapSize());
        UserIds.clear();AssetIds.clear();QuotaIds.clear();ProductIds.clear();commissionsMap.clear();mapUserTotalSale.clear();
        mapUserTotalSale2A.clear();mapUserTotalSale2B.clear();mapUserTotalSale2C.clear();mapUserTotalSale2D.clear();
        mapUserTotalSale3.clear();mapUserCommissionList.clear();Commissionlist.clear();Commissionlist1.clear();Assetlist1.clear();
        currentMonthQuota.clear();Payout.clear();ListProduct.clear();pay1.clear();
                //RECALCULATING COMMISSIONS FOR UPGRADE AND DOWNGRADE PROCESS AND ALSO UPDATING QUOTA PERCENTAGE ACHIVED TO ALL COMMISSIONS WITH 
        //LATEST COMMISSION QUOTA PERCENTAGE VALUE UPDATED TO ALL RELATED QUOTA COMMISSIONS
        
        Map<Id,Commission__c>  AllCommissions = new Map<ID, Commission__c>([select id,Name,Signing_AE__r.Name,Related_Commission__c,Is_Manager_Commission__c,CreatedDate,Related_to_Asset__c,product__r.Commission_Category__C,
                                                    Related_to_Quota__c,Asset_Amount__c,Quota_Percentage_Achieved1__c,Related_to_Quota__r.Target_Amount__c,Related_to_Quota__r.Quota_Percentage__c,Signing_AE__c,Commission_To__c,
                                                    RecordType.Name,User_Team__c,Total_Commissionable_Amount__c,CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c,CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c,CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c,
                                                    CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c,Payout_rate__c,Payout_Rate1B__c,CFCB_NEW_w_Qualifier_Payout_Rate2A__c,CFCB_New_w_o_Qualifier_Payout_Rate2B__c,CFCB_RNW_w_Qualifier_Payout_Rate2C__c,
                                                    CFCB_RNW_w_o_Qualifier_Payout_Rate2D__c,payout_rate_3__c,OpenBook_New_Sale_Comm_ble_Amount__c,OpenBook_New_Sale_Payout__c,Commissionable_Amount2__c,Commissionable_Amount1B__c,
                                                    Commissionable_Amount3__c,New_Sale_w_o_Qualifier_Commission__c,New_Sale_w_Qualifier_Commission__c,CFCB_NEW_w_Qualifier_Commission2A__c,CFCB_New_w_o_Qualifier_Commission2B__c,
                                                    CFCB_RNW_w_Qualifier_Commission2C__c,CFCB_RNW_w_o_Qualifier_Commission2D__c,Asset_Owner_Commission__c,TIGER_Commission4A__c,Collection_Commission__c,
                                                    Retention_Commission__c,OpenBook_New_Sale_Commission__c,RD_Payout_Rate__c
                                                    From Commission__c where Related_to_Quota__c IN : QuotaIds ORDER BY Name ASC]); 
        Integer MonthValue =  system.today().Month();   
        String RDTeam = '' ;
        if((MonthValue == 1) || (MonthValue == 2) || (MonthValue == 3)){
            RDTeam = 'Q3';
        }
        if(MonthValue == 04 || MonthValue == 05 || MonthValue == 06){
            RDTeam = 'Q4';
        }
        if(MonthValue == 07 || MonthValue == 08 || MonthValue == 09){
            RDTeam = 'Q1';
        }
        if(MonthValue == 10 || MonthValue == 11 || MonthValue == 12){
            RDTeam = 'Q2';
        }
        Map<Id,Commission__c> mapCommissions = new Map<Id,Commission__c>();
        Map<Id,User> users = New Map<id,User>([select id,Name from User where isActive = True]);
        for(commission__c cm1 : commissionsMap.Values()){
            Quota__c currentQuotaUpdate = currentMonthQuota.get(cm1.Related_to_Quota__c);
            Product2 Product1 = ListProduct.get(cm1.Product__c);
            for(Commission__c allCommissionsupdate : AllCommissions.Values()){                
                if(cm1.RecordType.Name != Commissions_Constants.COMMISSIONS_CLAWBACK){                    
                    if(cm1.Related_to_Quota__c == allCommissionsupdate.Related_to_Quota__c){  
                        Datetime temp1,temp2;       
                        temp1 = DateTime.now();
                        Integer recordCreatedMonth;  Integer currentMonth ;
                        currentMonth = temp1.Month();
                        recordCreatedMonth = (allCommissionsupdate.CreatedDate.month());   
                        user u = users.get(allCommissionsupdate.Signing_AE__c);
                        if(((currentQuotaUpdate.User_Team__c != Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM) && (currentMonth == recordCreatedMonth)) || 
                            (currentQuotaUpdate.User_Team__c == Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM && RDTeam == currentQuotaUpdate.Current_Quater__c )){
                            if(cm1.Quota_Percentage_Achieved1__c != 0.0 && cm1.Quota_Percentage_Achieved1__c != null){                                    
                                allCommissionsupdate.Quota_Percentage_Achieved1__c = cm1.Quota_Percentage_Achieved1__c;
                                mapCommissions.put(allCommissionsupdate.id,allCommissionsupdate);
                            }
                            if(cm1.Quota_Percentage_Achieved1__c == 0.0 || cm1.Quota_Percentage_Achieved1__c == Null){                                        
                                cm1.Quota_Percentage_Achieved1__c = allCommissionsupdate.Related_to_Quota__r.Quota_Percentage__c;
                                mapCommissions.put(cm1.id,cm1);
                            }
                            if(cm1.Payout_rate__c != Null && cm1.Payout_rate__c != 0.0){                                
                                if(allCommissionsupdate.Commissionable_Amount2__c != 0.0 && allCommissionsupdate.Commissionable_Amount2__c != Null){       
                                    allCommissionsupdate.Payout_rate__c = (cm1.Payout_rate__c).setScale(2);                                    
                                    allCommissionsupdate.Payout_Rate1B__c = 0.0;
                                    allCommissionsupdate.OpenBook_New_Sale_Payout__c = 0.0;
                                    allCommissionsupdate.Payout_Rate_3__c = 0.0;
                                    allCommissionsupdate.New_Sale_w_o_Qualifier_Commission__c = (allCommissionsupdate.Payout_Rate__c * allCommissionsupdate.Commissionable_Amount2__c)/100;
                                    mapCommissions.put(allCommissionsupdate.id,allCommissionsupdate);
                                }
                                if(allCommissionsupdate.Commissionable_Amount3__c != 0.0 && allCommissionsupdate.Commissionable_Amount3__c != Null){                                    
                                    allCommissionsupdate.Payout_Rate_3__c = (cm1.Payout_rate__c).setScale(2);                                    
                                    allCommissionsupdate.Payout_rate__c = 0.0;
                                    allCommissionsupdate.Payout_Rate1B__c = 0.0;
                                    allCommissionsupdate.OpenBook_New_Sale_Payout__c = 0.0;
                                    allCommissionsupdate.Asset_Owner_Commission__c = (allCommissionsupdate.Commissionable_Amount3__c * allCommissionsupdate.Payout_Rate_3__c)/100;
                                    mapCommissions.put(allCommissionsupdate.id,allCommissionsupdate); 
                                }
                                if(allCommissionsupdate.OpenBook_New_Sale_Comm_ble_Amount__c != 0.0 && allCommissionsupdate.OpenBook_New_Sale_Comm_ble_Amount__c != Null){
                                    allCommissionsupdate.OpenBook_New_Sale_Payout__c = (cm1.Payout_rate__c).setScale(2);
                                    allCommissionsupdate.OpenBook_New_Sale_Commission__c = (allCommissionsupdate.OpenBook_New_Sale_Comm_ble_Amount__c * allCommissionsupdate.OpenBook_New_Sale_Payout__c)/100;
                                    allCommissionsupdate.Payout_Rate_3__c = 0.0;                               
                                    allCommissionsupdate.Payout_rate__c = 0.0;
                                    allCommissionsupdate.Payout_Rate1B__c = 0.0;
                                    mapCommissions.put(allCommissionsupdate.id,allCommissionsupdate); 
                                }                               
                            }
                            if(cm1.Payout_Rate1B__c != Null && cm1.Payout_Rate1B__c != 0.0){
                                if(allCommissionsupdate.Commissionable_Amount1B__c != 0.0 && allCommissionsupdate.Commissionable_Amount1B__c != Null){
                                    allCommissionsupdate.Payout_Rate1B__c = (cm1.Payout_Rate1B__c).setScale(2);
                                    allCommissionsupdate.Payout_rate__c = 0.0;
                                    allCommissionsupdate.OpenBook_New_Sale_Payout__c = 0.0;
                                    allCommissionsupdate.Payout_Rate_3__c = 0.0;
                                    allCommissionsupdate.New_Sale_w_Qualifier_Commission__c = (allCommissionsupdate.Payout_Rate1B__c * allCommissionsupdate.Commissionable_Amount1B__c)/100;
                                    mapCommissions.put(allCommissionsupdate.id,allCommissionsupdate);
                                }
                                if(allCommissionsupdate.Commissionable_Amount3__c != 0.0 || allCommissionsupdate.Commissionable_Amount3__c != Null){
                                    allCommissionsupdate.Payout_Rate_3__c = (cm1.Payout_Rate1B__c).setScale(2);
                                    allCommissionsupdate.Payout_rate__c = 0.0;
                                    allCommissionsupdate.Payout_Rate1B__c = 0.0;
                                    allCommissionsupdate.OpenBook_New_Sale_Payout__c = 0.0;
                                    allCommissionsupdate.Asset_Owner_Commission__c = (allCommissionsupdate.Commissionable_Amount3__c * allCommissionsupdate.Payout_Rate_3__c)/100;
                                    mapCommissions.put(allCommissionsupdate.id,allCommissionsupdate); 
                                }
                                if(allCommissionsupdate.OpenBook_New_Sale_Comm_ble_Amount__c != 0.0 && allCommissionsupdate.OpenBook_New_Sale_Comm_ble_Amount__c != Null){
                                    allCommissionsupdate.OpenBook_New_Sale_Payout__c = (cm1.Payout_Rate1B__c);
                                    allCommissionsupdate.OpenBook_New_Sale_Commission__c = (allCommissionsupdate.OpenBook_New_Sale_Comm_ble_Amount__c * allCommissionsupdate.OpenBook_New_Sale_Payout__c)/100;
                                    allCommissionsupdate.Payout_Rate_3__c = 0.0;                               
                                    allCommissionsupdate.Payout_rate__c = 0.0;
                                    allCommissionsupdate.Payout_Rate1B__c = 0.0;
                                    mapCommissions.put(allCommissionsupdate.id,allCommissionsupdate); 
                                }                               
                            }                                
                            if(Product1.Commission_Category__c == 'CFCB' && cm1.CFCB_NEW_w_Qualifier_Payout_Rate2A__c != Null && cm1.CFCB_New_w_o_Qualifier_Payout_Rate2B__c != Null 
                                && cm1.CFCB_RNW_w_Qualifier_Payout_Rate2C__c != Null && cm1.CFCB_RNW_w_o_Qualifier_Payout_Rate2D__c != Null){  
                                if(allCommissionsupdate.CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c != 0.0){
                                    allCommissionsupdate.CFCB_NEW_w_Qualifier_Payout_Rate2A__c = (cm1.CFCB_NEW_w_Qualifier_Payout_Rate2A__c);
                                    allCommissionsupdate.CFCB_NEW_w_Qualifier_Commission2A__c = (allCommissionsupdate.CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c * allCommissionsupdate.CFCB_NEW_w_Qualifier_Payout_Rate2A__c)/100;
                                    mapCommissions.put(allCommissionsupdate.id,allCommissionsupdate);
                                }
                                if(allCommissionsupdate.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c != 0.0){
                                    allCommissionsupdate.CFCB_New_w_o_Qualifier_Payout_Rate2B__c = (cm1.CFCB_New_w_o_Qualifier_Payout_Rate2B__c);
                                    allCommissionsupdate.CFCB_New_w_o_Qualifier_Commission2B__c = (allCommissionsupdate.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c * allCommissionsupdate.CFCB_New_w_o_Qualifier_Payout_Rate2B__c)/100;
                                    mapCommissions.put(allCommissionsupdate.id,allCommissionsupdate);
                                }
                                if(allCommissionsupdate.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c != 0.0){
                                    allCommissionsupdate.CFCB_RNW_w_Qualifier_Payout_Rate2C__c = (cm1.CFCB_RNW_w_Qualifier_Payout_Rate2C__c);
                                    allCommissionsupdate.CFCB_RNW_w_Qualifier_Commission2C__c = (allCommissionsupdate.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c * allCommissionsupdate.CFCB_RNW_w_Qualifier_Payout_Rate2C__c)/100;
                                    mapCommissions.put(allCommissionsupdate.id,allCommissionsupdate);
                                }
                                if(allCommissionsupdate.CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c != 0.0){
                                    allCommissionsupdate.CFCB_RNW_w_o_Qualifier_Payout_Rate2D__c = (cm1.CFCB_RNW_w_o_Qualifier_Payout_Rate2D__c);
                                    allCommissionsupdate.CFCB_RNW_w_o_Qualifier_Commission2D__c = (allCommissionsupdate.CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c * allCommissionsupdate.CFCB_RNW_w_o_Qualifier_Payout_Rate2D__c)/100;
                                    mapCommissions.put(allCommissionsupdate.id,allCommissionsupdate);
                                }
                            }                            
                            if(cm1.Payout_Rate_3__c != Null && cm1.Payout_Rate_3__c != 0.0 ){                                
                                if(allCommissionsupdate.Commissionable_Amount3__c != 0.0 && allCommissionsupdate.Commissionable_Amount3__c != null){
                                    allCommissionsupdate.Payout_Rate_3__c = (cm1.Payout_Rate_3__c);
                                    allCommissionsupdate.Payout_rate__c = 0.0;
                                    allCommissionsupdate.Payout_Rate1B__c = 0.0;
                                    allCommissionsupdate.OpenBook_New_Sale_Payout__c = 0.0;
                                    allCommissionsupdate.Asset_Owner_Commission__c = (allCommissionsupdate.Commissionable_Amount3__c * allCommissionsupdate.Payout_Rate_3__c)/100;
                                    mapCommissions.put(allCommissionsupdate.id,allCommissionsupdate); 
                                }
                                if(allCommissionsupdate.Commissionable_Amount2__c != 0.0 && allCommissionsupdate.Commissionable_Amount2__c != Null){                                                                     
                                    allCommissionsupdate.Payout_rate__c = (cm1.Payout_Rate_3__c);                                    
                                    allCommissionsupdate.Payout_Rate1B__c = 0.0;
                                    allCommissionsupdate.OpenBook_New_Sale_Payout__c = 0.0;
                                    allCommissionsupdate.Payout_Rate_3__c = 0.0;
                                    allCommissionsupdate.New_Sale_w_o_Qualifier_Commission__c = (allCommissionsupdate.Payout_Rate__c * allCommissionsupdate.Commissionable_Amount2__c)/100;
                                    mapCommissions.put(allCommissionsupdate.id,allCommissionsupdate);
                                }
                                if(allCommissionsupdate.Commissionable_Amount1B__c != 0.0 && allCommissionsupdate.Commissionable_Amount1B__c != Null){
                                    allCommissionsupdate.Payout_Rate1B__c = (cm1.Payout_Rate_3__c);
                                    allCommissionsupdate.Payout_rate__c = 0.0;
                                    allCommissionsupdate.OpenBook_New_Sale_Payout__c = 0.0;
                                    allCommissionsupdate.Payout_Rate_3__c = 0.0;
                                    allCommissionsupdate.New_Sale_w_Qualifier_Commission__c = (allCommissionsupdate.Payout_Rate1B__c * allCommissionsupdate.Commissionable_Amount1B__c)/100;
                                    mapCommissions.put(allCommissionsupdate.id,allCommissionsupdate);
                                }
                            }
                            if(cm1.OpenBook_New_Sale_Comm_ble_Amount__c != Null && cm1.OpenBook_New_Sale_Comm_ble_Amount__c != 0.0 && cm1.User_Team__c != Commissions_Constants.BROKER_REGIONAL_DIRECTORS_SALES_TEAM  ){
                                if(cm1.id != allCommissionsupdate.id && cm1.User_team__c != Commissions_Constants.COLLECTION_TEAM && cm1.User_team__c != Commissions_Constants.COLLECTIONS_CLIENT_RELATIONS_MANAGERS){
                                    if(allCommissionsupdate.Payout_rate__c != 0.0 || allCommissionsupdate.Payout_rate__c != Null){
                                        cm1.OpenBook_New_Sale_Payout__c = (allCommissionsupdate.Payout_rate__c);
                                    }
                                    if(allCommissionsupdate.Payout_Rate1B__c != 0.0 || allCommissionsupdate.Payout_Rate1B__c != Null){
                                        cm1.OpenBook_New_Sale_Payout__c = (allCommissionsupdate.Payout_Rate1B__c);
                                    }
                                    if(allCommissionsupdate.Payout_Rate_3__c != 0.0 || allCommissionsupdate.Payout_Rate_3__c != Null){
                                        cm1.OpenBook_New_Sale_Payout__c = (allCommissionsupdate.Payout_Rate_3__c);
                                    }
                                    cm1.OpenBook_New_Sale_Commission__c = (cm1.OpenBook_New_Sale_Payout__c * cm1.OpenBook_New_Sale_Comm_ble_Amount__c)/100;                                 
                                    mapCommissions.put(cm1.id,cm1);
                                }                                                              
                            }                                
                        }          
                    }                   
                    //mapCommissions.put(allCommissionsupdate.id,allCommissionsupdate); 
                }                          
                if(cm1.RecordType.Name == Commissions_Constants.COMMISSIONS_CLAWBACK){             
                    if((cm1.Related_Commission__c == allCommissionsupdate.id) && (allCommissionsupdate.id!= Null)){ 
                        if(allCommissionsupdate.Quota_Percentage_Achieved1__c != 0.0 && allCommissionsupdate.Quota_Percentage_Achieved1__c != Null){                   
                            cm1.Quota_Percentage_Achieved1__c = allCommissionsupdate.Related_to_Quota__r.Quota_Percentage__c;
                            mapCommissions.put(cm1.id,cm1);
                        }
                        if(cm1.User_Team__c != Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM){
                            if(allCommissionsupdate.Payout_Rate__c != Null && allCommissionsupdate.Payout_Rate__c != 0.0){                  
                                cm1.Payout_rate__c = (allCommissionsupdate.Payout_rate__c);
                                if(cm1.Payout_Rate__c != 0.0 && cm1.Payout_Rate__c != null && cm1.Commissionable_Amount2__c != 0.0 &&cm1.Commissionable_Amount2__c!= Null){
                                    cm1.New_Sale_w_o_Qualifier_Commission__c = (cm1.Payout_Rate__c * cm1.Commissionable_Amount2__c)/100;
                                    mapCommissions.put(cm1.id,cm1);
                                }                              
                            }                           
                            if(allCommissionsupdate.Payout_Rate1B__c != Null && allCommissionsupdate.Payout_Rate1B__c != 0.0){                  
                                cm1.Payout_Rate1B__c = (allCommissionsupdate.Payout_Rate1B__c);
                                if(cm1.Payout_Rate1B__c != 0.0 && cm1.Payout_Rate1B__c != null && cm1.Commissionable_Amount1B__c != 0.0 &&cm1.Commissionable_Amount1B__c!= Null){
                                    cm1.New_Sale_w_Qualifier_Commission__c = (cm1.Payout_Rate1B__c * cm1.Commissionable_Amount1B__c)/100;                                        
                                    mapCommissions.put(cm1.id,cm1);
                                }                               
                            }   
                        }
                        if(cm1.User_Team__c == Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM){
                            if(allCommissionsupdate.RD_Payout_Rate__c != Null && allCommissionsupdate.RD_Payout_Rate__c != 0.0){                  
                                cm1.Payout_rate__c = (allCommissionsupdate.Payout_rate__c);
                                cm1.Payout_Rate1B__c = (allCommissionsupdate.Payout_Rate1B__c);
                                if(cm1.Commissionable_Amount2__c != 0.0 &&cm1.Commissionable_Amount2__c!= Null){
                                    cm1.New_Sale_w_o_Qualifier_Commission__c = (cm1.RD_Payout_Rate__c * cm1.Commissionable_Amount2__c)/100;
                                    mapCommissions.put(cm1.id,cm1);
                                }
                                if(cm1.Commissionable_Amount1B__c != 0.0 &&cm1.Commissionable_Amount1B__c!= Null){                              
                                    cm1.New_Sale_w_Qualifier_Commission__c = (cm1.RD_Payout_Rate__c * cm1.Commissionable_Amount1B__c)/100;                                        
                                    mapCommissions.put(cm1.id,cm1);
                                }   
                            }
                        }
                        if(Product1.Commission_Category__c == 'CFCB' && allCommissionsupdate.CFCB_NEW_w_Qualifier_Payout_Rate2A__c != Null && allCommissionsupdate.CFCB_New_w_o_Qualifier_Payout_Rate2B__c != Null && allCommissionsupdate.CFCB_RNW_w_Qualifier_Payout_Rate2C__c != Null && allCommissionsupdate.CFCB_RNW_w_o_Qualifier_Payout_Rate2D__c != Null){  
                            if(cm1.CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c != 0.0){
                                cm1.CFCB_NEW_w_Qualifier_Payout_Rate2A__c = (cm1.CFCB_NEW_w_Qualifier_Payout_Rate2A__c);
                                cm1.CFCB_NEW_w_Qualifier_Commission2A__c = (cm1.CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c * cm1.CFCB_NEW_w_Qualifier_Payout_Rate2A__c)/100;                                        
                                mapCommissions.put(cm1.id,cm1);
                            }
                            if(cm1.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c != 0.0){
                                cm1.CFCB_New_w_o_Qualifier_Payout_Rate2B__c = (cm1.CFCB_New_w_o_Qualifier_Payout_Rate2B__c);
                                cm1.CFCB_New_w_o_Qualifier_Commission2B__c = (cm1.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c * cm1.CFCB_New_w_o_Qualifier_Payout_Rate2B__c)/100;                                   
                                mapCommissions.put(cm1.id,cm1);
                            }
                            if(cm1.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c != 0.0){
                                cm1.CFCB_RNW_w_Qualifier_Payout_Rate2C__c = (cm1.CFCB_RNW_w_Qualifier_Payout_Rate2C__c);
                                cm1.CFCB_RNW_w_Qualifier_Commission2C__c = (cm1.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c * cm1.CFCB_RNW_w_Qualifier_Payout_Rate2C__c)/100;                                 
                                mapCommissions.put(cm1.id,cm1);
                            }
                            if(cm1.CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c != 0.0){
                                cm1.CFCB_RNW_w_o_Qualifier_Payout_Rate2D__c = (cm1.CFCB_RNW_w_o_Qualifier_Payout_Rate2D__c);
                                cm1.CFCB_RNW_w_o_Qualifier_Commission2D__c = (cm1.CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c * cm1.CFCB_RNW_w_o_Qualifier_Payout_Rate2D__c)/100;                                   
                                mapCommissions.put(cm1.id,cm1);
                            }                                                       
                        }                        
                    }
                    
                    if(cm1.Related_Commission__c == Null){                        
                        if(cm1.Related_to_Quota__c == allCommissionsupdate.Related_to_Quota__c){                   
                            if(allCommissionsupdate.Quota_Percentage_Achieved1__c != 0.0 && allCommissionsupdate.Quota_Percentage_Achieved1__c != Null){                                        
                                cm1.Quota_Percentage_Achieved1__c = allCommissionsupdate.Related_to_Quota__r.Quota_Percentage__c;
                                mapCommissions.put(cm1.id,cm1);
                            }
                            if(cm1.User_Team__c != Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM){   
                                if(allCommissionsupdate.Payout_Rate__c != Null && allCommissionsupdate.Payout_Rate__c != 0.0 && cm1.Commissionable_Amount2__c != Null && cm1.Commissionable_Amount2__c != 0.0){                                
                                    cm1.Payout_rate__c = allCommissionsupdate.Payout_rate__c;
                                    cm1.New_Sale_w_o_Qualifier_Commission__c = (cm1.Payout_Rate__c * cm1.Commissionable_Amount2__c)/100;                                  
                                    mapCommissions.put(cm1.id,cm1);
                                    break;
                                }
                                if(allCommissionsupdate.Payout_Rate1B__c != Null && allCommissionsupdate.Payout_Rate1B__c != 0.0 && cm1.Commissionable_Amount1B__c != Null && cm1.Commissionable_Amount1B__c != 0.0){                                
                                    cm1.Payout_Rate1B__c = (allCommissionsupdate.Payout_Rate1B__c);
                                    cm1.New_Sale_w_Qualifier_Commission__c = (cm1.Payout_Rate1B__c * cm1.Commissionable_Amount1B__c)/100;
                                    mapCommissions.put(cm1.id,cm1);
                                    break;
                                }
                            }
                            if(cm1.User_Team__c == Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM){   
                                if(allCommissionsupdate.RD_Payout_Rate__c != Null && allCommissionsupdate.RD_Payout_Rate__c != 0.0){                                
                                    cm1.Payout_rate__c = allCommissionsupdate.Payout_rate__c;
                                    cm1.Payout_Rate1B__c = (allCommissionsupdate.Payout_Rate1B__c);
                                    if(cm1.Commissionable_Amount2__c !=Null && cm1.Commissionable_Amount2__c != 0.0 ){
                                        cm1.New_Sale_w_o_Qualifier_Commission__c = (cm1.RD_Payout_Rate__c * cm1.Commissionable_Amount2__c)/100;
                                        mapCommissions.put(cm1.id,cm1);
                                        break;
                                    }
                                    if(cm1.Commissionable_Amount1B__c !=Null && cm1.Commissionable_Amount1B__c !=0.0){                                        
                                        cm1.New_Sale_w_Qualifier_Commission__c = (cm1.RD_Payout_Rate__c * cm1.Commissionable_Amount1B__c)/100;
                                        mapCommissions.put(cm1.id,cm1);
                                        break;
                                    }
                                }
                            }
                            
                            if(Product1.Commission_Category__c == 'CFCB' && allCommissionsupdate.CFCB_NEW_w_Qualifier_Payout_Rate2A__c != Null && allCommissionsupdate.CFCB_New_w_o_Qualifier_Payout_Rate2B__c != Null && allCommissionsupdate.CFCB_RNW_w_Qualifier_Payout_Rate2C__c != Null && allCommissionsupdate.CFCB_RNW_w_o_Qualifier_Payout_Rate2D__c != Null){  
                                if(cm1.CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c != 0.0){
                                    cm1.CFCB_NEW_w_Qualifier_Payout_Rate2A__c = (cm1.CFCB_NEW_w_Qualifier_Payout_Rate2A__c);
                                    cm1.CFCB_NEW_w_Qualifier_Commission2A__c = (cm1.CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c * cm1.CFCB_NEW_w_Qualifier_Payout_Rate2A__c)/100;
                                    mapCommissions.put(cm1.id,cm1);
                                }
                                if(cm1.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c != 0.0){
                                    cm1.CFCB_New_w_o_Qualifier_Payout_Rate2B__c = (cm1.CFCB_New_w_o_Qualifier_Payout_Rate2B__c);
                                    cm1.CFCB_New_w_o_Qualifier_Commission2B__c = (cm1.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c * cm1.CFCB_New_w_o_Qualifier_Payout_Rate2B__c)/100;                                   
                                    mapCommissions.put(cm1.id,cm1);
                                }
                                if(cm1.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c != 0.0){
                                    cm1.CFCB_RNW_w_Qualifier_Payout_Rate2C__c = (cm1.CFCB_RNW_w_Qualifier_Payout_Rate2C__c);
                                    cm1.CFCB_RNW_w_Qualifier_Commission2C__c = (cm1.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c * cm1.CFCB_RNW_w_Qualifier_Payout_Rate2C__c)/100;                                 
                                    mapCommissions.put(cm1.id,cm1);
                                }
                                if(cm1.CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c != 0.0){
                                    cm1.CFCB_RNW_w_o_Qualifier_Payout_Rate2D__c = (cm1.CFCB_RNW_w_o_Qualifier_Payout_Rate2D__c);
                                    cm1.CFCB_RNW_w_o_Qualifier_Commission2D__c = (cm1.CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c * cm1.CFCB_RNW_w_o_Qualifier_Payout_Rate2D__c)/100;                                   
                                    mapCommissions.put(cm1.id,cm1);
                                }
                                break;
                            }                               
                        }                        
                    }                    
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
        List<Quota__c> updateQuota = new List<Quota__c>();
        if(currentMonthQuota.size() > 0){
            for(Quota__c q1 : currentMonthQuota.values()){
                Quota__c q2 = new Quota__c();
                q2.id = q1.id;
                updateQuota.add(q2);
            }
            if(updateQuota.size() > 0){
                update updateQuota;
            }
        }
        AllCommissions.clear();
        mapCommissions.clear();
        updateQuota.clear();
        ***/
    }      
}