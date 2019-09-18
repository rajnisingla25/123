/**
 * Trigger handler class that maps the invoice item adjusments
 * to the right invoice items and invoices.
 * @author Waly K. Ndao (waly.ndao@zuora.com) 
 */
public with sharing class Z_IIA_TriggerHandler {
  
  // Constructor.
  public Z_IIA_TriggerHandler() {
  	
  }

  /**
  * Method called before insert invoice item
  * adjustments. 
  * @param newIIAs the invoice item adjustments to be inserted.
  */
  public void onBeforeInsert(List<Invoice_Item_Adjustment__c> newIIAs) {
  	System.debug('Inserting invoice item adjusment records...');
  	System.debug('The IIAs are: ' + newIIAs);
  	Set<String> ii_z_ids;
  	List<Invoice_Item__c> relIIs;
  	Map<String, Invoice_Item__c> ii_z2s;

  	ii_z_ids = new Set<String>();
  	ii_z2s = new Map<String, Invoice_Item__c>();
  	for (Invoice_Item_Adjustment__c iia : newIIAs) {
  		ii_z_ids.add(iia.Invoice_Item_Zuora_Id__c);
  	}

  	relIIs = [SELECT 
  			Id, 
  			Invoice_Item_Zuora_ID__c,
  			Invoice__c,
        Amount_with_Adjustments__c
  		FROM 		Invoice_Item__c
  		WHERE 	Invoice_Item_Zuora_Id__c in: ii_z_ids];
  	for (Invoice_Item__c ii : relIIs) {
  		ii_z2s.put(ii.Invoice_Item_Zuora_ID__c, ii);
  	}

  	for (Invoice_Item_Adjustment__c iia : newIIAs) {

  		if (ii_z2s.get(iia.Invoice_Item_Zuora_Id__c) != null) {
  			iia.Invoice_Item__c = ii_z2s.get(iia.Invoice_Item_Zuora_Id__c).Id;
  			iia.Invoice__c = ii_z2s.get(iia.Invoice_Item_Zuora_Id__c).Invoice__c;
        ii_z2s.get(iia.Invoice_Item_Zuora_Id__c).Amount_with_Adjustments__c 
          -= iia.Amount__c;
  		} else {
  			System.debug('We were unable to find the invoice item ' 
  				+ iia.Invoice_Item_Zuora_ID__c + '. Adding error.');
  			// No need to send the csv to admin
        // Errors will be displayed on the java program log.
  			iia.addError('The invoice item ' + iia.Invoice_Item_Zuora_ID__c 
  				+ ' for the invoice item adjustment ' 
  				+ iia.Adjustment_Zuora_ID__c 
  				+ ' is not found.');
  		}

  	}

    update ii_z2s.values();

  }

  /**
   * Called before invoice item adjustments are updated.
   * @param newIIAs the invoice item adjustments to be updated.
   */
  public void onBeforeUpdate(List<Invoice_Item_Adjustment__c> newIIAs) {
  	System.debug('Updating invoice item adjustment records...');
  	System.debug('The IIAs are: ' + newIIAs);
  }

}