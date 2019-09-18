//Name        : ARIICPQCallsUtility
//Description : Utility class for
//Frequencey  : Every Month
//Author      : Pallavi Tammana
//History     : CRM-3261: SFDC tasks for Lead processing & quote creation
//            : CRM-3733: AMLC Override value is getting retained from previous order for Auto-Renew Quote
//            : CRM-3846: Auto Quotes are stuck in Sales Ops when Account AMLC is 0

public class ARIICPQCallsUtility{
public static Map<Id,Integer> mapAssetIDDocumentNumber = new Map<Id,Integer>();
public static Map<Id, Asset_AR_Association__c> ARasstMap = new Map<Id, Asset_AR_Association__c>();
public static Map<Id,Asset> mapAllAssets = new Map<Id,Asset>();

public static String getcreateReq(){
    String body = '';
    body += getRequestHeader();
    body += createTransactionReq();
    return body;
}
public static String getUpdateReq(){
    String body = '';
    body += getRequestHeader();
    body += updateCallTransactionReq();
    return body;
}
public static String getUpdateReqFullInfo(){
    String body = '';
    body +=getRequestHeader();
    body +=getUpdateTransactionReq();
    return body;
}

private static String getUpdateSubDocuments(){
        String body = '';
        body = body+'<bm:sub_documents>';
        for(ARIICPQCalls.AutoRenewalQuoteLineWrapper arqw:ARIICPQCalls.updateAutoRenewalQuoteLineWrapper){
            body = body+'<bm:transactionLine bm:bs_id="'+Integer.valueof(ARIICPQCalls.tId)+'" bm:buyer_company_name="'+ARIICPQCalls.BMInstance+'" bm:buyer_user_name="'+ARIICPQCalls.BMUserName+'" bm:currency_pref="USD" bm:data_type="3" bm:document_name="Transaction Line" bm:document_number="'+arqw.BMDocumentNumber+'" bm:document_var_name="transactionLine" bm:process_var_name="oraclecpqo" bm:supplier_company_name="'+ARIICPQCalls.BMInstance+'">';
            body = body+'<bm:_document_number>'+arqw.BMDocumentNumber+'</bm:_document_number>';
            if(ARIICPQCalls.atype=='_update_line_items'){                          
                body = body+'<bm:billingPeriod_line>'+arqw.BillingType+'</bm:billingPeriod_line>';
            }
            body = body+'</bm:transactionLine>';
        } 
        body = body+'</bm:sub_documents>';
        return body;
}

private static String getUpdateDataxml(){
       String body = '';
        body = body+'<bm:data_xml>';
        body = body+'<bm:transaction bm:bs_id="'+Integer.valueof(ARIICPQCalls.tId)+'" bm:buyer_company_name="'+ARIICPQCalls.BMInstance+'" bm:buyer_user_name="'+ARIICPQCalls.BMUserName+'" bm:currency_pref="USD" bm:data_type="0" bm:document_name="Transaction" bm:document_number="1" bm:document_var_name="transaction" bm:process_var_name="oraclecpqo" bm:supplier_company_name="'+ARIICPQCalls.BMInstance+'">';
        body = body+'<bm:_document_number>1</bm:_document_number>';
        system.debug('ardIDStr --> '+ARIICPQCalls.ArIdStr);
        system.debug('atype --> '+ARIICPQCalls.aType);
        if(ARIICPQCalls.aType == 'plainSave_t'){
             body = body+'<bm:customerFranchiseAR_t>'+(ARIICPQCalls.franchiseType != null ? formatString(ARIICPQCalls.franchiseType) : '') +'</bm:customerFranchiseAR_t>';
             body = body+'<bm:advantageSelectedOpt_quote>'+(ARIICPQCalls.configOptions != null ? formatString(ARIICPQCalls.configOptions) : '') +'</bm:advantageSelectedOpt_quote>';
        }
    
        if(ARIICPQCalls.aType == 'plainSave_t' || ARIICPQCalls.aType == 'autoRenewAssetExport') {
            body = body+'<bm:renewableAssets_t>'+ARIICPQCalls.ArIdStr+'</bm:renewableAssets_t>';
            body = body+'<bm:skipConstraints_quote>true</bm:skipConstraints_quote>';
        } else{
            body = body+'<bm:skipAuthorization_quote>true</bm:skipAuthorization_quote>'; 
            body = body+'<bm:quoteType_quote>Auto-Renew</bm:quoteType_quote>';  
            if(ARIICPQCalls.acctBillingPreference == 'Invoice-Terms' || ARIICPQCalls.acctBillingPreference == 'Arrears-Invoice'){ //CRM-2805
            body = body+'<bm:suppressDocuSign_quote>true</bm:suppressDocuSign_quote>'; //CRM-2805
            }
        }
        if(ARIICPQCalls.quoteOwnerId!=''){body = body+'<bm:quoteOwnerId_quote>'+ARIICPQCalls.quoteOwnerId+'</bm:quoteOwnerId_quote>';} 
        if(ARIICPQCalls.opportunityID!=null && ARIICPQCalls.opportunityID!=''){body = body+'<bm:opportunityID_t>'+ARIICPQCalls.opportunityID+'</bm:opportunityID_t>';}
        body = body+'<bm:status_t>In Progress</bm:status_t>';
        body = body+'<bm:version_t>1</bm:version_t>';
        body = body+'<bm:bs_id>'+Integer.valueof(ARIICPQCalls.tId)+'</bm:bs_id>';
        if(ARIICPQCalls.AccountId!=null && ARIICPQCalls.AccountId!=''){body = body+'<bm:_customer_id>'+ARIICPQCalls.AccountId+'</bm:_customer_id>';}
        if(ARIICPQCalls.QuoteownerName!=''){ body = body+'<bm:owner_t>'+ARIICPQCalls.QuoteownerName+'</bm:owner_t>';
        } else { body = body+'<bm:owner_t>'+UserInfo.getUserName()+'</bm:owner_t>';}
        body = body+'<bm:lastUpdatedBy_t>'+UserInfo.getFirstName()+' '+UserInfo.getLastName()+'</bm:lastUpdatedBy_t>';
        body = body+'<bm:version_number_versionTransaction_t>1</bm:version_number_versionTransaction_t>';
        body = body+'<bm:caseId></bm:caseId>';
        body = body+ getUpdateSubDocuments();
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
        return body;
}

