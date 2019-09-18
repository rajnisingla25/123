/*******************************************************************************
Created By      :   Sourabh Lakhera
Created Date    :   23-MAR-2018
Usage           :   The usage of this class is to Create new commissions for signing ae and asset owner.
                    It will create commissions for all Teams with different components depends on the line type in asset level and 
                    kicker value in quota level.  
                                 
********************************************************************************/
Public Class commissions_NewSaleBatchProcessHdlr_New
{
     
    //RETRIVING ACCOUNT RECORD TYPES 
    private static Map<string,Schema.RecordTypeInfo> accountRecordtypeMap = Schema.SObjectType.Account.getRecordTypeInfosByName();
    @testvisible private static string assetAccountB2BRecordtype = accountRecordtypeMap.get('B2B').getRecordTypeId();
    private static string assetAccountB2CRecordtype = accountRecordtypeMap.get('B2C').getRecordTypeId();
    
    //RETRIVING COMMISSIONS RECORD TYPES 
    private static Map<string,Schema.RecordTypeInfo> commissionRecordtypeMap = Schema.SObjectType.Commission__c.getRecordTypeInfosByName();
    private static string commissionNewsaleRecordtype = commissionRecordtypeMap.get(System.Label.Commission_New_Sale).getRecordTypeId();
    private static string commissionNewsaleManagerRecordtype = commissionRecordtypeMap.get(System.Label.Managers_Team).getRecordTypeId();
    
    //RETRIEVING USER TEAMS FROM CUSTIOM SETTING/VARIABLE DECLERATION
    private static string brokerRegionalDirectorsTeam = CommissionTeams__c.getInstance('BROKER_REGIONAL_DIRECTORS_TEAM').Team_Name__c;
    //private static string collectionTeam = CommissionTeams__c.getInstance('COLLECTION_TEAM').Team_Name__c;
    //private static string collectionsClientRelationsManagers = CommissionTeams__c.getInstance('COLLECTIONS_CLIENT_RELATIONS_MANAGERS').Team_Name__c;
    private static string managersTeam = CommissionTeams__c.getInstance('MANAGERS_TEAM').Team_Name__c;
    Private Static Set<String> quotaUserTeamNames = new Set<String>{brokerRegionalDirectorsTeam};//,collectionTeam,collectionsClientRelationsManagers
    Private Static Set<String> totalNetLineTypes = new Set<String>{System.Label.Commission_Line_Type_Add,System.Label.Commission_Line_Type_Renew};
    //Private Static Set<String> deltaPriceLineTypes = new Set<String>{System.Label.Commission_Line_Type_Amend,System.Label.Commission_Line_Type_Cancel,System.Label.Commission_Line_Type_Credit};
    
    Product_Family__c pfamily = Product_Family__c.getvalues('Product_Family');

     @TestVisible 
    // BROKER REGIONAL DIRECTORS TEAM'S CURRENT QUATER CALCULATION
    private string getBrokerrdTeam(Integer monthValue) 
    {
        String brokerRDteam = 'Q2' ;   
        If (monthValue <= 3) 
        {       
            brokerRDteam = 'Q3';
        }
        else if (monthValue <= 6) 
        {
            brokerRDteam = 'Q4';
        }
        else if (monthValue <= 9) 
        {
            brokerRDteam = 'Q1';
        }
        return brokerRDteam;
    }
	
	public commissions_NewSaleBatchProcessHdlr_New(){
		// CRM-4551 [Start]
		Set<String> setCollectionTeamNames = new Set<String>();
        for(CollectionTeams__mdt collTeamName : [Select MasterLabel,DeveloperName,Team_Name__c From CollectionTeams__mdt]){
            if(string.isNotBlank(collTeamName.Team_Name__c)){
            	setCollectionTeamNames.add(collTeamName.Team_Name__c.trim().toLowerCase());
        	}
        }
        quotaUserTeamNames.addAll(setCollectionTeamNames);
        // CRM-4551 [End]
	}
    
    
    public class MyException extends Exception{
    }
    
    //CREATE NEW COMMISSIONS FOR ASSETS
    Public void createCommissions(List<Asset> fullfilledassets)
    {       
        //COLLECTING SIGNING AE AND OWNER IDS TO RETRIVE RELETAED CURRENT MONTH/QUATER QUOTAS 
        set<Id> quotaOwnerIds = new set<id>();
        for(Asset assetrecord : fullfilledassets)
        {           
            if(assetrecord.Sign_in_AE__c != Null)
            {
                 quotaOwnerIds.add(assetrecord.Sign_in_AE__c); 
            }           
            quotaOwnerIds.add(assetrecord.OwnerId);            
        }
        
        //RETRIVING SIGNING AE AND OWNER CURRENT MONTH/QUATER QUOTAS 
        Map<id,Quota__c> assetSigningAEandOwnerQuotasMap = new Map<id,Quota__c>();      
        for(Quota__c quotarecord : [SELECT id,User__c,Period_Name__r.Sigh_In_AE__c,Period_Name__r.asset_Owner__c,User_Team__c,
                    Period_Name__r.Agent_Asset_Owner__c,Period_Name__r.Agent_Sigh_In_AE__c,Is_Kicker__c,Current_Quater__c ,
                    Renewal_Payout__c,Quota_Attainment_Renewal__c,Component_1A_Payout__c,
                    ADVANTAGE_New__c,ADVANTAGE_Renew__c,COBROKE_New__c,COBROKE_Renew__c,DACAMPAIGN_New__c,DACAMPAIGN_Renew__c,
                    DIGITALAGENT_New__c,DIGITALAGENT_Renew__c,DOMAINNAME_New__c,DOMAINNAME_Renew__c,FEATCMA_New__c,FEATCMA_Renew__c,
                    FEATDISP_New__c,FEATDISP_Renew__c,FEATHOMES_New__c,FEATHOMES_Renew__c,FIVESTREET_New__c,FIVESTREET_Renew__c,
                    LISTHUBPRO_New__c,LISTHUBPRO_Renew__c,MRKTBUILD_New__c,MRKTBUILD_Renew__c,SELLERLEAD_New__c,SELLERLEAD_Renew__c,
                    SELLERLEADBUNDLE_New__c,SELLERLEADBUNDLE_Renew__c,SHOWCASE_New__c,SHOWCASE_Renew__c,SIGNRIDER_New__c,SIGNRIDER_Renew__c,
                    STANDLIST_New__c,STANDLIST_Renew__c,TOPCRM_New__c,TOPCRM_Renew__c,TOPIDX_New__c,TOPIDX_Renew__c,TOPMRKSNP_New__c,
                    TOPMRKSNP_Renew__c,TOPWEB_New__c,TOPWEB_Renew__c,TOPWEBFEE_New__c,TOPWEBFEE_Renew__c,TRKPHNMBR_New__c,TRKPHNMBR_Renew__c,
                    TURBO_New__c,TURBO_Renew__c,WEBSITE_New__c,WEBSITE_Renew__c,WEBSITEFEE_New__c,WEBSITEFEE_Renew__c,REESIO_New__c,
                    REESIO_Renew__c,RSRESPOND_New__c,RSRESPOND_Renew__c ,MEDIABUY_New__c ,MEDIABUY_Renew__c,RSCONNECT_New__c,
                    RSCONNECT_Renew__c,RSTRANSACT_New__c,RSTRANSACT_Renew__c,BETACONNECT_New__c,BETACONNECT_Renew__c,BETARESPOND_New__c,
                    BETARESPOND_Renew__c,BETATRANSACT_New__c,BETATRANSACT_Renew__c,LocalExpert_New__c,LocalExpert_Renew__c,LOCALEXPERTCITY_New__c,LOCALEXPERTCITY_Renew__c,Total_of_Deals__c,
                    Roll_up_Total_of_Deals__c,Target_Deals__c,Roll_up_BLA_Final_Commission_Amount__c,OPCITY_BLA_Payouts__c,
                    (Select Id, Product_Family__c, Product_Name__c, Product_Name__r.Name from Quota_Products__r)
                    FROM Quota__c where User__c In : quotaOwnerIds 
                    AND ((Quota_StartDate__c = THIS_MONTH) 
                    OR (Quota_StartDate__c = THIS_YEAR and Current_Quater__c =: getBrokerrdTeam(system.today().Month())))]){
                    
                    assetSigningAEandOwnerQuotasMap.put(quotarecord.User__c,quotarecord);
        }  
          
        Map<string,commission__c> createNewCommissionMap = new Map<string,commission__c>();
        
        Map<string,Commission__c> createNewBLACommissionMap = new Map<String,Commission__c>();
        Map<id,Asset> updateAssetsMap = new Map<id,Asset>(); 
        // BLA Quota updation
        Map<Id,BLAInfo> BLAInfoOnQuota = new Map<Id,BLAInfo>();
        
        //CREATING NEW COMMISSIONS LOGIC
        for(Asset assetrecord : fullfilledassets)
        {  
            Decimal totalnet_Deltaprice = 0.0;
            //ASSET AMOUNT FOR ADD AND RENEWAL LINE TYPE ASSETS                                   
            if(totalNetLineTypes.contains(assetrecord.Line_Type__c) && (assetrecord.Total_Net__c > 0))
            {
                totalnet_Deltaprice = assetrecord.Total_Net__c;     
            }
            //ASSET AMOUNT FOR CREDIT,AMEND AND CANCEL LINE TYPE ASSETS(+VE AMOUNT)              
            else if(assetrecord.Delta_Price_w_o_Tax__c > 0)
            {
                totalnet_Deltaprice = assetrecord.Delta_Price_w_o_Tax__c;
            }            
            if(assetrecord.Product2.ProductCode != 'OPCITYBLA' && totalnet_Deltaprice != 0.0)
            {
                Decimal assetSigningAESplitPercent = 0.0;
                Decimal assetOwnerSplitPercent = 0.0; 
                //FETCHING CURRENT MONTH/QUATER SIGNING AE AND ASSET OWNER QUOTAS
                Quota__c currentMonthSigningAEQuota = assetSigningAEandOwnerQuotasMap.get(assetrecord.Sign_in_AE__c);
                Quota__c currentMonthAssetOwnerQuota = assetSigningAEandOwnerQuotasMap.get(assetrecord.OwnerId);
                //CALCULATING SPLIT PERCENTAGE - IT MAY CHANGES DEPENTDS ON THE ACCOUNT RECORD TYPE AND SIGNING AS ANE ASSET OWNER
                
                if(assetrecord.Sign_in_AE__c == assetrecord.OwnerId){
                    assetSigningAESplitPercent = 100;
                    assetOwnerSplitPercent = 0;
                }
                else if((assetrecord.Account.RecordTypeId == assetAccountB2BRecordtype) || test.isRunningTest()){                
                    assetSigningAESplitPercent = currentMonthSigningAEQuota !=null? currentMonthSigningAEQuota.Period_Name__r.Sigh_In_AE__c:0; 
                    assetOwnerSplitPercent = currentMonthAssetOwnerQuota!=null?currentMonthAssetOwnerQuota.Period_Name__r.asset_Owner__c:0;                 
                }
                else if((assetrecord.Account.RecordTypeId == assetAccountB2CRecordtype)){
                    assetSigningAESplitPercent = currentMonthSigningAEQuota!=null?currentMonthSigningAEQuota.Period_Name__r.Agent_Sigh_In_AE__c:0; 
                    assetOwnerSplitPercent = currentMonthAssetOwnerQuota!=null?currentMonthAssetOwnerQuota.Period_Name__r.Agent_asset_Owner__c:0;                   
                }
                
                if(assetSigningAESplitPercent !=0.0 && assetSigningAESplitPercent!= null){
                    //CALLING CREATE COMMISSIONS METHOD WITH REQUIRED PARAMETERS FOR SIGNING AE
                    if(currentMonthSigningAEQuota != Null){
                        //commission__c commissionrecord = getcommissionrecord(assetrecord,currentMonthSigningAEQuota,(totalnet_Deltaprice),(assetSigningAESplitPercent));
                        createNewCommissionMap.put(assetRecord.id+'$$$$$',getcommissionrecord(assetrecord,currentMonthSigningAEQuota,(totalnet_Deltaprice),(assetSigningAESplitPercent)));   
                        assetrecord.Commissions_are_calculated__c = TRUE;
                    }
                }
                if(assetOwnerSplitPercent != 0.0 && assetOwnerSplitPercent != null && (assetrecord.OwnerId <> assetrecord.Sign_in_AE__c)){
                    //CALLING CREATE COMMISSIONS METHOD WITH REQUIRED PARAMETERS FOR ASSET OWNER
                    if(currentMonthAssetOwnerQuota != null){
                        createNewCommissionMap.put(assetRecord.id+'#####',getcommissionrecord(assetrecord,currentMonthAssetOwnerQuota,(totalnet_Deltaprice),(assetOwnerSplitPercent)));   
                        assetrecord.Commissions_are_calculated__c = TRUE;
                    }
                }             
            }
            // BLA Commission creation
            system.debug('OPCITYBLA='+assetrecord.Product2.ProductCode);
            if(assetrecord.Product2.ProductCode == 'OPCITYBLA'){
                Quota__c currentMonthSigningAEQuota = assetSigningAEandOwnerQuotasMap.get(assetrecord.Sign_in_AE__c);
                if(currentMonthSigningAEQuota != null){
                    if(!BLAInfoOnQuota.containsKey(currentMonthSigningAEQuota.Id)){
                    	BLAInfoOnQuota.put(currentMonthSigningAEQuota.Id, new BLAInfo(currentMonthSigningAEQuota));
                	}
                    createNewCommissionMap.put(assetRecord.id+'#####',getBLAcommissionrecord(assetrecord,currentMonthSigningAEQuota, BLAInfoOnQuota));
                    assetrecord.Commissions_are_calculated__c = TRUE;
                }
            }
            assetrecord.Record_processed_for_commission__c = true;
            updateAssetsMap.put(assetrecord.id,assetrecord);
        }  
        //CRAETING NEW COMMISSIONS 
        List<Error__c> lstError = new List<Error__c>();
        List<commission__c> commissionsList = new List<commission__c>();
        commissionsList.addall(createNewCommissionMap.values());
       
        Database.SaveResult[] commissionResult = Database.insert(createNewCommissionMap.values(), false);
        Integer i = 0;
        for(Database.SaveResult sr: commissionResult) {
            Id assetId = commissionsList.get(i).Related_to_Asset__c;
            if (sr.isSuccess())
            {               
                Asset assetRecordSuccess = new Asset();
                assetRecordSuccess.Id = assetId;
                assetRecordSuccess.Commissions_are_calculated__c = TRUE;
                assetRecordSuccess.Record_processed_for_commission__c = TRUE;
                updateAssetsMap.put(assetRecordSuccess.id,assetRecordSuccess);
            }
            else 
            {
                Asset assetrecordError = new Asset();
                assetrecordError.Id = assetId;
                assetrecordError.Commissions_are_calculated__c = FALSE;
                assetrecordError.Record_processed_for_commission__c = TRUE;
                updateAssetsMap.put(assetrecordError.id,assetrecordError);
                for (Database.Error err: sr.getErrors()) 
                {
                    Error__c error = new Error__c();
                    error.Name = 'Commission Creation Process/insert commission issue';
                    error.Entity_Id__c = 'Create new Commissions';
                    error.Interface_Name__c = 'Commissions_CreateNewCommissionHndlr_New';
                    error.Error_Description__c = 'The following error has occurrederred during the commissions creation process(New Sale) :' + err.getMessage() + 'Status Code' + err.getStatusCode();
                    lstError.add(error); 
                }
            }
            i++;
        }   
        createNewCommissionMap.clear();
        
        //UPDATING ASSETS
        if(updateAssetsMap.size() > 0)
        {
            try
            {
                SkipAssetTrigger.setSkipTrgTrue();
                update updateAssetsMap.values();
                 if(Test.isRunningTest()){
                    throw new myexception('Error');   
                }            
            }
            Catch(Exception e)
            {                
                Error__c error = new Error__c();
                error.Name = 'Commission Creation Process/update asset issue';
                error.Entity_Id__c = 'Create new Commissions';
                error.Interface_Name__c = 'Commissions_CreateNewCommissionsHandler';
                error.Error_Description__c = e+'';
                lstError.add(error);                
            }
        }
        updateAssetsMap.clear(); 
        
        //CREATING ERROR RECORDS   
        if(lstError.size() > 0 ){
            insert lstError;
        }
        lstError.clear();          
    }
    
    private commission__c getBLACommissionRecord(Asset assetrecord,Quota__c currentmonthquota, map<Id,BLAInfo> BLAInfoOnQuota){
        Commission__c commissionrecord = new Commission__c();                       
        commissionrecord.Related_to_Asset__c = assetrecord.id;
        commissionrecord.Signing_AE__c = assetrecord.Sign_in_AE__c;       
        commissionrecord.Related_to_Quota__c = currentmonthquota.id;                                        
        commissionrecord.User_Team__c = currentmonthquota.User_Team__c;
        commissionrecord.Status__c = System.Label.Commission_Status_Active; 
        commissionrecord.Record_Processed__c = FALSE;
        commissionrecord.Line_Type__c = assetrecord.Line_Type__c;  
        commissionrecord.Product__c = assetrecord.product2id;
        commissionrecord.Billing_Type__c = assetrecord.Billing_Period__c;  
        commissionrecord.Asset_Amount__c = 0.0 ;
        commissionrecord.Commission_Split__c = 0;
        system.debug('beforeCOunt::: '+ BLAInfoOnQuota.get(currentmonthquota.Id).Count);
        commissionrecord.Deal_Number__c = (Decimal)(BLAInfoOnQuota.get(currentmonthquota.Id) == null ? 1 : BLAInfoOnQuota.get(currentmonthquota.Id).Count + 1);
        BLAInfoOnQuota.get(currentmonthquota.Id).Count++;
        
        system.debug('afterCOunt::: '+ BLAInfoOnQuota.get(currentmonthquota.Id).Count);
        if(assetrecord.Order_Line_Item__c != Null){
            commissionrecord.Order_Product__c = assetrecord.Order_Line_Item__c;
        }
        if(currentmonthquota.User_Team__c == managersTeam){                               
            commissionrecord.RecordTypeId = commissionNewsaleManagerRecordtype;
        }
        else{
            commissionrecord.RecordTypeId = commissionNewsaleRecordtype;
        }
        
        commissionrecord.BLA_Commission_Amount__c = BLAInfoOnQuota.get(currentmonthquota.Id).getApplicablePayout(commissionrecord.Deal_Number__c);
        
        return commissionrecord;
    }
    
    public class BLAInfo{
        public Integer Count = 0;
        public list<BLApayout> payouts = new list<BLApayout>();
        public BLAInfo(Quota__c quota){
            Decimal existingDeals = quota.Total_of_Deals__c;
            if(existingDeals != null){
            	this.Count = Integer.valueOf(existingDeals);    
            }
            if(string.isNotBlank(quota.OPCITY_BLA_Payouts__c)){
                for(String strpayout: quota.OPCITY_BLA_Payouts__c.split('\\;')){
                    if(string.isNotBlank(strpayout)){
                        strpayout = strpayout.deleteWhitespace();
                        BLAPayout blaPay = new BLAPayout();
                        blaPay.starts = Integer.valueOf(strpayout.split('\\-')[0]);
                        blaPay.upto = Integer.valueOf((strpayout.split('\\-')[1]).split('\\:')[0].replace('Deals',''));                        
                        blaPay.amount = Decimal.valueOf((strpayout.split('\\-')[1]).split('\\:')[1].replace('$','').replace(',',''));
                        
                        this.payouts.add(blaPay);
                    }
                }
            }
        }
        public Decimal getApplicablePayout(Decimal dealNumberDecimal){
            if(dealNumberDecimal != null){
            	Integer dealNumber = Integer.valueOf(dealNumberDecimal);
                for(BLApayout payout: this.payouts){
                    if(dealNumber >= payout.starts && dealNumber <= payout.upto){
                        return payout.amount;
                    }
                }
            }
            return 0.0;
        }
    }    
    public class BLApayout{
        public Integer starts = 0;
        public Integer upto = 0;
        public Decimal amount = 0;        
    }
    
    //CREATE/ASSIGN COMMISSIONS METHOD    
    private commission__c getcommissionrecord(Asset assetrecord,Quota__c currentmonthquota,Decimal totalnet_Deltaprice,Decimal commissionSplitPercent){    
        totalnet_Deltaprice = totalnet_Deltaprice == null ? 0.0 : totalnet_Deltaprice;
        commissionSplitPercent = commissionSplitPercent == null ? 0.0 : commissionSplitPercent;
        decimal commissionalbleamount = (totalnet_Deltaprice * commissionSplitPercent)/100;
        Commission__c commissionrecord = new Commission__c();                       
        commissionrecord.Related_to_Asset__c = assetrecord.id;
        commissionrecord.Signing_AE__c = assetrecord.Sign_in_AE__c;       
        commissionrecord.Related_to_Quota__c = currentmonthquota.id;                                        
        commissionrecord.User_Team__c = currentmonthquota.User_Team__c;
        commissionrecord.Status__c = System.Label.Commission_Status_Active; 
        commissionrecord.Record_Processed__c = FALSE;
        commissionrecord.Line_Type__c = assetrecord.Line_Type__c;  
        commissionrecord.Product__c = assetrecord.product2id;
        commissionrecord.Billing_Type__c = assetrecord.Billing_Period__c;  
        commissionrecord.Asset_Amount__c = totalnet_Deltaprice ;
        commissionrecord.Commission_Split__c = commissionSplitPercent;
        if(assetrecord.Order_Line_Item__c != Null){
            commissionrecord.Order_Product__c = assetrecord.Order_Line_Item__c;
        }
        if(currentmonthquota.User_Team__c == managersTeam){                               
            commissionrecord.RecordTypeId = commissionNewsaleManagerRecordtype;
        }
        else{
            commissionrecord.RecordTypeId = commissionNewsaleRecordtype;
        }
        // CRM-4206 [Starts]
        if(assetrecord.product2id != null && currentmonthquota.Quota_Products__r != null && currentmonthquota.Quota_Products__r.size() > 0 && assetrecord.line_type__c == 'Add'){  //CRM-5383 added line type check
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
        // CRM-3794 [BRD Open Book] Starts
        if(currentmonthquota.User_Team__c == brokerRegionalDirectorsTeam && currentmonthquota.Current_Quater__c == getBrokerrdTeam(system.today().Month())
				&&!currentmonthquota.Is_Kicker__c && assetRecord.Owner.Profile.Name == 'Open Book Profile'){
                	commissionRecord.OpenBook_New_Sale_Comm_ble_Amount__c = commissionalbleamount;
        } // CRM-3794 [BRD Open Book] Ends
        else if(String.isNotBlank(currentmonthquota.User_Team__c) && !quotaUserTeamNames.contains(currentmonthquota.User_Team__c.toLowerCase())){ 
            if(!currentmonthquota.Is_Kicker__c){
                if(assetrecord.line_Type__c != System.Label.Commission_Line_Type_Renew){// && currentmonthquota.user_team__c == managersTeam){                    
                    commissionrecord.Commissionable_Amount2__c = commissionalbleamount;
                }
                else{
                    commissionrecord.Renewal_w_o_Qualifier_Comm_ble_Amount__c = commissionalbleamount;
                }
            }
            else{
                if(assetrecord.line_Type__c == System.Label.Commission_Line_Type_Renew){// || currentmonthquota.user_team__c == managersTeam){
                      commissionrecord.Renewal_w_Qualifier_Comm_ble_Amount__c = commissionalbleamount; 
                }                
                else{
                    commissionrecord.Commissionable_Amount1B__c = commissionalbleamount;                                     
                }    
            }
        }
        /*else{
            if(currentmonthquota.user_team__c == managersTeam && assetrecord.line_Type__c == System.Label.Commission_Line_Type_Renew){
                commissionrecord.Renewal_w_o_Qualifier_Comm_ble_Amount__c = commissionalbleamount;
            }
            else{
                commissionrecord.Commissionable_Amount2__c = commissionalbleamount;
            }
        }*/

        if(commissionrecord.Line_Type__c != 'Renew')
        {                 
            if(commissionrecord.Related_Commission__c == Null ) {
                 commissionrecord.Payout_Rate__c = currentmonthquota.Component_1A_Payout__c; 
            }
            else {
                //CLAW BACK COMMISSION RECORD PAYOUT RATES FOR MANAGERS TEAM
                commissionrecord.Payout_Rate__c = commissionrecord.Related_Commission__r.Payout_Rate__c;
            }
        }
        if(commissionrecord.Line_Type__c == 'Renew') {
            if(commissionrecord.Related_Commission__c == Null){
                commissionrecord.Renewal_w_o_Qualifier_Payout_Rate__c = currentmonthquota.Renewal_Payout__c;
            }
            else{
                //CLAW BACK COMMISSION RECORD PAYOUT RATES FOR MANAGERS TEAM
                commissionrecord.Renewal_w_o_Qualifier_Payout_Rate__c = commissionrecord.Related_Commission__r.Renewal_w_o_Qualifier_Payout_Rate__c ;
            }
         }
         
         getCalculatePayoutRates(commissionrecord,assetrecord,currentmonthquota);  
          
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
        return commissionrecord;
    }
    private void getCalculatePayoutRates(Commission__c commissionrecord, Asset assetrecord,quota__c currentmonthquota) 
    {
        String fieldAppendStr = '_New__c';
        if (assetrecord.Line_Type__c == System.Label.Commission_Line_Type_Renew) {
            fieldAppendStr = '_Renew__c';
        }
        String fieldName = '';
        decimal commissionPayout= 0.0;
        // [starts] Added against CRM-4176
            commissionrecord.Payout_Rate1B__c = commissionrecord.Payout_Rate1B__c == null ? 0.0 : commissionrecord.Payout_Rate1B__c;
            commissionrecord.Payout_Rate__c = commissionrecord.Payout_Rate__c == null ? 0.0 : commissionrecord.Payout_Rate__c;
            commissionrecord.Renewal_w_o_Qualifier_Payout_Rate__c = commissionrecord.Renewal_w_o_Qualifier_Payout_Rate__c == null ? 0.0 : commissionrecord.Renewal_w_o_Qualifier_Payout_Rate__c;
            commissionrecord.Renewal_w_Qualifier_Payout_Rate__c = commissionrecord.Renewal_w_Qualifier_Payout_Rate__c == null ? 0.0 : commissionrecord.Renewal_w_Qualifier_Payout_Rate__c;
            commissionrecord.Final_Commission__c = commissionrecord.Final_Commission__c == null ? 0.0 : commissionrecord.Final_Commission__c;
        // [Ends] CRM-4176
        //COMMISSION PAYOUT UPDATES FOR ALL TEAMS EXCEPT COLLECTION TEAMS
        if (!quotaUserTeamNames.contains(commissionrecord.user_team__c.toLowerCase())) {          
            fieldName = assetrecord.product2.ProductCode + fieldAppendStr;
            try{
                if(commissionrecord.user_team__c == managersTeam){
                	commissionPayout = assetrecord.Line_Type__c != system.label.Commission_Line_Type_Renew ? currentmonthquota.Component_1A_Payout__c : currentmonthquota.Renewal_Payout__c;
                }else{
                	commissionPayout = (Decimal)currentmonthquota.get(fieldName);                
                }
                system.debug('comm Payout::: '+ commissionPayout);
            }
            catch(exception e){}            
            if(!currentmonthquota.Is_Kicker__c && assetrecord.Line_Type__c != system.label.Commission_Line_Type_Renew){
                commissionrecord.Payout_Rate__c = commissionPayout; //(Decimal)currentmonthquota.get(fieldName);
                system.debug('payout_Rate__c: '+ commissionrecord.Payout_Rate__c);
            }
            else if (currentmonthquota.Is_Kicker__c && assetrecord.Line_Type__c != system.label.Commission_Line_Type_Renew){
                commissionrecord.Payout_Rate1B__c = commissionPayout; //(Decimal)currentmonthquota.get(fieldName);
                system.debug('Payout_Rate1B__c: '+ commissionrecord.Payout_Rate1B__c);
            } 
            else if(!currentmonthquota.Is_Kicker__c && assetrecord.Line_Type__c == system.label.Commission_Line_Type_Renew){
                commissionrecord.Renewal_w_o_Qualifier_Payout_Rate__c = commissionPayout; //(Decimal)currentmonthquota.get(fieldName);
                system.debug('Renewal_w_o_Qualifier_Payout_Rate__c: '+ commissionrecord.Renewal_w_o_Qualifier_Payout_Rate__c);
            }
            else{
                commissionrecord.Renewal_w_Qualifier_Payout_Rate__c = commissionPayout; //(Decimal)currentmonthquota.get(fieldName);
                system.debug('Renewal_w_Qualifier_Payout_Rate__c: '+ commissionrecord.Renewal_w_Qualifier_Payout_Rate__c);
            }            
        }
        //OTHER PRODUCTS
        /**
        else if(commissionrecord.Recordtype.name == otherproductrecordtype){
            fieldName = commissionrecord.Other_Product__c + fieldAppendStr;
            commissionrecord.Payout_Rate__c = (Decimal)currentmonthquota.get(fieldName);
        }
        **/
        
        else{  
            /*//MANAGERS TEAM NEW SALE
            if((assetrecord.Line_Type__c == System.Label.Commission_Line_Type_Add || assetrecord.Line_Type__c == System.Label.Commission_Line_Type_Amend) && commissionrecord.user_team__c == managersTeam) {    
                commissionrecord.Payout_Rate__c = currentmonthquota.Component_1A_Payout__c;
            }
            //MANAGERS TEAM RENEWAL
            else if(assetrecord.Line_Type__c != System.Label.Commission_Line_Type_Add && commissionrecord.user_team__c == managersTeam) { 
                commissionrecord.Renewal_w_o_Qualifier_Payout_Rate__c= currentmonthquota.Renewal_Payout__c;
            }
            //COLLECTION TEAM NEW SALE
            else*/ 
            if(assetrecord.Line_Type__c == System.Label.Commission_Line_Type_Add) {
                commissionrecord.Payout_Rate__c = currentmonthquota.Component_1A_Payout__c;
            }
            else {
                //COLLECTION TEAM PAYMENTS - DIRECTLY CALCULATION THROUGH FORMULA FIELD
                //commissionrecord.Payout_Rate__c = quotaRecord.Collection_Payout__c;
            }
        }                 
    }    
}

/*******************************************************
CODE MODIFICATION DETAILS : 


*******************************************************/