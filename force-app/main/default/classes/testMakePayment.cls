/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest (SeeAllData=true)
private class testMakePayment {

    static testMethod void MakePaymentTest() {
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
        testAccount.Primary_Email__c = 'testAccount@move.com';
        insert testAccount; 
        //Inserting Test Contact 
        Contact testContact = TestDataFactory.createContact('Test Contact','TestL',testAccount.Id,true,false);
        testContact.Email = 'rshekhawat@move.com';
        insert testContact;
        Case caseRec = TestDataFactory.createCase('Invalid Rights','Open','Collections' ,'Test Description', testContact.Id,testAccount.Id,true);
        Test.startTest();
        
        MakePayment mp = new MakePayment();
        System.currentPageReference().getParameters().put('preset', '1');
        System.currentPageReference().getParameters().put('pmId', 'newACH');  
        System.currentPageReference().getParameters().put('displayMessage', '1'); 
        mp = new MakePayment();
        mp.ismoving =true;
        mp.confirmError();
        mp.accId = testAccount.Id;
        mp.makePaymentNow();
        mp.paymentType='electronic';       
        mp.makePaymentNow();
        mp.cancel();
        mp.getPaymentMethodOptions();
        mp.getExternalPaymentMethodOptions();
        mp.updateValues();
        mp.updateInvoiceTotal();
        mp.updateTotal();
        mp.updateDate();
        mp.paymentDate = ('1/1/2015');
        mp.getPageRef();
        mp.getExtraParameters();
        mp.getBackURL();
        mp.navigateBack();
        mp.getNextUrl();
        mp.getPaymentTypeOptions();
        mp.pmId = 'newACH';
        mp.toACH();
        mp.ismoving =true;
        mp.updateRemaining();
        mp.successActions();
        mp.cancelValidation();
        mp.getValidateMonthOptions();
        mp.getValidateYearOptions();
        mp.validateInfo();
        mp.openValidation();
        mp.pmId = 'newCC';
        mp.toACH();
        mp.openBINValidation();   
        mp.paymentType='external';       
        mp.makePaymentNow();     
        mp.selectAll();
        mp.validatePmBIN();
        mp.cancelBINValidation();
        mp.paymentType='';       
        mp.makePaymentNow();
        Test.stopTest();
    }
}