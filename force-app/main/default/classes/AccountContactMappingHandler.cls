public class AccountContactMappingHandler{
    
    //Variables Declaration
    public id mappedContactId;
    public id mappedAccountId;    
    public List<Account> matchedAccountList = new List<Account>();
    public List<Contact> matchedContactList = new List<Contact>();
    
    public Id contRelationShipRTID = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;  
    
    /*******************************************************************************
    Method Name: FindEmailMatch
    Description: Used to query the Account and Contacts that match the email address
                 and update the case with the matched Account and Contact
    Parameters:  List<emailMessage>
    ReturnType:  None
    *********************************************************************************/
    public void FindEmailMatch(List<emailMessage> emailMessageList){
     
            case currentCase = new case(); 
            emailMessage emailMsg = new emailMessage();
            string fromAddress = '';
            string sordernumber;
            String subjectstring;
            if(emailMessageList.size()>0){            
                emailMsg = emailMessageList[0];
                string caseId = emailMsg.ParentId;
                system.debug('@@ caseId'+caseId);
                //Get Current Case                               
                currentCase = [select id,AccountId,Subject,ContactId,origin from case where id =:emailMsg.parentId];
                if(currentCase.origin!=null){
                    string caseOrigin = currentCase.Origin;                
                    string objectPrefix = caseId.substring(0,3); 
                    //Checking it the email is incoming and the parent object is Case
                    if(emailMsg.Incoming && objectPrefix == '500' && (CaseOrigin.containsIgnoreCase('Email-'))){                
                        fromAddress = emailMsg.fromAddress;
                    }
                    if(currentcase.subject.containsIgnoreCase('Re: Order Confirmation #:')){
                    subjectstring = currentCase.Subject;
                    String[] strArr = subjectstring.split(':');
                    if(strArr.size() >2){
                       sordernumber = strArr[2].trim();
                    } 
                }
                    
                }
            }
            if(sordernumber!=null){
                system.debug('@@ ordernumber '+sordernumber);
                List<order> OrderAccountList = [select AccountId,OrderNumber from Order where OrderNumber =:sordernumber];
                system.debug('@@ OrderAccountList'+OrderAccountList);
                if(OrderAccountList[0].AccountId!=null && currentCase.AccountId==null){
                currentCase.AccountId = OrderAccountList[0].AccountId;
                }
                List<Account_Relationship__c> contactRelationshipList  = [select id, Contact_Role__c, Contact_To__c, Parent_Account__c, Contact_To__r.Type__c,Contact_To__r.Active__c from Account_Relationship__c where Parent_Account__c =:OrderAccountList[0].AccountId and recordTypeId =:contRelationShipRTID and Contact_To__r.Active__c=true and Active__c=true];               
                if(contactRelationshipList[0].Contact_To__c!=null && currentCase.contactId==null){
                currentCase.contactId = contactRelationshipList[0].Contact_To__c;
                }
                try{
                update currentCase;
                }
                catch (Exception ec){system.debug('@@ in exception'+ec.getMessage());}
            }
            try{
            if(fromAddress!='' && sordernumber == null){
                system.debug('@@ fromAddress'+fromAddress);
                  //SOSL Query for fetching the List of Accounts & Contacts which have matched the email address.
                List<List<SObject>> searchAccountList = [FIND :fromAddress IN EMAIL FIELDS 
                                                         RETURNING Account(Email_Address__c)]; 
                                                         //Commented as part of Jira SMCI-554
                                                      //RETURNING Account(Advertiser_Email__c,MLS_Email__c,Other1_Email__c,Other2_Email__c,Primary_Email__c,Email_Address__c)];
                system.debug('@@ searchAccountList'+searchAccountList);

                List<List<SObject>> searchContactList = [FIND :fromAddress IN EMAIL FIELDS 
                                                         RETURNING Contact(email)];
                                                         //Commented as part of Jira SMCI-554
                                                      //RETURNING Contact(email,Optional_Email_2__c,Optional_Email_3__c,Optional_Email_4__c,Optional_Email_1__c,Unique_Email__c )];
                system.debug('@@ searchContactList'+searchContactList);                                          
                matchedAccountList = searchAccountList[0];
                matchedContactList = searchContactList[0];
                
                //If there are matchedContacts
                if(matchedContactList.size()>0){                                    
                    fetchAppropriateContact(matchedContactList);                        
                }
                //If there are matchedAccounts and no Matched contacts
                else if (matchedAccountList.size()>0){
                    fetchAppropriateAccount(matchedAccountList,null);                
                }
                
                //Assigning Account and Contact Id
                if(mappedAccountId!=null && currentCase.AccountId==null){
                    currentCase.AccountId = mappedAccountId;
                }
                if(mappedContactId!=null && currentCase.contactId==null){
                    currentCase.contactId = mappedContactId;
                }  
                //Updating the case
                update currentCase;
            }
        }
        catch(exception e){
            system.debug('@@ in exception'+e.getMessage());
        }
    }
    /*******************************************************************************
    Method Name: fetchAppropriateContact
    Description: Used to fetch the right contact and account from Account Relationship object 
    Parameters:  List<contact>
    ReturnType:  None
    *********************************************************************************/
    public void fetchAppropriateContact(List<contact> contactList){
        try{
            List<Account_Relationship__c> contactRelationshipList = new List<Account_Relationship__c>();
            if(contactList!=null){
                contactRelationshipList = [select id, Contact_Role__c, Contact_To__c, Parent_Account__c, Contact_To__r.Type__c,Contact_To__r.Active__c from Account_Relationship__c where Contact_To__c in:contactList and recordTypeId =:contRelationShipRTID and Contact_To__r.Active__c=true and Active__c=true order by Contact_Role__c DESC,Contact_To__r.Type__c DESC NULLS LAST];               
                if(contactRelationshipList.size()>0){
                    id tempMappedContactId;
                    id tempMappedAccountId;
                    integer primaryContactCount = 0;
                    for(Account_Relationship__c cr:contactRelationshipList){                        
                        if(cr.Contact_Role__c=='Primary Contact'){
                            primaryContactCount++;
                            tempMappedContactId = cr.Contact_To__c;
                            tempMappedAccountId = cr.Parent_Account__c;                            
                        }                
                    }
                    if(primaryContactCount==1){
                        system.debug('@@ in 1 primaryContactCount scenario'+primaryContactCount);
                        mappedAccountId=tempMappedAccountId;
                        mappedContactId=tempMappedContactId;
                    }
                    if(primaryContactCount>1 || primaryContactCount==0){ 
                        system.debug('@@ in Multiple primaryContactCount scenario'+primaryContactCount);                    
                        set<id> accountIdSet = new set<id>();
                        for(Account_Relationship__c cr:contactRelationshipList){
                            accountIdSet.add(cr.Parent_Account__c);
                        }
                        list<account> tempAccountList = new list<account>();
                        tempAccountList = [select id,name from account where id in:accountIdSet];
                        system.debug('@@ calling FetchAppropriateAccountmethod from contact');
                        fetchAppropriateAccount(tempAccountList,contactList);
                    }
                    /*if(primaryContactCount==0){
                        fetchStandardAccount(contactList[0]);
                    }*/
                }
                else{                
                    fetchStandardAccount(contactList[0]);               
                }
            }
        }
        catch(exception e){
            system.debug('@@ in exception in fetchAppropriateContact method'+e.getMessage());
        }
    }
    
    /*******************************************************************************
    Method Name: fetchAppropriateAccount
    Description: Used to fetch the right Account and contact from Account Relationship object 
    Parameters:  List<Account>
    ReturnType:  None
    *********************************************************************************/
    public void fetchAppropriateAccount(list<Account> accountList,List<contact>contactList){
        try{
            system.debug('@@ in fetchAppropriateAccount');
            List<Account_Relationship__c> accountRelationshipList = new List<Account_Relationship__c>();       
            if(accountList!=null){
                if(contactList!=null)
                    accountRelationshipList = [select id, Is_Parent_Primary__c, Contact_To__c, Parent_Account__c, Parent_Account__r.Type, Parent_Account__r.Advertiserid__c, Parent_Account__r.Total_Contract_Value__c from Account_Relationship__c where Parent_Account__c in:accountList and Contact_To__c in:contactList and recordTypeId =:contRelationShipRTID and Active__c=true order by Is_Parent_Primary__c DESC,Parent_Account__r.Type DESC, Parent_Account__r.Total_Contract_Value__c DESC NULLS LAST];
                else
                    accountRelationshipList = [select id, Is_Parent_Primary__c, Contact_To__c, Parent_Account__c, Parent_Account__r.Type, Parent_Account__r.Advertiserid__c, Parent_Account__r.Total_Contract_Value__c from Account_Relationship__c where Parent_Account__c in:accountList and recordTypeId =:contRelationShipRTID and Active__c=true order by Is_Parent_Primary__c DESC,Parent_Account__r.Type DESC, Parent_Account__r.Total_Contract_Value__c DESC NULLS LAST];                    
            }
            system.debug('@@ accountRelationshipList'+accountRelationshipList);
            if(accountRelationshipList.size()>0){
                for(Account_Relationship__c ar:accountRelationshipList){
                    if(ar.Is_Parent_Primary__c){ 
                        system.debug('@@ in IsPrimary'+ar);
                        system.debug('@@ Parent_Account__r.Total_Contract_Value__c'+ar.Parent_Account__r.Total_Contract_Value__c);
                        mappedAccountId = ar.Parent_Account__c;
                        mappedContactId = ar.Contact_To__c;
                        break;
                    }
                }
                if(mappedAccountId==null){
                    for(Account_Relationship__c ar:accountRelationshipList){
                        if(ar.Parent_Account__r.Type=='Realtor Agent'){
                            system.debug('@@ in RealtorAgent'+ar);
                            mappedAccountId = ar.Parent_Account__c;
                            mappedContactId = ar.Contact_To__c;
                            break;
                        }                                
                    }
                }            
                if(mappedAccountId==null){
                    for(Account_Relationship__c ar:accountRelationshipList){
                        if(ar.Parent_Account__r.Type=='Broker'){
                            system.debug('@@ in Broker'+ar);
                            mappedAccountId = ar.Parent_Account__c;
                            mappedContactId = ar.Contact_To__c;
                            break;
                        }
                    }
                }                            
                
                if(mappedAccountId == null){
                   fetchStandardContact(accountList[0]);
                }
            }
            else{
                fetchStandardContact(accountList[0]);                 
            }
        }
        catch(exception e){
            system.debug('@@ in exception in fetchAppropriateAccount method'+e.getMessage());
        }
    }
    /*******************************************************************************
    Method Name: fetchStandardContact
    Description: Used to fetch the standardContact associated with the account
    Parameters:  Account
    ReturnType:  None
    *********************************************************************************/
    public void fetchStandardContact(account acc){
        try{
            system.debug('@@ in fetchStandardContact');
            if(acc!=null){
                list<contact> contList = [select id from contact where accountId=: acc.Id limit 1];
                if(contList.size()>0)
                mappedContactId = contList[0].Id;
                mappedAccountId =acc.id;
            }
        }
        catch(exception e){
            system.debug('@@ in fetchStandardContact'+e.getMessage());
        }
    }
    /*******************************************************************************
    Method Name: fetchStandardAccount
    Description: Used to fetch the standardAccount associated with the Contact
    Parameters:  Contact
    ReturnType:  None
    *********************************************************************************/
    public void fetchStandardAccount(contact con){
        try{
            system.debug('@@ in fetchStandardAccount');
            if(con!=null){
                contact cont = [select id,accountId from contact where Id=: con.Id];
                mappedContactId = cont.Id;
                mappedAccountId =cont.accountId;
            }
        }
        catch(exception e){
            system.debug('@@ in fetchStandardAccount'+e.getMessage());
        }
    }
}