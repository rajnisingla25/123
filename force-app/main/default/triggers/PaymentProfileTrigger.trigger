//Name        : PaymentProfileTrigger
//Description : This Trigger updates Payment Method field on Payment Profile Object.
//Frequencey  : Every Insert and Update
//Author      : Pallavi Tammana
//History     : CRM-3185: populate Payment Method Id on Payment profile.


trigger PaymentProfileTrigger on PaymentProfiles__c (Before Insert, Before Update) {
    
    DisabledTrigger__c Dtrg= DisabledTrigger__c.getValues('Disabled');
    
    if(Dtrg != null && Dtrg.TaskTrigger__c!=UserInfo.getUserName()) {        
        
        if(!SkipAccountTrigger.skiptrigger){            
            PaymentProfileTriggerHandler PaymentProfileHdr = new PaymentProfileTriggerHandler();
            
            if(Trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){               
                PaymentProfileHdr.BeforeInsertUpdate(Trigger.New, Trigger.OldMap, trigger.isInsert);
                
            }
        }
    }
}