 private static String updateCallTransactionReq(){ 
      
        String body = '';
        body = body+'<soapenv:Body>';
        body = body+'<bm:updateTransaction xmlns:bm="urn:soap.bigmachines.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
        body = body+'<bm:transaction>';
        body = body+'<bm:id>'+Integer.valueof(ARIICPQCalls.tId)+'</bm:id>';
        body = body+'<bm:process_var_name>oraclecpqo</bm:process_var_name>';
        body = body+'<bm:buyer_company_name>'+ARIICPQCalls.BMInstance+'</bm:buyer_company_name>';
        body = body+'<bm:supplier_company_name>'+ARIICPQCalls.BMInstance+'</bm:supplier_company_name>';
        body = body+'<bm:last_document_number>1</bm:last_document_number>';
        body = body+getUpdateDataxml();
        body = body+getActionDataReq();
        body = body+'<bm:sub_step_name/>';
        body = body+'<bm:buyer_user_name>'+ARIICPQCalls.BMUserName+'</bm:buyer_user_name>';
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
        return body;
}

private static String getRequestHeader(){
    String   body = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">';
        body = body+'<soapenv:Header>';
        body = body+'<bm:userInfo xmlns:bm="urn:soap.bigmachines.com">';
        body = body+'<bm:sessionId>'+ARIICPQCalls.bmsessionid+'</bm:sessionId>';
        body = body+'</bm:userInfo>';
        body = body+'<bm:category xmlns:bm="urn:soap.bigmachines.com">Commerce</bm:category>';
        body = body+'<bm:xsdInfo xmlns:bm="urn:soap.bigmachines.com">';
        body = body+'<bm:schemaLocation>'+ARIICPQCalls.BMUrl +'/schema/v1_0/commerce/oraclecpqo.xsd</bm:schemaLocation>';
        body = body+'</bm:xsdInfo>';
        body = body+'</soapenv:Header>';
        return body;
}

private static String getUpdateTransactionReq(){
    
    String body = '<soapenv:Body>';
        body = body+'<bm:updateTransaction xmlns:bm="urn:soap.bigmachines.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
        body = body+'<bm:transaction>';
        body = body+'<bm:id>'+Integer.valueof(ARIICPQCalls.tId)+'</bm:id>';
        body = body+'<bm:process_var_name>oraclecpqo</bm:process_var_name>';
        body = body+'<bm:buyer_company_name>'+ARIICPQCalls.BMInstance+'</bm:buyer_company_name>';
        body = body+'<bm:supplier_company_name>'+ARIICPQCalls.BMInstance+'</bm:supplier_company_name>';
        body = body+'<bm:last_document_number>1</bm:last_document_number>';
        body = body+ getDataXMLReq();
        body = body+ getActionDataReq();
        body = body+'<bm:sub_step_name/>';
        body = body+'<bm:buyer_user_name>'+ARIICPQCalls.BMUserName+'</bm:buyer_user_name>';
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
        return body;
}

private static String getDataXMLReq(){
    String body = '';
    body = body+'<bm:data_xml>';
    body = body+ getTransactionDataReq();
    body = body+'</bm:data_xml>';
    return body;
}

private static string getActionDataReq(){
    String body = '';
        body = body+'<bm:action_data>';
        body = body+'<bm:action_var_name>'+ARIICPQCalls.atype+'</bm:action_var_name>';
        body = body+'<bm:_bm_cm_new_transaction_currency/>';
        body = body+'<bm:performer_comment/>';
        body = body+'<bm:reason_var_name/>';
        body = body+'<bm:performer_name/>';
        body = body+'<bm:performer_type/>';
        body = body+'<bm:performer_company_name/>';
        body = body+'</bm:action_data>';
    return body;
}

