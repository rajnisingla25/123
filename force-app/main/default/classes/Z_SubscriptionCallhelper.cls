//LCM-49 Create subscription record in Zuora application.
public class Z_SubscriptionCallhelper{
    public static Zuora.zApi zApi;    
    public static List<Zuora.zApi.SubscribeRequest> prepareSubscriptionRequest(String ZuoraAccountId, String CmId, String APRPID, String APRPCD, Decimal Price, Date Termstartdate, String paymentMethod, Boolean isivnseperate) {
        Zuora.zApi.SubscribeRequest request = new Zuora.zApi.SubscribeRequest();
        request.ZAccount = new Zuora.zObject('Account');
        request.ZAccount.setValue('Id', ZuoraAccountId);
        request.SubscribeOptions = createSubscribeOptions(false, false);
        request.SubscriptionData = createSubscriptionData(CmId, APRPID, APRPCD, Price, Termstartdate, paymentMethod,isivnseperate);
        system.debug(' Request@: ' + request);
        return new List <Zuora.zApi.SubscribeRequest> {request };
            }
    public static Zuora.zApi.SubscribeOptions createSubscribeOptions(Boolean generateInvoice, Boolean processPayments) {
        Zuora.zApi.SubscribeOptions so = new Zuora.zApi.SubscribeOptions();
        so.GenerateInvoice = generateInvoice;
        so.ProcessPayments = processPayments;
        return so;
    }
    
