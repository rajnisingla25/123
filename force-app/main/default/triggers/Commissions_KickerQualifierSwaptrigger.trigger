/*******************************************************************************
Created By      :   Srinivas Pendli
Created Date    :   28-APRIL-2016
Usage           :   This trigger is to swap CFCB componet values from kicker qualified values to kicker unqualified 
                    values (Component 2A to 2B,2B to 2A and 2C to 2D,2D to 2C)for CFCB product values and 
                    RD Team Qualified values(Component 1A to 1B and 1B to 1A).
                    
Modified By     :   Srinivas Pendli
Modified Date   :   28-APRIL-2016

********************************************************************************/
trigger Commissions_KickerQualifierSwaptrigger on Commission__c (after update){
    if(Commissions_TriggerHelperClass.kickerQualifier == false){
        Commissions_TriggerHelperClass.kickerQualifier = true;
        //VARIABLE DECLERATION
        Map<id,Commission__c> mapCommissionCFCB = new Map<id,commission__c>();
        Map<id,Commission__c> mapCommissionBrokerRD = new Map<id,commission__c>();
        //HANDLER CLASS
        Commissions_KickerQualifierSwapClass KQSwap = new Commissions_KickerQualifierSwapClass(); 
        //GETTING COMMISSION RECORDS BASED ON THE BELOW MENTIONED CONDTIONS.
        List<commission__c> commissionsList = [Select id,Name,Asset_amount2__c,Commissionable_Amount2__c,Commissionable_Amount1B__c,CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c,
                        CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c,CFCB_RNW_w_Qualifier_Comm_ble_Amount2C__c,CFCB_RNW_w_o_Qualifier_Comm_ble_Amount2D__c,
                        Related_To_Asset__r.Renewal_Type__c,Related_To_Quota__r.is_kicker__c,Related_To_Quota__r.RD_Team_Qualifier__c,User_Team__c,Related_To_Quota__r.user__c,Signing_AE__c,
                        Product_Category__c,Commission_Split__c from commission__c where 
                        User_Team__c !=: Commissions_Constants.MANAGERS_TEAM and id In : Trigger.newMap.keySet()];
        //COMMISSION RECORD COLLECTION AS PER BUSINESS LOGIC
        for(commission__c commNewRec : commissionsList){
            commission__c commOldRec= Trigger.oldMap.get(commNewRec.Id);
            if(commNewRec.User_Team__c != Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM && commNewRec.User_Team__c != Commissions_Constants.MANAGERS_TEAM){
                if(commNewRec.Related_To_Quota__r.user__c != commNewRec.Signing_AE__c){
                    mapCommissionCFCB.put(commNewRec.id,commNewRec);
                }
            }      
            if(commNewRec.User_Team__c == Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM){// && ( commNewRec.Related_To_Quota__r.RD_Team_Qualifier__c != commOldRec.Related_To_Quota__r.RD_Team_Qualifier__c))
                mapCommissionBrokerRD.put(commNewRec.id,commNewRec);
            }
        }
        //SENDING COLLECTED COMMISSION RECORDS TO "Commissions_KickerQualifierSwapClass" HANDLER CLASEE
        if(mapCommissionCFCB.size() > 0){
            //KQSwap.SwapMethod_CFCB(mapCommissionCFCB);    
        }
        if(mapCommissionBrokerRD.size() > 0){
            //KQSwap.SwapMethod_BrokerRD(mapCommissionBrokerRD);    
        }
    }
}