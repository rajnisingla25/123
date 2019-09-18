//
// (c) 2015 Appirio, Inc.
//
// Mock Test Class: CreateNewAccountExtensionMockCallout
// For Test Class: CreateNewAccountExtension_Test
// For Apex Extension: CreateNewAccountExtension
// For Apex Page: CreateNewAccount
// Description: Overrides new button of account sobject and creates an account using custom apex page.
// Calls CDH account creation web service via apex page.
//
// 08th April 2015    Hemendra Singh Bhati    Original (Task # T-376544)
//
@isTest
global class CreateNewAccountExtensionMockCallout implements WebServiceMock {
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
  	moveComMatchaccount.InputParameters_element theRequest = (moveComMatchaccount.InputParameters_element)request;
    moveComMatchaccount.OutputParameters_element responseElement = new moveComMatchaccount.OutputParameters_element();

    if(theRequest.P_ACCOUNT_TYPE == 'Agent') {
      moveComMatchaccount.Output theOutput = new moveComMatchaccount.Output();
      theOutput.PARTY_ID = 28993489;
      theOutput.SCORE = 10;

      moveComMatchaccount.OutputArray theOutputArray = new moveComMatchaccount.OutputArray();
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