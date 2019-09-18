@istest
public class xmlnsOracleComInt003ContactSynccont_Test {
    public static testMethod void main1(){
   xmlnsOracleComInt003ContactSynccont obj = new xmlnsOracleComInt003ContactSynccont ();
    xmlnsOracleComInt003ContactSynccont.SyncContactSFDCToCDHServiceBindingQSPort obj1 = new xmlnsOracleComInt003ContactSynccont.SyncContactSFDCToCDHServiceBindingQSPort();
    
    xmlnsOracleComInt003ContactSynccont.processResponse_element obj2 = new xmlnsOracleComInt003ContactSynccont.processResponse_element();
    xmlnsOracleComInt003ContactSynccont.process_element obj3 = new xmlnsOracleComInt003ContactSynccont.process_element();
    }
    
    public class WebServiceMockImpl implements WebServiceMock{
        public void doInvoke(Object stub, Object request, Map<String, Object> response,String endpoint, String soapAction, String requestName,String responseNS, String responseName, String responseType)
        {
             xmlnsOracleComInt003ContactSynccont.processResponse_element testdata = new  xmlnsOracleComInt003ContactSynccont.processResponse_element();
            testdata.result = 'success';
            if(request instanceof xmlnsOracleComInt003ContactSynccont.SyncContactSFDCToCDHServiceBindingQSPort )
                system.debug('in here');
                response.put('response_x', new xmlnsOracleComInt003ContactSynccont.process_element());
            return;
        }
    }
    
    /*public static testMethod void coverMethods(){
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        //list<CPMoveCom.CPLoginInfo> CPLoginInfoRequest = new list<CPMoveCom.CPLoginInfo>();
        new CPxmlnsOracleCom.GetControlPanelInfoSFDC_pt().process('Test','Test');
    }*/
}