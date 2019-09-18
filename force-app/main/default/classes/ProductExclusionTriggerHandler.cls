//
// (c) 2015 NTTDATA, Inc.
//
// Apex Class Name: ProductExclusionTriggerHandler for ProductRestrictionTrigger and AssetTrigger
//
// 21st December 2015   Sonu Sharma
//

Public class ProductExclusionTriggerHandler{
    Set<String> Pcode = new Set<String>{'SHOWCASE','ADVANTAGE'};
    //{'SHOWCASE','ADVANTAGE'};
        Public void CallCreateUpdateProductExclusion(Set<Id> setPRFIds,Boolean inculdeAgent){
            List<Product_Restriction_Flag__c> lstPRF = [Select Id,Name,Product__c,Account__c,Product_Type__c,Is_Active__c from Product_Restriction_Flag__c where id=:setPRFIds];
            CreateUpdateProductExclusion(lstPRF,inculdeAgent);
        }
    Public void CreateUpdateProductExclusion(List<Product_Restriction_Flag__c> lstPRF,Boolean inculdeAgent){
        Set<Id> setAccountIds = new Set<Id>();
        Set<Id> setProductIds = new Set<Id>();
        Set<Id> setBrokerAccountIds = new Set<Id>();
        Set<Id> setBrokerOfficeAccountIds = new Set<Id>();
        Set<Id> setBrokerOfficeAgentAccountIds = new Set<Id>();
        Map<Id,Id> mapChildParentAccountIds = new Map<Id,Id>();
        Map<String,Id> mapProductIds = new Map<String,Id>();
        Map<Id,List<String>> mapProductAccountString = new Map<Id,List<String>>();
        Map<String,Product_Restriction_Flag__c> mapAllAccountPRFlag = new Map<String,Product_Restriction_Flag__c>();
        Map<String,Product_Restriction_Flag__c> mapAllNewAccountPRFlag = new Map<String,Product_Restriction_Flag__c>();
        List<Product_Restriction_Flag__c> lstProductRestrictionFlag = new List<Product_Restriction_Flag__c>();
        for(Product_Restriction_Flag__c prf:lstPRF){
            //if(mapProduct2.containskey(prf.Product__c)){
            setAccountIds.add(prf.Account__c);
            setProductIds.add(prf.Product__c);
            if(mapProductAccountString.containskey(prf.Account__c)){
                List<String> lstProductString = new List<String>();
                lstProductString = mapProductAccountString.get(prf.Account__c);
                lstProductString.add(prf.Product__c+'##'+prf.Product_Type__c);
                mapProductIds.put(prf.Product__c+'##'+prf.Product_Type__c,prf.Product__c);
                mapProductAccountString.put(prf.Account__c,lstProductString);
            } else {
                List<String> lstProductString = new List<String>();
                lstProductString.add(prf.Product__c+'##'+prf.Product_Type__c);
                mapProductIds.put(prf.Product__c+'##'+prf.Product_Type__c,prf.Product__c);
                mapProductAccountString.put(prf.Account__c,lstProductString);
            }

            mapAllNewAccountPRFlag.put(prf.Account__c+'##'+prf.Product__c+'##'+prf.Product_Type__c,prf);
            //}
        }
        System.debug('$$$$$'+mapProductAccountString);
        for(Account acc:[Select id,Name,Type from Account where Id=:setAccountIds and Type='Broker']){
            setBrokerAccountIds.add(acc.id);
        }
        if(setBrokerAccountIds.size()>0){
            for(Account_Relationship__c arr:[Select Id,Name,Child_Account__c,Parent_Account__c from Account_Relationship__c where Parent_Account__c=:setBrokerAccountIds and active__c=true and Relationship_Type__c='Parent/Child']){
                setBrokerOfficeAccountIds.add(arr.Child_Account__c);
                mapChildParentAccountIds.put(arr.Child_Account__c,arr.Parent_Account__c);

            }
        }
        if((setBrokerOfficeAccountIds.size()>0) && inculdeAgent){
            for(Account_Relationship__c arr:[Select Id,Name,Child_Account__c,Parent_Account__c from Account_Relationship__c where Parent_Account__c=:setBrokerOfficeAccountIds and active__c=true and Relationship_Type__c='Parent/Child']){
                setBrokerOfficeAgentAccountIds.add(arr.Child_Account__c);
                if(mapChildParentAccountIds.containskey(arr.Parent_Account__c)){
                    mapChildParentAccountIds.put(arr.Child_Account__c,mapChildParentAccountIds.get(arr.Parent_Account__c));
                }
            }
        }
        for(Product_Restriction_Flag__c prff:[Select Id,Name,Is_Active__c,Account__c,Product_Type__c,Product__c from Product_Restriction_Flag__c  where Account__c=:setBrokerOfficeAccountIds and Product__c=:setProductIds]){
            mapAllAccountPRFlag.put(prff.Account__c+'##'+prff.Product__c+'##'+prff.Product_Type__c,prff);
        }
        for(Product_Restriction_Flag__c prff:[Select Id,Name,Is_Active__c,Account__c,Product_Type__c,Product__c from Product_Restriction_Flag__c  where Account__c=:setBrokerOfficeAgentAccountIds and Product__c=:setProductIds]){
            mapAllAccountPRFlag.put(prff.Account__c+'##'+prff.Product__c+'##'+prff.Product_Type__c,prff);
        }

        for(Id idd:setBrokerOfficeAccountIds){
            List<String> lstProductList = new List<String>();
            if(mapProductAccountString.containskey(mapChildParentAccountIds.get(idd))){
                lstProductList  = mapProductAccountString.get(mapChildParentAccountIds.get(idd));
            }
            System.debug('$$$$');
            if(lstProductList.size()>0){
                for(String pstring:lstProductList){
                    System.debug('$$$$'+pstring);
                    if(mapAllAccountPRFlag.containskey(idd+'##'+pstring)){
                        System.debug('$$$$'+pstring);
                        Product_Restriction_Flag__c prf = mapAllAccountPRFlag.get(idd+'##'+pstring);
                        if(mapAllNewAccountPRFlag.containskey(mapChildParentAccountIds.get(idd)+'##'+prf.Product__c)){
                            System.debug('$$$$'+pstring);
                            prf.Is_Active__c = mapAllNewAccountPRFlag.get(mapChildParentAccountIds.get(idd)+'##'+prf.Product__c).Is_Active__c;
                            if(prf.Account__c==null){prf.Account__c = idd;}
                        } else{
                            prf.Is_Active__c = true;
                            if(prf.Account__c==null){prf.Account__c = idd;}
                        }
                        lstProductRestrictionFlag.add(prf);
                    } else{
                        System.debug('$$$$'+pstring);
                        Product_Restriction_Flag__c prf = new Product_Restriction_Flag__c();
                        if(mapAllNewAccountPRFlag.containskey(mapChildParentAccountIds.get(idd)+'##'+pstring)){
                            prf.Is_Active__c = mapAllNewAccountPRFlag.get(mapChildParentAccountIds.get(idd)+'##'+pstring).Is_Active__c;
                            prf.Account__c = idd;
                            //prf.Is_Active__c = true;
                            prf.Product__c = mapAllNewAccountPRFlag.get(mapChildParentAccountIds.get(idd)+'##'+pstring).Product__c;
                        }
                        prf.Account__c = idd;
                        lstProductRestrictionFlag.add(prf);
                    }
                }
            }
        }

        for(Id idd:setBrokerOfficeAgentAccountIds){
            List<String> lstProductList = new List<String>();
            if(mapProductAccountString.containskey(mapChildParentAccountIds.get(idd))){
                lstProductList  = mapProductAccountString.get(mapChildParentAccountIds.get(idd));
            }
            System.debug(mapChildParentAccountIds+'$$$$'+idd+'$$$$'+lstProductList);
            if(lstProductList.size()>0){
                for(String pstring:lstProductList){
                    System.debug('$$$$'+pstring);
                    if(mapAllAccountPRFlag.containskey(idd+'##'+pstring)){
                        System.debug('$$$$'+pstring);
                        Product_Restriction_Flag__c prf = mapAllAccountPRFlag.get(idd+'##'+pstring);
                        if(mapAllNewAccountPRFlag.containskey(mapChildParentAccountIds.get(idd)+'##'+prf.Product__c)){
                            System.debug('$$$$'+pstring);
                            prf.Is_Active__c = mapAllNewAccountPRFlag.get(mapChildParentAccountIds.get(idd)+'##'+prf.Product__c).Is_Active__c;
                            if(prf.Account__c==null){prf.Account__c = idd;}
                        } else{
                            prf.Is_Active__c = true;
                            if(prf.Account__c==null){prf.Account__c = idd;}
                        }
                        prf.Product__c = mapProductIds.get(pstring);
                        lstProductRestrictionFlag.add(prf);
                    } else{
                        if(idd!=null){
                            System.debug('$$$$'+pstring);
                            Product_Restriction_Flag__c prf = new Product_Restriction_Flag__c();
                            prf.Product__c = mapProductIds.get(pstring);
                            if(mapAllNewAccountPRFlag.containskey(mapChildParentAccountIds.get(idd)+'##'+pstring)){
                                prf.Is_Active__c = mapAllNewAccountPRFlag.get(mapChildParentAccountIds.get(idd)+'##'+pstring).Is_Active__c;
                                prf.Account__c = idd;
                                //prf.Is_Active__c = true;
                                prf.Product_Type__c = mapAllNewAccountPRFlag.get(mapChildParentAccountIds.get(idd)+'##'+pstring).Product_type__c;
                                prf.Product__c = mapAllNewAccountPRFlag.get(mapChildParentAccountIds.get(idd)+'##'+pstring).Product__c;
                            }
                            prf.Account__c = idd;
                            lstProductRestrictionFlag.add(prf);
                        }
                    }
                }
            }
        }

        if(lstProductRestrictionFlag.size()>0){
            upsert lstProductRestrictionFlag;
        }
    }

    Public void DeleteProductExclusion(List<Product_Restriction_Flag__c> lstPRF){
        Set<Id> setAccountIds = new Set<Id>();
        Set<Id> setProductIds = new Set<Id>();
        Set<Id> setBrokerAccountIds = new Set<Id>();
        Set<Id> setBrokerOfficeAccountIds = new Set<Id>();
        Set<Id> setBrokerOfficeAgentAccountIds = new Set<Id>();
        Map<Id,Id> mapChildParentAccountIds = new Map<Id,Id>();
        Map<Id,Set<String>> mapProductAccountString = new Map<Id,Set<String>>();
        Map<String,Product_Restriction_Flag__c> mapAllAccountPRFlag = new Map<String,Product_Restriction_Flag__c>();
        Map<String,Product_Restriction_Flag__c> mapAllNewAccountPRFlag = new Map<String,Product_Restriction_Flag__c>();
        List<Product_Restriction_Flag__c> lstProductRestrictionFlag = new List<Product_Restriction_Flag__c>();
        for(Product_Restriction_Flag__c prf:lstPRF){
            //if(mapProduct2.containskey(prf.Product__c)){
            setAccountIds.add(prf.Account__c);
            setProductIds.add(prf.Product__c);
            if(mapProductAccountString.containskey(prf.Account__c)){
                Set<String> lstProductString = new Set<String>();
                lstProductString = mapProductAccountString.get(prf.Account__c);
                lstProductString.add(prf.Product__c);
                mapProductAccountString.put(prf.Account__c,lstProductString);
            } else {
                Set<String> lstProductString = new Set<String>();
                lstProductString.add(prf.Product__c);
                mapProductAccountString.put(prf.Account__c,lstProductString);
            }

            mapAllNewAccountPRFlag.put(prf.Account__c+'##'+prf.Product__c,prf);
            //}
        }
        System.debug('$$$$$'+mapProductAccountString);
        for(Account acc:[Select id,Name,Type from Account where Id=:setAccountIds and Type='Broker']){
            setBrokerAccountIds.add(acc.id);
        }
        if(setBrokerAccountIds.size()>0){
            for(Account_Relationship__c arr:[Select Id,Name,Child_Account__c,Parent_Account__c from Account_Relationship__c where Parent_Account__c=:setBrokerAccountIds and active__c = true and Relationship_Type__c='Parent/Child']){
                setBrokerOfficeAccountIds.add(arr.Child_Account__c);
                mapChildParentAccountIds.put(arr.Child_Account__c,arr.Parent_Account__c);

            }
        }
        if(setBrokerOfficeAccountIds.size()>0){
            for(Account_Relationship__c arr:[Select Id,Name,Child_Account__c,Parent_Account__c from Account_Relationship__c where Parent_Account__c=:setBrokerOfficeAccountIds and active__c = true and Relationship_Type__c='Parent/Child']){
                setBrokerOfficeAgentAccountIds.add(arr.Child_Account__c);
                if(mapChildParentAccountIds.containskey(arr.Parent_Account__c)){
                    mapChildParentAccountIds.put(arr.Child_Account__c,mapChildParentAccountIds.get(arr.Parent_Account__c));
                }
            }
        }
        for(Product_Restriction_Flag__c prff:[Select Id,Name,Is_Active__c,Product_Type__c,Account__c,Product__c from Product_Restriction_Flag__c  where Account__c=:setBrokerOfficeAccountIds and Product__c=:setProductIds]){
            if(mapProductAccountString.containskey(mapChildParentAccountIds.get(prff.Account__c))){
                if(mapProductAccountString.get(mapChildParentAccountIds.get(prff.Account__c)).contains(prff.Product__c)){
                    mapAllAccountPRFlag.put(prff.Account__c+'##'+prff.Product__c,prff);
                }
            }
        }
        for(Product_Restriction_Flag__c prff:[Select Id,Name,Is_Active__c,Product_Type__c,Account__c,Product__c from Product_Restriction_Flag__c  where Account__c=:setBrokerOfficeAgentAccountIds and Product__c=:setProductIds]){
            if(mapProductAccountString.containskey(mapChildParentAccountIds.get(prff.Account__c))){
                if(mapProductAccountString.get(mapChildParentAccountIds.get(prff.Account__c)).contains(prff.Product__c)){
                    mapAllAccountPRFlag.put(prff.Account__c+'##'+prff.Product__c,prff);
                }
            }
        }
        if(mapAllAccountPRFlag.values().size()>0){
            delete mapAllAccountPRFlag.values();
        }
    }

    Public void ExpireBrokerShowcaseAssetProductExclusion(List<Product_Restriction_Flag__c> lstPRF,boolean includeagent){
        Set<Id> setAccountIds = new Set<Id>();
        Set<Id> setProductIds = new Set<Id>();
        Set<Id> setBrokerAccountIds = new Set<Id>();
        Set<Id> setBrokerOfficeAccountIds = new Set<Id>();
        Set<Id> setBrokerOfficeAgentAccountIds = new Set<Id>();
        Map<Id,Id> mapChildParentAccountIds = new Map<Id,Id>();
        Map<Id,Set<String>> mapProductAccountString = new Map<Id,Set<String>>();
        Map<String,Product_Restriction_Flag__c> mapAllAccountPRFlag = new Map<String,Product_Restriction_Flag__c>();
        Map<String,Product_Restriction_Flag__c> mapAllNewAccountPRFlag = new Map<String,Product_Restriction_Flag__c>();
        List<Product_Restriction_Flag__c> lstProductRestrictionFlag = new List<Product_Restriction_Flag__c>();
        for(Product_Restriction_Flag__c prf:lstPRF){
            prf.Is_Active__c = false;
            setAccountIds.add(prf.Account__c);
            setProductIds.add(prf.Product__c);
            if(mapProductAccountString.containskey(prf.Account__c)){
                Set<String> lstProductString = new Set<String>();
                lstProductString = mapProductAccountString.get(prf.Account__c);
                lstProductString.add(prf.Product__c);
                mapProductAccountString.put(prf.Account__c,lstProductString);
            } else {
                Set<String> lstProductString = new Set<String>();
                lstProductString.add(prf.Product__c);
                mapProductAccountString.put(prf.Account__c,lstProductString);
            }
            //mapAllAccountPRFlag.put(prff.Account__c+'##'+prff.Product__c,prff);
            mapAllNewAccountPRFlag.put(prf.Account__c+'##'+prf.Product__c,prf);
        }
        System.debug('$$$$$'+mapProductAccountString);
        for(Account acc:[Select id,Name,Type from Account where Id=:setAccountIds and Type='Broker']){
            setBrokerAccountIds.add(acc.id);
        }
        if(setBrokerAccountIds.size()>0){
            for(Account_Relationship__c arr:[Select Id,Name,Child_Account__c,Parent_Account__c from Account_Relationship__c where Parent_Account__c=:setBrokerAccountIds and active__c = true and Relationship_Type__c='Parent/Child']){
                setBrokerOfficeAccountIds.add(arr.Child_Account__c);
                mapChildParentAccountIds.put(arr.Child_Account__c,arr.Parent_Account__c);

            }
        }
        if((setBrokerOfficeAccountIds.size()>0) && includeagent){
            for(Account_Relationship__c arr:[Select Id,Name,Child_Account__c,Parent_Account__c from Account_Relationship__c where Parent_Account__c=:setBrokerOfficeAccountIds and active__c = true and Relationship_Type__c='Parent/Child']){
                setBrokerOfficeAgentAccountIds.add(arr.Child_Account__c);
                if(mapChildParentAccountIds.containskey(arr.Parent_Account__c)){
                    mapChildParentAccountIds.put(arr.Child_Account__c,mapChildParentAccountIds.get(arr.Parent_Account__c));
                }
            }
        }
        for(Product_Restriction_Flag__c prff:[Select Id,Name,Is_Active__c,Product_Type__c,Account__c,Product__c from Product_Restriction_Flag__c  where Account__c=:setBrokerOfficeAccountIds and Product__c=:setProductIds]){
            if(mapProductAccountString.containskey(mapChildParentAccountIds.get(prff.Account__c))){
                if(mapProductAccountString.get(mapChildParentAccountIds.get(prff.Account__c)).contains(prff.Product__c)){
                    prff.Is_Active__c = false;
                    mapAllAccountPRFlag.put(prff.Account__c+'##'+prff.Product__c,prff);
                }
            }
        }
        for(Product_Restriction_Flag__c prff:[Select Id,Name,Is_Active__c,Product_Type__c,Account__c,Product__c from Product_Restriction_Flag__c  where Account__c=:setBrokerOfficeAgentAccountIds and Product__c=:setProductIds]){
            if(mapProductAccountString.containskey(mapChildParentAccountIds.get(prff.Account__c))){
                if(mapProductAccountString.get(mapChildParentAccountIds.get(prff.Account__c)).contains(prff.Product__c)){
                    prff.Is_Active__c = false;
                    mapAllAccountPRFlag.put(prff.Account__c+'##'+prff.Product__c,prff);
                }
            }
        }
        if(mapAllAccountPRFlag.values().size()>0){
            Update mapAllAccountPRFlag.values();
            update mapAllNewAccountPRFlag.values();
        }
    }

    Public void ShowCaseOfficeAgentProductExclusion(Set<Id> setorderIds){
        Set<Id> setShowcaseAccountIds = new Set<Id>();
        Set<Id> setShowcasewithoutAgentAccountIds = new Set<Id>();

        for(OrderItem oit:[Select Id,Order.AccountId,PriceBookEntry.product2.ProductCode,Product_Type__c,ConfigOptions__c from OrderItem where orderId=:setorderIds and PricebookEntry.Product2.ProductCode=:Pcode and Order.Account.Type='Broker']){
            if(oit.Product_Type__c!=null){
                if(oit.Product_Type__c.equalsIgnoreCase('Showcase') || (oit.PriceBookEntry.product2.ProductCode.equalsIgnoreCase('Advantage') && !oit.ConfigOptions__c.equalsIgnoreCase('withoutAgents'))){
                    setShowcaseAccountIds.add(oit.Order.AccountId);
                }
                if(oit.Product_Type__c.equalsIgnoreCase('Showcase w/o Agent') || (oit.PriceBookEntry.product2.ProductCode.equalsIgnoreCase('Advantage') && oit.ConfigOptions__c.equalsIgnoreCase('withoutAgents'))){
                    setShowcasewithoutAgentAccountIds.add(oit.Order.AccountId);
                }

            }
        }
        if(setShowcaseAccountIds.size()>0){
            CreateUpdateShowcaseProductExclusion(setShowcaseAccountIds,true);
        }
        if(setShowcasewithoutAgentAccountIds.size()>0){
            CreateUpdateShowcaseProductExclusion(setShowcasewithoutAgentAccountIds,false);
        }
    }

    Public void ExpireBrokerShowcaseAssetProductExclusion(Set<Id> setAccountIds,boolean inculdeAgent){
        List<Product_Restriction_Flag__c> lstPRF = [Select Id,Product__c,Account__c,Product_Type__c,Is_Active__c,Name from Product_Restriction_Flag__c where Account__c=:setAccountIds and Product__r.ProductCode=:Pcode];
        if(lstPRF.size()>0){
            ExpireBrokerShowcaseAssetProductExclusion(lstPRF,inculdeAgent);
        }
    }

    Public void CreateUpdateShowcaseProductExclusion(Set<Id> setAccountIds,boolean inculdeAgent){
        List<Product_Restriction_Flag__c> lstPRF = [Select Id,Product__c,Account__c,Product_Type__c,Is_Active__c,Name from Product_Restriction_Flag__c where Account__c=:setAccountIds and Product__r.ProductCode=:Pcode];
        if(lstPRF.size()>0){
            CreateUpdateProductExclusion(lstPRF,inculdeAgent);
        }
    }

    Public void CreateUpdateAssetShowcaseProductExclusion(Set<Id> setAccountIds,boolean inculdeAgent){
        String showcaseproductcode='';
        String advantageproductcode='';
        Set<Id> setOldAccountIds = new Set<Id>();
        Map<Id,Asset> mapAccountIdProductId = new Map<Id,Asset>();
        // CRM-2545 Added SOQL filter to exclude Advantage Brand products.
        for(Asset ast:[Select id,AccountId,Name,ConfigOptions__c,Product_Code__c,Product_type__c,Product2Id from Asset where AccountId=:setAccountIds and Product_Code__c=:Pcode and Status='Active' and Fulfillment_Status__c='Fulfilled' AND Product_Type__c != 'Brand']){
        mapAccountIdProductId.put(ast.AccountId,ast);
        if(ast.Product_Code__c=='SHOWCASE'){ showcaseproductcode = ast.Product2Id;
           }
           if(ast.Product_Code__c=='ADVANTAGE'){ advantageproductcode = ast.Product2Id;
           }
        }
      /*  for(Product2 pp:[Select Id,Name,ProductCode from Product2 where ProductCode=:Pcode and isActive=true]){
           if(pp.ProductCode=='SHOWCASE'){ showcaseproductcode = pp.id;
           }
           if(pp.ProductCode=='ADVANTAGE'){ advantageproductcode = pp.id;
           }
        }*/
        for(Product_Restriction_Flag__c prff:[Select Id,Product__c,Account__c,Product_Type__c,Is_Active__c,Name from Product_Restriction_Flag__c where Account__c=:setAccountIds and Product__r.ProductCode=:Pcode]){
            setOldAccountIds.add(prff.Account__c);
        }
        List<Product_Restriction_Flag__c> newlstPRF = new List<Product_Restriction_Flag__c>();
        for(Id aId:setAccountIds){
            if(!setOldAccountIds.contains(aId)){
                if(showcaseproductcode!=''){
                Product_Restriction_Flag__c nprff = new Product_Restriction_Flag__c();
                nprff.Product__c =  (showcaseproductcode != null && showcaseproductcode != '') ? showcaseproductcode : null;
                nprff.Account__c =  aid;
                nprff.Product_Type__c =  '';
                nprff.Is_Active__c = true;
                if(mapAccountIdProductId.containskey(aid)){
                nprff.Product_Type__c = mapAccountIdProductId.get(aid).Product_type__c;
                }
                newlstPRF.add(nprff);

            }
            if(advantageproductcode!=''){
                Product_Restriction_Flag__c nprff = new Product_Restriction_Flag__c();
                nprff.Product__c =  (advantageproductcode != null && advantageproductcode != '') ? advantageproductcode : null;
                nprff.Account__c =  aid;
                nprff.Product_Type__c =  '';
                nprff.Is_Active__c = true;
                if(mapAccountIdProductId.containskey(aid)){
                nprff.Product_Type__c = mapAccountIdProductId.get(aid).Product_type__c;
                }
                newlstPRF.add(nprff);

            }
        }
        }
        if(newlstPRF.size()>0){
            insert newlstPRF;
        }
        List<Product_Restriction_Flag__c> lstPRF = [Select Id,Product__c,Account__c,Product_Type__c,Is_Active__c,Name from Product_Restriction_Flag__c where Account__c=:setAccountIds and Product__r.ProductCode=:Pcode];

        if(lstPRF.size()>0){
            CreateUpdateProductExclusion(lstPRF,inculdeAgent);
        }
    }

}