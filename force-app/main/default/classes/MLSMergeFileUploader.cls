public class MLSMergeFileUploader {

    public string nameFile{get;set;}
    public Blob contentFile{get;set;}
    String[] filelines = new String[]{};
    List<MLS_Associations_Merge__c> MLSDatatoupload;
    
    /***This function reads the CSV file and inserts records into the MLS Association Merge object. ***/
    public Pagereference ReadFile() {
        try{
                //Convert the uploaded file which is in BLOB format into a string
                nameFile =blobToString( contentFile,'ISO-8859-1');
                  //nameFile = contentFile.toString();
                  system.debug('In Try Block nameFile'+nameFile);
                //Now sepatate every row of the excel file
                filelines = nameFile.split('\n');
                system.debug('In Try Block filelines.size()'+filelines);
                //Iterate through every line and create an MLS Association Merge record for each row
                MLSDatatoupload = new List<MLS_Associations_Merge__c>();
                //07/31/2017: Pallavi - CRM-1989: Added 100 records limit to avoid View State Error.
                Integer size = filelines.size();
                if(size <=101)
                    size = filelines.size();
                else
                    size = 101;
                for (Integer i=1;i<size;i++)
                {
                    String[] inputvalues = new String[]{};
                    inputvalues = filelines[i].split(',');
                    system.debug('inputvalues'+inputvalues);
                    MLS_Associations_Merge__c a = new MLS_Associations_Merge__c();
                    a.Transaction_Type__c = inputvalues[0];
                    a.Status__c = inputvalues[1];
                    if(inputvalues[2] != '' && inputvalues[2] != null)
                        a.Acccount_Type__c = inputvalues[2];
                    else
                        a.Acccount_Type__c = '';
                    if(inputvalues[3] != '' && inputvalues[3] != null)
                        a.Account_Name__c = inputvalues[3];
                    else
                        a.Account_Name__c = '';
                    if(inputvalues[4] != '' && inputvalues[4] != null)
                        a.OLD_MLS_Set__c = inputvalues[4];
                    else
                        a.OLD_MLS_Set__c = '';    
                    if(inputvalues[5] != '' && inputvalues[5] != null)
                        a.New_MLS_set__c = inputvalues[5];
                    else
                        a.New_MLS_set__c = '';    
                    if(inputvalues[6] != '' && inputvalues[6] != null)
                        a.Primary_MLS_Set__c = inputvalues[6];
                    else
                        a.Primary_MLS_Set__c = '';
                    if(inputvalues[7] != '' && inputvalues[7] != null)
                        a.CLC__c = Integer.valueOf(inputvalues[7]);
                    else
                        a.CLC__c = null;
                    if(inputvalues[8] != '' && inputvalues[8] != null)
                        a.HLC__c = Integer.valueOf(inputvalues[8]);
                    else
                        a.HLC__c = null;
                    if(inputvalues[9] != '' && inputvalues[9] != null)
                        a.Old_MLS_Set_Party_Id__c = inputvalues[9];
                    else
                        a.Old_MLS_Set_Party_Id__c = '';
                    if(inputvalues[10] != '' && inputvalues[10] != null)
                        a.New_MLS_Set_Party_Id__c = inputvalues[10];
                    else
                        a.New_MLS_Set_Party_Id__c = '';
                    if(inputvalues[11] != '' && inputvalues[11] != null)
                        a.Survivor_Party_Id__c = inputvalues[11];
                    else
                        a.Survivor_Party_Id__c = '';
                    if(inputvalues[12] != '' && inputvalues[12] != null)
                        a.Victim_Party_Id__c = inputvalues[12];
                    else
                        a.Victim_Party_Id__c = '';
                    MLSDatatoupload.add(a);
                    system.debug('MLSDatatoupload'+MLSDatatoupload);
                }
         }
         catch(Exception e){
                 ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured reading the CSV file'+e.getMessage());
                ApexPages.addMessage(errormsg);
         }       
           
        return null;
    }
    
    public Pagereference InsertRecords(){
        //07/31/2017: Pallavi - CRM-1989: Added below to code to process all the records in the file.
        try{
            //Convert the uploaded file which is in BLOB format into a string
            //nameFile =blobToString( contentFile,'ISO-8859-1');
            nameFile = contentFile.toString();
            system.debug('In Try Block nameFile'+nameFile);
            //Now sepatate every row of the excel file
            filelines = nameFile.split('\n');
            system.debug('In Try Block filelines.size()'+filelines);
            //Iterate through every line and create an MLS Association Merge record for each row
            MLSDatatoupload = new List<MLS_Associations_Merge__c>();
            for (Integer i=1;i<filelines.size();i++)
            {
                String[] inputvalues = new String[]{};
                inputvalues = filelines[i].split(',');
                system.debug('inputvalues'+inputvalues);
                MLS_Associations_Merge__c a = new MLS_Associations_Merge__c();
                a.Transaction_Type__c = inputvalues[0];
                a.Status__c = inputvalues[1];
                if(inputvalues[2] != '' && inputvalues[2] != null)
                    a.Acccount_Type__c = inputvalues[2];
                else
                    a.Acccount_Type__c = '';
                if(inputvalues[3] != '' && inputvalues[3] != null)
                    a.Account_Name__c = inputvalues[3];
                else
                    a.Account_Name__c = '';
                if(inputvalues[4] != '' && inputvalues[4] != null)
                    a.OLD_MLS_Set__c = inputvalues[4];
                else
                    a.OLD_MLS_Set__c = '';    
                if(inputvalues[5] != '' && inputvalues[5] != null)
                    a.New_MLS_set__c = inputvalues[5];
                else
                    a.New_MLS_set__c = '';    
                if(inputvalues[6] != '' && inputvalues[6] != null)
                    a.Primary_MLS_Set__c = inputvalues[6];
                else
                    a.Primary_MLS_Set__c = '';
                if(inputvalues[7] != '' && inputvalues[7] != null)
                    a.CLC__c = Integer.valueOf(inputvalues[7]);
                else
                    a.CLC__c = null;
                if(inputvalues[8] != '' && inputvalues[8] != null)
                    a.HLC__c = Integer.valueOf(inputvalues[8]);
                else
                    a.HLC__c = null;
                if(inputvalues[9] != '' && inputvalues[9] != null)
                    a.Old_MLS_Set_Party_Id__c = inputvalues[9];
                else
                    a.Old_MLS_Set_Party_Id__c = '';
                if(inputvalues[10] != '' && inputvalues[10] != null)
                    a.New_MLS_Set_Party_Id__c = inputvalues[10];
                else
                    a.New_MLS_Set_Party_Id__c = '';
                if(inputvalues[11] != '' && inputvalues[11] != null)
                    a.Survivor_Party_Id__c = inputvalues[11];
                else
                    a.Survivor_Party_Id__c = '';
                if(inputvalues[12] != '' && inputvalues[12] != null)
                    a.Victim_Party_Id__c = inputvalues[12];
                else
                    a.Victim_Party_Id__c = '';
                MLSDatatoupload.add(a);
                system.debug('MLSDatatoupload'+MLSDatatoupload);
            }
         }
         catch(Exception e){
                 ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured reading the CSV file'+e.getMessage());
                ApexPages.addMessage(errormsg);
         }       
        
        if(!MLSDatatoupload.isEmpty()){
            //Finally, insert the collected records
            try{
                insert MLSDatatoupload;
                Schema.DescribeSObjectResult r = MLS_Associations_Merge__c.sObjectType.getDescribe();
                String keyPrefix = r.getKeyPrefix();
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Records Created Successfully.Thank you!');
                ApexPages.addMessage(msg);
                PageReference pageRef = new PageReference('/'+keyPrefix+'/o');             
                return pageRef;
            }
            catch (Exception e)
            {
                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured inserting the records'+e.getMessage());
                ApexPages.addMessage(errormsg);
            } 
        }
        return null;
    
    }
   
   /**** This function sends back to the visualforce page the list of MLS Association Merge records that were inserted ****/ 
    public List<MLS_Associations_Merge__c> getuploadedMLSRecords()
    {
        if (MLSDatatoupload!= NULL)
            if (MLSDatatoupload.size() > 0)
                return MLSDatatoupload;
            else
                return null;                    
        else
            return null;
    }
    
    public Integer getMLSDataRecords()
    {
        if (filelines != NULL)
            if (filelines.size() > 0)
                return filelines.size()-1;
            else
                return null;                    
        else
            return null;
    } 
        /**
         This function convers the input CSV file in BLOB format into a string
        @param input    Blob data representing correct string in @inCharset encoding
        @param inCharset    encoding of the Blob data (for example 'ISO 8859-1')*/
     
    public static String blobToString(Blob input, String inCharset){
        String hex = EncodingUtil.convertToHex(input);
        System.assertEquals(0, hex.length() & 1);
        final Integer bytesCount = hex.length() >> 1;
        String[] bytes = new String[bytesCount];
        for(Integer i = 0; i < bytesCount; ++i)
            bytes[i] =  hex.mid(i << 1, 2);
        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
    }       
}