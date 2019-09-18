Public class AutoRenewalExecution{
Public String asstId{get;set;}
Public void ExecuteAutoRenewalExecution(){
AutoRenewalQuoteCreationBatchCls ARQ = new AutoRenewalQuoteCreationBatchCls();
ARQ.assetId = asstId;
    if(!Test.isRunningTest()){   
        Database.executeBatch(ARQ,10);
    }
}
Public void CreateRenewalOpportunity(){
String query = 'Select id,name,Parent_Asset__c,AccountId,Product2Id,Product2.ProductCode,Status,Asset_Stage__c,Quantity,Auto_Renewal__c,BOP_Code__c,Email__c,End_Date__c,Lead_Type__c,Line_Type__c,List_Price__c,Market_Zip__c,Market__c,Market_Tier__c,Ultimate_Parent__c from Asset where Id =:asstId';
List<Asset> lstAsset = Database.Query(query);
Set<Id> setAccountIds = new Set<Id>();
for(Asset ast:lstAsset){
setAccountIds.add(ast.AccountId);
}
if(setAccountIds.size()>0){
                       createOpportunity(setAccountIds);
}
}
 Public void createOpportunity(Set<Id> AccIds) {
        List<Opportunity> lstOpportunity = new List<Opportunity>(); 
            try {
            for(Id AccId:AccIds){
                Opportunity theOpportunity = new Opportunity(
                Name = 'The Opportunity',
                StageName = 'Prospecting',
                CloseDate = system.today(),
                AccountId = AccId,
                Is_Renewal_Opp__c = true,
                Account_Type__c = 'Renewal');
                lstOpportunity.add(theOpportunity); 
                }
        
        
        insert lstOpportunity;
        //return theOpportunity.Id;
        }
        catch(Exception e) {
            system.debug('TRACE: Exception Occurred - ' + e.getStackTraceString());
        ApexPages.addMessage(new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'An internal error occurred while processing your request. Please contact system administrator.'
        ));
        }
    
   // return null;
  }

}