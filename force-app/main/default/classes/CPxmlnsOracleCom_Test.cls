@istest
public class CPxmlnsOracleCom_Test {
    public static testMethod void main1(){
        CPxmlnsOracleCom obj = new CPxmlnsOracleCom();
        CPxmlnsOracleCom.GetControlPanelInfoSFDC_pt obj1 = new CPxmlnsOracleCom.GetControlPanelInfoSFDC_pt();
    }
    
    public class WebServiceMockImpl implements WebServiceMock{
        public void doInvoke(Object stub, Object request, Map<String, Object> response,String endpoint, String soapAction, String requestName,String responseNS, String responseName, String responseType)
        {
            CPMoveCom.CPLoginInfoRes_element testdata = new CPMoveCom.CPLoginInfoRes_element();
            testdata.Status = 'success';
            if(request instanceof CPxmlnsOracleCom.GetControlPanelInfoSFDC_pt )
                system.debug('in here');
                response.put('response_x', new CPMoveCom.CPLoginInfoRes_element());
            return;
        }
    }
    
    public static testMethod void coverMethods(){
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        list<CPMoveCom.CPLoginInfo> CPLoginInfoRequest = new list<CPMoveCom.CPLoginInfo>();
        new CPxmlnsOracleCom.GetControlPanelInfoSFDC_pt().process(CPLoginInfoRequest);
    }
}