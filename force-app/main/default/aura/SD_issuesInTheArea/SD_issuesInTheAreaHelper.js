({
	fetchIssues : function(component,recordId) {
		console.log('recordId-->' + recordId);
        
		var action = component.get('c.fetchIssues');
		action.setParams({
			recordId: recordId
		});
        action.setCallback(this, function (response) {
            var state = response.getState();
			console.log('stateissue-->' + state);
            if (state === "SUCCESS") {
                component.set('v.lstCases', response.getReturnValue());
                console.log("issuessss"+response.getReturnValue());
                
                setTimeout(function(){ 
                    $('#issuesTable').DataTable();
                    // add lightning class to search filter field with some bottom margin..  
                    $('div.dataTables_filter input').addClass('slds-input');
                    $('div.dataTables_filter input').css("marginBottom", "10px");
                }, 500); 

            }
        });
        $A.enqueueAction(action);
	}
})