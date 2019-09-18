public class DocuSignStatustriggerHandlerManager {
    //Update waitlist item status to Pending Pre-Auth
    public void giverank(list<dsfs__DocuSign_Status__c> newvalues ,list<dsfs__DocuSign_Status__c> oldvalues) {
        waitlistitemTriggerHandler.skipbeforeupdaterun = true;
    }
    public void updateCPQStatus(Map<Id,dsfs__DocuSign_Status__c> newitems, Map<Id,dsfs__DocuSign_Status__c> olditems){
        list<BigMachines__Quote__c> oracleCPQlist = new list<BigMachines__Quote__c>();
        set<ID>  oppids = new set<ID>();
        map<ID,list<BigMachines__Quote__c>> oppBigMachinesMap = new map<ID,list<BigMachines__Quote__c>>();
        map<ID,ID> oppDocuSignMap = new map<ID,ID>();
        
        
        // get opportunity ids
        for(dsfs__DocuSign_Status__c doc : newitems.values()){
            if(doc.dsfs__Opportunity__c != null && ((doc.dsfs__Sent_Date_Time__c != null && olditems.get(doc.ID).dsfs__Sent_Date_Time__c != doc.dsfs__Sent_Date_Time__c) ||(olditems.get(doc.ID).dsfs__Declined_Date_Time__c != doc.dsfs__Declined_Date_Time__c)||(doc.dsfs__Completed_Date_Time__c != null && olditems.get(doc.ID).dsfs__Completed_Date_Time__c != doc.dsfs__Completed_Date_Time__c) ||(doc.dsfs__Voided_Date_Time__c != null && olditems.get(doc.ID).dsfs__Voided_Date_Time__c != doc.dsfs__Voided_Date_Time__c) )){
                oppIds.add(doc.dsfs__Opportunity__c);
                oppDocuSignMap.put(doc.dsfs__Opportunity__c,doc.id);
            }
        }
        
        // get CPQ ids with respective to opportunity
        for(BigMachines__Quote__c BigMach : [SELECT ID,BigMachines__Opportunity__c FROM BigMachines__Quote__c WHERE BigMachines__Opportunity__c IN: oppIds AND  BigMachines__Is_Primary__c = true]){

            if(!oppBigMachinesMap.containsKey(BigMach.BigMachines__Opportunity__c)){
              oppBigMachinesMap.put(BigMach.BigMachines__Opportunity__c,new list<BigMachines__Quote__c>());
              oppBigMachinesMap.get(BigMach.BigMachines__Opportunity__c).add(BigMach);                  
             } 
            else{
              oppBigMachinesMap.get(BigMach.BigMachines__Opportunity__c).add(BigMach);    
             }  
        }


        set<ID> CpqUnique = new set<ID>();
        
        for(dsfs__DocuSign_Status__c doc : newitems.values()){
            if(doc.dsfs__Opportunity__c != null && oppBigMachinesMap.containsKey(doc.dsfs__Opportunity__c)){    
                    for(BigMachines__Quote__c bquote : oppBigMachinesMap.get(doc.dsfs__Opportunity__c)){
                    if(!CpqUnique.contains(bquote.ID)){
                         
                         if(doc.dsfs__Completed_Date_Time__c != null && olditems.get(doc.ID).dsfs__Completed_Date_Time__c != doc.dsfs__Completed_Date_Time__c){
                            system.debug('-----------In Comp If-------'+bquote.ID);
                            CpqUnique.add(bquote.ID);                      
                            oracleCPQlist.add(new BigMachines__Quote__c(ID=bquote.ID,BigMachines__Status__c='Customer Signed'));                                        

                         }else if(doc.dsfs__Voided_Date_Time__c  != null && olditems.get(doc.ID).dsfs__Voided_Date_Time__c  != doc.dsfs__Voided_Date_Time__c ){
							system.debug('-----------In Comp If-------'+bquote.ID);                            CpqUnique.add(bquote.ID);                      
                            oracleCPQlist.add(new BigMachines__Quote__c(ID=bquote.ID,BigMachines__Status__c='Document Expired'));                                        

                         }else if(doc.dsfs__Declined_Date_Time__c  != null && olditems.get(doc.ID).dsfs__Declined_Date_Time__c != doc.dsfs__Declined_Date_Time__c){
                            system.debug('-----------In Comp If-------'+bquote.ID);                            CpqUnique.add(bquote.ID);
                            CpqUnique.add(bquote.ID);                      
                            oracleCPQlist.add(new BigMachines__Quote__c(ID=bquote.ID,BigMachines__Status__c='Customer Rejected'));                                        

                         }else if(doc.dsfs__Sent_Date_Time__c != null && olditems.get(doc.ID).dsfs__Sent_Date_Time__c != doc.dsfs__Sent_Date_Time__c){                    
                            system.debug('-----------In Comp If-------'+bquote.ID);                            CpqUnique.add(bquote.ID);
                            CpqUnique.add(bquote.ID);                                           
                            oracleCPQlist.add(new BigMachines__Quote__c(ID=bquote.ID,BigMachines__Status__c= 'Pending Signature'));  
                          
                          } 
                      }                                                    
                          
                }            
        }                
        }// end for 
        if(!oracleCPQlist.isEmpty()){
        system.debug('*****'+oracleCPQlist);
            update oracleCPQlist;
        }
    }
}