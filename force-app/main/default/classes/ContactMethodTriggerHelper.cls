public with sharing class ContactMethodTriggerHelper{
    private static final String ContactMethodType_Email = 'Email';
    private static final String ContactMethodType_Phone = 'Phone';
    private static final String ContactMethodType_Web = 'Social'; 
    private static final String ContactMethodTypePurpose_HomepageURL = 'HomePage';  
    private static final String CONTACT_ROLE_PRIMARYCONTACT = 'Primary Contact';
    private static final String CMTypePurpose_BMobile = 'BUSINESS_MOBILE';
    private static final String CMTypePurpose_PMobile = 'PERSONAL_MOBILE';
    private static final String CMTypePurpose_HomePage = 'HomePage';
    
    public static void contactMethodValidations(List<ContactMethod__c> newContactMethodList,Map<Id,ContactMethod__c> oldContactMethodMap){           
        for(ContactMethod__c cm: newContactMethodList){
            String externalId = cm.External_ID__c != null ? ' External Id is: '+cm.External_ID__c : '';
            System.debug('cm:'+cm);
            if(cm.Primary_To_Contact__c && !cm.Active__c){
                cm.addError(' Contact Method which is Primary to Contact cannot be Inactive. '+externalId);
            }
            if(ContactMethodType_Web.EqualsIgnoreCase(cm.Type__c) && String.isBlank(cm.Value__c)){
                cm.addError(' Contact Method Value Cannot be Empty for Type: Web. '+externalId);
            }           
            if(ContactMethodType_Email.EqualsIgnoreCase(cm.Type__c) && NULL == cm.Email__c){
                cm.addError(' Contact Method Email Cannot be Empty for Type Email. '+externalId);
            }
            if(ContactMethodType_Phone.EqualsIgnoreCase(cm.Type__c) && NULL == cm.Phone__c){
                cm.addError(' Contact Method Phone Cannot be Empty for Type Phone. '+externalId);
            }
            if((ContactMethodType_Email.EqualsIgnoreCase(cm.Type__c) || ContactMethodType_Phone.EqualsIgnoreCase(cm.Type__c) || ContactMethodType_Web.EqualsIgnoreCase(cm.Type__c)) && String.isBlank(cm.Type_Purpose__c)){
                cm.addError(' Contact Method Type Purpose Cannot be Empty for Type: '+cm.Type__c+' '+externalId);
            }
            if((ContactMethodType_Email.EqualsIgnoreCase(cm.Type__c) || ContactMethodType_Phone.EqualsIgnoreCase(cm.Type__c) || ContactMethodType_Web.EqualsIgnoreCase(cm.Type__c)) && String.isBlank(cm.Source_Type__c)){
                cm.addError(' Please enter Source Type: '+cm.Type__c+' '+externalId);
            }
            if(ContactMethodType_Email.EqualsIgnoreCase(cm.Type__c) && ( null != cm.Phone__c || null != cm.Phone_Extension__c)){
                cm.addError(' Contact Method of Email Type should not have Phone or Phone Extension. '+externalId);
            }
            if(ContactMethodType_Phone.EqualsIgnoreCase(cm.Type__c) && null != cm.Email__c){
                cm.addError(' Contact Method of Phone Type should not have Email. '+externalId);
            }
            if(ContactMethodType_Phone.EqualsIgnoreCase(cm.Type__c) && (cm.Phone__c.StartsWithIgnoreCase('+')  || cm.Phone__c.StartsWithIgnoreCase('1'))){
                cm.addError(' Contact Method of Phone Type should not start with + or 1 '+externalId);
            }
            if(ContactMethodType_Web.EqualsIgnoreCase(cm.Type__c) && 
               (null != oldContactMethodMap && cm.Type_Purpose__c != oldContactMethodMap.get(cm.Id).Type_Purpose__c)){
                   cm.addError(' Type Purpose cannot be changed for Type Web '+externalId);
               }
            if((CMTypePurpose_BMobile.EqualsIgnoreCase(cm.Type_Purpose__c)|| CMTypePurpose_PMobile.EqualsIgnoreCase(cm.Type_Purpose__c)) && cm.Phone_Extension__c != null){
                cm.addError('No Phone Extension for Mobile.');
            }
            if(cm.Type_Purpose__c == 'BUSINESS_FAX' && (cm.Primary_To_Contact__c == true || cm.Primary_To_Account__c == true)){
                cm.addError('Business Fax cannot be Primary.');
            }
            
            if(ContactMethodType_Phone.EqualsIgnoreCase(cm.Type__c)){
                Pattern p = Pattern.compile('[-() ]');
                String sPhone = p.matcher(cm.Phone__c).replaceAll('');
                // check length without punctuation           
                if(sPhone.length() != 10)
                    cm.Phone__c.addError(' Phone number must be 10 digits'+externalId); 
                if(!sPhone.isNumeric())
                    cm.Phone__c.addError(' Phone number cannot have letters'+externalId); 
            }  
            
            system.debug('cm.Phone__c  =='+cm.Phone__c);
            //Added by Pratik on 21st February 2019 for SMCI-454
            if(cm.Phone__c != Null)
                cm.Phone_Text__c = convertFromFormatted(cm.Phone__c);
        }            
    }
    
    public static string convertFromFormatted(string phone)
    {
        system.debug('phone  =='+phone);
        string retPhone = '';
        string strChar;
        for(Integer iCount = 0; iCount < phone.length(); iCount++)
        {
            strChar = phone.subString(iCount, iCount+1);
            system.debug('strChar=='+strChar);
            if(strChar.isNumeric())
                retPhone += strChar;
        }
        
        system.debug('retPhone  =='+retPhone);
        
        if(retPhone.length() > 10)
            retPhone = retPhone.right(10);
        
        return retPhone;
    }    
    
    // 1. For any CM inserted, check if there is already a CM with same value
    // 1.1 If Yes, copy the preferences of existing CM 
    // 1.2 If No, Do Nothing
    public static void updateContactMethodPreferences(List<ContactMethod__c> newContactMethodList){ 
        Set<String> contactMethodValues = new Set<String>();
        Map<String,ContactMethod__c> contactMethodMap = new Map<String,ContactMethod__c>();
        for(ContactMethod__c cm: newContactMethodList){
            if(ContactMethodType_Email.EqualsIgnoreCase(cm.Type__c)){
                contactMethodValues.add(cm.Email__c);
            }else if(ContactMethodType_Phone.EqualsIgnoreCase(cm.Type__c)){
                contactMethodValues.add(cm.Phone__c);
            }
        }        
        
        for(ContactMethod__c cm: [Select id,Type__c,Email__c,Phone__c, RDC_Event_OptIn__c ,RDC_Info_OptIn__c ,RDC_Promo_OptIn__c ,SMS_RDC_Promo_Pref__c ,
                                  TP_Event_OptIn__c , TP_Info_OptIn__c , TP_Promo_OptIn__c from ContactMethod__c where (Email__c IN: contactMethodValues OR Phone__c IN: contactMethodValues) AND Active__c = TRUE]){
                                      if(ContactMethodType_Email.EqualsIgnoreCase(cm.Type__c) && !contactMethodMap.containsKey(cm.Email__c)){
                                          contactMethodMap.put(cm.Email__c,cm);
                                      }else if(ContactMethodType_Phone.EqualsIgnoreCase(cm.Type__c) && !contactMethodMap.containsKey(cm.Phone__c)){
                                          contactMethodMap.put(cm.Phone__c,cm);
                                      }
                                  }
        
        for(ContactMethod__c cm: newContactMethodList){          
            if(!contactMethodMap.isEmpty() && ContactMethodType_Email.EqualsIgnoreCase(cm.Type__c) && contactMethodMap.containsKey(cm.Email__c)){
                cm.RDC_Event_OptIn__c = contactMethodMap.get(cm.Email__c).RDC_Event_OptIn__c;
                cm.RDC_Promo_OptIn__c = contactMethodMap.get(cm.Email__c).RDC_Promo_OptIn__c;
                cm.TP_Event_OptIn__c  = contactMethodMap.get(cm.Email__c).TP_Event_OptIn__c;
                cm.TP_Promo_OptIn__c  = contactMethodMap.get(cm.Email__c).TP_Promo_OptIn__c;
                cm.RDC_Info_OptIn__c  = contactMethodMap.get(cm.Email__c).RDC_Info_OptIn__c;
                cm.TP_Info_OptIn__c   = contactMethodMap.get(cm.Email__c).TP_Info_OptIn__c;              
            }else if(!contactMethodMap.isEmpty() && ContactMethodType_Phone.EqualsIgnoreCase(cm.Type__c) && contactMethodMap.containsKey(cm.Phone__c)){
                cm.SMS_RDC_Promo_Pref__c     = contactMethodMap.get(cm.Phone__c).SMS_RDC_Promo_Pref__c;
            } else if(ContactMethodType_Email.EqualsIgnoreCase(cm.Type__c)){
                cm.RDC_Event_OptIn__c = True;
                cm.RDC_Promo_OptIn__c = True;
                cm.TP_Event_OptIn__c  = True;
                cm.TP_Promo_OptIn__c  = True;
                cm.RDC_Info_OptIn__c  = True;
                cm.TP_Info_OptIn__c   = True;
            }      
        }
    }
    
    // Method To make a Webservice call to SOA on insert / Update of Contact Method
    public static void webServiceCallOutToSOA(Map<Id,ContactMethod__c> newContactMethodMap,Map<Id,ContactMethod__c> oldContactMethodMap){
        List<Id> eligiblecontactMethodList = new List<Id>();
        for(Id contactMethodId: newContactMethodMap.KeySet()){
            if(null == oldContactMethodMap ||
               (null != oldContactMethodMap && 
                (newContactMethodMap.get(contactMethodId).Active__c != oldContactMethodMap.get(contactMethodId).Active__c || 
                 newContactMethodMap.get(contactMethodId).Contact_Party_Id__c != oldContactMethodMap.get(contactMethodId).Contact_Party_Id__c ||
                 newContactMethodMap.get(contactMethodId).Type__c != oldContactMethodMap.get(contactMethodId).Type__c ||
                 newContactMethodMap.get(contactMethodId).Value__c != oldContactMethodMap.get(contactMethodId).Value__c ||
                 newContactMethodMap.get(contactMethodId).Email__c != oldContactMethodMap.get(contactMethodId).Email__c ||
                 newContactMethodMap.get(contactMethodId).Phone__c != oldContactMethodMap.get(contactMethodId).Phone__c ||
                 newContactMethodMap.get(contactMethodId).Primary_To_Contact__c != oldContactMethodMap.get(contactMethodId).Primary_To_Contact__c  ||
                 // newContactMethodMap.get(contactMethodId).Global_Opt_Out__c != oldContactMethodMap.get(contactMethodId).Global_Opt_Out__c  ||
                 newContactMethodMap.get(contactMethodId).Type_Purpose__c != oldContactMethodMap.get(contactMethodId).Type_Purpose__c  ||
                 newContactMethodMap.get(contactMethodId).Phone_Extension__c != oldContactMethodMap.get(contactMethodId).Phone_Extension__c  ||
                 newContactMethodMap.get(contactMethodId).Source_Type__c != oldContactMethodMap.get(contactMethodId).Source_Type__c  ||
                 newContactMethodMap.get(contactMethodId).Sync_With_CDH__c  != oldContactMethodMap.get(contactMethodId).Sync_With_CDH__c  ||
                 newContactMethodMap.get(contactMethodId).Bounce_Back_Email__c != oldContactMethodMap.get(contactMethodId).Bounce_Back_Email__c))){
                     eligiblecontactMethodList.add(contactMethodId);
                 }
        } 
        
        if(!eligiblecontactMethodList.isEmpty()){
            system.debug(' *** eligiblecontactMethodList *** '+eligiblecontactMethodList);
            if(System.isBatch()){
                sendSOAOutBoundMessageInNonFuture(eligiblecontactMethodList);
            } else {
                sendSOAOutBoundMessageInFuture(eligiblecontactMethodList);
            }
        }       
    }
    
    /* Method to update Corresponding Contact when Contact Method is Inserted / Updated AND Primary to Contact = True
1. On CM Insert: Update corresponding Contact 
2. On CM update: check if Value changes or When Primary to contact becomes true from false
3. Update 'Primary Contact' Account based on relationship object associated to the Contact in Contact Method
*/
    
    public static void updateContact(Map<Id,ContactMethod__c> newContactMethodMap,Map<Id,ContactMethod__c> oldContactMethodMap){       
        List<ContactMethod__c> eligibleContactMethodList = new List<ContactMethod__c>(); 
        List<Id> contactIds = new List<Id>();
        Map<Id,Contact> contactsToBeUpdated;
        //Set<Account> accSet = new Set<Account>();
        Map<Id, Account> accIdMap = new Map<Id, Account>();
        List<Account> accList = new List<Account>();
        List<Account_Relationship__c> ARList = new List<Account_Relationship__c>();
        Map<Id,Id> ARMap = new Map<Id,Id>();
        Map<Id,List<ContactMethod__c>> CMIdMapList = new Map<Id,List<ContactMethod__c>>();
        Set<Id> contIdsforIntegration = new Set<Id>();
        Set<Id> CMIdSet = new Set<Id>();
        Set<Id> ConIdSet = new Set<Id>();
        Map<Id,List<ContactMethod__c>> CMIdConMapList = new Map<Id,List<ContactMethod__c>>();
        //List<Account_Relationship__c> ARIdList = new List<Account_Relationship__c>();
        //Map<Id,Id> ARIdMap = new Map<Id,Id>();
        //Assumption- 
        //1. when Primary To Contact is Set to True then it is Active CM - while insertion
        //2. No CM's are created with Inactive status
        for(Id contactMethodId: newContactMethodMap.KeySet()){             
            system.debug('newContactMethodMap.get(contactMethodId):'+newContactMethodMap.get(contactMethodId));
            if(null == oldContactMethodMap || 
                (null != oldContactMethodMap && (newContactMethodMap.get(contactMethodId).Active__c  != oldContactMethodMap.get(contactMethodId).Active__c || 
                                                 newContactMethodMap.get(contactMethodId).Primary_To_Contact__c  != oldContactMethodMap.get(contactMethodId).Primary_To_Contact__c ||
                                                 newContactMethodMap.get(contactMethodId).Primary_To_Account__c  != oldContactMethodMap.get(contactMethodId).Primary_To_Account__c ||
                                                 newContactMethodMap.get(contactMethodId).Email__c != oldContactMethodMap.get(contactMethodId).Email__c ||
                                                 newContactMethodMap.get(contactMethodId).Phone__c != oldContactMethodMap.get(contactMethodId).Phone__c ||
                                                 newContactMethodMap.get(contactMethodId).Contact__c  != oldContactMethodMap.get(contactMethodId).Contact__c ||
                                                 newContactMethodMap.get(contactMethodId).Type_Purpose__c != oldContactMethodMap.get(contactMethodId).Type_Purpose__c ||
                                                 newContactMethodMap.get(contactMethodId).Value__c != oldContactMethodMap.get(contactMethodId).Value__c))){                                                     
                                                     ConIdSet.add(newContactMethodMap.get(contactMethodId).Contact__c);
                                                     if(CMIdMapList.containsKey(newContactMethodMap.get(contactMethodId).Contact__c)) {
                                                         List<ContactMethod__c> cmList = CMIdMapList.get(newContactMethodMap.get(contactMethodId).Contact__c);
                                                         cmList.add(newContactMethodMap.get(contactMethodId));
                                                         CMIdMapList.put(newContactMethodMap.get(contactMethodId).Contact__c, cmList);
                                                     }else {                
                                                         CMIdMapList.put(newContactMethodMap.get(contactMethodId).Contact__c, new List<ContactMethod__c> {newContactMethodMap.get(contactMethodId)});
                                                     }
                                                     if(newContactMethodMap.get(contactMethodId).Primary_To_Contact__c){
                                                         eligibleContactMethodList.add(newContactMethodMap.get(contactMethodId));
                                                         contactIds.add(newContactMethodMap.get(contactMethodId).Contact__c);
                                                     }
                                                     //added below code for merge scenario 
                                                     if(UserInfo.getUserName().equals('integration_user@move.com') && null != oldContactMethodMap &&
                                                        oldContactMethodMap.get(contactMethodId).Primary_To_Contact__c == TRUE && newContactMethodMap.get(contactMethodId).Primary_To_Contact__c == FALSE){
                                                         contIdsforIntegration.add(newContactMethodMap.get(contactMethodId).Contact__c);
                                                     }
                                                 } 
        }
        System.debug('ConIdSet:'+ConIdSet);
        System.debug('contactIds:'+contactIds);
        System.debug('contactIds via Integration PTC update:'+contIdsforIntegration);
        
        if(!contIdsforIntegration.isEmpty()){
            for(ContactMethod__c cm: [Select id,Type__c,Email__c,Phone__c,Contact__c from ContactMethod__c where Contact__c IN: contIdsforIntegration AND Primary_To_Contact__c = TRUE]){ 
                eligibleContactMethodList.add(cm); 
                contactIds.add(cm.Contact__c);
            }             
        }
        System.debug('contactIds: After adding contIdsforIntegration : '+contactIds);
        
        for(Account_Relationship__c ar : [select Id, Contact_To__c, Contact_To__r.Id, Parent_Account__c, Parent_Account__r.Email_Address__c, Parent_Account__r.Phone,
                                          Parent_Account__r.Type_Purpose__c, Parent_Account__r.Preferred_Phone__c, Parent_Account__r.Phone_Extension__c,
                                          Parent_Account__r.PrimaryEmail_CMId__c, Parent_Account__r.PrimaryPhone_CMId__c, Parent_Account__r.PrimarySMS_CMId__c, Parent_Account__r.SMS_Phone__c 
                                          from Account_Relationship__c where Contact_Role__c ='Primary Contact' and Parent_Account__c != null and Active__c = True and Contact_To__c IN: ConIdSet]){
                                              ARMap.put(ar.Parent_Account__c, ar.Contact_To__c);
                                              ARList.add(ar);
                                          }                
        for(Account_Relationship__c ar : ARList){
            List<ContactMethod__c> CMList = new List<ContactMethod__c>();
            List<ContactMethod__c> ExistCMList = new List<ContactMethod__c>();
            if(ARMap.get(ar.Parent_Account__r.Id) != null && CMIdMapList.get(ARMap.get(ar.Parent_Account__r.Id)) != null){
                System.debug('CM:'+CMIdMapList.get(ARMap.get(ar.Parent_Account__r.Id)));
                CMList = CMIdMapList.get(ARMap.get(ar.Parent_Account__r.Id));
                System.debug('CMList:'+CMList);
                for(ContactMethod__c cm: CMList){
                    System.debug('CM:'+cm);
                    System.debug('ar.Parent_Account__r:'+ar.Parent_Account__r);
                    if(ContactMethodType_Email.EqualsIgnoreCase(cm.Type__c)){
                        if((ar.Parent_Account__r.PrimaryEmail_CMId__c == null && cm.Primary_To_Contact__c) || (ar.Parent_Account__r.PrimaryEmail_CMId__c != null && ar.Parent_Account__r.PrimaryEmail_CMId__c == cm.Id)){
                            ar.Parent_Account__r.Email_Address__c = cm.Email__c;
                            ar.Parent_Account__r.PrimaryEmail_CMId__c = cm.Id;
                            ar.Parent_Account__r.Type_Purpose__c = cm.Type_Purpose__c;                
                        }
                        //accSet.add(ar.Parent_Account__r);
                    }
                    if(ContactMethodType_Phone.EqualsIgnoreCase(cm.Type__c)){
                        if((ar.Parent_Account__r.PrimaryPhone_CMId__c == null  && cm.Primary_To_Contact__c) || (ar.Parent_Account__r.PrimaryPhone_CMId__c != null && ar.Parent_Account__r.PrimaryPhone_CMId__c == cm.Id)){
                            ar.Parent_Account__r.Phone = cm.Phone__c;
                            ar.Parent_Account__r.Phone_Extension__c = cm.Phone_Extension__c;
                            ar.Parent_Account__r.PrimaryPhone_CMId__c = cm.Id;
                            ar.Parent_Account__r.Preferred_Phone__c = cm.Type_Purpose__c; 
                            CMIdSet.add(cm.Id);
                        }
                        //accSet.add(ar.Parent_Account__r);
                    }
                    if(ContactMethodType_Phone.EqualsIgnoreCase(cm.Type__c) 
                       && (CMTypePurpose_BMobile.EqualsIgnoreCase(cm.Type_Purpose__c)
                           || CMTypePurpose_PMobile.EqualsIgnoreCase(cm.Type_Purpose__c))){
                               if(ar.Parent_Account__r.PrimarySMS_CMId__c == null || (ar.Parent_Account__r.PrimarySMS_CMId__c != null &&
                                                                                      ar.Parent_Account__r.PrimarySMS_CMId__c == cm.Id)){
                                                                                          ar.Parent_Account__r.SMS_Phone__c = cm.Phone__c;
                                                                                          ar.Parent_Account__r.PrimarySMS_CMId__c = cm.Id;
                                                                                          CMIdSet.add(cm.Id);
                                                                                      }                   
                               //accSet.add(ar.Parent_Account__r);
                           }
                    
                }                                
                accIdMap.put(ar.Parent_Account__c, ar.Parent_Account__r);
                System.debug('accIdMap:'+accIdMap);
            }
        }
        
        for(ContactMethod__c cm: [Select Id, Type__c, Type_Purpose__c, Phone__c, Phone_Extension__c, Active__c, Contact__c  from ContactMethod__c
                                  where Contact__c IN: ConIdSet and Active__c  = True order by LastModifiedDate Desc]){
                                      if(CMIdConMapList.containsKey(cm.Contact__c)) {
                                          List<ContactMethod__c> cmList = CMIdConMapList.get(cm.Contact__c);
                                          cmList.add(cm);
                                          CMIdConMapList.put(cm.Contact__c, cmList);
                                      }else {                
                                          CMIdConMapList.put(cm.Contact__c, new List<ContactMethod__c> {cm});
                                      }
                                  }
        for(Account_Relationship__c ar : ARList){
            List<ContactMethod__c> ExistCMList = new List<ContactMethod__c>();
            String BusinessPhoneCMId;
            String PersonalPhoneCMId;
            String BusinessmobileCMId;
            String PersonalmobileCMId;
            if(ARMap.get(ar.Parent_Account__r.Id) != null && CMIdConMapList.get(ARMap.get(ar.Parent_Account__r.Id)) != null){
                System.debug('CM:'+CMIdConMapList.get(ARMap.get(ar.Parent_Account__r.Id)));                
                ExistCMList = CMIdConMapList.get(ARMap.get(ar.Parent_Account__r.Id));
                if(!ExistCMList.isEmpty()){
                    ar.Parent_Account__r.Mobile2_Other__c  = null;
                    ar.Parent_Account__r.Other_Phone_Ext__c  = null;
                    ar.Parent_Account__r.Work_Phone__c  = null;
                    ar.Parent_Account__r.Work_Phone_Ext__c  = null;
                    ar.Parent_Account__r.Mobile1__c = null;
                    ar.Parent_Account__r.Home_Phone__c = null;                   
                }
                for(ContactMethod__c cm: ExistCMList){
                    if(ContactMethodType_Phone.EqualsIgnoreCase(cm.Type__c) && cm.Type_Purpose__c != 'BUSINESS_FAX') {
                        System.debug('cm:'+CM);
                        if(cm.Type_Purpose__c == 'BUSINESS_PHONE' && BusinessPhoneCMId == null){
                            BusinessPhoneCMId = cm.Id;
                            ar.Parent_Account__r.Work_Phone__c = cm.Phone__c;
                            ar.Parent_Account__r.Work_Phone_Ext__c = cm.Phone_Extension__c;
                        }
                        if(cm.Type_Purpose__c == 'PERSONAL_PHONE' && PersonalPhoneCMId == null){
                            PersonalPhoneCMId = cm.Id;
                            ar.Parent_Account__r.Home_Phone__c = cm.Phone__c;
                            ar.Parent_Account__r.Other_Phone_Ext__c = cm.Phone_Extension__c;
                        }
                        if(cm.Type_Purpose__c == 'BUSINESS_MOBILE' && BusinessmobileCMId == null){
                            BusinessmobileCMId = cm.Id;
                            ar.Parent_Account__r.Mobile1__c = cm.Phone__c;
                        }
                        if(cm.Type_Purpose__c == 'PERSONAL_MOBILE' && PersonalmobileCMId == null){
                            PersonalmobileCMId = cm.Id;
                            ar.Parent_Account__r.Mobile2_Other__c = cm.Phone__c;
                        }
                        accIdMap.put(ar.Parent_Account__c, ar.Parent_Account__r);
                    }             
                }
            }
        }
        System.debug('accIdMap:'+accIdMap);
        
        if(!contactIds.isEmpty()){ 
            contactsToBeUpdated = getContacts(contactIds);          
            for(ContactMethod__c contactMethodRecord: eligibleContactMethodList){            
                if(ContactMethodType_Email.EqualsIgnoreCase(contactMethodRecord.Type__c)){
                    contactsToBeUpdated.get(contactMethodRecord.Contact__c).Email = contactMethodRecord.Email__c;                                 
                }else if(ContactMethodType_Phone.EqualsIgnoreCase(contactMethodRecord.Type__c)){
                    contactsToBeUpdated.get(contactMethodRecord.Contact__c).Phone = contactMethodRecord.Phone__c; 
                }
            }       
            
            if(!contactsToBeUpdated.isEmpty()){
                try{
                    update contactsToBeUpdated.values();
                    system.debug(' *** contactsToBeUpdated *** '+contactsToBeUpdated.values());
                }catch(DMLException DMLEx){
                    system.debug(' Error while updating Contact Records: '+DMLEx.getMessage());
                }
            }
        }
        if(!contactIds.isEmpty() || !ConIdSet.isEmpty()){
            if(!accIdMap.isEmpty()){
                try{
                    //system.debug(' *** accList ***- before adding '+accList);
                    system.debug(' *** accIdMap *** '+accIdMap);
                    //accList.addAll(accSet);
                    system.debug(' *** accIdMap.values() ***- after adding  '+accIdMap.values());
                    update accIdMap.values();
                    
                }catch(DMLException DMLEx){
                    system.debug(' Error while updating Contact Records: '+DMLEx.getMessage());
                }
            }
        }
        
        CheckRecursiveTrigger.executeTriggerOnce = true;
    }
    public static void updateContactMethods(Map<Id,ContactMethod__c> newContactMethodMap,Map<Id,ContactMethod__c> oldContactMethodMap) {
        List<Id> contactIds = new List<Id>();
        Map<Id,List<ContactMethod__c>> CMIdMapList = new Map<Id,List<ContactMethod__c>>();
        List<ContactMethod__c> updCMList = new List<ContactMethod__c>();
        
        for(Id contactMethodId: newContactMethodMap.KeySet()){           
            if(newContactMethodMap.get(contactMethodId).Primary_To_Contact__c && (null == oldContactMethodMap || 
                                                                                  (null != oldContactMethodMap && (newContactMethodMap.get(contactMethodId).Primary_To_Contact__c  != oldContactMethodMap.get(contactMethodId).Primary_To_Contact__c)))){           
                                                                                      contactIds.add(newContactMethodMap.get(contactMethodId).Contact__c);
                                                                                      if(CMIdMapList.containsKey(newContactMethodMap.get(contactMethodId).Contact__c)) {
                                                                                          List<ContactMethod__c> cmList = CMIdMapList.get(newContactMethodMap.get(contactMethodId).Contact__c);
                                                                                          cmList.add(newContactMethodMap.get(contactMethodId));
                                                                                          CMIdMapList.put(newContactMethodMap.get(contactMethodId).Contact__c, cmList);
                                                                                      }else {                
                                                                                          CMIdMapList.put(newContactMethodMap.get(contactMethodId).Contact__c, new List<ContactMethod__c> {newContactMethodMap.get(contactMethodId)});
                                                                                      }
                                                                                      //CMIdMap.put(newContactMethodMap.get(contactMethodId).Contact__c, newContactMethodMap.get(contactMethodId));
                                                                                  } 
        }
        system.debug('contactIds:'+contactIds);
        system.debug('CMIdMapList:'+CMIdMapList);
        List<ContactMethod__c> CMList = new List<ContactMethod__c>();
        for(ContactMethod__c cm: [Select Id, Primary_To_Contact__c, Contact__c, Type__c 
                                  from ContactMethod__c where Contact__c IN: contactIds and Primary_To_Contact__c = true and Id Not IN: newContactMethodMap.KeySet()]) {
                                      CMList = CMIdMapList.get(cm.Contact__c);
                                      system.debug('CMList:'+CMList);
                                      for(ContactMethod__c newCM: CMList){
                                          if(cm.Type__c == newCM.Type__c){
                                              cm.Primary_To_Contact__c = False;
                                              updCMList.add(cm);
                                          }
                                      }
                                  }
        system.debug('updCMList:'+updCMList);
        if(!updCMList.isEmpty()){
            update updCMList;
        }
    }
    
    private static Map<Id,Contact> getContacts(List<Id> contactIds){
        return new Map<Id,Contact>([Select Id,Email,Phone,Preferred_Phone_Number__c from Contact where id =: contactIds]);
    }
    
    //Non future method used to call out external webservice from Batch
    private static void sendSOAOutBoundMessageInNonFuture(List<Id> eligibleContactMethodList){
        sendSOAOutBoundMessageCall(eligibleContactMethodList);
    }
    
    // future method used to call out external webservice
    @future(callout=true)
    private static void sendSOAOutBoundMessageInFuture(List<Id> eligibleContactMethodList){
        sendSOAOutBoundMessageCall(eligibleContactMethodList);
    }
    
    Public static void sendSOAOutBoundMessageCall(List<Id> eligibleContactMethodList){
        List<ContactMethod__c> contactMethodsToBeSyncedToCDH = new List<ContactMethod__c>([Select id,name,Active__c,Bounce_Back_Email__c,Contact__c,Contact_Party_Id__c,External_ID__c,Phone_Extension__c,
                                                                                           Email__c,Phone__c,Primary_To_Contact__c,Source_Type__c,Sync_With_CDH__c,Type__c,Type_Purpose__c,Value__c from ContactMethod__c where Id =: eligibleContactMethodList]);
        String endpoint_x = CDH_Webservices_Endpoints__c.getInstance().Contact_Method_Sync_Endpoint__c;
        Integer contactMethodsPerRequest = (Integer)CDH_Webservices_Endpoints__c.getInstance().NumberOfContactMethodsPerRequest__c ;
        Integer sizeofContactMethods = 0;
        HTTPResponse response;
        List<Error__c> errorList = new List<Error__c>();
        List<ContactMethod__c> contactMethodsSentinaRequest = new List<ContactMethod__c>();
        
        for(ContactMethod__c contactMethod: contactMethodsToBeSyncedToCDH){
            sizeofContactMethods +=1;
            contactMethodsSentinaRequest.add(contactMethod);
            system.debug(' *** sizeofContactMethods *** '+sizeofContactMethods+' *** contactMethodsSentinaRequest '+contactMethodsSentinaRequest);            
            if((contactMethodsSentinaRequest.size() == contactMethodsPerRequest) || (contactMethodsSentinaRequest.size() < contactMethodsPerRequest && sizeofContactMethods == contactMethodsToBeSyncedToCDH.size())){
                try{
                    response = generateHttpRequest(contactMethodsSentinaRequest,endpoint_x); //commented for some time- date - 5th March 2019
                    system.debug(' *** Response from SOA'+response);
                    for(ContactMethod__c cm:contactMethodsSentinaRequest){
                        errorList.add(new Error__c(Entity_Id__c = cm.Id,Name ='ContactMethodOutboundMessage'+cm.Name,Error_Description__c = 'Success:' + response));
                    }
                }catch(Exception ex){
                    system.debug(' Failed to Send Request to SOA due to: '+ex.getMessage());
                    for(ContactMethod__c cm:contactMethodsSentinaRequest){
                        errorList.add(new Error__c(Entity_Id__c = cm.Id,Name ='ContactMethodOutboundMessage'+cm.Name,Error_Description__c = ex.getMessage()));
                    }
                }                   
                contactMethodsSentinaRequest = new List<ContactMethod__c>();
            }           
        }    
        
        if(!errorList.isEmpty()){
            try{
                insert errorList;
                system.debug(' *** errorList is *** '+errorList);
            }catch(DMLException DMLEx){
                system.debug(' *** Unable to Insert ErrorList Records *** '+DMLEx.getMessage());
            }
        }
    }
    
    // Method to Prepare HTTP Request with JSON Body and generate Response.   
    private static HTTPResponse generateHttpRequest(List<ContactMethod__c> contactMethodRecordList, String endPointURL){
        JSONGenerator gen = JSON.createGenerator(true); 
        gen.writeStartObject();
        gen.writeFieldName('ContactMethod');
        gen.writeStartArray();
        for (integer i = 0; i < contactMethodRecordList.size(); i++){
            gen.writeStartObject();     
            gen.writeStringField('Cm_Id', contactMethodRecordList[i].Id);
            gen.writeBooleanField('Active', contactMethodRecordList[i].Active__c);
            gen.writeBooleanField('Bounce_Back_Email', contactMethodRecordList[i].Bounce_Back_Email__c);
            gen.writeStringField('contact', contactMethodRecordList[i].Contact__c);
            gen.writeStringField('Con_Party_Id', null != contactMethodRecordList[i].Contact_Party_Id__c? contactMethodRecordList[i].Contact_Party_Id__c:'null');
            gen.writeStringField('Contact_Id', null != contactMethodRecordList[i].Contact__c? contactMethodRecordList[i].Contact__c:null);
            gen.writeStringField('Cm_Extrnl_Id', null != contactMethodRecordList[i].External_ID__c?contactMethodRecordList[i].External_ID__c:'null');
            //gen.writeBooleanField('Glbl_Opt_Out', contactMethodRecordList[i].Global_Opt_Out__c);
            gen.writeStringField('Ph_Ext', null != contactMethodRecordList[i].Phone_Extension__c?contactMethodRecordList[i].Phone_Extension__c:'null');
            gen.writeBooleanField('Prim_To_Cont', contactMethodRecordList[i].Primary_To_Contact__c);
            gen.writeStringField('Src_Type', null != contactMethodRecordList[i].Source_Type__c?contactMethodRecordList[i].Source_Type__c:'null');
            gen.writeStringField('Type', contactMethodRecordList[i].Type__c);
            gen.writeStringField('Typ_Purpose', null != contactMethodRecordList[i].Type_Purpose__c?contactMethodRecordList[i].Type_Purpose__c:'null');
            gen.writeStringField('Value', null != contactMethodRecordList[i].Value__c?contactMethodRecordList[i].Value__c:'null');
            gen.writeStringField('Email',null != contactMethodRecordList[i].Email__c?contactMethodRecordList[i].Email__c:'null');
            gen.writeStringField('Phone',null != contactMethodRecordList[i].Phone__c?contactMethodRecordList[i].Phone__c:'null');
            gen.writeEndObject(); 
        }
        gen.writeEndArray();
        gen.writeEndObject();  
        String jsonString = gen.getAsString();
        system.debug(' *** Constructed JSON String is *** '+jsonString+' *** End Point is *** '+endPointURL);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPointURL);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setbody(jsonString);
        Http http = new Http();
        HTTPResponse response = http.send(req);
        
        return response;
    } 
    
    // Create Phone Records on Contact Method Insert
    // Update Phone Records on Contact Method Update 
    public static void createPhoneRecords(Map<Id,ContactMethod__c> newContactMethodMap, Map<Id,ContactMethod__c> oldContactMethodMap){
        List<Id> eligibleContactMethodList = new List<Id>();
        List<Phone__c> phoneRecordsToBeUpdated = new List<Phone__c>();
        List<Phone__c> phoneRecordsToBeInserted = new List<Phone__c>();
        Map<Id,List<ContactMethod__c>> contactToCMIdMap = new Map<Id,List<ContactMethod__c>>();
        // Logic for CM Update
        if(null != oldContactMethodMap){
            for(ContactMethod__c cm: newContactMethodMap.values()){
                if(ContactMethodType_Phone.EqualsIgnoreCase(cm.Type__c) && cm.Phone__c != oldContactMethodMap.get(cm.Id).Phone__c && cm.Type_Purpose__c != 'BUSINESS_FAX'){
                    eligibleContactMethodList.add(cm.Id);
                }               
            }
            for(Phone__c phoneRecord: [select id,name,Contact_Method__c,Phone_Type__c,Account__c from Phone__c where Contact_Method__c IN: eligibleContactMethodList]){
                phoneRecord.Name = convertFromFormatted(newContactMethodMap.get(phoneRecord.Contact_Method__c).Phone__c); 
                phoneRecordsToBeUpdated.add(phoneRecord);
            }           
            if(!phoneRecordsToBeUpdated.isEmpty()){
                update phoneRecordsToBeUpdated;
            }          
        }      
        // Logic for CM Insert
        if(null == oldContactMethodMap){
            for(ContactMethod__c cm: newContactMethodMap.values()){
                if(ContactMethodType_Phone.EqualsIgnoreCase(cm.Type__c) && cm.Type_Purpose__c != 'BUSINESS_FAX' && cm.Phone__c != null){
                    if(contactToCMIdMap.containsKey(cm.Contact__c)){
                        contactToCMIdMap.get(cm.Contact__c).add(cm); 
                    }else{
                        contactToCMIdMap.put(cm.Contact__c, new List<ContactMethod__c>{cm}); 
                    }
                }
            }            
            for(Account_Relationship__c rel: [select id,name,Parent_Account__c,Contact_Role__c,Contact_To__c from Account_Relationship__c where Contact_To__c IN: contactToCMIdMap.keyset() AND Contact_Role__c = 'Primary Contact' and Parent_Account__c != null and Active__c = True]){
                for(ContactMethod__c cm: contactToCMIdMap.get(rel.Contact_To__c)){                                   
                    Phone__c phoneRecord          = new Phone__c();   
                    phoneRecord.Account__c        = rel.Parent_Account__c;
                    phoneRecord.Contact_Method__c = cm.Id;
                    phoneRecord.Phone_Type__c     = cm.Type_Purpose__c;
                    phoneRecord.Name              = convertFromFormatted(cm.Phone__c);                   
                    phoneRecordsToBeInserted.add(phoneRecord); 
                }
            }            
            if(!phoneRecordsToBeInserted.isEmpty()){
                insert phoneRecordsToBeInserted;
            }
        }       
    }
}