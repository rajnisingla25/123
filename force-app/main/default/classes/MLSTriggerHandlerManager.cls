public class MLSTriggerHandlerManager {

    public void AccountMLSUpdate(map<ID,MLS__c> newMap,map<ID,MLS__c> oldMap){
        
            map<ID,MLS__c> mlsAccounts = new map<ID,MLS__c>();
            list<Account> accList = new list<Account>();
            
            for(MLS__c omls:newmap.values()){
                // if checkbox is modified
                if(oldmap != null && oldmap.containsKey(omls.ID) && oldmap.get(omls.ID).Primary_MLS_Set__c  != omls.Primary_MLS_Set__c){
                    if(omls.Primary_MLS_Set__c == true){
                        if(omls.Office__c != null && omls.MLS_Set_Type__c == 'Office')
                             mlsAccounts.put(omls.Office__c,omls);                                                   
                        if(omls.Agent__c != null && omls.MLS_Set_Type__c == 'Agent')
                             mlsAccounts.put(omls.Agent__c,omls); 
                    }                                                                           
                }
            }
            
            for(Account oacc:[SELECT Id,MLS_Set_Id__c FROM Account WHERE ID IN: mlsAccounts.keyset()]){ 
                Account tempAccount =  new Account(ID=oacc.ID);
                if(mlsAccounts.containsKey(oacc.ID)){
                    if(mlsAccounts.get(oacc.ID).Primary_MLS_Set__c){
                       tempAccount.MLS_Set_Id__c = mlsAccounts.get(oacc.ID).MLS_Set_ID__c;
                    }
                    else{
                      tempAccount.MLS_Set_Id__c = '';
                    }                                                                      
                     accList.add(tempAccount);  
                }
            }
            if(!accList.isEmpty()){
                update accList;
            }
        
    }

}