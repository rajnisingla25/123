({
    doInit : function(component,event,helper){
		
    },
    scriptsLoaded : function(component, event, helper) {
        var message = "New Issues";
		helper.fetchcaseinfo(component,message);
        console.log('Script loaded..'); 
    },
    waiting: function(component, event, helper) {
    	document.getElementById("Accspinner").style.display = "block";
 	},
 
   doneWaiting: function(component, event, helper) {
   		document.getElementById("Accspinner").style.display = "none";
 	},
    handleComponentEvent: function(component,event,helper){
        var message = event.getParam("message");
		helper.fetchcaseinfo(component,message);
    }
})