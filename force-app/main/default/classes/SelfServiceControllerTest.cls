/*****************************************************************************
* Class Name: SelfServiceControllerTest
* Author: Shraddha Kabade
* Purpose: Test class for SelfServiceController
* JIRA : LCM-294, LCM-295
****************************************************************************/
@isTest
public class SelfServiceControllerTest {
    
    static testMethod void testCase1() {
        
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Switch_AccountRelationshipTrigger__c art = new Switch_AccountRelationshipTrigger__c(name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
        insert art;  
        Suppress_in_Customer_Statements_Settings__c sct = new Suppress_in_Customer_Statements_Settings__c(name = 'Customer', Promo_Codes__c = 'FREERES');
        insert sct;
        Waitlist_Urls__c wlu = new Waitlist_Urls__c(name='SelfServiceProfileApi', URL__c = 'https://soa-external-app.entsys-dev.moveaws.com:7082/SearchCustomerDetailsProfile/SearchCustomerDetailsProfilePS');
        insert wlu;
        Waitlist_Urls__c wlu2 = new Waitlist_Urls__c(name='SelfServiceGEOApi', URL__c = 'https://soa-external-app.entsys-dev.moveaws.com:7082/SearchCustomerDetailsProfile/SearchCustomerDetailsProfilePS');
        insert wlu2;
        
        //creating account for agent and lender with type as real estate agent and lender
        // Inserting account records.
        Account agentAcc = TestDataFactory.createAccount('Agent Account', null, false);
        agentAcc.Primary_Email__c = 'parentAcc@move.com';
        agentAcc.Type = 'Realtor Agent';
        agentAcc.Party_ID__c  = '12345';
        agentAcc.Customer_Id__c  = '12345';
        agentAcc.BillingPostalCode  = '12345';
        agentAcc.BillingCity = 'newyork';
        agentAcc.MLS_Set_Id__c  = '12345';    
        agentAcc.advertiserId__c = '1234';
        insert agentAcc;
        
        paymentProfiles__c pp = new paymentProfiles__c();
        pp.MaskNumber__c = 'xxxxxx1111';
        pp.ExpirationDate__c = '08/2019';
        pp.PaymentMethodId__c = '9999';
        insert pp;
        paymentProfiles__c pp1 = new paymentProfiles__c();
        pp1.MaskNumber__c = 'xxxxxx1111';
        pp1.ExpirationDate__c = '08/2019';
        insert pp1;
        Product2 prd = new Product2();
        prd.name = 'Test Product';
        prd.productCode = 'COBROKE';
        Insert prd;
        Product2 prd1 = new Product2();
        prd1.name = 'Test Product2';
        prd1.productCode = 'TOPCRM';
        Insert prd1;
        
        Integer COUNTER = 2;
        List<Asset> theTestAssets = new List<Asset>();
        for(Integer index = 0; index < COUNTER; index++) {
            theTestAssets.add(new Asset(
                Name = 'Test Asset - ' + index,
                AccountId = agentAcc.Id,
                Asset_Type__c='Parent',
                Get_CP_Login_Status__c = 'Ready',
                Fulfillment_Status__c = 'Fulfilled',
                Status = 'Active',
                Product2Id = prd.id,
                price__c = 400,
                Extended_Net_Price__c = 400,
                promotion__c = 'test',
                Commerce_Group__c = 'Broker Marketing Solution'
            ));
        }
        for(Integer index = 0; index < COUNTER; index++) {
            theTestAssets.add(new Asset(
                Name = 'Test Asset - ' + index,
                AccountId = agentAcc.Id,
                Asset_Type__c='Parent',
                Get_CP_Login_Status__c = 'Ready',
                Fulfillment_Status__c = 'Fulfilled',
                Status = 'Active',
                Product2Id = prd1.id,
                price__c = 400,
                Extended_Net_Price__c = 400,
                promotion__c = 'test',
                Commerce_Group__c = 'Broker Marketing Solution'
            ));
        }
        insert theTestAssets;       
        
       test.startTest();
        for(Asset a : theTestAssets){
            a.status = 'Active';
        }
        update theTestAssets;
       SelfServiceController selfServiceCntrl = new SelfServiceController();
       SelfServiceController.getAllProducts(agentAcc.id);
       SelfServiceController.getProfileDetails(agentAcc.advertiserid__c);
       SelfServiceController.getAllCreditCards(agentAcc.id);
       SelfServiceController.getGeoParserData(new List<String>{'94085'});
       SelfServiceController.getCCDetailsById(pp.id);
       SelfServiceController.getCCDetailsById(pp1.id);
       SelfServiceController.getInvPaginationData(agentAcc.id, 2, 1, 'COBROKE',true,'priceHighToLow');
       SelfServiceController.verifyPassword(agentAcc.advertiserid__c, 'Password0');
       SelfServiceController.getInvoiceItemMonths(agentAcc.id);
       SelfServiceController sc = new SelfServiceController();
       sc.updateCCIframeDisplay();
       test.stopTest();
    }
    @isTest(SeeAllData=true)
     private static void testCase2() {
        PaymentProfiles__c pp = [Select id from PaymentProfiles__c limit 1];
        Zuora__PaymentMethod__c pm = [Select id from Zuora__PaymentMethod__c limit 1];
        SelfServiceController.updateCCDetails(pp.id, pm.id,'8999','12/2019','Steven', '94085', 'cc', 'cc', 'cc','cc','cc');
         
        SelfServiceController selfServiceCntrl = new SelfServiceController();
        selfServiceCntrl.getAddCCPageId();
    }

}