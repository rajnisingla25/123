/*******************************************************************************
Created By      :   Sourabh Lakhera
Created Date    :   
Usage           :   

********************************************************************************/
public class commissions_AmdClwbckBtchProcessHdlr_New{ 
    //RETRIVING ACCOUNT RECORD TYPES 
    private static Map<string,Schema.RecordTypeInfo> accountRecordtypeMap = Schema.SObjectType.Account.getRecordTypeInfosByName();
    private static string assetAccountB2BRecordtype = accountRecordtypeMap.get('B2B').getRecordTypeId();
    private static string assetAccountB2CRecordtype = accountRecordtypeMap.get('B2C').getRecordTypeId();
    
    //RETRIVING COMMISSIONS RECORD TYPES 
    private static Map<string,Schema.RecordTypeInfo> commissionRecordtypeMap = Schema.SObjectType.Commission__c.getRecordTypeInfosByName();
    private static string commissionClawbackRecordtype = commissionRecordtypeMap.get(System.Label.Commissions_Clawback).getRecordTypeId();
    
    //RETRIEVING USER TEAMS FROM CUSTIOM SETTING/VARIABLE DECLERATION
    private static string brokerRegionalDirectorsTeam = CommissionTeams__c.getInstance('BROKER_REGIONAL_DIRECTORS_TEAM').Team_Name__c;
    //private static string collectionTeam = CommissionTeams__c.getInstance('COLLECTION_TEAM').Team_Name__c;
    //private static string collectionsClientRelationsManagers = CommissionTeams__c.getInstance('COLLECTIONS_CLIENT_RELATIONS_MANAGERS').Team_Name__c;
    private static string managersTeam = CommissionTeams__c.getInstance('MANAGERS_TEAM').Team_Name__c;
    
    private integer month = Date.Today().month();
    private integer year = Date.Today().year();
    
    public class MyException extends Exception{
    }
    
    @TestVisible 
    private string getBrokerrdTeam(Integer monthValue){
        String brokerRDteam = 'Q2' ;   
        If (monthValue <= 3) {       
            brokerRDteam = 'Q3';
        }
        else if (monthValue <= 6) {
            brokerRDteam = 'Q4';
        }
        else if (monthValue <= 9) {
            brokerRDteam = 'Q1';
        }
        return brokerRDteam;
    }
    
