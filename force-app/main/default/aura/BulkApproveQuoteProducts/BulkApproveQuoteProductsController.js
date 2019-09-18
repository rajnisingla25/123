({
	doInit : function(component, event, helper) {
		helper.fetchColumns(component);
    },
    onQuoteIdChange : function(component, event, helper) {
        helper.fetchQuoteProducts(component);
    }
})