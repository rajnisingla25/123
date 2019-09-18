//Name        : ARIIResponseQuoteCreationBatch
//Description : This Batch creates quote for all auto renewable assets which are due for renewal in the following month.
//Frequencey  : First of every month
//Author      : Pallavi Tammana

global class ARIIResponseQuoteCreationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts,Database.Stateful{
    global String Query;
    global String assetId;
    global Map<Id,Id> mapAsstAccountIDs = new Map<Id,Id>();
    global Map<Id, List<Id>> AsstIDMap = new Map<Id, List<Id>>();
    global set<ID> AccountIDs = new set<ID>();
    global Map<Id,Id> mapAccountOpportunityId = new Map<Id,Id>();
    global String sessionId; 
     
    
    global ARIIResponseQuoteCreationBatch (Set<Id> AcctIDs, Map<Id, List<Id>> AsstIDs, Map<Id,Id> mapAccntOpptyId){
        AccountIDs.addall(AcctIDs);
        AsstIDMap.putall(AsstIDs);
        mapAccountOpportunityId.putAll(mapAccntOpptyId);
        System.debug('AsstIDMap:'+AsstIDMap);            
        System.debug('mapAccountOpportunityId:'+mapAccountOpportunityId);
                             
    }
    global String session(String user, String pwd) {
        if(sessionId == null) {
            ARIICPQCalls wcbm = new ARIICPQCalls();
            sessionId = ARIICPQCalls.GetSessionId(null,null);
            System.debug('sessionId:'+sessionId);
        }
        return sessionId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        Query = 'SELECT ID FROM Account WHERE ID IN :AccountIDs ORDER BY ID';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        Map<Id,String> AssetIds = New Map<Id,String>();
        Map<Id, List<Id>> AcctAsstIds = New Map<Id, List<Id>>();
        Set<Id> AcctIds = new Set<Id>();
        
        List<Id> asstList = AsstIDMap.get(scope[0].ID);
        session(null,null); 
        System.debug('sessionId:'+sessionId);
                       
        for(Asset AssetData : [SELECT id, name, Parent_Asset__c, AccountId, Account.OwnerId, Product2Id, 
                                 Product2.ProductCode, Status, Product2.Orderable__c,Asset_Stage__c, Quantity, 
                                 Follow_Up_Status__c, Auto_Renewal__c, BOP_Code__c, Email__c,End_Date__c, Lead_Type__c, 
                                 Line_Type__c, List_Price__c, Market_Zip__c, Market__c, Market_Tier__c, Renewal_Type__c,
                                 Ultimate_Parent__c, Last_Order_Activity_Date__c, Start_Date__c, Total_Net__c, KickoutReason__c
                                 FROM Asset WHERE Asset_Type__c='Parent' AND Status = 'Active'                                  
                                 AND Id IN :asstList ORDER BY AccountId]){                                                
            //AssetIds.put(AssetData.id,'');
            AcctIds.add(AssetData.AccountId);
            if(AcctAsstIds.containsKey(AssetData.AccountId)) {
                List<Id> asstId = AcctAsstIds.get(AssetData.AccountId);
                asstId.add(AssetData.Id);
                AcctAsstIds.put(AssetData.AccountId, asstId);
            } else {
                AcctAsstIds.put(AssetData.AccountId, new List<Id> { AssetData.Id });
            }
            System.debug('AcctAsstIds:'+AcctAsstIds);
        }
                    
        System.debug('AssetIds:'+AssetIds);
        //Create Quote
        if (!Test.isRunningTest() && !AcctIds.isEmpty()){
            for(Id id: AcctIds) {
                List<Id> asstIds = AcctAsstIds.get(id);
                System.debug('asstIds:'+asstIds);
                for(Id asst: asstIds) {
                    AssetIds.put(asst,'');
                }
                System.debug('AssetIds:'+AssetIds);
                ARIICPQCalls wscbm = new ARIICPQCalls();
                System.debug('sessionId:'+sessionId);
                if(sessionId != null)
                    ARIICPQCalls.bmsessionid = sessionId;
                    ARIICPQCalls.CreateQuote(ID,mapAccountOpportunityId.get(ID),AssetIds);                 
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){
       
        set<Id> BMQIdset   = new set<Id>();
        Set<Id> BMQPIdSet = new Set<Id>();
        List<Id> asstList = new List<Id>();
        system.debug(' --- accountIds --> '+AccountIDs);
        system.debug(' --- AsstIDMap --> '+AsstIDMap);
        for(Id acct : AccountIDs){
            asstList.addAll(AsstIDMap.get(acct));
        }
        
        system.debug('--- > asstList --> '+asstList);
        
        for(Asset asst: [Select Id, AutoRenewQuoteProduct__c from Asset where Id IN: asstList]){
            BMQPIdSet.add(asst.AutoRenewQuoteProduct__c);
        }
        
        for(BigMachines__Quote_Product__c bmqp: [Select Id, BigMachines__Quote__c, BigMachines__Quote__r.Id from BigMachines__Quote_Product__c
                                            where BigMachines__Quote__r.BigMachines_Quote_Type__c = 'Auto-Renew' 
                                            AND BigMachines__Quote__r.BigMachines__Status__c = 'In Progress'
                                            AND Id IN: BMQPIdSet]){
                System.debug('bmqp.Id:'+bmqp.Id);
                if(bmqp.BigMachines__Quote__c != null)
                    BMQIdset.add(bmqp.BigMachines__Quote__r.Id);
        } 
        System.debug('BMQIdset:'+BMQIdset);
        //Scheduling further Jobs to process remaining records.                       
        if(!Test.isRunningTest() && !BMQIdset.isEmpty()) {       
            ARIIQuoteSubmitBatch QuoteBatch = new ARIIQuoteSubmitBatch(BMQIdset);
            database.executebatch(QuoteBatch,1);
        }                           
       
    }
}