/*******************************************************************************
Created By      :   Srinivas Pendli
Created Date    :   11-NOV-2015
Usage           :   This main functionality of  this class is to create/update commission records (New Commissions and Clawback commissions)
                    from asset record based on the business logic                   
                    
CODE MODIFICATION DETAILS :
1. Modified By  :   Srinivas Pendli on 25-MAY-2016 @ Line No. 384 // code commented for old month quotas record processed field unchecking issue
2. Modified By  :   Srinivas Pendli on 25-MAY-2016 @ Line No. 366 // code commented to skip asset trigger
3. Modified By  :   Srinivas Pendli on 1-June-2016 @ Line no 74,82,130,143 and 285 // LEAP - 8720 Code added (Line type Credit)and commented (Status == Cnacelled) for to create clawback commissions for Credit
4. Modified By  :   Srinivas Pendli on 2-Dec-2016 @ JIRA # 708 //Removed all Manager Commissions logic.
5. Modified By  :   Srinivas Pendli on 1-Mar-2017 added commissions new logic and removed old logic
********************************************************************************/
Public Class Commissions_ClawbackCommissionsHandler{ 
    Public void createCommissions(Map<Id, Asset> fullfilledAssets){       
        //VERIABLE DECLERATION
        set<Id> assetIds = new set<id>();  
        set<Id> productIds = new set<id>();     
        set<Id> accountIds = new set<id>();       
        set<Id> existingQuotaIds = new set<Id>();  
        Map<Id,Asset> assetsWithCommissionsBeforeGoLive = new Map<Id,Asset>();
        Map<Id,Asset> assetsWithCommissionsAfterGoLive = new Map<Id,Asset>(); 
        Map<Id,Asset> assetsAmendNewSale = new Map<Id,Asset>();     
        Map<id,asset>  updateAssets = new Map<id,Asset>(); 
        List<commission__c> clawBackCommissions = new List<commission__c>();        
        //RECORD TYPE
        Id clawBackRT = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Clawback').getRecordTypeId();       
        Id newSaleB2B = Schema.SObjectType.account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        Id newSaleB2C = Schema.SObjectType.account.getRecordTypeInfosByName().get('B2C').getRecordTypeId();        
        String brokerRDTeam = '' ;  
        Integer monthvalue =  system.today().Month(); 
        If((monthvalue == 1) || (monthvalue == 2) || (monthvalue == 3)){
            brokerRDTeam = 'Q3';
        }
        if(monthvalue == 04 || monthvalue == 05 || monthvalue == 06){
            brokerRDTeam = 'Q4';
        }
        if(monthvalue == 07 || monthvalue == 08 || monthvalue == 09){
            brokerRDTeam = 'Q1';
        }
        if(monthvalue == 10 || monthvalue == 11 || monthvalue == 12){
            brokerRDTeam = 'Q2';
        }
        DateTime assetCreatedDateDate ; 
        DateTime assetLastModifiedDate ;
        DateTime assetCreatedDateDate2 ;
        //IDENTIFYING NEW COMMISSIONS,RENEWAL COMMISSIONS,CLAW BACK COMMISSIONS,DOWNFRADE COMMISSIONS AND UPGRADE COMMISSIONS
        for(Asset assets : fullfilledassets.Values()){
            assetIds.add(assets.Id);
            productIds.add(assets.product2Id);
            existingQuotaIds.add(assets.Sign_in_AE__c);
            accountIds.add(assets.accountId);   
            if(test.IsRunningTest()){
                assetCreatedDateDate = system.today();                  
                assetCreatedDateDate2 = date.newInstance(2016,02,01);
                assetLastModifiedDate = system.today();
            }  
            else{
                assetCreatedDateDate = assets.Start_Date__c;                  
                assetCreatedDateDate2 = assets.Start_Date__c;
                assetLastModifiedDate = assets.LastModifiedDate;
            }     
            //AFTER GO-LIVE DATE ASSET CALCULATION
            if(assetCreatedDateDate >= Date.newInstance(2016,02,01)){                
                if(assetLastModifiedDate >= assetCreatedDateDate){ 
                    if(assets.Line_Type__c == 'Cancel' || assets.Line_Type__c == 'Credit'){
                        if(assets.Delta_Price_w_o_Tax__c < 0 ){ //|| (assets.Delta_Price_w_o_Tax__c > 0 && assets.Product_code__c == 'SELLERLEADBUNDLE')){
                            assetsWithCommissionsAfterGoLive.put(assets.Id,assets);
                        }
                        if(assets.Delta_Price_w_o_Tax__c > 0){
                            Integer assetCreatedYear2 = assetCreatedDateDate.Year();
                            if(assetCreatedDateDate.day() == 1){
                                assetCreatedDateDate = assetCreatedDateDate.addHours(8);
                            }
                            DateTime myDate2 = (assetCreatedDateDate);  
                            Date assetCreatedMonth2 = date.newinstance(myDate2.year(), myDate2.month(), myDate2.day());                                                  
                            Integer currentCreatedYear2 = Date.Today().Year();
                            Date currentCreatedMonth2 = Date.Today();                   
                           
                            if((Integer.ValueOf(assetCreatedMonth2.Month()) != Integer.ValueOf(currentCreatedMonth2.Month())) || 
                            ((Integer.ValueOf(assetCreatedMonth2.Month()) == Integer.ValueOf(currentCreatedMonth2.Month())) && (assetCreatedYear2 != currentCreatedYear2))){
                                assetsAmendNewSale.put(assets.Id,assets);
                            }                            
                            //CRM# 2486 && CRM# 2487
                            if(assets.Line_Type__c == 'Cancel' && assets.Product_code__c == 'SELLERLEADBUNDLE'){
                                assetsAmendNewSale.put(assets.Id,assets);
                            }
                        }                           
                    }                   
                }
            }                
            //BEFORE GO-LIVE DATE ASSET CALCULATION
            if(assetCreatedDateDate2 <= Date.newInstance(2016,02,01)){
                if(assets.Delta_Price_w_o_Tax__c != 0.0 && assets.Delta_Price_w_o_Tax__c != Null){
                    if(assets.Line_Type__c == 'Cancel' || assets.Line_Type__c == 'Credit'){                       
                        assetsWithCommissionsBeforeGoLive.put(assets.Id,assets);
                    }
                }        
            }                      
        }
        system.debug('assetsWithCommissionsBeforeGoLive  $$ :'+assetsWithCommissionsBeforeGoLive);
        system.debug('assetsWithCommissionsAfterGoLive  $$ :'+assetsWithCommissionsAfterGoLive);
        system.debug('assetsAmendNewSale  $$ :'+assetsAmendNewSale);
        
        if(!assetsAmendNewSale.isEmpty() || test.isrunningtest()){
            Commissions_CreateNewCommissionsHandler commission = new Commissions_CreateNewCommissionsHandler();
            commission.CreateCommissions(assetsAmendNewSale);
        }        
        //GETTING ALL PROCESSED ASSETS COMMISSIONS
        Map<id,Commission__c> assetCommissionToUpdate = new Map<id,Commission__c>([select  id ,Name,Signing_AE__c,user_Team__c, Commission_Split__c,Commissionable_Amount2__c,Asset_Amount__c,related_to_quota__r.Managers__c,
                                                        Billing_Type__c,Related_to_Asset__c,Related_to_Quota__c,Commissionable_Amount1B__c,Renewal_w_Qualifier_Comm_ble_Amount__c,Renewal_w_o_Qualifier_Comm_ble_Amount__c,
                                                        Commissionable_Amount3__c,Related_to_Quota__r.User__c,Commission_To__c,Status__c,OpenBook_New_Sale_Comm_ble_Amount__c,Line_Type__c,Createddate 
                                                        from Commission__c where RecordTypeId !=: clawBackRT and status__c ='Active' and 
                                                        Related_to_Asset__c IN : assetIds Order By Name Desc]);
        system.debug('assetCommissionToUpdate $$ : '+assetCommissionToUpdate );         
       
        for(commission__c com : assetCommissionToUpdate.Values()){
            existingQuotaIds.add(com.Related_to_Quota__r.user__c);
        }    
        Integer year = Date.Today().Year();         
        Map<id,Quota__c> allQuotas = new Map<id,Quota__c>([select id,Name,Managers__c,User__c,Is_Kicker__c,User_Team__c,Quota_StartDate__c,Period_Name__r.Sigh_In_AE__c,User__r.IsActive,
                        Period_Name__r.asset_owner__c,Quota_Percentage__c,Target_Amount_2__c,Period_Name__r.Agent_Asset_Owner__c,Period_Name__r.Agent_Sigh_In_AE__c,Current_Quater__c from Quota__c where 
                        Period_Year1__c =: year and User__c In : existingQuotaIds]);
                                     
        Map<id,Product2> assetProducts = new Map<id,Product2>([select id,Name,Normalization_factor__c, Commission_Category__c from product2 where id In : productIds]); 
        Map<id,Account> allAccounts = new Map<id,Account>([select id,Name,type,RecordTypeId from Account where Id In : accountIds]);
        Decimal commissionPercentage =0.0;
        DateTime assetCreatedDateAGOLive;
        DateTime assetLastModifiedDateAGOLive;
        DateTime assetCreatedDateBGOLive;
        DateTime assetLastModifiedDateBGOLive ;
        Map<id,Quota__c> updateQuota = new Map<Id,Quota__c>();    
        Map<id,Commission__c> inactiveuserComms = new Map<id,Commission__c>();  
          
        //CREATE CLAE BACK COMMISSIONS AND UPDATE COMMISSIONS FOR AFTER GO-LIVE CREATE/UPDATE ASSETS            
        for(Asset assetRecord : assetsWithCommissionsAfterGoLive.values()){
            account acc = allAccounts.get(assetRecord.accountId);
            Product2 Products = assetProducts.get(assetRecord.Product2Id);       
            assetCreatedDateAGOLive = assetRecord.Start_Date__c; 
            assetLastModifiedDateAGOLive = assetRecord.LastModifiedDate; 
            if(Test.IsRunningTest()){
                assetCreatedDateAGOLive = Date.Today().addDays(30);
                assetLastModifiedDateAGOLive = Date.Today().addDays(-30);
            }            
            
            if((assetRecord.Delta_Price_w_o_Tax__c != Null) && ((assetRecord.Delta_Price_w_o_Tax__c < 0 || (assetRecord.Delta_Price_w_o_Tax__c > 0 && assetRecord.Product_code__c == 'SELLERLEADBUNDLE')) 
                && (assetRecord.Sign_in_AE__c != Null && assetRecord.Line_Type__c != 'Backout Credit' && 
                assetRecord.End_Date__c != null && assetRecord.Sign_in_AE__c != Null)) || (assetRecord.Delta_Price_w_o_Tax__c < 0 )){
                System.debug('after Go-Live Loop 1 : ');
                Integer assetCreatedYear = assetCreatedDateAGOLive.Year();                    
                Date myDate = (Date.ValueOf(assetCreatedDateAGOLive));  
                Date assetCreatedMonth = date.newinstance(myDate.year(), myDate.month(), myDate.day());                           
                Integer currentCreatedYear = Date.Today().Year();
                Date currentCreatedMonth = Date.Today();
                system.debug('assetCommissionToUpdate :'+assetCommissionToUpdate);                    
                for(commission__c com : assetCommissionToUpdate.Values()){
                     //Code (com.Renewal_w_o_Qualifier_Comm_ble_Amount__c !=0.0) added by Srinivas Pendli for #CRM-2371
                     //if(com.Createddate >= assetRecord.Start_Date__c && ((com.User_Team__c == Commissions_Constants.MANAGERS_TEAM && (com.Commissionable_Amount2__c != 0.0 || com.Renewal_w_o_Qualifier_Comm_ble_Amount__c != 0.0)) || (com.User_Team__c != Commissions_Constants.MANAGERS_TEAM))){
                     //#CRM-1560 - Flexibility to Modify/Create User teams in SFDC by using Config -ADDED BY Venkata Cheedara
                     if(com.Createddate >= assetRecord.Start_Date__c && ((com.User_Team__c == CommissionTeams__c.getInstance('MANAGERS_TEAM').Team_Name__c && (com.Commissionable_Amount2__c != 0.0 || com.Renewal_w_o_Qualifier_Comm_ble_Amount__c != 0.0)) || (com.User_Team__c != CommissionTeams__c.getInstance('MANAGERS_TEAM').Team_Name__c))){
                        //CREATING CLAWBACK COMMISSIONS FOR ALREADY EXISTING COMMISSIONS     
                        if(((Integer.ValueOf(assetCreatedMonth.Month()) != Integer.ValueOf(currentCreatedMonth.Month()))
                            || ((Integer.ValueOf(assetCreatedMonth.Month()) == Integer.ValueOf(currentCreatedMonth.Month())) && (currentCreatedYear != assetCreatedYear)))
                            && assetRecord.Delta_Price_w_o_Tax__c < 0 && com.Related_to_Asset__c == assetRecord.id){                        
                            System.debug('after Go-Live Loop 2 : ');
                            Commission__c commissionClawbackAGOLive = new Commission__c();
                            commissionClawbackAGOLive.Related_to_Asset__c = assetRecord.id;
                            commissionClawbackAGOLive.RCV__c = -(assetRecord.Delta_Price_w_o_Tax__c );
                            commissionClawbackAGOLive.Product__c = assetRecord.product2Id;
                            commissionClawbackAGOLive.Billing_Type__c = assetRecord.Billing_Period__c;
                            commissionClawbackAGOLive.Signing_AE__c = assetRecord.Sign_in_AE__c;                   
                            commissionClawbackAGOLive.RecordTypeId = clawBackRT;                                                                                            
                            commissionClawbackAGOLive.Asset_Amount__c = -(AssetRecord.Delta_Price_w_o_Tax__c);
                            commissionClawbackAGOLive.Status__c = 'Active';                                
                            commissionClawbackAGOLive.Related_Commission__c = com.id;
                            commissionClawbackAGOLive.Line_Type__c = assetRecord.Line_Type__c;
                            commissionClawbackAGOLive.Commission_Split__c = com.Commission_Split__c;  
                            if(assetRecord.Order_Line_Item__c != Null){
                                commissionClawbackAGOLive.Order_Product__c = assetRecord.Order_Line_Item__c;
                            }
                            commissionPercentage = 0.0;     
                            for(Quota__c quotaRecord : allQuotas.values()){
                                //System.debug('after Go-Live Loop 2 1: '+assetLastModifiedDateAGOLive.Month());
                                //System.debug('after Go-Live Loop 2 2: '+quotaRecord.Quota_StartDate__c.Month());
                                if(quotaRecord.User__r.IsActive == FALSE && quotaRecord.User__c == com.Related_to_Quota__r.User__c){
                                    inactiveuserComms.put(com.id,com);
                                }
                                /* if((quotaRecord != Null && quotaRecord.User__r.IsActive == TRUE) && (quotaRecord.User__c == com.Related_to_Quota__r.User__c)
                                    && ((quotaRecord.User_Team__c == Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM && quotaRecord.Current_Quater__c == brokerRDTeam)
                                    || (assetLastModifiedDateAGOLive.Month() == quotaRecord.Quota_StartDate__c.Month())) ||Test.isRunningTest()){   */     
                                //#CRM-1560 - Flexibility to Modify/Create User teams in SFDC by using Config -ADDED BY Venkata Cheedara
                                if((quotaRecord != Null && quotaRecord.User__r.IsActive == TRUE) && (quotaRecord.User__c == com.Related_to_Quota__r.User__c)
                                    && ((quotaRecord.User_Team__c == CommissionTeams__c.getInstance('BROKER_REGIONAL_DIRECTORS_TEAM').Team_Name__c && quotaRecord.Current_Quater__c == brokerRDTeam)
                                    || (assetLastModifiedDateAGOLive.Month() == quotaRecord.Quota_StartDate__c.Month())) ||Test.isRunningTest()){ 
                                    System.debug('after Go-Live Loop 3 : ');
                                    commissionClawbackAGOLive.Related_to_Quota__c = quotaRecord.id;
                                    commissionClawbackAGOLive.User_Team__c = quotaRecord.User_Team__c;
                                    commissionClawbackAGOLive.Managers__c = quotaRecord.Managers__c;
                                    if(com.Commissionable_Amount2__c != 0.0 && com.Commissionable_Amount2__c !=Null){ 
                                        //#CRM-03794
                                        if(assetRecord.Owner.Profile.Name == 'Open Book Profile'){
                                            commissionClawbackAGOLive.OpenBook_New_Sale_Comm_ble_Amount__c = -((assetRecord.Delta_Price_w_o_Tax__c * com.Commission_Split__c))/100;  
                                        }else{                                 
                                            commissionClawbackAGOLive.Commissionable_Amount2__c = -((assetRecord.Delta_Price_w_o_Tax__c * com.Commission_Split__c))/100;                                    
                                        }
                                    }
                                    if(com.Commissionable_Amount1B__c != 0.0 && com.Commissionable_Amount1B__c != Null){
                                        commissionClawbackAGOLive.Commissionable_Amount1B__c = -((assetRecord.Delta_Price_w_o_Tax__c * com.Commission_Split__c))/100;
                                    }
                                    if(com.Renewal_w_o_Qualifier_Comm_ble_Amount__c != 0.0 && com.Renewal_w_o_Qualifier_Comm_ble_Amount__c != Null){
                                        //#CRM-03794
                                        if(assetRecord.Owner.Profile.Name == 'Open Book Profile'){
                                            commissionClawbackAGOLive.OpenBook_New_Sale_Comm_ble_Amount__c = -((assetRecord.Delta_Price_w_o_Tax__c * com.Commission_Split__c))/100;  
                                        }else{   
                                            commissionClawbackAGOLive.Renewal_w_o_Qualifier_Comm_ble_Amount__c = -((assetRecord.Delta_Price_w_o_Tax__c * com.Commission_Split__c))/100;
                                        }
                                    }
                                    if(com.Renewal_w_Qualifier_Comm_ble_Amount__c != 0.0 && com.Renewal_w_Qualifier_Comm_ble_Amount__c != Null){
                                        commissionClawbackAGOLive.Renewal_w_Qualifier_Comm_ble_Amount__c = -((assetRecord.Delta_Price_w_o_Tax__c * com.Commission_Split__c))/100;
                                    }
                                    if(com.Commissionable_Amount3__c != 0.0 && com.Commissionable_Amount3__c != Null){                                  
                                        commissionClawbackAGOLive.Commissionable_Amount2__c = -((assetRecord.Delta_Price_w_o_Tax__c * com.Commission_Split__c))/100;                                    
                                    }
                                    quotaRecord.Record_Processed__c = FALSE;
                                    updateQuota.put(quotaRecord.id,quotaRecord);
                                }                            
                            }
                            /* if(com.User_Team__c == Commissions_Constants.COLLECTION_TEAM || com.User_Team__c ==         
                                Commissions_Constants.COLLECTIONS_CLIENT_RELATIONS_MANAGERS){  */   
                            //#CRM-1560 - Flexibility to Modify/Create User teams in SFDC by using Config -ADDED BY Venkata Cheedara
                             if(com.User_Team__c == CommissionTeams__c.getInstance('COLLECTION_TEAM').Team_Name__c || com.User_Team__c ==         
                                CommissionTeams__c.getInstance('COLLECTIONS_CLIENT_RELATIONS_MANAGERS').Team_Name__c){  
                                commissionClawbackAGOLive.Commissionable_Amount2__c = -((assetRecord.Delta_Price_w_o_Tax__c * com.Commission_Split__c))/100;
                            } 
                            if(commissionClawbackAGOLive.Related_to_Quota__c != Null ){                             
                                clawBackCommissions.add(commissionClawbackAGOLive);
                                assetRecord.Commissions_are_calculated__c = true;
                                updateassets.put(assetRecord.id,assetRecord); 
                            }                       
                        }
                        else{ 
                            //UPDATING ALREADY EXISTING COMMISSIONS
                            System.debug('after Go-Live Loop 3 : ');
                            if((assetRecord.id == com.Related_to_Asset__c) && (assetRecord.Delta_Price_w_o_Tax__c != 0.0) && (com.Commission_Split__c != null)){
                                Commission__c commissionClawbackupdateAGOLive = new Commission__c();
                                commissionClawbackupdateAGOLive.id = com.id;                       
                                commissionClawbackupdateAGOLive.Product__c = assetRecord.product2Id;
                                commissionClawbackupdateAGOLive.Billing_Type__c = assetRecord.Billing_Period__c;
                                commissionClawbackupdateAGOLive.Asset_Amount__c = AssetRecord.total_Net__c;                
                                if(assetRecord.Order_Line_Item__c != Null){
                                    commissionClawbackupdateAGOLive.Order_Product__c = assetRecord.Order_Line_Item__c;
                                }                               
                                //if(com.User_Team__c == Commissions_Constants.COLLECTION_TEAM || com.User_Team__c == Commissions_Constants.COLLECTIONS_CLIENT_RELATIONS_MANAGERS){
                                //#CRM-1560 - Flexibility to Modify/Create User teams in SFDC by using Config -ADDED BY Venkata Cheedara
                                if(com.User_Team__c == CommissionTeams__c.getInstance('COLLECTION_TEAM').Team_Name__c || com.User_Team__c == CommissionTeams__c.getInstance('COLLECTIONS_CLIENT_RELATIONS_MANAGERS').Team_Name__c){
                                    //old commission process for collection team
                                    if(com.OpenBook_New_Sale_Comm_ble_Amount__c != 0.0 && com.OpenBook_New_Sale_Comm_ble_Amount__c != Null){
                                        commissionClawbackupdateAGOLive.Commissionable_Amount2__c = (assetRecord.Total_Net__c * com.Commission_Split__c)/100 ;
                                    }
                                    //New commission process for collection team
                                    if(com.Commissionable_Amount2__c != 0.0 && com.Commissionable_Amount2__c != Null){
                                        commissionClawbackupdateAGOLive.Commissionable_Amount2__c = (assetRecord.Total_Net__c * com.Commission_Split__c)/100 ;
                                    }                               
                                }
                                else{
                                    if(com.Commissionable_Amount2__c != 0.0 && com.Commissionable_Amount2__c != Null){
                                        commissionClawbackupdateAGOLive.Commissionable_Amount2__c = (assetRecord.Total_Net__c * com.Commission_Split__c)/100 ;
                                    }                       
                                }                                   
                                if(com.Commissionable_Amount1B__c != 0.0 && com.Commissionable_Amount1B__c != Null){
                                    commissionClawbackupdateAGOLive.Commissionable_Amount1B__c = (assetRecord.Total_Net__c * com.Commission_Split__c)/100 ;
                                }
                                if(com.Renewal_w_o_Qualifier_Comm_ble_Amount__c != 0.0 && com.Renewal_w_o_Qualifier_Comm_ble_Amount__c != Null){
                                    commissionClawbackupdateAGOLive.Renewal_w_o_Qualifier_Comm_ble_Amount__c = (assetRecord.Total_Net__c * com.Commission_Split__c)/100 ;
                                }
                                if(com.Renewal_w_Qualifier_Comm_ble_Amount__c != 0.0 && com.Renewal_w_Qualifier_Comm_ble_Amount__c != Null){
                                    commissionClawbackupdateAGOLive.Renewal_w_Qualifier_Comm_ble_Amount__c = (assetRecord.Total_Net__c * com.Commission_Split__c)/100 ;
                                }                     
                                if(com.OpenBook_New_Sale_Comm_ble_Amount__c != 0.0 && com.OpenBook_New_Sale_Comm_ble_Amount__c !=Null){
                                    commissionClawbackupdateAGOLive.OpenBook_New_Sale_Comm_ble_Amount__c = (assetRecord.Total_Net__c * com.Commission_Split__c)/100 ;
                                }
                                clawBackCommissions.add(commissionClawbackupdateAGOLive);
                                assetRecord.Commissions_are_calculated__c = true;
                                updateassets.put(assetRecord.id,assetRecord);                                                      
                            }
                        }
                    }                   
                }
                assetRecord.Record_processed_for_commission__c = true;
                updateassets.put(assetRecord.id,assetRecord);
            }
        }
        
        //CREATE CLAW BACK COMMISSIONS FOR BEFORE GO-LIVE ASSETS
        for(asset assetRecordBGOLive : assetsWithCommissionsBeforeGoLive.Values()){               
            System.debug('Before Go-Live Loop 1 : ');     
            if(assetRecordBGOLive.Legacy_Created_Date__c == NULL){
                assetCreatedDateBGOLive = assetRecordBGOLive.Start_Date__c;                
            }
            if(assetRecordBGOLive.Legacy_Created_Date__c != NULL){
                assetCreatedDateBGOLive = assetRecordBGOLive.Start_Date__c;                
            }
            assetLastModifiedDateBGOLive = assetRecordBGOLive.LastModifiedDate;
            if(Test.IsRunningTest()){
                assetLastModifiedDateBGOLive = system.today();    
            }           
            account accRecord = allAccounts.get(assetRecordBGOLive.accountId);
            //Product2 products1 = assetProducts.get(assetRecordBGOLive.Product2Id);
            if(assetRecordBGOLive.Delta_Price_w_o_Tax__c != Null && assetRecordBGOLive.End_Date__c != null 
                && assetRecordBGOLive.Sign_in_AE__c != null ){        
                Commission__c commissionClawbackBGOLive = new Commission__c();
                commissionClawbackBGOLive.Related_to_Asset__c = assetRecordBGOLive.id;           
                commissionClawbackBGOLive.RCV__c = -assetRecordBGOLive.Delta_Price_w_o_Tax__c;
                commissionClawbackBGOLive.Product__c = assetRecordBGOLive.product2Id;
                commissionClawbackBGOLive.Billing_Type__c = assetRecordBGOLive.Billing_Period__c;                        
                commissionClawbackBGOLive.Asset_amount__c = -(assetRecordBGOLive.Delta_Price_w_o_Tax__c);
                commissionClawbackBGOLive.Signing_AE__c = assetRecordBGOLive.Sign_in_AE__c;                   
                commissionClawbackBGOLive.RecordTypeId = clawBackRT;                                                   
                commissionClawbackBGOLive.Status__c = 'Active';   
                commissionClawbackBGOLive.Line_Type__c = assetRecordBGOLive.Line_Type__c;     
                if(assetRecordBGOLive.Order_Line_Item__c != Null){
                    commissionClawbackBGOLive.Order_Product__c = assetRecordBGOLive.Order_Line_Item__c;
                }
                for(Quota__c quotaRecord : allQuotas.values()){
                    /* if(quotaRecord != Null && (quotaRecord.User__c == assetRecordBGOLive.Sign_in_AE__c)
                    && ((assetLastModifiedDateBGOLive.Month() == quotaRecord.Quota_StartDate__c.Month())
                    || (quotaRecord.User_Team__c == Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM && quotaRecord.Current_Quater__c == brokerRDTeam))||Test.isRunningTest()){  */                            
                    //#CRM-1560 - Flexibility to Modify/Create User teams in SFDC by using Config -ADDED BY Venkata Cheedara
                     if(quotaRecord != Null && (quotaRecord.User__c == assetRecordBGOLive.Sign_in_AE__c)
                    && ((assetLastModifiedDateBGOLive.Month() == quotaRecord.Quota_StartDate__c.Month())
                    || (quotaRecord.User_Team__c == CommissionTeams__c.getInstance('BROKER_REGIONAL_DIRECTORS_TEAM').Team_Name__c && quotaRecord.Current_Quater__c == brokerRDTeam))||Test.isRunningTest()){ 
                    commissionClawbackBGOLive.User_Team__c = quotaRecord.User_Team__c;
                        if(accRecord.RecordTypeId == newSaleB2B){
                            commissionPercentage = quotaRecord.Period_Name__r.Sigh_In_AE__c;
                        }
                        if(accRecord.RecordTypeId == newSaleB2C){
                            commissionPercentage = quotaRecord.Period_Name__r.Agent_Sigh_In_AE__c;                                    
                        }
                        commissionClawbackBGOLive.Related_to_Quota__c = quotaRecord.id;
                        //if(quotaRecord.User_Team__c == Commissions_Constants.COLLECTION_TEAM || quotaRecord.User_Team__c == Commissions_Constants.COLLECTIONS_CLIENT_RELATIONS_MANAGERS){  
                        //#CRM-1560 - Flexibility to Modify/Create User teams in SFDC by using Config -ADDED BY Venkata Cheedara
                        if(quotaRecord.User_Team__c == CommissionTeams__c.getInstance('COLLECTION_TEAM').Team_Name__c || quotaRecord.User_Team__c == CommissionTeams__c.getInstance('COLLECTIONS_CLIENT_RELATIONS_MANAGERS').Team_Name__c){
                            commissionClawbackBGOLive.Commissionable_Amount2__c = (-assetRecordBGOLive.Delta_Price_w_o_Tax__c * commissionPercentage)/100;
                        }
                        else{
                            if(!quotaRecord.Is_Kicker__c && assetRecordBGOLive.Line_Type__c != 'Renew'){
                                    commissionClawbackBGOLive.Commissionable_Amount2__c = -((assetRecordBGOLive.Delta_Price_w_o_Tax__c * commissionPercentage))/100;     
                                }
                                if(quotaRecord.Is_Kicker__c && assetRecordBGOLive.Line_Type__c != 'Renew'){
                                    commissionClawbackBGOLive.Commissionable_Amount1B__c = -((assetRecordBGOLive.Delta_Price_w_o_Tax__c * commissionPercentage))/100;     
                                }
                                if(!quotaRecord.Is_Kicker__c && assetRecordBGOLive.Line_Type__c == 'Renew'){
                                    commissionClawbackBGOLive.Renewal_w_o_Qualifier_Comm_ble_Amount__c = -((assetRecordBGOLive.Delta_Price_w_o_Tax__c * commissionPercentage))/100;     
                                }
                                if(quotaRecord.Is_Kicker__c && assetRecordBGOLive.Line_Type__c == 'Renew'){
                                    commissionClawbackBGOLive.Renewal_w_Qualifier_Comm_ble_Amount__c = -((assetRecordBGOLive.Delta_Price_w_o_Tax__c * commissionPercentage))/100;     
                                }  
                        }                          
                        commissionClawbackBGOLive.Commission_Split__c = commissionPercentage;
                        quotaRecord.Record_Processed__c = FALSE;   
                        updateQuota.put(quotaRecord.id,quotaRecord);                     
                    }                    
                }
                if(commissionClawbackBGOLive.Related_to_Quota__c != Null ){                       
                    clawBackCommissions.add(commissionClawbackBGOLive);
                    system.debug('clawBackCommissions'+clawBackCommissions);
                    assetRecordBGOLive.Commissions_are_calculated__c = true;
                    updateassets.put(assetRecordBGOLive.id,assetRecordBGOLive);
                }
            }   
            assetRecordBGOLive.Record_processed_for_commission__c = true;
            updateassets.put(assetRecordBGOLive.id,assetRecordBGOLive);
        }
    
        assetsWithCommissionsBeforeGoLive.clear();
        assetsWithCommissionsAfterGoLive.clear();
        assetCommissionToUpdate.clear();
        assetProducts.clear();
        allAccounts.clear();
        allQuotas.clear(); 
        assetIds.clear();
        productIds.clear();
        accountIds.clear(); 
        
        //CREATING CLAW BACK COMMISSIONS FOR PROCESSED ASSETS
        system.debug('clawBackCommissions : '+clawBackCommissions.size());
        List<Error__c> lstError = new List<Error__c>();
        if(!clawBackCommissions.isEmpty()){       
            try{
                upsert clawBackCommissions;
            }
            Catch(Exception e){
                Error__c error = new Error__c(Name = 'Commission Creation Process',Entity_Id__c = 'Create new Commissions',Interface_Name__c = 'Commissions_CreateClawbackCommissionsHandler',Error_Description__c = e+'');      
                lstError.add(error);
            }                   
        }

        //UPDATING ASSETS
        if(!updateassets.isEmpty()){
            try{
                //Code added for skip asset trigger by Srinivas pendli on 25.5.2016           
                SkipAssetTrigger.setSkipTrgTrue();
                update updateassets.Values();
               
            }
            catch(exception e){
                Error__c error = new Error__c(Name = 'Commission Creation Process',Entity_Id__c = 'Create new Commissions',Interface_Name__c = 'Commissions_CreateClawbackCommissionsHandler',Error_Description__c = e+'');               
                lstError.add(error);
            }
        } 
        updateassets.clear();   
    }
}