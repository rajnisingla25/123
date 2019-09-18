//**************************************************//
// (c) 2015 NTTDATA, Inc.
// Class Name : CountRelatedchildCases 
// This Class is Used to count the related child cases on the parent case and displays the count. 
//
// Created 20th aug 2015   Author Name:-  Venkataratamana Cheedara     Original
// Modified 20th aug 2015   Author Name:-  Venkataratamana Cheedara     Modified
//**************************************************//

public class CountRelatedchildCases {
    Set<Id> ParentIds = new Set<id>();
    Set<Id> UpdatedParentIds = new Set<id>();
    Public void countRelatedcases(List<Case> AllCases,Boolean isInsert){        
        if(isInsert){
            for (Case c: AllCases) {
                if(c.ParentId != null) {
                    ParentIds.add(c.ParentId);
                }
            }
        
        
        List<Case> pcount = [Select Id,Date_of_Last_Added_Child_Case__c, (Select Id from Cases) From CASE where Id IN : ParentIds];   
        for(Case pc : pcount){
            pc.Child_cases__c= pc.cases.size();
            pc.Date_of_Last_Added_Child_Case__c = system.today();
        }     
          update pcount;
       }
    }  

     
    public  void updateCases(map<ID,Case> newmap,map<ID,Case> oldmap,Boolean isUpdate){
        // CRM-3765 - Set for new parent case ids
        Set<Id> newParentCaseIds = new Set<Id>();
        for(Case c : newmap.Values()){
            case cs = oldmap.get(c.id);
            if(isUpdate){
             system.debug('1111111'+c.id);
                // CRM-2543 Changed below if to consider the scenario where old/new case might have parent asset as null
                //if (cs.parentid != null && c.ParentId != null && c.ParentId != cs.parentid ) {     
                if (c.ParentId != cs.parentid) { 
                    if (cs.parentid != null) {  // CRM-2543 Added check
                        ParentIds.add(cs.parentid);
                    }
                    if (c.ParentId != null) { // CRM-2543 Added check
                        ParentIds.add(c.parentid);
                        newParentCaseIds.add(c.ParentId); //CRM-3765 - Add new parent case id.
                    }
                    //UpdatedParentIds.add(c.ParentId);
                    //system.debug('222222'+c.parentid);
                }
            }
        } 
        
         // CRM-1423 Added condition to avoid executing SOQL if set is empty
         if (!ParentIds.isEmpty()) {
            List<Case> pcount = [Select Id, (Select Id from Cases) From CASE where Id IN : ParentIds];
            //List<Case> pccount = [Select Id, (Select Id from Cases) From CASE where Id IN : UpdatedParentIds];   
             
            for(Case pc : pcount){
                pc.Child_cases__c= pc.cases.size(); 
                // CRM-3765 - Update Date_of_Last_Added_Child_Case__c on new Parent
                if (newParentCaseIds.contains(pc.Id)) {
                    pc.Date_of_Last_Added_Child_Case__c = system.today();
                }
                // CRM-3765 - End
            }  
            try{   
            update pcount;
            }catch(Exception e){}
        }
        // for(Case pc1 : pccount){
         //   pc1.Child_cases__c= pc1.cases.size();
       // }  
        try{   
        //update pccount;
        }catch(Exception e){} 
    }
    // Modified by Ravinder - 11/11/2015
    public static boolean isRecurrsion = false;
    public static void updateChildCases(map<ID,Case> newmap,map<ID,Case> oldmap,Boolean isUpdate)
    {
        set<ID> oParentIDs = new set<ID>();
        list<Case> UpdateCase = new list<Case>();
        
      for(case oCase : newmap.values()){
          if(oCase.ParentID != null && oldmap != null && oldmap.containsKey(oCase.ID) && oldmap.get(oCase.ID).ParentID != oCase.ParentID){
              oParentIDs.add(oCase.ParentID);
          }

        List<Case> pcount = [Select Date_of_Last_Added_Child_Case__c,Id,ParentID, (Select Id from Cases) From CASE where Id IN : oParentIDs];                      
        for(Case pc : pcount){
            pc.Child_cases__c= pc.cases.size();  
            pc.Date_of_Last_Added_Child_Case__c = system.today();
            UpdateCase.add(pc);            
        } 
        if(!UpdateCase.isEmpty()){  
            isRecurrsion = true;
            update UpdateCase;
        }
          
      }
    }
        
    public void deleteCases(map<ID,Case> oldmap,Boolean isDelete){  
        for (Case c: oldmap.values()) {
            if(isDelete){
                if(c.ParentId != null) {
                    ParentIds.add(c.ParentId);
                }
            }   
        }
        system.debug('ParentIds:'+ParentIds);
        List<Case> pcount = [Select Id, (Select Id from Cases) From CASE where Id IN : ParentIds];   
        for(Case pc : pcount){
            pc.Child_cases__c= pc.cases.size();
        }     
        update pcount;  
    } 
  
}