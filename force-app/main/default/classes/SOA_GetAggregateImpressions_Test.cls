@IsTest
private with sharing class SOA_GetAggregateImpressions_Test
{
    private static testMethod void coverTypes()
    {
        SOA_GetAggregateImpressions obj = new SOA_GetAggregateImpressions ();
        new SOA_GetAggregateImpressions.process_element();
        new SOA_GetAggregateImpressions.CampaignRecord_element ();
        new SOA_GetAggregateImpressions.ImpressionRecord_element ();
        new SOA_GetAggregateImpressions.processResponse_element ();
        new SOA_GetAggregateImpressions.GetAggregateImpressionsAmazonService_pt ();
        
    }
    
    private class WebServiceMockImple implements WebServiceMock
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType)
        {
            if(request instanceof SOA_GetAggregateImpressions.process_element)
                response.put('response_x', new SOA_GetAggregateImpressions.processResponse_element());
            return;
        }
    }  
    private static testMethod void coverMethods()
    {
       Test.setMock(WebServiceMock.class, new WebServiceMockImple());
       new SOA_GetAggregateImpressions.GetAggregateImpressionsAmazonService_pt().process(null);
       
    }
   
    
        
}