//****************************************************************************************
//Name          : InvoiceBatchProcessing
//Date          : 2.22.2016
//Created by    : Stanley Sequeira
//Modified by   : 
//Description   : This Batch Class will typically be executed every 5-10 mins and will process the Invoices
//               
// *****************************************************************************************

global class InvoiceBatchProcessing implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        Id collectionsRecordTypeId                  	= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Collections').getRecordTypeId();
        String query                                	= 'Select Id, status, accountId, account.Past_Due__c, account.Credit_Status__c, (SELECT Id, Invoice_Status__c, Case__c FROM Invoices__r WHERE Zuora__Balance2__c = 0 AND Zuora__DueDate__c  < TODAY AND Invoice_Status__c != \'Paid\' AND Zuora__Status__c = \'Posted\') from Case where recordTypeId =: collectionsRecordTypeId AND Status != \'Closed\' AND Past_Due_Amount__c = 0';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Case> scope){
        List<Zuora__ZInvoice__c> invoicesToUpdate   	= new List<Zuora__ZInvoice__c>();
        List<Case> CasesToUpdate                    	= new List<Case>();
        Map<Id,Account> accountsMap 					= new Map<Id,Account>();	
        
        for(Case c: scope){
            if(!c.Invoices__r.isEmpty()){
                for(Zuora__ZInvoice__c inv: c.Invoices__r){
                    inv.Invoice_Status__c = 'Paid';
                    invoicesToUpdate.add(inv);
                }        
            }
            c.status = 'Closed';   
            casesToUpdate.add(c);  
            accountsMap.put(c.accountID,New Account(id=c.accountID, Past_Due__c = false,Credit_Status__c = 'Current'));
            
        }   
        
        system.debug('@@ invoicesToUpdate @@'+invoicesToUpdate);
        system.debug('@@ casesToUpdate @@'+casesToUpdate);
        system.debug('@@ accountsMap @@'+accountsMap);
        
        update invoicesToUpdate;
        update casesToUpdate;
        update accountsMap.values();
    }
    
    
    global void finish(Database.BatchableContext bc){}
    
}