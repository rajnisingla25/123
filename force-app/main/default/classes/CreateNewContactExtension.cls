//
// (c) 2015 Appirio, Inc.
//
// Apex Extension: CreateNewContactExtension
// For Apex Page: CreateNewContact
// Description: Overrides new button of contact sobject and creates a contact using custom apex page.
// Calls CDH contact creation web service via apex page.
//
// 08th April 2015    Hemendra Singh Bhati    Original (Task # T-376891)
// 16th April 2015    Hemendra Singh Bhati    Modified (Task # T-377874)  - Updated Methods: createContact(), updateExistingContact(),
//                                                                        - createNewContact().
// 21st April 2015    Hemendra Singh Bhati    Modified (Task # T-380320)  - Updated Method: createContact().
// 19th May 2015      Hemendra Singh Bhati    Modified (Issue # I-163522) - Updated Method: createContact().
//
public with sharing class CreateNewContactExtension {
    // Private Properties.
    private Id contactRecordTypeId { get; set; }
    private Contact theContact { get; set; }
    public Account_Relationship__c ar {get; set;}
    public List<Account_Relationship__c> arList {get; set;}
    public Account acc {get; set;}
    private ApexPages.StandardController theStandardController { get; set; }
    public String accountID {get; set;}
    //CRM-3975 Division separtation For Moving.com contacts
    private final String CONTACT_RECORD_TYPE_MOVING = 'Moving';  
    // Public Properties.
    public Boolean hasError { get; set; }
    public List<ContactWrapper> theSelectedContacts { get; set; }
    Map<String, String> contactRoleMap = new Map<String, String>();
    
    // CRM-495 Booleab variable to store is primary contact.
    public Boolean isPrimary {get; set;}
    public Boolean isBilling {get; set;}    
    
    public String selectedprefPhone{get;set;}
    public String selectedprefEmail{get;set;}
    public String businessPhone{get;set;}
    public String personalPhone{get;set;}
    public String businessMobile{get;set;}
    public String personalMobile{get;set;}
    public String businessFax{get;set;}
    public String businessEmail{get;set;}
    public String personalEmail{get;set;}
    public String businessExt{get;set;}
    public String personalExt{get;set;}
    
    public String contactRole{get;set;}
    
    // The Constructor.
    public CreateNewContactExtension(ApexPages.StandardController sc) {
        theStandardController = sc;
        theSelectedContacts = new List<ContactWrapper>();
        arList = new List<Account_Relationship__c>();
        // modifed by Ravinder
        //CRM-3975 Division separtation For Moving.com contacts
        theContact = (Contact)theStandardController.getRecord();
        theContact.Active__c = true;
        theContact.Type__c = 'Other';
        String recordType1 = ApexPages.currentPage().getParameters().get('RecordType');
        if(String.isNotBlank(recordType1) && recordType1 == Schema.SObjectType.Contact.RecordTypeInfosByName.get(CONTACT_RECORD_TYPE_MOVING).RecordTypeId){
            theContact.Division__c = 'Moving';
        }
        else{
            theContact.Division__c = 'Realtor';
        }
        hasError = true;    
        accountID = ApexPages.currentPage().getParameters().get('con4_lkid');
        if(accountID != null){
            acc = [Select Id, Name, Type, Email_Address__c, Phone 
                   from Account where Id =: accountID limit 1];
            arList = [Select Id, Contact_To__c, Contact_To__r.Name, Contact_To__r.Type__c, Contact_To__r.Email, Contact_To__r.Phone, 
                  Parent_Account__r.Name, Parent_Account__r.Type, Parent_Account__r.Email_Address__c, 
                  Parent_Account__r.Phone from Account_Relationship__c  
                  where Relationship_Type__c = 'Contact' and Contact_Role__c = 'Primary Contact' 
                  and Parent_Account__c =: accountID and Contact_To__c != null limit 1];
            // Added the below logic to handle when Account doesn't have any existing relationship.
            if(!arList.isEmpty()){
                for(Account_Relationship__c arp : arList){
                    ar = arp;
                }
            }
        }
        contactRecordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
        if(String.isBlank(contactRecordTypeId)) {
            List<String> names = new List<String>();
            List<RecordTypeInfo> infos = Contact.SObjectType.getDescribe().getRecordTypeInfos();
            if(infos.size() > 1) {
                for(RecordTypeInfo i : infos) {
                    if(i.isAvailable() && !String.valueOf(i.getRecordTypeId()).endsWith('AAA')) {
                        names.add(i.getName());
                    }
                }
            } 
            else { 
                names.add(infos[0].getName());
            }
            
            if(names.size() == 1) {
                contactRecordTypeId = Schema.SObjectType.Contact.RecordTypeInfosByName.get(names.get(0)).RecordTypeId;
            }
        }
    }

    /*
    @method      : createContact
    @description : Validates the contact from CDH system and creates a new user if the contact does not exist on CDH system.
    @params      : void
    @returns     : PageReference
    */
    public PageReference createContact() {
        try {
            hasError = true;
            theSelectedContacts = new List<ContactWrapper>();
            theContact = (Contact)theStandardController.getRecord();
            List<ContactMethod__c> contactMethodList = new List<ContactMethod__c>();
            List<Account> accountList = new List<Account>();
            system.debug('bPhone:'+businessPhone);
            system.debug('bPhone-Apex:'+ApexPages.currentPage().getParameters().get('businessPhone'));
            system.debug('selectedprefPhone:'+selectedprefPhone);
            Pattern p = Pattern.compile('[-() ]');
            String Bphone = null;
            String Pphone = null;
            String BMobile = null;
            String PMobile = null;
            String BFax = null;
            
            if(String.isNotBlank(businessPhone)) Bphone = p.matcher(businessPhone).replaceAll('');
            if(String.isNotBlank(personalPhone)) Pphone = p.matcher(personalPhone).replaceAll('');                
            if(String.isNotBlank(businessMobile)) BMobile = p.matcher(businessMobile).replaceAll('');               
            if(String.isNotBlank(personalMobile)) PMobile = p.matcher(personalMobile).replaceAll('');                
            if(String.isNotBlank(businessFax)) BFax = p.matcher(businessFax).replaceAll('');
                
            // Added For Task # T-380320.
            // CODE STARTS.
            if((String.isNotBlank(businessPhone) || 
                String.isNotBlank(personalPhone) || 
                String.isNotBlank(businessMobile) ||
                String.isNotBlank(personalMobile)) && 
                (selectedprefPhone == '' || selectedprefPhone == null)) {
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select your Preferred Phone.'));
              return null;
            }            
           // Added For Issue # I-163522.
          // CODE STARTS.
            else if(selectedprefPhone != '' &&
                ((selectedprefPhone == 'businessPhone' && String.isBlank(businessPhone)) ||
                  (selectedprefPhone == 'personalPhone' && String.isBlank(personalPhone)) ||
                  (selectedprefPhone == 'businessMobile' && String.isBlank(businessMobile)) ||
                  (selectedprefPhone == 'personalMobile' && String.isBlank(personalMobile))
                )) {
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please provide Phone number for the selected preferred phone.'));               
              return null;
            }
            else if((String.isNotBlank(businessPhone) && Bphone.length() != 10) ||
                    (String.isNotBlank(personalPhone) && Pphone.length() != 10) || 
                    (String.isNotBlank(businessMobile) && BMobile.length() != 10) || 
                    (String.isNotBlank(personalMobile) && PMobile.length() != 10) || 
                    (String.isNotBlank(businessFax) && BFax.length() != 10)){
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter only 10 digit Phone Number.'));
              return null;
            }
            else if((String.isNotBlank(businessPhone) && !Bphone.isNumeric()) || 
                    (String.isNotBlank(personalPhone) && !Pphone.isNumeric()) || 
                    (String.isNotBlank(businessMobile) && !BMobile.isNumeric()) || 
                    (String.isNotBlank(personalMobile) && !PMobile.isNumeric()) || 
                     (String.isNotBlank(businessFax) && !BFax.isNumeric())){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter only digits in Phone Number.'));
                return null;
            }
            // CODE ENDS.
            else if((String.isNotBlank(personalEmail) ||
                    String.isNotBlank(businessEmail)) &&
                    (selectedprefEmail == ''  || selectedprefEmail == null)){
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select your preferred Email Address.'));
            	return null;
            }
            else if(selectedprefEmail != '' &&
               ((selectedprefEmail == 'personalEmail' && String.isBlank(personalEmail)) ||
               (selectedprefEmail == 'businessEmail' && String.isBlank(businessEmail)))){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please provide Email Address for the selected preferred Email.'));
                return null;
            }
            else if((String.isNotBlank(personalEmail) && validateEmail(personalEmail) == false) ||
                    (String.isNotBlank(businessEmail) && validateEmail(businessEmail) == false)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please provide Valid Email Address.'));
                return null;
            }
            else if(String.isBlank(businessPhone) &&
                    String.isBlank(personalPhone) &&
                    String.isBlank(businessMobile) &&
                    String.isBlank(personalMobile) &&
                    String.isBlank(personalEmail) &&
                    String.isBlank(businessEmail)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please provide any Email Address or any Phone Number.'));
            	return null;
            }
            else if((businessPhone.StartsWithIgnoreCase('+')  || businessPhone.StartsWithIgnoreCase('1')) ||
                     (personalPhone.StartsWithIgnoreCase('+')  || personalPhone.StartsWithIgnoreCase('1')) ||
                     (businessMobile.StartsWithIgnoreCase('+')  || businessMobile.StartsWithIgnoreCase('1')) ||
                     (personalMobile.StartsWithIgnoreCase('+')  || personalMobile.StartsWithIgnoreCase('1')) ||
                     (businessFax.StartsWithIgnoreCase('+')  || businessFax.StartsWithIgnoreCase('1'))){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' Phone should not start with + or 1 '));
                return null;
            }
            else if(String.isNotBlank(personalEmail) && String.isNotBlank(businessEmail) && businessEmail == personalEmail){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' Both Personal & Business Email cannot be same '));
                return null;
            }
            else if(String.isNotBlank(businessPhone) && String.isNotBlank(personalPhone) && businessPhone == personalPhone){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' Both Business & Personal Phone cannot be same '));
                return null;
            }
            else if(String.isNotBlank(businessPhone) && String.isNotBlank(businessMobile)  && businessPhone == businessMobile ){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' Both Business Phone & Business Mobile cannot be same '));
                return null;
            }
            else if(String.isNotBlank(businessPhone) && String.isNotBlank(personalMobile)  && businessPhone == personalMobile){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' Both Business Phone & Personal Mobile cannot be same '));
                return null;
            }
            else if(String.isNotBlank(businessPhone) && String.isNotBlank(businessFax) && businessPhone == businessFax){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' Both Business Phone & Business Fax cannot be same '));
                return null;
            }
            else if(String.isNotBlank(personalPhone) && String.isNotBlank(businessFax) && businessFax == personalPhone){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' Both Personal Phone & Business Fax cannot be same '));
                return null;
            }
            else if(String.isNotBlank(personalPhone) && String.isNotBlank(businessMobile) && businessMobile == personalPhone){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' Both Personal Phone & Business Mobile cannot be same '));
                return null;
            }
            else if(String.isNotBlank(personalPhone) && String.isNotBlank(personalMobile) && personalMobile == personalPhone){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' Both Personal Phone & Personal Mobile cannot be same '));
                return null;
            }
            else if(String.isNotBlank(businessMobile) && String.isNotBlank(personalMobile) && businessMobile == personalMobile){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' Both Personal & Business Mobile cannot be same '));
                return null;
            }
            else if(String.isNotBlank(personalMobile) && String.isNotBlank(businessFax) && personalMobile == businessFax){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' Both Business Fax & Personal Mobile cannot be same '));
                return null;
            }
          // CODE ENDS.
            if(String.isNotBlank(businessPhone)) {
                businessPhone = '(' + Bphone.substring(0, 3) + ') ' + Bphone.substring(3, 6) + '-' + Bphone.substring(6);
            }
            if(String.isNotBlank(personalPhone)) {
                personalPhone = '(' + Pphone.substring(0, 3) + ') ' + Pphone.substring(3, 6) + '-' + Pphone.substring(6);
            }
            if(String.isNotBlank(businessMobile)) {
                businessMobile = '(' + BMobile.substring(0, 3) + ') ' + BMobile.substring(3, 6) + '-' + BMobile.substring(6);
            }
            if(String.isNotBlank(personalMobile)) {
                personalMobile = '(' + PMobile.substring(0, 3) + ') ' + PMobile.substring(3, 6) + '-' + PMobile.substring(6);
            }
            if(String.isNotBlank(businessFax)) {
                businessFax = '(' + BFax.substring(0, 3) + ') ' + BFax.substring(3, 6) + '-' + BFax.substring(6);
            }
    
            xmlnsOracleComInt013ContactMatchcon.MatchContactCDHService_pt soap = new xmlnsOracleComInt013ContactMatchcon.MatchContactCDHService_pt();
            soap.timeout_x = 60000;
            
            String theFirstName = String.isNotBlank(theContact.FirstName) ? theContact.FirstName : null;
            String theLastName = String.isNotBlank(theContact.LastName) ? theContact.LastName : null;
            String theContactType = String.isNotBlank(theContact.Type__c) ? theContact.Type__c : null;
            String thePhoneNumber = null;
            String theEmailAddress = null;
            
            if(selectedprefPhone != ''){
                if(selectedprefPhone == 'businessPhone' && String.isNotBlank(businessPhone)){
                    thePhoneNumber = businessPhone;
                }
                if(selectedprefPhone == 'personalPhone' && String.isNotBlank(personalPhone)){
                	thePhoneNumber = personalPhone;    
                }
                if(selectedprefPhone == 'businessMobile' && String.isNotBlank(businessMobile)){
                    thePhoneNumber = businessMobile;
                }
                if(selectedprefPhone == 'personalMobile' && String.isNotBlank(personalMobile)){
                	thePhoneNumber = personalMobile;    
                }
            }
            else{
                if(String.isNotBlank(businessPhone)){
                	thePhoneNumber = businessEmail;    
                }
                if(thePhoneNumber == null && String.isNotBlank(personalPhone)){
                    thePhoneNumber = personalPhone;
                }
                if(thePhoneNumber == null && String.isNotBlank(businessMobile)){
                    thePhoneNumber = businessMobile;
                }
                if(thePhoneNumber == null && String.isNotBlank(personalMobile)){
                    thePhoneNumber = personalMobile;
                }
            }
            
            if(selectedprefEmail != ''){
                if(selectedprefEmail == 'personalEmail' && String.isNotBlank(personalEmail)){
                    theEmailAddress = personalEmail;
                }
                if(selectedprefEmail == 'businessEmail' && String.isNotBlank(businessEmail)){
                	theEmailAddress = businessEmail;    
                }     
            }
            else{
                if(String.isNotBlank(businessEmail)){
                    theEmailAddress = businessEmail;    
                }
                if(theEmailAddress == null && String.isNotBlank(personalEmail)){
                    theEmailAddress = personalEmail;
                }             
            }
            
            
            moveComMatchcontact.OutputParameters_element response = soap.process(
            theFirstName,
            theLastName,
            thePhoneNumber,
            theEmailAddress,
            theContactType
            );
    
            // Matching Contact Party Ids.
            if(response.X_SRCH_RES_LIST != null && response.X_SRCH_RES_LIST.Output != null) {
                Set<String> contactPartyIDs = new Set<String>{ String.valueOf(response.X_SRCH_RES_LIST.Output.PARTY_ID) };
                system.debug('TRACE: contactPartyIDs - ' + contactPartyIDs);
                
                theSelectedContacts = new List<ContactWrapper>();
                for(Contact theContact : [SELECT Id, FirstName, LastName, Phone, Email, Type__c, Contact_Party_ID__c
                                          FROM Contact WHERE Contact_Party_ID__c IN :contactPartyIDs]) {
                    theSelectedContacts.add(new ContactWrapper(theContact));
                }
            }
            system.debug('TRACE: theSelectedContacts - ' + theSelectedContacts);
            
            hasError = false;
            if(theSelectedContacts.size() == 0) {
                // Updated For Task # T-377874.
                // CODE STARTS.
                if(String.isNotBlank(contactRecordTypeId)) {
                    theContact.RecordTypeId = contactRecordTypeId;
                }
                insert theContact;
                // Modifed by Ravinder
                Id recordTypeIDCR = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;
                list<Account_Relationship__c> accRelationList = [SELECT ID FROM Account_Relationship__c WHERE Parent_Account__c =: accountid AND RecordType.DeveloperName = 'Contact_Relationship' AND Active__c = true order by Name asc limit 49996];
                
                Account_Relationship__c accRelation = new Account_Relationship__c();
                  accRelation.Active__c = true;
                  accRelation.recordTypeId = recordTypeIDCR;
                  accRelation.Parent_Account__c = accountid;
                  accRelation.Contact_To__c = theContact.ID;
                System.debug('contactRole:'+contactRole);
                  
                // CRM-495
                if(!String.isEmpty(contactRole))
                    accRelation.Contact_Role__c  = contactRoleMap.get(contactRole);                  
                if(isBilling){
                    accRelation.Billing_Contact__c = true;
                }
                  // CRM-495 End
                  
                  if(accRelationList.isEmpty()){
                       accRelation.Billing_Contact__c = true;
                       accRelation.Contact_Role__c  = 'Primary Contact';              
                  }
                system.debug('accRelation:'+accRelation);  
                insert  accRelation; 
            
                if(theContact.ID != null) {
                    
                    if(!String.isEmpty(businessPhone)){
                        ContactMethod__c CM = new ContactMethod__c();
                        CM.Type__c = 'Phone';
                        CM.Type_Purpose__c = 'BUSINESS_PHONE';
                        CM.Source_Type__c = 'Web';
                        CM.Phone_Extension__c  = businessExt;
                        CM.Contact__c = theContact.ID;
                        if(selectedprefPhone == 'businessPhone'){
                            CM.Primary_To_Contact__c = True;  
                        }
                        CM.Phone__c = businessPhone;
                        contactMethodList.add(CM);
                    } System.debug('PersonalPhone:'+personalPhone);
                    if(!String.isEmpty(personalPhone)){
                        ContactMethod__c CM = new ContactMethod__c();
                        CM.Type__c = 'Phone';
                        CM.Type_Purpose__c = 'PERSONAL_PHONE';
                        CM.Phone_Extension__c  = personalExt;
                        CM.Source_Type__c = 'Web';
                        CM.Contact__c = theContact.ID;
                        if(selectedprefPhone == 'personalPhone'){
                            CM.Primary_To_Contact__c = True;  
                        }
                        CM.Phone__c = personalPhone;
                        contactMethodList.add(CM);
                    }
                    if(!String.isEmpty(businessMobile)){
                        ContactMethod__c CM = new ContactMethod__c();
                        CM.Type__c = 'Phone';
                        CM.Type_Purpose__c = 'BUSINESS_MOBILE';
                        CM.Source_Type__c = 'Web';
                        CM.Contact__c = theContact.ID;
                        if(selectedprefPhone == 'businessMobile'){
                            CM.Primary_To_Contact__c = True;  
                        }
                        CM.Phone__c = businessMobile;
                        contactMethodList.add(CM);
                    }
                    if(!String.isEmpty(personalMobile)){
                        ContactMethod__c CM = new ContactMethod__c();
                        CM.Type__c = 'Phone';
                        CM.Type_Purpose__c = 'PERSONAL_MOBILE';
                        CM.Source_Type__c = 'Web';
                        CM.Contact__c = theContact.ID;
                        if(selectedprefPhone == 'personalMobile'){
                            CM.Primary_To_Contact__c = True;  
                        }
                        CM.Phone__c = personalMobile;
                        contactMethodList.add(CM);
                    }
                    if(!String.isEmpty(businessFax)){
                        ContactMethod__c CM = new ContactMethod__c();
                        CM.Type__c = 'Phone';
                        CM.Type_Purpose__c = 'BUSINESS_FAX';
                        CM.Source_Type__c = 'Web';
                        CM.Contact__c = theContact.ID;
                        CM.Phone__c = businessFax;
                        contactMethodList.add(CM);
                    }
                    if(!String.isEmpty(personalEmail)){
                        ContactMethod__c CM = new ContactMethod__c();
                        CM.Type__c = 'Email';
                        CM.Type_Purpose__c = 'PERSONAL_EMAIL';
                        CM.Source_Type__c = 'Web';
                        CM.Contact__c = theContact.ID;
                        if(selectedprefEmail == 'personalEmail'){
                            CM.Primary_To_Contact__c = True;  
                        }
                        CM.Email__c = personalEmail;
                        contactMethodList.add(CM);
                    }
                    if(!String.isEmpty(businessEmail)){
                        ContactMethod__c CM = new ContactMethod__c();
                        CM.Type__c = 'Email';
                        CM.Type_Purpose__c = 'BUSINESS_EMAIL';
                        CM.Source_Type__c = 'Web';
                        CM.Contact__c = theContact.ID;
                        if(selectedprefEmail == 'businessEmail'){
                            CM.Primary_To_Contact__c = True;  
                        }
                        CM.Email__c = businessEmail;
                        contactMethodList.add(CM);
                    }
                }
                if(!contactMethodList.isEmpty())
                    insert contactMethodList;
                if(!contactMethodList.isEmpty() && contactRoleMap.get(contactRole) == 'Primary Contact'){
                    Account acc = new Account();
                    acc.Id = accountid;
                    acc.Mobile2_Other__c  = null;
                    acc.Other_Phone_Ext__c  = null;
                    acc.Work_Phone__c  = null;
                    acc.Work_Phone_Ext__c  = null;
                    acc.Mobile1__c = null;
                    acc.Home_Phone__c = null;
                    acc.Email_Address__c = null;
                    acc.Type_Purpose__c = null;
                    acc.PrimaryEmail_CMId__c = null;
                    acc.Phone = null;
                    acc.Preferred_Phone__c = null;
                    acc.PrimaryPhone_CMId__c = null;
                    acc.PrimarySMS_CMId__c = null;
                    acc.SMS_Phone__c = null;
                    for(ContactMethod__c CM: contactMethodList){                        
                        if(CM.Primary_To_Contact__c == True){                            
                            if(CM.Type__c == 'Email'){                                
                                acc.Email_Address__c = CM.Email__c;
                                acc.Type_Purpose__c = CM.Type_Purpose__c;
                                acc.PrimaryEmail_CMId__c = CM.Id;
                            }
                            if(CM.Type__c == 'Phone'){
                                //acc.Id = accountid;                                
                                acc.Phone = CM.Phone__c;
                                acc.Preferred_Phone__c = CM.Type_Purpose__c;
                                acc.PrimaryPhone_CMId__c = CM.Id;
                            }
                        }
                        if(CM.Type__c == 'Phone'){
                            if(CM.Type_Purpose__c == 'BUSINESS_MOBILE' || CM.Type_Purpose__c == 'PERSONAL_MOBILE' && acc.PrimarySMS_CMId__c == null){
                                acc.PrimarySMS_CMId__c = CM.Id;
                                acc.SMS_Phone__c = CM.Phone__c;
                            }
                            if(CM.Type_Purpose__c != 'BUSINESS_FAX') {
                                System.debug('CM:'+CM);
                                if(CM.Type_Purpose__c == 'BUSINESS_PHONE'){
                                    acc.Work_Phone__c = CM.Phone__c;
                                    acc.Work_Phone_Ext__c = CM.Phone_Extension__c;
                                    System.debug('acc.Work_Phone__c:'+acc.Work_Phone__c);
                                }                                
                                if(CM.Type_Purpose__c == 'PERSONAL_PHONE'){
                                    acc.Home_Phone__c = CM.Phone__c;
                                    acc.Other_Phone_Ext__c = CM.Phone_Extension__c;
                                    System.debug('acc.Home_Phone__c:'+acc.Home_Phone__c);
                                }
                                if(CM.Type_Purpose__c == 'BUSINESS_MOBILE'){
                                    acc.Mobile1__c = CM.Phone__c;                                            
                                }
                                if(CM.Type_Purpose__c == 'PERSONAL_MOBILE'){                                    
                                    acc.Mobile2_Other__c = CM.Phone__c;
                                }
                            }
                        }
                    }
                    accountList.add(acc);
                    system.debug('accountList:'+accountList);
                }
                if(!accountList.isEmpty())
                    update accountList;
                // Modifed by Ravinder    
                return new PageReference('/' + accountid);
                // CODE ENDS.
            }
        }
        catch(Exception e) {
            hasError = true;
          system.debug('TRACE: Exception Occurred - ' + e.getMessage());
          system.debug('TRACE: Exception Occurred - ' + e.getStackTraceString());
          ApexPages.addMessage(new ApexPages.Message(
            ApexPages.Severity.ERROR,
            e.getMessage()
          ));
        }

        return null;
    }

    /*
    @method      : cancelProcess
    @description : Cancels the CDH contact matching process and returns to RET_URL URL param.
    @params      : void
    @returns     : PageReference
    */
    public PageReference cancelProcess() {
        return theStandardController.cancel();
    }

    /*
    @method      : updateExistingContact
    @description : Updates the contact that does exist on CDH system to avoid duplicate contact creation.
    @params      : void
    @returns     : PageReference
    */
    public PageReference updateExistingContact() {
        try {
            Integer totalContactsSelected = 0;
        
            // Validating Contact Selection.
            for(ContactWrapper theContactWrapper : theSelectedContacts) {
                if(theContactWrapper.isSelected == true) {
                    totalContactsSelected++;
                }
            }
            
            if(totalContactsSelected > 1) {
                ApexPages.addMessage(new ApexPages.Message(
                  ApexPages.Severity.ERROR,
                  'Please select only one contact to update.'
                ));
                return null;
            }
            else if(totalContactsSelected == 0) {
                ApexPages.addMessage(new ApexPages.Message(
                  ApexPages.Severity.ERROR,
                  'Please select at least one contact to update.'
                ));
                return null;
            }
            else {
                Id ContactToUpdate = null;
                for(ContactWrapper theContactWrapper : theSelectedContacts) {
                    if(theContactWrapper.isSelected == true) {
                        ContactToUpdate = theContactWrapper.theContact.Id;
                        break;
                    }
                }
            
                // Updated For Task # T-377874.
                // CODE STARTS.
                Contact newContact = (Contact)theStandardController.getRecord();
                newContact.Id = ContactToUpdate;
                newContact.Existing_Party_ID__c = true;
                update newContact;
                return new PageReference('/' + ContactToUpdate);
                // CODE ENDS.
            }
        }
        catch(Exception e) {
            system.debug('TRACE: Exception Occurred - ' + e.getMessage());
            system.debug('TRACE: Exception Occurred - ' + e.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(
            ApexPages.Severity.ERROR,
            e.getMessage()
            ));
        }
        
        return null;
    }

    /*
    @method      : createNewContact
    @description : Allows the user to create a new contact even if the contact exists on CDH system.
    @params      : void
    @returns     : PageReference
    */
    public PageReference createNewContact() {
        try {
          // Updated For Task # T-377874.
          // CODE STARTS.
          theContact = (Contact)theStandardController.getRecord();
          if(String.isNotBlank(contactRecordTypeId)) {
            theContact.RecordTypeId = contactRecordTypeId;
          }
          theContact.Existing_Party_ID__c = true;
          insert theContact;                           
          return new PageReference('/' + theContact.Id);
          // CODE ENDS.
        }
        catch(Exception e) {
          system.debug('TRACE: Exception Occurred - ' + e.getMessage());
          system.debug('TRACE: Exception Occurred - ' + e.getStackTraceString());
          ApexPages.addMessage(new ApexPages.Message(
            ApexPages.Severity.ERROR,
            e.getMessage()
          ));
        }
        return null;
    }
  
    public List<SelectOption> getphoneOptions() {
        List<SelectOption> phoneOptions = new List<SelectOption>();
        phoneOptions.add(new SelectOption('','-None-'));
        phoneOptions.add(new SelectOption('businessPhone','Business Phone'));
        phoneOptions.add(new SelectOption('personalPhone','Personal Phone'));
        phoneOptions.add(new SelectOption('businessMobile','Business Mobile'));
        phoneOptions.add(new SelectOption('personalMobile','Personal Mobile'));
    
        return phoneOptions;
    }
    
    public List<SelectOption> getemailOptions() {
        List<SelectOption> emailOptions = new List<SelectOption>();
        emailOptions.add(new SelectOption('','-None-'));
        emailOptions.add(new SelectOption('businessEmail','Business Email'));
        emailOptions.add(new SelectOption('personalEmail','Personal Email'));
    
        return emailOptions;
    }
    
    public List<SelectOption> getcontactRoleLst() {
        List<SelectOption> contactRoleLst = new List<SelectOption>();
        contactRoleLst.add(new SelectOption('','-None-'));
        contactRoleLst.add(new SelectOption('primaryContact','Primary Contact'));
        contactRoleLst.add(new SelectOption('secondaryContact','Secondary Contact'));
        contactRoleLst.add(new SelectOption('technicalContact','Technical Contact'));
        contactRoleLst.add(new SelectOption('otherContact','Other Contact'));
        contactRoleLst.add(new SelectOption('decisionmaker','Decision Maker'));
        contactRoleLst.add(new SelectOption('financeContact','Finance Contact'));
        contactRoleLst.add(new SelectOption('marketingContact','Marketing Contact'));
        contactRoleLst.add(new SelectOption('salesContact','Sales Contact'));
        contactRoleLst.add(new SelectOption('reportingContact','Reporting Contact'));
        contactRoleLst.add(new SelectOption('businessContact','Business Contact'));
        contactRoleLst.add(new SelectOption('userandevaluator','User and Evaluator'));
        contactRoleLst.add(new SelectOption('propertymanager','Property Manager'));
        contactRoleLst.add(new SelectOption('President','President'));       
        contactRoleLst.add(new SelectOption('Assistant','Assistant'));
        
        contactRoleMap.put('primaryContact','Primary Contact');
        contactRoleMap.put('secondaryContact','Secondary Contact');
        contactRoleMap.put('technicalContact','Technical Contact');
        contactRoleMap.put('otherContact','Other Contact');
        contactRoleMap.put('decisionmaker','Decision Maker');
        contactRoleMap.put('financeContact','Finance Contact');
        contactRoleMap.put('marketingContact','Marketing Contact');
        contactRoleMap.put('salesContact','Sales Contact');
        contactRoleMap.put('reportingContact','Reporting Contact');
        contactRoleMap.put('businessContact','Business Contact');
        contactRoleMap.put('userandevaluator','User and Evaluator');
        contactRoleMap.put('President','President');
        contactRoleMap.put('propertymanager','Property Manager');
        contactRoleMap.put('Assistant','Assistant');
        return contactRoleLst;
    }
    
    public static Boolean validateEmail(String email) {
        Boolean res = true;                    
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; // source: <a href="http://www.regular-expressions.info/email.html" target="_blank" rel="nofollow">http://www.regular-expressions.info/email.html</a>
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(email);
    
        if (!MyMatcher.matches()) 
            res = false;
        System.debug('res:'+res);
        return res;	
	}

  // The Contact Wrapper For Binding Contacts With Apex Page.
    public class ContactWrapper {
        public Contact theContact { get; set; }
        public Boolean isSelected { get; set; }
        
        public ContactWrapper(Contact a) {
          theContact = a;
          isSelected = false;
        }
    }
}