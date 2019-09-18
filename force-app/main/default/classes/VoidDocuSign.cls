Global with sharing class VoidDocuSign {
    @RemoteAction
    Global static string VoidEnvelope(List<string> WLGUid){
        String envelopeId;
        String Reason;
        //Retrieving DocuSign credentials from custom settings
        DocuSignCredentials__c DocSignCredentials = DocuSignCredentials__c.getAll().values();
        String accountId        = DocSignCredentials.AccountId__c;
        String userId           = DocSignCredentials.UserId__c;
        String password         = DocSignCredentials.Password__c;
        String integratorsKey   = DocSignCredentials.IntegratorsKey__c;
        String webServiceUrl    = DocSignCredentials.WebServiceUrl__c;
        
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
        envelope.Subject    = 'Cancelled Please Sign the Pre-Auth Form'; 
        envelope.EmailBlurb = 'Your above Pre-Auth waitlist docusign has been cancelled';
        envelope.AccountId  = accountId;
        
        List<Waitlist_Item__c> WLIData = [select Waitlist__c from Waitlist_Item__c where Waitlist_ID__c in :WLGUid];
        set<id> waitlistitem = new set<id>();
        for(Waitlist_Item__c WLItem : WLIData){
            waitlistitem.add(WLItem.Waitlist__c);
        }
        
        dsfs__DocuSign_Status__c DocStatus = [select dsfs__DocuSign_Envelope_ID__c from dsfs__DocuSign_Status__c 
                                              where Waitlist__c IN : waitlistitem];
        
        EnvelopeID 	= DocStatus.dsfs__DocuSign_Envelope_ID__c;
        Reason 		= 'Pre-Auth Cancel';
        
        try{
            DocusignApi30.VoidEnvelopeStatus VoidStatus = dsApiSend.VoidEnvelope(EnvelopeID,Reason);
        } catch ( CalloutException error) {
            for(Waitlist_Item__c WLI : WLIData){  
                System.debug('Exception - ' + error );
                envelopeId = 'Exception - ' + error;
                Error__c logerror               = new Error__c();
                logerror.Name                   = WLI.Waitlist__c;
                logerror.Entity_Id__c           = 'Waitlist Void';
                logerror.Error_Description__c   = string.valueof(error);
                logerror.Interface_Name__c      = 'DocuSign';
                Insert logerror;
            }
        }  
        return null;        
    }
}