/*******************************************************************************
Created By      :   Srinivas Pendli
Created Date    :   28-APRIL-2016
Usage           :   This Class is to swap componet values from kicker qualified values to kicker unqualified 
                    values (Component New Sale with Qualified to New Sale without Qualified Vice Versa and Renewal with Qualified to Renewal without Qualified Vice Versa.
                    * Swaping only for signing AE commissions not for asset owner commissions,by default we are assiging Asset owner component to New Sale    
                      without Qualifier,  
                    * In the old commission logic we are assiging asset owner to asset owner component but in the commission process by default it is New 
                      Sale without Qualifier
                    * No Swaping applicable for Asset owner commission.
Modified By     :   Srinivas Pendli
Modified Date   :   28-APRIL-2016
Modified Date   :   28-SEPTM-2016 : Added Swap Methods for Retention Team (Retetion Commissionable Amount to Escalated Commissionable Amount & Vice Versa)
Modified Date   :   01-FEB-2017   : Asset renewal type replaced with Line type for CFCB Issue.
Modified Date   :   03-MARCH-2017 : Modified the swap logic as per the commissions new business logic
Modified date   :   14-APRIL-2017 : Modified the code as per #CRM-1404 -line #no-51,61
Modified date   :   10-JULY-2017 : Modified the code as per #CRM-1931 -line #no-63-68,77-82,91-96,106-111
********************************************************************************/

