({
	doInit : function(component, event, helper) {
    	helper.fetchReportNames(component);
    },
    sendEmail : function(component, event, helper) {
    	helper.sendEmail(component);
    },
    fetchForeground : function(component, event, helper) {
      	component.set("v.background", false);
    },
 	fetchBackground : function(component, event, helper) {
    	component.set("v.background", true);       
   },
})