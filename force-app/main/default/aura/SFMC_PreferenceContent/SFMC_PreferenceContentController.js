({
	doInit : function(component, event, helper) {        
        
        component.set('v.brandType', helper.getUrlParameter('brand'));
        component.set('v.contactMethodId', helper.getUrlParameter('contactMethodId'));
        console.log('contactMethodId = ' + component.get("v.contactMethodId"));        
    },
    fetchEventValue : function(component,event,helper){
        var showConfirmationPage = event.getParam('showConfirmationPage');
        console.log('-->> showConfirmationPage = ' + showConfirmationPage);
        component.set('v.showConfirmationPage', showConfirmationPage);
    }
})