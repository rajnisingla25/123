/* 
 *	Copyright (c) 2016 Zuora, Inc.
 *
 *	Permission is hereby granted, free of charge, to any person obtaining a copy of 
 *	this software and associated documentation files (the "Software"), to use copy, 
 *	modify, merge, publish the Software and to distribute, and sublicense copies of 
 *	the Software, provided no fee is charged for the Software.  In addition the
 *	rights specified above are conditioned upon the following:
 *
 *	The above copyright notice and this permission notice shall be included in all
 *	copies or substantial portions of the Software.
 *
 *	Zuora, Inc. or any other trademarks of Zuora, Inc.  may not be used to endorse
 *	or promote products derived from this Software without specific prior written
 *	permission from Zuora, Inc.
 *
 *	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *	FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL
 *	ZUORA, INC. BE LIABLE FOR ANY DIRECT, INDIRECT OR CONSEQUENTIAL DAMAGES
 *	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 *	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 *	ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 *	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.  
 *
 *	IN THE EVENT YOU ARE AN EXISTING ZUORA CUSTOMER, USE OF THIS SOFTWARE IS GOVERNED
 *
 *	BY THIS AGREEMENT AND NOT YOUR MASTER SUBSCRIPTION AGREEMENT WITH ZUORA.
 */
//This class is used to prevent a Future method calling another Future method, when sending Quote to Zuora and Updating custom fields from Zuora Quote to Subscription in Zuora
public class z_CustomFieldsUpdateQueueableApexClass implements Queueable {

	public void execute(QueueableContext context) {
     updateAccountsFromQuotes(quotesToSend);
	}


	private Map<Id, zqu__Quote__c>	newMap;
  	private Map<Id, zqu__Quote__c>  oldMap;
  	private List<zqu__Quote__c> 	newList;
  	private List<zqu__Quote__c> 	oldList;

	private	Set<ID> quotesToSend;
	private	Set<ID> cancelQuotesToSend;




  	private static final String NEW_SUB_TEXT = 'New Subscription';
  	private static final String AMEND_SUB_TEXT = 'Amend Subscription';
  	private static final String RENEW_SUB_TEXT = 'Renew Subscription';
  	private static final String CANCEL_SUB_TEXT = 'Cancel Subscription';
  	
  	/**
  	* Constructor builds class variables based on Trigger variables
  	**/
  	public z_CustomFieldsUpdateQueueableApexClass() {
		this.newMap  = (Map<Id, zqu__Quote__c>)	Trigger.newMap;
        this.oldMap  = (Map<Id, zqu__Quote__c>) Trigger.oldMap;
        this.newList = (List<zqu__Quote__c>)	Trigger.new;
        this.oldList = (List<zqu__Quote__c>) 	Trigger.old;
   		        
   		//afterUpdate();
  	}

  	/**
  	* Method invoked from Trigger. Call each trigger scenario we should handle (before insert, after insert, before update, etc)
  	**/ 
	public void run() { 		
  		afterUpdate();
  	}

  	/**
  	* Method used in case of "after update" for Trigger
  	**/
  	public void afterUpdate() {
    	if(Trigger.isAfter && Trigger.isUpdate) {
    		updateZuoraObjects(this.newMap, this.oldMap);
    	}
  	}
  	
