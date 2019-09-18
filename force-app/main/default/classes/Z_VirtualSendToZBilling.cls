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

/*
* Class: Z_VirtualSendToZBilling.cls
* @author Tyler Upadhyaya
* This class takes a Set of quote ids and allows for preprocessing, the sending of quotes to zuora, and then sets up postprocessing 
*/
public with sharing virtual class Z_VirtualSendToZBilling implements Queueable, Database.AllowsCallouts{
    // used incase the connection to zuora doesn't work
    public String errorMessage = '';
    //incase of a queuable context store the ids
    public Set<String> quoteIds;
    public String stage;

    //queueable contructor with set of ids and the context
    public Z_VirtualSendToZBilling(Set<String> ids, String stageContext){
        quoteIds = ids;
        stage = stageContext;
    }
    //default constructor
    public Z_VirtualSendToZBilling(){

    }

    public virtual void preSubmitQueueable(){
        Set<String> newIds = preSubmit(quoteIds);
        if(!Test.isRunningTest()){
            System.debug('Calling submit');
            Z_SendToZBillingInstantiator.queueableSend(newIds,'submit');
        }
    }

    public virtual void submitQueueable(){
        Set<String> newIds = submit(quoteIds);
        if(!Test.isRunningTest()){
            System.debug('Calling postSubmit');
            Z_SendToZBillingInstantiator.queueableSend(newIds,'postSubmit');
        }   
    }

    public virtual void postSubmitQueueable(){
        postSubmit(quoteIds);
    }


    /**
    *This allows for any callouts to be made before the quotes are sent to ZBilling
    *@param ids         Set of quote ids
    *@return            Set of any updated quotes that should/should not be sent to ZBilling
    **/
    public virtual Set<String> preSubmit(Set<String> ids){
        System.debug('In Presubmit');
        return ids;
    }

    /**
    *Sends a list of quotes to ZBilling
    *@param ids         Set of quote ids to be sent to ZBilling
    *@return            Set of all quotes that were sent to ZBilling
    **/
    public Set<String> submit(Set<String> ids){
         System.debug('In Submit with ids : ' + ids);
         List<zqu.zQuoteUtil.zBillingResult> results = new List<zqu.zQuoteUtil.zBillingResult>();
         List<zqu.zQuoteUtil.ZBillingQuoteCollection> bqcList = new List<zqu.zQuoteUtil.ZBillingQuoteCollection>();
         List<zqu__Quote__c> quotes = [SELECT id, zqu__Account__c, zqu__ZuoraAccountID__c FROM zqu__Quote__c WHERE id in :ids];
         for(zqu__Quote__c q : quotes){
            zqu.ZQuoteUtil.ZBillingQuoteCollection  bqc = new zqu.ZQuoteUtil.ZBillingQuoteCollection();
            bqc.sfdcAccountId = q.zqu__Account__c;
            bqc.zAccountId = (q.zqu__ZuoraAccountID__c==null) ? 'new' : q.zqu__ZuoraAccountID__c;
            zqu.zQuoteUtil.ZBillingQuoteRequest req = new zqu.zQuoteUtil.ZBillingQuoteRequest();
            req.sfdcQuoteId = q.id;
            bqc.quoteRequests = new List<zqu.zQuoteUtil.ZBillingQuoteRequest>{req};
            bqcList.add(bqc);
         }

         List<List<zqu.zQuoteUtil.ZBillingQuoteCollection>> bqcs = new List<List<zqu.zQuoteUtil.ZBillingQuoteCollection>>();
         List<zqu.zQuoteUtil.ZBillingQuoteCollection> temp = new List<zqu.zQuoteUtil.ZBillingQuoteCollection>();
         Integer count = 0;
         for(zqu.zQuoteUtil.ZBillingQuoteCollection b : bqcList){
            if(count > 0 && math.mod(count, 20)==0){
                bqcs.add(temp);
                temp = new List<zqu.zQuoteUtil.ZBillingQuoteCollection>();
            }
            temp.add(b);
            count++;
         }
         if(!temp.isEmpty()){
             bqcs.add(temp);
         }
         List<zqu.zQuoteUtil.zBillingResult> tempRes;
         for(List<zqu.zQuoteUtil.ZBillingQuoteCollection> bc : bqcs){
            System.debug('Calling with bc: ' + bc);
            tempRes = !Test.isRunningTest() ? zqu.zQuoteUtil.sendToZBilling(bc) : Z_SendToZBillingTestUtil.mockSendToZbillingRes(ids);
            results.addAll(tempRes);        
         }
         System.debug('Submit List Size: ' + results.size());
         Map<String,zqu.zQuoteUtil.zBillingResult> resultMap = new Map<String,zqu.zQuoteUtil.zBillingResult>();
         for(zqu.zQuoteUtil.zBillingResult r : results){
            if(r.sfdcQuoteId == null){
                errorMessage = r.message;
            }else{
                resultMap.put(r.sfdcQuoteId, r);
            }
         }
         if(resultMap.size() == 0 && !ids.isEmpty()){
            zqu.zQuoteUtil.zBillingResult res = new zqu.zQuoteUtil.zBillingResult();
            res.success = false;
            res.message = errorMessage;
             for(String s : ids){
                resultMap.put(s, res);
             }
         }
         return updateQuotes(resultMap);
    }

    /**
    *Allows for any more SFDC updates that need to be made to the quotes
    *@param ids         Set of quotes that were updated
    *@return            void
    **/
    public virtual void postSubmit(Set<String> ids){
        System.debug('In Postsubmit with ids: ' + ids);
    }


    /**
    *updates the quote with the result of the send to ZBilling call
    *@param resMap      map of quote id to the result form Zuora
    *@return            Set of the quotes that were updated
    **/
    public virtual Set<String> updateQuotes(Map<String,zqu.zQuoteUtil.zBillingResult> resMap){
        System.debug('In Postsubmit with map:: ' + resMap);
        if(resMap == null){
            throw new Z_SendtoZBillingException('The result map from the send to ZBilling call is null in postSubmit');
        }
        Set<String> resultIds = new Set<String>();
        List<zqu__Quote__c> quotes = [SELECT id, Quote_Submit_Status__c, Quote_Submit_Message__c FROM zqu__Quote__c WHERE Quote_Submit_Status__c != 'Error' AND id in :resMap.keySet()];
        for(zqu__Quote__c q : quotes){
            resultIds.add(q.id);
            if(resMap.get(q.id) == null){
                q.Quote_Submit_Status__c = 'Error';
                q.Quote_Submit_Message__c = 'Quote response not found';
            }else{
                q.Quote_Submit_Status__c = resMap.get(q.id).success ? 'Sent to Z-Billing' : 'Error';
                q.Quote_Submit_Message__c = resMap.get(q.id).message;
            }   
        }
        update quotes;
        return resultIds;
    }
    
    /**
    *The main method that calls preSubmit, submit, and postSubmit
    *@param resMap      Set of quote ids to but sent to ZBilling and updated
    *@return            void
    **/
    public virtual void run(Set<String> ids){
        Set<String> updatedIds = Presubmit(ids);
        Set<String> res = Submit(updatedIds);
        Postsubmit(res);
    }



    public virtual void execute(QueueableContext context) {
        System.debug('The stage is: ' + stage);
        if(stage == 'postSubmit'){
            System.debug('Sending to postSubmit');
            postSubmitQueueable();
        }else if(stage == 'submit'){
            System.debug('Sending to submit');
            submitQueueable();
        }else{
            preSubmitQueueable();
            System.debug('Sending to preSubmit');
        }
    }



    /**
    *Execption class to help catch any fatal errors     
    **/
    public class Z_SendtoZBillingException extends Exception {

    }

}