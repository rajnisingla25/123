//
// (c) 2015 Appirio, Inc.
//
// Mock Test Class: BMR_Report_ExtensionMockCallout
// For Test Class: BMR_Report_Extension_Test
// For Extension Class: BMR_Report_Extension
// For Apex Page: BMR_Report
// Description: This mock callout class generates a web-service response for BMR/BDR reporting.
//
// 07th June 2015     Hemendra Singh Bhati    Original (Task # T-396116)
//
@isTest
global class BMR_Report_ExtensionMockCallout implements WebServiceMock {
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

    system.debug('TRCAE: BMR_Report_ExtensionMockCallout - theRequest.ListName - ' + theRequest.ListName);
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