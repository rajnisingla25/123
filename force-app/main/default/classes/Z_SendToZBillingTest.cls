/*    Copyright (c) 2016 Zuora, Inc. 
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
@isTest(SeeAllData=true)
public with sharing class Z_SendToZBillingTest {
    static testmethod void success(){
        Account acc = makeAccount();
        Opportunity opp = makeOpportunity(acc);
        zqu__Quote__c quote = makeQuote(opp);
        Test.startTest();
        Z_SendToZBillingInstantiator.sendToZuora(quote.id);     
        Test.stopTest();
        quote = [Select Quote_Submit_Status__c FROM zqu__Quote__c WHERE id = :quote.id];
        //System.assertEquals(quote.Quote_Submit_Status__c, 'Sent to Z-Billing');
        //Zuora.zApi zApi = Z_VirtualSendToZBilling.zApi;
        //System.assertNotEquals(zApi,null);

    }

    public static Account makeAccount() {

        Account testAcc = new Account();
        testAcc.Name = 'my test account';
        testAcc.BillingState = 'CA';
        testAcc.BillingStreet = '123 Test Ln';
        testAcc.BillingCity = 'Test City';
        testAcc.BillingCountry = 'United States';
        testAcc.BillingPostalCode = '95111';
        testAcc.ShippingStreet = '123 Test Ln';
        testAcc.ShippingCity = 'Test City';
        testAcc.ShippingCountry = 'United States';
        testAcc.ShippingPostalCode = '95111';
        testAcc.ShippingState = 'CA';

        insert testAcc;
        return testAcc;
    }
    public static zqu__Quote__c makeQuote(Opportunity testOpp) {
        zqu__Quote__c testQuote = new zqu__Quote__c();

        testQuote.Name = 'my test quote';
        testQuote.zqu__Opportunity__c = testOpp.Id;
        testQuote.zqu__Currency__c = 'USD';
        testQuote.zqu__Status__c = 'New';
        testQuote.zqu__SubscriptionTermStartDate__c = Date.today();
        testQuote.zqu__startdate__c =  Date.today();
        testQuote.zqu__InitialTerm__c = 12;
        testQuote.zqu__SubscriptionTermEndDate__c = Date.today().addMonths(12);
        testQuote.zqu__SubscriptionType__c ='New Subscription';
        testQuote.zqu__RenewalTerm__c = 12;
        testQuote.Quote_Submit_Status__c = '';

        insert testQuote;
        return testQuote;
    }
   /**
   * Insert a test opportunity associated with an account
   */
  public static Opportunity makeOpportunity(Account testAcc) {

    Opportunity testOpp = new Opportunity();

    testOpp.Name = 'my test opportunity';
    testOpp.StageName = 'Hypothesize';
    //testOpp.ForecastCategoryName = 'Omitted';
    testOpp.CloseDate = System.today();

    testOpp.AccountId = testAcc.Id;

    insert testOpp;
    return testOpp;
  }

  //Creates a mock sendtoZBilling result for testing
    public static List<zqu.zQuoteUtil.zBillingResult> mockSendToZbillingRes(List<String> ids){
        
        List<zqu.zQuoteUtil.zBillingResult> mockSendToZbillingRes = new List<zqu.zQuoteUtil.zBillingResult>();
        zqu.zQuoteUtil.zBillingResult mockSucessRes;
        for(String id : ids){
            System.debug('Id: ' + id);
            mockSucessRes = new zqu.zQuoteUtil.zBillingResult();
            mockSucessRes.success = true;
            mockSucessRes.sfdcQuoteId = id;
            mockSendToZbillingRes.add(mockSucessRes);
        }       
        return mockSendToZbillingRes;

    }

}