//Name        : AutoRenewalQuoteSubmitBatch 
//Description : Quote will be submitted/Quote Product will be deleted based on the Customer response creating Lead by Eloqua.
//Frequencey  : Everytime new Lead gets created as part of Customer Response from Eloqua
//Author      : Pallavi Tammana
//History     : 3/15/2017[Pallavi] CRM-1131: Auto Renew Eloqua Lead Trigger fails the whole batch when one Lead record in the batch fails

Public class AutoRenewalCustmrResponseProcessing {
    
    public AutoRenewalCustmrResponseProcessing (List<Lead> LeadAutoRenewList) {   
        Set<String> setQuoteNumber = new Set<String>();
        Map<Id, String> asstMap = new Map<Id, String> ();
        Map<String, String> bmqpTermMap = new Map<String, String> ();
        Map<String, List<String>> mapCustRes = new Map<String, List<String>>();
        Map<String, AssetStructure> mapAssetStructure = new Map<String, AssetStructure>();
        Map<String, String> mapAsstQp = new Map<String, String>();              
        Map<String, String> mapQuoteline = new Map<String, String>();
        Map<String, String> mapQuotedoc = new Map<String, String>();
        Map<String, String> bmqpBillingMap = new Map<String, String>();
        Map<String, Id> QuoteLeadMap  = new Map<String, Id>();
        List<Lead> leadList = new List<Lead>();
        Set<Lead> setlead = new Set<Lead> ();
        List<Asset> AssetList = new List<Asset>();
        Set<Asset> setAsset = new Set<Asset> ();
        Map<String, Id> bmqpDocId = new Map<String, Id>();
        Map<String, Id> bmqLeadIdMap = new Map<String, Id>();
        
        
        Group grp = [SELECT Id FROM Group where Group.Type='Queue' and DeveloperName = 'Sales_Ops' limit 1];
        for (Lead ld : LeadAutoRenewList) {
            System.debug('ld:'+ld);
            if(!ld.CustomerResponseProcessed__c && ld.CustomerResponse__c != null && ld.QuoteNumber__c != null && ld.Marketing_Lead_Type__c == 'Auto-Renew') {          
                setQuoteNumber.add(ld.QuoteNumber__c);
                QuoteLeadMap.put(ld.QuoteNumber__c, ld.Id);
                
                List<String> custRes = ld.CustomerResponse__c.split(';');
                mapCustRes.put(ld.QuoteNumber__c, custRes);                         
                
                System.debug('setQuoteNumber:'+setQuoteNumber);
                System.debug('mapCustRes:'+mapCustRes);         
            }       
        }
        if(!setQuoteNumber.isEmpty()) {
            for(BigMachines__Quote_Product__c bmqp : [Select Id, BigMachines__Quote__c, BigMachines__Quote__r.Name, BigMachines__Quote__r.BigMachines_Quote_Type__c, Billing_Period__c, Contract_Term__c, DocumentNumber__c, Asset_Structure__c
                                from BigMachines__Quote_Product__c where BigMachines__Quote__r.Name IN: setQuoteNumber]) {
                if(bmqp.BigMachines__Quote__r.BigMachines_Quote_Type__c == 'Modify') {
                    Lead ldNew = new Lead();
                    ldNew.Id = QuoteLeadMap.get(bmqp.BigMachines__Quote__r.Name);
                    ldNew.Status = 'Rejected';
                    ldNew.Rejected_Reason__c = 'Conflict In Cust Response Processing';
                    ldNew.CustomerResponseProcessed__c = true;
                    ldNew.OwnerId = grp.id;
                    setlead.add(ldNew);
                    bmqLeadIdMap.put(bmqp.BigMachines__Quote__r.Name, bmqp.BigMachines__Quote__c);
                }
                else {
                    Lead ldNew = new Lead();
                    ldNew.Id = QuoteLeadMap.get(bmqp.BigMachines__Quote__r.Name);
                    ldNew.Status = 'Converted';
                    ldNew.CustomerResponseProcessed__c = true;
                    setlead.add(ldNew); 
                
                    AssetStructure AsstStrctlst = new AssetStructure(); 
                    String JSONStr = bmqp.Asset_Structure__c;
                    // Parse entire JSON response.
                    if(JSONStr!=null){
                        JSONParser parser = JSON.createParser(jsonStr);
                        while (parser.nextToken() != null) {
                            // Start at the array of AsstStrctlsts.
                            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                                while (parser.nextToken() != null) {
                                    // Advance to the start object marker to
                                    //  find next AsstStrctlst statement object.
                                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                                        // Read entire AsstStrctlst object, including its array of line items.
                                        AsstStrctlst = (AssetStructure)parser.readValueAs(AssetStructure.class);
                                        System.debug('AsstStrctlst:'+AsstStrctlst);
                                    }
                                }
                            }
                        }
                        mapAssetStructure.put(String.valueof(bmqp.DocumentNumber__c),AsstStrctlst);
                        System.debug('mapAssetStructure:'+mapAssetStructure);                        
                        mapAsstQp.put(bmqp.Id,mapAssetStructure.get(String.valueof(bmqp.DocumentNumber__c)).assetId);
                        System.debug('mapAsstQp:'+mapAsstQp);
                        mapQuotedoc.put(bmqp.Id, String.valueof(bmqp.BigMachines__Quote__c));
                        bmqpTermMap.put(bmqp.Id, String.valueof(bmqp.Contract_Term__c));
                        bmqpBillingMap.put(bmqp.Id,bmqp.Billing_Period__c);
                        String conCat = String.valueof(bmqp.BigMachines__Quote__r.Name)+ '-' + String.valueof(bmqp.DocumentNumber__c);
                        bmqpDocId.put(conCat,bmqp.Id);
                        System.debug('conCat:'+conCat);
                        
                    }
                }
            }
        }
        if(!mapAsstQp.isEmpty()) {
            for(Asset asst: [Select Id, Renewal_Status__c from Asset where Id IN: mapAsstQp.values()]) {
                asstMap.put(asst.Id, asst.Renewal_Status__c);
            }
        }
        String wbserAuReneLineStr = null;
        if(!mapCustRes.isEmpty()) {
            for(String bmq : mapCustRes.keySet()) {
                if(!bmqLeadIdMap.containsKey(bmq)) {
                    System.debug('bmq:'+bmq);
                    List<WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper> lstwbserAuReneLine= new List<WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper>();                        
                    String quotId = null;
                //for(List<String> strlstlp : mapCustRes.get(bmq))
                    //FOR(String strlp : strlstlp)
                    for(String strlp : mapCustRes.get(bmq)){
                        System.debug('strlp:'+strlp);
                        List<String> tempstring = strlp.split(',');                   
                        String documentId;
                        String renewType;
                        String billingType;
                        String renewReason;
                        Integer I = 0;
                        String conCat;
                        for(String strl : tempstring){
                            I = I+1;
                            System.debug('I:'+I);
                            If(I == 1)
                                documentId = strl;
                                conCat = bmq+ '-' +documentId;
                            If(I == 2) {
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
                                if(renewType == 'Do Not Renew') {
                                    renewType                   = 'Remove';
                                    //CRM-1131: Auto Renew Eloqua Lead Trigger fails the whole batch when one Lead record in the batch fails
                                    if(bmqpDocId.get(conCat) != null){
                                        //Updating Asset
                                        Asset asst                  = new Asset();
                                        asst.id                     = mapAsstQp.get(bmqpDocId.get(conCat));
                                        asst.Follow_Up_Status__c    = 'Will Not Renew';
                                        asst.Renewal_Status__c      = 'Do Not Renew';
                                        asst.Reason__c              = renewReason;
                                        asst.Reason_Details__c      = 'Auto-Renew';
                                        setAsset.add(asst);
                                    }
                                    else{
                                        Lead ldNew = new Lead();
                                        ldNew.Id = QuoteLeadMap.get(bmq);
                                        ldNew.Status = 'Rejected';
                                        ldNew.Rejected_Reason__c = 'Conflict In Cust Response Processing';
                                        ldNew.CustomerResponseProcessed__c = true;
                                        ldNew.OwnerId = grp.id;
                                        setlead.add(ldNew);
                                    }
                                }
                                if(!asstMap.isEmpty() && asstMap.get(mapAsstQp.get(bmqpDocId.get(conCat))) == 'Pending Fulfillment') {
                                    renewType                   = 'Remove';
                                }
                                if(renewType == 'Renew: Pay-in-full') {
                                    String term = bmqpTermMap.get(bmqpDocId.get(conCat));
                                    QuoteProductContractTerm__c conTerm = QuoteProductContractTerm__c.getInstance(term);
                                    System.debug('conTerm:'+conTerm);
                                    if(conTerm != null)
                                        billingType = conTerm.Term__c;
                                }
                                else {
                                   billingType =  bmqpBillingMap.get(bmqpDocId.get(conCat));
                                }
                            }               
                        }
                        System.debug('asstMap:'+asstMap);
                        System.debug('documentId:'+documentId);
                        System.debug('conCat:'+conCat);
                        System.debug('renewType:'+renewType);
                        System.debug('billingType:'+billingType);
                        
                        if(renewType == 'Remove' || (!asstMap.isEmpty())) {
                            WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper auto = new WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper();
                            auto.BMDocumentNumber = documentId;
                            auto.BMActionRequired = renewType;
                            auto.BillingType = billingType;
                            lstwbserAuReneLine.add(auto);                        
                        }
                        quotId = mapQuotedoc.get(bmqpDocId.get(conCat));
                        System.debug('quotId:'+quotId);
                                                    
                    }
                    wbserAuReneLineStr = JSON.serialize(lstwbserAuReneLine);
                    System.debug('wbserAuReneLineStr:'+wbserAuReneLineStr);
                    if(!Test.isRunningTest() && wbserAuReneLineStr != null && quotId != null)
                        autoRenewalQuote(quotId, wbserAuReneLineStr);
                }
            }
        }
        
        if(!setlead.isEmpty()) {
            leadList.addall(setlead);
            Update leadList;
        }
        
        if(!setAsset.isEmpty()) {
            AssetList.addall(setAsset);
            Update AssetList;
        }
        
        
    }
    @future(callout=true)
    public static void autoRenewalQuote (String QuoteId, String updateAutoRenewalQuoteList) {
        List<WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper> lstwbserAuReneLine = (List<WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper>)JSON.deserialize(updateAutoRenewalQuoteList, List<WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper>.class);
        WebserviceCallBigMachineQuoteCls wbcbmq = new WebserviceCallBigMachineQuoteCls();
        wbcbmq.UpdateDeleteAutoRenewalQuote(QuoteId, lstwbserAuReneLine);
        System.debug('wbcbmq.CPQReturnedMsg:'+wbcbmq.CPQReturnedMsg);
        System.debug('QuoteId:'+QuoteId);
        if(wbcbmq.CPQReturnedMsg != '') {
            BigMachines__Quote__c bmq  = new BigMachines__Quote__c();
            bmq.Id                     = QuoteId;
            bmq.SalesOperations__c     = True;            
            System.debug('bmq:'+bmq);          
            Update bmq;
        }
        
    }
      
}