@isTest
private class CPMoveCom_Test{
    public static testMethod void main(){
    
        CPMoveCom  obj = new CPMoveCom();
        CPMoveCom.CPLoginInfoRes_element  obj1 = new CPMoveCom.CPLoginInfoRes_element();
        CPMoveCom.CPLoginInfoReq_element  obj2 = new CPMoveCom.CPLoginInfoReq_element();
        CPMoveCom.ListOfFulFillTo_element obj3 = new CPMoveCom.ListOfFulFillTo_element();
        CPMoveCom.CPLoginInfo obj4 = new  CPMoveCom.CPLoginInfo();
        CPMoveCom.FulFillTo_element obj5 = new CPMoveCom.FulFillTo_element();
    }
    
    static testMethod void asyncXMLnsTest(){

        CPMoveCom  obj = new CPMoveCom();
        CPMoveCom.CPLoginInfoRes_element  obj1 = new CPMoveCom.CPLoginInfoRes_element();
        CPMoveCom.CPLoginInfoReq_element  obj2 = new CPMoveCom.CPLoginInfoReq_element();
        CPMoveCom.ListOfFulFillTo_element obj3 = new CPMoveCom.ListOfFulFillTo_element();
        list<CPMoveCom.CPLoginInfo> lst = new list<CPMoveCom.CPLoginInfo>();
        lst.add(new  CPMoveCom.CPLoginInfo());
        CPMoveCom.FulFillTo_element obj5 = new CPMoveCom.FulFillTo_element();
        /*AsyncCPxmlnsOracleCom.AsyncGetControlPanelInfoSFDC_pt test = new AsyncCPxmlnsOracleCom.AsyncGetControlPanelInfoSFDC_pt();
       //AsyncGetControlPanelInfoSFDC_pt temp = test.AsyncGetControlPanelInfoSFDC_pt();
         test.inputHttpHeaders_x = new map<string,string>();
        test.clientCertName_x ='test';
        test.timeout_x =100;
        continuation c =new continuation(120);
       AsyncCPMoveCom.CPLoginInfoRes_elementFuture temp = test.beginProcess(c, lst);*/
        
    }
 }