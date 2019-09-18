({
    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.isOpen", false);
    },
    
    //To update lead on popup click
    processLeadOnPopup: function(component, event, helper){
        
        component.set("v.Spinner",true);
        var interval;
        var formSubmissionId = component.get('v.formSubmissionId');
        console.log('clicked');
        //check if we have valid form submission id, if we don't add interval
        if($A.util.isEmpty(formSubmissionId)){
            console.log('Interval set');
            //Set interval to check if get valid form submission id after every 5 sec
            interval =  setInterval(function(){ helper.updateLeadHelper(component, event,helper);
                                              },
                                    5000);
            component.set('v.interval',interval);
            
        }
        else{
            //if we have valid form submission id update lead without adding interval
            helper.updateLeadHelper(component, event, helper);
        }
        var eUrl= $A.get("e.force:navigateToURL");
        var link = component.get("v.popUpImageLink");
        eUrl.setParams({
            "url": link
        });
        eUrl.fire();
        
        
    },
    
    handelFormId: function(component, event, helper){
        console.log('event is called');
        var formId = event.getParam("formSubmissionId");
        console.log('set form id>>'+formId);
        component.set("v.formSubmissionId",formId);        
    }
})