@isTest
Public class OracleComServicebusapplicationL_Test{
    
    public static testMethod void main1(){
        
        Date d1 = system.Today();
        OracleComServicebusapplicationL obj = new OracleComServicebusapplicationL();
        OracleComServicebusapplicationL.reservationtype obj1 = new OracleComServicebusapplicationL.reservationtype();
        OracleComServicebusapplicationL.reservation_line_item_element obj2 = new OracleComServicebusapplicationL.reservation_line_item_element();
        OracleComServicebusapplicationL.reservation_line_items_element obj3 = new OracleComServicebusapplicationL.reservation_line_items_element();
        OracleComServicebusapplicationL.lockInventoryQSPort obj4 = new OracleComServicebusapplicationL.lockInventoryQSPort();
        
    }
   
    Public class WebServiceMockImpl implements WebServiceMock{
        public void doInvoke(Object stub, Object request, Map<String, Object> response,String endpoint, String soapAction, String requestName,String responseNS, String responseName, String responseType)
        {
            if(request instanceof OracleComServicebusapplicationL.lockInventoryQSPort )
                response.put('response_x', new OracleComServicebusapplicationL.lockInventoryQSPort ());
            return;
        }
    }
    
    Public static testMethod void coverMethods(){
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        Date d1 = system.Today();
        OracleComServicebusapplicationL.reservation_line_items_element obj3 = new OracleComServicebusapplicationL.reservation_line_items_element();
        new OracleComServicebusapplicationL.lockInventoryQSPort().lockInventory('operation',d1,1,'transaction_id','ReservationID',obj3);
    }
}