  	/**
	* This trigger is designed to look for New Subscription and Amend Subscription Quotes that transition from "New" to "Sent to Z-Billing"
	* It will collect IDs of all Quotes that match that criteria and to Update their associated Accounts in Zuora.
	**/
  	public void updateZuoraObjects(Map<Id, zqu__Quote__c> newMap, Map<Id, zqu__Quote__c> oldMap) {
  		//List to store IDs of Quotes to send to z_AccountCustomFieldsUpdate.cls
		quotesToSend = new Set<ID>();
		cancelQuotesToSend = new Set<ID>();

		System.Debug('Starting to cycle through updated Quotes');
		 
		//Cycle through all Updated Quotes to find all Quotes that are "New Subscription" or "Amend Subscription" and transition from "New" to "Sent to Z-Billing"
		for (ID quoteId : newMap.keySet()) {
			
			//Get related old and new quotes
			zqu__Quote__c newQuote = newMap.get(quoteId);
			zqu__Quote__c oldQuote = oldMap.get(quoteId);
			System.Debug('newQuote: '+newQuote); 
			System.Debug('oldQuote: '+oldQuote);
			
			//Ensure successfully found both quotes 
			if (newQuote != null && oldQuote != null) { 
				
				//Check for New Subscription or Amend Subscription with change of Status
				if (newQuote.zqu__Status__c == 'Sent to Z-Billing' && oldQuote.zqu__Status__c == 'New' && !String.isBlank(newQuote.zqu__ZuoraAccountID__c) && newQuote.zqu__SubscriptionType__c != CANCEL_SUB_TEXT) {	
					quotesToSend.add(quoteId);
					System.Debug('Quote matched criteria. Adding to quotesToSend');
				} else {
					System.Debug('Quote did not match criteria.');
				} //END if-else-block

				//David Li
				//Check for Cencal Subscription with change of Status
				if (newQuote.zqu__Status__c == 'Sent to Z-Billing' && oldQuote.zqu__Status__c == 'New' && !String.isBlank(newQuote.zqu__ZuoraAccountID__c) && newQuote.zqu__SubscriptionType__c == CANCEL_SUB_TEXT) {	
					quotesToSend.add(quoteId);
					cancelQuotesToSend.add(quoteId);
					System.Debug('Quote matched criteria. Adding to quotesToSend');
				} else {
					System.Debug('Quote did not match criteria.');
				} //END if-else-block


			} //END if-block
		} //END for-loop  
		
		System.Debug('Done cycling through updated Quotes.');
		
		if (quotesToSend.size() > 0) {
			System.Debug('List of Quotes to send it not empty. Calling future method.');
			//updateAccountsFromQuotes(quotesToSend);
			z_CustomFieldsUpdateQueueableApexClass newClass = new z_CustomFieldsUpdateQueueableApexClass();
			newClass.quotesToSend = quotesToSend;
			System.enqueueJob(newClass);
		} else {
			System.Debug('List of Quotes to send is empty.');
		} //END if-else-block
  	}
  	
