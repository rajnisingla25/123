//
// (c) 2015 Appirio, Inc.
//
// Mock Test Class: CreateNewContactExtensionMockCallout
// For Test Class: CreateNewContactExtension_Test
// For Apex Extension: CreateNewContactExtension
// For Apex Page: CreateNewContact
// Description: Overrides new button of contact sobject and creates a contact using custom apex page.
// Calls CDH contact creation web service via apex page.
//
// 08th April 2015    Hemendra Singh Bhati    Original (Task # T-376891)
//
@isTest
global class CreateNewContactExtensionMockCallout implements WebServiceMock {
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
    moveComMatchcontact.InputParameters_element theRequest = (moveComMatchcontact.InputParameters_element)request;
    moveComMatchcontact.OutputParameters_element responseElement = new moveComMatchcontact.OutputParameters_element();

    if(theRequest.P_AGENT_TYPE == 'Agent') {
      moveComMatchcontact.Output theOutput = new moveComMatchcontact.Output();
      theOutput.PARTY_ID = 28993489;
      theOutput.SCORE = 10;

      moveComMatchcontact.OutputArray theOutputArray = new moveComMatchcontact.OutputArray();
      theOutputArray.Output = theOutput;

      responseElement.X_SRCH_RES_LIST = theOutputArray;
      responseElement.X_NUM_MATCHES = 1;
      responseElement.X_SEARCH_CTX_ID = 12345;
      responseElement.X_RETURN_STATUS = '200';
      responseElement.X_RET_MSGS = 'OK';
    }
    else {
      responseElement.X_SRCH_RES_LIST = null;
      responseElement.X_NUM_MATCHES = null;
      responseElement.X_SEARCH_CTX_ID = null;
      responseElement.X_RETURN_STATUS = null;
      responseElement.X_RET_MSGS = null;
    }
    response.put('response_x', responseElement);
  }
}