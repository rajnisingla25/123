//Name        : ARIICPQCalls
//Description : Utility class for
//Frequencey  : Every Month
//Author      : Pallavi Tammana
//History     : CRM-3261: SFDC tasks for Lead processing & quote creation

public class ARIICPQCalls {
    

    //variables used in constructor
    Public static BigMachineUrls__c BMUrls= BigMachineUrls__c.getValues('BM');
    Public static String BMUserName;
    Public static String BMUserPassword;
    Public static String BMUrl;
    Public static String BMSalesforceInstance;
    Public static String BMInstance;
    Public static String CPQReturnedMsg = '';
    Public static String bmsessionid;
    Public static String RequestResult;
    //variables used in create quote
    Public static Set<Id> setAssetIds = new Set<Id>();
    Public static String AccountId ='';
    Public static String OpportunityId ='';
    Public static String lineActionType;
    Public static Map<Id,String> mapAssetLineAction = new Map<Id,String>();    
    Public static String QuoteownerId='';
    Public static String QuoteownerName='';
    Public static String tid;
    Public Static String ArIdStr = '';
    Public Static String franchiseType;
    Public Static String configOptions;

    //variables used in update quote
    Public static String SFCreatedQuoteId = '';
    public static List<AutoRenewalQuoteLineWrapper> updateAutoRenewalQuoteLineWrapper = new List<AutoRenewalQuoteLineWrapper>(); 
    public static String atype;
    public static String sessionRes = '';
    public static String createTransactionRes = '';
    public static String updateTransactionRes = '';
    public static String acctBillingPreference;//CRM-2508

    //Constructors
    Public ARIICPQCalls(){
          if(BMUrls!=null){
                  BMUserName = BMUrls.DefaultUserName__c;
                  BMUserPassword=BMUrls.DefaultPassword__c;
                  BMUrl = BMUrls.Bigmachine_Url__c;
                  BMSalesforceInstance =BMUrls.Salesforce_Instance__c;
                  BMInstance = BMUrls.BigmachineInstance__c;
         }
         
    }
    //CRM-2456
    Public ARIICPQCalls(BigMachineUrls__c bURL){
          if(bUrl!=null){
                  BMUserName = BUrl.DefaultUserName__c; //CRM-2456
                  BMUserPassword=BUrl.DefaultPassword__c; //CRM-2456
                  BMUrl = BUrl.Bigmachine_Url__c; //CRM-2456
                  BMSalesforceInstance =BUrl.Salesforce_Instance__c; //CRM-2456
                  BMInstance = BUrl.BigmachineInstance__c; //CRM-2456
         }
         
    }

