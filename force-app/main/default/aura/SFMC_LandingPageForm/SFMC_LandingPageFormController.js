({
    doInit: function(component, event, helper) {
        helper.getFormSubmissionRecord(component, event, helper,true);
        var c = "~`!@#$%&*()+=-[]';,/{}|:<>?";
        component.set('v.specialChars',c);
    },
    
    saveFormSubmission: function(component, event, helper) {  
        helper.handlePopUp(component, event, helper);
    },
    
    handleValueChange : function (component, event, helper) {
        //Get the event message attribute
        var product = event.getParam("product");
        var submissionType = event.getParam("submissionType");
        var popUpProduct = event.getParam("popUpProduct"); 
        var campaignId = event.getParam("campaignId");
        component.set('v.productType',product);
        component.set('v.submissionType',submissionType);
        component.set('v.popUpProduct',popUpProduct);
        component.set('v.campaignId',campaignId);
    },
    
    changePhoneNumber : function (component, event, helper) {  
        helper.changePhoneNumber(component, event, helper);
    }
})