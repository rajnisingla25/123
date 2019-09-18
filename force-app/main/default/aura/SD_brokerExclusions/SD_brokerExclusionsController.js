({
	doInit : function(component, event, helper) {
        var record = component.get("v.recordId");
		helper.fetchBrokerExclusions(component,record);
    },
    scriptsLoaded : function(component, event, helper) {
        console.log('Script loaded brokerrr..'); 
    }
})