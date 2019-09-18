//
// (c) 2015 NTT Data, Inc.
//
// Controller Class Name: HighlightsPanelForServiceExtension
// For Apex Pages: agentAccountsHighlightPanelForService, brokerAccountsHighlightPanelForService
// Description: Here, we are displaying the 8 highlighting information on the account.
// 15th July 2015       Kalyan Meda    Created  Leap - 1567
// 21 April 2016 Krishna Bodala- Changed from showing red flag for open cases to No.of Open cases in the Account highlight panel #LEAP-8458


public without sharing class AccountHighlightsPanelServiceExtension {

        
        Public integer openCasesCountOnAccount {get; private set;}
        Public Boolean hasMLSIssue {get; private set;}
        Public Boolean hasMultipleMLSRelationship {get; private set;}
        Public String  creditStatus {get; private set;}
        Public String  accountOwner {get; private set;}
        Public Boolean showRedFlag {get; private set;}
        Public Boolean hasStrategicNotes {get; private set;}
        Public Boolean doNotCall {get; private set;}
        private Id accountId {get; private set;}
        Public Decimal totalCLC {get; private set;}
        Public Boolean text{get; private set;}
        public Boolean rend1{get;set;}
        public ApexPages.StandardController stdCntrlr {get; private set;}
    
        // Private Members
        private Id theLoggedInUserId = UserInfo.getUserId();
    
        // constructor
     public AccountHighlightsPanelServiceExtension(ApexPages.StandardController stdController) {
    
        accountId = stdController.getRecord().Id;
        Account acc = [Select id, Owner.Name, Type, Credit_Status__c, Total_CLC__c, Customer_Care_Calls__c, Sales_Calls__c, Marketing_Emails__c,
        Agent_SLE__c, Exclusion_Notes__c, MLS_Set_Id__c, Do_Not_Call__c from Account where id = : accountId LIMIT 1];
    
        system.debug('Account: ' + acc);
        
        this.openCasesCountOnAccount = getOpenCasesOnAccount(accountId);
        this.hasMultipleMLSRelationship = getMultipleMLSRelationship(acc);
        this.hasStrategicNotes = calculateStrategicNotes(acc);
        this.creditStatus = acc.Credit_Status__c;
        this.totalCLC = acc.Total_CLC__c;
        this.accountOwner = acc.Owner.Name;
        this.doNotCall = acc.Do_Not_Call__c;
        getMlSIssue(acc.Type, acc.MLS_Set_Id__c);

        system.debug('@@@ credit status: ' + creditStatus);
        system.debug('@@@ totalCLC : ' + totalCLC);
        system.debug('@@@ owner : ' + accountOwner);
    
    
     }
    
    
     // calculate the logic to show flag for Strategic Notes ( same as sales account HL panel)
     private boolean calculateStrategicNotes(Account theAccount) {
    
        if (String.isNotBlank(theAccount.Customer_Care_Calls__c) || 
            String.isNotBlank(theAccount.Sales_Calls__c) || 
            String.isNotBlank(theAccount.Marketing_Emails__c) || 
            String.isNotBlank(theAccount.Agent_SLE__c) || 
            String.isNotBlank(theAccount.Exclusion_Notes__c)) 
        {
            return true;
        }
    
        return false;
     }
     
    
     // Get Multiple MLS relationships on the account if any
     private boolean getMultipleMLSRelationship(Account acc) {
          if(acc.Type == 'Broker'){
             Text = true;               
             rend1 = false;
             return null;   
          }else{
    
        If(acc.MLS_Set_Id__c != null) {
            rend1 = true;
            Integer countOfMLSRelationshipsForTheAccount = 0;
            String mlsName = acc.MLS_Set_Id__c.split('-', -1)[1];
            system.debug('MlS Name : ' + mlsName);
    
            if (acc.type == 'Realtor Agent') {
    
                countOfMLSRelationshipsForTheAccount = [SELECT count() FROM MLS__c WHERE Agent__c = : acc.id AND RecordType.DeveloperName = 'MLS_Agent'
                AND status__c = 'Active'];
            } else if (acc.type == 'Realtor Office') {
    
                countOfMLSRelationshipsForTheAccount = [SELECT count() FROM MLS__c WHERE Office__c = : acc.id AND RecordType.DeveloperName = 'MLS_Office'
                AND status__c = 'Active'];
            }
            system.debug('countOfMLSRelationshipsForTheAccount: ' + countOfMLSRelationshipsForTheAccount);
            
            if(countOfMLSRelationshipsForTheAccount > 1) { return true ; }
            else if ( countOfMLSRelationshipsForTheAccount == 0 || countOfMLSRelationshipsForTheAccount ==1){ return false; }
            
    
        }
        return true;
        }
        //return null;
        
     }
    
     // Get MLS Issues
     private void getMLSIssue(String type, String mlsSetId) {
    
        If(mlsSetId != null) {
            String mlsName = mlsSetId.split('-', -1)[1];
            system.debug('MlS Name : ' + mlsName);
    
            try{
            Integer openCasesOnMLSAccount = [SELECT count() from
            case where AccountId = :[SELECT id from account where type = 'MLS Account' AND customer_id__c = : mlsName].id AND status != 'Closed'
                AND recordtypeId =: CaseRecordTypes__c.getValues('Global').Record_Type_Id__c];
            system.debug('openCasesOnMLSAccount: ' + openCasesOnMLSAccount);
            if (openCasesOnMLSAccount > 0) {
                this.hasMLSIssue = true;
            }

            }catch ( Exception e){
                
                this.hasMLSIssue = false;
            }
    
                
        }
    
     }
   
     // Get the Open cases on the Account
     private integer getOpenCasesOnAccount(Id accountId) {
        return ([SELECT count() FROM Case where AccountId = : accountId and Status != 'closed']);
     }
    

 }