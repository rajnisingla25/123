public with sharing class Constants {

    public static final String FEEDBACK = 'Feedback';
    public static final String ARTICLE_FEEDBACK = 'Article Feedback';
    public static final String LINKPOST_ARTICLE = 'LinkPost';
    public static final String GENERIC_ERROR_MSG ='Exception While Processing Request, Please Contact the Administrator';
    public static final String OFFICE_ACCOUNT_TYPE ='Realtor Office';
    public static final String AGENT_ACCOUNT_TYPE ='Realtor Agent';
    public static final String BROKER_ACCOUNT_TYPE='Broker';
    public static final String URGENT_KEYWORDS ='Urgent,Critical,Important';
    public static final String ACCOUNT_SUBTYPE_PROSPECT = 'Prospect';
    public static final String ACCOUNT_SUBTYPE_CUSTOMER = 'Customer';
    public static final String ACCOUNT_SUBTYPE_FORMER_CUSTOMER = 'Former Customer';
    public static final String MOVE_GENERAL_OPEN_QUEUE='Move General - Open';
    public static final String CASE_PRIORITY_MEDIUM='Medium';
    public static final String MOVE_GENERAL_EMAIL_CASE_TYPE='Move General Email';
    public static final String EMAIL_TO_CASE_SUCCESS_TEMPLATE='Email_To_Case_Success_Template';
    public static final String SALESFORCE_URL='https://cs9.salesforce.com/';
    public static final String CASE_CREATED='Case Has Been Created Successfully.';
    public static final String ASSET_CANCELLED_STATUS = 'Cancelled';
    public static final String ASSET_EXPIRED_STATUS = 'Expired';
    public static final String CASE_STATUS_CLOSED = 'Closed';
    public static final String ASSET_ACTIVE_STATUS = 'Active';
    public static final String REGION_ACCOUNT_TYPE='Region';
    public static final String BROKERCOUNCIL_ACCOUNT_TYPE='Broker Council';
    public static final String REALESTCORP_ACCOUNT_TYPE='Real Estate Corporation';
    public static final String ADAGENCY_ACCOUNT_TYPE='Ad Agency';
    public static final String REALESTNETWORK_ACCOUNT_TYPE='Real Estate Network';
    public static final String CORPORATEGROUP_ACCOUNT_TYPE='Corporate Group';
    
    public static final String ASSET_LINE_TYPE_Add = 'Add';
    public static final String ASSET_LINE_TYPE_Credit = 'Credit';
    public static final String ASSET_LINE_TYPE_Buyout = 'Buyout';
    public static final String ASSET_LINE_TYPE_Cancel = 'Cancel';
    public static final String ASSET_LINE_TYPE_Amend = 'Amend';
    
    public static final String CONTACT_RELATIONSHIP_RECORDTYPE_NAME='Contact_Relationship';
    public static final String B2B_ACCOUNT_RECORD_TYPE='B2B';
    public static final String B2C_ACCOUNT_RECORD_TYPE='B2C';
    public static final String EMAIL_ORIGIN ='Email';
    public static final String ASSET_TYPE_FULFILL = 'Fulfill To';
    //public static final String ASSET_TYPE_PARENT = 'Parent';
    public static final String ASSET_TYPE_PARTICIPANT = 'Participant';
    public static final String ASSET_CP_LOGIN_STATUS_ERROR = 'Error';
    public static final String ASSET_CP_LOGIN_STATUS_READY = 'Ready';
    public static final String ASSET_FULLFILL_STATUS_FULFILLED = 'Fulfilled';
    public static final String ASSET_TYPE_PARENT = 'Parent';
    public static final String QUOTE_STATUS_APPROVED ='Approved';
    public static final String QUOTE_STATUS_SIGNED ='Customer Signed';//'Signed';
    public static final String ACCOUNT_BILLING_PREFERENCE_INVOICE ='Invoice';
    public static final String ACCOUNT_BILLING_PREFERENCE_CC_Direct ='CC-Direct';
    public static final String ORDER_STATUS_CREATED = 'CREATED';
    public static final String ORDER_FULFILLMENT_STATUS_PENDING = 'Pending Fulfillment';
    public static final String ORDER_FULFILLMENT_STATUS_MANUAL = 'Manual';
    public static final String PRODUCT_FULFILLMENT_TYPE_MANUAL = 'Manual';
    public static final String ACCOUNT_TEAM_RETENTION_REP_ROLE = 'Retention Rep';
    public static final String ACCOUNT_TEAM_COLLECTIONS_REP_ROLE = 'Collections Rep';
    //public static final String ASSET_FULFILL_TO = 'Retention Rep';
    //Used in Asset & Commission creation (CreateCommissionTriggerHandler.cls)
    public static final String ASSET_TYPE = 'Parent';
    public static final String FULFILLMENT_STATUS = 'Fulfilled';
    public static final String ACTIVE_STATUS = 'Active';
    public static final String LINE_TYPE = 'Backout Credit';
    public static final String BILLING_PERIOD = 'Monthly';
    public static final String BILLING_PERIOD_YEARLY = 'Annual';
    public static final String COMMISSION_CATEGORY = 'CFCB';
    public static final String COMMISSION_CATEGORY_NORMAL = 'NORMAL';
    public static final String COMMISSION_CATEGORY_EMPTY = NULL;
    
    //Used in Record Sharing through Trigger 
    public static final String QueueName = 'Queue';
    
    //Used in AssetRenewalNotificationBatch class
     public static final String RenewalStatus = 'Renew';
     public static final String AssetType = 'Parent';
     public static final String ManualRenewalTemplate = 'Move_BS3_10_Day_Renewal_Notice_Email_Template';
     public static final String AutoRenewalTemplate = 'Move_BS3_30_Day_Renewal_Notice_Email_Template';
     
     //Used in ViewAssetValueController class
     public static final String OrderType = 'Renewal';
     public static final String FulfillmentStatus = 'Fulfilled';
     public static final String OrderStatus = 'Complete';

     //Used in TaskTriggerHandlerManager 
     public Integer LOCK_EXPIRATION_DATE_THRESHOLD = 3;//Constant__c.getInstance('LockExp').SalesLock_ExpDate__c.intValue();    //public static final Integer 
     public Constants(){
     if(!Test.isRunningTest()){
     LOCK_EXPIRATION_DATE_THRESHOLD = Constant__c.getInstance('LockExp').SalesLock_ExpDate__c.intValue();  // Commented by Anup - Not able to create lead test data

       } else {
       LOCK_EXPIRATION_DATE_THRESHOLD = 3;
       }
     }
    
}