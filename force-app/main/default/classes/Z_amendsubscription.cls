//CRM-3453 Cancel subscripitons From Case
//CRM-3328 Zuora Process to Suspend and Resume all Active Current CoBroke Subscriptions.
public class Z_amendsubscription{
    
    public static Zuora.zApi zApi; 
    public static Zuora.ZApi zuoraApiAccess(){
        system.debug('Login');
        zApi = new Zuora.ZApi();
        try {
            Zuora.ZApi.LoginResult loginResult = (!Test.isRunningTest()) ? zApi.zLogin() : new Zuora.ZApi.LoginResult();  
        } catch (Exception ex) {
            System.debug(' Login to Zuora failed. Message: '+ex.getMessage()+' Stacktrace: '+ex.getStackTraceString());
            throw ex;
        }
        return zApi;
    }
    
    public static string createAmendment(String name, String SubscriptionId, String Effectivedate, String Description, String Type , String Source){     
        Zuora.zObject amendment = new Zuora.zObject('Amendment');
        system.debug('--Amendment-- '+name+' == '+SubscriptionId+' == '+Effectivedate+' == ' +Description + ' == '+Type);
        amendment.setValue('ContractEffectiveDate', Effectivedate);
        amendment.setValue('Description', Description);
        if(Type == 'ResumeSubscription'){
            amendment.setValue('ResumeDate', Effectivedate);
        }
        else if(Type == 'SuspendSubscription'){
            amendment.setValue('SuspendDate', Effectivedate);
        }
        else if(Type == 'Cancellation'){
        amendment.setValue('EffectiveDate', Effectivedate);
        }
        amendment.setValue('Name', name);       
        amendment.setValue('Status', 'Completed');
        amendment.setValue('SubscriptionId', SubscriptionId);
        amendment.setValue('Type', Type);
        Zuora.zApi.AmendResult result = new Zuora.zApi.AmendResult();       
        List<Zuora.zObject> amendmentstoProcess = new List<Zuora.zObject>();
        amendmentstoProcess.add(amendment);
        String ErrorMessage;
        Boolean ErrorStatus;
        try{
            result = amendApiCall(amendmentstoProcess);
        }catch(Exception ex){                     
            ErrorMessage ='Exception Occured while performing Amendment(Resume/Suspend/Cancel) Exception Message: '+ex.getMessage()+' Stacktrace: '+ex.getStackTraceString()+' Subscription Id: '+SubscriptionId;               
            return ErrorMessage;
        }
        
        system.debug('<-- Amendment Result --> '+result);
        string new_subscriptionId;
        if(result.success){
             new_subscriptionId = result.SubscriptionId; 
            if(Source == 'Moving'){
               ErrorMessage = 'Successfully Cancelled the subscription '+ name; 
            }else{                          
            ErrorMessage = new_subscriptionId;           
            system.debug('<-- Amendment Result success --> ' +ErrorMessage);
            }
            return ErrorMessage;
            
        }else{           
            ErrorMessage = 'Failed to amend Subscription :'+name+' Error Message ';
            List<Zuora.Zobject> Errorresponse= result.Errors;
            for(Zuora.zobject rec:  Errorresponse){
                //ErrorMessage+='\n';
                ErrorMessage+=rec.getvalue('Message');
            }
            system.debug('<-- Amendment Result fail--> '+ErrorMessage);
            return ErrorMessage;
        }
    } 
    
    public static Zuora.zApi.AmendResult amendApiCall(List<Zuora.zObject> amendment){
        system.debug('<--zApi Result--> '+zApi );        
        Zuora.zApi.AmendRequest amendRequest = new Zuora.zApi.AmendRequest(); 
        Zuora.zObject[] amendments = amendment;
        amendRequest.amendments = amendments;
        
        Zuora.zApi.AmendOptions amendmentOption = new Zuora.zApi.AmendOptions();
        amendmentOption.GenerateInvoice = false;
        amendmentOption.ProcessPayments = false;
        Zuora.zApi.PreviewOptions PreviewOptions = new Zuora.zApi.PreviewOptions();
        PreviewOptions.EnablePreviewMode = false;                
        amendRequest.amendOptions = amendmentOption;
        system.debug('<---Z AmendRequest --> '+amendRequest);
        
        Zuora.zApi.AmendResult result = new Zuora.zApi.AmendResult();
        if(!test.isRunningTest()){                            
                result = ZApi.zamend(new List < Zuora.zApi.AmendRequest > {amendRequest});                      
       }else{
            result.success = true;
       }
        
        return result;
    }      
    
    // CRM-5709 - Function amend subscription as per fieldvalues given
    public static String amendSubscription(String subscriptionId, Map<String, Object> fieldValues) {
        String error = null;
        try {
            if (zApi == null) {
                zuoraApiAccess();
            }
            Zuora.zObject amendment = new Zuora.zObject('Amendment');
            amendment.setValue('SubscriptionId', subscriptionId);
            for (String field : fieldValues.keySet()) {
                amendment.setValue(field, fieldValues.get(field));
            }
            Zuora.zApi.AmendResult result = amendApiCall(new List<Zuora.zObject>{amendment});
            if (!result.success) {
                error = 'Failed to update subscription with Id - ' + subscriptionId + '. Error: ';
                for(Zuora.zobject rec:  result.Errors){
                    error += rec.getvalue('Message') + ' ';
                }
            }
        }
        catch (Exception e) {
            error = e.getMessage()+' Stacktrace: '+ e.getStackTraceString();
        }
        return error;
    }
    // CRM-5709 - ENd
}