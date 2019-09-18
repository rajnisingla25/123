({
	fetchReport : function(component) {
        var spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");  
		var action = component.get("c.updateReportCount");
        var report = component.get("v.report");
        action.setParams({name : report.name});
        report.count=null;
        component.set("v.report", report);
        action.setCallback(this, function (response) {
            var state = response.getState();
            var report = component.get("v.report");
            report.count = -1;
            if (state === "SUCCESS") {
                var r = response.getReturnValue();
                report.count = r.count;
                report.lastRunDateTime = r.lastRunDateTime;
                component.set("v.report", report);
            }
            if (report.count < 0) {
                report.count = null;
                alert('Failed to run report ' + report.name + ', please contact Salesforce Admin!');
            }
            $A.util.addClass(spinner, "slds-hide");
        });
        if (component.get("v.background")) {
        	action.setBackground();
        }
        $A.enqueueAction(action);
	},
    sendEmail : function(component) {
        var spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");  
		var action = component.get("c.sendEmailSingleReport");
        var report = component.get("v.report");
        action.setParams({rep : report});
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