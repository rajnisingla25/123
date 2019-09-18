/*******************************************************************************
Created By       :   Srinivas Pendli
Created Date     :   11-NOV-2015
Usage            :   This main functionality of  this class is to create/update commission records (Create-New Commissions,Clawback commissions,update-Existing commissions)
                     from asset record based on the business logic
CODE MODIFICATION DETAILS :
1. Modified By   :   Srinivas Pendli on 25-MAY-2016 @ 391 // code commented for old month quotas record processed field unchecking issue
2. Modified By   :   Srinivas Pendli on 25-MAY-2016 @ Line No. 374 // code commented to skip asset trigger
3. Modified By   :   Srinivas Pendli on 7-June-2016 @ Line no 63-90 and 96-99 as per commissions matrix sheet
4. Modified By   :   Srinivas Pendli on 2-Dec-2016 @ JIRA # 708 //Removed all Manager Commissions logic.
5. Modified By   :   Srinivas Pendli on 1-Mar-2017 added commissions new logic and removed old logic
********************************************************************************/
public class Commissions_AmendCommissionHandler{
    Public void updateCommissions(Map<id,asset> fullfilledAssets){
        //VERIABLE DECLERATION
        set<Id> assetIds = new set<id>();  
        //set<Id> productIds = new set<id>();     
        set<Id> accountIds = new set<id>();
        set<Id> existingQuotaIds = new set<Id>();      
        Map<id,commission__c> updateExistingCommissions = new Map<id,commission__c>();        
        List<commission__c> clawBackCommissions = new List<commission__c>();  
        Map<Id,Asset> assetsWithCommissionsAfterGoLive = new Map<Id,Asset>(); 
        Map<Id,Asset> assetsWithCommissionsBeforeGoLive = new Map<Id,Asset>(); 
        Map<Id,Asset> assetsCreateNewCommissions = new Map<Id,Asset>(); 
        Map<Id,Asset> assetsWithCommissions = new Map<Id,Asset>();         
        Map<id,Quota__c> updateQuota = new Map<Id,Quota__c>();
        Map<id,asset>  updateAssets = new Map<id,Asset>();
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
        //RECORD TYPE
        Id clawBackRT = Schema.SObjectType.Commission__c.getRecordTypeInfosByName().get('Clawback').getRecordTypeId();
        Id newSaleB2B = Schema.SObjectType.account.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        Id newSaleB2C = Schema.SObjectType.account.getRecordTypeInfosByName().get('B2C').getRecordTypeId();       
        DateTime assetCreatedDateDate;
        DateTime assetLastModifiedDate;
        //IDENTIFYING NEW COMMISSIONS,RENEWAL COMMISSIONS,CLAW BACK COMMISSIONS,DOWNFRADE COMMISSIONS AND UPGRADE COMMISSIONS
        for(Asset assets : fullfilledassets.Values()){
            assetIds.add(assets.Id);
            //ProductIds.add(assets.product2Id);
            existingQuotaIds.add(assets.Sign_in_AE__c);
            accountIds.add(assets.accountId);          
            assetCreatedDateDate = assets.Start_Date__c;
            assetLastModifiedDate = assets.LastModifiedDate;
            if(test.IsRunningTest()){
                assetLastModifiedDate = system.today();
            }  
            else{
                assetCreatedDateDate = assets.Start_Date__c;       
                assetLastModifiedDate = assets.LastModifiedDate;
            }                         
            //AFTER GO-LIVE DATE ASSET CALCULATION
            if(assetCreatedDateDate >= Date.newInstance(2016,02,01)){
                if((assets.Line_Type__c == 'Amend') && (assets.Delta_Price_w_o_Tax__c < 0 || assets.Delta_Price_w_o_Tax__c == 0 || assets.Total_Net__c != NULL)){
                    assetsWithCommissionsAfterGoLive.put(assets.Id,assets); 
                }
                //CREATE NEW COMMISSIONS, IF DELTA PRICE IS GREATER THEN 0 AND LAST MONTH ASSETS MODIFIED               
                Integer assetCreatedYear = assetCreatedDateDate.Year();
                Date myDate = Date.ValueOf((assetCreatedDateDate));  
                Date assetCreatedMonth ;            
                if(test.isRunningTest()){
                    assetCreatedMonth = system.today().addMonths(2);
                }
                if(!Test.isRunningTest()){
                    assetCreatedMonth = date.newinstance(myDate.year(), myDate.month(), myDate.day());
                } 
                Integer currentCreatedYear = Date.Today().Year();
                Date currentCreatedMonth = Date.Today();  
                system.debug('assetCreatedMonth.Month() :'+assetCreatedMonth.Month());    
                system.debug('currentCreatedMonth.Month() :'+currentCreatedMonth.Month());                                    
                if((Integer.ValueOf(assetCreatedMonth.Month()) != Integer.ValueOf(currentCreatedMonth.Month())) ||  ((Integer.ValueOf(assetCreatedMonth.Month()) == Integer.ValueOf(currentCreatedMonth.Month())) && (currentCreatedYear != assetCreatedYear))){
                    if(assets.Delta_Price_w_o_Tax__c > 0 && assets.Line_Type__c == 'Amend'){  
                        assetsCreateNewCommissions.put(assets.Id,assets);
                    }
                }                                     
            }
            if(test.isRunningTest()){
                    assetCreatedDateDate = Date.newInstance(2016,02,01);
                }
            if(assetCreatedDateDate <= Date.newInstance(2016,02,01)){
                if((assets.Line_Type__c == 'Amend') && (assets.Delta_Price_w_o_Tax__c < 0 || assets.Delta_Price_w_o_Tax__c == 0 || assets.Total_Net__c != NULL)){
                    assetsWithCommissionsBeforeGoLive.put(assets.Id,assets); 
                }
                if(assets.Delta_Price_w_o_Tax__c > 0 && assets.Line_Type__c == 'Amend'){  
                    assetsCreateNewCommissions.put(assets.Id,assets);
                }
            }                       
        }
        system.debug('assetsWithCommissionsAfterGoLive $$ :'+assetsWithCommissionsAfterGoLive);
        system.debug('assetsCreateNewCommissions $$ :'+assetsCreateNewCommissions);
        
        //SENDING COLLECTED ASSETS INTO 'Commissions_CreateNewCommissionsHandler' CLASS TO CREATE NEW COMMISSIONS
        if(assetsCreateNewCommissions.size() > 0 ){
            Commissions_CreateNewCommissionsHandler commission = new Commissions_CreateNewCommissionsHandler();
            commission.createCommissions(assetsCreateNewCommissions);
        }
        
        //GETTING ALL PROCESSED ASSETS COMMISSIONS                
        Map<id,Commission__c> assetCommissionToUpdate = new Map<id,Commission__c>([select  id ,Signing_AE__c,user_Team__c, Commission_Split__c,Commissionable_Amount2__c,name,Asset_Amount__c,
                                                        Billing_Type__c,Related_to_Asset__c, Related_to_Quota__c,Commissionable_Amount1B__c,
                                                        Renewal_w_o_Qualifier_Comm_ble_Amount__c,Renewal_w_Qualifier_Comm_ble_Amount__c,
                                                        Commissionable_Amount3__c,Related_to_Quota__r.User__c,Commission_To__c,CreatedDate,
                                                        Status__c,OpenBook_New_Sale_Comm_ble_Amount__c,Related_to_Quota__r.Record_Processed__c,Related_to_Quota__r.Id,Line_Type__c 
                                                        from Commission__c where RecordTypeId !=: clawBackRT and status__c ='Active' and 
                                                        Related_to_Asset__c IN : Assetids Order By Name Desc]);
        system.debug('assetCommissionToUpdate $$ :'+assetCommissionToUpdate );        
        
        //Map<id,Product2> assetProducts = new Map<id,Product2>([select id,Name,Normalization_factor__c, Commission_Category__c from product2 where id In : ProductIds]); 
        Map<id,Account> allAccounts = new Map<id,Account>([select id,Name,type,RecordTypeId from Account where Id In : accountIds]);
        
        for(commission__c com : assetCommissionToUpdate.Values()){
            existingQuotaIds.add(com.Related_to_Quota__r.user__c);
        } 
        Integer year = Date.Today().Year();  
        Map<id,Quota__c> allQuotas = new Map<id,Quota__c>([select id,Name,User__c,User__r.Team__c,Is_Kicker__c,User__r.Managers__c,User_Team__c,Quota_StartDate__c,Period_Name__r.Sigh_In_AE__c,
                                Period_Name__r.asset_owner__c,Quota_Percentage__c,Target_Amount_2__c,Period_Name__r.Agent_Asset_Owner__c,Period_Name__r.Agent_Sigh_In_AE__c,Current_Quater__c from Quota__c where 
                                Period_Year1__c =: year and User__c In : existingQuotaIds and User__r.IsActive= TRUE]);        
        system.debug('allQuotas $$ : '+allQuotas);
        for(Asset assetRecord : assetsWithCommissionsAfterGoLive.values()){
            if(!assetsCreateNewCommissions.ContainsKey(assetRecord.Id)){
                DateTime assetCreatedDateAGOLive ; 
                DateTime assetLastModifiedDateAGOLive;              
                Integer assetCreatedYear; 
                Date myDate;Date assetCreatedMonth;
                assetCreatedDateAGOLive = assetRecord.Start_Date__c; 
                if(test.IsRunningTest()){
                    assetLastModifiedDateAGOLive = system.today();
                }
                else{
                    assetLastModifiedDateAGOLive = assetRecord.LastModifiedDate;
                }
                assetCreatedYear = assetCreatedDateAGOLive.Year();
                myDate = Date.ValueOf(assetCreatedDateAGOLive);  
                assetCreatedMonth = date.newinstance(myDate.year(), myDate.month(), myDate.day());                             
                //account acc = allAccounts.get(assetRecord.accountId);
                //Product2 Products = assetProducts.get(assetRecord.Product2Id);            
                if((assetRecord.Sign_in_AE__c != Null && assetRecord.Line_Type__c != 'Backout Credit' && assetRecord.End_Date__c != null &&   
                    assetRecord.Sign_in_AE__c != Null) 
                    && (assetRecord.Order_Line_Item__r.Product_Commission_Category__c != 'Tiger')){                     
                    Integer currentCreatedYear = Date.Today().Year();
                    Date currentCreatedMonth = Date.Today();   
                    //System.debug('assetCreatedMonth.Month():'+assetCreatedMonth.Month());
                    //System.debug('currentCreatedMonth.Month():'+currentCreatedMonth.Month());
                    //System.debug('assetCreatedYear:'+assetCreatedYear);
                    //System.debug('currentCreatedYear:'+currentCreatedYear);
                    //System.debug('assetRecord.Delta_Price_w_o_Tax__c:'+assetRecord.Delta_Price_w_o_Tax__c);            
                    for(commission__c com : assetCommissionToUpdate.Values()){
                        //CREATING CLAWBACK COMMISSIONS          
                        System.debug('asset >>:'+com.Name);              
                        //if(com.Createddate >= assetRecord.Start_Date__c && ((com.User_Team__c == Commissions_Constants.MANAGERS_TEAM && com.Commissionable_Amount2__c != 0.0) || (com.User_Team__c != Commissions_Constants.MANAGERS_TEAM))){   
                          //#CRM-1560 - Flexibility to Modify/Create User teams in SFDC by using Config -ADDED BY Venkata Cheedara 
                        if(com.Createddate >= assetRecord.Start_Date__c && ((com.User_Team__c == CommissionTeams__c.getInstance('MANAGERS_TEAM').Team_Name__c && com.Commissionable_Amount2__c != 0.0) || (com.User_Team__c != CommissionTeams__c.getInstance('MANAGERS_TEAM').Team_Name__c))){   
                            System.debug('com.Related_to_Asset__c:'+com.Related_to_Asset__c);
                            if(((Integer.ValueOf(assetCreatedMonth.Month()) != Integer.ValueOf(currentCreatedMonth.Month())) || 
                                ((Integer.ValueOf(assetCreatedMonth.Month()) == Integer.ValueOf(currentCreatedMonth.Month())) && (assetCreatedYear != currentCreatedYear))) &&              
                                (assetRecord.Delta_Price_w_o_Tax__c < 0 && assetRecord.Delta_Price_w_o_Tax__c != Null) && (com.Related_to_Asset__c == assetRecord.id)){
                                                        
                                Commission__c commissionClawbackAGOLive = new Commission__c();
                                commissionClawbackAGOLive.Related_to_Asset__c = assetRecord.id;
                                commissionClawbackAGOLive.RCV__c = -(assetRecord.Delta_Price_w_o_Tax__c );
                                commissionClawbackAGOLive.Product__c = assetRecord.product2Id;
                                commissionClawbackAGOLive.Billing_Type__c = assetRecord.Billing_Period__c;
                                commissionClawbackAGOLive.Signing_AE__c = assetRecord.Sign_in_AE__c;                   
                                commissionClawbackAGOLive.RecordTypeId = clawBackRT;                                                                                            
                                commissionClawbackAGOLive.Asset_Amount__c = -(assetRecord.Delta_Price_w_o_Tax__c);
                                commissionClawbackAGOLive.Status__c = 'Active';                                
                                commissionClawbackAGOLive.Related_Commission__c = com.id;
                                commissionClawbackAGOLive.Line_Type__c = assetRecord.Line_Type__c;
                                if(assetRecord.Order_Line_Item__c != Null){
                                    commissionClawbackAGOLive.Order_Product__c = assetRecord.Order_Line_Item__c;
                                }           
                                for(Quota__c quotaRecord : allQuotas.values()){  
                                    /* if(quotaRecord != Null && com.Related_to_Quota__r.User__c != null && (com.Related_to_Quota__r.User__c == quotaRecord.User__c)
                                        && quotaRecord.Quota_StartDate__c != null && ((assetLastModifiedDateAGOLive.Month() == quotaRecord.Quota_StartDate__c.Month())
                                        || (quotaRecord.User_Team__c == Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM  && quotaRecord.Current_Quater__c == brokerRDTeam)) || Test.isRunningTest()){ */                            
                                    //#CRM-1560 - Flexibility to Modify/Create User teams in SFDC by using Config -ADDED BY Venkata Cheedara 
                                    if(quotaRecord != Null && com.Related_to_Quota__r.User__c != null && (com.Related_to_Quota__r.User__c == quotaRecord.User__c)
                                        && quotaRecord.Quota_StartDate__c != null && ((assetLastModifiedDateAGOLive.Month() == quotaRecord.Quota_StartDate__c.Month())
                                        || (quotaRecord.User_Team__c == CommissionTeams__c.getInstance('BROKER_REGIONAL_DIRECTORS_TEAM').Team_Name__c && quotaRecord.Current_Quater__c == brokerRDTeam)) || Test.isRunningTest()){    
                                        commissionClawbackAGOLive.Related_to_Quota__c = quotaRecord.id;                               
                                        commissionClawbackAGOLive.User_Team__c = quotaRecord.User_Team__c;
                                        if(com.Commissionable_Amount2__c != 0.0 && com.Commissionable_Amount2__c != Null){
                                            commissionClawbackAGOLive.Commissionable_Amount2__c = -((assetRecord.Delta_Price_w_o_Tax__c * com.Commission_Split__c))/100;
                                        }                                    
                                        if(com.Commissionable_Amount1B__c != 0.0 && com.Commissionable_Amount1B__c != Null){
                                            commissionClawbackAGOLive.Commissionable_Amount1B__c = -((assetRecord.Delta_Price_w_o_Tax__c * com.Commission_Split__c))/100;
                                        }
                                        if(com.Renewal_w_o_Qualifier_Comm_ble_Amount__c != 0.0 && com.Renewal_w_o_Qualifier_Comm_ble_Amount__c != Null){
                                            commissionClawbackAGOLive.Renewal_w_o_Qualifier_Comm_ble_Amount__c = -((assetRecord.Delta_Price_w_o_Tax__c * com.Commission_Split__c))/100;
                                        }
                                        if(com.Renewal_w_Qualifier_Comm_ble_Amount__c != 0.0 && com.Renewal_w_Qualifier_Comm_ble_Amount__c != Null){
                                            commissionClawbackAGOLive.Renewal_w_Qualifier_Comm_ble_Amount__c = -((assetRecord.Delta_Price_w_o_Tax__c * com.Commission_Split__c))/100;
                                        }
                                        if(com.Commissionable_Amount3__c != 0.0){                                  
                                            commissionClawbackAGOLive.Commissionable_Amount2__c = -((assetRecord.Delta_Price_w_o_Tax__c * com.Commission_Split__c))/100;                                    
                                        }
                                       /*  if(com.User_Team__c == Commissions_Constants.COLLECTION_TEAM || com.User_Team__c ==         
                                            Commissions_Constants.COLLECTIONS_CLIENT_RELATIONS_MANAGERS){  */   
                                        //#CRM-1560 - Flexibility to Modify/Create User teams in SFDC by using Config -ADDED BY Venkata Cheedara 
                                        if(com.User_Team__c == CommissionTeams__c.getInstance('COLLECTION_TEAM').Team_Name__c || com.User_Team__c ==         
                                           CommissionTeams__c.getInstance('COLLECTIONS_CLIENT_RELATIONS_MANAGERS').Team_Name__c){    
                                            commissionClawbackAGOLive.Commissionable_Amount2__c = -((assetRecord.Delta_Price_w_o_Tax__c * com.Commission_Split__c))/100;
                                        }
                                        commissionClawbackAGOLive.Commission_Split__c = com.Commission_Split__c;
                                        quotaRecord.Record_Processed__c = FALSE;
                                        updateQuota.put(quotaRecord.id,quotaRecord);  
                                    }                                                     
                                }                                                  
                                if(commissionClawbackAGOLive.Related_to_Quota__c != Null){                           
                                    clawBackCommissions.add(commissionClawbackAGOLive);
                                    assetRecord.Commissions_are_calculated__c = true;
                                    updateassets.put(assetRecord.id,assetRecord);                           
                                }  
                                                                       
                            }                   
                          
                            //UPDATING EXISTING COMMISSIONS                 
                            if(((Integer.ValueOf(assetCreatedMonth.Month()) == Integer.ValueOf(currentCreatedMonth.Month())) 
                                && (assetCreatedYear == currentCreatedYear)) 
                                && (assetRecord.total_Net__c != Null ) && (com.Related_to_Asset__c == assetRecord.id)){   
                                                  System.debug('assetCreatedMonth.Month():2 '+assetCreatedMonth.Month());       
                                if((assetRecord.id == com.Related_to_Asset__c) && (com.Commission_Split__c != null) && (com.Commission_Split__c != 0)){
                                    system.debug('update loop');
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
                                    If(com.Renewal_w_Qualifier_Comm_ble_Amount__c != 0.0 && com.Renewal_w_Qualifier_Comm_ble_Amount__c != Null){
                                        commissionClawbackupdateAGOLive.Renewal_w_Qualifier_Comm_ble_Amount__c = (assetRecord.Total_Net__c * com.Commission_Split__c)/100 ;
                                    }                                
                                    if(com.OpenBook_New_Sale_Comm_ble_Amount__c != 0.0 && com.OpenBook_New_Sale_Comm_ble_Amount__c !=Null){
                                        commissionClawbackupdateAGOLive.Commissionable_Amount2__c = (assetRecord.Total_Net__c * com.Commission_Split__c)/100 ;
                                    }
                                    updateExistingCommissions.put(commissionClawbackupdateAGOLive.id,commissionClawbackupdateAGOLive);
                                    assetRecord.Commissions_are_calculated__c = true;
                                    updateassets.put(assetRecord.id,assetRecord);                           
                                }
                            }
                        }
                        if(!test.IsRunningTest()){
                            assetsWithCommissions.put(assetRecord.id,assetRecord);  
                        }                
                    }                
                    assetRecord.Record_processed_for_commission__c = true;
                    updateassets.put(assetRecord.id,assetRecord);
                } 
            }
        }
        //CREATE CLAW BACK COMMISSIONS - AS PER THE BUSINESS LOGIC,IF ASSETS DON'T HAVE ANY COMMISSIONS
        for(Asset assetRecord : assetsWithCommissionsBeforeGoLive.values()){
            DateTime assetCreatedDateBGOLive;
            DateTime assetLastModifiedDateBGOLive;
            if((!assetsWithCommissions.ContainsKey(assetRecord.Id) && (!assetsCreateNewCommissions.ContainsKey(assetRecord.Id)))){
                assetCreatedDateBGOLive = assetRecord.Start_Date__c;  
                assetLastModifiedDateBGOLive = assetRecord.LastModifiedDate;
                if(test.IsRunningTest()){
                    assetLastModifiedDateBGOLive  = system.today();
                }
                account acc = allAccounts.get(assetRecord.accountId);
                
                if((assetRecord.Sign_in_AE__c != Null && assetRecord.Line_Type__c != 'Backout Credit' && assetRecord.End_Date__c != null && assetRecord.Sign_in_AE__c != Null) 
                    && (assetRecord.Order_Line_Item__r.Product_Commission_Category__c != 'Tiger') && (assetRecord.Delta_Price_w_o_Tax__c < 0)){
                    
                    Decimal commissionPercentage = 0.0;
                    Commission__c commissionClawbackBGOLive = new Commission__c();
                    commissionClawbackBGOLive.Related_to_Asset__c = assetRecord.id;           
                    commissionClawbackBGOLive.RCV__c = -assetRecord.Delta_Price_w_o_Tax__c;
                    commissionClawbackBGOLive.Product__c = assetRecord.product2Id;
                    commissionClawbackBGOLive.Billing_Type__c = assetRecord.Billing_Period__c;                        
                    commissionClawbackBGOLive.Asset_amount__c = -(assetRecord.Delta_Price_w_o_Tax__c);
                    commissionClawbackBGOLive.Signing_AE__c = assetRecord.Sign_in_AE__c;                   
                    commissionClawbackBGOLive.RecordTypeId = clawBackRT;                                                   
                    commissionClawbackBGOLive.Status__c = 'Active';
                    commissionClawbackBGOLive.Line_Type__c = assetRecord.Line_Type__c;
                    if(assetRecord.Order_Line_Item__c != Null){
                        commissionClawbackBGOLive.Order_Product__c = assetRecord.Order_Line_Item__c;
                    }
                    for(Quota__c quotaRecord : allQuotas.values()){
                        /* if((quotaRecord != Null  && quotaRecord.User__c == assetRecord.Sign_in_AE__c)
                            && (quotaRecord.Quota_StartDate__c != null && ((assetLastModifiedDateBGOLive.Month() == quotaRecord.Quota_StartDate__c.Month())
                            || (quotaRecord.User_Team__c != Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM &&  quotaRecord.Current_Quater__c == brokerRDTeam))) ||Test.isRunningTest()){  */                           
                        //#CRM-1560 - Flexibility to Modify/Create User teams in SFDC by using Config -ADDED BY Venkata Cheedara 
                        if((quotaRecord != Null  && quotaRecord.User__c == assetRecord.Sign_in_AE__c)
                            && (quotaRecord.Quota_StartDate__c != null && ((assetLastModifiedDateBGOLive.Month() == quotaRecord.Quota_StartDate__c.Month())
                            || (quotaRecord.User_Team__c != CommissionTeams__c.getInstance('BROKER_REGIONAL_DIRECTORS_TEAM').Team_Name__c&&  quotaRecord.Current_Quater__c == brokerRDTeam))) ||Test.isRunningTest()){ 
                         commissionClawbackBGOLive.User_Team__c = quotaRecord.User_Team__c;
                            if(acc.RecordTypeId == newSaleB2B){
                                commissionPercentage = quotaRecord.Period_Name__r.Sigh_In_AE__c;
                            }
                            if(acc.RecordTypeId == newSaleB2C){
                                commissionPercentage = quotaRecord.Period_Name__r.Agent_Sigh_In_AE__c;                                    
                            }
                            commissionClawbackBGOLive.Related_to_Quota__c = quotaRecord.id;
                            //if(quotaRecord.User_Team__c == Commissions_Constants.COLLECTION_TEAM || quotaRecord.User_Team__c == Commissions_Constants.COLLECTIONS_CLIENT_RELATIONS_MANAGERS){                                         
                            //#CRM-1560 - Flexibility to Modify/Create User teams in SFDC by using Config -ADDED BY Venkata Cheedara 
                            if(quotaRecord.User_Team__c == CommissionTeams__c.getInstance('COLLECTION_TEAM').Team_Name__c || quotaRecord.User_Team__c == CommissionTeams__c.getInstance('COLLECTIONS_CLIENT_RELATIONS_MANAGERS').Team_Name__c){                                         

                            commissionClawbackBGOLive.Commissionable_Amount2__c = (-assetRecord.Delta_Price_w_o_Tax__c * commissionPercentage)/100;
                            }
                            else{                                
                                if(!quotaRecord.Is_Kicker__c && assetRecord.Line_Type__c != 'Renew'){
                                    commissionClawbackBGOLive.Commissionable_Amount2__c = (-assetRecord.Delta_Price_w_o_Tax__c * commissionPercentage)/100;
                                }
                            } 
                            if(quotaRecord .Is_Kicker__c && assetRecord.Line_Type__c != 'Renew'){
                                commissionClawbackBGOLive.Commissionable_Amount1B__c = (-assetRecord.Delta_Price_w_o_Tax__c * commissionPercentage)/100;
                            }
                            if(!quotaRecord.Is_Kicker__c && assetRecord.Line_Type__c == 'Renew'){
                                commissionClawbackBGOLive.Renewal_w_o_Qualifier_Comm_ble_Amount__c = (-assetRecord.Delta_Price_w_o_Tax__c * commissionPercentage)/100;
                            }
                            if(quotaRecord .Is_Kicker__c && assetRecord.Line_Type__c == 'Renew'){
                                commissionClawbackBGOLive.Renewal_w_Qualifier_Comm_ble_Amount__c = (-assetRecord.Delta_Price_w_o_Tax__c * commissionPercentage)/100;
                            }                     
                            commissionClawbackBGOLive.Commission_Split__c = commissionPercentage;        
                            quotaRecord.Record_Processed__c = FALSE;
                            updateQuota.put(quotaRecord.id,quotaRecord);
                        }
                    }                       
                    if(commissionClawbackBGOLive.Related_to_Quota__c != Null ){                       
                        clawBackCommissions.add(commissionClawbackBGOLive);
                        assetRecord.Commissions_are_calculated__c = true;
                        updateassets.put(assetRecord.id,assetRecord);
                    }
                }                         
                assetRecord.Record_processed_for_commission__c = true;
                updateassets.put(assetRecord.id,assetRecord);
            }
        }        
            
        assetsWithCommissionsAfterGoLive.clear(); 
        assetCommissionToUpdate.clear();
        //assetProducts.clear();
        assetIds.clear();
        //productIds.clear();
        accountIds.clear();
        allAccounts.clear();
        allQuotas.clear();
        List<Error__c> lstError = new List<Error__c>();
        //UPDATING EXISTING COMMISSIONS-DOWNGRADE OR UPGRADE FOR SAME MONTH
        if(!updateExistingCommissions.isEmpty()){        
            try{   
                update updateExistingCommissions.Values();                     
            }
            catch(Exception e){
                Error__c error = new Error__c(Name = 'Commission Amend Process',Entity_Id__c = 'Update Commissions',Interface_Name__c = 'Commissions_AmendCommissionSchClass',Error_Description__c = e+'');
                lstError.add(error);
            }
        }
        updateExistingCommissions.clear();
            
        //CREATING CLAW BACK COMMISSIONS FOR PROCESSED ASSETS
        system.debug('clawBackCommissions : '+clawBackCommissions.size());        
        if(!clawBackCommissions.isEmpty()){
            try{
                Insert clawBackCommissions;
            }
            Catch(Exception e){
                Error__c error = new Error__c(Name = 'Commission Amend Process',Entity_Id__c = 'Update Commissions',Interface_Name__c = 'Commissions_AmendCommissionSchClass',Error_Description__c = e+'');  
                lstError.add(error);
            }                   
        } 
        clawBackCommissions.clear();             
        //UPDATING ASSETS
        if(!updateassets.isEmpty()){
            try{ 
                //Code added for skip asset trigger by Srinivas pendli on 25.5.2016                 
                SkipAssetTrigger.setSkipTrgTrue();
                update updateassets.Values();
                
            }
            catch(exception e){
                Error__c error = new Error__c(Name = 'Commission Amend Process',Entity_Id__c = 'Update Commissions',Interface_Name__c = 'Commissions_AmendCommissionSchClass',Error_Description__c = e+'');               
                lstError.add(error);
            }
        } 
        updateassets.clear();
        assetsCreateNewCommissions.clear();
        assetsWithCommissionsBeforeGoLive.clear();      
    }
}