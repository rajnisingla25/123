global class deleteCustomerSPScheduled implements Schedulable{
    global void execute(SchedulableContext sc){
        //Datetime cdate = Date.Today();
        //cdate.addHours(-4);
        //String CSP = 'CustomerSP';

        String query = 'SELECT Value__c FROM C1ASCloudConnectorConfig__c WHERE Type__c = \'CustomerSP\' and LastModifiedDate < :cdate';
        
        deleteCustomerSP delBatch = new deleteCustomerSP(query);
        Id BatchProcessId = Database.ExecuteBatch(delBatch);
    }
}