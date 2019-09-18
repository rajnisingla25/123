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
* Class: Z_SendToZBillingInstantiatior.cls
* @author Tyler Upadhyaya
* This class recives a list of Ids and instantiates a new instance of the Z_sendToZBilling class. 
* Alternativly, you can call this from a button to do the same thing    
*/

global with sharing class Z_SendToZBillingInstantiator {

    /**
    *This method instatitaiates the Z_SendToZBiling class and calls its run method
    *@param ids         Set of quote ids
    *@return void
    **/
    @future(callout = true)
    public static void futureSend(Set<String> ids){
        if(ids != null && !ids.isEmpty()){
            Z_SendToZBilling sender = new Z_SendToZBilling();
            sender.run(ids);
        }else{
            System.debug('Ids are empty');
            throw new Z_SendtoZBillingException('Ids are empty');
        }
    }


    public static void synchronousSend(Set<String> ids){
        if(ids != null && !ids.isEmpty()){
            Z_SendToZBilling sender = new Z_SendToZBilling();
            sender.run(ids);
        }else{
            System.debug('Ids are empty');
            throw new Z_SendtoZBillingException('Ids are empty');
        }
    }

    @future(callout = true)
    public static void queueableSend(Set<String> ids,  String stage){
        if(ids != null && !ids.isEmpty()){
            System.enqueueJob(new Z_SendToZBilling(ids, stage));
        }else{
            System.debug('Ids are empty');
            throw new Z_SendtoZBillingException('Ids are empty');
        }
    }



    /**
    *This class recives a call from a button, takes the id and turns it into a Set and passes it to the send method
    *@param myquoteId       id of a quote
    *@return a list containting that quote
    **/
    webservice static List<String> sendToZuora(Id myquoteId)
    {
        List<String> quote = new List<String>();
        quote.add((String) myquoteId);
        //futureSend(new Set<String>(quote));
        //syncgrinousSend(new Set<String>(quote));
        //queueableSend(new Set<String>(quote));
        return quote;   
     }

    /**
    *Execption class to help catch any fatal errors     
    **/
    public class Z_SendtoZBillingException extends Exception {

    }
}