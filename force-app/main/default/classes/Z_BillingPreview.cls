/** 
 * Description: This class is a wrapper class to call the BillingPreview SOAP request to Zuora
 */
public class Z_BillingPreview {
    
    public Boolean errorStatus;
    public String errorMessage;
    public Zuora.zApi zApi;

    //Error Messages
    public static final String ERR_MISSING_ACC = 'Zuora Account Id is required';
    public static final String ERR_MISSING_TDATE = 'Target Date is required';

    //Charge Types
    private static final String CTYPE_ONETIME = 'OneTime';
    private static final String CTYPE_RECURRING = 'Recurring';
    private static final String CTYPE_USAGE = 'Usage';
    
    public Z_BillingPreview(){
        this.errorMessage = '';
        this.errorStatus = false;
        this.zApi = new Zuora.zApi();
    }
   
    /**
     * This method will return billing preview for all subscriptions(evergreen, onetime, recurring and usage)
     * for given zuora account id
     * @param zAccId Zuora Account Id
     * @pram targateDate Datetime to calculate charges through for billing preview call
     */
    public ZuoraBillingPreviewapi.BillingPreviewResult[] billingPreview(String zAccId, Date targetDate){
        return billingPreview(zAccId, targetDate, true, false, false, false);
    }

    /**
     * This method will return billing preview for selective subscripitons / charges for given zuora account id
     * @param zAccId Zuora Account Id
     * @pram targateDate Datetime to calculate charges through for billing preview call
     * @param includeEvergreenSub if true then it will include evergeen subscriptions
     * @param excludeOneTime If true then it will exclude OneTime subscription
     * @param excludeRecurring If true then it will exclude Recurring subscription
     * @param excludeUsage If true then it will exclude Usage subscription
     */
    public ZuoraBillingPreviewapi.BillingPreviewResult[] billingPreview(String zAccId, Date targetDate, Boolean includeEvergreenSub, Boolean excludeOneTime, Boolean excludeRecurring, Boolean excludeUsage){
        
        ZuoraBillingPreviewapi.BillingPreviewResult[] billingPreviewResult;
        ZuoraBillingPreviewapi.BillingPreviewResult[] billingPreviewResultList = new List<ZuoraBillingPreviewapi.BillingPreviewResult>();
        ZuoraBillingPreviewapi.BillingPreviewResult billPreviewResultObj = new ZuoraBillingPreviewapi.BillingPreviewResult();
        ZuoraBillingPreviewapi.BillingPreviewRequest[] billingPreviewReqs = new List<ZuoraBillingPreviewapi.BillingPreviewRequest>();
        ZuoraBillingPreviewapi.BillingPreviewRequest req = new ZuoraBillingPreviewapi.BillingPreviewRequest();
        ZuoraBillingPreviewapi.SessionHeader_element sessionElement = new ZuoraBillingPreviewapi.SessionHeader_element();
        ZuoraBillingPreviewapi.Soap soapAPI;

        Set<String> chargeIds = new Set<String>();
        Set<String> subIds = new Set<String>();
        
        if(String.isBlank(zAccId)){
            errorMessage = ERR_MISSING_ACC;
            errorStatus = true;
            System.debug(errorMessage);
            return null;
        }
        
        if (targetDate == null){
            errorMessage = ERR_MISSING_TDATE;
            errorStatus = true;
            System.debug(errorMessage);
            return null;
        }
        
        includeEvergreenSub = (includeEvergreenSub == null) ? true : includeEvergreenSub;
        excludeOneTime = (excludeOneTime == null) ? false : excludeOneTime;
        excludeRecurring = (excludeRecurring == null) ? false : excludeRecurring;
        excludeUsage = (excludeUsage == null) ? false : excludeUsage;

        //Generate charge type exclusion string
        String chargeTypeToExclude = '';
        if (excludeOneTime){
            chargeTypeToExclude = CTYPE_ONETIME;
        }
        if (excludeRecurring){
            chargeTypeToExclude = (excludeOneTime) ? chargeTypeToExclude + ',' + CTYPE_RECURRING : CTYPE_RECURRING;
        }
        if (excludeUsage){
            chargeTypeToExclude = (excludeOneTime || excludeRecurring) ? chargeTypeToExclude + ',' + CTYPE_USAGE : CTYPE_USAGE;
        }
        System.debug('ChargeTypeToExclude:' + chargeTypeToExclude);
        
        req.AccountId = zAccId;
        // CRM-1629 Passing Date value only to billing previewApi
       req.TargetDate = targetDate;
        
        req.ChargeTypeToExclude = chargeTypeToExclude;
        req.IncludingEvergreenSubscription = includeEvergreenSub;
        
        try{
            //add BillingPreviewRequest object
            billingPreviewReqs.add(req);
            soapAPI = setupSoap();
            
            if (!Test.isRunningTest()){
                billingPreviewResult = soapAPI.billingPreview(billingPreviewReqs);
            }else{
                billingPreviewResult = Z_BillingPreviewTest.createTestBillingPreviewResponse();
            }
            
            if(billingPreviewResult != null && !billingPreviewResult.isEmpty()) {
                for( ZuoraBillingPreviewapi.BillingPreviewResult result : billingPreviewResult) {
                    /*System.debug('AccountId:' + result.AccountId);
                    System.debug('Success:' + result.Success);
                    System.debug('Size:' + result.Size);*/
                    ZuoraBillingPreviewapi.Error[] errors = result.Errors;
                    if(errors != null && !errors.isEmpty()){
                        for(ZuoraBillingPreviewapi.Error error: errors){
                            /*System.debug('Error Code:' + error.Code);
                            System.debug('Error Message:' + error.Message);
                            System.debug('Error Field' + error.Field);*/
                            errorMessage = errorMessage + ',' + error.Message;
                        }
                        errorStatus = true;
                        System.debug(errorMessage);
                    }
                    ZuoraBillingPreviewObject.InvoiceItem[] invoiceItems = result.InvoiceItem;
                    if(invoiceItems != null && !invoiceItems.isEmpty()){
                        for(ZuoraBillingPreviewObject.InvoiceItem invItem : invoiceItems){
                            chargeIds.add(invItem.RatePlanChargeId);
                            subIds.add(invItem.SubscriptionId);
                            /*System.debug('InvoiceItemId:' + invItem.Id);
                            System.debug('ChargeAmount:' + invItem.ChargeAmount);
                            System.debug('ChargeDate:' + invItem.ChargeDate);
                            System.debug('ChargeType:' + invItem.ChargeType);
                            System.debug('ProcessingType:' + invItem.ProcessingType);
                            System.debug('Quantity:' + invItem.Quantity);
                            System.debug('RatePlanChargeId:' + invItem.RatePlanChargeId);
                            System.debug('ServiceEndDate:' + invItem.ServiceEndDate);
                            System.debug('ServiceStartDate:' + invItem.ServiceStartDate);
                            System.debug('SubscriptionId:' + invItem.SubscriptionId);
                            System.debug('UOM:' + invItem.UOM);*/
                        }
                    }                    
                }  
                   
                Map<String,String> chargeMap = queryChargeName(chargeIds);
                Map<String,List<Object>> subMap = querySubName(subIds); 
                 
                for (ZuoraBillingPreviewapi.BillingPreviewResult result : billingPreviewResult) {
                    billPreviewResultObj.AccountId = result.AccountId;
                    billPreviewResultObj.Success = result.Success;
                    billPreviewResultObj.Size = result.Size;
                    billPreviewResultObj.Errors = result.Errors;
                    ZuoraBillingPreviewObject.InvoiceItem[] invoiceItems = result.InvoiceItem;
                    if( invoiceItems != null ){
                        for(Integer i=0 ; i<invoiceItems.size(); i++){
                            invoiceItems[i].RatePlanChargeName = chargeMap.get(invoiceItems[i].RatePlanChargeId);
                            List<Object> tmp = subMap.get(invoiceItems[i].SubscriptionId);
                            invoiceItems[i].SubscriptionName = (String)tmp[0];
                            invoiceItems[i].SubscriptionInvoiceSeparately = (Boolean)tmp[1];
                        }
                    }
                    billPreviewResultObj.InvoiceItem = invoiceItems;
                    billingPreviewResultList.add(billPreviewResultObj);
                }            
            }  
        } catch(Exception e){
            System.debug('Exception occured while calling BillingPreview' + e.getStackTraceString());
            errorMessage = e.getMessage();
            errorStatus = true;
        }
         
        return billingPreviewResultList;
    }
    
