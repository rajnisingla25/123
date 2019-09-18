/*
Class: class to store constants which is needed during SMCI project.
Created by: Varun
Created date : 12/20/2018
*/
public class SFMC_Constants {
    //this is for Engagement activity
    public static final String ENGAGEMENT_ACTIVITY_TYPE_CHANNEL_FORM = 'Form Submission';
    public static final String ENGAGEMENT_ACTIVITY_TYPE_TYPE_SUBMISSION = 'Submission';
    public static final String ENGAGEMENT_ACTIVITY_TYPE_TYPE_LANDING_PAGE = 'Landing page';
    public static final String ENGAGEMENT_ACTIVITY_TYPE_CHANNEL_FORM_SUBMISSION = 'Form Submission';
    public static final String ENGAGEMENT_ACTIVITY_TYPE_CHANNEL_WEBINAR = 'Goto Webinar';
    public static final String ENGAGEMENT_ACTIVITY_TYPE_EVENTS = 'Events';
    public static final String ENGAGEMENT_ACTIVITY_TYPE_WEBCONTENT = 'WebContent';
    public static final String ENGAGEMENT_ACTIVITY_TYPE_SMS = 'SMS';
    
    //Lead Update
    public static final String ENGAGEMENT_ACTIVITY_LEAD_UPDATE = 'EngagementActivityLeadUpdate';
    
    // this is for Lead Gen
    public static final String[] LEAD_OPEN_STATUSES = new String[]{'In Progress', 'New'};
    public static final String NURTURE_LEAD_TYPE = 'Nurture Lead Type';
    public static final String NURTURE_LEAD = 'Nurture Lead';
    public static final String LEAD_REJECTED_STATUS = 'Rejected';
    public static final String LEAD_REJECTED_REASON_CLOSED_DUE_TO_NEW_SUBMISSION = 'Closed due to new submission';
    public static final String LEAD_ORIGIN_MARKETING_REFERRAL = 'Marketing Referral';
    public static final string LEAD_SOCIAL_MEDIA_RECORD_TYPE = 'Social Media';
    public static final string LEAD_SOURCE_LINKEDIN = 'LinkedIn';
    
    //Batch for Lead Update on engagement activities
    public static final String LEAD_UPDATE_BATCH_NAME = 'SFMC_EngagementActivityLeadUpdateBatch';
    
    //this is for Lead score
    public static final String LEAD_SCORE_BATCH = 'LeadScoreBatch';
    public static final List<String> LEAD_SCORE_BATCH_NAME = new List<String>{LEAD_UPDATE_BATCH_NAME,'SFMC_LeadScoreCalculationBatch'};
        public static final List<String> BATCH_OPEN_STATUSES = new List<String>{'Preparing','Processing'}; // not adding queued/holding status because if we schedule a batch then it always remain in queued status.
            public static final integer HEAP_LIMIT_THRESHOLD = 10000; //10kb
    public static final String BATCH_APEX = 'BatchApex';
    
    //this is for preference 
    public static final String YES = 'Yes';
    public static final String NO = 'No';
    public static final String BRAND_RDC = 'rdc';
    public static final String BRAND_TOP_PRODUCER = 'topProducer';
    public static final String BRAND_EVENTS = 'events';
    public static final String RDC = 'RDC';
    public static final String TOP_PRODUCER = 'Top Producer';
    public static final String REALTOR_COM = 'Realtor.com';
    public static final String BUSINESS_UNIT_REALTOR = 'Realtor.com-Landing Page';
    public static final String BUSINESS_UNIT_TOP_PRODUCER = 'Top Producer-Landing page';
    
    
    //this is for Contact Method
    public static final String TYPE_EMAIL = 'Email';
    public static final String TYPE_PHONE = 'Phone';
    
    //this is for landing page
    public static final String CONTACT_METHOD_ID = 'contactMethodId';
    public static final String CAMPAIGN_ID = 'campaignId';
    public static final String ACCOUNT_ID = 'accountId';
    public static final String UBERFLIP_FORM = 'Uberflip form';
    public static final String UTM_SOURCE = 'utm_source';
    public static final String UTM_MEDIUM = 'utm_medium';
    public static final String UTM_CONTENT = 'utm_content';
    public static final String UTM_CAMPAIGN = 'utm_campaign';
    public static final String UTM_CAMPAIGN_ID = 'utm_campaign_id';
    public static final String LEAD_ORIGIN = 'lead_origin';
	public static final String PRODUCT_TYPE = 'product_type';
    public static final String RDC_TYPE = 'rtype';
    public static final String ORGANIC = 'Organic';
    public static final String GCLID = 'gclid';
    
    //This is for Case object
    public static final String RELATED_CONTACT_FIRSTNAME = 'Related_Contact_FirstName__c';
    public static final String RELATED_CONTACT_LASTNAME = 'Related_Contact_LastName__c';
    public static final String RECORD_TYPE_COLLECTIONS = 'Collections';
    public static final String CASE_STATUS_NEW = 'New';
    public static final String CASE_STATUS_OPEN = 'Open';
    public static final String CASE_STATUS_IN_PROGRESS = 'In Progress';
    public static final String CASE_BILLING_PREF_INVOICE_CC = 'Invoice-CC';
    public static final String CASE_BILLING_PREF_CC_DIRECT = 'CC-Direct';
    public static final Set<String> validCaseStatuses = new Set<String>{SFMC_Constants.CASE_STATUS_NEW, SFMC_Constants.CASE_STATUS_IN_PROGRESS, SFMC_Constants.CASE_STATUS_OPEN};
    public static final Set<String> validBillingPref = new Set<String>{SFMC_Constants.CASE_BILLING_PREF_INVOICE_CC, SFMC_Constants.CASE_BILLING_PREF_CC_DIRECT};
    public static final Set<Integer> validNVMFailedCounts = new Set<Integer>{3,7,15};
    public static final Integer NVM_FAILED_COUNT_THRESHOLD_1 = 3;
    public static final Integer NVM_FAILED_COUNT_THRESHOLD_2 = 7;
    public static final Integer NVM_FAILED_COUNT_THRESHOLD_3 = 15;
            
