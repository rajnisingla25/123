// CRM-6098- Opcity BLA CPQ Itegration Class
public class OpcityBLACPQUtility {
        public String BMUserName {get;set;}
        public String BMUserPassword {get;set;}
        public String accountId {get; set;}
        public String opcityBlaJson {get; set;}
        
        private String bmsessionid;
        private String BMUrl{get;set;}
        private String BMSalesforceInstance;
        private String BMInstance;
        private String endPoint;
        
        public class SfdcQuote {
            public String name {get; set;}
            public String editUrl {get; set;}
            public String id {get; set;}
        }
        
        public OpcityBLACPQUtility() {
            BigMachineUrls__c BMUrls = BigMachineUrls__c.getValues('BM');
            if (BMUrls != null){
                  BMUserName = BMUrls.DefaultUserName__c;
                  BMUserPassword = BMUrls.DefaultPassword__c;
                  BMUrl = BMUrls.Bigmachine_Url__c;
                  BMSalesforceInstance =BMUrls.Salesforce_Instance__c;
                  BMInstance = BMUrls.BigmachineInstance__c;
                  endPoint = 'https://'+BMInstance+'.bigmachines.com/v1_0/receiver';
            }
        }
        
        private String getCpqEditUrl(String sfdcId) {
            return BMSalesforceInstance +'/apex/QuoteEdit?retURL='+ sfdcId + '&scontrolCaching=1&sfdc.override=1&id='+sfdcId+'&siteid='+CreateQuoteController.oracleId;
        }
        
        private void getSessionId(){
            HttpRequest req = new HttpRequest();
            req.setTimeout(120000);
            String tidd='';
            req.setMethod('POST');
            req.setEndpoint(endPoint);
            String body ='<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">';
            body = body+'<soapenv:Header>';
            body = body+'<bm:category xmlns:bm="urn:soap.bigmachines.com">Security</bm:category>';
            body = body+'<bm:xsdInfo xmlns:bm="urn:soap.bigmachines.com">';
            body = body+'<bm:schemaLocation>'+BMUrl +'/schema/v1_0/security/Security.xsd</bm:schemaLocation>';
            body = body+'</bm:xsdInfo>';
            body = body+'</soapenv:Header>';
            body = body+'<soapenv:Body>';
            body = body+'<bm:login xmlns:bm="urn:soap.bigmachines.com">';
            body = body+'<bm:userInfo>';
            body = body+'<bm:username>'+BMUserName +'</bm:username>';
            body = body+'<bm:password>'+BMUserPassword +'</bm:password>';
            body = body+'<bm:sessionCurrency/>';
            body = body+'</bm:userInfo>';
            body = body+'</bm:login>';
            body = body+'</soapenv:Body>';
            body = body+'</soapenv:Envelope>';
            req.setBody(body);
            system.debug('Request XML: '+ req);
            
            HTTPResponse res;
            try {
                Http http = new Http();
                
                if(!Test.isRunningTest()) {
                    res = http.send(req);
                }
                else {
                    bmsessionid = 'test';
                    res = new HTTPResponse();
                    res.setBody('<test></test>');
                }
                     
                Dom.Document doc = res.getBodyDocument();
                Dom.XMLNode envelope = doc.getRootElement();
                Dom.XMLNode resbody = envelope.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
                Dom.XMLNode loginresponse= resbody.getChildElement('loginResponse', 'urn:soap.bigmachines.com');
                Dom.XMLNode userinfo= loginresponse.getChildElement('userInfo', 'urn:soap.bigmachines.com');
                Dom.XMLNode sessid= userinfo.getChildElement('sessionId', 'urn:soap.bigmachines.com');
                bmsessionid= sessid.getText();
            }
            catch (Exception e) {
                Error__c error = new Error__c();
                error.Name = 'OpcityBLACPQUtility';
                error.Entity_Id__c = accountId;
                error.Interface_Name__c = 'getSessionId';
                error.Error_Description__c = e.getMessage() + res.getBody();
                insert error;
            }
            
         }
        
