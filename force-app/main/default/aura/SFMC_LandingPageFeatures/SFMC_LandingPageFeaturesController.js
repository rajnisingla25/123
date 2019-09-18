({
	doInit : function(component, event, helper) {
        var prefixString = $A.get('$Resource.LandingPageImages') + '/assets/images/';
        component.set('v.prefixString', prefixString);
		
	}
})