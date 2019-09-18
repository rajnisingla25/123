public class BulkApproveQuotesController {
    public List<QuoteWrapper> quotes {get;set;}
    public String retURL {get;set;}
    public Integer columnCount {get;set;}
    public Integer quoteProdCount {get;set;}    
    public Boolean selectAll {get;set;} 
    
    private String BMInstance;  
    private String BMSalesforceInstance;
    private String query; 
    private String dummyQuoteTransactionId = '';
    private String currentUserName = UserInfo.getUserName();
    //String currentUserName = 'tyler.carr@move.com.dev';
    
    public class QuoteWrapper {
        public Boolean selected {get; set;}
        public Bigmachines__Quote__c quote {get; set;}
        public String cpqEditUrl {get; set;}
        public QuoteWrapper (Bigmachines__Quote__c q, String quoteEditUrl) {
            selected = false;
            quote = q;
            cpqEditUrl = quoteEditUrl;
            quote.Bulk_Approval_Comments__c = '';
        }
    }
    
    public BulkApproveQuotesController () {
        columnCount = SObjectType.Bigmachines__Quote_Product__c.FieldSets.Bulk_Approve_Quote.getFields().size()+1;
        BigMachineUrls__c BMUrls = BigMachineUrls__c.getValues('BM');
        if (BMUrls != null) {
            BMInstance = BMUrls.BigmachineInstance__c;  
            BMSalesforceInstance = BMUrls.Salesforce_Instance__c;
            Bulk_Approve_Quote_Setting__c currentUserSetting = Bulk_Approve_Quote_Setting__c.getInstance(currentUserName);
            if (currentUserSetting != null) {
                dummyQuoteTransactionId = currentUserSetting.Quote_Transaction_Id__c;
                query = 'SELECT Bulk_Approval_Comments__c,BigMachines__Account__r.Name,Final_Credit_Amount__c,BigMachines__Total__c,Total_Net_Price__c,Total_Amendment_Delta__c,Total_Discount_Amt__c,BigMachines__Transaction_Id__c,Id,Name,(QUOTEPRODQUERY) FROM Bigmachines__Quote__c WHERE Pending_Approval_With__r.UserName=:currentUserName order by CreatedDate desc';
                String innerQuery = 'SELECT ';
                for(Schema.FieldSetMember f : SObjectType.Bigmachines__Quote_Product__c.FieldSets.Bulk_Approve_Quote.getFields()) {
                    if (f.getFieldPath() != 'Id') {
                        innerQuery += f.getFieldPath() + ', ';
                    }
                }
                innerQuery += 'Id FROM BigMachines__BigMachines_Quote_Products__r';
                query = query.replace('QUOTEPRODQUERY', innerQuery);
                getPendingApprovalQuotes();
            }
            else {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Bulk Approve Quote Settings are not found for current user.'));
            }
        }
    }
    
    public void getPendingApprovalQuotes() {
        quoteProdCount = 0;
        selectAll = false;
        quotes = new List<QuoteWrapper>();
        for (Bigmachines__Quote__c quote : (List<Bigmachines__Quote__c >)DataBase.query(query)) {
            quotes.add(new QuoteWrapper(quote, getCpqEditUrl(quote.Id)));
            quoteProdCount = quoteProdCount + quote.BigMachines__BigMachines_Quote_Products__r.size();
        }
    }
    
    public void updateDummyQuote() {
        retURL = null;
        String transactionIds = '';
        String QuoteNumbers = '';
        String approverComments = '';
        Integer totalQP = 0, totalselectedQuotes=0;
        for (QuoteWrapper quote : quotes) {
            if (quote.selected) {
                transactionIds = transactionIds + ',' + quote.quote.BigMachines__Transaction_Id__c;
                QuoteNumbers = QuoteNumbers + quote.quote.Name;
                QuoteNumbers = QuoteNumbers + '||' + quote.quote.BigMachines__Account__r.Name;
                QuoteNumbers = QuoteNumbers + '||' + quote.quote.Total_Net_Price__c;
                QuoteNumbers = QuoteNumbers + '||' + quote.quote.Total_Discount_Amt__c;
                QuoteNumbers = QuoteNumbers + '||' + quote.quote.Final_Credit_Amount__c;
                QuoteNumbers = QuoteNumbers + '||' + quote.quote.Total_Amendment_Delta__c + '--';
                approverComments = approverComments + '!$!' + quote.quote.Bulk_Approval_Comments__c;
                
                totalQP += quote.quote.BigMachines__BigMachines_Quote_Products__r.size();
                totalselectedQuotes++;
            }
        }
        if (totalselectedQuotes > 0) {
            if(totalQP<=Integer.valueOf(Label.BulkApproval_No_QP_Allowed) || totalselectedQuotes == 1) {
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
            }
            else {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Only ' + Label.BulkApproval_No_QP_Allowed + ' Quote Products are allowed to approve at a time.'));
            }
        }
        else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please select Quote(s).'));

         }
    }
    
    private String getCpqEditUrl(String sfdcId) {
        return BMSalesforceInstance +'/apex/QuoteEdit?retURL=%2F'+ sfdcId + '&scontrolCaching=1&sfdc.override=1&id='+sfdcId+'&siteid='+CreateQuoteController.oracleId;
    }
    
    /*
    public void saveTransactionIdsToCPQ() {
        retURL = null;
        String transactionIds = '';
        String QuoteNumbers = '';
        Integer totalQP = 0, totalselectedQuotes=0;
        for (QuoteWrapper quote : quotes) {
            if (quote.selected) {
                transactionIds = transactionIds + ',' + quote.quote.BigMachines__Transaction_Id__c;
                QuoteNumbers = QuoteNumbers + quote.quote.Name;
                QuoteNumbers = QuoteNumbers + '||' + quote.quote.BigMachines__Account__r.Name;
                QuoteNumbers = QuoteNumbers + '||' + quote.quote.Total_Net_Price__c;
                QuoteNumbers = QuoteNumbers + '||' + quote.quote.Total_Discount_Amt__c;
                QuoteNumbers = QuoteNumbers + '||' + quote.quote.Final_Credit_Amount__c;
                QuoteNumbers = QuoteNumbers + '||' + quote.quote.Total_Amendment_Delta__c + '--';
                
                totalQP += quote.quote.BigMachines__BigMachines_Quote_Products__r.size();
                totalselectedQuotes++;
            }
        }
        if (transactionIds != '') {
            if(totalQP<=Integer.valueOf(Label.BulkApproval_No_QP_Allowed) || totalselectedQuotes == 1) {
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
                }
                catch (Exception e) {
                    
                }
                String sfdcId = [SELECT Id FROM Bigmachines__Quote__c  WHERE BigMachines__Transaction_Id__c=:dummyQuoteTransactionId].Id;
                retUrl = getCpqEditUrl(sfdcId);
                //p = new PageReference(BMSalesforceInstance +'/apex/QuoteEdit?retURL=%2F'+ sfdcId + '&scontrolCaching=1&sfdc.override=1&id='+sfdcId);
            }
            else {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Only ' + Label.BulkApproval_No_QP_Allowed + ' Quote Products are allowed to approve at a time.'));
            }
        }
        else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please select Quote(s).'));

         }
    }
    */
    
}