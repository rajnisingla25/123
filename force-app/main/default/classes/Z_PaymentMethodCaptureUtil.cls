/*    Copyright (c) 2014 Zuora, Inc.
 *
 *   Permission is hereby granted, free of charge, to any person obtaining a copy of 
 *   this software and associated documentation files (the "Software"), to use copy, 
 *   modify, merge, publish the Software and to distribute, and sublicense copies of 
 *   the Software, provided no fee is charged for the Software.  In addition the
 *   rights specified above are conditioned upon the following:
 *
 *   The above copyright notice and this permission notice shall be included in all
 *   copies or substantial portions of the Software.
 *
 *   Zuora, Inc. or any other trademarks of Zuora, Inc.  may not be used to endorse
 *   or promote products derived from this Software without specific prior written
 *   permission from Zuora, Inc.
 *
 *   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *   FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL
 *   ZUORA, INC. BE LIABLE FOR ANY DIRECT, INDIRECT OR CONSEQUENTIAL DAMAGES
 *   (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 *   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 *   ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 *   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.  
 *
 *   IN THE EVENT YOU ARE AN EXISTING ZUORA CUSTOMER, USE OF THIS SOFTWARE IS GOVERNED
 *
 *   BY THIS AGREEMENT AND NOT YOUR MASTER SUBSCRIPTION AGREEMENT WITH ZUORA. 
 */
