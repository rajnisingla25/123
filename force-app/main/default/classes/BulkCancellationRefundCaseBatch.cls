public class BulkCancellationRefundCaseBatch implements Database.Batchable<sObject> {
    private Set<Id> bulkProcessIds;
    
    public BulkCancellationRefundCaseBatch(Set<Id> bulkProcessIds) {
        this.bulkProcessIds = bulkProcessIds;
    }
    
    public Database.querylocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, Asset__r.Name, Asset__r.Asset_Number__c, Status__c, Asset__c, Asset__r.AccountId, Description__c,Cancellation_Reason__c FROM
                     Bulk_Process__c WHERE Id IN:bulkProcessIds AND Status__c!='Processed' AND Refund_Case_Creation_Status__c='New' Order By Asset__r.AccountId]);
    }
    
    public void execute(Database.BatchableContext BC, List<Bulk_Process__c> scope) {
        Map<Id, Bulk_Process__c> recordsToUpdate = new Map<Id, Bulk_Process__c>();
        Map<Id, String> accountvsCaseDesc = new Map<Id, String>();
        Set<Id> assetIds = new Set<Id>();
        for (Bulk_Process__c rec : scope) {
            String description = accountvsCaseDesc.get(rec.Asset__r.AccountId);
            if (description == null) {
                description = '';
            }
            description += rec.Asset__r.Asset_Number__c + ':' + rec.Cancellation_Reason__c + '\n';
            accountvsCaseDesc.put(rec.Asset__r.AccountId, description);
            
            assetIds.add(rec.Asset__c);
            rec.Refund_Case_Creation_Status__c = 'Processed';
            if (rec.Status__c != 'Failed') {
                rec.Status__c = 'Processed';
            }
            recordsToUpdate.put(rec.Id, rec);
        }
        
        for (AggregateResult result : [SELECT AccountId, count(Id) FROM Asset WHERE AccountId IN :accountvsCaseDesc.keySet() AND Id NOT IN:assetIds AND Status='Active' AND 
                            Total_Net__c>0 GROUP BY AccountId HAVING count(Id)>0]) {
            accountvsCaseDesc.remove(String.valueOf(result.get('AccountId')));
        }
        
        if (!accountvsCaseDesc.isEmpty()) {
            ProductCase__c ppcase= ProductCase__c.getValues('FinanceCase');
            String subject='Finance Refund Case', Type='finance', subArea='Refund', area='Refund';
            if (ppcase != null){
                subject = ppcase.Case_Subject__c;
                type = ppcase.Case_Type__c;
                subarea = ppcase.Case_Sub_Area__c;
                area = ppcase.Case_Area__c;
            }
            List<Case> caseToInsert = new List<Case>();
            Id financeRecordTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get('Finance').RecordTypeId;
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
        	dmlOpts.assignmentRuleHeader.useDefaultRule= true;
            for (Id accId : accountvsCaseDesc.keySet()) {
                Case refundCase = new Case();
                refundCase.Subject = subject;
                refundCase.Type = type;
                refundCase.Sub_Area__c = subarea;
                refundCase.Area__c = area;
                refundCase.Origin = 'Web';
                refundCase.RecordTypeId = financeRecordTypeId;
                refundCase.AccountId = accId;
                refundCase.Description = accountvsCaseDesc.get(accId);
                refundCase.setOptions(dmlOpts);
                caseToInsert.add(refundCase);
            }
           
            if (!caseToInsert.isEmpty()) {
                try {
                    insert caseToInsert;
                    for (Case c : caseToInsert) {
                        for (Bulk_Process__c rec : scope) {
                            if (rec.Asset__r.AccountId == c.AccountId) {
                                rec.Case__c = c.Id;
                                recordsToUpdate.put(rec.Id, rec);
                            }
                        }
                    }
                }
                catch (Exception e) {
                    for (Case c : caseToInsert) {
                        for (Bulk_Process__c rec : scope) {
                            if (rec.Asset__r.AccountId == c.AccountId) {
                                BulkCancellationBatch.updateStatusOnBulkProcessRecord(rec, 'Failed to create refund case  - ' + e.getMessage(), 'Failed');
                                rec.Refund_Case_Creation_Status__c = 'Failed';
                                recordsToUpdate.put(rec.Id, rec);
                            }
                        }
                    }
                }
            }
        }
        update recordsToUpdate.values();
    }    
    public void finish(Database.BatchableContext BC) {
    
    }
}