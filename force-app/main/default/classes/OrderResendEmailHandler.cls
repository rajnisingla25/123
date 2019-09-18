global with sharing class OrderResendEmailHandler{

    webservice static void UpdateSentEmailFlag(Id orderId){
        Order orderObj = [SELECT Id, Sent_Email__c FROM Order where id =: orderId];
        orderObj.Sent_Email__c = 'NotSent';
        update orderObj;
    }
    
     webservice static void UpdateSentEmailFlagQuote(Id QuoteId){
        BigMachines__Quote__c quoteObj = [SELECT Id, Sent_Email__c FROM BigMachines__Quote__c where id =: QuoteId];
        quoteObj.Sent_Email__c = 'NotSent';
        update quoteObj;
    }

}