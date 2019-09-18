({
    doInit : function(component, event, helper) {
        var prefixString = $A.get('$Resource.LandingPageImages') + '/assets/images/';
        component.set('v.prefixString', prefixString);
    },
    
    setTextAlignment : function(component, event, helper){
        switch(event.getParam('oldValue')){
            case 'left':
                component.set('v.textAlignmentClass', 'slds-float_left');
                break;
            case 'right':
                component.set('v.textAlignmentClass', 'slds-float_right');
                break;
            case 'centre':
                component.set('v.textAlignmentClass', 'slds-align_absolute-center');
                break;              
        }
    },
    
    setBrandAlignment : function(component, event, helper){
        switch(event.getParam('oldValue')){
            case 'left':
                component.set('v.brandAlignmentClass', 'slds-float_left');
                break;
            case 'right':
                component.set('v.brandAlignmentClass', 'slds-float_right');
                break;
            case 'centre':
                component.set('v.brandAlignmentClass', 'slds-align_absolute-center');
                break;              
        }
    }
})