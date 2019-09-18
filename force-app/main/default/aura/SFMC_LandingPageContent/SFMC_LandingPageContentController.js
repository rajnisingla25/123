({
    doInit : function(component, event, helper) {
        var prefixString = $A.get('$Resource.LandingPageImages') + '/assets/images/';
        component.set('v.prefixString', prefixString);
        
        var vars = {};
        var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
            vars[key] = value;
        });
        component.set('v.urlParamMap', vars);
        console.log('LP submissionType >>'+component.get('v.submissionType'));
    }
})