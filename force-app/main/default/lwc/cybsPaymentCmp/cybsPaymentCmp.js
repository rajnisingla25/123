import { LightningElement,api, wire,track } from 'lwc';
import getPaymentData from '@salesforce/apex/PaymentProfileController.getPaymentData';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';


const cols = [
    { label: 'Name', fieldName: 'Name', editable: false},
    { label: 'Type', fieldName: 'CreditCardType__c',type: 'text' , editable: false},
    { label: 'Reason Code', fieldName: 'Reason_Code__c',type: 'text' , editable: false},
    { label: 'Expiration Date', fieldName: 'Expiration_Date__c',type:'date' , editable: false},
    { label: 'Mask Number', fieldName: 'ACH_Account_Number_Mask__c',type: 'text' , editable: false},
    { label: 'Split Percentage', fieldName: 'SplitPercentage__c',type: 'percent' , editable: true}
];

export default class cybsPayment extends NavigationMixin(LightningElement) {
   
    @track columns = cols;
    @track draftValues = [];
    @track paymentRecords;
    wiredContactResult; // a new variable was introduced
    @track msg;

    constructor(){
        super();
        this.accId = this.getQueryParameters();
        console.log(' *** this.accId *** '+this.accId);
    }

    @wire(getPaymentData,{accId:'$accId'})
    imperativeWiring(result) {
        this.wiredContactResult = result;
        if(result.data) {
            this.paymentRecords = result.data;
            this.error = undefined;
        }else if (result.error) {
            this.error = result.error;
            this.paymentRecords = undefined;
        }
    } 

    sendData(){
       var iframeId = this.template.querySelector('.cybsiFrame');
       console.log(' *** iframeId *** '+iframeId);
       iframeId.src = '/c/cybsPaymentPage.app?id='+this.accId+'&pagesource=paymentProfileManager';
       var buttonHide = this.template.querySelector('.addCCbutton');
       buttonHide.hidden = true;      
    }

    getQueryParameters(){
        var params = {};
        var search = window.location.search.substring(1);
        if (search) {
            params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                return key === "" ? value : decodeURIComponent(value)
            });
        } 
        console.log(' *** params *** '+params);
        return params["id"];
    } 


    handleSave(event) {
        console.log('Entered to save ');
        const recordInputs =  event.detail.draftValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            return { fields };
        });
    
        console.log(' * recordInputs *  '+recordInputs);
        const promises = recordInputs.map(recordInput => updateRecord(recordInput));
        Promise.all(promises).then(paymentRecords => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Payment Profiles updated',
                    variant: 'success'
                })
            );
             // Clear all draft values
             this.draftValues = [];
    
             // Display fresh data in the datatable
             console.log(' *** Refresh acc Id ** '+JSON.stringify(this.paymentRecords));
              return refreshApex(this.wiredContactResult);
             // this.dispatchEvent(new CustomEvent('recordChange'));

        }).catch(error => { 
            console.log(' Error occured while saving'+JSON.stringify(error));
        });
    }

}