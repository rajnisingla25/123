public class MLSTriggerHandler {
    MLSTriggerHandlerManager Manager= new MLSTriggerHandlerManager();
    public void onAfterinsertUpdate(map<ID,MLS__c> newMap,map<ID,MLS__c> oldMap){
        Manager.AccountMLSUpdate(newMap,oldmap);
    }
}