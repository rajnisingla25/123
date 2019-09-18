({
	doInit : function(component, event, helper) {
        var record = component.get("v.recordId");
		helper.fetchAccountInfo(component,record);
        helper.fetchRelationshipInfo(component,record);
	},
    linkRedirect : function(component, event, helper) {
        var acctid = event.target.id;
        if(sforce.console.isInConsole()){
            sforce.console.openPrimaryTab(null, '/'+acctid,true);
        } else {
            window.open("/"+acctid, '_blank')
        }
    }
})