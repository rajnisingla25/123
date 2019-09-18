//Generated by wsdl2apex

public class AsyncSOA_GetAggregateImpressions {
    public class processResponse_elementFuture extends System.WebServiceCalloutFuture {
        public SOA_GetAggregateImpressions.ImpressionRecord_element[] getValue() {
            SOA_GetAggregateImpressions.processResponse_element response = (SOA_GetAggregateImpressions.processResponse_element)System.WebServiceCallout.endInvoke(this);
            return response.ImpressionRecord;
        }
    }
    public class AsyncGetAggregateImpressionsAmazonService_pt {
        public String endpoint_x = TurboUtilityClass.soaEndPointForAggrImpr;
        public Map<String,String> inputHttpHeaders_x;
        public String clientCertName_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://xmlns.oracle.com/AmazonRedshift/GetAggregateImpressionsAmazon/GetAggregateImpressionsAmazonService', 'SOA_GetAggregateImpressions'};
        public AsyncSOA_GetAggregateImpressions.processResponse_elementFuture beginProcess(System.Continuation continuation,SOA_GetAggregateImpressions.CampaignRecord_element[] CampaignRecord) {
            SOA_GetAggregateImpressions.process_element request_x = new SOA_GetAggregateImpressions.process_element();
            request_x.CampaignRecord = CampaignRecord;
            return (AsyncSOA_GetAggregateImpressions.processResponse_elementFuture) System.WebServiceCallout.beginInvoke(
              this,
              request_x,
              AsyncSOA_GetAggregateImpressions.processResponse_elementFuture.class,
              continuation,
              new String[]{endpoint_x,
              'process',
              'http://xmlns.oracle.com/AmazonRedshift/GetAggregateImpressionsAmazon/GetAggregateImpressionsAmazonService',
              'process',
              'http://xmlns.oracle.com/AmazonRedshift/GetAggregateImpressionsAmazon/GetAggregateImpressionsAmazonService',
              'processResponse',
              'SOA_GetAggregateImpressions.processResponse_element'}
            );
        }
    }
}