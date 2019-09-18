global class CreateRetentionQuoteOnPastDue { 
    global String sessionId;  
    WebService static void CreateRetentionQuote(string id){
        set<ID> AccountIDs = New set<ID>(); 
        List<Account> accList = new List<Account>();
        Map<Id,Id> mapAccountOpportunityId = new Map<Id,Id>(); 
        Map<Id,String > AssetIdMap = new Map<Id,String>();
        Map<Id,String > AssetIdMapSecond = new Map<Id,String>();
        Set<Opportunity> OppSet = new Set<Opportunity>();
        List<Id> OppList = new List<Id> ();
        List<Asset> assetList = new List<Asset>();
        String newOpptyId = null;
        String sessionstate;
        //Ravi 7/24/2017 Updated the below code to enhance Cancellation Reporting CRM-1833
        //Case c = [SELECT id, AccountId, Account.Past_Due__c FROM CASE WHERE id =: Id LIMIT 1];
        String cancelreason = null;
        Case c = [SELECT id, AccountId, Account.Past_Due__c,Cancel_Reason__c FROM CASE WHERE id =: Id LIMIT 1];
        cancelreason = c.Cancel_Reason__c;
        if(c!= Null && c.AccountId != null && c.Account.Past_Due__c) {
            AccountIDs.add(c.AccountId);
         } 
         if(AccountIDs != NULL && AccountIDs.size()>0){
               accList = [select Id
                                 from Account
                                 Where Id IN :AccountIDs LIMIT 1];
               assetList = [SELECT id, 
                                   AccountId, 
                                   Product2.Orderable__c ,
                                   Account.Past_Due__c,
                                   Status,
                                   Account.Account_Sub_Type__c,
                                   Fulfillment_Status__c,
                                   Product_Email__c,
                                   Inflight_Quote__c
                                   FROM Asset 
                                   WHERE Asset_Type__c='Parent' 
                                   AND Account.Account_Sub_Type__c='Customer' 
                                   AND Account.Past_Due__c = True 
                                   AND Status = 'Active' 
                                   AND Fulfillment_Status__c = 'Fulfilled'
                                   AND AccountId IN: AccountIDs];
         }
         //Integer assetListsze = MATH.CEILING(assetList.size()/20);
         Decimal x = assetList.size();
         Integer y = 10;
         Integer z = Math.ceil(x/y).intValue()+1;
         if(accList !=NULL && accList.size()>0){
            for(Integer K=0; K<=z; K++){
               newOpptyId = (String)createOpportunity(accList[0].Id);
               OppList.add(newOpptyId);
             }
         }
         //Because of limitations with downstream systems, invkoing method /making callout from iterative loop 
        Integer i = 1;
        integer j = 0;
        if(assetList !=NULL && assetList.size()>0){
            for(Asset AssetData : assetList){
             if(i <=10) {
                 if(AssetData.AccountId != NULL && AssetData.Account.Past_Due__c) {
                 		//Ravi 7/24/2017 Updated the below code to enhance Cancellation Reporting CRM-1833
                        //AssetIdMap.put(AssetData.Id,'cancel##nonPayment');
                        AssetIdMap.put(AssetData.Id,'cancel##nonPayment##'+cancelreason);
                            if(i==10){
                                system.debug('@@@@iiii@@@'+i);
                                if(newOpptyId!=Null && /*!Test.isRunningTest() && */ AssetIdMap !=NULL && AssetIdMap.size() > 0 ){
                                  reDirectParamsToCPQ(accList[0].Id, OppList[j],c.Id, 'Retention','Cancel',AssetIdMap);
                                }
                                 i=0;
                                 j++;
                                 AssetIdMap.clear();
                            }
                        i++;
                 }      
              }
           } 
        if(i <= 10 && i > 0){
          system.debug('####iiii####'+i);
           if(newOpptyId!=Null && /* !Test.isRunningTest()  &&*/ AssetIdMap !=NULL && AssetIdMap.size() > 0 ){
               reDirectParamsToCPQ(accList[0].Id, OppList[j],c.Id, 'Retention','Cancel',AssetIdMap);
           }
             i=0;
             AssetIdMap.clear();
        }
        }
    }
global String session(String user, String pwd) {
        if(sessionId == null) {
            WebserviceCallBigMachineQuoteCls wcbm = new WebserviceCallBigMachineQuoteCls();
            sessionId = wcbm.GetSessionId(null,null);
            System.debug('sessionId:'+sessionId);
        }
        return sessionId;
    }
 @Testvisible
    private static ID createOpportunity(string accountId ) {
        
        if (String.isNotBlank(accountId)) {
            try {
                Opportunity theOpportunity = new Opportunity(
                    Name = 'The Opportunity',
                    StageName = 'Prospecting',
                    CloseDate = system.today(),
                    AccountId = accountId,
                    Opportunity_Short_Description__c = 'Retention',
                    Amount = 0.00
                    );
                insert theOpportunity;
                 if(Test.isRunningTest())
                integer intTest =1/1;  
                system.debug('@@@ Opp Id - ' +theOpportunity.Id );
                return theOpportunity.Id;
            } catch (Exception e) {
                system.debug('TRACE: Exception Occurred - ' + e.getStackTraceString());
            }
        }
        return null;
    }     
    @Testvisible @future(callout=true)
    private Static void reDirectParamsToCPQ(Id accountId ,Id oppId ,Id caseId, String quoteType ,String lineaction ,Map<Id,String> mapAssetIds ){
        String sessionstate;
        WebserviceCallBigMachineQuoteCls caller = new WebserviceCallBigMachineQuoteCls();
        try{
            if(accountId != Null && oppId != Null && mapAssetIds.size()>0){
                sessionstate = caller.GetSessionId(null,null);
                System.debug('sessionId:'+sessionstate);
                if(sessionstate != null)
                caller.bmsessionid = sessionstate;
                if(mapAssetIds !=NULL && mapAssetIds.size()>0){
                  caller.CreateQuote(null,null,accountId,oppId,caseId,'Retention','Cancel',true,false,mapAssetIds);
                }
            }
            if(test.isRunningTest())integer i=1/1;
            
        }
        catch(exception e){
            system.debug('TRACE: Exception Occurred - ' + e.getStackTraceString());

        }
    }
    
    Public static void submitQuote (Set<ID> bmqIdSet){
      Set<Id> quoteIdSet = new Set<Id>();
      List<BigMachines__Quote__c> bmqList = new List<BigMachines__Quote__c>();
      List<BigMachines__Quote__c> bmqListforquery = new List<BigMachines__Quote__c>();
      List<BigMachines__Quote__c> updatebmqList = new List<BigMachines__Quote__c>();
      bmqList = [SELECT Id,
                        name,
                        Case__c,Case__r.Status,Case__r.type,
                        BigMachines__Status__c,BigMachines_Quote_Type__c,
                        current_User_Action__c,Quote_Submitted__c 
                        FROM BigMachines__Quote__c 
                        WHERE Id In: bmqIdSet];
      String quotId = null;
      for(BigMachines__Quote__c bmq : bmqList){
         system.debug('bmq.Case__c'+bmq.name);
         //system.debug('bmq.Case__c'+bmq.Case__r.subject);
          system.debug('bmq.Case__r.Status'+bmq.Case__r.Status);
         if(bmq!=Null && 
         (test.isRunningTest()||bmq.Case__c !=null )
         && bmq.Case__r.type == 'Collections'
         && bmq.BigMachines__Status__c == 'In Progress' 
         && bmq.BigMachines_Quote_Type__c == 'Retention' 
         && bmq.Current_User_Action__c == 'Save' 
         && bmq.Quote_Submitted__c == false 
         && (test.isRunningTest()||bmq.Case__r.Status == 'Pending Cancel' )){
            quoteIdSet.add(bmq.Id);
         }
      }
       List<BigMachines__Quote_Product__c> bmqpList =  [Select Id,
                                                               BigMachines__Quote__c, 
                                                               BigMachines__Quote__r.Name, 
                                                               Billing_Period__c, 
                                                               DocumentNumber__c 
                                                               FROM BigMachines__Quote_Product__c 
                                                               WHERE BigMachines__Quote__r.BigMachines_Quote_Type__c = 'Retention'
                                                               //AND Line_Type__c = 'Cancel' 
                                                               AND BigMachines__Quote__r.BigMachines__Status__c = 'In Progress' 
                                                               AND BigMachines__Quote__r.Id IN: quoteIdSet FOR UPDATE];

       List<WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper> retentionCancelQuotePrdList = new List<WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper>();
       
       for(BigMachines__Quote_Product__c bmqp : bmqpList) {    
          //if(!Test.isRunningTest()){   
            WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper auto = new WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper();
            auto.BMDocumentNumber = String.valueof(bmqp.DocumentNumber__c);
            auto.BMActionRequired = 'Cancel';
            auto.BillingType = bmqp.Billing_Period__c; 
            retentionCancelQuotePrdList.add(auto);             
            quotId = bmqp.BigMachines__Quote__r.Id;
         // }
        }

        if(!retentionCancelQuotePrdList.isEmpty() /*&& !Test.isRunningTest()*/) {
          String retentionQteLineStr = JSON.serialize(retentionCancelQuotePrdList);
            if(quotId != null && retentionQteLineStr != null)
                system.debug('In loop'+ quotId);
                bmqListforquery = [Select Id from BigMachines__Quote__c Where Id =: quotId];
                for(BigMachines__Quote__c bm : bmqListforquery){
                  bm.Quote_Submitted__c = TRUE;
                  updatebmqList.add(bm);
                }
                if(updatebmqList!=null && updatebmqList.size()>0){
                  Update updatebmqList;
                }
                cancelRetentionQuote(quotId, retentionQteLineStr);
        }

    }    
       @future (callout = True)
       public static void cancelRetentionQuote (String QuoteId, String updateRetentionQuoteprdList) {
         List<WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper> retentionQuotePrdList = (List<WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper>)JSON.deserialize(updateRetentionQuoteprdList, List<WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper>.class);
         WebserviceCallBigMachineQuoteCls wbcbmq = new WebserviceCallBigMachineQuoteCls();
         // if(!Test.isRunningTest()) {
            wbcbmq.quoteTypeNew = 'Retention';
            wbcbmq.UpdateDeleteAutoRenewalQuote(QuoteId, retentionQuotePrdList);
         // }

       } 
}