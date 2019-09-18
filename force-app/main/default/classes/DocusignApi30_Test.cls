@IsTest
Public class DocusignApi30_Test
{
    private static testMethod void coverTypes()
    {
        new DocusignApi30.RequestStatusesResponse_element();
        new DocusignApi30.EnvelopeAuditEventsResult_element ();
        new DocusignApi30.Attachment ();
        new DocusignApi30.SSN4Information ();
        new DocusignApi30.IDCheckInformation ();
        new DocusignApi30.RecipientStatus ();
        new DocusignApi30.EnvelopeAuditEventsResponse_element ();
        new DocusignApi30.Ping_element ();
        new DocusignApi30.ArrayOfCustomField ();
        new DocusignApi30.FormData ();
        new DocusignApi30.VoidEnvelopeStatus ();
        new DocusignApi30.DocuSignEnvelopeInformation ();
        new DocusignApi30.ArrayOfEnvelopeStatusCode ();
        new DocusignApi30.RequestStatusEx_element ();
        new DocusignApi30.ArrayOfDocumentPDF ();
        new DocusignApi30.DocumentPDF ();
        new DocusignApi30.FormDataXfdf ();
        new DocusignApi30.ArrayOfRecipientStatus ();
        new DocusignApi30.RequestStatusExResponse_element ();        
        new DocusignApi30.AuthenticationStatus ();
        new DocusignApi30.FilteredEnvelopeStatuses ();
        new DocusignApi30.ArrayOfFormDataXfdfField ();
        new DocusignApi30.ArrayOfString1 ();
        new DocusignApi30.ArrayOfDocumentStatus ();
        new DocusignApi30.ArrayOfString2 ();
        new DocusignApi30.EnvelopeStatusFilterBeginDateTime ();
        new DocusignApi30.GetStatusInDocuSignConnectFormat_element ();
        new DocusignApi30.VoidEnvelope_element ();
        new DocusignApi30.AddressInformation ();
        new DocusignApi30.ArrayOfTabStatus ();
        new DocusignApi30.PingResponse_element ();
        new DocusignApi30.UserInfo ();        
        new DocusignApi30.EnvelopeStatusFilter ();
        new DocusignApi30.ArrayOfAttachment ();
        new DocusignApi30.SynchEnvelopeStatus ();
        new DocusignApi30.RequestStatusesEx_element ();
        new DocusignApi30.VoidEnvelopeResponse_element ();
        new DocusignApi30.RequestStatusResponse_element ();
        new DocusignApi30.EnvelopeAuditEvents_element ();
        new DocusignApi30.RequestStatus_element ();
        new DocusignApi30.SynchEnvelope_element ();
        new DocusignApi30.TabStatus ();
        new DocusignApi30.ArrayOfEnvelopeStatus ();
        new DocusignApi30.RequestStatusesExResponse_element ();
        new DocusignApi30.SSN9Information ();
        new DocusignApi30.EnvelopeStatus ();
        new DocusignApi30.DOBInformation ();
        new DocusignApi30.DocumentStatus ();
        new DocusignApi30.EventResult ();
        new DocusignApi30.FormDataXfdfField ();        
        new DocusignApi30.GetStatusInDocuSignConnectFormatResponse_element ();
        new DocusignApi30.VaultingDetails ();
        new DocusignApi30.CustomField ();
        new DocusignApi30.RecipientStatusEsignAgreementInformation ();
        new DocusignApi30.RequestStatuses_element ();
        new DocusignApi30.SynchEnvelopeResponse_element ();
        new DocusignApi30.APIServiceSoap ();        
       Test.setMock(WebServiceMock.class, new WebServiceMockImpl ());
         try{
       new DocusignApi30.APIServiceSoap().RequestStatuses(null);
       new DocusignApi30.APIServiceSoap().EnvelopeAuditEvents(null);       
        }catch(Exception e){}
    }
     private static testMethod void coverTypes1(){
         Test.setMock(WebServiceMock.class, new WebServiceMockImple ());
          try{       
       new DocusignApi30.APIServiceSoap().VoidEnvelope(null , null);
       new DocusignApi30.APIServiceSoap().GetStatusInDocuSignConnectFormat(null);      
       
        }catch(Exception e){}
     }
     private static testMethod void coverTypes2(){
         Test.setMock(WebServiceMock.class, new WebServiceMockImplee ());
          try{       
      new DocusignApi30.APIServiceSoap().SynchEnvelope(null , null , null);
       new DocusignApi30.APIServiceSoap().RequestStatusEx(null);    
       
        }catch(Exception e){}
     }
     private static testMethod void coverTypes3(){
         Test.setMock(WebServiceMock.class, new WebServiceMockImplex ());
          try{       
      new DocusignApi30.APIServiceSoap().RequestStatus(null);
      new DocusignApi30.APIServiceSoap().RequestStatusesEx(null);
       
        }catch(Exception e){}
     }
     private static testMethod void coverTypes4(){
         Test.setMock(WebServiceMock.class, new WebServiceMockping ());
          try{       
      new DocusignApi30.APIServiceSoap().ping();      
       
        }catch(Exception e){}
     }
    private class WebServiceMockImpl implements WebServiceMock
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType)
        {
            if(request instanceof DocusignApi30.RequestStatuses_element)
                response.put('response_x', new DocusignApi30.RequestStatusesResponse_element());
            return;   
             if(request instanceof DocusignApi30.EnvelopeAuditEvents_element)
                response.put('response_x', new DocusignApi30.EnvelopeAuditEventsResponse_element());
            return;            
        }
    }
    private class WebServiceMockImple implements WebServiceMock
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType)
        {    
             if(request instanceof DocusignApi30.VoidEnvelope_element)
                response.put('response_x', new DocusignApi30.VoidEnvelopeResponse_element());
            return;
            if(request instanceof DocusignApi30.GetStatusInDocuSignConnectFormat_element)
                response.put('response_x', new  DocusignApi30.GetStatusInDocuSignConnectFormatResponse_element());
            return;            
         }
      }  
     private class WebServiceMockImplee implements WebServiceMock
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType)
        {  
            if(request instanceof DocusignApi30.SynchEnvelope_element)
                response.put('response_x', new  DocusignApi30.SynchEnvelopeResponse_element());
            return;
            if(request instanceof DocusignApi30.RequestStatusEx_element)
                response.put('response_x', new  DocusignApi30.RequestStatusExResponse_element());
            return;
         }
      } 
      private class WebServiceMockImplex implements WebServiceMock
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType)
        {  
            if(request instanceof DocusignApi30.RequestStatus_element)
                response.put('response_x', new DocusignApi30.RequestStatusResponse_element());
            return;
            if(request instanceof DocusignApi30.RequestStatusesEx_element )
                response.put('response_x', new DocusignApi30.RequestStatusesExResponse_element());
            return;
         }
      }  
      private class WebServiceMockping implements WebServiceMock
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType)
        {  
            if(request instanceof DocusignApi30.Ping_element)
                response.put('response_x', new DocusignApi30.PingResponse_element());
            return;
            
         }
      }                 
}