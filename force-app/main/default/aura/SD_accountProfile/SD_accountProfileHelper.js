({
	fetchAccountInfo : function(component,recordId) {
		console.log('recordId-->' + recordId);
		var action = component.get('c.fetchAccountInfo');
		action.setParams({
			recordId: recordId
		});
        action.setCallback(this, function (response) {
            var state = response.getState();
			console.log('state-->' + state);
            if (state === "SUCCESS") {
                component.set('v.lstAcc', response.getReturnValue());
                console.log(response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
    
    fetchRelationshipInfo : function(component,recordId) {
		console.log('recordId-->' + recordId);
		var action = component.get('c.fetchRelationshipInfo');
		action.setParams({
			recordId: recordId
		});
        action.setCallback(this, function (response) {
            var state = response.getState();
			console.log('state-->' + state);
            if (state === "SUCCESS") {
                component.set('v.lstAccRel', response.getReturnValue());
                console.log(response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	}
})