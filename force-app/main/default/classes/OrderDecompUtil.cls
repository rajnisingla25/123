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
public without sharing class OrderDecompUtil {
    
    public static Boolean errorStatus;
    public static String errorMessage;

    private static final String DEBUG_STR = 'OrderDecompUtil: ';
     
    public static SubscribePreviewResponse performSubscribePreview(Zuora.zApi zApi, Date previewDate, zqu__ProductRatePlan__c prp, zqu__ProductRatePlanCharge__c prpc, String price, String cpqId, String zBillingAccountId, Decimal initialTerm, Decimal renewalTerm) {
        final String FUNC_STR = DEBUG_STR+'performSubscribePreview: ';

        //Default preview date to today is not provided
        if (previewDate == null) {
            previewDate = System.today();
        }

        List<Zuora.zApi.SubscribeResult> subscribePreviewResults = new List<Zuora.zApi.SubscribeResult>();
        try {
            System.debug(FUNC_STR+'In try-block for subscribe preview');
            List<Zuora.zApi.SubscribeRequest> requests = new List<Zuora.zApi.SubscribeRequest>();
            Zuora.zApi.SubscribeRequest request = new Zuora.zApi.SubscribeRequest();
            request.ZAccount = new Zuora.zObject('Account');
            request.ZAccount.setValue('Id', zBillingAccountId);

            Zuora.zApi.SubscribeInvoiceProcessingOptions sipo = new Zuora.zApi.SubscribeInvoiceProcessingOptions();
           
            //InvoiceProcessingOptions
            sipo.InvoiceProcessingScope = 'Subscription';
            sipo.InvoiceTargetDate = ''+previewDate.addYears(40).year()+'-01-01';

            //subscription options
            Zuora.zApi.SubscribeOptions so = new Zuora.zApi.SubscribeOptions();
            so.GenerateInvoice = true;
            so.ProcessPayments = false;
            so.SubscribeInvoiceProcessingOptions = sipo;

            //Subscribe Data
            Zuora.zApi.SubscriptionData subscribeData = new Zuora.zApi.SubscriptionData();

            String ratePlanId = prp.zqu__ZuoraId__c;
            String recurringChargeId = prpc.zqu__ZuoraId__c;

            //RatePlanCharge (recurring charge)
            Zuora.zObject ratePlanCharge1 = new Zuora.zObject('RatePlanCharge');
            ratePlanCharge1.setValue('ProductRatePlanChargeId', recurringChargeId);
            ratePlanCharge1.setValue('Price', price);

            Zuora.zObject rplanChargeData = new Zuora.zObject('RatePlanChargeData');
            rplanChargeData.setValue('RatePlanCharge', ratePlanCharge1);

            //RatePlan
            Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
            ratePlan.setValue('ProductRatePlanId', ratePlanId);

            Zuora.zObject rplanData = new Zuora.zObject('RatePlanData');
            rplanData.setValue('RatePlan', ratePlan);
            rplanData.setValue('RatePlanChargeData', new List < Zuora.zObject > {
                rplanChargeData
            });

            String previewYear = String.valueOf(previewDate.year());
            String previewMonth = String.valueOf(previewDate.month());
            String previewDay = String.valueOf(previewDate.day());
            if(previewMonth.length() == 1){
                previewMonth = '0' + previewMonth;
            }
            if(previewDay.length() == 1){
                previewDay = '0' + previewDay;
            }
            String combinedDate = previewYear+'-'+previewMonth+'-'+previewDay;
            system.debug('combinedDate@@@'+ combinedDate);
            
            //Subscription
            Zuora.zObject subscription = new Zuora.zObject('Subscription');
            subscription.setValue('Name', 'Sample_Subscription' + System.currentTimeMillis());
            System.debug(FUNC_STR+'Contract Effective Date: ' + combinedDate);
            subscription.setValue('ContractEffectiveDate', combinedDate);
            subscription.setValue('ServiceActivationDate', combinedDate);
            subscription.setValue('ContractAcceptanceDate', combinedDate);
            subscription.setValue('InitialTerm', initialTerm);
            subscription.setValue('RenewalTerm', renewalTerm);
          
            System.debug(FUNC_STR+'Subscription: ' + subscription);
            System.debug(FUNC_STR+'rplanData: ' + rplanData);

            subscribeData.Subscription = subscription;
            subscribeData.RatePlanData = new List < Zuora.zObject > {
                rplanData
            };
        
            System.debug(FUNC_STR+'After rplanData');
            
            Zuora.zApi.PreviewOptions PreviewOptions = new Zuora.zApi.PreviewOptions();
            PreviewOptions.EnablePreviewMode = true;       
          
            request.SubscribeOptions = so;
            request.SubscriptionData = subscribeData;
            request.PreviewOptions = PreviewOptions;
          
            System.debug(FUNC_STR+'Adding Request');
            
            requests.add(request);
            System.debug(FUNC_STR+'requests: ' + requests);

            //JIRA LEAP-8890 Zuora returns Lock Competition. Retry 5 times for Read Timeout or Lock
            if (!Test.isRunningTest()) {
                for (Integer i=0;i<5;i++){
                    try {
                        subscribePreviewResults = zApi.zsubscribe(requests);

                        if (subscribePreviewResults != null && !subscribePreviewResults.isEmpty()) {
                            Zuora.zApi.SubscribeResult subscribeResult = subscribePreviewResults[0];
                            if (!subscribeResult.Success) {
                                String errMsg = '';
                                List<Zuora.zObject> errs = (subscribeResult.Errors != null) ? subscribeResult.Errors : new List<Zuora.zObject>();
                                for (Zuora.zObject err : errs) {
                                    if (String.isNotBlank(((String)err.getValue('Message')))) {
                                        errMsg += ((String)err.getValue('Message')) + ',';
                                    }
                                }
                                if (errMsg.containsIgnoreCase('lock competition')){
                                    continue;
                                }
                            }
                        }
                    } catch(Exception ex) {
                        if (ex.getMessage().containsIgnoreCase('Read timed out')) {
                            continue;
                        } else {
                            throw ex;
                        }
                    }
                    break;
                }
            } else {
                subscribePreviewResults = OrderDecompControllerTest.createTestSubPreviewResult();
            }

            if(!Test.isRunningTest()){
                System.debug(FUNC_STR+'SOAP Request = ' + Zuora.zApi.currentLogger.request );
                System.debug(FUNC_STR+'SOAP Response = ' + Zuora.zApi.currentLogger.response );
            }
            
            Decimal tempAmountWithoutTax = 0.0;
            Decimal tempTcv = 0.0;

            //TODO: need to test "totalTcv" and InvoiceDatas / "amountWithoutTax" in responses where there is no preview happening
            if (subscribePreviewResults != null && !subscribePreviewResults.isEmpty()) {
                Zuora.zApi.SubscribeResult subscribeResult = subscribePreviewResults[0];

                if (subscribeResult.Success) {
                    if (subscribeResult.totalTcv == null) {
                        System.debug(FUNC_STR+'subscribeResult totalTcv is null');
                    } else {
                        tempTcv += subscribeResult.totalTcv;
                    }

                    if (subscribeResult.InvoiceDatas == null || subscribeResult.InvoiceDatas.isEmpty()) {
                        System.debug(FUNC_STR+'Invoice Datas are null or empty');
                    } else {
                        for (Zuora.zObject invData : subscribeResult.InvoiceDatas) {
                            Zuora.zObject tmpInv = (Zuora.zObject)invData.getValue('Invoice');
                            if (tmpInv != null && tmpInv.getValue('AmountWithoutTax') != null) {
                                tempAmountWithoutTax += (Decimal)tmpInv.getValue('AmountWithoutTax');
                            } else {
                                System.debug(FUNC_STR+'Failed to retrieve AmountWithoutTax from Invoice object');
                            }
                        }
                    }

                    String amountWithoutTax = String.valueOf(tempAmountWithoutTax);
                    String tcv = String.valueOf(tempTcv);
                    System.debug(FUNC_STR+'TCV: ' + tcv);
                    System.debug(FUNC_STR+'amountWithoutTax: ' + amountWithoutTax);

                    return new SubscribePreviewResponse(amountWithoutTax, tcv, subscribeResult);
                } else {
                    //TODO: test this piece to ensure handling errors with null Errors container and with valid error messages
                    String errMsg = '';
                    List<Zuora.zObject> errs = (subscribeResult.Errors != null) ? subscribeResult.Errors : new List<Zuora.zObject>();
                    for (Zuora.zObject err : errs) {
                        if (String.isNotBlank(((String)err.getValue('Message')))) {
                            errMsg += ((String)err.getValue('Message')) + ',';
                        }
                    }
                    throw new OrderDecompUtilException('Subscribe preview result failed with error: '+errMsg+', result: '+subscribeResult);
                }
            } else {
                throw new OrderDecompUtilException('Failed to retrieve a subscribe preview result from Zuora');
            }
        } catch (Exception ex) {
            //errorMessage = FUNC_STR+'Subscribe Preview call failed: '+ex.getMessage();
            if(!Test.isRunningTest()){
                System.debug( 'SOAP Request = ' + Zuora.zApi.currentLogger.request );
                System.debug( 'SOAP Response = ' + Zuora.zApi.currentLogger.response );
            }
            System.debug('Exception occurred during subscribe preview section: '+ex.getMessage());
            throw new OrderDecompUtilException('Exception occurred during subscribe preview section: '+ex.getMessage());
        }
    }

    
    
    /**
     * Helper wrapper class for storing useful information from Subscribe Preview Response
     */
    public class SubscribePreviewResponse {
        public String amountWithoutTax {get;set;}
        public String totalTcv {get;set;}
        public Zuora.zApi.SubscribeResult result {get;set;}

        public SubscribePreviewResponse(String amountWithoutTax, String totalTcv, Zuora.zApi.SubscribeResult result) {
            this.amountWithoutTax = amountWithoutTax;
            this.totalTcv = totalTcv;
            this.result = result;
        }
    }

    public class OrderDecompUtilException extends Exception {}
    public static List<zqu.zChargeGroup> checkBillingPeriod(String price, String billingPeriod, List<zqu.zChargeGroup> chargeGroups, zqu__Quote__c zQuote, String billingPreference, Boolean consolidatedBillingFlag, String cpqId){
        return checkBillingPeriod(price, billingPeriod,chargeGroups,zQuote,billingPreference, consolidatedBillingFlag,cpqId, false);

    }

    
    public static List<zqu.zChargeGroup> checkBillingPeriod(String price, String billingPeriod, List<zqu.zChargeGroup> chargeGroups, zqu__Quote__c zQuote, String billingPreference, Boolean consolidatedBillingFlag, String cpqId, Boolean IsAmend){

        List<zqu.zChargeGroup> chargeGroupsToDelete = new List<zqu.zChargeGroup>();
        Map<String, String> productRatePlanToQty = new Map<String,String>();
        List<String> productRatePlanIds = new List<String>();
        final String RECURRING_CHARGE_TYPE = 'Recurring';
        final String USAGE_CHARGE_TYPE = 'Usage';
        List<zqu.zChargeGroup> chargeGroupdsToReturn;
        String qty;
        String quoteId = zQuote.Id;
        
        final String FUNC_STR = DEBUG_STR+'checkBillingPeriod: ';
        
        System.debug(FUNC_STR + 'Original billingPeriod:' + billingPeriod);
            
        if(billingPeriod == 'Bi-Annual')
            billingPeriod = 'Semi-Annual';
        else if (billingPeriod == 'Quarterly')
            billingPeriod = 'Quarter';
        else if (billingPeriod == 'Monthly')
            billingPeriod = 'Month';
            
        System.debug(FUNC_STR + 'billingPeriod after if clause:' + billingPeriod);  
        //CRM-2458 start convert charge trigger to non charge trigger
        System.debug(FUNC_STR + 'Existing charge group:' + chargeGroups);
         if(billingPreference == 'CC-Direct'){
                    cpqId = 'PAY' + cpqId;
                } else{
                    cpqId = 'INV' + cpqId;
                }
                if(billingPeriod != 'Month' && billingPeriod != 'Monthly' && billingPeriod != null && billingPeriod != ''){     
                    cpqId = 'CT' + cpqId;       
                } else if(consolidatedBillingFlag == false){
                    cpqId = 'CT' + cpqId;
                } 
                
                System.debug(FUNC_STR + 'cpqID after if clause @ :' + cpqId);
                
                String newprpId = OrderDecompController.getProductRatePlanId(cpqId);
        System.debug(FUNC_STR + 'newprpId : ' + newprpId);
        
        List<Zuora__SubscriptionProductCharge__c> subProdChrg = [SELECT zuora__billingperiod__c, zuora__type__c FROM Zuora__SubscriptionProductCharge__c 
            where zuora__subscription__r.zuora__external_id__c= :zQuote.zqu__ExistSubscriptionID__c];
            //CRM-1220 Add one more for loop to check recurring charges.
           // if Subscription contains one time and recurring charges together if condition is taking one time charges needs add one more for loop for subProdChrg 
    //CRM-3109 
        try{    
        for(Zuora__SubscriptionProductCharge__c recSubProdChrg:subProdChrg){ 
            if(recSubProdChrg.zuora__type__c==RECURRING_CHARGE_TYPE || recSubProdChrg.zuora__type__c==USAGE_CHARGE_TYPE){
                for(zqu.zChargeGroup chrgGrp : chargeGroups){
                    for(zqu.zCharge chrg: chrgGrp.zCharges){
                        System.debug(FUNC_STR + 'Charge groups ' + chrg);
                        System.debug(FUNC_STR + 'billing period of existing charge:' + chrg.PERIOD);
                        if((chrg.CHARGE_TYPE == RECURRING_CHARGE_TYPE || chrg.CHARGE_TYPE == USAGE_CHARGE_TYPE ) && (recSubProdChrg.zuora__billingperiod__c != billingPeriod || (chrgGrp.productRateplanZuoraID != newprpId &&((consolidatedBillingFlag && billingPeriod == 'Month') || IsAmend)))){
                            chargeGroupsToDelete.add(chrgGrp);
                            //productRatePlanIds.add(chrgGrp.productRatePlanId);
                            //productRatePlanToQty.put(chrg.NAME, chrg.QUANTITY);
                            qty= chrg.QUANTITY;
                            System.debug(FUNC_STR + 'qty retrived:' + qty);
                        }
                    }
                }
            }
        }

  // CRM-2458
            if(chargeGroupsToDelete.isEmpty()){
                chargeGroupdsToReturn = chargeGroups;
                System.debug(FUNC_STR + 'No Change in billingPeriod found, retrun the original chargegroup:' + chargeGroupdsToReturn);
            }else{
                if(!Test.isRunningTest())
                zqu.zQuoteUtil.deleteChargeGroups(chargeGroupsToDelete);
                System.debug(FUNC_STR +'Change found in billingPeriod, ChargeGroups Deleted:' + chargeGroupsToDelete);
                
                System.debug(FUNC_STR + 'billingPreference:' + billingPreference);
                System.debug(FUNC_STR + 'Original cpqId:' + cpqId);
                
                
                 String prpId = newprpId;
                List<zqu__ProductRatePlan__c> listofPRPs = [SELECT Id, zqu__ZuoraId__c 
                            FROM zqu__ProductRatePlan__c 
                            WHERE zqu__ZuoraId__c = :prpId AND zqu__Deleted__c = false];
   
                productRatePlanIds.add(listofPRPs[0].Id);
                System.debug(FUNC_STR + 'New ProductRatePlan Id:' + productRatePlanIds);
                
                List<zqu.zChargeGroup> chargeGroupdsToAdd = zqu.zQuoteUtil.getChargeGroups(quoteId, productRatePlanIds);
                List<zqu.zCharge> newZCharges = new List<zqu.zCharge>();

                for(zqu.zChargeGroup cg : chargeGroupdsToAdd) {
                    for(zqu.zCharge zc : cg.zCharges) {
                        if(zc.isEffectivePriceEditable){
                            System.debug(FUNC_STR + 'Price is editable: ' + price);
                            zc.EFFECTIVE_PRICE = price; 
                        }else
                            System.debug(FUNC_STR + 'Price is not editable');

                        newZCharges.add(zc);
                   }
                }
                
                List<zqu.zCharge> newZCharges2 = zqu.zQuoteUtil.calculateChargesOnEffectivePriceChange(newZCharges);
                System.debug(FUNC_STR + 'zCharge after price update' + newZCharges2);

                for(zqu.zChargeGroup cg : chargeGroupdsToAdd) {
                    System.debug(FUNC_STR+'Charge Group zCharges: '+cg.zCharges);
                }
                chargeGroupdsToReturn = zqu.zQuoteUtil.addChargeGroups(chargeGroupdsToAdd);

                System.debug(FUNC_STR + 'ChargeGroups Added:' + chargeGroupdsToReturn);
                          
            }
            
        }catch(Exception ex){
            System.debug('Exception::' + ex.getMessage());
        }
            
        System.debug(FUNC_STR + ' Returned Chargegroup:' + chargeGroupdsToReturn);
        return chargeGroupdsToReturn;
    }
}