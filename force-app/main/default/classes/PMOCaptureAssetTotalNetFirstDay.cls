global class PMOCaptureAssetTotalNetFirstDay implements Database.Batchable<sObject> {
    
    global Database.querylocator start(Database.BatchableContext BC){
        String query = 'Select id, End_Date__c, Day_One_Total_Net__c, Total_Net__c, Day_One_End_Date__c from Asset where Total_Net__c != null AND End_Date__c = THIS_MONTH';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        //if today is the first day of the month capture todays date and total net value
        //assuming this batch is run on the first day of the month
        SkipAssetTrigger.setSkipTrgTrue(); //input from Sonu Sharma @ Move to skip the Asset trigger
        List<Asset> assetList = new List<Asset>();
        for(sObject s : scope){
            Asset a = (Asset)s;
            a.Day_One_Total_Net__c = a.Total_Net__c;
            a.Day_One_End_Date__c = System.today();
            assetList.add(a);
        }
        update assetList;
    }
    
    global void finish(Database.BatchableContext BC){

    }   
}