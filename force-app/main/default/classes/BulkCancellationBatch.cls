public class BulkCancellationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    private Set<Id> bulkProcessIds;        // this will pass on to refund case creation batch in finish method. 
                                           // should not be altered anywhere except assignment in constructor.
    
    // Variables for execute method. Declared as global to avoid passing between different methods. 
    // These variables will be re-initialized for each batch execute
    private Map<Id, Bulk_Process__c> bulkRecsToUpdate;
    private Map<Id, Id> orderProdToDelete;
    private Map<Id, Asset> assetsToUpdate;
    private Map<Id, List<Asset>> parentAssetvsfulfillToAssets;
    
    public BulkCancellationBatch (Set<Id> bulkProcessIds) {
        this.bulkProcessIds = bulkProcessIds;
    }
    
    public Database.querylocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Description__c, asset__r.Asset_Type__c, asset__c, asset__r.Renewal_Order_Product__c, asset__r.AccountId, 
        asset__r.Subscription_Id__c, asset__r.Status, asset__r.Renewal_Status__c, Account__c, Cancellation_Effective_Date__c, 
        Cancellation_Type__c, Cancellation_Reason__c, Ignore_Claw_back__c,Refund_Case_Creation_Status__c, Renewal_Clearance_Status__c,
        SFDC_Asset_Cancellation_Status__c, Zuora_Subscription_Cancellation_Status__c, asset__r.Inflight_Quote__c 
        FROM Bulk_Process__c WHERE ID IN :bulkProcessIds Order By Asset__r.AccountId]);
    }
    
    public void execute(Database.BatchableContext BC, List<Bulk_Process__c> scope) {
        bulkRecsToUpdate = new Map<Id, Bulk_Process__c>();
        orderProdToDelete = new Map<Id, Id>();
        assetsToUpdate = new Map<Id, Asset>();
        parentAssetvsfulfillToAssets = new Map<Id, List<Asset>>();
        
        // CRM-6075 - Moved below code block in separate for loop
        Map<Id, Bulk_Process__c> toBeProcessedRecords = new Map<Id, Bulk_Process__c>();
        for (Bulk_Process__c rec : scope) {
            if (rec.asset__r.Status != 'Active') {
                rec.Description__c = 'Asset is not Active';
                rec.Status__c = 'Processed';
                bulkRecsToUpdate.put(rec.Asset__c, rec);
            }
            else if(rec.asset__r.Inflight_Quote__c != null && rec.asset__r.Inflight_Quote__c.length()>0) {
                rec.Status__c = 'Processed';
                rec.Description__c = 'Asset has an Inflight';
                if (rec.asset__r.Inflight_Quote__c.contains('Renew')) {
                    rec.Description__c += ' Renew Quote';
                }
                bulkRecsToUpdate.put(rec.Asset__c, rec);
            }
            else {
                toBeProcessedRecords.put(rec.Asset__c, rec);
            }
        }
        // CRM-6075 - End
        
        if (!toBeProcessedRecords.isEmpty()) {
            // CRM-6075 - Fetch Fulfill-To and Participant Assets for Cancellation
            for (Asset fulfillToAsset : [SELECT Parent_Asset__c, Asset_Type__c, (SELECT Asset_Type__c, Parent_Asset__r.Parent_Asset__c FROM Assets__r) FROM Asset WHERE Parent_Asset__c IN :toBeProcessedRecords.keySet()]) {
                List<asset> fulfillToAssets = parentAssetvsfulfillToAssets.get(fulfillToAsset.Parent_Asset__c);
                if (fulfillToAssets == null) {
                    fulfillToAssets = new List<asset>();
                }
                fulfillToAssets.add(fulfillToAsset);
                parentAssetvsfulfillToAssets.put(fulfillToAsset.Parent_Asset__c, fulfillToAssets);
            }
            // CRM-6075 - End
            
            for (Bulk_Process__c rec : toBeProcessedRecords.values()) {
                rec.Status__c = rec.Refund_Case_Creation_Status__c=='New'?'Pending Refund':'Processed';
                if (rec.Description__c == null) {
                    rec.Description__c = '';
                }
                
                Asset asset = new Asset(Id=rec.Asset__c, Asset_Type__c=rec.asset__r.Asset_Type__c);
                // Cancel Asset in SFDC
                if (rec.SFDC_Asset_Cancellation_Status__c == 'New') {
                    setFieldsToCancelAsset(asset, rec);   
                } 
                // Clear Renewal Fields 
                if (rec.Renewal_Clearance_Status__c == 'New') {                    
                    clearRenewalFields(asset, rec); 
                }
                // Cancel Subscription in Zuora
                if (rec.Zuora_Subscription_Cancellation_Status__c == 'New') {                            
                    cancelZuoraSubscription(rec); 
                }                              
                
                bulkRecsToUpdate.put(rec.Asset__c, rec);                        // Store Bulk Process records for DML out of loop
            }
        }
        
        deleteRenewalOrderProducts();                                       // Delete Renewal Order Product
        updateAssets();                                                     // Update Assets
        update bulkRecsToUpdate.values();                                   // Update Bulk Process Records
    }
    
    public void finish(Database.BatchableContext BC) {
        // 4th Step - Once all assets are cancelled, process refund batch for all accounts from this batch.
        BulkCancellationRefundCaseBatch batch = new BulkCancellationRefundCaseBatch(bulkProcessIds);
        DataBase.executeBatch(batch, 2000);
    }
    private void setFieldsToCancelAsset(Asset asset, Bulk_Process__c rec) {
        asset.Line_Type__c = 'Cancel';
        asset.Fulfillment_Status__c = 'Pending Fulfillment';          
        asset.Cancellation_Effective_Date__c = rec.Cancellation_Effective_Date__c!=null?rec.Cancellation_Effective_Date__c:System.today();
        asset.Cancel_Type__c = rec.Cancellation_Type__c;
        asset.Cancellation_Reason__c = rec.Cancellation_Reason__c;
        asset.Cancellation_Date__c = System.today();
        asset.Amend_Delta_Price__c = 0;
        asset.Delta_Price__c = 0;
        asset.Delta_Price_w_o_Tax__c = -0.01;
        if (rec.Ignore_Claw_back__c) {
            asset.Commission_field__c = 'Ignore';
        }
        assetsToUpdate.put(asset.Id, asset);    // Parent Asset
        // CRM-6075 - Cancel Fulfill-To and Paticipant Assets
        if (parentAssetvsfulfillToAssets.containsKey(asset.Id)) {
            for (Asset fulfillToAsset : parentAssetvsfulfillToAssets.get(asset.Id)) {
                fulfillToAsset.Line_Type__c = 'Cancel';
                fulfillToAsset.Fulfillment_Status__c = 'Pending Fulfillment';   
                assetsToUpdate.put(fulfillToAsset.Id, fulfillToAsset);  // Fulfill To Asset
                for (Asset participantAsset : fulfillToAsset.Assets__r) {
                    participantAsset.Line_Type__c = 'Cancel';
                    participantAsset.Fulfillment_Status__c = 'Pending Fulfillment';   
                    assetsToUpdate.put(participantAsset.Id, participantAsset);  // Participant To Asset
                }
            }
        }
        // CRM-6075 - End
        rec.SFDC_Asset_Cancellation_Status__c = 'Processed';
    }
    
    private void clearRenewalFields(Asset asset, Bulk_Process__c rec) {
        if (rec.asset__r.Renewal_Status__c == 'Pending Fulfillment' || rec.asset__r.Renewal_Order_Product__c != null) {
            asset.Renewal_Status__c = '';
            asset.Renewal_Start_Date__c = null;
            asset.Renewal_End_Date__c = null;
            asset.Inflight_Quote__c = '';
            orderProdToDelete.put(rec.asset__r.Renewal_Order_Product__c, rec.asset__c);
            assetsToUpdate.put(asset.Id, asset);
        }
        rec.Renewal_Clearance_Status__c = 'Processed';
    }
    
    // 1st Step
    private void cancelZuoraSubscription(Bulk_Process__c rec) {
        rec.Zuora_Subscription_Cancellation_Status__c = 'Processed';
        Map<String, String> fieldValues = new Map<String, String>();
        fieldValues.put('Type', 'Cancellation');
        fieldValues.put('Name', 'Cancel a subscription amendment');
        fieldValues.put('Description', 'Cancel a subscription amendment');
        fieldValues.put('ContractEffectiveDate', Z_SubscriptionCallhelper.getdate(system.today()));
        fieldValues.put('EffectiveDate', Z_SubscriptionCallhelper.getdate(rec.Cancellation_Effective_Date__c!=null?rec.Cancellation_Effective_Date__c:System.today()));
        String error = Z_amendsubscription.amendSubscription(rec.Asset__r.Subscription_Id__c, fieldValues);
        if (error != null) {
            updateStatusOnBulkProcessRecord(rec, error, 'Failed');
            rec.Zuora_Subscription_Cancellation_Status__c = 'Failed';
        }
    }
    
    // 2nd Step
    private void deleteRenewalOrderProducts() {
        if (!orderProdToDelete.isEmpty()) {
            List<OrderItem> orderProds = [SELECT Id FROM OrderItem WHERE ID IN :orderProdToDelete.keySet()];
            try {
                delete orderProds;
            }
            catch (Exception e) {
                for (OrderItem op : orderProds) {
                    Id assetId = orderProdToDelete.get(op.Id);
                    Bulk_Process__c rec = bulkRecsToUpdate.get(assetId);
                    updateStatusOnBulkProcessRecord(rec, 'Failed to delete Renewal Order Product -' + e.getMessage(), 'Failed');
                    rec.Renewal_Clearance_Status__c = 'Failed';
                    bulkRecsToUpdate.put(assetId, rec);
                }
            }
        }
    }
    
    // 3rd Step
    private void updateAssets() {
        if (!assetsToUpdate.isEmpty()) {
            try {
                update assetsToUpdate.values();
            }
            catch (Exception e) {
                Set<Id> updatedIds = new Set<Id>();
                for (Asset asset : assetsToUpdate.values()) {
                    system.debug(asset.Asset_Type__c );
                    // CRM-6075 - Fetch Parent Asset for Fulfill-To and Participant Asset to update Bulk Process Record.
                    Id parentAssetId = null;
                    if (asset.Asset_Type__c == 'Parent') {
                        parentAssetId = asset.Id;
                    }
                    else if (asset.Asset_Type__c == 'Fulfill To') {
                        parentAssetId = asset.Parent_Asset__c;
                    }
                    else if (asset.Asset_Type__c == 'Participant') {
                        parentAssetId = asset.Parent_Asset__r.Parent_Asset__c;
                    }
                    // CRM-6075 - End
                    if (parentAssetId!=null && !updatedIds.contains(parentAssetId)) {
                        Bulk_Process__c rec = bulkRecsToUpdate.get(parentAssetId);
                        updateStatusOnBulkProcessRecord(rec, 'Failed to cancel Asset - ' + e.getMessage(), 'Failed');
                        rec.SFDC_Asset_Cancellation_Status__c = 'Failed';
                        bulkRecsToUpdate.put(parentAssetId, rec);
                        updatedIds.add(parentAssetId);
                    }
                }
            }
        }
    }
    
    public static void updateStatusOnBulkProcessRecord(Bulk_Process__c rec, String errorMsg, String status) {
        if (rec != null) {
            rec.Status__c = status;
            rec.Description__c += '\n' + System.now() + ':: ' + errorMsg + '\n';
         }
    }
}