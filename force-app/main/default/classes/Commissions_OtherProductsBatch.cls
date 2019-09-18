global class Commissions_OtherProductsBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Getting Record Type Id -  Commission Object - Other Products
        Id devRecordTypeId = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Other Products').getRecordTypeId();  
        Datetime myDate = datetime.newInstanceGmt(datetime.now().year(), datetime.now().month(), datetime.now().day()-1, 13, 0,1);
        system.debug('myDate : '+myDate);
        return Database.getQueryLocator([select id,Name,RecordType.Name,Related_to_Quota__c,user_team__c,Commissionable_Amount2__c,Related_to_Quota__r.Target_Amount__c,Signing_AE__r.Name,
                                        Quota_Percentage_Achieved1__c,Total_Commissionable_Amount__c,Payout_Rate__c,OpenBook_New_Sale_Comm_ble_Amount__c,
                                        Collection_Commissionable_Amount__c,New_Sale_w_o_Qualifier_Commission__c,New_Sale_w_Qualifier_Commission__c,commissionable_Amount3__c,Asset_Owner_Commission__c,
                                        OpenBook_New_Sale_Commission__c from Commission__c where createddate >=: myDate and RecordTypeId =: devRecordTypeId 
                                        order by Name Asc]);
    }
   
    global void execute(Database.BatchableContext BC, List<Commission__c> scope) {
        system.debug('scope :'+scope.size());
        Set<Id> QuotaIds = new Set<Id>();        
        Set<Id> UserIds = new Set<Id>(); 
        Map<id,commission__c> commissionsMap = new Map<id,commission__c>();
        Map<String,Decimal> mapUserTotalSale = new Map<String,Decimal>();        
        Map<Id,List<commission__c>> mapUserCommissionList = new Map<Id,List<commission__c>>();        
        Map<String,Decimal> mapUserTotalSaleAO = new Map<String,Decimal>();     
        Decimal CommissionableAmount = 0.0;
        Decimal QuotaPer = 0.0;    
        
        Id RecordTypeIdPayroll = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Payroll Adjustment').getRecordTypeId();  
        Id RecordTypeIdClawBack = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Clawback').getRecordTypeId(); 
        
        for(Commission__c comm : scope){               
            QuotaIds.add(comm.Related_to_Quota__c);            
        }
        
        Date startOfMonth = Date.today().toStartOfMonth(); 
        Map<Id,Quota__c> currentMonthQuota = new Map<id,Quota__c>([select id,Name,User__c,User_Team__c,Period_Name__c,Target_Amount__c,Total_Sale__c,Total_Sale_2__c, 
                                                 Quota_Percentage__c from Quota__c where id IN : QuotaIds]);  
        system.debug('currentMonthQuota >> :'+currentMonthQuota);        
        Set<Id> QuotaUserIds = new set<Id>();
        for(Quota__c a : currentMonthQuota.Values()){
            QuotaUserIds.Add(a.User__c);
        }
            
        Map<ID, User> UserList = new Map<ID, User>([select id,Payout_Rate_Month_1__c, Payout_Rate_Month_2__c,Payout_Rate_Month_3__c,Name,Team__c,Managers__c from user where id In : QuotaUserIds]);
        
        Map<ID,Commission__c> Commissionlist = new Map<ID,Commission__c>([select id,Name,RecordType.Name,Related_Commission__c,Commissionable_Amount2__c,Related_to_Quota__r.Target_Amount__c,
                                                Related_to_Quota__c,Quota_Percentage_Achieved1__c,Payout_Rate__c,user_team__c,Total_Commissionable_Amount__c,Signing_AE__r.Name,
                                                OpenBook_New_Sale_Comm_ble_Amount__c,Collection_Commissionable_Amount__c,Commissionable_Amount1B__c,New_Sale_w_o_Qualifier_Commission__c,
                                                New_Sale_w_Qualifier_Commission__c,commissionable_Amount3__c,Asset_Owner_Commission__c,OpenBook_New_Sale_Commission__c
                                                from Commission__c 
                                                where RecordTypeId !=: RecordTypeIdPayroll and Related_to_Quota__c IN : QuotaIds order by Name Asc]); 
        Set<Id> PeriodIds = new Set<Id>();
        for(Quota__c quota : currentMonthQuota.Values()){
            PeriodIds.add(quota.Period_Name__c);
        }
        system.debug('PeriodIds >> : '+PeriodIds); 
        Map<Id,Payout__c> pay1 = new Map<ID, Payout__c>([select id, name, Low_level__c, High_Level__c, Low_Amount__c,High_Amount__c,Commissionable__c, RecordType.Name from Payout__c 
                                                        where Period__c In : PeriodIds and (RecordType.Name =: Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM) 
                                                        ORDER BY High_Level__c DESC ]);   
        Map<Id,Payout__C> Payout = new Map<ID, Payout__C>([select id ,name,RecordType.Name,High_Level__c,Period__c,Low_Level__c,Low_Amount__c, High_Amount__c,Commissionable__c from Payout__c 
                                                        where Period__c In : PeriodIds Order by Low_Level__c Desc]);   
        for(Commission__c cm : Scope){
            system.debug('Commission Name :'+cm.Name);
            QuotaPer = 0.0;
            Quota__c currentQuota = currentMonthQuota.get(cm.Related_to_Quota__c);            
            try{
                User user = UserList.get(currentQuota.User__c); 
                if(cm.Related_to_Quota__r.Target_Amount__c != null && currentQuota != Null && currentQuota.User__c != Null){                           
                    QuotaPer = ((currentQuota.Total_Sale__c)/(currentQuota.Target_Amount__c)*100);
                    system.debug('QuotaPer :'+QuotaPer);                        
                    if(cm.user_team__c != Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM){ // && (cm.user_team__c != 'Events Team')){
                        system.debug('Not RD ');
                        for(Payout__c pay : Payout.Values()){
                            system.debug('Not RD 1 '+user.Team__c);                                
                            if((user.Team__c == Pay.RecordType.Name) || (currentQuota.User_Team__c == Pay.RecordType.Name)){
                                system.debug('Not RD 5 '+currentQuota.Name);                                   
                                Decimal LowValue = 0.0;
                                Decimal HighValue = 0.0;
                                if(pay.Low_Level__c == Null && pay.High_Level__c == Null){
                                    LowValue =  pay.Low_Amount__c;
                                    HighValue =  pay.High_Amount__c ;
                                    system.debug('Test 1  :');
                                } 
                                if(pay.Low_Amount__c == Null && pay.High_Amount__c == Null){
                                    LowValue =  pay.Low_Amount__c;
                                    HighValue =  pay.High_Amount__c   ;
                                    system.debug('Test 2  :');
                                }                    
                                if((QuotaPer >= pay.Low_Level__c )){
                                    if(QuotaPer <= pay.High_Level__c ) {
                                        if(pay.Name == Commissions_Constants.NEW_SALE_WITHOUT_QUALIFIER){
                                            cm.Payout_Rate__c = (pay.Commissionable__c).setScale(2);                                        
                                            cm.Quota_Percentage_Achieved1__c = QuotaPer;
                                            cm.New_Sale_w_o_Qualifier_Commission__c = (cm.Payout_Rate__c * cm.Commissionable_Amount2__c);
                                            system.debug('Test 3  :');
                                        }
                                    }
                                    commissionsMap.put(cm.id,cm);
                                }
                            }
                        }
                    }
                    //NEW HIRE TEAM*****           
                    if(user.Team__c == Commissions_Constants.NEW_HIRE_TEAM){ //'New Hire Team'){        
                        cm.Quota_Percentage_Achieved1__c = 0;   
                        if(user.CreatedDate.month() == cm.CreatedDate.month()){
                            cm.Payout_Rate__c = (user.Payout_Rate_Month_1__c).setScale(2);
                            commissionsMap.put(cm.id,cm);
                        }                    
                        if(user.CreatedDate.addmonths(1).month() == cm.CreatedDate.month()){
                            cm.Payout_Rate__c = (user.Payout_Rate_Month_2__c).setScale(2);
                            cm.New_Sale_w_o_Qualifier_Commission__c = (cm.Payout_Rate__c * cm.Commissionable_Amount2__c);
                            commissionsMap.put(cm.id,cm);
                        }
                        if(user.CreatedDate.addmonths(2).month() == cm.CreatedDate.month()){
                            cm.Payout_Rate__c = (user.Payout_Rate_Month_3__c).setScale(2);
                            cm.New_Sale_w_o_Qualifier_Commission__c = (cm.Payout_Rate__c * cm.Commissionable_Amount2__c);
                            commissionsMap.put(cm.id,cm);
                        }
                       
                    }
                        
                    //LINEAR CURVE EQUATION FOR REGIONAL DIRECTORS TEAM AND EVENTS TEAM
                    Decimal x  = 0;   Decimal x1 = 0;   Decimal x2 = 0;
                    Decimal y  = 0;   Decimal y1 = 0;   Decimal y2 = 0;   
                         
                    if((cm.User_Team__c == Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM)){ // || (cm.User_Team__c == 'Events Team')){  
                        Decimal lowValueRD ; Decimal highValueRD ;    
                        for(Payout__c p : pay1.Values()){
                            if(cm.User_Team__c == p.Recordtype.Name){
                                //if(p.Name.contains('New Sale without Qualifier')){
                                if(p.Name == Commissions_Constants.NEW_SALE_WITHOUT_QUALIFIER){
                                    if(p.Low_Level__c == Null && p.High_Level__c == Null){
                                        lowValueRD = p.Low_Amount__c;
                                    }
                                    if(p.Low_Amount__c == Null && p.High_Amount__c == Null){
                                        lowValueRD = p.Low_Level__c;
                                    }
                                    if(lowValueRD <= QuotaPer){                                                                            
                                        x1 = p.High_Level__c;                         
                                        y1 = p.Commissionable__c;
                                        break;                               
                                    }
                                }
                            }                           
                        }                        
                        for(Payout__c p : pay1.Values()){
                            if(cm.User_Team__c == p.Recordtype.Name){
                                //if(p.Name.contains('New Sale without Qualifier')){
                                if(p.Name == Commissions_Constants.NEW_SALE_WITHOUT_QUALIFIER){
                                    if(p.Low_Level__c == Null && p.High_Level__c == Null){
                                        highValueRD = p.High_Amount__c;
                                    }
                                    if(p.Low_Amount__c == Null && p.High_Amount__c == Null){
                                        highValueRD = p.High_Level__c;
                                    }                                        
                                    if(highValueRD >= QuotaPer){                                
                                        x2 = p.Low_Level__c;  
                                        y2 = p.Commissionable__c; 
                                    }
                                }
                            }                            
                        }                        
                        x = QuotaPer;                             
                        try{
                            y = ((y2-y1)/(x2-x1)*(x-x1))+y1;
                        }                       
                        catch(Exception e){}
                        system.debug('RD Tean : '+cm.Name);
                        system.debug('x  >> : '+x);
                        system.debug('x1 >> : '+x1);
                        system.debug('x2 >> : '+x2);
                        system.debug('y1 >> : '+y1);
                        system.debug('y2 >> : '+y2);
                        system.debug('YYYYYYYYYYYYYYY : '+y);
                        
                        cm.Payout_Rate__c = Y.setScale(6);
                        cm.Quota_Percentage_Achieved1__c = QuotaPer;               
                        commissionsMap.put(cm.id,cm);
                        /*
                        if((currentQuota.User_Team__c == Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM)){
                            if(currentQuota.RD_Team_Qualifier__c == false){
                                cm.Payout_Rate__c = Y.setScale(6);
                                cm.New_Sale_w_o_Qualifier_Commission__c = (cm.Payout_Rate__c * cm.Commissionable_Amount2__c);
                            }
                            if(currentQuota.RD_Team_Qualifier__c == true){
                                cm.Payout_Rate1B__c = Y.setScale(6);
                                cm.New_Sale_w_o_Qualifier_Commission__c = (cm.Payout_Rate1B__c * cm.Commissionable_Amount2__c);
                            }                               
                        }
                        */                      
                        
                    }
                        
                    //**************MANAGERs TEAM ***************************
                    Decimal xMgr1 = 0; Decimal x1Mgr1 = 0; Decimal x2Mgr1 = 0;
                    Decimal yMgr1  = 0; Decimal y1Mgr1 = 0; Decimal y2Mgr1 = 0;   
                    Decimal lowValueMgr1 ; Decimal highValueMgr1 ;                    
                    if(cm.User_Team__c == Commissions_Constants.MANAGERS_TEAM){
                        for(Payout__c p : Payout.Values()){
                            if(p.RecordType.Name == cm.Signing_AE__r.Name){
                                //if(p.Name.contains('New Sale without Qualifier')){
                                if(p.Name == Commissions_Constants.NEW_SALE_WITHOUT_QUALIFIER){
                                    if(p.Low_Level__c == Null && p.High_Level__c == Null){
                                        lowValueMgr1 = p.Low_Amount__c;                                                                      
                                    }
                                    if(p.Low_Amount__c == Null && p.High_Amount__c == Null){
                                        lowValueMgr1 = p.Low_Level__c;                                       
                                    }                               
                                    if(lowValueMgr1 <= QuotaPer){ 
                                        x1Mgr1 = p.High_Level__c;                         
                                        y1Mgr1 = p.Commissionable__c;
                                        break;                               
                                    }
                                }
                            }
                        }                        
                        for(Payout__c p : Payout.Values()){
                            if(p.RecordType.Name == cm.Signing_AE__r.Name){
                                //if(p.Name.contains('New Sale without Qualifier')){
                                if(p.Name == Commissions_Constants.NEW_SALE_WITHOUT_QUALIFIER){
                                    if(p.Low_Level__c == Null && p.High_Level__c == Null){
                                        highValueMgr1 = p.High_Amount__c;                                                                    
                                    }
                                    if(p.Low_Amount__c == Null && p.High_Amount__c == Null){
                                        highValueMgr1 = p.High_Level__c;                                        
                                    }
                                    if(highValueMgr1 >= QuotaPer){                                
                                        x2Mgr1 = p.Low_Level__c;  
                                        y2Mgr1 = p.Commissionable__c;
                                    }
                                }
                            }                                   
                        }
                        xMgr1 = QuotaPer;                               
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
                            cm.Quota_Percentage_Achieved1__c = QuotaPer; 
                            cm.New_Sale_w_o_Qualifier_Commission__c = (cm.Payout_Rate__c * cm.Commissionable_Amount2__c);                           
                            commissionsMap.put(cm.id,cm);
                        }
                        if(xMgr1 >= 65.01 ){
                            cm.Payout_Rate__c = YMgr1.setScale(2);
                            cm.Quota_Percentage_Achieved1__c = QuotaPer;                  
                            cm.New_Sale_w_o_Qualifier_Commission__c = (cm.Payout_Rate__c * cm.Commissionable_Amount2__c);
                            commissionsMap.put(cm.id,cm);
                        }
                    }                       
                }
            }
            catch(Exception e){}
        }   
        
        system.debug('commissionsMap >>> :'+commissionsMap.size());
        if(commissionsMap.size() > 0) {
            system.debug('Enter 4 :');
            upsert commissionsMap.Values();
        }
        
        //UPDATE ALL RELATED QUOTA COMMISSIONS WITH NEW QUOTA VALUE AND PAYOUT VALUE  *********
        
        map<id,commission__c> allcommissions = new Map<id,commission__c>();
        for(commission__c comm : commissionsMap.Values()){
            for(commission__c comm1 : Commissionlist.Values()){
                if(comm.Related_to_Quota__c == comm1.Related_to_Quota__c){ 
                    if(comm1.RecordType.Name != Commissions_Constants.COMMISSIONS_CLAWBACK){
                        comm1.Quota_Percentage_Achieved1__c = comm.Quota_Percentage_Achieved1__c;
                        
                        if(comm1.Commissionable_Amount2__c != 0.0){
                            if(comm1.Payout_Rate__c != Null){
                                comm1.Payout_Rate__c = comm.Payout_Rate__c;
                                comm1.New_Sale_w_o_Qualifier_Commission__c = (comm1.Payout_Rate__c * comm1.Commissionable_Amount2__c)/100;
                                allcommissions.put(comm1.id,comm1);
                            }
                        }
                        if(comm1.Commissionable_Amount1B__c != 0.0){
                            if(comm1.Payout_Rate1B__c != Null){
                                comm1.Payout_Rate1B__c = comm.Payout_Rate__c;
                                comm1.New_Sale_w_Qualifier_Commission__c = (comm1.Payout_Rate1B__c * comm1.Commissionable_Amount1B__c)/100;
                                allcommissions.put(comm1.id,comm1);
                            }
                        }
                        if(comm1.OpenBook_New_Sale_Comm_ble_Amount__c != 0.0 && comm1.OpenBook_New_Sale_Comm_ble_Amount__c != null && comm.Payout_Rate__c!= null){
                            comm1.OpenBook_New_Sale_Payout__c = comm.Payout_Rate__c; 
                            
                          
                            comm1.OpenBook_New_Sale_Commission__c = (comm1.OpenBook_New_Sale_Payout__c * comm1.OpenBook_New_Sale_Comm_ble_Amount__c)/100;
                            allcommissions.put(comm1.id,comm1);
                        }
                        
                        if(comm1.Commissionable_Amount3__c !=0.0){
                            comm1.Payout_Rate_3__c = comm.Payout_Rate__c;
                            comm1.Asset_Owner_Commission__c = (comm1.Commissionable_Amount3__c * comm1.Payout_Rate_3__c)/100;                                        
                            allcommissions.put(comm1.id,comm1);
                        }
                        if(comm1.Collection_Commissionable_Amount__c != 0.0){
                            allcommissions.put(comm1.id,comm1);
                        }               
                        allcommissions.put(comm1.id,comm1);
                    }
                    if(comm1.RecordType.Name == Commissions_Constants.COMMISSIONS_CLAWBACK){    
                        if(comm1.Related_Commission__c == Null){
                            comm1.Quota_Percentage_Achieved1__c = comm.Quota_Percentage_Achieved1__c;
                            comm1.Payout_Rate__c = comm.Payout_Rate__c;                       
                            comm1.New_Sale_w_o_Qualifier_Commission__c = (comm1.Payout_Rate__c * comm1.Commissionable_Amount2__c);                              
                            allcommissions.put(comm1.id,comm1);
                        }
                    }               
                }
            }
        }        
        for(commission__c comm : Commissionlist.Values()){
            if(comm.RecordType.Name == Commissions_Constants.COMMISSIONS_CLAWBACK){
                if(comm.Related_Commission__c != Null){
                    commission__c commCB = allcommissions.get(comm.Related_Commission__c);
                    comm.Payout_rate__c = commCB.Payout_rate__c;
                    comm.Quota_Percentage_Achieved1__c = commCB.Quota_Percentage_Achieved1__c;
                    comm.New_Sale_w_o_Qualifier_Commission__c = (comm.Payout_Rate__c * comm.Commissionable_Amount2__c);                             
                    allcommissions.put(comm.id,comm);
                }               
            }
        }
        set<ID> Rids = new set<id>();
        for(commission__c comm : allcommissions.values()){
            Rids.add(comm.Id);
        }
        Map<ID,Commission__c> RelatedCommissions = new Map<ID,Commission__c>([select id,RecordType.Name,Related_Commission__c,Commissionable_Amount2__c,Related_to_Quota__r.Target_Amount__c,Related_to_Quota__c,Quota_Percentage_Achieved1__c,
                                                    name,Payout_Rate__c,user_team__c ,Total_Commissionable_Amount__c,Signing_AE__r.Name,Commissionable_Amount3__c,OpenBook_New_Sale_Comm_ble_Amount__c,Collection_Commissionable_Amount__c,
                                                    New_Sale_w_o_Qualifier_Commission__c,New_Sale_w_Qualifier_Commission__c,Asset_Owner_Commission__c,OpenBook_New_Sale_Commission__c
                                                    from Commission__c where 
                                                    RecordTypeId !=: RecordTypeIdPayroll and Related_Commission__c IN : Rids order by Name Asc]); 
               
        for(commission__c comm : RelatedCommissions.Values()){
            if(comm.RecordType.Name == Commissions_Constants.COMMISSIONS_CLAWBACK){
                if(comm.Related_Commission__c != Null){
                    commission__c commCB1 = allcommissions.get(comm.Related_Commission__c);
                    comm.Payout_rate__c = commCB1.Payout_rate__c;
                    comm.Quota_Percentage_Achieved1__c = commCB1.Quota_Percentage_Achieved1__c;
                    comm.New_Sale_w_o_Qualifier_Commission__c = (comm.Payout_Rate__c * comm.Commissionable_Amount2__c);
                    allcommissions.put(comm.id,comm);
                }               
            }
        }
        system.debug('allcommissions >>> :'+allcommissions.values());
        if(allcommissions.size() > 0) {
            system.debug('Enter Loop *** :');
            update allcommissions.Values();
        }
        List<Quota__c> updateQuota = new List<Quota__c>();
        for(Quota__c q1 : currentMonthQuota.Values()){
            Quota__c q2 = new Quota__c();
            q2.id = q1.id;
            updateQuota.add(q2);
        }
        update updateQuota;
    }   
    global void finish(Database.BatchableContext BC) {
    }
}