// (c) 2015 Appirio, Inc.
//
// Class Name: BrokerAccountExclusionNotesContExtension
// Description: Contoller Extensin for Broker Account Exclusion Notes Component
//
// 2nd April 2015    Ravindra Shekhawat   Original (Task # T-375444)
//
public with sharing class BrokerAccountExclusionNotesContExtension{
    public Account account;
    // Error Flag For False Account Type
    public boolean falseAccountType {get;set;}
    // Parent Accounts of Current Account, whose Exclusion Notes to Be Fetched
    Set<String> parentAccounts;
    // Filter Criteria To Be Sent to Related List Controller
    public String filterCriteria {get; set;}
    
    public BrokerAccountExclusionNotesContExtension(ApexPages.StandardController controller) {
    	 falseAccountType=false;
    	 //filterCriteria = 'Id = ';
       account = (Account)controller.getRecord();
       List<Account> accountList = [SELECT Id,Type,Name FROM Account WHERE Id=:ApexPages.currentPage().getParameters().get('id')];
       if(accountList !=null && accountList.size()>0){
            account = accountList.get(0);
            // Create a Set of Account Ids, whose Broker Notes to be Fetched
    	      parentAccounts = new Set<String>();
    	      // Check if Current Account Type is Other than Office/Agent, If Yes Send Error Message
            if(account.Type != Constants.OFFICE_ACCOUNT_TYPE && account.Type != Constants.AGENT_ACCOUNT_TYPE) {
                 falseAccountType = true;
            }
            System.debug('Account Type is : '+account.Type);
            // Check If Current Account is Of Office Type, If yes Fetch It's Parent Broker Accounts         
            if(account.Type == Constants.OFFICE_ACCOUNT_TYPE) { 
            		System.debug('Account Type is : '+Constants.OFFICE_ACCOUNT_TYPE);
         	      for(Account_Relationship__c accountRelationship: [SELECT Parent_Account__c,Active__c FROM Account_Relationship__c
        	 		  													 WHERE ((Child_Account__c =: account.Id) AND
                                                                                (Parent_Account__r.Type =: Constants.BROKER_ACCOUNT_TYPE OR
                                                                                 Parent_Account__r.Type =: Constants.REGION_ACCOUNT_TYPE OR
                                                                                 Parent_Account__r.Type =: Constants.BROKERCOUNCIL_ACCOUNT_TYPE OR
                                                                                 Parent_Account__r.Type =: Constants.REALESTCORP_ACCOUNT_TYPE OR
                                                                                 Parent_Account__r.Type =: Constants.ADAGENCY_ACCOUNT_TYPE OR
                                                                                 Parent_Account__r.Type =: Constants.REALESTNETWORK_ACCOUNT_TYPE OR
                                                                                 Parent_Account__r.Type =: Constants.CORPORATEGROUP_ACCOUNT_TYPE))]){
              	 	  System.debug(accountRelationship);
              	 	  if(accountRelationship.Active__c) {
              	 	     parentAccounts.add(+accountRelationship.Parent_Account__c);
              	 	  }
                }  
            
           // Prepare Filter Criteria    
           if(parentAccounts.size()>0){
               prepareFilterCriteria(parentAccounts);
           }
           } else if(account.Type == Constants.AGENT_ACCOUNT_TYPE){
           	 System.debug('Account Type is : '+Constants.AGENT_ACCOUNT_TYPE);
        	   Set<String> Ids = new Set<String>();
        	   // If Account Type is Of Agent, Get the Office Parent Accounts and Fetch Broker Parent Accounts of the Office Parents
        	   for(Account_Relationship__c accountRelationship: [SELECT Parent_Account__c,Active__c FROM Account_Relationship__c
        	 															 WHERE Child_Account__c =: account.Id AND Parent_Account__r.Type =: Constants.OFFICE_ACCOUNT_TYPE]){
                    System.debug('AGENT ACCOUNT TYPE : '+accountRelationship);
                    if(accountRelationship.Active__c) {                		 
              		      parentAccounts.add(accountRelationship.Parent_Account__c);
                    }
             } 
             for(Account_Relationship__c accountRelate : [SELECT Parent_Account__c,Active__c FROM Account_Relationship__c
        	 															 WHERE  ((Child_Account__c IN : parentAccounts) AND (Parent_Account__r.Type =: Constants.BROKER_ACCOUNT_TYPE OR
                                                                                                                             Parent_Account__r.Type =: Constants.REGION_ACCOUNT_TYPE OR
                                                                                                                             Parent_Account__r.Type =: Constants.BROKERCOUNCIL_ACCOUNT_TYPE OR
                                                                                                                             Parent_Account__r.Type =: Constants.REALESTCORP_ACCOUNT_TYPE OR
                                                                                                                             Parent_Account__r.Type =: Constants.ADAGENCY_ACCOUNT_TYPE OR
                                                                                                                             Parent_Account__r.Type =: Constants.REALESTNETWORK_ACCOUNT_TYPE OR
                                                                                                                             Parent_Account__r.Type =: Constants.CORPORATEGROUP_ACCOUNT_TYPE))]){
        	 				  	if(accountRelate.Active__c) { 
        	 				  	   Ids.add(accountRelate.Parent_Account__c);															 
        	 				  	} 
        	   }
        	   // Prepare Filter Criteria
        	   if(Ids.size()>0){
        	  	  prepareFilterCriteria(Ids);
        	   }
           }
        }else{
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error Occured While Getting Exclusion Notes!'));
        }
        
    }
    
    // This Method Creates the Filter Criteria
    private void prepareFilterCriteria(Set<String> accountDetails){
    	 try{
    	 	   filterCriteria = 'Id = ';
          // Prepare Filter Criteria
          for(String accountId : accountDetails){
             filterCriteria+= ('\''+accountId+'\' OR Id =');
          }
          System.debug('In prepareFilterCriteria:Filter Criteria Is : '+filterCriteria);                     
          filterCriteria = filterCriteria.substring(0,filterCriteria.length()-7);
    	 }catch(Exception e){
    	    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Constants.GENERIC_ERROR_MSG));
    	 }
    	 
    }
 }