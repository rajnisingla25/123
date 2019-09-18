global class Commissions_SendCompPlanToFinanceCtrl {
    
    Webservice static string updateSendCompensationPlanToFinance(Id quotaId){
        List<Quota__c> quotaToSendCompPlanList = [Select Id,Send_Comp_Plan_to__c From Quota__c Where Id = :quotaId];
        if(quotaToSendCompPlanList.size() > 0){
        	quotaToSendCompPlanList[0].Send_Comp_Plan_to__c = UserInfo.getUserEmail();
            Database.SaveResult[] result = Database.update(quotaToSendCompPlanList);
        
            if(result[0].isSuccess()){
                return 'Success';
            }
            else
                return 'Error';
        }
        return '';
    }

}