    //For Account object
    public static final String ACCOUNT_SUB_TYPE_CUSTOMER = 'Customer';
    
    //This is for Form Submission object
    public static final String FORM_TYPE_REFERRAL = 'Referral form';
    public static final String FORM_TYPE_FACEBOOK = 'Facebook form';
    public static final String FORM_TYPE_LINKEDIN = 'LinkedIn form';
    public static final String FRIEND_TYPE_FIELDS_PREFIX_LEAD = 'Friend_Lead_Id_';
    public static final String FRIEND_TYPE_FIELDS_PREFIX_FIRSTNAME = 'Friend_First_Name_';
    public static final String FRIEND_TYPE_FIELDS_PREFIX_LASTNAME = 'Friend_Last_Name_';
    public static final String FRIEND_TYPE_FIELDS_PREFIX_PHONE = 'Friend_Phone_';
    public static final String FRIEND_TYPE_FIELDS_PREFIX_EMAIL = 'Friend_Email_';
    public static final String API_FIELDNAME_SUFFIX = '__c';
    
    //KEYWORDS
    public static final String SOBJECT_KEYWORD = 'SObject'; 
    public static final String CASE_KEYWORD = 'Case';
    
    
    //Uberflip form fields Label and API names
    public static final String FIRST_NAME_LABEL = 'First Name';
    public static final String FIRST_NAME_APINAME = 'first_name';
    public static final String LAST_NAME_LABEL = 'Last Name';
    public static final String LAST_NAME_APINAME = 'last_name';
    public static final String EMAIL_LABEL = 'Email';
    public static final String EMAIL_APINAME = 'email_address';
    public static final String PHONE_LABEL = 'Phone';
    public static final String PHONE_APINAME = 'phone';
    public static final String CONTACT_METHOD_LABEL = 'ContactMethodId';
    public static final String CONTACT_METHOD_APINAME = 'contactMethodId';
    public static final String CAMPAIGN_ID_LABEL = 'Campaign ID';
    public static final String CAMPAIGN_ID_APINAME = 'utm_campaign_id';
    public static final String PRODUCT_TYPE_LABEL = 'Product Type';
    public static final String PRODUCT_TYPE_APINAME = 'product_type';
   
    public static final String ACCOUNT_ID_LABEL = 'Account Id';
    public static final String ACCOUNT_ID_APINAME = 'accountId';
    public static final String UTM_MEDIUM_LABEL = 'UTM Medium';
    public static final String UTM_MEDIUM_APINAME = 'utm_medium';
    public static final String UTM_SOURCE_LABEL = 'UTM Source';
    public static final String UTM_SOURCE_APINAME = 'utm_source';
    public static final String UTM_CONTENT_LABEL = 'UTM Content';
    public static final String UTM_CONTENT_APINAME = 'utm_content';
    public static final String LEAD_ORIGIN_LABEL = 'Lead Origin';
    public static final String LEAD_ORIGIN_APINAME = 'lead_origin';
    public static final String BUSINESS_UNIT_LABEL = 'Business unit';
    public static final String BUSINESS_UNIT_APINAME = 'business_unit';

    public static final String UBERFLIP_DEFAULT = 'Uberflip';
   
    
    //Facebook form response constants(key for key-value pair received in JSON format)
    public static final String FB_JSON_CAMPAIGN_ID = 'utm_campaign_id';
    public static final String FB_JSON_PRODUCT_TYPE = 'product_type';
    public static final String FB_JSON_EMAIL = 'email';
    public static final String FB_JSON_FIRST_NAME = 'first_name';
    public static final String FB_JSON_LAST_NAME = 'last_name';
    public static final String FB_JSON_PHONE_NUMBER = 'phone_number';
    public static final String FB_JSON_BUSINESS_UNIT = 'business_unit';
    public static final String FB_JSON_FORM_ID = 'id';

     public static final String FACEBOOK = 'Facebook';
     
    //Facebook API constants
    public static final String FB_GRAPH_URL = 'https://graph.facebook.com/';
    public static final String PAID_ADS = 'Paid Ads';
    
    //Product Type Picklist constants
    public static final String PRODUCT_TYPE_TOPIDX = 'TOPIDX';
    
    //Marketing Lead types(MLT) to be excluded in lead updation process.
    public static final String MLT_EVENT = 'Event';
    public static final String MLT_AUTO_RENEW = 'Auto-Renew';
    public static final String LEAD_RECORD_TYPE_RDC = 'RDC';
    
    public static final String ACCOUNT_TYPE_AGENT = 'Realtor Agent';
    public static final String TARGET_ACCOUNT_TYPE_AGENT = 'Agent';

    //Parameter name for skipping form submission creation  by bots
    public static final String BOT_FORM_SUBMISSION_PARAM_KEY = 'lead_type';  
    public static final String BOT_FORM_SUBMISSION_PARAM_VALUE = 'Non-Lead';

    
    
}