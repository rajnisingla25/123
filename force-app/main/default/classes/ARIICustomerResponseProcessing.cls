//Name        : ARIICustomerResponseProcessing
//Description : This class will be executed everytime Auto-renew Lead is created
//Frequencey  : Every Month
//Author      : Pallavi Tammana
//History     : CRM-3261: SFDC tasks for Lead processing & quote creation


Public Class ARIICustomerResponseProcessing{
    public static List<Asset> assetsToUpdate = new List<Asset>();
    public static set<Id> assetsToUpdateSet = new Set<Id>(); 
    public static Map<Id,List<Id>> accAssetMap = new Map<Id,List<Id>>();
    public static boolean processed = false;

    //CRM-3261: Merged Insert and Update methods
    public static void processBeforeInsertUpdates(Map<Id,Lead> oldMap, Map<Id,Lead> newMap, List<Lead> newLeads, Boolean isInsert){
       Set<Id> assetIds = new Set<Id>();
       System.debug('newMap:'+newMap);
       for(Lead l : newLeads){
           if((isInsert || oldMap.get(l.Id).CustomerResponseProcessed__c) && !l.CustomerResponseProcessed__c  && l.Marketing_Lead_Type__c == 'Auto-Renew' && l.CustomerResponse__c != null){
              List<String> customerResponses = l.CustomerResponse__c.split(';');             
              for(String eachAsset : customerResponses){
                 List<String> assetValues = eachAsset.split(',');
                 assetIds.add(assetValues[0]);
              }
           }
       }
       if(!assetIds.isEmpty()){
           system.debug('--- > '+assetIds);
           processLeads(assetIds,newLeads);
       }   
    }
    
    
    public static void processAfterRecords(){
        //update assets
        if(!processed){
            if(!assetsToUpdate.isEmpty() ){
                update assetsToUpdate;
            }
            if(!accAssetMap.isEmpty()){
                furtherProcess();
            }
            processed = true;
         }
            
    }
    
  
    public static void furtherProcess(){
        List<Opportunity> newOpportunities = new List<Opportunity>();
        for(Id IdLoop : accAssetMap.keySet()){
            Opportunity theOpportunity = new Opportunity(
                    Name = 'The Opportunity',
                    StageName = 'Prospecting',
                    CloseDate = system.today(),
                    AccountId = IDloop,
                    Is_Renewal_Opp__c = true,
                    Account_Type__c = 'Renewal');
            newOpportunities.add(theOpportunity);
        }
        if(!newOpportunities.isEmpty()){
            insert newOpportunities;
            Map<Id,Id> accOppMap = new Map<Id,Id>();
            for(Opportunity o : newOpportunities){
                accOppMap.put(o.AccountId, o.id);
            }
            system.debug('--- Opportunities --> '+newOpportunities);
            if(!Test.isRunningTest()) {
            
                ARIIResponseQuoteCreationBatch AssetBatch = new ARIIResponseQuoteCreationBatch(accAssetMap.keySet(), accAssetMap, accOppMap); 
                database.executebatch(AssetBatch,1);
            }
        }

    }

    public static void processLeads(Set<id> assetIds, List<Lead> newLeads){
        Map<Id,Asset> assetMap = new Map<Id,Asset>();
        for(Asset a : [Select accountId, Id, Name, Follow_Up_Status__c, CustResp_List_Price__c, CustResp_Total_Net__c,
                                CustResp_Renewal_Option__c, CustResp_Reason__c, Reason_Details__c, CustResp_Contract_Term__c, 
                                CustResp_Promotion__c, CustResp_Promo_age__c, CustResp_Spot_Promotion__c, 
                                CustResp_AppliesSpotPromo__c, AR_Oversold_Flag__c, CustResp_AutoOrder__c from asset where Id IN: assetIds AND status = 'Active']){
                assetMap.put(a.id,a);    
            
            }
            system.debug('--  assetMap -->'+assetMap);
            system.debug('-- !assetMap.isEmpty() -->'+!assetMap.isEmpty());
            system.debug('-- assetMap.keySet().size() -->'+assetMap.keySet().size());
            if(!assetMap.isEmpty() || assetMap.keySet().size()>0){
            system.debug('--- > Inside Asset Map --> ');
                Group grp = [SELECT Id FROM Group where Group.Type='Queue' and DeveloperName = 'Sales_Ops' limit 1];
                for(Lead l : newLeads){
                    if(!l.CustomerResponseProcessed__c && l.Marketing_Lead_Type__c == 'Auto-Renew' && l.CustomerResponse__c != null){
                        System.Debug('---> Inside Customer Response --> ');
                        List<String> customerResponses = l.CustomerResponse__c.split(';');  
                        boolean rejectLead = false;          
                        for(String eachAsset : customerResponses){
                            
                            List<String> resp = eachAsset.split(',');
                            Asset a = assetMap.get(resp[0]);
                            List<String> RenewTypeAndReason = getRenewTypeAndReason(resp[3]).split(',');
                            String renewType = RenewTypeAndReason[0];
                            String renewreason = RenewTypeAndReason[1];

                            if((renewType == 'Renew' || renewType == 'Renew: Pay-in-full')&& 
                                       (a.Follow_Up_Status__c == 'Will Not Renew' || 
                                       a.Follow_Up_Status__c == 'Pending Renewal' ||
                                       a.Follow_Up_Status__c == 'Renewed' || 
                                       a.Follow_Up_Status__c == 'Manual Renewal')) {
                                     rejectLead = true;   
                                        }
                            if(renewType == 'Do Not Renew' && 
                                      (a.Follow_Up_Status__c == 'Pending Renewal' ||
                                       a.Follow_Up_Status__c == 'Renewed' || 
                                       a.Follow_Up_Status__c == 'Manual Renewal')) {
                                     rejectLead = true;   
                                        }
                            
                            //updating asset values
                            if(!rejectLead){
                            
                                a.CustResp_List_Price__c = decimal.valueOf(resp[1]);
                                a.CustResp_Total_Net__c = decimal.valueOf(resp[2]);
                                a.CustResp_Contract_Term__c = resp[4];
                                a.CustResp_Promotion__c = resp[5] != null && resp[5] != '' ? resp[5] : a.CustResp_Promotion__c;
                                a.CustResp_Promo_age__c = resp[6] != null && resp[6] != '' ? Decimal.valueOf(resp[6]) : a.CustResp_Promo_age__c;
                                a.CustResp_AR_Promotion__c = resp[7] != null && resp[7] != '' ?  Decimal.valueOf(resp[7]) : a.CustResp_AR_Promotion__c;
                                a.CustResp_AR_Strategic_Promotion_code__c = resp[8] != null && resp[8] != '' ?  resp[8] : a.CustResp_AR_Strategic_Promotion_code__c;
                                a.CustResp_AR_Strategic_Promotion_age__c = resp[9] != null && resp[9] != '' ?  decimal.valueOf(resp[9]) : a.CustResp_AR_Strategic_Promotion_age__c ;
                                a.CustResp_AR_Strategic_Promotion__c = resp[10] != null && resp[10] != '' ?  decimal.valueOf(resp[10]) : a.CustResp_AR_Strategic_Promotion__c;
                                a.CustResp_Spot_Promotion__c = resp[11] != null && resp[11] != '' ?  resp[11] : a.CustResp_Spot_Promotion__c;
                                a.CustResp_Spot_Promotion_age__c = resp[12] != null && resp[12] != '' ?  decimal.valueOf(resp[12]) : a.CustResp_Spot_Promotion_age__c;
                                a.CustResp_AppliesSpotPromo__c = resp[13] != null && resp[13] != '' ? resp[13] : a.CustResp_AppliesSpotPromo__c;
                                a.CustResp_TotalListPrice__c = resp[14] != null && resp[14] != '' ? decimal.valueOf(resp[14]) : a.CustResp_TotalListPrice__c;
                                a.CustResp_AutoOrder__c = 'Yes';
                                a.Follow_Up_Status__c = (renewType == 'Do Not Renew' ? 'Will Not Renew' :  a.Follow_Up_Status__c);
                                a.CustResp_Renewal_Option__c = renewType;
                                a.CustResp_Reason__c = (renewType == 'Do Not Renew' ? renewReason : a.CustResp_Reason__c);
                                a.Reason__c = (renewType == 'Do Not Renew' ? renewReason : a.Reason__c);
                                a.Reason_Details__c = (renewType == 'Do Not Renew' ?  'Auto-Renew' : a.Reason_Details__c);
                               
                                if(!assetsToUpdateSet.contains(a.id)){
                                    assetsToUpdate.add(a);
                                    assetsToUpdateSet.add(a.id);
                                    system.debug('-- New asset --> '+a+' for Lead '+l);
                                }else{
                                    system.debug('--- Duplicate Id --> '+a+' for Lead '+l);
                                }
                                
                                if(renewType != 'Do Not Renew'){ //Adding the asset for further processing
                                  if(a.accountId != null){
                                    if(accAssetMap.containsKey(a.accountid)){
                                        accAssetMap.get(a.accountid).add(a.id);
                                    }else{
                                        List<Id> assets = new List<Id>();
                                        assets.add(a.id);
                                        accAssetMap.put(a.accountid,assets);
                                    }
                                    
                                   }
                                }
                            }               

                            }
                            //updating lead values
                            l.Status = rejectLead ? 'Rejected' : 'Converted';
                            l.Rejected_Reason__c = l.Status == 'Rejected' ? 'Conflict In Cust Response Processing' : '';
                            l.CustomerResponseProcessed__c = true;
                            l.OwnerId = l.status == 'Rejected' ? grp.id : l.OwnerId;
                           
                           
                           System.Debug('--- Lead l -->'+l);
                            
                        
                    }
                    system.debug('accAssetMap --> '+accAssetMap);
                }
            }

    }

    
    public static String getRenewTypeAndReason(String strl){
        String renewType = '';
        String renewReason = ' ';
        if(strl.contains('@')) {
            Integer J = 0;
            List<String> str = strl.split('@');
            for(String st : str){
                J = J+1;
                If(J == 1)
                    renewType = st;
                If(J == 2) {
                    AssetNotRenewReason__c renReason = AssetNotRenewReason__c.getInstance(st);
                    renewReason = renReason.Reason_Name__c;
                }
            }
        } else {
            renewType = strl;
        }
        return renewType+','+renewReason;
    }
    
}