({
	doInit : function(component, event, helper) {
        var record = component.get("v.recordId");
        helper.fetchSsoDetails(component,record);
    },
    resetAttempts : function(component, event, helper) {
        helper.resetLoginAttempts(component);
    },
    releaseSsoEmail: function(component, event, helper) {
        var advid = component.get('v.lstAcc2[0].accounts.user_id');
        var c = confirm("Are you sure of releasing the SSO email associated with advertiser : "+advid+" ?");
        if(c){
            helper.releaseEmailForAdvId(component,advid);
        }
    },
     scriptsLoaded : function(component, event, helper) {
        console.log('Script loaded..'); 
    }
})