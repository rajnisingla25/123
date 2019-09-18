global class WebServiceMockImplementation implements WebServiceMock {
   global void doInvoke(
           Object stub,
           Object request ,
           Map<String, Object>  response_map_x,
           String endpoint,           
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {            
                      
       DocuSignAPI.CreateAndSendEnvelopeResponse_element respElement = 
          new DocuSignAPI.CreateAndSendEnvelopeResponse_element(); 
          
       response_map_x.put('response_x', respElement); 
        
       
       
   }
   
   
}