 Public static String FormatString(String xmlText){
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

private static String getTransactionDataReq(){
    String body = '';
        body = body+'<bm:transaction bm:bs_id="'+Integer.valueof(ARIICPQCalls.tId)+'" bm:buyer_company_name="'+ARIICPQCalls.BMInstance+'" bm:buyer_user_name="'+ARIICPQCalls.BMUserName+'" bm:currency_pref="USD" bm:data_type="0" bm:document_name="Transaction" bm:document_number="1" bm:document_var_name="transaction" bm:process_var_name="oraclecpqo" bm:supplier_company_name="'+ARIICPQCalls.BMInstance+'">';
        body = body+'<bm:_document_number>1</bm:_document_number>';
        
        body = body+'<bm:opportunityID_t>'+ARIICPQCalls.opportunityID+'</bm:opportunityID_t>';
        body = body+'<bm:status_t>In Progress</bm:status_t>';
        body = body+'<bm:version_t>1</bm:version_t>';
        body = body+'<bm:bs_id>'+Integer.valueof(ARIICPQCalls.tId)+'</bm:bs_id>';
        body = body+'<bm:_customer_id>'+ARIICPQCalls.AccountId+'</bm:_customer_id>';
        body = body+'<bm:owner_t>'+ARIICPQCalls.QuoteOwnerName+'</bm:owner_t>';
        body = body+'<bm:quoteOwnerId_quote>'+ARIICPQCalls.QuoteownerId+'</bm:quoteOwnerId_quote>';
        body = body+'<bm:lastUpdatedBy_t>'+UserInfo.getFirstName()+' '+UserInfo.getLastName()+'</bm:lastUpdatedBy_t>';
        body = body+'<bm:version_number_versionTransaction_t>1</bm:version_number_versionTransaction_t>';
        body = body+'<bm:quoteType_quote>Auto-Renew</bm:quoteType_quote>';
        body = body+'<bm:caseId></bm:caseId>';
        body=body+getSubDocumentsReq();
        body = body+'<bm:rule_data>';
        body = body+'<bm:appliedPromotions_quote></bm:appliedPromotions_quote>';
        body = body+'<bm:totalAnnualValue_t bm:constrained="false" bm:hidden="true"/>';
        body = body+'<bm:totalContractValue_t bm:constrained="false" bm:hidden="true"/>';
        body = body+'<bm:totalMonthlyDiscount_t bm:constrained="false" bm:hidden="true"/>';
        body = body+'<bm:taxExemptReason_t bm:constrained="false" bm:hidden="true"/>';
        body = body+'<bm:totalMonthlyNetAmount_t bm:constrained="false" bm:hidden="true"/>';
        body = body+'<bm:totalMonthlyListAmount_t bm:constrained="false" bm:hidden="true"/>';
        body = body+'</bm:rule_data>';
        body = body+'</bm:transaction>';
        return body;
}


private static String getSubDocumentsReq(){
    String body = '';
        body = body+'<bm:sub_documents>';
        Map<Id,Asset> mapAllAssets = getAssetsMap(ARIICPQCalls.Accountid, ARIICPQCalls.setAssetIds);
        Map<Id, Asset_AR_Association__c> ARasstMap = getARMap(mapAllAssets.keySet());
        AssetTriggerHelper ath = new AssetTriggerHelper();
        ath.GenerateJsonStrings(mapAllAssets);
        for(Asset assst:mapAllAssets.values()){
            body = body + getTransactionLineReq(assst);
        }
        body = body+'</bm:sub_documents>';
        return body;
}

private static String getTransactionLineReq(Asset assst){
    String body = '';
    body = body+'<bm:transactionLine bm:bs_id="'+Integer.valueof(ARIICPQCalls.tId)+'" bm:buyer_company_name="'+ARIICPQCalls.BMInstance+'" bm:buyer_user_name="'+ARIICPQCalls.BMUserName+'" bm:currency_pref="USD" bm:data_type="3" bm:document_name="Transaction Line" bm:document_number="'+mapAssetIDDocumentNumber.get(assst.id)+'" bm:document_var_name="transactionLine" bm:process_var_name="oraclecpqo" bm:supplier_company_name="'+ARIICPQCalls.BMInstance+'">';
    body = body+'<bm:_document_number>'+mapAssetIDDocumentNumber.get(assst.id)+'</bm:_document_number>';
    body = body+'<bm:lineType_line>renew</bm:lineType_line>';   
    body += conditionalTags(assst);
    body += mandatoryTags(assst);
    body = body+'</bm:transactionLine>';
    return body;
}

private static String getExternalId(Asset assst){
     String fExternalId = (assst.External_ID__c+'');
                if((assst.External_ID__c+'').contains('-PR1')){
                fExternalId = (assst.External_ID__c+'').replace('-PR1','');
                } else{
                    if(assst.Assets__r.size()>0){
                fExternalId = assst.Assets__r[0].External_ID__c ;
                    }
                }
     return fExternalId;
}


Public Static String FindBillingPeriod(String contractTerm,String BillingPeriod){
        if(BillingPeriod!='Monthly'){
            QuoteProductContractTerm__c conTerm = QuoteProductContractTerm__c.getInstance(contractTerm);
            if(conTerm!=null){
                BillingPeriod = conTerm.Term__c;
            }
        }
        return BillingPeriod;
    }
    
private static String getpartitems(){
        String body = '';   
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
                                where   Accountid=:ARIICPQCalls.AccountId
                                        and
                                        Asset_Type__c='Parent'
                                        and
                                        Id=:ARIICPQCalls.setAssetIds
                                        and
                                        Quantity>0]){


            body = body+'<bm:partItem>';
            body = body+'<bm:part>'+(assst.Product2.ProductCode  !=  null ? assst.Product2.ProductCode : 'COBROKE')+'</bm:part>';
            body = body+'<bm:quantity>'+(assst.Quantity != null ? Integer.valueOf(assst.Quantity) : 0)+'</bm:quantity>';
            body = body+'<bm:price_book_var_name>_default_price_book</bm:price_book_var_name>';
            body = body+'<bm:lineType_line>renew</bm:lineType_line>';
            body = body+'<bm:campaignId_line>'+(assst.CampaignId__c != null && assst.CampaignId__c != ''? assst.CampaignId__c : '')+'</bm:campaignId_line>';
            if(assst.Cost_Per_Action__c!=null){body = body+'<bm:costPerAction_line>'+assst.Cost_Per_Action__c+'</bm:costPerAction_line>';}
            if(assst.PricePerImpressionSold__c!=null){body = body+'<bm:pricePerImpressionSold_line>'+assst.PricePerImpressionSold__c+'</bm:pricePerImpressionSold_line>';}
            body = body+'<bm:forecastedLeads_line>'+assst.Monthly_Contracted_Units__c+'</bm:forecastedLeads_line>';
            body = body+'<bm:contractedImpressions_line>'+assst.Contractedimpressions__c+'</bm:contractedImpressions_line>';
            body = body+'</bm:partItem>';
        }
        
        return body;

}
    
private static String createTransactionReq(){
     String body = '';
     body = body+'<soapenv:Body>';
        body = body+'<bm:createTransaction xmlns:bm="urn:soap.bigmachines.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
        body = body+'<bm:items>';
        body = body+'<bm:segment>realtor</bm:segment>';
        body = body+'<bm:partItem>';
        body = body+'<bm:part/>';
        body = body+'<bm:quantity>1</bm:quantity>';
        body = body+'<bm:price_book_var_name/>';
        body = body+'</bm:partItem>';
        body = body+ getPartItems();
        body = body+'</bm:items>';
        body = body+'<bm:transaction>';
        body = body+'<bm:process_var_name>oraclecpqo</bm:process_var_name>';
        body = body+'<bm:quoteType_quote>Auto-Renew</bm:quoteType_quote>';
        body = body+'<bm:_customer_id>'+ARIICPQCalls.AccountId+'</bm:_customer_id>';
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
        return body;
}

