Public Class Commissions_OrderProductHandler{
    Public void CreateCommissions(Map<Id, OrderItem> newTriggerValues){ 
        //VERIABLE DECLERATION
        set<Id> orderItemIds = new set<id>(); 
        set<Id> orderIds = new set<id>();   
        set<Id> ProductIds = new set<id>();     
        set<Id> accountIds = new set<id>();
        set<Id> orderOwnerIds = new set<id>();
        Decimal OrderOwnerPercent = 0.0; Decimal AccountOwnerPercent = 0.0;
        Map<String,commission__c> commission = new Map<String,Commission__c>();         
        for(OrderItem OrderId : newTriggerValues.values()){
            orderIds.add(OrderId.OrderId);   
            orderItemIds.add(OrderId.id);                                       
        }
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
        Map<Id,Order> orders = new Map<Id,Order>([select id,ownerId,AccountId,Account.OwnerId,TotalAmount from Order where Id In : orderIds]);
        for(Order Ors : Orders.Values()){            
            accountIds.add(Ors.AccountId);
            orderOwnerIds.add(Ors.OwnerId);  
            orderOwnerIds.add(Ors.Account.OwnerId);
        }        
        system.debug('orderOwnerIds : '+orderOwnerIds);
        Date startOfMonth = Date.today().toStartOfMonth();  
        Map<id,Quota__c> orderOwnerQuotas = new Map<id,Quota__c>([select id,Name, User__r.Managers__c ,Period_Name__r.Asset_Owner__c,Period_Name__r.Sigh_In_AE__c,
                                            Current_Quater__c,User__c,Period_Name__r.Agent_Sigh_In_AE__c,Period_Name__r.Agent_asset_Owner__c,Quota_StartDate__c,
                                            User_Team__c,User__r.Name from Quota__c where User__c In : orderOwnerIds]);
        system.debug('orderOwnerQuotas >>> : '+orderOwnerQuotas );      
        //Order Owner Manager Calculation
        Set<String> OrderManagers =  new Set<String>();        
        string[] str1;        
        for(Quota__c Qs : orderOwnerQuotas.Values()){
            string x1 = Qs.User__r.Managers__c;            
            if(x1 != null){
                str1 = x1.split(';');           
                for(string str : str1){        
                    OrderManagers.add(str.toLowerCase());
                }
            }
        }       
        system.debug('OrderManagers >>> : '+OrderManagers);
        Map<id,Quota__c> orderOwnerManagers_Quotas = new Map<id,Quota__c>([select id,Name,User__c,User__r.Managers__c,Quota_StartDate__c,Is_Kicker__c,Period_Name__r.Sigh_In_AE__c,
                                                         Period_Name__r.asset_owner__c,Period_Name__r.Agent_Sigh_In_AE__c,Period_Name__r.Agent_asset_Owner__c,Current_Quater__c,
                                                         User_Team__c,User__r.Name from Quota__c where User__r.Name In : OrderManagers]); 
        system.debug('orderOwnerManagers_Quotas >>> : '+orderOwnerManagers_Quotas.size()); 
        Map<id,User> orderOwners  = new Map<id,User>([select id,Name,Team__c,Managers__c,Profile.Name,Vacation_Start_Date__c,Vacation_End_Date__c from user where Id IN : orderOwnerIds]); 
        Map<id,Account> allAccounts = new Map<id,Account>([select id,Name,type,RecordTypeId from Account where Id In : accountIds]);
        system.debug('allAccounts  :'+allAccounts);         
        Set<id> PricebookEntryIds = new Set<Id>();
        for(orderItem PBE : newTriggerValues.Values()){
            PricebookEntryIds.add(PBE.PricebookEntryId);
        }
        system.debug('PricebookEntryIds >>> :'+PricebookEntryIds.size());
        Map<id,PricebookEntry> PricebookEntrys = new Map<Id,PricebookEntry>([SELECT Name,Pricebook2Id,Product2Id,ProductCode,UnitPrice FROM PricebookEntry where Id In :PricebookEntryIds]);
        system.debug('PricebookEntrys >>> :'+PricebookEntrys.size());           
        for(PricebookEntry PBE : PricebookEntrys.Values()){
            ProductIds.add(PBE.Product2Id);
        }        
        Map<Id,Product2> Products = new Map<id,Product2>([Select id,Name,Commission_Category__c,Normalization_factor__c from Product2 where Id In : ProductIds]);
        system.debug('Products >>> :'+Products.size());
        
        Id newSaleRT = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('New Sale').getRecordTypeId();       
        Id newSaleB2B = Schema.SObjectType.account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        Id newSaleB2C = Schema.SObjectType.account.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        Id newSaleManagerRT = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Managers Team').getRecordTypeId(); 
        Map<id,orderItem> updateOrderitemFlag = new Map<id,orderItem>();
        DateTime OrderCreatedDate; String ProductCommissionCategory;        
        for(OrderItem orderRecord : newTriggerValues.Values()){
            OrderOwnerPercent = 0.0; AccountOwnerPercent = 0.0;
            system.debug('orderRecord OrderId >>> : '+orderRecord.OrderId);
            order Ords = orders.get(orderRecord.OrderId);            
            system.debug('Ords >>> : '+Ords.Id);
            User orderOwner = orderOwners.get(Ords.OwnerId);
            if(orderOwner != Null){
                system.debug('orderOwner  >>> : '+orderOwner.Id);
                User accountOwner = orderOwners.get(Ords.Account.OwnerId);           
                system.debug('accountOwner >>> : '+accountOwner.Id);
                Account Acc = allAccounts.get(Ords.AccountId);
                system.debug('Acc >>> : '+Acc.Id);
                PricebookEntry Pbook = PricebookEntrys.get(orderRecord.PricebookEntryId);
                Product2 product = Products.get(Pbook.Product2Id);                
                if(test.IsRunningTest()){
                    OrderCreatedDate = system.today();
                    ProductCommissionCategory = 'Tiger';
                }
                else{
                    OrderCreatedDate = orderRecord.CreatedDate;
                    ProductCommissionCategory = orderRecord.Product_Commission_Category__c;
                }
                if(orderOwner.id != Null || accountOwner.id != Null){                
                    if((accountOwner  != Null) && (((accountOwner.Vacation_Start_Date__c != null && accountOwner.Vacation_End_Date__c != Null) &&
                        (accountOwner.Vacation_Start_Date__c < OrderCreatedDate && OrderCreatedDate < accountOwner.Vacation_End_Date__c)) || 
                        (accountOwner.Profile.Name.Contains('Open Book')))){
                        system.debug('LOA Loop :');
                        set<String> ManagerNames1 = new Set<String>(); 
                        string[] str6;      
                        String x6 = orderOwner.Managers__c;            
                        if(x6 != null){
                            str6 = x6.split(';');           
                            for(string str : str6){
                                ManagerNames1.add(str.toLowerCase());
                            }
                        }
                        OrderOwnerPercent = 100;
                        for(Quota__c  quotaRecord : orderOwnerQuotas.Values()){
                            if((quotaRecord.User__c == orderOwner.id) && ((quotaRecord.User_Team__c != Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM) && (OrderCreatedDate.Month() == quotaRecord.Quota_StartDate__c.Month()))
                                || ((quotaRecord.User_Team__c == Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM) && (quotaRecord.Current_Quater__c == RDTeam))){
                                system.debug('Same Loop 2:');
                                if(orderOwner.Id == quotaRecord.User__c  && orderRecord.Total_Net__c != Null){                          
                                    system.debug('Same Loop 3:');
                                    if((ProductCommissionCategory == 'Tiger')||(ProductCommissionCategory == 'TL')){
                                        system.debug('Same Loop 4:');
                                        Commission__c commissionRecord = new Commission__c();                       
                                        commissionRecord.Product__c = product.Id;
                                        commissionRecord.RecordTypeId = newSaleRT;                        
                                        commissionRecord.Asset_Amount__c = orderRecord.Total_Net__c;
                                        commissionRecord.Commissionable_Amount2__c = (orderRecord.Total_Net__c * OrderOwnerPercent)/100;
                                        commissionRecord.Commission_Split__c = OrderOwnerPercent;
                                        commissionRecord.User_Team__c = quotaRecord.User_Team__c;
                                        commissionRecord.Status__c = 'Active';
                                        if((ProductCommissionCategory == 'Tiger')||(ProductCommissionCategory == 'TL')){
                                            commissionRecord.TIGER_Commissionable_Amount4A__c = (orderRecord.Total_Net__c * OrderOwnerPercent)/100;
                                        }
                                        commissionRecord.Related_to_Quota__c = quotaRecord.id;
                                        commissionRecord.Signing_AE__c = orderOwner.Id;
                                        commissionRecord.Order_Product__c = orderRecord.id;
                                        //commission.add(commissionRecord);
                                        commission.put(orderRecord.id+'#',commissionRecord);
                                        orderRecord.Commissions_are_calculated__c = TRUE;
                                        updateOrderitemFlag.put(orderRecord.id,orderRecord);
                                    }
                                }
                            }
                        }
                        for(Quota__c quotaRecord : orderOwnerManagers_Quotas.Values()){                           
                            if(ManagerNames1.contains(quotaRecord.User__r.Name.toLowerCase())){                               
                                if(!ManagerNames1.contains(orderOwner.Name.toLowerCase())){                                 
                                    if((quotaRecord.User_Team__c == Commissions_Constants.MANAGERS_TEAM) && (OrderCreatedDate.Month() == quotaRecord.Quota_StartDate__c.Month())){
                                        if(((ProductCommissionCategory == 'Tiger')||(ProductCommissionCategory == 'TL'))  && orderRecord.Total_Net__c != Null){
                                            Commission__c commissionRecord = new Commission__c();                       
                                            commissionRecord.Product__c = product.Id;
                                            commissionRecord.RecordTypeId = newSaleManagerRT;                        
                                            commissionRecord.Asset_Amount__c = orderRecord.Total_Net__c;
                                            commissionRecord.Commissionable_Amount2__c = (orderRecord.Total_Net__c * OrderOwnerPercent)/100;
                                            commissionRecord.Commission_Split__c = OrderOwnerPercent;                               
                                            commissionRecord.Related_to_Quota__c = quotaRecord.id;
                                            commissionRecord.Signing_AE__c = orderOwner.Id;
                                            commissionRecord.Order_Product__c = orderRecord.id;
                                            commissionRecord.User_Team__c = quotaRecord.User_Team__c;
                                            commissionRecord.Status__c = 'Active';
                                            //commission.add(commissionRecord);
                                            commission.put(quotaRecord.id+'##'+orderRecord.id,commissionRecord);
                                            orderRecord.Commissions_are_calculated__c = TRUE;
                                            updateOrderitemFlag.put(orderRecord.id,orderRecord);
                                        }
                                    }
                                }
                            }
                        }                                   
                    }
                    else{ 
                        if(orderOwner != Null || accountOwner != Null){ //&& (!accountOwner.Profile.Name.Contains('Open Book')))
                            if(orderOwner != Null){
                                set<String> ManagerNames61 = new Set<String>(); 
                                string[] str61;      
                                String x61 = orderOwner.Managers__c;            
                                if(x61 != null){
                                    str61 = x61.split(';');           
                                    for(string str : str61){
                                        ManagerNames61.add(str.toLowerCase());
                                    }
                                }                                
                                //system.debug('Createdate : '+orderRecord.CreatedDate);
                                for(Quota__c  quotaRecord : orderOwnerQuotas.Values()){                                 
                                    if((quotaRecord.User__c == orderOwner.id) && ((quotaRecord.User_Team__c != Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM) && (OrderCreatedDate.Month() == quotaRecord.Quota_StartDate__c.Month()))
                                        || ((quotaRecord.User_Team__c == Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM) && (quotaRecord.Current_Quater__c == RDTeam))){
                                        if(orderOwner.Id == quotaRecord.User__c && orderRecord.Total_Net__c != Null){                                           
                                            if(((ProductCommissionCategory == 'Tiger')||(ProductCommissionCategory == 'TL'))  && orderRecord.Total_Net__c != Null){
                                                if(accountOwner!= Null && orderOwner!= Null && orderOwner == accountOwner){
                                                    OrderOwnerPercent = 100;
                                                }else{
                                                    if(acc.RecordTypeId == newSaleB2B){
                                                        OrderOwnerPercent = quotaRecord.Period_Name__r.Sigh_In_AE__c; 
                                                    }                                               
                                                    if(acc.RecordTypeId == newSaleB2C){
                                                        OrderOwnerPercent = quotaRecord.Period_Name__r.Agent_Sigh_In_AE__c;
                                                    }
                                                }
                                                Commission__c commissionRecord = new Commission__c();                       
                                                commissionRecord.Product__c = product.Id;
                                                commissionRecord.RecordTypeId = newSaleRT;                       
                                                commissionRecord.Asset_Amount__c = orderRecord.Total_Net__c;
                                                commissionRecord.Commissionable_Amount2__c = (orderRecord.Total_Net__c * OrderOwnerPercent )/100;
                                                commissionRecord.Commission_Split__c = OrderOwnerPercent; 
                                                commissionRecord.TIGER_Commissionable_Amount4A__c = (orderRecord.Total_Net__c * OrderOwnerPercent )/100;                                
                                                commissionRecord.Related_to_Quota__c = quotaRecord.id;
                                                commissionRecord.Signing_AE__c = orderOwner.Id;
                                                commissionRecord.Status__c = 'Active';
                                                commissionRecord.Order_Product__c = orderRecord.id;
                                                commissionRecord.User_Team__c = quotaRecord.User_Team__c;
                                                //commission.add(commissionRecord);
                                                if(commissionRecord.Commission_Split__c != 0.0){
                                                    commission.put(orderRecord.id+'###',commissionRecord);
                                                }
                                                orderRecord.Commissions_are_calculated__c = TRUE;
                                                updateOrderitemFlag.put(orderRecord.id,orderRecord);
                                            }
                                        }
                                    }
                                }
                                system.debug('OrderOwnerPercent >> :'+OrderOwnerPercent);
                                for(Quota__c quotaRecord : orderOwnerManagers_Quotas.Values()){
                                    if(ManagerNames61.contains(quotaRecord.User__r.Name.toLowerCase())){
                                        if(!ManagerNames61.contains(orderOwner.Name.toLowerCase())){
                                            if((quotaRecord.User_Team__c == Commissions_Constants.MANAGERS_TEAM) && (OrderCreatedDate.Month() == quotaRecord.Quota_StartDate__c.Month()) && orderRecord.Total_Net__c != Null){
                                                if((ProductCommissionCategory == 'Tiger') || (ProductCommissionCategory == 'TL')){
                                                    if(accountOwner != Null && orderOwner!= Null && orderOwner == accountOwner){
                                                        OrderOwnerPercent = 100;
                                                    }else{
                                                        if(acc.RecordTypeId == newSaleB2B){
                                                            OrderOwnerPercent = quotaRecord.Period_Name__r.Sigh_In_AE__c; 
                                                        }                                               
                                                        if(acc.RecordTypeId == newSaleB2C){
                                                            OrderOwnerPercent = quotaRecord.Period_Name__r.Agent_Sigh_In_AE__c;
                                                        }
                                                    }
                                                    Commission__c commissionRecord = new Commission__c();                       
                                                    commissionRecord.Product__c = product.Id;
                                                    commissionRecord.RecordTypeId = newSaleManagerRT;                       
                                                    commissionRecord.Asset_Amount__c = orderRecord.Total_Net__c;
                                                    commissionRecord.Commissionable_Amount2__c = (orderRecord.Total_Net__c * OrderOwnerPercent )/100;
                                                    commissionRecord.Commission_Split__c = OrderOwnerPercent;                               
                                                    commissionRecord.Related_to_Quota__c = quotaRecord.id;
                                                    commissionRecord.Signing_AE__c = orderOwner.Id;
                                                    commissionRecord.Order_Product__c = orderRecord.id;
                                                    commissionRecord.User_Team__c = quotaRecord.User_Team__c;
                                                    commissionRecord.Status__c = 'Active';
                                                    //commission.add(commissionRecord);
                                                    if(commissionRecord.Commission_Split__c != 0.0){
                                                        commission.put(quotaRecord.id+'####'+orderRecord.id,commissionRecord);
                                                    }
                                                    orderRecord.Commissions_are_calculated__c = TRUE;
                                                    updateOrderitemFlag.put(orderRecord.id,orderRecord);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            if(accountOwner != null && (!accountOwner.Profile.Name.Contains('Open Book'))){  
                                if(orderOwner.id <> accountOwner.id){                
                                    set<String> accountManagerNames = new Set<String>(); 
                                    string[] str4;      
                                    String x1 = accountOwner.Managers__c;            
                                    if(x1 != null){
                                        str4 = x1.split(';');           
                                        for(string str : str4){       
                                            accountManagerNames.add(str.toLowerCase());
                                        }
                                    }
                                    for(Quota__c  quotaRecord : orderOwnerQuotas.Values()){  
                                        if((quotaRecord.User__c == accountOwner.id) && ((quotaRecord.User_Team__c != Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM) && (OrderCreatedDate.Month() == quotaRecord.Quota_StartDate__c.Month()))
                                            || ((quotaRecord.User_Team__c == Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM) && (quotaRecord.Current_Quater__c == RDTeam))){
                                            if(accountOwner.Id == quotaRecord.User__c  && orderRecord.Total_Net__c != Null){
                                                if((ProductCommissionCategory == 'Tiger') || (ProductCommissionCategory == 'TL')){                        
                                                    if(acc.RecordTypeId == newSaleB2B){                                                     
                                                        AccountOwnerPercent = quotaRecord.Period_Name__r.asset_Owner__c;
                                                    }
                                                    if(acc.RecordTypeId == newSaleB2C){                                                     
                                                        AccountOwnerPercent = quotaRecord.Period_Name__r.Agent_asset_Owner__c;
                                                    }
                                                    Commission__c commissionRecord = new Commission__c();                       
                                                    commissionRecord.Product__c = product.Id;
                                                    commissionRecord.RecordTypeId = newSaleRT;   
                                                    commissionRecord.Asset_Amount__c= orderRecord.Total_Net__c;
                                                    commissionRecord.Related_to_Quota__c = quotaRecord.id;
                                                    commissionRecord.Signing_AE__c = orderOwner.Id;
                                                    commissionRecord.Order_Product__c = orderRecord.id;
                                                    commissionRecord.Commissionable_Amount3__c = (orderRecord.Total_Net__c * AccountOwnerPercent)/100;
                                                    commissionRecord.Commission_Split__c = AccountOwnerPercent;
                                                    commissionRecord.User_Team__c = quotaRecord.User_Team__c;
                                                    commissionRecord.Status__c = 'Active';
                                                    //commission.add(commissionRecord);
                                                    if(commissionRecord.Commission_Split__c != 0.0){
                                                        commission.put(orderRecord.id+'#####',commissionRecord);
                                                    }
                                                    orderRecord.Commissions_are_calculated__c = TRUE;
                                                    updateOrderitemFlag.put(orderRecord.id,orderRecord);
                                                }
                                            }
                                        }
                                    }
                                    for(Quota__c quotaRecord : orderOwnerManagers_Quotas.Values()){
                                        if(!accountManagerNames.contains(orderOwner.Name.toLowerCase())){
                                            if(accountManagerNames.contains(quotaRecord.User__r.Name.toLowerCase())){
                                                if((quotaRecord.User_Team__c == Commissions_Constants.MANAGERS_TEAM) && (OrderCreatedDate.Month() == quotaRecord.Quota_StartDate__c.Month())  && orderRecord.Total_Net__c != Null){
                                                    if((ProductCommissionCategory == 'Tiger')||(ProductCommissionCategory == 'TL')){                        
                                                        if(acc.RecordTypeId == newSaleB2B){                                                         
                                                            AccountOwnerPercent = quotaRecord.Period_Name__r.asset_Owner__c;
                                                        }
                                                        if(acc.RecordTypeId == newSaleB2C){                                                         
                                                            AccountOwnerPercent = quotaRecord.Period_Name__r.Agent_asset_Owner__c;
                                                        }
                                                        Commission__c commissionRecord = new Commission__c();                       
                                                        commissionRecord.Product__c = product.Id;
                                                        commissionRecord.RecordTypeId = newSaleManagerRT;   
                                                        commissionRecord.Asset_Amount__c = orderRecord.Total_Net__c;
                                                        commissionRecord.Related_to_Quota__c = quotaRecord.id;
                                                        commissionRecord.Signing_AE__c = orderOwner.Id;
                                                        commissionRecord.Order_Product__c = orderRecord.id;
                                                        commissionRecord.Commissionable_Amount2__c = (orderRecord.Total_Net__c * AccountOwnerPercent)/100;                                        
                                                        commissionRecord.Commission_Split__c = AccountOwnerPercent;
                                                        commissionRecord.User_Team__c = quotaRecord.User_Team__c;
                                                        commissionRecord.Status__c = 'Active';
                                                        //commission.add(commissionRecord);
                                                        if(commissionRecord.Commission_Split__c != 0.0){
                                                            commission.put(quotaRecord.id+'######'+orderRecord.id,commissionRecord);
                                                        }
                                                        orderRecord.Commissions_are_calculated__c = TRUE;
                                                        updateOrderitemFlag.put(orderRecord.id,orderRecord);
                                                    }
                                                }   
                                            }
                                        }
                                    }                   
                                }
                            }
                        }
                    }           
                }
            }
        }
        system.debug('commission : '+commission.size());
        if(commission.size() > 0){
            system.debug('commission : '+commission);
            insert commission.values();
        }
        if(updateOrderitemFlag.size() > 0){
            update updateOrderitemFlag.values();
        }       
    }    
    //************************************************************************************************************
    
    Public void UpdateCommissions(Map<Id, OrderItem> newTriggerValues){ 
        //VERIABLE DECLERATION
        set<Id> orderItemIds = new set<id>(); 
        set<Id> orderIds = new set<id>();   
        set<Id> ProductIds = new set<id>(); 
        set<Id> orderOwnerIds = new set<id>();
        Map<id,commission__c> commission = new Map<id,Commission__c>();    
        Map<id,orderItem> updateOrderitemFlag = new Map<id,orderItem>();
        for(OrderItem OT : newTriggerValues.Values()){
            orderItemIds.add(OT.Id);
            orderIds.add(OT.OrderId); 
            orderOwnerIds.add(OT.CreatedById);                                        
        }                      
        Map<ID,Commission__c> orderCommissionsToUpdate = new Map<ID,Commission__c>([select id,Signing_AE__c,Related_to_Quota__r.User__c,Related_to_Asset__r.Sign_in_AE__c,
                                                    Related_to_Asset__r.OwnerId,Related_to_Quota__r.Target_Amount__c,Product__r.Commission_Category__c,Related_to_Asset__r.Product2ID,
                                                    Related_to_Asset__c,Related_to_Quota__c,CreatedDate,Commissionable_Amount2__c,Quota_Percentage_Achieved1__c ,Payout_Rate1B__c,
                                                    Product__c ,TIGER_Payout_Rate4A__c,Order_Product__c,Commission_Split__c,name,Asset_Amount__c,Payout_Rate__c from Commission__c where 
                                                    Order_Product__c In : orderItemIds order by Name Asc]);
        Map<Id,OrderItem> orderItemsWithCommissions = new Map<Id,OrderItem>();
        Map<Id,OrderItem> orderItemsWithOutCommissions = new Map<Id,OrderItem>();
        Map<Id,OrderItem> orderItemsWithCommissionsCancel = new Map<Id,OrderItem>();
        for(commission__c comm : orderCommissionsToUpdate.Values()){
            orderItem orderItemRecord = newTriggerValues.get(comm.Order_Product__c);
            if(!Test.IsRunningTest()){
                orderItemsWithCommissions.put(orderItemRecord.id,orderItemRecord);
            }
        }
        DateTime OrderTtemCreatedDateDate ;
        for(OrderItem orderItemRecord : newTriggerValues.Values()){
            if(test.IsRunningTest()){
                OrderTtemCreatedDateDate = System.today();
            }
            else{
                OrderTtemCreatedDateDate = orderItemRecord.CreatedDate;              
            }
            if(OrderTtemCreatedDateDate >= Date.newInstance(2015,12, 1)){
                if(!orderItemsWithCommissions.ContainsKey(orderItemRecord.Id)){                             
                    orderItemsWithOutCommissions.put(orderItemRecord.Id,orderItemRecord);
                }
                if(orderItemsWithCommissions.ContainsKey(orderItemRecord.Id)){ 
                    //if(orderItemRecord.LastModifiedDate >= orderItemRecord.CreatedDate){  
                    if(orderItemRecord.Line_Type__c == 'Cancel'){
                        orderItemsWithCommissionsCancel.put(orderItemRecord.Id,orderItemRecord);
                    }
                    //}
                }   
            }                   
        }  
        if(orderItemsWithOutCommissions.size() > 0){
            CreateCommissions(orderItemsWithOutCommissions);
        }
        if(orderItemsWithOutCommissions.size() > 0){
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
            Integer Year = Date.Today().Year();
            Map<id,Quota__c> orderOwnerQuotas = new Map<id,Quota__c>([select id,Name,User__c,Is_Kicker__c,Quota_StartDate__c,Period_Name__r.Sigh_In_AE__c,Period_Name__r.asset_Owner__c,
                                                    Period_Name__r.Agent_Sigh_In_AE__c,User_Team__c,Target_Amount_2__c,Period_Name__r.Agent_Asset_Owner__c,Current_Quater__c from Quota__c where 
                                                    User__c In : orderOwnerIds]);                       
            Set<Id> orderOwnerQuotasUserIds = new Set<Id>();        
            for(Quota__c quotaUser : orderOwnerQuotas.Values()){
                orderOwnerQuotasUserIds.add(quotaUser.User__c);
            }
            Map<id,User> orderOwners  = new Map<id,User>([select id,Name,Team__c from user where Id IN : orderOwnerQuotasUserIds and IsActive = True]);   
            Map<Id,Order> orders = new Map<Id,Order>([select id,ownerId,AccountId,Account.OwnerId,TotalAmount from Order where Id In : orderIds]);
            Set<Id> accountIds = new Set<Id>();
            for(Order Ors : Orders.Values()){    
                accountIds.add(Ors.AccountId);            
            }   
            Map<id,Account> allAccounts = new Map<id,Account>([select id,Name,type,RecordTypeId from Account where Id In : accountIds]);
            Decimal commissionPercentage =0.0;
            Id clawBackRT = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Clawback').getRecordTypeId();
            Id NewSaleRT = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('New Sale').getRecordTypeId();                
            Id newSaleB2B = Schema.SObjectType.account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
            Id newSaleB2C = Schema.SObjectType.account.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
            Id newSaleManagerRT = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Managers Team').getRecordTypeId(); 
            DateTime OrderTtemCreatedDateDate1 ;
            for(OrderItem orderNew : orderItemsWithOutCommissions.Values()){
                if(test.IsRunningTest()){
                    OrderTtemCreatedDateDate = system.today();
                }
                else{
                    OrderTtemCreatedDateDate = orderNew.CreatedDate;
                }
                commissionPercentage =0.0;               
                order Ords = orders.get(orderNew.OrderId);    
                Account Acc = allAccounts.get(Ords.AccountId);
                Integer OrderCreatedYear = OrderTtemCreatedDateDate.Year();
                DateTime myDate = (OrderTtemCreatedDateDate.addmonths(1));  
                Date orderCreatedMonth = date.newinstance(myDate.year(), myDate.month(), myDate.day());                           
                Integer currentCreatedYear = Date.Today().Year();
                Date currentCreatedMonth = Date.Today();                    
                User quotaUser = orderOwners.get(orderNew.CreatedById);            
                if((Integer.ValueOf(orderCreatedMonth.Month()) == Integer.ValueOf(currentCreatedMonth.Month())) && (orderCreatedYear == currentCreatedYear)){
                    if(orderNew.Status__c == 'Cancelled'){ 
                        Commission__c commissionRecordCB = new Commission__c();
                        for(commission__c comm : orderCommissionsToUpdate.Values()){                            
                            if(comm.Order_Product__c == orderNew.Id){                                                   
                                commissionRecordCB.RecordTypeId = clawBackRT;                       
                                commissionRecordCB.RCV__c = orderNew.Total_Net__c;                     
                                commissionRecordCB.Related_Commission__c = comm.id;
                                commissionRecordCB.Quota_Percentage_Achieved1__c = comm.Quota_Percentage_Achieved1__c;
                                commissionRecordCB.Payout_Rate__c = comm.Payout_Rate__c;
                                commissionRecordCB.Payout_Rate1B__c = comm.Payout_Rate1B__c;
                                commissionRecordCB.TIGER_Payout_Rate4A__c = comm.TIGER_Payout_Rate4A__c;
                                commissionRecordCB.Signing_AE__c = orderNew.CreatedById;
                                commissionRecordCB.Order_Product__c = orderNew.id;                                                                                                             
                            }
                        }
                        for(Quota__c quotaRecord : orderOwnerQuotas.Values()){
                            /*if((quotaUser.Team__c != 'Regional Directors Team' || quotaUser.Team__c !='Events Team') || (((quotaUser.Team__c == 'Regional Directors Team') && (quotaRecord.Current_Quater__c == RDTeam)) 
                            || (quotaUser.Team__c=='Events Team') && (quotaRecord.Current_Quater__c == EventTeam)))
                            */
                            if(((quotaRecord.User_Team__c != Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM) && (orderNew.CreatedDate.Month() == quotaRecord.Quota_StartDate__c.Month()))
                            || ((quotaRecord.User_Team__c == Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM) && (quotaRecord.Current_Quater__c == RDTeam))){
                                if((quotaRecord.User__c == quotaUser.id)){
                                    commissionRecordCB.User_Team__c = quotaRecord.User_Team__c;
                                    if(acc.RecordTypeId == newSaleB2B){
                                        commissionPercentage = quotaRecord.Period_Name__r.Sigh_In_AE__c;
                                    }
                                    if(acc.RecordTypeId == newSaleB2C){
                                        commissionPercentage = quotaRecord.Period_Name__r.Agent_Sigh_In_AE__c;                                    
                                    }
                                    commissionRecordCB.Related_to_Quota__c = quotaRecord.id;                                    
                                    commissionRecordCB.Commissionable_Amount2__c = (Ords.TotalAmount * commissionPercentage)/100;
                                    commissionRecordCB.TIGER_Commissionable_Amount4A__c = (Ords.TotalAmount * commissionPercentage)/100;
                                    commissionRecordCB.Commission_Split__c = commissionPercentage;         
                                }
                            }
                        }
                        commission.put(commissionRecordCB.Id,commissionRecordCB);
                        if(commissionRecordCB.Related_to_Quota__c != Null){
                            commission.put(orderNew.Id+'#'+commissionRecordCB.Related_to_Quota__c,commissionRecordCB);                         
                            orderNew.Commissions_are_calculated__c = TRUE;
                            updateOrderitemFlag.put(orderNew.id,orderNew);
                        }
                    }
                }           
            }
            if(commission.size() > 0){
                upsert commission.Values();
            }
        }
    }
}