    //Getting session Id by making login call
    Public static String GetSessionId(String username,string password){
        HttpRequest req = new HttpRequest();
        HTTPResponse res = new HttpResponse();
        Http http = new Http();
        req.setTimeout(40000);
        req.setMethod('POST');
        req.setEndpoint('https://'+BMInstance+'.bigmachines.com/v1_0/receiver');
        req.setBody(ARIICPQCallsUtility.getLoginReq(username, password));
        system.debug('Request XML: '+ req.getBody());
        sessionRes = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><bm:loginResponse xmlns:bm="urn:soap.bigmachines.com"><bm:status><bm:success>true</bm:success><bm:message>Thu Nov 30 16:55:24 CST 2017 - Successfully processed API for qamoveinc</bm:message></bm:status><bm:userInfo><bm:sessionId>hHTmhgMbrp8fb5d7YWPsL2NDw7c9nhhKZGyFjXSqB2yJlTQhYTm6!626200874!1512082523946</bm:sessionId></bm:userInfo></bm:loginResponse></soapenv:Body></soapenv:Envelope>';

        if(!Test.isRunningTest()){
            res = http.send(req); 
        }
        else{
            res.setBody(sessionRes);//'<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><bm:loginResponse xmlns:bm="urn:soap.bigmachines.com"><bm:status><bm:success>true</bm:success><bm:message>Thu Nov 30 16:55:24 CST 2017 - Successfully processed API for qamoveinc</bm:message></bm:status><bm:userInfo><bm:sessionId>hHTmhgMbrp8fb5d7YWPsL2NDw7c9nhhKZGyFjXSqB2yJlTQhYTm6!626200874!1512082523946</bm:sessionId></bm:userInfo></bm:loginResponse></soapenv:Body></soapenv:Envelope>');
        }             
            Dom.Document doc = res.getBodyDocument();
            Dom.XMLNode envelope = doc.getRootElement();
            Dom.XMLNode resbody = envelope.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
             if(!(resbody+'').contains('faultcode')){
                    Dom.XMLNode loginresponse= resbody.getChildElement('loginResponse', 'urn:soap.bigmachines.com');
                    Dom.XMLNode userinfo= loginresponse.getChildElement('userInfo', 'urn:soap.bigmachines.com');
                    Dom.XMLNode sessid= userinfo.getChildElement('sessionId', 'urn:soap.bigmachines.com');
                    bmsessionid= sessid.getText();
                } else {
                    CPQReturnedMsg =  (resbody+'');
                    Error__c error = new Error__c();
                    error.Name = 'ARIICPQCalls';
                    error.Entity_Id__c = 'For : ' + tId;
                    error.Interface_Name__c = 'ARIICPQCalls.GetSessionId';
                    string exceptionMsg = '';
                    if( CPQReturnedMsg != null ){
                        exceptionMsg = '.------- Exception: ' + CPQReturnedMsg;
                    }
                    error.Error_Description__c = 'failedRecordIds: = '+tId + exceptionMsg+' - Request XML ->'+req.getBody();
                    insert error;
                    system.debug('----------------CPQReturnedMsg---------'+CPQReturnedMsg);
                }
         
       
        return bmsessionid;
    }
    
