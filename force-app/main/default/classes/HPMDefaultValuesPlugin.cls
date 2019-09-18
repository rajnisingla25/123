global class HPMDefaultValuesPlugin implements zqu.PaymentPageController.IHostedPageLitePlugin {
    global Map < String, String > getAdditionalParameters(String paymentMethodType) {
        Map < String, String > defaultValues = new Map < String, String >();
        // Default client parameters
        if (System.currentPageReference().getParameters().containsKey('field_accountId'))
            defaultValues.put('field_accountId', System.currentPageReference().getParameters().get('field_accountId'));
        defaultValues.put('retainValues', 'true');

        String ID = ApexPages.currentPage().getParameters().get('field_passthrough2');
        System.debug('id: '+id);
        defaultValues = (defaultValues != null) ? defaultValues : new Map<String,String>();
       
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
       
        List<Account> accs = [Select Id, Type, BillingStreet, BillingCountry, BillingCity, BillingState, BillingPostalCode, Name from Account where Id = :ID];   
        if(accs.size() != 0){
            account = accs[0];
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
            //defaultValues.put('creditCardHolderName',(String)account.Name);
            //CRM-3400 - Populate creditCardHolderName blank for Billing Account Manager
            defaultValues.put('creditCardHolderName','');
            System.Debug('Realtor');
        } else{
            //defaultValues.put('creditCardHolderName',(String)billRel.Contact_to__r.FirstName + ' ' + (String)billRel.Contact_to__r.LastName);
            //CRM-3400 - Populate creditCardHolderName blank for Billing Account Manager
            defaultValues.put('creditCardHolderName','');
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
}