        private HttpRequest getHeaderCPQRequest() {
            if (bmsessionid==null || bmsessionid=='') {
                getSessionId();
            }
            HttpRequest req = new HttpRequest();
            req.setTimeout(120000);
            req.setMethod('POST');
            req.setEndpoint(endPoint);
            String body ='<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">';
            body = body+'<soapenv:Header>';
            body = body+'<bm:userInfo xmlns:bm="urn:soap.bigmachines.com">';
            body = body+'<bm:sessionId>'+bmsessionid+'</bm:sessionId>';
            body = body+'</bm:userInfo>';
            body = body+'<bm:category xmlns:bm="urn:soap.bigmachines.com">Commerce</bm:category>';
            body = body+'<bm:xsdInfo xmlns:bm="urn:soap.bigmachines.com">';
            body = body+'<bm:schemaLocation>'+BMUrl +'/schema/v1_0/commerce/oraclecpqo.xsd</bm:schemaLocation>';
            body = body+'</bm:xsdInfo>';
            body = body+'</soapenv:Header>';
            req.setBody(body);
            return req;
        }
        
        public SfdcQuote createBLAQuote() {
            String transactionId = createQuote();
            if (transactionId != null) {
                Boolean success = updateBigMachineQuote(transactionId, 'addBLALines');
                //if (success) {
                    //success = updateBigMachineQuote(transactionId, 'cleanSave_t');
                    //if (success) {
                        //success = updateBigMachineQuote(transactionId, 'calculateTax');
                        if (success) {
                            success = updateBigMachineQuote(transactionId, 'plainSubmit_t');
                        }
                    //}
                //}
                if (success) {
                    List<BigMachines__Quote__c> quote = [SELECT name, id FROM BigMachines__Quote__c WHERE BigMachines__Transaction_Id__c=:transactionId ];
                    if (quote.size()>0) {
                        SfdcQuote sfdcQuoteObj = new SfdcQuote();
                        sfdcQuoteObj.name = quote[0].name;
                        sfdcQuoteObj.Id = quote[0].id;
                        sfdcQuoteObj.editUrl = getCpqEditUrl(quote[0].Id);
                        return sfdcQuoteObj;
                    }
                }
            }
            return null;
        }
        
