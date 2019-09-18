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
    },
    displayFriend2 : function(component, event, helper) {
        component.set("v.displayFriendSection2","section2");
         var addMore = component.find("addMoreDiv");
        $A.util.toggleClass(addMore, "slds-hide");
        
       
    },
    displayFriend3 : function(component, event, helper) {
        component.set("v.displayFriendSection3","section3");
         var addMore2 = component.find("addMoreDiv3");
        $A.util.toggleClass(addMore2, "slds-hide");
    },
   displayFriend4 : function(component, event, helper) {
        component.set("v.displayFriendSection4","section4");
         var addMore3 = component.find("addMoreDiv4");
        $A.util.toggleClass(addMore3, "slds-hide");
    },
    displayFriend5 : function(component, event, helper) {
        component.set("v.displayFriendSection5","section5");
         var addMore4 = component.find("addMoreDiv5");
        $A.util.toggleClass(addMore4, "slds-hide");
    }
    
})