import { LightningElement,api,track} from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import PAYMENT_PROFILE_OBJECT from '@salesforce/schema/PaymentProfiles__c';
import ABA_CODE  from '@salesforce/schema/PaymentProfiles__c.ACH_ABA_Code__c';
import CC_NUMBER from '@salesforce/schema/PaymentProfiles__c.ACH_Account_Number_Mask__c';
import EXP_DATE  from '@salesforce/schema/PaymentProfiles__c.ExpirationDate__c';
import ACC_ID    from '@salesforce/schema/PaymentProfiles__c.Account__c';
import PAYMETHOD_ID    from '@salesforce/schema/PaymentProfiles__c.PaymentMethodId__c';
import PAYMENT_TOKEN    from '@salesforce/schema/PaymentProfiles__c.Payment_Token__c';
import CC_TYPE    from '@salesforce/schema/PaymentProfiles__c.CreditCardType__c';


export default class lwcforLightningout extends LightningElement 
{
 @api pageSource;
 @api responseCode;
 @api abaCode;
 @api ccNumber;
 @api expDate;
 @api accountId;
 @api paymethodId;
 @track displayMessage = '';
 @track payprofileId = '';
 @api paymentToken;
 @api cardType;

constructor(){
  super();
} 
 
renderedCallback(){
  if(this.responseCode === '100' && this.displayMessage.length === 0 ){
    console.log(' Response code is 100 ');
    this.createPaymentProfile();
  }

  if(this.displayMessage.length !== 0){
  console.log(' Display lenght is greater then Zero '+this.pageSource);
   // var parent_window = "https://moveinc--dev--c.cs79.visual.force.com";
   var parent_window = "https://moveinc--rdev--c.cs37.visual.force.com";
   var postMsg = this.pageSource +';'+this.displayMessage;
   // var url = "https://moveinc--dev.lightning.force.com";
    window.postMessage(postMsg,parent_window);
  }

}

createPaymentProfile() {
  const fields = {};
  fields[ABA_CODE.fieldApiName]   = this.abaCode;
  fields[CC_NUMBER.fieldApiName]  = this.ccNumber;
  fields[EXP_DATE.fieldApiName]   = this.expDate;
  fields[ACC_ID.fieldApiName]     = this.accountId;
  fields[PAYMETHOD_ID.fieldApiName]  = this.paymethodId;
  fields[PAYMENT_TOKEN.fieldApiName]     = String(this.paymentToken);

  fields[CC_TYPE.fieldApiName]  = (this.cardType === 1)? 'Visa':(this.cardType === 2)? 'Mastercard':(this.cardType === 3)? 'American Express':(this.cardType === 4)? 'Discover':'NA';
  

  console.log(' *** this.paymentToken *** '+this.paymentToken+' this.cardType ***  '+fields[CC_TYPE.fieldApiName]);

console.log(' API name is'+ PAYMENT_PROFILE_OBJECT.objectApiName);
  const recordInput = { apiName: PAYMENT_PROFILE_OBJECT.objectApiName, fields };
  createRecord(recordInput)
      .then(paymentProfiles => {
          this.payprofileId = paymentProfiles.id;
          console.log(' pay profile created succesfully '+this.payprofileId);
          this.displayMessage = ' Payment Profile Created Successfully '+ this.payprofileId;
          this.dispatchEvent(
              new ShowToastEvent({
                  title: 'Success',
                  message: 'Payment Profile created',
                  variant: 'success',
              }),
          );
      })
      .catch(error => {
        console.log(' dml failed **'+JSON.stringify(error));
        this.displayMessage = ' Payment Profile failed to create due to: '+ error["body"].message;      
       // console.log(' error while creating pay profile -1111 '+error["body"]["output"]["errors"][0].message);
          this.dispatchEvent(
              new ShowToastEvent({
                  title: 'Error creating record',
                  message: error.body.message,
                  variant: 'error',
              }),
          );
      });
}

}