public class Commissions_KickerQualifierSwapClass{
    //SWAP COMPONENTS FROM NEW SALE WITH TO WITHOUT AND RENEWAL WITH TO WITHOUT QUALIFIER VICE VERSA.
    public void swapMethod(Set<id> qids){
        system.debug('swapMethod :'+qids);        
        Map<id,Commission__c> mapCommissionCFCB = new Map<id,Commission__c>();
        Map<id,commission__c> mapCommissions = new Map<Id,Commission__c>([Select id,Name,Asset_amount2__c,Commissionable_Amount2__c,Commissionable_Amount1B__c,
                        Renewal_w_o_Qualifier_Comm_ble_Amount__c,Renewal_w_Qualifier_Comm_ble_Amount__c,
                        Line_Type__c,Related_To_Quota__r.is_kicker__c,Related_To_Quota__r.RD_Team_Qualifier__c,User_Team__c,Related_To_Quota__r.user__c,Signing_AE__c,
                        Product_Category__c,Commission_Split__c,Payout_Rate__c,Payout_Rate1B__c,Renewal_w_o_Qualifier_Payout_Rate__c,
                        Renewal_w_Qualifier_Payout_Rate__c,Related_To_Quota__r.Quota_StartDate__c   
                        from commission__c where RecordType.Name !=: Commissions_Constants.COMMISSIONS_CLAWBACK and
                        User_Team__c !=: Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM and 
                        RecordType.Name !=: Commissions_Constants.Other_Products_RECORD_TYPE and Related_To_Quota__c IN : qids]);
        for(Commission__c comm : mapCommissions.values()){
            if(comm.Related_To_Quota__r.Quota_StartDate__c  >= Date.newInstance(2017,07,01)){
                //SWAP FROM NEW SALE WITH QUALIFIER TO WITHOUT QULIFIER FOR LINE TYPE 'ADD' AND 'AMEND' COMMISSIONS
                if(comm.User_Team__c == Commissions_Constants.MANAGERS_TEAM){                   
                    if(comm.Line_Type__c =='Renew'){
                        if(comm.Commissionable_Amount2__c != 0.0){
                            comm.Renewal_w_o_Qualifier_Comm_ble_Amount__c = comm.Commissionable_Amount2__c;
                            comm.Renewal_w_o_Qualifier_Payout_Rate__c = comm.Payout_Rate__c;
                            comm.Commissionable_Amount2__c = 0.0;
                        }
                        comm.Payout_Rate__c = 0.0;
                        //mapCommissionCFCB.put(comm.id,comm);
                    }
                    if(comm.Line_Type__c !='Renew'){
                        if(comm.Renewal_w_o_Qualifier_Comm_ble_Amount__c != 0.0){
                            comm.Commissionable_Amount2__c = comm.Renewal_w_o_Qualifier_Comm_ble_Amount__c;
                            comm.Payout_Rate__c = comm.Renewal_w_o_Qualifier_Payout_Rate__c;
                            comm.Renewal_w_o_Qualifier_Comm_ble_Amount__c= 0.0;
                        }
                        comm.Renewal_w_o_Qualifier_Payout_Rate__c = 0.0;
                        //mapCommissionCFCB.put(comm.id,comm);
                    }
                    mapCommissionCFCB.put(comm.id,comm);
                }           
                else{
                    if(!comm.Related_To_Quota__r.is_kicker__c && (comm.Line_Type__c == 'Add' || comm.Line_Type__c == 'Amend')){                
                        if(comm.Commissionable_Amount1B__c != 0.0){
                            comm.Commissionable_Amount2__c  = comm.Commissionable_Amount1B__c;
                            comm.Payout_Rate__c = comm.Payout_Rate1B__c;
                        }
                        comm.Commissionable_Amount1B__c = 0.0;
                        comm.Renewal_w_o_Qualifier_Comm_ble_Amount__c = 0.0;
                        comm.Renewal_w_Qualifier_Comm_ble_Amount__c= 0.0;
                        comm.Payout_Rate1B__c = 0.0;
                        comm.Renewal_w_o_Qualifier_Payout_Rate__c = 0.0;
                        comm.Renewal_w_Qualifier_Payout_Rate__c = 0.0;    
                        mapCommissionCFCB.put(comm.id,comm);
                    }
                    //SWAP FROM NEW SALE WITHOUT QUALIFIER TO WITH QULIFIER FOR LINE TYPE 'ADD' AND 'AMEND' COMMISSIONS
                    if(comm.Related_To_Quota__r.is_kicker__c && (comm.Line_Type__c == 'Add' || comm.Line_Type__c == 'Amend')){
                        if(comm.Commissionable_Amount2__c != 0.0){
                            comm.Commissionable_Amount1B__c = comm.Commissionable_Amount2__c;
                            comm.Payout_Rate1B__c = comm.Payout_Rate__c;
                        }
                        comm.Commissionable_Amount2__c = 0.0;
                        comm.Renewal_w_o_Qualifier_Comm_ble_Amount__c = 0.0;
                        comm.Renewal_w_Qualifier_Comm_ble_Amount__c= 0.0;
                        comm.Payout_Rate__c = 0.0;
                        comm.Renewal_w_o_Qualifier_Payout_Rate__c = 0.0;
                        comm.Renewal_w_Qualifier_Payout_Rate__c = 0.0;    
                        mapCommissionCFCB.put(comm.id,comm);
                    }
                    //SWAP FROM RENEWAL WITH QUALIFIER TO WITHOUT QULIFIER FOR LINE TYPE 'RENEW' COMMISSIONS
                    if(comm.Related_To_Quota__r.is_kicker__c && comm.Line_Type__c == 'Renew'){
                        if(comm.Renewal_w_o_Qualifier_Comm_ble_Amount__c != 0.0 ){
                            comm.Renewal_w_Qualifier_Comm_ble_Amount__c  = (comm.Renewal_w_o_Qualifier_Comm_ble_Amount__c);
                            comm.Renewal_w_Qualifier_Payout_Rate__c = comm.Renewal_w_o_Qualifier_Payout_Rate__c;
                        }
                        comm.Renewal_w_o_Qualifier_Comm_ble_Amount__c = 0.0;
                        comm.Commissionable_Amount2__c = 0.0;
                        comm.Commissionable_Amount1B__c = 0.0;
                        comm.Payout_Rate__c = 0.0;
                        comm.Payout_Rate1B__c = 0.0;                    
                        comm.Renewal_w_o_Qualifier_Payout_Rate__c = 0.0;

                        mapCommissionCFCB.put(comm.id,comm);
                    }
                    //SWAP FROM RENEWAL WITHOUT QUALIFIER TO WITH QULIFIER FOR LINE TYPE 'RENEW' COMMISSIONS
                    if(!comm.Related_To_Quota__r.is_kicker__c && comm.Line_Type__c == 'Renew'){
                        if(comm.Renewal_w_Qualifier_Comm_ble_Amount__c != 0.0 ){
                            comm.Renewal_w_o_Qualifier_Comm_ble_Amount__c  = (comm.Renewal_w_Qualifier_Comm_ble_Amount__c);
                            comm.Renewal_w_o_Qualifier_Payout_Rate__c = comm.Renewal_w_Qualifier_Payout_Rate__c;
                        }
                        comm.Renewal_w_Qualifier_Comm_ble_Amount__c = 0.0;
                        comm.Commissionable_Amount2__c  = 0.0;
                        comm.Commissionable_Amount1B__c  = 0.0;
                        comm.Payout_Rate__c = 0.0;
                        comm.Payout_Rate1B__c = 0.0;                    
                        comm.Renewal_w_Qualifier_Payout_Rate__c = 0.0;               
                        mapCommissionCFCB.put(comm.id,comm);
                    }   
                }  
            }           
        }
        //UPDATING COMMISSIONS
        
        if(!mapCommissionCFCB.isEmpty()){
            upsert mapCommissionCFCB.values();
        }
        mapCommissionCFCB.clear();      
    }
    //RD TEAM COMPONENTS SWAP METHOD - Component 1A to 1B,1B to 1A.
    public void swapMethodBrokerRD(Set<id> qids){
        //We are not calculating the payouts for RD team - commentedby Srinivas Pendli
        /***************************************
        Map<id,Commission__c> mapCommissionBrokerRD = new Map<id,Commission__c>();
        Map<id,commission__c> mapCommissions = new Map<Id,Commission__c>([Select id,Name,Asset_amount2__c,Commissionable_Amount2__c,Commissionable_Amount1B__c,
                            Line_Type__c,Related_To_Quota__r.is_kicker__c,Related_To_Quota__r.RD_Team_Qualifier__c,User_Team__c,
                            Related_To_Quota__r.user__c,Signing_AE__c,Product_Category__c,Commission_Split__c,Payout_Rate__c,Payout_Rate1B__c  
                            from commission__c where  RecordType.Name !=: Commissions_Constants.COMMISSIONS_CLAWBACK and 
                            User_Team__c =: Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM and Related_To_Quota__c IN : qids]);
        for(Commission__c comm : mapCommissions.values()){
            //RD TEAM QULIFIED COMPONENS SWAP - COMPONENT 1A TO 1B
            if(comm.Related_To_Quota__r.RD_Team_Qualifier__c == TRUE){
                
                if(comm.Commissionable_Amount2__c != 0.0){
                    comm.Commissionable_Amount1B__c  = comm.Commissionable_Amount2__c;
                }
                comm.Commissionable_Amount2__c = 0.0;
                comm.Payout_Rate__c = 0.0;
                mapCommissionBrokerRD.put(comm.id,comm);
            }
            //RD TEAM UN-QULIFIED COMPONENS SWAP - COMPONENT 1B TO 1A
            if(comm.Related_To_Quota__r.RD_Team_Qualifier__c == FALSE){
                
                if(comm.Commissionable_Amount1B__c != 0.0){
                    comm.Commissionable_Amount2__c  = comm.Commissionable_Amount1B__c;
                }
                comm.Commissionable_Amount1B__c = 0.0;
                comm.Payout_Rate1B__c = 0.0;
                mapCommissionBrokerRD.put(comm.id,comm);
            }       
                     
        }
        //UPDATING COMMISSIONS
        List<Error__c> lstError = new List<Error__c>();
        if(!mapCommissionBrokerRD.isEmpty()){
            upsert mapCommissionBrokerRD.values();
        }
        mapCommissionBrokerRD.clear();
        if(!lstError.isEmpty()){
            insert lstError;
        }
        **************************************************/
    }
    //Addition by Sandeep Meka
    //RETENTION TEAM COMPONENTS SWAP METHOD - Component Retention to Escalation, Escalation to Retention.
    public void swapMethodRetention(Set<id> qids){
        Map<id,Commission__c> mapCommissionRetention = new Map<id,Commission__c>();
        Map<id,commission__c> mapCommissions = new Map<Id,Commission__c>([Select id,Name,Asset_amount2__c,Retention_Commissionable_Amount1__c,Escalated_Commission_Amount__c,
                            Case_Asset_Relationship__c,Related_To_Quota__r.Retention_Escalation__c,User_Team__c,
                            Related_To_Quota__r.user__c from commission__c where RecordType.Name !=: Commissions_Constants.COMMISSIONS_CLAWBACK and 
                            User_Team__c =: Commissions_Constants.RETENTION_TEAM and Related_To_Quota__c IN : qids]);
        for(Commission__c comm : mapCommissions.values()){     
            if(comm.Related_To_Quota__r.Retention_Escalation__c){
                if(comm.Retention_Commissionable_Amount1__c == Null){
                    comm.Retention_Commissionable_Amount1__c = 0.0;
                }
                if(comm.Escalated_Commission_Amount__c == Null){
                    comm.Escalated_Commission_Amount__c = 0.0;
                }
                if(comm.Retention_Commissionable_Amount1__c != 0.0 && comm.Retention_Commissionable_Amount1__c != null){                   
                    comm.Escalated_Commission_Amount__c  = comm.Retention_Commissionable_Amount1__c;
                    comm.Retention_Commissionable_Amount1__c = 0.0;
                    mapCommissionRetention.put(comm.id,comm);
                }                
            }           
            //RETENTION TEAM UN-QULIFIED COMPONENS SWAP - COMPONENT ESCALATION TO RETENTION 
            if(!comm.Related_To_Quota__r.Retention_Escalation__c && comm.Escalated_Commission_Amount__c != 0.0 && comm.Escalated_Commission_Amount__c!= null){                                
                    comm.Retention_Commissionable_Amount1__c  = comm.Escalated_Commission_Amount__c;
                    comm.Escalated_Commission_Amount__c = 0.0;
                    mapCommissionRetention.put(comm.id,comm);                             
            }         
        }
        //UPDATING COMMISSIONS
        List<Error__c> lstError = new List<Error__c>();
        if(!mapCommissionRetention.isEmpty()){
            upsert mapCommissionRetention.values();
        }            
        mapCommissionRetention.clear();
        if(!lstError.isEmpty()){
            insert lstError;
        }
    }    
}