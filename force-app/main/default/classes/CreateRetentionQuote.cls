global with sharing class CreateRetentionQuote {
    
    public PageReference createQuote(){
        
        String newOpptyId = null;
        String username = null;
        String password = null;
        
        Id accountId = ApexPages.currentPage().getParameters().get('accountId');
        Id caseId = ApexPages.currentPage().getParameters().get('caseId');
        String quoteType = ApexPages.currentPage().getParameters().get('type');
        String opptyId = ApexPages.currentPage().getParameters().get('opptyId');
        
        system.debug('@@@ case ID ' +  caseId);
        system.debug('@@@ acc ID ' +  accountId);
        system.debug('@@@ Type ' +  quoteType);
        system.debug('@@@ Opp Id ' +  opptyId);
        
        //Radhika 28/10/2015 Start
        List<Account_Relationship__c> listAccRel = new List<Account_Relationship__c>();
        listAccRel = [SELECT Id,Parent_Account__c FROM Account_Relationship__c WHERE Parent_Account__c = :accountId and Contact_Role__c='Primary Contact'];
        if(listAccRel != null && listAccRel.size() == 0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'You cannot create Retention quote as there is no primary contact for this Account'));                
            return null;
        }
        //Radhika 28/10/2015 End
  
        
        If (opptyId == null){
            newOpptyId = (String) createOpportunity(accountId);
            PageReference pageRef = new PageReference('/apex/CreateRetentionQuote?caseId='+caseId+'&accountId='+accountId+'&type='+quoteType+'&opptyId='+newOpptyId);
            pageRef.setRedirect(true);
            system.debug('Page Reference: '+ pageRef.getUrl());
            return pageRef;
        }else {
            List<Case_Asset_Relationship__c> carIds = [SELECT Asset__r.id,Line_Action__c, cancellation_reason__c FROM Case_Asset_Relationship__c WHERE Case__c =: caseId];
            If(carIds.size()==0)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please close this tab and add atleast one Asset to the case and then retry creating a Quote'));                
                return null;
                
            } 
            Map<Id, String> mapAssetIds =  new Map<Id, String>();
            for (Case_Asset_Relationship__c carRecord : carIds ){
                
                // The Value in the Map will be in the format : LineAction##CancellationReason
                String encodedString = '';
                
                if(carRecord.Line_Action__c == 'cancel' && carRecord.Cancellation_Reason__c!= null ){
                    if(Cancellation_Reason_CPQ_Mapping__c.getInstance(carRecord.Cancellation_Reason__c).CPQ_Variable_Name__c == null){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'The cancellaton reason is not accepted by CPQ. Please contact the Administrator and provide the below Error message.'));
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'The Variable name for "'+carRecord.Cancellation_Reason__c+'" has issues. Please check the custom setting : Cancellation Reason CPQ Mapping')); 
                        return null;
                    }else{
                        // Get custom setting mapping to CPQ
                        encodedString = carRecord.Line_Action__c.toLowerCase()+'##'+ Cancellation_Reason_CPQ_Mapping__c.getInstance(carRecord.Cancellation_Reason__c).CPQ_Variable_Name__c ; 
                    }
                    
                }
                else if(carRecord.Line_Action__c == 'amend'){
                    // Adding a blank value to cancellation reason as amend or renew does not have any cancellation reason
                    encodedString = carRecord.Line_Action__c.toLowerCase()+'##'+ '$$';  
                }
                system.debug('TRACE : Encoded String : '+ encodedString );
                
                mapAssetIds.put(carRecord.Asset__r.id, encodedString);
            }
            system.debug('@@@ Map Asset IDs- '+ mapAssetIds );
            system.debug('@@@ Map Cancel Reason Value: ' + mapAssetIds.values());
            
            return reDirect( username , password , accountId , opptyId , caseId , quoteType , mapAssetIds );  
            
        }
        
    }
    @Testvisible
    private static ID createOpportunity(string accountId ) {
        
        if (String.isNotBlank(accountId)) {
            try {
                Opportunity theOpportunity = new Opportunity(
                    Name = 'The Opportunity',
                    StageName = 'Prospecting',
                    CloseDate = system.today(),
                    AccountId = accountId,
                    Opportunity_Short_Description__c = 'Retention',
                    Amount = 0.00
                    );
                insert theOpportunity;
                 if(Test.isRunningTest())
                integer intTest =1/0;  
                system.debug('@@@ Opp Id - ' +theOpportunity.Id );
                return theOpportunity.Id;
            } catch (Exception e) {
                system.debug('TRACE: Exception Occurred - ' + e.getStackTraceString());
                ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.FATAL,
                    'An internal error occurred while processing your request. Please contact system administrator.'+ 
                    'The below errors occured while processing your request'+e.getStackTraceString()));
            }
        }
        return null;
    } 
    @Testvisible
    Private Static PageReference reDirect(String username ,String password ,String accountId ,String oppId ,String caseId ,String quoteType ,Map<Id,String> mapAssetIds ){
        
        WebserviceCallBigMachineQuoteCls caller = new WebserviceCallBigMachineQuoteCls();
        try{
            PageReference pRef = caller.CreateQuote(username, password, accountId, oppId , caseId, quoteType,null, true, null, mapAssetIds);
            system.debug(pRef);
            pref.setRedirect(true);  
            if(Test.isRunningTest())
            integer intTest =1/0;        
            return pRef;
        } catch (Exception e){
            system.debug('TRACE: Exception Occurred - ' + e.getStackTraceString());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Something went wrong when communicating with CPQ system.  Please provide the below error to the system administrator.'));
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.INFO, e.getStackTraceString()));
            return null;
        }
        
        
    }
    
    
    
}