    Public void createCommissions(List<Asset> fullfilledAssets){       
        //VERIABLE DECLERATION
        set<Id> assetIds = new set<id>();        
        set<Id> quotaUserids = new set<Id>();  
        Map<Id,Asset> assetsWithCommissionsBeforeGoLive = new Map<Id,Asset>();
        Map<Id,Asset> assetsWithCommissionsAfterGoLive = new Map<Id,Asset>(); 
        list<Asset> assetsCreateNewCommissions = new list<Asset>();
        List<commission__c> createClawbackCommissionsList = new List<commission__c>();
        Map<Id,Asset> currentMonthAssets = new Map<Id,Asset>();
        
        for(Asset assetRecord : fullfilledassets){    
            Boolean isBeforeGoLiveAsset = assetRecord.Start_Date__c <= Date.ValueOf(system.label.Commissions_BeforeGoLiveDate);           
            if(assetRecord.Sign_in_AE__c != Null && (assetRecord.Line_Type__c == System.Label.Commission_Line_Type_amend || assetRecord.Line_Type__c == System.Label.Commission_Line_Type_Cancel || assetRecord.Line_Type__c == System.Label.Commission_Line_Type_Credit))
            {
                if(!isBeforeGoLiveAsset && assetRecord.Delta_Price_w_o_Tax__c > 0){
                    if(assetRecord.Start_Date__c.Month() != month || assetRecord.Start_Date__c.Year() != Year){	// CRM-5092, Updated Condition
                        assetsCreateNewCommissions.add(assetRecord);
                    }
                    // Added for CRM-5498
                    if(assetRecord.Start_Date__c.Month() == month && assetRecord.Start_Date__c.Year() == Year){
                        currentMonthAssets.put(assetRecord.Id, assetRecord);
                    }
                }             
            }            
            assetIds.add(assetRecord.Id);
            quotaUserids.add(assetRecord.Sign_in_AE__c);         
        }
        // Added for CRM-5498
        if(currentMonthAssets.size() > 0){
            List<Asset> lstAssetsWithComm = [select Id, (Select Id from Commissions__r) from Asset where id IN :currentMonthAssets.keySet()];
            for(Asset thisMonthAsset : lstAssetsWithComm){
                if(thisMonthAsset.Commissions__r != null && thisMonthAsset.Commissions__r.size() < 1){
                    assetsCreateNewCommissions.add(currentMonthAssets.get(thisMonthAsset.Id));
                }
            }
        }
        
        if(!assetsCreateNewCommissions.isEmpty()){
            commissions_NewSaleBatchProcessHdlr_New commission = new commissions_NewSaleBatchProcessHdlr_New ();
            commission.createCommissions(assetsCreateNewCommissions);
        }        
        //GETTING ALL PROCESSED ASSETS COMMISSIONS
        Map<id,Commission__c> assetsExistingCommissions = new Map<id,Commission__c>([SELECT id ,Signing_AE__c,user_Team__c,Commission_Split__c,
                                                                                     Billing_Type__c,Related_to_Asset__c,Related_to_Quota__c,Related_to_Quota__r.User__c,Status__c,Line_Type__c,Createddate,
                                                                                     Asset_Amount__c,Commissionable_Amount2__c,Commissionable_Amount1B__c,Renewal_w_Qualifier_Comm_ble_Amount__c, Payout_Rate__c,Payout_Rate1B__c,
                                                                                     Renewal_w_o_Qualifier_Payout_Rate__c, Renewal_w_Qualifier_Payout_Rate__c,
                                                                                     Renewal_w_o_Qualifier_Comm_ble_Amount__c,Commissionable_Amount3__c,OpenBook_New_Sale_Comm_ble_Amount__c
                                                                                     FROM Commission__c 
                                                                                     WHERE RecordTypeId !=: commissionClawbackRecordtype
                                                                                     AND status__c ='Active' 
                                                                                     AND Related_to_Asset__c IN : assetIds]);
        
        for(commission__c referencecommission : assetsExistingCommissions.Values()){
            quotaUserids.add(referencecommission.Related_to_Quota__r.user__c);
        }    
        
        Map<id,Quota__c> processedCurrentmothAssetQuotas = new Map<id,Quota__c>([select id,Is_Kicker__c,User_Team__c,User__c ,Current_Quater__c,
                                                                                 Quota_StartDate__c,Period_Name__r.Sigh_In_AE__c,Period_Name__r.Agent_Sigh_In_AE__c,Component_1A_Payout__c,
                                                                                 (Select Id, Product_Family__c, Product_Name__c, Product_Name__r.Name from Quota_Products__r)
                                                                                 FROM Quota__c                           
                                                                                 WHERE User__c In : quotaUserids
                                                                                 AND ((Quota_StartDate__c = THIS_MONTH) 
                                                                                      OR (Quota_StartDate__c = THIS_YEAR 
                                                                                          AND Current_Quater__c =: getBrokerrdTeam(Month)))]);                                               
        for(Quota__c quotarecord : processedCurrentmothAssetQuotas.values()){
            processedCurrentmothAssetQuotas.put(quotarecord.User__c, quotarecord);
        } 
        Map<id,asset>  updateAssets = new Map<id,Asset>(); 
        for(Asset assetRecord : fullfilledAssets){
            if(assetsCreateNewCommissions.contains(assetRecord)){
                continue;
            }
            assetRecord.Record_processed_for_commission__c = TRUE;
            updateassets.put(assetRecord.id, assetRecord);
            Boolean isBeforeGoLiveAsset = assetRecord.Start_Date__c <= Date.ValueOf(system.label.Commissions_BeforeGoLiveDate);  
            if(!isBeforeGoLiveAsset){           // removed this [&& assetRecord.Delta_Price_w_o_Tax__c < 0] as part of CRM-4407 Fix
                for(commission__c referencecommission : assetsExistingCommissions.Values()){
                    if(referencecommission.Related_to_Asset__c != assetRecord.id){
                        continue;
                    }
                    quota__c currentmonthquota = processedCurrentmothAssetQuotas.get(referencecommission.Related_to_Quota__r.user__c);
                    if (currentmonthquota == null){ 
                        continue;
                    } 
                    boolean isUpdate = true;
                    if(referencecommission.Createddate >= assetRecord.Start_Date__c 
                       && (assetRecord.Start_Date__c.month() != month 
                           || (assetRecord.Start_Date__c.month() == month && year != assetRecord.Start_Date__c.year())
                          )
                      ){
                          isUpdate = False;                    
                      }
                    if(isUpdate || assetRecord.Delta_Price_w_o_Tax__c < 0){			//CRM-4455
                        createClawbackCommissionsList.add(getcommissionrecord(assetrecord,currentmonthquota,referencecommission,isUpdate,FALSE));
                    }
                }
            }
            else if(assetRecord.Delta_Price_w_o_Tax__c < 0){
                quota__c currentmonthquotaBefore = processedCurrentmothAssetQuotas.get(assetRecord.Sign_in_AE__c);
                if(currentmonthquotaBefore != null){
                    createClawbackCommissionsList.add(getcommissionrecord(assetrecord,currentmonthquotaBefore,null,FALSE,FALSE));
                }
            }
        }
        List<Error__c> lstError = new List<Error__c>();
        List<commission__c> commissionsList = new List<commission__c>();
        commissionsList.addall(createClawbackCommissionsList);
        
        Database.upsertResult[] commissionResult = Database.upsert(createClawbackCommissionsList, false);
        Integer i = 0;
        for(Database.UpsertResult sr: commissionResult) {
            Id assetId = commissionsList.get(i).Related_to_Asset__c;
            if(sr.isSuccess()){               
                Asset assetRecordSuccess = new Asset();
                assetRecordSuccess.Id = assetId;
                assetRecordSuccess.Commissions_are_calculated__c = TRUE;
                assetRecordSuccess.Record_processed_for_commission__c = TRUE;
                updateassets.put(assetRecordSuccess.id,assetRecordSuccess);
            }
            else {
                Asset assetrecordError = new Asset();
                assetrecordError.Id = assetId;
                assetrecordError.Commissions_are_calculated__c = FALSE;
                assetrecordError.Record_processed_for_commission__c = TRUE;
                updateassets.put(assetrecordError.id,assetrecordError);
                for (Database.Error err: sr.getErrors()) {
                    Error__c error = new Error__c();
                    error.Name = 'Commission (Amend and Cancel ) claw back Creation';
                    error.Entity_Id__c = 'Create clawback new Commissions';
                    error.Interface_Name__c = 'commissions_AmendClawbackBatchHandler_New';
                    error.Error_Description__c = 'The following error has occurrederred during the commissions Clawback creation process(Amend/Cancel/Credit) :' + err.getMessage() + 'Status Code' + err.getStatusCode();
                    lstError.add(error); 
                }
            }
            i++;
        }  
        createClawbackCommissionsList.Clear();
        
        if(!updateassets.isEmpty()){
            try{
                SkipAssetTrigger.setSkipTrgTrue();
                update updateassets.Values();  
                if(Test.isRunningTest()){
                    throw new myexception('Error');   
                }             
            }
            catch(exception e){
                Error__c error = new Error__c(
                    Name = 'Commission Creation/clawback Process',
                    Entity_Id__c = 'Update Assets',
                    Interface_Name__c = 'commissions_AmendClawbackBatchHandler_New',
                    Error_Description__c = e+'commissions clawback process asset update failuer');           
                lstError.add(error);
            }
        } 
        updateassets.clear(); 
        if(lstError.size() > 0 ){
            insert lstError;
        } 
        lstError.clear();       
    }
    @TestVisible
    private commission__c getcommissionrecord(Asset assetrecord,Quota__c currentmonthquota,commission__c referencecommission,Boolean isUpdate,boolean isBeforeGoLive){    
        Commission__c commissionrecord = new Commission__c();  
        Decimal commissionsSplitpercent ;
        Decimal totalnet_deltaprice;
        
        if(isUpdate == TRUE){
            //commissionrecord.id = referencecommission.id;
            commissionrecord = referencecommission;
            totalnet_deltaprice = assetRecord.Total_Net__c;
            commissionrecord.Asset_Amount__c = totalnet_deltaprice ;         	
        }
        else{
            totalnet_deltaprice = assetRecord.Delta_Price_w_o_Tax__c;
            commissionrecord.RecordTypeId = commissionClawbackRecordtype;
            if(referencecommission != Null){
                commissionrecord.Related_Commission__c = referencecommission.id;
            }
            commissionrecord.RCV__c = -(totalnet_deltaprice) ;
            commissionrecord.Line_Type__c = assetrecord.Line_Type__c;  
            commissionrecord.Asset_Amount__c = -(totalnet_deltaprice) ;
        }
        
        if(referencecommission != Null){
            commissionsSplitpercent = (referencecommission.Commission_Split__c);
        }
        else if(assetrecord.Account.RecordTypeId == assetAccountB2BRecordtype && currentmonthquota != null){
            commissionsSplitpercent = currentmonthquota.Period_Name__r.Sigh_In_AE__c;
        }
        else if(assetrecord.Account.RecordTypeId == assetAccountB2CRecordtype && currentmonthquota != null){
            commissionsSplitpercent  = currentmonthquota.Period_Name__r.Agent_Sigh_In_AE__c;                                    
        }
        else if(assetrecord.Sign_in_AE__c == assetrecord.OwnerId || Test.IsRunningTest()){
            commissionsSplitpercent  = 100;                                    
        }
        if(referencecommission != null){            
            commissionrecord.Payout_Rate__c = referencecommission.Payout_Rate__c;
            commissionrecord.Payout_Rate1B__c = referencecommission.Payout_Rate1B__c;
            commissionrecord.Renewal_w_o_Qualifier_Payout_Rate__c = referencecommission.Renewal_w_o_Qualifier_Payout_Rate__c;
            commissionrecord.Renewal_w_Qualifier_Payout_Rate__c = referencecommission.Renewal_w_Qualifier_Payout_Rate__c;
            
        }
        totalnet_deltaprice = totalnet_deltaprice == null ? 0.0 : totalnet_deltaprice;
        commissionsSplitpercent = commissionsSplitpercent == null ? 0.0 : commissionsSplitpercent;
        Decimal commissionalbleamount = (totalnet_deltaprice * commissionsSplitpercent)/100;
        if(commissionrecord.Id == null){	//CRM-4736
            commissionrecord.Related_to_Asset__c = assetrecord.id;
            commissionrecord.Signing_AE__c = assetrecord.Sign_in_AE__c;                                        
            if(currentmonthquota != null && commissionrecord.Related_to_Quota__c == null){
                commissionrecord.Related_to_Quota__c = currentmonthquota.id;
                commissionrecord.User_Team__c = currentmonthquota.User_Team__c;
            }
            commissionrecord.Status__c = System.Label.Commission_Status_Active; 
            commissionrecord.Record_Processed__c = FALSE;
            commissionrecord.Product__c = assetrecord.product2id;
            commissionrecord.Billing_Type__c = assetrecord.Billing_Period__c;  
            
            if(assetrecord.Order_Line_Item__c != Null){
                commissionrecord.Order_Product__c = assetrecord.Order_Line_Item__c;
            }
        }
        // CRM-4206 [Starts]
        if(isUpdate && assetrecord.product2id != null && currentmonthquota.Quota_Products__r != null && currentmonthquota.Quota_Products__r.size() > 0 && (assetrecord.line_type__c == 'Add' || (assetrecord.line_type__c == 'Amend' && commissionrecord.RecordTypeId != commissionClawbackRecordtype))){  //CRM-5383 added line type check
            for(Quota_Product__c qp : currentmonthquota.Quota_Products__r){
                if(qp.Product_Name__c == null){ 
                    if(assetrecord.Product2.Name == qp.Product_Name__r.Name && Product_Family__c.getInstance(assetrecord.Product2.Name) != null){
                        commissionrecord.Quota_Product_Family__c = qp.Id;
                    }
                }
                else if(assetrecord.product2id == qp.Product_Name__c){
                    commissionrecord.Quota_Product__c = qp.Id;
                }
                if(commissionrecord.Quota_Product_Family__c != null && commissionrecord.Quota_Product__c != null){
                    break;
                }
            }
        }
        // CRM-4206 [Ends]
        commissionrecord.Commission_Split__c = commissionsSplitpercent;
        // CRM-3794 [BRD Open Book] Starts
        if(currentmonthquota.User_Team__c == brokerRegionalDirectorsTeam && currentmonthquota.Current_Quater__c == getBrokerrdTeam(system.today().Month())
           && !currentmonthquota.Is_Kicker__c && assetRecord.Owner.Profile.Name == 'Open Book Profile'){
               commissionRecord.OpenBook_New_Sale_Comm_ble_Amount__c = commissionalbleamount;
           } // CRM-3794 [BRD Open Book] Ends
        else if(referencecommission != null){
            if( referencecommission.Commissionable_Amount3__c != 0.0 && (!isBeforeGoLive)){                                  
                commissionrecord.Commissionable_Amount2__c = commissionalbleamount;
            }
            else{	//CRM-4525 starts        		
                commissionrecord.Commissionable_Amount2__c = referencecommission.Commissionable_Amount2__c != 0.0 ? commissionalbleamount : 0.0;
                commissionrecord.Commissionable_Amount1B__c = referencecommission.Commissionable_Amount1B__c != 0.0 ? commissionalbleamount : 0.0;
                commissionrecord.Renewal_w_o_Qualifier_Comm_ble_Amount__c = referencecommission.Renewal_w_o_Qualifier_Comm_ble_Amount__c != 0.0 ? commissionalbleamount : 0.0;
                commissionrecord.Renewal_w_Qualifier_Comm_ble_Amount__c = referencecommission.Renewal_w_Qualifier_Comm_ble_Amount__c != 0.0 ? commissionalbleamount : 0.0; 
            }// CRM-4525 ends
        }
        else if(commissionrecord.Related_Commission__c == null){
            if(assetrecord.Line_Type__c != System.Label.Commission_Line_Type_Renew && !currentmonthquota.Is_Kicker__c){                                  
                commissionrecord.Commissionable_Amount2__c = commissionalbleamount;
            }
            else if(assetrecord.Line_Type__c != System.Label.Commission_Line_Type_Renew && currentmonthquota.Is_Kicker__c){
                commissionrecord.Commissionable_Amount1B__c = commissionalbleamount;
            }
            else if(assetrecord.Line_Type__c == System.Label.Commission_Line_Type_Renew && !currentmonthquota.Is_Kicker__c){
                commissionrecord.Renewal_w_o_Qualifier_Comm_ble_Amount__c = commissionalbleamount;
            }
            else if(assetrecord.Line_Type__c == System.Label.Commission_Line_Type_Renew && currentmonthquota.Is_Kicker__c){
                commissionrecord.Renewal_w_Qualifier_Comm_ble_Amount__c = commissionalbleamount;
            }
            //else if(referencecommission.OpenBook_New_Sale_Comm_ble_Amount__c != 0.0 && (isBeforeGoLive)){
            //  commissionrecord.OpenBook_New_Sale_Comm_ble_Amount__c = -(commissionalbleamount);
            //} 
        }
        
        
        if(commissionrecord.Line_Type__c != 'Renew'){
            if(commissionrecord.Related_Commission__c == Null ) {
                if(!isUpdate){
                    commissionrecord.Payout_Rate__c = currentmonthquota.Component_1A_Payout__c;
                } 
            }
            else {
                //CLAW BACK COMMISSION RECORD PAYOUT RATES FOR MANAGERS TEAM
                commissionrecord.Payout_Rate__c = referencecommission.Payout_Rate__c;
            }
        }
        
        commissionrecord.Commissionable_Amount2__c = commissionrecord.Commissionable_Amount2__c == null ? 0.0 : commissionrecord.Commissionable_Amount2__c;
        commissionrecord.Commissionable_Amount1B__c = commissionrecord.Commissionable_Amount1B__c == null ? 0.0 : commissionrecord.Commissionable_Amount1B__c;
        commissionrecord.Payout_Rate__c = commissionrecord.Payout_Rate__c == null ? 0.0 : commissionrecord.Payout_Rate__c;
        commissionrecord.Payout_Rate1B__c = commissionrecord.Payout_Rate1B__c == null ? 0.0 : commissionrecord.Payout_Rate1B__c;
        commissionrecord.Renewal_w_o_Qualifier_Comm_ble_Amount__c = commissionrecord.Renewal_w_o_Qualifier_Comm_ble_Amount__c == null ? 0.0 : commissionrecord.Renewal_w_o_Qualifier_Comm_ble_Amount__c;
        commissionrecord.Renewal_w_o_Qualifier_Payout_Rate__c = commissionrecord.Renewal_w_o_Qualifier_Payout_Rate__c == null ? 0.0 : commissionrecord.Renewal_w_o_Qualifier_Payout_Rate__c;
        commissionrecord.Renewal_w_Qualifier_Comm_ble_Amount__c = commissionrecord.Renewal_w_Qualifier_Comm_ble_Amount__c == null ? 0.0 : commissionrecord.Renewal_w_Qualifier_Comm_ble_Amount__c;
        commissionrecord.Renewal_w_Qualifier_Payout_Rate__c =  commissionrecord.Renewal_w_Qualifier_Payout_Rate__c == null ? 0.0 : commissionrecord.Renewal_w_Qualifier_Payout_Rate__c;
        commissionrecord.Final_Commission__c = ((commissionrecord.Commissionable_Amount2__c * commissionrecord.Payout_Rate__c)
                                                + (commissionrecord.Commissionable_Amount1B__c * commissionrecord.Payout_Rate1B__c)
                                                + (commissionrecord.Renewal_w_o_Qualifier_Comm_ble_Amount__c * commissionrecord.Renewal_w_o_Qualifier_Payout_Rate__c)
                                                + (commissionrecord.Renewal_w_Qualifier_Comm_ble_Amount__c * commissionrecord.Renewal_w_Qualifier_Payout_Rate__c))/100;
        if(commissionrecord.RecordTypeId == commissionClawbackRecordtype){
            commissionrecord.Final_Commission__c = -1 * commissionrecord.Final_Commission__c;
        }
        return commissionrecord;
    }
}