	@future (callout=true)
	public static void updateAccountsFromQuotes(Set<ID> quoteIds) {
		if (quoteIds != null && quoteIds.size() > 0) {
			System.Debug('Passed in quoteIds list is not empty. Starting method');

			//List of Quote to ZObject Mapping Custom Settings
			List<Zuora_Quote_to_ZObject_Mapping__c> quoteToObjectMappings = Zuora_Quote_to_ZObject_Mapping__c.getall().values();
			
			//Set to hold field API Names
			Set<String> quoteFields = new Set<String>();
			quoteFields.add('zqu__ZuoraAccountID__c');
			quoteFields.add('zqu__SubscriptionType__c');
			//TODO: add other required fields for Subscription use case
			quoteFields.add('zqu__Subscription_Name__c');
			quoteFields.add('zqu__ZuoraSubscriptionID__c');
			
			for (Zuora_Quote_to_ZObject_Mapping__c quoteToZObjectMapping : quoteToObjectMappings) {
				if (String.isNotBlank(quoteToZObjectMapping.Quote_Field__c)) {
					quoteFields.add(quoteToZObjectMapping.Quote_Field__c);
				}
			}

			//Remove Id field if it exists. We will always query this field
			if (quoteFields.contains('Id')) {
				quoteFields.remove('Id');
			}
		
			//Quote query string
			String quoteQuery = 'SELECT Id';
		
			//Cycle through Quote Fields Set and build query string
			for (String field : quoteFields) {
				quoteQuery += ', '+field;
			}
			
			quoteQuery += ' FROM zqu__Quote__c WHERE Id IN :quoteIds';
			
			System.Debug('quoteQuery: '+quoteQuery);
			
			List<zqu__Quote__c> quotes = Database.query(quoteQuery);
			
			if (quotes.size() > 0) {
				
				//List of Zuora Accounts to update
				List<Zuora.zObject> zuoraAccounts = new List<Zuora.zObject>();
				
				//List of Zuora Accounts to query for BillToContacts and SoldToContacts
				Set<String> zuoraContactAccountIds = new Set<String>(); 
				
				//List of Quotes to cycle through for BillToContact or SoldToContact updates
				Set<zqu__Quote__c> zuoraContactQuotes = new Set<zqu__Quote__c>();

				//TODO: List of Zuora Subscriptions to update
				List<Zuora.zObject> zuoraSubs = new List<Zuora.zObject>();

				//TODO: List of Zuora Sub Names to query
				Set<String> zuoraSubNames = new Set<String>();

				//
				Set<String> zuoraCancelSubNames = new Set<String>();

				//TODO: Map of Zuora Sub Id/Name to zObject
				Map<String, Zuora.ZObject> subIdToObjectMap = new Map<String, Zuora.ZObject>();
				Map<String, Zuora.ZObject> subNameToObjectMap = new Map<String, Zuora.ZObject>();
				
				//Cycle through list of Salesforce Quotes
				for (zqu__Quote__c quote : quotes) {

					//Retrieve Zuora Account Id related to this Salesforce Quote
					String zuoraAccountId = quote.zqu__ZuoraAccountID__c;
					
					if (String.isNotBlank(zuoraAccountId)) {
						Zuora.zObject zAcc = new Zuora.zObject('Account');
						zAcc.setValue('Id', zuoraAccountId);

						Zuora.zObject zSub = new Zuora.zObject('Subscription');
						//previous:
						Boolean pullSubFromQuote = (quote.zqu__SubscriptionType__c == NEW_SUB_TEXT && String.isNotBlank(quote.zqu__ZuoraSubscriptionID__c)) ? true : false;
	
						Boolean pullSubFromZuora = (!pullSubFromQuote && String.isNotBlank(quote.zqu__Subscription_Name__c)) ? true : false;

						//For New Subscription Quotes, we can retrieve Subscription Id directly from Quote
						if (pullSubFromQuote) {
							System.debug('Retrieved Id of Subscription: '+quote.zqu__ZuoraSubscriptionID__c);
							zSub.setValue('Id',quote.zqu__ZuoraSubscriptionID__c);
						} else if (pullSubFromZuora) {
							System.debug('Need to query for Id of Subscription: '+quote.zqu__Subscription_Name__c);

							//David Li
							if(quote.zqu__SubscriptionType__c == CANCEL_SUB_TEXT){
								zuoraCancelSubNames.add(quote.zqu__Subscription_Name__c);
							}else{
								zuoraSubNames.add(quote.zqu__Subscription_Name__c);
							}

						} else {
							System.debug('Could not retrieve Sub Id or Sub Name for Quote');
						}


						Boolean updatedField = false;
						Boolean updatedSubField = false;
						
						//Look at custom object for Account standard fields		
						for (Zuora_Quote_to_ZObject_Mapping__c quoteToZObjectMapping : quoteToObjectMappings) {	
							System.Debug('quoteToZObjectMapping: ' + quoteToZObjectMapping);

							if (confirmQuoteType(quote, quoteToZObjectMapping) && validateMappingSetting(quoteToZObjectMapping) &&
								quote.get(quoteToZObjectMapping.Quote_Field__c) != null) {

								
								if (quoteToZObjectMapping.Zuora_Object__c.equalsIgnoreCase('Account')) {
									System.Debug('Setting ' + quoteToZObjectMapping.Zuora_Object_Field__c + ' on Zuora' +
										quoteToZObjectMapping.Zuora_Object__c + ' as ' +quote.get(quoteToZObjectMapping.Quote_Field__c));
										
									zAcc.setValue(quoteToZObjectMapping.Zuora_Object_Field__c, quote.get(quoteToZObjectMapping.Quote_Field__c));
									updatedField = true;
								} else if (quoteToZObjectMapping.Zuora_Object__c.equalsIgnoreCase('Bill To Contact') || quoteToZObjectMapping.Zuora_Object__c.equalsIgnoreCase('Sold To Contact')) {
									zuoraContactAccountIds.add(quote.zqu__ZuoraAccountID__c);
									zuoraContactQuotes.add(quote);
									System.Debug('Adding Account Id to Accounts for Contacts List: ' + quote.zqu__ZuoraAccountId__c);
								} else if (quoteToZObjectMapping.Zuora_Object__c.equalsIgnoreCase('Subscription')) {
									//TODO: handle subscription use case here

									System.Debug('Setting ' + quoteToZObjectMapping.Zuora_Object_Field__c + ' on Zuora' +
										quoteToZObjectMapping.Zuora_Object__c + ' as ' +quote.get(quoteToZObjectMapping.Quote_Field__c));
										
									zSub.setValue(quoteToZObjectMapping.Zuora_Object_Field__c, quote.get(quoteToZObjectMapping.Quote_Field__c));
									updatedSubField = true;
								}
								
							}
						}
						
						if (updatedField) {
							System.debug('Fields updated on Account. Adding Account to list of Accounts to update in Zuora');
							zuoraAccounts.add(zAcc);
						} else {
							System.debug('No fields updated on Account. Will not add Account to list of Accounts to update in Zuora');
						}

						if (updatedSubField) {
							System.debug('Fields updated on Subscription. Adding Subscription to list of Subscriptions to update in Zuora');

							if (pullSubFromQuote) {
								System.debug('Adding Subscription to subIdToObjectMap');
								subIdToObjectMap.put(quote.zqu__ZuoraSubscriptionID__c, zSub);
								zuoraSubs.add(zSub);
							} else if (pullSubFromZuora) {
								System.debug('Adding Subscription to subNameToObjectMap');
								subNameToObjectMap.put(quote.zqu__Subscription_Name__c, zSub);
							} else {
								System.debug('Quote did not match criteria for pullSubFromQuote or pullSubFromZuora');
							}	
						} else {
							System.debug('No fields updated on Subscription or Quote is not New Subscription. Will not add Subscription to list of Subscriptions to update in Zuora');
						}
					} else {
						System.Debug('Account Id empty for Quote: '+quote);
					}	
				}

				Zuora.zApi zApi = new Zuora.zApi();
				
				try {
					if (!Test.isRunningTest()) {
						zApi.zLogin();
					}
				} catch (Exception e) {
					System.Debug ('Exception while logging in: '+e.getMessage());
				} 

				//Checks if we need to query Zuora by Sub Name to retrieve appropriate Sub Ids
				if (subNameToObjectMap.values().size() > 0) {
					System.debug('Will query Zuora for '+subNameToObjectMap.values().size()+' Subscriptions by Name');

					List<String> zuoraSubNameList = new List<String>();
					List<String> zuoraCancelSubNameList = new List<String>();

					zuoraSubNameList.addAll(zuoraSubNames);
					zuoraCancelSubNameList.addAll(zuoraCancelSubNames);

					//TODO: Build Subscription Query String
					String subQuery = 'Select Id, Name From Subscription ';

					System.debug('zuoraSubNameList "'+zuoraSubNameList.size()+'"');
					Integer i = 0;
					for (i = 0; i < zuoraSubNameList.size(); i++) {
						if (i != 0) {
							//previous
							subQuery += ' Or Name = \''+zuoraSubNameList.get(i)+'\' And Status = \'Active\' ';
						} else {
							//previous
							subQuery += ' Where Name = \''+zuoraSubNameList.get(i)+'\' And Status = \'Active\' ';
						}
					}

					System.debug('zuoraCancelSubNameList "'+zuoraCancelSubNameList.size()+'"');
					for(Integer j = 0; j<zuoraCancelSubNameList.size(); j++){
						/*						
						if (i != 0) {
							//previous
							subQuery += ' Or Name = \''+zuoraCancelSubNameList.get(i)+'\' And Status = \'Cancelled\' ';
						} else {
							//previous
							subQuery += ' Where Name = \''+zuoraCancelSubNameList.get(i)+'\' And Status = \'Cancelled\' ';
						}
						*/
						System.debug('i = ' + i);
						System.debug('j = ' + j);

						if((i == 0) && (j == 0) ){
							subQuery += ' Where Name = \''+zuoraCancelSubNameList.get(j)+'\' And Status = \'Cancelled\' ';
						}else{
							subQuery += ' Or Name = \''+zuoraCancelSubNameList.get(j)+'\' And Status = \'Cancelled\' ';							
						}		
					}

					//TODO: Query Zuora for Subscriptions
					System.debug('Querying Zuora with String "'+subQuery+'"');

					List<Zuora.zObject> retrievedSubs = new List<Zuora.zObject>();

					//TODO: try-catch
					try {  
						retrievedSubs = (!Test.isRunningTest()) ? zApi.zQuery(subQuery) : z_AccountCustomFieldsUpdateTest.getTestZuoraSubs();
					} catch	(Exception ex) {
						System.debug('Exception occurred querying Subs from Zuora: '+ex.getMessage());
					} 
					
					


					//TODO: cycle through ZObjects and set Ids
					for (Zuora.zObject retrievedSub : retrievedSubs) {
						Zuora.zObject relatedSub = subNameToObjectMap.get((String)retrievedSub.getValue('Name'));

						if (relatedSub != null) {
							relatedSub.setValue('Id', (String)retrievedSub.getValue('Id'));
							zuoraSubs.add(relatedSub);
						} else {
							System.debug('relatedSub is null');
						}
					}
				} else {
					System.debug('No Subscriptions to query from Zuora by Name');
				}
				
				System.debug('List of all Zuora Subscriptions: '+zuoraSubs);
				if (zuoraSubs.size() > 0) {
					List<Zuora.zApi.SaveResult> subUpdateResults = new List<Zuora.zApi.SaveResult>();
					try {
						if (!Test.isRunningTest()) {
							subUpdateResults = zApi.zUpdate(zuoraSubs);
						} else {
							//TODO: handle in test class
						}
					} catch (Exception e) {
						System.Debug('Exception while updating Accounts: '+e.getMessage());
					}

					System.Debug('Update Subscription Results: '+subUpdateResults);
				} else {
					System.Debug('Zuora Subscription to update list is empty');
				}
				
				System.Debug('List of all Zuora Accounts: '+zuoraAccounts);			
				if (zuoraAccounts.size() > 0) {
					List<Zuora.zApi.SaveResult> accountUpdateResults = new List<Zuora.zApi.SaveResult>();
					try {
						if (!Test.isRunningTest()) {
							accountUpdateResults = zApi.zUpdate (zuoraAccounts);
						} else {
							//TODO: handle in test class
						}
					} catch (Exception e) {
						System.Debug('Exception while updating Accounts: '+e.getMessage());
					}

					System.Debug('Update Account Results: '+accountUpdateResults);
				} else {
					System.Debug('Zuora Accounts to update list is empty');
				}
				
				List<String> zuoraContactAccountIdsList = new List<String>();
				zuoraContactAccountIdsList.addAll(zuoraContactAccountIds);
				
				//Handle Sold To / Bill To use case
				if (zuoraContactAccountIdsList.size() > 0) {
					System.Debug('Need to query for SoldTo / BillTo information on Accounts: ' + zuoraContactAccountIdsList);
					
					List<Zuora.zObject> contactAccounts = new List<Zuora.zObject>();
					
					String accountQuery = 'Select Id, BillToId, SoldToId From Account Where ';
						
					//Build Account Query filters
					for (Integer i = 0; i < zuoraContactAccountIdsList.size(); i++) {
						if (i != 0) {
							accountQuery += ' OR Id = \''+zuoraContactAccountIdsList.get(i)+'\' ';
						} else {
							accountQuery += ' Id = \''+zuoraContactAccountIdsList.get(i)+'\' ';
						}
					}
					
					System.Debug('accountQuery: '+accountQuery);
					
					//TODO: try-catch
					try {
						contactAccounts = (!Test.isRunningTest()) ? zApi.zQuery(accountQuery) : z_AccountCustomFieldsUpdateTest.getTestZuoraAccounts();
					} catch (Exception ex) {
						System.debug('Exception occurred querying contact Accounts: '+ex.getMessage());
					}
					 
					//if (!Test.isRunningTest()) {
					//	contactAccounts = zApi.zQuery(accountQuery);
					//} else {
					//	//TODO: handle in test class
					//	Zuora.zObject testAccount = new Zuora.zObject('Account');
					//	testAccount.setValue('Id', '12345');
					//	testAccount.setValue('BillToId', '23456');
					//	testAccount.setValue('SoldToId', '34567');
						
					//	contactAccounts.add(testAccount);
					//}
					
					Map<String, Zuora.zObject> accountMap = new Map<String, Zuora.zObject>();
					
					//Build Account Map for later use with Quotes
					for (Zuora.zObject account : contactAccounts) {
						accountMap.put((String)account.getValue('Id'), account);
					}
					
					List<Zuora.zObject> contactsToUpdate = new List<Zuora.zObject>();
					
					//Cycle through affected quotes
					for (zqu__Quote__c quote : zuoraContactQuotes) {
						Zuora.zObject soldToContact = new Zuora.zObject('Contact');
						Zuora.zObject billToContact = new Zuora.zObject('Contact');
						Boolean addSoldTo = false;
						Boolean addBillTo = false;
						
						//Cycle through custom settings
						for (Zuora_Quote_to_ZObject_Mapping__c quoteToZObjectMapping : quoteToObjectMappings) {
							
							//Check if setting is a Bill To Contact or Sold To Contact case
							if (confirmQuoteType(quote, quoteToZObjectMapping) && validateMappingSetting(quoteToZObjectMapping) &&
								quote.get(quoteToZObjectMapping.Quote_Field__c) != null &&
								(quoteToZObjectMapping.Zuora_Object__c.equalsIgnoreCase('Bill To Contact') || 
								quoteToZObjectMapping.Zuora_Object__c.equalsIgnoreCase('Sold To Contact'))) {
								
								System.Debug('Setting matches criteria: '+quoteToZObjectMapping);
							
								Zuora.zObject tempAccount = accountMap.get(quote.zqu__ZuoraAccountID__c);
								
								if (tempAccount != null) {
									if (quoteToZObjectMapping.Zuora_Object__c.equalsIgnoreCase('Bill To Contact')) {
										System.Debug('Bill To Contact use case');
										billToContact.setValue('Id', tempAccount.getValue('BillToId'));
										billToContact.setValue(quoteToZObjectMapping.Zuora_Object_Field__c, quote.get(quoteToZObjectMapping.Quote_Field__c));
										addBillTo = true;
										System.Debug('Current billToContact: ' + billToContact);
									} else if (quoteToZObjectMapping.Zuora_Object__c.equalsIgnoreCase('Sold To Contact')) {
										System.Debug('Sold To Contact use case');
										soldToContact.setValue('Id', tempAccount.getValue('SoldToId'));
										soldToContact.setValue(quoteToZObjectMapping.Zuora_Object_Field__c, quote.get(quoteToZObjectMapping.Quote_Field__c));
										addSoldTo = true;
										System.Debug('Current soldToContact: ' + soldToContact);
									}
								}
							}
						}
						
						if (addSoldTo) {
							System.Debug('Adding sold to contact: ' + soldToContact);
							contactsToUpdate.add(soldToContact);
						}
						if (addBillTo) {
							System.Debug('Adding bill to contact: ' + billToContact);
							contactsToUpdate.add(billToContact);
						}
					}
					
					if (contactsToUpdate.size() > 0) {
						List<Zuora.zApi.SaveResult> contactUpdateResults = new List<Zuora.zApi.SaveResult>();

						try {
							if (!Test.isRunningTest()) {
								contactUpdateResults = zApi.zUpdate (contactsToUpdate);
							} else {
								//TODO: handle this in test class
								Zuora.zApi.SaveResult testResult = new Zuora.zApi.SaveResult();
								testResult.Success = true;
								testResult.Id = '12345';
								
								contactUpdateResults.add(testResult);
							}
						} catch (Exception ex) {
							System.Debug('Exception when updating Cotnacts: '+ex.getMessage());
						}

						System.Debug('contactUpdateResults: '+contactUpdateResults);
					}
				} else {
					System.Debug('No Accounts specified for querying Contacts. Will Skip.');
				}							
			} else {
				System.Debug('Failed to retrieve Salesforce Quotes.');
			}						
		} else {
			System.Debug('Passed in quoteIds list is null or empty: '+quoteIds);
		}	
	} //END updateAccountsFromQuotes() method

