trigger Waitlisttrigger on Waitlist__c (after insert,after update) {
    for(Waitlist__c WLloop : trigger.new ){
        if(WLloop.Status__c == 'Pending Pre-Auth' && WLLoop.Submitted__c && WLloop.Total_MAX_Monthly_Pre_Auth_Spend__c > 0){
        System.debug('Checking this Condition===>');
            SendDocusign.SendNow(WLloop.id);
        }
    }
    
    
    
    
}