@IsTest
public class ZuoraBillingPreviewAPITest {
	private class WebServiceMockImpl implements WebServiceMock
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType)
        {
            if(request instanceof ZuoraBillingPreviewapi.billingPreview_element)
                response.put('response_x', new ZuoraBillingPreviewapi.billingPreviewResponse_element ());
            return;
        }
    }
    
    private static testMethod void coverTypes()
    {
        new ZuoraBillingPreviewObject.InvoiceItem();
        new ZuoraBillingPreviewObject.zObject();
        new ZuoraBillingPreviewapi.billingPreview_element();
        new ZuoraBillingPreviewapi.BillingPreviewRequest();
        new ZuoraBillingPreviewapi.billingPreviewResponse_element();
        new ZuoraBillingPreviewapi.BillingPreviewResult();
        new ZuoraBillingPreviewapi.CallOptions_element();
        new ZuoraBillingPreviewapi.Error();
        new ZuoraBillingPreviewapi.QueryOptions_element();
        new ZuoraBillingPreviewapi.SessionHeader_element();
    }
    
    private static testMethod void coverMethods()
    {
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        new ZuoraBillingPreviewapi.Soap().billingPreview(null);
    }
}