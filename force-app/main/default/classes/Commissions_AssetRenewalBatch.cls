global class Commissions_AssetRenewalBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([select id,Name,RecordType.Name,Order_Type__c,Line_Type__c,Commission_field__c
                                         from Asset where Commission_field__c = 'Ignore']);
    }   
    global void execute(Database.BatchableContext BC, List<Asset> scope) {
        system.debug('scope >>>: '+scope);
        Set<Id> AssetIds = new Set<Id>();
        Map<Id,Asset> CalculateAssets = new Map<Id,Asset>();
        for(Asset Aid : Scope){
            AssetIds.add(Aid.Id);
        }
        system.debug('AssetIds >>>: '+AssetIds);
        Map<Id,Zuora__Subscription__c> Subscriptions = new Map<Id,Zuora__Subscription__c>([select id,Name,Asset__c from Zuora__Subscription__c where Asset__c In : AssetIds]);
        system.debug('Subscriptions >>>: '+Subscriptions);
        Set<Id> SubIds = new Set<Id>();
        for(Zuora__Subscription__c sub : Subscriptions.values()){
            SubIds.add(sub.id);
        }
        system.debug('SubIds >>>: '+SubIds);
        Map<id,Invoice_Item__c> InvoiceItems = new Map<id,Invoice_Item__c>([select id,Name,Invoice__c,Subscription__c from Invoice_Item__c where Subscription__c In : SubIds]);
        system.debug('InvoiceItems >>>: '+InvoiceItems);
        Set<Id> InvoiceIds = new Set<Id>();        
        for(Invoice_Item__c Inv : InvoiceItems.Values()){
             //InvoiceIds.add(Inv.Id);
             InvoiceIds.add(Inv.Invoice__c);
        }
        Map<id,Zuora__ZInvoice__c> Invoices = new Map<id,Zuora__ZInvoice__c>([select id,Name,Invoice_Status__c from Zuora__ZInvoice__c where Id In : InvoiceIds]);
        system.debug('Invoices >>>: '+Invoices);
        //Map<Id,Asset> Assets = new Map<Id,Asset>([select id,Name,RecordType.Name,Order_Type__c,Line_Type__c,Commission_field__c from Asset where Id in: AssetIds]);
        for(Zuora__ZInvoice__c Inv : Invoices.Values()){
            if(Inv.Invoice_Status__c =='Paid'){
                for(Invoice_Item__c InvoiceItem : InvoiceItems.Values()){//get(Inv.Id);
                    if(InvoiceItem.Invoice__c == Inv.Id){
                        Zuora__Subscription__c Subscription = Subscriptions.get(InvoiceItem.Subscription__c);
                        for(Asset ast : scope){
                            if(Subscription.Asset__c == ast.id){
                                ast.Commission_field__c = 'Calculate';
                                CalculateAssets.put(ast.id,ast);
                            }               
                        }
                    }
                }
            }       
        }
        /*
        for(Asset ast : Assets.Values())//scope){
            ast.Commission_field__c = 'Calculate';
            CalculateAssets.put(ast.id,ast);
        }
        */
        system.debug('CalculateAssets >>>: '+CalculateAssets);
        if(CalculateAssets.size() > 0){
            system.debug('Test >> : true');
            update CalculateAssets.Values();
        }
    }
    global void finish(Database.BatchableContext BC) {
    
    }
}