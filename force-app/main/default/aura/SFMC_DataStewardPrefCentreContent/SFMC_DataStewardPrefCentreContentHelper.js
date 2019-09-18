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
    
    

    businessUnitCheck : function(component,helper){
        var action = component.get("c.getBusinessUnit");
        var pageURL = window.location.href;
        pageURL = pageURL.split('?')[0];
        action.setParams({
            communityDomain : pageURL
        });

        action.setCallback(this, function(result){
            if(result.getState() === "SUCCESS"){
                var bu = result.getReturnValue();
                if(!$A.util.isEmpty(bu)){
                    if( $A.get("$Label.c.SFMC_Brand_RDC") === bu || $A.get("$Label.c.SFMC_Brand_Top_Producer") === bu){
                        component.set('v.brandType', bu);
                    }else{
                        component.set("v.businessUnitErrorMsg","Business unit is not configured or incorrect. Please contact your administrator.");
                        component.set("v.businessUnitError", true);
                    }
                }
                else{
                    component.set("v.businessUnitErrorMsg","Business unit is not configured or incorrect. Please contact your administrator.");
                    component.set("v.businessUnitError", true);  
                }
            }else{
                component.set("v.businessUnitErrorMsg","Business unit is not configured or incorrect. Please contact your administrator.");
                component.set("v.businessUnitError", true);  
            }
        });
        $A.enqueueAction(action);
    },
    
    updatePreferences : function(component, helper){
        component.set('v.contactMethodIdError',false);
        var optInForTPInformational;
        var optInForTPPromotional;
        var optInForTPWebinars;
        var optTPOut;
        var optInForRDCInformational;
        var optInForRDCPromotional;
        var optInForRDCWebinars;
        var optRDCOut;
        var rdcEmailFormComponent = component.find('rdcEmailForm');
        var tpEmailFormComponent = component.find('tpEmailForm');
        if(rdcEmailFormComponent != undefined){
            optInForRDCInformational = rdcEmailFormComponent.find("optInForInformational").get("v.value");
            optInForRDCPromotional = rdcEmailFormComponent.find("optInForPromotional").get("v.value");
            optInForRDCWebinars = rdcEmailFormComponent.find("optInForEvents").get("v.value");
            optRDCOut = rdcEmailFormComponent.find("optOut").get("v.value");
        
        }
        if(tpEmailFormComponent != undefined){
            optInForTPInformational   = tpEmailFormComponent.find("optInForInformational").get("v.value");
            optInForTPPromotional = tpEmailFormComponent.find("optInForPromotional").get("v.value");
            optInForTPWebinars = tpEmailFormComponent.find("optInForEvents").get("v.value");
            optTPOut = tpEmailFormComponent.find("optOut").get("v.value");
        }
        var formIncomplete = false;
        if((optInForRDCInformational != undefined && !optInForRDCInformational) && (optInForRDCPromotional != undefined && !optInForRDCPromotional) && (optInForRDCWebinars != undefined && !optInForRDCWebinars) && (optRDCOut != undefined && !optRDCOut)){
            rdcEmailFormComponent.set('v.checkBoxErrorMsg',$A.get("$Label.c.Checkbox_Error_in_preference_center_UI")); 
            rdcEmailFormComponent.set("v.checkBoxError",true);
            formIncomplete = true;
        }if((optInForTPInformational != undefined && !optInForTPInformational) && (optInForTPPromotional !=undefined && !optInForTPPromotional) && (optInForTPWebinars != undefined && !optInForTPWebinars) && (optTPOut != undefined && !optTPOut)){
            tpEmailFormComponent.set('v.checkBoxErrorMsg',$A.get("$Label.c.Checkbox_Error_in_preference_center_UI")); 
            tpEmailFormComponent.set("v.checkBoxError",true);
            formIncomplete = true;
        }
        if(!formIncomplete){
            var action = component.get("c.saveDataStewardPreferenceRecord");
            action.setParams({ contactMethodId: component.get('v.contactMethodId'),
                              optInForRDCInformational: (optInForRDCInformational  != undefined ? optInForRDCInformational : false),
                              optInForRDCPromotional: (optInForRDCPromotional != undefined ? optInForRDCPromotional : false),
                              optInForRDCWebinars: (optInForRDCWebinars != undefined ? optInForRDCWebinars : false),
                              optInForTPInformational: (optInForTPInformational != undefined ? optInForTPInformational : false),
                              optInForTPPromotional: (optInForTPPromotional != undefined ? optInForTPPromotional : false),
                              optInForTPWebinars: (optInForTPWebinars != undefined ? optInForTPWebinars : false)
                             });
            action.setCallback(this, function(result) {               
               // if (result.getState() === "SUCCESS") {
               // If result state is error or returned value is false, show error message.
                if(result.getState() === "ERROR"){
                    component.set('v.contactMethodIdErrorMsg',$A.get("$Label.c.Invalid_record_in_preference_center_UI"));
                    component.set('v.contactMethodIdError',true);
                }
                if(!result.getReturnValue()){
                    component.set('v.contactMethodIdErrorMsg',$A.get("$Label.c.SFMC_Eng_List_Error"));
                    component.set('v.contactMethodIdError',true);
                }else{
                    var record = result.getReturnValue();
                    console.log('record updated');                    
                    component.set('v.showConfirmationPage', true);
                }
            });
            $A.enqueueAction(action);
        }
    
    },

    getUserType : function(component){
        var action = component.get("c.getUserType");
        action.setParams({
            userId: component.get('v.userId')
        });

        action.setCallback(this, function(result){
            if(result.getState()=== "SUCCESS"){
                var user = result.getReturnValue();
                component.set("v.userType", user);
                console.log('user>>>'+user);
                if(user === "Guest"){
                    component.set("v.headerCenterBigText",$A.get("$Label.c.SFMC_Guest_User_Heading"));
                    component.set("v.headerCenterSmallText1",$A.get("$Label.c.SFMC_Guest_User_Subheading1"));
                    component.set("v.isGuest", true);
                    component.set("v.isDataSteward",false);
                }
                else if(user === "Standard"){
                    
                    component.set("v.headerCenterBigText",$A.get("$Label.c.SFMC_Standard_User_Heading"));
                    component.set("v.headerCenterSmallText1",$A.get("$Label.c.SFMC_Standard_User_Subheading1"));
                    component.set("v.headerCenterSmallText2",$A.get("$Label.c.SFMC_Standard_User_Subheading2"));
                    
                    component.set("v.isGuest", false);
                    component.set("v.isDataSteward",true);
                }
                else if(user === null){
                    /*component.set("v.headerCenterBigText","Tell us about your email preferences");
                    component.set("v.headerCenterSmallText1","We want you to receive only the emails you want. Our aim is to only send emails that you find helpful. Please update your preferences below so that we can better tailor emails to your interests.");*/
                    
                    component.set("v.isGuest", true);
                    component.set('v.noAccessMsg',$A.get("$Label.c.SFMC_Community_Access"));
                    component.set('v.noAccess',true);
                }
            }
            else{
                component.set('v.noAccessMsg',$A.get("$Label.c.SFMC_Community_Access"));
                component.set('v.noAccess',true);
                component.set("v.isGuest", true);
            }

        });
        $A.enqueueAction(action);
    }
})