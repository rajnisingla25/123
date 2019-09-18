({
	doInit : function(component, event, helper) {
		var brandType = component.get("v.brandType");
        var userId = component.get("v.userId");
        var brandTopProducer = $A.get("$Label.c.SFMC_Brand_Top_Producer");
        var brandRDC = $A.get("$Label.c.SFMC_Brand_RDC");
        var brandEvents = $A.get("$Label.c.SFMC_Brand_Events");        
        if(brandType == brandTopProducer && $A.util.isEmpty(userId)){
            component.set('v.confirmationHeader','We\'ve made the changes to your Top Producer® email subscriptions!');
           	component.set('v.confirmationSubHeader1','You\'ve successfully changed your Top Producer® email subscriptions.');
            component.set('v.confirmationSubHeader2','Did you make a mistake? ');
        }
        else if(brandType == brandRDC && $A.util.isEmpty(userId)){
            component.set('v.confirmationHeader','We\'ve made the changes to your realtor.com® email subscriptions!');
           	component.set('v.confirmationSubHeader1','You\'ve successfully changed your realtor.com® email subscriptions.');
            component.set('v.confirmationSubHeader2','Did you make a mistake? ');
        }
        else if(!$A.util.isEmpty(brandType) && !$A.util.isEmpty(userId)){
            component.set('v.confirmationHeader','We\'ve made the changes to your Top Producer® and realtor.com® email subscriptions!');
           	component.set('v.confirmationSubHeader1','You\'ve successfully updated your email subscriptions.');
            component.set('v.confirmationSubHeader2','Did you make a mistake? ');
        }
        
	},
    handelClick : function(component, event, helper){
        var evt = $A.get("e.c:SFMC_PreferenceEvent");
        console.log('evt'+evt);
        evt.setParams({
            showConfirmationPage: false
        });
        evt.fire();
    }
})