    /**
     * This method will return Map of RatePlanChargeId and Name
     * @param chargeIds Set of chargeIds from BillingPreviewResult
     */
    public Map<String,String> queryChargeName(Set<String> chargeIds){
        List<String> chargeIdList = new List<String>(chargeIds);
        List<Zuora.zObject> zuoraCharges;
        Map<String,String> chargeMap = new Map<String,String>();
        
        String zoqlQuery = 'SELECT Id, Name FROM RatePlanCharge WHERE Id = ';
        
        try{
            System.debug('Size of chargeIdList:' + chargeIdList.size());
            zuoraCharges = executeQuery(zoqlQuery, chargeIdList);
            
            if (Test.isRunningTest()){
                zuoraCharges = Z_BillingPreviewTest.retrieveTestCharges();
            }

            //Populate map of RatePlanChargeId => Name
            for (Zuora.zObject charge : zuoraCharges) {
                System.debug('Charge Id: '+charge.getValue('Id')+', Name: '+charge.getValue('Name'));
                chargeMap.put((String)charge.getValue('Id'), (String)charge.getValue('Name'));
            }   
        } catch (Exception e) {
            System.debug('Exception occured while querying Charge Name:' + e);
            errorMessage = e.getMessage();
            errorStatus = true;
        }
        
        return chargeMap;
    }

