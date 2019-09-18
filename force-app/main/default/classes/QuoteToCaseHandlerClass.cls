//**************************************************//
// (c) 2015 NTTDATA, Inc.
// Class Name : QuoteToCaseHandlerClass
// Usage: Used to  Update case status based on quote approval process status.
//
// Created 27th june 2015   Author Name:-  Vikram Thallapelli     Original
// Modified 29th june 2015   Author Name:-  Vikram Thallapelli     Modified
//**************************************************//
Public class QuoteToCaseHandlerClass{
    public static void QuoteToCase(List<BigMachines__Quote__c> QuoteRecords){    
        Set<Id> quoteIds = new Set<Id>();
        Set<String> quoteAccount = new Set<String>();
        for(BigMachines__Quote__c quote : QuoteRecords){
            QuoteIds.add(quote.id);
            quoteAccount.add(quote.BigMachines__Account__c);    
        }
        List<Case> Cases = [select Id,Status,AccountId,Oracle_Quote__c from Case where AccountId In : quoteAccount 
                            and Oracle_Quote__c In : QuoteIds and status!='Closed'];
        Map<id,Case> caseMap =  new Map<id,Case>();
        for(BigMachines__Quote__c quote : QuoteRecords){
            for(case cas : Cases){
                if(cas.Oracle_Quote__c == quote.id){
                    cas.status = quote.BigMachines__Status__c;
                    caseMap.put(cas.id,cas);
                }            
            }
        } 
        if(caseMap.size() > 0){
            update caseMap.Values();
        }   
    }

}