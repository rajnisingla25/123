({
	fetchCategories : function(component) {
        var spinner = component.find("spinner");
    	$A.util.removeClass(spinner, "slds-hide");  
   		var action = component.get("c.getCategories");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resultData = response.getReturnValue();
                component.set("v.categories", resultData);
            }
            else {
                alert('Something went wrong, please contact Salesforce Admin!');
            }
            $A.util.addClass(spinner, "slds-hide");
        });
        $A.enqueueAction(action);
	},
})