  	/**
  	* Helper method for determining if this custom setting record applies to this Quote Type
  	**/
  	public static Boolean confirmQuoteType(zqu__Quote__c quote, Zuora_Quote_to_ZObject_Mapping__c quoteToZObjectMapping) {
  		Boolean success = false;

  		if (quote != null && String.isNotBlank(quote.zqu__SubscriptionType__c) && quoteToZObjectMapping != null) {
  			if ((quote.zqu__SubscriptionType__c == NEW_SUB_TEXT && quoteToZObjectMapping.Enable_for_New_Subscriptions__c) ||
  				(quote.zqu__SubscriptionType__c == AMEND_SUB_TEXT && quoteToZObjectMapping.Enable_for_Amendments__c) ||
  				(quote.zqu__SubscriptionType__c == RENEW_SUB_TEXT && quoteToZObjectMapping.Enable_for_Renewals__c) ||
  				(quote.zqu__SubscriptionType__c == CANCEL_SUB_TEXT && quoteToZObjectMapping.Enable_for_Cancellation__c)) {

  				//System.debug('Quote Sub Type matches mapping');
  				success = true;
  			} else {
  				System.debug('Quote Sub Type does not match mapping');
  			}
  		} else {
  			System.debug('Quote, Sub Type, or Mapping object passed into confirmQuoteType is null');
  		}

  		return success; 
  	}

  	/**
  	* Helper method for validating mapping record doesn't contain any blank fields
  	**/
  	public static Boolean validateMappingSetting(Zuora_Quote_to_ZObject_Mapping__c quoteToZObjectMapping) {
  		Boolean success = false;

  		if (quoteToZObjectMapping != null) {
  			if (String.isNotBlank(quoteToZObjectMapping.Zuora_Object__c) &&
				String.isNotBlank(quoteToZObjectMapping.Quote_Field__c) &&
				String.isNotBlank(quoteToZObjectMapping.Zuora_Object_Field__c)) {

  				//System.debug('Mapping validated');
  				success = true;
  			} else {
  				System.debug('Mapping object contains one or more blank fields');
  			}
  		} else {
  			System.debug('Mapping object passed into validateMappingSetting is null');
  		}

  		return success;
  	}


}


//Test in Developer console 
/*
Set<ID> quotesToSend = new Set<ID>();
quotesToSend.add('a0XZ0000004hGTm');
z_CustomFieldsUpdateQueueableApexClass.updateAccountsFromQuotes(quotesToSend);
*/