public class QuoteLineItemTriggerHandlerManager {


    public QuoteLineItemTriggerHandlerManager() {
    }
    
    public void updateAsset(Map<Id,BigMachines__Quote_Product__c> QuoteProductMap, Map<Id,BigMachines__Quote_Product__c> QuoteProductoldMap){
        Map<Id,AssetStructure> mapAssetStructure = new Map<Id,AssetStructure>();
        List<Asset> lstupdateAsset = new List<Asset>();
        List<Error__c> errorList = new List<Error__c>();
         
        System.debug('QuoteProductMap:'+QuoteProductMap);
        for(BigMachines__Quote_Product__c bmqp : [Select Id, Asset_Structure__c, BigMachines__Quote__c, Line_Type__c, BigMachines__Quote__r.Name, DocumentNumber__c, Billing_Period__c, Need_Manual_Renew__c, BigMachines__Quote__r.BigMachines_Quote_Type__c from BigMachines__Quote_Product__c where Id IN: QuoteProductMap.keySet()]) {
            If(bmqp.BigMachines__Quote__r.BigMachines_Quote_Type__c == 'Auto-Renew' && bmqp.Line_Type__c == 'Renew'){
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
                    mapAssetStructure.put(bmqp.id,AsstStrctlst);
                    System.debug('mapAssetStructure:'+mapAssetStructure);
                }
                String wbserAuReneLineStr = null;
                if(mapAssetStructure.get(bmqp.id).assetId != null) {
                    Id Assetid = mapAssetStructure.get(bmqp.id).assetId;
                    System.debug('Assetid:'+Assetid);
                    
                    if(!bmqp.Need_Manual_Renew__c) {
                        System.debug('bmqp.id:'+bmqp.id);
                        Asset TempAsst = New Asset();
                        TempAsst.id = Assetid;
                        TempAsst.AutoRenewQuoteProduct__c = bmqp.id;
                        //Adding Asset to the List for update
                        lstupdateAsset.add(TempAsst);
                    }
                }else{
                    errorList.add(new Error__c(Entity_Id__c = bmqp.id,Interface_Name__c = 'QuoteProduct',Name ='QuoteProductUpdation',Error_Description__c = 'Error: Asset Structure on Quote Product is Blank'));
                
                }
            }                
        }
        //Updating Asset
        if(!lstupdateAsset.isEmpty())
            update lstupdateAsset;