private static String getAutoSubmitTags(Map<Id,Asset_AR_association__c> ARasstMap, Asset assst){
    String body = '';
    Boolean AccAMLC = false;
    system.debug('--- ARasstMap --> '+ARasstMap);
    system.debug(' --- assst --> '+assst);
    if(ARasstMap.containsKey(assst.Id) && ARasstMap.get(assst.Id).AR_Price_Info__c != null){
    
	//CRM-3846 Start AccAMLC = true when AR pric Info contains 12 month term, AMLC > 0
	List<String> PriceInfo1 = ARasstMap.get(assst.Id).AR_Price_Info__c.split('#');
    if(assst.Product2.ProductCode == 'ADVANTAGE'){
	Map<String, String> PriceInfoMap = new Map<String, String>();
		for(String Str: PriceInfo1){
		      List<String> PrcInf = str.split('\\^');
	            PriceInfoMap.put(PrcInf[0], PrcInf[0]);
	            if(PriceInfoMap.keyset().contains('12'))
	            {
	                AccAMLC = true;
	                break;
	            }
		 }
	}
	system.debug('AccAMLC'+AccAMLC);
	//CRM-3846 End AccAMLC = true when AR pric Info contains 12 month term, AMLC > 0
	
	system.debug('inside the AR Price Info'+ARasstMap.get(assst.Id).AR_Price_Info__c);
    List<String> PriceInfo = ARasstMap.get(assst.Id).AR_Price_Info__c.split('#');
                    String accountDefaultRenewalTerm = (assst.account.AR_Default_Renewal_Term__c != null ? assst.account.AR_Default_Renewal_Term__c.toPlainString() : 'NA');//CRM-2559
                    String accountBillingPeriod = FindBillingPeriod(accountDefaultRenewalTerm,assst.Billing_Period__c); //CRM-2559
                    String productDefaultRenewalTerm = (assst.Product2.DefaultRenewalTerm__c != null ? assst.Product2.DefaultRenewalTerm__c : 'NA'); //CRM-2559
                    String productBillingPeriod = FindBillingPeriod(productDefaultRenewalTerm,assst.Billing_Period__c); //CRM-2559
                    String accountBodyTag = ''; //CRM-2559 added 
                    String productBodyTag = ''; //CRM-2559 added 
                    
                    //CRM-3846 Start if AMLC = 0, then default renewal term = 6. Billing Period = Monthly if Asset Billing Period = Monthly else Bi-Annual
                    if (AccAMLC == false && assst.Product2.ProductCode == 'ADVANTAGE')
                    {
                    	accountDefaultRenewalTerm = System.label.DefaultAMLC0ContractTerm;
                    	productDefaultRenewalTerm = System.label.DefaultAMLC0ContractTerm;
                    	accountBillingPeriod = FindBillingPeriod(System.label.DefaultAMLC0ContractTerm,assst.Billing_Period__c); //CRM-2559
                    	productBillingPeriod = FindBillingPeriod(System.label.DefaultAMLC0ContractTerm,assst.Billing_Period__c); //CRM-2559
                    	system.debug('accountBillingPeriod: '+accountBillingPeriod+'  productBillingPeriod:'+productBillingPeriod);
                    }
                	//CRM-3846 Start if AMLC = 0, then default renewal term = 6. Billing Period = Monthly if Asset Billing Period = Monthly else Bi-Annual
                    
                    for(String Str: PriceInfo){
                        system.debug('--- for each str --> '+str);
                        List<String> PrcInf = str.split('\\^');//CRM-2559
                        String ar_contractTerm = PrcInf[0]; //CRM-2559
                        String ar_billingPeriod = PrcInf[PrcInf.size()-1]; //CRM-2559
                        if(ar_contractTerm == accountDefaultRenewalTerm && ar_billingPeriod == accountBillingPeriod) {  //CRM-2559 changed the condition
                            system.debug('-- inside account contract term --> ');
                            accountBodyTag = accountBodyTag+'<bm:contractTerms_line>'+(ar_contractTerm != null ? ar_contractTerm : '')+'</bm:contractTerms_line>'; //CRM-2559 changed to accountbodytag, changed contractTerm field
                            accountBodyTag = accountBodyTag+'<bm:billingPeriod_line>'+ar_billingPeriod+'</bm:billingPeriod_line>';      //CRM-2559 changed to accountbodytag   added billingPeriod                  
                            accountBodyTag = accountBodyTag+'<bm:originalListPrice_line>'+(PrcInf[1] != null ? formatString(PrcInf[1]) : '') +'</bm:originalListPrice_line>'; //CRM-2559 changed to accountbodytag //CRM- 2536 changed the tag to originalListPrice_line
                            accountBodyTag = accountBodyTag+'<bm:autoRenewPromotion_line>'+(PrcInf[4] != null ? formatString(PrcInf[4]) : '')+'</bm:autoRenewPromotion_line>'; //CRM-2559 changed to accountbodytag           
                            accountBodyTag = accountBodyTag+'<bm:override_line>'+(PrcInf[5] != null ? formatString(PrcInf[5]) : '')+'</bm:override_line>'; //CRM-2559 changed to accountbodytag
                            accountBodyTag = accountBodyTag+'<bm:strategicDiscount_line>'+(PrcInf[7] != null ? formatString(PrcInf[7]) : '')+'</bm:strategicDiscount_line>'; //CRM-2490 added the tag //CRM-2559 changed to accountbodytag
                            accountBodyTag = accountBodyTag+'<bm:strategicDiscountPercent_line>'+(PrcInf[8] != null ? formatString(PrcInf[8]) : '')+'</bm:strategicDiscountPercent_line>'; //CRM-2490 //CRM-2559 changed to accountbodytag
                            break; //CRM-2559 added (breaks out of for loop)
                        }
                        if(ar_contractTerm == productDefaultRenewalTerm && ar_billingPeriod == productBillingPeriod) { //CRM-2559 added 
                            system.debug('-- inside product contract term --> ');

                            productBodyTag = productBodyTag+'<bm:contractTerms_line>'+(ar_contractTerm != null ? ar_contractTerm : '')+'</bm:contractTerms_line>'; //CRM-2559 added 
                            productBodyTag = productBodyTag+'<bm:billingPeriod_line>'+ar_billingPeriod+'</bm:billingPeriod_line>';      //CRM-2559 added                 
                            productBodyTag = productBodyTag+'<bm:originalListPrice_line>'+(PrcInf[1] != null ? formatString(PrcInf[1]) : '') +'</bm:originalListPrice_line>'; //CRM-2559 added //CRM- 2536 changed the tag to originalListPrice_line
                            productBodyTag = productBodyTag+'<bm:autoRenewPromotion_line>'+(PrcInf[4] != null ? formatString(PrcInf[4]) : '')+'</bm:autoRenewPromotion_line>';    //CRM-2559 added            
                            productBodyTag = productBodyTag+'<bm:override_line>'+(PrcInf[5] != null ? formatString(PrcInf[5]) : '')+'</bm:override_line>'; //CRM-2559 added 
                            productBodyTag = productBodyTag+'<bm:strategicDiscount_line>'+(PrcInf[7] != null ? formatString(PrcInf[7]) : '')+'</bm:strategicDiscount_line>'; //CRM-2559 added 
                            productBodyTag = productBodyTag+'<bm:strategicDiscountPercent_line>'+(PrcInf[8] != null ? formatString(PrcInf[8]) : '')+'</bm:strategicDiscountPercent_line>'; //CRM-2559 added 
                        }
                    }
                    AccAMLC = false;
                    //CRM-2559 added the whole if else
                    if(accountBodyTag != ''){
                        system.debug('account tag '+accountBodyTag);
                        body = body+accountBodyTag; 
                    }else if(productBodyTag != ''){
                        system.debug('product tag '+productBodyTag);
                        body = body+productBodyTag;
                    }
           }
           return body;
}