    public static String AssetNightlyPriceUpdate(String tranId, String type, Set<Id> ARasstId, String AsstConfig){
        HttpRequest req = new HttpRequest();
        HTTPResponse res = new HttpResponse();
        Http http = new Http();
        
        req.setTimeout(120000);
        String tidd='';
        String newtidd='';
        ArIdStr = '';
        if(bmsessionid==null || bmsessionid=='') {
            bmsessionid = GetSessionId(null,null);   
        }
        atype = type;
        tId = tranId;
        if(aType == 'plainSave_t') {
           if(!test.isRunningTest()) {franchiseType = [Select BigMachines__Account__r.Franchise_Type__c from BigMachines__Quote__c where BigMachines__Transaction_Id__c=:tranID].BigMachines__Account__r.Franchise_Type__c;}
            for(Id ArId: ARasstId){
                if(ArIdStr == null || ArIdStr == ''){
                    ArIdStr = '\''+ArId+'\'';
                }
                else
                ArIdStr = ArIdStr+ ',\''+ArId+'\'';
            }
            if(AsstConfig != null)
                configOptions = AsstConfig;
        }
        system.debug('-- > ArIdStr '+ArIdStr);
        system.debug('-- > ARasstId '+ARasstId);
        //Set HTTPRequest Method
        req.setMethod('POST');
        req.setEndpoint('https://'+BMInstance+'.bigmachines.com/v1_0/receiver');
        req.setBody(ARIICPQCallsUtility.getUpdateReq());
        System.debug('---------Request Body Update----------'+req.getBody());
        
        
         try {
            //if(!Test.isRunningTest() || true){
                //if(Test.isRunningTest()){Integer ii=1/0;} 
                //Execute web service call here
               if(!Test.isRunningTest()){ res = http.send(req);}
             else{res.setBody(updateTransactionRes);}//'<?xml version=\'1.0\' encoding=\'utf-8\'?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><bm:updateTransactionResponse xmlns:bm="urn:soap.bigmachines.com"><bm:status><bm:success>true</bm:success><bm:message>Tue Nov 07 08:19:54 CST 2017 - Successfully processed API for qamoveinc</bm:message></bm:status></bm:updateTransactionResponse></soapenv:Body></soapenv:Envelope>');}
                system.debug('----------------CPQ Response----------'+res.getBody());
                Dom.Document doc = res.getBodyDocument();
                Dom.XMLNode envelope = doc.getRootElement();
                Dom.XMLNode resbody = envelope.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
                if(!(resbody+'').contains('faultcode')){
                    Dom.XMLNode updateTransactionRes= resbody.getChildElement('updateTransactionResponse', 'urn:soap.bigmachines.com');
                    Dom.XMLNode transtatus= updateTransactionRes.getChildElement('status', 'urn:soap.bigmachines.com');
                    Dom.XMLNode tsuccess= transtatus.getChildElement('success', 'urn:soap.bigmachines.com');                    
                    RequestResult = tsuccess.getText();
                } else {
                    CPQReturnedMsg =  (resbody+'');
                    Error__c error = new Error__c();
                    error.Name = 'ARIICPQCalls';
                    error.Entity_Id__c = 'For : ' + tId;
                    error.Interface_Name__c = 'ARIICPQCalls.AssetNightlyPriceUpdate';
                    string exceptionMsg = '';
                    if( CPQReturnedMsg != null ){
                        exceptionMsg = '.------- Exception: ' + CPQReturnedMsg;
                    }
                    error.Error_Description__c = 'failedRecordIds: = '+tId + exceptionMsg+' - Request XML ->'+req.getBody();
                    insert error;
                    system.debug('----------------CPQReturnedMsg---------'+CPQReturnedMsg);
                }
           // }
        } catch(Exception ex) {
            //Exception handling goes here....
             Error__c error = new Error__c();
            error.Name = 'ARIICPQCalls';
            error.Entity_Id__c = 'For : ' + tId;
            error.Interface_Name__c = 'ARIICPQCalls.AssetNightlyPriceUpdate';
            string exceptionMsg = '';
            if( ex != null ){
                CPQReturnedMsg = ex.getMessage();
                exceptionMsg = '.------- Exception: ' + ex.getMessage() + '------StackTraceString: ---' + ex.getStackTraceString();
            }
            error.Error_Description__c = 'failedRecordIds: = '+tId + exceptionMsg+' - Request XML ->'+req.getBody();
            insert error;
            system.debug('----------------CPQReturnedMsg---------'+CPQReturnedMsg);
    
        }
        return tId;
        
    }

    public static void CreateQuote(string accId,String oppid,Map<Id,String> assetIds){
        setAssetIds = assetIds.keyset();
        if(oppid!=null){OpportunityId = oppid;}
        if(accId!=null){AccountId=accId;}
        lineActionType = 'renew';
        mapAssetLineAction = assetIds;
        QuoteownerId = UserInfo.getUSERId();
        QuoteownerName = UserInfo.getUserName();


        if(accId!=null){
            Account accc=[Select Id,Ownerid,owner.Name,Billing_Preference__c from Account where id=:accId];
            if(accc!=null){
                QuoteownerId = accc.Ownerid;
                QuoteownerName = accc.owner.Name;
                
                }
            }
        
        if(bmsessionid==null || bmsessionid==''){
            bmsessionid = GetSessionId(null,null);
        }
        system.debug('In Create Quote-------------'+bmsessionid);
        system.debug('set asset ids --> '+setassetIds);
        CreateBigMachineQuote();

        }
    

