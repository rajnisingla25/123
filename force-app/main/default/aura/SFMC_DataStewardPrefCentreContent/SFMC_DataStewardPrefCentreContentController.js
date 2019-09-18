({
    doInit : function(component, event, helper) {
        
        
        if($A.util.isEmpty(helper.getUrlParameter('contactMethodId'))){
            component.set('v.contactMethodIdErrorMsg',$A.get("$Label.c.Invalid_record_in_preference_center_UI"));
            component.set('v.contactMethodIdError',true);
        }
       	
        else{
            component.set('v.contactMethodId',helper.getUrlParameter('contactMethodId'));
        }
        if($A.util.isEmpty(helper.getUrlParameter('userId'))){
            component.set('v.noAccessMsg',$A.get("$Label.c.SFMC_Community_Access"));
            //component.set('v.noAccess',true);
        }else{
            component.set('v.userId',helper.getUrlParameter('userId'));
        }
        
        helper.getUserType(component);
        helper.businessUnitCheck(component,helper);  
    },
    
    fetchEventValue : function(component,event,helper){
        var showConfirmationPage = event.getParam('showConfirmationPage');
        component.set('v.showConfirmationPage', showConfirmationPage);
    },
    
    updatePreferences : function(component,event,helper){
        helper.updatePreferences(component, helper);
    }
})