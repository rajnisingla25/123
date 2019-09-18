({
	doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
		helper.fetchIssues(component,recordId);
    },
     scriptsLoaded : function(component, event, helper) {
        console.log('Script loaded..'); 
    },
    linkRedirect : function(component, event, helper) {
        var caseid = event.target.id;
        if(sforce.console.isInConsole()){
            sforce.console.openPrimaryTab(null, '/'+caseid,true);
        } else {
            window.open("/"+caseid, '_blank')
        }
    }
})