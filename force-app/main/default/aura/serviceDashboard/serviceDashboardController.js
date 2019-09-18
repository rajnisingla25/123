({
    doInit: function(component, event, helper) {
        helper.fetchPickListVal(component, 'Type_of_Issue__c', 'accIndustry');
    },
    onPicklistChange: function(component, event, helper) {
         var sel = component.find("accIndustry");
         var nav =	sel.get("v.value");
         console.log('selected value'+nav);
         var cmpEvent = component.getEvent("serviceDashboardEvent");
         cmpEvent.setParams({
            "message" : nav }); 
         cmpEvent.fire(); 
    }
})