global class WebserviceCallBigMachineQuoteCls{
    Public String bmsessionid{get;set;}
    Public String AccountId ='';
    Public String OpportunityId ='';
    Public String CaseId ='';
    Public String QuoteownerId='';
    Public String BMQuoteId = '';
    Public String SFCreatedQuoteId = '';
    Public String CPQReturnedMsg = '';
    Public String inventorypool='';
    Public Boolean executeAutoRenewalUpdate=false;
    Public Boolean suppressdocusign;
    Public Boolean suppressauthrisation;
    Public String QuoteownerName='';
    Public String quoteType{get;set;}
    Public String quoteTypeNew{get;set;}
    Public String lineActionType{get;set;}
    Public String RequestResult{get;set;}
    Public String BMUserName{get;set;}
    Public String BMUserPassword{get;set;}
    Public String BMUrl{get;set;}
    Public String BMSalesforceInstance{get;set;}
    Public String BMInstance{get;set;}
    Public Map<Id,String> mapAssetLineAction = new Map<Id,String>();
    Public Map<Id,String> mapQuoteAccountWebservice = new Map<Id,String>();
    Public List<CreateWaitlistQuoteWrapper> lstclsCreateWaitlistQuoteWrapper = new List<CreateWaitlistQuoteWrapper>();
    Public list<AutoRenewalQuoteLineWrapper> updateAutoRenewalQuoteLineWrapper = new list<AutoRenewalQuoteLineWrapper>();

    Public boolean autoprocess=false;
    Public Set<Id> setAssetIds = new Set<Id>();
    BigMachineUrls__c BMUrls= BigMachineUrls__c.getValues('BM');

    Public WebserviceCallBigMachineQuoteCls(){
    System.debug('Testing'+BMUrls);
    suppressdocusign=false;
          if(BMUrls!=null){
                  BMUserName = BMUrls.DefaultUserName__c;
                  BMUserPassword=BMUrls.DefaultPassword__c;
                  BMUrl = BMUrls.Bigmachine_Url__c;
                  BMSalesforceInstance =BMUrls.Salesforce_Instance__c;
                  BMInstance = BMUrls.BigmachineInstance__c;
         }
    }
    Public Map<String,Integer> mapAssetIDDocumentNumber = new Map<String,Integer>();

    public PageReference CreateQuote(String username,string password,string accId,String oppid,string casid,String qtype,String lineaType,boolean returnCPQ,boolean autop,Map<Id,String> assetIds){
        setAssetIds = assetIds.keyset();
        //AccountId = accountId;
        autoprocess = autop;
        if(oppid!=null){OpportunityId = oppid;}
        if(accId!=null){AccountId=accId;}
        if(casid!=null){CaseId = casid;}
        lineActionType = lineaType;
        mapAssetLineAction = assetIds;
        quoteType = qtype;
        QuoteownerId = UserInfo.getUSERId();
        QuoteownerName = UserInfo.getUserName();
        suppressdocusign = false;
        suppressauthrisation = false;
        if(accId!=null && ( quoteType=='Backout' || ( quoteType =='Modify' && lineaType == 'cancel') || (quoteType =='Auto-Renew') ) ){
        Account accc=[Select Id,Ownerid,owner.Name,Billing_Preference__c from Account where id=:accId];
        if(accc!=null){
        QuoteownerId = accc.Ownerid;
        QuoteownerName = accc.owner.Name;
        if( ((quoteType =='Modify' && lineaType == 'cancel') || quoteType == 'Auto-Renew') && (accc.Billing_Preference__c=='Invoice-Terms' || accc.Billing_Preference__c=='Arrears-Invoice')){
            suppressdocusign = true;
        }
        if(quoteType == 'Auto-Renew'){
            suppressauthrisation = true;
        }

        }
        }
        if(bmsessionid==null || bmsessionid==''){
        bmsessionid = GetSessionId(username,password);
        }
        system.debug('In Create Quote-------------'+bmsessionid);
        //bmsessionid = '9747AC785118D453E6A722F530658D09';
        PageReference pr =null;

        if(returnCPQ==true){
        String salesforceqouteid = CreateBigMachineQuote();
        SFCreatedQuoteId = salesforceqouteid;
        pr = new PageReference(BMSalesforceInstance +'/apex/QuoteEdit?retURL=%2F'+salesforceqouteid+'&scontrolCaching=1&sfdc.override=1&id='+salesforceqouteid);
            //pr = new PageReference('https://'+BMInstance+'.bigmachines.com/commerce/buyside/document.jsp?bm_cm_process_id=36244034&formaction=performAction&document_id=36244074&action_id=36244076&version_id=36306984&id='+CreateBigMachineQuote());
            pr.setRedirect(true);
        }
        //system.debug('Page Reference: ' + pr);
        return pr;
    }

     public String CreateWaitlistQuote(String username,string password,string accId,String oppid,string casid,String qtype,String lineaType,boolean returnCPQ,boolean autop,String waitlistId,String wquoteOwnerName,String wquoteOwnerId,List<CreateWaitlistQuoteWrapper> lstCreateWaitlistQuoteWrapper){
        //setAssetIds = assetIds.keyset();
        //AccountId = accountId;
        autoprocess = autop;
        if(oppid!=null){OpportunityId = oppid;}
        if(accId!=null){AccountId=accId;}
        if(casid!=null){CaseId = casid;}
        if(wquoteOwnerId!=null){QuoteownerId = wquoteOwnerId;}
         if(wquoteOwnerName!=null){QuoteownerName = wquoteOwnerName;}
        lineActionType = lineaType;
       // mapAssetLineAction = assetIds;
        quoteType = qtype;
        if(bmsessionid==null || bmsessionid==''){
        bmsessionid = GetSessionId(username,password);
        }
        //bmsessionid = '9747AC785118D453E6A722F530658D09';
        PageReference pr =null;
        //if(lineaType!='CFBQuote'){
        inventorypool = 'preauth';
       // }
       /* if(lineaType=='CFBQuote'){
        inventorypool = '';
        }*/
        lstclsCreateWaitlistQuoteWrapper = lstCreateWaitlistQuoteWrapper;
        System.debug('My OPP Id'+oppid);
        String salesforceqouteid = CreateBigMachineQuoteWaitlist();
        SFCreatedQuoteId = salesforceqouteid;
        return salesforceqouteid;
    }

    public String CreateC3Quote(String username,string password,string accId,String oppid,string casid,String qtype,String lineaType,boolean returnCPQ,boolean autop,String waitlistId,String wquoteOwnerName,String wquoteOwnerId,List<CreateWaitlistQuoteWrapper> lstCreateWaitlistQuoteWrapper){
        //setAssetIds = assetIds.keyset();
        //AccountId = accountId;
        autoprocess = autop;
        if(oppid!=null){OpportunityId = oppid;}
        if(accId!=null){AccountId=accId;}
        if(casid!=null){CaseId = casid;}
        if(wquoteOwnerId!=null){QuoteownerId = wquoteOwnerId;}
         if(wquoteOwnerName!=null){QuoteownerName = wquoteOwnerName;}
        lineActionType = lineaType;
       // mapAssetLineAction = assetIds;
        quoteType = qtype;
        if(bmsessionid==null || bmsessionid==''){
        bmsessionid = GetSessionId(username,password);
        }
        //bmsessionid = '9747AC785118D453E6A722F530658D09';
        PageReference pr =null;
        inventorypool = '';
        lstclsCreateWaitlistQuoteWrapper = lstCreateWaitlistQuoteWrapper;
        String salesforceqouteid = CreateBigMachineQuoteWaitlist();
        SFCreatedQuoteId = salesforceqouteid;
        return salesforceqouteid;
    }

    Public String GetSessionId(String username,string password){
        HttpRequest req = new HttpRequest();
        req.setTimeout(40000);
        String tidd='';
        //Set HTTPRequest Method
        req.setMethod('POST');
        req.setEndpoint('https://'+BMInstance+'.bigmachines.com/v1_0/receiver');
        //Set the HTTPRequest body
        String    body ='<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">';
        body = body+'<soapenv:Header>';
        body = body+'<bm:category xmlns:bm="urn:soap.bigmachines.com">Security</bm:category>';
        body = body+'<bm:xsdInfo xmlns:bm="urn:soap.bigmachines.com">';
        body = body+'<bm:schemaLocation>'+BMUrl +'/schema/v1_0/security/Security.xsd</bm:schemaLocation>';
        body = body+'</bm:xsdInfo>';
        body = body+'</soapenv:Header>';
        body = body+'<soapenv:Body>';
        body = body+'<bm:login xmlns:bm="urn:soap.bigmachines.com">';
        body = body+'<bm:userInfo>';
        if(username!=null && password!=null){
            body = body+'<bm:username>'+username+'</bm:username>';
            body = body+'<bm:password>'+password+'</bm:password>';
        } else {
            body = body+'<bm:username>'+BMUserName +'</bm:username>';
            body = body+'<bm:password>'+BMUserPassword +'</bm:password>';
        }
        body = body+'<bm:sessionCurrency/>';
        body = body+'</bm:userInfo>';
        body = body+'</bm:login>';
        body = body+'</soapenv:Body>';
        body = body+'</soapenv:Envelope>';
        req.setBody(body);
        system.debug('Request XML: '+ req);
        Http http = new Http();

        if(!Test.isRunningTest()){
        //Execute web service call here

        HTTPResponse res = http.send(req);
        Dom.Document doc = res.getBodyDocument();
        Dom.XMLNode envelope = doc.getRootElement();
        Dom.XMLNode resbody = envelope.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
        Dom.XMLNode loginresponse= resbody.getChildElement('loginResponse', 'urn:soap.bigmachines.com');
        Dom.XMLNode userinfo= loginresponse.getChildElement('userInfo', 'urn:soap.bigmachines.com');
        Dom.XMLNode sessid= userinfo.getChildElement('sessionId', 'urn:soap.bigmachines.com');
        bmsessionid= sessid.getText();
        } else {
        bmsessionid = 'sfasfasfasasfasfsf';
        }
        return bmsessionid;
    }

    // Quote update delete /Update
    Public String UpdateDeleteAutoRenewalQuote(String QuoteId, List<AutoRenewalQuoteLineWrapper> lstAutoRenewalQuoteLineWrapper){
        list<AutoRenewalQuoteLineWrapper> deleteAutoRenewalQuoteLineWrapper = new list<AutoRenewalQuoteLineWrapper>();
   if(bmsessionid==null || bmsessionid==''){
    bmsessionid = GetSessionId(null,null);
   }
    BMQuoteId = QuoteId;
    autoprocess = true;
    for(AutoRenewalQuoteLineWrapper arqlw:lstAutoRenewalQuoteLineWrapper){
    if(arqlw.BMActionRequired=='Remove'){
     deleteAutoRenewalQuoteLineWrapper.add(arqlw);
    }else{
        updateAutoRenewalQuoteLineWrapper.add(arqlw);
    }
    }

String tidd;
if(quoteTypeNew==null){
quoteType = 'Auto-Renew';
} else {
    quoteType = quoteTypeNew;
}
if(tidd==null){
        System.debug(QuoteId+'QId *********** ');
        BigMachines__Quote__c BigMachineCreatedQuote = [Select Id,BigMachines__Transaction_Id__c,BigMachines__Account__c from BigMachines__Quote__c where Id=:QuoteId];
tidd = BigMachineCreatedQuote.BigMachines__Transaction_Id__c;
Accountid = BigMachineCreatedQuote.BigMachines__Account__c;
    }
    if(Test.isRunningTest()) {
        tidd = '7675435';
    }
    if(deleteAutoRenewalQuoteLineWrapper.size()>0){
        try{
        HttpRequest req = new HttpRequest();
        //if(bmsessionid==null || bmsessionid==''){
        bmsessionid = GetSessionId(null,null);
        //}

        req.setTimeout(80000);
//        String tidd='';
        String newtidd='';
        //Set HTTPRequest Method
        req.setMethod('POST');
        req.setEndpoint('https://'+BMInstance+'.bigmachines.com/v1_0/receiver');
        //Set the HTTPRequest body
        String    body ='<?xml version="1.0" encoding="UTF-8"?>';
        body = body+'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">';
        body = body+'<soapenv:Header>';
        body = body+'<bm:userInfo xmlns:bm="urn:soap.bigmachines.com">';
            body = body+'<bm:sessionId>'+bmsessionid+'</bm:sessionId>';
        body = body+'</bm:userInfo>';
        body = body+'<bm:category xmlns:bm="urn:soap.bigmachines.com">Commerce</bm:category>';
        body = body+'<bm:xsdInfo xmlns:bm="urn:soap.bigmachines.com">';
            body = body+'<bm:schemaLocation>https://'+BMUrl +'/schema/v1_0/commerce/oraclecpqo.xsd</bm:schemaLocation>';
        body = body+'</bm:xsdInfo>';
        body = body+'</soapenv:Header>';
        body = body+'<soapenv:Body>';
        body = body+'<bm:removeFromTransaction xmlns:bm="urn:soap.bigmachines.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
            body = body+'<bm:items>';
            System.debug('deleteAutoRenewalQuoteLineWrapper'+deleteAutoRenewalQuoteLineWrapper);
            for(AutoRenewalQuoteLineWrapper arqlw:deleteAutoRenewalQuoteLineWrapper){
                body = body+'<bm:item>';
                     body = body+'<bm:document_number>'+arqlw.BMDocumentNumber+'</bm:document_number>';
                body = body+'</bm:item>';
            }
            body = body+'</bm:items>';
            body = body+'<bm:transaction>';
                body = body+'<bm:process_var_name>oraclecpqo</bm:process_var_name>';
                body = body+'<bm:id>'+Integer.valueof(tidd)+'</bm:id>';
                body = body+'<bm:action_data>';
                    body = body+'<bm:document_var_name>transaction</bm:document_var_name>';
                body = body+'</bm:action_data>';
            body = body+'</bm:transaction>';
        body = body+'</bm:removeFromTransaction>';
    body = body+'</soapenv:Body>';
    body = body+'</soapenv:Envelope>';
    req.setBody(body);


        System.debug('---------Request Body Remove----------'+req.getBody());
        Http http = new Http();

        String createdqouteId = '';
            if(!Test.isRunningTest()){
            //Execute web service call here
            HTTPResponse res = http.send(req);

            String docc = res.getBody();
            Dom.Document doc = res.getBodyDocument();
            Dom.XMLNode envelope = doc.getRootElement();
            Dom.XMLNode resbody = envelope.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
            Dom.XMLNode createTransactionRes= resbody.getChildElement('removeFromTransactionResponse', 'urn:soap.bigmachines.com');
            Dom.XMLNode trans= createTransactionRes.getChildElement('status', 'urn:soap.bigmachines.com');
            //Dom.XMLNode tid= trans.getChildElement('id', 'urn:soap.bigmachines.com');
            //tidd = tid.getText();
            //RequestResult = trans.getText();
            System.debug('---------Response Body Remove----------'+res.getBody());
            Dom.XMLNode transmsg= trans.getChildElement('message', 'urn:soap.bigmachines.com');
            RequestResult = transmsg.getText();
            System.debug('---------Response Body Remove----------'+transmsg.getText());
            }
        } catch(Exception ex){

        }
              if(RequestResult!=''){
            RequestResult = '';
            UpdateBigMachineQuoteWaitlist(tidd,'cleanSave_t');
            }
           
    }
if(updateAutoRenewalQuoteLineWrapper.size()>0){

    executeAutoRenewalUpdate = true;
    for(AutoRenewalQuoteLineWrapper uaqw:updateAutoRenewalQuoteLineWrapper){
        CreateWaitlistQuoteWrapper cwqa = new CreateWaitlistQuoteWrapper();
        //cwqa.
        lstclsCreateWaitlistQuoteWrapper.add(cwqa);
    }
if(!Test.isRunningTest()){
           // = tid.getText();
           if(RequestResult!=''){
            RequestResult = '';
             UpdateBigMachineQuoteWaitlist(tidd,'cleanSave_t');
           }


            //System.debug('KKKKKKKK'+newtidd);
            if(RequestResult!=''){
            RequestResult = '';
            UpdateBigMachineQuoteWaitlist(tidd,'_update_line_items');
            }

            //System.debug('KKKKKKKK'+newtidd);
            if(RequestResult!=''){
            RequestResult = '';
            UpdateBigMachineQuoteWaitlist(tidd,'cleanSave_t');
            }
           // System.debug('KKKKKKKK'+newtidd);
           if(updateAutoRenewalQuoteLineWrapper.size()>0){
           if(RequestResult!=''){
            RequestResult = '';
           UpdateBigMachineQuoteWaitlist(tidd,'calculateTax');
           }
           if(RequestResult!=''){
            RequestResult = '';
           UpdateBigMachineQuoteWaitlist(tidd,'submit_t');
           }
           }
}
}
SFCreatedQuoteId = QuoteId;
    return QuoteId;
    }

    Public String CreateBigMachineQuote(){
       // bmsessionid = GetSessionId(null,null);
        HttpRequest req = new HttpRequest();
        req.setTimeout(80000);
        String tidd='';
        String newtidd='';
        //Set HTTPRequest Method
        req.setMethod('POST');
        req.setEndpoint('https://'+BMInstance+'.bigmachines.com/v1_0/receiver');
        //Set the HTTPRequest body
        String    body ='<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">';
        body = body+'<soapenv:Header>';
        body = body+'<bm:userInfo xmlns:bm="urn:soap.bigmachines.com">';
        body = body+'<bm:sessionId>'+bmsessionid+'</bm:sessionId>';
        body = body+'</bm:userInfo>';
        body = body+'<bm:category xmlns:bm="urn:soap.bigmachines.com">Commerce</bm:category>';
        body = body+'<bm:xsdInfo xmlns:bm="urn:soap.bigmachines.com">';
        body = body+'<bm:schemaLocation>'+BMUrl +'/schema/v1_0/commerce/oraclecpqo.xsd</bm:schemaLocation>';
        body = body+'</bm:xsdInfo>';
        body = body+'</soapenv:Header>';
        body = body+'<soapenv:Body>';
        body = body+'<bm:createTransaction xmlns:bm="urn:soap.bigmachines.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
        body = body+'<bm:items>';
        //body = body+'<bm:catalogItem>';
        body = body+'<bm:segment>realtor</bm:segment>';
        //body = body+'<bm:product_line>nonInventoryProducts</bm:product_line>';
        //body = body+'<bm:model>fiveStreet';
        //body = body+'</bm:model>';
        //body = body+'</bm:catalogItem>';
        body = body+'<bm:partItem>';
        body = body+'<bm:part/>';
        body = body+'<bm:quantity>1</bm:quantity>';
        body = body+'<bm:price_book_var_name/>';
        body = body+'</bm:partItem>';
        Integer iiii=2;
        if(lineActionType==null && quoteType=='Retention'){lineActionType='cancel';}
        if(quoteType=='Backout'){
            lineActionType='cancel';
        }
        for(Asset assst:    [   Select  Id,
                                        Name,
                                        Product_Email__c,
                                        License_Tier__c,LastModifiedDate,
                                        HLC_Override__c,Last_Activity_Date__c,Last_Order_Activity_Date__c,
                                        Top_Connector__c,Commerce_Group__c,
                                        Contract_Term__c,Billing_Period__c,
                                        Promotion__c,Discount_Type__c,Manual_Discount_Type__c,
                                        Renewal_End_Date__c,Product2.ProductCode,
                                        Quantity,Lead_Type__c,Product_Type__c,
                                        Market_Zip__c,Market__c,Price,Renewal_Start_Date__c,
                                        CampaignId__c,Monthly_Contracted_Units__c,Cost_Per_Action__c,
                                        PricePerImpressionSold__c,Contractedimpressions__c
                                from    Asset
                                where   Accountid=:AccountId
                                        and
                                        Asset_Type__c='Parent'
                                        and
                                        Id=:setAssetIds
                                        and
                                        Quantity>0]){

            Integer qtty=0;
            string pcode = 'COBROKE';

            if( assst.Product2.ProductCode  !=  null ){
                pcode=assst.Product2.ProductCode;
            }
            string campaignId = '';
            if( assst.CampaignId__c != null && assst.CampaignId__c != '' ){
                campaignId = assst.CampaignId__c;
            }
            mapAssetIDDocumentNumber.put(assst.Id,iiii);

            if( assst.Quantity != null ){
                qtty =Integer.valueof(assst.Quantity);
            }
            body = body+'<bm:partItem>';
            body = body+'<bm:part>'+pcode+'</bm:part>';
            body = body+' <bm:quantity>'+qtty+'</bm:quantity>';
            body = body+'<bm:price_book_var_name>_default_price_book</bm:price_book_var_name>';
            body = body+'<bm:lineType_line>'+lineActionType+'</bm:lineType_line>';
            body = body+'<bm:campaignId_line>'+campaignId+'</bm:campaignId_line>';
            if(assst.Cost_Per_Action__c!=null){body = body+'<bm:costPerAction_line>'+assst.Cost_Per_Action__c+'</bm:costPerAction_line>';}
            if(assst.PricePerImpressionSold__c!=null){body = body+'<bm:pricePerImpressionSold_line>'+assst.PricePerImpressionSold__c+'</bm:pricePerImpressionSold_line>';}
            body = body+'<bm:forecastedLeads_line>'+assst.Monthly_Contracted_Units__c+'</bm:forecastedLeads_line>';
            body = body+'<bm:contractedImpressions_line>'+assst.Contractedimpressions__c+'</bm:contractedImpressions_line>';

            body = body+'</bm:partItem>';
            iiii++;
        }

        body = body+'</bm:items>';
        body = body+'<bm:transaction>';
        body = body+'<bm:process_var_name>oraclecpqo</bm:process_var_name>';
        body = body+'<bm:quoteType_quote>'+quoteType+'</bm:quoteType_quote>';
        if(AccountId!=null && AccountId!=''){
        body = body+'<bm:_customer_id>'+AccountId+'</bm:_customer_id>';
        }
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
        Http http = new Http();
        String createdqouteId = '';
        try {
            if(!Test.isRunningTest()){
            //Execute web service call here
            HTTPResponse res = http.send(req);

            String docc = res.getBody();
            Dom.Document doc = res.getBodyDocument();
            Dom.XMLNode envelope = doc.getRootElement();
            Dom.XMLNode resbody = envelope.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
            Dom.XMLNode createTransactionRes= resbody.getChildElement('createTransactionResponse', 'urn:soap.bigmachines.com');
            Dom.XMLNode trans= createTransactionRes.getChildElement('transaction', 'urn:soap.bigmachines.com');
            Dom.XMLNode tid= trans.getChildElement('id', 'urn:soap.bigmachines.com');
            tidd = tid.getText();
            RequestResult = '';
            newtidd = UpdateBigMachineQuote(tid.getText(),'cleanSave_t');
            System.debug(newtidd+'$$$$$');
            if(quoteType== 'Auto-Renew') {
             if(RequestResult!=''){
            RequestResult = '';
             UpdateBigMachineQuoteWaitlist(tidd,'mLSImport');
             }
            }
            
            if(RequestResult!=''){
              RequestResult = '';
            UpdateBigMachineQuote(tid.getText(),'_update_line_items');
            System.debug('KKKKKKKK'+newtidd);
            if(RequestResult!=''){
            RequestResult = '';
            UpdateBigMachineQuote(tid.getText(),'cleanSave_t');
            System.debug('KKKKKKKK'+newtidd);
            if(autoprocess==true){
              if(RequestResult!=''){
              RequestResult = '';
            UpdateBigMachineQuote(tid.getText(),'calculateTax');
            if(RequestResult!=''){
            RequestResult = '';
            UpdateBigMachineQuote(tid.getText(),'submit_t');
            }
              }
            }
            }
            }
                        createdqouteId = [Select id,name,BigMachines__Transaction_Id__c from BigMachines__Quote__c where BigMachines__Transaction_Id__c=:newtidd].id;

            } else {
            tidd = '34453453';
            createdqouteId = '1234567890';
              }
              SFCreatedQuoteId = createdqouteId;
              //CPQReturnedMsg =
            } catch(System.CalloutException ex) {
                 Error__c error = new Error__c();
        error.Name = 'WebserviceBigmachineQuoteUpdate';
        error.Entity_Id__c = 'For : ' + createdqouteId;
        error.Interface_Name__c = 'WebserviceBigmachineQuoteUpdate';
        string exceptionMsg = '';
        if( ex != null ){
            CPQReturnedMsg = ex.getMessage();
            exceptionMsg = '.------- Exception: ' + ex.getMessage() + '------StackTraceString: ---' + ex.getStackTraceString();
        }
        error.Error_Description__c = 'failedRecordIds: = '+createdqouteId + exceptionMsg;
        insert error;

        }

        return  createdqouteId;
        //  return UpdateBigMachineQuote(tidd,'submit_t');
    }

    Public String CreateBigMachineQuoteWaitlist(){
       // bmsessionid = GetSessionId(null,null);
        HttpRequest req = new HttpRequest();
        req.setTimeout(40000);
        String tidd='';
        String newtidd='';
        //Set HTTPRequest Method
        req.setMethod('POST');
        req.setEndpoint('https://'+BMInstance+'.bigmachines.com/v1_0/receiver');
        //Set the HTTPRequest body
        String    body ='<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">';
        body = body+'<soapenv:Header>';
        body = body+'<bm:userInfo xmlns:bm="urn:soap.bigmachines.com">';
        body = body+'<bm:sessionId>'+bmsessionid+'</bm:sessionId>';
        body = body+'</bm:userInfo>';
        body = body+'<bm:category xmlns:bm="urn:soap.bigmachines.com">Commerce</bm:category>';
        body = body+'<bm:xsdInfo xmlns:bm="urn:soap.bigmachines.com">';
        body = body+'<bm:schemaLocation>'+BMUrl +'/schema/v1_0/commerce/oraclecpqo.xsd</bm:schemaLocation>';
        body = body+'</bm:xsdInfo>';
        body = body+'</soapenv:Header>';
        body = body+'<soapenv:Body>';
        body = body+'<bm:createTransaction xmlns:bm="urn:soap.bigmachines.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
        body = body+'<bm:items>';
        body = body+'<bm:segment>realtor</bm:segment>';
        body = body+'<bm:partItem>';
        body = body+'<bm:part/>';
        body = body+'<bm:quantity>1</bm:quantity>';
        body = body+'<bm:price_book_var_name/>';
        body = body+'</bm:partItem>';
        Integer iiii=2;
        if(lineActionType==null && quoteType=='Retention'){lineActionType='cancel';}
        for(CreateWaitlistQuoteWrapper assst:lstclsCreateWaitlistQuoteWrapper){
            Integer qtty=0;
            string pcode = 'COBROKE';
            if(assst.ProductCode!=null){pcode=assst.ProductCode;}
            mapAssetIDDocumentNumber.put(assst.uniqueRecordId,iiii);
            if(assst.Quantity!=null){qtty =Integer.valueof(assst.Quantity);}
            body = body+'<bm:partItem>';
            body = body+'<bm:part>'+pcode+'</bm:part>';
            body = body+' <bm:quantity>'+qtty+'</bm:quantity>';
            body = body+'<bm:priceEffectiveDate_line>'+assst.priceEffectiveDate +'</bm:priceEffectiveDate_line>';
                      if(inventorypool!=null){
                        System.debug('inventorypool===>'+inventorypool);
                        body = body + '<bm:invPool_line>'+inventorypool+'</bm:invPool_line>';
                      }
            body = body+'<bm:price_book_var_name>_default_price_book</bm:price_book_var_name>';
            body = body+'<bm:lineType_line>add</bm:lineType_line>';
            body = body+'<bm:campaignId_line></bm:campaignId_line>';
            body = body+'</bm:partItem>';
            iiii++;
        }
        body = body+'</bm:items>';
        body = body+'<bm:transaction>';
        body = body+'<bm:process_var_name>oraclecpqo</bm:process_var_name>';
        body = body+'<bm:quoteType_quote>'+quoteType+'</bm:quoteType_quote>';
        if(AccountId!=null && AccountId!=''){
        body = body+'<bm:_customer_id>'+AccountId+'</bm:_customer_id>';
        }
       /* if(lineActionType=='CFBQuote'){
          String  QueryCFB = 'Select id,order.AccountId,Order.Oracle_Quote__r.Name,';
            QueryCFB += 'Order.EffectiveDate from OrderItem where Order.Account.Type=\'Realtor Agent\' and Order.Status=\'Complete\' and Line_Type__c =\'Renew\'' ;
             QueryCFB += '  and Order.EffectiveDate=Today and Order.Fulfillment_Status__c=\'Fulfilled\' and PricebookEntry.Product2.productCode=\'COBROKE\' and Order.AccountId=:AccountId' ;
             List<OrderItem> sobjList1 = Database.query(QueryCFB);
      String Quotenum='';
      for(OrderItem ast:sobjList1){
       Quotenum = ast.Order.Oracle_Quote__r.Name;
      }
          body = body+'<bm:parentQuoteNumber_quote>'+Quotenum+'</bm:parentQuoteNumber_quote>';
          }*/
        
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
        System.debug('---------Request Body Create----------'+req.getBody());
        Http http = new Http();
        String createdqouteId = '';
        try {
            if(!Test.isRunningTest()){
            //Execute web service call here
            HTTPResponse res = http.send(req);

            String docc = res.getBody();
            System.debug('Testing 1 '+docc);
            Dom.Document doc = res.getBodyDocument();
            System.debug('Testing 2 '+doc);
            Dom.XMLNode envelope = doc.getRootElement();
            System.debug('Testing 3 '+envelope);
            Dom.XMLNode resbody = envelope.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
             System.debug('Testing 4 '+resbody);
            Dom.XMLNode createTransactionRes= resbody.getChildElement('createTransactionResponse', 'urn:soap.bigmachines.com');
            System.debug('$$$$$$$'+createTransactionRes);
            Dom.XMLNode trans= createTransactionRes.getChildElement('transaction', 'urn:soap.bigmachines.com');
            Dom.XMLNode tid= trans.getChildElement('id', 'urn:soap.bigmachines.com');
            tidd = tid.getText();
             if(lineActionType!='CFBQuote'){
            mapQuoteAccountWebservice.put(AccountId,tidd);
            }
            newtidd = UpdateBigMachineQuoteWaitlist(tid.getText(),'cleanSave_t');
          /*  if(mapQuoteAccountWebservice.containskey(AccountId)){
          body = body+'<bm:parentQuoteNumber_quote>'+mapQuoteAccountWebservice.get(AccountId)+'</bm:parentQuoteNumber_quote>';
          }*/
             if(lineActionType=='CFBQuote'){
             if(RequestResult!='' && mapQuoteAccountWebservice.values().size()>0){
            RequestResult = '';
            newtidd = UpdateBigMachineQuoteWaitlist(tid.getText(),'addBundleProsoft_t');
            }
            if(RequestResult!=''){
              RequestResult = '';
            newtidd = UpdateBigMachineQuoteWaitlist(tid.getText(),'cleanSave_t');
            System.debug('KKKKKKKK'+newtidd);
            }
             }
            if(RequestResult!='' && lineActionType!='CFBQuote'){
              RequestResult = '';
            newtidd = UpdateBigMachineQuoteWaitlist(tid.getText(),'_update_line_items');
            System.debug('KKKKKKKK'+newtidd);
            }
            if(RequestResult!='' && lineActionType!='CFBQuote'){
              RequestResult = '';
            newtidd = UpdateBigMachineQuoteWaitlist(tid.getText(),'cleanSave_t');
            System.debug('KKKKKKKK'+newtidd);
            }
            if(RequestResult!='' && mapQuoteAccountWebservice.values().size()>0 && lineActionType!='CFBQuote'){
            RequestResult = '';
            newtidd = UpdateBigMachineQuoteWaitlist(tid.getText(),'addBundleProsoft_t');
            }
            if(RequestResult!='' && lineActionType!='CFBQuote'){
              RequestResult = '';
            newtidd = UpdateBigMachineQuoteWaitlist(tid.getText(),'cleanSave_t');
            }
            System.debug('KKKKKKKK'+newtidd);
            if(autoprocess==true && lineActionType=='CFBQuote'){
              if(RequestResult!=''){
              RequestResult = '';
              newtidd = UpdateBigMachineQuoteWaitlist(tid.getText(),'calculateTax');
              }
              if(RequestResult!=''){
              RequestResult = '';
              newtidd = UpdateBigMachineQuoteWaitlist(tid.getText(),'submit_t');
              }
            //UpdateBigMachineQuote(tid.getText(),'calculateTax');
            //UpdateBigMachineQuote(tid.getText(),'submit_t');
            }
            createdqouteId = [Select id,name,BigMachines__Transaction_Id__c from BigMachines__Quote__c where BigMachines__Transaction_Id__c=:newtidd].id;
            SFCreatedQuoteId = createdqouteId;
            } else {
            tidd = '34453453';
            createdqouteId = '1234567890';
            }
        } catch(System.CalloutException ex) {
             Error__c error = new Error__c();
        error.Name = 'WebserviceBigmachineQuoteUpdate'+quoteType;
        error.Entity_Id__c = 'For : ' + tidd;
        error.Interface_Name__c = 'WebserviceBigmachineQuoteUpdate';
        string exceptionMsg = '';
        if( ex != null ){
            CPQReturnedMsg = ex.getMessage();
            exceptionMsg = '.------- Exception: ' + ex.getMessage() + '------StackTraceString: ---' + ex.getStackTraceString();
        }
        error.Error_Description__c = 'failedRecordIds: = '+BMQuoteId+ ''+tidd + exceptionMsg;
        insert error;

        }
        System.debug('KKKKKKKK'+createdqouteId);
        return [Select id,name,BigMachines__Transaction_Id__c from BigMachines__Quote__c where BigMachines__Transaction_Id__c=:newtidd].id;

        //  return UpdateBigMachineQuote(tidd,'submit_t');
    }

    Public String UpdateBigMachineQuote(String tId,String atype){
        HttpRequest req = new HttpRequest();
        req.setTimeout(120000); // CRM-4127 - Changed Timeout value to 120000 from 80000    
        //Set HTTPRequest Method
        req.setMethod('POST');
        req.setEndpoint('https://'+BMInstance+'.bigmachines.com/v1_0/receiver');
        //Set the HTTPRequest body
        String   body = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">';
        body = body+'<soapenv:Header>';
        body = body+'<bm:userInfo xmlns:bm="urn:soap.bigmachines.com">';
        body = body+'<bm:sessionId>'+bmsessionid+'</bm:sessionId>';
        body = body+'</bm:userInfo>';
        body = body+'<bm:category xmlns:bm="urn:soap.bigmachines.com">Commerce</bm:category>';
        body = body+'<bm:xsdInfo xmlns:bm="urn:soap.bigmachines.com">';
        body = body+'<bm:schemaLocation>'+BMUrl +'/schema/v1_0/commerce/oraclecpqo.xsd</bm:schemaLocation>';
        body = body+'</bm:xsdInfo>';
        body = body+'</soapenv:Header>';
        body = body+'<soapenv:Body>';
        body = body+'<bm:updateTransaction xmlns:bm="urn:soap.bigmachines.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
        body = body+'<bm:transaction>';
        body = body+'<bm:id>'+Integer.valueof(tId)+'</bm:id>';
        body = body+'<bm:process_var_name>oraclecpqo</bm:process_var_name>';
        body = body+'<bm:buyer_company_name>'+BMInstance+'</bm:buyer_company_name>';
        body = body+'<bm:supplier_company_name>'+BMInstance+'</bm:supplier_company_name>';
        //body = body+'<bm:step_var_name/>';
        if(autoprocess==true){
        body = body+'<bm:skipAuthorization_quote>true</bm:skipAuthorization_quote>';
        } else {
        body = body+'<bm:skipAuthorization_quote>false</bm:skipAuthorization_quote>';
        }
        if(suppressdocusign){
            body = body+'<bm:suppressDocuSign_quote>true</bm:suppressDocuSign_quote>';
        }
        body = body+'<bm:last_document_number>1</bm:last_document_number>';
        //body = body+'<bm:date_added>2015-07-04 21:26:32</bm:date_added>';
        //body = body+'<bm:date_modified>2015-07-04 21:26:32</bm:date_modified>';
        body = body+'<bm:data_xml>';
        body = body+'<bm:transaction bm:bs_id="'+Integer.valueof(tId)+'" bm:buyer_company_name="'+BMInstance+'" bm:buyer_user_name="'+BMUserName+'" bm:currency_pref="USD" bm:data_type="0" bm:document_name="Transaction" bm:document_number="1" bm:document_var_name="transaction" bm:process_var_name="oraclecpqo" bm:supplier_company_name="'+BMInstance+'">';
        body = body+'<bm:_document_number>1</bm:_document_number>';
        if(opportunityID!=null && opportunityID!=''){
        body = body+'<bm:opportunityID_t>'+opportunityID+'</bm:opportunityID_t>';
        }
        body = body+'<bm:status_t>In Progress</bm:status_t>';
        //body = body+'<bm:lineType_line>Modify</bm:lineType_line>';
        if(autoprocess==true){
        body = body+'<bm:skipAuthorization_quote>true</bm:skipAuthorization_quote>';
        } else {
             if(suppressauthrisation){
            body = body+'<bm:skipAuthorization_quote>true</bm:skipAuthorization_quote>';
        } else {
        body = body+'<bm:skipAuthorization_quote>false</bm:skipAuthorization_quote>';
             }
        }
        if(suppressdocusign){
            body = body+'<bm:suppressDocuSign_quote>true</bm:suppressDocuSign_quote>';
        }

        body = body+'<bm:version_t>1</bm:version_t>';
        body = body+'<bm:bs_id>'+Integer.valueof(tId)+'</bm:bs_id>';
        String promotion = '';
            //if(assst.Promotion__c!=null){promotion=assst.Promotion__c;}
        if(AccountId!=null && AccountId!=''){
        body = body+'<bm:_customer_id>'+AccountId+'</bm:_customer_id>';
        }
        
        body = body+'<bm:owner_t>'+QuoteOwnerName+'</bm:owner_t>';
        body = body+'<bm:quoteOwnerId_quote>'+QuoteownerId+'</bm:quoteOwnerId_quote>';
        body = body+'<bm:lastUpdatedBy_t>'+UserInfo.getFirstName()+' '+UserInfo.getLastName()+'</bm:lastUpdatedBy_t>';
        body = body+'<bm:version_number_versionTransaction_t>1</bm:version_number_versionTransaction_t>';
        //body = body+'<bm:quoteNumber_quote>2015-2594</bm:quoteNumber_quote>';
        body = body+'<bm:quoteType_quote>'+quoteType+'</bm:quoteType_quote>';
        //body = body+'<bm:quoteType_quote>Auto Renewal</bm:quoteType_quote>';
        //body = body+'<bm:stringOfAsset_quote>Product2.BigMachines__Part_Number__c,Quantity,Start_Date__c,End_Date__c,Status,Product2.Id,Price,Lead_Type__c,Product_Type__c,Market__c,Contract_Term__c,Billing_Period__c,Promotion__c,Discount_Type__c,Commerce_Group__c,Broker_Plan_Affiliation__c,Product_Email__c,Participants__c,License_Tier_Range__c,Top_Connector__c,Featured_Mortgage__c,HLC_Override__c</bm:stringOfAsset_quote>';
        body = body+'<bm:caseId>'+caseid+'</bm:caseId>';
        //body = body+'<bm:_price_quantity>1</bm:_price_quantity>';
        body = body+'<bm:sub_documents>';

        Map<Id,Asset> mapAllAssets = new Map<Id,Asset>([Select Grandfather_Plus_Percentage__c,Trial__c, Haircut_Asset__c,Spot_Promo_Code__c, CustResp_AR_Strategic_Promotion_code__c, CustResp_AR_Strategic_Promotion_age__c, 
                                                        Spot_Promo_Percentage__c, CustResp_List_Price__c, CustResp_Total_Net__c, CustResp_Renewal_Option__c,
                                                        CustResp_Contract_Term__c, CustResp_Promotion__c, CustResp_Promo_age__c, CustResp_Spot_Promotion__c,
                                                        CustResp_Spot_Promotion_age__c, CustResp_AppliesSpotPromo__c, CustResp_AutoOrder__c, Id,Asset_Number__c,
                                                        LastModifiedDate,Manual_Discount_Type__c,Last_Order_Activity_Date__c,
                                                        Last_Activity_Date__c,Category__c, CampaignId__c,Market_Code__c, Period_Start_Day__c ,Next_Charge_Date__c,
                                                        Renewal_Status__c,Price_Effective_Date__c,Manual_Discount_Amount__c,Override_Term__c,status ,
                                                        Term_Start_Date__c,Term_End_Date__c,Fulfillment_Status__c,HLC__c ,Manual_Override_Amount__c,
                                                        Name,Subscription_Id__c,ZuoraProductRatePlanId__c,Zoura_Id__c,Subscription_Start_Date__c,
                                                        Subscription_End_Date__c,Zoura_Product_Rate_Plan_Charge_Id__c,Start_Date__c,List_Price__c,
                                                        End_Date__c,Total_Net__c,Asset_Structure__c,Order_Line_Item__r.Asset_Structure__c,Product_Email__c,
                                                        Market_Tier__c,Featured_Mortgage__c,Extended_Net_Price__c,MSA_Tier__c,Suppress_Welcome_Calls__c,
                                                        Create_Broker_Tools__c,Broker_Plan_Affiliation__c,License_Tier__c,HLC_Override__c,Top_Connector__c,
                                                        Commerce_Group__c,Contract_Term__c,Billing_Period__c,Promotion__c,Discount_Type__c,
                                                        Total_List_Price__c,External_ID__c,Renewal_End_Date__c,Product2.ProductCode,
                                                        Product2.DefaultRenewalTerm__c,Quantity,Lead_Type__c,Product_Type__c,Market_Zip__c,Market__c,
                                                        Price,Renewal_Start_Date__c,PricePerImpressionSold__c,Monthly_Contracted_Units__c,
                                                        ConfigOptions__c,ResidentialLeadPPL__c ,ResidentialBrandPPL__c ,ResidentialAMLC__c ,
                                                        LandAMLC__c ,RentalAMLC__c ,ContractedAMLC__c ,DecommissionedAsset__c  ,AMLCOverride__c ,PPLOverride__c ,undersoldMarket__c,
                                                        Contractedimpressions__c, (select Market_Key__c,External_ID__c FROM Assets__r where Asset_Type__c = 'Fulfill To') from Asset where Accountid=:AccountId and Asset_Type__c='Parent' and Id=:setAssetIds  and Quantity>0]);
        AssetTriggerHelper ath = new AssetTriggerHelper();
        ath.GenerateJsonStrings(mapAllAssets);
        for(Asset assst:mapAllAssets.values()){
            Integer qtty=0;
            body = body+'<bm:transactionLine bm:bs_id="'+Integer.valueof(tId)+'" bm:buyer_company_name="'+BMInstance+'" bm:buyer_user_name="'+BMUserName+'" bm:currency_pref="USD" bm:data_type="3" bm:document_name="Transaction Line" bm:document_number="'+mapAssetIDDocumentNumber.get(assst.id)+'" bm:document_var_name="transactionLine" bm:process_var_name="oraclecpqo" bm:supplier_company_name="'+BMInstance+'">';
            body = body+'<bm:_document_number>'+mapAssetIDDocumentNumber.get(assst.id)+'</bm:_document_number>';
            if(assst.Promotion__c!=null){promotion=promotion+mapAssetIDDocumentNumber.get(assst.id)+'.!.'+assst.Promotion__c+'!!!';}
            if(assst.Quantity!=null){qtty =Integer.valueof(assst.Quantity);}
            String marketZip ='';
            String leadtype  ='';
            String producttype ='';
            Date renewalstartdate=System.today();
            Date renewalenddate=System.today().addMonths(6);
            String contractterm ='6';
            String prodemail='';
            String billingperiod='';
            String commercegrp='';
            String hlcoverride ='';
            String msaTier ='';
            Integer MarketTier = 0;
            Decimal assetpricee = 0.0;
            String cancelcpqvariable = '';
            marketZip='';
            string campaignId = '';
             if( assst.CampaignId__c != null && assst.CampaignId__c != '' ){
                campaignId = assst.CampaignId__c;
            }

            if(assst.Market__c!=null && assst.Market__c!=''){marketZip=assst.Market__c;}

            if(assst.Lead_Type__c!=null){ leadtype =assst.Lead_Type__c;leadtype = leadtype.remove(' Follow-up'); }
            if(assst.Product_Type__c!=null){ producttype =assst.Product_Type__c;}
            // Modified as part of Auto-Renewal
            if(quoteType== 'Auto-Renew') {contractterm= assst.Product2.DefaultRenewalTerm__c;}
            else if(assst.Contract_Term__c!=null){ contractterm =assst.Contract_Term__c;}
            if(assst.Start_Date__c!=null){ renewalstartdate=assst.Start_Date__c;}
            if(assst.End_Date__c!=null){ renewalenddate=assst.End_Date__c;}
            //if(assst.Contract_Term__c!=null){ contractterm =assst.Contract_Term__c;}
            if(assst.Product_Email__c!=null){ prodemail=assst.Product_Email__c;}
            if(assst.Billing_Period__c!=null){ billingperiod=assst.Billing_Period__c;

            }
            if(assst.Commerce_Group__c!=null){ commercegrp=assst.Commerce_Group__c.trim();
            //if(commercegrp=='Agent Marketing Solutions'){commercegrp='Agent Marketing Solution';}
            //Ravi CRM-1638 5/15/2017 Modified below If condition
            if(commercegrp=='Agent Marketing Solutions' || commercegrp=='Agent Marketing Solution'){commercegrp='';}
            if(commercegrp=='Broker Marketing Solutions'){commercegrp='Broker Marketing Solution';}
            if(commercegrp.length()<4){commercegrp='';}
            }
            if(assst.HLC_Override__c!=null){ hlcoverride=assst.HLC_Override__c+'';}
            if(assst.MSA_Tier__c!=null){ msaTier =assst.MSA_Tier__c;}
            //if(assst.Commerce_Group__c!=null){ commercegrp=assst.Commerce_Group__c;}
            if(assst.Market_Tier__c!=null){MarketTier = Integer.valueof(assst.Market_Tier__c);}
            if(assst.Total_Net__c!=null){assetpricee = assst.Total_Net__c;}
            if(lineActionType==null && quoteType=='Retention'){lineActionType='cancel';}
            if(quoteType=='Backout'){lineActionType='cancel';}
            if(quoteType!='Retention'){body = body+'<bm:lineType_line>'+lineActionType+'</bm:lineType_line>';}
            if(assst.Trial__c==true){body = body+'<bm:trial_line>'+assst.Trial__c+'</bm:trial_line>'; System.debug('Passing trial');} //CRM-3945
            //Started -  Added by Rajamohan - JIRA -ADVP 3329
            if(assst.ConfigOptions__c!=null){
              //Asset a = assst;
                String co = (assst.ConfigOptions__c+'').replace(' ','');
                String co1 = co.replace('ConfigOptions__c','');
                String co2 = co1.replace(';','~');
                System.debug(co2+'optionline');
                if(co2.length()>0){
                System.debug(co2+'optionline');
                body = body+'<bm:selectOption_line>'+co2+'</bm:selectOption_line>';
                }
               //body = body+'<bm:selectOption_line >Residential~Rental~Land</bm:selectOption_line >';

            }

            if(assst.ResidentialLeadPPL__c!=null){
                         body = body+'<bm:residentialLeadPPL_line>'+assst.ResidentialLeadPPL__c+'</bm:residentialLeadPPL_line>';
            }
            if(assst.ResidentialBrandPPL__c!=null){
                           body = body+'<bm:residentialBrandPPL_line>'+assst.ResidentialBrandPPL__c+'</bm:residentialBrandPPL_line>';
            }
            if(assst.ResidentialAMLC__c!=null){
                          body = body+'<bm:residentialALC_line>'+assst.ResidentialAMLC__c+'</bm:residentialALC_line>';
            }
            if(assst.LandAMLC__c!=null){
                           body = body+'<bm:landALC_line>'+assst.LandAMLC__c+'</bm:landALC_line>';
            }
            if(assst.RentalAMLC__c!=null){
                          body = body+'<bm:rentalALC_line>'+assst.RentalAMLC__c+'</bm:rentalALC_line>';
            }
            if(assst.ContractedAMLC__c!=null){
                        body = body+'<bm:contractedALC_line>'+assst.ContractedAMLC__c+'</bm:contractedALC_line>';
            }
            if(assst.DecommissionedAsset__c!=null){
                        body = body+'<bm:decommissionedAssetID_line>'+assst.DecommissionedAsset__c+'</bm:decommissionedAssetID_line>';
            }
            if(assst.AMLCOverride__c!=null){
                        //Ravi 7/24 CRM-1961. The CPQ Attribute Variable name was incorrect causing the value not sent to CPQ.
                         //body = body+'<bm:AMLCOverride_line>'+assst.AMLCOverride__c+'</bm:AMLCOverride_line>';
                         body = body+'<bm:aMLCOverride_line>'+assst.AMLCOverride__c+'</bm:aMLCOverride_line>';
            }
            if(assst.PPLOverride__c!=null){
                          body = body+'<bm:PPLOverride_line>'+assst.PPLOverride__c+'</bm:PPLOverride_line>';
            }
            if(assst.undersoldMarket__c!=null){
                   //  if(quoteType!= 'Auto-Renew') {     body = body+'<bm:undersoldAsset_line>'+assst.undersoldMarket__c+'</bm:undersoldAsset_line>';}
           body = body+'<bm:undersoldAsset_line>'+assst.undersoldMarket__c+'</bm:undersoldAsset_line>';
            }
            if(assst.Product2.ProductCode == 'ADVANTAGE'){
                Double term =0.0 ;
                String pricingStringForAdvantage_line='';
                if (assst.Override_Term__c > 0){
                    term = assst.Override_Term__c;
                }
                else{
                    term = Double.valueOf(assst.Contract_Term__c);
                }
                if( assst.Billing_Period__c == 'Monthly'){
                      pricingStringForAdvantage_line  = assst.ConfigOptions__c +'$$'+assst.Total_List_Price__c/term+'$$'+0.0;
                 }
                 else{
                    pricingStringForAdvantage_line  = assst.ConfigOptions__c +'$$'+0.0+'$$'+assst.Total_List_Price__c/term;
                 }
                  body = body+'<bm:pricingStringForAdvantage_line>'+pricingStringForAdvantage_line+'</bm:pricingStringForAdvantage_line>';

            }


            //  Ended - Rajamohan - JIRA -ADVP 3329
            //body = body+'<bm:marketZip_line>'+marketZip+'</bm:marketZip_line>';
            body = body+'<bm:campaignId_line>'+campaignId+'</bm:campaignId_line>';
            if(assst.Cost_Per_Action__c!=null){body = body+'<bm:costPerAction_line>'+assst.Cost_Per_Action__c+'</bm:costPerAction_line>';}
            if(assst.PricePerImpressionSold__c != null){body = body+'<bm:pricePerImpressionSold_line>'+assst.PricePerImpressionSold__c+'</bm:pricePerImpressionSold_line>';}
            body = body+'<bm:forecastedLeads_line>'+assst.Monthly_Contracted_Units__c+'</bm:forecastedLeads_line>';
            body = body+'<bm:contractedImpressions_line>'+assst.Contractedimpressions__c+'</bm:contractedImpressions_line>';
            body = body+'<bm:assetID_l>'+assst.id+'</bm:assetID_l>';
            body = body+'<bm:assetNumber>'+assst.Asset_Number__c+'</bm:assetNumber>'; //Ravi CRM-1772 Add Asset Number to Line Item
            body = body+'<bm:leadType_line>'+leadtype +'</bm:leadType_line>';
            body = body+'<bm:productType_line>'+producttype+'</bm:productType_line>';
            //body = body+'<bm:assetPrice_line>'+assst.Price+'</bm:assetPrice_line>';
            body = body+'<bm:contractStartDate_l>'+renewalstartdate+'</bm:contractStartDate_l>';
            if(renewalenddate!=null){
            body = body+'<bm:contractEndDate_l>'+renewalenddate+'</bm:contractEndDate_l>';}
            else{
            body = body+'<bm:contractEndDate_l></bm:contractEndDate_l>';
            }
            body = body+'<bm:contractTerms_line>'+ contractterm +'</bm:contractTerms_line>';
            body = body+'<bm:billingPeriod_line>'+FindBillingPeriod(contractterm,billingperiod)+'</bm:billingPeriod_line>';
            if(quoteType== 'Auto-Renew') {
                String fExternalId = (assst.External_ID__c+'');
                if((assst.External_ID__c+'').contains('-PR1')){
                fExternalId = (assst.External_ID__c+'').replace('-PR1','');
                } else{
                    if(assst.Assets__r.size()>0){
                fExternalId = assst.Assets__r[0].External_ID__c ;
                    }
                }
                body = body+'<bm:externalID_line>'+fExternalId+'</bm:externalID_line>';
                
            }
            if(assst.Last_Order_Activity_Date__c!=null){
            body = body+'<bm:assetLastModifiedDate_line>'+(assst.Last_Order_Activity_Date__c+'').replace(' ','T')+'.000Z'+'</bm:assetLastModifiedDate_line>';
            } else {
            if(quoteType!= 'Auto-Renew') {body = body+'<bm:assetLastModifiedDate_line>'+(assst.LastModifiedDate+'').replace(' ','T')+'.000Z'+'</bm:assetLastModifiedDate_line>';
            }
            }
            String renewalStatus='';
            if(assst.Renewal_Status__c!=null){renewalStatus=assst.Renewal_Status__c;}
            body = body+'<bm:renewalStatus_line>'+renewalStatus+'</bm:renewalStatus_line>';
            String mdiscounttype = (assst.Manual_Discount_Type__c != null ? assst.Manual_Discount_Type__c : '');
            if(mdiscounttype!=null){mdiscounttype = mdiscounttype.replace(' ','');if(mdiscounttype=='$'){mdiscounttype='Amt';}}
            
            //CRM-2627
            body = body+'<bm:spotDiscount_line>'+(assst.Spot_Promo_Code__c != null ? assst.Spot_Promo_Code__c : '')+'</bm:spotDiscount_line>';
            body = body+'<bm:spotDiscountPercent_line>'+(assst.Spot_Promo_Percentage__c != null ? assst.Spot_Promo_Percentage__c.format() : '')+'</bm:spotDiscountPercent_line>';
            
            if(quoteType!= 'Auto-Renew') {if(mdiscounttype!=null && mdiscounttype!=''){body = body+'<bm:discountType_line>'+mdiscounttype+'</bm:discountType_line>';}}
            //body = body+'<bm:discountType_line>'+(assst.Manual_Discount_Type__c != null ? assst.Manual_Discount_Type__c : '')+'</bm:discountType_line>';
            body = body+'<bm:commerceGroup_line>'+FormatString(commercegrp)+'</bm:commerceGroup_line>';
            body = body+'<bm:productEmail_line>'+prodemail+'</bm:productEmail_line>';
            //body = body+'<bm:licenseTier_line>'+assst.License_Tier__c+'</bm:licenseTier_line>';
            body = body+'<bm:topConnector_line>'+assst.Top_Connector__c+'</bm:topConnector_line>';
            body = body+'<bm:featuredMortgage_line>'+assst.Featured_Mortgage__c+'</bm:featuredMortgage_line>';
            body = body+'<bm:mSATier_line>'+msaTier+'</bm:mSATier_line>';
            body = body+'<bm:hlcOverride_line>'+hlcoverride+'</bm:hlcOverride_line>';
            String licensetier='';
            if(assst.License_Tier__c != null){licensetier = assst.License_Tier__c+''; }
            body = body+'<bm:license_line>'+licensetier+'</bm:license_line>';
            //body = body+'<marketId_line label="Market Id">77449@@TX@@COBROKE@@POSTALCODE@@FULL</marketId_line>';
            if(quoteType!= 'Auto-Renew') {body = body + '<bm:assetPrice_line>'+assetpricee+'</bm:assetPrice_line>';}
            body = body+'<bm:assetFlag_l>true</bm:assetFlag_l>';
            body = body+'<bm:marketType_line/>';
            if(assst.Asset_Structure__c!=null){ //body = body+'<bm:assetStructure_line>'+assst.Asset_Structure__c+'</bm:assetStructure_line>';
            body = body+'<bm:originalAssetStructure_line>'+assst.Asset_Structure__c+'</bm:originalAssetStructure_line>';
            }
            body = body+'<bm:priceTier_line>'+MarketTier+'</bm:priceTier_line>';
            body = body+'<bm:accountCategory_line>'+(assst.Category__c != null ? assst.Category__c +'' : '')+'</bm:accountCategory_line>';
            body = body+'<bm:override_line>'+(assst.Manual_Discount_Amount__c != null ? assst.Manual_Discount_Amount__c : 0.0)+'</bm:override_line>';
            body = body+'<bm:hLC_line>'+(assst.HLC__c != null ? assst.HLC__c +'' : '')+'</bm:hLC_line>';
            body = body+'<bm:marketCode_line>'+(assst.Market_Code__c != null ? assst.Market_Code__c +'' : '')+'</bm:marketCode_line>';
            body = body+'<bm:marketZip_line>'+ marketZip +'</bm:marketZip_line>';
            body = body+'<bm:suppressWelcomeCalls_line>'+assst.Suppress_Welcome_Calls__c+'</bm:suppressWelcomeCalls_line>';
            body = body+'<bm:priceEffectiveDate_line/>';
            if(quoteType!= 'Auto-Renew') {
                if(assst.List_Price__c==null){assst.List_Price__c=0.0;}
                if(assst.List_Price__c!=null){body = body+'<bm:assetListPrice_line>'+assst.List_Price__c.setscale(4,RoundingMode.DOWN)+'</bm:assetListPrice_line>';}
            }
            if(quoteType=='Retention'){
            String retentionString = mapAssetLineAction.get(assst.id);
            List<String> lstRetentionString = retentionString.split('##');
            if(!retentionString.contains('$$')){
            system.debug('lstRetentionString ------'+lstRetentionString);
            //Ravi 7/24/2017 Updated the below code to enhance Cancellation Reporting CRM-1833
            if (lstRetentionString.size()>1)
            {
                if(lstRetentionString[1]==null){lstRetentionString[1] = 'customerRequest';}
                body = body+'<bm:cancellationReason_line>'+lstRetentionString[1]+'</bm:cancellationReason_line>';
                //Ravi 7/24/2017 Updated the below code to enhance Cancellation Reporting CRM-1833
                if (lstRetentionString.size()>2)
                {
                    body = body+'<bm:appliedReasons_line>'+lstRetentionString[2]+'</bm:appliedReasons_line>';
                }
            }
            }
            if(retentionString.contains('$$')){
            if(lstRetentionString[0]==null){lstRetentionString[0]='amend';}
            if(lstRetentionString[0]!=null){
            if(lstRetentionString[0].equalsIgnoreCase('Credit')){
            lstRetentionString[0]='amend';
            }
            }
            body = body+'<bm:lineType_line>'+lstRetentionString[0]+'</bm:lineType_line>';}
            else {body = body+'<bm:lineType_line>cancel</bm:lineType_line>';}
            } else {
            if(quoteType=='Backout'){
            //Ravi 7/24/2017 Updated the below code to enhance Cancellation Reporting CRM-1833
            //body = body+'<bm:cancellationReason_line>convertToCoShow</bm:cancellationReason_line>';
            body = body+'<bm:cancellationReason_line>productIssue</bm:cancellationReason_line>';
            body = body+'<bm:appliedReasons_line>Moved Under Broker/Team Product</bm:appliedReasons_line>';
            }
            //Ravi 5/16/2017 Turbo Auto Cancellation Quotes failing to submit Modified below if condition to include product code != Turbo
            //if(quoteType=='Modify' && lineActionType =='cancel'){
            if(quoteType=='Modify' && lineActionType =='cancel' && assst.Product2.ProductCode != 'TURBO'){
            body = body+'<bm:cancellationReason_line>medicalIssues</bm:cancellationReason_line>';
            }
            if(quoteType=='Modify' && lineActionType =='cancel' && assst.Product2.ProductCode == 'TURBO'){
            //Ravi 7/24/2017 Updated the below code to enhance Cancellation Reporting CRM-1833
            //body = body+'<bm:cancellationReason_line>productPerformance</bm:cancellationReason_line>';
            body = body+'<bm:cancellationReason_line>productIssue</bm:cancellationReason_line>';
            body = body+'<bm:appliedReasons_line>No Active Listings</bm:appliedReasons_line>';
            }
            //body = body+'<bm:lineType_line>'+lineActionType+'</bm:lineType_line>';
            }
            //<bm:bundleID_line/>
            //<bm:invTransactionID_line/>
            body = body+'<bm:createBrokerTools_line>'+assst.Create_Broker_Tools__c+'</bm:createBrokerTools_line>';
            String zouraSubscriptionStartDate = assst.Term_Start_Date__c!= null ? (assst.Term_Start_Date__c+'') : '';
            body = body+'<bm:subscriptionStartDate_line>'+zouraSubscriptionStartDate+'</bm:subscriptionStartDate_line>';
            String zouraSubscriptionEndDate = assst.Subscription_End_Date__c != null ? (assst.Subscription_End_Date__c+'') : '';
            body = body+'<bm:subscriptionEndDate_line>'+zouraSubscriptionEndDate+'</bm:subscriptionEndDate_line>';
            String zouraproductRatePlanChargeId = assst.Zoura_Product_Rate_Plan_Charge_Id__c != null ? (assst.Zoura_Product_Rate_Plan_Charge_Id__c+'') : '';
            body = body+'<bm:zuoraProductRatePlanChargeID_line>'+zouraproductRatePlanChargeId+'</bm:zuoraProductRatePlanChargeID_line>';
            String zouraproductRatePlanId = assst.ZuoraProductRatePlanId__c != null ? (assst.ZuoraProductRatePlanId__c+'') : '';
            body = body+'<bm:zuoraRatePlanID_line>'+zouraproductRatePlanId+'</bm:zuoraRatePlanID_line>';
            String zourasubscriptionId = assst.Subscription_Id__c != null ? (assst.Subscription_Id__c+'') : '';
            body = body+'<bm:zuoraSubscriptionID_line>'+zourasubscriptionId+'</bm:zuoraSubscriptionID_line>';
            String zouraId = assst.Zoura_Id__c != null ? (assst.Zoura_Id__c+'') : '';
            body = body+'<bm:zuoraAmendmentID_line>'+zouraId+'</bm:zuoraAmendmentID_line>';
            //Modified for Auto-Renewal Project
            if(quoteType != 'Auto-Renew') {
                body = body+'<bm:listPriceOverride_line>'+(assst.Manual_Override_Amount__c!= null ? assst.Manual_Override_Amount__c+'' : '')+'</bm:listPriceOverride_line>';
            }
            //body = body+'<bm:assetDetails_line>#'+assst.Product2.ProductCode+'#'+Integer.valueof(assst.Quantity)+'#'+assetpricee+'#'+assst.id+'#'+(assst.Start_Date__c+'').replace(' 00:00:00','')+'#'+(assst.End_Date__c+'').replace(' 00:00:00','')+'#'+leadtype +'#'+producttype+'#'+marketZip+'#'+contractterm+'#'+billingperiod+'#'+(assst.Promotion__c != null ? assst.Promotion__c : '')+'#'+(assst.Discount_Type__c != null ? assst.Discount_Type__c : '')+'#'+(assst.Commerce_Group__c != null ? assst.Commerce_Group__c : '')+'#'+(assst.Broker_Plan_Affiliation__c != null ? assst.Broker_Plan_Affiliation__c : '')+'</bm:assetDetails_line>';
           body = body+'<bm:assetDetails_line>#'+assst.Product2.ProductCode+'#'+Integer.valueof(assst.Quantity)+'#'+assetpricee+'#'+assst.id+'#';
            body = body+(assst.Start_Date__c+'').replace(' 00:00:00','')+'#'+(assst.End_Date__c+'').replace(' 00:00:00','')+'#'+leadtype +'#'+producttype+'#';
            body = body+marketZip+'#'+contractterm+'#'+billingperiod+'#'+FormatString(assst.Promotion__c != null ? assst.Promotion__c : '')+'#';
            body = body+(assst.Discount_Type__c != null ? assst.Discount_Type__c : '')+'#'+FormatString(assst.Commerce_Group__c != null ? assst.Commerce_Group__c : '')+'#';
            body = body+FormatString(assst.Broker_Plan_Affiliation__c != null ? assst.Broker_Plan_Affiliation__c : '')+'#'+(assst.Product_Email__c != null ? assst.Product_Email__c : '');
            body = body+'#'+(assst.Participants__c != null ? assst.Participants__c : '')+'#'+(assst.License_Tier_Range__c != null ? assst.License_Tier_Range__c : '');
            body = body+'#'+(assst.Top_Connector__c != null ? assst.Top_Connector__c+'' : '')+'#'+(assst.Featured_Mortgage__c != null ? assst.Featured_Mortgage__c+'' : '')+'#'+(assst.HLC_Override__c != null ? assst.HLC_Override__c+'' : '')+'#';//
            body = body+(assst.Status != null ? assst.Status : '')+'#'+(assst.Zoura_Product_Rate_Plan_Charge_Id__c != null ? assst.Zoura_Product_Rate_Plan_Charge_Id__c : '')+'#';
            body = body+(assst.Zoura_Id__c != null ? assst.Zoura_Id__c : '')+'#'+(assst.Subscription_Id__c != null ? assst.Subscription_Id__c : '')+'#';
            body = body+(assst.Market_Tier__c != null ? assst.Market_Tier__c+'' : '')+'#'+(assst.ZuoraProductRatePlanId__c != null ? assst.ZuoraProductRatePlanId__c : '')+'#';

            body = body+(assst.List_Price__c != null ? assst.List_Price__c +'' : '')+'#'+(assst.External_ID__c != null ? assst.External_ID__c : '')+'#';
            body = body+(assst.Term_Start_Date__c!= null ? assst.Term_Start_Date__c+'' : '')+'#'+(assst.Subscription_End_Date__c != null ? assst.Subscription_End_Date__c+'' : '')+'#';
            //(select External_ID__c FROM Assets__r where Asset_Type__c = 'Fulfill To')
            String fulfilltoExternalid = '';
            String MarketKeyfulfill = '';
            if(assst.Assets__r.size()>0){fulfilltoExternalid = assst.Assets__r[0].External_ID__c ;
            MarketKeyfulfill = assst.Assets__r[0].Market_Key__c;
            }

            body = body+(assst.HLC__c != null ? assst.HLC__c +'' : '')+'#';
            body = body+fulfilltoExternalid +'#';
            //body = body+(assst.Broker_Plan_Affiliation__c != null ? assst.Broker_Plan_Affiliation__c : '')+'#';
            body = body+(assst.Override_Term__c != null ? assst.Override_Term__c +'' : '')+'#'+(assst.License_Tier__c != null ? assst.License_Tier__c +'' : '')+'#';
            body = body+(assst.Manual_Discount_Amount__c != null ? assst.Manual_Discount_Amount__c+'' : '')+'#'+(assst.Manual_Discount_Type__c != null ? assst.Manual_Discount_Type__c : '%')+'#';
            body = body+(assst.Price_Effective_Date__c != null ? (assst.Price_Effective_Date__c +'').replace(' 00:00:00',''): '')+'#'+FormatString(MarketKeyfulfill)+'#';

            body = body+(assst.Renewal_Status__c != null ? assst.Renewal_Status__c : '')+'#'+(assst.Cost_Per_Action__c != null ? assst.Cost_Per_Action__c +'' : '')+'#';
            body = body+(assst.Manual_Override_Amount__c!= null ? assst.Manual_Override_Amount__c+'' : '')+'#';
            body = body+(assst.Period_Start_Day__c!= null ? (assst.Period_Start_Day__c +'').replace(' 00:00:00','') : '')+'#';
            body = body+(assst.Market_Code__c!= null ? assst.Market_Code__c+'' : '')+'#';
            body = body+(assst.Last_Order_Activity_Date__c!= null ? (assst.Last_Order_Activity_Date__c +'').replace(' 00:00:00','') : '')+'#';
            body = body+(assst.Term_End_Date__c!= null ? (assst.Term_End_Date__c +'').replace(' 00:00:00','') : '')+'#';
            body = body+(assst.Monthly_Contracted_Units__c!= null ? assst.Monthly_Contracted_Units__c+'' : '')+'#';
            body = body+(assst.Contractedimpressions__c!= null ? assst.Contractedimpressions__c+'' : '')+'#';
            body = body+(assst.CampaignID__c!= null ? assst.CampaignID__c+'' : '')+'#';
            body = body+(assst.PricePerImpressionSold__c!= null ? assst.PricePerImpressionSold__c+'' : '')+'#';
            body = body+(assst.undersoldMarket__c!= null ? assst.undersoldMarket__c+'' : '')+'#';
            body = body+(assst.Extended_Net_Price__c!= null ? assst.Extended_Net_Price__c+'' : '')+'#';
            body = body+(assst.Category__c != null ? assst.Category__c +'' : '')+'#';
            body = body+(assst.Asset_Number__c != null ? assst.Asset_Number__c +'' : '')+'#';                        
            body = body+(assst.CustResp_Contract_Term__c != null ? FormatString(assst.CustResp_Contract_Term__c +''):'')+'#'; //CRM-2390
            body = body+(assst.CustResp_List_Price__c != null ? FormatString(assst.CustResp_List_Price__c +''):'')+'#'; //CRM-2390
            body = body+(assst.CustResp_Promotion__c != null ? FormatString(assst.CustResp_Promotion__c +''):'')+'#'; //CRM-2390
            body = body+(assst.CustResp_Promo_age__c != null ? FormatString(assst.CustResp_Promo_age__c +''):'')+'#'; //CRM-2390
            body = body+(assst.CustResp_Spot_Promotion__c != null ? FormatString(assst.CustResp_Spot_Promotion__c +''):'')+'#'; //CRM-2390
            body = body+(assst.CustResp_Renewal_Option__c != null ? FormatString(assst.CustResp_Renewal_Option__c +''):'')+'#'; //CRM-2390
            body = body+(assst.CustResp_AutoOrder__c != null ? FormatString(assst.CustResp_AutoOrder__c +''):'')+'#'; //CRM-2390
            body = body+(assst.CustResp_AR_Strategic_Promotion_code__c != null ? FormatString(assst.CustResp_AR_Strategic_Promotion_code__c +''):'')+'#'; //CRM-2390
            body = body+(assst.CustResp_AR_Strategic_Promotion_age__c != null ? FormatString(assst.CustResp_AR_Strategic_Promotion_age__c +''):'')+'#'; //CRM-2390
            body = body+'#'; //CRM-2390 
            body = body+'#'; //CRM-2390 
            body = body+(assst.Spot_Promo_Code__c != null ? FormatString(assst.Spot_Promo_Code__c +''):'')+'#'; //CRM-2390
            body = body+(assst.Spot_Promo_Percentage__c != null ? FormatString(assst.Spot_Promo_Percentage__c +''):'')+'#'; //CRM-2390
            body = body+(assst.Haircut_Asset__c != null ? assst.Haircut_Asset__c +'':'')+'#'; //CRM-2716
            body = body+(assst.Grandfather_Plus_Percentage__c != null ? assst.Grandfather_Plus_Percentage__c +'':'')+'#'; //Added by Ravi to pass Grandfather Plus Percentage in Asset Details CRM-3880
            //body = body+'';Haircut_Asset__c
            body = body+'</bm:assetDetails_line>';
           // body = body+'</bm:partItem>';Next_Charge_Date__c
            body = body+'</bm:transactionLine>';
        }

        body = body+'</bm:sub_documents>';
        body = body+'<bm:rule_data>';
        //Added FormatString function for Promotion by Ravi 8/15/2017 To fix the & character issue in Promo Description CRM-2089
        //body = body+'<bm:appliedPromotions_quote>'+promotion+'</bm:appliedPromotions_quote>';
        body = body+'<bm:appliedPromotions_quote>'+FormatString(promotion)+'</bm:appliedPromotions_quote>';
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
        body = body+'<bm:action_var_name>'+atype+'</bm:action_var_name>';
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
        Http http = new Http();

        try {
            if(!Test.isRunningTest()){
            //Execute web service call here
            HTTPResponse res = http.send(req);
            system.debug('----------------CPQ Response----------'+res.getBody());
            //String doc = res.getBody();

            Dom.Document doc = res.getBodyDocument();
            //Retrieve the root element for this document.
            // Dom.XMLNode address = doc.getRootElement();
            Dom.XMLNode envelope = doc.getRootElement();
            Dom.XMLNode resbody = envelope.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
            if(!(resbody+'').contains('faultcode')){
            Dom.XMLNode updateTransactionRes= resbody.getChildElement('updateTransactionResponse', 'urn:soap.bigmachines.com');
            Dom.XMLNode transtatus= updateTransactionRes.getChildElement('status', 'urn:soap.bigmachines.com');
            Dom.XMLNode tsuccess= transtatus.getChildElement('success', 'urn:soap.bigmachines.com');
            RequestResult = tsuccess.getText();
            System.debug(RequestResult+'Response time'+System.now());
            } else {
            CPQReturnedMsg =  (resbody+'');
            }

            //String name = address.getChildElement('name', null).getText();
            //String state = address.getChildElement('bm:id', null).getText();
            } else{
           // tId = '234234';
            }
        } catch(System.CalloutException ex) {
            //Exception handling goes here....
             Error__c error = new Error__c();
        error.Name = 'WebserviceBigmachineQuoteUpdate'+quoteType;
        error.Entity_Id__c = 'For : ' + tId;
        error.Interface_Name__c = 'WebserviceBigmachineQuoteUpdate';
        string exceptionMsg = '';
        if( ex != null ){
            CPQReturnedMsg = ex.getMessage();
            exceptionMsg = '.------- Exception: ' + ex.getMessage() + '------StackTraceString: ---' + ex.getStackTraceString();
        }
        error.Error_Description__c = 'failedRecordIds: = '+BMQuoteId+ ' '+tId + exceptionMsg;
        insert error;
system.debug('----------------CPQReturnedMsg---------'+CPQReturnedMsg);

        }
        return tId;
    }

    Public String UpdateBigMachineQuoteWaitlist(String tId,String atype){

        HttpRequest req = new HttpRequest();
        req.setTimeout(120000); // CRM-4127 - Changed Timeout value to 120000 from 80000
        //Set HTTPRequest Method
        req.setMethod('POST');
        req.setEndpoint('https://'+BMInstance+'.bigmachines.com/v1_0/receiver');
        //Set the HTTPRequest body
        String   body = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">';
        body = body+'<soapenv:Header>';
        body = body+'<bm:userInfo xmlns:bm="urn:soap.bigmachines.com">';
        body = body+'<bm:sessionId>'+bmsessionid+'</bm:sessionId>';
        body = body+'</bm:userInfo>';
        body = body+'<bm:category xmlns:bm="urn:soap.bigmachines.com">Commerce</bm:category>';
        body = body+'<bm:xsdInfo xmlns:bm="urn:soap.bigmachines.com">';
        body = body+'<bm:schemaLocation>'+BMUrl +'/schema/v1_0/commerce/oraclecpqo.xsd</bm:schemaLocation>';
        body = body+'</bm:xsdInfo>';
        body = body+'</soapenv:Header>';
        body = body+'<soapenv:Body>';
        body = body+'<bm:updateTransaction xmlns:bm="urn:soap.bigmachines.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
        body = body+'<bm:transaction>';
        body = body+'<bm:id>'+Integer.valueof(tId)+'</bm:id>';
        body = body+'<bm:process_var_name>oraclecpqo</bm:process_var_name>';
        body = body+'<bm:buyer_company_name>'+BMInstance+'</bm:buyer_company_name>';
        body = body+'<bm:supplier_company_name>'+BMInstance+'</bm:supplier_company_name>';
        //body = body+'<bm:step_var_name/>';
        system.debug('My Value'+autoprocess);

        body = body+'<bm:last_document_number>1</bm:last_document_number>';
        //body = body+'<bm:date_added>2015-07-04 21:26:32</bm:date_added>';
        //body = body+'<bm:date_modified>2015-07-04 21:26:32</bm:date_modified>';
        body = body+'<bm:data_xml>';
        body = body+'<bm:transaction bm:bs_id="'+Integer.valueof(tId)+'" bm:buyer_company_name="'+BMInstance+'" bm:buyer_user_name="'+BMUserName+'" bm:currency_pref="USD" bm:data_type="0" bm:document_name="Transaction" bm:document_number="1" bm:document_var_name="transaction" bm:process_var_name="oraclecpqo" bm:supplier_company_name="'+BMInstance+'">';
        body = body+'<bm:_document_number>1</bm:_document_number>';
        System.debug('My OPP Id'+opportunityID);
        if(opportunityID!=null && opportunityID!=''){
        body = body+'<bm:opportunityID_t>'+opportunityID+'</bm:opportunityID_t>';
        }
        body = body+'<bm:status_t>In Progress</bm:status_t>';
        //body = body+'<bm:lineType_line>Modify</bm:lineType_line>';
        if(autoprocess==true){
        body = body+'<bm:skipAuthorization_quote>true</bm:skipAuthorization_quote>';
        } else {
        body = body+'<bm:skipAuthorization_quote>false</bm:skipAuthorization_quote>';
        }
        body = body+'<bm:version_t>1</bm:version_t>';
        body = body+'<bm:bs_id>'+Integer.valueof(tId)+'</bm:bs_id>';
        if(AccountId!=null && AccountId!=''){
        body = body+'<bm:_customer_id>'+AccountId+'</bm:_customer_id>';
        }

            if(QuoteownerName!=''){
        System.debug(lineActionType+'CCCCCC'+QuoteownerName);
        body = body+'<bm:owner_t>'+QuoteownerName+'</bm:owner_t>';
        } else {
        body = body+'<bm:owner_t>'+UserInfo.getUserName()+'</bm:owner_t>';
        }
        
        System.debug(mapQuoteAccountWebservice+'My Quote'+AccountId);
        //Map<Id,String> mapQuoteAccountWebservice = new Map<Id,String>();
        if(AccountId!=null){
        if(mapQuoteAccountWebservice.containskey(AccountId)){
          body = body+'<bm:parentQuoteNumber_quote>'+mapQuoteAccountWebservice.get(AccountId)+'</bm:parentQuoteNumber_quote>';
          }
        }
        if(quoteOwnerId!=''){
        body = body+'<bm:quoteOwnerId_quote>'+quoteOwnerId+'</bm:quoteOwnerId_quote>';
        } else {
            if(quoteType != 'Auto-Renew'){
        body = body+'<bm:quoteOwnerId_quote>'+UserInfo.getUserId()+'</bm:quoteOwnerId_quote>';
        }
        }
                System.debug('=== > Execute 2 === ');

        body = body+'<bm:lastUpdatedBy_t>'+UserInfo.getFirstName()+' '+UserInfo.getLastName()+'</bm:lastUpdatedBy_t>';
        body = body+'<bm:version_number_versionTransaction_t>1</bm:version_number_versionTransaction_t>';
        //body = body+'<bm:quoteNumber_quote>2015-2594</bm:quoteNumber_quote>';
        body = body+'<bm:quoteType_quote>'+quoteType+'</bm:quoteType_quote>';
        //body = body+'<bm:quoteType_quote>Auto Renewal</bm:quoteType_quote>';
        //body = body+'<bm:stringOfAsset_quote>Product2.BigMachines__Part_Number__c,Quantity,Start_Date__c,End_Date__c,Status,Product2.Id,Price,Lead_Type__c,Product_Type__c,Market__c,Contract_Term__c,Billing_Period__c,Promotion__c,Discount_Type__c,Commerce_Group__c,Broker_Plan_Affiliation__c,Product_Email__c,Participants__c,License_Tier_Range__c,Top_Connector__c,Featured_Mortgage__c,HLC_Override__c</bm:stringOfAsset_quote>';
        body = body+'<bm:caseId>'+caseid+'</bm:caseId>';
        System.debug('caseid===>'+caseid);
        //body = body+'<bm:_price_quantity>1</bm:_price_quantity>';
        body = body+'<bm:sub_documents>';

        System.debug('=== > Execute 1 === ');
        if(executeAutoRenewalUpdate!=null){
        if(executeAutoRenewalUpdate){
             System.debug('=== > Execute 3 === ');
            for(AutoRenewalQuoteLineWrapper arqw:updateAutoRenewalQuoteLineWrapper){
                 System.debug('=== > Execute 4 === ');
            body = body+'<bm:transactionLine bm:bs_id="'+Integer.valueof(tId)+'" bm:buyer_company_name="'+BMInstance+'" bm:buyer_user_name="'+BMUserName+'" bm:currency_pref="USD" bm:data_type="3" bm:document_name="Transaction Line" bm:document_number="'+arqw.BMDocumentNumber+'" bm:document_var_name="transactionLine" bm:process_var_name="oraclecpqo" bm:supplier_company_name="'+BMInstance+'">';
            body = body+'<bm:_document_number>'+arqw.BMDocumentNumber+'</bm:_document_number>';
            if(atype=='_update_line_items'){
            body = body+'<bm:billingPeriod_line>'+arqw.BillingType+'</bm:billingPeriod_line>';
            }
            body = body+'</bm:transactionLine>';
             System.debug('=== > Execute 5 === ');
            }
        }
        }
        If(executeAutoRenewalUpdate!=null){
        if(!executeAutoRenewalUpdate){
        for(CreateWaitlistQuoteWrapper assst:lstclsCreateWaitlistQuoteWrapper){
            System.debug('assst===>'+assst);

            Integer qtty=0;
            body = body+'<bm:transactionLine bm:bs_id="'+Integer.valueof(tId)+'" bm:buyer_company_name="'+BMInstance+'" bm:buyer_user_name="'+BMUserName+'" bm:currency_pref="USD" bm:data_type="3" bm:document_name="Transaction Line" bm:document_number="'+mapAssetIDDocumentNumber.get(assst.uniqueRecordId)+'" bm:document_var_name="transactionLine" bm:process_var_name="oraclecpqo" bm:supplier_company_name="'+BMInstance+'">';
            body = body+'<bm:_document_number>'+mapAssetIDDocumentNumber.get(assst.uniqueRecordId)+'</bm:_document_number>';
            if(assst.Quantity!=null){qtty =Integer.valueof(assst.Quantity);}
            String marketZip ='';
            String leadtype  ='';
            String producttype ='';
            Date renewalstartdate=System.today();
            Date renewalenddate=System.today().addMonths(6);
            String contractterm ='6';
            String prodemail='';
            String billingperiod='';
            String commercegrp='';
            String hlcoverride ='';
            String msaTier ='';
            Integer MarketTier = 0;
            //subbu modified
            if(assst.priceTier!=null){
               MarketTier = assst.priceTier;
            }
            Decimal assetpricee = 0.0;
            marketZip='';
            if(assst.MarketID!=null && assst.MarketID!=''){marketZip=assst.MarketID;}
            if(assst.LeadType!=null){ leadtype =assst.LeadType; }
            if(assst.productType!=null){ producttype =assst.productType;}
            //if(assst.Email!=null){ contractterm =assst.Contract_Term__c;}
            //if(assst.Start_Date__c!=null){ renewalstartdate=assst.Start_Date__c;}
            //if(assst.End_Date__c!=null){ renewalenddate=assst.End_Date__c;}
            if(assst.Term!=null){ contractterm =assst.Term+'';//renewalenddate=assst.End_Date__c;
            }
            if(assst.Email!=null){ prodemail=assst.Email;}
            billingperiod = 'Monthly';
            //if(assst.Billing_Period__c!=null){ billingperiod=assst.Billing_Period__c;}
            //if(assst.Commerce_Group__c!=null){ commercegrp=assst.Commerce_Group__c;}
            //if(assst.HLC_Override__c!=null){ hlcoverride=assst.HLC_Override__c+'';}
            //if(assst.MSA_Tier__c!=null){ msaTier =assst.MSA_Tier__c;}
            //if(assst.Commerce_Group__c!=null){ commercegrp=assst.Commerce_Group__c;}
            //if(assst.Market_Tier__c!=null){MarketTier = Integer.valueof(assst.Market_Tier__c);}
            //if(assst.Total_Net__c!=null){assetpricee = assst.Total_Net__c;}
            //if(lineActionType==null && quoteType=='Retention'){lineActionType='cancel';}
            //if(quoteType!='Retention'){body = body+'<bm:lineType_line>'+lineActionType+'</bm:lineType_line>';}
            //body = body+'<bm:marketZip_line>'+marketZip+'</bm:marketZip_line>';
            //body = body+'<bm:assetID_l>'+assst.id+'</bm:assetID_l>';
            body = body+'<bm:leadType_line>'+leadtype +'</bm:leadType_line>';
            body = body+'<bm:productType_line>'+producttype+'</bm:productType_line>';
            //body = body+'<bm:assetPrice_line>'+assst.Price+'</bm:assetPrice_line>';
            //body = body+'<bm:contractStartDate_l>'+renewalstartdate+'</bm:contractStartDate_l>';
            //body = body+'<bm:contractEndDate_l>'+renewalenddate+'</bm:contractEndDate_l>';
            body = body+'<bm:contractTerms_line>'+ contractterm +'</bm:contractTerms_line>';
            body = body+'<bm:billingPeriod_line>'+billingperiod+'</bm:billingPeriod_line>';
            body = body+'<bm:marketCode_line>'+(assst.MarketKey != null ? assst.MarketKey +'' : '')+'</bm:marketCode_line>';
            //body = body+'<bm:promotion_line>'+assst.Promotion__c+'</bm:promotion_line>';
            //body = body+'<bm:discountType_line>'+assst.Discount_Type__c+'</bm:discountType_line>';
            body = body+'<bm:commerceGroup_line>'+commercegrp+'</bm:commerceGroup_line>';
            body = body+'<bm:productEmail_line>'+prodemail+'</bm:productEmail_line>';
            //body = body+'<bm:licenseTier_line>'+assst.License_Tier__c+'</bm:licenseTier_line>';
            body = body+'<bm:topConnector_line>false</bm:topConnector_line>';
            body = body+'<bm:featuredMortgage_line>false</bm:featuredMortgage_line>';
            body = body+'<bm:mSATier_line>'+msaTier+'</bm:mSATier_line>';
            body = body+'<bm:hlcOverride_line>'+hlcoverride+'</bm:hlcOverride_line>';
            String licensetier='';
            //if(assst.License_Tier__c != null){licensetier = assst.License_Tier__c+''; }
            body = body+'<bm:license_line>'+licensetier+'</bm:license_line>';
            //body = body+'<marketId_line label="Market Id">77449@@TX@@COBROKE@@POSTALCODE@@FULL</marketId_line>';
            //subbu
            if(assst.MarketKey !=null){
               string MarketKey = assst.MarketKey.replace('|','@@');
               body = body+'<marketId_line label="Market Id">'+MarketKey+'</marketId_line>';
            }
            //subbu
            if(inventorypool!=''){
            body = body + '<bm:invPool_line>'+inventorypool+'</bm:invPool_line>';
            }
            body = body + '<bm:assetPrice_line>'+assetpricee+'</bm:assetPrice_line>';
            body = body+'<bm:assetFlag_l>true</bm:assetFlag_l>';
            body = body+'<bm:marketType_line/>';

            body = body+'<bm:priceTier_line>'+MarketTier+'</bm:priceTier_line>';
            body = body+'<bm:marketZip_line>'+ marketZip +'</bm:marketZip_line>';
            body = body+'<bm:suppressWelcomeCalls_line></bm:suppressWelcomeCalls_line>';
            body = body+'<bm:priceEffectiveDate_line>'+(assst.priceEffectiveDate != null ? assst.priceEffectiveDate +'' : '') +'</bm:priceEffectiveDate_line>';
            body = body+'<bm:assetListPrice_line>0.0</bm:assetListPrice_line>';
            body = body+'<bm:lineType_line>add</bm:lineType_line>';
            //body = body+'<bm:createBrokerTools_line>'+assst.Create_Broker_Tools__c+'</bm:createBrokerTools_line>';
            //String zouraSubscriptionStartDate = assst.Subscription_Start_Date__c != null ? (assst.Subscription_Start_Date__c+'') : '';
            //body = body+'<bm:subscriptionStartDate_line>'+zouraSubscriptionStartDate+'</bm:subscriptionStartDate_line>';
            //String zouraSubscriptionEndDate = assst.Subscription_End_Date__c != null ? (assst.Subscription_End_Date__c+'') : '';
            //body = body+'<bm:subscriptionEndDate_line>'+zouraSubscriptionEndDate+'</bm:subscriptionEndDate_line>';
            //String zouraproductRatePlanChargeId = assst.Zoura_Product_Rate_Plan_Charge_Id__c != null ? (assst.Zoura_Product_Rate_Plan_Charge_Id__c+'') : '';
            //body = body+'<bm:zuoraProductRatePlanChargeID_line>'+zouraproductRatePlanChargeId+'</bm:zuoraProductRatePlanChargeID_line>';
            //String zouraproductRatePlanId = assst.ZuoraProductRatePlanId__c != null ? (assst.ZuoraProductRatePlanId__c+'') : '';
            //body = body+'<bm:zuoraRatePlanID_line>'+zouraproductRatePlanId+'</bm:zuoraRatePlanID_line>';
            //String zourasubscriptionId = assst.Subscription_Id__c != null ? (assst.Subscription_Id__c+'') : '';
            //body = body+'<bm:zuoraSubscriptionID_line>'+zourasubscriptionId+'</bm:zuoraSubscriptionID_line>';
            //String zouraId = assst.Zoura_Id__c != null ? (assst.Zoura_Id__c+'') : '';
            //body = body+'<bm:zuoraAmendmentID_line>'+zouraId+'</bm:zuoraAmendmentID_line>';
            body = body+'<bm:assetDetails_line>#'+assst.ProductCode+'######'+leadtype +'#'+producttype+'#'+marketZip+'#'+contractterm+'##############</bm:assetDetails_line>';
           // body = body+'</bm:partItem>';
            body = body+'</bm:transactionLine>';
            System.debug('BODY == '+body);
        }
        }
        }

        body = body+'</bm:sub_documents>';
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
        body = body+'<bm:action_var_name>'+atype+'</bm:action_var_name>';
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
        system.debug('My body Value'+body);
        Http http = new Http();

        try {
            if(!Test.isRunningTest()){
            //Execute web service call here
            HTTPResponse res = http.send(req);
system.debug('----------------CPQ Response----------'+res.getBody());

            //String doc = res.getBody();
            Dom.Document doc = res.getBodyDocument();
            //Dom.Document doc = res.getBodyDocument();
            //Retrieve the root element for this document.
            // Dom.XMLNode address = doc.getRootElement();
            Dom.XMLNode envelope = doc.getRootElement();
            //Retrieve the root element for this document.
            //Dom.XMLNode address = doc.getRootElement();
            Dom.XMLNode resbody = envelope.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
            if(!(resbody+'').contains('faultcode')){
            Dom.XMLNode updateTransactionRes= resbody.getChildElement('updateTransactionResponse', 'urn:soap.bigmachines.com');
            Dom.XMLNode transtatus= updateTransactionRes.getChildElement('status', 'urn:soap.bigmachines.com');
            Dom.XMLNode tsuccess= transtatus.getChildElement('success', 'urn:soap.bigmachines.com');
            RequestResult = tsuccess.getText();
            } else {
CPQReturnedMsg =  (resbody+'');
if(CPQReturnedMsg.contains('The quote cannot be saved because a line item was added concurrently.')){
RequestResult = 'Success';
}
            }
            //String name = address.getChildElement('name', null).getText();
            //String state = address.getChildElement('bm:id', null).getText();
            }
        } catch(System.CalloutException ex) {
            //Exception handling goes here....
            Error__c error = new Error__c();
        error.Name = 'WebserviceBigmachineQuoteUpdate'+quoteType;
        error.Entity_Id__c = 'For : ' + tId;
        error.Interface_Name__c = 'WebserviceBigmachineQuoteUpdate';
        string exceptionMsg = '';
        if( ex != null ){
            CPQReturnedMsg = ex.getMessage();
            exceptionMsg = '.------- Exception: ' + ex.getMessage() + '------StackTraceString: ---' + ex.getStackTraceString();
        }
        error.Error_Description__c = 'failedRecordIds: = '+BMQuoteId+ ' '+tId + exceptionMsg;
        insert error;
        system.debug('----------------CPQReturnedMsg---------'+CPQReturnedMsg);
        }
        return tId;
    }
    Public String FormatString(String xmlText){
    String returnString='';
    if(xmlText!=null){
    if(xmlText.contains('&')){returnString=xmlText.replace('&','&amp;'); }
    if(xmlText.contains('<')){returnString=xmlText.replace('<','&lt;'); }
    if(xmlText.contains('>')){returnString=xmlText.replace('>','&gt;'); }
    if(xmlText.contains('"')){returnString=xmlText.replace('"','&quot;'); }
    if(xmlText.contains('~')){returnString=xmlText.replace('~','&#126;'); }
    if(xmlText.contains('|')){returnString=xmlText.replace('|','@@'); }
   // if(xmlText.contains('\'')){returnString=xmlText.replace('\'','&apos;'); }   //CRM-2760 - reverting 2760 CRM-2779
   // if(xmlText.contains('$')){returnString=xmlText.replace('$','&#36;'); }   //CRM-2760 - reverting 2760 CRM-2779
   // if(xmlText.contains('%')){returnString=xmlText.replace('%','&#37;'); }   //CRM-2760 - reverting 2760 CRM-2779
   // if(xmlText.contains(',')){returnString=xmlText.replace(',','&#44;'); }   //CRM-2760 - reverting 2760 CRM-2779
    if(returnString==''){returnString=xmlText;}
    }
    return returnString;
    }

    Public String FindBillingPeriod(String contractTerm,String BillingPeriod){
    if(BillingPeriod!='Monthly'){
    QuoteProductContractTerm__c conTerm = QuoteProductContractTerm__c.getInstance(contractTerm);
    if(conTerm!=null){
    BillingPeriod = conTerm.Term__c;
    }
    }
    return BillingPeriod;
    }

    Public class AutoRenewalQuoteLineWrapper{
    Public String BMDocumentNumber{get;set;}
    Public String BMActionRequired{get;set;} //Delete,Update
    Public String BillingType{get;set;}
    }        


    // CRM-2198 Start - Send Quote DocuSign
    webservice static string SendQuoteDocuSign(String transactionId, String action) { 
        String returnStr = 'BM URLs are not set';
        BigMachineUrls__c BMUrls= BigMachineUrls__c.getValues('BM');
        if (BMUrls != null) {
            try {
                WebserviceCallBigMachineQuoteCls wbs = new WebserviceCallBigMachineQuoteCls();
                String seess = wbs.GetSessionId(null,null);
                String BMUserName = BMUrls.DefaultUserName__c;
                String BMUserPassword = BMUrls.DefaultPassword__c;
                String BMUrl = BMUrls.Bigmachine_Url__c;
                String BMSalesforceInstance = BMUrls.Salesforce_Instance__c;
                String BMInstance = BMUrls.BigmachineInstance__c;
            
                String body = '<?xml version="1.0" encoding="UTF-8"?>';
                body = body+'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">';
                body = body+'<soapenv:Header>';
                body = body+'<bm:userInfo xmlns:bm="urn:soap.bigmachines.com">';
                body = body+'<bm:sessionId>'+seess+'</bm:sessionId>';
                body = body+'</bm:userInfo>';
                body = body+'<bm:category xmlns:bm="urn:soap.bigmachines.com">Commerce</bm:category>';
                body = body+'<bm:xsdInfo xmlns:bm="urn:soap.bigmachines.com">';
                body = body+'<bm:schemaLocation>'+BMUrl +'/schema/v1_0/commerce/oraclecpqo.xsd</bm:schemaLocation>';
                body = body+'</bm:xsdInfo>';
                body = body+'</soapenv:Header>';
                body = body+'<soapenv:Body>';
                body = body+'<bm:updateTransaction xmlns:bm="urn:soap.bigmachines.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
                body = body+'<bm:transaction>';
                body = body+'<bm:id>' + transactionId + '</bm:id>';
                body = body+'<bm:process_var_name>oraclecpqo</bm:process_var_name>';
                body = body+'<bm:buyer_company_name>'+BMInstance+'</bm:buyer_company_name>';
                body = body+'<bm:supplier_company_name>'+BMInstance+'</bm:supplier_company_name>';
                body = body+'<bm:last_document_number>1</bm:last_document_number>';
                body = body+'<bm:data_xml>';
                body = body+'<bm:transaction bm:bs_id="'+transactionId + '" bm:buyer_company_name="'+BMInstance+'" bm:buyer_user_name="apiuser" bm:currency_pref="USD" bm:data_type="0" bm:document_name="Transaction" bm:document_number="1" bm:document_var_name="transaction" bm:process_var_name="oraclecpqo" bm:supplier_company_name="'+BMInstance+'">';
                body = body+'<bm:_document_number>1</bm:_document_number>';
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
                body = body+'<bm:buyer_user_name>apiuser</bm:buyer_user_name>';
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
                HttpRequest req = new HttpRequest();
                req.setTimeout(80000);
                req.setMethod('POST');
                req.setEndpoint('https://'+BMInstance+'.bigmachines.com/v1_0/receiver');
               
                req.setBody(body);
                System.debug('---------Request Body Update----------'+req.getBody());
                Http http = new Http();
                //Execute web service call here
                HTTPResponse res = http.send(req);
                system.debug('----------------CPQ Response----------'+res.getBody());
                
                returnStr = res.getBody();
                Dom.Document doc = res.getBodyDocument();
                Dom.XMLNode envelope = doc.getRootElement();
                Dom.XMLNode resbody = envelope.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
                Dom.XMLNode updateTransactionRes= resbody.getChildElement('updateTransactionResponse', 'urn:soap.bigmachines.com');
                Dom.XMLNode transtatus= updateTransactionRes.getChildElement('status', 'urn:soap.bigmachines.com');
                Dom.XMLNode tsuccess= transtatus.getChildElement('success', 'urn:soap.bigmachines.com');
                if (tsuccess.getText() == 'true') {
                    returnStr  = 'Docusign sent successfully.';
                }
            }
            catch (Exception e) {
                returnStr = 'Response - ' + returnStr + ' Exception -  ' + e.getMessage();
            }
        }
        return returnStr;
    }
    // CRM-2198  - End
}