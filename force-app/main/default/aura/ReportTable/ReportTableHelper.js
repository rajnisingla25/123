({
	fetchReportNames : function(component) {
        var spinner = component.find("spinner");
    	$A.util.removeClass(spinner, "slds-hide");  
   		var action = component.get("c.getReportDetails");
        action.setParams({ category : component.get("v.category")});
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.reports", response.getReturnValue());
            }
            else {
                alert('Something went wrong, please contact Salesforce Admin!');
            }
            $A.util.addClass(spinner, "slds-hide");
        });
        $A.enqueueAction(action);
	},
    sendEmail : function(component) {
        var spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");  
		var action = component.get("c.sendEmailCategoryReports");
        var reports = component.get("v.reports");
        var category = component.get("v.category");
        action.setParams({category : category, reports:reports});
        action.setCallback(this, function (response) {
            var state = response.getState();
            var result = "";
            if (state === "SUCCESS") {
            	result = response.getReturnValue();
            }
            else {
                result = "Something went wrong, please contact Salesforce Admin!";
            }
            alert(result);
            $A.util.addClass(spinner, "slds-hide");
        });
        $A.enqueueAction(action);
	}
})