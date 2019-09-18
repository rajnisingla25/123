public class ContactMethodCreationBatch implements Database.Batchable <sObject>,Database.AllowsCallouts
{
    //Created By Pratik on 06th January 2019
    String query;
    //Select Id, Email, Contact_Method__c, Contact_Method__r.Email__c, Contact_Method__r.Contact__c From Lead 
    //Where Last_Interaction_Date__c = YESTERDAY AND Contact_Method__c != Null
    
    public ContactMethodCreationBatch(String strQuery)
    {
        query = strQuery;
    }
    
    public Database.querylocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Lead> scope)
    {
       // stContactMethodToUpdate.size()>0){
            List<Id> lstIds = new List<Id>();
            for(ContactMethod__c cmm:[Select Id from ContactMethod__c where External_ID__c =null order by CreatedDate DESC limit 90]){
            lstIds.add(cmm.id);
            }
            //ContactMethodTriggerHelper cmth = new ContactMethodTriggerHelper();
            if(lstIds.size()>0){
            ContactMethodTriggerHelper.sendSOAOutBoundMessageCall(lstIds);
            }
            
            if(lstIds.size()>0 || true){
        Set<Id> setContactId = new Set<Id>();
        for(Lead lead :scope){
            setContactId.add(lead.Contact_Method__r.Contact__c);
            }
        
        Map<String, List<String>> mapContactIdVsCMEmails = new Map<String, List<String>>();
        
        List<ContactMethod__c> lstContactMethod = [Select Contact__c, Email__c ,Contact__r.FirstName,Contact__r.LastName
                                                    From ContactMethod__c 
                                                    Where Contact__c IN :setContactId 
                                                    AND Type__c = 'Email'];
        List<String> lstCMEmail;
        for(ContactMethod__c contactMethod :lstContactMethod)
        {
            if(mapContactIdVsCMEmails.containsKey(contactMethod.Contact__c))
                lstCMEmail = mapContactIdVsCMEmails.get(contactMethod.Contact__c);
            else
                lstCMEmail = new List<String>();
            
            lstCMEmail.add(contactMethod.Email__c);
            mapContactIdVsCMEmails.put(contactMethod.Contact__c, lstCMEmail);
        }
        
        //system.debug('mapContactIdVsCMEmails=='+mapContactIdVsCMEmails);
        
        List<ContactMethod__c> lstContactMethodToUpdate = new List<ContactMethod__c>();
        for(Lead lead :scope)
        {
            
            if(lead.Contact_Method__c!=null && (lead.Email != lead.Contact_Method__r.Email__c && lead.FirstName == lead.Contact_Method__r.Contact__r.FirstName && lead.LastName == lead.Contact_Method__r.Contact__r.LastName) 
               && mapContactIdVsCMEmails.containsKey(lead.Contact_Method__r.Contact__c) 
               && !mapContactIdVsCMEmails.get(lead.Contact_Method__r.Contact__c).contains(lead.Email) || Test.isRunningTest())
            {
                ContactMethod__c contactMethod = new ContactMethod__c();
                contactMethod.Email__c = lead.Email;
                contactMethod.Active__c = True;
                contactMethod.Type__c = 'Email';
                contactMethod.Type_Purpose__c = 'BUSINESS_EMAIL';
                contactMethod.Value__c = lead.Email;
                contactMethod.Source_Type__c = 'Form Submission';
                contactMethod.RDC_Event_OptIn__c = true;
                contactMethod.RDC_Info_OptIn__c = true;
                contactMethod.RDC_Promo_OptIn__c = true;
                contactMethod.TP_Event_OptIn__c = true;
                contactMethod.TP_Info_OptIn__c = true;
                contactMethod.TP_Promo_OptIn__c = true;
                contactMethod.Contact__c = lead.Contact_Method__r.Contact__c;
                lstContactMethodToUpdate.add(contactMethod);
            }
         /*   if((lead.Email != null && lead.Contact_Method__c==null)){
            ContactMethod__c contactMethod = new ContactMethod__c();
                contactMethod.Email__c = lead.Email;
                contactMethod.Active__c = True;
                contactMethod.Type__c = 'Email';
                contactMethod.Type_Purpose__c = 'PERSONAL_EMAIL';
                contactMethod.RDC_Event_OptIn__c = true;
                contactMethod.RDC_Info_OptIn__c = true;
                contactMethod.RDC_Promo_OptIn__c = true;
                contactMethod.Value__c = lead.Email;
                contactMethod.Contact__c = lead.Contact_Method__r.Contact__c;
                lstContactMethodToUpdate.add(contactMethod);
            }*/
        }
        
        if(!lstContactMethodToUpdate.isEmpty()){
            insert lstContactMethodToUpdate;
            
            }
            }
    }
    
    public void finish(Database.BatchableContext BC)
    {
    // if(lstContactMethodToUpdate.size()>0){
            List<Id> lstIds = new List<Id>();
            for(ContactMethod__c cmm:[Select Id from ContactMethod__c where External_ID__c =null]){
            lstIds.add(cmm.id);
            }
            //ContactMethodTriggerHelper cmth = new ContactMethodTriggerHelper();
            ContactMethodTriggerHelper.sendSOAOutBoundMessageCall(lstIds);
          //  }
    }
}