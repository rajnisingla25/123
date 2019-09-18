//
// (c) 2015 Appirio, Inc.
//
// Class Name: AccountRelationshipRelatedlistController
// Description: contoller class for AccountRelationshipRelatedlist page
//
// 10th April 2015    Kirti Agarwal         Original (Task # T-376900)
// 29th April 2015    Hemendra Singh Bhati  Modified (Task # T-381870) - Added Public Property: MLSObjectId
//                                                                     - Updated Consturctor: AccountRelationshipRelatedlistController()
// 08th May 2015            Hemendra Singh Bhati  Modified (Task # T-393149) - Added Public Property: parentFieldName
//                                                                                                                                       - Updated Consturctor: AccountRelationshipRelatedlistController()
//                                                                                                                                   - Indented the code.
// 11th May 2015            Hemendra Singh Bhati  Modified (Task # T-393149) - Added Public Property: MLSRecordTypeName
//                                                                                                                                       - Updated Consturctor: AccountRelationshipRelatedlistController().
//
public class AccountRelationshipRelatedlistController {
    
    
    public Account account;
    public String url { get; set; }
    public String accountRelationShipobjectId { get; set; }
    public String MLSObjectId { get; set; }
    public String contactCSV { get; set; }
    public String parentFieldName { get; set; }
    public String MLSRecordTypeName { get; set; }
    public String ChildAccBtnVisibile { get; set; }  
    Public String selectedTab {get; set;}
    public Id accId       {get;set;}
    public boolean disableODSbtn {get;set;}
    public boolean brokerAffiliationODSbtn {get;set;}
    public boolean isPrimaryContactExist {get;set;}
   
    
    // The Consturctor - Used to get acount record id, name and key prefix for "Account_Relationship__c" object.
    public AccountRelationshipRelatedlistController(ApexPages.StandardController controller) {
        selectedTab = 'parentTab' ;
        Account accountRec = (Account)controller.getRecord();
        account = [SELECT Id, Name, Type, Account_Sub_Type__c,SyncButtonEnableDisable__c,BrokerAffiliationChanged__c FROM Account WHERE Id = :accountRec.Id];
        //disableODSbtn = account.SyncButtonEnableDisable__c ;
        if(account.Type == 'Realtor Office' || account.Type == 'Agent Team'|| account.Type == 'Realtor Agent' ){
            disableODSbtn = true;
            system.debug('disableODSbtn&&&'+disableODSbtn);
        }
        else{
            disableODSbtn = account.BrokerAffiliationChanged__c ;
            system.debug('disableODSbtn&&&'+disableODSbtn);
        }
        brokerAffiliationODSbtn = account.BrokerAffiliationChanged__c ;
        //isPrimaryContactExist = FALSE;
        accId  = accountRec.Id;
        ChildAccBtnVisibile = 'button';
        if(account.Type == 'Realtor Office' || account.Type == 'Agent Team'|| account.Type == 'Realtor Agent' ){
            ChildAccBtnVisibile = 'hidden';
        }
        
        // Added For Task # T-393149.
        // CODE STARTS.
        parentFieldName = 'MLS__c';
        MLSRecordTypeName = '';
        String accountType = account.Type;
        if(String.isNotBlank(accountType)) {
            if(accountType.equalsIgnoreCase('Realtor Agent')) {
                parentFieldName = 'Agent__c';
                MLSRecordTypeName = '\'MLS_Agent\'';
            }
            else if(accountType.equalsIgnoreCase('Realtor Office')) {
                parentFieldName = 'Office__c';
                MLSRecordTypeName = '\'MLS_Office\'';
            }
        }
        // CODE ENDS.

        // CRM-1722 : Check whether primary contact already exists.
        /*if (account.Account_Sub_Type__c == 'customer') {
        List <Account_Relationship__c> accConRelList = [select id, Parent_Account__r.name
                                                        from Account_Relationship__c 
                                                        where Relationship_Type__c = 'Contact' and Parent_Account__c =:accId
                                                        and Contact_Role__c = 'Primary Contact' limit 1];
        if(!accConRelList.isEmpty()){
            isPrimaryContactExist = TRUE;
        }

        }  */                                 
        
        Schema.DescribeSObjectResult result = Account_Relationship__c.sObjectType.getDescribe();
        accountRelationShipobjectId = result.getKeyPrefix();
        
        MLSObjectId = MLS__c.sObjectType.getDescribe().getKeyPrefix();
        
        //contactCSV = 'Contact_To__c,Contact_Role__c,Contact_To__r.Type__c,Contact_To__r.FirstName,Contact_To__r.LastName,';
        //contactCSV = 'Contact_To__c,Contact_Role__c,Billing_Contact__c,Contact_To__r.Type__c,';
        //contactCSV += 'Contact_To__r.Email,Contact_To__r.Preferred_Phone_Number__c,Contact_To__r.NAR_ID__c,Contact_To__r.DoNotCall,Active__c';
        //Contact_To__r.HasOptedOutOfEmail,Contact_To__r.SMS_Opt_In__c'; //Commented as part of Jira SMCI-554
    }
    
    public void setSelectedTab() {
        
    }
    public void syncWithOds(){
        List<Account> accList = [SELECT Id, Name, Party_ID__c, Type, BrokerAffiliationChanged__c,Broker_Affiliation_Changed_SOA__c, Account_ID_18_digit_ID__c FROM Account Where ID =:accId LIMIT 1];
        system.debug('accList'+accList); 
        If(accList.size()>0){
            accList[0].BrokerAffiliationChanged__c = TRUE;
            accList[0].Broker_Affiliation_Changed_SOA__c = TRUE;
            accList[0].SyncButtonEnableDisable__c = FALSE;
        }
        Update accList;
        
    }
}