    Public static void CreateBigMachineQuote(){
        HttpRequest req = new HttpRequest();
        req.setTimeout(80000);
       
        //Set HTTPRequest Method
        req.setMethod('POST');
        req.setEndpoint('https://'+BMInstance+'.bigmachines.com/v1_0/receiver');
        //Set the HTTPRequest body
        req.setBody(ARIICPQCallsUtility.getcreateReq()); 
        System.debug('---------Request Body----------'+req.getBody());
        Http http = new Http();
        String createdqouteId = '';
        try {
           // if(!Test.isRunningTest()){
            //  if(Test.isRunningTest()){Integer ii=1/0;} 
                //Execute web service call here
                HTTPResponse res = new HTTPResponse();
                if(!Test.isRunningTest()){res = http.send(req);}
                else{
                    res.setbody(createTransactionRes);//'<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><bm:createTransactionResponse xmlns:bm="urn:soap.bigmachines.com"><bm:status><bm:success>true</bm:success><bm:message>Thu Nov 30 16:56:13 CST 2017 - Successfully processed API for qamoveinc</bm:message></bm:status><bm:transaction><bm:category>bm_cm_bs_data</bm:category><bm:action>add</bm:action><bm:id>107523155</bm:id><bm:process_var_name>oraclecpqo</bm:process_var_name><bm:buyer_company_name>qamoveinc</bm:buyer_company_name><bm:supplier_company_name>qamoveinc</bm:supplier_company_name><bm:step_var_name/><bm:last_document_number>1</bm:last_document_number><bm:date_added>2017-11-30 16:56:13</bm:date_added><bm:date_modified>2017-11-30 16:56:13</bm:date_modified><bm:data_xml><bm:transaction bm:bs_id="107523155" bm:buyer_company_name="qamoveinc" bm:buyer_user_name="ashoksontinenicontractor" bm:currency_pref="USD" bm:data_type="0" bm:document_name="Transaction" bm:document_number="1" bm:document_var_name="transaction" bm:process_var_name="oraclecpqo" bm:supplier_company_name="qamoveinc"><bm:_document_number>1</bm:_document_number><bm:obsolete_attributes><bm:__cm_bs_service_ignore_override>false</bm:__cm_bs_service_ignore_override><bm:__cm_bs_service_unsaved_data>false</bm:__cm_bs_service_unsaved_data><bm:__cm_bs_service_new_data>false</bm:__cm_bs_service_new_data><bm:_price_quantity>1</bm:_price_quantity></bm:obsolete_attributes><bm:approval_history/><bm:approval_status/><bm:sub_documents/><bm:rule_data><bm:totalAnnualValue_t bm:constrained="false" bm:hidden="true"/><bm:selectedFulfillToLineNums_quote bm:constrained="false" bm:hidden="true"/><bm:paymentAuthorization_quote bm:constrained="false" bm:hidden="true"/><bm:chooseLead bm:constrained="false" bm:hidden="true"/><bm:totalUsageFees_quote bm:constrained="false" bm:hidden="true"/><bm:totalMonthlyDiscount_t bm:constrained="false" bm:hidden="true"/><bm:authorizationAmount_quote bm:constrained="false" bm:hidden="true"/><bm:taxExemptReason_t bm:constrained="false" bm:hidden="true"/><bm:totalMonthlyNetAmount_t bm:constrained="false" bm:hidden="true"/><bm:authorizationDate_quote bm:constrained="false" bm:hidden="true"/><bm:paymentAuthorizationlabel_quote bm:constrained="false" bm:hidden="true"/><bm:hTMLErrorMessage_quote bm:constrained="false" bm:hidden="true"/><bm:selectedOfficeValue_t bm:constrained="false" bm:hidden="true"/><bm:totalMonthlyListAmount_t bm:constrained="false" bm:hidden="true"/><bm:specialAdvantagePricing_quote bm:constrained="false" bm:hidden="true"/><bm:prorationMessage_quote bm:constrained="false" bm:hidden="true"/><bm:estUsageTax_quote bm:constrained="false" bm:hidden="true"/></bm:rule_data></bm:transaction></bm:data_xml><bm:action_data><bm:action_var_name/><bm:_bm_cm_new_transaction_currency/><bm:performer_comment/><bm:reason_var_name/><bm:performer_name/><bm:performer_type/><bm:performer_company_name/></bm:action_data><bm:sub_step_name/><bm:buyer_user_name>ashoksontinenicontractor</bm:buyer_user_name><bm:currency_pref>USD</bm:currency_pref><bm:status>0</bm:status><bm:update_count>2</bm:update_count><bm:language_pref>English</bm:language_pref><bm:num_transitions>0</bm:num_transitions></bm:transaction></bm:createTransactionResponse></soapenv:Body></soapenv:Envelope>');
                }
                String docc = res.getBody();
                Dom.Document doc = res.getBodyDocument();
                Dom.XMLNode envelope = doc.getRootElement();
                Dom.XMLNode resbody = envelope.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
                Dom.XMLNode createTransactionRes= resbody.getChildElement('createTransactionResponse', 'urn:soap.bigmachines.com');
                Dom.XMLNode trans= createTransactionRes.getChildElement('transaction', 'urn:soap.bigmachines.com');
                Dom.XMLNode ttid= trans.getChildElement('id', 'urn:soap.bigmachines.com');
                
                RequestResult = '';
                tid = createBigMachineQuoteIncpq(ttid.getText(),'cleanSave_t');
                
                system.debug(' Request result --> '+requestResult);
               
                if(RequestResult!=''){
                    RequestResult = '';
                    UpdateBigMachineQuoteWaitlist(ttid.getText(),'mLSImport');
                    system.debug('inside mls import call');
                }
                
                if(RequestResult!=''){
                    RequestResult = '';
                    createBigMachineQuoteIncpq(ttid.getText(),'_update_line_items');
                    System.debug('KKKKKKKK'+ttid.getText());
                    if(RequestResult!=''){
                        RequestResult = '';
                        createBigMachineQuoteIncpq(ttid.getText(),'cleanSave_t');
                        System.debug('KKKKKKKK'+ttid.getText());
                        
                    }
                }
                createdqouteId = [Select id,name,BigMachines__Transaction_Id__c from BigMachines__Quote__c where BigMachines__Transaction_Id__c=:ttid.getText()].id;

           /* } else {
                tid = '34453453';
                createdqouteId = '1234567890';
            } */
          
        } catch(Exception ex) {
             Error__c error = new Error__c();
            error.Name = 'ARIICPQCalls';
            error.Entity_Id__c = 'For : ' + createdqouteId;
            error.Interface_Name__c = 'ARIICPQCalls.CreateBigMachineQuote';
            string exceptionMsg = '';
            if( ex != null ){
           //     CPQReturnedMsg = ex.getMessage();
                exceptionMsg = '.------- Exception: ' + ex.getMessage() + '------StackTraceString: ---' + ex.getStackTraceString();
            }
            error.Error_Description__c = 'failedRecordIds: = '+createdqouteId + exceptionMsg+' - Request XML ->'+req.getBody();
            insert error;

        }

   }

