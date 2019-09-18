// Extension Class Name: ADVP_BMR_Report_Extension
// For Apex Page: ADVP_BMR_Report
// Description: This extension class is used to generate BMR report using web-service calls.
// Author : Subbu
public with sharing class ADVP_BMR_Report_Extension {
    // Public Data Members.
    public String theReportURL { get; private set; }
    public Boolean showForm { get; private set; }
    public String theReportName { get; set; }
    public List<OfficeAccounts> theOfficeAccounts { get; private set; }
    public Map<Id, Set<String>> theOfficeAccountIdAndMLSSetIDMapping { get; set; }
    public Account theBrokerAccount = New Account();
    public List<Account> TheAccount = New list<Account>();
    
    // Private Data Members.
    private String theReportType { get; set; }
    private String theAccountID { get; set; }
    
    // The Constructor.
    public ADVP_BMR_Report_Extension(ApexPages.StandardController stdController) {
        // Fetching Broker Account.
        showForm = true;
        theBrokerAccount = (Account)stdController.getRecord();
        
        // Extracting Report Type.
        theReportType = ApexPages.currentPage().getParameters().get('type');
        
        // Extracting Account ID.
        TheAccount = [SELECT id,Party_ID__c,ResidentialBrandPPL__c,ResidentialLeadPPL__c,ResidentialAMLC__c,LandAMLC__c,RentalAMLC__c FROM Account WHERE ID=: theBrokerAccount.ID];
        theAccountID = TheAccount[0].id;
        // Extracting Office Accounts Related To Loaded Broker Account.
        Set<Id> theOfficeAccountIds = new Set<Id>();
        theOfficeAccounts = new List<OfficeAccounts>();
        for(Account_Relationship__c theAccountRelationship : [SELECT Child_Account__c, Child_Account__r.Name FROM Account_Relationship__c
                                                              WHERE Parent_Account__c = :theBrokerAccount.Id AND Child_Account__r.Type = 'Realtor Office'
                                                              AND Active__c = True]) {
                                                                  theOfficeAccountIds.add(theAccountRelationship.Child_Account__c);
                                                                  theOfficeAccounts.add(new OfficeAccounts(
                                                                      theAccountRelationship.Child_Account__c,
                                                                      theAccountRelationship.Child_Account__r.Name
                                                                  ));
                                                              }
        system.debug('TRACE: theOfficeAccountIds - ' + theOfficeAccountIds);
        
        if(theOfficeAccountIds.size() == 0) {
            showForm = false;
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.INFO,
                'Sorry! We didn\'t find any office account related to broker account "' + theBrokerAccount.Name + '"'
            ));
        }
        else {
            // Extracting MLS Set IDs Associated With Above Office Accounts.
            theOfficeAccountIdAndMLSSetIDMapping = new Map<Id, Set<String>>();
            for(MLS__c theMLS : [SELECT Id, MLS_Set_ID__c, Office__c FROM MLS__c WHERE Office__c IN :theOfficeAccountIds
                                 AND Status__c = 'Active' And MLS_Set_Type__c = 'Office']) {
                                     if(!theOfficeAccountIdAndMLSSetIDMapping.containsKey(theMLS.Office__c)) {
                                         theOfficeAccountIdAndMLSSetIDMapping.put(theMLS.Office__c, new Set<String>());
                                     }
                                     theOfficeAccountIdAndMLSSetIDMapping.get(theMLS.Office__c).add(theMLS.MLS_Set_ID__c);
                                 }
            system.debug('TRACE: theOfficeAccountIdAndMLSSetIDMapping - ' + theOfficeAccountIdAndMLSSetIDMapping);
            
            if(theOfficeAccountIdAndMLSSetIDMapping.size() == 0) {
                showForm = false;
                ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.INFO,
                    'Sorry! We didn\'t find any MLS Set Ids for office accounts related to broker account "' + theBrokerAccount.Name + '"'
                ));
            }
        }
    }
    
    /*
@method      : generateReport()
@description : This method makes a web-service call to fetch report URL that needs to be opened in a new tab.
@params      : void
@returns     : void
*/
    //public void generateReport(ApexPages.StandardController stdController) {
    public void generateReport() {
        Boolean hasError = false;
        if(String.isBlank(theReportName)) {
            hasError = true;
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR,
                'Please provide report name.'
            ));
        }
        
        Set<Id> theSelectedOffices = new Set<Id>();
        for(OfficeAccounts theOfficeAccount : theOfficeAccounts) {
            if(theOfficeAccount.isSelected) {
                theSelectedOffices.add(theOfficeAccount.officeAccountId);
            }
        }
        system.debug('TRACE: theSelectedOffices - ' + theSelectedOffices);
        
        if(theSelectedOffices.size() == 0) {
            hasError = true;
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR,
                'Please select at least one office.'
            ));
        }
        
        // No Error Found. Good To Go.
        if(!hasError) {
            theReportURL = '';
            
            Set<String> MLSSetIds = new Set<String>();
            for(Id officeAccountId : theSelectedOffices) {
                if(theOfficeAccountIdAndMLSSetIDMapping.containsKey(officeAccountId)) {
                    MLSSetIds.addAll(theOfficeAccountIdAndMLSSetIDMapping.get(officeAccountId));
                }
            }
            system.debug('TRACE: MLSSetIds - ' + MLSSetIds);
            
            if(MLSSetIds.size() == 0) {
                theReportURL = 'error';
                ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    'Sorry! We didn\'t find any MLS Set ID for the selected office accounts.'
                ));
            }
            else {
                try {
                    xmlnsMoveComBmrrealtorlist.BMRRealtorList soap = new xmlnsMoveComBmrrealtorlist.BMRRealtorList();
                    soap.timeout_x = 60000;
                    User ouser = [select id,   NT_Login_ID__c from user where id =: userinfo.getuserid()];
                    String LoginUserName = ouser.NT_Login_ID__c;
                    // String LoginUserName = UserInfo.getName();
                    String ListName = theReportName;
                    String ListDesc = theReportName;
                    String ListID = null;
                    
                    moveComBmr.ArrayOfBMRRealtor theRealtors = new moveComBmr.ArrayOfBMRRealtor();
                    theRealtors.Realtor = new List<moveComBmr.BMRRealtor>();
                    
                    moveComBmr.BMRRealtor theBMRRealtor = null;
                    for(String MLSSetId : MLSSetIds) {
                        theBMRRealtor = new moveComBmr.BMRRealtor();
                        theBMRRealtor.MLSSetID = MLSSetId;
                        theBMRRealtor.RealtorID = null;
                        
                        theRealtors.Realtor.add(theBMRRealtor);
                    }
                    
                    moveComBmr.BMRListCreationResponse response = soap.process(
                        LoginUserName,
                        ListName,
                        ListDesc,
                        ListID,
                        theRealtors
                    );
                    
                    system.debug('response:' + response);
                    
                    // CRM-5289: Updated if condition to remove the NULL check condition on response.BMRURL
                    if(response.ResponseCode == 0) {
                         theReportURL = response.BMRURL;
                        
                        
                        If(ApexPages.currentPage().getParameters().get('POS')==null){
                        if(String.isNotBlank(theReportType) && theReportType.equalsIgnoreCase('BDR') && response.ListID != null) {
                            theReportURL = CDH_Webservices_Endpoints__c.getInstance().AdvantageBDRPart1__c+CDH_Webservices_Endpoints__c.getInstance().AdvantageBDRPart2__c;
                            //+response.ListID; removed list Id for CRM-5823
                        }
                        }
                        else{
                          theReportURL = CDH_Webservices_Endpoints__c.getInstance().POS_BDR1__c+CDH_Webservices_Endpoints__c.getInstance().AdvantageBDRPart2__c;
                          //+response.ListID; removed list Id for CRM-5823

                        
                        }
                        system.debug('before theReportURL:' + theReportURL);
                        theReportURL = theReportURL.replace('BRPPL', TheAccount[0].ResidentialBrandPPL__c != null ? String.valueOf(TheAccount[0].ResidentialBrandPPL__c) : '0.0');  
                        theReportURL = theReportURL.replace('LRPPL', TheAccount[0].ResidentialLeadPPL__c != null ? String.valueOf(TheAccount[0].ResidentialLeadPPL__c) : '0.0');  
                        theReportURL = theReportURL.replace('RNAMLC', TheAccount[0].ResidentialAMLC__c != null ? String.valueOf(TheAccount[0].ResidentialAMLC__c) : '0');  
                        theReportURL = theReportURL.replace('LAMLC', TheAccount[0].LandAMLC__c != null ? String.valueOf(TheAccount[0].LandAMLC__c) : '0');  
                        theReportURL = theReportURL.replace('RSAMLC', TheAccount[0].RentalAMLC__c != null ? String.valueOf(TheAccount[0].RentalAMLC__c) : '0');  
                        theReportURL = theReportURL.replace('PartyID', string.valueof(TheAccount[0].Party_ID__c));
                        theReportURL = theReportURL.replace('AcctID', string.valueof(TheAccount[0].id));
                        system.debug('theReportURL:' + theReportURL);
                    }
                    else if(response.ResponseCode != 0) {
                        system.debug('TRACE: Message Failed With Response Code - ' + response.ResponseCode);
                        system.debug('TRACE: Message Failed With Error - ' + response.MsgDetails != null ? response.MsgDetails : 'Unknown Error.');
                        
                        theReportURL = 'error';
                        ApexPages.addMessage(new ApexPages.Message(
                            ApexPages.Severity.ERROR,
                            'Message failed. Please contact your administrator.'
                        ));
                        
                    }
                    
                }
                catch(Exception e) {
                    system.debug('TRACE: Exception Occurred - ' + e.getMessage());
                    system.debug('TRACE: Exception Occurred - ' + e.getStackTraceString());
                    
                    theReportURL = 'error';
                    ApexPages.addMessage(new ApexPages.Message(
                        ApexPages.Severity.ERROR,
                        'Message failed. Please contact your administrator.'
                    ));
                }
            }
        }
        
        system.debug('TRACE: Generated BDR/BMR Report URL - ' + theReportURL);
    }
    
    // Inner Class.
    public class OfficeAccounts {
        // Public Data Members.
        public Boolean isSelected { get; set; }
        public String officeAccountName { get; private set; }
        
        // Private Data Members.
        private Id officeAccountId { get; set; }
        
        // The Constructor.
        public OfficeAccounts(Id theOfficeAccountId, String theOfficeAccountName) {
            officeAccountId = theOfficeAccountId;
            officeAccountName = theOfficeAccountName;
            isSelected = true;
        }
    }
}