         if(!errorList.isEmpty()) {
          insert errorList;
        }
    }
    
    /*
    @future(callout=true)
    public static void autoRenewalQuote (String QuoteId, String updateAutoRenewalQuoteList) {
        List<WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper> lstwbserAuReneLine = (List<WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper>)JSON.deserialize(updateAutoRenewalQuoteList, List<WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper>.class);
        WebserviceCallBigMachineQuoteCls wbcbmq = new WebserviceCallBigMachineQuoteCls();
        wbcbmq.UpdateDeleteAutoRenewalQuote(QuoteId, lstwbserAuReneLine);  
    }
    */
    
    public void deleteQuoteProduct(Map<Id,BigMachines__Quote_Product__c> QuoteProductMap, Map<Id,BigMachines__Quote_Product__c> QuoteProductoldMap){
    
        Map<Id,AssetStructure> mapAssetStructure = new Map<Id,AssetStructure>();
        List<Asset> lstupdateAsset = new List<Asset>();
        List<BigMachines__Quote_Product__c> delQpList = new List<BigMachines__Quote_Product__c>();
        List<Error__c> errorList = new List<Error__c>();
         
        System.debug('QuoteProductMap:'+QuoteProductMap);
        for(BigMachines__Quote_Product__c bmqp : [Select Id, Asset_Structure__c, BigMachines__Quote__c, Line_Type__c, BigMachines__Quote__r.Name, DocumentNumber__c, Billing_Period__c, Need_Manual_Renew__c, BigMachines__Quote__r.BigMachines_Quote_Type__c from BigMachines__Quote_Product__c where Id IN: QuoteProductMap.keySet()]) {
            If(bmqp.BigMachines__Quote__r.BigMachines_Quote_Type__c == 'Auto-Renew' && bmqp.Line_Type__c == 'Renew'){
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
                    mapAssetStructure.put(bmqp.id,AsstStrctlst);
                    System.debug('mapAssetStructure:'+mapAssetStructure);
                }
                String wbserAuReneLineStr = null;
                if(mapAssetStructure.get(bmqp.id).assetId != null) {
                    Id Assetid = mapAssetStructure.get(bmqp.id).assetId;
                    System.debug('Assetid:'+Assetid);
                    
                    if(bmqp.Need_Manual_Renew__c) {
                        if(bmqp.Need_Manual_Renew__c != QuoteProductoldMap.get(bmqp.Id).Need_Manual_Renew__c) {
                            //Adding Quote Products to the List for delete
                            //delQpList.add(bmqp); 
                            if(mapAssetStructure.get(bmqp.id).Type != 'Add'){
                                Asset TempAsst                  = New Asset();
                                TempAsst.id                     = Assetid;
                                TempAsst.Follow_Up_Status__c    = 'Manual Renewal';
                                TempAsst.Renewal_Type__c        = 'Manual';
                                TempAsst.KickoutReason__c       = 'Oversold Market';
                                //Adding Asset to the List for update
                                lstupdateAsset.add(TempAsst);
                            }
                            /*
                            List<WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper> lstwbserAuReneLine= new List<WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper>();
                            WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper auto = new WebserviceCallBigMachineQuoteCls.AutoRenewalQuoteLineWrapper();
                            auto.BMDocumentNumber = String.valueof(bmqp.DocumentNumber__c);
                            auto.BMActionRequired = 'Remove';
                            auto.BillingType = bmqp.Billing_Period__c;
                            lstwbserAuReneLine.add(auto); 
                            wbserAuReneLineStr = JSON.serialize(lstwbserAuReneLine);
                            */
                        }
                    }
                }else{
                    errorList.add(new Error__c(Entity_Id__c = bmqp.id,Interface_Name__c = 'QuoteProduct',Name ='QuoteProductUpdation',Error_Description__c = 'Error: Asset Structure on Quote Product is Blank'));
                
                }
                /*
                if(!Test.isRunningTest() && wbserAuReneLineStr != null) {
                    String quotId = bmqp.BigMachines__Quote__r.Id;
                    autoRenewalQuote(quotId, wbserAuReneLineStr); 
                }
                */
            }                
        }
        //Updating Asset
        if(!lstupdateAsset.isEmpty())
            update lstupdateAsset;

         if(!errorList.isEmpty()) {
          insert errorList;
        }
    }
    
    public void updateNotRenewAsset(Map<Id,BigMachines__Quote_Product__c> QuoteProductMap, Map<Id,BigMachines__Quote_Product__c> QuoteProductoldMap){
    /*
        Map<Id,AssetStructure> mapAssetStructure = new Map<Id,AssetStructure>();
        List<Asset> lstupdateAsset = new List<Asset>();
        List<BigMachines__Quote_Product__c> delQpList = new List<BigMachines__Quote_Product__c>();
        List<Error__c> errorList = new List<Error__c>();
        Map<Id, Id> mapAsstQp = new Map<Id, Id>();
        Map<Id, String> asstMap = new Map<Id, String> ();
         
        System.debug('QuoteProductMap:'+QuoteProductMap);
        System.debug('QuoteProductoldMap:'+QuoteProductoldMap);
        if(!QuoteProductoldMap.isEmpty()) {
            for(BigMachines__Quote_Product__c bmqp : [Select Id, Asset_Structure__c, BigMachines__Quote__c, Line_Type__c, BigMachines__Quote__r.Name, DocumentNumber__c, Billing_Period__c, Need_Manual_Renew__c, BigMachines__Quote__r.BigMachines_Quote_Type__c from BigMachines__Quote_Product__c where Id IN: QuoteProductoldMap.keySet() and Need_Manual_Renew__c = false]) {
                If(bmqp.BigMachines__Quote__r.BigMachines_Quote_Type__c == 'Auto-Renew' && bmqp.Line_Type__c == 'Renew'){
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
                        mapAssetStructure.put(bmqp.id,AsstStrctlst);
                        System.debug('mapAssetStructure:'+mapAssetStructure);
                        if(mapAssetStructure.get(bmqp.id).Type != 'Add')
                            mapAsstQp.put(bmqp.id,mapAssetStructure.get(bmqp.Id).assetId);
                    }
                }
            }
            if(!mapAsstQp.isEmpty()) {
                for(Asset asst: [Select Id, Renewal_Status__c from Asset where Id IN: mapAsstQp.values()]) {
                    asstMap.put(asst.Id, asst.Renewal_Status__c);
                }
            }        
                    if(!mapAsstQp.isEmpty()) {
                        for(Id bmqpid: mapAsstQp.keyset()) {
                            Id Assetid = mapAsstQp.get(bmqpid);
                            if(!asstMap.isEmpty() && asstMap.get(Assetid) != 'Pending Fulfillment') {
                                System.debug('Assetid:'+Assetid);
                            
                                Asset TempAsst                  = New Asset();
                                TempAsst.id                     = Assetid;
                                TempAsst.Follow_Up_Status__c    = 'Will Not Renew';
                                TempAsst.Renewal_Status__c      = 'Do Not Renew';
                                TempAsst.Reason__c              = 'Not Interested';
                                TempAsst.Reason_Details__c      = 'Auto-Renew';
                                //Adding Asset to the List for update
                                lstupdateAsset.add(TempAsst);
                            }
                            else{
                                errorList.add(new Error__c(Entity_Id__c = Assetid,Interface_Name__c = 'QuoteProduct',Name ='QuoteProductUpdation',Error_Description__c = 'Error: Asset Quote Product is Blank'));                           
                            }
                        }
                    }
                }
        //Updating Asset
        if(!lstupdateAsset.isEmpty())
            update lstupdateAsset;

         if(!errorList.isEmpty()) {
          insert errorList;
        }*/
    }
    
    // CRM-6197, CRM-6063 & CRM-6098  - Approve Quote once BLA Focus Fire Setup is completed
    public void approveQuote(Map<Id,BigMachines__Quote_Product__c> newMap, Map<Id,BigMachines__Quote_Product__c> oldMap) {
        List<String> blaProductCodes = Label.Opcity_BLA_Product_Codes.split(',');
        Set<String> quoteIds = new Set<String>();
        for (BigMachines__Quote_Product__c newQP : newMap.values()) {
            if (blaProductCodes.contains(newQP.Name)) {
                BigMachines__Quote_Product__c oldQP = oldMap.get(newQP.Id);
                if (newQP.Focus_Fire_Status_Completed__c && !oldQP.Focus_Fire_Status_Completed__c) {
                    quoteIds.add(newQP.Bigmachines__Quote__c);
                }
            }
        }
        
        if (!quoteIds.isEmpty()) {
            for (AggregateResult result : [SELECT Bigmachines__Quote__c, Count(Id)cnt FROM BigMachines__Quote_Product__c WHERE Bigmachines__Quote__c IN :quoteIds and Name IN :blaProductCodes AND Focus_Fire_Status_Completed__c = false GROUP BY Bigmachines__Quote__c]) {
                if (Integer.valueOf(result.get('cnt')) > 0) {
                    quoteIds.remove(String.valueOf(result.get('Bigmachines__Quote__c')));
                }
            }
        }
        if (!quoteIds.isEmpty()) {
            List<Bigmachines__Quote__c> quotes = new List<Bigmachines__Quote__c>();
            for (Bigmachines__Quote__c quote : [SELECT Bigmachines__Status__c FROM Bigmachines__Quote__c WHERE ID IN :quoteIds]) {
                quote.Bigmachines__Status__c = 'Approved';
                quotes.add(quote);
            }
            if (!quotes.isEmpty()) {
                update quotes;
            }
        }
    }
    // CRM-6098 - End
}