@isTest
public class OracleComWaitlistSyncwaitlistin_Test {
    public static testMethod void main1(){
        OracleComWaitlistSyncwaitlistin obj = new OracleComWaitlistSyncwaitlistin();
        OracleComWaitlistSyncwaitlistin.SyncWaitListInventoryService_pt obj1 = new OracleComWaitlistSyncwaitlistin.SyncWaitListInventoryService_pt();
    }
    public class WebServiceMockImpl implements WebServiceMock{
        public void doInvoke(Object stub, Object request, Map<String, Object> response,String endpoint, String soapAction, String requestName,String responseNS, String responseName, String responseType)
        {
            if(request instanceof OracleComWaitlistSyncwaitlistin.SyncWaitListInventoryService_pt )
                response.put('response_x', new OracleComWaitlistSyncwaitlistin.SyncWaitListInventoryService_pt());
            return;
        }
    }
    
    public static testMethod void coverMethods(){
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        wwwMoveCom.waitlist waitlist = new wwwMoveCom.waitlist();
        new OracleComWaitlistSyncwaitlistin.SyncWaitListInventoryService_pt().process(waitlist);
    }
}