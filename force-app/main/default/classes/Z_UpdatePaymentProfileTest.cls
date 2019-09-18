@isTest(SeeAllData=true)
public with sharing class Z_UpdatePaymentProfileTest {
	static testmethod void testUpdate(){
		Account acc = makeAccount();
		Zuora__CustomerAccount__c billAcc = makeBillingAccount(acc);
		Zuora__PaymentMethod__c pm = makePaymentMethod(billAcc);
		PaymentProfiles__c pp = makeProfile(acc);
		pm.Zuora__AchAccountName__c = 'Test account Name';
		Test.startTest();
		update pm;
		Test.stopTest();

	}



	public static Account makeAccount() {
	    Account testAcc = new Account();
	    testAcc.Name = 'my test account';
	    testAcc.BillingState = 'California';
	    insert testAcc;
	    return testAcc;
    }

    public static Zuora__CustomerAccount__c makeBillingAccount(Account acc) {
	    Zuora__CustomerAccount__c testAcc = new Zuora__CustomerAccount__c();
	    testAcc.Name = 'my test billing account';
	    testAcc.Zuora__Account__c = acc.id;
	    testAcc.Zuora__External_Id__c = '2222222222222222222222222222222';
	    testAcc.Zuora__Currency__c = 'USD';
	    testAcc.Zuora__BillToCity__c = 'Test City';
	    testAcc.Zuora__BillToCountry__c = 'United States';
	    testAcc.Zuora__BillToAddress1__c = '123 Test Lane';
	    testAcc.Zuora__BillToState__c = 'California';
	    testAcc.Zuora__BillToPostalCode__c = '95124';
	    testAcc.Zuora__BillToName__c = 'Tyler Bill';


	    insert testAcc;
	    return testAcc;
    }


    static String zID = '11111111111111111111111111111111';
    public static Zuora__PaymentMethod__c makePaymentMethod(Zuora__CustomerAccount__c billAcc){
    	Zuora__PaymentMethod__c pm = new Zuora__PaymentMethod__c();
    	pm.Name = 'Test Payment Method';
    	pm.Zuora__External_Id__c = zID;
    	pm.Zuora__BillingAccount__c = billAcc.id;
    	insert pm;
    	return pm;
    }
    public static PaymentProfiles__c makeProfile(Account acc){
    	PaymentProfiles__c pp = new PaymentProfiles__c();
    	pp.Account__c = acc.id;
    	//pp.Name = 'Test Profile';
    	pp.PaymentMethodId__c = zId;
    	insert pp;
    	return pp;
    }
}