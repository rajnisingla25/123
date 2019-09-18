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
public with sharing class Z_SendToZBillingInstantiatorTest {
    static testmethod void success(){
        Account acc = Z_SendToZBillingTestUtil.makeAccount();
        Opportunity opp = Z_SendToZBillingTestUtil.makeOpportunity(acc);
        zqu__Quote__c quote = Z_SendToZBillingTestUtil.makeQuote(opp);
        Set<String> quoteSet = new Set<String>();
        quoteSet.add(quote.id);
        Test.startTest();
        Z_SendToZBillingInstantiator.sendToZuora(quote.id);
        Z_SendToZBillingInstantiator.queueableSend(quoteSet, 'preSubmit'); 
        Z_SendToZBillingInstantiator.queueableSend(quoteSet, 'submit');
        Z_SendToZBillingInstantiator.queueableSend(quoteSet, 'postSubmit');
        Z_SendToZBillingInstantiator.futureSend(quoteSet);
        Z_SendToZBillingInstantiator.synchronousSend(quoteSet);     
        Test.stopTest();
        quote = [Select Quote_Submit_Status__c FROM zqu__Quote__c WHERE id = :quote.id];
        System.assertEquals(quote.Quote_Submit_Status__c, 'Sent to Z-Billing');
    }

    

}