    public static Zuora.zApi.SubscriptionData createSubscriptionData(String CmId, String APRPID, String APRPCD, Decimal Price, Date Termstartdate, String paymentMethod, Boolean isivnseperate) {
        Zuora.zApi.SubscriptionData subscribeData = new Zuora.zApi.SubscriptionData();
        List<Zuora.zObject> rplanData= createRatePlanData(APRPID, APRPCD, Price, '');
        Zuora.zObject subscription = new Zuora.zObject('Subscription');
        subscription.setValue('ContractEffectiveDate', getdate(Termstartdate));
        subscription.setValue('CMRelationshipId__c', CmId);
        subscription.setValue('TermType', 'EVERGREEN');
        if(paymentMethod != null && paymentMethod != ''){
        subscription.setValue('PaymentMethodId__c', paymentMethod);
        subscription.setValue('AutoPay__c', 'On');
        }
        subscription.setValue('IsInvoiceSeparate', isivnseperate);
        subscribeData.Subscription = subscription;
        subscribeData.RatePlanData = rplanData;
        return subscribeData;
    }
    
    
    public static List<Zuora.zObject> createRatePlanData(String productRatePlanId, String productRatePlanChargeId, Decimal Price, string subscriptionId) {
        system.debug('---createSubscriptionRatePlanData entered--'+productRatePlanId);
        Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
        ratePlanData.setValue('RatePlan', createRatePlan(productRatePlanId));
        ratePlanData.setValue('RatePlanChargeData', new List < Zuora.zObject > {
            createRatePlanChargeDataForNewProduct(productRatePlanChargeId,Price, subscriptionId)
                });
        return new List < Zuora.zObject > { ratePlanData };
            }
    public static Zuora.zObject createRatePlan(String productRatePlanId) {
        Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
        ratePlan.setValue('ProductRatePlanId', productRatePlanId);
        return ratePlan;
    }
    public static Zuora.zObject createRatePlanChargeDataForNewProduct(String productRatePlanChargeId,Decimal Price, string subscriptionId) {
        Zuora.zObject ratePlanChargeData = new Zuora.zObject('RatePlanChargeData');
        ratePlanChargeData.setValue('RatePlanCharge', createRatePlanCharge(productRatePlanChargeId,Price, subscriptionId));
        return ratePlanChargeData;
    }
    public static Zuora.zObject createRatePlanCharge(String productRatePlanChargeId,Decimal Price, string subscriptionId) {
        Zuora.zObject ratePlanCharge = new Zuora.zObject('RatePlanCharge');
        ratePlanCharge.setValue('ProductRatePlanChargeId', productRatePlanChargeId);
        ratePlanCharge.setValue('Price', Price);
        return ratePlanCharge;
    }
    
    
    Public static Boolean Z_subscribe(List <Zuora.zApi.SubscribeRequest> subscriptionRequests) {
        List < Zuora.zApi.SubscribeResult > subscribeResults = new List < Zuora.zApi.SubscribeResult >(); 
        System.debug('at Z_subscribe: ' + subscriptionRequests.size());
        try{
            if(!test.isrunningtest())
            subscribeResults = zApi.zsubscribe(subscriptionRequests);
        } catch (exception ex){
            throw new errorException(ex.getmessage());   
        }
        for (Zuora.zApi.SubscribeResult result: subscribeResults) {
            system.debug('result@ '+result);
            String message = '';
            if (result.Success) {
            } else {
                Zuora.zObject[] errors = result.errors;
                for (Zuora.zObject error: errors) {
                    String errorCode = (String) error.getValue('Code');
                    message += (String) error.getValue('Message');
                    System.debug(LoggingLevel.Info, 'Zuora: error -- ' + errorCode + ' : ' + message);
                }
                throw new errorException(message);
            }
        }
        return true;
    }
    public class errorException extends Exception {}
    public static Zuora.zObject createAmendment(String name, String subscriptionId, String amendType, date effectivedate) {
        Zuora.zObject amendment = new Zuora.zObject('Amendment');
        system.debug('---createAmendment entered--'+name+'====>'+subscriptionId+'------>'+amendType);
        String processthrough_date = getdate(effectivedate);
        amendment.setValue('ContractEffectiveDate', processthrough_date);
        amendment.setValue('CustomerAcceptanceDate', processthrough_date);
        amendment.setValue('Description', 'new product amendment');
        amendment.setValue('EffectiveDate', processthrough_date);
        amendment.setValue('Name', name);
        amendment.setValue('ServiceActivationDate', processthrough_date);
        amendment.setValue('Status', 'Completed');
        amendment.setValue('SubscriptionId', subscriptionId);
        amendment.setValue('Type', amendType);
        
        return amendment;
    }
    Public static String amendForUpdateProduct(String Name, String AmendmentSubscriptionRatePlanId, String productRatePlanChargeId, Decimal Price, string subscriptionId, Date today) {
        Zuora.zObject amendment = createAmendment(Name, subscriptionId, 'UpdateProduct', today);
        Zuora.zObject ratePlandata =createSubscriptionRatePlanDataforupdateprice(AmendmentSubscriptionRatePlanId);
        Zuora.zObject ratePlanChargeData = createRatePlanChargeData(productRatePlanChargeId, price);
        ratePlandata.setValue('RatePlanChargeData', new List < Zuora.zObject > {
            ratePlanChargeData
                });
        amendment.setValue('RatePlanData', ratePlandata);
        return amendApiCall(new List < Zuora.zObject > { amendment });
    }
    public static Zuora.zObject createSubscriptionRatePlanDataforupdateprice(String amendmentSubscriptionRatePlanId) {
        Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
        ratePlan.setValue('AmendmentSubscriptionRatePlanId', amendmentSubscriptionRatePlanId);
        Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
        ratePlanData.setValue('RatePlan', ratePlan);
        return ratePlanData;
    }
    public static Zuora.zObject createRatePlanChargeData(String productRatePlanChargeId, decimal Price) {
        Zuora.zObject ratePlanCharge = new Zuora.zObject('RatePlanCharge');
        ratePlanCharge.setValue('ProductRatePlanChargeId', productRatePlanChargeId);
        Zuora.zObject ratePlanChargeData = new Zuora.zObject('RatePlanChargeData');
        ratePlanChargeData.setValue('RatePlanCharge', ratePlanCharge);
        ratePlanCharge.setValue('Price', Price);
        return ratePlanChargeData;
    }
    
