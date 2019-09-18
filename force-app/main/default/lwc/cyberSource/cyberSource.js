import { LightningElement,api, wire,track } from 'lwc';
import getData from '@salesforce/apex/CybersourceRequestDetails.getData';
export default class CyberSource extends LightningElement {

    @track endPoint;
    accountId;
    pageSource;
    @track errorMessage;
    
    constructor(){
        super();
        this.getQueryParameters();
        
        console.log(' *** this AccountId *** '+this.accountId+' *** pagesource *** '+this.pageSource);
        console.log(' *** cybersource page - location *** '+window.location);
    }
   
    @wire(getData,{accountId:'$accountId',pageSource:'$pageSource'})
    wiredData({ error, data }) {
        if (data) {
         console.log(' *** data.parameterValues '+data.ParametersValues);
          this.template.querySelector('div').innerHTML =data.ParametersValues; 
          this.errorMessage = data.errorMessage;
          console.log(' error msg is '+this.errorMessage);
          var formId = this.template.querySelector('.payment_confirmation');
          formId.attributes[1].value=data.EndPoint;
          
          if(this.errorMessage.length === 0){
            this.template.querySelector('.submit').click();
          }
         
        } else if (error) {
            this.error = error;
        }
    }

    getQueryParameters(){
        var params = {};
        var search = window.location.search.substring(1);
        if (search) {
            params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                return key === "" ? value : decodeURIComponent(value)
            });
        } 
        console.log(' *** params *** '+JSON.stringify(params));
        console.log(' *** params page source *** '+params["pagesource"]);

        this.pageSource = params["pagesource"] === undefined? 'null':params["pagesource"];

        this.accountId =  params["id"];
        //return params["id"];
    } 

}