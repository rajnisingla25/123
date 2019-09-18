public class Commissions_TranscReportingBatchHndlr {
    
    public Commissions_TranscReportingBatchHndlr(List<Commission__c> lstCommissions){
        List<Commissions_Backup__c> lstCommBackupToInsert = new List<Commissions_Backup__c>();
        String commissionBackupFieldAPIName;
        List<Commissions_and_Commissions_Backup__c> lstcommBackupmappingData = Commissions_and_Commissions_Backup__c.getAll().values();
        system.debug('lstcommBackupmappingData***'+lstcommBackupmappingData);
        system.debug('lstcommBackupmappingData***'+lstcommBackupmappingData.size());
        
        Map<String,String> mapCommANDBackupData = new Map<String,String>();
        for(Commissions_and_Commissions_Backup__c commBackup : lstcommBackupmappingData){
            mapCommANDBackupData.put(commBackup.Commissions_API_FieldName__c,commBackup.Commission_Backup_API_FieldName__c);   
        }
        
        if(lstCommissions != null && lstCommissions.size() > 0){ 
            for(Commission__c commission : lstCommissions){
                system.debug('commission####'+commission);
                Commissions_Backup__c backup = new Commissions_Backup__c();
                for(String commissionFieldAPIName : mapCommANDBackupData.keySet()){
                    system.debug('commissionFieldAPIName####'+commissionFieldAPIName);
                	commissionBackupFieldAPIName = mapCommANDBackupData.get(commissionFieldAPIName);//.Commission_Backup_API_FieldName__c;
                    system.debug('commissionBackupFieldAPIName####'+commissionBackupFieldAPIName);                    
                    String[] strRelationFieldName;
                    //Related_to_Asset__r.Account.Customer_Id__c
                    strRelationFieldName = commissionFieldAPIName.split('\\.');
                    sObject obj = (sObject)commission;
                    for(String strRel : strRelationFieldName){  
                        Schema.SObjectType token = obj!= null ? obj.getSObjectType() : null;
						Schema.DescribeSObjectResult dr = token != null ? token.getDescribe() : null;                       
                        if(strRel.endsWith('__r') || (!strRel.endsWith('__c') && (dr != null && dr.fields.getMap().containsKey(strRel+'Id')) && obj.get(strRel+'Id') != null)){                            
                            obj = (sObject)obj.getSObject(strRel);                            
                        }                            
                        else{
                            if(obj != null)
                            	backup.put(commissionBackupFieldAPIName,obj.get(strRel));     
                        }
                    }
                }
                lstCommBackupToInsert.add(backup); 
            }                
                               
        }
        system.debug('lstCommBackupToInsert***'+lstCommBackupToInsert);
        if(lstCommBackupToInsert.size() > 0)
        	insert lstCommBackupToInsert;
    }

}