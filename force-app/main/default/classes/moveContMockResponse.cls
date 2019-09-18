@isTest 
global class moveContMockResponse implements WebServiceMock 
{
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
         
           moveComMatchcontact.OutputParameters_element respElement=new moveComMatchcontact.OutputParameters_element();
          //  moveComMatchcontact.InputParameters_element respElement2=new moveComMatchcontact.InputParameters_element();
           moveComMatchcontact.OutputArray  outerArrClass=new moveComMatchcontact.OutputArray();
           moveComMatchcontact.Output output1=new  moveComMatchcontact.Output();
       
           output1.PARTY_ID=28993489;
          
           outerArrClass.Output=output1;
           
           respElement.X_SRCH_RES_LIST=outerArrClass;
           
           response.put('response_x', respElement);
        //   response.put('response_x', respElement2); 
   }
}