    /**
     * This method will prepare and call executeZoql method. It will return Zuora.zObject
     * @param zoqlQuery Zuora Query
     * @pram objList list of any zuora object
     */
    public List<Zuora.zObject> executeQuery(String zoqlQuery,List<String> objList){
        String zuoraQuery = zoqlQuery;

        //Holds intermediate results
        List<Zuora.zObject>  zObjList =  new  List<Zuora.zObject>();

        //Holds final list of results
        List<Zuora.zObject>  zObjListMaster = new  List<Zuora.zObject>();
        
        for (Integer i = 0; i < objList.size(); i++) {
            //Create first entry in string for every 200 filters
            if(((Math.mod(i, 199) == 1) && i > 199) || i == 0){
                zuoraQuery = zuoraQuery + '\''+ objList[i] +'\' ';
                continue;
            }

            //Regular path of adding filter to string
            zuoraQuery += ' OR Id = \''+objList[i]+'\' ';
            
            //Call Zuora every 200 filters
            if(Math.mod(i, 199) == 0){
                System.debug('zuoraQuery:' + zuoraQuery);
                zObjList = executeZoql(zuoraQuery);

                //Reset query string
                zuoraQuery = zoqlQuery;

                //Add results to final master list
                zObjListMaster.addAll(zObjList);
            }   
        }

        //Call Zuora for any remaining items
        if (!zuoraQuery.equals(zoqlQuery)) {
            System.debug('zuoraQuery outside for loop:' + zuoraQuery);
            zObjList = executeZoql(zuoraQuery);
            zObjListMaster.addAll(zObjList);
        }

        return zObjListMaster;  
    }
    
    /**
     * This method will return result after executing Zoql Query
     * @param strQuery Zuora Query
     */
    public List<Zuora.zObject> executeZoql(String strQuery){
        List<Zuora.zObject>  zObjList;
        
        try {
            Zuora.ZApi.LoginResult loginResult = (!Test.isRunningTest()) ? zApi.zLogin() : new Zuora.ZApi.LoginResult();  
            zObjList = (!Test.isRunningTest()) ? zApi.zQuery(strQuery) : new List<Zuora.zObject>();    
        } catch (Exception e) {
            System.debug('Exception occured while querying Zuora:' + e);
            errorMessage = e.getMessage();
            errorStatus = true;
        }
        
        return zObjList;
    }
    
    /**
     * This method will return Map of SuscriptionId, Name and IsInvoiceSeparate
     * @param chargeIds Set of subIds from BillingPreviewResult
     */
    public Map<String,List<Object>> querySubName(Set<String> subIds) {
        List<String> subIdList = new List<String>(subIds);
        List<Zuora.zObject> zuoraSubs;
        Map<String,List<Object>> subMap = new Map<String,List<Object>>();
        List<Object> tmpSub = new List<Object>();
        
        String zoqlQuery = 'SELECT Id, Name, IsInvoiceSeparate FROM Subscription WHERE Id = ';
        try{
            System.debug('Size of subIdList:' + subIdList.size());
            zuoraSubs = executeQuery(zoqlQuery, subIdList);
            
            if (Test.isRunningTest()){
                zuoraSubs = Z_BillingPreviewTest.retrieveTestSubs();
            }
            
            for (Zuora.zObject sub : zuoraSubs) {
                System.debug('Subscription Id: '+sub.getValue('Id')+', Name: '+sub.getValue('Name')); 
                tmpSub = new List<Object>();
                tmpSub.add((String)sub.getValue('Name'));
                tmpSub.add((Boolean)sub.getValue('IsInvoiceSeparate'));
                subMap.put((String)sub.getValue('Id'), tmpSub);
            }          
        } catch (Exception e) {
            System.debug('Exception occured while querying Subscriptions:' + e);
            errorMessage = e.getMessage();
            errorStatus = true;
        }       

        return subMap;
    }
    
    /**
     * This method is used to setup the Soap object
     */
    public ZuoraBillingPreviewapi.Soap setupSoap() {
        ZuoraBillingPreviewapi.SessionHeader_element sessionElement = new ZuoraBillingPreviewapi.SessionHeader_element();
        ZuoraBillingPreviewapi.Soap soapAPI;
        String endpoint;
        
        try{
            //Set Session from zLogin()
            Zuora.ZApi.LoginResult loginResult = (!Test.isRunningTest()) ? zApi.zlogin() : new Zuora.zApi.LoginResult();
            sessionElement.Session = loginResult.Session;

            //Set endpoint from Zuora Config
            Map<String,Object> zConfig = zqu.zQuoteUtil.getZuoraConfigInformation();
            endpoint = (String)zConfig.get('apiurl__c');
            system.debug('endpoint@' + endpoint );

            //Setup BillingPreviewapi Soap
            soapAPI = new ZuoraBillingPreviewapi.Soap();
            soapAPI.SessionHeader = sessionElement;
            soapAPI.endpoint_x = endpoint;
        } catch(Exception e){
            System.debug('Exception occured while setting Soap object' + e);
            errorMessage = e.getMessage();      
            errorStatus = true;
        }

        return soapAPI;
    }  
}