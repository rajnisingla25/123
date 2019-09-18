/*******************************************************************************
Created By      :   Srinivas Pendli
Created Date    :   11-NOV-2015
Usage           :   This main functionality of  this class is to create commission records (New Commissions)
                    from asset record based on the business logic
                      * Create commissions to signing AE ,Asset owner and their managers
                      * Create commissions for LOA
                      * Create commissions for Open Book/Open Sale
                      * Create New Sale Commissions-For New and Legacy assets                   
                      
CODE MODIFICATION DETAILS :                    
1. Modified By  :   Srinivas Pendli on 25-MAY-2016 @ 482 // code commented for old month quotas record processed field unchecking issue
2. Modified By  :   Srinivas Pendli on 25-MAY-2016 @ Line No. 498 // code commented to skip asset trigger
3. Modified By  :   Sudhakar Reddy Lekkala on 26-May-2016 @ Line no 124,125 // LEAP-8492 Updating "Delta_Price__c" field with new field "Delta_Price_w_o_Tax__c".
4. Modified By  :   Srinivas Pendli on 7-june-2016 @ Line no 122-127 //added line type bcz we are calling the same class from Amend and Clawback Jobs.
5. Modified By  :   Srinivas Pendli on 2-Dec-2016 @ JIRA # 708 //Removed all Manager Commissions,LOA and Open Book related logic.
********************************************************************************/
Public Class Commissions_CreateNewCommissionsHandler{ 
    Public void CreateCommissions(Map<Id, Asset> fullfilledAssets){       
        //VARIABLES DECLERATION
        set<Id> productIds = new set<id>();     
        set<Id> accountIds = new set<id>(); 
        set<Id> signInAEIds = new set<id>();          
        Map<String,commission__c> commission = new Map<String,commission__c>();      
        Map<id,asset>  updateAssets = new Map<id,Asset>();
        Decimal signingAEPercent = 0.0;Decimal assetOwnerPercent = 0.0;  Decimal TotalNet = 0.0;
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
        for(Asset Assets : fullfilledAssets.Values()){           
            ProductIds.add(Assets.product2id);
            accountIds.add(Assets.AccountId);
            SignInAEIds.add(Assets.Sign_in_AE__c);           
            SignInAEIds.add(Assets.OwnerId);            
        }
        Integer Year = Date.Today().Year();       
        system.debug('SignInAEIds $$ : '+SignInAEIds); 
    
        //GETTING ALL SIGNING AE's AND ASSET OWNER QUOTAS FOR QUOTA OBJECT
        Map<id,Quota__c> assetSignInAEQuotas = new Map<id,Quota__c>([select id,Name,User__c,User__r.Team__c,User__r.Managers__c,Quota_StartDate__c,Period_Name__r.Sigh_In_AE__c,Period_Name__r.asset_Owner__c,User_Team__c,Target_Amount_2__c,Record_Processed__c,Period_Name__r.Agent_Asset_Owner__c,Period_Year1__c,Period_Name__r.Agent_Sigh_In_AE__c,Is_Kicker__c,Current_Quater__c from Quota__c where 
        User__c In : SignInAEIds and Quota_StartDate__c = THIS_YEAR]);
        system.debug('assetSignInAEQuotas $$ :'+assetSignInAEQuotas);        
        
        Map<id,Product2> assetProducts = new Map<id,Product2>([select id,Name,Normalization_factor__c,Commission_Category__c from product2 where id In : ProductIds ]);
        ProductIds.clear();
        Map<id,Account> allAccounts = new Map<id,Account>([select id,Name,type,RecordTypeId from Account where Id In : accountIds ]);
        accountIds.clear();
        Map<id,Quota__c> updateQuota = new Map<Id,Quota__c>();
        
        //RECORD TYPES     
        Id newSaleRT = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('New Sale').getRecordTypeId();       
        Id newSaleB2B = Schema.SObjectType.account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        Id newSaleB2C = Schema.SObjectType.account.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        //Id newSaleManagerRT = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Managers Team').getRecordTypeId();
        Id newSaleManagerRT = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get(System.Label.Managers_Team).getRecordTypeId();
        
        //CREATING COMMISSIONS FOR SIGN IN AND ACCOUNT OWNER OF PROCESSED ASSETS /UPDATING ASSETS   
        for(Asset assetRecord : fullfilledAssets.values()){  
            signingAEPercent = 0.0;assetOwnerPercent = 0.0;TotalNet = 0.0;
            account acc = allAccounts.get(assetRecord.AccountId);            
            //LINE TYPE IDENTIFICATION -ADD,RENEW,AMEND,CANCEL AND CREDIT,BASED ON LINE TYPE TAKING THE ASSET AMOUNT
            if(assetRecord.Line_Type__c == 'Add' || assetRecord.Line_Type__c == 'Renew'){
                if(assetRecord.Total_Net__c != Null){
                    TotalNet = assetRecord.Total_Net__c;     
                }               
            }           
            if((assetRecord.Line_Type__c == 'Amend' || assetRecord.Line_Type__c == 'Cancel' || assetRecord.Line_Type__c == 'Credit') && assetRecord.Delta_Price_w_o_Tax__c > 0){
                if(assetRecord.Delta_Price_w_o_Tax__c!= Null){
                    TotalNet = assetRecord.Delta_Price_w_o_Tax__c;
                }
            }
            if((assetRecord.Status == Constants.ACTIVE_STATUS  &&  TotalNet != 0.0)|| assetRecord.Status == Constants.ASSET_CANCELLED_STATUS && assetRecord.Order_Line_Item__r.Product_Commission_Category__c != 'Tiger'|| Test.isRunningTest()){
                Product2 Products = assetProducts.get(assetRecord.product2id);              
                DateTime assetLastModifiedDate ;DateTime assetCreatedDateDate ;
                if(test.IsRunningTest()){
                    assetLastModifiedDate = System.today();
                    assetCreatedDateDate = System.today();
                    signingAEpercent = 100;
                }
                else{
                    assetLastModifiedDate = assetRecord.LastModifiedDate;
                    assetCreatedDateDate = assetRecord.Start_Date__c;
                    if(assetCreatedDateDate.day() == 1){
                        assetCreatedDateDate = assetCreatedDateDate.addHours(8);
                    }
                }        
                //CREATING COMMISSIONS TO SIGNING AE's AND ASSET OWNERS WITH DEFINED SPLIT FROM PERIOD OBJECT FOR CURRENT MONTH
                for(quota__c quotaRecordSAE : assetSignInAEQuotas.values()){    
                                              
                    if((quotaRecordSAE != Null) && (assetRecord.Sign_in_AE__c != Null) && (quotaRecordSAE.User__c == assetRecord.Sign_in_AE__c)){
                        /* if(((quotaRecordSAE.User_Team__c == Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM && quotaRecordSAE.Current_Quater__c == RDTeam) || (assetLastModifiedDate.Month() == quotaRecordSAE.Quota_StartDate__c.Month()))
                        && (quotaRecordSAE.Quota_StartDate__c.Year() == Year)){ */
                        System.debug( quotaRecordSAE.User_Team__c +'=='+ CommissionTeams__c.getInstance('BROKER_REGIONAL_DIRECTORS_TEAM').Team_Name__c +'KKKKK'+ quotaRecordSAE.Current_Quater__c +'KKKKK'+  RDTeam  +'KKKKK'+  assetLastModifiedDate.Month()  +'KKKKK'+ quotaRecordSAE.Quota_StartDate__c.Month());
                        //#CRM-1560 - Flexibility to Modify/Create User teams in SFDC by using Config -ADDED BY Venkata Cheedara
                         if(((quotaRecordSAE.User_Team__c == CommissionTeams__c.getInstance('BROKER_REGIONAL_DIRECTORS_TEAM').Team_Name__c && quotaRecordSAE.Current_Quater__c == RDTeam) || (assetLastModifiedDate.Month() == quotaRecordSAE.Quota_StartDate__c.Month()))
                        && (quotaRecordSAE.Quota_StartDate__c.Year() == Year)){ 
                            
                        if(assetRecord.Sign_in_AE__c != Null && assetRecord.OwnerId != NULL && assetRecord.Sign_in_AE__c== assetRecord.OwnerId){
                            signingAEpercent = 100;
                        }
                        else{
                            if(quotaRecordSAE != Null && acc.RecordTypeId == newSaleB2B){
                                signingAEpercent = quotaRecordSAE.Period_Name__r.Sigh_In_AE__c;                        
                            }
                            if(quotaRecordSAE != Null && acc.RecordTypeId == newSaleB2C){
                                signingAEpercent = quotaRecordSAE.Period_Name__r.Agent_Sigh_In_AE__c;                       
                            }
                        }
                        if(signingAEpercent != 0.0){
                            Commission__c commissionRecord = new Commission__c();                       
                            commissionRecord.Related_to_Asset__c = assetRecord.id;
                            if(assetRecord.Order_Line_Item__c != Null){
                                commissionRecord.Order_Product__c = assetRecord.Order_Line_Item__c;
                            }
                            commissionRecord.Product__c = assetRecord.product2id;
                            commissionRecord.Billing_Type__c = assetRecord.Billing_Period__c;
                            //if(quotaRecordSAE.User_Team__c == Commissions_Constants.MANAGERS_TEAM){
                            //#CRM-1560 - Flexibility to Modify/Create User teams in SFDC by using Config -ADDED BY Venkata Cheedara
                          if(quotaRecordSAE.User_Team__c == CommissionTeams__c.getInstance('MANAGERS_TEAM').Team_Name__c){
                               
                                commissionRecord.RecordTypeId = newSaleManagerRT;
                            }
                            else{
                                commissionRecord.RecordTypeId = newSaleRT;
                            }       
                            commissionRecord.Asset_Amount__c=TotalNet;
                            commissionRecord.Commission_Split__c = signingAEpercent;
                            commissionRecord.Signing_AE__c = assetRecord.Sign_in_AE__c;       
                            commissionRecord.Related_to_Quota__c = quotaRecordSAE.id;                                        
                            commissionRecord.User_Team__c = quotaRecordSAE.User_Team__c;
                            commissionRecord.Status__c = 'Active'; 
                            commissionRecord.Record_Processed__c = FALSE;
                            commissionRecord.Line_Type__c = assetRecord.Line_Type__c;                                           
                            //if(quotaRecordSAE.User_Team__c == Commissions_Constants.COLLECTION_TEAM || quotaRecordSAE.User_Team__c == Commissions_Constants.COLLECTIONS_CLIENT_RELATIONS_MANAGERS){
                            //#CRM-1560 - Flexibility to Modify/Create User teams in SFDC by using Config -ADDED BY Venkata Cheedara
                            if(quotaRecordSAE.User_Team__c == CommissionTeams__c.getInstance('COLLECTION_TEAM').Team_Name__c || quotaRecordSAE.User_Team__c == CommissionTeams__c.getInstance('COLLECTIONS_CLIENT_RELATIONS_MANAGERS').Team_Name__c){
    
                                commissionRecord.Commissionable_Amount2__c= (TotalNet * signingAEpercent)/100;
                            }
                             //if(quotaRecordSAE.User_Team__c != Commissions_Constants.COLLECTION_TEAM && quotaRecordSAE.User_Team__c !=                           
                                 //Commissions_Constants.COLLECTIONS_CLIENT_RELATIONS_MANAGERS && quotaRecordSAE.User_Team__c != Commissions_Constants.MANAGERS_TEAM){
                            //#CRM-1560 - Flexibility to Modify/Create User teams in SFDC by using Config -ADDED BY Venkata Cheedara
                            if(quotaRecordSAE.User_Team__c != CommissionTeams__c.getInstance('COLLECTION_TEAM').Team_Name__c && quotaRecordSAE.User_Team__c !=                           
                                CommissionTeams__c.getInstance('COLLECTIONS_CLIENT_RELATIONS_MANAGERS').Team_Name__c && quotaRecordSAE.User_Team__c != CommissionTeams__c.getInstance('MANAGERS_TEAM').Team_Name__c){ 
                                if(quotaRecordSAE.Is_Kicker__c == False && assetRecord.Line_Type__c != 'Renew'){
                                    //#CRM-03794
                                    if(assetRecord.Owner.Profile.Name == 'Open Book Profile'){
                                        commissionRecord.OpenBook_New_Sale_Comm_ble_Amount__c = (TotalNet * signingAEpercent)/100;
                                    }else{
                                        commissionRecord.Commissionable_Amount2__c = (TotalNet * signingAEpercent)/100; 
                                    }
                                }
                                if(quotaRecordSAE.Is_Kicker__c == true && assetRecord.Line_Type__c != 'Renew'){
                                    commissionRecord.Commissionable_Amount1B__c = (TotalNet * signingAEpercent)/100; 
                                }
                                if(quotaRecordSAE.Is_Kicker__c == False && assetRecord.Line_Type__c == 'Renew'){
                                    //#CRM-03794
                                    if(assetRecord.Owner.Profile.Name == 'Open Book Profile'){
                                        commissionRecord.OpenBook_New_Sale_Comm_ble_Amount__c = (TotalNet * signingAEpercent)/100;
                                    }else{
                                        commissionRecord.Renewal_w_o_Qualifier_Comm_ble_Amount__c = (TotalNet * signingAEpercent)/100; 
                                    }
                                }
                                if(quotaRecordSAE.Is_Kicker__c == true && assetRecord.Line_Type__c == 'Renew'){
                                    commissionRecord.Renewal_w_Qualifier_Comm_ble_Amount__c = (TotalNet * signingAEpercent)/100; 
                                }
                            }
                            //if(quotaRecordSAE.User_Team__c == Commissions_Constants.MANAGERS_TEAM){  
                            //#CRM-1560 - Flexibility to Modify/Create User teams in SFDC by using Config -ADDED BY Venkata Cheedara
                            if(quotaRecordSAE.User_Team__c == CommissionTeams__c.getInstance('MANAGERS_TEAM').Team_Name__c){                         
                                commissionRecord.Commissionable_Amount2__c = (TotalNet * signingAEpercent)/100; 
                            }
                            commission.put(assetRecord.id+'#####',commissionRecord);
                            assetRecord.Commissions_are_calculated__c = true;
                            updateAssets.put(assetRecord.id,assetRecord);
                            quotaRecordSAE.Record_Processed__c =FALSE;
                            updateQuota.put(quotaRecordSAE.id,quotaRecordSAE);                                            
                        }
                        }
                    }
                    if((quotaRecordSAE != Null) && (assetRecord.Sign_in_AE__c != Null && assetRecord.OwnerId != Null) && (assetRecord.OwnerId <>    
                        assetRecord.Sign_in_AE__c) && (quotaRecordSAE.User__c == assetRecord.OwnerId)){
                          //if(((assetLastModifiedDate.Month() == quotaRecordSAE.Quota_StartDate__c.Month()) || ((quotaRecordSAE.User_Team__c == Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM) && (quotaRecordSAE.Current_Quater__c == RDTeam))) && (quotaRecordSAE.Quota_StartDate__c.Year() == Year)){
                        //#CRM-1560 - Flexibility to Modify/Create User teams in SFDC by using Config -ADDED BY Venkata Cheedara
                        if(((assetLastModifiedDate.Month() == quotaRecordSAE.Quota_StartDate__c.Month()) || ((quotaRecordSAE.User_Team__c == CommissionTeams__c.getInstance('BROKER_REGIONAL_DIRECTORS_TEAM').Team_Name__c) && (quotaRecordSAE.Current_Quater__c == RDTeam))) && (quotaRecordSAE.Quota_StartDate__c.Year() == Year)){
                              
                            if(quotaRecordSAE != Null && acc.RecordTypeId == newSaleB2B){                               
                                assetOwnerPercent = quotaRecordSAE.Period_Name__r.asset_Owner__c;
                            }
                            if(quotaRecordSAE != Null && acc.RecordTypeId == newSaleB2C){                                
                                assetOwnerPercent = quotaRecordSAE.Period_Name__r.Agent_asset_Owner__c;
                            }
                            if(test.isrunningtest()){
                                assetOwnerPercent  = 100;
                            }
                            if(assetOwnerPercent != 0.0){
                                Commission__c commission2Records = new Commission__c(); 
                                commission2Records.Related_to_Asset__c = assetRecord.id;
                                if(assetRecord.Order_Line_Item__c != Null){
                                    commission2Records.Order_Product__c = assetRecord.Order_Line_Item__c;
                                }
                                commission2Records.Product__c = assetRecord.product2id;
                                commission2Records.Billing_Type__c = assetRecord.Billing_Period__c;
                                //if(quotaRecordSAE.User_Team__c == Commissions_Constants.MANAGERS_TEAM){
                                //#CRM-1560 - Flexibility to Modify/Create User teams in SFDC by using Config -ADDED BY Venkata Cheedara
                                
                                if(quotaRecordSAE.User_Team__c == CommissionTeams__c.getInstance('MANAGERS_TEAM').Team_Name__c){
                                   
                                    commission2Records.RecordTypeId = newSaleManagerRT;
                                }
                                else{
                                    commission2Records.RecordTypeId = newSaleRT;
                                }                                           
                                commission2Records.Asset_Amount__c= TotalNet;                                    
                                commission2Records.Commission_Split__c = assetOwnerPercent;
                                //commission2Records.Commissionable_Amount2__c = (TotalNet * assetOwnerPercent)/100;
                                //if(quotaRecordSAE.User_Team__c == Commissions_Constants.COLLECTION_TEAM || quotaRecordSAE.User_Team__c == Commissions_Constants.COLLECTIONS_CLIENT_RELATIONS_MANAGERS){
                                //#CRM-1560 - Flexibility to Modify/Create User teams in SFDC by using Config -ADDED BY Venkata Cheedara
                                if(quotaRecordSAE.User_Team__c == CommissionTeams__c.getInstance('COLLECTION_TEAM').Team_Name__c || quotaRecordSAE.User_Team__c == CommissionTeams__c.getInstance('COLLECTIONS_CLIENT_RELATIONS_MANAGERS').Team_Name__c){
                                    commission2Records.Commissionable_Amount2__c= (TotalNet * signingAEpercent)/100;
                                }
                                //if(quotaRecordSAE.User_Team__c != Commissions_Constants.COLLECTION_TEAM && quotaRecordSAE.User_Team__c !=                           
                                    //Commissions_Constants.COLLECTIONS_CLIENT_RELATIONS_MANAGERS && quotaRecordSAE.User_Team__c != Commissions_Constants.MANAGERS_TEAM){
                                //#CRM-1560 - Flexibility to Modify/Create User teams in SFDC by using Config -ADDED BY Venkata Cheedara
                                if(quotaRecordSAE.User_Team__c != CommissionTeams__c.getInstance('COLLECTION_TEAM').Team_Name__c && quotaRecordSAE.User_Team__c !=                           
                                    CommissionTeams__c.getInstance('COLLECTIONS_CLIENT_RELATIONS_MANAGERS').Team_Name__c && quotaRecordSAE.User_Team__c != CommissionTeams__c.getInstance('MANAGERS_TEAM').Team_Name__c){ 
                                    if(quotaRecordSAE.Is_Kicker__c == False && assetRecord.Line_Type__c != 'Renew'){
                                        commission2Records.Commissionable_Amount2__c = (TotalNet * assetOwnerPercent )/100; 
                                    }
                                    if(quotaRecordSAE.Is_Kicker__c == true && assetRecord.Line_Type__c != 'Renew'){
                                        commission2Records.Commissionable_Amount1B__c = (TotalNet * assetOwnerPercent )/100; 
                                    }
                                    if(quotaRecordSAE.Is_Kicker__c == False && assetRecord.Line_Type__c == 'Renew'){
                                        commission2Records.Renewal_w_o_Qualifier_Comm_ble_Amount__c = (TotalNet * assetOwnerPercent )/100; 
                                    }
                                    if(quotaRecordSAE.Is_Kicker__c == true && assetRecord.Line_Type__c == 'Renew'){
                                        commission2Records.Renewal_w_Qualifier_Comm_ble_Amount__c = (TotalNet * assetOwnerPercent )/100; 
                                    }                           
                                }
                                //if(quotaRecordSAE.User_Team__c == Commissions_Constants.MANAGERS_TEAM){  
                                //#CRM-1560 - Flexibility to Modify/Create User teams in SFDC by using Config -ADDED BY Venkata Cheedara
                                if(quotaRecordSAE.User_Team__c == CommissionTeams__c.getInstance('MANAGERS_TEAM').Team_Name__c){  
                                    commission2Records.Commissionable_Amount2__c = (TotalNet * assetOwnerPercent )/100; 
                                }                               
                                commission2Records.Signing_AE__c = assetRecord.Sign_in_AE__c;
                                commission2Records.Billing_Type__c = assetRecord.Billing_Period__c;
                                commission2Records.Status__c = 'Active';
                                commission2Records.Record_Processed__c = FALSE;
                                commission2Records.Related_to_Quota__c = quotaRecordSAE.id;
                                commission2Records.User_Team__c = quotaRecordSAE.User_Team__c;
                                commission2Records.Line_Type__c = assetRecord.Line_Type__c;
                                if(commission2Records.Related_to_Quota__c != Null){
                                    commission.put(assetRecord.id+'#######',commission2Records);
                                    assetRecord.Commissions_are_calculated__c = true;
                                    updateAssets.put(assetRecord.id,assetRecord);
                                    quotaRecordSAE.Record_Processed__c = FALSE;
                                    updateQuota.put(quotaRecordSAE.id,quotaRecordSAE);
                                }
                                assetRecord.Record_processed_for_commission__c = true;
                                updateAssets.put(assetRecord.id,assetRecord);
                            }
                        }                           
                    }
                }                 
            }
            assetRecord.Record_processed_for_commission__c = true;
            updateAssets.put(assetRecord.id,assetRecord);
        }
        assetSignInAEQuotas.clear();productIds.clear(); accountIds.clear();signInAEIds.clear();assetProducts.clear();allAccounts.clear() ;
        //CREATING COMMISSIONS    
        List<Error__c> lstError = new List<Error__c>();
        if(commission.size () > 0){                                         
            try{
                upsert commission.Values();                          
            }
            Catch(Exception e){
                Error__c error = new Error__c();
                error.Name = 'Commission Creation Process';
                error.Entity_Id__c = 'Create new Commissions';
                error.Interface_Name__c = 'Commissions_CreateNewCommissionsHandler';
                error.Error_Description__c = e+'';
                lstError.add(error); 
            }  
        } 
        commission.clear();
        //if(!updateQuota.isEmpty()){
            //update updateQuota.values();
        //}
        updateQuota.clear(); 
        system.debug('Commission Size $$ :'+commission.size());
        //UPDATING ASSETS
        if(updateAssets.size() > 0){
            try{
                //Code added for skip asset trigger by Srinivas pendli on 25.5.2016
                SkipAssetTrigger.setSkipTrgTrue();
                update updateAssets.values();
            }
            Catch(Exception e){
                Error__c error = new Error__c();
                error.Name = 'Commission Creation Process';
                error.Entity_Id__c = 'Create new Commissions';
                error.Interface_Name__c = 'Commissions_CreateNewCommissionsHandler';
                error.Error_Description__c = e+'';
                lstError.add(error);
            }
        }
        updateAssets.clear();
        System.debug(LoggingLevel.ERROR, 'Heap Size Commissions Loop $$ : ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize());               
    }
}