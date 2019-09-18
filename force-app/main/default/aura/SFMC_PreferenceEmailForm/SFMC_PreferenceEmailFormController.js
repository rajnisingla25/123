({
	doInit : function(component, event, helper) {
        var brandType = component.get("v.brandType");
        var brandTopProducer = $A.get("$Label.c.SFMC_Brand_Top_Producer");
        var brandRDC = $A.get("$Label.c.SFMC_Brand_RDC");
        var brandEvents = $A.get("$Label.c.SFMC_Brand_Events");        
        if(brandType == brandTopProducer){            
            component.set('v.brandName','Top Producer');
        }else if(brandType == brandRDC){            
            component.set('v.brandName','realtor.com');
        }else{
            component.set('v.contactMethodIdErrorMsg',$A.get("$Label.c.Invalid_record_in_preference_center_UI"));
            component.set('v.contactMethodIdError',true);
        }
        
        var action = component.get('c.getPreferenceRecord');
        action.setParams({
            contactMethodId : component.get('v.contactMethodId')
        });
        

        action.setCallback(this, function(data){            
            console.log('data.getState() = ' + data.getState());
            if (data.getState() === "SUCCESS") {
                var record = data.getReturnValue();
                if(record == null){
                    component.set('v.contactMethodIdErrorMsg',$A.get("$Label.c.Invalid_record_in_preference_center_UI"));
                    component.set('v.contactMethodIdError',true);
                }else{
                    component.set('v.emailAddress',record.Email__c);
                    component.set('v.contactMethodId',record.Id); //updated because this has been change due to merge/purge.
                    console.log('id =' + record.Id);
                    
                    
                    if(brandType == brandTopProducer){
                        helper.setOptIn(component,record.TP_Promo_OptIn__c,record.TP_Info_OptIn__c,record.TP_Event_OptIn__c);
                    }else if(brandType == brandRDC){
                        helper.setOptIn(component,record.RDC_Promo_OptIn__c,record.RDC_Info_OptIn__c,record.RDC_Event_OptIn__c);
                    }else if(brandType == brandEvents){
                        helper.setOptIn(component,record.Events_Informational_opt_in__c,record.Events_events_opt_in__c,record.Events_promotional_opt_in__c);
                    }
                }
            }else if (data.getState() === "ERROR"){
                component.set('v.contactMethodIdErrorMsg',$A.get("$Label.c.Invalid_record_in_preference_center_UI"));
				component.set('v.contactMethodIdError',true);
                component.set('v.isError',true);
            }
        });       
        $A.enqueueAction(action);
    },
    optOutChecked : function(component, event, helper){
        var optOut = component.find("optOut");
        var optInForInformational = component.find("optInForInformational");
        var optInForPromotional = component.find("optInForPromotional");
        var optInForEvents = component.find("optInForEvents");
        if(optOut.get("v.value") == true){
            optInForInformational.set("v.value",false);
            optInForPromotional.set("v.value",false);
            optInForEvents.set("v.value",false);
            component.set("v.checkBoxError",false);
        }
    },
    optInChecked : function(component, event, helper){        
        var optOut = component.find("optOut");
        var optInForInformational = component.find("optInForInformational").get("v.value");
        var optInForPromotional = component.find("optInForPromotional").get("v.value");
        var optInForEvents = component.find("optInForEvents").get("v.value");        
        
        if(optInForInformational || optInForPromotional || optInForEvents){
            optOut.set("v.value",false);
            component.set("v.checkBoxError",false);
        }
    },
    handleUpdate : function(component, event, helper){
        component.set('v.contactMethodIdError',false);
        component.set("v.checkBoxError",false);
        var optOut = component.find("optOut").get("v.value");
        var optInForInformational = component.find("optInForInformational").get("v.value");
        var optInForPromotional = component.find("optInForPromotional").get("v.value");
        var optInForEvents = component.find("optInForEvents").get("v.value");
        
        if(!optInForInformational && !optInForPromotional && !optInForEvents && !optOut){
            component.set('v.checkBoxErrorMsg',$A.get("$Label.c.Checkbox_Error_in_preference_center_UI")); 
            component.set("v.checkBoxError",true);
        }else{
            var action1 = component.get("c.savePreferenceRecord");
            action1.setParams({ contactMethodId: component.get('v.contactMethodId'),
                               brandType : component.get('v.brandType'),
                               optInForInformational: optInForInformational,
                               optInForPromotional: optInForPromotional,
                               optInForEvents: optInForEvents
                              });
            action1.setCallback(this, function(result) {   
                // If result state is error or returned value is false, show error message.
                if(result.getState() === "ERROR"){
                    component.set('v.contactMethodIdErrorMsg',$A.get("$Label.c.Invalid_record_in_preference_center_UI"));
                    component.set('v.contactMethodIdError',true);
                }
                if(!result.getReturnValue()){
                    component.set('v.contactMethodIdErrorMsg',$A.get("$Label.c.SFMC_Eng_List_Error"));
                    component.set('v.contactMethodIdError',true);
                }
                else{
                    var record = result.getReturnValue();
                    console.log('record updated');
                    
                    var evt = $A.get("e.c:SFMC_PreferenceEvent");
                    console.log('evt'+evt);
                    evt.setParams({
                        showConfirmationPage: true
                    });
                
                    evt.fire();
                }
            });
            $A.enqueueAction(action1);
        }
    }
})