({
	fetchBrokerExclusions : function(component,recordId) {
		console.log('recordId-->' + recordId);
		var action = component.get('c.fetchBrokerExclusions');
		action.setParams({
			recordId: recordId
		});
        action.setCallback(this, function (response) {
            var state = response.getState();
			console.log('state-->' + state);
            if (state === "SUCCESS") {
                component.set('v.lstAccRel', response.getReturnValue());
                console.log(response.getReturnValue());

                  setTimeout(function(){ 
                    $('#account-table').DataTable();
                }, 500); 
            }
        });
        $A.enqueueAction(action);
	}
})