public class AccountStatementPrinter implements Database.Batchable<SObject>, Database.AllowsCallouts {

    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([SELECT Id,Zuora__Account__c,Zuora__Balance__c FROM Zuora__CustomerAccount__c where Zuora__Account__r.Type='Realtor Agent']);
    }

    public void execute(Database.BatchableContext context, List<Zuora__CustomerAccount__c> scopes) {

        Set<Id> setAccountIds = new Set<Id>();
        for(Zuora__CustomerAccount__c acc:scopes){
        System.debug('OPP ID '+acc.Zuora__Account__c);
        //use the relative url of your page
        PageReference pr = new PageReference('/apex/AccountStatementNew');
        pr.getParameters().put('id', acc.Zuora__Account__c);
        Blob data = Blob.valueof('Test');
        If(!Test.isrunningTest()){
        data = pr.getContent();
        }
        String str = 'sdfhskfsdfsdfj';
        DateTime dt = System.now();
        String stringaccId = '';
         if(dt.month()>9){stringaccId = dt.month()+''+acc.Zuora__Account__c+''+dt.year()+'.pdf';}
           if(dt.month()<10){stringaccId = '0'+dt.month()+''+acc.Zuora__Account__c+''+dt.year()+'.pdf';}
        
        //save the PDF as an attachment on the record
        Blob keye = Blob.valueOf('123456789012345678901234');
        Blob cipherText = Crypto.encryptWithManagedIV('AES192', keye, Blob.valueOf(acc.id));
        String encodedCipherText = EncodingUtil.base64Encode(cipherText);

        uploadPDFToAWScls fileup= new uploadPDFToAWScls();
        fileup.uploadPDFToAWS(data,'kSu0o0aAozh0Y4XDdbUyvc99J4s8cnTDYGCqSf1M','AKIAJTBINTQBSFS5SX4A',stringaccId);
        //fileup.uploadPDFToAWS(data,'','',encodedCipherText);

    }
    }

    public void finish(Database.BatchableContext context) {
        //
    }
}