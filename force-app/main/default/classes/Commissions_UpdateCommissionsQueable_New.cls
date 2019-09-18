public class Commissions_UpdateCommissionsQueable_New implements Queueable {
    private static string brokerRegionalDirectorsTeam = CommissionTeams__c.getInstance('BROKER_REGIONAL_DIRECTORS_TEAM').Team_Name__c;
    //private static string collectionTeam = CommissionTeams__c.getInstance('COLLECTION_TEAM').Team_Name__c;
    //private static string collectionsClientRelationsManagers = CommissionTeams__c.getInstance('COLLECTIONS_CLIENT_RELATIONS_MANAGERS').Team_Name__c;
    private static string managersTeam = CommissionTeams__c.getInstance('MANAGERS_TEAM').Team_Name__c;
    private static Set<String> quotaUserTeamNames = new Set<String>{brokerRegionalDirectorsTeam};//,collectionTeam,collectionsClientRelationsManagers
    private static Map<string,Schema.RecordTypeInfo> commissionRecordtypeMap = Schema.SObjectType.Commission__c.getRecordTypeInfosByName();
    private static string otherproductrecordtype = commissionRecordtypeMap.get(System.Label.Other_Product_Record_Type).getRecordTypeId();
    private static string managerrecordtype= commissionRecordtypeMap.get(System.Label.Managers_Team).getRecordTypeId();       
    
    public final List<List<Commission__c>> listCommissionsToUpdate;
    
    public set<Id> commissionIdsToExclude;
    public final map<Id,Quota__c> mapQuotaRec;
    
    // Constructors
    public Commissions_UpdateCommissionsQueable_New(List<List<Commission__c>> input) {
        listCommissionsToUpdate = input;
    }
    public Commissions_UpdateCommissionsQueable_New(map<Id,Quota__c> mapQuotas, set<Id> setCommissionIds) {
        this.mapQuotaRec = mapQuotas;
        this.commissionIdsToExclude = setCommissionIds;
    }
	
	public Commissions_UpdateCommissionsQueable_New(){
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
    
    // Execute Queueable
    public void execute(QueueableContext context) {
    	if(mapQuotaRec != null && mapQuotaRec != null && mapQuotaRec.size() > 0){
    		if(commissionIdsToExclude == null){
    			commissionIdsToExclude = new set<Id>();
    		}
    		//RETRIVING COMMISSION RECORDS TO UPDATE THE LATEST PAYOUTS
	        Integer iLimit = 1000;
	        map<Id,Commission__c> mapCommissionsToProcess = new map<Id,Commission__c>([Select id,Name,Final_Commission__c,Product__r.ProductCode,Related_to_Quota__c,Line_Type__c,Payout_Rate__c,Commission_Split__c,Asset_Amount__c,
		                                                  Payout_Rate1B__c ,RecordType.Name,Renewal_w_o_Qualifier_Payout_Rate__c,Renewal_w_Qualifier_Payout_Rate__c,Commissionable_Amount2__c,Commissionable_Amount1B__c,
		                                                  Renewal_w_o_Qualifier_Comm_ble_Amount__c,Renewal_w_Qualifier_Comm_ble_Amount__c,User_Team__c,Related_Commission__c, Product_Category__c,
		                                                  Related_Commission__r.Payout_Rate__c,Other_Product__c,Related_Commission__r.Payout_Rate1B__c,Related_Commission__r.Renewal_w_o_Qualifier_Payout_Rate__c,Related_Commission__r.Renewal_w_Qualifier_Payout_Rate__c,
		                                                  Related_Commission__r.CFCB_NEW_w_Qualifier_Payout_Rate1__c,Related_Commission__r.CFCB_New_w_o_Qualifier_Payout_Rate1__c,Related_Commission__r.CFCB_RNW_w_Qualifier_Payout_Rate1__c,
		                                                  Related_Commission__r.CFCB_RNW_w_o_Qualifier_Payout_Rate1__c,Related_Commission__r.CreatedDate,Related_Commission__r.Asset_Owner_Payout_Rate1__c,
		                                                  Related_Commission__r.Historic_CFCB_NewSale_With_Q_Payout__c,Related_Commission__r.Historic_CFCB_New_Sale_w_o_Qualifier_Pay__c,
		                                                  Related_Commission__r.Historic_CFCB_RNW_W_Q_Payout_Rate__c,Related_Commission__r.Historic_CFCB_RNW_w_o_Q_Payout_Rate__c,Related_Commission__r.Historic_Asset_Owner_Payout_Rate__c,
		                                                  Related_Commission__r.HistoricNew_Sale_W_OQualifier_PayoutRate__c,Related_Commission__r.HistorNew_Sale_WithQualifier_Payout_Rate__c,
                                                          Related_to_Quota__r.BLA_Tier_Changed__c,Deal_Number__c,BLA_Commission_Amount__c,// BLA Fields
		                                                  Total_Clawback_Commission__c, Total_Clawback_Commission_RD__c
	                                                  from Commission__c 
	                                                  where Related_to_Quota__c In :mapQuotaRec.keySet() 
	                                                  	AND ((Related_to_Quota__r.BLA_Tier_Changed__c = true AND Product__r.ProductCode = 'OPCITYBLA') OR (RecordType.Name != :Commissions_Constants.COMMISSIONS_CLAWBACK))	//updated for BLA 
	                                                  	AND Id NOT IN :commissionIdsToExclude  LIMIT :iLimit]);
	            if(mapCommissionsToProcess.size() > 0){
					//PayoutCalcuationOnCommission
		    		commissionIdsToExclude.addAll( payoutCalculation(mapQuotaRec, mapCommissionsToProcess) );
		    		
		    		if(!Test.isRunningTest()){
		    			System.enqueueJob(new Commissions_UpdateCommissionsQueable_New(mapQuotaRec, commissionIdsToExclude));
		    		}
	            }
	            else{
	            	for(Quota__c processedQuota : mapQuotaRec.values()){
	            		processedQuota.New_Sale_Tier_Changed__c = false;
	            		processedQuota.Renewal_Tier_Changed__c = false;
                    	processedQuota.BLA_Tier_Changed__c = FALSE;
	            	}
	            	update mapQuotaRec.values();
	            }
    		
    	}else{
	    	if(listCommissionsToUpdate != null && listCommissionsToUpdate.size() > 0){
	    		update listCommissionsToUpdate[0];
	    	}
	    	listCommissionsToUpdate.remove(0);
	    	if(listCommissionsToUpdate != null && listCommissionsToUpdate.size() > 0){
	    		System.enqueueJob(new Commissions_UpdateCommissionsQueable_New(listCommissionsToUpdate));
	    	}
    	}
    }

    // BLA Commission ticket
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
                        blaPay.upto = Integer.valueOf((strpayout.split('\\-')[1]).split('\\:')[0]);                        
                        blaPay.amount = Decimal.valueOf((strpayout.split('\\-')[1]).split('\\:')[1]);
                        
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
    // BLA Commission ticket    
    //PAYOUT CALCULATION METHOD IN COMMISSION LEVEL - PAYOUT CALCULATION FOR COMMISSIONS LOGIC START
    Public set<Id> payoutCalculation(Map<Id,Quota__c> mapQuotas, map<Id,Commission__c> mapCommissionsToProcess){
        list<Commission__c> commssionsToUpdate = new list<Commission__c> ();
        Map<Id,BLAInfo> mapQuotaBLAInfo = new Map<Id,BLAInfo>();
        
        if(mapCommissionsToProcess != null && mapCommissionsToProcess.size() > 0){
	  		for(Commission__c commissionrecord : mapCommissionsToProcess.values()){
	          	//FETCHING COMMISSION RELATED QUOTA
	            Quota__c quotaRecord = mapQuotas.get(commissionrecord.Related_to_Quota__c);   
	            Boolean isManagerTeam = commissionrecord.User_Team__c == managersTeam;
	              
				//BLA Commissions update
                if(quotaRecord.BLA_Tier_Changed__c && commissionrecord.Product__r.ProductCode == 'OPCITYBLA' && commissionrecord.Deal_Number__c != null){
                    if(!mapQuotaBLAInfo.containsKey(quotaRecord.Id)){
                        mapQuotaBLAInfo.put(quotaRecord.Id, new BLAInfo(quotaRecord));
                    }
                    commissionrecord.BLA_Commission_Amount__c = mapQuotaBLAInfo.get(quotaRecord.Id).getApplicablePayout(commissionrecord.Deal_Number__c);
                }
	            //UPDATE ALL COMMISSION RECORDS WITH LATEST PAYOUT VALUES EXCEPT CLAWBACK COMMISSIONS 
	            if (commissionrecord.Related_Commission__c == Null) {                
	                //UPDATING ONLY NEW SALE/ADD COMMISSIONS IF TIER VALUES CHANGE
	                system.debug('>>>>>>>>>> 123 :'+quotaRecord.New_Sale_Tier_Changed__c);
	                if(quotaRecord.New_Sale_Tier_Changed__c && (commissionrecord.Line_Type__c == 'Add' || commissionrecord.Line_Type__c == 'Amend')){    
	                    getCalculatePayoutRates(commissionrecord, true, isManagerTeam, quotaRecord);
	                    commssionsToUpdate.add(commissionrecord);
	                }
	                //UPDATING ONLY RENEWAL COMMISSIONS IF TIER VALUES CHANGE               
	                else if(quotaRecord.Renewal_Tier_Changed__c && commissionrecord.Line_Type__c == 'Renew'){
	                    getCalculatePayoutRates(commissionrecord, false, isManagerTeam, quotaRecord);
	                    commssionsToUpdate.add(commissionrecord);
	                }
	            }					
	        }
	        if(commssionsToUpdate.size() > 0){
    			update commssionsToUpdate;
	        }
    		return mapCommissionsToProcess.keySet();
        }
        
        return new set<Id>();
    }
    
    //UPDATING LATEST PRODUCT PAYOUTS IN COMMSISSION RECORDS FOR NEW AND RENEWAL COMMISSIONS
    private void getCalculatePayoutRates(Commission__c commissionrecord, Boolean isNew, Boolean isManagerTeam, Quota__c quotaRecord) {
        String fieldAppendStr = '_New__c';
        if (!isNew) {
            fieldAppendStr = '_Renew__c';
        }
        String fieldName = '';
        decimal productPayout = 0.0;        
        decimal commissionalbleamount = (commissionrecord.Asset_Amount__c * commissionrecord.Commission_Split__c)/100 ;
       	// CRM-4524 Starts
       	if(commissionrecord.RecordtypeId == otherproductrecordtype){
       		commissionalbleamount = commissionrecord.Commissionable_Amount2__c;
        }
        // CRM 4524 End.
		commissionrecord.Payout_Rate__c = 0.0;
		commissionrecord.Payout_Rate1B__c = 0.0;
		commissionrecord.Renewal_w_o_Qualifier_Comm_ble_Amount__c = 0.0;
		commissionrecord.Renewal_w_o_Qualifier_Payout_Rate__c = 0.0;
		commissionrecord.Renewal_w_Qualifier_Comm_ble_Amount__c = 0.0;
		commissionrecord.Renewal_w_Qualifier_Payout_Rate__c =  0.0;
		commissionrecord.Commissionable_Amount1B__c = 0.0;
		commissionrecord.Commissionable_Amount2__c = 0.0;
		system.debug('commissionrecord.Product__r.ProductCode :: '+ commissionrecord.Product__r.ProductCode);
		        
        //COMMISSION PAYOUT UPDATES FOR ALL TEAMS EXCEPT COLLECTION TEAMS
        if (commissionrecord.RecordtypeId != otherproductrecordtype && !isManagerTeam && String.isNotBlank(commissionrecord.User_Team__c) && !quotaUserTeamNames.contains(commissionrecord.User_Team__c.toLowerCase())) {	// CRM-4524 added condition for other product
            fieldName = commissionrecord.Product__r.ProductCode + fieldAppendStr;
            try{
                productPayout = (Decimal)quotaRecord.get(fieldName);
            }
            catch(Exception e){}
            if(!quotaRecord.Is_Kicker__c){
                if(isNew){
                    commissionrecord.Payout_Rate__c = productPayout;//(Decimal)quotaRecord.get(fieldName);
                    commissionrecord.Commissionable_Amount2__c = commissionalbleamount;
                }
                else{
                    commissionrecord.Renewal_w_o_Qualifier_Payout_Rate__c = productPayout;
                    commissionrecord.Renewal_w_o_Qualifier_Comm_ble_Amount__c = commissionalbleamount;
                }
            }
            else{
                if(isNew){
                    commissionrecord.Payout_Rate1B__c = productPayout;//(Decimal)quotaRecord.get(fieldName);
                    commissionrecord.Commissionable_Amount1B__c = commissionalbleamount;
                }
                else{
                    commissionrecord.Renewal_w_Qualifier_Payout_Rate__c = productPayout;
                    commissionrecord.Renewal_w_Qualifier_Comm_ble_Amount__c = commissionalbleamount;
                }
            } 
        }
        //OTHER PRODUCTS
        else if(commissionrecord.RecordtypeId == otherproductrecordtype){
            fieldName = commissionrecord.Product__r.ProductCode + fieldAppendStr;		//fieldName = commissionrecord.Other_Product__c + fieldAppendStr;
            commissionrecord.Payout_Rate__c = (Decimal)quotaRecord.get(fieldName);
            //commissionalbleamount = 100;
            commissionrecord.Commissionable_Amount2__c = commissionalbleamount;
        }
        else{  
            //MANAGERS TEAM NEW SALE
            if(isNew && isManagerTeam ){    
                commissionrecord.Payout_Rate__c = quotaRecord.Component_1A_Payout__c;
                commissionrecord.Commissionable_Amount2__c = commissionalbleamount;
            }
            //MANAGERS TEAM RENEWAL
            else if(!isNew && isManagerTeam ){
                commissionrecord.Renewal_w_o_Qualifier_Payout_Rate__c= quotaRecord.Renewal_Payout__c;
                commissionrecord.Renewal_w_o_Qualifier_Comm_ble_Amount__c = commissionalbleamount;
            }
            //COLLECTION TEAM NEW SALE
            else if(isNew){
                commissionrecord.Payout_Rate__c = quotaRecord.Component_1A_Payout__c;
                commissionrecord.Commissionable_Amount2__c = commissionalbleamount;
            }
            else{
                //COLLECTION TEAM PAYMENTS - DIRECTLY CALCULATION THROUGH FORMULA FIELD
                //commissionrecord.Payout_Rate__c = quotaRecord.Collection_Payout__c;
                //commissionrecord.Commissionable_Amount2__c = commissionalbleamount;
            }
        } 
        // [CRM-4335] Starts
		commissionrecord.Commissionable_Amount2__c = commissionrecord.Commissionable_Amount2__c == null ? 0.0 : commissionrecord.Commissionable_Amount2__c;
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
         // [CRM-4335] Ends            
    }
    
}