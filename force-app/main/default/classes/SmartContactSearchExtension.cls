//
// (c) 2015 Appirio, Inc.
//
// Apex Extension Name: SmartContactSearchExtension
// Description: Create process to create consumer type of contact.
//
// 19th March 2015   Hemendra Singh Bhati   Original (Asset # Smart Contact Search # Asset-342)
// 20th March 2015   Hemendra Singh Bhati   Modified (Task # T-371911) - Added Method: checkContactRecordType().
// 25th March 2015   Hemendra Singh Bhati   Modified (Task # T-373297)
// 08th April 2015   Hemendra Singh Bhati   Modified (Task # T-376891) - Added Method: getAvailableRecordTypeNamesForSObject().
//                                                                       Updated Method: checkContactRecordType().
//
public without sharing class SmartContactSearchExtension {
  // Search criteria fields.
  // Public properties.
    public String contactFirstNameToSearch { set; get; }
    public String contactLastNameToSearch { set; get; }
    public String contactEmail { set; get; }
    public STring contactPhone { set; get; }
    public String leadFirstNameToSearch { set; get; }
    public String leadLastNameToSearch { set; get; }
    public String leadEmail { set; get; }
    public STring leadAccount { set; get; }
    public String resetTextBoxName { set; get; }
    public String filterCriteria { set; get; }
    public String filterLeadCriteria { set; get; }
    public String contactFieldCsv { set; get; }
    public String leadFieldCsv { set; get; }
    public String soslSearchStringForContact { set; get; }
    public String soslSearchStringForLead { set; get; }
    public Boolean isContactSearchWithSOSL { set; get; }
    public Boolean isLeadSearchWithSOSL { set; get; }

  public Boolean isLastNameUsedAsFilterCriteria { set; get; }
  public Boolean isEmailUsedAsFilterCriteria { set; get; }
  public Boolean isPhoneUsedAsFilterCriteria { set; get; }

  // Private properties.
  private final String CONTACT_RECORD_TYPE_CONSUMER = 'Consumer';
  private final String CONTACT_RECORD_TYPE_STANDARD = 'Standard';
  private final String CONTACT_RECORD_TYPE_MOVING = 'Moving';       //CRM-3717
  private final String CONTACT_RECORD_TYPE_MORTGAGE  = 'Mortgage';       

  // The constructor.
  public SmartContactSearchExtension(ApexPages.StandardController controller) {         
    init();
  }    
    
  // The Constructor.
  public SmartContactSearchExtension() {            
    init();
  }

  private void init() {
      isContactSearchWithSOSL = DuplicateContact__c.getInstance().Search_Using_SOSL__c;
      isLeadSearchWithSOSL =  DuplicateLead__c.getInstance().Search_Using_SOSL__c; 
      resetSearchStatus();
        createContactFieldCsv();
        createLeadFieldCsv();
  }
    
  // Method for create csv of field from fieldset of Contact.
    private void createContactFieldCsv(){
      contactFieldCsv = SmartSearchUtility.createFieldCsv('Contact','Contact_Search_Result');
    }

  // Method for create csv of field from fieldset of Lead.
  private void createLeadFieldCsv() {
    leadFieldCsv = SmartSearchUtility.createFieldCsv('Lead', 'lead_search_result' );
  }

  // Set to default status of page.
  public void resetSearchStatus() {
    // Reset Contact fields.
    if(resetTextBoxName != '') {
            if(resetTextBoxName == '1') {
        contactFirstNameToSearch = '';
            }
            else if(resetTextBoxName == '2') {
        contactLastNameToSearch = '';
            }
            else if(resetTextBoxName == '3') {
        contactEmail = '';
            }
            else if(resetTextBoxName == '4') {
        contactPhone = '';
            }  
            performSearch();
    }
    else {
            contactFirstNameToSearch = '';
            contactLastNameToSearch = '';
            contactEmail = '';
            contactPhone = '';
            filterCriteria = '';
            filterLeadCriteria = '';
            soslSearchStringForContact = '';
            soslSearchStringForLead = '';
            populateLeadFields();
    }
  }
    
  // Method for populate lead fields from contact fields for search.
  public void populateLeadFields() {
    leadFirstNameToSearch = contactFirstNameToSearch;
        leadLastNameToSearch = contactLastNameToSearch;
        leadEmail = contactEmail;
        leadAccount = contactPhone;
  }

  // Method to create filter criteria string for contact search.
  public String findSearchCondition() {
    String query = '';
    soslSearchStringForContact = '';

    if(String.isNotBlank(contactPhone)) {
          contactPhone = contactPhone.replace('*','');
          contactPhone = String.escapeSingleQuotes(contactPhone);
          isPhoneUsedAsFilterCriteria = true;
      if(isContactSearchWithSOSL) {
        String dynamicQuery = 'FIND \'' + contactPhone.Trim() + '*\' IN ALL FIELDS RETURNING Contact ( Name, Id ) LIMIT 100';

        List<List<SObject>>searchList = search.query(dynamicQuery);
        for(sObject obj : searchList[0]) {
          query += ' Phone = \'' + String.valueOf(obj.get('Id')) + '\' AND';
        }
        isContactSearchWithSOSL = false;
      }
      else {
        query += ' Phone like \'%' + contactPhone.Trim() + '%\' AND';
      }
    }

      if(isContactSearchWithSOSL && String.isNotBlank(contactFirstNameToSearch)) {
      soslSearchStringForContact += contactFirstNameToSearch + ' OR ';
      }

      if(String.isNotBlank(contactLastNameToSearch)) {
      contactLastNameToSearch = contactLastNameToSearch.replace('*','');
      contactLastNameToSearch = String.escapeSingleQuotes(contactLastNameToSearch);
      isLastNameUsedAsFilterCriteria = true;
      query += ' LastName like \'%' + contactLastNameToSearch.Trim() + '%\' AND';
      if(isContactSearchWithSOSL) {
        soslSearchStringForContact += contactLastNameToSearch.Trim() + ' OR ';
      }
    }

      if(String.isNotBlank(contactEmail)) {
          contactEmail = contactEmail.replace('*','');
          contactEmail = String.escapeSingleQuotes(contactEmail);
          isEmailUsedAsFilterCriteria = true;
          query += ' Email like \'%' + contactEmail.Trim() + '%\' AND';
          if(isContactSearchWithSOSL) {
        soslSearchStringForContact += contactEmail.Trim() + ' OR ';
          }
      }

    if(String.isNotBlank(query)) {
      query += ' RecordTypeId = \'' + Schema.SObjectType.Contact.RecordTypeInfosByName.get(CONTACT_RECORD_TYPE_CONSUMER).RecordTypeId + '\' AND';
      query = query.substring(0,query.lastindexof('AND'));
    }
    if(isContactSearchWithSOSL && String.isNotBlank(soslSearchStringForContact)) {
      soslSearchStringForContact = soslSearchStringForContact.substring(0,soslSearchStringForContact.lastindexof(' OR '));
    }

    return query;
  }

  // Method to create filter criteria string for lead search.
  public String findLeadSearchCondition() {
    String query = '';
    soslSearchStringForLead = '';

      if(isLeadSearchWithSOSL && String.isNotBlank(leadFirstNameToSearch)) {
      soslSearchStringForLead += leadFirstNameToSearch + ' OR ';
      }

    if(String.isNotBlank(leadLastNameToSearch)) {
          leadLastNameToSearch = leadLastNameToSearch.replace('*','');
          leadLastNameToSearch = String.escapeSingleQuotes(leadLastNameToSearch);
          query += ' LastName like \'%' + leadLastNameToSearch.Trim() + '%\' AND';

          if(isLeadSearchWithSOSL) {
        soslSearchStringForLead += leadLastNameToSearch.Trim() + ' OR ';
          }
    }

    if(String.isNotBlank(leadEmail)) {
          leadEmail = leadEmail.replace('*','');
          leadEmail = String.escapeSingleQuotes(leadEmail);
          query += ' Email like \'%' + leadEmail.Trim() + '%\' AND';

          if(isLeadSearchWithSOSL) {
            soslSearchStringForLead += leadEmail.Trim() + ' OR ';
          }
    }
      
    if(String.isNotBlank(leadAccount)) {
          leadAccount = leadAccount.replace('*','');
          leadAccount = String.escapeSingleQuotes(leadAccount);
          query += ' Company like \'%' + leadAccount.Trim() + '%\' AND';

      if(isLeadSearchWithSOSL) {
        soslSearchStringForLead += leadAccount.Trim() + ' OR ';
      }
    }

      if(String.isNotBlank(query)) {
      query = query.substring(0,query.lastindexof('AND'));
      }

      if(isLeadSearchWithSOSL && String.isNotBlank(soslSearchStringForLead)) {
      soslSearchStringForLead = soslSearchStringForLead.substring(0,soslSearchStringForLead.lastindexof(' OR '));
      }

    return query;
  }

  public void performSearch() {
      populateLeadFields();

    isLastNameUsedAsFilterCriteria = false;
    isEmailUsedAsFilterCriteria = false;
    isPhoneUsedAsFilterCriteria = false;

      filterCriteria = findSearchCondition();

      filterLeadCriteria = findLeadSearchCondition();
  }

  public pagereference createNewContact() {
    String recordType = ApexPages.currentPage().getParameters().get('RecordType');
    Pagereference pg = new Pagereference('/' + SmartSearchUtility.getPrefix('Contact') + '/e?retURL=/apex/SmartContactSearch&nooverride=1&name_firstcon2=' + contactFirstNameToSearch + '&name_lastcon2=' + contactLastNameToSearch + '&con15=' + contactEmail + '&con10=' + contactPhone + (String.isEmpty(recordType) ? '' : '&RecordType=' + recordType ));
    pg.setRedirect(true);
    return pg;
  }

  public pagereference createNewLead() {
    Pagereference pg = new Pagereference('/' + SmartSearchUtility.getPrefix('Lead') + '/e?retURL=/apex/SmartContactSearch&nooverride=1&name_firstlea2=' + leadFirstNameToSearch + '&name_lastlea2=' + leadLastNameToSearch + '&lea11=' + leadEmail + '&lea3=' + leadAccount);
    pg.setRedirect(true);
    return pg;
  }

  // Returns a list of names of all the available record types available to the running user for a given sobject type.
  public static List<String> getAvailableRecordTypeNamesForSObject(Schema.SObjectType objType) {
    List<String> names = new List<String>();
    List<RecordTypeInfo> infos = objType.getDescribe().getRecordTypeInfos();
    // If there are 2 or more RecordTypes.
    if(infos.size() > 1) {
      for(RecordTypeInfo i : infos) {
        if(i.isAvailable()
           // Ignore the Master Record Type, whose Id always ends with 'AAA'.
           // We check the Id because Name can change depending on the user's language.
           && !String.valueOf(i.getRecordTypeId()).endsWith('AAA')) {
            names.add(i.getName());
           }
        }
    }
    // Otherwise there's just the Master record type,
    // so add it in, since it MUST always be available.
    else {
        names.add(infos[0].getName());
    } 
    return names;
  }

  // This method checks the contact record type and handles redirection.
  public PageReference checkContactRecordType() {
    PageReference redirect = null;

    String theURLParams = '';
      Map<String,String> urlParams = ApexPages.currentPage().getParameters();
      System.debug('TRACE: urlParams - ' + urlParams);
      for(String key : urlParams.keySet()) {
        if(key != 'save_new') {
          theURLParams += '&' + key + '=' + urlParams.get(key);
        }
      }

    String recordType = ApexPages.currentPage().getParameters().get('RecordType');
    if(
      String.isNotBlank(recordType) && (
      recordType == Schema.SObjectType.Contact.RecordTypeInfosByName.get(CONTACT_RECORD_TYPE_STANDARD).RecordTypeId ||
      recordType == Schema.SObjectType.Contact.RecordTypeInfosByName.get(CONTACT_RECORD_TYPE_MOVING).RecordTypeId || //CRM-3717
      recordType == Schema.SObjectType.Contact.RecordTypeInfosByName.get(CONTACT_RECORD_TYPE_MORTGAGE).RecordTypeId
    )) {
        redirect = new PageReference('/apex/CreateNewContact?nooverride=0' + (String.isNotBlank(theURLParams) ? theURLParams : ''));
    }
    else if(String.isBlank(recordType)) {
      List<String> availableContactRecordTypes = getAvailableRecordTypeNamesForSObject(Contact.SObjectType);
      if(availableContactRecordTypes.size() == 1) {
        if(Schema.SObjectType.Contact.RecordTypeInfosByName.get(availableContactRecordTypes.get(0)).RecordTypeId ==
         Schema.SObjectType.Contact.RecordTypeInfosByName.get(CONTACT_RECORD_TYPE_STANDARD).RecordTypeId
        ) {
            redirect = new PageReference(
              '/apex/CreateNewContact?RecordType=' +
              Schema.SObjectType.Contact.RecordTypeInfosByName.get(CONTACT_RECORD_TYPE_STANDARD).RecordTypeId +
              (String.isNotBlank(theURLParams) ? theURLParams : '')
          );
        }
      }
      else {
         redirect = new PageReference('/' + SmartSearchUtility.getPrefix('Contact') + '/e?nooverride=1' + (String.isNotBlank(theURLParams) ? theURLParams : ''));
      }
    }

    return redirect;
  }
}