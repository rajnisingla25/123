@isTest
private class ARIICPQCalls_Test{

public static testMethod void testWebserviceCallFunctionality6() {
        ARIICPQCalls.sessionRes ='<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><bm:loginResponse xmlns:bm="urn:soap.bigmachines.com"><bm:status><bm:success>true</bm:success><bm:message>Thu Nov 30 16:55:24 CST 2017 faultcode- Successfully processed API for qamoveinc</bm:message></bm:status><bm:userInfo><bm:sessionId>hHTmhgMbrp8fb5d7YWPsL2NDw7c9nhhKZGyFjXSqB2yJlTQhYTm6!626200874!1512082523946</bm:sessionId></bm:userInfo></bm:loginResponse></soapenv:Body></soapenv:Envelope>';
        ARIICPQCalls.updateTransactionRes = '<?xml version=\'1.0\' encoding=\'utf-8\'?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><bm:updateTransactionResponse xmlns:bm="urn:soap.bigmachines.com"><bm:status><bm:success>true</bm:success><bm:message>Tue Nov 07 08:19:54 CST 2017 faultcode- Successfully processed API for qamoveinc</bm:message></bm:status></bm:updateTransactionResponse></soapenv:Body></soapenv:Envelope>';

        ARIICPQCalls.createTransactionRes = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><bm:createTransactionResponse xmlns:bm="urn:soap.bigmachines.com"><bm:status><bm:success>true</bm:success><bm:message>Thu Nov 30 16:56:13 CST 2017 faultcode- Successfully processed API for qamoveinc</bm:message></bm:status><bm:transaction><bm:category>bm_cm_bs_data</bm:category><bm:action>add</bm:action><bm:id>107523155</bm:id><bm:process_var_name>oraclecpqo</bm:process_var_name><bm:buyer_company_name>qamoveinc</bm:buyer_company_name><bm:supplier_company_name>qamoveinc</bm:supplier_company_name><bm:step_var_name/><bm:last_document_number>1</bm:last_document_number><bm:date_added>2017-11-30 16:56:13</bm:date_added><bm:date_modified>2017-11-30 16:56:13</bm:date_modified><bm:data_xml><bm:transaction bm:bs_id="107523155" bm:buyer_company_name="qamoveinc" bm:buyer_user_name="ashoksontinenicontractor" bm:currency_pref="USD" bm:data_type="0" bm:document_name="Transaction" bm:document_number="1" bm:document_var_name="transaction" bm:process_var_name="oraclecpqo" bm:supplier_company_name="qamoveinc"><bm:_document_number>1</bm:_document_number><bm:obsolete_attributes><bm:__cm_bs_service_ignore_override>false</bm:__cm_bs_service_ignore_override><bm:__cm_bs_service_unsaved_data>false</bm:__cm_bs_service_unsaved_data><bm:__cm_bs_service_new_data>false</bm:__cm_bs_service_new_data><bm:_price_quantity>1</bm:_price_quantity></bm:obsolete_attributes><bm:approval_history/><bm:approval_status/><bm:sub_documents/><bm:rule_data><bm:totalAnnualValue_t bm:constrained="false" bm:hidden="true"/><bm:selectedFulfillToLineNums_quote bm:constrained="false" bm:hidden="true"/><bm:paymentAuthorization_quote bm:constrained="false" bm:hidden="true"/><bm:chooseLead bm:constrained="false" bm:hidden="true"/><bm:totalUsageFees_quote bm:constrained="false" bm:hidden="true"/><bm:totalMonthlyDiscount_t bm:constrained="false" bm:hidden="true"/><bm:authorizationAmount_quote bm:constrained="false" bm:hidden="true"/><bm:taxExemptReason_t bm:constrained="false" bm:hidden="true"/><bm:totalMonthlyNetAmount_t bm:constrained="false" bm:hidden="true"/><bm:authorizationDate_quote bm:constrained="false" bm:hidden="true"/><bm:paymentAuthorizationlabel_quote bm:constrained="false" bm:hidden="true"/><bm:hTMLErrorMessage_quote bm:constrained="false" bm:hidden="true"/><bm:selectedOfficeValue_t bm:constrained="false" bm:hidden="true"/><bm:totalMonthlyListAmount_t bm:constrained="false" bm:hidden="true"/><bm:specialAdvantagePricing_quote bm:constrained="false" bm:hidden="true"/><bm:prorationMessage_quote bm:constrained="false" bm:hidden="true"/><bm:estUsageTax_quote bm:constrained="false" bm:hidden="true"/></bm:rule_data></bm:transaction></bm:data_xml><bm:action_data><bm:action_var_name/><bm:_bm_cm_new_transaction_currency/><bm:performer_comment/><bm:reason_var_name/><bm:performer_name/><bm:performer_type/><bm:performer_company_name/></bm:action_data><bm:sub_step_name/><bm:buyer_user_name>ashoksontinenicontractor</bm:buyer_user_name><bm:currency_pref>USD</bm:currency_pref><bm:status>0</bm:status><bm:update_count>2</bm:update_count><bm:language_pref>English</bm:language_pref><bm:num_transitions>0</bm:num_transitions></bm:transaction></bm:createTransactionResponse></soapenv:Body></soapenv:Envelope>';
        BigMachineUrls__c bmUrl = new BigMachineUrls__c(Name = 'BM', BigmachineInstance__c = '', Bigmachine_Url__c = 'https://moveinc--dev.cs79.visual.force.com​', DefaultPassword__c = 'testPrice', DefaultUserName__c = 'testPrice@move.com', Parallel_Processing_User__c = True, Salesforce_Instance__c = 'https://moveinc--dev.cs79.visual.force.com​');
        insert bmUrl;
        
        MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
        mtduc.CreateBMURLSingle();
        mtduc.CreateDisabledTriggerSingle();
        mtduc.CreateBrokerAccountSingle();
        mtduc.CreateOppurtunitySingle();
        mtduc.CreateContactSingle();
        mtduc.CreateContractSingle();
        Product2 pt = mtduc.CreateProductSingle();
        mtduc.CreateOracleQuoteSingle();
        Asset ast = mtduc.CreateFullfilledAssetSingle();
        Map<Id,String> assetIds = new Map<Id,String>();
        Set<Id> asstId = new Set<Id>();
        List<CreateWaitlistQuoteWrapper> lstCreateWaitlistQuoteWrapper = new List<CreateWaitlistQuoteWrapper>();
        CreateWaitlistQuoteWrapper cwqw = new CreateWaitlistQuoteWrapper();
        lstCreateWaitlistQuoteWrapper.add(cwqw);
        assetIds.put(ast.id,'amend##customerRequest');
        asstId.add(ast.Id);
        ARIICPQCalls wcbmq = new ARIICPQCalls();
        ast.CampaignId__c = 'Testing';
        update ast;
        ARIICPQCalls.CreateQuote(mtduc.newAccount.id,mtduc.theOpportunity.id,assetIds);
        
        ARIICPQCalls.createBigMachineQuoteIncpq('34453453','ppp');
        //wcbmq.executeAutoRenewalUpdate= false;
        ARIICPQCalls.createBigMachineQuoteIncpq('34453453','ppp');
        ARIICPQCalls.tId = '34453453';
        ARIICPQCalls.AssetNightlyPriceUpdate(ARIICPQCalls.tId,'plainSave_t',asstId, 'Land');
        ARIICPQCalls.AssetNightlyPriceUpdate(ARIICPQCalls.tId,'autoRenewAssetExport',asstId, 'Land');
        
        pt.ProductCode = 'ADVANTAGE';
        update pt;
        ast.Commerce_Group__c = 'Broker Marketing Solutions';        
        ast.ConfigOptions__c = 'Residential';
        ast.Override_Term__c  = 3;
        ast.Billing_Period__c = 'Monthly';
        ast.Total_List_Price__c = 50;
        update ast;
        //wcbmq.autoprocess = true;
       // wcbmq.suppressdocusign = true;
       // wcbmq.executeAutoRenewalUpdate = true;
        ARIICPQCalls.createBigMachineQuoteIncpq('23423','ppp');       
        
        ast.Commerce_Group__c = 'Agent Marketing Solution';
        ast.ResidentialLeadPPL__c = 2;
        ast.ResidentialBrandPPL__c = 2;
        ast.ResidentialAMLC__c = 2;
        ast.LandAMLC__c = 2;
        ast.RentalAMLC__c = 2;
        ast.ContractedAMLC__c = 2;
        ast.AMLCOverride__c = 2;
        ast.PPLOverride__c = 2;
        ast.Override_Term__c = 0;
        ast.Contract_Term__c = '3';
        ast.Billing_Period__c = 'Quarterly'; 
        ast.Total_List_Price__c = 50;      
        update ast;
        
        Asset_AR_Association__c arAsst= new Asset_AR_Association__c();
            arAsst.Asset_Id__c = ast.Id;
            arAsst.AR_Config_Options__c = 'Land';
            arAsst.AR_Lead_PPL__c = 1;
            arAsst.AR_Brand_PPL__c = 1;
            arAsst.AR_AMLC_Residential__c = 1;
            arAsst.AR_AMLC_Land__c = 1;
            arAsst.AR_AMLC_Rental__c = 1;
            arAsst.AR_PPL_Override__c = 1;
            arAsst.External_ID__c = '1234-78979';
            arAsst.AR_Price_Info__c = '12^0.0^ASR_A/R_NewOrder_CBC10_Off^10.0^0.0^KWCBC25^10.0^0.0^0.0^0.0^0.0#';
            insert arAsst;
        //wcbmq.autoprocess = true;
        //wcbmq.suppressdocusign = true;
        //wcbmq.executeAutoRenewalUpdate = true;
        ARIICPQCalls.createBigMachineQuoteIncpq('23423','ppp');
          List<ARIICPQCalls.AutoRenewalQuoteLineWrapper> wraps = new List<ARIICPQCalls.AutoRenewalQuoteLineWrapper>();
        ARIICPQCalls.UpdateDeleteAutoRenewalQuote('23423',wraps);
    }
    Public static testMethod void testWebserviceCallFunctionality() {
        ARIICPQCalls.sessionRes ='<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><bm:loginResponse xmlns:bm="urn:soap.bigmachines.com"><bm:status><bm:success>true</bm:success><bm:message>Thu Nov 30 16:55:24 CST 2017 - Successfully processed API for qamoveinc</bm:message></bm:status><bm:userInfo><bm:sessionId>hHTmhgMbrp8fb5d7YWPsL2NDw7c9nhhKZGyFjXSqB2yJlTQhYTm6!626200874!1512082523946</bm:sessionId></bm:userInfo></bm:loginResponse></soapenv:Body></soapenv:Envelope>';
        ARIICPQCalls.updateTransactionRes = '<?xml version=\'1.0\' encoding=\'utf-8\'?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><bm:updateTransactionResponse xmlns:bm="urn:soap.bigmachines.com"><bm:status><bm:success>true</bm:success><bm:message>Tue Nov 07 08:19:54 CST 2017 - Successfully processed API for qamoveinc</bm:message></bm:status></bm:updateTransactionResponse></soapenv:Body></soapenv:Envelope>';

        ARIICPQCalls.createTransactionRes = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><bm:createTransactionResponse xmlns:bm="urn:soap.bigmachines.com"><bm:status><bm:success>true</bm:success><bm:message>Thu Nov 30 16:56:13 CST 2017 - Successfully processed API for qamoveinc</bm:message></bm:status><bm:transaction><bm:category>bm_cm_bs_data</bm:category><bm:action>add</bm:action><bm:id>107523155</bm:id><bm:process_var_name>oraclecpqo</bm:process_var_name><bm:buyer_company_name>qamoveinc</bm:buyer_company_name><bm:supplier_company_name>qamoveinc</bm:supplier_company_name><bm:step_var_name/><bm:last_document_number>1</bm:last_document_number><bm:date_added>2017-11-30 16:56:13</bm:date_added><bm:date_modified>2017-11-30 16:56:13</bm:date_modified><bm:data_xml><bm:transaction bm:bs_id="107523155" bm:buyer_company_name="qamoveinc" bm:buyer_user_name="ashoksontinenicontractor" bm:currency_pref="USD" bm:data_type="0" bm:document_name="Transaction" bm:document_number="1" bm:document_var_name="transaction" bm:process_var_name="oraclecpqo" bm:supplier_company_name="qamoveinc"><bm:_document_number>1</bm:_document_number><bm:obsolete_attributes><bm:__cm_bs_service_ignore_override>false</bm:__cm_bs_service_ignore_override><bm:__cm_bs_service_unsaved_data>false</bm:__cm_bs_service_unsaved_data><bm:__cm_bs_service_new_data>false</bm:__cm_bs_service_new_data><bm:_price_quantity>1</bm:_price_quantity></bm:obsolete_attributes><bm:approval_history/><bm:approval_status/><bm:sub_documents/><bm:rule_data><bm:totalAnnualValue_t bm:constrained="false" bm:hidden="true"/><bm:selectedFulfillToLineNums_quote bm:constrained="false" bm:hidden="true"/><bm:paymentAuthorization_quote bm:constrained="false" bm:hidden="true"/><bm:chooseLead bm:constrained="false" bm:hidden="true"/><bm:totalUsageFees_quote bm:constrained="false" bm:hidden="true"/><bm:totalMonthlyDiscount_t bm:constrained="false" bm:hidden="true"/><bm:authorizationAmount_quote bm:constrained="false" bm:hidden="true"/><bm:taxExemptReason_t bm:constrained="false" bm:hidden="true"/><bm:totalMonthlyNetAmount_t bm:constrained="false" bm:hidden="true"/><bm:authorizationDate_quote bm:constrained="false" bm:hidden="true"/><bm:paymentAuthorizationlabel_quote bm:constrained="false" bm:hidden="true"/><bm:hTMLErrorMessage_quote bm:constrained="false" bm:hidden="true"/><bm:selectedOfficeValue_t bm:constrained="false" bm:hidden="true"/><bm:totalMonthlyListAmount_t bm:constrained="false" bm:hidden="true"/><bm:specialAdvantagePricing_quote bm:constrained="false" bm:hidden="true"/><bm:prorationMessage_quote bm:constrained="false" bm:hidden="true"/><bm:estUsageTax_quote bm:constrained="false" bm:hidden="true"/></bm:rule_data></bm:transaction></bm:data_xml><bm:action_data><bm:action_var_name/><bm:_bm_cm_new_transaction_currency/><bm:performer_comment/><bm:reason_var_name/><bm:performer_name/><bm:performer_type/><bm:performer_company_name/></bm:action_data><bm:sub_step_name/><bm:buyer_user_name>ashoksontinenicontractor</bm:buyer_user_name><bm:currency_pref>USD</bm:currency_pref><bm:status>0</bm:status><bm:update_count>2</bm:update_count><bm:language_pref>English</bm:language_pref><bm:num_transitions>0</bm:num_transitions></bm:transaction></bm:createTransactionResponse></soapenv:Body></soapenv:Envelope>';
        MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
        mtduc.CreateBMURLSingle();
        mtduc.CreateDisabledTriggerSingle();
        mtduc.CreateBrokerAccountSingle();
        mtduc.CreateOppurtunitySingle();
        mtduc.CreateContactSingle();
        mtduc.CreateContractSingle();
        Product2 pt = mtduc.CreateProductSingle();
        mtduc.CreateOracleQuoteSingle();
        Asset ast = mtduc.CreateFullfilledAssetSingle();
        Map<Id,String> assetIds = new Map<Id,String>();
        Set<Id> asstId = new Set<Id>();
        List<CreateWaitlistQuoteWrapper> lstCreateWaitlistQuoteWrapper = new List<CreateWaitlistQuoteWrapper>();
        CreateWaitlistQuoteWrapper cwqw = new CreateWaitlistQuoteWrapper();
        lstCreateWaitlistQuoteWrapper.add(cwqw);
        assetIds.put(ast.id,'amend##customerRequest');
        asstId.add(ast.Id);
        ARIICPQCalls wcbmq = new ARIICPQCalls();
        ast.CampaignId__c = 'Testing';
        update ast;
        Asset_AR_Association__c arAsst= new Asset_AR_Association__c();
            arAsst.Asset_Id__c = ast.Id;
            arAsst.AR_Config_Options__c = 'Land';
            arAsst.AR_Lead_PPL__c = 1;
            arAsst.AR_Brand_PPL__c = 1;
            arAsst.AR_AMLC_Residential__c = 1;
            arAsst.AR_AMLC_Land__c = 1;
            arAsst.AR_AMLC_Rental__c = 1;
            arAsst.AR_PPL_Override__c = 1;
            arAsst.External_ID__c = '1234-78979';
            arAsst.AR_Price_Info__c = '12^0.0^ASR_A/R_NewOrder_CBC10_Off^10.0^0.0^KWCBC25^10.0^0.0^0.0^0.0^0.0#';
            insert arAsst;
        ARIICPQCalls.CreateQuote(mtduc.newAccount.id,mtduc.theOpportunity.id,assetIds);
        
        ARIICPQCalls.createBigMachineQuoteIncpq('34453453','ppp');
        //wcbmq.executeAutoRenewalUpdate= false;
        ARIICPQCalls.createBigMachineQuoteIncpq('34453453','ppp');
        ARIICPQCalls.tId = '34453453';
        ARIICPQCalls.AssetNightlyPriceUpdate(ARIICPQCalls.tId,'plainSave_t',asstId, 'Land');
        ARIICPQCalls.AssetNightlyPriceUpdate(ARIICPQCalls.tId,'autoRenewAssetExport',asstId, 'Land');
        
        pt.ProductCode = 'ADVANTAGE';
        update pt;
        ast.Commerce_Group__c = 'Broker Marketing Solutions';        
        ast.ConfigOptions__c = 'Residential';
        ast.Override_Term__c  = 3;
        ast.Billing_Period__c = 'Monthly';
        ast.Total_List_Price__c = 50;
        update ast;
        //wcbmq.autoprocess = true;
       // wcbmq.suppressdocusign = true;
       // wcbmq.executeAutoRenewalUpdate = true;
        ARIICPQCalls.createBigMachineQuoteIncpq('23423','ppp');       
        
        ast.Commerce_Group__c = 'Agent Marketing Solution';
        ast.ResidentialLeadPPL__c = 2;
        ast.ResidentialBrandPPL__c = 2;
        ast.ResidentialAMLC__c = 2;
        ast.LandAMLC__c = 2;
        ast.RentalAMLC__c = 2;
        ast.ContractedAMLC__c = 2;
        ast.AMLCOverride__c = 2;
        ast.PPLOverride__c = 2;
        ast.Override_Term__c = 0;
        ast.Contract_Term__c = '3';
        ast.Billing_Period__c = 'Quarterly'; 
        ast.Total_List_Price__c = 50;      
        update ast;
        //wcbmq.autoprocess = true;
        //wcbmq.suppressdocusign = true;
        //wcbmq.executeAutoRenewalUpdate = true;
        ARIICPQCalls.createBigMachineQuoteIncpq('23423','ppp');
          List<ARIICPQCalls.AutoRenewalQuoteLineWrapper> wraps = new List<ARIICPQCalls.AutoRenewalQuoteLineWrapper>();
        ARIICPQCalls.UpdateDeleteAutoRenewalQuote('23423',wraps);
    }

