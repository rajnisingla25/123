@isTest
private class UberflipForm_Test {
	@testSetup static void setup() {

	 DisabledTrigger__c dt=new DisabledTrigger__c();
        dt.name='Disabled';
        dt.TaskTrigger__c='move@.com';
        insert dt;

	    List<Account> testAccts = new List<Account>();
	    for(Integer i=0;i<10;i++) {
	       //testAccts.add(TestDataFactory.createAccount('Test'+i,null,false));
	       testAccts.add(SFMC_TestDataFactory.createAccount('Test'+i,null,false));
	    }
	    insert testAccts;
	    List<Contact> testContacts = new List<Contact>();
	    for(Integer i=0;i<10;i++) {
	       testContacts.add(SFMC_TestDataFactory.createContact('Test Contact FN'+i, 'Test Contact LN'+i, testAccts.get(i).Id, true, false));
	    }
	    insert testContacts;   

		Campaign camp = new Campaign();
		camp.Name = 'Test Campaign';
        camp.Target_Product__c = SFMC_Constants.PRODUCT_TYPE_TOPIDX;
		insert camp;

		List<ContactMethod__c> testContactMethods = new List<ContactMethod__c>();
		 for(Integer i=0;i<10;i++) {
	    	for(Integer j=0;j<10;j++){
	    		testContactMethods.add(SFMC_TestDataFactory.createContactMethod(testContacts.get(i).Id,'Email','test'+i+'_'+j+'@gmail.com',true,false,'Business Email',false));
	    	}
	    }
	    insert testContactMethods;
	
	}

	
	@isTest static void test_getfields() {
		RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
        request.requestUri ='/services/GetFields';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response =  response;
        UberflipGetFields.responseWrapper resp = UberflipGetFields.doPost();
        System.debug(resp);
        System.assert(resp.data != null);
        //System.assertEquals('Test', acct.Name);
		// Implement test code
	}
	
	@isTest static void test_formSubmission_success() {
	/*
	{"event":"cta_submitted","occurred_at":"2019-03-19T15:34:45-04:00","account_id":551343,"cta_id":203974,"hub_id":85652,"submission":{"url":"https:\/\/movesales.uberflip.com\/facebook-page-realtor-com-pro?campaign=7013C000000IRNbQAO&cmid=a5e3C000000GvQJQA0","ip_address":"209.74.103.33","fields":{"first_name":"Apt14","last_name":"sha14","email_address":"ap@test14.com","phone":"321-456-7985","Cookie":"vl82dnulnagsdabtrqi2hrgovj","cmid":"a5e3C000000GvQJQA0","campaign":"7013C000000IRNbQAO"},"stream_id":2889980,"previous_stream_id":2889980}}
	*/
	// Implement test code
	List<Campaign> cList = [Select Id from Campaign];
	List<ContactMethod__c> cmList = [Select Id from ContactMethod__c];
    List<Account> accList = [Select Id from Account];


	RestRequest request = new RestRequest();
	RestResponse response = new RestResponse();
        request.requestUri ='/services/FormSubmission';
        request.httpMethod = 'POST';
        JSONGenerator gen = JSON.createGenerator(true);
        
		gen.writeStartObject();

        gen.writeStringField('event','cta_submitted');
        gen.writeDateTimeField('occurred_at', System.now());
        gen.writeNumberField('accountId',551343);
        gen.writeNumberField('cta_id',203974);
        gen.writeNumberField('hub_id',85652);
        
        Field fld = new Field();
        fld.first_name='TestFN';
        fld.last_name='TestLN';
        fld.email_address='test@uf.com';
        fld.phone='312-654-9874';
        //fld.cookie='vl82dnulnagsdabtrqi2hrgovj';
        fld.contactMethodId=cmList.get(0).Id;
        fld.utm_campaign_id=cList.get(0).Id;
        fld.product_type='TOPCRM';
        fld.accountId=accList[0].id;
        fld.utm_medium='test';
        fld.utm_source='test';
        fld.lead_origin='test';
        
        Submission sub = new Submission();
        sub.url='https://movesales.uberflip.com/facebook-page-realtor-com-pro?'+SFMC_Constants.CAMPAIGN_ID_APINAME+'='+cList.get(0).Id+'&'+SFMC_Constants.CONTACT_METHOD_APINAME+'='+cmList.get(0).Id;
        sub.ip_address='209.74.103.33';
        sub.fields=fld;
        sub.stream_id=2889980;
        sub.previous_stream_id=2889980;
        									
        gen.writeObjectField('submission',sub);
        gen.writeEndObject();
        
		
        System.debug('>>>***'+gen.getAsString());
        request.requestBody = Blob.Valueof(gen.getAsString());
        System.debug('request.requestBody: '+request.requestBody);

        RestContext.request = request;
        RestContext.response =  response;
        Test.startTest();
        UberflipFormSubmission.doPost();
        Test.stopTest();
        List<Form_Submission__c> fsList = [Select Id,utm_content__c,Product_Type__c from Form_Submission__c where Contact_Method_Id__c=:cmList.get(0).Id and Campaign_Id__c=:cList.get(0).Id];
        System.debug('>>>***>>>'+fsList);
        System.assertNotEquals(fsList.size(),0);
        system.assertEquals(fsList[0].Product_Type__c , 'TOPCRM');	//check if passed value is set.
        system.assertEquals(fsList[0].utm_content__c , SFMC_Constants.UBERFLIP_DEFAULT);	//check if default value(not passed in URL) is set.
	}
    