    Public static String createBigMachineQuoteIncpq(String tranId,String type){
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        HTTPResponse res = new HTTPResponse();

        req.setTimeout(80000);
        //Set HTTPRequest Method
        req.setMethod('POST');
        req.setEndpoint('https://'+BMInstance+'.bigmachines.com/v1_0/receiver');
        //Set the HTTPRequest body
        atype = type;
        tid = tranId;
        req.setBody(ARIICPQCallsUtility.getUpdateReqFullInfo());
        

        System.debug('---------Request Body Update----------'+req.getBody());
        

        try {
            //if(!Test.isRunningTest() || true){
            //  if(Test.isRunningTest()){Integer ii=1/0;} 
                //Execute web service call here
               if(!Test.isRunningTest()){ res = http.send(req);}
            else{res.setBody(createTransactionRes);}//'<?xml version="1.0" encoding="utf-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><bm:updateTransactionResponse xmlns:bm="urn:soap.bigmachines.com"><bm:status><bm:success>true</bm:success><bm:message>Tue Nov 07 08:19:54 CST 2017 - Successfully processed API for qamoveinc</bm:message></bm:status></bm:updateTransactionResponse></soapenv:Body></soapenv:Envelope>');}
                system.debug('----------------CPQ Response----------'+res.getBody());
                Dom.Document doc = res.getBodyDocument();
                Dom.XMLNode envelope = doc.getRootElement();
                Dom.XMLNode resbody = envelope.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
                if(!(resbody+'').contains('faultcode')){
                    Dom.XMLNode updateTransactionRes= resbody.getChildElement('updateTransactionResponse', 'urn:soap.bigmachines.com');
                    Dom.XMLNode transtatus= updateTransactionRes.getChildElement('status', 'urn:soap.bigmachines.com');
                    Dom.XMLNode tsuccess= transtatus.getChildElement('success', 'urn:soap.bigmachines.com');
                    RequestResult = tsuccess.getText();
                } else {
                    CPQReturnedMsg =  (resbody+'');
                    Error__c error = new Error__c();
                    error.Name = 'ARIICPQCalls';
                    error.Entity_Id__c = 'For : ' + tId;
                    error.Interface_Name__c = 'ARIICPQCalls.UpdateBigMachineQuote';
                    string exceptionMsg = '';
                    if( CPQReturnedMsg != null ){
                        exceptionMsg = '.------- Exception: ' + CPQReturnedMsg;
                    }
                    error.Error_Description__c = 'failedRecordIds: = '+tId + exceptionMsg+' - Request XML ->'+req.getBody();
                    insert error;
                    system.debug('----------------CPQReturnedMsg---------'+CPQReturnedMsg);
                }
            //} 
        } catch(Exception ex) {
            //Exception handling goes here....
             Error__c error = new Error__c();
            error.Name = 'ARIICPQCalls';
            error.Entity_Id__c = 'For : ' + tId;
            error.Interface_Name__c = 'ARIICPQCalls.UpdateBigMachineQuote';
            string exceptionMsg = '';
            if( ex != null ){
                CPQReturnedMsg = ex.getMessage();
                exceptionMsg = '.------- Exception: ' + ex.getMessage() + '------StackTraceString: ---' + ex.getStackTraceString();
            }
            error.Error_Description__c = 'failedRecordIds: = '+tId + exceptionMsg+' - Request XML ->'+req.getBody();
            insert error;
            system.debug('----------------CPQReturnedMsg---------'+CPQReturnedMsg);

        }
        return tId;
    }