    Public static testMethod void testWebserviceCallFunctionality2() {
    ARIICPQCalls.sessionRes ='<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><bm:loginResponse xmlns:bm="urn:soap.bigmachines.com"><bm:status><bm:success>true</bm:success><bm:message>Thu Nov 30 16:55:24 CST 2017 - Successfully processed API for qamoveinc</bm:message></bm:status><bm:userInfo><bm:sessionId>hHTmhgMbrp8fb5d7YWPsL2NDw7c9nhhKZGyFjXSqB2yJlTQhYTm6!626200874!1512082523946</bm:sessionId></bm:userInfo></bm:loginResponse></soapenv:Body></soapenv:Envelope>';
        ARIICPQCalls.updateTransactionRes = '<?xml version=\'1.0\' encoding=\'utf-8\'?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><bm:updateTransactionResponse xmlns:bm="urn:soap.bigmachines.com"><bm:status><bm:success>true</bm:success><bm:message>Tue Nov 07 08:19:54 CST 2017 - Successfully processed API for qamoveinc</bm:message></bm:status></bm:updateTransactionResponse></soapenv:Body></soapenv:Envelope>';

        ARIICPQCalls.createTransactionRes = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><bm:createTransactionResponse xmlns:bm="urn:soap.bigmachines.com"><bm:status><bm:success>true</bm:success><bm:message>Thu Nov 30 16:56:13 CST 2017 - Successfully processed API for qamoveinc</bm:message></bm:status><bm:transaction><bm:category>bm_cm_bs_data</bm:category><bm:action>add</bm:action><bm:id>107523155</bm:id><bm:process_var_name>oraclecpqo</bm:process_var_name><bm:buyer_company_name>qamoveinc</bm:buyer_company_name><bm:supplier_company_name>qamoveinc</bm:supplier_company_name><bm:step_var_name/><bm:last_document_number>1</bm:last_document_number><bm:date_added>2017-11-30 16:56:13</bm:date_added><bm:date_modified>2017-11-30 16:56:13</bm:date_modified><bm:data_xml><bm:transaction bm:bs_id="107523155" bm:buyer_company_name="qamoveinc" bm:buyer_user_name="ashoksontinenicontractor" bm:currency_pref="USD" bm:data_type="0" bm:document_name="Transaction" bm:document_number="1" bm:document_var_name="transaction" bm:process_var_name="oraclecpqo" bm:supplier_company_name="qamoveinc"><bm:_document_number>1</bm:_document_number><bm:obsolete_attributes><bm:__cm_bs_service_ignore_override>false</bm:__cm_bs_service_ignore_override><bm:__cm_bs_service_unsaved_data>false</bm:__cm_bs_service_unsaved_data><bm:__cm_bs_service_new_data>false</bm:__cm_bs_service_new_data><bm:_price_quantity>1</bm:_price_quantity></bm:obsolete_attributes><bm:approval_history/><bm:approval_status/><bm:sub_documents/><bm:rule_data><bm:totalAnnualValue_t bm:constrained="false" bm:hidden="true"/><bm:selectedFulfillToLineNums_quote bm:constrained="false" bm:hidden="true"/><bm:paymentAuthorization_quote bm:constrained="false" bm:hidden="true"/><bm:chooseLead bm:constrained="false" bm:hidden="true"/><bm:totalUsageFees_quote bm:constrained="false" bm:hidden="true"/><bm:totalMonthlyDiscount_t bm:constrained="false" bm:hidden="true"/><bm:authorizationAmount_quote bm:constrained="false" bm:hidden="true"/><bm:taxExemptReason_t bm:constrained="false" bm:hidden="true"/><bm:totalMonthlyNetAmount_t bm:constrained="false" bm:hidden="true"/><bm:authorizationDate_quote bm:constrained="false" bm:hidden="true"/><bm:paymentAuthorizationlabel_quote bm:constrained="false" bm:hidden="true"/><bm:hTMLErrorMessage_quote bm:constrained="false" bm:hidden="true"/><bm:selectedOfficeValue_t bm:constrained="false" bm:hidden="true"/><bm:totalMonthlyListAmount_t bm:constrained="false" bm:hidden="true"/><bm:specialAdvantagePricing_quote bm:constrained="false" bm:hidden="true"/><bm:prorationMessage_quote bm:constrained="false" bm:hidden="true"/><bm:estUsageTax_quote bm:constrained="false" bm:hidden="true"/></bm:rule_data></bm:transaction></bm:data_xml><bm:action_data><bm:action_var_name/><bm:_bm_cm_new_transaction_currency/><bm:performer_comment/><bm:reason_var_name/><bm:performer_name/><bm:performer_type/><bm:performer_company_name/></bm:action_data><bm:sub_step_name/><bm:buyer_user_name>ashoksontinenicontractor</bm:buyer_user_name><bm:currency_pref>USD</bm:currency_pref><bm:status>0</bm:status><bm:update_count>2</bm:update_count><bm:language_pref>English</bm:language_pref><bm:num_transitions>0</bm:num_transitions></bm:transaction></bm:createTransactionResponse></soapenv:Body></soapenv:Envelope>';
        
        MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
        mtduc.CreateBMURLSingle();
        mtduc.CreateDisabledTriggerSingle();
        mtduc.CreateBrokerAccountSingle();
        mtduc.CreateOppurtunitySingle();
        mtduc.CreateContactSingle();
        mtduc.CreateContractSingle();
        mtduc.CreateProductSingle();
        mtduc.CreateOracleQuoteSingle();
        Asset ast = mtduc.CreateFullfilledAssetSingle();
        Map<Id,String> assetIds = new Map<Id,String>();
        Set<Id> asstId = new Set<Id>();
        List<CreateWaitlistQuoteWrapper> lstCreateWaitlistQuoteWrapper = new List<CreateWaitlistQuoteWrapper>();
        CreateWaitlistQuoteWrapper cwqw = new CreateWaitlistQuoteWrapper();
        lstCreateWaitlistQuoteWrapper.add(cwqw);
        assetIds.put(ast.id,'amend##customerRequest');
        asstId.add(ast.Id);
        ARIICPQCalls wcbmq = new ARIICPQCalls();
        ARIICPQCalls.CreateQuote(mtduc.newAccount.id,mtduc.theOpportunity.id,assetIds);
        ARIICPQCalls.createBigMachineQuoteIncpq('23423','ppp');
        //wcbmq.executeAutoRenewalUpdate= false;
        ARIICPQCalls.UpdateBigMachineQuoteWaitlist('23423','ppp');
        List<ARIICPQCalls.AutoRenewalQuoteLineWrapper> lstAutoRenewalQuoteLineWrapper = new List<ARIICPQCalls.AutoRenewalQuoteLineWrapper>();
        ARIICPQCalls.AutoRenewalQuoteLineWrapper arqlwr = new ARIICPQCalls.AutoRenewalQuoteLineWrapper();
        arqlwr.BMActionRequired='Remove';
        lstAutoRenewalQuoteLineWrapper.add(arqlwr);
        ARIICPQCalls.UpdateDeleteAutoRenewalQuote(ARIICPQCalls.SFCreatedQuoteId,lstAutoRenewalQuoteLineWrapper);
        
        lstAutoRenewalQuoteLineWrapper = new List<ARIICPQCalls.AutoRenewalQuoteLineWrapper>();
        arqlwr = new ARIICPQCalls.AutoRenewalQuoteLineWrapper();
        arqlwr.BMActionRequired='Renew';
        arqlwr.BMDocumentNumber = '23454';
        arqlwr.billingtype = 'Monthly';
        lstAutoRenewalQuoteLineWrapper.add(arqlwr);
        ARIICPQCalls.UpdateDeleteAutoRenewalQuote(ARIICPQCalls.SFCreatedQuoteId,lstAutoRenewalQuoteLineWrapper);
       // ARIICPQCalls.FindBillingPeriod('Quarterly','Quarterly');               
    
    }
    
