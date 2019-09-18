({
toggleButton : function(component, event, helper) {
if(label == 'fa fa-chevron-down') {
    component.set("v.toggleIcon","fa fa-chevron-up");
    $A.util.addClass(component.find("toggleArea"), "slds-hide");
}else {
    component.set("v.toggleIcon","fa fa-chevron-down");
    $A.util.removeClass(component.find("toggleArea"), "slds-hide");
}
}
})