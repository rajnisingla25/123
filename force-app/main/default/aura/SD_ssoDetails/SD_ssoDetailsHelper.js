({  
    fetchSsoDetails : function(component,recordId) {
		console.log('recordId-->' + recordId);

		var action = component.get('c.fetchSsoDetails');
		action.setParams({
			recordId: recordId
		});
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('response----'+response.getReturnValue());
                try{
                    if(JSON.parse(response.getReturnValue()).err != null){
                        $(".alert-info").html(JSON.parse(response.getReturnValue()).err.messages);
                        $(".alert-info").parent().attr("hidden", false);
                        $(".alert-info").addClass("slds-text-color_error");
                        $(".sso-btn").attr("disabled",true);
                    } else {
                        component.set('v.lstAcc1', JSON.parse(response.getReturnValue()).rows);
                        component.set('v.lstAcc2', JSON.parse(response.getReturnValue()));
                        if(JSON.parse(response.getReturnValue()).credMissing == "true"){
                            $(".alert-info").html("Advertiser ID is not linked to any SSO");
                            $(".alert-info").parent().attr("hidden", false);
                            $(".sso-btn").attr("disabled",true);
                        } else {
                             $(".alert-info").parent().attr("hidden", true);
                             $(".alert-info").removeClass("slds-text-color_error");
                        }
                    }
                } catch(e){
                    console.log("Exception"+e)
                }
                
            }
        });
        $A.enqueueAction(action);
	},
    
    resetLoginAttempts : function(component) {
		var action = component.get('c.resetLoginAttempts');
		action.setParams({
			email: component.get('v.lstAcc1[0].email')
		});
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('response----'+response.getReturnValue());
                if(JSON.parse(response.getReturnValue()).email == component.get('v.lstAcc1[0].email')){
                    alert("Success")
                } else {
                    alert("Error occurred, contact administrator");
                }
            } else {
                alert("Error occurred, contact administrator");
            }
        });
        $A.enqueueAction(action);
	},
    releaseEmailForAdvId : function(component,advid) {
		var action = component.get('c.releaseEmailForAdvId');
        console.log("adv---"+advId);
		action.setParams({
			advId: advid.toString()
		});
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('response----'+response.getReturnValue()+component.get("v.recordId"));
                if((JSON.parse(response.getReturnValue()).messages) != null){
                    if((JSON.parse(response.getReturnValue()).messages).includes("SSO is freed up from the account")){
                     alert("Email released successfully from advertiser :"+advid);
                    } else {
                         alert(JSON.parse(response.getReturnValue()).messages);
                    }
                   this.fetchSsoDetails(component,component.get("v.recordId"));
               } else {
                alert("Error occurred, contact administrator");
               }
            } else {
                alert("Error occurred, contact administrator");
            }
        });
        $A.enqueueAction(action);
	},
})