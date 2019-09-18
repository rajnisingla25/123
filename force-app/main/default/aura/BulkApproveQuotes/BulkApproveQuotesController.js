// $Label.c.BulkApproval_No_QP_Allowed
({
	doInit : function(component, event, helper) {
    	helper.fetchQuotes(component);
    },
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
            switch (action.name) {
                case 'viewProducts':
                    component.set("v.pQuoteId", row.Name);
                    break;
                case 'viewQuote':
                    if(sforce.console.isInConsole()){
                    	sforce.console.openPrimaryTab(undefined , row.cpqEditUrl, true, row.Name, null);
                    }
                    else {
                    	window.open(row.cpqEditUrl, '_blank');
                    }
                    break;
            }
	},
    submit : function(component, event, helper) {
        helper.submitQuoteToCPQ(component);
    },
    handleSelect : function(component, event, helper) {
        var selectedRows = event.getParam('selectedRows'); 
        var setRows = [];
        var total = 0;
        for ( var i = 0; i < selectedRows.length; i++ ) {
            setRows.push(selectedRows[i].Id);
            total += selectedRows[i].numOfProducts;
        }
        component.set("v.selectedQuotes", setRows);
        component.set("v.totalProds", total);
    },
    handleSave: function(component, event, helper) {
        helper.updateQuotes(component);
    },
})