     // Quote update delete /Update
    Public static String UpdateDeleteAutoRenewalQuote(String QuoteId, List<AutoRenewalQuoteLineWrapper> updateAutoRenewalQuoteLineWrapper){
        if(bmsessionid==null || bmsessionid==''){
            bmsessionid = GetSessionId(null,null);
        }
        String tIdd;
       // BMQuoteId = QuoteId;

       if(Test.isRunningTest()) {
            tidd = '7675435';
        }
        else if(tidd==null){
            System.debug(QuoteId+'QId *********** ');
            tidd = [Select Id,BigMachines__Transaction_Id__c from BigMachines__Quote__c where Id=:QuoteId].BigMachines__Transaction_Id__c;
        }
        
        
        if(updateAutoRenewalQuoteLineWrapper.size()>0){
            //if(!Test.isRunningTest()){
               if(RequestResult!=''){
                 RequestResult = '';
                 UpdateBigMachineQuoteWaitlist(tidd,'cleanSave_t');
               }
                if(RequestResult!=''){
                RequestResult = '';
                UpdateBigMachineQuoteWaitlist(tidd,'_update_line_items');
                }
                if(RequestResult!=''){
                RequestResult = '';
                UpdateBigMachineQuoteWaitlist(tidd,'cleanSave_t');
                }
               if(RequestResult!=''){
                RequestResult = '';
               UpdateBigMachineQuoteWaitlist(tidd,'calculateTax');
               }
               if(RequestResult!=''){
                RequestResult = '';
               UpdateBigMachineQuoteWaitlist(tidd,'submit_t');
               }  
          //  }
        }
        SFCreatedQuoteId = QuoteId;
        return QuoteId;
    }


