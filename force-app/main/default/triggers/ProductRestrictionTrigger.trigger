trigger ProductRestrictionTrigger on Product_Restriction_Flag__c (after insert,after update,after delete) {
//Map<Id,Product2> mapProduct2 = new Map<Id,Product2>([Select Id,Name from Product2 Where ProductCode='SHOWCASE']);
DisabledTrigger__c Dtrg= DisabledTrigger__c.getValues('Disabled');
  // Turn off trigger if the value of custom setting field is true. 
  if(Dtrg.ProductRestrictionTrigger__c!=UserInfo.getUserName()){
  if(!SkipProductRestrictionTriggerTrigger.skiptrigger){
if(Trigger.isInsert || Trigger.isUpdate){
String sttrIds = '';
for(Product_Restriction_Flag__c prf:Trigger.new){
sttrIds = sttrIds + ','+prf.id;
}
ProductExclusionTriggerHandler peth = new ProductExclusionTriggerHandler();
//peth.CallCreateUpdateProductExclusion(Trigger.newMap.keyset(),true);
AsyncRecordProcessExecution__c arpe = new AsyncRecordProcessExecution__c();
arpe.Name = 'PRF Trigger';
arpe.Interface_Name__c = 'ProductRestrictionTrigger';
arpe.ClassName__c = 'ProductExclusionTriggerHandler';
arpe.MethodName__c = 'CallCreateUpdateProductExclusion';
arpe.Boolean_Param__c = true;
arpe.Records_To_Process_Ids__c = sttrIds;

insert arpe;
}



if(Trigger.isDelete){
ProductExclusionTriggerHandler peth = new ProductExclusionTriggerHandler();
peth.DeleteProductExclusion(Trigger.old);
}
}
}
}