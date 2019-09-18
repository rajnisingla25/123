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
public without sharing class CaseAssetRelationshipTriggerHandler {
  // Private Data Members.
  private Integer batchSize = 0;
  private Boolean isExecuting = false;
  private CaseAssetRelationshipTriggerManager theManager = null;

  // The Constructor.
  public CaseAssetRelationshipTriggerHandler() {
  }

  public boolean IsTriggerContext {
    get { return isExecuting; }
  }

  public boolean IsVisualforcePageContext {
    get { return !IsTriggerContext; }
  }

  public boolean IsWebServiceContext {
    get { return !IsTriggerContext; }
  }

  public boolean IsExecuteAnonymousContext {
    get { return !IsTriggerContext; }
  }

  public CaseAssetRelationshipTriggerHandler(Boolean isExecuting, Integer size) {
    isExecuting = isExecuting;
    batchSize = size;
    theManager = new CaseAssetRelationshipTriggerManager();
  }

  /*
  @method      : onAfterInsertUpdate
  @description : Updates asset field "At_Risk__c" for all the scenarios mentioned in the description above.
  @params      : Map<Id, Case_Asset_Relationship__c> newMap, Map<Id, Case_Asset_Relationship__c> oldMap, Boolean isInsert
  @returns     : void
  */
  public void onAfterInsertUpdate(Map<Id, Case_Asset_Relationship__c> newMap, Map<Id, Case_Asset_Relationship__c> oldMap, Boolean isInsert) {
    // Turn on/off asset field "At_Risk__c" updation logic.
    if(Switch_CaseAssetRelationshipTrigger__c.getInstance().Set_Asset_Risk_Updation_Off__c == false) {
      // Update asset field "At_Risk__c" for all the scenarios mentioned in the description above.
      system.debug(
        'TRACE: CaseAssetRelationshipTriggerHandler - Calling Method - ' +
        'CaseAssetRelationshipTriggerManager.updateAssetRiskFlagOnAfterInsertUpdateDelete(newMap, oldMap, isInsert, null).'
      );
      theManager.updateAssetRiskFlagOnAfterInsertUpdateDelete(newMap, oldMap, isInsert, null);  
      theManager.updateduplicateflagonCAR(newMap,oldMap, isInsert); 
    }
  }

    /*
  @method      : onBeforeInsert
  @description : Calculates the At risk Amount for the asset based on the product of daily rate and days remaining on the asset and update the value on 
                 Jn obj record
  @params      : Map<Id, Case_Asset_Relationship__c> newMap,  Boolean isInsert
  @returns     : void
  */
    public void onBeforeInsert(List<Case_Asset_Relationship__c> lstCA, Map<Id, Case_Asset_Relationship__c> newMap, Boolean isInsert){
        // Turn on/off asset field "At_Risk__c" updation logic.
        if(Switch_CaseAssetRelationshipTrigger__c.getInstance().Set_Asset_Risk_Updation_Off__c == false) {
             system.debug('TRACE: CaseAssetRelationshipTriggerHandler - Calling Method - ' +
            'CaseAssetRelationshipTriggerManager.updateAtRiskAmountPerAssetAndRollUpToCaseonAfterInsertUpdate(lstCA, newMap,isInsert).'
      );

       theManager.updateAtRiskAmountPerAssetAndRollUpToCaseonAfterInsertUpdate(lstCA, newMap, isInsert);  
    }
  }
    /*
  @method      : onAfterDelete
  @description : Updates asset field "At_Risk__c" for all the scenarios mentioned in the description above.
  @params      : List<Case_Asset_Relationship__c> old
  @returns     : void
  */
  public void onAfterDelete(List<Case_Asset_Relationship__c> old) {
    // Turn on/off asset field "At_Risk__c" updation logic.
    if(Switch_CaseAssetRelationshipTrigger__c.getInstance().Set_Asset_Risk_Updation_Off__c == false) {
      // Update asset field "At_Risk__c" for all the scenarios mentioned in the description above.
      system.debug(
        'TRACE: CaseAssetRelationshipTriggerHandler - Calling Method - ' +
        'CaseAssetRelationshipTriggerManager.updateAssetRiskFlagOnAfterInsertUpdateDelete(null, null, false, old).'
      );
      theManager.updateAssetRiskFlagOnAfterInsertUpdateDelete(null, null, false, old);
    }
  }
    
    
  /*
  @method      : 
  @description : 
  @params      : 
  @returns     : 
  */
  
  /*
  // In this method creating new commission record while case and asset mapping.
    Public void CaseCommission (Map<id,Case_Asset_Relationship__c> NewCaseAsset){
        Set<Id> caseownerIds = new Set<Id>();
        Set<Id> AssetIds= new Set<Id>();
        Set<Id> CaseIds= new Set<Id>();
            Set<String> Pid= new Set<String>();
    Map<id,Commission__c> NewCaseCommissionList =  new Map<id,commission__c>();
    
    
    Map<id,Case_Asset_Relationship__c> caseasset = new map<id,Case_Asset_Relationship__c>([select id,At_Risk_Amount__c,Asset_Type__c,Asset_Price__c,Case__c,    Asset_Product__c,Asset__c,Case__r.Ownerid,  Case_Status__c , New_List_Price__c,Case__r.Type from Case_Asset_Relationship__c Where ID IN:NewCaseAsset.values()]);
    system.debug('caseasset****'+caseasset.values());
        
        for(Case_Asset_Relationship__c relationasset : caseasset.values()){
            caseownerIds.add(relationasset.case__r.Ownerid);
            AssetIds.add(relationasset.Asset__c);
            CaseIds.add(relationasset.Case__c);
            Pid.add(relationasset.Asset_Product__c);
        }
        
        system.debug('caseownerIds'+caseownerIds);
        system.debug('AssetIds'+AssetIds);
        system.debug('CaseIds'+CaseIds);
        system.debug('Pid'+Pid);
     
     Map<id,Quota__c> caseQuota = New Map<id,Quota__c>([select id,Total_Sale__c from Quota__c where User__c IN : caseownerIds]);
     Map<id,Product2> product = New Map<id,Product2>([select id,Name,Normalization_factor__c, Commission_Category__c from product2 where Name IN: Pid]);
     system.debug('Product size'+product.size());
     for(Case_Asset_Relationship__c CAS : NewCaseAsset.values()){
          for(Quota__c q :caseQuota.values()){
          system.debug('Enter 2:');
              if(CAS.Case_Status__c=='Closed' && CAS.Case__r.Type == 'Retention'){
              system.debug('Enter 3:');
                   if((CAS.At_Risk_Amount__c==CAS.New_List_Price__c)||(CAS.New_List_Price__c==0)){
                   system.debug('Enter 4:');
                       if(CAS.Asset_type__c=='Parent'){
                       system.debug('Enter 5:');
                            Product2 pro = Product.get(CAS.Asset__r.Product2Id);
                            Commission__c com = new Commission__c();           
                            com.Related_to_Asset__c = CAS.Asset__c; 
                            Com.Related_to_Quota__c = 'a1tg0000000TQuI';//q.id;
                            Com.Related_to_Quota__c = q.id;
                            Com.Product__c = pro.id;
                            Com.Billing_Type__c = CAS.Asset__r.Billing_Period__c;
                            // Com.User_Team__c = ca.Owner.Team__c;
                            //system.debug('User Team :'+ca.Owner.Team__c);
                            Com.Asset_Amount__c= CAS.Asset_Price__c;
                            Com.Signing_AE__c = CAS.Asset__r.Sign_in_AE__c;
                            if(CAS.Asset__r.Billing_Period__c == Constants.BILLING_PERIOD){
                                Com.Normalization_factor__c = pro.Normalization_factor__c; 
                            }
                            else if(CAS.Asset__r.Billing_Period__c == Constants.BILLING_PERIOD_YEARLY){
                                Com.Normalization_factor__c = 1.00; 
                            }
                            else{
                                Com.Normalization_factor__c = 1.00;
                            }           
                                NewCaseCommissionList.put(com.id,com);
                            }
                    }
                 }
             }
          }
     
                //To insert the records
                system.debug('NewCaseCommissionListsize1 '+NewCaseCommissionList.size());
                if(NewCaseCommissionList.size () >= 0){       
                    insert NewCaseCommissionList.values();
                    system.debug('NewCaseCommissionListsize2 '+NewCaseCommissionList.size());
                }
 
  }  */
}