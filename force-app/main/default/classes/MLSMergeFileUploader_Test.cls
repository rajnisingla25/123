@isTest
public class MLSMergeFileUploader_Test{
    static testmethod void testfileupload(){
         StaticResource testdoc = [Select Id,Body from StaticResource where name ='testMethodMLSUpload'];
         MLSMergeFileUploader  testUpload = new MLSMergeFileUploader();
         testUpload.contentFile= testdoc.Body;
         testUpload.ReadFile();
         testUpload.InsertRecords();
         testUpload.getuploadedMLSRecords(); 
    }
    
    static testmethod void testfileupload2(){
         //StaticResource testdoc = [Select Id,Body from StaticResource where name ='testMethodMLSUpload'];
         MLSMergeFileUploader  testUpload = new MLSMergeFileUploader();
         testUpload.contentFile= Blob.valueOf('\n,,, \n \n \n');
         testUpload.ReadFile();
         testUpload.InsertRecords();
         testUpload.getuploadedMLSRecords(); 
    }
    
    static testmethod void testfileupload3(){
         //StaticResource testdoc = [Select Id,Body from StaticResource where name ='testMethodMLSUpload'];
         MLSMergeFileUploader  testUpload = new MLSMergeFileUploader();
         String strFile='Transaction_Type__c,Status__c,Acccount_Type__c,Account_Name__c,OLD_MLS_Set__c,New_MLS_set__c,Primary_MLS_Set__c,CLC__c,HLC__c,Old_MLS_Set_Party_Id__c,New_MLS_Set_Party_Id__c,Survivor_Party_Id__c,Victim_Party_Id__c'
                        +'\nMerge,New,null,null';
         testUpload.contentFile= Blob.valueOf(strFile);
         testUpload.ReadFile();
         testUpload.InsertRecords();
         testUpload.getuploadedMLSRecords(); 
    }
    
}