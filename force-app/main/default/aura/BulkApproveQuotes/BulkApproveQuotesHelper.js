({
    
	fetchQuotes : function(component) {
        var spinner = component.find("spinner");
        component.set("v.quotes", null);
        component.set("v.pQuoteId", null);
		$A.util.removeClass(spinner, "slds-hide");  
   		var action = component.get("c.fetchQuotes");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resultData = response.getReturnValue();
                component.set("v.quotes", resultData);
                //console.log(JSON.stringify(resultData));
                var columns = [
                	{
                        label:'Quote #', 
                     	fieldName:'cpqEditUrl', 
                        type: 'button', 
                        typeAttributes: { 
                            label: { fieldName: 'Name' }, 
                            name: 'viewQuote',
                            title: 'Click to View/Edit Quote in CPQ',
                            variant:'base',
                            width: 100
                        }
                    },
                    {
                        label: 'Comments', 
                        fieldName: 'comments', 
                        type: 'TextArea',
                        editable: true
                    },
                    {
                      type:  'button',
                      label:'# Prods',
                      typeAttributes: 
                      {
                          label: { fieldName: 'numOfProducts' }, 
                          name: 'viewProducts', 
                          title: 'Click to View Products', 
                          disabled: false, 
                          value: 'test',
                          variant:'base',
                          width: 100,
                      }
                    }
            	];
                component.set("v.columns", columns);
            }
            else {
                alert('Something went wrong, please contact Salesforce Admin!');
            }
            $A.util.addClass(spinner, "slds-hide");
        });
        $A.enqueueAction(action);
	},
    submitQuoteToCPQ : function (component) {
        var spinner = component.find("spinner");
		var records = component.get("v.selectedQuotes");
        var allowedProds = $A.get("$Label.c.BulkApproval_No_QP_Allowed");
        if (records.length == 0) {
            alert('Please select Quote(s).');
        }
        else if (component.get("v.totalProds")<=allowedProds || records.length == 1){
            $A.util.removeClass(spinner, "slds-hide");  
            var action = component.get("c.updateDummyQuote");
            action.setParams({ quoteIds : records});
            action.setCallback(this, function (response) {
                var retUrl = null;
                var state = response.getState();
                if (state === "SUCCESS") {
                    retUrl = response.getReturnValue();
                    console.log(retUrl);
                }
                if (retUrl != null) {
                    if(sforce.console.isInConsole()){
                    	sforce.console.openPrimaryTab(undefined , retUrl, true, 'Approve Quotes', null);
                    }
                    else {
                    	window.open(retUrl, '_blank');
                    }
                }
                else {
                    alert('Something went wrong, please contact Salesforce Admin!');
                }
            	$A.util.addClass(spinner, "slds-hide"); 
            });
            $A.enqueueAction(action);
        }
        else {
             alert('Only ' + allowedProds + ' Quote Products are allowed to approve at a time.');
        }
    },
    updateQuotes : function (component) {
        var spinner = component.find("spinner");
        var editedRecords =  component.find("quoteTable").get("v.draftValues");
        var quotesToUpdate = [];
        for ( var i = 0; i < editedRecords.length; i++ ) {
            var quote = {};
            quote.Id = editedRecords[i].Id;
            quote.Bulk_Approval_Comments__c = editedRecords[i].comments;
            quotesToUpdate.push(quote);
        }
        var action = component.get("c.updateQuotes");
        action.setParams({quotes : quotesToUpdate});
        $A.util.removeClass(spinner, "slds-hide"); 
        action.setCallback(this, function (response) {
            var retVal = false;
            var state = response.getState();
            if (state === "SUCCESS") {
                retVal = true;
                
                var editedRecords =  component.find("quoteTable").get("v.draftValues");
                var quotes = component.get("v.quotes");
                var newQuotes = [];
                for ( var i = 0; i < quotes.length; i++ ) {
                    var quote = quotes[i];
                    for ( var j = 0; j < editedRecords.length; j++ ) {
                        if (quote.Id == editedRecords[j].Id) {
                            quote.comments = editedRecords[j].comments;
                            break;
                        }   
                    }
                    newQuotes.push(quote);
                }
                component.set("v.quotes", newQuotes);
                
                component.find("quoteTable").set("v.draftValues", null);
                //$A.util.addClass(spinner, "slds-hide");
                //this.fetchQuotes(component);
            }
            if (retVal == false) {
                alert('Something went wrong, please contact Salesforce Admin!');
                //$A.util.addClass(spinner, "slds-hide");
            }
            $A.util.addClass(spinner, "slds-hide"); 
        });
        $A.enqueueAction(action);
    },
})