//
// (c) 2015 Appirio, Inc.
//
// Apex  Class Name: MoveUtility
//
// 19th May 2015 Ravindra Shekhawat   Utility Class for common methods
//
global without sharing class MoveUtility {
    
    
    
    //This Method Return The QueueSobject for A User
    public static QueueSobject[] getQueueForUser(Id userId){
        
        Set<Id> groupIds = getGroupsForIds(new Set<Id>{userId});
        Set<Id> queueIds = new Set<Id>();
        
        for(GroupMember grp : [Select UserOrGroupId, GroupId From GroupMember Where ( UserOrGroupId IN: groupIds OR UserOrGroupId =:userId ) AND Group.Type = 'Queue']){
            queueIds.add(grp.GroupId);
        }
        return [ SELECT SobjectType, Queue.Name, QueueId, Id FROM QueueSobject WHERE  QueueId IN: queueIds AND  SobjectType = 'Case'];
    }
    
    // return all ids the user belongs to via direct or indirect membership
    public static Set<Id> getGroupsForIds(Set<Id> userOrGroupIds){
        
        Set<Id> output = new Set<Id>();
        
        Set<Id> nestedGroupIds = new Set<Id>();
        
        // only query actual groups and not roles and queues
        list<GroupMember> records = [ SELECT id, GroupId, UserOrGroupId FROM GroupMember
                                     WHERE UserOrGroupId =: userOrGroupIds AND UserOrGroupId != null ];
        
        for (GroupMember record:records)
        {
            // found a group, remember for traversal
            if (!(record.UserOrGroupId + '').startsWith('005'))
            {
                nestedGroupIds.add(record.UserOrGroupId);   
            }
            else
            {
                output.add(record.GroupId);
            }
        }
        
        // call self to get nested groups we found
        if (nestedGroupIds.size() > 0)
        {
            output.addAll(getGroupsForIds(nestedGroupIds));
        }
        
        return output;
    }
    
    // This Method Converts a 15 Digit ID to 18 Digit Id
    public static String convertID15to18(String inID) {
        if (inID.length() == 18) { return inID; }
        else if (inID.length() != 15) { return ''; }
        else {
            String suffix = '';
            for (Integer i = 0; i < 3; i++) {
                Integer flags = 0;
                for (Integer j = 0; j < 5; j++) {
                    String c = inID.substring(i*5+j, i*5+j+1);
                    if ( ( c.compareTo('A') >= 0 ) && ( c.compareTo('Z') <= 0 ) ) {
                        flags += 1 << j;
                    }
                }
                suffix = suffix + 'ABCDEFGHIJKLMNOPQRSTUVWXYZ012345'.substring(flags, flags+1);
            }
            return inID + suffix;
        }
    }
    
    // CRM-2312 Method to check if an email is a bad email or not
    webservice static boolean isBadEmail(String email) {
        boolean badEmail = false;
        if (email == null || email.startswith('bad_') || email.endswith('@default.com')) {
            badEmail = true;
        }
        return badEmail;
    }
    
    // CRM-2312 End
    
  // The following method is to Update Phone fields of Lead, Case, Opportunity from Contact Methods   
    public static void updatePhoneFields(List<SObject> sobjectList, Set<Id> accountIds){
        List<Account_Relationship__c> contactRelationshipList;
        Map<Id,Id> accToContactIds = new Map<Id,Id>();
        List<ContactMethod__c> contactMethodList = new List<ContactMethod__c>();
        Map<String,List<ContactMethod__c>> contactToContactMethodList = new Map<String,List<ContactMethod__c>>();       
        
        contactRelationshipList = new List<Account_Relationship__c>([Select id,name,recordtype.name, Contact_To__c, Contact_Role__c,Parent_Account__c,Child_Account__c from Account_Relationship__c where 
                                                                     Contact_Role__c = 'Primary Contact' and Parent_Account__c IN: accountIds ]);              
        
        if(!contactRelationshipList.isEmpty()){
            for(Account_Relationship__c rel: contactRelationshipList){
                if(rel.Contact_To__c != null){
                    accToContactIds.put(rel.Parent_Account__c,rel.Contact_To__c);                    
                }
            }
        }                       
        
        if(!accToContactIds.isEmpty()){
            contactMethodList = [Select id,name,Type_Purpose__c,Contact__c,Phone__c,Phone_Extension__c,Type__c from ContactMethod__c where 
                                 Contact__c IN: accToContactIds.values() and Type__c = 'Phone' order by Type_Purpose__c,lastmodifieddate ASC];            
            if(!contactMethodList.isEmpty()){
                for(ContactMethod__c cm: contactMethodList){
                    if(!contactToContactMethodList.containsKey(cm.Contact__c)){
                        contactToContactMethodList.put(cm.Contact__c,new List<ContactMethod__c>{cm});
                    }else{
                        contactToContactMethodList.get(cm.Contact__c).add(cm);
                    }                    
                }         
            }
        }        
        system.debug(' *** sobjectList *** '+sobjectList);
        Schema.SObjectType leadSchema = Schema.Lead.getSObjectType();
        Schema.SObjectType caseSchema = Schema.Case.getSObjectType();
        Schema.SObjectType opptySchema = Schema.Opportunity.getSObjectType();
        system.debug( '*** schema type is? ' +leadSchema +' case? '+ caseSchema+ 'oppty? '+opptySchema);
        for(Sobject sobj: sobjectList){                      
            system.debug(' **** getSObjectType()**** '+sobj.getSObjectType());
            if(sobj.getSObjectType() == leadSchema){
                Lead leadRecord = (Lead)sobj;               
                if(!accToContactIds.isEmpty() && accToContactIds.containsKey(leadRecord.Account__c)){
                    String contactId = accToContactIds.get(leadRecord.Account__c);                                      
                    if(!contactToContactMethodList.isEmpty() && contactToContactMethodList.containsKey(contactId)){
                        for(ContactMethod__c cm: contactToContactMethodList.get(contactId)){
                            if(cm.Type_Purpose__c == 'PERSONAL_MOBILE'){
                                leadRecord.Home_Phone__c = cm.Phone__c;
                            }else if(cm.Type_Purpose__c == 'BUSINESS_MOBILE'){
                                leadRecord.Mobile__c = cm.Phone__c;
                            }else if(cm.Type_Purpose__c == 'BUSINESS_PHONE'){
                                leadRecord.Work_Phone__c = cm.Phone__c;
                                leadRecord.Work_Phone_Ext__c = cm.Phone_Extension__c;
                            }else if(cm.Type_Purpose__c == 'PERSONAL_PHONE'){
                                leadRecord.Other_Phone__c = cm.Phone__c;
                                leadRecord.Other_Phone_Ext__c = cm.Phone_Extension__c;
                            }                           
                        }
                    }                   
                }                
            }else if(sobj.getSObjectType() == caseSchema){
                Case caseRecord = (Case)sobj;               
                if(!accToContactIds.isEmpty() && accToContactIds.containsKey(caseRecord.AccountId)){ 
                    String contactId = accToContactIds.get(caseRecord.AccountId);                                      
                    if(!contactToContactMethodList.isEmpty() && contactToContactMethodList.containsKey(contactId)){
                        for(ContactMethod__c cm: contactToContactMethodList.get(contactId)){
                            if(cm.Type_Purpose__c == 'PERSONAL_MOBILE'){
                                caseRecord.Home_Phone__c = cm.Phone__c;
                            }else if(cm.Type_Purpose__c == 'BUSINESS_MOBILE'){
                                caseRecord.Mobile__c = cm.Phone__c;
                            }else if(cm.Type_Purpose__c == 'BUSINESS_PHONE'){
                                caseRecord.Work_Phone__c = cm.Phone__c;
                                caseRecord.Work_Phone_Ext__c = cm.Phone_Extension__c;
                            }else if(cm.Type_Purpose__c == 'PERSONAL_PHONE'){
                                caseRecord.Other_Phone__c = cm.Phone__c;
                                caseRecord.Other_Phone_Ext__c = cm.Phone_Extension__c;
                            }                           
                        }
                    }                   
                }  
            }else if(sobj.getSObjectType() == opptySchema){
                Opportunity opptyRecord = (Opportunity)sobj;               
                if(!accToContactIds.isEmpty() && accToContactIds.containsKey(opptyRecord.AccountId)){ 
                    String contactId = accToContactIds.get(opptyRecord.AccountId);                                      
                    if(!contactToContactMethodList.isEmpty() && contactToContactMethodList.containsKey(contactId)){
                        for(ContactMethod__c cm: contactToContactMethodList.get(contactId)){
                            if(cm.Type_Purpose__c == 'PERSONAL_MOBILE'){
                                opptyRecord.Home_Phone__c = cm.Phone__c;
                            }else if(cm.Type_Purpose__c == 'BUSINESS_MOBILE'){
                                opptyRecord.Mobile_Phone__c = cm.Phone__c;
                            }else if(cm.Type_Purpose__c == 'BUSINESS_PHONE'){
                                opptyRecord.Phone__c = cm.Phone__c;
                                opptyRecord.Work_Phone_Ext__c = cm.Phone_Extension__c;
                            }else if(cm.Type_Purpose__c == 'PERSONAL_PHONE'){
                                opptyRecord.Other_Phone__c = cm.Phone__c;
                                opptyRecord.Other_Phone_Ext__c = cm.Phone_Extension__c;
                            }                           
                        } 
                    }                   
                }  
            }            
        }              
    }        
}