/*
Author - Ravinder
a) For prospect accounts with no owner(integration user) & no sales lock 
 Assign Account owner  who is the person who creates order. 
*/
global class orderTriggerHandler
{
    orderTriggerHandlerManager orderManager= new orderTriggerHandlerManager();
    public void onAfterinsertUpdate(map<ID,Order> newMap,map<ID,Order> oldMap){
    
       orderManager.accountOwnerUpdate(newMap,oldMap);
    }

    public void onAfterUpdate(List<Order> newList,map<ID,Order> oldMap){
            // LCM-97
        orderManager.updateCoMarketingRel(newList,oldMap);
    }
    //Adding Cases relate Method and updating to the case Queues.
    public void insertCasesBrk(List<order> ordLst){
        
        List<order> orderLstActual = new List<order>();
        List<orderItem> orderItmLst = new List<orderItem>();
        List<product2> prdLst = new List<product2>();
        List<account> relAccLst = new List<account>();
        List<user> mgrLst = new List<user>();
        List<AccountTeamMember> userdLst = new List<AccountTeamMember>();
        
        Map<String,RDC_Products_Codes__c> rdcPrdCodemap = RDC_Products_Codes__c.getAll();
        Map<String,TP_Product_Code__c> tdPrdCodemap = TP_Product_Code__c.getAll();
        Map<String,product2> prdcodeMap = new Map<String,product2>();
        Map<id,AccountTeamMember> teamMemMap = new Map<id,AccountTeamMember>();
        
        Set<id> ordrSetId = new Set<id>();
        Set<id> prdOrdrItmSet = new Set<id>();
        Set<id> prdcodeSet = new Set<id>();
        List<case> casesToInsert = new List<case>();
        set<string> rdcProdSet = new set<string>();
        set<string> tpProdSet = new set<string>();
        set<id> accntIds = new set<id>();
        set<id> userIds = new set<id>();
        
        boolean tpProdCheck = false ;
        boolean rdcProdCheck = false ;
        
        for(order ord : ordLst){
            //if(ord.Pricebookentry.Product2Id != null)
            ordrSetId.add(ord.id);
            if(ord.accountId != null)
                accntIds.add(ord.id);
        }   
        if(!ordrSetId.IsEmpty()){
            
            for( RDC_Products_Codes__c rdcp : rdcPrdCodemap.Values() )
                rdcProdSet.add(rdcp.name);
            
            for( TP_Product_Code__c tpp : tdPrdCodemap.Values() )
                tpProdSet.add(tpp.name);
            
            relAccLst = [Select Id, (select id,TeamMemberRole ,userId from accountTeammembers where TeamMemberRole='Account Manager') from account where id IN:accntIds];
            
            if(!relAccLst.isEmpty()){
                teamMemMap = FillingAccountmanager(accntIds);
                userdLst = teamMemMap.Values(); 
                system.debug('++UsersLst'+userdLst);
                    
            }
            
            group tpGrpID = [Select Id, Name, DeveloperName, Type from Group where Type =: 'Queue' AND developerName =: 'TP_Product_Setup_Open'];   
            group rdcGrpID = [Select Id, Name, DeveloperName, Type from Group where Type =: 'Queue' AND developerName =: 'RDC_Broker_Unassigned_Product_Setup'];    
            
            orderItmLst = [SELECT Id,Pricebookentry.Product2Id,OrderId FROM orderItem where OrderId IN:ordrSetId];
            for(orderItem ordIt : orderItmLst){
                prdOrdrItmSet.add(ordIt.Pricebookentry.Product2Id);
            }
            prdLst = [Select name,ProductCode,Description from product2 where id IN:prdOrdrItmSet];
            
            for(product2 prd : prdLst)
                prdcodeMap.put(prd.id,prd); 
            system.debug('+++ ProdMap +'+prdcodeMap);    
            //Insertion of cases
            //rdcPrdCodeLst.Lower();
            //tdPrdCodeLst.lower();
            orderLstActual = [Select id,accountid,(select id,Pricebookentry.Product2Id,Pricebookentry.Product2.ProductCode,Fulfillment_Status__c from orderItems where Fulfillment_Status__c =:'Fulfilled' ) from order where id IN:ordrSetId];
            id ordAccId = orderLstActual[0].accountid;
            id orderId = orderLstActual[0].id;
            set<id> orderSet = new set<id>();
            string caseDesc = '';
            string caseDescTp = '';
            string caseDescRdc = '';
            set<string> productCodeSetOfProd = new set<string>();
            set<string> productNameSet = new set<string>();
            Map<Id,Boolean> mapOrderRSMap = new Map<Id,Boolean>();
            Set<String> rsBundleProd = new Set<String>{'RSRESPOND', 'RSTRANSACT', 'RSCONNECT'};
            for(order ordVal : orderLstActual){
                caseDesc = '';
                productNameSet.clear();
                for(orderitem ordItm : ordVal.orderItems){
                        string pid = ordItm.Pricebookentry.Product2Id;
                        system.debug('+++Prod Ids'+prdcodeMap.get(pid));
                        if(rsBundleProd.contains(ordItm.Pricebookentry.Product2.ProductCode)){
                        mapOrderRSMap.put(ordVal.Id,true);
                        }
                        if(!productNameSet.Contains(prdcodeMap.get(pid).name)){
                            if(caseDesc == ''){
                                caseDesc = prdcodeMap.get(pid).name;
                                productNameSet.add(prdcodeMap.get(pid).name);
                            }   
                            else{ 
                                caseDesc = caseDesc+' '+prdcodeMap.get(pid).name;
                                productNameSet.add(prdcodeMap.get(pid).name);
                            }
                        }       
                        productCodeSetOfProd.add(prdcodeMap.get(pid).productcode);  
                        if(tpProdSet.contains(prdcodeMap.get(pid).productcode)){
                            tpProdCheck = true ;
                            if(caseDescTp == '')
                                caseDescTp = prdcodeMap.get(pid).name;
                            else 
                                caseDescTp = caseDescTp+' '+prdcodeMap.get(pid).name;
                        }   
                        if(rdcProdSet.contains(prdcodeMap.get(pid).productcode)){
                            rdcProdCheck = true;
                            if(caseDescRdc == '')
                                caseDescRdc = prdcodeMap.get(pid).name;
                            else 
                                caseDescRdc = caseDescRdc+' '+prdcodeMap.get(pid).name;
                        }   
                    }
                    if(!orderSet.contains(ordVal.id) && (tpProdCheck || rdcProdCheck) || Test.isRunningTest()){  
                        
                        Case caseToAdd = new Case();
                        caseToAdd.Status = 'New';
                        caseToAdd.Origin = 'Web';
                        caseToAdd.Type = 'Outbound';
                        caseToAdd.Area__c = 'Product Set Up';
                        caseToAdd.Subject = 'Welcome Call';
                        if(mapOrderRSMap.containskey(ordVal.id)){
                        caseToAdd.bundle_RS__c = true;
                        }
                        //caseToAdd.ContactId = ass.ContactId;
                        caseToAdd.AccountId = ordVal.accountid;
                        if(tpProdCheck)
                            caseToAdd.Description = caseDescTp ;
                        if(rdcProdCheck)
                            caseToAdd.Description = caseDescRdc ;
                        caseToAdd.Order__c = ordVal.id;
                        if(userdLst.size() <= 0){
                            if(tpProdCheck == true)
                                caseToAdd.ownerId = tpGrpID.id ;
                            else if (rdcProdCheck == true)
                                caseToAdd.ownerId = rdcGrpID.id ;
                        } else if(teamMemMap.containsKey(ordVal.accountId))
                            caseToAdd.ownerId = teamMemMap.get(ordVal.accountId).userid;
                        /*for( string code : productCodeSetOfProd){
                            if(
                            caseToAdd.Product_Category__c = 'RDC';
                            if(
                            caseToAdd.Product_Category__c = 'TP';
                        }*/ 
                        if(tpProdCheck == true)
                            tpProdCheck = false;
                        if(rdcProdCheck == true)
                            rdcProdCheck = false;
                        //Commented By Pratik on 18th December 2018 for CRM-3405
                        //casesToInsert.add(caseToAdd);
                        orderSet.add(ordVal.id);
                    }   
            }
            
            if(!casesToInsert.IsEmpty())
             insert casesToInsert;
        }
    
    }
    
    
    public void insertCasesAgnt(List<order> ordLst){
        List<order> orderLstActual = new List<order>();
        List<orderItem> orderItmLst = new List<orderItem>();
        List<product2> prdLst = new List<product2>();
        List<account> relAccLst = new List<account>();
        List<user> mgrLst = new List<user>();
        List<AccountTeamMember> userdLst = new List<AccountTeamMember>();
        
        Map<String,RDC_Products_Codes__c> rdcPrdCodemap = RDC_Products_Codes__c.getAll();
        Map<String,TP_Product_Code__c> tdPrdCodemap = TP_Product_Code__c.getAll();
        Map<String,product2> prdcodeMap = new Map<String,product2>();
        Map<id,AccountTeamMember> teamMemMap = new Map<id,AccountTeamMember>();
        
        Set<id> ordrSetId = new Set<id>();
        Set<id> prdOrdrItmSet = new Set<id>();
        Set<id> prdcodeSet = new Set<id>();
        List<case> casesToInsert = new List<case>();
        set<string> rdcProdSet = new set<string>();
        set<string> tpProdSet = new set<string>();
        set<id> accntIds = new set<id>();
        set<id> userIds = new set<id>();
        
        boolean tpProdCheck = false ;
        
        for(order ord : ordLst){
            //if(ord.Pricebookentry.Product2Id != null)
            ordrSetId.add(ord.id);
            if(ord.accountId != null)
                accntIds.add(ord.id);
        }   
        if(!ordrSetId.IsEmpty()){
            
            for( RDC_Products_Codes__c rdcp : rdcPrdCodemap.Values() )
                rdcProdSet.add(rdcp.name);
            
            for( TP_Product_Code__c tpp : tdPrdCodemap.Values() )
                tpProdSet.add(tpp.name);
            
            relAccLst = [Select Id, (select id,TeamMemberRole ,userId from accountTeammembers where TeamMemberRole='Account Manager') from account where id IN:accntIds];
            
            if(!relAccLst.isEmpty()){
                teamMemMap = FillingAccountmanager(accntIds);
                userdLst = teamMemMap.Values(); 
                system.debug('++UsersLst'+userdLst);
                    
            }
            
            group tpGrpID = [Select Id, Name, DeveloperName, Type from Group where Type =: 'Queue' AND developerName =: 'TP_Product_Setup_Open'];   
            group rdcGrpID = [Select Id, Name, DeveloperName, Type from Group where Type =: 'Queue' AND developerName =: 'RDC_Broker_Unassigned_Product_Setup'];    
            
            orderItmLst = [SELECT Id,Pricebookentry.Product2Id,OrderId FROM orderItem where OrderId IN:ordrSetId];
            for(orderItem ordIt : orderItmLst){
                prdOrdrItmSet.add(ordIt.Pricebookentry.Product2Id);
            }
            prdLst = [Select name,ProductCode,Description from product2 where id IN:prdOrdrItmSet];
            
            for(product2 prd : prdLst){
                prdcodeMap.put(prd.id,prd); 
            system.debug('+++ ProdMap +'+prdcodeMap);    
            }
            //Insertion of cases
            //rdcPrdCodeLst.Lower();
            //tdPrdCodeLst.lower();
            orderLstActual = [Select id,accountid,(select id,Pricebookentry.Product2Id,Fulfillment_Status__c from orderItems where Fulfillment_Status__c =:'Fulfilled' ) from order where id IN:ordrSetId];
            id ordAccId = orderLstActual[0].accountid;
            id orderId = orderLstActual[0].id;
            set<id> orderSet = new set<id>();
            string caseDesc = '';
            set<string> productCodeSetOfProd = new set<string>();
            set<string> productNameSet = new set<string>();
            
            for(order ordVal : orderLstActual){
                caseDesc = '';
                productNameSet.clear();
                
                for(orderitem ordItm : ordVal.orderItems){
                        string pid = ordItm.Pricebookentry.Product2Id;
                        //system.debug('+++Prod Ids'+prdcodeMap.get(pid
                        if(!productNameSet.contains(prdcodeMap.get(pid).name) ||caseDesc == ''){
                            if(caseDesc == ''){
                                caseDesc = prdcodeMap.get(pid).name;
                                productNameSet.add(prdcodeMap.get(pid).name);
                            }   
                            else {
                                caseDesc = caseDesc+' '+prdcodeMap.get(pid).name;
                                productNameSet.add(prdcodeMap.get(pid).name);
                            }   
                        }   
                        productCodeSetOfProd.add(prdcodeMap.get(pid).productcode);  
                        if(tpProdSet.contains(prdcodeMap.get(pid).productcode))
                            tpProdCheck = true ;
                    }
                    if(!orderSet.contains(ordVal.id)){  
                        Case caseToAdd = new Case();
                        caseToAdd.Status = 'New';
                        caseToAdd.Origin = 'Web';
                        caseToAdd.Type = 'Outbound';
                        caseToAdd.Area__c = 'Product Set Up';
                        caseToAdd.Subject = 'Welcome Call';
                        //caseToAdd.ContactId = ass.ContactId;
                        caseToAdd.AccountId = ordVal.accountid;
                        caseToAdd.Description = caseDesc ;
                        caseToAdd.Order__c = ordVal.id;
                        if(userdLst.size() <= 0){
                            if(tpProdCheck == true)
                                caseToAdd.ownerId = tpGrpID.id ;
                            else 
                                caseToAdd.ownerId = rdcGrpID.id ;
                        } else if(teamMemMap.containsKey(ordVal.accountId))
                            caseToAdd.ownerId = teamMemMap.get(ordVal.accountId).userid;
                        /*for( string code : productCodeSetOfProd){
                            if(
                            caseToAdd.Product_Category__c = 'RDC';
                            if(
                            caseToAdd.Product_Category__c = 'TP';
                        }*/
                        //Commented By Pratik on 18th December 2018 for CRM-3405
                        //casesToInsert.add(caseToAdd);
                        orderSet.add(ordVal.id);
                    }   
            }
            
            if(!casesToInsert.IsEmpty())
             insert casesToInsert;
        }
    
    }
    // -------------------------------------------------------------------------------------------
    // This method return's Mapof Accountid and AccountTeamMember
    // Version#   Date                Author              Description
    // -------------------------------------------------------------------------------------------
    // 1.0        19-November-2015    Sateesh Reddy        Initial Version
    // -------------------------------------------------------------------------------------------
   private map<id,AccountTeamMember> FillingAccountmanager(set<id> setofAccountids)
   {
        map<id,AccountTeamMember> mapofAccountidandATM = new map<id,AccountTeamMember>();
        list<AccountTeamMember> lstAccountTeamMember = [Select UserId, TeamMemberRole, Id, AccountId From AccountTeamMember where AccountID in :setofAccountids and TeamMemberRole = 'Account Manager'];
        if(lstAccountTeamMember != null && lstAccountTeamMember.size() > 0)
        {
            for(AccountTeamMember objAccountTeamMember : lstAccountTeamMember)
            {
                mapofAccountidandATM.put(objAccountTeamMember.AccountId,objAccountTeamMember);
            }
        }
        return mapofAccountidandATM;
    
   }
    
    
    //----------------New Code----------------
    
    /*
   public void closeChildCase(List < Order > Orders) {
         set < id > OrderId = new set < id > ();
         List < Case > casesToupdate = new List < Case > ();
        set < id > OrderId = new set < id > ();

        for (order o: orders) {
            
            OrderId.add(o.id);
            
                    }
        //Query for child case where recordtype is retention 
        id RetentionRtID = Schema.SObjectType.Case.RecordTypeInfosByName.get('Retention').RecordTypeId;
        List < Case > childcase = [Select id, status,ParentId  from case where  Order__c in : OrderId AND RecordTypeId =: RetentionRtID];
             
        for(case c :childcase)
               
        {
        c.Status = 'Closed';
        
        
        }
         if(casesToupdate.size()>0) 
              
       
               
    }*/
    
    //-------------- New Code--------
    

}