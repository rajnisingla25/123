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
global class Z_PaymentPage_IHostedPageLitePlugin implements zqu.PaymentPageController.IHostedPageLitePlugin {

    private final String DEBUG_STR = 'Z_PaymentPage_IHostedPageLitePlugin: ';

    //Holds Id of various objects page deals with 
    private Id quoteId;
    private BigMachines__Quote__c quote;
    public Boolean hasQuote {
        get {
            if (String.isNotBlank(quoteId) && quote != null) {
                return true;
            } else {
                return false;
            }
        }
    }

    private Id sfdcBillingAccountId; 
    private String sfdcAccountId; 
    private Boolean ismovingchild; 
    private Zuora__CustomerAccount__c sfdcBillingAccount;
    public Boolean hasSfdcBillingAccount {
        get {
            if (String.isNotBlank(sfdcBillingAccountId) && sfdcBillingAccount != null) {
                return true; 
            } else {
                return false;
            }
        }
    }

    private String zuoraAccountId; 
    private Zuora.ZObject zuoraAccount;
    public Boolean hasAccountInZuora {
        get {
            if (String.isNotBlank(zuoraAccountId) && zuoraAccount != null) {
                return true;
            } else {
                return false;
            }
        }
    }

    public Boolean testFindAccount {get;set;}


    public Z_PaymentPage_IHostedPageLitePlugin() {
        this.testFindAccount = true;
        this.ismovingchild = false;
    }


    /**
    * Plugin method for setting default parameters in the IFrame. Currently only defaults 'field_accountId'
    * Returns a string map of fields to values
    **/
    global Map < String, String > getAdditionalParameters(String paymentMethodType) {
        final String FUNC_STR = DEBUG_STR + 'getAdditionalParameters: ';
        System.debug(FUNC_STR+'Starting getAdditionalParameters');

        Map<String,String> defaultValues = new Map<String,String>();

        defaultValues = setAddressFields(defaultValues);

        defaultValues = setExistingAccount(defaultValues);

        //Whitelist countries to USA and CAN
        defaultValues = setWhitelistCountries(defaultValues);
        
        // CRM-2311 - Make creditCardHolderName name as blank if its from Quote
        //if (hasQuote) {  // Commented hasquote filter as part of CRM-3400
            defaultValues.put('creditCardHolderName','');
            System.Debug('Has Quote - creditCardHolderName is Blank now');
        //}
        // CRM-2311 - End
        
        System.debug(FUNC_STR+'returning defaultValues: '+defaultValues);
        
        return defaultValues;
    }


    /**
    * This method populates address fields for the IFrame
    * Reads in values from the SFDC Account billing fields
    **/
    private Map<String,String> setAddressFields(Map<String,String> defaultValues) {
        final String FUNC_STR = DEBUG_STR + 'setAddressFields: ';
        System.debug(FUNC_STR+'Starting setAddressFields');

        String ID = ApexPages.currentPage().getParameters().get('id');
        defaultValues = (defaultValues != null) ? defaultValues : new Map<String,String>();
       
        List<BigMachines__Quote__c> bMQs = [Select Id, BigMachines__Account__c from BigMachines__Quote__c where Id = :ID];
        Account account = new Account();
        
         Map<String, String> stateMap = new Map<String, String>{'AL' => 'Alabama','AK' => 'Alaska','AZ' => 'Arizona',
            'AR' => 'Arkansas','CA' => 'California','CO' => 'Colorado','CT' => 'Connecticut','DE' => 'Delaware',
            'DC' => 'District of Columbia','FL' => 'Florida','GA' => 'Georgia','HI' => 'Hawaii','ID' => 'Idaho','IL' => 'Illinois',
            'IN' => 'Indiana','IA' => 'Iowa','KS' => 'Kansas','KY' => 'Kentucky','LA' => 'Louisiana','ME' => 'Maine',
            'MD' => 'Maryland','MA' => 'Massachusetts','MI' => 'Michigan','MN' => 'Minnesota','MS' => 'Mississippi',
            'MO' => 'Missouri','MT' => 'Montana','NE' => 'Nebraska','NV' => 'Nevada','NH' => 'New Hampshire',
            'NJ' => 'New Jersey','NM' => 'New Mexico','NY' => 'New York','NC' => 'North Carolina', 'ND' => 'North Dakota',
            'OH' => 'Ohio','OK' => 'Oklahoma','OR' => 'Oregon','PA' => 'Pennsylvania','RI' => 'Rhode Island',
            'SC' => 'South Carolina','SD' => 'South Dakota','TN' => 'Tennessee','TX' => 'Texas',
            'UT' => 'Utah','VT' => 'Vermont','VA' => 'Virginia','WA' => 'Washington','WV' => 'West Virginia',
            'WI' => 'Wisconsin','WY' => 'Wyoming','PR' => 'Puerto Rico'};

        If(bMQs.size() == 0){
                List<Account> accs = [Select Id, Type,Bill_To_Parent__c, BillingStreet, BillingCountry, BillingCity, BillingState, BillingPostalCode, Name from Account where Id = :ID];   
                if(accs.size() != 0){
                    account = accs[0];
                }
        }else{
            String AccId = bMQs[0].BigMachines__Account__c;
            List<Account> accs = [Select Id, Type, BillingStreet,Bill_To_Parent__c, BillingCountry, BillingCity, BillingState, BillingPostalCode, Name from Account where Id = :AccId];   
                if(accs.size() != 0){
                    account = accs[0];
                }
        }
        //CRM-5242 Added mortgage accounts types and Zuora account creation logic.
          set<String> childacTypes = new set<String>{'Moving Company','Lender Branch','Loan Officer'};
        //parent Account changes
        if(childacTypes.contains(account.Type)&& account.Bill_To_Parent__c == 'Yes'){
             List<Account_Relationship__c>  relationact = [Select Id, Parent_Account__c,Parent_Account__r.Type, Child_Account__c From Account_Relationship__c where Child_Account__c = :account.Id and Parent_Account__c !=null and Active__c  = true and Relationship_Type__c  = 'Parent/Child' LIMIT 1];
             if(relationact!=null && relationact.size()>0 && !childacTypes.contains(relationact[0].Parent_Account__r.Type)){            
                   List<Account> accs = [Select Id, Type, BillingStreet,Bill_To_Parent__c, BillingCountry, BillingCity, BillingState, BillingPostalCode, Name from Account where Id = :relationact[0].Parent_Account__c];  
                  if(accs.size() != 0){
                    account = accs[0];
                    this.sfdcAccountId =  accs[0].Id;
                    this.ismovingchild =true;
                }
             }           
        }
        List<Account_Relationship__c> contactRelationships = [
                    SELECT Name, Contact_to__r.FirstName, Contact_to__r.LastName, Billing_Contact__c, 
                        Contact_Role__c, Zuora_Bill_to_Contact_ID__c, Zuora_Ship_to_Contact_ID__c 
                    FROM Account_Relationship__c 
                    WHERE Parent_Account__c = :account.Id AND Active__c = true
                ];
                
        Account_Relationship__c billRel = null;
        
        for (Account_Relationship__c rel : contactRelationships) {
                    if (rel.Billing_Contact__c) {
                        billRel = rel;
                    } 
        }
        System.Debug('accountType: ' + account.Type);
        System.Debug('billrel: ' + billrel);
        if(account.Type == 'Realtor Agent' || billRel == null){                
            defaultValues.put('creditCardHolderName',(String)account.Name);
            System.Debug('Realtor');
        } else{
            defaultValues.put('creditCardHolderName',(String)billRel.Contact_to__r.FirstName + ' ' + (String)billRel.Contact_to__r.LastName);
            System.Debug('Other');
        }
        defaultValues.put('creditCardAddress1',(String)account.BillingStreet);
        defaultValues.put('creditCardCountry', (String)account.BillingCountry);
        defaultValues.put('creditCardCity', (String)account.BillingCity);
        if(account.BillingState.length() == 2){
            String stateValue = stateMap.get((String)account.BillingState);
            if(stateValue != null){
                defaultValues.put('creditCardState', stateValue);
            }
        } else {
        defaultValues.put('creditCardState', (String)account.BillingState);
        }
        defaultValues.put('creditCardPostalCode', (String)account.BillingPostalCode);
		
        return defaultValues;
    }

    /**
    * This method populates the country whitelist for the IFrame to only show select countries (US and CAN)
    * Reads in list of available countries from Zuora_Payment_Profile_Allowed_Country__c custom setting
    **/
    private Map<String,String> setWhitelistCountries(Map<String,String> defaultValues) {
        final String FUNC_STR = DEBUG_STR + 'setWhitelistCountries: ';
        System.debug(FUNC_STR+'Starting setWhitelistCountries');

        defaultValues = (defaultValues != null) ? defaultValues : new Map<String,String>();

        //List of all Country settings
        List<Zuora_Payment_Profile_Allowed_Country__c> allCountries = Zuora_Payment_Profile_Allowed_Country__c.getall().values();
        
        //List of Active Country ISO Codes
        Set<String> allowedCountries = new Set<String>();
        
        //Filter allowedCountries to only be Active Records
        for (Zuora_Payment_Profile_Allowed_Country__c country : allCountries) {
            if (country.Active__c && String.isNotBlank(country.Country_ISO_Code__c)) {
                System.debug(FUNC_STR+'Country "'+country.Name+'" is Active and has ISO code. Adding to list');
                allowedCountries.add(country.Country_ISO_Code__c);
            } else {
                System.debug(FUNC_STR+'Country "'+country.Name+'" is not Active or missing ISO code. Filtering from list');
            }
        }

        String countryList = '';

        List<String> allowedCountryList = new List<String>(allowedCountries);

        for (Integer i = 0; i < allowedCountryList.size(); i++) {
            if (i == 0) {
                countryList += allowedCountryList[i];
            } else {
                countryList += ','+allowedCountryList[i];
            }
        }

        System.debug(FUNC_STR+'List of valid countries: '+countryList);
        defaultValues.put('countryWhiteList',countryList);
        return defaultValues;
    }


    /**
    * This method attempts to find a related Zuora Account Id from either the CPQ Quote, Billing Account in SFDC, or directly on an Account in Zuora
    * If successful, it will populate "field_accountId" and returns the map of Strings
    **/
    private Map<String,String> setExistingAccount(Map<String,String> defaultValues) {
        final String FUNC_STR = DEBUG_STR + 'setExistingAccount: ';
        System.debug(FUNC_STR+'Starting setExistingAccount');

        defaultValues = (defaultValues != null) ? defaultValues : new Map<String,String>();
        final String fieldAccountKey = 'field_accountId';

        if (searchForQuote()) {
            System.debug(FUNC_STR+'Found CPQ Quote');

            if (searchForSFDCBillingAccount(this.quote.BigMachines__Account__c) && hasSfdcBillingAccount) {
                System.debug(FUNC_STR+'Found Billing Account');

                defaultValues.put(fieldAccountKey, this.sfdcBillingAccount.Zuora__Zuora_Id__c);
            } else {
                System.debug(FUNC_STR+'Failed to find Billing Account. Will search Zuora for crmId "'+this.quote.BigMachines__Account__c+'"');

                if (searchForZuoraAccount(this.quote.BigMachines__Account__c)) {
                    System.debug(FUNC_STR+'Found Account in Zuora: '+(String)this.zuoraAccount.getValue('Id'));

                    defaultValues.put(fieldAccountKey, (String)this.zuoraAccount.getValue('Id'));
                } else {
                    System.debug(FUNC_STR+'Failed to find Account in Zuora with crmId "'+this.quote.BigMachines__Account__c+'". Will not set field_accountId');

                    //TODO: handle error: 
                }
            }
        } else {
            String tempId = ApexPages.currentPage().getParameters().get('id');

            if (String.isNotBlank(tempId) && searchForSFDCBillingAccount(tempId) && hasSfdcBillingAccount) {
                System.debug(FUNC_STR+'Found Billing Account');

                defaultValues.put(fieldAccountKey, this.sfdcBillingAccount.Zuora__Zuora_Id__c);
            } else {
                //TODO: handle error
            }
        }

        return defaultValues;
    }


    /**
    * This method looks at the 'id' param in the URL and attempts to find a related Quote in SFDC. 
    * If successful, it will set this.quote and this.quoteId, and return true. Else returns false
    **/
    public Boolean searchForQuote() {
        final String FUNC_STR = DEBUG_STR + 'searchForQuote: ';
        System.debug(FUNC_STR+'Starting searchForQuote');

        String quoteId = ApexPages.currentPage().getParameters().get('id');
        System.debug(FUNC_STR+'id param in URL: '+quoteId);
        Boolean foundQuote = false;

        this.quote = Z_PaymentMethodCaptureUtil.searchForQuote(quoteId);

        if (quote != null) {
            System.debug(FUNC_STR+'Found Quote based on Id: '+quoteId);
            foundQuote = true;
            this.quoteId = quote.Id;
        } else {
            System.debug(FUNC_STR+'Failed to find Quote based on Id: '+quoteId);
        }

        return foundQuote;
    }


    /**
    * This method looks at the 'accId' param in the URL and attempts to find a related Billing Account in SFDC. 
    * If successful, it will set this.sfdcBillingAccount and this.sfdcBillingAccountId, and return true. Else returns false
    **/
    public Boolean searchForSFDCBillingAccount(String accId) {
        final String FUNC_STR = DEBUG_STR + 'searchForSFDCBillingAccount: ';
        System.debug(FUNC_STR+'Starting searchForSFDCBillingAccount');

        Boolean foundAccount = false;
          if(ismovingchild){
            accId = sfdcAccountId;
          }
        this.sfdcBillingAccount = Z_PaymentMethodCaptureUtil.searchForSFDCBillingAccount(accId);

        if (sfdcBillingAccount != null) {
            System.debug(FUNC_STR+'Found Billing Account based on Id: '+accId);
            foundAccount = true;
            this.sfdcBillingAccountId = sfdcBillingAccount.Id;
        } else {
            System.debug(FUNC_STR+'Failed to find Billing Account based on Id: '+accId);
        }

        return foundAccount;
    }


    /**
    * This method searches for an Account in Zuora based on its crmId matching the Id passed into the method (SFDC Account Id)
    * If successful, sets this.zuoraAccount and this.zuoraAccountId, and return true. Else returns false
    **/
    public Boolean searchForZuoraAccount(String sAccId) {
        final String FUNC_STR = DEBUG_STR + 'searchForZuoraAccount: ';
        System.debug(FUNC_STR+'Starting searchForZuoraAccount');

        Boolean foundAccount = false;
          if(ismovingchild){
            sAccId = sfdcAccountId;
          }
        this.zuoraAccount = Z_PaymentMethodCaptureUtil.searchForZuoraAccount(sAccId, testFindAccount);

        if (zuoraAccount != null) {
            System.debug(FUNC_STR+'Found Account in Zuora based on Id: '+sAccId);
            foundAccount = true;
            this.zuoraAccountId = (String)zuoraAccount.getValue('Id');
        } else {
            System.debug(FUNC_STR+'Failed to find Account in Zuora based on Id: '+sAccId);
        }

        return foundAccount;
    }

}