@isTest
global class ADVP_BMR_Report_ExtensionMockCallout implements WebServiceMock {
  global void doInvoke(
    Object stub,
    Object request,
    Map<String, Object> response,
    String endpoint,
    String soapAction,
    String requestName,
    String responseNS,
    String responseName,
    String responseType
  ) {
    moveComBmr.BMRListCreationRequest theRequest = (moveComBmr.BMRListCreationRequest)request;
    moveComBmr.BMRRealtorListResponse_element response_x = new moveComBmr.BMRRealtorListResponse_element();

    system.debug('TRCAE: ADVP_BMR_Report_ExtensionMockCallout - theRequest.ListName - ' + theRequest.ListName);
    if(theRequest.ListName == 'BMR Report - Message Failed') {
      // Do Nothing.
    }
    else if(theRequest.ListName == 'BMR Report - Non-Zero Response Code') {
      moveComBmr.BMRListCreationResponse BMRListCreationResult = new moveComBmr.BMRListCreationResponse();
      BMRListCreationResult.ResponseCode = 1;
      BMRListCreationResult.BMRURL = 'http://reports/ReportServer/Pages/ReportViewer.aspx?%2fSalestrack%2fBroker+Marketing+Report+-+ALLINONE&ListID=';
      BMRListCreationResult.ListID = '12345';

      response_x.BMRListCreationResult = BMRListCreationResult;
      response.put('response_x', response_x);
    }
  }
}