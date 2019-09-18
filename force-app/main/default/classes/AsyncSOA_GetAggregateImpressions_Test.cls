@IsTest
private with sharing class AsyncSOA_GetAggregateImpressions_Test
{
    private static testMethod void coverTypes()
    {
    
    AsyncSOA_GetAggregateImpressions obj = new AsyncSOA_GetAggregateImpressions();
    new AsyncSOA_GetAggregateImpressions.AsyncGetAggregateImpressionsAmazonService_pt(); 
     new AsyncSOA_GetAggregateImpressions.processResponse_elementFuture();  
    
    }
    private class WebServiceMockImple implements WebServiceMock
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType)
        {
                if(request instanceof SOA_GetAggregateImpressions.process_element)
                response.put('response_x', new AsyncSOA_GetAggregateImpressions.processResponse_elementFuture());
            return;
        }
    }  
    private static testMethod void coverMethods()
    {
       Test.setMock(WebServiceMock.class, new WebServiceMockImple());        
       try{
       new AsyncSOA_GetAggregateImpressions.AsyncGetAggregateImpressionsAmazonService_pt().beginProcess(null,null);
       }catch(Exception e){}
       
    }
}