({
	doInit : function(component, event, helper) {
        var styleString = "<style>.siteforceStarterBody .cCenterPanel {margin-top : 0;max-width: none;padding-left: 0rem;padding-right: 0rem;}<style>"
		component.set('v.customClassOverride', styleString);
	}
})