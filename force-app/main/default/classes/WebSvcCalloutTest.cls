@isTest
                        
private class WebSvcCalloutTest {
    @isTest static void testEchoString() {              
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        
        // Call the method that invokes a callout
        String output = WebSvcCallout.callEchoString('Hello World!');
        
        // Verify that a fake result is returned
        System.assertEquals('Mock response', output); 
    }
}