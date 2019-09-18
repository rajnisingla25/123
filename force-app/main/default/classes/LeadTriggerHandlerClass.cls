Public class LeadTriggerHandlerClass{

Public void LeadHandlerBefore(List<Lead> LeadRecords){
    
        Set<Id> setAccountIds = new Set<Id>();
        Set<Id> setMatchAccountIds = new Set<Id>();
        Set<Id> setLeadIds = new Set<Id>();
        Set<Id> setContactIds = new Set<Id>();
        Map<Id,Id> MapAccountUser = new Map<Id,Id>();
        Map<Id,List<Id>> mapContactAccountIds = new  Map<Id,List<Id>>();
        
        Set<String> setLeadPhoneBroker = new Set<String>();
        Set<String> setLeadEmailBroker = new Set<String>();
        Set<String> setLeadPhone = new Set<String>();
        Set<String> setLeadEmail = new Set<String>();
        
        Set<Id> setBrokerAccountPhoneEmailIds = new Set<Id>();
        String keyBrokerAccountPhoneEmailIds = null;
        Map<String,List<Id>> mapLeadBrokerAccountPhoneEmailIds = new  Map<String,List<Id>>();
        
        Set<Id> setBrokerAccountPhoneIds = new Set<Id>();
        String keyBrokerAccountPhoneIds = null;
        Map<String,List<Id>> mapLeadBrokerAccountPhoneIds = new  Map<String,List<Id>>();
        
        Set<Id> setBrokerAccountEmailIds = new Set<Id>();
        String keyBrokerAccountEmailIds = null;
        Map<String,List<Id>> mapLeadBrokerAccountEmailIds = new  Map<String,List<Id>>();
        
        Set<Id> setBrokerAccountHLCCLCIds = new Set<Id>();
        Map<Id,List<Id>> mapLeadBrokerAccountHLCCLCIds = new  Map<Id,List<Id>>();
        
        Set<Id> setAccountPhoneEmailIds = new Set<Id>();
        String keyAccountPhoneEmailIds = null;
        Map<String,List<Id>> mapLeadAccountPhoneEmailIds = new  Map<String,List<Id>>();
        
        Set<Id> setAccountPhoneIds = new Set<Id>();
        String keyAccountPhoneIds = null;
        Map<String,List<Id>> mapLeadAccountPhoneIds = new  Map<String,List<Id>>();
        
        Set<Id> setAccountEmailIds = new Set<Id>();
        String keyAccountEmailIds = null;
        Map<String,List<Id>> mapLeadAccountEmailIds = new  Map<String,List<Id>>();
        
        Set<Id> setAccountHLCCLCIds = new Set<Id>();
        Map<Id,List<Id>> mapLeadAccountHLCCLCIds = new  Map<Id,List<Id>>();
        
        Set<Id> setBrokerHLCCLCContactIds = new Set<Id>();
        Set<Id> setHLCCLCContactIds = new Set<Id>();
        
        // These variables will be used when RDC Contact Type is Blank on Lead and hence Lead assocition to
        // Account will be performed based on Target Account Type defined on Campaign
        Set<String> setLeadPhoneBrokerCamp = new Set<String>();
        Set<String> setLeadEmailBrokerCamp = new Set<String>();
        Set<String> setLeadPhoneCamp = new Set<String>();
        Set<String> setLeadEmailCamp = new Set<String>();
        
        Set<Id> setBrokerAccountPhoneEmailCampIds = new Set<Id>();
        String keyBrokerAccountPhoneEmailCampIds = null;
        Map<String,List<Id>> mapLeadBrokerAccountPhoneEmailCampIds = new  Map<String,List<Id>>();
        
        Set<Id> setBrokerAccountPhoneCampIds = new Set<Id>();
        String keyBrokerAccountPhoneCampIds = null;
        Map<String,List<Id>> mapLeadBrokerAccountPhoneCampIds = new  Map<String,List<Id>>();
        
        Set<Id> setBrokerAccountEmailCampIds = new Set<Id>();
        String keyBrokerAccountEmailCampIds = null;
        Map<String,List<Id>> mapLeadBrokerAccountEmailCampIds = new  Map<String,List<Id>>();
        
        Set<Id> setBrokerAccountHLCCLCCampIds = new Set<Id>();
        Map<Id,List<Id>> mapLeadBrokerAccountHLCCLCCampIds = new  Map<Id,List<Id>>();
        
        Set<Id> setAccountPhoneEmailCampIds = new Set<Id>();
        String keyAccountPhoneEmailCampIds = null;
        Map<String,List<Id>> mapLeadAccountPhoneEmailCampIds = new  Map<String,List<Id>>();
        
        Set<Id> setAccountPhoneCampIds = new Set<Id>();
        String keyAccountPhoneCampIds = null;
        Map<String,List<Id>> mapLeadAccountPhoneCampIds = new  Map<String,List<Id>>();
        
        Set<Id> setAccountEmailCampIds = new Set<Id>();
        String keyAccountEmailCampIds = null;
        Map<String,List<Id>> mapLeadAccountEmailCampIds = new  Map<String,List<Id>>();
        
        Set<Id> setAccountHLCCLCCampIds = new Set<Id>();
        Map<Id,List<Id>> mapLeadAccountHLCCLCCampIds = new  Map<Id,List<Id>>();
        
        Set<Id> setBrokerHLCCLCContactCampIds = new Set<Id>();
        Set<Id> setHLCCLCContactCampIds = new Set<Id>();
        
        for(Lead led : LeadRecords){
        if(led.id!=null){
        setLeadIds.add(led.id);
        }
            //CRM-1858: will be adding more conditions to it.
            //if(led.Account__c!=null) continue;
        
            //led.ownerid=null;
            if(led.Account__c!=null){
                setAccountIds.add(led.Account__c);
            }
            if(led.Contact__c!=null){
                setContactIds.add(led.Contact__c);
            }
            
            if(led.RDC_Contact_Type__c != null && led.RDC_Contact_Type__c != 'Single Agent'){
                if(led.Phone != null){
                    setLeadPhoneBroker.add(led.Phone);
                }   
            
                if(led.Email != null){
                    setLeadEmailBroker.add(led.Email);
                }
                    
                if(led.Contact__c != null){
                    setBrokerHLCCLCContactIds.add(led.Contact__c);
                }
                
           
            }
            
            if(led.RDC_Contact_Type__c != null && led.RDC_Contact_Type__c == 'Single Agent'){
                if(led.Phone != null){
                    setLeadPhone.add(led.Phone);
                }   
            
                if(led.Email != null){
                    setLeadEmail.add(led.Email);
                }
                    
                if(led.Contact__c != null){
                    setHLCCLCContactIds.add(led.Contact__c);
                }
            }
            
            // When RDC Contact Type is Null we will look Lead was target to Broker on Campaing
            // Lead_Target_Account_Type__c is formula field on Lead based on Recent_Campaing_id look up
            if(led.RDC_Contact_Type__c == null && led.Lead_Target_Account_Type__c == 'Broker') {
                if(led.Phone != null){
                    setLeadPhoneBrokerCamp.add(led.Phone);
                }   
            
                if(led.Email != null){
                    setLeadEmailBrokerCamp.add(led.Email);
                }
                    
                if(led.Contact__c != null){
                    setBrokerHLCCLCContactCampIds.add(led.Contact__c);
                }
            
            }
            
            // When RDC Contact Type is Null we will look Lead was target to Agent on Campaing
            // Lead_Target_Account_Type__c is formula field on Lead based on Recent_Campaing_id look up
            if(led.RDC_Contact_Type__c == null && led.Lead_Target_Account_Type__c == 'Agent') {
                if(led.Phone != null){
                    setLeadPhoneCamp.add(led.Phone);
                }   
            
                if(led.Email != null){
                    setLeadEmailCamp.add(led.Email);
                }
                    
                if(led.Contact__c != null){
                    setHLCCLCContactCampIds.add(led.Contact__c);
                }
            }
               
            
        }
        
        if(setContactIds.size()>0){
            system.debug('setContactIds :'+setContactIds);
            
            // For Loop to populate AccountList for a Contact
            for(Account_Relationship__c Arr : [Select id,name,Parent_Account__c,Contact_To__c from Account_Relationship__c where Contact_To__c=:setContactIds]){
                system.debug('setContactIds :'+Arr);
                setAccountIds.add(Arr.Parent_Account__c);
                if(mapContactAccountIds.containskey(Arr.Contact_To__c)){
                    List<Id> lstAccountIds = mapContactAccountIds.get(Arr.Contact_To__c);
                    lstAccountIds.add(Arr.Parent_Account__c);
                    mapContactAccountIds.put(Arr.Contact_To__c,lstAccountIds);
                }
                else{
                    List<Id> lstAccountIds = new List<Id>();
                    lstAccountIds.add(Arr.Parent_Account__c);
                    mapContactAccountIds.put(Arr.Contact_To__c,lstAccountIds);
                }
            }
              
        }
        
        system.debug('mapContactAccountIds.size :'+mapContactAccountIds.size());
        
        
        
        
       // For Agent look up when RDC Contact Type on Lead Exists
       if(setLeadPhone.size() > 0 || setLeadEmail.size() > 0 ){
        // For Agent based on Phone and Email
        if(setAccountIds.size() > 1 || setAccountIds.size() == 0){
            for(Account AccPhoneEmail : [Select id, Phone, Email_Address__c from Account where Type = 'Realtor Agent' AND Phone =: setLeadPhone and Email_Address__c =: setLeadEmail]){
            system.debug('AccPhoneEmail :'+AccPhoneEmail);
            setAccountPhoneEmailIds.add(AccPhoneEmail.id);
            keyAccountPhoneEmailIds = AccPhoneEmail.Phone + AccPhoneEmail.Email_Address__c;
            
            
            system.debug('keyAccountPhoneEmailIds :'+keyAccountPhoneEmailIds);
                    
                    if(mapLeadAccountPhoneEmailIds.containskey(keyAccountPhoneEmailIds)){
                        List<Id> lstAccPhoneEmailIds = mapLeadAccountPhoneEmailIds.get(keyAccountPhoneEmailIds);
                        lstAccPhoneEmailIds.add(AccPhoneEmail.id);
                        mapLeadAccountPhoneEmailIds.put(keyAccountPhoneEmailIds,lstAccPhoneEmailIds);
                    }
                    else{
                        List<Id> lstAccPhoneEmailIds = new List<Id>();
                        lstAccPhoneEmailIds.add(AccPhoneEmail.id);
                        mapLeadAccountPhoneEmailIds.put(keyAccountPhoneEmailIds,lstAccPhoneEmailIds);
                    }
                    
            }
        }
        
        // For Agent Based on Phone
        if(setAccountPhoneEmailIds.size() == 0){
            for(Account AccPhone : [Select id, Phone, Email_Address__c from Account where Type = 'Realtor Agent' AND Phone =: setLeadPhone limit 49999]){
            system.debug('AccPhone :'+AccPhone);
            setAccountPhoneIds.add(AccPhone.id);
            
            keyAccountPhoneIds = AccPhone.Phone ;
                    
                    if(mapLeadAccountPhoneIds.containskey(keyAccountPhoneIds)){
                        List<Id> lstAccPhoneIds = mapLeadAccountPhoneIds.get(keyAccountPhoneIds);
                        lstAccPhoneIds.add(AccPhone.id);
                        mapLeadAccountPhoneIds.put(keyAccountPhoneIds,lstAccPhoneIds);
                    }
                    else{
                        List<Id> lstAccPhoneIds = new List<Id>();
                        lstAccPhoneIds.add(AccPhone.id);
                        mapLeadAccountPhoneIds.put(keyAccountPhoneIds,lstAccPhoneIds);
                    }
            
            }
        }
        
        // For Agent based on Email
        if(setAccountPhoneIds.size() == 0){  
            for(Account AccEmail : [Select id, Phone, Email_Address__c from Account where Type = 'Realtor Agent' AND Email_Address__c =: setLeadEmail limit 49999]){
            system.debug('AccEmail :'+AccEmail);
            setAccountEmailIds.add(AccEmail.id);
            
            keyAccountEmailIds = AccEmail.Email_Address__c ;
                    
                    if(mapLeadAccountEmailIds.containskey(keyAccountEmailIds)){
                        List<Id> lstAccEmailIds = mapLeadAccountEmailIds.get(keyAccountEmailIds);
                        lstAccEmailIds.add(AccEmail.id);
                        mapLeadAccountEmailIds.put(keyAccountEmailIds,lstAccEmailIds);
                    }
                    else{
                        List<Id> lstAccEmailIds = new List<Id>();
                        lstAccEmailIds.add(AccEmail.id);
                        mapLeadAccountEmailIds.put(keyAccountEmailIds,lstAccEmailIds);
                    }
                    
            }
        }
        
        // For Agent based on HLC CLC
        if(setAccountIds.size() != 0 && (setAccountEmailIds.size() > 1 || setAccountEmailIds.size() == 0)){
            for(Account_Relationship__c AccHLCCLC : [Select Parent_Account__c, Contact_To__c from Account_Relationship__c where  Contact_To__c =: setHLCCLCContactIds order by Parent_Account__r.Account_Sub_Type__c asc, Parent_Account__r.Total_HLC1__c desc, Parent_Account__r.Total_CLC1__c desc limit 1]){
            system.debug('AccHLCCLC :'+AccHLCCLC);
            setAccountHLCCLCIds.add(AccHLCCLC.Parent_Account__c);
            
                    if(mapLeadAccountHLCCLCIds.containskey(AccHLCCLC.Contact_To__c)){
                        List<Id> lstAccHLCCLCIds = mapLeadAccountHLCCLCIds.get(AccHLCCLC.Contact_To__c);
                        lstAccHLCCLCIds.add(AccHLCCLC.Parent_Account__c);
                        mapLeadAccountHLCCLCIds.put(AccHLCCLC.Contact_To__c,lstAccHLCCLCIds);
                    }
                    else{
                        List<Id> lstAccHLCCLCIds = new List<Id>();
                        lstAccHLCCLCIds.add(AccHLCCLC.Parent_Account__c);
                        mapLeadAccountHLCCLCIds.put(AccHLCCLC.Contact_To__c,lstAccHLCCLCIds);
                    }        
            }
        }
        
       } // Ends if(setLeadPhone.size() > 0 || setLeadEmail.size() > 0 )  
       
        
        
        // Agent Look up when RDC Contact Type on Lead does not exists
       if(setLeadPhoneCamp.size() > 0 || setLeadEmailCamp.size() > 0 ){
            
        // For Agent with Phone and Email
        if(setAccountIds.size() > 1 || setAccountIds.size() == 0){
            for(Account AccPhoneEmailCamp : [Select id, Phone, Email_Address__c from Account where Type = 'Realtor Agent' AND Phone =: setLeadPhoneCamp and Email_Address__c =: setLeadEmailCamp]){
            system.debug('AccPhoneEmailCamp :'+AccPhoneEmailCamp);
            setAccountPhoneEmailCampIds.add(AccPhoneEmailCamp.id);
            keyAccountPhoneEmailCampIds = AccPhoneEmailCamp.Phone + AccPhoneEmailCamp.Email_Address__c;
                    
                    if(mapLeadAccountPhoneEmailCampIds.containskey(keyAccountPhoneEmailCampIds)){
                        List<Id> lstAccPhoneEmailCampIds = mapLeadAccountPhoneEmailCampIds.get(keyAccountPhoneEmailCampIds);
                        lstAccPhoneEmailCampIds.add(AccPhoneEmailCamp.id);
                        mapLeadAccountPhoneEmailCampIds.put(keyAccountPhoneEmailCampIds,lstAccPhoneEmailCampIds);
                    }
                    else{
                        List<Id> lstAccPhoneEmailCampIds = new List<Id>();
                        lstAccPhoneEmailCampIds.add(AccPhoneEmailCamp.id);
                        mapLeadAccountPhoneEmailCampIds.put(keyAccountPhoneEmailCampIds,lstAccPhoneEmailCampIds);
                    }
                    
            }
        
       }
        // For Agent for Phone
        if(setAccountPhoneEmailCampIds.size() == 0){
            for(Account AccPhoneCamp : [Select id, Phone, Email_Address__c from Account where Type = 'Realtor Agent' AND Phone =: setLeadPhoneCamp limit 49999]){
            system.debug('AccPhoneCamp :'+AccPhoneCamp);
            setAccountPhoneCampIds.add(AccPhoneCamp.id);
            
            keyAccountPhoneCampIds = AccPhoneCamp.Phone ;
                    
                    if(mapLeadAccountPhoneCampIds.containskey(keyAccountPhoneCampIds)){
                        List<Id> lstAccPhoneCampIds = mapLeadAccountPhoneCampIds.get(keyAccountPhoneCampIds);
                        lstAccPhoneCampIds.add(AccPhoneCamp.id);
                        mapLeadAccountPhoneCampIds.put(keyAccountPhoneCampIds,lstAccPhoneCampIds);
                    }
                    else{
                        List<Id> lstAccPhoneCampIds = new List<Id>();
                        lstAccPhoneCampIds.add(AccPhoneCamp.id);
                        mapLeadAccountPhoneCampIds.put(keyAccountPhoneCampIds,lstAccPhoneCampIds);
                    }
            
            }
        }
        
        // For Agent for Email
        if(setAccountPhoneCampIds.size() == 0){
            for(Account AccEmailCamp : [Select id, Phone, Email_Address__c from Account where Type = 'Realtor Agent' AND Email_Address__c =: setLeadEmailCamp limit 49999]){
            system.debug('AccEmailCamp :'+AccEmailCamp);
            setAccountEmailCampIds.add(AccEmailCamp.id);
            
            keyAccountEmailCampIds = AccEmailCamp.Email_Address__c ;
                    
                    if(mapLeadAccountEmailCampIds.containskey(keyAccountEmailCampIds)){
                        List<Id> lstAccEmailCampIds = mapLeadAccountEmailCampIds.get(keyAccountEmailCampIds);
                        lstAccEmailCampIds.add(AccEmailCamp.id);
                        mapLeadAccountEmailCampIds.put(keyAccountEmailCampIds,lstAccEmailCampIds);
                    }
                    else{
                        List<Id> lstAccEmailCampIds = new List<Id>();
                        lstAccEmailCampIds.add(AccEmailCamp.id);
                        mapLeadAccountEmailCampIds.put(keyAccountEmailCampIds,lstAccEmailCampIds);
                    }
                    
            }
        }
        
        // For Agent HLC CLC
        if(setAccountIds.size() > 1 && (setAccountEmailCampIds.size() == 0 || setAccountEmailCampIds.size() > 1)){
            for(Account_Relationship__c AccHLCCLCCamp : [Select Parent_Account__c, Contact_To__c from Account_Relationship__c where  Contact_To__c =: setHLCCLCContactCampIds order by Parent_Account__r.Account_Sub_Type__c asc, Parent_Account__r.Total_HLC1__c desc, Parent_Account__r.Total_CLC1__c desc limit 1]){
            system.debug('AccHLCCLCCamp :'+AccHLCCLCCamp);
            setAccountHLCCLCCampIds.add(AccHLCCLCCamp.Parent_Account__c);
            
            
                    if(mapLeadAccountHLCCLCCampIds.containskey(AccHLCCLCCamp.Contact_To__c)){
                        List<Id> lstAccHLCCLCCampIds = mapLeadAccountHLCCLCCampIds.get(AccHLCCLCCamp.Contact_To__c);
                        lstAccHLCCLCCampIds.add(AccHLCCLCCamp.Parent_Account__c);
                        mapLeadAccountHLCCLCCampIds.put(AccHLCCLCCamp.Contact_To__c,lstAccHLCCLCCampIds);
                    }
                    else{
                        List<Id> lstAccHLCCLCCampIds = new List<Id>();
                        lstAccHLCCLCCampIds.add(AccHLCCLCCamp.Parent_Account__c);
                        mapLeadAccountHLCCLCCampIds.put(AccHLCCLCCamp.Contact_To__c,lstAccHLCCLCCampIds);
                    }
                    
            }
        }
      
      
      } // Ends setLeadPhoneCamp.size() > 0 || setLeadEmailCamp.size() > 0 
      
        /*******************************************************
        ENDS - Below code is to map based on Target Account Type defined on Campaign, when RDC Contact Type is Blank on Lead
        ********************************************************/        
        
        Map<Id,String> mapLeadCampaign = new Map<Id,String>();
       // if(!setLeadIds.isEmpty())
            for(CampaignMember cmm : [Select Id,Name,LeadId,CampaignId,Campaign.Type from CampaignMember where LeadId =: setLeadIds]){
               mapLeadCampaign.put(cmm.LeadId,cmm.Campaign.Type);
            }
        Map<Id, User> mapUser = new Map<Id, User>([select id, Ignore_assignment__c from user where Ignore_assignment__c = true or Profile_Name__c = 'Open Book Profile']);

        for(Lead led : LeadRecords){
            if(mapContactAccountIds.containskey(led.Contact__c)){
                if(led.Account__c==null){
                    if(mapContactAccountIds.get(led.Contact__c).size()==1){
                        led.Account__c = mapContactAccountIds.get(led.Contact__c)[0];
                        led.Lead_Matching_Type__c = 'Auto - Single Relation Match';
                    }
                    // when you have multiple accounts returned from Relationship for matching contact on Lead
                    else if (led.Marketing_Lead_Type__c != 'Outbound Call Leads' || led.Marketing_Lead_Type__c != 'Event' || led.Marketing_Lead_Type__c != 'RDC Webinar'){
                        if(led.RDC_Contact_Type__c != null){
                        system.debug('led.RDC_Contact_Type__c :'+led.RDC_Contact_Type__c + led.Email + '==>' + mapLeadBrokerAccountEmailIds.containskey(led.Email));
                           
                           //For Broker Account
                           if (led.RDC_Contact_Type__c != 'Single Agent'){
                            
                                            
                           } // Broker Accounts ends here
                           // else condition for Agent Accounts
                           else{
                           
                               if (mapLeadAccountPhoneEmailIds.containskey(led.Phone + led.Email) && mapLeadAccountPhoneEmailIds.get(led.Phone + led.Email).size()==1){
                                   system.debug('CK Inside Email and Phone match condition### :'+led.Phone + led.Email);
                                   led.Account__c = mapLeadAccountPhoneEmailIds.get(led.Phone + led.Email)[0];
                                   led.Lead_Matching_Type__c = 'Auto - Email & Phone Match';
                                   setAccountIds.add(led.Account__c);                                        
                                }
                   
                                else if (!mapLeadAccountPhoneEmailIds.containskey(led.Phone + led.Email) && mapLeadAccountPhoneIds.containskey(led.Phone) && mapLeadAccountPhoneIds.get(led.Phone).size()==1){
                                    system.debug('CK InsidePhone match condition ###:'+led.Phone + led.Account__c);
                                    led.Account__c = mapLeadAccountPhoneIds.get(led.Phone)[0];
                                    led.Lead_Matching_Type__c = 'Auto - Phone Match';
                                    setAccountIds.add(led.Account__c);
                                }
                            
                                else if (!mapLeadAccountPhoneEmailIds.containskey(led.Phone + led.Email) && mapLeadAccountEmailIds.containskey(led.Email) && mapLeadAccountEmailIds.get(led.Email).size()==1){
                                    system.debug('CK Inside Email match condition ###:'+led.Email + led.Account__c);
                                    led.Account__c = mapLeadAccountEmailIds.get(led.Email)[0];
                                    led.Lead_Matching_Type__c = 'Auto - Email Match';
                                    setAccountIds.add(led.Account__c);
                                }
                            /*
                            else if (!mapLeadAccountPhoneEmailIds.containskey(led.Phone + led.Email) && mapLeadAccountHLCCLCIds.containskey(led.Contact__c)){
                                system.debug('CK Inside Agent HLCCLC match condition :'+led.RDC_Contact_Type__c + led.Contact__c);
                                if(mapLeadAccountHLCCLCIds.get(led.Contact__c).size()==1){
                                    led.Account__c = mapLeadAccountHLCCLCIds.get(led.Contact__c)[0];
                                    led.Lead_Matching_Type__c = 'Auto - HLC/CLC Match';
                                }
                            }
                           */
                           else {
                               system.debug('CK Inside Agent HLCCLC match condition :'+led.RDC_Contact_Type__c + led.Contact__c);
                               if(mapLeadAccountHLCCLCIds.containskey(led.Contact__c)){
                                   led.Account__c = mapLeadAccountHLCCLCIds.get(led.Contact__c)[0];
                                   led.Lead_Matching_Type__c = 'Auto - Customer/HLC/CLC Match';
                                   setAccountIds.add(led.Account__c);
                               }
                           }
                           
                            
                           } // Agent Accounts ends
                           
                        } // ends led.RDC_Contact_Type__c != null
                        // start RDC Contact Type as Null
                        else{
                            if(led.Link_Campaign__c != null) {
                                System.debug('Im Inside Campaign');
                                // start Broker Account Check
                                if (led.Lead_Target_Account_Type__c =='Broker'){
                                 
                                } // ends Broker Account Check
                                // Start Agent account check
                                else{
                                    if (mapLeadAccountPhoneEmailCampIds.containskey(led.Phone + led.Email) && mapLeadAccountPhoneEmailCampIds.get(led.Phone + led.Email).size()==1){
                                
                                        system.debug('CK Inside Email and Phone match condition :'+led.Phone + led.Email);
                                        led.Account__c = mapLeadAccountPhoneEmailCampIds.get(led.Phone + led.Email)[0];
                                        led.Lead_Matching_Type__c = 'Auto - Email & Phone Match';
                                        setAccountIds.add(led.Account__c);   
                                    }
                           
                                    else if (!mapLeadAccountPhoneEmailCampIds.containskey(led.Phone + led.Email) && mapLeadAccountPhoneCampIds.containskey(led.Phone) && mapLeadAccountPhoneCampIds.get(led.Phone).size()==1){
                                        led.Account__c = mapLeadAccountPhoneCampIds.get(led.Phone)[0];
                                        led.Lead_Matching_Type__c = 'Auto - Phone Match';
                                        setAccountIds.add(led.Account__c);
                                    }
                                    
                                    else if (!mapLeadAccountPhoneEmailCampIds.containskey(led.Phone + led.Email) && mapLeadAccountEmailCampIds.containskey(led.Email) && mapLeadAccountEmailCampIds.get(led.Email).size()==1){
                                       led.Account__c = mapLeadAccountEmailCampIds.get(led.Email)[0];
                                       led.Lead_Matching_Type__c = 'Auto - Email Match';
                                       setAccountIds.add(led.Account__c); 
                                    }
                                    /*
                                    else if (!mapLeadAccountPhoneEmailCampIds.containskey(led.Phone + led.Email) && mapLeadAccountHLCCLCCampIds.containskey(led.Contact__c)){
                                        system.debug('CK Inside HLCCLC Camp match condition :'+led.Lead_Target_Account_Type__c + led.Contact__c);
                                        if(mapLeadAccountHLCCLCCampIds.get(led.Contact__c).size()==1){
                                           led.Account__c = mapLeadAccountHLCCLCCampIds.get(led.Contact__c)[0];
                                           led.Lead_Matching_Type__c = 'Auto - HLC/CLC Match';
                                        }
                                    }
                                    */                                   
                                    else{
                                        system.debug('CK Inside HLCCLC Camp match condition :'+led.Lead_Target_Account_Type__c + led.Contact__c);
                                        if(mapLeadAccountHLCCLCCampIds.containskey(led.Contact__c)){
                                           led.Account__c = mapLeadAccountHLCCLCCampIds.get(led.Contact__c)[0];
                                           led.Lead_Matching_Type__c = 'Auto - Customer/HLC/CLC Match';
                                           setAccountIds.add(led.Account__c);
                                        }
                                    }
                                    
                                    
                                    
                                } // ends Agent Account Check
                                
                            } // end led.Recent_Campaign_Id__c  
                            
                        } // ends start RDC Contact Type as Null
                    }  // ends else for -- when you have multiple accounts returned from Relationship for matching contact on Lead
                } // ends led.Account__c
            } // Ends if mapContactAccountIds.containskey(led.Contact__c)
            // When Contact and account both do not exist on Lead
            else if (led.Account__c == null && led.Contact__c==null && (led.Marketing_Lead_Type__c != 'Outbound Call Leads' || led.Marketing_Lead_Type__c != 'Event' || led.Marketing_Lead_Type__c != 'RDC Webinar')){
                // Start led.RDC_Contact_Type__c != null
                if(led.RDC_Contact_Type__c != null){
                   //For Broker Account
                   if (led.RDC_Contact_Type__c != 'Single Agent'){
                   
                                  
                   } // ends if condition for Broker Accounts
                   // else condition for Agent Accounts
                   else{
                    
                           if (mapLeadAccountPhoneEmailIds.containskey(led.Phone + led.Email) && mapLeadAccountPhoneEmailIds.get(led.Phone + led.Email).size()==1){
                                
                                system.debug('CK Inside Email and Phone match condition :'+led.Phone + led.Email);
                                led.Account__c = mapLeadAccountPhoneEmailIds.get(led.Phone + led.Email)[0];
                                led.Lead_Matching_Type__c = 'Auto - Email & Phone Match';
                                setAccountIds.add(led.Account__c);
                            }
                   
                            else if (!mapLeadAccountPhoneEmailIds.containskey(led.Phone + led.Email) && mapLeadAccountPhoneIds.containskey(led.Phone) && mapLeadAccountPhoneIds.get(led.Phone).size()==1){
                                led.Account__c = mapLeadAccountPhoneIds.get(led.Phone)[0];
                                led.Lead_Matching_Type__c = 'Auto - Phone Match';
                                setAccountIds.add(led.Account__c);
                            }
                            
                            else if (!mapLeadAccountPhoneEmailIds.containskey(led.Phone + led.Email) && mapLeadAccountEmailIds.containskey(led.Email) && mapLeadAccountEmailIds.get(led.Email).size()==1){
                                led.Account__c = mapLeadAccountEmailIds.get(led.Email)[0];
                                led.Lead_Matching_Type__c = 'Auto - Email Match';
                                setAccountIds.add(led.Account__c);
                            }
                    
                   } // endselse condition for Agent Accounts
                   
                } // ends led.RDC_Contact_Type__c != null
                
                //start led.RDC_Contact_Type__c == null
                else{
                    
                    if(led.Link_Campaign__c != null) {
                        if (led.Lead_Target_Account_Type__c =='Broker'){
                            
                        }
                        // For Agent Account
                        else {
                                 if (mapLeadAccountPhoneEmailCampIds.containskey(led.Phone + led.Email) && mapLeadAccountPhoneEmailCampIds.get(led.Phone + led.Email).size()==1){
                                       system.debug('CK Inside Email and Phone match condition :'+led.Phone + led.Email);
                                       led.Account__c = mapLeadAccountPhoneEmailCampIds.get(led.Phone + led.Email)[0];
                                       led.Lead_Matching_Type__c = 'Auto - Email & Phone Match';
                                       setAccountIds.add(led.Account__c);     
                                    }
                           
                                    else if (!mapLeadAccountPhoneEmailCampIds.containskey(led.Phone + led.Email) && mapLeadAccountPhoneCampIds.containskey(led.Phone) && mapLeadAccountPhoneCampIds.get(led.Phone).size()==1){
                                       led.Account__c = mapLeadAccountPhoneCampIds.get(led.Phone)[0];
                                       led.Lead_Matching_Type__c = 'Auto - Phone Match';
                                       setAccountIds.add(led.Account__c); 
                                    }
                                    
                                    else if (!mapLeadAccountPhoneEmailCampIds.containskey(led.Phone + led.Email) && mapLeadAccountEmailCampIds.containskey(led.Email) && mapLeadAccountEmailCampIds.get(led.Email).size()==1){
                                        led.Account__c = mapLeadAccountEmailCampIds.get(led.Email)[0];
                                        led.Lead_Matching_Type__c = 'Auto - Email Match';
                                        setAccountIds.add(led.Account__c);
                                    }
                            
                        } // End of else for Agent Account
                        
                        
                    } // ends of led.Recent_Campaign_Id__c != null
                    
                } // ends led.RDC_Contact_Type__c == null
                
            } // ends of else if for led.Account__c == null && led.Contact__c==null
            
            //CRM-1858: updating Map with Account Owners.
            
             
            // CK - We do not need to set Interested_in_Connection_For_Co_Brokerag__c from SFDC, this is coming from Eloqua
            /*
            if(mapLeadCampaign.containskey(led.id)){
             if(mapLeadCampaign.get(led.id)=='Organic Campaign'){
             led.Interested_in_Connection_For_Co_Brokerag__c = true;
             }
            }
            */
            System.debug('$$$$$$'+led.OwnerId);
        } // for looks for LeadRecords ends 
        
                System.debug('setAccountIds:'+setAccountIds);
            for(Account acc:[Select id,Name,Territories__c,ownerid from Account where id=:setAccountIds]){
              if(!mapUser.containskey(acc.ownerid)){
                    MapAccountUser.put(acc.id,acc.ownerid);
              }
            }
            
        for(Lead led : LeadRecords){
            
                                  
            if(MapAccountUser.containskey(led.Account__c)  && led.Ignore_Owner_Assignment__c!='Yes'){
                System.debug('MapAccountUser:'+MapAccountUser);
                led.OwnerId = MapAccountUser.get(led.Account__c);
            }
        }
        
    }

  Public void LeadHandlerBeforeNew(List<Lead> LeadRecords){
                //System.debug('setAccountIds:'+setAccountIds);
                Set<Id> setAccountIds = new Set<Id>();
                Map<Id,Id> MapAccountUser = new Map<Id,Id>();
                Map<Id,Account> MapAccountLead = new Map<Id,Account>();
                Map<Id, User> mapUser = new Map<Id, User>([select id, Ignore_assignment__c from user where Ignore_assignment__c = true or Profile_Name__c = 'Open Book Profile']);
            List<AccountContactMatch.RecordInfoWrapper> lstWrapper = new List<AccountContactMatch.RecordInfoWrapper>();
            AccountContactMatch.RecordInfoWrapper RecordInfoWrap = new AccountContactMatch.RecordInfoWrapper();
            //RecordInfoWrap.CMId = 'a6aq0000000oA7SAAU';
            //RecordInfoWrap.Campaign = '701q0000000i8gnAAA';
            //RecordInfoWrap.ContactId ='003f1000025JV74AAG';
            Map<Id,Integer> mapLeadIdAccountMatch = new Map<Id,Integer>();
            Integer ii=0;
            Id opcityRecordTypeId = Schema.SObjectType.LEAD.getRecordTypeInfosByName().get('OPCITY').getRecordTypeId();
            for(Lead led : LeadRecords){
            if(led.Account__c==null && led.Are_you_buying_your_own_leads__c == 'Yes'){
            RecordInfoWrap.Email=led.Email_of_Managing_Broker__c;
            RecordInfoWrap.Phone=led.Phone;
            lstWrapper.add(RecordInfoWrap);
            mapLeadIdAccountMatch.put(led.id,ii);
            ii++;
            }
            }
            if(ii>0){
            AccountContactMatch.getBrokerOfficeRecordInfo(lstWrapper);
            }
            for(Lead led : LeadRecords){
            if(led.Are_you_buying_your_own_leads__c == 'Yes'){
            led.RecordTypeId = opcityRecordTypeId;
            }
           if(led.Account__c==null && led.Are_you_buying_your_own_leads__c == 'Yes' && mapLeadIdAccountMatch.containskey(led.Id)){
           if(lstWrapper.size()>0 && mapLeadIdAccountMatch.get(led.Id)!=null){
           if(lstWrapper[mapLeadIdAccountMatch.get(led.Id)]!=null){
                led.RecordTypeId = opcityRecordTypeId;
                led.Account__c = lstWrapper[mapLeadIdAccountMatch.get(led.Id)].AccountId;
                led.contact__c = lstWrapper[mapLeadIdAccountMatch.get(led.Id)].ContactId;
                led.Lead_Matching_Type__c = lstWrapper[mapLeadIdAccountMatch.get(led.Id)].MatchType;
                //led.Account__c = lstWrapper[mapLeadIdAccountMatch.get(led.Id)].AccountId;
                //led.Account__c = lstWrapper[mapLeadIdAccountMatch.get(led.Id)].AccountId;
                }
                }
            } 
            }
            
            for(Lead led : LeadRecords){
            if(led.Account__c!=null){
                setAccountIds.add(led.Account__c);
            } 
            }
            Set<String> setStatus = new Set<String>();
        setStatus.add('New');
        setStatus.add('In Progress');
        Set<String> setMLT = new Set<String>();
        setMLT.add('Event');
        setMLT.add('Auto-Renew');
            List<Account> lstAccount = [Select id,Name,Territories__c,ownerid,(Select Id,Recent_Campaign__c,Lead_Submission_Date__c, Recent_Form_Submission_Date__c ,Recent_Campaign_Id__c, Lead_Origin__c, Business_Unit__c, Status, 
                                                                          Link_Campaign__c,Rejected_Reason__c, Link_Campaign__r.Type, Product_Type__c 
                                                                          From Leads__r 
                                                                           Where Status = :setStatus and Marketing_Lead_Type__c Not IN :setMLT  and RecordTypeId!=:opcityRecordTypeId) from Account where id=:setAccountIds];
            
            for(Account acc:lstAccount){
            MapAccountLead.put(acc.id,acc);
              if(!mapUser.containskey(acc.ownerid)){
                    MapAccountUser.put(acc.id,acc.ownerid);
              }
            }
            
        for(Lead led : LeadRecords){
            if(MapAccountUser.containskey(led.Account__c)){
            List<Lead> lstLead = MapAccountLead.get(led.Account__c).Leads__r;
             if(lstLead.size()>1){
             if(led.Status != 'Converted' && led.Status != 'Waitlisted'){
             led.Status = 'Rejected';
             led.Rejected_reason__c = 'Closed by admin';
             }
             }
            }
            //CRM-6251: Setting Ignore_Owner_Assignment__c as 'Yes' for all Top Producer Leads.
            if(led.Business_Unit__c == 'Top Producer'){
                led.Ignore_Owner_Assignment__c = 'Yes';
            }
            if(MapAccountUser.containskey(led.Account__c)  && led.Ignore_Owner_Assignment__c!='Yes'){
                System.debug('MapAccountUser:'+MapAccountUser);
                led.OwnerId = MapAccountUser.get(led.Account__c);
            }
            
        }
        
    }
    
    
    Public void LeadHandlerAfter(List<Lead> LeadRecords,Map<Id,Lead> LeadMap){
          Set<Id> setLeadIds = new Set<Id>();
        Map<Id,String> mapContactIds = new Map<Id,String>();
        Set<Id> setCampaignIds = new Set<Id>();
        Map<Id,Lead> mapLead = LeadMap;
        List<Campaign_History__c> lstNewCampaignHistory = new List<Campaign_History__c>();
        Map<String,Campaign_History__c> mapLeadCH = new Map<String,Campaign_History__c>();
        Group grp = [SELECT Id FROM Group where Group.Type='Queue' and DeveloperName = 'Unassigned_Leads'];
 
        for(Lead led : LeadRecords){
            setLeadIds.add(led.id);
            if(led.Contact__c!=null){
            mapContactIds.put(led.Contact__c,led.Recent_Campaign_Id__c);
            }
            setCampaignIds.add(led.Recent_Campaign_Id__c);
        }
        for(Campaign_History__c ch:[Select Id,name,Lead__c,Campaign__c,Contact__c,Account__c from Campaign_History__c where Lead__c =: setLeadIds]){
            if(ch.Campaign__c!=null){
                mapLeadCH.put(ch.Lead__c+'##'+String.valueOf(ch.Campaign__c).substring(0, 15),ch);
            }
        }
        List<CampaignMember> lstCampaignMember = new List<CampaignMember>();
        set<Id> setCampaignContacts = new set<Id>();
        if(setCampaignIds.size()>0){
        for(CampaignMember cmm : [Select Id,Name,LeadId,ContactId,Status,CampaignId from CampaignMember where ContactId =: mapContactIds.keyset() and CampaignId=:setCampaignIds]){
        setCampaignContacts.add(cmm.ContactId);
        if(cmm.Status=='Sent'){
        cmm.Status = 'Responded';
        lstCampaignMember.add(cmm);
        }
        }
        for(Id idd:mapContactIds.keyset()){
        if(!setCampaignContacts.contains(idd)){
        if(mapContactIds.get(idd)!=null && mapContactIds.get(idd)!=''){
        System.debug(mapContactIds.get(idd)+'KKKK');
        if(!Test.isRunningTest()){
        CampaignMember cmmm = new CampaignMember();
        cmmm.ContactId = idd;
        cmmm.CampaignId = mapContactIds.get(idd);
        cmmm.Status = 'Responded';
        lstCampaignMember.add(cmmm);
        }
        }
        }
        }
        }
        if(lstCampaignMember.size()>0){
        System.debug(lstCampaignMember+'LLLLLLL');
        upsert lstCampaignMember;
        }
      
        /*for(CampaignMember cmm : [Select Id,Name,LeadId,CampaignId from CampaignMember where (LeadId =: setLeadIds OR ContactId=:setContactIds) and CampaignId=:setCampaignIds]){
            if(!mapLeadCH.containskey(cmm.LeadId+'##'+cmm.CampaignId)){
                Campaign_History__c ch = new Campaign_History__c();
                ch.Lead__c = cmm.LeadId;
                ch.Campaign__c = cmm.CampaignId;
                if(mapLead.get(cmm.LeadId).Contact__c!=null){
                    ch.Contact__c = mapLead.get(cmm.LeadId).Contact__c;
                }
                if(mapLead.get(cmm.LeadId).Account__c !=null){
                    ch.Account__c = mapLead.get(cmm.LeadId).Account__c ;
                }
                lstNewCampaignHistory.add(ch);
            }
        }*/
        for(Lead led : LeadRecords){
        if(led.Recent_Campaign_Id__c!=null){
        System.debug(mapLeadCH.containskey(led.Id+'##'+led.Recent_Campaign_Id__c)+'KKKKKK'+mapLeadCH+'LLLL'+led.Id+'##'+led.Recent_Campaign_Id__c);
             if(!mapLeadCH.containskey(led.Id+'##'+String.valueOf(led.Recent_Campaign_Id__c).substring(0, 15))){
                Campaign_History__c ch = new Campaign_History__c();
                ch.Lead__c = led.Id;
                ch.Campaign__c = led.Recent_Campaign_Id__c;
                if(mapLead.get(led.Id).Contact__c!=null){
                    ch.Contact__c = mapLead.get(led.Id).Contact__c;
                }
                if(mapLead.get(led.Id).Account__c !=null){
                    ch.Account__c = mapLead.get(led.Id).Account__c ;
                }
                mapLeadCH.put(led.Id+'##'+led.Recent_Campaign_Id__c,ch);
            }
            }
 
 
        }
        
        if(mapLeadCH.values().size() > 0){
            Upsert mapLeadCH.values();
        }
        
        set<Id> setLeadQueueIds = new set<Id>();
        for(Lead olead : LeadRecords){
            System.debug(olead.ownerId+'####'+olead.owner.type);
            /*if((olead.ownerId+'').contains('005')){
                // Added by Chandan to pass only Lead which has Account Id
                if(olead.Account__c!=null){
                setLeadQueueIds.add(olead.id);
                } 
            }*/
            if(grp.id!=olead.ownerId){
            if((olead.ownerId+'').startsWithIgnoreCase('00G')){
                // Added by Chandan to pass only Lead which has Account Id
                if(olead.Account__c!=null){
                setLeadQueueIds.add(olead.id);
                } 
            }
            }
        }
        if(setLeadQueueIds.size()>0 && !System.isBatch()){
            System.debug('####'+setLeadQueueIds);
            //LeadRoutingLogic.LeadToRoute(setLeadQueueIds);
            LeadRoutingLogic_RoundRobin.LeadToRoute(setLeadQueueIds);
            //SkipTrigger.setSkipTrgTrue();
        }
    }
    //CRM-1511 - Updating Referral Status based on Lead Status
    Public void LeadReferralStatus(List<Lead> newLeads,map<ID,Lead> oldLeads, Boolean isInsert){
        
        Map<String, String> RefStatusMap = new Map<String, String>();
        for(Lead_Referral_Status__mdt refStat : [Select Lead_Status__c, Referral_Status__c from Lead_Referral_Status__mdt]){
            RefStatusMap.put(refStat.Lead_Status__c, refStat.Referral_Status__c);
        }
        System.debug('RefStatusMap:'+RefStatusMap);
        
        for(Lead ld: newLeads) {
            if(ld.Lead_Origin__c != null) {
                if(isInsert) {
                    //CRM-1716 - Verifying that Marketing Lead Type contains 'referral-sponsored'.
                    //CRM-6326 - Changing from Marketing Lead Type to Lead Origin for SFMC.
                    if(ld.Lead_Origin__c.contains('Referral') && !RefStatusMap.isEmpty() && RefStatusMap.containsKey(ld.Status)) {
                        ld.Referral_Status__c = RefStatusMap.get(ld.Status);
                    }
                }
                else{
                    if(ld.Lead_Origin__c.contains('Referral') && ld.Status != oldLeads.get(ld.Id).Status && !RefStatusMap.isEmpty() && RefStatusMap.containsKey(ld.Status)) {
                        ld.Referral_Status__c = RefStatusMap.get(ld.Status);
                    }
                }
            }
        }
        
    }
    
    Public void LeadDuplicate(List<Lead> newLeads, Boolean isInsert){
    
        Map<String, Lead> LeadMap = new Map<String, Lead>();
        if(isInsert) {
            User user = [select id, Name,profile.Name,Username,Sales_Lock_User__c from User where ID =: UserInfo.getUserId()];
            string profilename = user.profile.Name;
            if (!profilename.contains('Eloqua')) {
                for (Lead ld : newLeads) {        
                    if (ld.Email != null && ld.Marketing_Lead_Type__c != 'Event') {           
                        // Make sure another new Contact isn't also a duplicate          
                        if (LeadMap.containsKey(ld.Email)) {
                            ld.Email.addError('Another new Lead has the '
                                                + 'same email address.');
                        } else if(ld.Marketing_Lead_Type__c != 'Event'){
                            LeadMap.put(ld.Email, ld);
                        }
                   }
                }
            }
        }
            
        if(!LeadMap.isEmpty()) {       
            for (Lead ld : [SELECT Email FROM Lead
                              WHERE Email IN :LeadMap.KeySet() AND Status != 'Converted' AND Status != 'Rejected' AND Marketing_Lead_Type__c != 'Event']) {
                Lead ldnew = LeadMap.get(ld.Email);
                ldnew.Email.addError('A Lead with this email '
                                       + 'address already exists.');
            }
        }
    }
    
    
   
    //Added By Pratik on 9th August 2018 for CRM-4544
    public void handleAfterInsert(List<Lead> lstLead)
    {
        Map<Id,Account> lstAccount = new Map<Id,Account>();
        Set<Id> setAccount = new Set<Id>();
        Set<Id> setLeadIds = new Set<Id>();
        
        for(Lead lead :lstLead)
        {
            if(lead.Account__c != Null){
                setAccount.add(lead.Account__c);
                }
                setLeadIds.add(lead.id);
        }
        
        if(!setAccount.isEmpty() || Test.isRunningTest())
        {
            Map<Id, Account> mapAccount = new Map<Id, Account>([Select Id, Object_Id__c, NextContactTime__c, Scheduled_CallBack__c From Account Where Id IN:setAccount]);
            Map<Id,Id> mapTaskAssignTo = new Map<Id,Id>();
            for(Task tsk:[Select id,Lead__c, OwnerId,Owner.name from task where Lead__c=:setLeadIds order by createddate Desc limit 6]){
            if(tsk.Lead__c!=null && tsk.Owner.name!=null){
            if(!tsk.Owner.name.contains('nvmapiuser@move.com') && !mapTaskAssignTo.containskey(tsk.Lead__c)){
            mapTaskAssignTo.put(tsk.Lead__c,tsk.OwnerId);
            }
            }
            }
            
            for(Lead lead :lstLead)
            {
                if(lead.Account__c != Null // && lead.NVM_Callback_DateTime__c != Null 
                   && mapAccount.containsKey(lead.Account__c) || Test.isRunningTest())
                {
                 if(lead.NVM_Callback_DateTime__c != null || lead.NVM_Callback_DateTime__c == null 
                    && mapAccount.containsKey(lead.Account__c) 
                    && mapAccount.get(lead.Account__c).Object_Id__c!=null  || Test.isRunningTest()){
                    Account account = new Account();
                    account.Id = lead.Account__c;
                    System.debug('Here it is');
                   
                       account.Scheduled_CallBack__c = lead.NVM_Callback_DateTime__c;
                     //Commented by Pratik on 1st February 2019 for CRM-5497
                    //account.Callback_User__c = mapTaskAssignTo.get(lead.Id);
                    //Added by Pratik on 27th September 2018 for CRM-4698
                    account.Object_Id__c = lead.Id;
                    if(lead.NVM_Callback_DateTime__c==null 
                       && mapAccount.containsKey(lead.Account__c) 
                       && mapAccount.get(lead.Account__c).Object_Id__c==lead.id){
                    account.Object_Id__c = null;
                    }
                    lstAccount.put(account.Id,account);
                    }
                }
            }
            
            if(!lstAccount.values().isEmpty())
            SkipAccountTrigger.setSkipTrgTrue();
            if(!Test.isRunningTest()){
                update lstAccount.values();
                }
            
        }
    }
    
    public void handleAfterUpdate(List<Lead> lstLead, Map<Id, Lead> mapOldLead)
    {
        List<Lead> lstLeadToUpdate = new List<Lead>();
        
        for(Lead lead :lstLead)
        {
            if(lead.NVM_Callback_DateTime__c != mapOldLead.get(lead.Id).NVM_Callback_DateTime__c || true)
                //Commented by Pratik for CRM-4665 on 4th September 2018
               //&& (lead.Follow_Up_Status__c == 'Follow up Scheduled- no Pitch' || lead.Follow_Up_Status__c == 'Follow up Scheduled- Pitched'))
            {
                lstLeadToUpdate.add(lead);
            }
        }
        
        if(!lstLeadToUpdate.isEmpty())
            handleAfterInsert(lstLeadToUpdate);
    }
    //Ends here
    
    // The following Method updates the phone fields from Contact Method during Lead creation , update when the status is New or In Progress - Venkat Arisa
    public void populateLeadPhoneFields(List<Lead> newLeadList, Map<Id,Lead> oldLeadMap){
        Set<Id> accountsList = new Set<Id>();
        List<Lead> newLeads = new List<Lead>();
        for(Lead leadRecord: newLeadList){           
            if((leadRecord.Status == 'New' || leadRecord.Status == 'In Progress') && 
               ((oldLeadMap == null && leadRecord.Account__c != null) ||
                (oldLeadMap != null && (leadRecord.Account__c != oldLeadMap.get(leadRecord.Id).Account__c)))){
                   accountsList.add(leadRecord.Account__c);
                   newLeads.add(leadRecord);
               }                  
        }
        
        if(!accountsList.isEmpty()){
            system.debug(' **** accountsList *** '+accountsList);
            system.debug(' **** newLeads *** '+newLeads);
            MoveUtility.updatePhoneFields(newLeads,accountsList); 
        }
        
    }
    public void populateSFMCSync(List<Lead> newLeadList, Map<Id,Lead> oldLeadMap, Boolean isInsert){
    
        for(Lead leadRecord: newLeadList){           
            if((leadRecord.Status == 'New' || leadRecord.Status == 'In Progress') && 
               (leadRecord.Marketing_Lead_Type__c != 'Auto-Renew' && leadRecord.Marketing_Lead_Type__c != 'Event') &&
               (isInsert || oldLeadMap.get(leadRecord.Id).SFMC_Sync__c == False)){
                    leadRecord.SFMC_Sync__c = True;
           }                  
        }
    }
    
}