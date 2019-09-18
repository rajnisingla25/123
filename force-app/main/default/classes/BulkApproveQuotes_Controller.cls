public class BulkApproveQuotes_Controller {
    
    private Static String BMInstance;  
    private Static String BMSalesforceInstance;
    private Static String query; 
    private Static String dummyQuoteTransactionId; 
    private Static String currentUserName = UserInfo.getUserName();
    //private Static String currentUserName = 'tyler.carr@move.com.dev';
        
    static {
        BigMachineUrls__c BMUrls = BigMachineUrls__c.getValues('BM');
        if (BMUrls != null) {
            BMInstance = BMUrls.BigmachineInstance__c;  
            BMSalesforceInstance = BMUrls.Salesforce_Instance__c;
        }
        Bulk_Approve_Quote_Setting__c currentUserSetting = Bulk_Approve_Quote_Setting__c.getInstance(currentUserName);
        if (currentUserSetting != null) {
            dummyQuoteTransactionId = currentUserSetting.Quote_Transaction_Id__c;
        }
    }
    
    public class column {
        @auraEnabled 
        public String label {get; set;}
        @auraEnabled 
        public String fieldName {get; set;}
        @auraEnabled 
        public String type {get; set;}
        @auraEnabled 
        public Integer initialWidth {get; set;}
        
        public column(String l, String f, Schema.DisplayType t) {
            label = l;
            fieldName = f.replaceAll('\\.', '');
            if (fieldName.contains('Asset__r')) {
                label = 'Asset:' + l;
            }
            else if (fieldName.contains('BigMachines__Quote__r')) {
                label = 'Quote:' + l;
            }
            if (t == Schema.DisplayType.Boolean|| t == Schema.DisplayType.Integer || t == Schema.DisplayType.Double || t == Schema.DisplayType.Long ||t == Schema.DisplayType.Currency || t == Schema.DisplayType.Percent) {
                type = 'number';
            }
            else {
                type = 'text';
            }
            initialWidth = 150;
            if (label.length()*10>150) {
                initialWidth = 200;
            }
        }
    }
    
    public class QuoteWrapper {
        @auraEnabled
        public String Id {get; set;}
        @auraEnabled
        public String comments {get; set;}
        @auraEnabled
        public String Name {get; set;}
        @auraEnabled
        public String cpqEditUrl {get; set;}
        @auraEnabled
        public String quoteViewUrl {get; set;}
        @auraEnabled
        public Integer numOfProducts {get; set;}
        public QuoteWrapper (Bigmachines__Quote__c quote) {
            this.Id = quote.Id;
            this.Name = quote.Name;
            cpqEditUrl = getCpqEditUrl(quote.Id);
            quoteViewUrl = '/' + Id;
            this.numOfProducts = quote.BigMachines__BigMachines_Quote_Products__r.size();
            this.comments = quote.Bulk_Approval_Comments__c;
        }
    }
    
    @AuraEnabled
    public static List<QuoteWrapper> fetchQuotes() {
        List<QuoteWrapper> quotes = new List<QuoteWrapper>();
        Bulk_Approve_Quote_Setting__c currentUserSetting = Bulk_Approve_Quote_Setting__c.getInstance(currentUserName);
        if (currentUserSetting != null) {
            String dummyQuoteTransactionId = currentUserSetting.Quote_Transaction_Id__c;
            for (Bigmachines__Quote__c  quote : [SELECT Bulk_Approval_Comments__c, Id, Name, (SELECT Id FROM BigMachines__BigMachines_Quote_Products__r) FROM Bigmachines__Quote__c WHERE Pending_Approval_With__r.UserName=:currentUserName order by CreatedDate desc]) {
                quotes.add(new QuoteWrapper(quote));
            }
        }
        return quotes;
    }
    
    /*
    @AuraEnabled
    public static List<Bigmachines__Quote_Product__c> fetchQuoteProducts1(String quoteId) {
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : SObjectType.Bigmachines__Quote_Product__c.FieldSets.Bulk_Approve_Quote.getFields()) {
            if (f.getFieldPath() != 'Id') {
                query += f.getFieldPath() + ', ';
            }
        }
        query += 'Id FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__r.Name =:quoteId';
        return (List<Bigmachines__Quote_Product__c >)DataBase.query(query);
    }
    */
    
    @AuraEnabled
    public static List<Map<String, Object>> fetchQuoteProducts(String quoteId) {
        List<Map<String, Object>> records = new List<Map<String, Object>>();
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : SObjectType.Bigmachines__Quote_Product__c.FieldSets.Bulk_Approve_Quote.getFields()) {
            if (f.getFieldPath() != 'Id') {
                query += f.getFieldPath() + ', ';
            }
        }
        query += 'Id FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__r.Name =:quoteId';
        for (Bigmachines__Quote_Product__c  qp : (List<Bigmachines__Quote_Product__c >)DataBase.query(query)) {
            Map<String, Object> record = new Map<String, Object>();
            for (Schema.FieldSetMember f : SObjectType.Bigmachines__Quote_Product__c.FieldSets.Bulk_Approve_Quote.getFields()) {
                String fieldPath = f.getFieldPath();
                sObject obj = qp;
                List<String> strs = fieldPath.split('\\.');
                for (integer i=0; i<strs.size()-1; i++) {
                    system.debug(strs[i]);
                    if (obj != null) {
                        obj = obj.getSObject(strs[i]);
                    }
                }
                if (obj != null) {
                    record.put(fieldPath.replaceAll('\\.', ''), obj.get(strs[strs.size()-1]));
                }
           
            }
            records.add(record);
        }
        system.debug(records);
        return records;
    }
    
    @AuraEnabled
    public static List<Column> fetchQuoteProductsColumns() {
        List<Column> columns = new List<Column>();
        for(Schema.FieldSetMember f : SObjectType.Bigmachines__Quote_Product__c.FieldSets.Bulk_Approve_Quote.getFields()) {
            columns.add(new Column(f.getLabel(), f.getFieldPath(), f.getType()));
        }
        return columns;
    }
    
    @AuraEnabled 
    public static Boolean updateQuotes(List<Bigmachines__Quote__c> quotes) {
        Boolean ret = true;
        try {
           update quotes;
        }
        catch (Exception e) {
            ret = false;
        }
        return ret;
    }
    
    @AuraEnabled 
    public Static String updateDummyQuote(List<String> quoteIds) {
        String retURL = null;
        String transactionIds = '';
        String QuoteNumbers = '';
        String approverComments = '';
        for (Bigmachines__Quote__c quote : [SELECT Bulk_Approval_Comments__c,BigMachines__Account__r.Name,Final_Credit_Amount__c,Total_Discount_Amt__c,Total_Net_Price__c,Total_Amendment_Delta__c,BigMachines__Total__c,BigMachines__Transaction_Id__c,Id,Name FROM Bigmachines__Quote__c WHERE ID IN :quoteIds]) {
            transactionIds = transactionIds + ',' + quote.BigMachines__Transaction_Id__c;
            QuoteNumbers = QuoteNumbers + quote.Name;
            QuoteNumbers = QuoteNumbers + '||' + quote.BigMachines__Account__r.Name;
            QuoteNumbers = QuoteNumbers + '||' + quote.Total_Net_Price__c;
            QuoteNumbers = QuoteNumbers + '||' + quote.Total_Discount_Amt__c;
            QuoteNumbers = QuoteNumbers + '||' + quote.Final_Credit_Amount__c;
            QuoteNumbers = QuoteNumbers + '||' + quote.Total_Amendment_Delta__c + '--';
            approverComments = approverComments + '!$!' + quote.Bulk_Approval_Comments__c;
        }
       
        transactionIds = transactionIds.removeStart(',');
        QuoteNumbers = QuoteNumbers.removeStart('||');
        QuoteNumbers = QuoteNumbers.removeEnd('--');
        approverComments = approverComments.removeStart('!$!');
        try {
            Bigmachines__Quote__c dummyQuote = [SELECT Id FROM Bigmachines__Quote__c WHERE BigMachines__Transaction_Id__c=:dummyQuoteTransactionId];
            dummyQuote.Bulk_Approval_Transaction_Ids__c = transactionIds;
            dummyQuote.Bulk_Approval_Details__c = QuoteNumbers;
            dummyQuote.Bulk_Approval_Comments__c = approverComments;
            update dummyQuote;
            retURL = getCpqEditUrl(dummyQuote.Id);
        }
        catch (Exception e) {
            
        }
        return retUrl;
    }
    
    private Static String getCpqEditUrl(String sfdcId) {
        return BMSalesforceInstance +'/apex/QuoteEdit?retURL='+ sfdcId + '&scontrolCaching=1&sfdc.override=1&id='+sfdcId+'&siteid='+CreateQuoteController.oracleId;
    }
    
    /*
    @AuraEnabled 
    public Static String saveTransactionIdsToCPQ(List<String> quoteIds) {
        String retURL = null;
        String transactionIds = '';
        String QuoteNumbers = '';
        for (Bigmachines__Quote__c quote : [SELECT BigMachines__Account__r.Name,Final_Credit_Amount__c,Total_Discount_Amt__c,Total_Net_Price__c,Total_Amendment_Delta__c,BigMachines__Total__c,BigMachines__Transaction_Id__c,Id,Name FROM Bigmachines__Quote__c WHERE ID IN :quoteIds]) {
            transactionIds = transactionIds + ',' + quote.BigMachines__Transaction_Id__c;
            QuoteNumbers = QuoteNumbers + quote.Name;
            QuoteNumbers = QuoteNumbers + '||' + quote.BigMachines__Account__r.Name;
            QuoteNumbers = QuoteNumbers + '||' + quote.Total_Net_Price__c;
            QuoteNumbers = QuoteNumbers + '||' + quote.Total_Discount_Amt__c;
            QuoteNumbers = QuoteNumbers + '||' + quote.Final_Credit_Amount__c;
            QuoteNumbers = QuoteNumbers + '||' + quote.Total_Amendment_Delta__c + '--';
        }
       
        transactionIds = transactionIds.removeStart(',');
        QuoteNumbers = QuoteNumbers.removeStart('||');
        QuoteNumbers = QuoteNumbers.removeEnd('--');
        try {
            WebserviceCallBigMachineQuoteCls wbs = new WebserviceCallBigMachineQuoteCls();
            String seess = wbs.GetSessionId(null,null);
            String body = '<?xml version="1.0" encoding="UTF-8"?>';
            body = body + '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">';
            body = body + '<soapenv:Header>';
            body = body + '<bm:userInfo xmlns:bm="urn:soap.bigmachines.com">';
            body = body + '<bm:sessionId>' + seess + '</bm:sessionId>';
            body = body + '</bm:userInfo>';
            body = body + '<bm:category xmlns:bm="urn:soap.bigmachines.com">Commerce</bm:category>';
            body = body + '<bm:xsdInfo xmlns:bm="urn:soap.bigmachines.com">';
            body = body + '<bm:schemaLocation>https://'+ BMInstance +'.bigmachines.com/bmfsweb/'+ BMInstance + '/schema/v1_0/commerce/oraclecpqo.xsd</bm:schemaLocation>';
            body = body + '</bm:xsdInfo>';
            body = body + '</soapenv:Header>';
            body = body + '<soapenv:Body>';
            body = body + '<bm:updateTransaction xmlns:bm="urn:soap.bigmachines.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
            body = body + '<bm:transaction>';
            body = body + '<bm:id>' + dummyQuoteTransactionId + '</bm:id>';
            body = body + '<bm:process_var_name>oraclecpqo</bm:process_var_name>';
            body = body + '<bm:data_xml>';
            body = body + '<bm:transaction bm:data_type="0" bm:document_name="Transaction" bm:document_number="1" bm:document_var_name="transaction" bm:process_var_name="oraclecpqo" bm:supplier_company_name="'+BMInstance + '">';
            body = body + '<bm:bulkApprovalTransactions_quote>'+ transactionIds  +'</bm:bulkApprovalTransactions_quote>';
            body = body + '<bm:bulkApprovalQuoteNumbers>'+ QuoteNumbers.escapeHtml4() +'</bm:bulkApprovalQuoteNumbers>';
            body = body + '<bm:bulkQuoteSuccess_quote>false</bm:bulkQuoteSuccess_quote>';
            body = body + '<bm:bulkQuoteFailure_quote></bm:bulkQuoteFailure_quote >';
            body = body + '<bm:action_var_name>_update_line_items</bm:action_var_name>';
            body = body + '</bm:transaction>';
            body = body + '</bm:data_xml>';
            body = body + '<bm:action_data>';
            body = body + '<bm:action_var_name>plainSave_t</bm:action_var_name>';
            body = body + '</bm:action_data>';
            body = body + '</bm:transaction>';
            body = body + '</bm:updateTransaction>';
            body = body + '</soapenv:Body>';
            body = body + '</soapenv:Envelope>';
            
            HttpRequest req = new HttpRequest();
            req.setTimeout(80000);
            req.setMethod('POST');
            req.setEndpoint('https://'+BMInstance+'.bigmachines.com/v1_0/receiver');
            req.setBody(body);
            System.debug('Req - ' + body);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug('Res - ' + res.getBody());
            system.debug(QuoteNumbers.escapeHtml4());
            String sfdcId = [SELECT Id FROM Bigmachines__Quote__c  WHERE BigMachines__Transaction_Id__c=:dummyQuoteTransactionId].Id;
            retURL = getCpqEditUrl(sfdcId);
            
        }
        catch (Exception e) {
            
        }
        return retUrl;
    }
    */
}