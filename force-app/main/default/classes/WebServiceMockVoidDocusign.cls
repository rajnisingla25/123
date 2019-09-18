@istest
global class WebServiceMockVoidDocusign implements WebServiceMock {
    public static String callfrom;       
    global void doInvoke(
        Object stub,
        Object request,
        Map<String, Object> response,
        String endpoint,
        String soapAction,
        String requestName,
        String responseNS,
        String responseName,
        String responseType) {
            system.debug('callfrom:'+callfrom);
            system.debug('request:'+request);
            if(callfrom == 'voiddocusign'){     
            //if(request instanceof DocusignApi30.VoidEnvelopeStatus){
            	system.debug('in void');
                DocusignApi30.VoidEnvelopeResponse_element respElement = new DocusignApi30.VoidEnvelopeResponse_element();
                DocusignApi30.VoidEnvelopeStatus VoidEnvelopeResult = new DocusignApi30.VoidEnvelopeStatus();
                VoidEnvelopeResult.VoidSuccess = true;
                response.put('response_x', respElement);
            } else if(callfrom == 'accounttrigger'){
            //} else{ 
            	system.debug('in account');
                xmlnsOracleComInt003ContactSyncacco.processResponse_element respElement = new xmlnsOracleComInt003ContactSyncacco.processResponse_element();
                respElement.result = null;
                response.put('response_x', respElement);
            }
        }
}