    Public static String amendForCredit(String Name, String productRatePlanId, String productRatePlanChargeId, Decimal Price, string subscriptionId, Date today){
        Zuora.zObject amendment = createAmendment(Name, subscriptionId, 'NewProduct', today);
        Zuora.zObject ratePlandata =createSubscriptionRatePlanDataforcredit(productRatePlanId);
        Zuora.zObject ratePlanChargeData = createRatePlanChargeData(productRatePlanChargeId, price);
        ratePlandata.setValue('RatePlanChargeData', new List < Zuora.zObject > {
            ratePlanChargeData
                });
        amendment.setValue('RatePlanData', ratePlandata);
        return amendApiCall(new List < Zuora.zObject > { amendment });
    } 
    public static Zuora.zObject createSubscriptionRatePlanDataforcredit(String productRatePlanId) {
        Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
        ratePlan.setValue('ProductRatePlanId', productRatePlanId);
        Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
        ratePlanData.setValue('RatePlan', ratePlan);
        return ratePlanData;
    }
    
    public static string createAmendmentforCancel(String name, String SubscriptionId, Date dt){           
       // Date Effectivedatee = dT.year(), dT.month(), dT.day();
        Zuora.zObject amendment = new Zuora.zObject('Amendment');
        system.debug('--Amendment-- '+name+' == '+SubscriptionId+' == '+dt);
        String Effectivedate = getdate(dt);
        amendment.setValue('ContractEffectiveDate', Effectivedate);
        amendment.setValue('Description', 'Cancelling Subscription');       
        amendment.setValue('EffectiveDate', Effectivedate);
        amendment.setValue('Name', name);       
        amendment.setValue('Status', 'Completed');
        amendment.setValue('SubscriptionId', SubscriptionId);
        amendment.setValue('Type', 'Cancellation');
        return amendApiCall(new List < Zuora.zObject > { amendment });
    }
    public static String amendApiCall(List<Zuora.zObject> amendment) {
        Zuora.zApi.AmendRequest amendRequest = new Zuora.zApi.AmendRequest();
        Zuora.zObject[] amendments = amendment;
        amendRequest.amendments = amendments;
        Zuora.zApi.AmendOptions amendmentOption = new Zuora.zApi.AmendOptions();
        amendmentOption.GenerateInvoice = false;
        amendmentOption.ProcessPayments = false;
        
        amendRequest.amendOptions = amendmentOption;
        system.debug('---amendRequest before zament--'+amendRequest);
        
        Zuora.zApi.AmendResult result = new Zuora.zApi.AmendResult();
        if(!test.isrunningtest()){
        result = zApi.zamend(new List < Zuora.zApi.AmendRequest > { amendRequest});
        }else{
             result.success = true;
             result.SubscriptionId = '1212';
        }
        System.debug('result------>'+result);
        String SubscriptionId = '';
        String ErrorMessage = '';
        if(result.success){
            SubscriptionId  = result.SubscriptionId;               
        }else{                
            List<Zuora.Zobject> Errorresponse= result.Errors;
            for(Zuora.zobject rec:  Errorresponse){                  
                ErrorMessage+=rec.getvalue('Message');
            }
            throw new errorException(ErrorMessage);
        }
        return SubscriptionId;
    }
    public static Zuora.ZApi zuoraApiAccess(){
        system.debug('@@@###Login');
        final String FUNC_STR = 'zuoraApiAccess: ';
        zApi = new Zuora.ZApi();
        try {
            Zuora.ZApi.LoginResult loginResult = (!Test.isRunningTest()) ? zApi.zLogin() : new Zuora.ZApi.LoginResult();  
        } catch (Exception ex) {
            System.debug(FUNC_STR+' Login to Zuora failed. Message: '+ex.getMessage()+' Stacktrace: '+ex.getStackTraceString());
            throw ex;
        }
        return zApi;
    }
   
    Public static String getdate(Date amenddate){  
        String processthrough_date = '';
        string month = '0'+string.valueof(amenddate.month());
        month = month.right(2);
        string day = '0'+string.valueof(amenddate.day());
        day = day.right(2);
        processthrough_date = amenddate.year()+'-'+month+'-'+day;
        return processthrough_date; 
    } 
    
}