    @isTest static void test_ProductType_Defaulting() {
        
	List<Campaign> cList = [Select Id,Target_Product__c from Campaign];
	List<ContactMethod__c> cmList = [Select Id from ContactMethod__c];
    List<Account> accList = [Select Id from Account];


	RestRequest request = new RestRequest();
	RestResponse response = new RestResponse();
        request.requestUri ='/services/FormSubmission';
        request.httpMethod = 'POST';
        JSONGenerator gen = JSON.createGenerator(true);
        
		gen.writeStartObject();

        gen.writeStringField('event','cta_submitted');
        gen.writeDateTimeField('occurred_at', System.now());
        gen.writeNumberField('accountId',551343);
        gen.writeNumberField('cta_id',203974);
        gen.writeNumberField('hub_id',85652);
        
        Field fld = new Field();
        fld.first_name='TestFN';
        fld.last_name='TestLN';
        fld.email_address='test@uf.com';
        fld.phone='312-654-9874';
        fld.contactMethodId=cmList.get(0).Id;
        fld.utm_campaign_id=cList.get(0).Id;
        //fld.product_type='TOPCRM'; //Not passing PT as parameter.
        fld.accountId=accList[0].id;
        fld.utm_medium='test';
        fld.utm_source='test';
        fld.lead_origin='test';
        
        Submission sub = new Submission();
        //Not passing PT as a parameter from URL.
        sub.url='https://movesales.uberflip.com/facebook-page-realtor-com-pro?'+SFMC_Constants.CAMPAIGN_ID_APINAME+'='+cList.get(0).Id+'&'+SFMC_Constants.CONTACT_METHOD_APINAME+'='+cmList.get(0).Id;
        sub.ip_address='209.74.103.33';
        sub.fields=fld;
        sub.stream_id=2889980;
        sub.previous_stream_id=2889980;
        									
        gen.writeObjectField('submission',sub);
        gen.writeEndObject();
        
        request.requestBody = Blob.Valueof(gen.getAsString());

        RestContext.request = request;
        RestContext.response =  response;
        Test.startTest();
        UberflipFormSubmission.doPost();
        Test.stopTest();
        List<Form_Submission__c> fsList = [Select Id,utm_content__c,Product_Type__c from Form_Submission__c where Contact_Method_Id__c=:cmList.get(0).Id and Campaign_Id__c=:cList.get(0).Id];
        System.assertNotEquals(fsList.size(),0);
        system.assertEquals(fsList[0].Product_Type__c , SFMC_Constants.PRODUCT_TYPE_TOPIDX);	//check if value is set based on Campaign's value.
	}

	
	@isTest static void test_formSubmission_failure() {
	/*
	{"event":"cta_submitted","occurred_at":"2019-03-19T15:34:45-04:00","account_id":551343,"cta_id":203974,"hub_id":85652,"submission":{"url":"https:\/\/movesales.uberflip.com\/facebook-page-realtor-com-pro?campaign=7013C000000IRNbQAO&cmid=a5e3C000000GvQJQA0","ip_address":"209.74.103.33","fields":{"first_name":"Apt14","last_name":"sha14","email_address":"ap@test14.com","phone":"321-456-7985","Cookie":"vl82dnulnagsdabtrqi2hrgovj","cmid":"a5e3C000000GvQJQA0","campaign":"7013C000000IRNbQAO"},"stream_id":2889980,"previous_stream_id":2889980}}
	*/
	// Implement test code
	List<Campaign> cList = [Select Id from Campaign];
	List<ContactMethod__c> cmList = [Select Id from ContactMethod__c];


	RestRequest request = new RestRequest();
	RestResponse response = new RestResponse();
        request.requestUri ='/services/FormSubmission';
        request.httpMethod = 'POST';
        JSONGenerator gen = JSON.createGenerator(true);
        
		gen.writeStartObject();

        gen.writeStringField('event','cta_submitted');
        gen.writeDateTimeField('occurred_at', System.now());
        gen.writeNumberField('account_id',551343);
        gen.writeNumberField('cta_id',203974);
        gen.writeNumberField('hub_id',85652);
        
        Field fld = new Field();
        fld.first_name='TestFN';
        fld.last_name='TestLN';
        fld.email_address='312-654-9874';//'test@uf.com';
        fld.phone='test@uf.com';//'312-654-9874';
        //fld.cookie='vl82dnulnagsdabtrqi2hrgovj';
        fld.contactMethodId=cmList.get(0).Id;
        fld.utm_campaign_id=cList.get(0).Id;
        
        Submission sub = new Submission();
        sub.url='https://movesales.uberflip.com/facebook-page-realtor-com-pro?campaign=7013C000000IRNbQAO&cmid=a5e3C000000GvQJQA0';
        sub.ip_address='209.74.103.33';
        sub.fields=fld;
        sub.stream_id=2889980;
        sub.previous_stream_id=2889980;
        									
        gen.writeObjectField('submission',sub);
        gen.writeEndObject();
        
		
        System.debug('>>>***'+gen.getAsString());
        request.requestBody = Blob.Valueof(gen.getAsString());

        RestContext.request = request;
        RestContext.response =  response;
        Test.startTest();
        UberflipFormSubmission.doPost();
        Test.stopTest();

        List<Form_Submission__c> fsList = [Select Id from Form_Submission__c where Contact_Method_Id__c=:cmList.get(0).Id and Campaign_Id__c=:cList.get(0).Id];
        System.debug('>>>***>>>'+fsList);
        System.assertEquals(fsList.size(),0);
	}

	public class Submission{
		public String url {get;set;}
		public String ip_address {get;set;}
		public Field fields {get;set;}
		public Integer stream_id {get;set;}
		public Integer previous_stream_id {get;set;}
	}

	public class Field{
		public String first_name{get;set;}
		public String last_name{get;set;}
		public String email_address{get;set;}
		public String phone{get;set;}
		public String contactMethodId{get;set;}
		public String utm_campaign_id{get;set;}
        public String accountId{get;set;}
        public String utm_source{get;set;}
        public String utm_medium{get;set;}
        //public String utm_content{get;set;} 		//Commented to test default value scenario.
        public String lead_origin{get;set;}
        public String business_unit{get;set;}
        public String product_type{get;set;}
	}
	
}