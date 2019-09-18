({
	getUrlParameter : function(sParam) {
        var sPageURL = decodeURIComponent(window.location.search.substring(1)),
            sURLVariables = sPageURL.split('&'),
            sParameterName,
            i;
    
        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('=');    		
            if (sParameterName[0] === sParam) {
                return sParameterName[1] === undefined ? true : sParameterName[1];
            }
        }
    },

    getbusinessUnit : function(component, event, helper){
        var action = component.get('c.businessUnit');
        var pageURL = window.location.href;
        pageURL = pageURL.split('?')[0];
        action.setParams({
            pageURL : pageURL
        });
        action.setCallback(this,function(data){
            if(data.getState() == 'SUCCESS'){
                var bu = data.getReturnValue();
                if(!$A.util.isEmpty(bu)){
                    component.set('v.brandType', bu);
                }
            }
        });
        $A.enqueueAction(action);
    }
})