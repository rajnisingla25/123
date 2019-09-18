({
    doInit : function(component, event, helper) {
        var record = component.get("v.recordId");
        helper.fetchOpenCases(component,record);
    },
    scriptsLoaded : function(component, event, helper) {
        console.log('Script loaded..'); 
    },
    linkRedirect : function(component, event, helper) {
        var caseid = event.target.id;
        if(sforce.console.isInConsole()){
            sforce.console.openPrimaryTab(null, '/'+caseid,true);
        } else {
            window.open("/"+caseid, '_blank')
        }
    },
    
    createCaseRedirect : function(component, event, helper) {
        //CRM-5024
        url = 'setup/ui/recordtypeselect.jsp?ent=Case&retURL=';
        returl = encodeURIComponent(window.location); 
        urlParams = new URLSearchParams(window.location.search);
        accountid = urlParams.get('id');
        saveNewUrl = encodeURIComponent('/500/e?retURL='+returl+'&def_account_id='+accountid);
		url = url+returl+'&save_new_url='+saveNewUrl;
        if(sforce.console.isInConsole()){
            sforce.console.openPrimaryTab(null, '/'+url,true);
        } else {
            window.open("/"+url, '_blank')
        }
     
    }
    
})