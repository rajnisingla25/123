public class MLSMergeController {
    public String selectedInsert2{get;set;}
    
    public MLSMergeController (){
    }
    public List<SelectOption> getInsertOptions() {
        List<SelectOption> insertOptions = new List<SelectOption>();
        insertOptions.add(new SelectOption('Single Record','Single Record'));
        insertOptions.add(new SelectOption('File Insert','File Insert'));
        return insertOptions;
    }

    public PageReference redirect(){
        if(selectedInsert2 == 'File Insert'){
            PageReference pageRef = new PageReference('/apex/MLSDataImport');
            return pageRef;
        }
        else{
            Schema.DescribeSObjectResult r = MLS_Associations_Merge__c.sObjectType.getDescribe();
            String keyPrefix = r.getKeyPrefix();
            PageReference pageRef = new PageReference('/'+keyPrefix+'/e');
            return pageRef;           
        }
    }

}