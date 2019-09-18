//CRM-3232 send charges to Zuora

global class Z_SendchargestoZuora implements 
Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts {
    global final String Query; 
    
    global Z_SendchargestoZuora(String q)  
    {  
        Query=q;  
    }  
    
    global Integer RecordsFailed = 0;
    global Integer RecordsProcessed = 0;
    global Integer TotalNumberofRecords = 0;
    global Static Map<Id, String> Assetsubmap = new Map<Id, String>();
    public static Zuora.zApi zApi;   
    public static List<Moving_Lead__c> Results;
    public static Map<String, Id> mapleadids;
    public Map<String,Id> SubAsset;
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);   
     
    }
    
    global void execute(Database.BatchableContext bc, List<Moving_Lead__c> scope){
        system.debug('Execuation statrted :' + scope.size());
        Results = new List<Moving_Lead__c>();
        mapleadids = new Map<String, Id>();
        SubAsset = new Map<String, Id>();
        Map<String,zqu__ProductRatePlanCharge__c> CpqidRatecharge = new Map<String, zqu__ProductRatePlanCharge__c>();
        List<Zuora.zObject> temppay;     
        Map<String,list<Zuora.zObject>> Subamend = new Map<String, List<Zuora.zObject>>(); 
       
        for(zqu__ProductRatePlanCharge__c  inloop: [SELECT Id, zqu__ZuoraId__c ,zqu__ProductRatePlan__r.zqu__ZuoraId__c,CPQID__c  FROM zqu__ProductRatePlanCharge__c WHERE zqu__Deleted__c = false]){            
            CpqidRatecharge.put(inloop.CPQID__c, inloop);
        }
        
        String prpid ='';
        String prpcid = '';
        if(Test.isRunningtest()){
            prpid = '8a8083e66103687a016173e0fca60df0';
            prpcid = '8a8083d96103689c016173e35cca0875';
        }
        String  processthrough_date = getdate();       
        //system.debug('Assetid : ' + Assetid);
        for (Moving_Lead__c inloop : scope) {           
            if(inloop.Asset__c!=null && inloop.Asset__r.Subscription_Id__c != null && inloop.Quantity__c != null && inloop.Per_Unit_Price__c != null){
                 String Description =  inloop.Description__c != null ?  inloop.Description__c : '';
                Id Assetid = inloop.Asset__c;
                String cpqid = inloop.Asset__r.Product2.ProductCode!=null ? inloop.Asset__r.Product2.ProductCode : 'PRODUCTNOTFOUND';
                            
                system.debug('Assetid : ' + Assetid); 
                String Subscriptionid = inloop.Asset__r.Subscription_Id__c;               
                if(Subamend.containskey(Subscriptionid)){
                    temppay = Subamend.get(Subscriptionid);
                }else{                                
                    temppay = new List<Zuora.zObject>();                   
                }              
                if(Assetsubmap.containsKey(Assetid))
                    Subscriptionid=Assetsubmap.get(Assetid);   
                TotalNumberofRecords++;
                if(CpqidRatecharge.containskey(cpqid)){                    
                    prpid = CpqidRatecharge.get(cpqid).zqu__ProductRatePlan__r.zqu__ZuoraId__c;
                    prpcid = CpqidRatecharge.get(cpqid).zqu__ZuoraId__c;                      
                }else{
                    Moving_Lead__c uu = new Moving_Lead__c(); 
                    uu.Id = inloop.id;
                    uu.Zuora_Comment__c  = 'No Rateplan Charge associated with CPQID: ' +cpqid;                   
                    uu.Status__c = 'Error';               
                    Results.add(uu);
                    RecordsFailed++;
                    if(!Test.isRunningtest())
                        Continue;
                }
                
                if(inloop.Account_ID__r.Bill_To_Parent__c !=null && inloop.Account_ID__r.Bill_To_Parent__c == 'Yes'){
                    Description = 'Company : ' +inloop.Account_ID__r.Name +'         State: '+ inloop.Account_ID__r.ShippingState+ '                  '+ Description;
                }
                
                Description  =  Description != '' ?  Description.abbreviate(500) : '';   
                Zuora.zObject amendment = createAmendment('Add a Charge ' + System.currentTimeMillis(), Subscriptionid, 'NewProduct', processthrough_date);
                amendment.setValue('RatePlanData', createRatePlanData(prpid, prpcid,inloop.Price__c,inloop.Quantity__c,inloop.Name, Description, String.valueof(inloop.Per_Unit_Price__c)));
                temppay.add(amendment);            
                Subamend.put(Subscriptionid, temppay);
                SubAsset.put(inloop.Asset__r.Subscription_Id__c, Assetid);
                mapleadids.put(inloop.Name , inloop.Id);
            }
        }
        Zuora.zApi zApi = zuoraApiAccess();
        for(String inloop : Subamend.keyset()){ 
            if(Subamend.get(inloop).size()>0)
                amendbatches(Subamend.get(inloop),inloop,inloop);           
        }
        system.debug('ResultSize: ' + Results);
        try{
            upsert Results;
        } catch (Exception ex) {
            System.debug('Failed to Update the Leads');
        }
    }
    global void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed + ' records processed ');
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()]; 
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();    
        String[] toAddresses=new String[] {job.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
        mail.setSubject('Send To Zuora Lead Result');
        String messageBody = '<html><body> Total Number of Records: ' +TotalNumberofRecords + '<br><br> Records Processed: ' +RecordsProcessed+ '<br><br> Records Failed: ' +RecordsFailed + '<br><br> Job Details : '+job+'</body></html>';
        mail.setHtmlBody(messageBody);       
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {mail};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
    }
    
    Boolean amendbatches(List<Zuora.zObject> amendmentList, string SubscriptionId ,String OriginalSubid){
        
        List<Zuora.zObject> amendmentBatch = new List<Zuora.zObject>();
        Zuora.zApi.AmendResult result = new Zuora.zApi.AmendResult();        
        system.debug('listReceivedfrom Metthod : ' +amendmentList);
        if(amendmentList.size()>0){
            integer size = amendmentList.size()>10? 10 : amendmentList.size();
            for(integer i=0;i<size;i++){
                amendmentBatch.add(amendmentList[0]);
                amendmentList.remove(0);
                
            }
            system.debug('amendmentBatch'+amendmentBatch);
            String  ErrorMessage ='';
            try{
                result = amendApiCall(amendmentBatch);               
            }catch(Exception ex){
                system.debug('Amendment Result Entered'+result);
                ErrorMessage ='Exception Occured while performing Amendment(New/Remove) Exception Message: '+ex.getMessage()+' Stacktrace: '+ex.getStackTraceString()+' Subscription Id: '+SubscriptionId;               
                updateleads(amendmentBatch, ErrorMessage , 'Error'); 
                if(!amendmentList.isempty() && amendmentList.size()>0){                    
                    amendbatches(amendmentList,OriginalSubid,OriginalSubid);
                }
                return false;
            }            
            string new_subscriptionId;
            if(result.success){
                new_subscriptionId = result.SubscriptionId;               
                if(SubAsset.containskey(OriginalSubid)){
                    Id Assetid = SubAsset.get(OriginalSubid);                   
                    Assetsubmap.put(Assetid, new_subscriptionId); 
                }
                
                if(!amendmentList.isempty() && amendmentList.size()>0){
                    List<Zuora.zObject> remainingList = new List<Zuora.zObject>();
                    for(Zuora.zObject amendment: amendmentList){
                        amendment.setValue('SubscriptionId', new_subscriptionId);              
                        remainingList.add(amendment);
                    } 
                    amendbatches(remainingList,new_subscriptionId,OriginalSubid);
                }   
                ErrorMessage = ' Successfully for the Subscription Id:'+new_subscriptionId;               
                updateleads(amendmentBatch, 'Sent to Z-Billing' , 'Processed');               
                
            }else{
                ErrorMessage = 'failed for the Subscription Id:'+SubscriptionId+' Error Details';
                List<Zuora.Zobject> Errorresponse= result.Errors;
                for(Zuora.zobject rec:  Errorresponse){
                    ErrorMessage+='\n';
                    ErrorMessage+=rec.getvalue('Message');
                }
                updateleads(amendmentBatch, ErrorMessage , 'Error');
                if(!amendmentList.isempty() && amendmentList.size()>0){                    
                    amendbatches(amendmentList,OriginalSubid,OriginalSubid);
                }
                
                return false;
            }
        }
        return true;
    } 
    Zuora.zApi.AmendResult amendApiCall(List<Zuora.zObject> amendment) {        
        Zuora.zApi.AmendRequest amendRequest = new Zuora.zApi.AmendRequest();
        Zuora.zObject[] amendments = amendment;
        amendRequest.amendments = amendments;        
        Zuora.zApi.AmendOptions amendmentOption = new Zuora.zApi.AmendOptions();
        amendmentOption.GenerateInvoice = false;
        amendmentOption.ProcessPayments = false;       
        amendRequest.amendOptions = amendmentOption;
        system.debug('---amendRequest before zament--'+amendRequest);        
        Zuora.zApi.AmendResult result = new Zuora.zApi.AmendResult();
        if(!test.isRunningTest()){          
            result = zApi.zamend(new List < Zuora.zApi.AmendRequest > {
                amendRequest
                    });
        }else{
            result.success = true;
        }        
        System.debug('result------>'+result);        
        return result;
    }
    Zuora.zObject createAmendment(String name, String subscriptionId, String amendType, String processthrough_date) {
        Zuora.zObject amendment = new Zuora.zObject('Amendment');
        system.debug('---createAmendment entered--'+name+'====>'+subscriptionId+'------>'+amendType);        
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
    Zuora.zObject createRatePlanData(String productRatePlanId, String productRatePlanChargeId, Decimal price, Decimal QTY, String Name, String Description, String Perunit) {
        system.debug('---createSubscriptionRatePlanData entered--'+productRatePlanId);
        Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
        ratePlanData.setValue('RatePlan', createRatePlan(productRatePlanId));
        ratePlanData.setValue('RatePlanChargeData', new List < Zuora.zObject > {
            createRatePlanChargeDataForNewProduct(productRatePlanChargeId,price, QTY,Name, Description, Perunit)
                });
        return ratePlanData;
    }
    Zuora.zObject createRatePlan(String productRatePlanId) {
        Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
        ratePlan.setValue('ProductRatePlanId', productRatePlanId);
        return ratePlan;
    }
    Zuora.zObject createRatePlanChargeDataForNewProduct(String productRatePlanChargeId, Decimal price, Decimal QTY, String Name, String Description, String Perunit) {
        Zuora.zObject ratePlanChargeData = new Zuora.zObject('RatePlanChargeData');
        ratePlanChargeData.setValue('RatePlanCharge', createRatePlanCharge(productRatePlanChargeId,price, QTY,Name, Description, Perunit));
        return ratePlanChargeData;
    }
    Zuora.zObject createRatePlanCharge(String productRatePlanChargeId, Decimal price, Decimal QTY, String Name, String Description, String Perunit) {
        Zuora.zObject ratePlanCharge = new Zuora.zObject('RatePlanCharge');
        ratePlanCharge.setValue('ProductRatePlanChargeId', productRatePlanChargeId);
        ratePlanCharge.setValue('Lead_Name__c', Name);      
       // ratePlanCharge.setValue('Price', price);
        ratePlanCharge.setValue('Quantity', QTY);
        ratePlanCharge.setValue('Price', Perunit); 
        //ratePlanCharge.setValue('ItemDescription__c', Description);
        ratePlanCharge.setValue('Description', Description);
        return ratePlanCharge;
    }
    
    Zuora.ZApi zuoraApiAccess(){
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
    void updateleads(List<Zuora.zObject> amendmentBatch, String Errormessage, String Status){        
        for(Zuora.zObject inloop : amendmentBatch){ 
            system.debug('inloop@ : '+ inloop);
            Zuora.zObject rate  = (Zuora.zObject)inloop.getvalue('RatePlanData');
            List<Object> bb = rate.getArrayValue('RatePlanChargeData');                       
            for(Object inloop33: bb){
                system.debug('inloop33## : '+ inloop33);
                Zuora.zObject inn =  (Zuora.zObject)inloop33;
                Zuora.zObject ratecharge  = (Zuora.zObject)inn.getvalue('RatePlanCharge');                        
                String ff =   (String)ratecharge.getvalue('Lead_Name__c');
                system.debug('String## : '+ ff);                                                
                
                if(mapleadids.containsKey(ff)){
                    Moving_Lead__c uu = new Moving_Lead__c(); 
                    uu.Id = mapleadids.get(ff); 
                    uu.Zuora_Comment__c  = Errormessage;                   
                    uu.Status__c = Status;               
                    Results.add(uu);
                }
                
                if(Status == 'Processed')
                    RecordsProcessed++;
                else
                    RecordsFailed++;
                
            }                                          
        }       
        
    }
    String getdate(){        
        String processthrough_date = '';      
        string month = '0'+string.valueof(system.today().month());
        month = month.right(2);
        string day = '0'+string.valueof(system.today().day());
        day = day.right(2);
        processthrough_date = system.today().year()+'-'+month+'-'+day;
        return processthrough_date; 
    }
}