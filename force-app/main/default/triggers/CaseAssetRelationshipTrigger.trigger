//
// (c) 2015 Appirio, Inc.
//
// Trigger Name: CaseAssetRelationshipTrigger
// On SObject: Case_Asset_Relationship__c
// Trigger Handler: CaseAssetRelationshipTriggerHandler
// Trigger Manager: CaseAssetRelationshipTriggerManager
//
// Description: This trigger has the following pusposes:
//  Purpose 1: The Asset.At_Risk__c field should be enabled/disabled based on the following scenarios:
//    Enable Asset.At_Risk__c checkbox
//      One or more Case Asset Relationship records exist where the case has the following criteria:
//        Case.Status <> 'Closed'
//        Case.Type__c = 'Retention'
//    Disable Asset.At_Risk__c checkbox
//      If no Case Asset Relationship records exist where the case meets the criteria described above.
//      Deletion of the Case Asset Relationship record.
//
// 29th May 2015     Hemendra Singh Bhati   Original (Task # T-380907)
//
trigger CaseAssetRelationshipTrigger on Case_Asset_Relationship__c(after insert, after update, after delete, before insert, before update) {
    // Instantiating The Trigger Handler.
    CaseAssetRelationshipTriggerHandler theHandler = new CaseAssetRelationshipTriggerHandler(Trigger.isExecuting, Trigger.size);
    
    //Retention Commissions - Added By Srinivas Pendli
    /*** commented by Srinivas pendli on 02.12.2015 
    Commissions_CreateRetentionCommsClass RetentionComm = new Commissions_CreateRetentionCommsClass ();    
    if(trigger.isAfter) {
        if(trigger.isInsert || trigger.isUpdate) {
            if(!SkipComissionTrigger.skiptrigger){
                system.debug('Enter Commission Loop');
                RetentionComm.CaseCommission(Trigger.NewMap);
             }
        }
    }
    ***/
    //Retention Commissions - Code ends
     
    // Commented by  Kalyan Meda ( Ntt data ). Its interfering with cases . So commenting the code. Please contact me in case you have any concerns
  
  // Turn off the trigger if the value of custom setting field is true.
  if(Switch_CaseAssetRelationshipTrigger__c.getInstance().Set_Overall_Trigger_Off__c == false) {
    if(trigger.isAfter) {
      if(trigger.isInsert || trigger.isUpdate) {
        system.debug('TRACE: CaseAssetRelationshipTrigger - Calling Method - CaseAssetRelationshipTriggerHandler.onAfterInsertUpdate().');
        theHandler.onAfterInsertUpdate(trigger.newMap, trigger.oldMap, trigger.isInsert);
      }
        
      if(trigger.isDelete) {
        system.debug('TRACE: CaseAssetRelationshipTrigger - Calling Method - CaseAssetRelationshipTriggerHandler.onAfterDelete().');
         theHandler.onAfterDelete(trigger.old);
      }
    }
     if(Trigger.isBefore){
         if(trigger.isInsert){
             system.debug('TRACE: CaseAssetRelationshipTrigger - Calling Method - CaseAssetRelationshipTriggerHandler.onBeforeInsert().');
             theHandler.onBeforeInsert(trigger.new, trigger.newMap, trigger.isInsert);
         }
     
            
   }
  }
}