private static String getAssetDetails(Asset assst){
     String fulfilltoExternalid = '';
     String MarketKeyfulfill = '';
     String body = '';
      if(assst.Assets__r.size()>0){fulfilltoExternalid = assst.Assets__r[0].External_ID__c ;MarketKeyfulfill = assst.Assets__r[0].Market_Key__c;}

            body = body+'<bm:assetDetails_line>#'+assst.Product2.ProductCode+'#'+Integer.valueof(assst.Quantity)+'#'+(assst.Total_Net__c != null ? String.valueOf(assst.Total_Net__c) : '')+'#'+assst.id+'#';
            body = body+(assst.Start_Date__c+'').replace(' 00:00:00','')+'#'+(assst.End_Date__c+'').replace(' 00:00:00','')+'#'+(assst.Lead_Type__c != null ? assst.lead_type__c : '' )+'#'+(assst.product_Type__c != null ? Assst.product_Type__c : '')+'#';
            body = body+(assst.market__c != null ? assst.market__c : '')+'#'+assst.Product2.DefaultRenewalTerm__c+'#'+(assst.Billing_Period__c != null ? assst.Billing_Period__c : '')+'#';
            body = body+''+'#';
            body = body+(assst.Discount_Type__c != null ? assst.Discount_Type__c : '')+'#'+FormatString(assst.Commerce_Group__c != null ? assst.Commerce_Group__c : '')+'#';
            body = body+FormatString(assst.Broker_Plan_Affiliation__c != null ? assst.Broker_Plan_Affiliation__c : '')+'#'+(assst.Product_Email__c != null ? assst.Product_Email__c : '');
            body = body+'#'+(assst.Participants__c != null ? assst.Participants__c : '')+'#'+(assst.License_Tier_Range__c != null ? assst.License_Tier_Range__c : '');
            body = body+'#'+(assst.Top_Connector__c != null ? assst.Top_Connector__c+'' : '')+'#'+(assst.Featured_Mortgage__c != null ? assst.Featured_Mortgage__c+'' : '')+'#'+(assst.HLC_Override__c != null ? assst.HLC_Override__c+'' : '')+'#';//
            body = body+(assst.Status != null ? assst.Status : '')+'#'+(assst.Zoura_Product_Rate_Plan_Charge_Id__c != null ? assst.Zoura_Product_Rate_Plan_Charge_Id__c : '')+'#';
            body = body+(assst.Zoura_Id__c != null ? assst.Zoura_Id__c : '')+'#'+(assst.Subscription_Id__c != null ? assst.Subscription_Id__c : '')+'#';
            body = body+(assst.Market_Tier__c != null ? assst.Market_Tier__c+'' : '')+'#'+(assst.ZuoraProductRatePlanId__c != null ? assst.ZuoraProductRatePlanId__c : '')+'#';
            body = body+(assst.List_Price__c != null ? assst.List_Price__c +'' : '')+'#'+(assst.External_ID__c != null ? assst.External_ID__c : '')+'#';
            body = body+(assst.Term_Start_Date__c!= null ? assst.Term_Start_Date__c+'' : '')+'#'+(assst.Subscription_End_Date__c != null ? assst.Subscription_End_Date__c+'' : '')+'#';      
            body = body+(assst.HLC__c != null ? assst.HLC__c +'' : '')+'#';
            body = body+fulfilltoExternalid +'#';
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
            body = body+(assst.CustResp_Contract_Term__c != null ? assst.CustResp_Contract_Term__c +'':'')+'#'; //CRM-2390
            body = body+(assst.CustResp_List_Price__c != null ? assst.CustResp_List_Price__c +'':'')+'#'; //CRM-2390
            body = body+(assst.CustResp_Promotion__c != null ? formatString(assst.CustResp_Promotion__c) +'':'')+'#'; //CRM-2390
            body = body+(assst.CustResp_Promo_age__c != null ? assst.CustResp_Promo_age__c +'':'')+'#'; //CRM-2390
            body = body+(assst.CustResp_Spot_Promotion__c != null ? formatString(assst.CustResp_Spot_Promotion__c) +'':'')+'#'; //CRM-2390
            body = body+(assst.CustResp_Renewal_Option__c != null ? assst.CustResp_Renewal_Option__c +'':'')+'#'; //CRM-2390
            body = body+(assst.CustResp_AutoOrder__c != null ? assst.CustResp_AutoOrder__c +'':'')+'#'; //CRM-2390
            body = body+(assst.CustResp_AR_Strategic_Promotion_code__c != null ? formatString(assst.CustResp_AR_Strategic_Promotion_code__c) +'':'')+'#'; //CRM-2390
            body = body+(assst.CustResp_AR_Strategic_Promotion_age__c != null ? formatString(assst.CustResp_AR_Strategic_Promotion_age__c +''):'')+'#'; //CRM-2390
            body = body+(ARasstMap.containsKey(assst.Id) && ARasstMap.get(assst.Id).AR_Price_Info__c != null ? ARasstMap.get(assst.Id).AR_Price_Info__c.replace('#','**') +'':'')+'#'; //CRM-2390 
            body = body+(ARasstMap.containsKey(assst.Id) && ARasstMap.get(assst.Id).AR_Renewal_Price_Tier__c != null ? ARasstMap.get(assst.Id).AR_Renewal_Price_Tier__c +'':'')+'#'; //CRM-2390 
            body = body+(assst.Spot_Promo_Code__c != null ? formatString(assst.Spot_Promo_Code__c) +'':'')+'#'; //CRM-2390
            body = body+(assst.Spot_Promo_Percentage__c != null ? formatString(assst.Spot_Promo_Percentage__c +''):'')+'#'; //CRM-2390
            body = body+'</bm:assetDetails_line>';
            return body;
}
    
    private static String getCustomerResponseTags(Asset assst, String billingPeriod){
        String body = '';
        body = body + '<bm:originalListPrice_line>'+(assst.CustResp_List_Price__c != null ? assst.CustResp_List_Price__c : 0.00)+'</bm:originalListPrice_line>';
                    body = body+'<bm:contractTerms_line>'+(assst.CustResp_Contract_Term__c != null ? assst.CustResp_Contract_Term__c : '')+'</bm:contractTerms_line>';
                    if(assst.CustResp_Renewal_Option__c == 'Renew') 
                        billingperiod = 'Monthly';
                    else
                        billingperiod = '';
                    body = body+'<bm:billingPeriod_line>'+FindBillingPeriod(assst.CustResp_Contract_Term__c,billingperiod)+'</bm:billingPeriod_line>';                    
                    body = body+'<bm:autoRenewPromotion_line>'+(assst.CustResp_Promotion__c != null ? formatString(assst.CustResp_Promotion__c) : '')+'</bm:autoRenewPromotion_line>';                
                    body = body+'<bm:override_line>'+(assst.CustResp_Promo_age__c != null ? assst.CustResp_Promo_age__c : 0.00)+'</bm:override_line>';
                    body = body+'<bm:spotDiscount_line>'+(assst.CustResp_Spot_Promotion__c != null ? formatString(assst.CustResp_Spot_Promotion__c) : '')+'</bm:spotDiscount_line>';
                    body = body+'<bm:Apply_Spot_Promo_line>'+(assst.CustResp_AppliesSpotPromo__c != null ? assst.CustResp_AppliesSpotPromo__c : '')+'</bm:Apply_Spot_Promo_line>';
                    body = body+'<bm:strategicDiscount_line>'+(assst.CustResp_AR_Strategic_Promotion_code__c != null ? formatString(assst.CustResp_AR_Strategic_Promotion_code__c) : '')+'</bm:strategicDiscount_line>'; //CRM-2490
                    body = body+'<bm:strategicDiscountPercent_line>'+(assst.CustResp_AR_Strategic_Promotion_age__c != null ? assst.CustResp_AR_Strategic_Promotion_age__c : 0.00)+'</bm:strategicDiscountPercent_line>'; //CRM-2490
                        
        return body;
    }
    //CRM-3261: Sending Asset AR Association fields
    private static String ARconfigOptions(Asset_AR_Association__c arassst){
        String body = '';
        String co = (arassst.AR_Config_Options__c +'').replace(' ','');
        String co1 = co.replace('AR_Config_Options__c','');
        String co2 = co1.replace(';','~');
        System.debug(co2+'optionline');
        if(co2.length()>0){
            System.debug(co2+'optionline');
            body = body+'<bm:selectOption_line>'+co2+'</bm:selectOption_line>';
        }
    
        return body;
    }
    
