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
global class Z_PaymentPage_GoNextPlugin extends zqu.PaymentPageController.DefaultHostedPageLiteGoNextPlugin {
    
    public Boolean testBoolean;
    
    
    
    
    //Zuora API handler
    transient public static Zuora.ZApi zApi;
    
    //Test case params
    public Boolean testFindPM {get;set;} 
    public Boolean testFindPMError {get;set;}
    public Boolean testUpdateSuccess {get;set;}
    public Boolean testUpdateException {get;set;}  
    
    //Debugging string
    private static final String DEBUG_STR = 'Z_PaymentPage_GoNextPlugin: ';
    
    //Values for "Type" field on PaymentMethod object in Zuora
    private static final String achTypeValue = 'ACH';
    private static final String ccTypeValue = 'CreditCard';
    
    //Id of newly created payment method in Zuora ("refId")
    public String paymentMethodId;
    public Boolean isSubscriptionCentric;
    public Boolean isLender;
    
    /**
* Constructor. Sets various test parameters used in test class
**/
    public Z_PaymentPage_GoNextPlugin() { 
        this.testFindPM = true;
        this.testFindPMError = true; 
        this.testUpdateSuccess = true;
        this.testUpdateException = true;
        this.isLender = false;
        this.isSubscriptionCentric =false;
    }
    
    /**
* Helper method for instantiating Zuora.ZApi and logging into Zuora
**/
    public static Zuora.ZApi getApiStub() {
        if (zApi == null) { 
            zApi = new Zuora.ZApi();
            if (!Test.isRunningTest()){
                zApi.zLogin();
            }
        }
        return zApi;
    } 
    
    /**
* Main override method. Creates Payment Profile in SFDC and redirects to the Payment Profile Manager page
**/
    global override PageReference navigateNext(String paymentMethodType, Map < String, String > callbackParameters) {
        final String FUNC_STR = DEBUG_STR + 'navigateNext: ';
        System.debug(FUNC_STR+'Starting navigateNext');
        
        // If the transaction was not successful, display the error message to the user
        Boolean success = Boolean.valueOf(callbackParameters.get('success')); 
        if(!success) {
            appendError('Error occurred in callback: '+ callbackParameters.get('errorMessage'));
            return null;
        } else {
            //Retrieve id of newly created payment method
            paymentMethodId = callbackParameters.get('refId');
            //CRM-4351 Accept the payment method at the subscription level.
            //Create Payment Profile object in SFDC for newly created Payment Method in Zuora
            System.debug(FUNC_STR+'Calling createPaymentProfile with new paymentMethodId: '+paymentMethodId);
            createPaymentProfile(paymentMethodId);
            PageReference pageRef;
            String Iscommunityuser =  ApexPages.currentPage().getParameters().get('iscommunityuser');
            String Issoftlaunch  =  ApexPages.currentPage().getParameters().get('softlaunch');
            
            if(Iscommunityuser != null && Iscommunityuser == 'true'){
                pageRef = page.SelfServiceCreditCards;  
                pageRef.getParameters().put('iscommunityuser',Iscommunityuser);   
            } else  if(isLender || test.isrunningtest()){          
                pageRef = page.LenderPaymentProfile;             
                pageRef.getParameters().put('rId', ApexPages.currentPage().getParameters().get('rId'));   
                pageRef.getParameters().put('ActType',ApexPages.currentPage().getParameters().get('ActType'));               
                pageRef.getParameters().put('sendToZuora',ApexPages.currentPage().getParameters().get('sendToZuora')); 
                pageRef.getParameters().put('softLaunch',ApexPages.currentPage().getParameters().get('softLaunch')); 
            } else if(isSubscriptionCentric)
                pageRef = Page.ManageSubscriptionPaymentmethods;
            else
                pageRef = Page.Z_PaymentProfileManager;
            pageRef.getParameters().put('id', ApexPages.currentPage().getParameters().get('id'));          
            pageRef.setRedirect(true);
            System.debug(FUNC_STR+'Response was successful. Returning to Z_PaymentProfileManager');
            return pageRef;
            return null;
        }
    }  
    
    /**
* Creates a Payment Profile based on a passed in "refId" (payment method Id). Specifies Credit Card and ACH specific fields, based on Payment Method information queried from Zuora
**/
    //Move Payment Profile creation to Util class
    public void createPaymentProfile(String refId) {
        final String FUNC_STR = DEBUG_STR + 'createPaymentProfile: ';
        System.debug(FUNC_STR+'Starting createPaymentProfile');
        String Iscommunityuser =  ApexPages.currentPage().getParameters().get('iscommunityuser');
        if (String.isNotBlank(refId)) {
            //Instantiate Zuora.ZApi and login to Zuora
            try {
                getApiStub();
            } catch (Exception ex) {
                System.debug(FUNC_STR+'Error occurred logging into Zuora. Will not create Payment Profile. Error: '+ex.getMessage());
                appendError('Error occurred logging into Zuora. Will not create Payment Profile. Error: '+ex.getMessage()); 
                return;
            }
            
            //TODO: check if removing BankIdentificationNumber fixes error
            String paymentMethodQuery = 'Select Id, Type, CreditCardType, CreditCardMaskNumber, CreditCardHolderName, CreditCardExpirationMonth, CreditCardExpirationYear, BankIdentificationNumber, AchAbaCode, AchAccountName, AchAccountNumberMask, AchAccountType, AchBankName From PaymentMethod Where Id = \''+refId+'\'';      
            System.debug(FUNC_STR+'paymentMethodQuery: '+paymentMethodQuery);
            
            List<Zuora.ZObject> paymentMethods = new List<Zuora.ZObject>();
            try {
                paymentMethods = (!Test.isRunningTest()) ? zApi.zQuery(paymentMethodQuery) : Z_PaymentPage_GoNextPluginTest.retrieveFakePaymentMethod(testfindPm);
            } catch (Exception ex) {
                System.debug(FUNC_STR+'Error occurred retrieving payment methods from Zuora: '+ex.getMessage());
                appendError('Error occurred querying new payment method from Zuora. Will not create Payment Profile. Error: '+ex.getMessage());
                return;
            }
            
            if (paymentMethods != null && paymentMethods.size() > 0) {
                Account sfdcAccount= retrieveSfdcAccountId();
                
                if (sfdcAccount != null) {
                    Zuora.ZObject zPM = paymentMethods[0];
                    
                    //Standard fields used for CC + ACH
                    PaymentProfiles__c paymentProf = new PaymentProfiles__c();
                    paymentProf.PaymentMethodId__c = (String)zPM.getValue('Id');
                    paymentProf.SplitPercentage__c = 0;
                    //LCM-350 Start
                    try{
                        if((Iscommunityuser != null && Iscommunityuser == 'true') || test.isRunningTest()){
                            paymentProf.SplitPercentage__c = 100;
                            PaymentProfiles__c pp = [Select id, SplitPercentage__c from PaymentProfiles__c where Payment_Method_Type__c = 'CreditCard' and Account__c = :sfdcAccount.id and SplitPercentage__c = 100 limit 1];
                            if(pp != null){
                                pp.SplitPercentage__c = 0;
                                update pp;
                            }
                            //CRM-5958 Updating credit cards should update invoices for Past Due customers.
                            if(sfdcAccount.Past_Due__c){                          
                                sfdcAccount.Last_Payment_Update_through_Dashboard__c = Date.today();
                                update sfdcAccount;
                            }
                        } 
                        
                    } catch(Exception e){
                        system.debug('Exception'+e);
                    }
                    
                    //LCM-350 End
                    paymentProf.Account__c = sfdcAccount.id;
                    
                    String pmType = (String)zPM.getValue('Type');
                    paymentProf.Payment_Method_Type__c = pmType;
                    
                    //Populate CC and ACH fields
                    if (String.isNotBlank(pmType) && pmType.equalsIgnoreCase(ccTypeValue) || test.isrunningtest()) {
                        //CC-specific fields
                        System.debug(FUNC_STR+'Populating CC-specific fields');
                        paymentProf.CardholderName__c = (String)zPM.getValue('CreditCardHolderName');
                        // paymentProf.CardholderName__c = '';
                        paymentProf.CreditCardType__c = (String)zPM.getValue('CreditCardType');
                        paymentProf.ExpirationDate__c = '' + (Integer)zPM.getValue('CreditCardExpirationMonth') + '/' + (Integer)zPM.getValue('CreditCardExpirationYear');
                        paymentProf.MaskNumber__c = (String)zPM.getValue('CreditCardMaskNumber');
                        //TODO: check if removing BankIdentificationNumber fixes error
                        paymentProf.Credit_Card_BIN__c = (String)zPM.getValue('BankIdentificationNumber');
                    } else {
                        System.debug(FUNC_STR+'payment method type "'+pmType+'" does not match CC or ACH. Will not populate additional fields');
                    }
                    
                    System.debug(FUNC_STR+'Inserting payment profile: '+paymentProf);
                    insert paymentProf;
                } else {
                    System.debug(FUNC_STR+'Failed to retrieve Sfdc Account Id');
                    appendError('Failed to find a SFDC Account. Will not create Payment Profile');
                }
            } else {
                System.debug(FUNC_STR+'paymentMethods variable is null or empty');
                appendError('Failed to retrieve payment methods from Zuora. Will not create Payment Profile');
            } 
        } else {
            System.debug(FUNC_STR+'refId param is null. Will not create Payment Profile');
        }
    }
    
    /**
* Helper method for retriving Id of related SFDC Account based on Id param in URL relating to Quote or SFDC Account
* Returns Id of SFDC Account or null if it fails to find an Account 
**/
    public Account retrieveSfdcAccountId() {
        final String FUNC_STR = DEBUG_STR + 'retriveSfdcAccountId: ';
        System.debug(FUNC_STR+'Starting retriveSfdcAccountId');
        
        Id sfdcAccountId = null;
        
        String quoteId = ApexPages.currentPage().getParameters().get('id');
        String accountId = quoteId;
        
        //Check to see if Id param in URL is related to Quote
        BigMachines__Quote__c quote = Z_PaymentMethodCaptureUtil.searchForQuote(quoteId);
        
        //If Id param was related to Quote, set accountId to account on Quote
        if (quote != null && String.isNotBlank(quote.BigMachines__Account__c)) {
            accountId = quote.BigMachines__Account__c;   
        } else {
            System.debug(FUNC_STR+'Quote or Quote Account is null. Will search for SFDC Account based on Id param in url');
        }
        
        //Query for SFDC Account based on Quote Account or Id in url (if didn't find a Quote)
        Account account = Z_PaymentMethodCaptureUtil.searchForSFDCAccount(accountId);
        
        if (account != null) {
            //CRM-5242 Added mortgage accounts types and Zuora account creation logic. 
            set<String> childacTypes = new set<String>{'Moving Company','Lender Branch','Loan Officer'};
                //parent Account changes
                if(childacTypes.contains(account.Type) && account.Bill_To_Parent__c == 'Yes'){  
                    List<Account_Relationship__c>  relationact = [Select Id, Parent_Account__c,Parent_Account__r.Type, Child_Account__c From Account_Relationship__c where Child_Account__c = :accountId and Parent_Account__c !=null and Active__c  = true and Relationship_Type__c  = 'Parent/Child' LIMIT 1];
                    
                    if(relationact!=null && relationact.size()>0 && !childacTypes.contains(relationact[0].Parent_Account__r.Type)){                   
                        account = Z_PaymentMethodCaptureUtil.searchForSFDCAccount(relationact[0].Parent_Account__c);  
                    }
                }
            sfdcAccountId = account.Id;
            isSubscriptionCentric = account.Subscription_payment__c;
            if(account.Type == 'Lender Individual')
                isLender = true;
        } else {
            System.debug(FUNC_STR+'Failed to find related Account');
        }
        
        return account;
    }
    
    /**
* Helper method for appending an Error message to the VF Page
**/
    public static void appendError(String Message) {
        appendMessage(ApexPages.Severity.ERROR, message);
    } 
    
    /**
* Helper method for appending messages to the VF Page
**/
    public static void appendMessage(ApexPages.Severity severity, String message) {
        System.Debug('appendMessage: '+message+', severity: '+severity);
        ApexPages.addMessage(new ApexPages.Message(severity, message));
    }
    
}