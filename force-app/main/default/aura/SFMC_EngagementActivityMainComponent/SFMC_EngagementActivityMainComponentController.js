({
	doInit : function(component, event, helper) {        
		        
        helper.parseJson(component);
        
        var action1 = component.get('c.getPicklistValues'), action2 = component.get('c.getProductTypeValues');
        action2.setBackground(true);        
        action1.setCallback(this, function(data){            
            console.log('data.getState() = ' + data.getState());
            if (data.getState() === "SUCCESS") {
                var record = data.getReturnValue();
                
                component.set("v.activityType", JSON.parse(record)); 
                
                
            }else if (data.getState() === "ERROR"){
                var errors = data.getError();
                console.log('errors = ' +errors);
                
                if (errors) {
                    for(var i=0; i < errors.length; i++) {
                        console.log('page errors = ' +errors[i].pageErrors );
                        console.log('page errors = ' +errors[i].fieldErrors );
                        console.log('message errors = ' +errors[i].message );
                        
                    }
                }
                
            }
        });
        action2.setCallback(this, function(data){

            if(data.getState() === 'SUCCESS'){
                var record = data.getReturnValue();
                component.set("v.productType", JSON.parse(record));
            }
        });
        $A.enqueueAction(action1);
        $A.enqueueAction(action2);
        
        //component.set('v.engList','[ { "attributeWrapper": [ { "value": "rajni+emailmethod2@comitydesigns.com", "isLink": false, "columnLabel": "Email" }, { "value": ", RDC", "isLink": false, "columnLabel": "Product" }, { "value": "Shashi Kumar", "isLink": false, "columnLabel": "Name" } ], "activityTime": "1:40 AM", "activityDate": "1/15/2019", "activityDescriptionTitle":"test first activity 1" }, { "attributeWrapper": [ { "value": "shashi@comitydesigns.com", "isLink": false, "columnLabel": "Email" }, { "value": ", RDC", "isLink": false, "columnLabel": "Product" }, { "value": "Shashi Kumar", "isLink": false, "columnLabel": "Name" } ], "activityTime": "11:06 PM", "activityDate": "12/10/2018" ,"activityDescriptionTitle":"test first activity 2" } ]');
	},
    handleTypeChange: function(component, event, helper){        
        var offset = 0;	        
        helper.getActivityList(component,helper,offset,false,1);        
    },

    pagiantion : function(component, event, helper)
    {
        var pageSize = component.get("v.pageSize");
        var offset = component.get("v.offset");
        var totalSize = component.get("v.totalSize");
            
        var source = event.getSource().getLocalId();
		        
        var newOffset = 0;
        if(source == "first"){
            newOffset = 0;
        }else if(source == "previous"){
			newOffset = offset - pageSize;        
        }else if(source == "next"){
            newOffset = offset + pageSize; 
        }else if(source == "last"){
            var totalPage = Math.floor(totalSize / pageSize);
           
            newOffset = totalPage * pageSize;
            
            if(newOffset == totalSize){
                newOffset = totalSize - pageSize; 
            }
            
        }
        
        if(newOffset < 0){
            newOffset = 0;
        }
        helper.getActivityList(component,helper,newOffset,false);               
        
	},
})