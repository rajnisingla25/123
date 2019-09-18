public class quotaProductTriggerHandler {
    public static void processQuotaproducts(List<Quota_Product__c> quotaProductList){
        if(RecursionBlockerClass.runOnce()){
            Set<id> relatedQuotaIds = new Set<id>();
            Set<id> relatedProducts = new Set<id>();
            Map<String,Double> totalCommissionMap=new Map<String,Double>();
            Map<String,Double> totalCommissionMapFamilyWise=new Map<String,Double>();
            Map<string,Product_Family__c> pfamilyMap = Product_Family__c.getall();
           string managersTeam = CommissionTeams__c.getInstance('MANAGERS_TEAM').Team_Name__c;
            for(Quota_Product__c quotaProd : quotaProductList){
                if(quotaProd.Product_Name__c!=null || quotaProd.Product_Family__c!=Null){
                    relatedQuotaIds.add(quotaProd.related_to_quota__c);
                    relatedProducts.add(quotaProd.Product_Name__c);
                }
            }
            system.debug('relatedProducts@@'+relatedProducts);
            if(relatedQuotaIds!=null){
                for(Commission__c comm : [SELECT id,Name,
                                                 Total_Commissionable_Amount__c,Product__c,Signing_AE__c,Related_to_Asset__c,Related_to_Asset__r.OwnerId,
                                                 Product__r.Name,Product__r.Family,Related_to_Quota__c,Related_to_Quota__r.User__c,
												 Related_To_Quota__r.Period_Name__r.Credit_Signing_AE__c,Related_To_Quota__r.Period_Name__r.Credit_Asset_Owner__c
                                                 FROM Commission__c 
                                                 WHERE (line_type__c = 'Add' OR (line_type__c = 'Amend' AND RecordType.Name!= 'Clawback'))
                                                 AND Related_to_Quota__c IN: relatedQuotaIds AND Related_to_Quota__r.User_Team__c != :managersTeam  		//CRM-4552, Added filter for Managers Team
                                                 LIMIT 50000]){
                   if(comm.Related_to_Quota__c!=null && comm.Product__c!=null  && ((comm.Related_To_Quota__r.Period_Name__r.Credit_Signing_AE__c && comm.Related_To_Quota__r.Period_Name__r.Credit_Asset_Owner__c) || (comm.Related_To_Quota__r.Period_Name__r.Credit_Signing_AE__c && comm.Signing_AE__c == comm.Related_to_Quota__r.User__c) || (comm.Related_To_Quota__r.Period_Name__r.Credit_Asset_Owner__c && comm.Related_to_Asset__r.OwnerId == comm.Related_to_Quota__r.User__c))){
                   if(relatedProducts.contains(comm.Product__c)){                                              
                       if(totalCommissionMap!=null && totalCommissionMap.containsKey(comm.Related_to_Quota__c+''+comm.Product__c)){
                           totalCommissionMap.put(comm.Related_to_Quota__c+''+comm.Product__c,totalCommissionMap.get(comm.Related_to_Quota__c+''+comm.Product__c)+comm.Total_Commissionable_Amount__c);
                       }
                       else{
                          totalCommissionMap.put(comm.Related_to_Quota__c+''+comm.Product__c,comm.Total_Commissionable_Amount__c); 
                       }
                   }
                   system.debug('totalCommissionMap@@'+totalCommissionMap);
                   if(pfamilyMap.keySet().contains(comm.Product__r.Name)){
                       if(Product_Family__c.getInstance(comm.Product__r.Name)!=null  && Product_Family__c.getInstance(comm.Product__r.Name).Family_Name__c!=null && totalCommissionMapFamilyWise!=null && totalCommissionMapFamilyWise.containsKey(comm.Related_to_Quota__c+''+Product_Family__c.getInstance(comm.Product__r.Name).Family_Name__c)){
                           totalCommissionMapFamilyWise.put(comm.Related_to_Quota__c+''+Product_Family__c.getInstance(comm.Product__r.Name).Family_Name__c,totalCommissionMapFamilyWise.get(comm.Related_to_Quota__c+''+Product_Family__c.getInstance(comm.Product__r.Name).Family_Name__c)+comm.Total_Commissionable_Amount__c);
                       }
                       else if(comm.Product__r.Family!=null && Product_Family__c.getInstance(comm.Product__r.Name)!=null  && Product_Family__c.getInstance(comm.Product__r.Name).Family_Name__c!=null && totalCommissionMapFamilyWise!=null && !totalCommissionMapFamilyWise.containsKey(comm.Related_to_Quota__c+''+Product_Family__c.getInstance(comm.Product__r.Name).Family_Name__c)){
                          totalCommissionMapFamilyWise.put(comm.Related_to_Quota__c+''+Product_Family__c.getInstance(comm.Product__r.Name).Family_Name__c,comm.Total_Commissionable_Amount__c); 
                       }
                    }
                }
                }
            }
            for(Quota_Product__c quotaProd : quotaProductList){
                if(quotaProd.Product_Name__c!=null
                    && quotaProd.Product_Family__c==null 
                    && totalCommissionMap.containsKey(quotaProd.Related_To_Quota__c+''+quotaProd.Product_Name__c)
                    && totalCommissionMap.get(quotaProd.Related_To_Quota__c+''+quotaProd.Product_Name__c)!=null){
                    quotaProd.Sales_Achivement__c = totalCommissionMap.get(quotaProd.Related_To_Quota__c+''+quotaProd.Product_Name__c);
                }
                else if(quotaProd.Product_Name__c==null && quotaProd.Product_Family__c!=null 
                    && totalCommissionMapFamilyWise.containsKey(quotaProd.Related_To_Quota__c+''+quotaProd.Product_Family__c)
                    && totalCommissionMapFamilyWise.get(quotaProd.Related_To_Quota__c+''+quotaProd.Product_Family__c)!=null){
                    quotaProd.Sales_Achivement__c = totalCommissionMapFamilyWise.get(quotaProd.Related_To_Quota__c+''+quotaProd.Product_Family__c);
                }
                
                if(quotaProd.Sales_Achivement__c>=quotaProd.Sales__c){
                    quotaProd.Target__c=true;
                }
                else
                    quotaProd.Target__c=false;
            }
        }
       // updateQuotaObjectForQualifier(quotaProductList);
    }
    
    public static void updateQuotaObjectForQualifier(List<Quota_Product__c> quotProductList){
        List<Quota__c> updateList = new List<Quota__c>();
        Map<id,List<Quota_Product__c>> mapParentIDAndChild = new Map<id,List<Quota_Product__c>>();
        boolean flag;
        set<Id> parenetTrue = new set<Id>();
        for(Quota_Product__c objChild : quotProductList) {
            parenetTrue.add(objChild.Related_To_Quota__c);
        }
        for(Quota_Product__c objChild : [select id ,Target__c,Target_Achieved__c,Related_To_Quota__c from Quota_Product__c where Related_To_Quota__c IN: parenetTrue] ){
            system.debug('<<<<<<objChild '+objChild );
            if(mapParentIDAndChild.containsKey(objChild.Related_To_Quota__c)) {
                system.debug('<<<<<<in if 1st ');
                mapParentIDAndChild.get(objChild.Related_To_Quota__c).add(objChild);
                system.debug('<<<<<<in if 1st mapParentIDAndChild '+mapParentIDAndChild);
            } else {
                system.debug('<<<<<<in else 1st ');
                mapParentIDAndChild.put(objChild.Related_To_Quota__c,new List<Quota_Product__c>{objChild});
                system.debug('<<<<<<in else 1st mapParentIDAndChild '+mapParentIDAndChild);
            }
        }
        for(Id objId : mapParentIDAndChild.keySet()) {
            flag = true;
            for(Quota_Product__c objChild : mapParentIDAndChild.get(objId)) {
                if(objChild.Target_Achieved__c== false){
                    flag = false;
                    break;
                }
            }
            if(flag == true) {
                updateList.add(new Quota__c(Id = objId , Is_Kicker__c = TRUE));
            } else {
                updateList.add(new Quota__c(Id = objId , Is_Kicker__c = FALSE));
            }
        }
        if(!updateList.isEmpty()) {
            update updateList;
        }   
    }    
    //CRM-3027 - To update quota product on commissions.
    public static void updateCommWQP(List<Quota_Product__c> quotaProductList){
        Set<id> relatedQuotaIds = new Set<id>();
        List<Commission__c> updateCommList = new List<Commission__c>();
        Map<String,Id> commissionMap=new Map<String,Id>();
        Map<String,Id> commissionMapFamilyWise=new Map<String,Id>();
        for(Quota_Product__c quotaProd : quotaProductList){
            if(quotaProd.Product_Name__c!=null || quotaProd.Product_Family__c!=Null){
                relatedQuotaIds.add(quotaProd.related_to_quota__c);
            }
        }
        for(Quota_Product__c quotaProd : quotaProductList){
            //Product Check
            if(quotaProd.Product_Name__c!=null 
                && quotaProd.Product_Family__c == null
                && commissionMap.containsKey(quotaProd.Related_To_Quota__c+''+quotaProd.Product_Name__c)
                && commissionMap.get(quotaProd.Related_To_Quota__c+''+quotaProd.Product_Name__c)!=null){
                    commissionMap.put(quotaProd.Related_To_Quota__c+''+quotaProd.Product_Name__c,commissionMap.get(quotaProd.Related_To_Quota__c+''+quotaProd.Product_Name__c));
            }
            else{
                commissionMap.put(quotaProd.Related_To_Quota__c+''+quotaProd.Product_Name__c,quotaProd.Id);
            }
            //Product Family Check
            if(quotaProd.Product_Name__c==null 
                && quotaProd.Product_Family__c != null
                && commissionMapFamilyWise.containsKey(quotaProd.Related_To_Quota__c+''+quotaProd.Product_Family__c)
                && commissionMapFamilyWise.get(quotaProd.Related_To_Quota__c+''+quotaProd.Product_Family__c)!=null){
                    commissionMapFamilyWise.put(quotaProd.Related_To_Quota__c+''+quotaProd.Product_Family__c,commissionMapFamilyWise.get(quotaProd.Related_To_Quota__c+''+quotaProd.Product_Family__c));
                }
            else{
                    commissionMapFamilyWise.put(quotaProd.Related_To_Quota__c+''+quotaProd.Product_Family__c,quotaProd.Id);
            }
        }
        if(relatedQuotaIds!=null){
            for(Commission__c comm : [SELECT id,Name,
                                                 Total_Commissionable_Amount__c,Product__c,
                                                 Quota_Product__c,Quota_Product_Family__c,Signing_AE__c,
                                                 Product__r.Name,Product__r.Family,Related_to_Quota__c,Related_to_Quota__r.User__c
                                                 FROM Commission__c 
                                                 WHERE (line_type__c = 'Add' OR (line_type__c = 'Amend' AND RecordType.Name!= 'Clawback'))
                                                 AND Related_to_Quota__c IN: relatedQuotaIds 
                                                 LIMIT 50000]){
                if(comm.Product__c!=null
                    && commissionMap.containsKey(comm.Related_To_Quota__c+''+comm.Product__c)
                    && commissionMap.get(comm.Related_To_Quota__c+''+comm.Product__c)!=null){
                        comm.Quota_Product__c = commissionMap.get(comm.Related_To_Quota__c+''+comm.Product__c);   
                }
                if(comm.Product__c!=null
                    && Product_Family__c.getInstance(comm.Product__r.Name)!=null
                    && commissionMapFamilyWise.containsKey(comm.Related_To_Quota__c+''+Product_Family__c.getInstance(comm.Product__r.Name).Family_Name__c)
                    && Product_Family__c.getInstance(comm.Product__r.Name) !=null
                    && Product_Family__c.getInstance(comm.Product__r.Name).Family_Name__c !=null){
                        comm.Quota_Product_Family__c = commissionMapFamilyWise.get(comm.Related_To_Quota__c+''+Product_Family__c.getInstance(comm.Product__r.Name).Family_Name__c);
                }
                updateCommList.add(comm);    
            }
            if(!updateCommList.isEmpty()){
                Update updateCommList;
            }
        }
    }
}