/***********************************************************************************
Created By          :    Srinivas Pendli    
Created Date        :    28.07.2015
Company             :    NTT Data,Inc.
Usage               :    The main purpose of this class is to update conditional matrix for all Teams                         
Modified By         :    Srinivas Pendli
Modifide Date       :    13.09.2015
************************************************************************************/

Public with sharing class Commissions_CreateCommsfromOrderProduct{
    //@future   
    //Public static void OnIsinsert(set<id> allCommissionIds,Boolean IsUpdate){ 
    Public static void OnIsinsert(set<id> allCommissionIds){   
        /**********************
        //set<id> allCommissionIds;      
        Commissions_TriggerHelperClass.firstRun = false;                  
        Set<Id> orderProductIds = new Set<Id>();            
        Set<Id> QuotaIds = new Set<Id>(); 
        Set<Id> ProductIds = new Set<Id>();          
        Decimal Componet4ARollUpValue = 0.0;
        Decimal Componet1RollUpValue = 0.0;
        Decimal Componet3RollUpValue = 0.0;         
        Decimal quotaPercentage = 0.0;                     
        Decimal quotaPercentage3 = 0.0; 
        Decimal quotaPercentage4A = 0.0;
         Decimal quotaPercentage4 = 0.0;         
        Map<id,commission__c> commissionsMap = new Map<id,commission__c>();
        Map<String,Decimal> mapUserTotalSale = new Map<String,Decimal>();
        Map<String,Decimal> mapUserTotalSale4A = new Map<String,Decimal>();
        Map<String,Decimal> mapUserTotalSale3 = new Map<String,Decimal>();               
        Map<Id,List<commission__c>> mapUserCommissionList = new Map<Id,List<commission__c>>();
        Datetime myDate = datetime.now().addSeconds(-60);
        system.debug('myDate  : '+myDate );
        Map<ID,Commission__c> Commissionlist = new Map<ID,Commission__c>([select id,Signing_AE__c,commission_To__c,User_Team__c,TIGER_Commissionable_Amount4A__c,RecordType.Name,Order_Product__c,Related_to_Quota__r.User__c,
                                                    Product__r.Commission_Category__c,Related_to_Quota__c,Related_to_Quota__r.Target_Amount__c,Commissionable_Amount3__c,CreatedDate,Commissionable_Amount2__c,Quota_Percentage_Achieved1__c,Product__c,
                                                    Name,Payout_Rate__c,TIGER_Payout_Rate4A__c,LastModifiedDate,Payout_Rate1B__c,OpenBook_New_Sale_Payout__c,OpenBook_New_Sale_Comm_ble_Amount__c,
                                                    New_Sale_w_o_Qualifier_Commission__c,New_Sale_w_Qualifier_Commission__c,CFCB_NEW_w_Qualifier_Commission2A__c,CFCB_New_w_o_Qualifier_Commission2B__c,
                                                    CFCB_RNW_w_Qualifier_Commission2C__c,CFCB_RNW_w_o_Qualifier_Commission2D__c,Asset_Owner_Commission__c,TIGER_Commission4A__c,
                                                    OpenBook_New_Sale_Commission__c 
                                                    from Commission__c where Order_Product__c != null and Id In : allCommissionIds order by Name Asc]);                                                  
        system.debug('Commissionlist >> :'+Commissionlist);
        for(Commission__c comm : Commissionlist.Values()){    
            QuotaIds.add(comm.Related_to_Quota__c);
            orderProductIds.add(comm.Order_Product__c);
        }  
        Map<id,Commission__c> allExistingCommissionlist = new Map<id,Commission__c>([select id,Signing_AE__c,User_Team__c,commission_To__c,TIGER_Commissionable_Amount4A__c,RecordType.Name,Total_Commissionable_Amount__c,
                                                            Related_to_Quota__r.User__c,Product__r.Commission_Category__c,Related_to_Quota__r.Target_Amount__c,Commissionable_Amount3__c,Related_to_Quota__c,CreatedDate,Commissionable_Amount2__c,
                                                            Quota_Percentage_Achieved1__c,Product__c,name,Payout_Rate__c,TIGER_Payout_Rate4A__c,Payout_Rate1B__c,OpenBook_New_Sale_Payout__c,OpenBook_New_Sale_Comm_ble_Amount__c, 
                                                            New_Sale_w_o_Qualifier_Commission__c,New_Sale_w_Qualifier_Commission__c,CFCB_NEW_w_Qualifier_Commission2A__c,CFCB_New_w_o_Qualifier_Commission2B__c,
                                                            CFCB_RNW_w_Qualifier_Commission2C__c,CFCB_RNW_w_o_Qualifier_Commission2D__c,Asset_Owner_Commission__c,TIGER_Commission4A__c,
                                                            OpenBook_New_Sale_Commission__c
                                                            from Commission__c where RecordTypeId !=: Commissions_Constants.COMMISSIONS_CLAWBACK and User_Team__c !=: Commissions_Constants.COLLECTION_TEAM and User_team__c !=: Commissions_Constants.COLLECTIONS_CLIENT_RELATIONS_MANAGERS and 
                                                            Related_to_Quota__c IN : QuotaIds order by Name Asc]);
        system.debug('allExistingCommissionlist >> :'+allExistingCommissionlist);       
        
        for(Commission__c comm : allExistingCommissionlist.Values()){ 
            QuotaIds.add(comm.Related_to_Quota__c);  
        }  
        Date startOfMonth = Date.today().toStartOfMonth(); 
        Map<Id,Quota__c> currentMonthQuota = new Map<id,Quota__c>([select id,Name,User_Team__c,User__c,User__r.CreatedDate,User__r.Name,Target_Amount__c,Total_Sale__c,Total_Sale_2__c,RD_Team_Qualifier__c,
                                                User__r.Payout_Rate_Month_1__c,User__r.Payout_Rate_Month_2__c,User__r.Payout_Rate_Month_3__c,Quota_Percentage__c,Period_Name__r.Sigh_In_AE__c,
                                                Period_Name__r.Asset_Owner__c,Period_Name__c from Quota__c where id IN : QuotaIds]);
        
        Set<Id> PeriodIds = new Set<Id>();
        for(Quota__c quota : currentMonthQuota.Values()){
            system.debug('QuotaIds : '+Quota.Period_Name__c);
            PeriodIds.add(quota.Period_Name__c);
        }
        //NEW SALE COMMISSION ROLLUP CALACULATION
        Id newSaleRT = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('New Sale').getRecordTypeId(); 
        for(Commission__c comm : allExistingCommissionlist.Values()){                 
            if(comm.RecordType.Name != Commissions_Constants.COMMISSIONS_CLAWBACK || (comm.RecordTypeId == newSaleRT && comm.User_Team__c != Commissions_Constants.COLLECTION_TEAM && comm.User_team__c != Commissions_Constants.COLLECTIONS_CLIENT_RELATIONS_MANAGERS)){
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
        system.debug('+++++++++++mapUserCommissionList >> :'+mapUserCommissionList);
        for(Id idds : mapUserCommissionList.keyset()){
            Decimal decc = 0.0; Decimal decc4A = 0.0; Decimal decc3 = 0.0;
            for(commission__c comm1 : mapUserCommissionList.get(idds)){
                Quota__c currentQuota = currentMonthQuota.get(comm1.Related_to_Quota__c);                            
                if((comm1.Total_Commissionable_Amount__c != 0.0) && (comm1.Total_Commissionable_Amount__c != Null)){
                    decc = decc + (comm1.Total_Commissionable_Amount__c);
                    mapUserTotalSale.put(idds+'###'+comm1.Name,decc);                    
                }
                if(comm1.Total_Commissionable_Amount__c == 0.0){
                    decc = decc + (comm1.Total_Commissionable_Amount__c);
                    mapUserTotalSale.put(idds+'###'+comm1.Name,decc);                    
                }
                if(comm1.TIGER_Commissionable_Amount4A__c != 0.0){
                    decc4A = decc4A + (comm1.TIGER_Commissionable_Amount4A__c);
                    mapUserTotalSale4A.put(idds+'###'+comm1.Name,decc4A);
                }
                if((comm1.Commissionable_Amount3__c != 0.0 ) && (comm1.Commissionable_Amount3__c != Null)){
                    decc3 = decc3 +(comm1.Commissionable_Amount3__c);
                    mapUserTotalSale3.put(idds+'###'+comm1.Name,decc3);                     
                }
            }
        } 
        system.debug('PeriodIds : '+PeriodIds);
        Map<Id,Payout__C> Payout = new Map<ID, Payout__C>([select id ,name,RecordType.Name,High_Level__c,Low_Level__c,Low_Amount__c, High_Amount__c,Commissionable__c from Payout__c
                                        where RecordType.Name !=: Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM and Period__c In : PeriodIds  Order by Low_Level__c Desc]);          
        system.debug('Payout <<<<<< : '+Payout.size());
        Map<Id,Payout__c> pay1 = new Map<ID, Payout__c>([select id, name, Low_level__c, High_Level__c,Low_Amount__c,High_Amount__c, Commissionable__c, RecordType.Name from Payout__c 
                                                    where RecordType.Name =: Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM ORDER BY High_Level__c DESC ]);
        Map<Id,Product2> ListProduct = new Map<ID, Product2>([select id,Name,Normalization_factor__c,Commission_Category__c from Product2 where id In : ProductIds]); 
        
        Map<Id,OrderItem> orderItems = new Map<Id,OrderItem>([select id,PricebookEntryId,OrderId,OrderItemNumber from OrderItem where Id In : orderProductIds]);                                        
        system.debug('orderItems <<<<<< : '+orderItems);
        Set<Id> OrderIds = new set<Id>();
        for(OrderItem orderRecord : orderItems.Values()){
            OrderIds.add(orderRecord.OrderId);
        }
        Map<Id,Order> orders = new Map<Id,Order>([select id,ownerId,AccountId,Account.OwnerId,TotalAmount from Order where Id In : orderIds]);
        system.debug('orders <<<<<< : '+orders);
        set<Id> accountIds = new Set<Id>();
        for(Order ord : orders.Values()){
            AccountIds.add(ord.AccountId);
        }
        Map<id,Account> allAccounts = new Map<id,Account>([select id,Name,OwnerId,type from Account where Id In : accountIds]);
        string TeamName;
        for(commission__c cm : Commissionlist.Values()){
            
            quotaPercentage4 =0.0;            
            quotaPercentage = 0.0;quotaPercentage3 = 0.0;Componet1RollUpValue = 0.0;Componet3RollUpValue = 0.0;Componet4ARollUpValue = 0.0;
            Quota__c currentQuota = currentMonthQuota.get(cm.Related_to_Quota__c);
            Product2 Product = ListProduct.get(cm.Product__c);
            system.debug('cm product : '+cm.Order_Product__c);
            orderItem orderItemRecord = orderItems.get(cm.Order_Product__c);
            system.debug('orderItemRecord >>:'+orderItemRecord.id);
            system.debug('orderItemRecord >>>>:'+orderItemRecord.OrderId);
            order Ords = orders.get(orderItemRecord.OrderId);
            account acc = allAccounts.get(Ords.AccountId);            
            if(cm.RecordType.Name != Commissions_Constants.COMMISSIONS_CLAWBACK && (cm.OpenBook_New_Sale_Comm_ble_Amount__c == 0.0 || cm.OpenBook_New_Sale_Comm_ble_Amount__c == Null)){                             
                if((cm.Signing_AE__c == acc.OwnerId) && (cm.Related_to_Quota__r.Target_Amount__c != null && cm.Related_to_Quota__r.Target_Amount__c != 0)){                           
                    if(cm.Signing_AE__c == currentQuota.user__c){
                        quotaPercentage = ((mapUserTotalSale.get(cm.Related_to_Quota__r.user__c+'###'+cm.Name))/cm.Related_to_Quota__r.Target_Amount__c)*100;
                        Componet1RollUpValue = mapUserTotalSale.get(cm.Related_to_Quota__r.user__c+'###'+cm.Name);
                        if((Product.Commission_Category__c == 'Tiger') || (Product.Commission_Category__c == 'TL')){ 
                            Componet4ARollUpValue = mapUserTotalSale4A.get(cm.Related_to_Quota__r.user__c+'###'+cm.Name);
                        }               
                    }
                }
                if((cm.Signing_AE__c != acc.OwnerId) && (cm.Related_to_Quota__r.Target_Amount__c != null && cm.Related_to_Quota__r.Target_Amount__c != 0)){                           
                    if(cm.Signing_AE__c == currentQuota.user__c){
                        quotaPercentage = ((mapUserTotalSale.get(cm.Related_to_Quota__r.user__c+'###'+cm.Name))/cm.Related_to_Quota__r.Target_Amount__c)*100;
                        Componet1RollUpValue = mapUserTotalSale.get(cm.Related_to_Quota__r.user__c+'###'+cm.Name);
                        if((Product.Commission_Category__c == 'Tiger') || (Product.Commission_Category__c == 'TL')){ 
                            Componet4ARollUpValue = mapUserTotalSale4A.get(cm.Related_to_Quota__r.user__c+'###'+cm.Name);
                        }               
                    }
                    if(cm.Signing_AE__c != currentQuota.user__c){
                        quotaPercentage3 = ((mapUserTotalSale.get(cm.Related_to_Quota__r.user__c+'###'+cm.Name))/cm.Related_to_Quota__r.Target_Amount__c)*100;
                        Componet3RollUpValue = mapUserTotalSale3.get(cm.Related_to_Quota__r.user__c+'###'+cm.Name);
                    }
                }
                system.debug('commission Name >>: '+cm.Name);
                system.debug('Componet1RollUpValue >>: '+Componet1RollUpValue);                 
                system.debug('quotaPercentage >>: '+quotaPercentage);
                system.debug('Componet4ARollUpValue >>: '+Componet4ARollUpValue);
                system.debug('Componet3RollUpValue >>: '+Componet3RollUpValue);
                system.debug('quotaPercentage3 >>: '+quotaPercentage3);
   
                //NEW HIRE TEAM         
                if((currentQuota.user_Team__c == Commissions_Constants.NEW_HIRE_TEAM)){
                    if(currentQuota.user__r.CreatedDate.month() == cm.CreatedDate.month()){
                        if(currentQuota.user__r.Payout_Rate_Month_1__c != Null){
                            cm.Payout_Rate__c = (currentQuota.user__r.Payout_Rate_Month_1__c).setScale(2);
                            if((product.Commission_Category__c == 'CFCB')|| (product.Commission_Category__c == 'TL')){                               
                                cm.Quota_Percentage_Achieved1__c = 0;    
                            }
                        }
                    }    //TIGER_Commission4A__c                
                    if(currentQuota.user__r.CreatedDate.addmonths(1).month() == cm.CreatedDate.month()){
                        if(currentQuota.user__r.Payout_Rate_Month_2__c != Null){
                            cm.Payout_Rate__c = (currentQuota.user__r.Payout_Rate_Month_2__c).setScale(2);
                            cm.New_Sale_w_o_Qualifier_Commission__c = (cm.Payout_Rate__c * cm.Commissionable_Amount2__c);
                            cm.Quota_Percentage_Achieved1__c = 0;    
                        }
                    }                                 
                    if(currentQuota.user__r.CreatedDate.addmonths(2).month() == cm.CreatedDate.month()){
                        if(currentQuota.user__r.Payout_Rate_Month_3__c != Null){
                            cm.Payout_Rate__c = (currentQuota.user__r.Payout_Rate_Month_3__c).setScale(2);
                            cm.New_Sale_w_o_Qualifier_Commission__c = (cm.Payout_Rate__c * cm.Commissionable_Amount2__c);
                            cm.Quota_Percentage_Achieved1__c = 0;                               
                        }
                    }
                    commissionsMap.put(cm.id,cm);
                }                                
                           
                String QuotaTeam = '';
                if(currentQuota.User_Team__c == Commissions_Constants.MANAGERS_TEAM){
                    QuotaTeam = currentQuota.User_Team__c;
                }else{
                    QuotaTeam = currentQuota.User_Team__c;
                }
                system.debug('Payout >> : '+payout.size());
                for(Payout__c pay : Payout.Values()){
                    system.debug('Payout >> 1: '+payout.size());
                    if((QuotaTeam  == Pay.RecordType.Name) && currentQuota.User_Team__c != Commissions_Constants.COLLECTION_TEAM && currentQuota.User_Team__c !=Commissions_Constants.COLLECTIONS_CLIENT_RELATIONS_MANAGERS ){
                        system.debug('Payout >> 2: '+payout.size());
                        if((currentQuota.User_Team__c != Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM)){
                            system.debug('Payout >> 3: '+payout.size());
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
                            system.debug('CommissinableAmountComp1 >> : '+CommissinableAmountComp1);                            
                            if((CommissinableAmountComp1 != 0.0 ) && (CommissinableAmountComp1 >= LowValueComp1)){
                                if(CommissinableAmountComp1 <= HighValueComp1) {
                                    if(pay.Name == Commissions_Constants.NEW_SALE_WITHOUT_QUALIFIER){ //'New Sale without Qualifier')
                                        cm.Payout_Rate__c = (pay.Commissionable__c).setScale(2);
                                        cm.New_Sale_w_o_Qualifier_Commission__c = (cm.Payout_Rate__c * cm.Commissionable_Amount2__c);
                                        cm.Quota_Percentage_Achieved1__c = quotaPercentage;
                                        system.debug('cmmmmm >> 1: '+cm.Name);
                                    }
                                }
                                commissionsMap.put(cm.id,cm);
                            }
                            //Calculating component 4A for all team
                            system.debug('Componet4ARollUpValue >> 1: '+Componet4ARollUpValue); 
                            if((product.Commission_Category__c == 'Tiger')){
                                system.debug('Componet4ARollUpValue >> 2: '+Componet4ARollUpValue); 
                                if(pay.Name == Commissions_Constants.TIGER_LEAD_SALE){ //'Tiger Lead Sale')
                                    system.debug('Componet4ARollUpValue >> 3: '+Componet4ARollUpValue); 
                                    if((Componet4ARollUpValue != 0.0) && (Componet4ARollUpValue >= pay.Low_Amount__c)){
                                        system.debug('Componet4ARollUpValue >> 4: '+Componet4ARollUpValue); 
                                        if(Componet4ARollUpValue <= pay.High_Amount__c) {
                                            system.debug('Componet4ARollUpValue >> 5: '+Componet4ARollUpValue); 
                                            cm.TIGER_Payout_Rate4A__c  = pay.Commissionable__c;
                                            cm.TIGER_Commission4A__c = (cm.TIGER_Commissionable_Amount4A__c * cm.TIGER_Payout_Rate4A__c )/100;                                                    
                                            commissionsMap.put(cm.id,cm);                                            
                                        }                                       
                                    }
                                }                               
                            }                  
                            Decimal LowValueComp3; Decimal HighValueComp3; Decimal CommissinableAmountComp3;
                            if(pay.Low_Level__c == Null && pay.High_Level__c == Null){
                                LowValueComp3 = pay.Low_Amount__c;
                                HighValueComp3 = pay.High_Amount__c;
                                CommissinableAmountComp3 = Componet3RollUpValue;                                
                            }
                            if(pay.Low_Amount__c == Null && pay.High_Amount__c == Null){
                                LowValueComp3 = pay.Low_Level__c;
                                HighValueComp3 = pay.High_Level__c;
                                CommissinableAmountComp3 = quotaPercentage3;
                            }
                            system.debug('CommissinableAmountComp3 ?? :'+CommissinableAmountComp3);
                            if((CommissinableAmountComp3 !=0.0) && (CommissinableAmountComp3 >= LowValueComp3)){
                                if(CommissinableAmountComp3 <= HighValueComp3) {
                                    if(pay.Name == Commissions_Constants.ASSET_OWNER_COMPONENTS ){ //'Asset Owner Component')
                                        cm.Payout_Rate_3__c= Pay.Commissionable__c.setScale(2);
                                        cm.Asset_Owner_Commission__c =(cm.Commissionable_Amount3__c * cm.Payout_Rate_3__c);
                                        cm.Quota_Percentage_Achieved1__c = quotaPercentage3;
                                        system.debug('cmmmmm >> 3: '+cm.Name);
                                    }
                                }
                            }
                            system.debug('cm Quota >> 1: '+cm.Name);
                            system.debug('cm Quota >> 2: '+cm.Quota_Percentage_Achieved1__c);
                            commissionsMap.put(cm.id,cm);
                        }
                    }
                }
                    
                //LINEAR CURVE EQUATION FOR REGIONAL DIRECTORS TEAM AND EVENTS TEAM
                Decimal x= 0;Decimal x1= 0;Decimal x2= 0;Decimal y= 0;Decimal y1= 0;Decimal y2= 0;   
                           
                if(currentQuota.User_Team__c == Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM){  
                    Decimal lowAmountRD; Decimal highAmountRD;
                    Decimal lowValueRD ; Decimal highValueRD ; Decimal CommissinableAmountCompRD;
                    for(Payout__c p : pay1.Values()){
                        if(p.Name == Commissions_Constants.NEW_SALE_WITHOUT_QUALIFIER ){ //'New Sale without Qualifier')
                            if(p.Low_Level__c == Null && p.High_Level__c == Null){
                                lowValueRD = p.Low_Amount__c;
                                CommissinableAmountCompRD = Componet1RollUpValue;                               
                            }
                            if(p.Low_Amount__c == Null && p.High_Amount__c == Null){
                                lowValueRD = p.Low_Level__c;
                                CommissinableAmountCompRD = quotaPercentage;
                            }
                            if(lowValueRD <= CommissinableAmountCompRD){                                                                            
                                x1 = p.High_Level__c;                         
                                y1 = p.Commissionable__c;
                                break;                               
                            }
                        }                           
                    }                        
                    for(Payout__c p : pay1.Values()){
                        if(p.Name == Commissions_Constants.NEW_SALE_WITHOUT_QUALIFIER ){ //'New Sale without Qualifier')
                            if(p.Low_Level__c == Null && p.High_Level__c == Null){
                                highValueRD = p.High_Amount__c;
                                CommissinableAmountCompRD = Componet1RollUpValue;                               
                            }
                            if(p.Low_Amount__c == Null && p.High_Amount__c == Null){
                                highValueRD = p.High_Level__c;
                                CommissinableAmountCompRD = quotaPercentage;
                            }
                            if(highValueRD >= CommissinableAmountCompRD){                                
                                x2 = p.Low_Level__c;  
                                y2 = p.Commissionable__c; 
                            }
                        }                            
                    }                        
                    x = quotaPercentage;
                    system.debug('x  >> : '+x);
                    system.debug('x1 >> : '+x1);
                    system.debug('x2 >> : '+x2);
                    system.debug('y1 >> : '+y1);
                    system.debug('y2 >> : '+y2);
                    system.debug('YYYYYYYYYYYYYYY : '+y);
                    try{
                        y = ((y2-y1)/(x2-x1)*(x-x1))+y1;
                    }
                    catch(Exception e){} 
                    if((currentQuota.User_Team__c == Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM)){
                        cm.Quota_Percentage_Achieved1__c = quotaPercentage;
                        if(currentQuota.RD_Team_Qualifier__c == false){
                            cm.Payout_Rate__c = Y.setScale(2);
                            cm.New_Sale_w_o_Qualifier_Commission__c = (cm.Payout_Rate__c * cm.Commissionable_Amount2__c);
                        }
                        if(currentQuota.RD_Team_Qualifier__c == true){
                            cm.Payout_Rate1B__c = Y.setScale(2);
                            cm.New_Sale_w_Qualifier_Commission__c = (cm.Payout_Rate1B__c * cm.Commissionable_Amount1B__c);
                        }
                    }
                   
                        
                    //COMPONENT 3 CALCULATION FOR REGIINAL DIRECTORS TEAM AND EVENTS TEAM
                    Decimal xRD  = 0;Decimal x1RD = 0;Decimal x2RD = 0;
                    Decimal yRD  = 0;Decimal y1RD = 0;Decimal y2RD = 0;  
                    Decimal lowAmountRD3; Decimal highAmountRD3;
                    Decimal lowValueRD3 ; Decimal highValueRD3 ;   
                    Decimal CommissinableAmountCompRD3;
                    for(Payout__c p : pay1.Values()){
                        if(p.Name == Commissions_Constants.ASSET_OWNER_COMPONENTS){
                            if(p.Low_Level__c == Null && p.High_Level__c == Null){
                                lowValueRD3 = p.Low_Amount__c;
                                CommissinableAmountCompRD3 = Componet3RollUpValue;                              
                            }
                            if(p.Low_Amount__c == Null && p.High_Amount__c == Null){
                                lowValueRD3 = p.Low_Level__c;
                                CommissinableAmountCompRD3 = Componet3RollUpValue;
                            }
                            if(lowValueRD <= CommissinableAmountCompRD3){                                                                            
                                x1RD = p.High_Level__c;                         
                                y1RD = p.Commissionable__c;
                                break;                               
                            }
                        }                           
                    } 
                    for(Payout__c p : pay1.Values()){
                        if(p.Name == Commissions_Constants.ASSET_OWNER_COMPONENTS){
                            if(p.Low_Level__c == Null && p.High_Level__c == Null){
                                highValueRD3 = p.High_Amount__c;
                                CommissinableAmountCompRD3 = Componet3RollUpValue;                              
                            }
                            if(p.Low_Amount__c == Null && p.High_Amount__c == Null){
                                highValueRD3 = p.High_Level__c;
                                CommissinableAmountCompRD3 = Componet3RollUpValue;
                            }
                            if(CommissinableAmountCompRD3 > 0){
                                if(highValueRD3 >= CommissinableAmountCompRD3){                                
                                    x2RD = p.Low_Level__c;  
                                    y2RD = p.Commissionable__c; 
                                }
                            }
                        }                            
                    }
                    xRD = quotaPercentage;
                    system.debug('xRD  >> : '+xRD);
                    system.debug('x1RD >> : '+x1RD);
                    system.debug('x2RD >> : '+x2RD);
                    system.debug('y1RD >> : '+y1RD);
                    system.debug('y2RD >> : '+y2RD);
                    try{
                        yRD = ((y2RD-y1RD)/(x2RD-x1RD)*(xRD-x1RD))+y1RD;
                    }
                    catch(Exception e){}
                    system.debug('YYYYYYYYYYYYYYY_RD : '+yRD);
                    if(cm.Commissionable_Amount3__c != 0.0){
                        cm.Payout_Rate_3__c= YRD.setScale(2);
                        cm.Asset_Owner_Commission__c =(cm.Commissionable_Amount3__c * cm.Payout_Rate_3__c);
                    }
                    commissionsMap.put(cm.id,cm);   
                } 
                
                //**************MANAGERs TEAM ***************************
                Decimal xMgr1 = 0; Decimal x1Mgr1 = 0; Decimal x2Mgr1 = 0;
                Decimal yMgr1  = 0; Decimal y1Mgr1 = 0; Decimal y2Mgr1 = 0;   
                Decimal lowAmountMgr1; Decimal highAmountMgr1;
                Decimal lowValueMgr1 ; Decimal highValueMgr1 ;    
                Decimal CommissinableAmountCompMgr1;
                if(cm.User_Team__c == Commissions_Constants.MANAGERS_TEAM){
                    system.debug('cm Manager : '+cm.Name);
                    for(Payout__c p : Payout.Values()){
                        if(p.RecordType.Name == cm.commission_To__c){
                            if(p.Name == Commissions_Constants.NEW_SALE_WITHOUT_QUALIFIER){ //'New Sale without Qualifier')
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
                            if(p.Name == Commissions_Constants.NEW_SALE_WITHOUT_QUALIFIER){ //'New Sale without Qualifier')
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
                        cm.Quota_Percentage_Achieved1__c = quotaPercentage+quotaPercentage3;  
                        cm.New_Sale_w_o_Qualifier_Commission__c = (cm.Payout_Rate__c * cm.Commissionable_Amount2__c);                       
                        commissionsMap.put(cm.id,cm);
                    }
                    if(xMgr1 >= 65.01 ){
                        cm.Payout_Rate__c = YMgr1.setScale(2);
                        cm.Quota_Percentage_Achieved1__c = quotaPercentage+quotaPercentage3;                  
                         cm.New_Sale_w_o_Qualifier_Commission__c = (cm.Payout_Rate__c * cm.Commissionable_Amount2__c);
                        commissionsMap.put(cm.id,cm);
                    }
                }
            }
            if((cm.User_team__c == Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM || cm.User_team__c == Commissions_Constants.COLLECTION_TEAM || cm.User_team__c == Commissions_Constants.COLLECTIONS_CLIENT_RELATIONS_MANAGERS) 
                && (cm.OpenBook_New_Sale_Comm_ble_Amount__c != 0.0 && cm.OpenBook_New_Sale_Comm_ble_Amount__c !=Null)){
                system.debug('Collection New Sale 1 : ');
                Decimal LowValueComp4; Decimal HighValueComp4; Decimal CommissinableAmountComp4;
                if(cm.User_team__c == Commissions_Constants.COLLECTION_TEAM || cm.User_team__c == Commissions_Constants.COLLECTIONS_CLIENT_RELATIONS_MANAGERS ){
                    //quotaPercentage4 = currentQuota.Collection_Quota_Percentage__c;
                    quotaPercentage4 = ((currentQuota.Collection_Total_Sale__c)/(currentQuota.Collection_Target_Amount__c))*100;
                    TeamName = Commissions_Constants.NEW_SALE_WITH_QUALIFIER;
                }else{
                    quotaPercentage4 = ((currentQuota.Total_Sale__c + cm.OpenBook_New_Sale_Comm_ble_Amount__c)/(currentQuota.Target_Amount__c))*100;
                    TeamName = Commissions_Constants.OPEN_SALE_COMPONENT;
                }
                system.debug('Collection New Sale 2 : '+quotaPercentage4);
                system.debug('Collection New Sale 3 : '+TeamName);
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
                        system.debug('quotaPercentage4 : '+quotaPercentage4);
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
                                    system.debug('quotaPercentage4 : '+quotaPercentage4);
                                }
                            }
                        }
                    }
                }
            }
        }      
        
        if(commissionsMap.size() > 0){
            update commissionsMap.Values();
        }
        
        Map<Id,Commission__c>  AllCommissions = new Map<ID, Commission__c>([select id,Signing_AE__c,Name,Related_Commission__c,CreatedDate,product__r.Commission_Category__C,Related_to_Quota__c,
                                                        Quota_Percentage_Achieved1__c,TIGER_Payout_Rate4A__c,Related_to_Quota__r.Quota_Percentage__c,Related_to_Quota__r.Target_Amount__c,Payout_rate__c,Payout_Rate1B__c,Total_Commissionable_Amount__c,
                                                        Payout_rate_3__c,RecordType.Name,User_Team__c,Commissionable_Amount2__c,Commissionable_Amount1B__c,OpenBook_New_Sale_Payout__c,
                                                        TIGER_Commissionable_Amount4A__c,Commissionable_Amount3__c,OpenBook_New_Sale_Comm_ble_Amount__c,
                                                        New_Sale_w_o_Qualifier_Commission__c,New_Sale_w_Qualifier_Commission__c,CFCB_NEW_w_Qualifier_Commission2A__c,
                                                        CFCB_New_w_o_Qualifier_Commission2B__c,CFCB_RNW_w_Qualifier_Commission2C__c,CFCB_RNW_w_o_Qualifier_Commission2D__c,
                                                        Asset_Owner_Commission__c,TIGER_Commission4A__c,OpenBook_New_Sale_Commission__c from Commission__c where Related_to_Quota__c IN : QuotaIds]);
                                                        
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
                        if((currentQuotaUpdate.user_Team__c != Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM)){
                            if(currentMonth == recordCreatedMonth){ 
                                if(cm1.Quota_Percentage_Achieved1__c != 0.0 && cm1.Quota_Percentage_Achieved1__c != null){
                                    allCommissionsupdate.Quota_Percentage_Achieved1__c = cm1.Quota_Percentage_Achieved1__c;
                                    mapCommissions.put(allCommissionsupdate.id,allCommissionsupdate);
                                }
                                if(cm1.Quota_Percentage_Achieved1__c == 0.0 || cm1.Quota_Percentage_Achieved1__c == Null){                                        
                                    cm1.Quota_Percentage_Achieved1__c = allCommissionsupdate.Related_to_Quota__r.Quota_Percentage__c;
                                    mapCommissions.put(cm1.id,cm1);
                                }
                                if(cm1.Payout_rate__c != Null){
                                    if(allCommissionsupdate.Commissionable_Amount2__c != 0.0){
                                        allCommissionsupdate.Payout_rate__c = (cm1.Payout_rate__c).setScale(2);
                                        allCommissionsupdate.New_Sale_w_o_Qualifier_Commission__c = (allCommissionsupdate.Payout_Rate__c * allCommissionsupdate.Commissionable_Amount2__c)/100;
                                        mapCommissions.put(allCommissionsupdate.id,allCommissionsupdate);
                                    }
                                }
                                if(cm1.Payout_Rate1B__c != Null){
                                    if(allCommissionsupdate.Commissionable_Amount1B__c != 0.0){
                                        allCommissionsupdate.Payout_Rate1B__c = (cm1.Payout_Rate1B__c).setScale(2);
                                        allCommissionsupdate.New_Sale_w_Qualifier_Commission__c = (allCommissionsupdate.Payout_Rate1B__c * allCommissionsupdate.Commissionable_Amount1B__c)/100;
                                       
                                        mapCommissions.put(allCommissionsupdate.id,allCommissionsupdate);
                                    }
                                }                                
                                if(Product1.Commission_Category__c == 'Tiger' && cm1.TIGER_Payout_Rate4A__c  != Null){  
                                    if(allCommissionsupdate.TIGER_Commissionable_Amount4A__c != 0.0){
                                        allCommissionsupdate.TIGER_Payout_Rate4A__c = (cm1.TIGER_Payout_Rate4A__c ).setScale(2);
                                        allCommissionsupdate.TIGER_Commission4A__c = (allCommissionsupdate.TIGER_Commissionable_Amount4A__c * allCommissionsupdate.TIGER_Payout_Rate4A__c )/100; 
                                        mapCommissions.put(allCommissionsupdate.id,allCommissionsupdate);
                                    }                                   
                                }
                                if(cm1.Payout_Rate_3__c != Null && cm1.Payout_Rate_3__c != 0.0 ){
                                    if(allCommissionsupdate.Commissionable_Amount3__c != 0.0){
                                        allCommissionsupdate.Payout_Rate_3__c = (cm1.Payout_Rate_3__c).setScale(2);
                                        allCommissionsupdate.Asset_Owner_Commission__c = (allCommissionsupdate.Commissionable_Amount3__c * allCommissionsupdate.Payout_Rate_3__c)/100;                                        
                                        mapCommissions.put(allCommissionsupdate.id,allCommissionsupdate);
                                    }                                    
                                }                               
                                if(cm1.OpenBook_New_Sale_Comm_ble_Amount__c != Null && cm1.OpenBook_New_Sale_Comm_ble_Amount__c != 0.0 ){
                                    if(cm1.Payout_rate__c != Null && cm1.Payout_rate__c != 0.0){
                                        if(cm1.id != allCommissionsupdate.id){
                                            cm1.OpenBook_New_Sale_Payout__c = (allCommissionsupdate.Payout_rate__c).setScale(2);
                                            cm1.New_Sale_w_o_Qualifier_Commission__c = (cm1.OpenBook_New_Sale_Payout__c * cm1.OpenBook_New_Sale_Comm_ble_Amount__c)/100;
                                            mapCommissions.put(cm1.id,cm1);
                                        } 
                                    }
                                    if(cm1.Payout_Rate1B__c != Null && cm1.Payout_Rate1B__c != 0.0){
                                        if(cm1.id != allCommissionsupdate.id){
                                            cm1.OpenBook_New_Sale_Payout__c = (allCommissionsupdate.Payout_Rate1B__c).setScale(2);
                                            cm1.New_Sale_w_o_Qualifier_Commission__c = (cm1.OpenBook_New_Sale_Payout__c * cm1.OpenBook_New_Sale_Comm_ble_Amount__c)/100;
                                            mapCommissions.put(cm1.id,cm1);
                                        } 
                                    }                                   
                                }     
                            }          
                        }                      
                        
                                        
                        if(currentQuotaUpdate.user_Team__c == Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM){                            
                            if(cm1.Quota_Percentage_Achieved1__c != 0.0 && cm1.Quota_Percentage_Achieved1__c != null){
                                allCommissionsupdate.Quota_Percentage_Achieved1__c = cm1.Quota_Percentage_Achieved1__c;
                                mapCommissions.put(allCommissionsupdate.id,allCommissionsupdate);
                            }
                            if(cm1.Quota_Percentage_Achieved1__c == 0.0 || cm1.Quota_Percentage_Achieved1__c == Null){                                        
                                cm1.Quota_Percentage_Achieved1__c = allCommissionsupdate.Related_to_Quota__r.Quota_Percentage__c;
                                mapCommissions.put(cm1.id,cm1);
                            }
                            if(cm1.Payout_Rate__c != Null){                                
                                if(allCommissionsupdate.Commissionable_Amount2__c != 0.0){                                    
                                    allCommissionsupdate.Payout_rate__c = (cm1.Payout_rate__c).setScale(2);
                                    allCommissionsupdate.New_Sale_w_o_Qualifier_Commission__c = (allCommissionsupdate.Payout_Rate__c * allCommissionsupdate.Commissionable_Amount2__c)/100;                                
                                    mapCommissions.put(allCommissionsupdate.id,allCommissionsupdate);
                                }                                                           
                            }
                            if(cm1.Payout_Rate1B__c != Null){                                
                                if(allCommissionsupdate.Commissionable_Amount1B__c != 0.0){                             
                                    allCommissionsupdate.Payout_Rate1B__c = (cm1.Payout_Rate1B__c).setScale(2);
                                    allCommissionsupdate.New_Sale_w_Qualifier_Commission__c = (allCommissionsupdate.Payout_Rate1B__c * allCommissionsupdate.Commissionable_Amount1B__c)/100;
                                    mapCommissions.put(allCommissionsupdate.id,allCommissionsupdate);
                                }
                            }  
                            if(Product1.Commission_Category__c == 'Tiger' && cm1.TIGER_Payout_Rate4A__c  != Null){  
                                if(allCommissionsupdate.TIGER_Commissionable_Amount4A__c != 0.0){
                                    allCommissionsupdate.TIGER_Payout_Rate4A__c  = (cm1.TIGER_Payout_Rate4A__c ).setScale(2);
                                    allCommissionsupdate.TIGER_Commission4A__c = (allCommissionsupdate.TIGER_Commissionable_Amount4A__c * allCommissionsupdate.TIGER_Payout_Rate4A__c )/100;                                        
                                    mapCommissions.put(allCommissionsupdate.id,allCommissionsupdate);
                                }                               
                            }
                            if(cm1.Payout_Rate_3__c != Null && cm1.Payout_Rate_3__c != 0.0 ){
                                if(allCommissionsupdate.Commissionable_Amount3__c != 0.0){
                                    allCommissionsupdate.Payout_Rate_3__c = (cm1.Payout_Rate_3__c).setScale(2);
                                    allCommissionsupdate.Asset_Owner_Commission__c = (allCommissionsupdate.Commissionable_Amount3__c * allCommissionsupdate.Payout_Rate_3__c)/100;                                        
                                    mapCommissions.put(allCommissionsupdate.id,allCommissionsupdate);
                                }
                            }
                            if(cm1.OpenBook_New_Sale_Comm_ble_Amount__c != Null && cm1.OpenBook_New_Sale_Comm_ble_Amount__c != 0.0 ){
                                if(cm1.Payout_rate__c != Null && cm1.Payout_rate__c != 0.0){
                                    if(cm1.id != allCommissionsupdate.id){
                                        cm1.OpenBook_New_Sale_Payout__c = (allCommissionsupdate.Payout_rate__c).setScale(2);
                                        cm1.New_Sale_w_o_Qualifier_Commission__c = (cm1.OpenBook_New_Sale_Payout__c * cm1.OpenBook_New_Sale_Comm_ble_Amount__c)/100;
                                        mapCommissions.put(cm1.id,cm1);
                                    } 
                                }
                                if(cm1.Payout_Rate1B__c != Null && cm1.Payout_Rate1B__c != 0.0){
                                    if(cm1.id != allCommissionsupdate.id){
                                        cm1.OpenBook_New_Sale_Payout__c = (allCommissionsupdate.Payout_Rate1B__c).setScale(2);
                                        cm1.New_Sale_w_o_Qualifier_Commission__c = (cm1.OpenBook_New_Sale_Payout__c * cm1.OpenBook_New_Sale_Comm_ble_Amount__c)/100;
                                        mapCommissions.put(cm1.id,cm1);
                                    } 
                                }                                   
                            }                                                   
                        }                           
                    }                   
                }                
                if(cm1.RecordType.Name == Commissions_Constants.COMMISSIONS_CLAWBACK){                    
                    if((cm1.Related_Commission__c == allCommissionsupdate.id) && (allCommissionsupdate.id!= Null)){                  
                        if(allCommissionsupdate.Quota_Percentage_Achieved1__c != 0.0 || allCommissionsupdate.Quota_Percentage_Achieved1__c != Null){                                        
                            cm1.Quota_Percentage_Achieved1__c = allCommissionsupdate.Quota_Percentage_Achieved1__c;
                            mapCommissions.put(cm1.id,cm1);
                        }
                        if(allCommissionsupdate.Payout_Rate1B__c != Null || allCommissionsupdate.Payout_Rate__c != Null){                     
                            if(allCommissionsupdate.Payout_Rate__c != Null){
                                cm1.Payout_Rate__c = (allCommissionsupdate.Payout_rate__c).setScale(2);                           
                                cm1.New_Sale_w_o_Qualifier_Commission__c = (cm1.Payout_Rate__c * cm1.Commissionable_Amount2__c)/100;                            
                                mapCommissions.put(cm1.id,cm1);
                            }
                            if(allCommissionsupdate.Payout_Rate1B__c != Null){
                                cm1.Payout_Rate1B__c = (allCommissionsupdate.Payout_Rate1B__c).setScale(2);
                                cm1.New_Sale_w_Qualifier_Commission__c = (cm1.Payout_Rate1B__c * cm1.Commissionable_Amount1B__c)/100;
                                mapCommissions.put(cm1.id,cm1);
                            }                               
                        }
                        if(Product1.Commission_Category__c == 'Tiger' && allCommissionsupdate.TIGER_Payout_Rate4A__c  != Null){  
                            cm1.TIGER_Payout_Rate4A__c  = (allCommissionsupdate.TIGER_Payout_Rate4A__c).setScale(2);                               
                            cm1.TIGER_Commission4A__c = (cm1.TIGER_Commissionable_Amount4A__c * cm1.TIGER_Payout_Rate4A__c )/100;                                   
                                    
                            mapCommissions.put(cm1.id,cm1);                             
                        }                        
                    }
                    if(cm1.Related_Commission__c == Null){                       
                        if(cm1.Related_to_Quota__c == allCommissionsupdate.Related_to_Quota__c){                                
                            if(allCommissionsupdate.Quota_Percentage_Achieved1__c != 0.0 || allCommissionsupdate.Quota_Percentage_Achieved1__c != Null){                                        
                                cm1.Quota_Percentage_Achieved1__c = allCommissionsupdate.Quota_Percentage_Achieved1__c;                             
                                mapCommissions.put(cm1.id,cm1);
                                break;
                            }
                            if(allCommissionsupdate.Payout_Rate1B__c != Null || allCommissionsupdate.Payout_Rate__c != Null){
                                if(allCommissionsupdate.Payout_Rate__c != Null){
                                    cm1.Payout_rate__c = (allCommissionsupdate.Payout_Rate__c).setScale(2);                                 
                                    cm1.New_Sale_w_o_Qualifier_Commission__c = (cm1.Payout_Rate__c * cm1.Commissionable_Amount2__c)/100; 
                                    mapCommissions.put(cm1.id,cm1);                                 
                                }
                                if(allCommissionsupdate.Payout_Rate1B__c != Null){                                  
                                    cm1.Payout_Rate1B__c = (allCommissionsupdate.Payout_Rate1B__c).setScale(2);
                                     cm1.New_Sale_w_Qualifier_Commission__c = (cm1.Payout_Rate1B__c * cm1.Commissionable_Amount1B__c)/100;
                                    mapCommissions.put(cm1.id,cm1);                                 
                                }
                                break;
                            }
                            if(Product1.Commission_Category__c == 'Tiger' && allCommissionsupdate.TIGER_Payout_Rate4A__c  != Null){  
                                cm1.TIGER_Payout_Rate4A__c  = (allCommissionsupdate.TIGER_Payout_Rate4A__c).setScale(2);
                                cm1.TIGER_Commission4A__c = (cm1.TIGER_Commissionable_Amount4A__c * cm1.TIGER_Payout_Rate4A__c )/100;
                                mapCommissions.put(cm1.id,cm1);
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
        for(Quota__c q1 : currentMonthQuota.values()){
            Quota__c q2 = new Quota__c();
            q2.id = q1.id;
            updateQuota.add(q2);
        }
        if(updateQuota.size() > 0){
            update updateQuota;
        }
        **************************/        
    }
}