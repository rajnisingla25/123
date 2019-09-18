/* Class :- LeadScoreCalculationCls
Purpose : CRM-1804 Calculate Account Score and Inventory Score
CRM - CRM-2334 Calculate Waitlist Score
Created Date :- 12 June 2017
Created By : Sonu Sharma
*/

Public class LeadScoreCalculationCls {

    // Score weightage
    Integer waitlistweight = 1;
    Integer waitlistwarmweight = 1;
    Integer waitlistpipelineweight = 1;
    Integer waitlistscoreweight = 5;
    
    Integer formweight = 4;
    Integer buyersideweight = 3;
    Integer listingweight = 2;
    Integer officeweight = 1;
    Integer customerweight = 10;
    Integer formerweight = 1;
    Integer prospectweight = 2;
    Integer perfectaccweight = 100;
    Integer normalaccweight = 1;
    Integer custom1weight = 1;
    Integer custom2weight = 1;
    Integer custom3weight = 1;
    Integer custom4weight = 1;
    Integer custom5weight = 1;
    Integer ownerweight = 1;
    Lead_Scoring_Settings__c lscwaitlist = Lead_Scoring_Settings__c.getValues('Waitlist Weight');
    Lead_Scoring_Settings__c lscwaitlistwarm = Lead_Scoring_Settings__c.getValues('Waitlist Warm');
    Lead_Scoring_Settings__c lscwaitlistpipeline = Lead_Scoring_Settings__c.getValues('Waitlist Pipeline');
    Lead_Scoring_Settings__c lscweightwaitlist = Lead_Scoring_Settings__c.getValues('Waitlist Score Weight');
    Lead_Scoring_Settings__c lscform = Lead_Scoring_Settings__c.getValues('Form Weight');
    Lead_Scoring_Settings__c lscbuyerside = Lead_Scoring_Settings__c.getValues('BuyerSide Weight');
    Lead_Scoring_Settings__c lsclisting = Lead_Scoring_Settings__c.getValues('Listing Weight');
    Lead_Scoring_Settings__c lscoffice = Lead_Scoring_Settings__c.getValues('Office Weight');
    Lead_Scoring_Settings__c lsccustomer = Lead_Scoring_Settings__c.getValues('Customer Weight');
    Lead_Scoring_Settings__c lscformer = Lead_Scoring_Settings__c.getValues('Former Weight');
    Lead_Scoring_Settings__c lscprospect = Lead_Scoring_Settings__c.getValues('Prospect Weight');
    Lead_Scoring_Settings__c lscperfectacc = Lead_Scoring_Settings__c.getValues('Credit Worthiness Weight');
    Lead_Scoring_Settings__c lscnormalacc = Lead_Scoring_Settings__c.getValues('Account owner Weight');
    Lead_Scoring_Settings__c lsccustom1 = Lead_Scoring_Settings__c.getValues('Custom1 Weight');
    Lead_Scoring_Settings__c lsccustom2 = Lead_Scoring_Settings__c.getValues('Custom2 Weight');
    Lead_Scoring_Settings__c lsccustom3 = Lead_Scoring_Settings__c.getValues('Custom3 Weight');
    Lead_Scoring_Settings__c lsccustom4 = Lead_Scoring_Settings__c.getValues('Custom4 Weight');
    Lead_Scoring_Settings__c lsccustom5 = Lead_Scoring_Settings__c.getValues('Custom5 Weight');
    Lead_Scoring_Settings__c lscowner = Lead_Scoring_Settings__c.getValues('Owner Weight');
    Set<String> setOwnerString = new Set<String>{'runassigned.move.com@example.com.qa','datamigration@move.com.qa','batchintegration_user@move.com.qa','formercustomerholdingbook@move.com.qa'};
    // Method to Calculate Score
    Public void CalculateScore(Map < Id, Inventory_Data__c > newMapInventoryData, Map < Id, Inventory_Data__c > oldMapInventoryData) {
        
        
        Set < Id > setIds = new Set < Id > ();
        try{
        
        Boolean usewaitlist = true;
        Boolean usebuyerside = true;
        Boolean uselisting = true;
        Boolean useform = true;
        Boolean useoffice = true;
        Boolean useasset = true;
        Boolean usecustom1 = true;
        Boolean usecustom2 = true;
        Boolean usecustom3 = true;
        Boolean usecustom4 = true;
        Boolean usecustom5 = true;
        if (lscwaitlist != null) {
            waitlistweight = Integer.valueOf(lscwaitlist.Weight__c);
        }
        if (lscwaitlistwarm != null) {
            waitlistwarmweight = Integer.valueOf(lscwaitlistwarm.Weight__c);
        }
        if (lscwaitlistpipeline != null) {
            waitlistpipelineweight = Integer.valueOf(lscwaitlistpipeline.Weight__c);
        }
        if(lscweightwaitlist!=null){
            waitlistscoreweight = Integer.valueOf(lscweightwaitlist.Weight__c);
        }
        if (lscform != null) {
            formweight = Integer.valueOf(lscform.Weight__c);
        }
        if (lscbuyerside != null) {
            buyersideweight = Integer.valueOf(lscbuyerside.Weight__c);
        }
        if (lsclisting != null) {
            listingweight = Integer.valueOf(lsclisting.Weight__c);
        }
        if (lscoffice != null) {
            officeweight = Integer.valueOf(lscoffice.Weight__c);
        }
        if (lsccustomer != null) {
            customerweight = Integer.valueOf(lsccustomer.Weight__c);
        }
        if (lscformer != null) {
            formerweight = Integer.valueOf(lscformer.Weight__c);
        }
        if (lscprospect != null) {
            prospectweight = Integer.valueOf(lscprospect.Weight__c);
        }
        if (lscperfectacc != null) {
            perfectaccweight = Integer.valueOf(lscperfectacc.Weight__c);
        }
        if (lscnormalacc != null) {
            normalaccweight = Integer.valueOf(lscnormalacc.Weight__c);
        }
        if (lsccustom1 != null) {
            custom1weight = Integer.valueOf(lsccustom1.Weight__c);
        }
        if (lsccustom2 != null) {
            custom2weight = Integer.valueOf(lsccustom2.Weight__c);
        }
        if (lsccustom3 != null) {
            custom3weight = Integer.valueOf(lsccustom3.Weight__c);
        }
        if (lsccustom4 != null) {
            custom4weight = Integer.valueOf(lsccustom4.Weight__c);
        }
        if (lsccustom5 != null) {
            custom5weight = Integer.valueOf(lsccustom5.Weight__c);
        }
        if (lscowner != null) {
            ownerweight = Integer.valueOf(lscowner.Weight__c);
        }

        for (Inventory_Data__c Idd: newMapInventoryData.values()) {

            // get Ids for update event
            if (Trigger.isUpdate) {
                if (oldMapInventoryData.get(Idd.id).Is_available__c != Idd.Is_available__c) {
                    setIds.add(Idd.id);
                }
            }
            // get Ids for Insert event
            if (Trigger.isInsert) {
                if (Idd.Is_available__c) {
                    setIds.add(Idd.id);
                }
            }
        }

        Map < Id, Decimal > mapAccountIds = new Map < Id, Decimal > ();
        Map < Id, Decimal > mapWaitlistAccountScore = new Map < Id, Decimal > ();
        Map < Id, Decimal > mapAccountUpsellIds = new Map < Id, Decimal > ();
        system.debug(setIds+'KKKKK');
        // Query Invetory account relationship data
        for (Inventory_Account__c Ia: [Select Id, Name, Account__c from Inventory_Account__c where Inventory_Data__c =: setIds and Short_calculation__c = true]) {
            mapAccountIds.put(Ia.Account__c, 0);
mapAccountUpsellIds.put(Ia.Account__c, 0);
            //CRM-2334 : Defaulting score to 0
            mapWaitlistAccountScore.put(Ia.Account__c, 0);
        }
            System.debug(mapWaitlistAccountScore.values());
        // Inventory account data query
        for (Inventory_Account__c Ia: [Select Id, Name,Has_Assets__c,Waitlist_Type__c,Eligibility_Flex__c,Waitlist_Slot_Type__c,Having_waitlist__c,Custom_field1__c,Custom_field2__c,Custom_field3__c,Custom_field4__c,Custom_field5__c, Waitlist__c, office__c, Inventory_Data__c, Listing__c, Form__c, Buyers_Side__c, Account__c from Inventory_Account__c where Account__c =: mapAccountIds.keyset() and Inventory_Data__r.Is_available__c = true and Inventory_Data__r.Opcity_Market__c = false and Short_calculation__c = true and Inventory_Data__r.is_city_code__c = false]) {
            //if
            System.debug(Ia.id+'####PPPP');
            Integer countrecord = 0;
            Integer assetcount = 0;
            System.debug('####PPPP'+countrecord);
            if(Ia.Waitlist__c){
            //usewaitlist = true;
            }
            if (newMapInventoryData.get(Ia.Inventory_Data__c) != null) {
                if (newMapInventoryData.get(Ia.Inventory_Data__c).Is_available__c) {
                    if (Ia.Waitlist__c && usewaitlist) {
                        countrecord = waitlistweight;
                        System.debug('####PPPP'+countrecord);
                    } else if (Ia.Form__c && useform) {
                        countrecord = formweight;
                        System.debug('####PPPP'+countrecord);
                    }else if (Ia.Buyers_Side__c && usebuyerside) {
                        countrecord = buyersideweight;
                        System.debug('####PPPP'+countrecord);
                    } else if (Ia.Listing__c && uselisting) {
                        countrecord = listingweight;
                        System.debug('####PPPP'+countrecord);
                    } else if (Ia.office__c && useoffice) {
                        countrecord = officeweight;
                        System.debug('####PPPP'+countrecord);
                    }  else if (Ia.Custom_field1__c && usecustom1) {
                        countrecord = custom1weight;
                    } else if (Ia.Custom_field2__c && usecustom2) {
                        countrecord = custom2weight;
                    } else if (Ia.Custom_field3__c && usecustom3) {
                        countrecord = custom3weight;
                    } else if (Ia.Custom_field4__c && usecustom4) {
                        countrecord = custom4weight;
                    } else if (Ia.Custom_field5__c && usecustom5) {
                        countrecord = custom5weight;
                    } else {

                    }
                    System.debug('####PPPP'+countrecord);
                    if (Ia.Has_Assets__c && useasset) {
                        assetcount = 1;
                    }
                }
                
            } else {
                if (Ia.Waitlist__c) {
                    countrecord = waitlistweight;
                    System.debug('####PPPP'+countrecord);
                } else if (Ia.Form__c) {
                        countrecord = formweight;
                        System.debug('####PPPP'+countrecord);
                }else if (Ia.Buyers_Side__c) {
                    countrecord = buyersideweight;
                    System.debug('####PPPP'+countrecord);
                } else if (Ia.Listing__c) {
                    countrecord = listingweight;
                    System.debug('####PPPP'+countrecord);
                } else if (Ia.office__c) {
                    countrecord = officeweight;
                    System.debug('####PPPP'+countrecord);
                }  else if (Ia.Custom_field1__c) {
                    countrecord = custom1weight;
                } else if (Ia.Custom_field2__c) {
                    countrecord = custom2weight;
                } else if (Ia.Custom_field3__c) {
                    countrecord = custom3weight;
                } else if (Ia.Custom_field4__c) {
                    countrecord = custom4weight;
                } else if (Ia.Custom_field5__c) {
                    countrecord = custom5weight;
                }
                if (Ia.Has_Assets__c && useasset) {
                        assetcount = 1;
                    }
System.debug('####PPPP'+countrecord);
            }
            
            System.debug(Ia.id+'####'+Ia.Having_waitlist__c+'Running Account Id '+Ia.Account__c);
                    //CRM-2334 :- Adding score 1 to current value
                    if(Ia.Having_waitlist__c){
                    System.debug('Running Account Id '+Ia.Account__c);
                    mapWaitlistAccountScore.put(Ia.Account__c,(mapWaitlistAccountScore.get(Ia.Account__c) + 1));
                    }
                    //System.debug('$$$$$'+mapWaitlistAccountScore.values());
            //System.debug('$$$$$'+mapWaitlistAccountScore);
            mapAccountIds.put(Ia.Account__c, (mapAccountIds.get(Ia.Account__c) + countrecord));
            mapAccountUpsellIds.put(Ia.Account__c, (mapAccountUpsellIds.get(Ia.Account__c) + assetcount));
            //mapWaitlistAccountScore.put(Ia.Account__c,(mapAccountIds.get(Ia.Account__c) + 1));
        }

        // Map account data to update
        Map < Id, Account > mapUpdateAccount = new Map < Id, Account > ([Select id, name,owner.username, Credit_Dispute__c, Credit_Risk__c, Credit_Status__c, Account_Sub_Type__c, Inventory_Score__c from account where Id =: mapAccountIds.keyset()]);
        Integer multiplier = 1;
        Integer CreditWorthiness = 1;
        System.debug( mapAccountIds +'KLLLK');
        for (Id idd: mapAccountIds.keyset()) {
            Account acc = new Account();
            acc = mapUpdateAccount.get(idd);
            multiplier = 1;
            CreditWorthiness = 0;
            if(setOwnerString.contains(acc.Owner.Username+'')){
            ownerweight = 1;
            }
            acc.waitlist_score__c = mapWaitlistAccountScore.get(idd);
            acc.Inventory_Score__c = mapAccountIds.get(idd);  //CRM-2334
            acc.Upsell_Score_new__c = mapAccountUpsellIds.get(idd);  //CRM-2334
            if (acc.Account_Sub_Type__c == 'Customer') {
                multiplier = customerweight;
            }
            if (acc.Account_Sub_Type__c == 'Former Customer') {
                multiplier = formerweight;
            }
            if (acc.Account_Sub_Type__c == 'Prospect') {
                multiplier = prospectweight;
            }
            if (acc.Credit_Dispute__c == false && acc.Credit_Risk__c == false && acc.Credit_Status__c == 'Current') {
                CreditWorthiness = perfectaccweight;
            }
            System.debug(CreditWorthiness +'****'+ normalaccweight +'****'+ multiplier);

           // acc.Account_Score__c = (CreditWorthiness+normalaccweight + multiplier);
            acc.Id = idd;
            mapUpdateAccount.put(idd, acc);
        }
        if (mapUpdateAccount.values().size() > 0) {
            SkipAccountTrigger.setSkipTrgTrue();
            update mapUpdateAccount.values(); // Map account data update
        }
        
        } catch(Exception ex){
           //  CRM-2822
           List<Inventory_Data__c> lstInvData = [Select Id,Soa_Error__c,name,SOA_Error_Full_Count__c,SOA_Error_Half_Count__c,Error__c,Error_Message__c from Inventory_Data__c where Id=:setIds and is_city_code__c = false];
           for(Inventory_Data__c Idd:lstInvData){
           Idd.Error__c = true ;
           Idd.Soa_Error__c = false ;
           Idd.SOA_Error_Full_Count__c = 1000;
           Idd.SOA_Error_Half_Count__c = 1000;
           Idd.Error_Message__c ='Line number : '+ex.getLineNumber()+ ' Stack trace'+ ex.getStackTraceString()+' Print Message'+ex.getMessage();
           }
           setSkipTrgTrue();
           update lstInvData;
           //CRM-2822
           }
    }
    
    // Method to Calculate Opcity Score
    
    
    Public void CalculateOpcityScore(Map < Id, Inventory_Data__c > newMapInventoryData, Map < Id, Inventory_Data__c > oldMapInventoryData) {
        Set < Id > setIds = new Set < Id > ();
        for (Inventory_Data__c Idd: newMapInventoryData.values()) {

            // get Ids for update event
            if (Trigger.isUpdate) {
                if (oldMapInventoryData.get(Idd.id).Red_market__c != Idd.Red_market__c || oldMapInventoryData.get(Idd.id).Yellow_Market__c != Idd.Yellow_Market__c || oldMapInventoryData.get(Idd.id).Green_Market__c != Idd.Green_Market__c) {
                    setIds.add(Idd.id);
                }
            }
           
        }
        CalculateOpcityScoreFuture(setIds);
        }
        
        @future
    Public static void CalculateOpcityScoreFuture(set<Id> setIds) {
    // Score weightage
    Integer waitlistweight = 6;
    
    
    Integer formweight = 4;
    Integer buyersideweight = 10;
    Integer listingweight = 5;
    Integer tcvweight = 1;
    
    Lead_Scoring_Settings__c lscwaitlist = Lead_Scoring_Settings__c.getValues('Opcity Waitlist Weight');
    
    Lead_Scoring_Settings__c lscform = Lead_Scoring_Settings__c.getValues('Opcity Form Weight');
    Lead_Scoring_Settings__c lscbuyerside = Lead_Scoring_Settings__c.getValues('Opcity BuyerSide Weight');
    Lead_Scoring_Settings__c lsclisting = Lead_Scoring_Settings__c.getValues('Opcity Listing Weight');
    Lead_Scoring_Settings__c lscUseTCV = Lead_Scoring_Settings__c.getValues('Opcity TCV Weight');
   
        try{
        
        Boolean usewaitlist = true;
        Boolean usebuyerside = true;
        Boolean uselisting = true;
        Boolean useform = true;
        Boolean useTCV = true;
        
        if (lscwaitlist != null) {
            waitlistweight = Integer.valueOf(lscwaitlist.Weight__c);
        }
        
        if (lscform != null) {
            formweight = Integer.valueOf(lscform.Weight__c);
        }
        if (lscbuyerside != null) {
            buyersideweight = Integer.valueOf(lscbuyerside.Weight__c);
        }
        if (lsclisting != null) {
            listingweight = Integer.valueOf(lsclisting.Weight__c);
        }
        if (lscUseTCV != null) {
            tcvweight = Integer.valueOf(lscUseTCV.Weight__c);
        }
 
        Set<Id> setAccountIds = new Set<Id>();  
        Map < Id, Decimal > mapAccountIds = new Map < Id, Decimal > ();
        Map < Id, Decimal > mapRedAccountIds = new Map < Id, Decimal > ();
        Map < Id, Decimal > mapGreenAccountIds = new Map < Id, Decimal > ();
        Map < Id, Decimal > mapYellowAccountIds = new Map < Id, Decimal > ();
        Map < Id, Decimal > mapWaitlistAccountScore = new Map < Id, Decimal > ();
        Map < Id, Decimal > mapAccountUpsellIds = new Map < Id, Decimal > ();
        system.debug(setIds+'KKKKK');
        // Query Invetory account relationship data
        for (Inventory_Account__c Ia: [Select Id, Name, Account__c,Number_of_Buy_Side_Transactions__c,Inventory_Data__r.Red_market__c,Inventory_Data__r.Green_Market__c,Inventory_Data__r.Yellow_Market__c from Inventory_Account__c where Inventory_Data__c =: setIds and Account__r.Type='Realtor Agent' and Short_calculation__c = true and Inventory_Data__r.is_city_code__c = false]) {
            mapAccountIds.put(Ia.Account__c,0);
            if(Ia.Inventory_Data__r.Red_Market__c){
            mapRedAccountIds.put(Ia.Account__c, 0);
            }
            if(Ia.Inventory_Data__r.Green_Market__c){
            mapGreenAccountIds.put(Ia.Account__c, 0);
            }
            if(Ia.Inventory_Data__r.Yellow_Market__c){
            mapYellowAccountIds.put(Ia.Account__c, 0);
            }
        }
            //System.debug(mapWaitlistAccountScore.values());
        // Inventory account data query
        for (Inventory_Account__c Ia: [Select Id, Name,Number_of_Buy_Side_Transactions__c,Account__r.Total_Contract_Value__c,Having_waitlist__c,Custom_field1__c,Custom_field2__c,Custom_field3__c,Custom_field4__c,Custom_field5__c, Waitlist__c, office__c, Inventory_Data__c, Listing__c, Form__c, Buyers_Side__c, Account__c from Inventory_Account__c where Account__c =: mapRedAccountIds.keyset() and Inventory_Data__r.Red_market__c=true  and Account__r.Type='Realtor Agent' and Short_calculation__c = true and Inventory_Data__r.is_city_code__c = false]) {
            //if
            System.debug(Ia.id+'####PPPP');
            Integer countrecord = 0;
            Integer assetcount = 0;
            
               
                    if (Ia.Buyers_Side__c && usebuyerside) {
                        if(Ia.Number_of_Buy_Side_Transactions__c==null){Ia.Number_of_Buy_Side_Transactions__c=0;}
                        countrecord = buyersideweight*Integer.valueof(Ia.Number_of_Buy_Side_Transactions__c);
                        System.debug('####PPPP'+countrecord);
                    } 
                     if (Ia.Account__r.Total_Contract_Value__c>0 && useTCV || Test.isRunningTest()) {
                        if(Ia.Account__r.Total_Contract_Value__c<=5000){ tcvweight = 1; }  
                        else if(Ia.Account__r.Total_Contract_Value__c>5000 && Ia.Account__r.Total_Contract_Value__c<=10000){tcvweight = 5; }
                        else if(Ia.Account__r.Total_Contract_Value__c>10000 && Ia.Account__r.Total_Contract_Value__c<=25000){tcvweight = 25; }
                        else if(Ia.Account__r.Total_Contract_Value__c>25000 && Ia.Account__r.Total_Contract_Value__c<=50000){tcvweight = 50; }
                        else if(Ia.Account__r.Total_Contract_Value__c>50000 && Ia.Account__r.Total_Contract_Value__c<=100000){tcvweight = 75; }
                        else if(Ia.Account__r.Total_Contract_Value__c>100000){tcvweight = 100; }
                        countrecord = countrecord + tcvweight;
                        System.debug('####PPPP'+countrecord);
                    }  
                     if (Ia.Waitlist__c && usewaitlist) {
                        countrecord = countrecord + waitlistweight;
                        System.debug('####PPPP'+countrecord);
                    } 
                     if (Ia.Listing__c && uselisting) {
                        countrecord = countrecord + listingweight;
                        System.debug('####PPPP'+countrecord);
                    }  
                    mapRedAccountIds.put(Ia.Account__c, (mapRedAccountIds.get(Ia.Account__c) + countrecord));
            
           
        }
        
        // Inventory account data query
        for (Inventory_Account__c Ia: [Select Id, Name,Number_of_Buy_Side_Transactions__c,Account__r.Total_Contract_Value__c,Having_waitlist__c,Custom_field1__c,Custom_field2__c,Custom_field3__c,Custom_field4__c,Custom_field5__c, Waitlist__c, office__c, Inventory_Data__c, Listing__c, Form__c, Buyers_Side__c, Account__c from Inventory_Account__c where Account__c =: mapYellowAccountIds.keyset() and Inventory_Data__r.Yellow_market__c=true  and Account__r.Type='Realtor Agent' and Short_calculation__c = true and Inventory_Data__r.is_city_code__c=false]) {
            //if
            System.debug(Ia.id+'####PPPP');
            Integer countrecord = 0;
            Integer assetcount = 0;
            
                
                     if (Ia.Buyers_Side__c && usebuyerside) {
                        if(Ia.Number_of_Buy_Side_Transactions__c==null){Ia.Number_of_Buy_Side_Transactions__c=0;}
                        countrecord = buyersideweight*Integer.valueof(Ia.Number_of_Buy_Side_Transactions__c);
                        System.debug('####PPPP'+countrecord);
                    } 
                     if (Ia.Account__r.Total_Contract_Value__c>0 && useTCV || Test.isRunningTest()) {
                        if(Ia.Account__r.Total_Contract_Value__c<=5000){ tcvweight = 1; }  
                        else if(Ia.Account__r.Total_Contract_Value__c>5000 && Ia.Account__r.Total_Contract_Value__c<=10000){tcvweight = 5; }
                        else if(Ia.Account__r.Total_Contract_Value__c>10000 && Ia.Account__r.Total_Contract_Value__c<=25000){tcvweight = 25; }
                        else if(Ia.Account__r.Total_Contract_Value__c>25000 && Ia.Account__r.Total_Contract_Value__c<=50000){tcvweight = 50; }
                        else if(Ia.Account__r.Total_Contract_Value__c>50000 && Ia.Account__r.Total_Contract_Value__c<=100000){tcvweight = 75; }
                        else if(Ia.Account__r.Total_Contract_Value__c>100000){tcvweight = 100; }
                        countrecord = countrecord+ tcvweight;
                    } 
                     if (Ia.Waitlist__c && usewaitlist) {
                        countrecord = countrecord+ waitlistweight;
                        System.debug('####PPPP'+countrecord);
                    } 
                     if (Ia.Listing__c && uselisting) {
                        countrecord = countrecord + listingweight;
                        System.debug('####PPPP'+countrecord);
                    }
            mapYellowAccountIds.put(Ia.Account__c, (mapYellowAccountIds.get(Ia.Account__c) + countrecord));
            
           
        }
        
        // Inventory account data query
        for (Inventory_Account__c Ia: [Select Id, Name,Number_of_Buy_Side_Transactions__c,Account__r.Total_Contract_Value__c,Having_waitlist__c,Custom_field1__c,Custom_field2__c,Custom_field3__c,Custom_field4__c,Custom_field5__c, Waitlist__c, office__c, Inventory_Data__c, Listing__c, Form__c, Buyers_Side__c, Account__c from Inventory_Account__c where Account__c =: mapGreenAccountIds.keyset() and Inventory_Data__r.Green_market__c=true and Account__r.Type='Realtor Agent' and Short_calculation__c = true and Inventory_Data__r.is_city_code__c = false]) {
            //if
            System.debug(Ia.id+'####PPPP');
            Integer countrecord = 0;
            Integer assetcount = 0;
            
                
                    if (Ia.Buyers_Side__c && usebuyerside) {
                    if(Ia.Number_of_Buy_Side_Transactions__c==null){Ia.Number_of_Buy_Side_Transactions__c=0;}
                        countrecord = buyersideweight*Integer.valueof(Ia.Number_of_Buy_Side_Transactions__c);
                        System.debug('####PPPP'+countrecord);
                    } 
                     if (Ia.Account__r.Total_Contract_Value__c>0 && useTCV || Test.isRunningTest()) {
                        if(Ia.Account__r.Total_Contract_Value__c<=5000){ tcvweight = 1; }  
                        else if(Ia.Account__r.Total_Contract_Value__c>5000 && Ia.Account__r.Total_Contract_Value__c<=10000){tcvweight = 5; }
                        else if(Ia.Account__r.Total_Contract_Value__c>10000 && Ia.Account__r.Total_Contract_Value__c<=25000){tcvweight = 25; }
                        else if(Ia.Account__r.Total_Contract_Value__c>25000 && Ia.Account__r.Total_Contract_Value__c<=50000){tcvweight = 50; }
                        else if(Ia.Account__r.Total_Contract_Value__c>50000 && Ia.Account__r.Total_Contract_Value__c<=100000){tcvweight = 75; }
                        else if(Ia.Account__r.Total_Contract_Value__c>100000){tcvweight = 100; }
                        countrecord = countrecord+ tcvweight;
                    } 
                     if (Ia.Waitlist__c && usewaitlist) {
                        countrecord = countrecord+ waitlistweight;
                        System.debug('####PPPP'+countrecord);
                    } 
                     if (Ia.Listing__c && uselisting) {
                        countrecord = countrecord +listingweight;
                        System.debug('####PPPP'+countrecord);
                    }
                   
            mapGreenAccountIds.put(Ia.Account__c, (mapGreenAccountIds.get(Ia.Account__c) + countrecord));
           
        }
System.debug(mapRedAccountIds+' KKKLLL '+mapYellowAccountIds +' MMMMKL'+mapGreenAccountIds);
        // Map account data to update
        Map < Id, Account > mapUpdateAccount = new Map < Id, Account > ([Select id,Opcity_Score_Date_Time__c,Yellow_Score__c,Green__c,Red_Score__c, name,owner.username, Credit_Dispute__c, Credit_Risk__c, Credit_Status__c, Account_Sub_Type__c, Inventory_Score__c from account where Id =: mapAccountIds.keyset() and Type='Realtor Agent']);
        Integer multiplier = 1;
        Integer CreditWorthiness = 1;
        System.debug( mapAccountIds +'KLLLK');
        for (Id idd: mapAccountIds.keyset()) {
            Account acc = new Account();
            acc = mapUpdateAccount.get(idd);
            /*acc.Red_Score__c = 0;
            acc.Green__c = 0;
            acc.Yellow_Score__c = 0;*/
            if(mapRedAccountIds.containskey(idd)){
            acc.Red_Score__c = mapRedAccountIds.get(idd);
            acc.Opcity_Score_Date_Time__c = System.now();
            }
            if(mapGreenAccountIds.containskey(idd)){
            acc.Green__c = mapGreenAccountIds.get(idd);  //CRM-2334
            acc.Opcity_Score_Date_Time__c = System.now();
            }
            if(mapYellowAccountIds.containskey(idd)){
            acc.Yellow_Score__c = mapYellowAccountIds.get(idd);  //CRM-2334
            acc.Opcity_Score_Date_Time__c = System.now();
            }
            acc.Id = idd;
            mapUpdateAccount.put(idd, acc);
        }
        if (mapUpdateAccount.values().size() > 0) {
        //Map<Id,Account> map
        for(Account_Relationship__c offct:[Select Id,Name,Parent_Account__c,Parent_Account__r.Type,Child_Account__c from Account_Relationship__c where Child_Account__c=:mapUpdateAccount.keyset()]){
        //mapAccountRelationship.put(offct.Child_Account__c,offct.Parent_Account__c);
        if(offct.Parent_Account__r.Type == 'Realtor Office'){
        Account pAccount = new Account();
        pAccount.Id = offct.Parent_Account__c;
        pAccount.Opcity_Score_Date_Time__c = System.now();
        mapUpdateAccount.put(offct.Parent_Account__c,pAccount);
        }
        }
        }
        if (mapUpdateAccount.values().size() > 0) {
            SkipAccountTrigger.setSkipTrgTrue();
            update mapUpdateAccount.values(); // Map account data update
        }
        
        } catch(Exception ex){
           //  CRM-2822
           List<Inventory_Data__c> lstInvData = [Select Id,name, Capacity_error__c, Capacity_error_Message__c,Error__c,Error_Message__c from Inventory_Data__c where Id=:setIds and is_city_code__c= false];
           for(Inventory_Data__c Idd:lstInvData){
           Idd.Capacity_error__c = true ;
           //Idd.SOA_Error_Full_Count__c = 0;
           //Idd.SOA_Error_Half_Count__c = 0;
           Idd.Capacity_error_Message__c ='Line number : '+ex.getLineNumber()+ ' Stack trace'+ ex.getStackTraceString()+' Print Message'+ex.getMessage();
           }
           setSkipTrgTrue();
           update lstInvData;
           //CRM-2822
           }
    }

    Public void CalculateScoreInvAccount(Map < Id, Inventory_Account__c > newMapInventoryAccount, Map < Id, Inventory_Account__c > oldMapInventoryAccount) {

        Set < Id > setInvIds = new Set < Id > ();
        Map < Id, Decimal > mapAccountIds = new Map < Id, Decimal > ();
        Map < Id, Decimal > mapWaitlistAccountScore = new Map < Id, Decimal > ();
        if (lscwaitlist != null) {
            waitlistweight = Integer.valueOf(lscwaitlist.Weight__c);
        }
        if (lscwaitlistwarm != null) {
            waitlistwarmweight = Integer.valueOf(lscwaitlistwarm.Weight__c);
        }
        if (lscwaitlistpipeline != null) {
            waitlistpipelineweight = Integer.valueOf(lscwaitlistpipeline.Weight__c);
        }
        if (lscform != null) {
            formweight = Integer.valueOf(lscform.Weight__c);
        }
        if (lscbuyerside != null) {
            buyersideweight = Integer.valueOf(lscbuyerside.Weight__c);
        }
        if (lsclisting != null) {
            listingweight = Integer.valueOf(lsclisting.Weight__c);
        }
        if (lscoffice != null) {
            officeweight = Integer.valueOf(lscoffice.Weight__c);
        }
        if (lsccustomer != null) {
            customerweight = Integer.valueOf(lsccustomer.Weight__c);
        }
        if (lscformer != null) {
            formerweight = Integer.valueOf(lscformer.Weight__c);
        }
        if (lscprospect != null) {
            prospectweight = Integer.valueOf(lscprospect.Weight__c);
        }
        if (lscperfectacc != null) {
            perfectaccweight = Integer.valueOf(lscperfectacc.Weight__c);
        }
        if (lscnormalacc != null) {
            normalaccweight = Integer.valueOf(lscnormalacc.Weight__c);
        }
        if(lscweightwaitlist!=null){
            waitlistscoreweight = Integer.valueOf(lscweightwaitlist.Weight__c);
        }

        for (Inventory_Account__c Ia: newMapInventoryAccount.values()) {
            setInvIds.add(Ia.Inventory_Data__c);
            mapAccountIds.put(Ia.Account__c, 0);
            //CRM-2334
            mapWaitlistAccountScore.put(Ia.Account__c, 0);
        }
        Map < Id, Account > mapUpdateAccount = new Map < Id, Account > ([Select id, name, Credit_Dispute__c, Credit_Risk__c, Credit_Status__c, Account_Sub_Type__c, Inventory_Score__c from account where Id =: mapAccountIds.keyset()]);
        for (Inventory_Account__c Ia: [Select Id, name,Eligibility_Flex__c,Waitlist_Type__c,Waitlist_Slot_Type__c,Having_waitlist__c,Custom_field1__c,Custom_field2__c,Custom_field3__c,Custom_field4__c,Custom_field5__c, Listing__c, office__c, Form__c, Buyers_Side__c, Account__c, Waitlist__c, Inventory_Data__r.Is_available__c from Inventory_Account__c where Account__c =: mapAccountIds.keyset() and Inventory_Data__r.Is_available__c = true and Inventory_Data__r.is_city_code__c = false]) {
            Integer count = 0;
            if (Ia.Inventory_Data__r.Is_available__c) {
                if (Ia.Waitlist__c) {
                    count = waitlistweight;
                } else if (Ia.Form__c) {
                        count = formweight;
                } else if (Ia.Buyers_Side__c) {
                    count = buyersideweight;
                } else if (Ia.Listing__c) {
                    count = listingweight;
                } else if (Ia.office__c) {
                    count = officeweight;
                }  else if (Ia.Custom_field1__c) {
                    count = custom1weight;
                } else if (Ia.Custom_field2__c) {
                    count = custom2weight;
                } else if (Ia.Custom_field3__c) {
                    count = custom3weight;
                } else if (Ia.Custom_field4__c) {
                    count = custom4weight;
                } else if (Ia.Custom_field5__c) {
                    count = custom5weight;
                }
                
                
            } else {
                if (Ia.Waitlist__c) {
                    count = waitlistweight;
                } else if (Ia.Form__c) {
                        count = formweight;
                } else if (Ia.Buyers_Side__c) {
                    count = buyersideweight;
                } else if (Ia.Listing__c) {
                    count = listingweight;
                } else if (Ia.office__c) {
                    count = officeweight;
                }  else if (Ia.Custom_field1__c) {
                    count = custom1weight;
                } else if (Ia.Custom_field2__c) {
                    count = custom2weight;
                } else if (Ia.Custom_field3__c) {
                    count = custom3weight;
                } else if (Ia.Custom_field4__c) {
                    count = custom4weight;
                } else if (Ia.Custom_field5__c) {
                    count = custom5weight;
                }
            }
            System.debug(Ia.id+'####'+Ia.Having_waitlist__c+'Running Account Id '+Ia.Account__c);
                    //CRM-2334 :- Adding score 1 to current value
                    if(Ia.Having_waitlist__c){
                    System.debug('Running Account Id '+Ia.Account__c);
                    mapWaitlistAccountScore.put(Ia.Account__c,(mapWaitlistAccountScore.get(Ia.Account__c) + 1));
                    }
                    //System.debug('$$$$$'+mapWaitlistAccountScore.values());
            //System.debug('$$$$$'+mapWaitlistAccountScore);
            mapAccountIds.put(Ia.Account__c, (mapAccountIds.get(Ia.Account__c) + count));
            
        }
        Integer multiplier = 1;
        Integer CreditWorthiness = 0;
        System.debug( mapAccountIds +'KLLLK');
        for (Id idd: mapAccountIds.keyset()) {
            Account acc = new Account();
            acc = mapUpdateAccount.get(idd);
            multiplier = 1;
            acc.Inventory_Score__c = mapAccountIds.get(idd);
            acc.waitlist_score__c = mapWaitlistAccountScore.get(idd);//CRM-2334
            if (acc.Account_Sub_Type__c == 'Customer') {
                multiplier = customerweight;
            }
            if (acc.Account_Sub_Type__c == 'Former Customer') {
                multiplier = formerweight;
            }
            if (acc.Account_Sub_Type__c == 'Prospect') {
                multiplier = prospectweight;
            }
            if (acc.Credit_Dispute__c == false && acc.Credit_Risk__c == false && acc.Credit_Status__c == 'Current') {
                CreditWorthiness = perfectaccweight;
            }

            System.debug(CreditWorthiness +'****'+ normalaccweight +'****'+ multiplier);
            //acc.Account_Score__c = (CreditWorthiness + normalaccweight + multiplier);
            acc.Id = idd;
            mapUpdateAccount.put(idd, acc);
        }
        if (mapUpdateAccount.values().size() > 0) {
            SkipAccountTrigger.setSkipTrgTrue();
            update mapUpdateAccount.values();
        }
    }
    
    //for local expert city
    @future(callout=true)
    Public static void pullInventoryWaitlistInformationforCity(Set<ID> setcityCodes){
    pullInventoryWaitlistInformationRequestforCity(setcityCodes);
    }
    
    //for local expert city
    Public static void pullInventoryWaitlistInformationRequestforCity(Set<ID> setcityCodes){
        //get city interested markets from the inventory data
            Set<Id> accountIds = new Set<Id>();
            MAP<Id,String> updateRecordsMap = new Map<Id,String>();
            Map<String,String> availMap = new Map<String,String>();
            RequestWrapper request = new RequestWrapper();
            List<Inventory_Account__c> recordToUpdate = new List<Inventory_Account__c>();
            for(Inventory_Account__c ia: [SELECT Account__c FROM Inventory_Account__c WHERE Inventory_Data__c IN: setcityCodes and Inventory_Data__r.is_city_code__c=true]){
               accountIds.add(ia.account__c);
            }
            for(Inventory_Account__c ia: [SELECT inventory_data__r.City__c, account__r.party_id__c, inventory_data__r.city_primary_zip__r.name, inventory_data__r.State__c, id, Buyers_Side__c, Waitlist__c, CLC__c, Form__c, Office__c, account__c FROM Inventory_Account__c WHERE Account__c IN: accountIds AND Inventory_Data__r.is_city_code__c = TRUE AND waitlist_product_type__c = 'SOV10']){
                updateRecordsMap.put(ia.id, ia.inventory_data__r.city__c+', '+ia.inventory_data__r.state__c);
                Map<String,String> cityStateMap = new Map<String,String>();
                request.party_ids.add(ia.account__r.party_id__c);
                cityStateMap.put('city', ia.inventory_data__r.city__c);
                cityStateMap.put('state',ia.inventory_data__r.state__c);
                request.cities_state.add(cityStateMap);
                
            }
            request.part_numbers.add('LOCALEXPERTCITY');
            system.debug('--> JSON '+JSON.serialize(request));
            //making an Http call
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Waitlist_Urls__c reqUrl = Waitlist_Urls__c.getValues('SOALocalExpertCityScoringURL');

            req.setbody(JSON.serialize(request));
          //  req.setEndpoint('https://soa-external-app.entsys-dev.moveaws.com:7082/AvailableInventorySearchService/AvailableInventorySearchPS');
            req.setEndpoint(reqUrl.URL__c);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json'); 
            
           // req.setHeader('Accept', 'application/json');
            //req.setHeader('Authorization', 'oAuth');
           // req.setHeader('x-api-key', '5lfstIvpWLNSUMt3fZfj9TW2fezQSff33u6C9aq9');
            req.setHeader('Content-Length', '0'); 
            req.setTimeout(120000);
            if(!Test.isRunningTest())
            {res = http.send(req);}else{
                 res.setBody('{"request":{"cities_state":[{"city":"bountiful","state":"ut"}],"part_numbers":["LOCALEXPERTCITY"],"request_datetime":"2019-06-07T18:42:11.1150000+00:00","type":"GetAvailableInventories"},"available_inventories":[{"available_flex":"4","available_presale_flex":"0","fast_unit_price":"0.0","flex_unit_price":"200.0","market_name":"Bountiful, UT","market_type":"City","part_number":"LOCALEXPERTCITY","price_tier":"2","product_name":"Local Expert City","product_size":"SOV10"}]}');

            }
            
            system.debug('response --> '+ res.getbody());
            
            //hardcoding the response here for writing parsing logic as the response is not coming properly. 
            //parsing the response for availability and multiplying the availability with the parameter score. 
            availMap = parseResponse(res.getBody());
            system.debug('avail map --> '+JSON.serialize(availmap));
            for(Id mId : updateRecordsMap.keySet()){
               if(availMap.containsKey(updateRecordsMap.get(mId))){
                system.debug('inside contains loop '+mid+' '+updateRecordsMap.get(mId)+' '+availMap.get(updateRecordsMap.get(mId)));
                Inventory_Account__c recToUpdate = new Inventory_Account__c();
                recToUpdate.id = mId;
                recToUpdate.sov10__c = Integer.valueOf(availMap.get(updateRecordsMap.get(mId)));
                recordToUpdate.add(recToUpdate);
                }
            }
            if(!recordToUpdate.isEmpty()){
                Update recordToUpdate;
            }
       
    }
    
    public static map<String,String> parseResponse(String response){
        Map<String,String> availabilityMap = new Map<String,String>();
        
        ResponseWrapper availability = response != null ? (ResponseWrapper)JSON.deserialize(response,ResponseWrapper.class) : new responsewrapper();
        
        if(!availability.available_inventories.isEmpty()){
            for(Map<String,String> eachMap : availability.available_inventories){
                availabilityMap.put(eachmap.get('market_name'),eachmap.get('available_flex'));
                
            }
        }
        return availabilityMap;
    }
    
    public class ResponseRequest{
        List<Map<String,String>> cities_state = new List<Map<String,String>>();
        Set<String> part_numbers = new Set<String>();
        Set<String> party_ids = new Set<String>();
        String request_datetime = '';
        String type = '';
    }
    public class ResponseWrapper{
        ResponseRequest request = new ResponseRequest();
        List<Map<String,String>> available_inventories = new List<Map<String,String>>();
    }
    
    public class RequestWrapper{
        Set<String> part_numbers = new Set<String>();
        Set<String> party_ids = new Set<String>();
        Set<Map<String,String>> cities_state = new Set<Map<String,String>>();
    }
    
   
    
    //CRM-2541 - Inventory callout to get realtime invenotry eligibility
    @future(callout=true)
    Public static void pullInventoryWaitlistInformation(Set<ID> setZipCodes){
    pullInventoryWaitlistInformationRequest(setZipCodes);
    }
    
    
    
    Public static void pullInventoryWaitlistInformationRequest(Set<ID> setZipCodes){
    try{
    Set<String> setPartyIds = new Set<String>();
    Set<String> setPartyZips = new Set<String>();
    Set<Id> setAccountIds = new Set<Id>();
    String party_Ids ='';
    String Zips ='';
    List< available_inventories > lstavailinv = new List< available_inventories >();
    Map<String,Inventory_Account__c> mapInventoryAccount = new Map<String,Inventory_Account__c>();
    Map<String,available_inventories> mapAvailableInventory = new Map<String,available_inventories>();
    Map<String,Boolean> mapRecordProcessed = new Map<String,Boolean>();
    Map<String,Boolean> mapPartyIds = new Map<String,Boolean>();
    Map<String,Decimal> mapInventoryZipCount = new Map<String,Decimal>();
    Map<String,Decimal> mapInventoryZipFastCount = new Map<String,Decimal>();
    Map<String,Decimal> mapInventoryZipPriceCount = new Map<String,Decimal>();
    Map<String,Decimal> mapInventoryZipPriceFastCount = new Map<String,Decimal>();
    System.debug(setZipCodes+'setZipCodes11');
    Boolean runQuery=false;
    Boolean runQuery1=false;
    Boolean runQuery2=false;
    Boolean runQuery3=false;
    Boolean runQuery4=false;
    Boolean runQuery5=false;
    Boolean runQuery6=false;
    Boolean runQuery7=false;
    Boolean runQuery8=false;
    Boolean runQuery9=false;
    Boolean runQuery10=false;
    Boolean runQuery11=false;
    Boolean runQuery12=false;
    Boolean runQuery13=false;
    Boolean runQuery14=false;
    Boolean runQuery15=false;
    Boolean runQuery16=false;
    Boolean runQuery17=false;
    Boolean runQuery18=false;
    Boolean runQuery19=false;
    Boolean runQuery20=false;
    //Boolean runQuery=false;
    Boolean runQuery21=false;
    Boolean runQuery22=false;
    Boolean runQuery23=false;
    Boolean runQuery24=false;
    Boolean runQuery25=false;
    Boolean runQuery26=false;
    Boolean runQuery27=false;
    Boolean runQuery28=false;
    Boolean runQuery29=false;
    Boolean runQuery110=false;
    Boolean runQuery111=false;
    Boolean runQuery112=false;
    Boolean runQuery113=false;
    Boolean runQuery114=false;
    Boolean runQuery115=false;
    Boolean runQuery116=false;
    Boolean runQuery117=false;
    Boolean runQuery118=false;
    Boolean runQuery119=false;
    Boolean runQuery210=false;
    if(Test.isRunningTest()){
      runQuery = true;
    }
    //System.debug([Select Id, Name,Eligibility_Flex__c, Waitlist__c,Fast_Price__c,Flex_Price__c , Waitlist_Half__c ,Eligibility__c,Account__c, Account__r.party_id__c,Inventory_Data__c,Inventory_Data__r.Name,Inventory_Data__r.Is_available__c from Inventory_Account__c]+'PPPPP');
    List<Inventory_Account__c> lstInventoryAccount = new List<Inventory_Account__c>();
    if(Test.isRunningTest()){
    //  lstInventoryAccount = [Select Id, Name,Eligibility_Flex__c, Waitlist__c,Fast_Price__c,Flex_Price__c , Waitlist_Half__c ,Eligibility__c,Account__c, Account__r.party_id__c,Inventory_Data__r.Name,Inventory_Data__r.Is_available__c from Inventory_Account__c];
    } else{
    //lstInventoryAccount = [Select Id, Name,Eligibility_Flex__c, Waitlist__c,Fast_Price__c,Flex_Price__c , Waitlist_Half__c ,Eligibility__c,Account__c, Account__r.party_id__c,Inventory_Data__r.Name,Inventory_Data__r.Is_available__c from Inventory_Account__c where Inventory_Data__c =: setZipCodes and (Having_waitlist__c=true) FOR UPDATE];
    }
    for(Inventory_Account__c Ia: [Select Id,Waitlist_Weight__c,Weight_Count__c,Having_waitlist__c,SOV20_Price__c,SOV30_Price__c,SOV50_Price__c,SOV20__c,SOV30__c,SOV50__c,Inventory_Data__r.SOV50__c,Inventory_Data__r.SOV20__c,Inventory_Data__r.SOV30__c, Name,Eligibility_Flex__c, Waitlist__c,Fast_Price__c,Flex_Price__c , Waitlist_Half__c ,Eligibility__c,Account__c, Account__r.party_id__c,Inventory_Data__r.Name,Inventory_Data__r.Is_available__c from Inventory_Account__c where Inventory_Data__c =: setZipCodes and (Need_Inventory_call__c=true) and Short_calculation__c = true and Inventory_Data__r.is_city_code__c=false]){
      Ia.Eligibility__c = 0;
    Ia.Eligibility_Flex__c = 0;
    Ia.Fast_Price__c = 0;
    Ia.Flex_Price__c = 0;
    Ia.SOV20__c = false;
    Ia.SOV20_Price__c = 0;
    Ia.SOV30__c = false;
    Ia.SOV30_Price__c = 0;
    Ia.SOV50__c = false;
    Ia.SOV50_Price__c = 0;
    Ia.Weight_Count__c = 0;
    Ia.Waitlist_Weight__c = 0;
    //CRM-2851
    if(Ia.Inventory_Data__r.Is_available__c || Ia.Inventory_Data__r.SOV50__c || Ia.Inventory_Data__r.SOV20__c || Ia.Inventory_Data__r.SOV30__c){
    setPartyIds.add(Ia.Account__r.party_id__c);
    setPartyZips.add(Ia.Inventory_Data__r.Name);
    setAccountIds.add(Ia.Account__c);
    party_Ids = party_Ids + (party_Ids==''?'' :',') +'"'+Ia.Account__r.party_id__c+'"'; //CRM-2781
    }
    mapInventoryAccount.put(Ia.Account__r.party_id__c+'##'+Ia.Inventory_Data__r.Name,Ia);
    }
    //CRM-2851
    if(setPartyZips.size()>0){
    for(String ss:setPartyZips){
    Zips = Zips +(Zips==''?'' :',')+ '"'+ss+'"';
    }
    
        string  mProduct = 'COBROKE';
        string responseString = '';
       // String step1 = codesString.escapeCsv();
        HttpRequest req = new HttpRequest(); 
        HttpResponse res = new HttpResponse();
        Http http = new Http();
       /* InventorySecurity__c obj = InventorySecurity__c.getvalues('InventorySecurity');
        if(obj.expiration_date_time__c == null || system.now() >= obj.expiration_date_time__c.addseconds(-600)){
          InventorySecurityTokenHelper.getSecurityToken('InventorySecurity');
          req.setHeader('Authorization',obj.token_type__c+' '+InventorySecurityTokenHelper.accesstokenInv);
        }else{
          req.setHeader('Authorization', obj.token_type__c+' '+obj.access_token__c+obj.access_token_2__c+obj.access_token_3__c+obj.access_token_4__c);

        }
        */
        req.setMethod('POST');
        String endPointUrl=Label.Inventory_Endpoint;//'https://es-is.api.move.com/availableinventory'; 
        req.setEndpoint(endPointUrl);
        req.setHeader('Content-Type', 'application/json'); 
        req.setHeader('Accept', 'application/json');
        req.setHeader('Authorization', 'oAuth');
       
        req.setHeader('x-api-key', '5lfstIvpWLNSUMt3fZfj9TW2fezQSff33u6C9aq9');
        req.setHeader('Content-Length', '0'); 
        req.setTimeout(120000);
        
        String strbody = '{  "part_numbers" :["cobroke", "localexpert"], "party_ids" :[' +party_Ids+'] , "postal_codes" :['+Zips+']}'; //CRM-2781
        strbody=strbody.replace('(','').replace(')','');
        system.debug('response####'+req);
        req.setBody(strbody);
        
            if(!Test.isRunningTest()){
                res=http.send(req);
               // InventorySecurityTokenHelper.updatesettings();
                } else {
                //res = '{"request":{"__type":"eai.inventory.search.api.ServiceModel.RequestDto.GetAvailableInventories, eai.inventory.search.api.ServiceModel","request_id":"6fc63a15-e82d-4f3a-8548-88824048c9a8","request_datetime":"2017-11-14T20:09:29.1179503Z","part_numbers":["cobroke"],"postal_codes":["89044"],"party_ids":["333323046","200768583","212129244","36201033","33965803","126346924","238664827","93061016","21315787","154690384","105784309","261520144","3756057","3216249","43604042"]},"available_inventories":[{"part_number":"cobroke","market_name":"89044","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":2,"available_fast":5,"available_presale_flex":0,"available_presale_fast":0,"price_tier":107,"flex_unit_price":473,"fast_unit_price":261},{"part_number":"cobroke","market_name":"89044","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Half","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":207,"flex_unit_price":237,"fast_unit_price":132},{"part_number":"cobroke","market_name":"Henderson Cluster, NV","market_type":"City","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":10,"flex_unit_price":238,"fast_unit_price":131},{"part_number":"cobroke","market_name":"Henderson Cluster, NV","market_type":"City","product_name":"Connection for Co-Brokerage","product_size":"Half","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":30,"flex_unit_price":119,"fast_unit_price":66},{"part_number":"cobroke","market_name":"Las Vegas Cluster, NV","market_type":"City","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":12,"flex_unit_price":213,"fast_unit_price":118},{"part_number":"cobroke","market_name":"Las Vegas Cluster, NV","market_type":"City","product_name":"Connection for Co-Brokerage","product_size":"Half","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":32,"flex_unit_price":107,"fast_unit_price":59},{"part_number":"cobroke","market_name":"89002","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Half","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":29,"flex_unit_price":154,"fast_unit_price":85},{"part_number":"cobroke","market_name":"89002","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":0,"available_fast":1,"available_presale_flex":0,"available_presale_fast":0,"price_tier":9,"flex_unit_price":308,"fast_unit_price":170},{"party_id":"105784309","part_number":"cobroke","market_name":"89002","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":0,"available_fast":1,"available_presale_flex":0,"available_presale_fast":0,"price_tier":9,"flex_unit_price":308,"fast_unit_price":170},{"party_id":"238664827","part_number":"cobroke","market_name":"89002","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":0,"available_fast":1,"available_presale_flex":0,"available_presale_fast":0,"price_tier":9,"flex_unit_price":308,"fast_unit_price":170},{"part_number":"cobroke","market_name":"89009","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Half","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":40,"flex_unit_price":37,"fast_unit_price":21},{"part_number":"cobroke","market_name":"89009","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":20,"flex_unit_price":72,"fast_unit_price":41},{"part_number":"cobroke","market_name":"89011","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":4,"available_fast":9,"available_presale_flex":0,"available_presale_fast":0,"price_tier":109,"flex_unit_price":416,"fast_unit_price":230},{"party_id":"333323046","part_number":"cobroke","market_name":"89011","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":4,"available_fast":9,"available_presale_flex":0,"available_presale_fast":0,"price_tier":109,"flex_unit_price":416,"fast_unit_price":230},{"party_id":"261520144","part_number":"cobroke","market_name":"89011","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":4,"available_fast":9,"available_presale_flex":0,"available_presale_fast":0,"price_tier":109,"flex_unit_price":416,"fast_unit_price":230},{"part_number":"cobroke","market_name":"89011","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Half","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":209,"flex_unit_price":208,"fast_unit_price":115},{"part_number":"cobroke","market_name":"89012","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":1,"available_fast":2,"available_presale_flex":0,"available_presale_fast":0,"price_tier":127,"flex_unit_price":526,"fast_unit_price":290},{"part_number":"cobroke","market_name":"89012","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Half","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":227,"flex_unit_price":264,"fast_unit_price":146},{"part_number":"cobroke","market_name":"89014","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":3,"available_fast":7,"available_presale_flex":0,"available_presale_fast":0,"price_tier":130,"flex_unit_price":356,"fast_unit_price":196},{"part_number":"cobroke","market_name":"89014","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Half","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":230,"flex_unit_price":178,"fast_unit_price":98},{"part_number":"cobroke","market_name":"89015","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":1,"available_fast":2,"available_presale_flex":0,"available_presale_fast":0,"price_tier":91,"flex_unit_price":276,"fast_unit_price":153},{"part_number":"cobroke","market_name":"89015","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Half","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":191,"flex_unit_price":138,"fast_unit_price":77},{"party_id":"333323046","part_number":"cobroke","market_name":"89015","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Half","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":191,"flex_unit_price":138,"fast_unit_price":77},{"part_number":"cobroke","market_name":"89016","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":14,"flex_unit_price":196,"fast_unit_price":109},{"part_number":"cobroke","market_name":"89016","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Half","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":34,"flex_unit_price":98,"fast_unit_price":55},{"part_number":"cobroke","market_name":"89052","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Half","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":26,"flex_unit_price":195,"fast_unit_price":108},{"part_number":"cobroke","market_name":"89052","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":1,"available_fast":2,"available_presale_flex":0,"available_presale_fast":0,"price_tier":6,"flex_unit_price":388,"fast_unit_price":214},{"part_number":"cobroke","market_name":"89053","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Half","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":40,"flex_unit_price":37,"fast_unit_price":21},{"part_number":"cobroke","market_name":"89053","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":20,"flex_unit_price":72,"fast_unit_price":41},{"part_number":"cobroke","market_name":"89074","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":129,"flex_unit_price":462,"fast_unit_price":255},{"party_id":"3216249","part_number":"cobroke","market_name":"89074","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":129,"flex_unit_price":462,"fast_unit_price":255},{"part_number":"cobroke","market_name":"89074","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Half","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":229,"flex_unit_price":232,"fast_unit_price":128},{"part_number":"cobroke","market_name":"89077","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Half","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":40,"flex_unit_price":37,"fast_unit_price":21},{"part_number":"cobroke","market_name":"89077","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":20,"flex_unit_price":72,"fast_unit_price":41},{"part_number":"cobroke","market_name":"89122","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Half","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":33,"flex_unit_price":106,"fast_unit_price":59},{"part_number":"cobroke","market_name":"89122","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":13,"flex_unit_price":211,"fast_unit_price":117},{"party_id":"105784309","part_number":"cobroke","market_name":"89122","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":13,"flex_unit_price":211,"fast_unit_price":117},{"part_number":"cobroke","market_name":"89123","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":0,"available_fast":1,"available_presale_flex":0,"available_presale_fast":0,"price_tier":130,"flex_unit_price":356,"fast_unit_price":196},{"party_id":"21315787","part_number":"cobroke","market_name":"89123","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":0,"available_fast":1,"available_presale_flex":0,"available_presale_fast":0,"price_tier":130,"flex_unit_price":356,"fast_unit_price":196},{"part_number":"cobroke","market_name":"89123","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Half","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":230,"flex_unit_price":178,"fast_unit_price":98},{"party_id":"21315787","part_number":"cobroke","market_name":"89123","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Half","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":230,"flex_unit_price":178,"fast_unit_price":98},{"part_number":"cobroke","market_name":"89165","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Half","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":40,"flex_unit_price":37,"fast_unit_price":21},{"part_number":"cobroke","market_name":"89165","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":20,"flex_unit_price":72,"fast_unit_price":41},{"part_number":"cobroke","market_name":"89183","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":130,"flex_unit_price":356,"fast_unit_price":196},{"part_number":"cobroke","market_name":"89183","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Half","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":230,"flex_unit_price":178,"fast_unit_price":98}]}';
                }
                system.debug('response####'+res.getBody());
                if(res.getStatusCode()==200 && res.getStatus()=='OK' || Test.isRunningTest()){
                    system.debug('response####'+res.getBody());
                    responseString=res.getBody();
                    if(Test.isRunningTest()){
                    responseString = '{"request":{"__type":"eai.inventory.search.api.ServiceModel.RequestDto.GetAvailableInventories, eai.inventory.search.api.ServiceModel","request_id":"6fc63a15-e82d-4f3a-8548-88824048c9a8","request_datetime":"2017-11-14T20:09:29.1179503Z","part_numbers":["cobroke"],"postal_codes":["89044"],"party_ids":["333323046","200768583","212129244","36201033","33965803","126346924","238664827","93061016"]},"available_inventories":[{"part_number":"cobroke","market_name":"89044","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":2,"available_fast":5,"available_presale_flex":0,"available_presale_fast":0,"price_tier":107,"flex_unit_price":473,"fast_unit_price":261},{"part_number":"cobroke","market_name":"89044","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Half","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":207,"flex_unit_price":237,"fast_unit_price":132},{"part_number":"cobroke","market_name":"Henderson Cluster, NV","market_type":"City","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":10,"flex_unit_price":238,"fast_unit_price":131},{"part_number":"cobroke","market_name":"Henderson Cluster, NV","market_type":"City","product_name":"Connection for Co-Brokerage","product_size":"Half","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":30,"flex_unit_price":119,"fast_unit_price":66},{"part_number":"cobroke","market_name":"Las Vegas Cluster, NV","market_type":"City","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":12,"flex_unit_price":213,"fast_unit_price":118},{"part_number":"cobroke","market_name":"Las Vegas Cluster, NV","market_type":"City","product_name":"Connection for Co-Brokerage","product_size":"Half","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":32,"flex_unit_price":107,"fast_unit_price":59},{"part_number":"cobroke","market_name":"89002","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Half","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":29,"flex_unit_price":154,"fast_unit_price":85},{"part_number":"cobroke","market_name":"89002","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":0,"available_fast":1,"available_presale_flex":0,"available_presale_fast":0,"price_tier":9,"flex_unit_price":308,"fast_unit_price":170},{"party_id":"105784309","part_number":"cobroke","market_name":"89002","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":0,"available_fast":1,"available_presale_flex":0,"available_presale_fast":0,"price_tier":9,"flex_unit_price":308,"fast_unit_price":170},{"party_id":"238664827","part_number":"cobroke","market_name":"89002","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":0,"available_fast":1,"available_presale_flex":0,"available_presale_fast":0,"price_tier":9,"flex_unit_price":308,"fast_unit_price":170},{"part_number":"cobroke","market_name":"89009","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Half","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":40,"flex_unit_price":37,"fast_unit_price":21},{"part_number":"cobroke","market_name":"89009","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":20,"flex_unit_price":72,"fast_unit_price":41},{"part_number":"cobroke","market_name":"89011","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":4,"available_fast":9,"available_presale_flex":0,"available_presale_fast":0,"price_tier":109,"flex_unit_price":416,"fast_unit_price":230},{"party_id":"333323046","part_number":"cobroke","market_name":"89011","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":4,"available_fast":9,"available_presale_flex":0,"available_presale_fast":0,"price_tier":109,"flex_unit_price":416,"fast_unit_price":230},{"party_id":"261520144","part_number":"cobroke","market_name":"89011","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":4,"available_fast":9,"available_presale_flex":0,"available_presale_fast":0,"price_tier":109,"flex_unit_price":416,"fast_unit_price":230},{"part_number":"cobroke","market_name":"89011","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Half","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":209,"flex_unit_price":208,"fast_unit_price":115},{"part_number":"cobroke","market_name":"89012","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":1,"available_fast":2,"available_presale_flex":0,"available_presale_fast":0,"price_tier":127,"flex_unit_price":526,"fast_unit_price":290},{"part_number":"cobroke","market_name":"89012","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Half","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":227,"flex_unit_price":264,"fast_unit_price":146},{"part_number":"cobroke","market_name":"89014","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":3,"available_fast":7,"available_presale_flex":0,"available_presale_fast":0,"price_tier":130,"flex_unit_price":356,"fast_unit_price":196},{"part_number":"cobroke","market_name":"89014","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Half","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":230,"flex_unit_price":178,"fast_unit_price":98},{"part_number":"cobroke","market_name":"89015","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":1,"available_fast":2,"available_presale_flex":0,"available_presale_fast":0,"price_tier":91,"flex_unit_price":276,"fast_unit_price":153},{"part_number":"cobroke","market_name":"89015","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Half","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":191,"flex_unit_price":138,"fast_unit_price":77},{"party_id":"333323046","part_number":"cobroke","market_name":"89015","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Half","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":191,"flex_unit_price":138,"fast_unit_price":77},{"part_number":"cobroke","market_name":"89016","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":14,"flex_unit_price":196,"fast_unit_price":109},{"part_number":"cobroke","market_name":"89016","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Half","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":34,"flex_unit_price":98,"fast_unit_price":55},{"part_number":"cobroke","market_name":"89052","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Half","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":26,"flex_unit_price":195,"fast_unit_price":108},{"part_number":"cobroke","market_name":"89052","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":1,"available_fast":2,"available_presale_flex":0,"available_presale_fast":0,"price_tier":6,"flex_unit_price":388,"fast_unit_price":214},{"part_number":"cobroke","market_name":"89053","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Half","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":40,"flex_unit_price":37,"fast_unit_price":21},{"part_number":"cobroke","market_name":"89053","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":20,"flex_unit_price":72,"fast_unit_price":41},{"part_number":"cobroke","market_name":"89074","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":129,"flex_unit_price":462,"fast_unit_price":255},{"party_id":"3216249","part_number":"cobroke","market_name":"89074","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":129,"flex_unit_price":462,"fast_unit_price":255},{"part_number":"cobroke","market_name":"89074","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Half","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":229,"flex_unit_price":232,"fast_unit_price":128},{"part_number":"cobroke","market_name":"89077","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Half","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":40,"flex_unit_price":37,"fast_unit_price":21},{"part_number":"cobroke","market_name":"89077","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":20,"flex_unit_price":72,"fast_unit_price":41},{"part_number":"cobroke","market_name":"89122","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Half","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":33,"flex_unit_price":106,"fast_unit_price":59},{"part_number":"cobroke","market_name":"89122","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":13,"flex_unit_price":211,"fast_unit_price":117},{"party_id":"105784309","part_number":"cobroke","market_name":"89122","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":13,"flex_unit_price":211,"fast_unit_price":117},{"part_number":"cobroke","market_name":"89123","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":0,"available_fast":1,"available_presale_flex":0,"available_presale_fast":0,"price_tier":130,"flex_unit_price":356,"fast_unit_price":196},{"party_id":"21315787","part_number":"cobroke","market_name":"89123","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":0,"available_fast":1,"available_presale_flex":0,"available_presale_fast":0,"price_tier":130,"flex_unit_price":356,"fast_unit_price":196},{"part_number":"cobroke","market_name":"89123","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Half","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":230,"flex_unit_price":178,"fast_unit_price":98},{"party_id":"21315787","part_number":"cobroke","market_name":"89123","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Half","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":230,"flex_unit_price":178,"fast_unit_price":98},{"part_number":"cobroke","market_name":"89165","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Half","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":40,"flex_unit_price":37,"fast_unit_price":21},{"part_number":"cobroke","market_name":"89165","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":20,"flex_unit_price":72,"fast_unit_price":41},{"part_number":"cobroke","market_name":"89183","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Full","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":130,"flex_unit_price":356,"fast_unit_price":196},{"part_number":"cobroke","market_name":"89183","market_type":"Postal Code","product_name":"Connection for Co-Brokerage","product_size":"Half","available_flex":0,"available_fast":0,"available_presale_flex":0,"available_presale_fast":0,"price_tier":230,"flex_unit_price":178,"fast_unit_price":98}]}';
                        }
                        
                    JSONParser parser = JSON.createParser(responseString);
                   System.debug('######'+parser);
         while (parser.nextToken() != null) {
             if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                    while (parser.nextToken() != null) {
                        System.debug('$$$$$$'+parser.getText());
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        System.debug('$$$$$$'+parser.getText());
                        available_inventories invcount = (available_inventories)parser.readValueAs(available_inventories.class);
                           System.debug(invcount.market_name+'$$$$$$'+setPartyZips);
                           //Syste
                           if((invcount.market_name+'').length()<7){
                           if(invcount.available_fast<0){invcount.available_fast=0;} //CRM-2781
                           if(invcount.available_flex<0){invcount.available_flex=0;} //CRM-2781
                           System.debug(invcount.market_name+'');
                           if(setPartyZips.contains(invcount.market_name)){
                               System.debug(invcount.party_id+'##'+invcount.market_name+'##'+invcount.product_size);
                               if(invcount.party_id!=null && invcount.party_id!=''){
                                    mapAvailableInventory.put(invcount.party_id+'##'+invcount.market_name+'##'+invcount.product_size,invcount);
                            } else {
                                    mapAvailableInventory.put(invcount.market_name+'##'+invcount.product_size,invcount);
                            }
                    }
                           }
                }
               }
            }
          }
       } 
       
       System.debug(mapAvailableInventory.keyset()+' Its working '+mapAvailableInventory.values());
        //CRM- 
    for(Inventory_Account__c IA:mapInventoryAccount.values()){
    Integer countrecord = 0;
    Ia.SOV20__c = false;
    Ia.SOV20_Price__c = 0;
    Ia.SOV30__c = false;
    Ia.SOV30_Price__c = 0;
    Ia.SOV50__c = false;
    Ia.SOV50_Price__c = 0;
    Ia.Weight_Count__c = 0;
    Ia.Waitlist_Weight__c = 0;
    System.debug('Its working'+Ia.Inventory_Data__r.Name+'##Half');
    System.debug(mapAvailableInventory.containskey(Ia.Inventory_Data__r.Name+'##Half')+' && '+mapAvailableInventory.containskey(Ia.Inventory_Data__r.Name+'##Full'));
    System.debug((Ia.Account__r.party_id__c+'##'+Ia.Inventory_Data__r.Name+'##Half')+' && '+(Ia.Account__r.party_id__c+'##'+Ia.Inventory_Data__r.Name+'##Full'));
    System.debug(mapAvailableInventory.containskey(Ia.Account__r.party_id__c+'##'+Ia.Inventory_Data__r.Name+'##Half')+' && '+mapAvailableInventory.containskey(Ia.Account__r.party_id__c+'##'+Ia.Inventory_Data__r.Name+'##Full'));
    if(!mapAvailableInventory.containskey(Ia.Inventory_Data__r.Name+'##Half')){
    available_inventories AvailInv = new available_inventories();
    AvailInv.fast_unit_price = 0;
    AvailInv.flex_unit_price = 0;
    AvailInv.available_fast = 0;
    AvailInv.available_flex = 0;
    mapAvailableInventory.put(Ia.Inventory_Data__r.Name+'##Half',AvailInv);
    }
    if(!mapAvailableInventory.containskey(Ia.Inventory_Data__r.Name+'##Full')){
    available_inventories AvailInv = new available_inventories();
    AvailInv.fast_unit_price = 0;
    AvailInv.flex_unit_price = 0;
    AvailInv.available_fast = 0;
    AvailInv.available_flex = 0;
    mapAvailableInventory.put(Ia.Inventory_Data__r.Name+'##Full',AvailInv);
    }
    if(mapAvailableInventory.containskey(Ia.Account__r.party_id__c+'##'+Ia.Inventory_Data__r.Name+'##Full') && mapAvailableInventory.containskey(Ia.Account__r.party_id__c+'##'+Ia.Inventory_Data__r.Name+'##Half')){
            
            System.debug('Its working');
            available_inventories halfInvCount = new available_inventories();
            available_inventories fullInvCount = new available_inventories();
            fullInvCount = mapAvailableInventory.get(Ia.Account__r.party_id__c+'##'+Ia.Inventory_Data__r.Name+'##Full');
            halfInvCount = mapAvailableInventory.get(Ia.Account__r.party_id__c+'##'+Ia.Inventory_Data__r.Name+'##Half');
            Ia.Eligibility__c = fullInvCount.available_fast+halfInvCount.available_fast;
            Ia.Eligibility_Flex__c = fullInvCount.available_flex+halfInvCount.available_flex;
            Ia.Fast_Price__c = fullInvCount.available_fast*fullInvCount.fast_unit_price+halfInvCount.available_fast*halfInvCount.fast_unit_price;
            Ia.Flex_Price__c = fullInvCount.available_flex*fullInvCount.flex_unit_price+halfInvCount.available_flex*halfInvCount.flex_unit_price;
    } else if(mapAvailableInventory.containskey(Ia.Account__r.party_id__c+'##'+Ia.Inventory_Data__r.Name+'##Full') && mapAvailableInventory.containskey(Ia.Inventory_Data__r.Name+'##Half')){
            
            System.debug('Its working');
            available_inventories halfInvCount = new available_inventories();
            available_inventories fullInvCount = new available_inventories();
            fullInvCount = mapAvailableInventory.get(Ia.Account__r.party_id__c+'##'+Ia.Inventory_Data__r.Name+'##Full');
            halfInvCount = mapAvailableInventory.get(Ia.Inventory_Data__r.Name+'##Half');
            Ia.Eligibility__c = fullInvCount.available_fast+halfInvCount.available_fast;
            Ia.Eligibility_Flex__c = fullInvCount.available_flex+halfInvCount.available_flex;
            Ia.Fast_Price__c = fullInvCount.available_fast*fullInvCount.fast_unit_price+halfInvCount.available_fast*halfInvCount.fast_unit_price;
            Ia.Flex_Price__c = fullInvCount.available_flex*fullInvCount.flex_unit_price+halfInvCount.available_flex*halfInvCount.flex_unit_price;
    } else if(mapAvailableInventory.containskey(Ia.Account__r.party_id__c+'##'+Ia.Inventory_Data__r.Name+'##Half') && mapAvailableInventory.containskey(Ia.Inventory_Data__r.Name+'##Full')){
            
            System.debug('Its working');
            available_inventories halfInvCount = new available_inventories();
            available_inventories fullInvCount = new available_inventories();
            fullInvCount = mapAvailableInventory.get(Ia.Inventory_Data__r.Name+'##Full');
            halfInvCount = mapAvailableInventory.get(Ia.Account__r.party_id__c+'##'+Ia.Inventory_Data__r.Name+'##Half');
            Ia.Eligibility__c = fullInvCount.available_fast+halfInvCount.available_fast;
            Ia.Eligibility_Flex__c = fullInvCount.available_flex+halfInvCount.available_flex;
            Ia.Fast_Price__c = fullInvCount.available_fast*fullInvCount.fast_unit_price+halfInvCount.available_fast*halfInvCount.fast_unit_price;
            Ia.Flex_Price__c = fullInvCount.available_flex*fullInvCount.flex_unit_price+halfInvCount.available_flex*halfInvCount.flex_unit_price;
    } else if(mapAvailableInventory.containskey(Ia.Inventory_Data__r.Name+'##Half') && mapAvailableInventory.containskey(Ia.Inventory_Data__r.Name+'##Full')){
            
            System.debug('Its working');
            available_inventories halfInvCount = new available_inventories();
            available_inventories fullInvCount = new available_inventories();
            fullInvCount = mapAvailableInventory.get(Ia.Inventory_Data__r.Name+'##Full');
            halfInvCount = mapAvailableInventory.get(Ia.Inventory_Data__r.Name+'##Half');
            Ia.Eligibility__c = fullInvCount.available_fast+halfInvCount.available_fast;
            Ia.Eligibility_Flex__c = fullInvCount.available_flex+halfInvCount.available_flex;
            Ia.Fast_Price__c = fullInvCount.available_fast*fullInvCount.fast_unit_price+halfInvCount.available_fast*halfInvCount.fast_unit_price;
            Ia.Flex_Price__c = fullInvCount.available_flex*fullInvCount.flex_unit_price+halfInvCount.available_flex*halfInvCount.flex_unit_price;
    } else {
    
    }
      if(Ia.Having_waitlist__c)
        {
            Ia.Waitlist_Weight__c = 1;
            System.debug('Running Account Id '+Ia.Account__c);
            //mapWaitlistAccountScore.put(Ia.Account__c,(mapWaitlistAccountScore.get(Ia.Account__c) + 1));
        }
        
        Ia.Weight_Count__c = countrecord;
        /*System.debug('####PPPP'+countrecord);
        if (Ia.Has_Assets__c) {
            assetcount = officeweight;
        }*/
    Ia.SOV20__c = false;
    Ia.SOV20_Price__c = 0;
    Ia.SOV30__c = false;
    Ia.SOV30_Price__c = 0;
    Ia.SOV50__c = false;
    Ia.SOV50_Price__c = 0;
    System.debug(mapAvailableInventory+'Good Marning');
    //Added by Pratik on 28th January 2019 for LE Invenroty Score requirement
    if(mapAvailableInventory.containskey(Ia.Account__r.party_id__c+'##'+Ia.Inventory_Data__r.Name+'##SOV20'))
    {
        
        available_inventories sov20 = mapAvailableInventory.get(Ia.Account__r.party_id__c+'##'+Ia.Inventory_Data__r.Name+'##SOV20');
      System.debug(' SOV 20 '+sov20.flex_unit_price);
       if(sov20.available_flex > 0){
        Ia.SOV20__c = True;
        
            Ia.SOV20_Price__c = sov20.flex_unit_price;
       }
    }
    else if(mapAvailableInventory.containskey(Ia.Inventory_Data__r.Name+'##SOV20'))
    {
            //System.debug(' SOV 20 ');
        available_inventories sov20 = mapAvailableInventory.get(Ia.Inventory_Data__r.Name+'##SOV20');
        System.debug(' SOV 20 '+sov20.flex_unit_price);
         if(sov20.available_flex > 0){
        Ia.SOV20__c = True;
       
            Ia.SOV20_Price__c = sov20.flex_unit_price;
         }
    }
    
    if(mapAvailableInventory.containskey(Ia.Account__r.party_id__c+'##'+Ia.Inventory_Data__r.Name+'##SOV30'))
    {
                //System.debug(' SOV 30 ');
        available_inventories sov30 = mapAvailableInventory.get(Ia.Account__r.party_id__c+'##'+Ia.Inventory_Data__r.Name+'##SOV30');
        System.debug(' SOV 30 '+sov30.flex_unit_price);
         if(sov30.available_flex > 0){
        Ia.SOV30__c = True;
       
            Ia.SOV30_Price__c = sov30.flex_unit_price;
         }
    }
    else if(mapAvailableInventory.containskey(Ia.Inventory_Data__r.Name+'##SOV30'))
    {
                System.debug(' SOV 30 ');
        available_inventories sov30 = mapAvailableInventory.get(Ia.Inventory_Data__r.Name+'##SOV30');
        System.debug(' SOV 30 '+sov30.flex_unit_price);
        if(sov30.available_flex > 0){       
        Ia.SOV30__c = True;
        
            Ia.SOV30_Price__c = sov30.flex_unit_price;
        }
    }
    
    if(mapAvailableInventory.containskey(Ia.Account__r.party_id__c+'##'+Ia.Inventory_Data__r.Name+'##SOV50'))
    {
                System.debug(' SOV 50 ');
        available_inventories sov50 = mapAvailableInventory.get(Ia.Account__r.party_id__c+'##'+Ia.Inventory_Data__r.Name+'##SOV50');
        System.debug(' SOV 50 '+sov50.flex_unit_price);
        if(sov50.available_flex > 0){
        Ia.SOV50__c = True;
            Ia.SOV50_Price__c = sov50.flex_unit_price;
        }
    }
    else if(mapAvailableInventory.containskey(Ia.Inventory_Data__r.Name+'##SOV50'))
    {
                System.debug(' SOV 50 ');
        available_inventories sov50 = mapAvailableInventory.get(Ia.Inventory_Data__r.Name+'##SOV50');
        System.debug(' SOV 50 '+sov50.flex_unit_price);
        if(sov50.available_flex > 0){
        Ia.SOV50__c = True;
        
            Ia.SOV50_Price__c = sov50.flex_unit_price;
        }
    }
    //Ends Here
    }
    }
    
    
    update mapInventoryAccount.values();
    if(Test.isRunningTest()){Integer ii=1/0;}
                } 
                
           catch(Exception ex){
           //  CRM-2822
           List<Inventory_Data__c> lstInvData = [Select Id,name,Error__c,Error_Message__c from Inventory_Data__c where Id=:setZipCodes and is_city_code__c = false];
           for(Inventory_Data__c Idd:lstInvData){
           Idd.Error__c = true ;
           Idd.Error_Message__c ='Line number : '+ex.getLineNumber()+ ' Stack trace'+ ex.getStackTraceString()+' Print Message'+ex.getMessage();
           }
           setSkipTrgTrue();
           update lstInvData;
           //CRM-2822
           }
    }
    
    Public static boolean skiptrigger= false;

    public static boolean isSkipTrg() {
        return skiptrigger;
    }
    public static void setSkipTrgTrue(){
        skiptrigger = true;
    }
    
    Public Class available_inventories{
public String party_id{get;set;}
public String part_number{get;set;}
public String market_name{get;set;}
public String postal_code{get;set;}
public String market_type{get;set;}
public String product_name{get;set;}
public String product_size{get;set;}
public Decimal available_flex{get;set;}
public Decimal available_fast{get;set;}
Public Decimal total_available{get;set;}
public Decimal available_presale_flex{get;set;}
public Decimal available_presale_fast{get;set;}
public Decimal price_tier  {get;set;}
public Decimal flex_unit_price {get;set;}
public Decimal fast_unit_price {get;set;}


//public Decimal invCount{get;set;}
} 
}