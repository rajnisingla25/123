({
	parseJson : function(component,isScrollableAction) {
		var activity = component.get('v.engList');
        
        var activityList = JSON.parse(activity);
		
        var totalRecord = component.get('v.totalSize');
        var isLimitExceeded = component.get('v.isLimitExceeded');
        var isError = false;
        var errorMessage = $A.get("$Label.c.SFMC_Engagement_Record_Not_Found");
        
        if(isScrollableAction){
            var prevActitivtyList = component.get('v.activityParseWrappers');            
            for (var key in activityList){                
            	prevActitivtyList.push(activityList[key]);
            }            
            component.set('v.activityParseWrappers',prevActitivtyList);
        }else{
        	component.set('v.activityParseWrappers',activityList);
            totalRecord = activityList.length > 0 ? activityList[0].recordListSize : 0;
            isLimitExceeded = activityList.length > 0 ? activityList[0].isLimitExceeded : false;
        }
        
        if(activityList.isError != undefined){       
            isError =  activityList.isError;
            errorMessage = activityList.errorMessage != undefined ? activityList.errorMessage : $A.get("$Label.c.SFMC_Engagement_Record_Not_Found");
        }
        
        component.set('v.totalSize',totalRecord);
        component.set('v.totalSizeStr' ,  isLimitExceeded ? totalRecord + '+' : totalRecord);
        component.set('v.isLimitExceeded',isLimitExceeded);
        component.set('v.isError',isError);
        component.set('v.errorMessage',errorMessage);
        
	},
    getActivityList : function(component,helper,newOffset,isScrollable,currentPageNumber){ 
        var contactId = component.get('v.contactId');
        var selectedValue = component.get("v.selectedValue");
        var selectedProd = component.get("v.selectedProduct");
        
        console.log('selectedValue '+selectedValue);
        
        var action = component.get('c.getOffsetRecords');
        action.setParams({
            offset: newOffset, contactId:contactId, engagementTypeFilter: selectedValue,isFilter:!isScrollable, selectedProduct: selectedProd
        });
        
        action.setCallback(this, function(data){            
            console.log('data.getState() = ' + data.getState());
            if (data.getState() === "SUCCESS") {
                var record = data.getReturnValue(); 
                component.set("v.offset", newOffset); 
                component.set('v.engList',record);
                component.set('v.lastPageNumber',currentPageNumber);
                component.set('v.Spinner',false);
                
                if(!isScrollable){
                    var modContent = component.find('modalContent').getElement();
                    modContent.scrollTop = 0;
                }
                
                helper.parseJson(component,isScrollable);
                                
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
        $A.enqueueAction(action);
        
    },   
    
})