//CRM-3261: Sending Asset AR Association fields
private static String conditionalTags(Asset assst){
    String body = '';
        if(ARasstMap.containsKey(assst.Id)) {
            if(ARasstMap.get(assst.Id).AR_Config_Options__c!=null){body += ARconfigOptions(ARasstMap.get(assst.Id));}
            body = body+'<bm:residentialLeadPPL_line>'+(ARasstMap.get(assst.Id).AR_Lead_PPL__c!= null ? ARasstMap.get(assst.Id).AR_Lead_PPL__c+'':'')+'</bm:residentialLeadPPL_line>';
            body = body+'<bm:residentialBrandPPL_line>'+(ARasstMap.get(assst.Id).AR_Brand_PPL__c!= null ? ARasstMap.get(assst.Id).AR_Brand_PPL__c+'':'')+'</bm:residentialBrandPPL_line>';
            body = body+'<bm:residentialALC_line>'+(ARasstMap.get(assst.Id).AR_AMLC_Residential__c!= null ? ARasstMap.get(assst.Id).AR_AMLC_Residential__c+'':'')+'</bm:residentialALC_line>';
            body = body+'<bm:landALC_line>'+(ARasstMap.get(assst.Id).AR_AMLC_Land__c!= null ? ARasstMap.get(assst.Id).AR_AMLC_Land__c+'':'')+'</bm:landALC_line>';
            body = body+'<bm:rentalALC_line>'+(ARasstMap.get(assst.Id).AR_AMLC_Rental__c!= null ? ARasstMap.get(assst.Id).AR_AMLC_Rental__c+'':'')+'</bm:rentalALC_line>';
            body = body+'<bm:pPLOverride_line>'+(ARasstMap.get(assst.Id).AR_PPL_Override__c!= null ? ARasstMap.get(assst.Id).AR_PPL_Override__c+'':'')+'</bm:pPLOverride_line>';            
        } //CRM-3733: Commented out below lines for AR.       
        //if(assst.ContractedAMLC__c!=null){body = body+'<bm:contractedALC_line>'+assst.ContractedAMLC__c+'</bm:contractedALC_line>';}
        if(assst.DecommissionedAsset__c!=null){body = body+'<bm:decommissionedAssetID_line>'+assst.DecommissionedAsset__c+'</bm:decommissionedAssetID_line>';}
        //if(assst.AMLCOverride__c!=null){body = body+'<bm:aMLCOverride_line>'+assst.AMLCOverride__c+'</bm:aMLCOverride_line>';}
        if(assst.undersoldMarket__c!=null){body = body+'<bm:undersoldAsset_line>'+assst.undersoldMarket__c+'</bm:undersoldAsset_line>';}           
        if(assst.Cost_Per_Action__c!=null){body = body+'<bm:costPerAction_line>'+assst.Cost_Per_Action__c+'</bm:costPerAction_line>';}
        if(assst.PricePerImpressionSold__c != null){body = body+'<bm:pricePerImpressionSold_line>'+assst.PricePerImpressionSold__c+'</bm:pricePerImpressionSold_line>';} 
        if(assst.Last_Order_Activity_Date__c!=null){body = body+'<bm:assetLastModifiedDate_line>'+(assst.Last_Order_Activity_Date__c+'').replace(' ','T')+'.000Z'+'</bm:assetLastModifiedDate_line>';}         
        if(assst.CustResp_AutoOrder__c == 'Yes'){body += getCustomerResponseTags(assst, '');}else{body += getAutoSubmitTags(ARasstMap, assst);}

    return body;
}

