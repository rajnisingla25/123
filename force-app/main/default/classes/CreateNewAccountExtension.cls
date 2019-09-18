//
// (c) 2015 Appirio, Inc.
//
// Apex Extension: CreateNewAccountExtension
// For Apex Page: CreateNewAccount
// Description: Overrides new button of account sobject and creates an account using custom apex page.
// Calls CDH account creation web service via apex page.
//
// 07th April 2015    Hemendra Singh Bhati    Original (Task # T-376544)
// 08th April 2015    Hemendra Singh Bhati    Modified (Task # T-376544) - Webservice Endpoint Updated.
// 15th April 2015    Hemendra Singh Bhati    Modified (Task # T-377875) - Updated Methods: createAccount(), updateExistingAccount(),
//                                                                       - createNewAccount().
// 27th April 2015    Hemendra Singh Bhati    Modified (Task # T-381848) - Updated Method: createAccount().
// 01st May 2015      Hemendra Singh Bhati    Modified (Task # T-382738) - Updated Method: createAccount() - Updated SOQL Query.
//
public with sharing class CreateNewAccountExtension {
  // Private Properties.
  private Id accountRecordTypeId { get; set; }
  private Account theAccount { get; set; }
  private ApexPages.StandardController theStandardController { get; set; }
  
  // CRM-3277 Moving.com
  private static Id movingRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Moving').getRecordTypeId();
  public boolean isMovingAccount {get; set;}
  // CRM-3277 End
  
  // Mortgage
  private static Id mortgageRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Mortgage').getRecordTypeId();
  public boolean isMortgageAccount {get; set;}
  // CRM-3277 End
  
  // Public Properties.
  public Boolean hasError { get; set; }
  public List<AccountWrapper> theSelectedAccounts { get; set; }

  // The Constructor.
    public CreateNewAccountExtension(ApexPages.StandardController sc) {
        theStandardController = sc;
        theSelectedAccounts = new List<AccountWrapper>();
        theAccount = (Account)theStandardController.getRecord();
        theAccount.Account_Sub_Type__c = 'Prospect';
        theAccount.Account_Status__c = 'Active';
        isMovingAccount = false; // CRM-3277
        isMortgageAccount = false; // Mortgage
        hasError = true;
    accountRecordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
    if(String.isBlank(accountRecordTypeId)) {
        List<String> names = new List<String>();
      List<RecordTypeInfo> infos = Account.SObjectType.getDescribe().getRecordTypeInfos();
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
        accountRecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get(names.get(0)).RecordTypeId;
        }
    }
    isMovingAccount = accountRecordTypeId == movingRecordTypeId; // CRM-3277
    isMortgageAccount = accountRecordTypeId == mortgageRecordTypeId; // Mortgage
    }

  /*
  @method      : createAccount()
  @description : This method calls CDH web-service to find matching accounts. If no match is found, a new account is created and the user
               : is redirected to new account detail page. If a match is found, the list of matching CDH accounts gets displayed from
               : where a user can either opt to create a new account or update the existing CDH account.
  @params      : void
  @returns     : PageReference
  */
  public PageReference createAccount() {
    try {
        hasError = true;
        theSelectedAccounts = new List<AccountWrapper>();
      theAccount = (Account)theStandardController.getRecord();

      // Added For Task # T-381848.
      // CODE STARTS.
      // Validating billing and shipping addresses.
      if(
        String.isBlank(theAccount.BillingStreet) &&
        String.isBlank(theAccount.BillingCity) &&
        String.isBlank(theAccount.BillingState) &&
        String.isBlank(theAccount.BillingPostalCode) &&
        String.isBlank(theAccount.ShippingStreet) &&
        String.isBlank(theAccount.ShippingCity) &&
        String.isBlank(theAccount.ShippingState) &&
        String.isBlank(theAccount.ShippingPostalCode)
      ) {
        ApexPages.addMessage(new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'Please enter either complete billing address or shipping address.'
        ));
        return null;
      }
      else if(
        String.isBlank(theAccount.BillingStreet) ||
        String.isBlank(theAccount.BillingCity) ||
        String.isBlank(theAccount.BillingState) ||
        String.isBlank(theAccount.BillingPostalCode)
      ) {
        if(
          String.isBlank(theAccount.ShippingStreet) ||
          String.isBlank(theAccount.ShippingCity) ||
          String.isBlank(theAccount.ShippingState) ||
          String.isBlank(theAccount.ShippingPostalCode)
        ) {
          ApexPages.addMessage(new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Please enter either complete billing address or shipping address.'
          ));
          return null;
        }
      }

      // Validating phone number and email address.
      if(!isMovingAccount &&   // CRM-3277 Moving.com
        String.isBlank(theAccount.Email_Address__c) &&
        String.isBlank(theAccount.Phone)
      ) {
        ApexPages.addMessage(new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'Please provide a phone number or an email address.'
        ));
        return null;
      }

      // Set preferred phone to blank if phone fields are not populated.
      if(String.isNotBlank(theAccount.Preferred_Phone__c) &&
        String.isBlank(theAccount.Phone)
      ) {
        theAccount.Preferred_Phone__c = null;
      }
      // CODE ENDS.

      xmlnsOracleComInt012AccountMatchacc.MatchAccountCDHService_pt soap = new xmlnsOracleComInt012AccountMatchacc.MatchAccountCDHService_pt();
      soap.timeout_x = 60000;

      String theAccountName = String.isNotBlank(theAccount.Name) ? theAccount.Name : null;
      String theAccountType = String.isNotBlank(theAccount.Type) ? theAccount.Type : null;
      String theStreet = String.isNotBlank(theAccount.BillingStreet) ? theAccount.BillingStreet :
                         String.isNotBlank(theAccount.ShippingStreet) ? theAccount.ShippingStreet : null;
      String theCity = String.isNotBlank(theAccount.BillingCity) ? theAccount.BillingCity :
                       String.isNotBlank(theAccount.ShippingCity) ? theAccount.ShippingCity : null;
      String theStateOrProvince = String.isNotBlank(theAccount.BillingState) ? theAccount.BillingState :
                                  String.isNotBlank(theAccount.ShippingState) ? theAccount.ShippingState : null;
      String thePostalCode = String.isNotBlank(theAccount.BillingPostalCode) ? theAccount.BillingPostalCode :
                             String.isNotBlank(theAccount.ShippingPostalCode) ? theAccount.ShippingPostalCode : null;
      String thePhoneNumber = String.isNotBlank(theAccount.Phone) ? theAccount.Phone : null;
      String theEmailAddress = String.isNotBlank(theAccount.Email_Address__c) ? theAccount.Email_Address__c : null;

      moveComMatchaccount.OutputParameters_element response = soap.process(
        theAccountName,
        theAccountType,
        theStreet,
        theCity,
        theStateOrProvince,
        theStateOrProvince,
        thePostalCode,
        thePhoneNumber,
        theEmailAddress
      );
    system.debug('****callout Ended***'+system.now());
      // Matching Account Party Ids.
      if(response.X_SRCH_RES_LIST != null && response.X_SRCH_RES_LIST.Output != null) {
        Set<String> partyIds = new Set<String>{ String.valueOf(response.X_SRCH_RES_LIST.Output.PARTY_ID) };
        system.debug('TRACE: partyIds - ' + partyIds);

        theSelectedAccounts = new List<AccountWrapper>();
        for(Account theAccount : [SELECT Id, Name, Type, BillingStreet, BillingCity, BillingState, BillingPostalCode, Phone, Email_Address__c,
                                  Party_ID__c, CP_request__c
                                  FROM Account WHERE Party_ID__c IN :partyIds]) {
          theSelectedAccounts.add(new AccountWrapper(theAccount));
        }
      }
      system.debug('TRACE: theSelectedAccounts - ' + theSelectedAccounts);

      hasError = false;
      if(theSelectedAccounts.size() == 0) {
        // Updated For Task # T-377875.
        // CODE STARTS.
        if(String.isNotBlank(accountRecordTypeId)) {
          theAccount.RecordTypeId = accountRecordTypeId;
        }
        insert theAccount;
        return new PageReference('/' + theAccount.Id);
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
  @method      : cancelProcess()
  @description : This method cancels CDH account matching process and returns user to RET_URL URL param.
  @params      : void
  @returns     : PageReference
  */
  public PageReference cancelProcess() {
    return theStandardController.cancel();
  }

  /*
  @method      : updateExistingAccount()
  @description : This method updates the selected CDH matching account.
  @params      : void
  @returns     : PageReference
  */
  public PageReference updateExistingAccount() {
    try {
      Integer totalAccountsSelected = 0;

        // Validating Account Selection.
        for(AccountWrapper theAccountWrapper : theSelectedAccounts) {
          if(theAccountWrapper.isSelected == true) {
            totalAccountsSelected++;
          }
        }

        if(totalAccountsSelected > 1) {
          ApexPages.addMessage(new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Please select only one account to update.'
          ));
          return null;
        }
        else if(totalAccountsSelected == 0) {
          ApexPages.addMessage(new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Please select at least one account to update.'
          ));
          return null;
        }
        else {
          Id accountToUpdate = null;
          for(AccountWrapper theAccountWrapper : theSelectedAccounts) {
            if(theAccountWrapper.isSelected == true) {
              accountToUpdate = theAccountWrapper.theAccount.Id;
              break;
            }
          }

          // Updated For Task # T-377875.
          // CODE STARTS.
          Account newAccount = (Account)theStandardController.getRecord();
          newAccount.Id = accountToUpdate;
          newAccount.Existing_Party__c = true;
          update newAccount;
          return new PageReference('/' + accountToUpdate);
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
  @method      : createNewAccount()
  @description : This method lets user to create a new account even if a matching CDH account is found.
  @params      : void
  @returns     : PageReference
  */
  public PageReference createNewAccount() {
    try {
        // Updated For Task # T-377875.
        // CODE STARTS.
        theAccount = (Account)theStandardController.getRecord();
        if(String.isNotBlank(accountRecordTypeId)) {
          theAccount.RecordTypeId = accountRecordTypeId;
        }
        theAccount.Existing_Party__c = true;
        insert theAccount;
        return new PageReference('/' + theAccount.Id);
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

  // The Account Wrapper Class.
  public class AccountWrapper {
    public Account theAccount { get; set; }
    public Boolean isSelected { get; set; }

    public AccountWrapper(Account a) {
      theAccount = a;
      isSelected = false;
    }
  }
 public PageReference copy_billingto_shipping() { 
    theAccount = (Account)theStandardController.getRecord();
    if(this.theAccount.BillingStreet != null) {         
        this.theAccount.ShippingStreet = this.theAccount.BillingStreet;
      }  
     if(this.theAccount.Billingcity != null){  
        this.theAccount.ShippingCity = this.theAccount.Billingcity ;
      }
      if(this.theAccount.billingstate != null){ 
        this.theAccount.ShippingState = this.theAccount.billingstate ;
       }
      if(this.theAccount.billingpostalcode != null){ 
        this.theAccount.Shippingpostalcode = this.theAccount.billingpostalcode ;
       } 
      if(this.theAccount.billingcountry != null){
        this.theAccount.Shippingcountry = this.theAccount.billingcountry ;
       }
       return null; 
    }  
   public PageReference updatename() { 
     theAccount = (Account)theStandardController.getRecord();
     if(this.theAccount.Name != null) { 
         this.theAccount.Display_Name__c = this.theAccount.Name;
         }         
         return null;
     }    
}