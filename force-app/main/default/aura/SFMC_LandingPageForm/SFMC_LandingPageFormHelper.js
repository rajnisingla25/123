({
    getFormSubmissionRecord : function(component, event, helper,isFromInit) {
        component.find("formSubmissionRecordCreator").getNewRecord(
            "Form_Submission__c", // sObject type (entityAPIName)
            null,      // recordTypeId
            true,     // skip cache?
            $A.getCallback(function() {
                var rec = component.get("v.newFormSubmission");
                var error = component.get("v.newFormSubmissionError");
                
                if(error || (rec === null)) {
                    console.log("Error initializing record template: " + error);
                }
                else {
                    helper.populateAllValues(component, event, helper,isFromInit);
                }
            })
        );
    },

    handlePopUp: function(component, event, helper){
        var action = component.get('c.enableDisablePopUp');
        action.setCallback(this,function(data){
            if(data.getState() === 'SUCCESS'){
                component.set('v.enablePopUp',data.getReturnValue());
                this.handleSaveFormSubmission(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },

    handleSaveFormSubmission: function(component, event, helper) {        
        component.set("v.showValidationError",false);
        
        var allValid = component.find('contactField').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);

        
        if (allValid) {
            var newFormSubmissionObj = component.get("v.simpleNewFormSubmission");
            if($A.util.isEmpty(newFormSubmissionObj.Email__c) && $A.util.isEmpty(newFormSubmissionObj.Phone__c) ){
                allValid = false;
                component.set("v.errorMessage",$A.get("$Label.c.SFMC_Email_or_phone_Validation"));
                component.set("v.showValidationError",true);
            }else{
                var urlParam = component.get('v.urlParamMap');
                var urlParamStr = JSON.stringify(urlParam);
                var newFormSubmissionObjStr = JSON.stringify(newFormSubmissionObj);
                var saveAction = component.get('c.saveFormSubmissionRecord');

                saveAction.setParams({
                    urlParam : urlParamStr,
                    formSubmissionRecord : newFormSubmissionObj
                });
                saveAction.setCallback(this,function(data){
                    if(data.getState() === "SUCCESS"){
                        var appEvent = $A.get("e.c:SFMC_FormIdEvent");
                        appEvent.setParams({"formSubmissionId" : data.getReturnValue().Id});
                        appEvent.fire();
                    }
                });
                $A.enqueueAction(saveAction);
                component.set("v.isOpen",true);
                component.set("v.showThankYou",true);
                var thankYouMessageData = component.get('v.simpleNewFormSubmission');
                component.set('v.firstName',thankYouMessageData.First_Name__c);
                component.set('v.lastName',thankYouMessageData.Last_Name__c);
                component.set('v.emailId',thankYouMessageData.Email__c);
                component.set('v.phoneNumber',thankYouMessageData.Phone__c);

                helper.getFormSubmissionRecord(component, event, helper,false);                
            }
        }else{
            console.log('Error in form validation');           
        }
    },
    
    populateAllValues : function(component, event, helper,isFromInit){
        if(isFromInit){
        var vars = {};
        var pageURL = window.location.href;
        var parts = pageURL.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
            vars[key] = value;
        });
        
        component.set('v.urlParamMap', vars);
            var action = component.get('c.getPicklistValues');
            action.setParams({
                cmId : vars.contactMethodId
            });
            action.setCallback(this, function(data){
                if (data.getState() === "SUCCESS") {
                    var returnValue = data.getReturnValue();
                    component.set('v.picklistLabelvalueMap', returnValue);
                    component.set('v.optionList', JSON.parse(returnValue['valuesInSequence']));
                    helper.populateValueForParam(component, returnValue,event,helper,isFromInit);
                }else if (data.getState() === "ERROR"){
                    var errors = data.getError();
                    console.log('errors = ' +errors);
                    if (errors) {
                        for(var i=0; i < errors.length; i++) {
                            console.log('page errors = ' +errors[i].pageErrors );
                            console.log('page errors = ' +errors[i].fieldErrors );
                            console.log('message errors = ' +errors[i].message );
                        }
                    }
                }
            });       
            $A.enqueueAction(action);
        }
        else{
            helper.populateValueForParam(component, component.get('v.picklistLabelvalueMap'),event,helper,isFromInit);
        }
    },
	
    
    populateValueForParam : function(component, picklistLabelvalueMap,event,helper,isFromInit){
        var vars = {};
        var selectedValue = '';
        var pageURL = window.location.href;
        var path = window.location.pathname;
        var parts = pageURL.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
            vars[key] = value;
        });
        component.set('v.urlParamMap', vars);
        var page = path.split('/')[1];
        var dynamicBu = 'https://'+window.location.hostname+'/'+page;

        
        var simpleNewFormSubmission2 = component.get('v.simpleNewFormSubmission');
        var simpleNewFormSubmission = JSON.parse(JSON.stringify(simpleNewFormSubmission2));
        
        //Pre-populate values if contact method id is provided from url
        
        simpleNewFormSubmission.Email__c = picklistLabelvalueMap['Email__c'];
        simpleNewFormSubmission.First_Name__c = picklistLabelvalueMap['First_Name__c'];
        simpleNewFormSubmission.Last_Name__c = picklistLabelvalueMap['Last_Name__c'];
        simpleNewFormSubmission.Phone__c = picklistLabelvalueMap['Phone__c'];
        
        simpleNewFormSubmission.URL__c = pageURL.split('?')[0];
        
        //Set business unit value
        if(picklistLabelvalueMap[dynamicBu] != null){
            simpleNewFormSubmission.Business_Unit__c = picklistLabelvalueMap[dynamicBu];
        }
        else if(picklistLabelvalueMap[pageURL.split('/')[2]] != null){
            simpleNewFormSubmission.Business_Unit__c = picklistLabelvalueMap[pageURL.split('/')[2]];
        }
        // Set RDC Contact Type field on form submission
        if(!$A.util.isEmpty(selectedValue)){
            simpleNewFormSubmission.RDC_Contact_Type__c = selectedValue;
        }
        else if(!$A.util.isEmpty(vars.rtype) && picklistLabelvalueMap[vars.rtype] != null){
            simpleNewFormSubmission.RDC_Contact_Type__c = picklistLabelvalueMap[vars.rtype];
        }
        
        else if(picklistLabelvalueMap['defaultVal'] != null){
            simpleNewFormSubmission.RDC_Contact_Type__c = picklistLabelvalueMap['defaultVal'];
        }

        component.set('v.simpleNewFormSubmission', simpleNewFormSubmission);
        component.set('v.selectedValue', selectedValue);
        if(isFromInit){
          var getSubmissionType = component.get('v.submissionType');
		  
          var productTypeDecode = $A.util.isEmpty(vars.product_type) ? vars.product_type : decodeURIComponent((vars.product_type + '').replace(/\+/g, '%20'));
           var getProductType =  component.get('v.productType');
            if(!$A.util.isEmpty(productTypeDecode)){
               getProductType  =  productTypeDecode;
            }
          
          var getCampignId = vars.utm_campaign_id != undefined ? vars.utm_campaign_id : component.get('v.campaignId');
          component.find('stId').set('v.value',getSubmissionType);
          component.find('prodTypeId').set('v.value',getProductType);
          component.find('camId').set('v.value',getCampignId);
        }
    },
    
    changePhoneNumber : function(component, event, helper){
        var currentNumber = component.get("v.simpleNewFormSubmission.Phone__c");
        currentNumber = currentNumber.replace(/\D+/g, '').replace(/(\d{3})(\d{3})(\d{4})/, '($1) $2-$3');
        component.set("v.simpleNewFormSubmission.Phone__c",currentNumber);
        
        var phoneField = event.getSource();
        phoneField.setCustomValidity('');
        phoneField.reportValidity(); 
        
        var phoneLength = phoneField.get('v.value').length;
        if(phoneLength < 10 && phoneLength != 0){
            var errorLabel = $A.get("$Label.c.Phone_number_too_short");
            phoneField.setCustomValidity(errorLabel);
            phoneField.reportValidity();
            return;
        }
        if(phoneLength == 10){
            phoneField.setCustomValidity('');
            phoneField.reportValidity();
        }
    }
})