// (c) 2015 Appirio, Inc.  
//
// Class Name: ChildAccountCasesController
// Description: Contoller Extensin for showing Child Account's Cases of the Current Selected Account
//
// 4th April 2015    Ravindra Shekhawat   Original (Task # T-376024)
//
public with sharing class ChildAccountCasesController {

   public Account account;
    // Error Flag For False Account Type
    public boolean noChildAccounts {get;set;}
    // Parent Accounts of Current Account, whose Exclusion Notes to Be Fetched
    Set<String> childAccounts;
    // Filter Criteria To Be Sent to Related List Controller
    public String filterCriteria {get; set;}
    
    public ChildAccountCasesController(ApexPages.StandardController controller) {
    	 // Initialize Set of Child Accounts
    	 childAccounts = new Set<String>();
    	 noChildAccounts=false;
    	 filterCriteria = '(AccountId = ';
         account = (Account)controller.getRecord();
         //Fetch Child Accounts From Account_Relationship__c object for Current Account
         for(Account_Relationship__c accountRelationship: [SELECT Child_Account__c from Account_Relationship__c where Parent_Account__c =: account.Id and Active__c = true]){
         	if(accountRelationship.Child_Account__c !=null)
         	childAccounts.add(accountRelationship.Child_Account__c);
         }
         if(childAccounts.size()>0){
         		prepareFilterCriteria(childAccounts);
         		System.debug('Filter Criteria is : '+filterCriteria);
         }else{
         	noChildAccounts = true;
         }     
    }
    
    // This Method Creates the Filter Criteria
    private void prepareFilterCriteria(Set<String> accountDetails){
    	 // Prepare Filter Criteria
            for(String accountId : accountDetails){
                   filterCriteria+= ('\''+accountId+'\' OR AccountId =');
            }                     
            filterCriteria = filterCriteria.substring(0,filterCriteria.length()-14);
            filterCriteria += ')'; //  AND Status != \'Closed\''; (Commenting due to Leap - 2954)
    }
 }