        public String createQuote() {
            HttpRequest req = getHeaderCPQRequest();
            String body = req.getBody();
            String quoteTransactionId = null;
            
            body = body+'<soapenv:Body>';
            body = body+'<bm:createTransaction xmlns:bm="urn:soap.bigmachines.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
            body = body+'<bm:items>';
            body = body+'<bm:segment>realtor</bm:segment>';
            body = body+'<bm:partItem>';
            body = body+'<bm:part/>';
            body = body+'<bm:quantity>1</bm:quantity>';
            body = body+'<bm:price_book_var_name/>';
            body = body+'</bm:partItem>';
            body = body+'</bm:items>';
            body = body+'<bm:transaction>';
            body = body+'<bm:process_var_name>oraclecpqo</bm:process_var_name>';
            body = body+'<bm:quoteType_quote>new</bm:quoteType_quote>';
            body = body+'<bm:_customer_id>'+accountId+'</bm:_customer_id>';
            body = body+'<bm:_bm_cm_new_transaction_currency/>';
            body = body+'<bm:return_specific_attributes>';
            body = body+'<bm:documents>';
            body = body+'<bm:document>';
            body = body+'<bm:var_name>transaction</bm:var_name>';
            body = body+'<bm:attributes>';
            body = body+'<bm:attribute>_document_number</bm:attribute>';
            body = body+'</bm:attributes>';
            body = body+'</bm:document>';
            body = body+'</bm:documents>';
            body = body+'</bm:return_specific_attributes>';
            body = body+'</bm:transaction>';
            body = body+'</bm:createTransaction>';
            body = body+'</soapenv:Body>';
            body = body+'</soapenv:Envelope>';
            body = body+'';
            req.setBody(body);
            System.debug('---------Request Body----------'+req.getBody());
            
            String errorMsg = '';
            HTTPResponse res;
            try {
                if(!Test.isRunningTest()) {
                    Http http = new Http();
                    res = http.send(req);
                 }
                 else {
                     quoteTransactionId = '12345';
                     res = new HTTPResponse();
                     res.setBody('<test></test>');
                 }
                String docc = res.getBody();
                Dom.Document doc = res.getBodyDocument();
                Dom.XMLNode envelope = doc.getRootElement();
                Dom.XMLNode resbody = envelope.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
                Dom.XMLNode createTransactionRes= resbody.getChildElement('createTransactionResponse', 'urn:soap.bigmachines.com');
                Dom.XMLNode trans= createTransactionRes.getChildElement('transaction', 'urn:soap.bigmachines.com');
                Dom.XMLNode tid= trans.getChildElement('id', 'urn:soap.bigmachines.com');
                quoteTransactionId  = tid.getText();
                system.debug('quoteTransactionId  -- ' + quoteTransactionId );
                
            }
            catch (Exception e) {
                errorMsg = e.getMessage();
            }
            if (quoteTransactionId == null) {
                Error__c error = new Error__c();
                error.Name = 'OpcityBLACPQUtility';
                error.Entity_Id__c = accountId;
                error.Interface_Name__c = 'createBLAQuote';
                error.Error_Description__c = errorMsg + '\nRes: \n'+res.getBody();
                insert error;
        
            }
            return quoteTransactionId;
        }
        
        
        private boolean updateBigMachineQuote(String tId, String action) {
            Boolean ret = false;
            if (bmsessionid==null || bmsessionid=='') {
                getSessionId();
            }
            HttpRequest req = getHeaderCPQRequest();
            String body = req.getBody();
            
            body = body+'<soapenv:Body>';
            body = body+'<bm:updateTransaction xmlns:bm="urn:soap.bigmachines.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
            body = body+'<bm:transaction>';
            body = body+'<bm:id>'+Integer.valueof(tId)+'</bm:id>';
            body = body+'<bm:process_var_name>oraclecpqo</bm:process_var_name>';
            body = body+'<bm:buyer_company_name>'+BMInstance+'</bm:buyer_company_name>';
            body = body+'<bm:supplier_company_name>'+BMInstance+'</bm:supplier_company_name>';
            body = body+'<bm:skipAuthorization_quote>true</bm:skipAuthorization_quote>';
            body = body+'<bm:taxVerified_quote>true</bm:taxVerified_quote>';
            body = body+'<bm:last_document_number>1</bm:last_document_number>';
            body = body+'<bm:data_xml>';
            body = body+'<bm:transaction bm:bs_id="'+Integer.valueof(tId)+'" bm:buyer_company_name="'+BMInstance+'" bm:buyer_user_name="'+BMUserName+'" bm:currency_pref="USD" bm:data_type="0" bm:document_name="Transaction" bm:document_number="1" bm:document_var_name="transaction" bm:process_var_name="oraclecpqo" bm:supplier_company_name="'+BMInstance+'">';
            body = body+'<bm:opcityBLADetails_t>'+opcityBlaJson+'</bm:opcityBLADetails_t>';
            body = body+'<bm:isBLAAutoQuote_t>true</bm:isBLAAutoQuote_t>';
            body = body+'<bm:isQuickQuote_t>true</bm:isQuickQuote_t>';
            body = body+'<bm:isOpcityQuickQuote>true</bm:isOpcityQuickQuote>';
            body = body+'<bm:_document_number>1</bm:_document_number>';
            body = body+'<bm:status_t>In Progress</bm:status_t>';
            body = body+'<bm:skipAuthorization_quote>true</bm:skipAuthorization_quote>';
            body = body+'<bm:version_t>1</bm:version_t>';
            body = body+'<bm:bs_id>'+Integer.valueof(tId)+'</bm:bs_id>';
            body = body+'<bm:_customer_id>'+accountId+'</bm:_customer_id>';
            
            body = body+'<bm:owner_t>'+UserInfo.getUserName()+'</bm:owner_t>';
            body = body+'<bm:quoteOwnerId_quote>'+UserInfo.getUserId()+'</bm:quoteOwnerId_quote>';
            body = body+'<bm:lastUpdatedBy_t>'+UserInfo.getFirstName()+' '+UserInfo.getLastName()+'</bm:lastUpdatedBy_t>';
            body = body+'<bm:version_number_versionTransaction_t>1</bm:version_number_versionTransaction_t>';
            body = body+'<bm:quoteType_quote>New</bm:quoteType_quote>'; 
            body = body+'<bm:stringOfAsset_quote>Product2.BigMachines__Part_Number__c,Quantity,Start_Date__c,End_Date__c,Status,Product2.Id,Price,Lead_Type__c,Product_Type__c,Market__c,Contract_Term__c,Billing_Period__c,Promotion__c,Discount_Type__c,Commerce_Group__c,Broker_Plan_Affiliation__c,Product_Email__c,Participants__c,License_Tier_Range__c,Top_Connector__c,Featured_Mortgage__c,HLC_Override__c</bm:stringOfAsset_quote>';
            body = body+'<bm:rule_data>';
            body = body+'<bm:totalAnnualValue_t bm:constrained="false" bm:hidden="true"/>';
            body = body+'<bm:totalContractValue_t bm:constrained="false" bm:hidden="true"/>';
            body = body+'<bm:totalMonthlyDiscount_t bm:constrained="false" bm:hidden="true"/>';
            body = body+'<bm:taxExemptReason_t bm:constrained="false" bm:hidden="true"/>';
            body = body+'<bm:totalMonthlyNetAmount_t bm:constrained="false" bm:hidden="true"/>';
            body = body+'<bm:totalMonthlyListAmount_t bm:constrained="false" bm:hidden="true"/>';
            body = body+'</bm:rule_data>';
            body = body+'</bm:transaction>';
            body = body+'</bm:data_xml>';
            body = body+'<bm:action_data>';
            body = body+'<bm:action_var_name>'+action+'</bm:action_var_name>';
            body = body+'<bm:_bm_cm_new_transaction_currency/>';
            body = body+'<bm:performer_comment/>';
            body = body+'<bm:reason_var_name/>';
            body = body+'<bm:performer_name/>';
            body = body+'<bm:performer_type/>';
            body = body+'<bm:performer_company_name/>';
            body = body+'</bm:action_data>';
            body = body+'<bm:sub_step_name/>';
            body = body+'<bm:buyer_user_name>'+BMUserName+'</bm:buyer_user_name>';
            body = body+'<bm:currency_pref>USD</bm:currency_pref>';
            body = body+'<bm:status>0</bm:status>';
            body = body+'<bm:update_count>2</bm:update_count>';
            body = body+'<bm:language_pref>English</bm:language_pref>';
            body = body+'<bm:offline_user_id>-1</bm:offline_user_id>';
            body = body+'<bm:num_transitions>0</bm:num_transitions>';
            body = body+'</bm:transaction>';
            body = body+'</bm:updateTransaction>';
            body = body+'</soapenv:Body>';
            body = body+'</soapenv:Envelope>';

            req.setBody(body);
            System.debug('---------Request Body Update----------'+req.getBody());
            
            String errorMsg = '';
            HTTPResponse res;
            try {
                if(!Test.isRunningTest()) {
                    Http http = new Http();
                    res = http.send(req);
                }
                else{
                    ret = true;
                    res = new HTTPResponse();
                    res.setBody('<test></test>');
                }
                system.debug('----------------CPQ Response----------'+res.getBody());
                Dom.Document doc = res.getBodyDocument();
                Dom.XMLNode envelope = doc.getRootElement();
                Dom.XMLNode resbody = envelope.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
                if(!(resbody+'').contains('faultcode')) {
                    Dom.XMLNode updateTransactionRes= resbody.getChildElement('updateTransactionResponse', 'urn:soap.bigmachines.com');
                    Dom.XMLNode transtatus= updateTransactionRes.getChildElement('status', 'urn:soap.bigmachines.com');
                    Dom.XMLNode tsuccess= transtatus.getChildElement('success', 'urn:soap.bigmachines.com');
                    System.debug(tsuccess.getText()+'Response time'+System.now());
                    ret = true;
                }
            } 
            catch(Exception ex) {
                errorMsg = ex.getMessage();
            }
            if (!ret) {
                Error__c error = new Error__c();
                error.Name = 'OpcityBLACPQUtility';
                error.Entity_Id__c = 'For : ' + tId;
                error.Interface_Name__c = 'updateBigMachineQuote - ' + action;
                error.Error_Description__c = errorMsg + '\nRes: \n'+res.getBody();
                insert error;
            }
            return ret;
        }
    }