public without sharing class Z_PaymentMethodCaptureUtil {

    //String used for debugging purposes
    private static final String DEBUG_STR = 'Z_PaymentMethodCaptureUtil: ';

    //Holds connector to zuora apis
    public static Zuora.ZApi zApi {
        get {
            if (zApi == null) {
                System.debug(DEBUG_STR+'Instantiating zApi and logging into Zuora');
                zApi = new Zuora.ZApi();
                if (!Test.isRunningTest()) {
                    zApi.zLogin();
                }
            }
            return zApi;
        } set;
    }


    /**
    * Generic method for querying a single object. Will always return the first record if more than one are found
    * Takes some Id related to the object, the api name of the object, a list of fields to query, and the filter field (defaults to 'Id')
    **/
    public static List<SObject> searchForObject(String objectId, String objectType, Set<String> objectFields, String objectLookupField) {
        final String FUNC_STR = DEBUG_STR + 'searchForObject: ';
        System.debug(FUNC_STR+'Starting searchForObject');

        objectLookupField = (String.isNotBlank(objectLookupField)) ? objectLookupField : 'Id';
        objectFields = (objectFields != null) ? objectFields : new Set<String>();

        List<SObject> retrievedObjects = new List<SObject>();

        if (String.isNotBlank(objectId) && String.isNotBlank(objectType)) {
            //Remove Id field if it exists. We will always query this field
            if (objectFields.contains('Id')) {
                objectFields.remove('Id');
            }
            
            //Object query string
            String objectQuery = 'SELECT Id';
            
            //Cycle through Objects Fields set and build query string
            for (String field : objectFields) {
                objectQuery += ', '+field;
            }
            
            objectQuery += ' FROM '+objectType+' WHERE '+objectLookupField+' = :objectId';
            System.debug(FUNC_STR+'objectQuery: '+objectquery);

            try {
                retrievedObjects = Database.query(objectQuery);
            } catch (Exception ex) {
                System.debug(FUNC_STR+'Exception occurred trying to query objects: '+ex.getMessage());
            }
        } else {
            System.debug(FUNC_STR+'objectId or objectType passed into function is blank');
        }

        System.debug(FUNC_STR+'Returning objects: '+retrievedObjects);
        return retrievedObjects;
    }


    /**
    * Searches for a single CPQ Quote based on its Id
    * Returns CPQ Quote if it exists, or null
    **/
    public static BigMachines__Quote__c searchForQuote(String objectId) {
        final String FUNC_STR = DEBUG_STR + 'searchForQuote: ';
        System.debug(FUNC_STR+'Starting searchForQuote');

        //TODO: Add authorization fields
        Set<String> quoteFields = new Set<String>{
            'BigMachines__Account__c','BigMachines_authorization_amount__c',
            'BigMachines_authorization_date__c','BigMachines_authorization_status__c'
        };
        String objectType = 'BigMachines__Quote__c';
        String quoteLookupField = 'Id';

        System.debug(FUNC_STR+'objectId: '+objectId+', objectType: '+objectType+', quoteLookupField: '+quoteLookupField+', quotefields: '+quotefields);

        List<BigMachines__Quote__c> quotes = (List<BigMachines__Quote__c>)searchForObject(objectId, objectType, quoteFields, quoteLookupField);

        BigMachines__Quote__c quote = (quotes != null && quotes.size() > 0) ? quotes[0] : null;

        System.debug(FUNC_STR+'Returning quote: '+quote);
        return quote;
    }


    /**
    * Searches for a single SFDC Account based on its Id
    * Return Account if it exists, or null
    **/
    public static Account searchForSFDCAccount(String objectId) {
        final String FUNC_STR = DEBUG_STR + 'searchForSFDCAccount: ';
        System.debug(FUNC_STR+'Starting searchForSFDCAccount');

        Set<String> accountFields = new Set<String>();
        String accountType = 'Account';
        String accountLookupField = 'Id';
        //parent Account changes
        accountFields.add('Bill_To_Parent__c');
        accountFields.add('Type');
        accountFields.add('Subscription_payment__c'); 
        accountFields.add('Past_Due__c');
        
        System.debug(FUNC_STR+'objectId: '+objectId+', accountType: '+accountType+', accountLookupField: '+accountLookupField+', accountFields: '+accountFields);

        List<Account> accounts = (List<Account>)searchForObject(objectId, accountType, accountFields, accountLookupField);
       
        Account account = (accounts != null && accounts.size() > 0) ? accounts[0] : null;

        System.debug(FUNC_STR+'Returning account: '+account);
        return account;
    }

    public static String CreateZuoraAccountWithSfdcAccountId(String SfdcId){
         String Zid = '';
        Zuora__CustomerAccount__c sfdcBillingAccount = searchForSFDCBillingAccount(SfdcId);        
        if (sfdcBillingAccount == null) {
             List<Account> accounts = [SELECT Id,Name,Type,Billing_Preference__c,Subscription_payment__c ,Currency_Type__c,  BillingStreet,BillingCity,BillingCountry,BillingPostalCode,BillingState,
                        ShippingStreet,ShippingCity,Bill_To_Parent__c ,ShippingCountry,ShippingPostalCode,ShippingState,
                        Zoura_Account_id__c, Phone, Party_ID__c
                        FROM Account WHERE Id =:SfdcId LIMIT 1];
            
            Z_PaymentMethodCaptureUtil Zacc = new Z_PaymentMethodCaptureUtil();
           Zid =  Zacc.createZuoraAccount(accounts[0]);
        }
        
        
        return Zid;
    }
    /**
    * Searches for a single Billing Account in SFDC based on the Id of its related SFDC Account
    * Returns Billing Account if it exists, or null
    **/
    public static Zuora__CustomerAccount__c searchForSFDCBillingAccount(String objectId) {
        final String FUNC_STR = DEBUG_STR + 'searchForBillingAccount: ';
        System.debug(FUNC_STR+'Starting searchForBillingAccount');

        Set<String> billingAccountFields = new Set<String>{
            'Zuora__Zuora_Id__c'
        };
        String billAccType = 'Zuora__CustomerAccount__c';
        String billAccLookupField = 'Zuora__Account__c';

        System.debug(FUNC_STR+'objectId: '+objectId+', billAccType: '+billAccType+', billAccLookupField: '+billAccLookupField+', billingAccountFields: '+billingAccountFields);

        List<Zuora__CustomerAccount__c> billingAccounts = (List<Zuora__CustomerAccount__c>)searchForObject(objectId, billAccType, billingAccountFields, billAccLookupField);

        Zuora__CustomerAccount__c billingAccount = (billingAccounts != null && billingAccounts.size() > 0) ? billingAccounts[0] : null;

        System.debug(FUNC_STR+'Returning billing account: '+billingAccount);
        return billingAccount;
    }

    /**
    * Searches for a single Account in Zuora where the Id, AccountNumber, or CrmId matches the objectId passed into the method
    * Returns Zuora.ZObject for the Account if it exists, or null. Has test param for creating the ZObject in case of test context
    **/
    public static Zuora.ZObject searchForZuoraAccount(String objectId, Boolean testFindAccount) {
        final String FUNC_STR = DEBUG_STR + 'getZuoraAccount: ';
        System.debug(FUNC_STR+'Starting method');

        Zuora.ZObject billingAccount = null; 

        //Search for Quote if id is not blank
        if (String.isNotBlank(objectId)) {
            System.debug(FUNC_STR+'Searching for Account in Zuora related to id: '+objectId);

            String tempCrm = (objectId.length() == 18) ? objectId.substring(0,15) : objectId;
            System.debug(FUNC_STR+'tempCrm: '+tempCrm);

            //String zoql = 'SELECT Id FROM Account WHERE Id = \'' + objectId + '\' or AccountNumber = \''+objectId+'\' or CrmId LIKE \''+tempCrm+'%\'';
            String zoql = 'SELECT Id FROM Account WHERE Id = \'' + objectId + '\' or AccountNumber = \''+objectId+'\' or CrmId = \''+tempCrm+'\' or CrmId = \''+objectId+'\'' ;
            
            List <Zuora.zObject> billingAccounts = (!Test.isRunningTest()) ? zApi.zquery(zoql) : Z_TestFactory.retrieveTestAccount(testFindAccount);  
            System.debug(FUNC_STR+'Retrieved Accounts from Zuora: '+billingAccounts);

            if (billingAccounts != null && billingAccounts.size() > 0) {
                System.debug(FUNC_STR+'Found a related Billing Account');

                if (String.isNotBlank((String)billingAccounts[0].getValue('Id'))) {
                    System.debug(FUNC_STR+'Retrieved Zuora Account Id "'+(String)billingAccounts[0].getValue('Id')+'" from Zuora Account');
                    billingAccount = billingAccounts[0];
                } else {
                    System.debug(FUNC_STR+'Id on Zuora Account is blank');
                }
            } else {
                System.debug(FUNC_STR+'Failed to find a related Billing Account in SFDC');
            }
        } else {
            System.debug(FUNC_STR+'accid param in URL is blank');
        }

        return billingAccount;      
    }
     /**
* Main method for creating an Account in Zuora in the case one doesn't already exist
* Creates an Account in draft status, creates Bill To and Sold To contact, and updates Account to Active
*
* @exception Z_MPPException if any error occurs creating the new Zuora Account
**/
    //CRM-4351 Accept the payment method at the subscription level.
    public String createZuoraAccount(Account sfdcAccount) {
        final String FUNC_STR =  'createZuoraAccount: ';
        System.debug(FUNC_STR+'Starting createZuoraAccount');
        
        //Retrieve ZObject from helper method. Method throws error if sfdcAccount is null.
        Zuora.ZObject newAcc = createAccountZObject(sfdcAccount);
        
        //Create ZApi and login to Zuora. Method thorws error if login is unsuccessful
        Zuora.ZApi zApi = getZApi();
        System.debug(FUNC_STR+'Logged into Zuora successfully');
        
        //Create Account in Zuora
        List<Zuora.ZApi.SaveResult> createAccResults = new List<Zuora.ZApi.SaveResult>();
        try {
            createAccResults = (!Test.isRunningTest()) ? zApi.zCreate(new List<Zuora.ZObject>{newAcc}) : new List<Zuora.ZApi.SaveResult>{Z_TestFactory.createSaveResult(true)};
                } catch (Exception ex) {
                    throw new Z_MPPException('Draft Account creation failed: '+ex.getMessage(), ex);
                }
        System.debug(FUNC_STR+'Create Account in Zuora results: '+createAccResults);
        
        
        Boolean createAccountSuccess = false;
        String createAccountError = '';
        String accId = '';
        if (createAccResults.size() > 0) {
            Zuora.ZApi.SaveResult createAccResult = createAccResults[0];
            createAccountSuccess = (createAccResult.Success != null) ? createAccResult.Success : false;
            accId = (createAccountSuccess && String.isNotBlank(createAccResult.Id)) ? createAccResult.Id : '';
            createAccountError = (createAccResult.Errors != null && createAccResult.Errors.size() > 0 && String.isNotBlank((String)createAccResult.Errors[0].getValue('Message'))) ? (String)createAccResult.Errors[0].getValue('Message') : '';
        }
        System.debug(FUNC_STR+'Create Account Success: '+createAccountSuccess+', accId: '+accId);
        
        //Create Contacts in Zuora
        if (createAccountSuccess && String.isNotBlank(accId)) {
            try {
                System.debug(FUNC_STR+'Successfully created Draft Account in Zuora. Creating Contacts');
                //Retrieve Contact Relationships
                List<Account_Relationship__c> contactRelationships = [
                    SELECT Contact_to__r.FirstName, Contact_to__r.LastName, Billing_Contact__c, 
                    Contact_Role__c, Zuora_Bill_to_Contact_ID__c, Zuora_Ship_to_Contact_ID__c, Contact_To__r.Email 
                    FROM Account_Relationship__c 
                    WHERE Parent_Account__c = :sfdcAccount.Id AND Active__c = true
                ];
                System.debug(FUNC_STR+'Retrieved contactRelationships: '+contactRelationships);
                Account_Relationship__c billRel = null;
                Account_Relationship__c soldRel = null;
                
                for (Account_Relationship__c rel : contactRelationships) {
                    if (rel.Billing_Contact__c) {
                        billRel = rel;
                    } 
                    if (rel.Contact_Role__c == 'Primary Contact'){
                        soldRel = rel;
                    }
                }
                
                if (billRel == null) {
                    throw new Z_MPPException('Failed to find a Billing Contact Relationship');
                }
                if (soldRel == null) {
                    throw new Z_MPPException('Failed to find a Shipping Contact Relationship');
                }
                
                //Create Account in Zuora
                Zuora.ZObject newBillCon = createBillToContactZObject(accId, sfdcAccount, billRel);
                Zuora.ZObject newSoldCon = createSoldToContactZObject(accId, sfdcAccount, soldRel);
                String BillConSFDCId = billRel.Id;
                String SoldConSFDCId = soldRel.Id;
                List<Zuora.ZApi.SaveResult> createConResults = new List<Zuora.ZApi.SaveResult>();
                try {
                    createConResults = (!Test.isRunningTest()) ? zApi.zCreate(new List<Zuora.ZObject>{newBillCon,newSoldCon}) : new List<Zuora.ZApi.SaveResult>{Z_TestFactory.createSaveResult(true)};
                        } catch (Exception ex) {
                            throw new Z_MPPException('Error occurred trying to create Contacts in Zuora: '+ex.getMessage(),ex);
                        }
                System.debug(FUNC_STR+'Create Contacts in Zuora results: '+createConResults);
                
                String billToId = '';
                String soldToId = '';
                
                Boolean createContactsSuccess = false;
                if (createConResults.size() > 0) {
                    Zuora.ZApi.SaveResult billSaveResult;
                    Zuora.ZApi.SaveResult soldSaveResult;
                    
                    if (createConResults.size() > 1) {
                        billSaveResult = createConResults[0];
                        soldSaveResult = createConResults[1];
                    } else {
                        billSaveResult = createConResults[0];
                        soldSaveResult = createConResults[0];
                    }
                    
                    createContactsSuccess = (billSaveResult != null && soldSaveResult != null) ? (billSaveResult.Success && soldSaveResult.Success) : false;
                    
                    billToId = (createContactsSuccess) ? billSaveResult.Id : '';
                    soldToId = (createContactsSuccess) ? soldSaveResult.Id : '';
                }
                
                System.debug(FUNC_STR+'Create Contacts Success: '+createContactsSuccess);
                
                if (createContactsSuccess && String.isNotBlank(billToId) && String.isNotBlank(soldToId)) {
                    List<Zuora.ZApi.SaveResult> updateAccResults = new List<Zuora.ZApi.SaveResult>();
                    Zuora.ZObject updatedAccount = new Zuora.ZObject('Account');
                    updatedAccount.setValue('Id', accId);
                    updatedAccount.setValue('BillToId', billToId);
                    updatedAccount.setValue('SoldToId', soldToId);
                    updatedAccount.setValue('CRMBillToID__c', BillConSFDCId);
                    updatedAccount.setValue('CRMSoldToID__c', SoldConSFDCId);
                    updatedAccount.setValue('Status', 'Active');
                    
                    try {
                        updateAccResults = (!Test.isRunningTest()) ? zApi.zUpdate(new List<Zuora.ZObject>{updatedAccount}) : new List<Zuora.ZApi.SaveResult>{Z_TestFactory.createSaveResult(true)};
                            } catch (Exception ex) {
                                throw new Z_MPPException('Error occurred trying to create Account in Zuora: '+ex.getMessage(),ex);
                            }
                    System.debug(FUNC_STR+'Update Account in Zuora results: '+updateAccResults);
                    
                    Boolean updateAccountSuccess = false;
                    String updateAccountError = '';
                    if (updateAccResults.size() > 0) {
                        Zuora.ZApi.SaveResult updateAccResult = updateAccResults[0];
                        updateAccountSuccess = (updateAccResult.Success != null) ? updateAccResult.Success : false;
                        updateAccountError = (updateAccResult.Errors != null && updateAccResult.Errors.size() > 0 && String.isNotBlank((String)updateAccResult.Errors[0].getValue('Message'))) ? (String)updateAccResult.Errors[0].getValue('Message') : '';
                    }
                    System.debug(FUNC_STR+'Create Account Success: '+updateAccountSuccess);
                    
                    if (updateAccountSuccess) {
                        
                        //Update SFDC Account with new Zuora Account Id
                        sfdcAccount.Zoura_Account_id__c = accId;
                        try {
                            update sfdcAccount;
                        } catch (Exception ex) {
                            throw new Z_MPPException('Error occurred updating SFDC Account with new Zuora Account Id: '+ex.getMessage(), ex);
                        }
                        
                        //Update SFDC Relationship with new Contact Ids
                        billRel.Zuora_Bill_to_Contact_ID__c = billToId;
                        soldRel.Zuora_Ship_to_Contact_ID__c = soldToId;
                        
                        try {
                            if(billRel != soldRel){
                                update new List<Account_Relationship__c>{billRel,soldRel};
                                    } else {
                                        update new List<Account_Relationship__c>{billRel};
                                            }
                        } catch (Exception ex) {
                            throw new Z_MPPException('Error occurred updating SFDC Contact Relationship with new Zuora Contact Ids: '+ex.getMessage(), ex);
                        }
                        
                        return accId;
                    } else {
                        throw new Z_MPPException('Error occurred trying to update Account to "Active": '+updateAccountError);
                    }
                } else {
                    throw new Z_MPPException('Error occurred creating Contacts for new Account in Zuora');
                }
            } catch (Z_MPPException ex) {
                System.debug(FUNC_STR+'Error occurred after draft account created: '+ex.getMessage()+'. Deleting draft account with id: '+accId);
                if(!Test.isRunningTest()){
                    Boolean deleteAccountResult = deleteZObjects('Account', new List<String>{accId}, zApi);
                }
                throw ex;
            }   
        } else {
            System.debug(FUNC_STR+'Failed to create Draft Account in Zuora: '+createAccountError);
            throw new Z_MPPException('Error occurred creating Draft Account in Zuora: '+createAccountError);
        }   
    }
 /**
* Helper method for deleting objects from Zuora
*
* @param zObjectType String defining the type of Zuora object to delete
* @param zIdsToDelete List of Strings for Zuora Ids of objects to delete
* @param zApi Zuora.ZApi used for making calls to Zuora. Assumes not null and already logged in
* @return Boolean whether or not objects were deleted successfully
**/
    public Boolean deleteZObjects(String zObjectType, List<String> zIdsToDelete, Zuora.ZApi zApi) {
        final String FUNC_STR = DEBUG_STR + 'deleteZObjects: ';
        
        Boolean zDeleteSuccess = false;
        String zDeleteErrorMessage = '';
        List<Zuora.ZApi.DeleteResult> deleteResults = new List<Zuora.ZApi.DeleteResult>();
        
        if (String.isNotBlank(zObjectType) && zIdsToDelete != null && zIdsToDelete.size() > 0 && zApi != null) {
            
            try {
                deleteResults = (!Test.isRunningTest()) ? zApi.zDelete(zObjectType, zIdsToDelete) : new List<Zuora.ZApi.DeleteResult>{Z_TestFactory.createTestDeleteResult(true)};
                    } catch (Exception ex) {
                        System.debug(FUNC_STR+'Error occurred trying to delete object in Zuora: '+ex.getMessage());
                        zDeleteErrorMessage = ex.getMessage();
                        zDeleteSuccess = false;
                        return zDeleteSuccess;
                    }
            
            if (deleteResults.size() > 0) {
                Zuora.ZApi.DeleteResult deleteResult = deleteResults[0];
                zDeleteSuccess = (deleteResult.Success != null) ? deleteResult.Success : false;
                zDeleteErrorMessage = (deleteResult.Errors != null && deleteResult.Errors.size() > 0 && String.isNotBlank((String)deleteResult.Errors[0].getValue('Message'))) ? (String)deleteResult.Errors[0].getValue('Message') : '';
            } else {
                System.debug(FUNC_STR+'Error occurred trying to delete payment method in Zuora. DeleteResult list is empty');
                zDeleteErrorMessage = (String.isBlank(zDeleteErrorMessage)) ? 'DeleteResult list is empty' : zDeleteErrorMessage;
                zDeleteSuccess = false;
                return zDeleteSuccess;
            }
        } else {
            System.debug(FUNC_STR+'Invalid params. zObjectType: '+zObjectType+', zIdsToDelete: '+zIdsToDelete+', zApi: '+zApi);
        }
        
        System.debug(FUNC_STR+'Delete Status: '+zDeleteSuccess+', Delete error message: '+zDeleteErrorMessage);
        return zDeleteSuccess;
    }
    
    /**
* Helper method for creating Zuora.ZApi object and logging into Zuora
* 
* @exception Z_MPPException if exception occurs logging into Zuora
* @return Zuora.ZApi
**/
    public Zuora.ZApi getZApi() {
        Zuora.ZApi zApi = new Zuora.ZApi();
        
        try {
            Zuora.ZApi.LoginResult loginResult = (!Test.isRunningTest()) ? zApi.zLogin() : new Zuora.ZApi.LoginResult();  
        } catch (Exception ex) {
            throw new Z_MPPException('Error occurred logging in to Zuora: '+ex.getMessage(), ex);
        }
        
        return zApi;
    }
    
    /**
* Helper method for creating an Account Zuora.ZObject based off a specified SFDC Account.
* Sets new Zuora Account fields based on Billing Preference on SFDC Account
* If Billing Preference is null, assumes "Invoice" use case
* 
* @param sfdcAccount SFDC Account to retrieve information from for new Zuora Account
* @exception Z_MPPException if sfdcAccount param is null or is missing a Currency Type
* @return Zuora.ZObject ZObject representing new Zuora Account
**/
    public Zuora.ZObject createAccountZObject(Account sfdcAccount) {
        final String FUNC_STR = DEBUG_STR + 'createAccountZObject: ';
        
        if (sfdcAccount == null) {
            throw new Z_MPPException('Salesforce Account passed to createAccountZObject is null');
        }
        
        sfdcAccount = [select Id, Name,Subscription_payment__c, Type, Currency_Type__c, Billing_Preference__c, Phone, Party_ID__c from Account where Id = :sfdcAccount.Id];
        
        //Find Account information from SFDC Account
        Zuora.ZObject newAccount = new Zuora.ZObject('Account');
        newAccount.setValue('Name', sfdcAccount.Name);
        newAccount.setValue('CrmId', sfdcAccount.Id);
        //LEAP-8525
        newAccount.setValue('AccountNumber',sfdcAccount.Party_ID__c);
        newAccount.setValue('Status', 'Draft');
        
        if(sfdcAccount.Type == 'Agent Team' || sfdcAccount.Type == 'Realtor Agent'){
            newAccount.setValue('Account_Type__c', 'Agent');            
        }else {            
            newAccount.setValue('Account_Type__c', 'Broker');
        }
        
        
        //Read currency from SFDC Account. Throw exception if blank
        if (String.isBlank(sfdcAccount.Currency_Type__c)) {
            throw new Z_MPPException('Currency Type on Salesforce Account is empty');
        } else {
            newAccount.setValue('Currency', sfdcAccount.Currency_Type__c);
        }
        
        if (String.isBlank(sfdcAccount.Billing_Preference__c) || sfdcAccount.Billing_Preference__c.equalsIgnoreCase('Invoice-CC')) {
            //Invoice use case
            newAccount.setValue('PaymentTerm', 'Due Upon Receipt');
            newAccount.setValue('Batch', 'Batch2');
            newAccount.setValue('BillCycleDay',1);
        } else if (sfdcAccount.Billing_Preference__c.equalsIgnoreCase('Invoice-Terms')) {
            //Invoice-Terms use case
            newAccount.setValue('PaymentTerm', 'Net 30');
            newAccount.setValue('Batch', 'Batch2');
            newAccount.setValue('BillCycleDay',1);
        } else if (sfdcAccount.Billing_Preference__c.equalsIgnoreCase('CC-Direct')) {
            //Credit Card Direct use case
            newAccount.setValue('PaymentTerm', 'Due Upon Receipt');
            newAccount.setValue('Batch', 'Batch1');
            newAccount.setValue('BillCycleDay',System.today().day());
        } else if (sfdcAccount.Billing_Preference__c.equalsIgnoreCase('Tiger')) {
            //Tiger use case
            newAccount.setValue('PaymentTerm', 'Due Upon Receipt');
            newAccount.setValue('Batch', 'Batch3');
            newAccount.setValue('BillCycleDay',1);
        } else if (sfdcAccount.Billing_Preference__c.equalsIgnoreCase('arrears-invoice')) {
            //arrears-invoice use case
            newAccount.setValue('PaymentTerm', 'Net 30');
            newAccount.setValue('Batch', 'Batch5');
            newAccount.setValue('BillCycleDay',1);
        }else if (sfdcAccount.Billing_Preference__c.equalsIgnoreCase('arrears-cc')) {
            //arrears-cc use case
            newAccount.setValue('PaymentTerm', 'Due Upon Receipt');
            newAccount.setValue('Batch', 'Batch5');
            newAccount.setValue('BillCycleDay',1);
        }else {
            //Else use case
            newAccount.setValue('PaymentTerm', 'Due Upon Receipt');
            newAccount.setValue('Batch', 'Batch2');
            newAccount.setValue('BillCycleDay',1);
            
        }
        if(sfdcAccount.Type == 'Moving Company' || sfdcAccount.Type == 'Moving Corporation'){            
            newAccount.setValue('Account_Type__c', sfdcAccount.Type);            
            newAccount.setValue('Batch', 'Batch7');
            newAccount.setValue('BillCycleDay',1);          
            newAccount.setValue('PaymentTerm', 'Due Upon Receipt');  
            newAccount.setValue('InvoiceTemplateId', System.Label.Z_InvoiceTemplateId);
            
            if (sfdcAccount.Billing_Preference__c.equalsIgnoreCase('Invoice-Check') || sfdcAccount.Billing_Preference__c.equalsIgnoreCase('Invoice-Terms')){
                newAccount.setValue('PaymentTerm', 'Net 30'); 
            }
        }
        System.Debug('SFDC Billing Pref: ' + sfdcAccount.Billing_Preference__c);
        newAccount.setValue('Billing_Preference__c', sfdcAccount.Billing_Preference__c);
        if(sfdcAccount.Subscription_payment__c == true){
          newAccount.setValue('Subscription_payment__c', 'True');
       }
        //LCM-109
        if(sfdcAccount.Type == 'Lender Individual' || test.isrunningtest()){
            newAccount.setValue('Account_Type__c', sfdcAccount.Type); 
            newAccount.setValue('AutoApplyCreditBalances__c', 'False');  
            //newAccount.setValue('Subscription_payment__c', 'True');
            newAccount.setValue('Batch', 'Batch10');           
        }
        //CRM-5242 Added mortgage accounts types and Zuora account creation logic. 
         Set<String> lenderAcctype = new Set<String>{'Lender Parent','Lender Branch', 'Loan Officer'};
         if(lenderAcctype.contains(sfdcAccount.Type) || test.isrunningtest()){
            newAccount.setValue('Account_Type__c', sfdcAccount.Type);            
            newAccount.setValue('Batch', 'Batch15');
            newAccount.setValue('BillCycleDay',1);          
            newAccount.setValue('PaymentTerm', 'Due Upon Receipt');  
            newAccount.setValue('InvoiceTemplateId', System.Label.Z_MRCTemplate);
             //CRM-6026
            if (sfdcAccount.Billing_Preference__c.equalsIgnoreCase('Invoice-Check') || sfdcAccount.Billing_Preference__c.equalsIgnoreCase('Invoice-Terms')){
                newAccount.setValue('PaymentTerm', 'Net 30'); 
            }      
        }
        //LCM-109 end
        System.Debug('newAccount: ' + newAccount);
        
        
        return newAccount;
    }
    
    /**
* Helper method for creating a Bill To Contact Zuora.ZObject
**/
    public Zuora.ZObject createBillToContactZObject(String zAccId, Account sfdcAccount, Account_Relationship__c rel) {
        final String FUNC_STR = DEBUG_STR + 'createBillToContactZObject: ';
        return createContactZObject(true, zAccId, sfdcAccount, rel);
    }
    
    /**
* Helper method for creating a Sold To Contact Zuora.ZObject
**/
    public Zuora.ZObject createSoldToContactZObject(String zAccId, Account sfdcAccount, Account_Relationship__c rel) {
        final String FUNC_STR = DEBUG_STR + 'createSoldToContactZObject: ';
        return createContactZObject(false, zAccId, sfdcAccount, rel);
    }
    public class Z_MPPException extends Exception {}
    /**
* Helper method for creating a Contact Zuora.ZObject based on "isBillTo" flag
**/
    public Zuora.ZObject createContactZObject(Boolean isBillTo, String zAccId, Account sfdcAccount, Account_Relationship__c rel) {
        final String FUNC_STR = DEBUG_STR + 'createContactZObject: ';
        Zuora.ZObject newContact = new Zuora.ZObject('Contact');
        
        //Assume bill to contact if boolean is null
        isBillTo = (isBillTo == null) ? true : isBillTo;
        
        if (String.isBlank(zAccId) || sfdcAccount == null || rel == null || String.isBlank(rel.Contact_to__r.FirstName) || String.isBlank(rel.Contact_to__r.LastName)) {
            System.debug('SfdcAccount: ' + sfdcAccount);
            System.debug('rel: ' + rel);
            System.debug(' first + last: ' + rel.Contact_to__r.FirstName + rel.Contact_to__r.LastName); 
            throw new Z_MPPException('Zuora Account Id, SFDC Account, SFDC Relationship, or Contact First + Last Name is null');
            
        } else {
            newContact.setValue('AccountId', zAccId);
        }
        
        if (String.isNotBlank(rel.Contact_to__r.FirstName)) {
            newContact.setValue('FirstName', rel.Contact_to__r.FirstName);
        }
        if (String.isNotBlank(rel.Contact_to__r.LastName)) {
            newContact.setValue('LastName', rel.Contact_to__r.LastName);
        }
        if(String.isNotBlank(rel.Contact_to__r.Email)){
            newContact.setValue('WorkEmail', rel.Contact_To__r.Email);
        }
        if(String.isNotBlank(sfdcAccount.Phone)){
            newContact.setValue('WorkPhone', sfdcAccount.Phone);
        }
        
        if (isBillTo) {
            if (String.isNotBlank(sfdcAccount.BillingStreet)) {
                newContact.setValue('Address1', sfdcAccount.BillingStreet);
            }
            if (String.isNotBlank(sfdcAccount.BillingCity)) {
                newContact.setValue('City', sfdcAccount.BillingCity);
            }
            if (String.isNotBlank(sfdcAccount.BillingCountry)) {
                newContact.setValue('Country', sfdcAccount.BillingCountry);
            }
            if (String.isNotBlank(sfdcAccount.BillingPostalCode)) {
                newContact.setValue('PostalCode', sfdcAccount.BillingPostalCode);
            }
            if (String.isNotBlank(sfdcAccount.BillingState)) {
                newContact.setValue('State', sfdcAccount.BillingState);
            }
        } else {
            //TODO: if these are blank, do we read from billing contact?
            if (String.isNotBlank(sfdcAccount.ShippingStreet)) {
                newContact.setValue('Address1', sfdcAccount.ShippingStreet);
            }
            if (String.isNotBlank(sfdcAccount.ShippingCity)) {
                newContact.setValue('City', sfdcAccount.ShippingCity);
            }
            if (String.isNotBlank(sfdcAccount.ShippingCountry)) {
                newContact.setValue('Country', sfdcAccount.ShippingCountry);
            }
            if (String.isNotBlank(sfdcAccount.ShippingPostalCode)) {
                newContact.setValue('PostalCode', sfdcAccount.ShippingPostalCode);
            }
            if (String.isNotBlank(sfdcAccount.ShippingState)) {
                newContact.setValue('State', sfdcAccount.ShippingState);
            }
        }
        
        return newContact; 
    }

}