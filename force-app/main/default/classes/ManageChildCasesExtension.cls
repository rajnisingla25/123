//
// (c) 2015 Appirio, Inc.
//
// Apex Extension: ManageChildCasesExtension
// For Apex Page: ManageChildCases
// Description: A process where the user can create an email from scratch or from an existing template. The user can then view a
// filterable list of all child cases related to the global parent case. He/she can select one or more child cases to send the mass email to.
// The user should also be able to update the status of the selected cases. The user can then send the email and return to the parent case.
//
// 27th March 2015   Hemendra Singh Bhati   Original (Task # T-373932)
// 02nd April 2015   Hemendra Singh Bhati   Modified (Task # T-375441)
// 13th April 2015   Hemendra Singh Bhati   Modified (Issue # I-154865) - Methods Modified: updateStatus(), processParentAndChildCases(),
//                                                                      - addCaseComments().
// 13th April 2015   Hemendra Singh Bhati   Modified (Issue # I-154860) - Methods Modified: createNewTemplate(), getTemplates().
//                                                                      - Added Private Final Property: GLOBAL_CASE_TEMPLATES_FOLDER.
// 30th April 2015   Hemendra Singh Bhati   Modified (Issue # I-157474) - Methods Modified: populateChildCasesWrapperList(),
//                                                                      - processParentAndChildCases().
//
public with sharing class ManageChildCasesExtension {
  public Case theParentCase { get; set; }
  public String theParentCaseComments { get; set; }
  public Boolean hasChildCases { get; set; }
  public Boolean applyParentCaseStatusToChildCases { get; set; }
  public Boolean isParentCaseStatusChanged { get; set; }
  public Boolean isChildCaseStatusChanged { get; set; }

  public List<Case> caseToBeUpdated { get; set; }
  public List<Case> childCaseToBeUpdated { get; set; }
  public List<ChildCasesWrapper> childCasesWrapper { get; set; }

  public ApexPages.StandardController connection { get; set; }

  // Email Template Properties.
  public String showEmailTemplateForm { get; set; }
  public String emailSubject { get; set; }
  public String templateId { get; set; }
  public String fromAddress { get; set; }
  public String toAddress { get; set; }
  public String ccAddress { get; set; }
    public String bccAddress { get; set; }
    public String emailBody { get; set; }
    public Boolean emailSent { get; set; }
  public Boolean renderNewTemplateSection { get; set; }
  public Boolean sendEmailToChildCaseContacts { get; set; }
  public EmailTemplate newEmailTemplate { get; set; }
  private Map<Id, Map<String, String>> emailData { get; set; }
  private final String GLOBAL_CASE_TEMPLATES_FOLDER = 'Global Case Templates';

  // Email Template Parser Properties.
  private final Map<String, String> allowedMergeSObjects = new Map<String, String> {
    'Account' => 'Account',
    'Asset' => 'Asset',
    'Contact' => 'Contact',
    'Case' => 'Case',
    'Campaign' => 'Campaign'
  };
  private Map<String, String> replaceWithFields = new Map<String, String> {
    'Account' => 'Account.Name',
    'Asset' => 'Asset.Name',
    'BusinessHours' => 'BusinessHours.Name',
    'RecordType' => 'RecordType.Name',
    'Contact' => 'Contact.Name',
    'CreatedBy' => 'CreatedBy.Name',
    'LastModifiedBy' => 'LastModifiedBy.Name',
    'OwnerEmail' => 'Owner.Email',
    'OwnerFirstName' => 'Owner.FirstName',
    'OwnerFullName' => 'Owner.Name',
    'OwnerLastName' => 'Owner.LastName',
    'OwnerPhone' => 'Owner.Phone',
    'OwnerTitle' => 'Owner.Title',
    'Parent' => 'Parent.CaseNumber'
  };
  private Map<String, String> replaceWithActualFields { get; set; }
  private String templateBody { get; set; }
  private Set<String> tokens { get; set; }
  private Boolean mergeFieldsProcessorHasError { get; set; }

  // Error Messages.
  private final String CASE_COMMENTS_ERROR = 'Please enter case comments.';
  private final String PARENT_CASE_STATUS_ERROR = 'Please select parent case status.';

  // The Constructor.
  public ManageChildCasesExtension(ApexPages.StandardController theStandardController) {
    system.debug('TRACE: Inside Constructor.');

    connection = theStandardController;

    emailSent = false;
    showEmailTemplateForm = 'none';
    renderNewTemplateSection = false;
    sendEmailToChildCaseContacts = false;
    newEmailTemplate = new EmailTemplate(TemplateType = 'text');

    populateChildCasesWrapperList();
  }

  // Populate Child Cases Wrapper List.
  public void populateChildCasesWrapperList() {
    system.debug('TRACE: Inside populateChildCasesWrapperList().');

    theParentCase = null;
    applyParentCaseStatusToChildCases = false;
    childCasesWrapper = new List<ChildCasesWrapper>();

      Id parentCaseId = ApexPages.currentPage().getParameters().get('parentCaseId');
      if(String.isNotBlank(parentCaseId)) {
        for(Case theChildCase : [SELECT Id, CaseNumber, Subject, Status, Type, Priority, CreatedDate, ParentId, Parent.Status, Parent.OwnerId,
                                 OwnerId, ContactId, Parent.ContactId, Parent.SubStatus__c, Contact.Name, Contact.Email, Thread_ID__c, SubStatus__c
                                 FROM Case WHERE ParentId = :parentCaseId ORDER BY CreatedDate DESC]) {
          childCasesWrapper.add(new ChildCasesWrapper(theChildCase));
        }

        if(childCasesWrapper.size() > 0) {
        hasChildCases = true;
            theParentCase = new Case(
              Id = childCasesWrapper.get(0).theChildCase.ParentId,
              Status = childCasesWrapper.get(0).theChildCase.Parent.Status,
              SubStatus__c = childCasesWrapper.get(0).theChildCase.Parent.SubStatus__c,
              OwnerId = childCasesWrapper.get(0).theChildCase.Parent.OwnerId,
              ContactId = childCasesWrapper.get(0).theChildCase.Parent.ContactId
            );
        }
        else {
        hasChildCases = false;
        ApexPages.addMessage(new ApexPages.Message(
          ApexPages.Severity.INFO,
          'No child cases found.'
        ));
        }
      }
  }

  // Process Parent And Child Cases.
  public void processParentAndChildCases() {
    system.debug('TRACE: Inside processParentAndChildCases().');

    // Updated Code For Issue # I-154865.
    // Added Case Comments To The Parent Case And Selected Child Cases.
    Case theCase = null;
    caseToBeUpdated = new List<Case>();
    List<CaseComment> caseCommentsToBeInserted = new List<CaseComment>();
    if(applyParentCaseStatusToChildCases) {
      for(ChildCasesWrapper theWrapper : childCasesWrapper) {
        if(theWrapper.isSelected == true) {
            theCase = theWrapper.theChildCase;
            theCase.Status = theParentCase.Status;
            theCase.SubStatus__c = theParentCase.SubStatus__c;
            caseToBeUpdated.add(theCase);

          // Adding Comment To Selected Child Case.
          caseCommentsToBeInserted.add(new CaseComment(
            ParentId = theCase.Id,
            IsPublished = true,
            CommentBody = theParentCaseComments
          ));
          }
        }
    }
    else if(isChildCaseStatusChanged && !applyParentCaseStatusToChildCases) {
      for(ChildCasesWrapper theWrapper : childCasesWrapper) {
        if(theWrapper.isSelected == true) {
          caseToBeUpdated.add(theWrapper.theChildCase);

          // Adding Comment To Selected Child Case.
          caseCommentsToBeInserted.add(new CaseComment(
            ParentId = theWrapper.theChildCase.Id,
            IsPublished = true,
            CommentBody = theParentCaseComments
          ));
        }
      }
    }
 
    if(isParentCaseStatusChanged) {
      // Adding Comment To Parent Case.
      caseCommentsToBeInserted.add(new CaseComment(
        ParentId = theParentCase.Id,
        IsPublished = true,
        CommentBody = theParentCaseComments
      ));
    }
      
   if(isParentCaseStatusChanged || isChildCaseStatusChanged || applyParentCaseStatusToChildCases) {
       // CRM-2139 - added to cloase all child cases whenever we close parent
       if(caseToBeUpdated.size() > 0) {
           update caseToBeUpdated;
       }
       
       caseToBeUpdated.add(theParentCase);
    }      

    if(caseToBeUpdated.size() > 0) {
        try {
        update caseToBeUpdated;
        insert caseCommentsToBeInserted;
        theParentCaseComments = '';
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Your request has been processed successfully.'));
        }
        catch(System.DmlException e) {
            system.debug('TRACE: Exception Occurred - ' + e.getMessage());
        system.debug('TRACE: Exception Occurred - ' + e.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(
          ApexPages.Severity.ERROR,
          e.getDmlMessage(0)
        ));
        }
        catch(Exception e) {
          system.debug('TRACE: Exception Occurred - ' + e.getMessage());
          system.debug('TRACE: Exception Occurred - ' + e.getStackTraceString());
          ApexPages.addMessage(new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'An internal error occurred while processing your request. Please contact system administrator.'
          ));
        }
    }
  }

  public PageReference updateStatus() {
    system.debug('TRACE: Inside updateStatus().');

    // Code Added - For Issue # I-154865.
    // STARTS HERE.
    if(String.isBlank(theParentCaseComments)) {
      ApexPages.addMessage(new ApexPages.Message(
        ApexPages.Severity.ERROR,
        CASE_COMMENTS_ERROR
      ));
      return null;
    }
    else if(isParentCaseStatusChanged && String.isBlank(theParentCase.Status)) {
      ApexPages.addMessage(new ApexPages.Message(
        ApexPages.Severity.ERROR,
        PARENT_CASE_STATUS_ERROR
      ));
      return null;
    }
    // ENDS HERE.

    processParentAndChildCases();
    return null;
  }

  public PageReference addCaseComments() {
    system.debug('TRACE: Inside addCaseComments().');

    // Code Updated For Issue # I-154865.
    // STARTS HERE.
    // Removed The Following Conditions:
    // #1 - theParentCase.Status.equalsIgnoreCase('Closed')
    if(String.isBlank(theParentCaseComments)) {
        ApexPages.addMessage(new ApexPages.Message(
          ApexPages.Severity.ERROR,
          CASE_COMMENTS_ERROR
        ));
      return null;
    }
    else if(String.isBlank(theParentCase.Status)) {
      ApexPages.addMessage(new ApexPages.Message(
        ApexPages.Severity.ERROR,
        PARENT_CASE_STATUS_ERROR
      ));
      return null;
    }
    // ENDS HERE.

    List<CaseComment> toBeInserted = new List<CaseComment>();
    if(String.isNotBlank(theParentCaseComments)) {
      // Adding Comment To Parent Case.
      toBeInserted.add(new CaseComment(
        ParentId = theParentCase.Id,
        IsPublished = true,
        CommentBody = theParentCaseComments
      ));
        
      // Adding Comment To Selected Child Cases.
      for(ChildCasesWrapper theWrapper : childCasesWrapper) {
        if(theWrapper.isSelected == true) {
          toBeInserted.add(new CaseComment(
            ParentId = theWrapper.theChildCase.Id,
            IsPublished = true,
            CommentBody = theParentCaseComments
          ));
        }
      }
    }

    try {
        if(toBeInserted.size() > 0) {
          insert toBeInserted;
          theParentCaseComments = '';
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Your request has been processed successfully.'));
        }
    }
      catch(System.DmlException e) {
        system.debug('TRACE: Exception Occurred - ' + e.getMessage());
        system.debug('TRACE: Exception Occurred - ' + e.getStackTraceString());
        ApexPages.addMessage(new ApexPages.Message(
          ApexPages.Severity.ERROR,
          e.getDmlMessage(0)
        ));
      }
    catch(Exception e) {
      system.debug('TRACE: Exception Occurred - ' + e.getMessage());
      system.debug('TRACE: Exception Occurred - ' + e.getStackTraceString());
      ApexPages.addMessage(new ApexPages.Message(
        ApexPages.Severity.ERROR,
        'An internal error occurred while processing your request. Please contact system administrator.'
      ));
    }

    return null;
  }

  public PageReference sendEmailToCaseContacts() {
    system.debug('TRACE: Inside sendEmailToCaseContacts().');

    toAddress = '';
    emailSent = false;
    emailSubject = '';
    emailBody = '';
    templateId = null;

    Case theCase = null;
    sendEmailToChildCaseContacts = true;
    Set<String> contactEmailAddressesWithNames = new Set<String>();

      for(ChildCasesWrapper theWrapper : childCasesWrapper) {
        if(theWrapper.isSelected == true) {
          theCase = theWrapper.theChildCase;
          if(String.isBlank(theCase.Contact.Email)) {
            ApexPages.addMessage(new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Email address not found for selected child case contact - Case Number #' + theCase.CaseNumber
          ));
          sendEmailToChildCaseContacts = false;
          }
          else {
          contactEmailAddressesWithNames.add(theCase.Contact.Email);
          }
        }
      }

    if(sendEmailToChildCaseContacts && contactEmailAddressesWithNames.size() > 0) {
      for(String theEmailAddressWithName : contactEmailAddressesWithNames) {
        toAddress += theEmailAddressWithName + ';\n';
        }
        toAddress = toAddress.Substring(0, toAddress.length() - 2);
    }

    return null;
  }

  // This is our wrapper/container class to process child cases.
  // This wrapper class contains standard salesforce object Case and two boolean values.
  public class ChildCasesWrapper {
    public Case theChildCase { get; set; }
    public Boolean isSelected { get; set; }

    public ChildCasesWrapper(Case theCase) {
        theChildCase = theCase;
        isSelected = false;
    }
  }

  // Email Templating.
  // CODE STARTS.
  public PageReference selectTemplate() {
    system.debug('TRACE: Inside selectTemplate().');

    return null;
  }

  public List<SelectOption> getTemplates() {
    system.debug('TRACE: Inside getTemplates().');

    Id theFolderId;
    try {
      theFolderId = [SELECT Id, Name, Type FROM Folder WHERE Type = 'Email' AND Name = :GLOBAL_CASE_TEMPLATES_FOLDER].Id;
    }
      catch(Exception e) {
        system.debug('TRACE: Exception Occurred - ' + e.getMessage());
        system.debug('TRACE: Exception Occurred - ' + e.getStackTraceString());
        ApexPages.addMessage(new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'The folder ("' + GLOBAL_CASE_TEMPLATES_FOLDER + '") does not exists.'
        ));
        return null;
      }

    List<SelectOption> options = new List<SelectOption>();

    options.add(new SelectOption('--None--','--None--'));
    for(EmailTemplate theTemplate : [SELECT Id, Name FROM EmailTemplate WHERE folderId IN (:theFolderId, :UserInfo.getUserId())
                                     AND IsActive = true ORDER BY Name ASC]) {
      options.add(new SelectOption(theTemplate.Id,theTemplate.Name));
    }

    return options;
  }

  // Updating Case Fields MetaData For Email Templates Merge Fields Parsing.
  private void updateCaseFieldsMetaData() {
    Schema.DescribeFieldResult caseField = null;
    List<Schema.Sobjectfield> aFieldList = Schema.sObjectType.Case.fields.getMap().values();
    for(Schema.Sobjectfield theField: aFieldList) {
      caseField = theField.getDescribe();
      if(caseField.isCustom() && String.valueOf(caseField.getType()).equalsIgnoreCase('REFERENCE')) {
        replaceWithFields.put(caseField.getName(), caseField.getName().replace('__c', '__r.Name'));
      }
    }

    replaceWithActualFields = new Map<String, String>();
    String theData = '';
    for(String theKey : replaceWithFields.keySet()) {
      theData = replaceWithFields.get(theKey);
      replaceWithActualFields.put(theData, theKey);
    }

    system.debug('TRACE: allowedMergeSObjects - ' + allowedMergeSObjects);
    system.debug('TRACE: replaceWithFields - ' + replaceWithFields);
  }

  // Fetch Selected Child Case Record Ids.
  private Set<Id> getSelectedChildCaseIds() {
    Set<Id> childCaseIds = new Set<Id>();
    for(ChildCasesWrapper theWrapper : childCasesWrapper) {
      if(theWrapper.isSelected == true) {
        childCaseIds.add(theWrapper.theChildCase.Id);
      }
    }
    return childCaseIds;
  }

  // Mapping Selected Child Case Id With Thread Id And Email Address.
  private Map<Id, Map<String, String>> mapChildCaseIdWithThreadIdAndEmailAddress() {
    Map<Id, Map<String, String>> theMap = new Map<Id, Map<String, String>>();
    for(ChildCasesWrapper theWrapper : childCasesWrapper) {
      if(theWrapper.isSelected == true) {
        theMap.put(theWrapper.theChildCase.Id, new Map<String, String> {
            'toAddress' => theWrapper.theChildCase.Contact.Email,
            'Thread_ID__c' => theWrapper.theChildCase.Thread_ID__c
        });
      }
    }
    return theMap;
  }

  // Email Template Merge Fields Processor.
  private void mergeFieldsProcessor() {
    try {
        String theSObject = '';
        String field = '';
        String fieldName = '';
        String sObjectName = '';
        String queryCaseFields = '';
      List<String> theData = new List<String>();
        Set<String> mergeFields = new Set<String>();

      // Updating Case Fields MetaData For Email Templates Merge Fields Parsing.
      updateCaseFieldsMetaData();

      system.debug('TRACE: tokens - ' + tokens);
        for(String mergeField : tokens) {
        if(String.isNotBlank(mergeField)) {
            theSObject = '';
            field = '';

            system.debug('TRACE: mergeField - ' + mergeField);

            theData = mergeField.split('\\.');
            system.debug('TRACE: theData - ' + theData);

            if(theData.size() == 2) {
                sObjectName = theData.get(0);
                fieldName = theData.get(1);
                system.debug('TRACE: sObjectName - ' + sObjectName);
                system.debug('TRACE: fieldName - ' + fieldName);

            if(allowedMergeSObjects.containsKey(sObjectName)) {
                system.debug('TRACE: Allowed Merge SObject.');
                if(String.isNotBlank(sObjectName) && sObjectName.equalsIgnoreCase('Case')) {
                    system.debug('TRACE: Case Object Field.');

                  if(replaceWithFields.containsKey(fieldName)) {
                    system.debug('TRACE: replaceWithFields.get(fieldName) - ' + replaceWithFields.get(fieldName));

                    queryCaseFields += replaceWithFields.get(fieldName).trim() + ', ';
                    mergeFields.add(replaceWithFields.get(fieldName).trim());
                  }
                  else {
                    system.debug('TRACE: fieldName Not Found In replaceWithFields.');

                    queryCaseFields += fieldName.trim() + ', ';
                    mergeFields.add(fieldName.trim());
                  }
                }
                else if(String.isNotBlank(sObjectName) && !sObjectName.equalsIgnoreCase('Case')) {
                    system.debug('TRACE: Non-Case Object - ' + sObjectName);

                  if(allowedMergeSObjects.containsKey(sObjectName)) {
                    theSObject = allowedMergeSObjects.get(sObjectName);
                  system.debug('TRACE: theSObject - ' + theSObject);
                  }
                  queryCaseFields += theSObject.trim() + '.' + fieldName.trim() + ', ';
                  mergeFields.add(theSObject.trim() + '.' + fieldName.trim());

                  system.debug('TRACE: queryCaseFields - ' + queryCaseFields);
                }
            }
            }
        }
        }
      system.debug('TRACE: mergeFields - ' + mergeFields);

      mergeFieldsProcessorHasError = true;
      Id parentCaseId = ApexPages.currentPage().getParameters().get('parentCaseId');
      if(mergeFields.size() > 0 && queryCaseFields.length() > 0 && String.isNotBlank(parentCaseId)) {
        mergeFieldsProcessorHasError = false;

        Set<Id> childCaseIds = getSelectedChildCaseIds();

        sObjectName = '';
          fieldName = '';
          Map<String, String> mergeFieldAndValues = new Map<String, String>();
        Map<Id, Map<String, String>> mergeFieldAndValuesWithCaseIds = new Map<Id, Map<String, String>>();

        queryCaseFields = queryCaseFields.Substring(0, queryCaseFields.length() - 2);
        String query = 'SELECT ' + queryCaseFields + ', Thread_ID__c, Contact.Email FROM Case WHERE Id IN :childCaseIds';
        system.debug('TRACE: query - ' + query);

        for(sObject theCase : Database.query(query)) {
            theCase = (Case)theCase;
            mergeFieldAndValues = new Map<String, String>();
            for(String mergeFieldName : mergeFields) {
                if(mergeFieldName.indexOf('.') == -1) {
                    mergeFieldAndValues.put('Case.' + mergeFieldName, theCase.get(mergeFieldName) != null ? String.valueOf(theCase.get(mergeFieldName)) : '');
                }
            else {
                theData = mergeFieldName.split('\\.');
                system.debug('TRACE: theData - ' + theData);
                mergeFieldAndValues.put(mergeFieldName, theCase.getSobject(theData.get(0)) != null ? String.valueOf(theCase.getSobject(theData.get(0)).get(theData.get(1))) : '');
            }
            }
          mergeFieldAndValues.put('Thread_ID__c', String.valueOf(theCase.get('Thread_ID__c')));
          mergeFieldAndValues.put('Email', String.valueOf(theCase.getSobject('Contact').get('Email')));
            mergeFieldAndValuesWithCaseIds.put(theCase.Id, mergeFieldAndValues);
        }
        system.debug('TRACE: mergeFieldAndValuesWithCaseIds - ' + mergeFieldAndValuesWithCaseIds);

        // Processing Email Subject And Email Body.
        String newMergeField = '';
        String parsedEmailSubject = '';
        String parsedEmailBody = '';
        emailData = new Map<Id, Map<String, String>>();

                emailSubject = emailSubject.replaceAll('\\{!', '');
                emailSubject = emailSubject.replaceAll('\\}', '');
        emailBody = emailBody.replaceAll('\\{!', '');
        emailBody = emailBody.replaceAll('\\}', '');

        system.debug('TRACE: BEFORE - emailSubject - ' + emailSubject);
        system.debug('TRACE: BEFORE - emailBody - ' + emailBody);

        for(Id childCaseId : mergeFieldAndValuesWithCaseIds.keySet()) {
          parsedEmailSubject = emailSubject;
          parsedEmailBody = emailBody;

            mergeFieldAndValues = mergeFieldAndValuesWithCaseIds.get(childCaseId);
            for(String mergeField : mergeFieldAndValues.keySet()) {
                if(replaceWithActualFields.containsKey(mergeField)) {
              newMergeField = 'Case.' + replaceWithActualFields.get(mergeField);

              system.debug('TRACE: Inside For Loop - mergeField - ' + mergeField);
              system.debug('TRACE: Inside For Loop - newMergeField - ' + newMergeField);
              system.debug('TRACE: Inside For Loop - mergeFieldValue - ' + mergeFieldAndValues.get(mergeField));

              parsedEmailSubject = parsedEmailSubject.replaceAll(mergeField.replace('.','\\.'), mergeFieldAndValues.get(mergeField));
              parsedEmailBody = parsedEmailBody.replaceAll(mergeField.replace('.','\\.'), mergeFieldAndValues.get(mergeField));

              system.debug('TRACE: Inside For Loop - parsedEmailSubject - ' + parsedEmailSubject);
              system.debug('TRACE: Inside For Loop - parsedEmailBody - ' + parsedEmailBody);

              parsedEmailSubject = parsedEmailSubject.replaceAll(newMergeField.replace('.','\\.'), mergeFieldAndValues.get(mergeField));
              parsedEmailBody = parsedEmailBody.replaceAll(newMergeField.replace('.','\\.'), mergeFieldAndValues.get(mergeField));

              system.debug('TRACE: Inside For Loop - parsedEmailSubject - ' + parsedEmailSubject);
              system.debug('TRACE: Inside For Loop - parsedEmailBody - ' + parsedEmailBody);
                }
                else {
                system.debug('TRACE: Inside For Loop - mergeField - ' + mergeField);
                system.debug('TRACE: Inside For Loop - mergeFieldValue - ' + mergeFieldAndValues.get(mergeField));

                parsedEmailSubject = parsedEmailSubject.replaceAll(mergeField.replace('.','\\.'), mergeFieldAndValues.get(mergeField));
                parsedEmailBody = parsedEmailBody.replaceAll(mergeField.replace('.','\\.'), mergeFieldAndValues.get(mergeField));

                  system.debug('TRACE: Inside For Loop - parsedEmailSubject - ' + parsedEmailSubject);
                  system.debug('TRACE: Inside For Loop - parsedEmailBody - ' + parsedEmailBody);
                }
            }
            system.debug('TRACE: AFTER - parsedEmailSubject - ' + parsedEmailSubject);
            system.debug('TRACE: AFTER - parsedEmailBody - ' + parsedEmailBody);

          emailData.put(childCaseId, new Map<String, String> {
            'toAddress' => mergeFieldAndValues.get('Email'),
            'emailSubject' => parsedEmailSubject + ' [' + mergeFieldAndValues.get('Thread_ID__c') + ']',
            'emailBody' => parsedEmailBody + '\n\n[' + mergeFieldAndValues.get('Thread_ID__c') + ']'
          });
        }
      }
      else {
        mergeFieldsProcessorHasError = true;
        ApexPages.addMessage(new ApexPages.Message(
         ApexPages.Severity.ERROR,
         'The selected email template is not related to cases. For more details, please contact system administrator.'
        ));
      }
    }
    catch(Exception e) {
        mergeFieldsProcessorHasError = true;
        system.debug('TRACE: Exception Occurred - ' + e.getMessage());
      system.debug('TRACE: Exception Occurred - ' + e.getStackTraceString());
      ApexPages.addMessage(new ApexPages.Message(
        ApexPages.Severity.ERROR,
        'An internal error occurred while processing your request. Please contact system administrator.'
      ));
    }
  }

  public PageReference sendEmail() {
    system.debug('TRACE: Inside sendEmail().');

    // Calling Email Template Merge Fields Parser.
    parseTemplate(emailSubject + ' - ' + emailBody);
    if(tokens.size() > 0) {
        // Calling Email Template Merge Fields Processor.
        mergeFieldsProcessor();
        if(mergeFieldsProcessorHasError) {
            return null;
        }
    }

    Map<String, String> theEmailData = null;
    Messaging.SingleEmailMessage mail = null;
    EmailMessage theEmailMessage = null;
    List<EmailMessage> theEmailMessages = new List<EmailMessage>();
    List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

    if(emailData != null && emailData.size() > 0) {
        for(Id childCaseId : emailData.keySet()) {
            theEmailData = emailData.get(childCaseId);

        mail = new Messaging.SingleEmailMessage();
        mail.saveAsActivity = false;
        mail.setToAddresses(new List<String> { theEmailData.get('toAddress') });

        if(ccAddress != null && ccAddress != '') {
          mail.setCcAddresses(ccAddress.split(';'));
        }

        if(bccAddress != null && bccAddress != '') {
          mail.setBccAddresses(bccAddress.split(';'));
        }

        mail.setSubject(theEmailData.get('emailSubject'));
        mail.setPlainTextBody(theEmailData.get('emailBody'));

        emailsToSend.add(mail);

        theEmailMessage = new EmailMessage(
          ToAddress = theEmailData.get('toAddress'),
          Subject = theEmailData.get('emailSubject'),
          TextBody = theEmailData.get('emailBody'),
          ParentId = childCaseId,
          Status = '3',
          MessageDate = DateTime.now()
        );
        theEmailMessages.add(theEmailMessage);

        theEmailMessage = new EmailMessage(
          ToAddress = theEmailData.get('toAddress'),
          Subject = theEmailData.get('emailSubject'),
          TextBody = theEmailData.get('emailBody'),
          ParentId = theParentCase.Id,
          Status = '3',
          MessageDate = DateTime.now()
        );
        theEmailMessages.add(theEmailMessage);

        system.debug('TRACE: Merge Fields Found - ToAddress - ' + theEmailData.get('toAddress'));
            system.debug('TRACE: Merge Fields Found - emailSubject - ' + theEmailData.get('emailSubject'));
            system.debug('TRACE: Merge Fields Found - emailBody - ' + theEmailData.get('emailBody'));
        }
    }
    else {
        Map<Id, Map<String, String>> mapChildCaseIdWithThreadIdAndEmailAddress = mapChildCaseIdWithThreadIdAndEmailAddress();
      for(Id childCaseId : mapChildCaseIdWithThreadIdAndEmailAddress.keySet()) {
            theEmailData = mapChildCaseIdWithThreadIdAndEmailAddress.get(childCaseId);

        mail = new Messaging.SingleEmailMessage();
        mail.saveAsActivity = false;
        mail.setToAddresses(new List<String> { theEmailData.get('toAddress') });

            if(ccAddress != null && ccAddress != '') {
              mail.setCcAddresses(ccAddress.split(';'));
            }

            if(bccAddress != null && bccAddress != '') {
              mail.setBccAddresses(bccAddress.split(';'));
            }

            mail.setSubject(emailSubject + '[' + theEmailData.get('Thread_ID__c') + ']');
            mail.setPlainTextBody(emailBody + '\n\n' + theEmailData.get('Thread_ID__c'));

        emailsToSend.add(mail);

        theEmailMessage = new EmailMessage(
          ToAddress = theEmailData.get('toAddress'),
          Subject = emailSubject + ' [' + theEmailData.get('Thread_ID__c') + ']',
          TextBody = emailBody + '\n\n' + theEmailData.get('Thread_ID__c'),
          ParentId = childCaseId,
          Status = '3',
          MessageDate = DateTime.now()
        );
        theEmailMessages.add(theEmailMessage);

        theEmailMessage = new EmailMessage(
          ToAddress = theEmailData.get('toAddress'),
          Subject = emailSubject + ' [' + theEmailData.get('Thread_ID__c') + ']',
          TextBody = emailBody + '\n\n' + theEmailData.get('Thread_ID__c'),
          ParentId = theParentCase.Id,
          Status = '3',
          MessageDate = DateTime.now()
        );
        theEmailMessages.add(theEmailMessage);

        system.debug('TRACE: Merge Fields Not Found - ToAddress - ' + theEmailData.get('toAddress'));
        system.debug('TRACE: Merge Fields Not Found - emailSubject - ' + emailSubject + ' [' + theEmailData.get('Thread_ID__c') + ']');
        system.debug('TRACE: Merge Fields Not Found - emailBody - ' + emailBody + '\n\n' + theEmailData.get('Thread_ID__c'));
        }
    }

    system.debug('TRACE: emailsToSend - ' + emailsToSend);
    system.debug('TRACE: theEmailMessages - ' + theEmailMessages);

      try {
        showEmailTemplateForm = 'block';
        Messaging.sendEmail(emailsToSend);
        insert theEmailMessages;
      }
      catch(System.DmlException e) {
        system.debug('TRACE: Exception Occurred - ' + e.getMessage());
        system.debug('TRACE: Exception Occurred - ' + e.getStackTraceString());
        ApexPages.addMessage(new ApexPages.Message(
          ApexPages.Severity.ERROR,
          e.getDmlMessage(0)
        ));
        return null;
      }
      catch(Exception e) {
        system.debug('TRACE: Exception Occurred - ' + e.getMessage());
        system.debug('TRACE: Exception Occurred - ' + e.getStackTraceString());
        ApexPages.addMessage(new ApexPages.Message(
         ApexPages.Severity.ERROR,
         'An internal error occurred while processing your request. Please contact system administrator.'
      ));
        return null;
      }

      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Mail sent successfully to selected child case contacts.'));
      emailSent = true;
      renderNewTemplateSection = false;

      return null;
  }

    public PageReference createNewTemplate() {
      system.debug('TRACE: Inside createNewTemplate().');

      if(!renderNewTemplateSection) {
        renderNewTemplateSection = true;
        return null;
      }
      else
      {
            newEmailTemplate.Subject = emailSubject;
            newEmailTemplate.Body = emailBody;
            newEmailTemplate.FolderId = UserInfo.getUserId();
            newEmailTemplate.IsActive = true;

        try {
          insert newEmailTemplate;
        }
        catch(System.DmlException e) {
          system.debug('TRACE: Exception Occurred - ' + e.getMessage());
          system.debug('TRACE: Exception Occurred - ' + e.getStackTraceString());
          ApexPages.addMessage(new ApexPages.Message(
            ApexPages.Severity.ERROR,
            e.getDmlMessage(0)
          ));
          return null;
        }
        catch(Exception e) {
            system.debug('TRACE: Exception Occurred - ' + e.getMessage());
            system.debug('TRACE: Exception Occurred - ' + e.getStackTraceString());
          ApexPages.addMessage(new ApexPages.Message(
           ApexPages.Severity.ERROR,
           'An internal error occurred while processing your request. Please contact system administrator.'
          ));
          return null;
        }

        ApexPages.addMessage(new ApexPages.Message(
         ApexPages.Severity.INFO,
       'Successfully created the email template and saved to your personal email templates folder.'
        ));

        newEmailTemplate.Id = null;
        renderNewTemplateSection = false;
        return null;
    }
  }

    public PageReference cancelNewTemplate() {
      system.debug('TRACE: Inside cancelNewTemplate().');

      renderNewTemplateSection = false;
      return null;
  }
  // CODE ENDS.

    // Email Template Parser.
    // CODE STARTS.
    private void parseTemplate(String theTemplateBody) {
      templateBody = theTemplateBody;
      tokens = new Set<String>();
      parseTemplate();
    }

    // Email Template Merge Fields Parser.
    private void parseTemplate() {
      try {
        if(templateBody == null || templateBody.trim() == '') {
          return;
        }

        String zToken = null;
        Integer tokenStart = -1;
        Integer tokenEnd = -1;

        String parseTextTemplate = templateBody;
        while(parseTextTemplate != null && parseTextTemplate.length() > 0) {
          zToken = null;
          tokenStart = parseTextTemplate.indexOf('{!');
          if(tokenStart != -1) {
            tokenEnd = parseTextTemplate.indexOf('}', tokenStart);
            if(tokenEnd != -1) {
              // Extracted the token.
              zToken = parseTextTemplate.substring(tokenStart + 2, tokenEnd).trim();
              if(zToken != null) {
                tokens.Add(zToken);                         
              }
              if(zToken != null && zToken != '' && parseTextTemplate.length() > (tokenEnd + 3)) {
                parseTextTemplate = parseTextTemplate.substring(tokenEnd + 1);
              }
              else {
                parseTextTemplate = '';
              }
            }
          }
          if(zToken == null) {
            parseTextTemplate= null;
          }
        }
      }
      catch(Exception e) {
        system.debug('TRACE: Exception Occurred - ' + e.getMessage());
        system.debug('TRACE: Exception Occurred - ' + e.getStackTraceString());
        ApexPages.addMessage(new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'An internal error occurred while processing your request. Please contact system administrator.'
      ));
      }
  }
  // CODE ENDS.
}