    Public static String UpdateBigMachineQuoteWaitlist(String tranId,String type){
        if(!Test.isRunningTest()){
        acctBillingPreference = [Select BigMachines__Account__r.Billing_Preference__c from BigMachines__Quote__c where BigMachines__Transaction_Id__c=:tranID].BigMachines__Account__r.Billing_Preference__c; //CRM-2805
        }else{
            acctBillingPreference = 'Test Billing Preference';
        }
        HttpRequest req = new HttpRequest();
        req.setTimeout(80000);
        //Set HTTPRequest Method
        req.setMethod('POST');
        req.setEndpoint('https://'+BMInstance+'.bigmachines.com/v1_0/receiver');
        //Set the HTTPRequest body
        atype = type;
        tId = tranId;
        system.debug('atype -->'+atype);
        system.debug('type -->'+type);
        req.setBody(ARIICPQCallsUtility.getUpdateReq());
        system.debug('My body Value'+req.getbody());
        Http http = new Http();

        try {
          //  if(!Test.isRunningTest() || true){
            //  if(Test.isRunningTest()){Integer ii=1/0;} 
                //Execute web service call here
                HTTPResponse res = new HTTPResponse();
                if(!Test.isRunningTest()){ res= http.send(req);}
            else{res.setBody(updateTransactionRes);}//'<?xml version=\'1.0\' encoding=\'utf-8\'?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><bm:updateTransactionResponse xmlns:bm="urn:soap.bigmachines.com"><bm:status><bm:success>true</bm:success><bm:message>Tue Nov 07 08:19:54 CST 2017 - Successfully processed API for qamoveinc</bm:message></bm:status></bm:updateTransactionResponse></soapenv:Body></soapenv:Envelope>');}
                system.debug('----------------CPQ Response----------'+res.getBody());
    
                Dom.Document doc = res.getBodyDocument();
                Dom.XMLNode envelope = doc.getRootElement();
                Dom.XMLNode resbody = envelope.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
                if(!(resbody+'').contains('faultcode')){
                    Dom.XMLNode updateTransactionRes= resbody.getChildElement('updateTransactionResponse', 'urn:soap.bigmachines.com');
                    Dom.XMLNode transtatus= updateTransactionRes.getChildElement('status', 'urn:soap.bigmachines.com');
                    Dom.XMLNode tsuccess= transtatus.getChildElement('success', 'urn:soap.bigmachines.com');
                    RequestResult = tsuccess.getText();
                } else {
                    CPQReturnedMsg =  (resbody+'');
                    Error__c error = new Error__c();
                    error.Name = 'ARIICPQCalls';
                    error.Entity_Id__c = 'For : ' + tId;
                    error.Interface_Name__c = 'ARIICPQCalls.UpdateBigMachineQuoteWaitlist';
                    string exceptionMsg = '';
                    if( CPQReturnedMsg != null ){
                        exceptionMsg = '.------- Exception: ' + CPQReturnedMsg;
                    }
                    error.Error_Description__c = 'failedRecordIds: = '+tId + exceptionMsg+' - Request XML ->'+req.getBody();
                    insert error;
                    system.debug('----------------CPQReturnedMsg---------'+CPQReturnedMsg);
                }
           // }
        } catch(Exception ex) {
            //Exception handling goes here....
            Error__c error = new Error__c();
            error.Name = 'ARIICPQCalls';
            error.Entity_Id__c = 'For : ' + tId;
            error.Interface_Name__c = 'ARIICPQCalls.UpdateBigMachineQuoteWaitlist';
            string exceptionMsg = '';
            if( ex != null ){
                CPQReturnedMsg = ex.getMessage();
                exceptionMsg = '.------- Exception: ' + ex.getMessage() + '------StackTraceString: ---' + ex.getStackTraceString();
            }
            error.Error_Description__c = 'failedRecordIds: = '+tId + exceptionMsg+' - Request XML ->'+req.getBody();
            insert error;
            system.debug('----------------CPQReturnedMsg---------'+CPQReturnedMsg);
        }
        return tId;
    }
    //Wrapper Class

    Public class AutoRenewalQuoteLineWrapper{
        Public String BMDocumentNumber{get;set;}
        Public String BMActionRequired{get;set;} //Delete,Update
        Public String BillingType{get;set;}
    }


}