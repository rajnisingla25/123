({
    doInit: function(component, event, helper) {
        
        //setSubmissionType = getSubmissionType;

        // Prepare a new record from template
        var appEvent = $A.get("e.c:ConfigurationEvent"); 
        //Set event attribute value
        appEvent.setParams({"product" : component.get('v.productType'), "submissionType" : component.get('v.submissionType'), "popUpProduct" : component.get('v.popUpProductType'), "campaignId" : component.get('v.campaignId')});
        appEvent.fire();
    },
    /*changeConfig : function(component, event, helper) {
        //var newValue = event.getParam("value");
        //var oldValue = event.getParam("oldValue");
        //alert("Expense name changed from '" + oldValue + "' to '" + newValue + "'");
        var appEvent = $A.get("e.c:ConfigurationEvent"); 
        //Set event attribute value
        appEvent.setParams({"product" : event.getParam("value")});
        console.log('event.getParam("value")>>'+event.getParam("value"));
        appEvent.fire();
    }*/
})