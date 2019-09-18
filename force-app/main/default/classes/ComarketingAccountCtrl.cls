/* Class :- ComarketingAccountCtrl
Purpose : LCM-149 To add amend and cancel in CO Marketing relationship
Created Date :- 12 October 2018
Created By : Mridula
*/
public class ComarketingAccountCtrl {

    
    public boolean showAdd {get;set;}
    
    public PageReference add() {
        return new PageReference('/apex/comarketingDetails?rId=&id='+ApexPages.currentPage().getParameters().get('id')+'&accounttype='+ApexPages.currentPage().getParameters().get('accounttype')+'&name='+ApexPages.currentPage().getParameters().get('name')+'&totalAssets='+ApexPages.currentPage().getParameters().get('totalAssets'));
    }

    public List<account_Relationship__c> getRelations() {
        Integer count = [Select count() from Account_Relationship__c where (Parent_Account__c =: ApexPages.currentPage().getParameters().get('id') OR Child_Account__c =: ApexPages.currentPage().getParameters().get('id')) AND relationship_Type__c = 'Partner' AND (comarketing_status__c = 'Active' OR comarketing_status__c = 'Pending Activation' OR comarketing_status__c = 'Pending Cancellation' )];
        if(count >= Integer.valueOf(Label.Account_Lender_Limit) && ApexPages.currentPage().getParameters().get('accounttype') != 'Lender Individual'){
            showAdd= false;
        }else{
          //  String ZId=  Z_PaymentMethodCaptureUtil.CreateZuoraAccountWithSfdcAccountId(ApexPages.currentPage().getParameters().get('id'));        
            showAdd = true;
        }
        Return [Select Comarketing_cancellation_reason__c , Comarketing_cancellation_description__c, relationship_CAP__c, id, comarketer_spend__c, Total_comarketing_assets__c, Comarketing_Zuora_InProgress__c, comarketer_spend_percent__c , comarketer_Actual_Spend__c , Current_Comarketer_Spend_Percent__c , Initial_comarketer_spend_percent__c , total_connections_price__c , total_relationship_assets_price__c ,Parent_Account__r.Name, comarketing_status__c, Parent_Account__r.Party_ID__c, Child_Account__r.Name, Child_Account__r.Party_Id__c from Account_Relationship__c where (Parent_Account__c =: ApexPages.currentPage().getParameters().get('id') OR Child_Account__c =: ApexPages.currentPage().getParameters().get('id')) AND relationship_Type__c = 'Partner' AND comarketing_status__c != null];
    }
    
    public pageReference returnToAccount(){
        return new PageReference('/'+ApexPages.currentPage().getParameters().get('id'));
    }
    
    public PageReference cancel() {
        system.debug('Inside cancel');
        boolean cancelRelationship = true;
        Account_Relationship__c ar = new Account_Relationship__c();
        ar.comarketing_status__c = 'Pending Cancellation';
        ar.Comarketing_Zuora_InProgress__c = true;
        ar.Comarketing_Cancellation_Date__c = Date.today(); //LCM-67
        ar.Total_comarketing_assets__c = 0;
        ar.Active__c = false;
        ar.comarketing_action__c = 'Cancel';
        ar.Comarketing_Cancellation_Description__c = ApexPages.currentPage().getParameters().get('desc');
        ar.comarketing_Cancellation_Reason__c = ApexPages.currentPage().getParameters().get('reason');
        ar.id = ApexPages.currentPage().getParameters().get('rId');
        List<comarketing_relationship__c> crList = [select lender_asset_monthly_contribution__c, id,status__c,agent_zuora_status__c,lender_zuora_status__c from comarketing_relationship__c where relationship__c=:ApexPages.currentPage().getParameters().get('rId') AND (status__c = 'Active' OR status__c = 'Pending Activation')]; 
        for(comarketing_relationship__c cr: crList){
            // LCM-214
            if(cr.agent_zuora_status__c == null && cr.lender_zuora_status__c == null && cr.status__c != 'Active'){
                 cr.status__c = 'Cancelled';
                 if(ar.comarketing_status__c != 'Cancelled'){
                     ar.comarketing_status__c = 'Cancelled';
                 }
            } else {
                if(cr.lender_asset_monthly_contribution__c != null && cr.lender_asset_monthly_contribution__c >0){
                     cr.status__c = 'Pending Cancellation';
                     cr.agent_zuora_status__c = 'Pending Update';
                     cr.lender_zuora_status__c = 'Pending Update';
                     cancelRelationship = false;
                }else{
                    cr.status__c = 'Cancelled';
                    cr.agent_zuora_status__c = 'Success';
                    cr.lender_zuora_status__c = 'Success';
                    cr.agent_zuora_comment__c = 'No subscription to cancel because its zero dollar';
                    cr.lender_zuora_comment__c = 'No subscription to cancel because its zero dollar';
                }
            }
            cr.action__c = 'Cancel';
            cr.lender_cancellation_Date__c = system.today();
            cr.agent_cancellation_date__c = system.today();
            cr.Cancellation_Reason__c = ApexPages.currentPage().getParameters().get('reason');
            cr.Cancel_Description__c = ApexPages.currentPage().getParameters().get('desc');
  
        }
        if(cancelRelationship){
            ar.comarketing_status__c = 'Cancelled';
            ar.Comarketing_Zuora_InProgress__c = false;
        }
        update ar;
        update crList;
        return null;
    }
}