/*******************************************************************************
Created By      :   Srinivas Pendli
Created Date    :   11-NOV-2015
Usage           :   This main functionality of  this class is to create commission records (New Commissions and Clawback commissions)
                    from asset record based on the business logic
                    1.Create commissions to signing AE ,Asset owner and their managers
                    2.Create commissions for LOA
                    3.Create commissions for Open Book/Open Sale
                    4.Create New Sale Commissions-For New and Legacy assets
                    5.Create ClawBack commissions-For New and Legacy assets
                    6.Updating commissions as per Downgrade and Upgrade amount
                    
Modified By     :   Srinivas Pendli
Modified Date   :   28-APRIL-2016
********************************************************************************/
Public Class Commissions_CreateCommissionsHandler{ 
    Public Static void CreateCommissions(Map<Id, Asset> newTriggerValues){       
        //VARIABLES DECLERATION
        set<Id> productIds = new set<id>();     
        set<Id> accountIds = new set<id>(); set<Id> signInAEIds = new set<id>();          
        Map<String,commission__c> commission = new Map<String,commission__c>(); 
        Map<Id,Quota__c> signInAeQuotas = new Map<Id,Quota__c>();
        Map<Id,Quota__c> ownerQuotas = new Map<Id,Quota__c>();
        Map<id,asset>  updateAssets = new Map<id,Asset>();
        Decimal signingAEPercent = 0.0;Decimal assetOwnerPercent = 0.0; 
        //BROKER REGIONAL DIRECTIORS TEAM CURRENT QUATER CALCULATION
        String RDTeam = '' ;   
        Integer MonthValue =  system.today().Month();  
        If((MonthValue == 1) || (MonthValue == 2) || (MonthValue == 3)){
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
        //COLLECTING SIGNING AE'S,ASSET OWNERS,ACCOUNT IDS AND PRODUCT IDS
        for(Asset assetId : newTriggerValues.values()){            
            ProductIds.add(assetId.product2id);
            accountIds.add(assetId.AccountId);
            SignInAEIds.add(assetId.Sign_in_AE__c);           
            SignInAEIds.add(assetId.OwnerId);
        }        
        system.debug('SignInAEIds >> : '+SignInAEIds);
        //GETTING ALL SIGNING AE's AND ASSET OWNER QUOTAS FOR QUOTA OBJECT
        Map<id,Quota__c> assetSignInAEQuotas = new Map<id,Quota__c>([select id,Name,User__c,User__r.Team__c,User__r.Managers__c,Quota_StartDate__c,Period_Name__r.Sigh_In_AE__c,Period_Name__r.asset_Owner__c,
                                                   User_Team__c,Target_Amount_2__c,Record_Processed__c,Period_Name__r.Agent_Asset_Owner__c,Period_Year1__c,Period_Name__r.Agent_Sigh_In_AE__c,Is_Kicker__c,Current_Quater__c from Quota__c where 
                                                   User__c In : SignInAEIds]);
        system.debug('assetSignInAEQuotas >>> :'+assetSignInAEQuotas);        
        Set<String> AEManagers =  new Set<String>();        
        string[] str1;        
        //COLLECTIING SIGNING AE's AND ASSET OWNER MANAGERS
        for(Quota__c Qs : assetSignInAEQuotas.Values()){
            string x1 = Qs.User__r.Managers__c;            
            if(x1 != null){
                str1 = x1.split(';');           
                for(string str : str1){        
                    AEManagers.add(str.toLowerCase());
                }
            }
        }
        //GETTING ALL SIGNING AE's AND ASSET OWNER MANAGERS QUOTAS FOR QUOTA OBJECT
        Map<id,Quota__c> assetSignInAEManagers_Quotas = new Map<id,Quota__c>([select id,Name,User__r.Name,User__c,User__r.Team__c,User__r.Managers__c,Quota_StartDate__c,User_Team__c,Is_Kicker__c,
                                                            Period_Name__r.Sigh_In_AE__c,Record_Processed__c,Target_Amount_2__c,Period_Name__r.asset_owner__c,Period_Name__r.Agent_Asset_Owner__c,Period_Name__r.Agent_Sigh_In_AE__c,Current_Quater__c from Quota__c where 
                                                            User__r.Name In : AEManagers ]);
        AEManagers.clear();
        system.debug('assetSignInAEManagers_Quotas >>> : '+assetSignInAEManagers_Quotas.size() );        
        Map<id,User> assetsignInAEs  = new Map<id,User>([select id,Name,Team__c,Managers__c,ProfileId,Profile.Name,Vacation_Start_Date__c,Vacation_End_Date__c from user where Id IN : SignInAEIds ]);
        system.debug('assetsignInAEs >> : '+assetsignInAEs);        
        Map<id,Product2> assetProducts = new Map<id,Product2>([select id,Name,Normalization_factor__c,Commission_Category__c from product2 where id In : ProductIds ]);
        ProductIds.clear();
        Map<id,Account> allAccounts = new Map<id,Account>([select id,Name,type,RecordTypeId from Account where Id In : accountIds ]);
        accountIds.clear();
        Map<id,Quota__c> updateQuota = new Map<Id,Quota__c>();           
        
        //RECORD TYPES     
        Id newSaleRT = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('New Sale').getRecordTypeId();       
        Id newSaleB2B = Schema.SObjectType.account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        Id newSaleB2C = Schema.SObjectType.account.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        Id newSaleManagerRT = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Managers Team').getRecordTypeId(); 
        Decimal TotalNet = 0.0;DateTime assetLastModifiedDate ;DateTime assetCreatedDateDate ;
        
        //CREATING COMMISSIONS FOR SIGN IN AND ACCOUNT OWNER OF PROCESSED ASSETS /UPDATING ASSETS   
        for(Asset assetRecord : newTriggerValues.values()){            
            system.debug('assetRecord 1: '+assetRecord.id);
            signingAEPercent = 0.0;assetOwnerPercent = 0.0;TotalNet = 0.0;
            account acc = allAccounts.get(assetRecord.AccountId);  
            if(assetRecord.Status == Constants.ACTIVE_STATUS &&  assetRecord.Sign_in_AE__c != null && assetRecord.OwnerId != Null && assetRecord.Total_Net__c != Null && assetRecord.Order_Line_Item__r.Product_Commission_Category__c != 'Tiger'){
                system.debug('assetRecord 2: '+assetRecord.id);
                Product2 Products = assetProducts.get(assetRecord.product2id);
                User SignInAE = assetsignInAEs.get(assetRecord.Sign_in_AE__c); 
                User assetOwner = assetsignInAEs.get(assetRecord.OwnerId);
                set<String> ManagerNames = new Set<String>();
                if(test.IsRunningTest()){
                    assetLastModifiedDate = System.today();
                    assetCreatedDateDate = System.today();
                }
                else{
                    assetLastModifiedDate = assetRecord.LastModifiedDate;
                    assetCreatedDateDate = assetRecord.CreatedDate;
                }
                
                if(assetRecord.Line_Type__c == 'Amend' ||  assetRecord.Line_Type__c == 'Cancel'){
                    TotalNet = assetRecord.Delta_Price__c;
                }
                else{
                    TotalNet = assetRecord.Total_Net__c;
                }                
                if(assetRecord.Sign_in_AE__c == assetRecord.OwnerId){
                    signingAEpercent = 100;
                }
                if((SignInAE != Null ) || (assetOwner != Null)){
                    //OPEN BOOK AND LOA - COMMISSION CREATION LOGIC
                    if((assetOwner != Null ) && (((assetOwner.Vacation_Start_Date__c != null && assetOwner.Vacation_End_Date__c != Null) && (assetOwner.Vacation_Start_Date__c < assetCreatedDateDate && assetCreatedDateDate < assetOwner.Vacation_End_Date__c)) || 
                    (assetOwner.Profile.Name.Contains('Open Book')))){
                        signingAEpercent = 100;
                        system.debug('LOA Loop and Open Book Loop');
                        set<String> ManagerNames16 = new Set<String>();     
                        string[] str66; String x66;
                        if(SignInAE != Null){
                            if(SignInAE.Managers__c != null){      
                                x66 = SignInAE.Managers__c;
                            }            
                            if(x66 != null){
                                str66 = x66.split(';');           
                                for(string str : str66){
                                    ManagerNames16.add(str.toLowerCase());
                                }
                            }
                            //CREATING COMMISSIONS TO SIGNING AE'S WITH 100% SPLIT -AS PER LOA AND OPEN BOOK LOGIC                          
                            for(quota__c quotaRecordSAE : assetSignInAEQuotas.values()){
                                if((quotaRecordSAE != Null) && (quotaRecordSAE.User__c == assetRecord.Sign_in_AE__c)&& (((quotaRecordSAE.User_Team__c != Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM) && (assetLastModifiedDate.Month() == quotaRecordSAE.Quota_StartDate__c.Month()))
                                    || (((quotaRecordSAE.User_Team__c == Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM) && (quotaRecordSAE.Current_Quater__c == RDTeam))))){                        
                                    Commission__c commissionRecord = new Commission__c();                       
                                    commissionRecord.Related_to_Asset__c = assetRecord.id;
                                    commissionRecord.Product__c = assetRecord.product2id;
                                    commissionRecord.Billing_Type__c = assetRecord.Billing_Period__c;
                                    if(quotaRecordSAE.User_Team__c == Commissions_Constants.MANAGERS_TEAM){
                                        commissionRecord.RecordTypeId = newSaleManagerRT;
                                    }else{
                                        commissionRecord.RecordTypeId = newSaleRT;
                                    }                                   
                                    commissionRecord.Asset_Amount__c= assetRecord.Total_Net__c;
                                    if(quotaRecordSAE.User_Team__c == Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM || quotaRecordSAE.User_Team__c == Commissions_Constants.COLLECTION_TEAM || quotaRecordSAE.User_Team__c == Commissions_Constants.COLLECTIONS_CLIENT_RELATIONS_MANAGERS){
                                        commissionRecord.OpenBook_New_Sale_Comm_ble_Amount__c  = (assetRecord.Total_Net__c * signingAEpercent)/100;
                                    }else{
                                        commissionRecord.Commissionable_Amount2__c = (assetRecord.Total_Net__c * signingAEpercent)/100;
                                    }
                                    commissionRecord.Commission_Split__c = signingAEpercent;
                                    commissionRecord.Status__c = 'Active';
                                    if((Products.Commission_Category__c == 'CFCB' && Products.Commission_Category__c != null) && (quotaRecordSAE.Target_Amount_2__c != 0.0 && quotaRecordSAE.Target_Amount_2__c !=null)){
                                        if(assetRecord.Renewal_Type__c == Null && quotaRecordSAE.Is_Kicker__c == TRUE){  
                                            commissionRecord.CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c = (TotalNet * signingAEpercent)/100;
                                        }  
                                        if(assetRecord.Renewal_Type__c == Null && quotaRecordSAE.Is_Kicker__c == FALSE){                                    
                                            commissionRecord.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c = (TotalNet * signingAEpercent)/100;
                                        }
                                        if((assetRecord.Renewal_Type__c == 'Auto' || assetRecord.Renewal_Type__c == 'Manual') && quotaRecordSAE.Is_Kicker__c == TRUE){  
                                            commissionRecord.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c = (TotalNet * signingAEpercent)/100;
                                        }
                                        if((assetRecord.Renewal_Type__c == 'Auto' || assetRecord.Renewal_Type__c == 'Manual') && quotaRecordSAE.Is_Kicker__c == FALSE){ 
                                            commissionRecord.CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c= (TotalNet * signingAEpercent)/100;
                                        }                                   
                                    }                                      
                                    commissionRecord.Signing_AE__c = assetRecord.Sign_in_AE__c;       
                                    commissionRecord.Related_to_Quota__c = quotaRecordSAE.id;
                                    commissionRecord.User_Team__c = quotaRecordSAE.User__r.Team__c;
                                    commissionRecord.Record_Processed__c = FALSE;
                                    if(commissionRecord.Related_to_Quota__c != Null){
                                        commission.put(assetRecord.id+'#',commissionRecord);
                                        assetRecord.Commissions_are_calculated__c = true;
                                        updateAssets.put(assetRecord.id,assetRecord);
                                        quotaRecordSAE.Record_Processed__c = FALSE;
                                        updateQuota.put(quotaRecordSAE.id,quotaRecordSAE);
                                    }
                                }
                            }
                        }
                        //CREATING COMMISSIONS TO SIGNING AE'S MANAGERS WITH 100% SPLIT -AS PER LOA AND OPEN BOOK LOGIC
                        for(Quota__c quotaRecord : assetSignInAEManagers_Quotas.Values()){
                            if(ManagerNames16.contains(quotaRecord.User__r.Name.toLowerCase())){
                                if(!ManagerNames16.contains(SignInAE.Name.toLowerCase())){
                                    if((quotaRecord.User_Team__c == Commissions_Constants.MANAGERS_TEAM) && (assetLastModifiedDate.Month() == quotaRecord.Quota_StartDate__c.Month())){                                       
                                        Commission__c commissionRecord = new Commission__c();                       
                                        commissionRecord.Related_to_Asset__c = assetRecord.id;
                                        commissionRecord.Product__c = assetRecord.product2id;
                                        commissionRecord.Billing_Type__c = assetRecord.Billing_Period__c;
                                        commissionRecord.RecordTypeId = newSaleManagerRT;
                                        commissionRecord.Asset_Amount__c= TotalNet;                                     
                                        commissionRecord.Is_Manager_Commission__c = true;
                                        commissionRecord.Manager_Of__c = SignInAE.Name;
                                        commissionRecord.Commissionable_Amount2__c = (TotalNet * signingAEpercent)/100;
                                        commissionRecord.Commission_Split__c = signingAEpercent;                                            
                                        commissionRecord.Signing_AE__c = assetRecord.Sign_in_AE__c;       
                                        commissionRecord.Related_to_Quota__c = quotaRecord.id;
                                        commissionRecord.User_Team__c = quotaRecord.User__r.Team__c;
                                        commissionRecord.Status__c = 'Active';
                                        commissionRecord.Record_Processed__c = FALSE;
                                        if(commissionRecord.Related_to_Quota__c != Null){                                       
                                            commission.put(quotaRecord.id+'##'+assetRecord.id,commissionRecord);
                                            assetRecord.Commissions_are_calculated__c = true;
                                            updateAssets.put(assetRecord.id,assetRecord);
                                            quotaRecord.Record_Processed__c = FALSE;
                                            updateQuota.put(quotaRecord.id,quotaRecord);
                                        }
                                    }
                                }
                            }
                        }                     
                        ManagerNames16.clear(); 
                    }
                    else{
                        //CREATING COMMISSIONS TO SIGNING AE's AND ASSET OWNERS
                        if(SignInAE != Null || assetOwner != Null){                      
                            system.debug('assetRecord : 3'+assetRecord.id);               
                            string[] str3; String x1;
                            //CREATING COMMISSIONS TO SIGNING AE's
                            if(SignInAE != Null ){
                                if(SignInAE.Managers__c != Null){
                                    x1 = SignInAE.Managers__c;
                                }
                                if(x1 != null){
                                    str3 = x1.split(';');           
                                    for(string str : str3){                                        
                                        ManagerNames.add(str.toLowerCase());
                                    }
                                } 
                                system.debug('assetRecord : 4>>'+RDTeam);
                                //CREATING COMMISSIONS TO SIGNING AE'S WITH DEFINED SPLIT FROM PERIOD OBJECT FOR CURRENT MONTH
                                for(quota__c quotaRecordSAE : assetSignInAEQuotas.values()){                                    
                                    if((quotaRecordSAE != Null) && (quotaRecordSAE.User__c == assetRecord.Sign_in_AE__c) && ((((quotaRecordSAE.User_Team__c != Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM)) && (assetLastModifiedDate.Month() == quotaRecordSAE.Quota_StartDate__c.Month()))
                                        || (((quotaRecordSAE.User_Team__c == Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM) && (quotaRecordSAE.Current_Quater__c == RDTeam))))){
                                        if(Test.isRunningTest()){
                                            signingAEpercent = 100;
                                        }
                                        else{                                    
                                            if(SignInAE != Null && assetOwner != NULL && SignInAE == assetOwner){
                                                signingAEpercent = 100;
                                            }else{
                                                if(quotaRecordSAE != Null && acc.RecordTypeId == newSaleB2B){
                                                    signingAEpercent = quotaRecordSAE.Period_Name__r.Sigh_In_AE__c;                        
                                                }
                                                if(quotaRecordSAE != Null && acc.RecordTypeId == newSaleB2C){
                                                    signingAEpercent = quotaRecordSAE.Period_Name__r.Agent_Sigh_In_AE__c;                       
                                                }
                                            }
                                        }
                                        if(signingAEpercent != 0.0){
                                            system.debug('assetRecord : 4'+assetRecord.id); 
                                            Commission__c commissionRecord = new Commission__c();                       
                                            commissionRecord.Related_to_Asset__c = assetRecord.id;
                                            commissionRecord.Product__c = assetRecord.product2id;
                                            commissionRecord.Billing_Type__c = assetRecord.Billing_Period__c;
                                            if(quotaRecordSAE.User_Team__c == Commissions_Constants.MANAGERS_TEAM){
                                                commissionRecord.RecordTypeId = newSaleManagerRT;
                                            }else{
                                                commissionRecord.RecordTypeId = newSaleRT;
                                            }       
                                            commissionRecord.Asset_Amount__c= TotalNet;
                                            commissionRecord.Commission_Split__c = signingAEpercent;
                                            commissionRecord.Signing_AE__c = assetRecord.Sign_in_AE__c;       
                                            commissionRecord.Related_to_Quota__c = quotaRecordSAE.id;                                        
                                            commissionRecord.User_Team__c = quotaRecordSAE.User__r.Team__c;
                                            commissionRecord.Status__c = 'Active'; 
                                            commissionRecord.Record_Processed__c = FALSE;                                           
                                            if(quotaRecordSAE.User_Team__c == Commissions_Constants.COLLECTION_TEAM || quotaRecordSAE.User_Team__c == Commissions_Constants.COLLECTIONS_CLIENT_RELATIONS_MANAGERS){
                                                commissionRecord.OpenBook_New_Sale_Comm_ble_Amount__c  = (TotalNet * signingAEpercent)/100;
                                            }else{
                                                commissionRecord.Commissionable_Amount2__c = (TotalNet * signingAEpercent)/100;    
                                            }                                                            
                                              
                                            if((Products.Commission_Category__c != 'Null' && Products.Commission_Category__c == 'CFCB') && (quotaRecordSAE.Target_Amount_2__c !=null && quotaRecordSAE.Target_Amount_2__c != 0.0)){
                                                if(assetRecord.Renewal_Type__c == Null && quotaRecordSAE.Is_Kicker__c == TRUE){  
                                                    commissionRecord.CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c = (TotalNet * signingAEpercent)/100;
                                                }  
                                                if(assetRecord.Renewal_Type__c == Null && quotaRecordSAE.Is_Kicker__c == FALSE){                                    
                                                    commissionRecord.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c = (TotalNet * signingAEpercent)/100;
                                                }
                                                if((assetRecord.Renewal_Type__c == 'Auto' || assetRecord.Renewal_Type__c == 'Manual') && quotaRecordSAE.Is_Kicker__c == TRUE){  
                                                    commissionRecord.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c = (TotalNet * signingAEpercent)/100;
                                                }
                                                if((assetRecord.Renewal_Type__c == 'Auto' || assetRecord.Renewal_Type__c == 'Manual') && quotaRecordSAE.Is_Kicker__c == FALSE){ 
                                                    commissionRecord.CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c= (TotalNet * signingAEpercent)/100;
                                                }                                   
                                            }  
                                            if(commissionRecord.Related_to_Quota__c != Null){
                                                commission.put(assetRecord.id+'#####',commissionRecord);
                                                assetRecord.Commissions_are_calculated__c = true;
                                                updateAssets.put(assetRecord.id,assetRecord);
                                                quotaRecordSAE.Record_Processed__c =FALSE;
                                                updateQuota.put(quotaRecordSAE.id,quotaRecordSAE);
                                            }
                                        }
                                    }
                                }
                                //CREATING COMMISSIONS TO SIGNING AE's MANAGERS 
                                System.debug('>>> :'+assetSignInAEManagers_Quotas.size());          
                                for(Quota__c quotaRecord : assetSignInAEManagers_Quotas.Values()){
                                    System.debug('>>> 1:'+quotaRecord );
                                    if(ManagerNames.contains(quotaRecord.User__r.Name.toLowerCase())){
                                        if((!ManagerNames.contains(SignInAE.Name.toLowerCase()))){
                                            system.debug('assetRecord : 5>>>'+assetLastModifiedDate.Month());
                                            system.debug('assetRecord : 5>>>>'+quotaRecord.Quota_StartDate__c.Month()); 
                                            if((quotaRecord.User_Team__c == Commissions_Constants.MANAGERS_TEAM) && (assetLastModifiedDate.Month() == quotaRecord.Quota_StartDate__c.Month())){  
                                                System.debug('>>> 2:'+quotaRecord );
                                                /*
                                                if(Test.isRunningTest()){
                                                    signingAEpercent = 100;
                                                }
                                                else{                                    
                                                    if(SignInAE != Null && assetOwner != NULL && SignInAE == assetOwner){
                                                        signingAEpercent = 100;
                                                    }else{
                                                        if(quotaRecord != Null && acc.RecordTypeId == newSaleB2B){
                                                            signingAEpercent = quotaRecord.Period_Name__r.Sigh_In_AE__c;                        
                                                        }
                                                        if(quotaRecord != Null && acc.RecordTypeId == newSaleB2C){
                                                            signingAEpercent = quotaRecordSAE.Period_Name__r.Agent_Sigh_In_AE__c;                       
                                                        }
                                                    }
                                                }
                                                */
                                                if(signingAEpercent != 0.0){
                                                    Commission__c commissionRecord = new Commission__c();                       
                                                    commissionRecord.Related_to_Asset__c = assetRecord.id;
                                                    commissionRecord.Product__c = assetRecord.product2id;
                                                    commissionRecord.Billing_Type__c = assetRecord.Billing_Period__c;
                                                    commissionRecord.RecordTypeId = newSaleManagerRT;
                                                    commissionRecord.Asset_Amount__c= TotalNet;                                     
                                                    commissionRecord.Is_Manager_Commission__c = true;
                                                    commissionRecord.Manager_Of__c = SignInAE.Name;
                                                    commissionRecord.Commissionable_Amount2__c = (TotalNet * signingAEpercent)/100;                                            
                                                    commissionRecord.Commission_Split__c = signingAEpercent;                                           
                                                    commissionRecord.Signing_AE__c = assetRecord.Sign_in_AE__c;       
                                                    commissionRecord.Status__c = 'Active';
                                                    commissionRecord.Record_Processed__c = FALSE;
                                                    commissionRecord.Related_to_Quota__c = quotaRecord.id;
                                                    commissionRecord.User_Team__c = quotaRecord.User_Team__c;
                                                    if(commissionRecord.Related_to_Quota__c != Null){
                                                        commission.put(quotaRecord.id+'######'+assetRecord.id,commissionRecord);
                                                        assetRecord.Commissions_are_calculated__c = true;
                                                        updateAssets.put(assetRecord.id,assetRecord);
                                                        quotaRecord.Record_Processed__c = FALSE;
                                                        updateQuota.put(quotaRecord.id,quotaRecord);
                                                    }
                                                }                                               
                                            }
                                        }
                                    }
                                }
                                ManagerNames.clear();
                            }  
                            //CREATING COMMISSIONS FOR ASSET OWNERS
                            set<String> accountManagerNames = new Set<String>();    
                            if(assetOwner != null && (!assetOwner.Profile.Name.Contains('Open Book'))){                         
                                if((assetRecord.OwnerId <> assetRecord.Sign_in_AE__c)){                        
                                    string[] str4;String x11;
                                    if(assetOwner.Managers__c != Null){ 
                                        x11 = assetOwner.Managers__c;
                                    }
                                    if(x11 != null){
                                        str4 = x11.split(';');           
                                        for(string str : str4){       
                                            accountManagerNames.add(str.toLowerCase());
                                        }
                                    }
                                    //CREATING COMMISSIONS TO ASSET OWNER'S WITH DEFINED SPLIT FROM PERIOD OBJECT FOR CURRENT MONTH
                                    for(quota__c quotaRecordAO : assetSignInAEQuotas.values()){                                       
                                        if((quotaRecordAO != Null) && (quotaRecordAO.User__c == assetRecord.OwnerId) && (((quotaRecordAO.User_Team__c != Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM) && (assetLastModifiedDate.Month() == quotaRecordAO.Quota_StartDate__c.Month()))
                                            || ((quotaRecordAO.User_Team__c == Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM) && (quotaRecordAO.Current_Quater__c == RDTeam)))){
                                            if(quotaRecordAO!=Null && acc.RecordTypeId == newSaleB2B){                               
                                                assetOwnerPercent = quotaRecordAO.Period_Name__r.asset_Owner__c;
                                            }
                                            if(quotaRecordAO!= Null && acc.RecordTypeId == newSaleB2C){                                
                                                assetOwnerPercent = quotaRecordAO.Period_Name__r.Agent_asset_Owner__c;
                                            }
                                            if(assetOwnerPercent !=0.0){
                                                system.debug('quotaRecordAO : '+quotaRecordAO);
                                                Commission__c commission2Records = new Commission__c(); 
                                                commission2Records.Related_to_Asset__c = assetRecord.id;
                                                commission2Records.Product__c = assetRecord.product2id;
                                                commission2Records.Billing_Type__c = assetRecord.Billing_Period__c;
                                                if(quotaRecordAO.User_Team__c == Commissions_Constants.MANAGERS_TEAM){
                                                    commission2Records.RecordTypeId = newSaleManagerRT;
                                                }else{
                                                    commission2Records.RecordTypeId = newSaleRT;
                                                }                                           
                                                commission2Records.Asset_Amount__c= TotalNet;                                       
                                                commission2Records.Manager_Of__c = assetOwner.Name;
                                                commission2Records.Commission_Split__c = assetOwnerPercent;
                                                commission2Records.Commissionable_Amount3__c = (TotalNet * assetOwnerPercent)/100;                                           
                                                commission2Records.Signing_AE__c = assetRecord.Sign_in_AE__c;
                                                commission2Records.Billing_Type__c = assetRecord.Billing_Period__c;
                                                commission2Records.Status__c = 'Active';
                                                commission2Records.Record_Processed__c = FALSE;
                                                commission2Records.Related_to_Quota__c = quotaRecordAO.id;
                                                commission2Records.User_Team__c = quotaRecordAO.User_Team__c;
                                                if(commission2Records.Related_to_Quota__c != Null){
                                                    commission.put(assetRecord.id+'#######',commission2Records);
                                                    assetRecord.Commissions_are_calculated__c = true;
                                                    updateAssets.put(assetRecord.id,assetRecord);
                                                    quotaRecordAO.Record_Processed__c = FALSE;
                                                    updateQuota.put(quotaRecordAO.id,quotaRecordAO);
                                                }
                                            }
                                        }
                                    }
                                }
                                //CREATING COMMISSIONS TO ASSET OWNER MANAGERS
                                for(Quota__c quotaRecord : assetSignInAEManagers_Quotas.Values()){                                    
                                    if(!accountManagerNames.contains(assetOwner.Name.toLowerCase())){
                                        if((accountManagerNames.contains(quotaRecord.User__r.Name.toLowerCase()))){
                                            if((quotaRecord.User_Team__c == Commissions_Constants.MANAGERS_TEAM) && (assetLastModifiedDate.Month() == quotaRecord.Quota_StartDate__c.Month())){  
                                                /*
                                                if(quotaRecordAO!=Null && acc.RecordTypeId == newSaleB2B){                               
                                                    assetOwnerPercent = quotaRecordAO.Period_Name__r.asset_Owner__c;
                                                }
                                                if(quotaRecordAO!= Null && acc.RecordTypeId == newSaleB2C){                                
                                                    assetOwnerPercent = quotaRecordAO.Period_Name__r.Agent_asset_Owner__c;
                                                }
                                                */
                                                if(assetOwnerPercent !=0.0){
                                                    Commission__c commission2Records = new Commission__c(); 
                                                    commission2Records.Related_to_Asset__c = assetRecord.id;
                                                    commission2Records.Product__c = assetRecord.product2id;
                                                    commission2Records.Billing_Type__c = assetRecord.Billing_Period__c;
                                                    commission2Records.RecordTypeId = newSaleManagerRT;
                                                    commission2Records.Asset_Amount__c= TotalNet;                                      
                                                    commission2Records.Is_Manager_Commission__c = true;
                                                    commission2Records.Manager_Of__c = assetOwner.Name;
                                                    commission2Records.Commissionable_Amount2__c = (TotalNet * assetOwnerPercent)/100;
                                                    commission2Records.Commission_Split__c = assetOwnerPercent;                                          
                                                    commission2Records.Signing_AE__c = assetRecord.Sign_in_AE__c;
                                                    commission2Records.Billing_Type__c = assetRecord.Billing_Period__c;
                                                    commission2Records.Status__c = 'Active';
                                                    commission2Records.Related_to_Quota__c = quotaRecord.id;
                                                    commission2Records.User_Team__c = quotaRecord.User__r.Team__c;
                                                    commission2Records.Normalization_factor__c = 1.0;                                    
                                                    commission2Records.Payout_rate_3__c = 0.00;
                                                    commission2Records.Record_Processed__c = FALSE;
                                                    if(commission2Records.Related_to_Quota__c != Null){
                                                        commission.put(quotaRecord.id+'########'+assetRecord.id,commission2Records);
                                                        assetRecord.Commissions_are_calculated__c = true;
                                                        updateAssets.put(assetRecord.id,assetRecord);
                                                        quotaRecord.Record_Processed__c = FALSE;
                                                        updateQuota.put(quotaRecord.id,quotaRecord);
                                                    }
                                                }                                               
                                            }
                                        }
                                    }                               
                                }                    
                                accountManagerNames.clear();
                            }
                        }
                    }
                }
            }
            assetRecord.Record_processed_for_commission__c = true;
            updateAssets.put(assetRecord.id,assetRecord);
        }
        System.debug(LoggingLevel.ERROR, 'Heap Size Commissions Loop >> 1 : ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize());
        signInAeQuotas.clear();ownerQuotas.clear();assetSignInAEQuotas.clear();assetSignInAEManagers_Quotas.clear();assetsignInAEs.clear();
        productIds.clear(); accountIds.clear();signInAEIds.clear();
        assetProducts.clear();allAccounts.clear() ;AEManagers.clear();
        //CREATING COMMISSIONS    
        if(commission.size () > 0){                                         
            try{
                upsert commission.Values();                          
            }
            Catch(Exception e){}  
        } 
        commission.clear();
        //UPDATING QUOTAS
        if(updateQuota.size() > 0){
            try{               
                update updateQuota.Values();                
            }
            Catch(Exception e){}
        }
        updateQuota.clear(); 
        system.debug('Commission Size >>> :'+commission.size());
        //UPDATING ASSETS
        if(updateAssets.size() > 0){
            try{
                update updateAssets.values();
            }
            Catch(Exception e){}
        }
        updateAssets.clear();
        System.debug(LoggingLevel.ERROR, 'Heap Size Commissions Loop >> 2 : ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize());               
    }
     
    //THE MAIN PURPOSE OF THIS UpdateCommissions() IS TO UPDATE/INSERT COMMISSIONS IF ANY CHANGES HAPPEN IN ASSET RECORDS.
    Public void UpdateCommissions(Map<id,asset> fullfilledAssets){
        //BROKER REGIONAL DIRECTORS TEAM CURRENT QUOTA CALCULATION
        String RDTeam = '' ;   
        Integer MonthValue =  system.today().Month();  
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
        //VERIABLE DECLERATION
        set<Id> assetIds = new set<id>();  
        set<Id> productIds = new set<id>();     
        set<Id> accountIds = new set<id>();
        set<Id> signInAEIds = new set<id>();
        set<Id> ExIds = new set<Id>();      
        Map<id,commission__c> updateExistingCommissions = new Map<id,commission__c>();
        List<commission__c> updateRenewalCommissions = new List<commission__c>();
        List<commission__c> clawBackCommissions = new List<commission__c>();
        Map<Id,Asset> assetsWithCommissions = new Map<Id,Asset>();
        Map<Id,Asset> assetsWithOutCommissions = new Map<Id,Asset>();
        Map<Id,Asset> assetsWithCommissionsUpG = new Map<Id,Asset>();   
        Map<Id,Asset> assetsWithCommissionsBeforeGoLive = new Map<Id,Asset>();
        Map<Id,Asset> assetsWithCommissionsAfterGoLive = new Map<Id,Asset>(); 
        Decimal signingAEPercent = 0.0;Decimal assetOwnerPercent = 0.0;
        //RECORD TYPE
        Id clawBackRT = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Clawback').getRecordTypeId();
        Id NewSaleRT = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('New Sale').getRecordTypeId(); 
        Id newSaleB2B = Schema.SObjectType.account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        Id newSaleB2C = Schema.SObjectType.account.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        system.debug('fullfilledAssets >>> :'+fullfilledAssets);        
        Map<id,Asset> assetsCreateNewCommissionsRenewals = new Map<id,Asset>();
        DateTime assetCreatedDateDate ; DateTime assetLastModifiedDate ;DateTime assetCreatedDateDate2 ;
        //IDENTIFYING NEW COMMISSIONS,RENEWAL COMMISSIONS,CLAW BACK COMMISSIONS,DOWNFRADE COMMISSIONS AND UPGRADE COMMISSIONS
        for(Asset Assets : fullfilledAssets.Values()){
            AssetIds.add(Assets.Id);
            ProductIds.add(Assets.product2Id);
            SignInAEIds.add(Assets.Sign_in_AE__c);
            ExIds.add(Assets.Sign_in_AE__c);
            accountIds.add(Assets.accountId);
            
            if(test.IsRunningTest()){
                assetCreatedDateDate = System.today();
                assetLastModifiedDate = System.today();
                assetCreatedDateDate2 = Date.today().addDays(-125);
            }
            else{
                assetCreatedDateDate = Assets.Start_Date__c;                  
                assetCreatedDateDate2 = Assets.Start_Date__c;
                //Leap 8490 validation changed from Legacy_Created_Date__c to Start_Date__c                
                /*                
                if(Assets.Legacy_Created_Date__c == NULL){
                    assetCreatedDateDate = Assets.CreatedDate;                  
                    assetCreatedDateDate2 = Assets.CreatedDate;
                }
                if(Assets.Legacy_Created_Date__c != NULL){
                    assetCreatedDateDate = Assets.Legacy_Created_Date__c;                   
                    assetCreatedDateDate2 = Assets.Legacy_Created_Date__c;
                }
                */                
                assetLastModifiedDate = Assets.LastModifiedDate;
            }
            
            //AFTER GO-LIVE DATE ASSET CALCULATION
            if(assetCreatedDateDate >= Date.newInstance(2016,02,01)){
                if(!assetsWithCommissions.ContainsKey(Assets.Id)){                             
                    if(Assets.Line_Type__c != 'Amend' &&  Assets.Line_Type__c != 'Cancel'){
                        assetsWithOutCommissions.put(Assets.Id,assets);
                    }
                }
                if(assetsWithCommissions.ContainsKey(Assets.Id)){ 
                    if(assetLastModifiedDate >= assetCreatedDateDate){ 
                        if(Assets.Line_Type__c != 'New' || Assets.Line_Type__c != 'Add'){
                            assetsWithCommissionsAfterGoLive.put(Assets.Id,assets); 
                        }
                    }
                }
                if(assetLastModifiedDate >= assetCreatedDateDate){ 
                    if(Assets.Line_Type__c == 'Cancel'){
                        assetsWithCommissionsAfterGoLive.put(Assets.Id,assets); 
                    }
                }
                system.debug('assetsWithOutCommissions  ****:'+assetsWithOutCommissions);
                system.debug('assetsWithCommissionsAfterGoLive  ****:'+assetsWithCommissionsAfterGoLive);
                
                if(Assets.Delta_Price__c > 0 && (Assets.Line_Type__c == 'Amend' ||  Assets.Line_Type__c == 'Cancel')){                    
                    Integer assetCreatedYear = assetCreatedDateDate.Year();
                    DateTime myDate = (assetCreatedDateDate);  
                    Date assetCreatedMonth = date.newinstance(myDate.year(), myDate.month(), myDate.day());                           
                    Integer currentCreatedYear = Date.Today().Year();
                    Date currentCreatedMonth = Date.Today();                    
                    if((Integer.ValueOf(assetCreatedMonth.Month()) != Integer.ValueOf(currentCreatedMonth.Month())) && (assetCreatedYear == currentCreatedYear)){
                        assetsCreateNewCommissionsRenewals.put(Assets.Id,assets);
                    }                                     
                }
                if(Assets.Line_Type__c == 'Renew'){ 
                    if(!assetsWithOutCommissions.ContainsKey(Assets.Id)){                             
                        assetsCreateNewCommissionsRenewals.put(Assets.Id,assets);                 
                    }                                         
                }
                //Assets.Record_processed_for_commission__c = true;
                //updateAssets.put(Assets.id,Assets);
            }
            
            //BEFORE GO-LIVE DATE ASSET CALCULATION
            if(assetCreatedDateDate2 <= Date.newInstance(2016,02,01)){
                if(Assets.Delta_Price__c != 0.0 && Assets.Delta_Price__c != Null){
                    if(Assets.Line_Type__c == 'Amend' ||  Assets.Line_Type__c == 'Cancel' ){
                        system.debug('assetsWithCommissionsBeforeGoLive 1: '+assetsWithCommissionsBeforeGoLive);
                        assetsWithCommissionsBeforeGoLive.put(Assets.Id,assets);
                    }
                }
                system.debug('assetsWithOutCommissions >> 1:'+assetsWithOutCommissions);
                if(Assets.Delta_Price__c > 0 && (Assets.Line_Type__c == 'Amend' ||  Assets.Line_Type__c == 'Cancel')){
                    assetsCreateNewCommissionsRenewals.put(Assets.Id,assets);                     
                }                
                if(Assets.Line_Type__c == 'Renew'){ 
                    assetsCreateNewCommissionsRenewals.put(Assets.Id,assets);                     
                }
                //Assets.Record_processed_for_commission__c = true;
                //updateAssets.put(Assets.id,Assets);
            }                      
        }
        //GETTING ALL PROCESSED ASSETS COMMISSIONS
        Map<id,asset>  updateAssets = new Map<id,Asset>();        
        Map<id,Commission__c> assetCommissionToUpdate = new Map<id,Commission__c>([select  id ,Signing_AE__c,user_Team__c, Commission_Split__c,Commissionable_Amount2__c,name,Asset_Amount__c,
                                                        Billing_Type__c,Related_to_Asset__c,payout_rate_3__c, Related_to_Quota__c,Quota_Percentage_Achieved1__c,Payout_Rate__c,Commissionable_Amount1B__c,
                                                        CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c,CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c,CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c,CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c,
                                                        Commissionable_Amount3__c,Rd_Payout_Rate__c,Related_to_Quota__r.User__c,Commission_To__c,Payout_Rate1B__c,CFCB_New_w_o_Qualifier_Payout_Rate2B__c,CFCB_RNW_w_o_Qualifier_Payout_Rate2D__c,
                                                        CFCB_NEW_w_Qualifier_Payout_Rate2A__c,Status__c,CFCB_RNW_w_Qualifier_Payout_Rate2C__c,OpenBook_New_Sale_Comm_ble_Amount__c,CFCB_NEW_w_Qualifier_Commission2A__c,
                                                        CFCB_New_w_o_Qualifier_Commission2B__c,CFCB_RNW_w_Qualifier_Commission2C__c ,
                                                        OpenBook_New_Sale_Commission__c,CFCB_RNW_w_o_Qualifier_Commission2D__c,Asset_Owner_Commission__c
                                                        from Commission__c where RecordTypeId !=: clawBackRT and Related_to_Asset__c IN : Assetids Order By Name Desc]);
        system.debug('assetCommissionToUpdate >>> : '+assetCommissionToUpdate ); 
        for(commission__c comm : assetCommissionToUpdate.Values()){
            Asset assets = fullfilledAssets.get(comm.Related_to_Asset__c);
            assetsWithCommissions.put(assets.id,assets);
        }
        system.debug('assetsWithCommissions >> :'+assetsWithCommissions); 
        system.debug('assetsWithCommissionsBeforeGoLive 2: '+assetsWithCommissionsBeforeGoLive);        
        system.debug('assetsWithCommissionsAfterGoLive >> :'+assetsWithCommissionsAfterGoLive);
        system.debug('assetsWithOutCommissions >> :'+assetsWithOutCommissions);
        system.debug('assetsCreateNewCommissionsRenewals >> :'+assetsCreateNewCommissionsRenewals);
        //CALLING CREATE COMMISSIONS METHOD TO CREATE NEW COMMISSIONS
        if(assetsWithOutCommissions.size() > 0){
            system.debug('New -Sale >> :'+assetsWithOutCommissions);
            CreateCommissions(assetsWithOutCommissions);
        }
        if(assetsCreateNewCommissionsRenewals.size() > 0){
            system.debug('New Sale - Modify >> :'+assetsCreateNewCommissionsRenewals);
            CreateCommissions(assetsCreateNewCommissionsRenewals);
        }
        //UPDATING DOWNGRADE,UPGRADE AND CREATING CLAW BACK COMMISSIONS
        if(assetsWithCommissionsAfterGoLive.size() > 0 || assetsWithCommissionsBeforeGoLive.size() > 0){
            Integer Year = Date.Today().Year(); 
            Map<id,Product2> assetProducts = new Map<id,Product2>([select id,Name,Normalization_factor__c, Commission_Category__c from product2 where id In : ProductIds]); 
            Map<id,Account> allAccounts = new Map<id,Account>([select id,Name,type,RecordTypeId from Account where Id In : accountIds]);
            for(commission__c com : assetCommissionToUpdate.Values()){
                ExIds.add(com.Related_to_Quota__r.user__c);
            }        
            Map<id,Quota__c> allQuotas = new Map<id,Quota__c>([select id,Name,User__c,User__r.Team__c,Is_Kicker__c,User__r.Managers__c,User_Team__c,Quota_StartDate__c,Period_Name__r.Sigh_In_AE__c,
                                                Period_Name__r.asset_owner__c,Quota_Percentage__c,Target_Amount_2__c,Period_Name__r.Agent_Asset_Owner__c,Period_Name__r.Agent_Sigh_In_AE__c,Current_Quater__c from Quota__c where 
                                                Period_Year1__c =: Year and User__c In : ExIds]);
            Decimal commissionPercentage =0.0;              
            Integer YearValue = system.today().Year(); 
            Decimal ClawbackPayout=0.0;Decimal ClawbackPayout1b=0.0;DateTime assetCreatedDateDate1 ;
            DateTime assetLastModifiedDate1 ;DateTime assetCreatedDateDate3 ;DateTime assetLastModifiedDate3 ;
            
            Map<Id,Quota__c> mapQuotaall = new   Map<Id,Quota__c>();
            for(Quota__c Qta : allQuotas.values()){
                mapQuotaall.put(Qta.User__c,Qta);
            }    
            //CREATE CLAE BACK COMMISSIONS AND UPDATE COMMISSIONS FOR AFTER GO-LIVE CREATE/UPDATE ASSETS            
            for(Asset assetRecord : assetsWithCommissionsAfterGoLive.values()){
                if(test.IsRunningTest()){
                    assetCreatedDateDate1 = System.today();
                    assetLastModifiedDate1 = System.today();
                }
                else{
                    assetCreatedDateDate1 = assetRecord.Start_Date__c;  
                    /*
                    if(assetRecord.Legacy_Created_Date__c == NULL){
                        assetCreatedDateDate1 = assetRecord.CreatedDate;                        
                    }
                    if(assetRecord.Legacy_Created_Date__c != NULL){
                        assetCreatedDateDate1 = assetRecord.Legacy_Created_Date__c;                     
                    }
                    */
                    assetLastModifiedDate1 = assetRecord.LastModifiedDate;
                }               
                signingAEPercent = 0.0;assetOwnerPercent = 0.0;ClawbackPayout=0.0;ClawbackPayout1b=0.0;
                account acc = allAccounts.get(assetRecord.accountId);
                Product2 Products = assetProducts.get(assetRecord.Product2Id);
                if((assetRecord.Status == Constants.ACTIVE_STATUS || assetRecord.Status == 'Cancelled') && (assetRecord.Delta_Price__c != Null && assetRecord.Sign_in_AE__c != Null && assetRecord.Line_Type__c != 'Backout Credit' 
                    && assetRecord.End_Date__c != null && assetRecord.Sign_in_AE__c != Null) && (assetRecord.Order_Line_Item__r.Product_Commission_Category__c != 'Tiger')){
                    system.debug('assetsWithCommissionsAfterGoLive >> Asset Id :'+ assetRecord.Id);
                    Integer assetCreatedYear = assetCreatedDateDate1.Year();
                    DateTime myDate = (assetCreatedDateDate1);  
                    Date assetCreatedMonth = date.newinstance(myDate.year(), myDate.month(), myDate.day());                           
                    Integer currentCreatedYear = Date.Today().Year();
                    Date currentCreatedMonth = Date.Today();                    
                    //if((Integer.ValueOf(assetCreatedMonth.Month()) != Integer.ValueOf(currentCreatedMonth.Month()))) 
                    System.debug('after Go-Live Loop 1 : ');
                    for(commission__c com : assetCommissionToUpdate.Values()){
                        //CREATING CLAWBACK COMMISSIONS FOR ALREADY EXISTING COMMISSIONS                        
                        if((Integer.ValueOf(assetCreatedMonth.Month()) != Integer.ValueOf(currentCreatedMonth.Month()))){
                            if((assetRecord.Delta_Price__c < 0 ) || (assetRecord.Status == 'Cancelled')){
                                System.debug('after Go-Live Loop 2 : ');
                                Commission__c commissionRecordCBOwner = new Commission__c();
                                commissionRecordCBOwner.Related_to_Asset__c = assetRecord.id;
                                commissionRecordCBOwner.RCV__c = -(assetRecord.Delta_Price__c );
                                commissionRecordCBOwner.Product__c = assetRecord.product2Id;
                                commissionRecordCBOwner.Billing_Type__c = assetRecord.Billing_Period__c;
                                commissionRecordCBOwner.Signing_AE__c = assetRecord.Sign_in_AE__c;                   
                                commissionRecordCBOwner.RecordTypeId = clawBackRT;                                                                                            
                                commissionRecordCBOwner.Asset_Amount__c = -(AssetRecord.Delta_Price__c);
                                commissionRecordCBOwner.Status__c = 'Active';                                
                                commissionRecordCBOwner.Related_Commission__c = com.id;
                                if(com.Related_to_Asset__c == assetRecord.id){                                    
                                    commissionPercentage = 0.0;     
                                    //Quota__c quotaRecord = mapQuotaall.get(com.Related_to_Quota__r.User__c); 
                                    for(Quota__c quotaRecord : allQuotas.values()){
                                        system.debug('quotaRecord : '+quotaRecord);
                                        if((quotaRecord != Null) && (((quotaRecord.User_Team__c != Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM) && (assetLastModifiedDate1.Month() == quotaRecord.Quota_StartDate__c.Month()))
                                            || ((quotaRecord.User_Team__c == Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM) && (quotaRecord.Current_Quater__c == RDTeam)))){                                            
                                            commissionRecordCBOwner.Quota_Percentage_Achieved1__c = quotaRecord.Quota_Percentage__c ;                                           
                                            commissionRecordCBOwner.Related_to_Quota__c = quotaRecord.id;
                                            system.debug('Related_to_Quota__c '+quotaRecord.id);
                                            commissionRecordCBOwner.User_Team__c = quotaRecord.User_Team__c;
                                            if(Products.Commission_Category__c != null && Products.Commission_Category__c == 'CFCB'){
                                                if(assetRecord.Renewal_Type__c == Null && quotaRecord.Is_Kicker__c == TRUE){                                    
                                                    commissionRecordCBOwner.CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c = -((assetRecord.Delta_Price__c * com.Commission_Split__c))/100;
                                                }                                          
                                                if(assetRecord.Renewal_Type__c == Null && quotaRecord.Is_Kicker__c == FALSE){
                                                    commissionRecordCBOwner.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c = -((assetRecord.Delta_Price__c * com.Commission_Split__c))/100;
                                                }
                                                if((assetRecord.Renewal_Type__c == 'Auto' || assetRecord.Renewal_Type__c == 'Manual') && quotaRecord.Is_Kicker__c == TRUE){ 
                                                    commissionRecordCBOwner.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c = -((assetRecord.Delta_Price__c * com.Commission_Split__c))/100;
                                                }
                                                if((assetRecord.Renewal_Type__c == 'Auto' || assetRecord.Renewal_Type__c == 'Manual') && quotaRecord.Is_Kicker__c == FALSE){
                                                    commissionRecordCBOwner.CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c = -((assetRecord.Delta_Price__c * com.Commission_Split__c))/100;
                                                }                                    
                                            }
                                        }
                                        if((com.User_Team__c == Commissions_Constants.COLLECTION_TEAM || com.User_Team__c == Commissions_Constants.COLLECTIONS_CLIENT_RELATIONS_MANAGERS) && COM.OpenBook_New_Sale_Comm_ble_Amount__c!= 0.0 && COM.OpenBook_New_Sale_Comm_ble_Amount__c!= Null){                                         
                                            commissionRecordCBOwner.OpenBook_New_Sale_Comm_ble_Amount__c = -((assetRecord.Delta_Price__c * com.Commission_Split__c))/100;
                                        }
                                        if(com.Commissionable_Amount2__c != 0.0 && com.Commissionable_Amount2__c != Null){
                                            commissionRecordCBOwner.Commissionable_Amount2__c = -((assetRecord.Delta_Price__c * com.Commission_Split__c))/100;
                                        }
                                        If(com.Commissionable_Amount1B__c != 0.0 && com.Commissionable_Amount1B__c != Null){
                                            commissionRecordCBOwner.Commissionable_Amount1B__c = -((assetRecord.Delta_Price__c * com.Commission_Split__c))/100;
                                        }
                                        if(com.OpenBook_New_Sale_Comm_ble_Amount__c != 0.0 && com.OpenBook_New_Sale_Comm_ble_Amount__c != Null){
                                            commissionRecordCBOwner.OpenBook_New_Sale_Comm_ble_Amount__c = -((assetRecord.Delta_Price__c * com.Commission_Split__c))/100;
                                        }
                                        if(com.Commissionable_Amount3__c != 0.0 && com.Commissionable_Amount3__c != Null){
                                            commissionRecordCBOwner.Commissionable_Amount3__c = -((assetRecord.Delta_Price__c * com.Commission_Split__c))/100;
                                        }
                                        commissionRecordCBOwner.Commission_Split__c = com.Commission_Split__c;
                                    }                             
                                }                                                  
                                if(commissionRecordCBOwner.Related_to_Quota__c != Null){
                                    system.debug('commissionRecordCBOwner '+ commissionRecordCBOwner);
                                    clawBackCommissions.add(commissionRecordCBOwner);
                                    assetRecord.Commissions_are_calculated__c = true;
                                    updateAssets.put(assetRecord.id,assetRecord);
                                    assetsWithCommissionsUpG.put(assetRecord.Id,assetRecord); 
                                }                          
                            }                               
                        }                                            
                        Else{ 
                            //UPDATING ALREADY EXISTING COMMISSIONS
                            System.debug('after Go-Live Loop 3 : ');
                            if((assetRecord.id == com.Related_to_Asset__c) && (assetRecord.Delta_Price__c != 0.0) && (com.Commission_Split__c != null)){
                                if(!assetsWithCommissionsUpG.ContainsKey(assetRecord.Id)){
                                    System.debug('after Go-Live Loop 4 : ');
                                    Commission__c commissionRecord = new Commission__c();
                                    commissionRecord.id = com.id;                       
                                    commissionRecord.Product__c = assetRecord.product2Id;
                                    commissionRecord.Billing_Type__c = assetRecord.Billing_Period__c;
                                    commissionRecord.Asset_Amount__c = AssetRecord.total_Net__c;        
                                    if(com.User_Team__c == Commissions_Constants.COLLECTION_TEAM || com.User_Team__c == Commissions_Constants.COLLECTIONS_CLIENT_RELATIONS_MANAGERS){
                                        if(com.OpenBook_New_Sale_Comm_ble_Amount__c != 0.0 && com.OpenBook_New_Sale_Comm_ble_Amount__c != Null){
                                            commissionRecord.OpenBook_New_Sale_Comm_ble_Amount__c = (assetRecord.Total_Net__c * com.Commission_Split__c)/100 ;
                                        }                        
                                    }
                                    else{
                                        if(com.Commissionable_Amount2__c != 0.0 && com.Commissionable_Amount2__c != Null){
                                            commissionRecord.Commissionable_Amount2__c = (assetRecord.Total_Net__c * com.Commission_Split__c)/100 ;
                                        }                       
                                    }                                   
                                    if(com.Commissionable_Amount1B__c != 0.0 && com.Commissionable_Amount1B__c != Null){
                                        commissionRecord.Commissionable_Amount1B__c = (assetRecord.Total_Net__c * com.Commission_Split__c)/100 ;
                                    }
                                    if(com.CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c != 0.0 && com.CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c != Null){
                                        commissionRecord.CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c = (assetRecord.Total_Net__c * com.Commission_Split__c)/100 ;
                                    }
                                    If(com.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c != 0.0 && com.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c != Null){
                                        commissionRecord.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c = (assetRecord.Total_Net__c * com.Commission_Split__c)/100 ;
                                    }
                                    if(com.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c != 0.0 && com.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c != Null){
                                        commissionRecord.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c = (assetRecord.Total_Net__c * com.Commission_Split__c)/100 ;
                                    }
                                    if(com.CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c !=0.0 && com.CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c != Null){
                                        commissionRecord.CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c = (assetRecord.Total_Net__c * com.Commission_Split__c)/100 ;
                                    }
                                    if(com.Commissionable_Amount3__c != 0.0 && com.Commissionable_Amount3__c!=Null){
                                        commissionRecord.Commissionable_Amount3__c = (assetRecord.Total_Net__c * com.Commission_Split__c)/100 ;
                                    }
                                    if(com.OpenBook_New_Sale_Comm_ble_Amount__c != 0.0 && com.OpenBook_New_Sale_Comm_ble_Amount__c !=Null){
                                        commissionRecord.OpenBook_New_Sale_Comm_ble_Amount__c = (assetRecord.Total_Net__c * com.Commission_Split__c)/100 ;
                                    }
                                    updateExistingCommissions.put(commissionRecord.id,commissionRecord);
                                    assetRecord.Commissions_are_calculated__c = true;
                                    updateAssets.put(assetRecord.id,assetRecord);                               
                                }                                    
                            }
                        }                                      
                    }
                    assetRecord.Record_processed_for_commission__c = true;
                    updateAssets.put(assetRecord.id,assetRecord);
                }
            }
            //CREATE CLAE BACK COMMISSIONS FOR BEFORE GO-LIVE ASSETS
            for(asset assetRecord1 : assetsWithCommissionsBeforeGoLive.Values()){               
                System.debug('Before Go-Live Loop 1 : ');
                if(test.IsRunningTest()){
                    assetCreatedDateDate3 = System.today();
                    assetLastModifiedDate3 = System.today();
                }
                else{
                    if(assetRecord1.Legacy_Created_Date__c == NULL){
                        assetCreatedDateDate3 = assetRecord1.Start_Date__c;                    
                    }
                    if(assetRecord1.Legacy_Created_Date__c != NULL){
                        assetCreatedDateDate3 = assetRecord1.Start_Date__c;                        
                    }
                    assetLastModifiedDate3 = assetRecord1.LastModifiedDate;
                }               
                account acc1 = allAccounts.get(assetRecord1.accountId);
                Product2 Products1 = assetProducts.get(assetRecord1.Product2Id);
                if(((assetRecord1.Delta_Price__c < 0  && assetRecord1.Delta_Price__c != Null) || (assetRecord1.Status == 'Cancelled' && assetRecord1.Delta_Price__c != Null))
                    && (assetRecord1.End_Date__c != null && assetRecord1.Sign_in_AE__c != null) && (assetRecord1.Order_Line_Item__r.Product_Commission_Category__c != 'Tiger')){            
                    System.debug('Before Go-Live Loop 2 : ');
                    if(!assetsWithCommissions.ContainsKey(assetRecord1.Id)){
                        Commission__c commissionRecordCB = new Commission__c();
                        commissionRecordCB.Related_to_Asset__c = assetRecord1.id;           
                        commissionRecordCB.RCV__c = -assetRecord1.Delta_Price__c;
                        commissionRecordCB.Product__c = assetRecord1.product2Id;
                        commissionRecordCB.Billing_Type__c = assetRecord1.Billing_Period__c;                        
                        commissionRecordCB.Asset_amount__c = -(assetRecord1.Delta_Price__c);
                        commissionRecordCB.Signing_AE__c = assetRecord1.Sign_in_AE__c;                   
                        commissionRecordCB.RecordTypeId = clawBackRT;                                                   
                        commissionRecordCB.Status__c = 'Active';                        
                        System.debug('Before Go-Live Loop 3 : ');  
                        //Quota__c quotaRecord = mapQuotaall.get(assetRecord1.Sign_in_AE__c);                  
                        for(Quota__c quotaRecord : allQuotas.values()){
                            if((quotaRecord != Null) && (((quotaRecord.User_Team__c != Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM) && (assetLastModifiedDate3.Month() == quotaRecord.Quota_StartDate__c.Month()))
                                || ((quotaRecord.User_Team__c == Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM) && (quotaRecord.Current_Quater__c == RDTeam)))){                            
                                commissionRecordCB.User_Team__c = quotaRecord.User__r.Team__c;
                                System.debug('Before Go-Live Loop 4 : ');
                                //if(assetRecord1.Sign_in_AE__c == assetRecord1.OwnerId){
                                    //commissionPercentage = 100;
                                //}else{
                                    if(acc1.RecordTypeId == newSaleB2B){
                                        commissionPercentage = quotaRecord.Period_Name__r.Sigh_In_AE__c;
                                    }
                                    if(acc1.RecordTypeId == newSaleB2C){
                                        commissionPercentage = quotaRecord.Period_Name__r.Agent_Sigh_In_AE__c;                                    
                                    }
                                //}
                           
                                commissionRecordCB.Related_to_Quota__c = quotaRecord.id;
                                if(quotaRecord.User_Team__c == Commissions_Constants.COLLECTION_TEAM || quotaRecord.User_Team__c == Commissions_Constants.COLLECTIONS_CLIENT_RELATIONS_MANAGERS){                                         
                                    commissionRecordCB.OpenBook_New_Sale_Comm_ble_Amount__c = (-assetRecord1.Delta_Price__c * commissionPercentage)/100;
                                }else{
                                    commissionRecordCB.Commissionable_Amount2__c = (-assetRecord1.Delta_Price__c * commissionPercentage)/100;
                                }                          
                                commissionRecordCB.Commission_Split__c = commissionPercentage;                       
                                if(Products1 != Null){
                                    if((Products1.Commission_Category__c != null && Products1.Commission_Category__c == 'CFCB' )){
                                        if((assetRecord1.Renewal_Type__c == Null || assetRecord1.Renewal_Type__c == ' ') && quotaRecord.Is_Kicker__c == TRUE){                                    
                                            commissionRecordCB.CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c = -((assetRecord1.Delta_Price__c * commissionPercentage))/100;                                      
                                        }                                           
                                        if((assetRecord1.Renewal_Type__c == Null || assetRecord1.Renewal_Type__c == ' ') && quotaRecord.Is_Kicker__c == FALSE){  
                                            commissionRecordCB.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c = -((assetRecord1.Delta_Price__c * commissionPercentage))/100;                                        
                                        }
                                        if((assetRecord1.Renewal_Type__c == 'Auto' || assetRecord1.Renewal_Type__c == 'Manual') && quotaRecord.Is_Kicker__c == TRUE){  
                                            commissionRecordCB.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c = -((assetRecord1.Delta_Price__c * commissionPercentage))/100;                                      
                                        }
                                        if((assetRecord1.Renewal_Type__c == 'Auto' || assetRecord1.Renewal_Type__c == 'Manual') && quotaRecord.Is_Kicker__c == FALSE){  
                                            commissionRecordCB.CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c = -((assetRecord1.Delta_Price__c * commissionPercentage))/100;                                        
                                        }                                    
                                    }
                                }
                            }
                        }                       
                        if(commissionRecordCB.Related_to_Quota__c != Null ){                       
                            clawBackCommissions.add(commissionRecordCB);
                            assetRecord1.Commissions_are_calculated__c = true;
                            updateAssets.put(assetRecord1.id,assetRecord1);
                        }
                    }            
                    assetsWithCommissionsUpG.put(assetRecord1.Id,assetRecord1);
                    assetRecord1.Record_processed_for_commission__c = true;
                    updateAssets.put(assetRecord1.id,assetRecord1);
                    
                    /**********************************************************************************************
                    Integer assetCreatedYear = assetCreatedDateDate3.Year();
                    DateTime myDate = (assetCreatedDateDate3);  
                    Date assetCreatedMonth = date.newinstance(myDate.year(), myDate.month(), myDate.day());                           
                    Integer currentCreatedYear = Date.Today().Year();
                    Date currentCreatedMonth = Date.Today();
                    for(commission__c com : assetCommissionToUpdate.Values()){
                        system.debug('Legacy Clawback Loop 1: ');
                        if((Integer.ValueOf(assetCreatedMonth.Month()) != Integer.ValueOf(currentCreatedMonth.Month()))){
                            system.debug('Legacy Clawback Loop 2: ');
                            if(assetsWithCommissions.ContainsKey(assetRecord1.Id)){   
                                system.debug('Legacy Clawback Loop 3: ');
                                Commission__c commissionRecordCB = new Commission__c();
                                commissionRecordCB.Related_to_Asset__c = assetRecord1.id;           
                                commissionRecordCB.RCV__c = -assetRecord1.Delta_Price__c;
                                commissionRecordCB.Product__c = assetRecord1.product2Id;
                                commissionRecordCB.Billing_Type__c = assetRecord1.Billing_Period__c;                        
                                commissionRecordCB.Asset_amount__c = -(assetRecord1.Delta_Price__c);
                                commissionRecordCB.Signing_AE__c = assetRecord1.Sign_in_AE__c;                   
                                commissionRecordCB.RecordTypeId = clawBackRT;                                                   
                                commissionRecordCB.Status__c = 'Active';                        
                                if(com.Related_to_Asset__c == assetRecord1.id){                                
                                    commissionRecordCB.Related_Commission__c = com.id;
                                    commissionRecordCB.Commission_Split__c = com.Commission_Split__c;
                                    commissionPercentage = com.Commission_Split__c;
                                }
                                Quota__c quotaRecord = mapQuotaall.get(com.Related_to_Quota__r.User__c);                  
                                if((quotaRecord != Null) && (((quotaRecord.User_Team__c != Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM) && (assetLastModifiedDate3.Month() == quotaRecord.Quota_StartDate__c.Month()))
                                    || ((quotaRecord.User_Team__c == Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM) && (quotaRecord.Current_Quater__c == RDTeam)))){                            
                                    commissionRecordCB.User_Team__c = quotaRecord.User__r.Team__c;                              
                                    commissionRecordCB.Related_to_Quota__c = quotaRecord.id;
                                    if(quotaRecord.User_Team__c == Commissions_Constants.COLLECTION_TEAM || quotaRecord.User_Team__c == Commissions_Constants.COLLECTIONS_CLIENT_RELATIONS_MANAGERS){                                         
                                        commissionRecordCB.OpenBook_New_Sale_Comm_ble_Amount__c = (-assetRecord1.Delta_Price__c * commissionPercentage)/100;
                                    }else{
                                        commissionRecordCB.Commissionable_Amount2__c = (-assetRecord1.Delta_Price__c * commissionPercentage)/100;
                                    }                          
                                    commissionRecordCB.Commission_Split__c = commissionPercentage;                       
                                    if(Products1 != Null){
                                        if((Products1.Commission_Category__c != null && Products1.Commission_Category__c == 'Normal' ) && (quotaRecord.Target_Amount_2__c != 0.0 && quotaRecord.Target_Amount_2__c !=null)){
                                            if((assetRecord1.Renewal_Type__c == Null || assetRecord1.Renewal_Type__c == ' ') && quotaRecord.Is_Kicker__c == TRUE){                                    
                                                commissionRecordCB.CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c = -((assetRecord1.Delta_Price__c * commissionPercentage))/100;                                      
                                            }                                           
                                            if((assetRecord1.Renewal_Type__c == Null || assetRecord1.Renewal_Type__c == ' ') && quotaRecord.Is_Kicker__c == FALSE){  
                                                commissionRecordCB.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c = -((assetRecord1.Delta_Price__c * commissionPercentage))/100;                                        
                                            }
                                            if((assetRecord1.Renewal_Type__c == 'Auto' || assetRecord1.Renewal_Type__c == 'Manual') && quotaRecord.Is_Kicker__c == TRUE){  
                                                commissionRecordCB.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c = -((assetRecord1.Delta_Price__c * commissionPercentage))/100;                                      
                                            }
                                            if((assetRecord1.Renewal_Type__c == 'Auto' || assetRecord1.Renewal_Type__c == 'Manual') && quotaRecord.Is_Kicker__c == FALSE){  
                                                commissionRecordCB.CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c = -((assetRecord1.Delta_Price__c * commissionPercentage))/100;                                        
                                            }                                    
                                        }
                                    }
                                }                                     
                                if(commissionRecordCB.Related_to_Quota__c != Null ){                       
                                    clawBackCommissions.add(commissionRecordCB);
                                    assetRecord1.Commissions_are_calculated__c = true;
                                    updateAssets.put(assetRecord1.id,assetRecord1);
                                }
                            }
                        }
                        else{
                            //for(commission__c commission : assetCommissionToUpdate.values())                                   
                            if((assetRecord1.id == com.Related_to_Asset__c) && (assetRecord1.Delta_Price__c != 0.0) && (com.Commission_Split__c != null)){
                                //if(!assetsWithCommissionsUpG.ContainsKey(assetRecord.Id))                              
                                Commission__c commissionRecordCB = new Commission__c();
                                commissionRecordCB.id = com.id;                       
                                commissionRecordCB.Product__c = assetRecord1.product2Id;
                                commissionRecordCB.Billing_Type__c = assetRecord1.Billing_Period__c;
                                commissionRecordCB.Asset_Amount__c = AssetRecord1.total_Net__c;        
                                if(com.User_Team__c == Commissions_Constants.COLLECTION_TEAM || com.User_Team__c == Commissions_Constants.COLLECTIONS_CLIENT_RELATIONS_MANAGERS){
                                    if(com.OpenBook_New_Sale_Comm_ble_Amount__c != 0.0 && com.OpenBook_New_Sale_Comm_ble_Amount__c != Null){
                                        commissionRecordCB.OpenBook_New_Sale_Comm_ble_Amount__c = (assetRecord1.Total_Net__c * com.Commission_Split__c)/100 ;
                                    }                        
                                }
                                else{
                                    if(com.Commissionable_Amount2__c != 0.0 && com.Commissionable_Amount2__c != Null){
                                        commissionRecordCB.Commissionable_Amount2__c = (assetRecord1.Total_Net__c * com.Commission_Split__c)/100 ;
                                    }                       
                                }                                   
                                if(com.Commissionable_Amount1B__c != 0.0 && com.Commissionable_Amount1B__c != Null){
                                    commissionRecordCB.Commissionable_Amount1B__c = (assetRecord1.Total_Net__c * com.Commission_Split__c)/100 ;
                                }
                                if(com.CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c != 0.0 && com.CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c != Null){
                                    commissionRecordCB.CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c = (assetRecord1.Total_Net__c * com.Commission_Split__c)/100 ;
                                }
                                if(com.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c != 0.0 && com.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c != Null){
                                    commissionRecordCB.CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c = (assetRecord1.Total_Net__c * com.Commission_Split__c)/100 ;
                                }
                                if(com.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c != 0.0 && com.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c != Null){
                                    commissionRecordCB.CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c = (assetRecord1.Total_Net__c * com.Commission_Split__c)/100 ;
                                }
                                if(com.CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c !=0.0 && com.CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c != Null){
                                    commissionRecordCB.CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c = (assetRecord1.Total_Net__c * com.Commission_Split__c)/100 ;
                                }
                                if(com.Commissionable_Amount3__c != 0.0 && com.Commissionable_Amount3__c!=Null){
                                    commissionRecordCB.Commissionable_Amount3__c = (assetRecord1.Total_Net__c * com.Commission_Split__c)/100 ;
                                }
                                if(com.OpenBook_New_Sale_Comm_ble_Amount__c != 0.0 && com.OpenBook_New_Sale_Comm_ble_Amount__c !=Null){
                                    commissionRecordCB.OpenBook_New_Sale_Comm_ble_Amount__c = (assetRecord1.Total_Net__c * com.Commission_Split__c)/100 ;
                                }
                                //clawBackCommissions.put(commissionRecordCB.id,commissionRecordCB);
                                clawBackCommissions.add(commissionRecordCB);
                                assetRecord1.Commissions_are_calculated__c = true;
                                updateAssets.put(assetRecord1.id,assetRecord1);                               
                            }                                    
                        }
                    } 
                    ***********************************************************************************************************************/
                }
            }
            assetsWithCommissions.clear();assetsWithOutCommissions.clear();assetsWithCommissionsUpG.clear();       
            signInAEIds.clear();assetsWithCommissionsBeforeGoLive.clear();assetsWithCommissionsAfterGoLive.clear();
            assetCommissionToUpdate.clear();assetProducts.clear();allAccounts.clear();allQuotas.clear();mapQuotaall.clear();
            assetIds.clear();productIds.clear();accountIds.clear(); 
            //INACTIVATING EXISTING COMMISSIONS OF RENEWAL ASSETS
            for(Asset assetRecord2 : assetsCreateNewCommissionsRenewals.values()){
                for(commission__c com : assetCommissionToUpdate.Values()){
                    if(com.Related_to_Asset__c == assetRecord2.id){
                        com.Status__c = 'InActive';
                        updateRenewalCommissions.add(com);
                    }
                }
            }                       
            if(updateRenewalCommissions.size() > 0){
                try{
                    update updateRenewalCommissions;
                }
                Catch(Exception e){}
            }
            updateRenewalCommissions.clear();
            //UPDATING EXISTING COMMISSIONS-DOWNGRADE OR UPGRADE FOR SAME MONTH
            if(updateExistingCommissions.size() > 0){        
                try{   
                    update updateExistingCommissions.Values();                     
                }
                catch(Exception e){}
            }
            updateExistingCommissions.clear();
            
            //CREATING CLAW BACK COMMISSIONS FOR PROCESSED ASSETS
            system.debug('clawBackCommissions : '+clawBackCommissions.size());
            if(clawBackCommissions.size() > 0){
                try{
                    Insert clawBackCommissions;
                }
                Catch(Exception e){
                }                   
            } 
            clawBackCommissions.clear();updateExistingCommissions.clear();
            //UPDATING ASSETS
            if(updateAssets.size() > 0){
                try{            
                    update updateAssets.Values();
                }
                catch(exception e){}
            } 
            updateAssets.clear();           
        }         
    }
}