private static String mandatoryTags(Asset assst){
    String body = '';
            body = body+'<bm:contractEndDate_l>'+(assst.End_Date__c != null ? (assst.End_Date__c+'') : '')+'</bm:contractEndDate_l>';
            body = body+'<bm:campaignId_line>'+(assst.CampaignId__c != null && assst.CampaignId__c != '' ? assst.CampaignId__c : '')+'</bm:campaignId_line>';          
            body = body+'<bm:forecastedLeads_line>'+assst.Monthly_Contracted_Units__c+'</bm:forecastedLeads_line>';
            body = body+'<bm:contractedImpressions_line>'+assst.Contractedimpressions__c+'</bm:contractedImpressions_line>';
            body = body+'<bm:assetID_l>'+assst.id+'</bm:assetID_l>';
            body = body+'<bm:assetNumber>'+assst.Asset_Number__c+'</bm:assetNumber>'; //Ravi CRM-1772 Add Asset Number to Line Item
            body = body+'<bm:leadType_line>'+(assst.Lead_Type__c != null ? assst.Lead_Type__c.remove(' Follow-up') : '')+'</bm:leadType_line>';
            body = body+'<bm:productType_line>'+(assst.Product_Type__c != null ? assst.product_Type__c : '')+'</bm:productType_line>';
            body = body+'<bm:contractStartDate_l>'+(assst.Start_Date__c != null ? (assst.Start_Date__c+'') : '')+'</bm:contractStartDate_l>';
            body = body+'<bm:externalID_line>'+getExternalId(assst)+'</bm:externalID_line>';
            body = body+'<bm:renewalStatus_line>'+(assst.Renewal_Status__c != null ? assst.Renewal_Status__c : '')+'</bm:renewalStatus_line>';
            body = body+'<bm:commerceGroup_line></bm:commerceGroup_line>';
            body = body+'<bm:productEmail_line>'+(assst.Product_Email__c != null ? assst.Product_Email__c : '')+'</bm:productEmail_line>';
            body = body+'<bm:topConnector_line>'+assst.Top_Connector__c+'</bm:topConnector_line>';
            body = body+'<bm:featuredMortgage_line>'+assst.Featured_Mortgage__c+'</bm:featuredMortgage_line>';
            body = body+'<bm:mSATier_line>'+(assst.MSA_Tier__c != null ? assst.MSA_Tier__c : '')+'</bm:mSATier_line>';
            body = body+'<bm:hlcOverride_line>'+(assst.HLC_Override__c != null ? assst.HLC_Override__c+'' : '')+'</bm:hlcOverride_line>';
            body = body+'<bm:license_line>'+(assst.License_Tier__c != null ? String.valueOf(assst.License_Tier__c) : '')+'</bm:license_line>';
            body = body+'<bm:assetFlag_l>true</bm:assetFlag_l>';
            body = body+'<bm:marketType_line/>';
            body = body+'<bm:originalAssetStructure_line>'+(assst.Asset_Structure__c != null ? assst.Asset_Structure__c : '')+'</bm:originalAssetStructure_line>';
            body = body+'<bm:priceTier_line>'+(assst.Market_Tier__c != null ? String.valueof(assst.Market_Tier__c) : '')+'</bm:priceTier_line>';
            body = body+'<bm:accountCategory_line>'+(assst.Category__c != null ? assst.Category__c +'' : '')+'</bm:accountCategory_line>';
            body = body+'<bm:hLC_line>'+(assst.HLC__c != null ? assst.HLC__c +'' : '')+'</bm:hLC_line>';
            body = body+'<bm:marketCode_line>'+(assst.Market_Code__c != null ? assst.Market_Code__c +'' : '')+'</bm:marketCode_line>';
            body = body+'<bm:marketZip_line>'+ (assst.Market__c != null ? assst.Market__c : '') +'</bm:marketZip_line>';
            body = body+'<bm:suppressWelcomeCalls_line>'+assst.Suppress_Welcome_Calls__c+'</bm:suppressWelcomeCalls_line>';
            body = body+'<bm:priceEffectiveDate_line/>';
            body = body+'<bm:createBrokerTools_line>'+assst.Create_Broker_Tools__c+'</bm:createBrokerTools_line>';
            body = body+'<bm:subscriptionStartDate_line>'+ (assst.Term_Start_Date__c!= null ? (assst.Term_Start_Date__c+'') : '')+'</bm:subscriptionStartDate_line>';
            body = body+'<bm:subscriptionEndDate_line>'+(assst.Subscription_End_Date__c != null ? (assst.Subscription_End_Date__c+'') : '')+'</bm:subscriptionEndDate_line>';
            body = body+'<bm:zuoraProductRatePlanChargeID_line>'+(assst.Zoura_Product_Rate_Plan_Charge_Id__c != null ? (assst.Zoura_Product_Rate_Plan_Charge_Id__c+'') : '')+'</bm:zuoraProductRatePlanChargeID_line>';
            body = body+'<bm:zuoraRatePlanID_line>'+(assst.ZuoraProductRatePlanId__c != null ? (assst.ZuoraProductRatePlanId__c+'') : '')+'</bm:zuoraRatePlanID_line>';
            body = body+'<bm:zuoraSubscriptionID_line>'+(assst.Subscription_Id__c != null ? (assst.Subscription_Id__c+'') : '')+'</bm:zuoraSubscriptionID_line>';
            body = body+'<bm:zuoraAmendmentID_line>'+(assst.Zoura_Id__c != null ? (assst.Zoura_Id__c+'') : '')+'</bm:zuoraAmendmentID_line>';
            body = body+ getAssetDetails(assst);

            return body;
}

