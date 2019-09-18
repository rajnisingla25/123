({
	fetchOpenCases : function(component,recordId) {
		console.log('recordId-->' + recordId);
		var action = component.get('c.fetchOpenCases');
		action.setParams({
			recordId: recordId
		});
        action.setCallback(this, function (response) {
            var state = response.getState();
			console.log('state-->' + state);
            if (state === "SUCCESS") {
                component.set('v.lstCases', response.getReturnValue());
                console.log(response.getReturnValue());

                  setTimeout(function(){ 
                    $('#casesTable').DataTable();
                    // add lightning class to search filter field with some bottom margin..  
                    $('div.dataTables_filter input').addClass('slds-input');
                    $('div.dataTables_filter input').css("marginBottom", "10px");
                }, 500); 
            }
        });
        $A.enqueueAction(action);
	}
})