//Generated by wsdl2apex

public class xmlnsMoveComBmrrealtorlist {
    public class BMRRealtorList {
        // public String endpoint_x = 'http://daz02app21200.corp.homestore.net:8001/soa-infra/services/default/BMRRealtorList/client';
        public String endpoint_x = CDH_Webservices_Endpoints__c.getInstance().BMR_Report_Endpoint__c;
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://xmlns.move.com/BMRRealtorList', 'xmlnsMoveComBmrrealtorlist', 'http://move.com/bmr', 'moveComBmr'};
        public moveComBmr.BMRListCreationResponse process(String LoginUserName,String ListName,String ListDesc,String ListID,moveComBmr.ArrayOfBMRRealtor Realtors) {
            moveComBmr.BMRListCreationRequest request_x = new moveComBmr.BMRListCreationRequest();
            request_x.LoginUserName = LoginUserName;
            request_x.ListName = ListName;
            request_x.ListDesc = ListDesc;
            request_x.ListID = ListID;
            request_x.Realtors = Realtors;
            moveComBmr.BMRRealtorListResponse_element response_x;
            Map<String, moveComBmr.BMRRealtorListResponse_element> response_map_x = new Map<String, moveComBmr.BMRRealtorListResponse_element>();
            response_map_x.put('response_x', response_x);
            system.debug('TRACE: request_x - ' + request_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'process',
              'http://move.com/bmr',
              'BMRRealtorListRequest',
              'http://move.com/bmr',
              'BMRRealtorListResponse',
              'moveComBmr.BMRRealtorListResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            system.debug('TRACE: response_x - ' + response_x);
            return response_x.BMRListCreationResult;
        }
    }
}