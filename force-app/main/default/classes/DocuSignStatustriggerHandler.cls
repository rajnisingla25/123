public class DocuSignStatustriggerHandler {
    Public static boolean skipbeforeupdaterun = false;
    Public static boolean skipafterupdaterun = false;
    
    Public static boolean runRerank = true;  // CRM-2816 To skip running re-rank for Amend Waitlist
    
    DocuSignStatustriggerHandlerManager Manager = new DocuSignStatustriggerHandlerManager();
    // Before Update Method of Trigger
    public void onBeforeUpdate(Map<Id,dsfs__DocuSign_Status__c> newitems, Map<Id,dsfs__DocuSign_Status__c> olditems) {
        DocuSignStatustriggerHandlerManager Manager = new DocuSignStatustriggerHandlerManager();
        //CRM-5678
        if(newitems != null && newitems.size() > 0){
            for(dsfs__DocuSign_Status__c dsStatus : newitems.values()){
                dsfs__DocuSign_Status__c oldDSStatus = olditems.get(dsStatus.Id);
                if(oldDSStatus != null && 'Void'.equalsIgnoreCase(oldDSStatus.dsfs__Envelope_Status__c) &&('Delivered'.equalsIgnoreCase(dsStatus.dsfs__Envelope_Status__c) || 'Completed'.equalsIgnoreCase(dsStatus.dsfs__Envelope_Status__c))){
                    dsStatus.dsfs__Envelope_Status__c = 'Void';
                }
            }            
        }//CRM-5678 Ends
    }
    
    // After Update Method of Trigger
    public void onAfterUpdate(Map<Id,dsfs__DocuSign_Status__c> newitems, Map<Id,dsfs__DocuSign_Status__c> olditems) {    
        Manager.updateCPQStatus(newitems,olditems);
        
    }
    
    public void onAfterUpdateforWaitList(Map<Id,dsfs__DocuSign_Status__c> newitems) {    
        List<dsfs__DocuSign_Status__c> docuSignSttaus = newitems.values();
        
        for(dsfs__DocuSign_Status__c status :docuSignSttaus){
            if(status.dsfs__Envelope_Status__c =='Declined' &&  status.Waitlist__c != null ){
                
                Waitlist__c waitListRecords =  [Select id from Waitlist__c where id=:status.Waitlist__c] ;
                waitListRecords.Status__c='Rejected Pre-Auth';
                update waitListRecords ;  
                List<Waitlist_Item__c> wlitem12 = [Select Id, Waitlist_Expiration_Date__c  from Waitlist_Item__c
                                                   where Waitlist__c=:status.Waitlist__c
                                                   AND Status__c IN ('Active','Pending Pre-Auth','Created','Pending Pre-Auth Approval')];
                List<Waitlist_Item__c> wlItemstobeUpdate = new   List<Waitlist_Item__c>();
                for(Waitlist_Item__c w :wlitem12 ){
                   // w.Waitlist_Expiration_Date__c = System.today()+90 ; //CRM-4683
                    w.Status__c='Rejected Pre-Auth';
                    wlItemstobeUpdate.add(w);
                }
                update wlItemstobeUpdate ;
                
            }
            
            if(status.dsfs__Envelope_Status__c =='Voided' &&  status.Waitlist__c != null ){
                Waitlist__c waitListRecords =  [Select id from Waitlist__c where id=:status.Waitlist__c] ;
                // CRM-4190 - Changes status value from Canceled to Abandoned
                waitListRecords.Status__c='Abandoned'; //'Canceled ';
                update waitListRecords ;  
                List<Waitlist_Item__c> wlitem12 = [Select Id, Waitlist_Expiration_Date__c  from Waitlist_Item__c
                                                   where Waitlist__c=:status.Waitlist__c
                                                   AND Status__c IN ('Active','Pending Pre-Auth','Created','Pending Pre-Auth Approval')];
                List<Waitlist_Item__c> wlItemstobeUpdate = new   List<Waitlist_Item__c>();
                for(Waitlist_Item__c w :wlitem12 ){
                  //  w.Waitlist_Expiration_Date__c = System.today()+90 ; //CRM-4683
                    w.Status__c='Canceled';
                    wlItemstobeUpdate.add(w);
                }  
                update wlItemstobeUpdate ;
            }
            
            if(status.dsfs__Envelope_Status__c =='Completed' &&  status.Waitlist__c != null ){
                System.debug('status.Waitlist__c '+status.Waitlist__c );
                String accid = [Select Id , Account__c  from  Waitlist__c where Id=:status.Waitlist__c].Account__c ;
                System.debug('accid ====>'+accid);
                if(accid!=null){
                   // Waitlist__c waitListRecords =  [Select id , Pre_Auth_Type__c  from Waitlist__c where Account__c=:accid order by Name DESC LImit 1 ] ;

                   Waitlist__c waitListRecords = [Select id, Pre_Auth_Type__c, Status__c  from Waitlist__c where id =: status.Waitlist__c]; // CRM-2193
                   if(waitListRecords.Status__c != 'Canceled' && waitListRecords.Status__c != 'Expired'){ //CRM-2560

                    if(waitListRecords.Pre_Auth_Type__c=='Renew'){
                        waitListRecords.Status__c=' Renewed';    
                        
                        update waitListRecords ;
                        
                        List<Waitlist_Item__c> wlitem = [Select Id, Pre_Auth_Type__c, Waitlist_Expiration_Date__c ,Waitlist__r.Submitted_Date__c , Is_Renewed_Row__c 
                                                         from Waitlist_Item__c where Waitlist__c  =:waitListRecords.Id AND Status__c='Pending Pre-Auth Approval'];
                        List<Waitlist_Item__c> wlItemstobeUpdate = new   List<Waitlist_Item__c>();
                        System.debug('wlitem'+wlitem);
                        for(Waitlist_Item__c w :wlitem ){
                            If( w.Is_Renewed_Row__c){
                                if(w.Pre_Auth_Type__c == 'New'){ //CRM-1551
                                    w.status__c = 'Active';     //CRM-1551
                                }                               //CRM-1551
                                else{                           //CRM-1551
                                    w.Status__c='Renewed';      //CRM-1551
                                }                               //CRM-1551
                              //  w.Rank__c = 0 ;
                                w.Amendment_Status__c='';
                            } 
                            
                            wlItemstobeUpdate.add(w);
                        }
                        if(wlItemstobeUpdate.size()>0){
                            update wlItemstobeUpdate ; 
                        }
                                                                        
                    }else{
                       // waitListRecords.Waitlist_Expiration_Date__c  = System.today()+90 ;
                        waitListRecords.Status__c=' Active';
                        update waitListRecords ;
                        List<Waitlist_Item__c> wlitem = [Select Id, Waitlist_Expiration_Date__c  
                                                         from Waitlist_Item__c where Waitlist__c  =:waitListRecords.Id AND Status__c='Pending Pre-Auth Approval'];
                        List<Waitlist_Item__c> wlItemstobeUpdate = new   List<Waitlist_Item__c>();
                        System.debug('wlitem'+wlitem);
                        for(Waitlist_Item__c w :wlitem ){
                            //w.Waitlist_Expiration_Date__c = System.today()+90 ; //CRM-4683
                            w.Status__c='Active';
                            w.Amendment_Status__c='';
                            wlItemstobeUpdate.add(w);
                        }
                        if(wlItemstobeUpdate.size()>0){
                            update wlItemstobeUpdate ; 
                        }
                        if(accid!=null){
                            Account acc = [Select id ,Pre_Auth_Expiration_Date__c  from Account where id =:accid];
                            acc.Pre_Auth_Expiration_Date__c = System.today()+90 ;
                            update acc ;
                            System.debug('acc'+acc);
                        }
                        List<Waitlist__c> waitOldListRecords =  [Select id,Status__c from Waitlist__c where Account__c=:accid AND ID != :waitListRecords.Id];
                        Set<Id> ids = new Set<Id>();
                        for(Waitlist__c wTem :waitOldListRecords){
                            wTem.Status__c='Canceled';
                           // wTem.Waitlist_ID__c = '0';
                            ids.add(wTem.Id);                        
                        }
                        update waitOldListRecords ;
                        List<Waitlist_Item__c> wlitem12 = [Select Id, Waitlist_Expiration_Date__c  from Waitlist_Item__c
                                                           where Waitlist__c IN: ids AND Status__c IN ('Active','Pending Pre-Auth','Created','Pending Pre-Auth Approval')];
                        for(Waitlist_Item__c wTem12 :wlitem12){
                            wTem12.Status__c='Canceled';
                          //  wTem12.Waitlist_ID__c = '0'; //CRM-1717
                        }
                        
                        DocuSignStatustriggerHandler.runRerank = false;  // CRM-2816 Do no run Re-Rank for Amend
                        update wlitem12 ; 
                        
                    }
                }
                    
                } 
                
                
            } 
        }
    }
    
    
    
    public void onAfterInsert(Map<Id,dsfs__DocuSign_Status__c> newitems) {    
        List<dsfs__DocuSign_Status__c> docuSignSttaus = newitems.values();
        for(dsfs__DocuSign_Status__c status :docuSignSttaus){
            
            if(status.dsfs__Envelope_Status__c =='Sent' &&  status.Waitlist__c != null ){
                Waitlist__c waitListRecords =  [Select id,Submitted_Date__c  from Waitlist__c where id=:status.Waitlist__c] ;
                waitListRecords.Status__c='Pending Pre-Auth Approval';
                update waitListRecords ;  
                List<Waitlist_Item__c> wlitem12 = [Select Id, Waitlist_Expiration_Date__c ,Is_Renewed_Row__c  , Waitlist__r.Submitted_Date__c from Waitlist_Item__c
                                                   where Waitlist__c=:status.Waitlist__c
                                                   AND Status__c='Pending Pre-Auth' ];
                List<Waitlist_Item__c> wlItemstobeUpdate = new   List<Waitlist_Item__c>();
                for(Waitlist_Item__c w :wlitem12 ){
                    If(w.Is_Renewed_Row__c){
                        w.Waitlist_Expiration_Date__c = w.Waitlist__r.Submitted_Date__c.addDays(90) ;
                    }else{
                        w.Waitlist_Expiration_Date__c = system.today().addDays(90) ;
                    }
                    w.Status__c='Pending Pre-Auth Approval';
                    
                    wlItemstobeUpdate.add(w);
                }
                update wlItemstobeUpdate;
            }
        }
        
    }
    //CRM-1103 - to update account after completion of docusign for payment plan
    public void updateAccount(Map<Id,dsfs__DocuSign_Status__c> newitems){
        List<Account> acclist = new List<Account>();
        for(dsfs__DocuSign_Status__c status :newitems.values()){
            if(status.dsfs__Envelope_Status__c =='Completed' &&  status.Waitlist__c == null && status.dsfs__Case__c != null &&status.dsfs__Subject__c.contains('Payment')){
                Account acc = new Account();
                acc.Id = status.dsfs__Company__c;
                acc.Payment_Plan__c = TRUE;
                acc.Payment_Plan_Date_Time__c = system.now();
                acclist.add(acc);
            }
        }
        if(acclist!=null && acclist.size()>0){
            Update acclist;
        }
    }
}