public static String getLoginReq(String username, String password){
     String body ='<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">';
        body = body+'<soapenv:Header>';
        body = body+'<bm:category xmlns:bm="urn:soap.bigmachines.com">Security</bm:category>';
        body = body+'<bm:xsdInfo xmlns:bm="urn:soap.bigmachines.com">';
       body = body+'<bm:schemaLocation>'+ARIICPQCalls.BMUrl +'/schema/v1_0/security/Security.xsd</bm:schemaLocation>';
        body = body+'</bm:xsdInfo>';
        body = body+'</soapenv:Header>';
        body = body+'<soapenv:Body>';
        body = body+'<bm:login xmlns:bm="urn:soap.bigmachines.com">';
        body = body+'<bm:userInfo>';
        if(username!=null && password!=null){
            body = body+'<bm:username>'+username+'</bm:username>';
            body = body+'<bm:password>'+password+'</bm:password>';
        } else {
           body = body+'<bm:username>'+ARIICPQCalls.BMUserName +'</bm:username>';
           body = body+'<bm:password>'+ARIICPQCalls.BMUserPassword +'</bm:password>';
        }
        body = body+'<bm:sessionCurrency/>';
        body = body+'</bm:userInfo>';
        body = body+'</bm:login>';
        body = body+'</soapenv:Body>';
        body = body+'</soapenv:Envelope>';
        return body;
}

private static Map<Id,Asset> getAssetsMap(String AccountId, Set<Id> setAssetIds){
     Integer lineNumber = 2;
     mapAllAssets = new Map<Id,Asset>([Select account.AR_Default_Renewal_Term__c, Spot_Promo_Code__c, Spot_Promo_Percentage__c, Id,Asset_Number__c,LastModifiedDate,Manual_Discount_Type__c,Last_Order_Activity_Date__c,
                                                        Last_Activity_Date__c,Category__c, CampaignId__c,Market_Code__c, Period_Start_Day__c ,Next_Charge_Date__c,
                                                        Renewal_Status__c,Price_Effective_Date__c,Manual_Discount_Amount__c,Override_Term__c,status ,
                                                        Term_Start_Date__c,Term_End_Date__c,Fulfillment_Status__c,HLC__c ,Manual_Override_Amount__c,
                                                        Name,Subscription_Id__c,ZuoraProductRatePlanId__c,Zoura_Id__c,Subscription_Start_Date__c,
                                                        Subscription_End_Date__c,Zoura_Product_Rate_Plan_Charge_Id__c,Start_Date__c,List_Price__c,
                                                        End_Date__c,Total_Net__c,Asset_Structure__c,Order_Line_Item__r.Asset_Structure__c,Product_Email__c,
                                                        Market_Tier__c,Featured_Mortgage__c,Extended_Net_Price__c,MSA_Tier__c,Suppress_Welcome_Calls__c,
                                                        Create_Broker_Tools__c,Broker_Plan_Affiliation__c,License_Tier__c,HLC_Override__c,Top_Connector__c,
                                                        Commerce_Group__c,Contract_Term__c,Billing_Period__c,Promotion__c,Discount_Type__c,
                                                        Total_List_Price__c,External_ID__c, CustResp_List_Price__c, CustResp_Total_Net__c, CustResp_Renewal_Option__c,
                                                        CustResp_Contract_Term__c, CustResp_Promotion__c, CustResp_Promo_age__c, CustResp_Spot_Promotion__c,
                                                        CustResp_Spot_Promotion_age__c, CustResp_AppliesSpotPromo__c, CustResp_AutoOrder__c,
                                                        Renewal_End_Date__c,Product2.ProductCode,Product2.DefaultRenewalTerm__c,Quantity,Lead_Type__c,Product_Type__c,Market_Zip__c,Market__c,
                                                        Price,Renewal_Start_Date__c,PricePerImpressionSold__c,Monthly_Contracted_Units__c,
                                                        ConfigOptions__c,ResidentialLeadPPL__c ,ResidentialBrandPPL__c ,ResidentialAMLC__c ,
                                                        LandAMLC__c ,RentalAMLC__c ,ContractedAMLC__c ,DecommissionedAsset__c  ,AMLCOverride__c ,PPLOverride__c ,undersoldMarket__c,
                                                        Contractedimpressions__c, (select Market_Key__c,External_ID__c FROM Assets__r where Asset_Type__c = 'Fulfill To') from Asset where Accountid=:AccountId and Asset_Type__c='Parent' and Id=:setAssetIds  and Quantity>0]);
       
       for(Asset a: mapAllAssets.values()){
           mapAssetIDDocumentNumber.put(a.id, lineNumber);
           lineNumber++;
       }
       return mapAllAssets;
}

private static Map<Id, Asset_AR_Association__c> getARMap(Set<Id> assetIds){
    ARasstMap = new Map<Id, Asset_AR_Association__c>();
        for(Asset_AR_Association__c ARasst: [Select Id, AR_Renewal_Price_Tier__c, Asset_Id__c, AR_Price_Info__c, AR_Lead_PPL__c, AR_Config_Options__c,
                                                AR_AMLC_Land__c, AR_AMLC_Rental__c, AR_AMLC_Residential__c, AR_Brand_PPL__c, AR_PPL_Override__c
                                                from Asset_AR_Association__c 
                                                where Asset_Id__c IN: assetIds]){
            ARasstMap.put(ARasst.Asset_Id__c, ARasst);
        }

     return ARasstMap;
}


}