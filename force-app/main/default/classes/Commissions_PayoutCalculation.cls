/*******************************************************************************
Created By         :   Srinivas Pendli
Created Date       :   04-FEB-2017
Usage              :   It will uodate the payout rates from quota for all the teams with all products.
2. Modified Date   :   13-APRIL-2017
3. Modified By     :   Srinivas Pendli for #CRM - 1365

********************************************************************************/
public class Commissions_PayoutCalculation{
    //CALLING THIS METHOD FROM COMMISSION TRIGGER
    Public Boolean isSucess = FALSE;
    Public void payoutCalculation(Set<id> quotaIds,Map<Id,Quota__c> mapQuotas){
        
        system.debug('payoutCalculation :');
        Map<Id,Commission__c> mapCommissions = new Map<Id,Commission__c>();
        //RETRIVE ALL COMMISSIONS OF SELECTED QUOTA
        List<Commission__c> listCommissions = [Select id,Name,Final_Commission__c,Product__r.ProductCode,Related_to_Quota__c,Line_Type__c,Payout_Rate__c,
                            Payout_Rate1B__c ,RecordType.Name,Renewal_w_o_Qualifier_Payout_Rate__c,Renewal_w_Qualifier_Payout_Rate__c,Commissionable_Amount2__c,Commissionable_Amount1B__c,
                            Renewal_w_o_Qualifier_Comm_ble_Amount__c,Renewal_w_Qualifier_Comm_ble_Amount__c,User_Team__c,Related_Commission__c, Product_Category__c,
                            Related_Commission__r.Payout_Rate__c,Other_Product__c,Related_Commission__r.Payout_Rate1B__c,Related_Commission__r.Renewal_w_o_Qualifier_Payout_Rate__c,Related_Commission__r.Renewal_w_Qualifier_Payout_Rate__c,
                            Related_Commission__r.CFCB_NEW_w_Qualifier_Payout_Rate1__c,Related_Commission__r.CFCB_New_w_o_Qualifier_Payout_Rate1__c,Related_Commission__r.CFCB_RNW_w_Qualifier_Payout_Rate1__c,
                            Related_Commission__r.CFCB_RNW_w_o_Qualifier_Payout_Rate1__c,Related_Commission__r.CreatedDate,Related_Commission__r.Asset_Owner_Payout_Rate1__c,
                            Related_Commission__r.Historic_CFCB_NewSale_With_Q_Payout__c,Related_Commission__r.Historic_CFCB_New_Sale_w_o_Qualifier_Pay__c,
                            Related_Commission__r.Historic_CFCB_RNW_W_Q_Payout_Rate__c,Related_Commission__r.Historic_CFCB_RNW_w_o_Q_Payout_Rate__c,Related_Commission__r.Historic_Asset_Owner_Payout_Rate__c,
                            Related_Commission__r.HistoricNew_Sale_W_OQualifier_PayoutRate__c,Related_Commission__r.HistorNew_Sale_WithQualifier_Payout_Rate__c
                            from Commission__c where Related_to_Quota__c In : quotaIds];
                            
        Decimal finalcommissionpayout =0.0;
        //UPDATE PAYOUTS ON COMMISSION RECORDS -
        //IT WILL RETRIVE ALL PRODUCTS AND MANAGERS PAYOUT RATES FROM QUOTA AND IT WILL UPDATE ON RESPECTIVE COMMISSION RECORDS BASED ON THE LINE TYPE AND QUOTA KICKER
        for(Commission__c commission : listCommissions){
            system.debug('commission 1:'+commission);
            finalcommissionpayout = 0.0;
            //if(commission.Final_Commission__c == Null){
                
            //}            
            Quota__c quotaRecord = mapQuotas.get(commission.Related_to_Quota__c);  
            if(quotaRecord != Null){  
                system.debug('commission 2:'+commission);              
                //UPDATE PAYOUTS FOR LINE TYPE - NEW COMMISSIONS
                if(commission.Line_Type__c != 'Renew' && commission.Related_Commission__c == Null){
                    if(commission.Product__r.ProductCode =='ADVANTAGE'){
                        if(!quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate__c = quotaRecord.ADVANTAGE_New__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate1B__c = quotaRecord.ADVANTAGE_New__c;
                        }                   
                    }
                    if(commission.Product__r.ProductCode =='COBROKE'){
                        if(!quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate__c = quotaRecord.COBROKE_New__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate1B__c = quotaRecord.COBROKE_New__c;
                        }
                    }
                    if(commission.Product__r.ProductCode =='DACAMPAIGN'){
                        if(!quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate__c = quotaRecord.DACAMPAIGN_New__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate1B__c = quotaRecord.DACAMPAIGN_New__c;
                        }
                    }
                    if(commission.Product__r.ProductCode =='DIGITALAGENT'){
                       if(!quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate__c = quotaRecord.DIGITALAGENT_New__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate1B__c = quotaRecord.DIGITALAGENT_New__c;
                        } 
                    }
                    if(commission.Product__r.ProductCode =='DOMAINNAME'){
                       if(!quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate__c = quotaRecord.DOMAINNAME_New__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate1B__c = quotaRecord.DOMAINNAME_New__c;
                        } 
                    }
                    if(commission.Product__r.ProductCode =='FEATCMA'){
                        if(!quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate__c = quotaRecord.FEATCMA_New__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate1B__c = quotaRecord.FEATCMA_New__c;
                        }
                    }
                    if(commission.Product__r.ProductCode =='FEATDISP'){
                       if(!quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate__c = quotaRecord.FEATDISP_New__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate1B__c = quotaRecord.FEATDISP_New__c;
                        }
                    }
                    if(commission.Product__r.ProductCode =='FEATHOMES'){
                       if(!quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate__c = quotaRecord.FEATHOMES_New__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate1B__c = quotaRecord.FEATHOMES_New__c;
                        }
                    }
                    if(commission.Product__r.ProductCode =='FIVESTREET'){
                       if(!quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate__c = quotaRecord.FIVESTREET_New__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate1B__c = quotaRecord.FIVESTREET_New__c;
                        }  
                    }
                    if(commission.Product__r.ProductCode =='LISTHUBPRO'){
                      if(!quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate__c = quotaRecord.LISTHUBPRO_New__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate1B__c = quotaRecord.LISTHUBPRO_New__c;
                        }
                    }
                    if(commission.Product__r.ProductCode =='MRKTBUILD'){
                      if(!quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate__c = quotaRecord.MRKTBUILD_New__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate1B__c = quotaRecord.MRKTBUILD_New__c;
                        }
                    }
                    if(commission.Product__r.ProductCode =='SELLERLEAD'){
                       if(!quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate__c = quotaRecord.SELLERLEAD_New__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate1B__c = quotaRecord.SELLERLEAD_New__c;
                        }
                    }
                    if(commission.Product__r.ProductCode =='SELLERLEADBUNDLE'){
                        if(!quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate__c = quotaRecord.SELLERLEADBUNDLE_New__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate1B__c = quotaRecord.SELLERLEADBUNDLE_New__c;
                        }  
                    }
                    if(commission.Product__r.ProductCode =='SHOWCASE'){
                       if(!quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate__c = quotaRecord.SHOWCASE_New__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate1B__c = quotaRecord.SHOWCASE_New__c;
                        }  
                    }
                    if(commission.Product__r.ProductCode =='SIGNRIDER'){
                      if(!quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate__c = quotaRecord.SIGNRIDER_New__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate1B__c = quotaRecord.SIGNRIDER_New__c;
                        }
                    }
                    if(commission.Product__r.ProductCode =='STANDLIST'){
                       if(!quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate__c = quotaRecord.STANDLIST_New__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate1B__c = quotaRecord.STANDLIST_New__c;
                        }
                    }
                    if(commission.Product__r.ProductCode =='TOPCRM'){
                        if(!quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate__c = quotaRecord.TOPCRM_New__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate1B__c = quotaRecord.TOPCRM_New__c;
                        }
                    }
                    if(commission.Product__r.ProductCode =='TOPIDX'){
                        if(!quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate__c = quotaRecord.TOPIDX_New__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate1B__c = quotaRecord.TOPIDX_New__c;
                        }
                    }
                    if(commission.Product__r.ProductCode =='TOPMRKSNP'){
                        if(!quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate__c = quotaRecord.TOPMRKSNP_New__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate1B__c = quotaRecord.TOPMRKSNP_New__c;
                        }
                    }
                    if(commission.Product__r.ProductCode =='TOPWEB'){
                        if(!quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate__c = quotaRecord.TOPWEB_New__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate1B__c = quotaRecord.TOPWEB_New__c;
                        }  
                    }
                    if(commission.Product__r.ProductCode =='TOPWEBFEE'){
                        if(!quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate__c = quotaRecord.TOPWEBFEE_New__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate1B__c = quotaRecord.TOPWEBFEE_New__c;
                        }
                    }
                     if(commission.Product__r.ProductCode =='TRKPHNMBR'){
                        if(!quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate__c = quotaRecord.TRKPHNMBR_New__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate1B__c = quotaRecord.TRKPHNMBR_New__c;
                        }  
                    }
                    if(commission.Product__r.ProductCode =='TURBO'){
                        if(!quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate__c = quotaRecord.TURBO_New__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate1B__c = quotaRecord.TURBO_New__c;
                        }  
                    }
                    if(commission.Product__r.ProductCode =='WEBSITE'){
                        if(!quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate__c = quotaRecord.WEBSITE_New__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate1B__c = quotaRecord.WEBSITE_New__c;
                        }  
                    }
                    if(commission.Product__r.ProductCode =='WEBSITEFEE'){
                        if(!quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate__c = quotaRecord.WEBSITEFEE_New__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate1B__c = quotaRecord.WEBSITEFEE_New__c;
                        }
                    }
                    if(commission.Product__r.ProductCode =='REESIO'){
                        if(!quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate__c = quotaRecord.REESIO_New__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate1B__c = quotaRecord.REESIO_New__c;
                        }
                    }
                    if(commission.Product__r.ProductCode =='RSRESPOND'){
                        if(!quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate__c = quotaRecord.RSRESPOND_New__c ;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate1B__c = quotaRecord.RSRESPOND_New__c ;
                        }
                    }
                    //#CRM -1727 - Added Pay out rates for Broker Highlight products.
                    if(commission.Product__r.ProductCode =='MEDIABUY'){
                        if(!quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate__c = quotaRecord.MEDIABUY_New__c ;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate1B__c = quotaRecord.MEDIABUY_New__c ;
                        }
                    }
                    //#CRM -3163 - Added Pay out rates for RealSuit products.
                    if(commission.Product__r.ProductCode =='RSCONNECT'){
                        if(!quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate__c = quotaRecord.RSCONNECT_New__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate1B__c = quotaRecord.RSCONNECT_New__c;
                        }
                    }
                    if(commission.Product__r.ProductCode =='RSTRANSACT'){
                        if(!quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate__c = quotaRecord.RSTRANSACT_New__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate1B__c = quotaRecord.RSTRANSACT_New__c;
                        }
                    }
                    if(commission.Payout_Rate__c !=0.0){
                        finalcommissionpayout = commission.Payout_Rate__c;
                    }
                    if(commission.Payout_Rate1B__c !=0.0){
                        finalcommissionpayout = commission.Payout_Rate1B__c;
                    }   
                    commission.Final_Commission__c = 0.0;                 
                    if(commission.Commissionable_Amount2__c !=0.0 && commission.Commissionable_Amount2__c !=null && finalcommissionpayout != null){
                        commission.Final_Commission__c = 0.0;
                        commission.Final_Commission__c = (commission.Commissionable_Amount2__c * finalcommissionpayout)/100;
                    }
                    if(commission.Commissionable_Amount1B__c !=0.0 && commission.Commissionable_Amount1B__c !=null && finalcommissionpayout != null){
                        commission.Final_Commission__c = 0.0;
                        commission.Final_Commission__c = (commission.Commissionable_Amount1B__c * finalcommissionpayout)/100;
                    }               
                    mapCommissions.put(commission.id,commission);  
                    system.debug('mapCommissions 1 :'+commission);
                    system.debug('mapCommissions 1 :'+mapCommissions.size());
                }
                //UPDATE PAYOUTS FOR LINE TYPE - NEW COMMISSIONS - LOGIC END
                //UPDATE PAYOUTS FOR LINE TYPE - RENEW COMMISSIONS - LOGIC START
                if(commission.Line_Type__c == 'Renew' && commission.Related_Commission__c == null){
                    if(commission.Product__r.ProductCode =='ADVANTAGE'){
                        if(!quotaRecord.Is_Kicker__c ){
                            commission.Renewal_w_o_Qualifier_Payout_Rate__c = quotaRecord.ADVANTAGE_Renew__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_Qualifier_Payout_Rate__c = quotaRecord.ADVANTAGE_Renew__c;
                        }                   
                    }
                    if(commission.Product__r.ProductCode =='COBROKE'){
                        if(!quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_o_Qualifier_Payout_Rate__c = quotaRecord.COBROKE_Renew__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_Qualifier_Payout_Rate__c = quotaRecord.COBROKE_Renew__c;
                        }
                    }
                    if(commission.Product__r.ProductCode =='DACAMPAIGN'){
                        if(!quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_o_Qualifier_Payout_Rate__c = quotaRecord.DACAMPAIGN_Renew__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_Qualifier_Payout_Rate__c = quotaRecord.DACAMPAIGN_Renew__c;
                        }
                    }
                    if(commission.Product__r.ProductCode =='DIGITALAGENT'){
                       if(!quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_o_Qualifier_Payout_Rate__c = quotaRecord.DIGITALAGENT_Renew__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_Qualifier_Payout_Rate__c = quotaRecord.DIGITALAGENT_Renew__c;
                        } 
                    }
                    if(commission.Product__r.ProductCode =='DOMAINNAME'){
                       if(!quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_o_Qualifier_Payout_Rate__c = quotaRecord.DOMAINNAME_Renew__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_Qualifier_Payout_Rate__c = quotaRecord.DOMAINNAME_Renew__c;
                        } 
                    }
                    if(commission.Product__r.ProductCode =='FEATCMA'){
                        if(!quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_o_Qualifier_Payout_Rate__c = quotaRecord.FEATCMA_Renew__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_Qualifier_Payout_Rate__c = quotaRecord.FEATCMA_Renew__c;
                        }
                    }
                    if(commission.Product__r.ProductCode =='FEATDISP'){
                       if(!quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_o_Qualifier_Payout_Rate__c = quotaRecord.FEATDISP_Renew__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_Qualifier_Payout_Rate__c = quotaRecord.FEATDISP_Renew__c;
                        }
                    }
                    if(commission.Product__r.ProductCode =='FEATHOMES'){
                       if(!quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_o_Qualifier_Payout_Rate__c = quotaRecord.FEATHOMES_Renew__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_Qualifier_Payout_Rate__c = quotaRecord.FEATHOMES_Renew__c;
                        }
                    }
                    if(commission.Product__r.ProductCode =='FIVESTREET'){
                       if(!quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_o_Qualifier_Payout_Rate__c = quotaRecord.FIVESTREET_Renew__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_Qualifier_Payout_Rate__c = quotaRecord.FIVESTREET_Renew__c;
                        }  
                    }
                    if(commission.Product__r.ProductCode =='LISTHUBPRO'){
                      if(!quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_o_Qualifier_Payout_Rate__c = quotaRecord.LISTHUBPRO_Renew__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_Qualifier_Payout_Rate__c = quotaRecord.LISTHUBPRO_Renew__c;
                        }
                    }
                    if(commission.Product__r.ProductCode =='MRKTBUILD'){
                      if(!quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_o_Qualifier_Payout_Rate__c = quotaRecord.MRKTBUILD_Renew__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_Qualifier_Payout_Rate__c = quotaRecord.MRKTBUILD_Renew__c;
                        }
                    }
                    if(commission.Product__r.ProductCode =='SELLERLEAD'){
                       if(!quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_o_Qualifier_Payout_Rate__c = quotaRecord.SELLERLEAD_Renew__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_Qualifier_Payout_Rate__c = quotaRecord.SELLERLEAD_Renew__c;
                        }
                    }
                    if(commission.Product__r.ProductCode =='SELLERLEADBUNDLE'){
                        if(!quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_o_Qualifier_Payout_Rate__c = quotaRecord.SELLERLEADBUNDLE_Renew__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_Qualifier_Payout_Rate__c = quotaRecord.SELLERLEADBUNDLE_Renew__c;
                        }  
                    }
                    if(commission.Product__r.ProductCode =='SHOWCASE'){
                       if(!quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_o_Qualifier_Payout_Rate__c = quotaRecord.SHOWCASE_Renew__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_Qualifier_Payout_Rate__c = quotaRecord.SHOWCASE_Renew__c;
                        }  
                    }
                    if(commission.Product__r.ProductCode =='SIGNRIDER'){
                      if(!quotaRecord.Is_Kicker__c ){
                            commission.Renewal_w_o_Qualifier_Payout_Rate__c = quotaRecord.SIGNRIDER_Renew__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_Qualifier_Payout_Rate__c = quotaRecord.SIGNRIDER_Renew__c;
                        }
                    }
                    if(commission.Product__r.ProductCode =='STANDLIST'){
                       if(!quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_o_Qualifier_Payout_Rate__c = quotaRecord.STANDLIST_Renew__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_Qualifier_Payout_Rate__c = quotaRecord.STANDLIST_Renew__c;
                        }
                    }
                    if(commission.Product__r.ProductCode =='TOPCRM'){
                        if(!quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_o_Qualifier_Payout_Rate__c = quotaRecord.TOPCRM_Renew__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_Qualifier_Payout_Rate__c = quotaRecord.TOPCRM_Renew__c;
                        }
                    }
                    if(commission.Product__r.ProductCode =='TOPIDX'){
                        if(!quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_o_Qualifier_Payout_Rate__c = quotaRecord.TOPIDX_Renew__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_Qualifier_Payout_Rate__c = quotaRecord.TOPIDX_Renew__c;
                        }
                    }
                    if(commission.Product__r.ProductCode =='TOPMRKSNP'){
                        if(!quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_o_Qualifier_Payout_Rate__c = quotaRecord.TOPMRKSNP_Renew__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_Qualifier_Payout_Rate__c = quotaRecord.TOPMRKSNP_Renew__c;
                        }
                    }
                    if(commission.Product__r.ProductCode =='TOPWEB'){
                        if(!quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_o_Qualifier_Payout_Rate__c = quotaRecord.TOPWEB_Renew__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_Qualifier_Payout_Rate__c = quotaRecord.TOPWEB_Renew__c;
                        }  
                    }
                    if(commission.Product__r.ProductCode =='TOPWEBFEE'){
                        if(!quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_o_Qualifier_Payout_Rate__c = quotaRecord.TOPWEBFEE_Renew__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_Qualifier_Payout_Rate__c = quotaRecord.TOPWEBFEE_Renew__c;
                        }
                    }
                     if(commission.Product__r.ProductCode =='TRKPHNMBR'){
                        if(!quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_o_Qualifier_Payout_Rate__c = quotaRecord.TRKPHNMBR_Renew__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_Qualifier_Payout_Rate__c = quotaRecord.TRKPHNMBR_Renew__c;
                        }  
                    }
                    if(commission.Product__r.ProductCode =='TURBO'){
                        if(!quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_o_Qualifier_Payout_Rate__c = quotaRecord.TURBO_Renew__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_Qualifier_Payout_Rate__c = quotaRecord.TURBO_Renew__c;
                        }  
                    }
                    if(commission.Product__r.ProductCode =='WEBSITE'){
                        if(!quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_o_Qualifier_Payout_Rate__c = quotaRecord.WEBSITE_Renew__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_Qualifier_Payout_Rate__c = quotaRecord.WEBSITE_Renew__c;
                        }  
                    }
                    if(commission.Product__r.ProductCode =='WEBSITEFEE'){
                        if(!quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_o_Qualifier_Payout_Rate__c = quotaRecord.WEBSITEFEE_Renew__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_Qualifier_Payout_Rate__c = quotaRecord.WEBSITEFEE_Renew__c;
                        }
                    }
                    if(commission.Product__r.ProductCode =='REESIO'){
                        if(!quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_o_Qualifier_Payout_Rate__c = quotaRecord.REESIO_Renew__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_Qualifier_Payout_Rate__c = quotaRecord.REESIO_Renew__c;
                        }
                    }
                    if(commission.Product__r.ProductCode =='RSRESPOND'){
                        if(!quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_o_Qualifier_Payout_Rate__c = quotaRecord.RSRESPOND_Renew__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_Qualifier_Payout_Rate__c = quotaRecord.RSRESPOND_Renew__c;
                        }
                    }
                    //#CRM -1727 - Added Pay out rates for Broker Highlight products.
                    if(commission.Product__r.ProductCode =='MEDIABUY'){
                        if(!quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_o_Qualifier_Payout_Rate__c = quotaRecord.MEDIABUY_Renew__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Renewal_w_Qualifier_Payout_Rate__c = quotaRecord.MEDIABUY_Renew__c;
                        }
                    }
                    //#CRM -3163 - Added Pay out rates for RealSuit products.
                    if(commission.Product__r.ProductCode =='RSCONNECT'){
                        if(!quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate__c = quotaRecord.RSCONNECT_Renew__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate1B__c = quotaRecord.RSCONNECT_Renew__c;
                        }
                    }
                    if(commission.Product__r.ProductCode =='RSTRANSACT'){
                        if(!quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate__c = quotaRecord.RSTRANSACT_Renew__c;
                        }
                        if(quotaRecord.Is_Kicker__c){
                            commission.Payout_Rate1B__c = quotaRecord.RSTRANSACT_Renew__c;
                        }
                    }
                   // mapCommissions.put(commission.id,commission);
                                     
                    if(commission.Renewal_w_o_Qualifier_Payout_Rate__c !=0.0){
                        finalcommissionpayout = commission.Renewal_w_o_Qualifier_Payout_Rate__c;
                    }
                    if(commission.Renewal_w_Qualifier_Payout_Rate__c !=0.0){
                        finalcommissionpayout = commission.Renewal_w_Qualifier_Payout_Rate__c;
                    }
                    commission.Final_Commission__c = 0.0;
                    if(commission.Renewal_w_o_Qualifier_Comm_ble_Amount__c !=0.0 && commission.Renewal_w_o_Qualifier_Comm_ble_Amount__c !=null && finalcommissionpayout != null){
                        commission.Final_Commission__c = 0.0;
                        commission.Final_Commission__c = (commission.Renewal_w_o_Qualifier_Comm_ble_Amount__c * finalcommissionpayout)/100;
                    }
                    if(commission.Renewal_w_Qualifier_Comm_ble_Amount__c !=0.0 && commission.Renewal_w_Qualifier_Comm_ble_Amount__c !=null && finalcommissionpayout != null){
                        commission.Final_Commission__c = 0.0;
                        commission.Final_Commission__c = (commission.Renewal_w_Qualifier_Comm_ble_Amount__c * finalcommissionpayout)/100;
                    }  
                    mapCommissions.put(commission.id,commission);
                    system.debug('mapCommissions 2 :'+mapCommissions.size());
                }
                //UPDATE PAYOUTS FOR LINE TYPE - RENEW COMMISSIONS - LOGIC END
                //UPDATE PAYOUTS FOR MANAGER RELEATED COMMISSIONS                
                //#CRM-1365 - MODIFIED THE LOGIC AS PER THE MENTIONED JIRA TICKET   
                //if(commission.User_Team__c == Commissions_Constants.MANAGERS_TEAM){
                //#CRM-1560 - Flexibility to Modify/Create User teams in SFDC by using Config -ADDED BY Venkata Cheedara
                if(commission.User_Team__c ==  CommissionTeams__c.getInstance('MANAGERS_TEAM').Team_Name__c){
                    commission.Payout_Rate__c = 0.0;
                    commission.Renewal_w_o_Qualifier_Payout_Rate__c = 0.0;
                    if(commission.Line_Type__c != 'Renew'){                 
                        if(commission.Related_Commission__c == Null ){
                             commission.Payout_Rate__c = quotaRecord.Component_1A_Payout__c; 
                            }
                       else{
                            //CLAW BACK COMMISSION RECORD PAYOUT RATES FOR MANAGERS TEAM
                            commission.Payout_Rate__c = commission.Related_Commission__r.Payout_Rate__c;
                        }
                        commission.Payout_Rate1B__c =0.0;
                        commission.Renewal_w_o_Qualifier_Payout_Rate__c = 0.0;
                        commission.Renewal_w_Qualifier_Payout_Rate__c = 0.0;             
                        commission.Final_Commission__c = 0.0;
                        if(commission.Commissionable_Amount2__c != Null && commission.Payout_Rate__c != Null){
                            commission.Final_Commission__c = (commission.Commissionable_Amount2__c * commission.Payout_Rate__c)/100;
                        }
                    }
                    if(commission.Line_Type__c == 'Renew'){                 
                        if(commission.Related_Commission__c == Null){
                            commission.Renewal_w_o_Qualifier_Payout_Rate__c = quotaRecord.Renewal_Payout__c;
                        }
                        else{
                            //CLAW BACK COMMISSION RECORD PAYOUT RATES FOR MANAGERS TEAM
                            commission.Renewal_w_o_Qualifier_Payout_Rate__c = commission.Related_Commission__r.Renewal_w_o_Qualifier_Payout_Rate__c ;
                        }
                        commission.Payout_Rate1B__c =0.0;
                        commission.Payout_Rate__c = 0.0;
                        commission.Renewal_w_Qualifier_Payout_Rate__c = 0.0;             
                        commission.Final_Commission__c = 0.0;
                        if(commission.Renewal_w_o_Qualifier_Comm_ble_Amount__c != null && commission.Renewal_w_o_Qualifier_Payout_Rate__c != null){
                            commission.Final_Commission__c = (commission.Renewal_w_o_Qualifier_Comm_ble_Amount__c* commission.Renewal_w_o_Qualifier_Payout_Rate__c)/100;
                        }
                    }
                    mapCommissions.put(commission.id,commission);
                    system.debug('mapCommissions 3 :'+mapCommissions.size());
                }
                //#CRM -1413 - Added Pay out rates for other products.
                //if(commission.Recordtype.name == Commissions_Constants.Other_Products_RECORD_TYPE && commission.User_Team__c != Commissions_Constants.MANAGERS_TEAM && commission.Line_Type__c == 'Renew'){
                //#CRM-1560 - Flexibility to Modify/Create User teams in SFDC by using Config -ADDED BY Venkata Cheedara
                if(commission.Recordtype.name == Commissions_Constants.Other_Products_RECORD_TYPE && commission.User_Team__c !=  CommissionTeams__c.getInstance('MANAGERS_TEAM').Team_Name__c && commission.Line_Type__c == 'Renew'){
                commission.Payout_Rate__c = 0.0;
                    if(commission.Other_Product__c == 'List Hub' ){
                         commission.Payout_Rate__c = quotaRecord.LISTHUBPRO_Renew__c;                                                
                    }                      
                    if(commission.Other_Product__c == 'Top Producer' ){
                        commission.Payout_Rate__c = quotaRecord.TOPCRM_Renew__c;                        
                    }
                      
                    if(commission.Other_Product__c == 'Reesio' ){                     
                        commission.Payout_Rate__c = quotaRecord.REESIO_Renew__c;                        
                    }                    
                    if(commission.Other_Product__c == 'Top Producer Website' ){                   
                        commission.Payout_Rate__c = quotaRecord.TOPWEB_Renew__c;
                    }
                    if(commission.Other_Product__c == 'Market Snapshot' ){                   
                        commission.Payout_Rate__c = quotaRecord.TOPMRKSNP_Renew__c;
                    }
                    if(commission.Commissionable_Amount2__c !=0.0 && commission.Commissionable_Amount2__c !=null && commission.Payout_Rate__c != Null){ 
                        commission.Final_Commission__c = 0.0;
                        commission.Final_Commission__c = (commission.Commissionable_Amount2__c * commission.Payout_Rate__c)/100;
                    }
                    
                    mapCommissions.put(commission.id,commission);
                    system.debug('mapCommissions 4 :'+mapCommissions.size());
                }
                //if(commission.Recordtype.name == Commissions_Constants.Other_Products_RECORD_TYPE && commission.User_Team__c != Commissions_Constants.MANAGERS_TEAM && commission.Line_Type__c != 'Renew'){
                //#CRM-1560 - Flexibility to Modify/Create User teams in SFDC by using Config -ADDED BY Venkata Cheedara
                if(commission.Recordtype.name == Commissions_Constants.Other_Products_RECORD_TYPE && commission.User_Team__c !=  CommissionTeams__c.getInstance('MANAGERS_TEAM').Team_Name__c && commission.Line_Type__c != 'Renew'){
                commission.Payout_Rate__c = 0.0;
                    if(commission.Other_Product__c == 'List Hub' ){                    
                        commission.Payout_Rate__c = quotaRecord.LISTHUBPRO_New__c;                       
                    }   
                    if(commission.Other_Product__c == 'Top Producer' ){                        
                        commission.Payout_Rate__c = quotaRecord.TOPCRM_New__c;                        
                    }                      
                    if(commission.Other_Product__c == 'Top Producer Website' ){                   
                        commission.Payout_Rate__c = quotaRecord.TOPWEB_New__c;
                    }
                    if(commission.Other_Product__c == 'Reesio' ){                   
                        commission.Payout_Rate__c = quotaRecord.REESIO_New__c;
                    }
                    if(commission.Other_Product__c == 'Market Snapshot' ){                   
                        commission.Payout_Rate__c = quotaRecord.TOPMRKSNP_New__c;
                    }
                    if(commission.Commissionable_Amount2__c !=0.0 && commission.Commissionable_Amount2__c !=null && commission.Payout_Rate__c != Null){ 
                        commission.Final_Commission__c = 0.0;
                        commission.Final_Commission__c = (commission.Commissionable_Amount2__c * commission.Payout_Rate__c)/100;
                    }
                    
                    mapCommissions.put(commission.id,commission);
                    system.debug('mapCommissions 5 :'+mapCommissions.size());
                }
                //#CRM-1421 - COLLECTION TEAM PAYOUT CALCULATION ADDED BY SRINIVAS PENDLI 
                //if(commission.User_team__c == Commissions_Constants.COLLECTION_TEAM || commission.User_team__c == Commissions_Constants.CLIENT_RELATIONS_MANAGERS ){
                //#CRM-1560 - Flexibility to Modify/Create User teams in SFDC by using Config -ADDED BY Venkata Cheedara
                if(commission.User_team__c == CommissionTeams__c.getInstance('COLLECTION_TEAM').Team_Name__c || commission.User_team__c == CommissionTeams__c.getInstance('CLIENT_RELATIONS_MANAGERS').Team_Name__c){
                    //PAYOUT CALCULATION FOR REGULAR PROCESS
                    if(commission.Commissionable_Amount2__c !=0.0 && commission.Commissionable_Amount2__c !=Null){
                        Commission.Payout_Rate__c = quotaRecord.Component_1A_Payout__c;
                    }
                    if(commission.Commissionable_Amount2__c !=0.0 && commission.Commissionable_Amount2__c !=null && commission.Payout_Rate__c != Null){ 
                        commission.Final_Commission__c = 0.0;
                        commission.Final_Commission__c = (commission.Commissionable_Amount2__c * commission.Payout_Rate__c)/100;
                    }                            
                    mapCommissions.put(commission.id,commission);
                    system.debug('mapCommissions 6 :'+mapCommissions.size());
                }                
                
                //UPDATING CLAWBACK COMMISSION RECORD PAYOUT RATES
                //IF COMMISSION RELATED COMMISSION(Related_Commission__c) IS NULL,IT WILL UPDATE WITH CURRENT MONTH PAYOUT RATES
                //ELSE IT WILL UPDATE WITH RELATED COMMISSION PAYOUT RATES
                system.debug('comm >> 0:'+commission.Name);
                
                if(commission.RecordType.Name == Commissions_Constants.COMMISSIONS_CLAWBACK && commission.Related_Commission__c != Null){
                    system.debug('comm >> 1:'+commission.Name);
                    if(commission.Related_Commission__r.CreatedDate <= Date.newInstance(2017,07,01)){
                        if(commission.Product_Category__c == 'CFCB'){
                            if(commission.Related_Commission__r.HistoricNew_Sale_W_OQualifier_PayoutRate__c !=Null && commission.Related_Commission__r.Historic_CFCB_NewSale_With_Q_Payout__c !=Null && commission.Related_Commission__r.Historic_CFCB_New_Sale_w_o_Qualifier_Pay__c != Null &&
                                                        commission.Related_Commission__r.Historic_CFCB_RNW_W_Q_Payout_Rate__c !=Null && commission.Related_Commission__r.Historic_CFCB_RNW_w_o_Q_Payout_Rate__c !=null && commission.Related_Commission__r.Historic_Asset_Owner_Payout_Rate__c != Null){                
                                commission.Payout_Rate__c = (commission.Related_Commission__r.HistoricNew_Sale_W_OQualifier_PayoutRate__c+commission.Related_Commission__r.Historic_CFCB_NewSale_With_Q_Payout__c+commission.Related_Commission__r.Historic_CFCB_New_Sale_w_o_Qualifier_Pay__c+
                                                            commission.Related_Commission__r.Historic_CFCB_RNW_W_Q_Payout_Rate__c+commission.Related_Commission__r.Historic_CFCB_RNW_w_o_Q_Payout_Rate__c+commission.Related_Commission__r.Historic_Asset_Owner_Payout_Rate__c);
                                mapCommissions.put(commission.id,commission);
                                system.debug('mapCommissions 7 :'+mapCommissions.size());
                            }
                        }
                        else{
                            system.debug('comm >> 7:'+commission.Name);
                            if(commission.Commissionable_Amount2__c !=0.0 && commission.Commissionable_Amount2__c !=null){
                                if(commission.Related_Commission__r.HistoricNew_Sale_W_OQualifier_PayoutRate__c != Null && commission.Related_Commission__r.Historic_Asset_Owner_Payout_Rate__c !=Null){
                                    commission.Payout_Rate__c = (commission.Related_Commission__r.HistoricNew_Sale_W_OQualifier_PayoutRate__c+commission.Related_Commission__r.Historic_Asset_Owner_Payout_Rate__c);
                                }
                            }
                            if(commission.Commissionable_Amount1B__c !=0.0 && commission.Commissionable_Amount1B__c !=null){
                                if(commission.Related_Commission__r.HistorNew_Sale_WithQualifier_Payout_Rate__c != Null && commission.Related_Commission__r.Historic_Asset_Owner_Payout_Rate__c !=Null){
                                    commission.Payout_Rate1B__c = (commission.Related_Commission__r.HistorNew_Sale_WithQualifier_Payout_Rate__c+commission.Related_Commission__r.Historic_Asset_Owner_Payout_Rate__c);
                                }
                            }
                            if(commission.Renewal_w_o_Qualifier_Comm_ble_Amount__c !=0.0 && commission.Renewal_w_o_Qualifier_Comm_ble_Amount__c !=null){
                                if(commission.Related_Commission__r.HistoricNew_Sale_W_OQualifier_PayoutRate__c != Null && commission.Related_Commission__r.Historic_Asset_Owner_Payout_Rate__c != Null){
                                    commission.Renewal_w_o_Qualifier_Payout_Rate__c = (commission.Related_Commission__r.HistoricNew_Sale_W_OQualifier_PayoutRate__c+commission.Related_Commission__r.Historic_Asset_Owner_Payout_Rate__c);
                                }
                            }
                            if(commission.Renewal_w_Qualifier_Comm_ble_Amount__c !=0.0 && commission.Renewal_w_Qualifier_Comm_ble_Amount__c !=null){
                                if(commission.Related_Commission__r.HistorNew_Sale_WithQualifier_Payout_Rate__c != Null && commission.Related_Commission__r.Historic_Asset_Owner_Payout_Rate__c != Null){
                                    commission.Renewal_w_Qualifier_Payout_Rate__c =  (commission.Related_Commission__r.HistorNew_Sale_WithQualifier_Payout_Rate__c+commission.Related_Commission__r.Historic_Asset_Owner_Payout_Rate__c);
                                }
                            }
                            mapCommissions.put(commission.id,commission);
                            system.debug('mapCommissions 8 :'+mapCommissions.size());
                        } 
                    }
                    else{
                        if(commission.Commissionable_Amount2__c !=0.0 && commission.Commissionable_Amount2__c !=null){
                            commission.Payout_Rate__c = (commission.Related_Commission__r.Payout_Rate__c);
                        }
                        if(commission.Commissionable_Amount1B__c !=0.0 && commission.Commissionable_Amount1B__c !=null){
                            commission.Payout_Rate1B__c = (commission.Related_Commission__r.Payout_Rate1B__c);
                        }
                        if(commission.Renewal_w_o_Qualifier_Comm_ble_Amount__c !=0.0 && commission.Renewal_w_o_Qualifier_Comm_ble_Amount__c !=null){
                            commission.Renewal_w_o_Qualifier_Payout_Rate__c = (commission.Related_Commission__r.Renewal_w_o_Qualifier_Payout_Rate__c);
                        }
                        if(commission.Renewal_w_Qualifier_Comm_ble_Amount__c !=0.0 && commission.Renewal_w_Qualifier_Comm_ble_Amount__c !=null){
                            commission.Renewal_w_Qualifier_Payout_Rate__c =  (commission.Related_Commission__r.Renewal_w_Qualifier_Payout_Rate__c);
                        }
                        mapCommissions.put(commission.id,commission);
                    }                   
                      
                    if(commission.Commissionable_Amount2__c !=0.0 && commission.Commissionable_Amount2__c !=null && commission.Payout_Rate__c != Null && commission.Payout_Rate__c !=0.0){
                        commission.Final_Commission__c = 0.0;
                        commission.Final_Commission__c = -(commission.Commissionable_Amount2__c * commission.Payout_Rate__c)/100;
                    }
                    if(commission.Commissionable_Amount1B__c !=0.0 && commission.Commissionable_Amount1B__c !=null && commission.Payout_Rate1B__c != null && commission.Payout_Rate1B__c !=0.0){
                        commission.Final_Commission__c = 0.0;
                        commission.Final_Commission__c = -(commission.Commissionable_Amount1B__c * commission.Payout_Rate1B__c)/100;
                    }  
                    if(commission.Renewal_w_o_Qualifier_Comm_ble_Amount__c !=0.0 && commission.Renewal_w_o_Qualifier_Comm_ble_Amount__c !=null && commission.Renewal_w_o_Qualifier_Payout_Rate__c != null && commission.Renewal_w_o_Qualifier_Payout_Rate__c !=0.0){
                        commission.Final_Commission__c = 0.0;
                        commission.Final_Commission__c = -(commission.Renewal_w_o_Qualifier_Comm_ble_Amount__c * commission.Renewal_w_o_Qualifier_Payout_Rate__c)/100;
                    }
                    if(commission.Renewal_w_Qualifier_Comm_ble_Amount__c !=0.0 && commission.Renewal_w_Qualifier_Comm_ble_Amount__c !=null && commission.Renewal_w_Qualifier_Payout_Rate__c != null && commission.Renewal_w_Qualifier_Payout_Rate__c != 0.0){
                        commission.Final_Commission__c = 0.0;
                        commission.Final_Commission__c = -(commission.Renewal_w_Qualifier_Comm_ble_Amount__c * commission.Renewal_w_Qualifier_Payout_Rate__c)/100;
                    } 
                    mapCommissions.put(commission.id,commission);
                    system.debug('mapCommissions 9 :'+mapCommissions.size());
                }                
            }     
        }
        //UPDATE THE COMMISSION RECORDS OF RESPECTIVE QUOTA
        system.debug('mapCommissions 10 :'+mapCommissions.size());
        if(!mapCommissions.isEmpty()){
            SkipAssetTrigger.setSkipTrgTrue();
            update mapCommissions.Values(); 
            isSucess = TRUE;
        }
        system.debug('isSucess 10 :'+isSucess);
        if(isSucess == TRUE){
            Commissions_KickerQualifierSwapClass comms = new Commissions_KickerQualifierSwapClass();
            comms.swapMethod(quotaIds);
        }
    }
}