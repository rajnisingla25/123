({
    updateLeadHelper : function(component,event,helper) {
        
        var popupProductType = component.get('v.popupProductType');
        var formSubmissionId = component.get('v.formSubmissionId');
        var interval = component.get('v.interval');
        if($A.util.isEmpty(formSubmissionId)){
            console.log('invalid formsubmission');
        }
        else{
            //we have valid form submission id, check if interval is set and clear the interval to prevent recurssion
            if(!$A.util.isEmpty(interval)){
                clearInterval(interval);
            }
            
            console.log('valid formsubmission');
            //call sever side controller to update lead
            var updateLead = component.get('c.updateLeadforProdType');
            updateLead.setParams({
                formSubmissionId : formSubmissionId,
                popupProductType : popupProductType
            });
            console.log('updateLead>>'+updateLead);
            console.log('formSubmissionId>>'+formSubmissionId);
            console.log('popupProductType>>'+popupProductType);
            //debugger;
            //check call back if call back is successful close the popup
            updateLead.setCallback(helper, function(data){
                //debugger;
                component.set('v.isOpen',false);
                console.log('state>>'+data);
                if (data.getState() === "SUCCESS") {
                    component.set("v.Spinner",false);
                }
                else{
                    console.log('result>>'+data.getReturnValue());
                }
            });
            $A.getCallback(function() { $A.enqueueAction(updateLead); })();
        }
    }
})