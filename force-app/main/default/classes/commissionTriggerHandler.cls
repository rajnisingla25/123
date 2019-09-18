public class commissionTriggerHandler {
    
    //RETRIVING COMMISSIONS RECORD TYPES 
    private static Map<string,Schema.RecordTypeInfo> commissionRecordtypeMap = Schema.SObjectType.Commission__c.getRecordTypeInfosByName();
    private static string commissionOtherProductsRecordtype = commissionRecordtypeMap.get(System.Label.Commission_Other_Products).getRecordTypeId();
	
    public static void processQuotaproducts(List<commission__c> commisssionsList){
        if(RecursionBlockerClass.runOnce()){
           Product_Family__c pfamily = Product_Family__c.getvalues('Product_Family');
           Map<String,Double> totalCommissionMap=new Map<String,Double>();
           Map<String,Double> totalCommissionMapFamilyWise=new Map<String,Double>();
           Set<Id> relatedQuotaReusableSet=new Set<Id>();
           List<Quota_Product__c> quotProductList=new List<Quota_Product__c>();
           string managersTeam = CommissionTeams__c.getInstance('MANAGERS_TEAM').Team_Name__c;
    
           System.debug('$$$$$$$$$$$$InSide processQuotaProducts'+commisssionsList);
           
           for(Commission__c comm:commisssionsList){
               relatedQuotaReusableSet.add(comm.Related_to_Quota__c);
           }
		   
		   
           
           for(Commission__c comm:[Select id,Related_to_Quota__c,
                                          Related_to_Quota__r.User__c, Related_to_Quota__r.User_Team__c,
                                          Signing_AE__c,Product__c,Product__r.Family,Product__r.name,
                                          Line_Type__c,RecordType.Name,Total_Commissionable_Amount__c,Related_to_Asset__c,Related_to_Asset__r.OwnerId,
										  Related_To_Quota__r.Period_Name__r.Credit_Signing_AE__c,Related_To_Quota__r.Period_Name__r.Credit_Asset_Owner__c
                                          FROM Commission__c 
                                          WHERE Related_to_Quota__c in: relatedQuotaReusableSet AND Related_to_Quota__r.User_Team__c != :managersTeam  		//CRM-4552, Added filter for Managers Team
                                          AND Status__c = 'Active'
                                          AND ((Line_Type__c = 'Add') OR (Line_Type__c = 'Amend' AND recordtype.name!= 'Clawback'))
                                          LIMIT 50000]){
										  //comm.Signing_AE__c == comm.Related_to_Quota__r.User__c
                   if(comm.Related_to_Quota__c == null || comm.Related_to_Quota__r.User_Team__c == managersTeam){
                        continue;
                   }
               if(comm.Related_to_Quota__c != null && comm.Product__c != null  && ((comm.Related_To_Quota__r.Period_Name__r.Credit_Signing_AE__c && comm.Related_To_Quota__r.Period_Name__r.Credit_Asset_Owner__c) || (comm.Related_To_Quota__r.Period_Name__r.Credit_Signing_AE__c && comm.Signing_AE__c == comm.Related_to_Quota__r.User__c) || (comm.Related_To_Quota__r.Period_Name__r.Credit_Asset_Owner__c && comm.Related_to_Asset__r.OwnerId == comm.Related_to_Quota__r.User__c)))
               {
                   system.debug('comm.Total_Commissionable_Amount__c'+comm.Product__r.Family);
                   if(totalCommissionMap!=null && totalCommissionMap.containsKey(comm.Related_to_Quota__c+''+comm.Product__c)){
                       totalCommissionMap.put(comm.Related_to_Quota__c+''+comm.Product__c,totalCommissionMap.get(comm.Related_to_Quota__c+''+comm.Product__c)+comm.Total_Commissionable_Amount__c);
                   }
                   else{
                      totalCommissionMap.put(comm.Related_to_Quota__c+''+comm.Product__c,comm.Total_Commissionable_Amount__c); 
                   }
                   if(Product_Family__c.getInstance(comm.Product__r.Name)!=null  && Product_Family__c.getInstance(comm.Product__r.Name).Family_Name__c!=null && totalCommissionMapFamilyWise!=null && totalCommissionMapFamilyWise.containsKey(comm.Related_to_Quota__c+''+Product_Family__c.getInstance(comm.Product__r.Name).Family_Name__c)){
                       totalCommissionMapFamilyWise.put(comm.Related_to_Quota__c+''+Product_Family__c.getInstance(comm.Product__r.Name).Family_Name__c,totalCommissionMapFamilyWise.get(comm.Related_to_Quota__c+''+Product_Family__c.getInstance(comm.Product__r.Name).Family_Name__c)+comm.Total_Commissionable_Amount__c);
                   }
                   else if(comm.Product__r.Family!=null && Product_Family__c.getInstance(comm.Product__r.Name)!=null  && Product_Family__c.getInstance(comm.Product__r.Name).Family_Name__c!=null && totalCommissionMapFamilyWise!=null && !totalCommissionMapFamilyWise.containsKey(comm.Related_to_Quota__c+''+Product_Family__c.getInstance(comm.Product__r.Name).Family_Name__c)){
                      totalCommissionMapFamilyWise.put(comm.Related_to_Quota__c+''+Product_Family__c.getInstance(comm.Product__r.Name).Family_Name__c,comm.Total_Commissionable_Amount__c); 
                   }
               }
           }
           
           System.debug('$$$$$$$$$$$$$ TOtal Sum Commissionable Amount'+totalCommissionMap);
           System.debug('$$$$$$$$$$$$$ TOtal Sum Commissionable Amount Family Wise'+totalCommissionMapFamilyWise);
           
           For(Quota_Product__c quotaProd:[select id,Sales__c,Sales_Achivement__c,Target__c,
                                            Product_Family__c,Product_Name__c,Related_To_Quota__c 
                                            from Quota_Product__c 
                                           	where Related_To_Quota__c in: relatedQuotaReusableSet
                                          		AND Related_To_Quota__r.User_Team__c != :managersTeam]){	// Added against CRM-4552
               if(quotaProd.Product_Name__c!=null  
                    && totalCommissionMap.containsKey(quotaProd.Related_To_Quota__c+''+quotaProd.Product_Name__c)
                    && totalCommissionMap.get(quotaProd.Related_To_Quota__c+''+quotaProd.Product_Name__c)!=null
                    && totalCommissionMap.get(quotaProd.Related_To_Quota__c+''+quotaProd.Product_Name__c)!=quotaProd.Sales_Achivement__c
                    ){
                       
                    quotaProd.Sales_Achivement__c= totalCommissionMap.get(quotaProd.Related_To_Quota__c+''+quotaProd.Product_Name__c);
                    quotProductList.add(quotaProd);
                }
                else if(quotaProd.Product_Name__c==null && quotaProd.Product_Family__c!=null 
                    && totalCommissionMapFamilyWise.containsKey(quotaProd.Related_To_Quota__c+''+quotaProd.Product_Family__c)
                    && totalCommissionMapFamilyWise.get(quotaProd.Related_To_Quota__c+''+quotaProd.Product_Family__c)!=null
                    && totalCommissionMapFamilyWise.get(quotaProd.Related_To_Quota__c+''+quotaProd.Product_Family__c)!=quotaProd.Sales_Achivement__c
                    ){
                        
                    quotaProd.Sales_Achivement__c= totalCommissionMapFamilyWise.get(quotaProd.Related_To_Quota__c+''+quotaProd.Product_Family__c);
                    quotProductList.add(quotaProd);
                }
                else if(
                    (quotaProd.Product_Name__c!=null  
                    && !totalCommissionMap.containsKey(quotaProd.Related_To_Quota__c+''+quotaProd.Product_Name__c))
                    ||
                    (quotaProd.Product_Name__c==null && quotaProd.Product_Family__c!=null 
                    && !totalCommissionMapFamilyWise.containsKey(quotaProd.Related_To_Quota__c+''+quotaProd.Product_Family__c))
                    
                    ){
                        quotaProd.Sales_Achivement__c= 0.00;
                         quotProductList.add(quotaProd); 
                        
                    }
                
               
           }
           
           System.debug('$$$ Final List $$$$$'+quotProductList);
           
           if(quotProductList!=null && !quotProductList.isEmpty()){
               Database.SaveResult[] sr=Database.update(quotProductList,false);
           }
       
        }
       
    }
    //CRM-3027 - To update quota product on commissions.
    public static void updateCommissionswQP(List<commission__c> commisssionsList){
        Product_Family__c pfamily = Product_Family__c.getvalues('Product_Family');
        Set<id> relatedQuotaIds = new Set<id>();
        Set<id> relatedProducts = new Set<id>();
        Map<String,Id> quotaprodMapfamilywise=new Map<String,Id>();
        Map<String,Id> quotaprodMap=new Map<String,Id>();
        Map<String,String> quotaprodMapfamilycheck=new Map<String,string>();
        Map<Id,String> ProductMap = new Map<Id,String>();
        for(Commission__c com:commisssionsList){
            if((com.Line_Type__c == 'Add'||(com.Line_Type__c == 'Amend' && com.recordtype.name!= 'Clawback')) && com.Product__c!=null){
               relatedQuotaIds.add(com.Related_to_Quota__c);
               relatedProducts.add(com.Product__c);
            }   
        }
       for(Product2 p : [Select Id,name from Product2 where Id IN :relatedProducts AND IsActive =: TRUE AND Orderable__c =:TRUE]){
           ProductMap.put(p.Id,p.name);
       }
       For(Quota_Product__c quotaProd:[select id,Sales__c,Sales_Achivement__c,Target__c,
                                            Product_Family__c,Product_Name__c,Related_To_Quota__c 
                                            FROM Quota_Product__c WHERE Related_To_Quota__c IN: relatedQuotaIds]){
               system.debug('inside qp for');
                //Product Check
               if(quotaProd.Product_Name__c!=null  && quotaProd.Product_Family__c == null
                    && quotaprodMap.containsKey(quotaProd.Related_To_Quota__c+''+quotaProd.Product_Name__c)
                    && quotaprodMap.get(quotaProd.Related_To_Quota__c+''+quotaProd.Product_Name__c)!=null
                    ){
                    system.debug('inside qp product check if');
                    quotaprodMap.put(quotaProd.Related_To_Quota__c+''+quotaProd.Product_Name__c,quotaprodMap.get(quotaProd.Related_To_Quota__c+''+quotaProd.Product_Name__c));
                }
                else {
                    system.debug('inside qp product check else');
                    quotaprodMap.put(quotaProd.Related_To_Quota__c+''+quotaProd.Product_Name__c,quotaProd.id);
                    system.debug('quotaprodMap@@@@@@'+quotaprodMap);
                }
                //Product Family Check
                if(quotaProd.Product_Name__c==null  && quotaProd.Product_Family__c != null
                    && quotaprodMapfamilywise.containsKey(quotaProd.Related_To_Quota__c+''+quotaProd.Product_Family__c)
                    && quotaprodMapfamilywise.get(quotaProd.Related_To_Quota__c+''+quotaProd.Product_Family__c)!=null
                    ){
                        system.debug('inside qp product family check if');
                        quotaprodMapfamilywise.put(quotaProd.Related_To_Quota__c+''+quotaProd.Product_Family__c,quotaprodMapfamilywise.get(quotaProd.Related_To_Quota__c+''+quotaProd.Product_Family__c));
                        quotaprodMapfamilycheck.put(quotaProd.Related_To_Quota__c+''+quotaProd.Product_Family__c,quotaProd.Id);
                    }
                    else{
                        system.debug('inside qp product family check else');
                        quotaprodMapfamilywise.put(quotaProd.Related_To_Quota__c+''+quotaProd.Product_Family__c,quotaProd.id);
                        quotaprodMapfamilycheck.put(quotaProd.Related_To_Quota__c+''+quotaProd.Product_Family__c,quotaProd.Product_Family__c);
                        system.debug('quotaprodMapfamilywise@@@@@@'+quotaprodMapfamilywise);
                    }
        }
        for(Commission__c comm:commisssionsList){
            if(comm.Product__c!=null
                && quotaprodMap.containsKey(comm.Related_To_Quota__c+''+comm.Product__c)
                && quotaprodMap.get(comm.Related_To_Quota__c+''+comm.Product__c)!=null){
                    system.debug('inside com update product');
                comm.Quota_Product__c = quotaprodMap.get(comm.Related_To_Quota__c+''+comm.Product__c);
            }
            string prodname = ProductMap.get(comm.Product__c);
            if(comm.Product__c!=null
                && Product_Family__c.getInstance(prodname)!=null
                && quotaprodMapfamilywise.containsKey(comm.Related_To_Quota__c+''+Product_Family__c.getInstance(prodname).Family_Name__c)
                && quotaprodMapfamilywise.get(comm.Related_To_Quota__c+''+Product_Family__c.getInstance(prodname).Family_Name__c)!=null){
                    system.debug('inside com update product family');
                    comm.Quota_Product_Family__c = quotaprodMapfamilywise.get(comm.Related_To_Quota__c+''+Product_Family__c.getInstance(comm.Product__r.Name).Family_Name__c);
                }
        }
    }
    // CRM-4379 - Payout % to populate for Other Product Commission Records
    public static void updateCommissionsPayoutRate(List<Commission__c> lstNewCommissions){
        Set<Id> quoataIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        
        if(lstNewCommissions.size() > 0){
            for(Commission__c commission : lstNewCommissions){
                if(commission.Related_to_Quota__c != null)
                	quoataIds.add(commission.Related_to_Quota__c);
                if(commission.Product__c != null)
                	productIds.add(commission.Product__c);   
            }
        }
        Map<Id,Product2> mapRelatedProducts = null;
        // CRM-5575 added below query to fetch associated product code of the commission record
        if(productIds.size() > 0)
        	mapRelatedProducts = new Map<Id,Product2>([Select Id, ProductCode,Name,Family From Product2 Where Id IN :productIds]);
        
        if(quoataIds.size() > 0){            
			Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Quota__c.fields.getMap();        
			List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();
			String theQuery = 'SELECT Id, Name,';        
            for(Schema.SObjectField s : fldObjMapValues) {           
                String fieldName = s.getDescribe().getName();
                if(string.isNotBlank(fieldName) && (fieldName.endsWithIgnoreCase('_New__c') || fieldName.endsWithIgnoreCase('_Renew__c'))){
                	theQuery += fieldName + ',';     
                }
             }
            if(theQuery.endsWithIgnoreCase(',')){
                theQuery = theQuery.removeEnd(',');
            }      
            theQuery += ' FROM Quota__c where id IN :quoataIds'; 
            
            Map<Id,Quota__c> mapRelatedQuotaRecords = new Map<Id,Quota__c>((List<Quota__c>)Database.query(theQuery));
                
            for(Commission__c commission : lstNewCommissions){
                if(commission.RecordtypeId == commissionOtherProductsRecordtype && (commission.Line_Type__c == 'Add'|| commission.Line_Type__c == 'Amend')){ //CRM-4526, added amend condition.
                    Quota__c quotaRecord = mapRelatedQuotaRecords.get(commission.Related_to_Quota__c); 
                    commission.Payout_Rate__c = 0.0;
                    string fieldName = '';
                    fieldName = (mapRelatedProducts != null && mapRelatedProducts.containsKey(commission.Product__c) != null) ? mapRelatedProducts.get(commission.Product__c).ProductCode + '_New__c' : '';
                    if(fieldName != '' && quotaRecord.get(fieldName) != null){
                        commission.Payout_Rate__c = (Decimal)quotaRecord.get(fieldName);                                                
                    }                  
                }
            }
        }
    }
    // End - CRM-4379
}