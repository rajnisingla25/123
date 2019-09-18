({
    doInit : function(component, event, helper) {       
        
        var action = component.get('c.businessUnit');
        var pageURL = window.location.href;
        pageURL = pageURL.split('?')[0];
        action.setParams({
            pageURL : pageURL
        });
        var brandType;
        action.setCallback(this,function(data){
            if(data.getState() == 'SUCCESS'){
                var bu = data.getReturnValue();
                console.log('check bu>>'+bu);
                if(!$A.util.isEmpty(bu)){
                    component.set('v.brandType', bu);
                    brandType = bu;

                    if(brandType == $A.get("$Label.c.SFMC_Brand_Top_Producer")){
                        component.set('v.footerTopText',$A.get("$Label.c.Preference_Center_Top_Producer_Footer1"));
                        component.set('v.footerSecondText',$A.get("$Label.c.Preference_Center_Top_Producer_Footer2"));
                    }else if(brandType == $A.get("$Label.c.SFMC_Brand_RDC")){
                        component.set('v.footerTopText',$A.get("$Label.c.Preference_Center_RDC_Footer1"));
                        component.set('v.footerSecondText',$A.get("$Label.c.Preference_Center_RDC_Footer2"));
                    }
                    else{
                        component.set('v.footerTopText','© 2018 Move Sales, Inc.');
                        component.set('v.footerSecondText','All rights reserved. All trademarks used herein are the property of their respective owners.');
                    }
                    console.log('brandType >>'+brandType);
        
                }
            }
        });
        $A.enqueueAction(action);
    },
})