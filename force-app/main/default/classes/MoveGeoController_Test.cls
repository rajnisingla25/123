@isTest
private class MoveGeoController_Test{
    
    public static testMethod void main1(){
    
            MoveGeoController  obj = new MoveGeoController ();
            MoveGeoController  obj4 = new MoveGeoController ();
            obj.org ='test';
            //obj.MyMoveGeoController();
            MoveGeoController.Area obj1 = new MoveGeoController.Area();
            obj1.MyArea('sgeo','sstate','sareacode','stimezone','szipcode','scity');
            //List<String> str = obj.getarea('m');
                        
            MoveGeoController.GeoWebserviceObject GA = new MoveGeoController.GeoWebserviceObject();
            List<MoveGeoController.GeoWebserviceObject> gaList = new List<MoveGeoController.GeoWebserviceObject>();
            gaList.add(GA);
            obj.geoList = gaList;
            obj4.geoList = null;
            obj.contactList = null;
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            gaList = obj.GetWaitlistfromWebService();
            Test.stopTest();  
        
    }
}