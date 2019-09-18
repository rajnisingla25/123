@IsTest
private class SOA_GetAggregateLeads_Test
{
    private static testMethod void coverTypes()
    {
        SOA_GetAggregateLeads obj = new SOA_GetAggregateLeads();
        new SOA_GetAggregateLeads.GetSellerLeads_element();
        new SOA_GetAggregateLeads.process_element();
        new SOA_GetAggregateLeads.GetSellerRecordResponse_element ();
        new SOA_GetAggregateLeads.processResponse_element ();
        new SOA_GetAggregateLeads.GetAggregateSellerLeadsAmazon_pt ();
        
    }
    
    private class WebServiceMockImple implements WebServiceMock
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType)
        {
            if(request instanceof SOA_GetAggregateLeads.process_element)
                response.put('response_x', new SOA_GetAggregateLeads.processResponse_element());
            return;
        }
    }  
    private static testMethod void coverMethods()
    {
       Test.setMock(WebServiceMock.class, new WebServiceMockImple());
       new SOA_GetAggregateLeads.GetAggregateSellerLeadsAmazon_pt().process(null);
       
    }
   
    
        
}