    Public static testMethod void testWebserviceCallBigMachineQuoteClsFunctionality3() {
    ARIICPQCalls.sessionRes ='<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><bm:loginResponse xmlns:bm="urn:soap.bigmachines.com"><bm:status><bm:success>true</bm:success><bm:message>Thu Nov 30 16:55:24 CST 2017 - Successfully processed API for qamoveinc</bm:message></bm:status><bm:userInfo><bm:sessionId>hHTmhgMbrp8fb5d7YWPsL2NDw7c9nhhKZGyFjXSqB2yJlTQhYTm6!626200874!1512082523946</bm:sessionId></bm:userInfo></bm:loginResponse></soapenv:Body></soapenv:Envelope>';
        ARIICPQCalls.updateTransactionRes = '<?xml version=\'1.0\' encoding=\'utf-8\'?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><bm:updateTransactionResponse xmlns:bm="urn:soap.bigmachines.com"><bm:status><bm:success>true</bm:success><bm:message>Tue Nov 07 08:19:54 CST 2017 - Successfully processed API for qamoveinc</bm:message></bm:status></bm:updateTransactionResponse></soapenv:Body></soapenv:Envelope>';

        ARIICPQCalls.createTransactionRes = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><bm:createTransactionResponse xmlns:bm="urn:soap.bigmachines.com"><bm:status><bm:success>true</bm:success><bm:message>Thu Nov 30 16:56:13 CST 2017 - Successfully processed API for qamoveinc</bm:message></bm:status><bm:transaction><bm:category>bm_cm_bs_data</bm:category><bm:action>add</bm:action><bm:id>107523155</bm:id><bm:process_var_name>oraclecpqo</bm:process_var_name><bm:buyer_company_name>qamoveinc</bm:buyer_company_name><bm:supplier_company_name>qamoveinc</bm:supplier_company_name><bm:step_var_name/><bm:last_document_number>1</bm:last_document_number><bm:date_added>2017-11-30 16:56:13</bm:date_added><bm:date_modified>2017-11-30 16:56:13</bm:date_modified><bm:data_xml><bm:transaction bm:bs_id="107523155" bm:buyer_company_name="qamoveinc" bm:buyer_user_name="ashoksontinenicontractor" bm:currency_pref="USD" bm:data_type="0" bm:document_name="Transaction" bm:document_number="1" bm:document_var_name="transaction" bm:process_var_name="oraclecpqo" bm:supplier_company_name="qamoveinc"><bm:_document_number>1</bm:_document_number><bm:obsolete_attributes><bm:__cm_bs_service_ignore_override>false</bm:__cm_bs_service_ignore_override><bm:__cm_bs_service_unsaved_data>false</bm:__cm_bs_service_unsaved_data><bm:__cm_bs_service_new_data>false</bm:__cm_bs_service_new_data><bm:_price_quantity>1</bm:_price_quantity></bm:obsolete_attributes><bm:approval_history/><bm:approval_status/><bm:sub_documents/><bm:rule_data><bm:totalAnnualValue_t bm:constrained="false" bm:hidden="true"/><bm:selectedFulfillToLineNums_quote bm:constrained="false" bm:hidden="true"/><bm:paymentAuthorization_quote bm:constrained="false" bm:hidden="true"/><bm:chooseLead bm:constrained="false" bm:hidden="true"/><bm:totalUsageFees_quote bm:constrained="false" bm:hidden="true"/><bm:totalMonthlyDiscount_t bm:constrained="false" bm:hidden="true"/><bm:authorizationAmount_quote bm:constrained="false" bm:hidden="true"/><bm:taxExemptReason_t bm:constrained="false" bm:hidden="true"/><bm:totalMonthlyNetAmount_t bm:constrained="false" bm:hidden="true"/><bm:authorizationDate_quote bm:constrained="false" bm:hidden="true"/><bm:paymentAuthorizationlabel_quote bm:constrained="false" bm:hidden="true"/><bm:hTMLErrorMessage_quote bm:constrained="false" bm:hidden="true"/><bm:selectedOfficeValue_t bm:constrained="false" bm:hidden="true"/><bm:totalMonthlyListAmount_t bm:constrained="false" bm:hidden="true"/><bm:specialAdvantagePricing_quote bm:constrained="false" bm:hidden="true"/><bm:prorationMessage_quote bm:constrained="false" bm:hidden="true"/><bm:estUsageTax_quote bm:constrained="false" bm:hidden="true"/></bm:rule_data></bm:transaction></bm:data_xml><bm:action_data><bm:action_var_name/><bm:_bm_cm_new_transaction_currency/><bm:performer_comment/><bm:reason_var_name/><bm:performer_name/><bm:performer_type/><bm:performer_company_name/></bm:action_data><bm:sub_step_name/><bm:buyer_user_name>ashoksontinenicontractor</bm:buyer_user_name><bm:currency_pref>USD</bm:currency_pref><bm:status>0</bm:status><bm:update_count>2</bm:update_count><bm:language_pref>English</bm:language_pref><bm:num_transitions>0</bm:num_transitions></bm:transaction></bm:createTransactionResponse></soapenv:Body></soapenv:Envelope>';
        
        MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
        mtduc.CreateBMURLSingle();
        mtduc.CreateDisabledTriggerSingle();
        mtduc.CreateBrokerAccountSingle();
        mtduc.CreateOppurtunitySingle();
        mtduc.CreateContactSingle();
        mtduc.CreateContractSingle();
        Product2 pt = mtduc.CreateProductSingle();
        mtduc.CreateOracleQuoteSingle();
        Asset ast = mtduc.CreateFullfilledAssetSingle();
        ast.CustResp_AutoOrder__c = 'Yes';
        update ast;
        Map<Id,String> assetIds = new Map<Id,String>();
        Set<Id> asstId = new Set<Id>();
        List<CreateWaitlistQuoteWrapper> lstCreateWaitlistQuoteWrapper = new List<CreateWaitlistQuoteWrapper>();
        CreateWaitlistQuoteWrapper cwqw = new CreateWaitlistQuoteWrapper();
        lstCreateWaitlistQuoteWrapper.add(cwqw);
        assetIds.put(ast.id,'amend##customerRequest');
        asstId.add(ast.Id);
        ARIICPQCalls wcbmq = new ARIICPQCalls();
        ARIICPQCalls.CreateQuote(mtduc.newAccount.id,mtduc.theOpportunity.id,assetIds);
        ARIICPQCalls.createBigMachineQuoteIncpq('23423','ppp');
       // ARIICPQCalls.executeAutoRenewalUpdate= false;
        ARIICPQCalls.UpdateBigMachineQuoteWaitlist('23423','ppp');
        
        ast.CustResp_AutoOrder__c = ' ';
        update ast;
        
        pt.DefaultRenewalTerm__c = '12';
        update pt;
        
        Asset_AR_Association__c arAsst = new Asset_AR_Association__c();
        arAsst.Asset_Id__c = ast.Id;
        arAsst.External_ID__c = '123-2356743';
        arAsst.AR_Price_Info__c = '12^0.0^ASR_A/R_NewOrder_CBC10_Off^10.0^0.0^KWCBC25^10.0^0.0^0.0^0.0^0.0#';
        arAsst.AR_Config_Options__c = 'Land';
        arAsst.AR_Lead_PPL__c = 1;
        arAsst.AR_Brand_PPL__c = 1;
        arAsst.AR_AMLC_Residential__c = 1;
        arAsst.AR_AMLC_Land__c = 1;
        arAsst.AR_AMLC_Rental__c = 1;
        arAsst.AR_PPL_Override__c = 1;
        insert arAsst;
        
        ARIICPQCalls.CreateQuote(mtduc.newAccount.id,mtduc.theOpportunity.id,assetIds);
        ARIICPQCalls.createBigMachineQuoteIncpq('23423','ppp');
       // wcbmq.executeAutoRenewalUpdate= false;
        ARIICPQCalls.UpdateBigMachineQuoteWaitlist('23423','ppp');
        List<ARIICPQCalls.AutoRenewalQuoteLineWrapper> wraps = new List<ARIICPQCalls.AutoRenewalQuoteLineWrapper>();
        ARIICPQCalls.UpdateDeleteAutoRenewalQuote('23423',wraps);
       // ARIICPQCalls.tId = 23423;
       // ARIICPQCalls.AssetNightlyPriceUpdate(ARIICPQCalls.SFCreatedQuoteId,'plainSave_t',asstId);
       // ARIICPQCalls.AssetNightlyPriceUpdate(ARIICPQCalls.SFCreatedQuoteId,'autoRenewAssetExport',asstId);
       BigMachineUrls__c BMUrls= BigMachineUrls__c.getValues('BM');
       ARIICPQCalls wcbmq1 = new ARIICPQCalls(BMUrls);
      // wcbmq1.DammyMethod();
    
    }
}