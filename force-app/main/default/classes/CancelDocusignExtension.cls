public with sharing class CancelDocusignExtension {

    public dsfs__DocuSign_Status__c sDocusign {get;set;}
    string EnvelopeID = '';
    public string Reason {get;set;}

    public CancelDocusignExtension(ApexPages.StandardController stdController) {
        this.sDocusign = (dsfs__DocuSign_Status__c)stdController.getRecord();
        this.sDocusign = [SELECT Name,ID,dsfs__DocuSign_Envelope_ID__c FROM dsfs__DocuSign_Status__c  WHERE ID=: this.sDocusign.ID];
        Reason = '';
    }
    public pageReference cancel()
    {

        return new PageReference('/'+sDocusign.ID);       
    }
    public pageReference cancelDocusign()
    {
     //Retrieving DocuSign credentials from custom settings
        DocuSignCredentials__c DocSignCredentials = DocuSignCredentials__c.getAll().values();
        String accountId = DocSignCredentials.AccountId__c;
        String userId = DocSignCredentials.UserId__c;
        String password = DocSignCredentials.Password__c;
        String integratorsKey = DocSignCredentials.IntegratorsKey__c;
        String webServiceUrl = DocSignCredentials.WebServiceUrl__c;
     
        set<string> GUidset = new set<string>();
        List<Waitlist_Item__c> WLIData = new List<Waitlist_Item__c>();
        list<dsfs__DocuSign_Status__c> DocStatus = new list<dsfs__DocuSign_Status__c>();
        PageReference retrunref;
        
        DocuSignAPI30.APIServiceSoap dsApiSend = new DocuSignAPI30.APIServiceSoap();
        dsApiSend.endpoint_x = webServiceUrl;
        
        //Set Authentication
        String auth = '<DocuSignCredentials><Username>'+ userId 
            +'</Username><Password>' + password 
            + '</Password><IntegratorKey>' + integratorsKey 
            + '</IntegratorKey></DocuSignCredentials>';
        
        dsApiSend.inputHttpHeaders_x = new Map<String, String>();
        dsApiSend.inputHttpHeaders_x.put('X-DocuSign-Authentication',auth);
        
        DocuSignAPI.Envelope envelope = new DocuSignAPI.Envelope();
        envelope.Subject    = 'Cancellation'; 
        envelope.EmailBlurb = 'Please find the voided form';
        envelope.AccountId  = accountId;
                      
               
    try{
        EnvelopeID = this.sDocusign.dsfs__DocuSign_Envelope_ID__c;
        //Reason = 'No response from Customer';
        DocusignApi30.VoidEnvelopeStatus VoidStatus = dsApiSend.VoidEnvelope(EnvelopeID,Reason);
        return new PageReference('/'+sDocusign.ID);        
     }
     catch(CalloutException DSerror)
     {
                   System.debug('DSException - ' + DSerror );
            Error__c logerror               = new Error__c();
            logerror.Name                   = EnvelopeID;
            logerror.Entity_Id__c           = 'IO or TigerLead Void';
            logerror.Error_Description__c   = string.valueof(DSerror);
            logerror.Interface_Name__c      = 'DocuSign';
            Insert logerror;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,''+DSerror.getMessage());
            ApexPages.addMessage(myMsg);            
            return null;  
              
     }
        
                        
        return null;
    }

}