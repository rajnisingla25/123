/********************************************************************************************
*   @Author :       Vamsi Ch 
*   @Purpose:       To Assign the emailMessage to the right existing case 
*   @Class          EmailMessageHandler
*   @TestClass      EmailMessageHandler_Test
*   @JIRA           SEP-139
*   @CreatedDate:   July 2nd, 2018
*********************************************************************************************
   JIRA No      Date       Modified By         Description                                Tag No
*********************************************************************************************

*/
Public class EmailMessageHandler{
    //Variable Declaration
    public static string subjectDelimiter = 'Case Number ';
    public static Map<string,EmailMessage> caseNumberEmailMessageMap{get;set;} //Map to hold the link between CaseNumber and related Email Message record
    public static Map<string,case> emailMessageCaseMap{get;set;} //Map to hold the Link between emailMessageId and clonedEmailMessage
    public static boolean isFirstRun=false;    
    public static set<id> finalEmailMessageIds {get;set;}
    
   
   
    /*******************************************************************************
    Method Name: assignToExistingCase
    Description: Used to assign the EmailMessage to the Existing Case if the subject contains CaseNumber
    Parameters:  List<emailMessage>
    ReturnType:  None
    *********************************************************************************/
    public static void assignToExistingCase(list<EmailMessage> newEmailMessageList){
        
        try{            
            isFirstRun =false;
            finalEmailMessageIds = new set<id>();            
            List<case> existingCaseList = new List<case>();
            List<emailMessage> clonedEmailMessageList = new List<emailMessage>();
            caseNumberEmailMessageMap = new Map<string,EmailMessage>();
            emailMessageCaseMap = new Map<string,case>();
            
            //Invoke parseCaseNumberFromSubject method to parse the casenumber
            parseCaseNumberFromSubject(newEmailMessageList); 
            
            //If the subject has Case Number
            if(caseNumberEmailMessageMap.size()>0){
                
                existingCaseList = [select id,caseNumber,Case_Thread_Id__c,subject from case where caseNumber in:caseNumberEmailMessageMap.keySet()];
                set<id> casesToBeDeletedIdSet = new set<id>();
                
                //Filtering out the invalid casenumbers
                for(case c: existingCaseList){
                    emailMessageCaseMap.put(caseNumberEmailMessageMap.get(c.caseNumber).id,c);
                    casesToBeDeletedIdSet.add(caseNumberEmailMessageMap.get(c.caseNumber).parentId);
                }
                
                system.debug('@@ casesToBeDeletedIdSet'+casesToBeDeletedIdSet);                
                //Calling the method to assign the new cases to CasesToBeDeleted Queue
                assignNewCaseToDeletedCasesQueue(casesToBeDeletedIdSet);
                
                //Cloning the emailMessages to reparent them to the case in the subject
                for(emailMessage em:caseNumberEmailMessageMap.values()){
                    if(emailMessageCaseMap!=null){
                        emailMessage newEm = em.clone(false,true,true);
                        system.debug('@@ emailMessageCaseMap'+emailMessageCaseMap);
                        system.debug('@@ caseId'+emailMessageCaseMap.get(em.id));            
                        newEm.parentId = emailMessageCaseMap.get(em.id).Id;
                        newEm.ThreadIdentifier = emailMessageCaseMap.get(em.id).Case_Thread_Id__c;
                        clonedEmailMessageList.add(newEm);    
                    }            
                }
                
                //Boolean check for recursion
                isFirstRun =true;
                insert clonedEmailMessageList;                

                system.debug('@@ finalEmailMessageIds'+finalEmailMessageIds);
                //Invoke Queueable Apex to Insert Attachments related to the cloned Email messages
                System.enqueueJob(new InsertAttachmentsQueuable(finalEmailMessageIds,clonedEmailMessageList,false));            
            }
        }
        catch(exception e){
            system.debug('@@ in exception in assignToExistingCase'+e.getMessage());
        }
        
    }
    
    /*******************************************************************************
    Method Name: parseCaseNumberFromSubject
    Description: Used to parse the casenumber and generate a map for emailMessages and the related Cases
    Parameters:  List<emailMessage>
    ReturnType:  None
    *********************************************************************************/
    
    public static void parseCaseNumberFromSubject(List<EmailMessage> newEmailMessageList){
        try{                        
            finalEmailMessageIds = new set<id>();
            set<id> caseIdSet = new set<id>();
            for(emailMessage em: newEmailMessageList){        
                caseIdSet.add(em.parentId);
            }
            list<case> caseList = [select id,origin,casenumber from case where id in:caseIdSet];
            Map<id,case> emailMsgOriginMap = new Map<id,case>();
            for(emailMessage em: newEmailMessageList){ 
                for(case c: caseList){
                    if(c.id==em.parentId){
                        emailMsgOriginMap.put(em.id,c);
                    }
                }                    
            }
            for(emailMessage em: newEmailMessageList){
                string caseId = em.ParentId;
                string objectPrefix = caseId.substring(0,3);
                string caseOrigin = '';
                if(emailMsgOriginMap.size()>0){
                    caseOrigin = emailMsgOriginMap.get(em.id).origin;
                }
                //Checking it the email is incoming and the parent object is Case
                if(em.Incoming && objectPrefix == '500' && caseOrigin!='' && (caseOrigin.containsIgnoreCase('Email-'))){  
                    system.debug('@@ em.subject'+em.subject);
                    system.debug('@@ em.ThreadIdentifier'+em.ThreadIdentifier);
                    if(em.subject.containsIgnoreCase(subjectDelimiter)){
                        system.debug('@@ subject has caseNumber');
                        string subject = em.subject;
                        //Splitting CaseSubject based on the caseDelimiter
                        list<string> subjectParts = subject.split(subjectDelimiter);
                        system.debug('@@subjectParts'+subjectParts);
                        system.debug('@@ subjectParts[subjectParts.size()-1]'+subjectParts[subjectParts.size()-1]);
                        //Parsing the caseNumber from Subject
                        string caseNumber= subjectParts[subjectParts.size()-1].substring(0,8);
                        system.debug('@@ caseNumber'+caseNumber);                                        
                        
                        if(caseNumber!=null && caseNumber.isNumeric() && emailMsgOriginMap.get(em.id).caseNumber!=caseNumber){
                            caseNumberEmailMessageMap.put(caseNumber,em);                        
                            finalEmailMessageIds.add(em.id);
                        }
                    }
                }
            }
            system.debug('@@ finalEmailMessageIds in setting method'+finalEmailMessageIds);
            system.debug('@@ caseNumberEmailMessageMap'+caseNumberEmailMessageMap);       
        }
        catch(exception e){
            system.debug('@@ in exception in parseCaseNumberFromSubject'+e.getMessage());
        }
    }
    
    /*******************************************************************************
    Method Name: assignNewCaseToDeletedCasesQueue
    Description: Used to assign the new Cases to Cases To Be Deleted Queue
    Parameters:  List<emailMessage>
    ReturnType:  None
    *********************************************************************************/
    
    public static void assignNewCaseToDeletedCasesQueue(set<id> casesToBeDeleted){
        try{
            list<case> newCaseList = new list<case>();        
            group casesToBeDeletedQueue = [select id,type from group where name='Cases to be Deleted' limit 1];
            //QueueSObject QueueID = [Select Queue.Id, Queue.Name, Queue.Type from QueueSObject WHERE Queue.Type ='Queue' AND Queue.Name ='Cases_to_be_Deleted' Limit 1];        
            system.debug('@@ casesToBeDeleted'+casesToBeDeleted);
            newCaseList = [select id,ownerId from case where id in:casesToBeDeleted];
            for(case c: newCaseList){
                c.ownerId =casesToBeDeletedQueue.id;
                c.status = 'C3ToolsToE2C';
            }
            Database.DMLOptions dmo = new Database.DMLOptions();
            //Assign the default (active) assignment rule for the case
            dmo.assignmentRuleHeader.useDefaultRule = false;
            Database.update(newCaseList, dmo);     
            //update newCaseList;
        }
        catch(exception e){
            system.debug('@@ in exception in assignNewCaseToDeletedCasesQueue'+e.getMessage());
        }
    }
    
   
}