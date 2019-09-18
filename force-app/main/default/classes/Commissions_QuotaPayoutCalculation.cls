/*******************************************************************************
Created By      :   Srinivas Pendli
Created Date    :   01-APRIL-2016
Usage           :   This class is to calculate payout rate for component 1A,1B,2A,2B,2C,2D,3 and 4A.
Calling from Quota_QuotaPayoutCalculationTrigger.
CODE MODOFOCATION DETAILS :
1. Modified By  :   Srinivas Pendli on 24-May-2016 @ Line No.512 and 549 // LEAP-8667 - Total clawback commission issue on quota level
2. Modified By  :   Srinivas Pendli on 25-May-2016 @ Line No.532 //System.LimitException: Too many DML rows: 10001 issue
3. Modified By  :   Srinivas Pendli on 14-APRIL-2017 For #CRM-1394 and #CRM-1393
********************************************************************************/
Public class Commissions_QuotaPayoutCalculation{   
    public void quotaPayoutCalculation(set<id> quotaAfterinsertIds){    
        //VARIABLE DECLERATION                                 
        Set<Id> periodIds = new Set<Id>();
        Set<Id> quotaIds = new Set<Id>();
        Set<String> recordtypenames = new Set<String>();     
        Decimal payoutRate1A = 0.0;
        Decimal payoutRate1B = 0.0;
        Decimal quotaPercentage = 0.0;
        Decimal quotaPercentageRenewal = 0.0;
        Decimal collectionTeamPayout = 0.0;      
        Decimal denominator = 0.0;  
        Decimal lowValueComp1 ; 
        Decimal highValueComp1 ;
        Decimal commissinableAmountComp1;
        Decimal lowValueComp2 ; 
        Decimal highValueComp2 ;
        Decimal commissinableAmountComp2;
        Decimal y  = 0; 
        Decimal yf  = 0;
        Decimal x  = 0;   
        Decimal x1 = 0;   
        Decimal x2 = 0;   
        Decimal y1 = 0;   
        Decimal y2 = 0;
        Boolean recordProcessed = False;  
        //RETRIVING PROCESSED QUOTA RECORDS         
        List<Quota__c> quotaList = [select id, Name,User_Team__c,Period_Name__c,User__r.Name, Owner_Name__c,Final_Collection_Total_Sale__c,Quota_Percentage__c,Total_Sale__c,
                                    user__r.CreatedDate,user__r.Payout_Rate_Month_1__c,CreatedDate,user__r.Payout_Rate_Month_2__c,user__r.Payout_Rate_Month_3__c,
                                    user__r.Payout_Rate_Month_4__c,user__r.Payout_Rate_Month_5__c,Total_Sale_Renewal__c,Manager_Total_Sale_Renewal__c,
                                    Is_Kicker__c,Collection_Total_Sale__c,Collection_Target_Amount__c,Target_Amount__c,Record_Processed__c,                    
                                    Component_1B_Payout__c,Total_Clawback_Commission_Amount__c,Collection_Quota_Percentage__c,Manager_Total_Sale__c,Current_Quater__c,
                                    ADVANTAGE_New__c,ADVANTAGE_Renew__c,COBROKE_New__c,COBROKE_Renew__c,DACAMPAIGN_New__c,DACAMPAIGN_Renew__c,DIGITALAGENT_New__c,
                                    DIGITALAGENT_Renew__c,DOMAINNAME_New__c,DOMAINNAME_Renew__c,FEATCMA_New__c,FEATCMA_Renew__c,FEATDISP_New__c,FEATDISP_Renew__c,
                                    FEATHOMES_New__c,FEATHOMES_Renew__c,FIVESTREET_New__c,FIVESTREET_Renew__c,LISTHUBPRO_New__c,LISTHUBPRO_Renew__c,MRKTBUILD_New__c,
                                    MRKTBUILD_Renew__c,SELLERLEAD_New__c,SELLERLEAD_Renew__c,SELLERLEADBUNDLE_New__c,SELLERLEADBUNDLE_Renew__c,SHOWCASE_New__c,
                                    SHOWCASE_Renew__c,SIGNRIDER_New__c,SIGNRIDER_Renew__c,STANDLIST_New__c,STANDLIST_Renew__c,TOPCRM_New__c,TOPCRM_Renew__c,TOPIDX_New__c,
                                    TOPIDX_Renew__c,TOPMRKSNP_New__c,TOPMRKSNP_Renew__c,TOPWEB_New__c,TOPWEB_Renew__c,TOPWEBFEE_New__c,TOPWEBFEE_Renew__c,TRKPHNMBR_New__c,
                                    TRKPHNMBR_Renew__c,TURBO_New__c,TURBO_Renew__c,WEBSITE_New__c,WEBSITE_Renew__c,WEBSITEFEE_New__c,WEBSITEFEE_Renew__c,REESIO_New__c,
                                    REESIO_Renew__c,RSRESPOND_New__c,RSRESPOND_Renew__c , MEDIABUY_New__c ,MEDIABUY_Renew__c,Renewal_Payout__c,Quota_Attainment_Renewal__c,RSCONNECT_New__c,
                                    RSCONNECT_Renew__c,RSTRANSACT_New__c,RSTRANSACT_Renew__c,LocalExpert_New__c,LocalExpert_Renew__c 
                                    
                                    from Quota__c where Id in : quotaAfterinsertIds];
        //COLLECTIING PERIOD,USER TEAM NAMES AND QUOTA IDS TO GET PERIOD AND PAYOUT RECORDS 
        for(Quota__c quota : quotaList){
            //CRM-4735 [Start] code Modification
            if(quota.Period_Name__c != null){
                periodIds.add(quota.Period_Name__c);            
            }
            if(quota.User_Team__c != null){
                recordtypenames.add(quota.User_Team__c);
            }
            if(String.isNotBlank(quota.Owner_Name__c)){
                recordtypenames.add(quota.Owner_Name__c);  
            }
            //CRM-4735 [Ends] modification
            quotaIds.add(quota.id);
        }
        // CRM-4551 [Start]
        Set<String> quotaUserTeamNames = new Set<String>();
        for(CollectionTeams__mdt collTeamName : [Select MasterLabel,DeveloperName,Team_Name__c From CollectionTeams__mdt]){
            if(string.isNotBlank(collTeamName.Team_Name__c)){
                quotaUserTeamNames.add(collTeamName.Team_Name__c.trim().toLowerCase());
            }
        }
        // CRM-4551 [End]
        
        Map<id,Quota__c> quotaRecords = new Map<id,Quota__c>();
        //GETTING PAYOUT RECORDS FROM PAYOUT OBJECT
        // code added by srinivas pendli for #CRM-2616
        Map<Id,Payout__C> mapPayoutNewSalesRecords = new Map<ID, Payout__C>([select id ,name,RecordType.Name,High_Level__c,Low_Level__c,Low_Amount__c, High_Amount__c,Commissionable__c,Product_Commission_Category__c,Sale_Type__c ,Product_Code__c
                                                                             from Payout__c where (Sale_Type__c = 'New' OR Sale_Type__c ='Collections') and RecordType.Name in : recordtypenames and Period__c In : PeriodIds  Order by Low_Level__c Desc]); //and After_Optimization__c =false
        
        Map<Id,Payout__C> mapPayoutRenewalRecords = new Map<ID, Payout__C>([select id ,name,RecordType.Name,High_Level__c,Low_Level__c,Low_Amount__c, High_Amount__c,Commissionable__c,Product_Commission_Category__c,Sale_Type__c ,Product_Code__c
                                                                            from Payout__c where Sale_Type__c = 'Renewal' and RecordType.Name in : recordtypenames and Period__c In : PeriodIds   Order by Low_Level__c Desc]); //and After_Optimization__c =false
        
        
        Decimal ADVANTAGE_New = 0.0,COBROKE_New = 0.0,DACAMPAIGN_New = 0.0,DIGITALAGENT_New = 0.0,DOMAINNAME_New = 0.0 ,FEATCMA_New = 0.0 ,FEATDISP_New ,FEATHOMES_New = 0.0,FIVESTREET_New = 0.0,LISTHUBPRO_New = 0.0 ,MRKTBUILD_New = 0.0,SELLERLEAD_New = 0.0,SELLERLEADBUNDLE_New = 0.0 ,SHOWCASE_New = 0.0 ,SIGNRIDER_New = 0.0,STANDLIST_New = 0.0,TOPCRM_New= 0.0,TOPIDX_New= 0.0,TOPMRKSNP_New= 0.0,TOPWEB_New= 0.0,TOPWEBFEE_New= 0.0,TRKPHNMBR_New= 0.0,TURBO_New= 0.0,WEBSITE_New= 0.0,WEBSITEFEE_New= 0.0,REESIO_New = 0.0,REESIO_Renew=0.0,RSRESPOND_New=0.0,RSRESPOND_Renew=0.0,RSCONNECT_New =0.0,RSTRANSACT_New=0.0,LocalExpert_New =0.0;  
        
        Decimal ADVANTAGE_Renew = 0.0,COBROKE_Renew= 0.0,DACAMPAIGN_Renew= 0.0,DIGITALAGENT_Renew= 0.0,DOMAINNAME_Renew= 0.0,FEATCMA_Renew= 0.0,FEATDISP_Renew= 0.0,FEATHOMES_Renew= 0.0,FIVESTREET_Renew= 0.0,LISTHUBPRO_Renew= 0.0,MRKTBUILD_Renew= 0.0,SELLERLEAD_Renew= 0.0,SELLERLEADBUNDLE_Renew= 0.0,SHOWCASE_Renew= 0.0,SIGNRIDER_Renew= 0.0,STANDLIST_Renew= 0.0,TOPCRM_Renew= 0.0,TOPIDX_Renew= 0.0,TOPMRKSNP_Renew= 0.0,TOPWEB_Renew= 0.0,TOPWEBFEE_Renew= 0.0,TRKPHNMBR_Renew= 0.0,TURBO_Renew= 0.0,WEBSITE_Renew= 0.0,WEBSITEFEE_Renew= 0.0, MEDIABUY_New =0.0,MEDIABUY_Renew =0.0,RSCONNECT_Renew=0.0,RSTRANSACT_Renew=0.0,LocalExpert_ReNew=0.0;
        //CALCULATING COMMISSION COMPONENTS PAYOUT RATES
        for(Quota__c currentQuota : quotaList){
            if(!currentQuota.Record_Processed__c || currentQuota.Record_Processed__c){ 
                recordProcessed = true;         
                quotaIds.add(currentQuota.id);
                quotaPercentage = 0.0;quotaPercentageRenewal = 0.0;payoutRate1A = 0.0;payoutRate1B = 0.0;collectionTeamPayout = 0.0;         
                ADVANTAGE_New = 0.0;COBROKE_New = 0.0;DACAMPAIGN_New = 0.0;DIGITALAGENT_New = 0.0 ;DOMAINNAME_New = 0.0 ;FEATCMA_New = 0.0 ;FEATDISP_New =0.0;FEATHOMES_New = 0.0;FIVESTREET_New = 0.0;LISTHUBPRO_New = 0.0 ;MRKTBUILD_New = 0.0;SELLERLEAD_New = 0.0;SELLERLEADBUNDLE_New = 0.0;SHOWCASE_New = 0.0 ;SIGNRIDER_New = 0.0;STANDLIST_New = 0.0;TOPCRM_New= 0.0;TOPIDX_New= 0.0;TOPMRKSNP_New= 0.0;TOPWEB_New= 0.0;TOPWEBFEE_New= 0.0;TRKPHNMBR_New= 0.0;TURBO_New= 0.0;WEBSITE_New= 0.0;WEBSITEFEE_New= 0.0;REESIO_New = 0.0;RSRESPOND_New=0.0;RSCONNECT_New =0.0;RSTRANSACT_New=0.0;RSCONNECT_Renew=0.0;RSTRANSACT_Renew=0.0;
                ADVANTAGE_Renew = 0.0;COBROKE_Renew= 0.0;DACAMPAIGN_Renew= 0.0;DIGITALAGENT_Renew= 0.0;DOMAINNAME_Renew= 0.0;FEATCMA_Renew= 0.0;FEATDISP_Renew= 0.0;FEATHOMES_Renew= 0.0;FIVESTREET_Renew= 0.0;LISTHUBPRO_Renew= 0.0;MRKTBUILD_Renew= 0.0;SELLERLEAD_Renew= 0.0;SELLERLEADBUNDLE_Renew= 0.0;SHOWCASE_Renew= 0.0;SIGNRIDER_Renew= 0.0;STANDLIST_Renew= 0.0;TOPCRM_Renew= 0.0;TOPIDX_Renew= 0.0;TOPMRKSNP_Renew= 0.0;TOPWEB_Renew= 0.0;TOPWEBFEE_Renew= 0.0;TRKPHNMBR_Renew= 0.0;TURBO_Renew= 0.0;WEBSITE_Renew= 0.0;WEBSITEFEE_Renew= 0.0;REESIO_Renew=0.0;RSRESPOND_Renew=0.0;MEDIABUY_New =0.0;MEDIABUY_Renew =0.0;
                x  = 0; x1 = 0;  x2 = 0;  y1 = 0;  y2 = 0;             
                lowValueComp1 = 0.0; highValueComp1 =0.0;commissinableAmountComp1=0; 
                lowValueComp2 = 0.0; highValueComp2 =0.0;commissinableAmountComp2=0;                
                quotaPercentage = currentQuota.Quota_Percentage__c; 
                quotaPercentageRenewal = currentQuota.Quota_Attainment_Renewal__c;              
                
                String quotaTeam = '';
                //#CRM-1560 - Flexibility to Modify/Create User teams in SFDC by using Config -ADDED BY Venkata Cheedara
                //if(currentQuota.User_Team__c == Commissions_Constants.MANAGERS_TEAM ){
                if(currentQuota.User_Team__c == CommissionTeams__c.getInstance('MANAGERS_TEAM').Team_Name__c){
                    quotaTeam = currentQuota.User__r.Name;
                }
                else{
                    quotaTeam = currentQuota.User_Team__c;
                }
                // PAYOUT CALCULATION FOR ALL TEAMS EXCEPT BROKER REGIONAL DIRECTORS TEAM,COLLECTIONS TEAM AND COLLECTIONS CLIENT RELATIONS MANAGERS TEAM  
                for(Payout__c pay : mapPayoutNewSalesRecords.Values()){    
                    //#CRM-1560 - Flexibility to Modify/Create User teams in SFDC by using Config -ADDED BY Venkata Cheedara
                    /* if((quotaTeam  == Pay.RecordType.Name) && (currentQuota.User_Team__c != Commissions_Constants.COLLECTION_TEAM && 
currentQuota.User_Team__c != Commissions_Constants.CLIENT_RELATIONS_MANAGERS && 
currentQuota.User_Team__c != Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM) && (currentQuota.User_Team__c != Commissions_Constants.MANAGERS_TEAM)){  */						
                    /* 4551: currentQuota.User_Team__c != CommissionTeams__c.getInstance('COLLECTION_TEAM').Team_Name__c && 
currentQuota.User_Team__c != CommissionTeams__c.getInstance('COLLECTIONS_CLIENT_RELATIONS_MANAGERS').Team_Name__c*/
                    if((quotaTeam  == Pay.RecordType.Name) && (String.isNotBlank(currentQuota.User_Team__c) && !quotaUserTeamNames.contains(currentQuota.User_Team__c.toLowerCase()) && currentQuota.User_Team__c != CommissionTeams__c.getInstance('BROKER_REGIONAL_DIRECTORS_TEAM').Team_Name__c) && (currentQuota.User_Team__c != CommissionTeams__c.getInstance('MANAGERS_TEAM').Team_Name__c)){                     
                        if(Pay.Sale_Type__c != 'Renewal'){                      
                            if(pay.Low_Level__c == Null && pay.High_Level__c == Null){
                                lowValueComp2 = pay.Low_Amount__c;
                                highValueComp2 = pay.High_Amount__c;
                                //commissinableAmountComp2 = (currentQuota.Total_Sale_Renewal__c+currentQuota.Manager_Total_Sale_Renewal__c); // code commented for #CRM-2616  
                                commissinableAmountComp1 = (currentQuota.Total_Sale__c+currentQuota.Manager_Total_Sale__c);                                    
                                
                            }
                            if(pay.Low_Amount__c == Null && pay.High_Amount__c == Null){
                                lowValueComp2 = pay.Low_Level__c;
                                highValueComp2 = pay.High_Level__c;
                                //commissinableAmountComp2 = quotaPercentageRenewal; // code commented for #CRM-2616
                                commissinableAmountComp1 = quotaPercentage;
                            }
                        }
                        //COMPONENT 1A CALCULATION                         
                        if((commissinableAmountComp1 >= lowValueComp2 ) && Pay.Sale_Type__c == 'New'){
                            if(commissinableAmountComp1 <= highValueComp2 ) {                                                                 
                                if(pay.Name == Commissions_Constants.NEW_SALE_WITHOUT_QUALIFIER && (!currentQuota.is_Kicker__c)){                              
                                    if(Pay.Product_Code__c == 'ADVANTAGE'){                                 
                                        ADVANTAGE_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'COBROKE'){  
                                        COBROKE_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'DACAMPAIGN'){  
                                        DACAMPAIGN_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'DIGITALAGENT'){  
                                        DIGITALAGENT_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'DOMAINNAME'){  
                                        DOMAINNAME_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'FEATCMA'){    
                                        FEATCMA_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'FEATDISP'){  
                                        FEATDISP_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'FEATHOMES'){  
                                        FEATHOMES_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'FIVESTREET'){  
                                        FIVESTREET_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'LISTHUBPRO'){  
                                        LISTHUBPRO_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'MRKTBUILD'){                                        
                                        MRKTBUILD_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'SELLERLEAD'){  
                                        SELLERLEAD_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'SELLERLEADBUNDLE'){  
                                        SELLERLEADBUNDLE_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'SHOWCASE'){  
                                        SHOWCASE_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'SIGNRIDER'){  
                                        SIGNRIDER_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'STANDLIST'){                                
                                        STANDLIST_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'TOPCRM'){  
                                        TOPCRM_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'TOPIDX'){  
                                        TOPIDX_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'TOPMRKSNP'){  
                                        TOPMRKSNP_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'TOPWEB'){  
                                        TOPWEB_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'TOPWEBFEE'){                                
                                        TOPWEBFEE_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'TRKPHNMBR'){  
                                        TRKPHNMBR_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'TURBO'){  
                                        TURBO_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'WEBSITE'){  
                                        WEBSITE_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'WEBSITEFEE'){  
                                        WEBSITEFEE_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'REESIO'){  
                                        REESIO_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'RSRESPOND'){  
                                        RSRESPOND_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    //#CRM -1727 - Added Pay out rates for Broker Highlight products.
                                    if(Pay.Product_Code__c == 'MEDIABUY'){  
                                        MEDIABUY_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    //#CRM -3163 - Added Pay out rates for RealSuite products.
                                    if(Pay.Product_Code__c == 'RSCONNECT'){  
                                        RSCONNECT_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'RSTRANSACT'){  
                                        RSTRANSACT_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'LOCALEXPERT'){  
                                        LocalExpert_New = (pay.Commissionable__c).setScale(4);
                                    }
                                }
                                if(pay.Name == Commissions_Constants.NEW_SALE_WITH_QUALIFIER && (currentQuota.is_Kicker__c)){                              
                                    if(Pay.Product_Code__c == 'ADVANTAGE'){                             
                                        ADVANTAGE_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'COBROKE'){  
                                        COBROKE_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'DACAMPAIGN'){  
                                        DACAMPAIGN_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'DIGITALAGENT'){  
                                        DIGITALAGENT_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'DOMAINNAME'){  
                                        DOMAINNAME_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'FEATCMA'){    
                                        FEATCMA_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'FEATDISP'){  
                                        FEATDISP_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'FEATHOMES'){  
                                        FEATHOMES_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'FIVESTREET'){  
                                        FIVESTREET_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'LISTHUBPRO'){  
                                        LISTHUBPRO_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'MRKTBUILD'){                                        
                                        MRKTBUILD_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'SELLERLEAD'){  
                                        SELLERLEAD_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'SELLERLEADBUNDLE'){  
                                        SELLERLEADBUNDLE_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'SHOWCASE'){  
                                        SHOWCASE_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'SIGNRIDER'){  
                                        SIGNRIDER_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'STANDLIST'){                                
                                        STANDLIST_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'TOPCRM'){  
                                        TOPCRM_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'TOPIDX'){  
                                        TOPIDX_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'TOPMRKSNP'){  
                                        TOPMRKSNP_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'TOPWEB'){  
                                        TOPWEB_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'TOPWEBFEE'){                                
                                        TOPWEBFEE_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'TRKPHNMBR'){  
                                        TRKPHNMBR_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'TURBO'){  
                                        TURBO_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'WEBSITE'){  
                                        WEBSITE_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'WEBSITEFEE'){  
                                        WEBSITEFEE_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'REESIO'){  
                                        REESIO_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'RSRESPOND'){  
                                        RSRESPOND_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    //#CRM -1727 - Added Pay out rates for Broker Highlight products.
                                    if(Pay.Product_Code__c == 'MEDIABUY'){  
                                        MEDIABUY_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    //#CRM -3163 - Added Pay out rates for RealSuite products.
                                    if(Pay.Product_Code__c == 'RSCONNECT'){  
                                        RSCONNECT_New = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'RSTRANSACT'){  
                                        RSTRANSACT_New = (pay.Commissionable__c).setScale(4);
                                    }  
                                    if(Pay.Product_Code__c == 'LOCALEXPERT'){  
                                        LocalExpert_New = (pay.Commissionable__c).setScale(4);
                                    }
                                }                                
                            }
                        }                       
                    }           
                    //#CRM-1560 - Flexibility to Modify/Create User teams in SFDC by using Config -ADDED BY Venkata Cheedara
                    //if(quotaTeam  == Pay.RecordType.Name && currentQuota.User_Team__c == Commissions_Constants.MANAGERS_TEAM){
                    if(quotaTeam  == Pay.RecordType.Name && currentQuota.User_Team__c == CommissionTeams__c.getInstance('MANAGERS_TEAM').Team_Name__c){
                        if(currentQuota.Collection_Quota_Percentage__c == 0.0 || currentQuota.Collection_Quota_Percentage__c == Null){
                            
                            if(Pay.Sale_Type__c == 'New'){
                                if(pay.Low_Level__c == Null && pay.High_Level__c == Null){
                                    lowValueComp1 = pay.Low_Amount__c;
                                    highValueComp1 = pay.High_Amount__c;
                                    commissinableAmountComp1 = (currentQuota.Total_Sale__c+currentQuota.Manager_Total_Sale__c);                                    
                                    //commissinableAmountComp2 = (currentQuota.Total_Sale_Renewal__c+currentQuota.Manager_Total_Sale_Renewal__c);
                                }
                                if(pay.Low_Amount__c == Null && pay.High_Amount__c == Null){
                                    lowValueComp1 = pay.Low_Level__c;
                                    highValueComp1 = pay.High_Level__c;
                                    commissinableAmountComp1 = quotaPercentage;
                                } 
                                //COMPONENT 1A CALCULATION     
                                if((commissinableAmountComp1 >= lowValueComp1)){
                                    if(commissinableAmountComp1 <= highValueComp1) {  
                                        if(pay.Name == Commissions_Constants.NEW_SALE_WITHOUT_QUALIFIER){ 
                                            payoutRate1A = (pay.Commissionable__c).setScale(6);
                                        }       
                                    }
                                }
                            }                      
                        }//COLLECTION MANAGERS LOGIC
                        
                        //CRM-3162 Collections commissions payout rate is getting zero -updated by Venkata Ramana
                        else{
                            
                            quotaPercentage = currentQuota.Quota_Percentage__c;
                            if(currentQuota.Quota_Percentage__c >= 0.0){
                                if(pay.Low_Level__c == Null && pay.High_Level__c == Null){
                                    lowValueComp1 = pay.Low_Amount__c;
                                    highValueComp1 = pay.High_Amount__c;
                                    commissinableAmountComp1 = (currentQuota.Final_Collection_Total_Sale__c);                                    
                                }
                                if(pay.Low_Amount__c == Null && pay.High_Amount__c == Null){
                                    lowValueComp1 = pay.Low_Level__c;
                                    highValueComp1 = pay.High_Level__c;
                                    commissinableAmountComp1 = quotaPercentage;
                                } 
                                //COMPONENT 1A CALCULATION                                     
                                if((commissinableAmountComp1 >= lowValueComp1)){                            
                                    if(commissinableAmountComp1 <= highValueComp1) {  
                                        if(pay.Name == Commissions_Constants.NEW_SALE_WITH_QUALIFIER){ 
                                            payoutRate1A = (pay.Commissionable__c).setScale(6);
                                        }       
                                    }
                                }   
                            } 
                            
                            if(currentQuota.Collection_Quota_Percentage__c >= 0.0){
                                quotaPercentage = currentQuota.Collection_Quota_Percentage__c;
                                if(pay.Low_Level__c == Null && pay.High_Level__c == Null){
                                    lowValueComp1 = pay.Low_Amount__c;
                                    highValueComp1 = pay.High_Amount__c;
                                    commissinableAmountComp1 = (currentQuota.Final_Collection_Total_Sale__c);                                    
                                }
                                if(pay.Low_Amount__c == Null && pay.High_Amount__c == Null){
                                    lowValueComp1 = pay.Low_Level__c;
                                    highValueComp1 = pay.High_Level__c;
                                    commissinableAmountComp1 = quotaPercentage;
                                } 
                                //COMPONENT 1A CALCULATION                                     
                                if((commissinableAmountComp1 >= lowValueComp1)){                            
                                    if(commissinableAmountComp1 <= highValueComp1) {  
                                        if(pay.Name == Commissions_Constants.NEW_SALE_WITHOUT_QUALIFIER){ 
                                            collectionTeamPayout = (pay.Commissionable__c).setScale(6);
                                        }       
                                    }
                                }   
                            }
                            
                        }
                        
                    }                          
                    //COLLECTION TEAM
                    //#CRM-1560 - Flexibility to Modify/Create User teams in SFDC by using Config -ADDED BY Venkata Cheedara
                    /*  if((currentQuota.User_Team__c == Commissions_Constants.COLLECTION_TEAM && pay.RecordType.Name == Commissions_Constants.COLLECTION_TEAM) ||
(currentQuota.User_Team__c == Commissions_Constants.CLIENT_RELATIONS_MANAGERS && pay.RecordType.Name == Commissions_Constants.CLIENT_RELATIONS_MANAGERS )){  */
                    if(String.isNotBlank(currentQuota.User_Team__c) && quotaUserTeamNames.contains(currentQuota.User_Team__c.toLowerCase()) && quotaUserTeamNames.contains(pay.RecordType.Name.toLowerCase()) && currentQuota.User_Team__c.toLowerCase() == pay.RecordType.Name.toLowerCase()){                      
                        quotaPercentage = currentQuota.Collection_Quota_Percentage__c;
                        if(pay.Low_Level__c == Null && pay.High_Level__c == Null){
                            lowValueComp1 = pay.Low_Amount__c;
                            highValueComp1 = pay.High_Amount__c;
                            commissinableAmountComp1 = currentQuota.Collection_Total_Sale__c;                                    
                        }
                        if(pay.Low_Amount__c == Null && pay.High_Amount__c == Null){
                            lowValueComp1 = pay.Low_Level__c;
                            highValueComp1 = pay.High_Level__c;
                            commissinableAmountComp1 = quotaPercentage;
                        } 
                        //COMPONENT 1A CALCULATION  
                        if((commissinableAmountComp1 != null) && (commissinableAmountComp1 >= lowValueComp1)){                                       
                            if(commissinableAmountComp1 <= highValueComp1) {                                       
                                //COLLECTED AMOUNT PAYOUT RATE
                                if(pay.Name == Commissions_Constants.NEW_SALE_WITHOUT_QUALIFIER){                      
                                    collectionTeamPayout = (pay.Commissionable__c).setScale(4);
                                }
                                //NEW SALE AMOUNT PAYOUT RATE
                                if(pay.Name == Commissions_Constants.NEW_SALE_WITH_QUALIFIER){                      
                                    payoutRate1A = (pay.Commissionable__c).setScale(4);
                                }
                            }
                        }   
                    }
                }
                for(Payout__c pay : mapPayoutRenewalRecords.Values()){       
                    //#CRM-1560 - Flexibility to Modify/Create User teams in SFDC by using Config -ADDED BY Venkata Cheedara
                    /* if((quotaTeam  == Pay.RecordType.Name) && (currentQuota.User_Team__c != Commissions_Constants.COLLECTION_TEAM && 
currentQuota.User_Team__c != Commissions_Constants.CLIENT_RELATIONS_MANAGERS && 
currentQuota.User_Team__c != Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM) && (currentQuota.User_Team__c != Commissions_Constants.MANAGERS_TEAM)){   */                  
                    /* 4551: if( (currentQuota.User_Team__c == CommissionTeams__c.getInstance('COLLECTION_TEAM').Team_Name__c && pay.RecordType.Name ==CommissionTeams__c.getInstance('COLLECTION_TEAM').Team_Name__c) ||
(currentQuota.User_Team__c == CommissionTeams__c.getInstance('COLLECTIONS_CLIENT_RELATIONS_MANAGERS').Team_Name__c && pay.RecordType.Name == CommissionTeams__c.getInstance('COLLECTIONS_CLIENT_RELATIONS_MANAGERS').Team_Name__c )){ */
                    if(String.isNotBlank(currentQuota.User_Team__c) && quotaUserTeamNames.contains(currentQuota.User_Team__c.toLowerCase()) && quotaUserTeamNames.contains(pay.RecordType.Name.toLowerCase()) && currentQuota.User_Team__c.toLowerCase() == pay.RecordType.Name.toLowerCase()){
                        if(Pay.Sale_Type__c == 'Renewal'){                      
                            if(pay.Low_Level__c == Null && pay.High_Level__c == Null){
                                lowValueComp2 = pay.Low_Amount__c;
                                highValueComp2 = pay.High_Amount__c;
                                commissinableAmountComp2 = (currentQuota.Total_Sale_Renewal__c+currentQuota.Manager_Total_Sale_Renewal__c);                                    
                            }
                            if(pay.Low_Amount__c == Null && pay.High_Amount__c == Null){
                                lowValueComp2 = pay.Low_Level__c;
                                highValueComp2 = pay.High_Level__c;
                                commissinableAmountComp2 = quotaPercentageRenewal;
                            }
                        }
                        if((commissinableAmountComp2 >= lowValueComp2) && Pay.Sale_Type__c == 'Renewal'){
                            if(commissinableAmountComp2 <= highValueComp2) {                                                                 
                                if(pay.Name == Commissions_Constants.RENEWAL_WITHOUT_QUALIFIER && (!currentQuota.is_Kicker__c)){                                        
                                    if(Pay.Product_Code__c == 'ADVANTAGE'){                           
                                        ADVANTAGE_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'COBROKE'){                           
                                        COBROKE_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'DACAMPAIGN'){                             
                                        DACAMPAIGN_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'DIGITALAGENT'){                              
                                        DIGITALAGENT_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'DOMAINNAME'){                                      
                                        DOMAINNAME_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'FEATCMA'){                              
                                        FEATCMA_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'FEATDISP'){                           
                                        FEATDISP_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'FEATHOMES'){                       
                                        FEATHOMES_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'FIVESTREET'){                        
                                        FIVESTREET_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'LISTHUBPRO'){                            
                                        LISTHUBPRO_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'MRKTBUILD'){                            
                                        MRKTBUILD_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'SELLERLEAD'){                                  
                                        SELLERLEAD_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'SELLERLEADBUNDLE'){                       
                                        SELLERLEADBUNDLE_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'SHOWCASE'){                      
                                        SHOWCASE_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'SIGNRIDER'){                            
                                        SIGNRIDER_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'STANDLIST'){                           
                                        STANDLIST_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'TOPCRM'){                                  
                                        TOPCRM_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'TOPIDX'){                             
                                        TOPIDX_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'TOPMRKSNP'){                         
                                        TOPMRKSNP_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'TOPWEB'){                        
                                        TOPWEB_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'TOPWEBFEE'){                             
                                        TOPWEBFEE_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'TRKPHNMBR'){                          
                                        TRKPHNMBR_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'TURBO'){                         
                                        TURBO_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'WEBSITE'){                         
                                        WEBSITE_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'WEBSITEFEE'){                         
                                        WEBSITEFEE_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'REESIO'){  
                                        REESIO_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'RSRESPOND'){  
                                        RSRESPOND_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    //#CRM -1727 - Added Pay out rates for Broker Highlight products.
                                    if(Pay.Product_Code__c == 'MEDIABUY'){  
                                        MEDIABUY_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    //#CRM -3163 - Added Pay out rates for RealSuite products.
                                    if(Pay.Product_Code__c == 'RSCONNECT'){  
                                        RSCONNECT_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == ' RSTRANSACT'){  
                                        RSTRANSACT_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'LOCALEXPERT'){  
                                        LocalExpert_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                }
                                if(pay.Name == Commissions_Constants.RENEWAL_WITH_QUALIFIER && (currentQuota.is_Kicker__c)){                                   
                                    if(Pay.Product_Code__c == 'ADVANTAGE'){                                     
                                        ADVANTAGE_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'COBROKE'){                             
                                        COBROKE_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'DACAMPAIGN'){                         
                                        DACAMPAIGN_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'DIGITALAGENT'){                                
                                        DIGITALAGENT_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'DOMAINNAME'){                           
                                        DOMAINNAME_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'FEATCMA'){                           
                                        FEATCMA_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'FEATDISP'){                        
                                        FEATDISP_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'FEATHOMES'){                            
                                        FEATHOMES_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'FIVESTREET'){                             
                                        FIVESTREET_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'LISTHUBPRO'){                                
                                        LISTHUBPRO_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'MRKTBUILD'){                               
                                        MRKTBUILD_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'SELLERLEAD'){                                
                                        SELLERLEAD_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'SELLERLEADBUNDLE'){                            
                                        SELLERLEADBUNDLE_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'SHOWCASE'){                                
                                        SHOWCASE_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'SIGNRIDER'){                             
                                        SIGNRIDER_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'STANDLIST'){                                   
                                        STANDLIST_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'TOPCRM'){                              
                                        TOPCRM_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'TOPIDX'){                               
                                        TOPIDX_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'TOPMRKSNP'){                               
                                        TOPMRKSNP_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'TOPWEB'){                                    
                                        TOPWEB_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'TOPWEBFEE'){                                 
                                        TOPWEBFEE_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'TRKPHNMBR'){                                      
                                        TRKPHNMBR_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'TURBO'){                                     
                                        TURBO_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'WEBSITE'){                                      
                                        WEBSITE_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'WEBSITEFEE'){                                       
                                        WEBSITEFEE_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'REESIO'){  
                                        REESIO_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'RSRESPOND'){  
                                        RSRESPOND_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    //#CRM -1727 - Added Pay out rates for Broker Highlight products.
                                    if(Pay.Product_Code__c == 'MEDIABUY'){  
                                        MEDIABUY_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    //#CRM -3163 - Added Pay out rates for RealSuite products.
                                    if(Pay.Product_Code__c == 'RSCONNECT'){  
                                        RSCONNECT_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == ' RSTRANSACT'){  
                                        RSTRANSACT_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                    if(Pay.Product_Code__c == 'LOCALEXPERT'){  
                                        LocalExpert_Renew = (pay.Commissionable__c).setScale(4);
                                    }
                                }
                            }
                        }                       
                    }           
                    //#CRM-1560 - Flexibility to Modify/Create User teams in SFDC by using Config -ADDED BY Venkata Cheedara
                    //if(quotaTeam  == Pay.RecordType.Name && currentQuota.User_Team__c == Commissions_Constants.MANAGERS_TEAM){
                    if(quotaTeam  == Pay.RecordType.Name && currentQuota.User_Team__c == CommissionTeams__c.getInstance('MANAGERS_TEAM').Team_Name__c){
                        system.debug('quotaTeam   :'+quotaTeam  );
                        system.debug('Pay.RecordType.Name :'+currentQuota.Collection_Quota_Percentage__c);
                        if(currentQuota.Collection_Quota_Percentage__c == 0.0 || currentQuota.Collection_Quota_Percentage__c == Null){
                            if(Pay.Sale_Type__c == 'Renewal'){
                                if(pay.Low_Level__c == Null && pay.High_Level__c == Null){
                                    lowValueComp2 = pay.Low_Amount__c;
                                    highValueComp2 = pay.High_Amount__c;
                                    //commissinableAmountComp1 = (currentQuota.Total_Sale__c+currentQuota.Manager_Total_Sale__c);                                    
                                    commissinableAmountComp2 = (currentQuota.Total_Sale_Renewal__c+currentQuota.Manager_Total_Sale_Renewal__c);
                                }
                                if(pay.Low_Amount__c == Null && pay.High_Amount__c == Null){
                                    lowValueComp2 = pay.Low_Level__c;
                                    highValueComp2 = pay.High_Level__c;
                                    commissinableAmountComp2 = quotaPercentageRenewal;
                                } 
                                //COMPONENT 1A CALCULATION     
                                if((commissinableAmountComp2 >= lowValueComp2)){
                                    if(commissinableAmountComp2 <= highValueComp2) {  
                                        if(pay.Name == Commissions_Constants.RENEWAL_WITHOUT_QUALIFIER){ 
                                            payoutRate1B = (pay.Commissionable__c).setScale(6);
                                        }       
                                    }
                                }
                            }                            
                        }                        
                    }               
                }
                //ASSIGNING CALCULATED PAYOUTS TO RELATED FIELDS OF PROCESSED QUOTA
                currentQuota.Component_1A_Payout__c = payoutRate1A;
                currentQuota.Renewal_Payout__c = payoutRate1B;
                currentQuota.ADVANTAGE_New__c = ADVANTAGE_New;
                currentQuota.ADVANTAGE_Renew__c = ADVANTAGE_Renew;
                currentQuota.COBROKE_New__c = COBROKE_New;
                currentQuota.COBROKE_Renew__c = COBROKE_Renew;
                currentQuota.DACAMPAIGN_New__c = DACAMPAIGN_New;
                currentQuota.DACAMPAIGN_Renew__c = DACAMPAIGN_Renew;
                currentQuota.DIGITALAGENT_New__c = DIGITALAGENT_New;
                currentQuota.DIGITALAGENT_Renew__c = DIGITALAGENT_Renew;
                currentQuota.DOMAINNAME_New__c = DOMAINNAME_New;
                currentQuota.DOMAINNAME_Renew__c = DOMAINNAME_Renew;
                currentQuota.FEATCMA_New__c = FEATCMA_New;
                currentQuota.FEATCMA_Renew__c = FEATCMA_Renew;
                currentQuota.FEATDISP_New__c = FEATDISP_New;
                currentQuota.FEATDISP_Renew__c = FEATDISP_Renew;
                currentQuota.FEATHOMES_New__c = FEATHOMES_New;
                currentQuota.FEATHOMES_Renew__c = FEATHOMES_Renew;
                currentQuota.FIVESTREET_New__c = FIVESTREET_New;
                currentQuota.FIVESTREET_Renew__c = FIVESTREET_Renew;
                currentQuota.LISTHUBPRO_New__c = LISTHUBPRO_New;
                currentQuota.LISTHUBPRO_Renew__c = LISTHUBPRO_Renew;
                currentQuota.MRKTBUILD_New__c = MRKTBUILD_New;
                currentQuota.MRKTBUILD_Renew__c = MRKTBUILD_Renew;
                currentQuota.SELLERLEAD_New__c = SELLERLEAD_New ;
                currentQuota.SELLERLEAD_Renew__c = SELLERLEAD_Renew;
                currentQuota.SELLERLEADBUNDLE_New__c = SELLERLEADBUNDLE_New;
                currentQuota.SELLERLEADBUNDLE_Renew__c = SELLERLEADBUNDLE_Renew;
                currentQuota.SHOWCASE_New__c = SHOWCASE_New;
                currentQuota.SHOWCASE_Renew__c = SHOWCASE_Renew;
                currentQuota.SIGNRIDER_New__c = SIGNRIDER_New;
                currentQuota.SIGNRIDER_Renew__c = SIGNRIDER_Renew;
                currentQuota.STANDLIST_New__c = STANDLIST_New;
                currentQuota.STANDLIST_Renew__c = STANDLIST_Renew;
                currentQuota.TOPCRM_New__c = TOPCRM_New;
                currentQuota.TOPCRM_Renew__c = TOPCRM_Renew;
                currentQuota.TOPIDX_New__c = TOPIDX_New;
                currentQuota.TOPIDX_Renew__c = TOPIDX_Renew;
                currentQuota.TOPMRKSNP_New__c = TOPMRKSNP_New;
                currentQuota.TOPMRKSNP_Renew__c = TOPMRKSNP_Renew;
                currentQuota.TOPWEB_New__c = TOPWEB_New;
                currentQuota.TOPWEB_Renew__c = TOPWEB_Renew; 
                currentQuota.TOPWEBFEE_New__c = TOPWEBFEE_New;
                currentQuota.TOPWEBFEE_Renew__c = TOPWEBFEE_Renew;
                currentQuota.TRKPHNMBR_New__c = TRKPHNMBR_New;
                currentQuota.TRKPHNMBR_Renew__c = TRKPHNMBR_Renew;
                currentQuota.TURBO_New__c = TURBO_New;
                currentQuota.TURBO_Renew__c = TURBO_Renew;
                currentQuota.WEBSITE_New__c = WEBSITE_New;
                currentQuota.WEBSITE_Renew__c = WEBSITE_Renew;
                currentQuota.WEBSITEFEE_New__c = WEBSITEFEE_New;
                currentQuota.WEBSITEFEE_Renew__c = WEBSITEFEE_Renew;
                currentQuota.REESIO_New__c = REESIO_New;
                currentQuota.REESIO_Renew__c = REESIO_Renew;
                currentQuota.RSRESPOND_New__c = RSRESPOND_New;
                currentQuota.RSRESPOND_Renew__c = RSRESPOND_Renew;
                currentQuota.Collection_Payout__c = collectionTeamPayout;
                currentQuota.MEDIABUY_New__c = MEDIABUY_New;  
                currentQuota.MEDIABUY_Renew__c= MEDIABUY_Renew; 
                
                currentQuota.RSCONNECT_New__c = RSCONNECT_New;
                currentQuota.RSTRANSACT_New__c = RSTRANSACT_New;
                currentQuota.RSCONNECT_Renew__c = RSCONNECT_Renew;
                currentQuota.RSTRANSACT_Renew__c = RSTRANSACT_Renew;  
                currentQuota.LocalExpert_New__c = LocalExpert_New;
                currentQuota.LocalExpert_Renew__c = LocalExpert_Renew;
                
                
                currentQuota.Record_Processed__c = TRUE;           
                quotaRecords.put(currentQuota.id,currentQuota);
                
            }
        }
        System.debug(LoggingLevel.ERROR, 'Heap Size: 1 : ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize());
        
        //UPDATING COMMISSION RECORDS OF RELATED QUOTA      
        //#CRM-1560 - Flexibility to Modify/Create User teams in SFDC by using Config -ADDED BY Venkata Cheedara
        /* Map<id,commission__c> commissionMap = new Map<id,Commission__c>([select id,user_Team__c,Total_Clawback_Commission__c,Total_Clawback_Commission_RD__c,Related_to_Quota__c,RecordType.Name  
from commission__c where User_Team__c !=: Commissions_Constants.MANAGERS_TEAM and Related_To_Quota__c IN : quotaIds]); */
        Map<id,commission__c> commissionMap = new Map<id,Commission__c>([select id,user_Team__c,Total_Clawback_Commission__c,Total_Clawback_Commission_RD__c,Related_to_Quota__c,RecordType.Name  
                                                                         from commission__c where User_Team__c !=: CommissionTeams__c.getInstance('MANAGERS_TEAM').Team_Name__c and Related_To_Quota__c IN : quotaIds ]);                      
        Map<Id,Quota__c> mapQuotas = new Map<Id,Quota__c>(); 
        
        //Code Open 
        if(commissionMap.size() > 0){
            for(Quota__c quotaRecord : quotaRecords.Values()){
                decimal Total_Clawback_Commission = 0.0;decimal Total_Clawback_Commission_RD = 0.0;
                for(commission__c comm : commissionMap.values()){
                    //#CRM-1560 - Flexibility to Modify/Create User teams in SFDC by using Config -ADDED BY Venkata Cheedara
                    //if(quotaRecord.id == comm.Related_To_Quota__c  && comm.Total_Clawback_Commission__c !=0.0 && comm.RecordType.Name == 'Clawback' && comm.User_Team__c != Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM){
                    if(quotaRecord.id == comm.Related_To_Quota__c  && (comm.Total_Clawback_Commission__c !=0.0 || Total_Clawback_Commission != null) && comm.RecordType.Name == 'Clawback' && comm.User_Team__c != CommissionTeams__c.getInstance('BROKER_REGIONAL_DIRECTORS_TEAM').Team_Name__c){
                        Total_Clawback_Commission = Total_Clawback_Commission + comm.Total_Clawback_Commission__c;        
                    }
                    //#CRM-1560 - Flexibility to Modify/Create User teams in SFDC by using Config -ADDED BY Venkata Cheedara
                    //if(quotaRecord.id == comm.Related_To_Quota__c && comm.RecordType.Name == 'Clawback' && comm.User_Team__c == Commissions_Constants.BROKER_REGIONAL_DIRECTORS_TEAM){
                    if(quotaRecord.id == comm.Related_To_Quota__c && comm.RecordType.Name == 'Clawback' && comm.User_Team__c == CommissionTeams__c.getInstance('BROKER_REGIONAL_DIRECTORS_TEAM').Team_Name__c){
                        Total_Clawback_Commission_RD = Total_Clawback_Commission_RD + comm.Total_Clawback_Commission_RD__c;        
                    }                    
                    commissionMap.put(comm.id,comm);
                    mapQuotas.put(quotaRecord.id,quotaRecord);       
                }
                quotaRecord.Record_Processed__c = TRUE; 
                // #CRM-2372 - Total Clawback Commission is setting to 0 on Quota's by System Users.
                if(Total_Clawback_Commission != 0.0 || Total_Clawback_Commission != null){
                    quotaRecord.Total_Clawback_Commission_Amount__c = Total_Clawback_Commission ;
                }
                quotaRecord.Total_Clawback_Commission_Amount_RD__c = Total_Clawback_Commission_RD;
                quotaRecords.put(quotaRecord.id,quotaRecord);    
            }          
        } 
        
        //MANAGERS TEAM
        //claw back condition added in WHERE CLAUSE by srinivas pendli on 25.5.2016 for "System.LimitException: Too many DML rows: 10001" Exception
        //#CRM-1560 - Flexibility to Modify/Create User teams in SFDC by using Config -ADDED BY Venkata Cheedara
        /* Map<id,commission__c> commissionMapManagers = new Map<id,Commission__c>([select id,Total_Clawback_Commission__c,Related_to_Quota__c,RecordType.Name  
from commission__c where User_Team__c =: Commissions_Constants.MANAGERS_TEAM and RecordType.Name = 'Clawback' and Related_To_Quota__c IN : quotaIds]); */
        Map<id,commission__c> commissionMapManagers = new Map<id,Commission__c>([select id,Total_Clawback_Commission__c,Related_to_Quota__c,RecordType.Name  
                                                                                 from commission__c where User_Team__c =:  CommissionTeams__c.getInstance('MANAGERS_TEAM').Team_Name__c and RecordType.Name = 'Clawback' and Related_To_Quota__c IN : quotaIds]);
        if(commissionMapManagers.size() > 0){ 
            for(Quota__c quotaRecord : quotaRecords.Values()){               
                decimal Total_Clawback_Commission_Mgr = 0.0;
                for(commission__c comm : commissionMapManagers.values()){
                    if(quotaRecord.id == comm.Related_To_Quota__c && comm.RecordType.Name == 'Clawback'){
                        Total_Clawback_Commission_Mgr = Total_Clawback_Commission_Mgr + comm.Total_Clawback_Commission__c;        
                    }
                    commissionMapManagers.put(comm.id,comm);       
                }
                quotaRecord.Record_Processed__c = TRUE;
                quotaRecord.Total_Clawback_Commission_Amount__c = Total_Clawback_Commission_Mgr;
                quotaRecords.put(quotaRecord.id,quotaRecord);
            }
        }
        //Code end 
        if(!quotaRecords.isEmpty()){
            SkipAssetTrigger.setSkipTrgTrue();
            update quotaRecords.values();
        }
        if(!commissionMap.isEmpty()){
            SkipAssetTrigger.setSkipTrgTrue();
            update commissionMap.values();
        }
        if(!commissionMapManagers.isEmpty()){
            SkipAssetTrigger.setSkipTrgTrue();
            update commissionMapManagers.values();
        }
        //if(recordProcessed){
        Commissions_PayoutCalculation comms1 = new Commissions_PayoutCalculation();
        comms1.payoutCalculation(quotaIds,quotaRecords);          
        //Commissions_KickerQualifierSwapClass comms = new Commissions_KickerQualifierSwapClass();
        //comms.swapMethod(quotaIds);  
        //} 
        mapPayoutNewSalesRecords.clear();   
        mapPayoutRenewalRecords.clear();   
    }
    Public Void managersRollUp(List<Quota__c> mgrQuota,Set<String> managersList){        
        String queryString = 'SELECT Id, Roll_up_Total_of_Deals__c, Total_of_Deals__c, Name,Total_Sale__c,Final_Commission_Amount__c,Manager_Total_Sale__c,Managers__c,Total_Sale_Renewal__c,Manager_Total_Sale_Renewal__c,Manager_Total_Clawback_Commissinable_Amt__c,Total_Clawback__c,Collection_Total_Sale__c,Manager_Collection_Sale__c,Manager_Total_Clawback_Commission__c,Total_Clawback_Commission_Amount__c,Quota_StartDate__c,User_Team__c FROM Quota__c WHERE Managers__c INCLUDES(';
        for(String includeValue : managersList)
            queryString += includeValue + ',';
        queryString = queryString.removeEnd(',') +')';
        
        List<Quota__c> listQuota = (List<Quota__c>)Database.query(queryString);
        Map<id,quota__c> mapQuotas = new Map<id,quota__c>();
        for(Quota__c parent : mgrQuota){
            parent.Manager_Total_Sale__c = 0.0;
            parent.Manager_Total_Sale_Renewal__c = 0.0;
            parent.Manager_Total_Clawback_Commissinable_Amt__c = 0.0;
            parent.Manager_Collection_Sale__c = 0.0;
            parent.Roll_up_Total_of_Deals__c = 0.0;
            system.debug('Limit=='+Limits.getLimitCpuTime());
            system.debug('ApexCPULimit='+Limits.getCpuTime());
            for(Quota__c child : listQuota){
                if(String.isNotBlank(child.Managers__c) && child.Managers__c.contains(parent.Owner_Name__c) && child.Quota_StartDate__c != null && parent.Quota_StartDate__c != null 
                   && child.Quota_StartDate__c.month() == parent.Quota_StartDate__c.month()
                   && child.Quota_StartDate__c.Year() == parent.Quota_StartDate__c.Year()){
                       //MANAGER TOTAL SALE CALCULATION
                       parent.Manager_Total_Sale__c = (parent.Manager_Total_Sale__c + child.Total_Sale__c);
                       parent.Manager_Total_Sale_Renewal__c = (parent.Manager_Total_Sale_Renewal__c + child.Total_Sale_Renewal__c);
                       
                       if(child.Total_of_Deals__c != null){
                           if(parent.Roll_up_Total_of_Deals__c == null){
                               parent.Roll_up_Total_of_Deals__c = 0.0;
                           }
                           parent.Roll_up_Total_of_Deals__c += child.Total_of_Deals__c;	// BLA Commissions
                       }
                       //MANAGER TOTAL CLAWBACK CALCULATION
                       if(child.Total_Clawback__c!= null){
                           //parent.Manager_Total_Clawback_Commission__c =(parent.Manager_Total_Clawback_Commission__c + child.Total_Clawback_Commission_Amount__c);                                      
                           parent.Manager_Total_Clawback_Commissinable_Amt__c=(parent.Manager_Total_Clawback_Commissinable_Amt__c+ child.Total_Clawback__c);                                      
                       }                    
                       //MANAGER COLLECTION SALE 
                       //#CRM-1560 - Flexibility to Modify/Create User teams in SFDC by using Config -ADDED BY Venkata Cheedara
                       //if(parent.User_Team__c == Commissions_Constants.MANAGERS_TEAM){
                       if(parent.User_Team__c == CommissionTeams__c.getInstance('MANAGERS_TEAM').Team_Name__c){
                           parent.Manager_Collection_Sale__c = (parent.Manager_Collection_Sale__c+ child.Collection_Total_Sale__c);                                      
                       }
                       mapQuotas.put(Parent.id,Parent);
                   }
            }                 
        }         
    }
}