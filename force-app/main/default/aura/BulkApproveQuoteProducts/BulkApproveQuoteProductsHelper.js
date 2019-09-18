({
	fetchColumns : function(component) {
   		var action = component.get("c.fetchQuoteProductsColumns");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resultData = response.getReturnValue();
                component.set("v.columns", resultData);
                console.log(JSON.stringify(resultData));
            }
            else {
                alert('Something went wrong, please contact Salesforce Admin!');
            }
        });
        $A.enqueueAction(action);
	},
    fetchQuoteProducts : function(component) {
        var quoteId = component.get("v.cQuoteId");
        if (quoteId != null && quoteId != "") {
            var spinner = component.find("spinner");
            $A.util.removeClass(spinner, "slds-hide"); 
            var action = component.get("c.fetchQuoteProducts");
            action.setParams({ quoteId : component.get("v.cQuoteId") });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var resultData = response.getReturnValue();
                    component.set("v.quoteProducts", resultData);
                    console.log(JSON.stringify(resultData));
                }
                else {
                	alert('Something went wrong, please contact Salesforce Admin!');
            	}
                $A.util.addClass(spinner, "slds-hide");
            });
            $A.enqueueAction(action);
       }
        else {
            component.set("v.quoteProducts", null);
        }
	},
})