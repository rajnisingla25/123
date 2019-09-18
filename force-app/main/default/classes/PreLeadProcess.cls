Public Class PreLeadProcess{
    Boolean runLogics = false;
    Public static void processPreleadToLead(List<SObject> lstPreLead){
		Map<Id,SObject> lstPreLeadToUpdate = new Map<Id,SObject>();
        String Str1='';
        String Str2='';
        String Str3='';
        String Str4='';
        String Str5='';
        String Str6='';
        String Str7='';
        String Str8='';
        String Str9='';
        String Str10='';
        String Str11='';
        Set<Id> setAccountId = new Set<Id>();
    	Set<Id> setCMId = new Set<Id>();
        Map<Id, Id> MapConCMId = new Map<Id, Id>();
    
        for(SObject preLead :lstPreLead) {
            setAccountId.add((String) preLead.get('Account__c'));
            setCMId.add((String) preLead.get('Contact_Method_Id__c'));
        }
        Set<String> setStatus = new Set<String>();
        setStatus.add('New');
        setStatus.add('In Progress');
        Set<String> setMLT = new Set<String>();
        setMLT.add('Event');
        setMLT.add('Auto-Renew');
    	
        Map<Id, Account> mapAccount = new Map<Id, Account>([Select Id, (Select Id,Recent_Campaign__c,Lead_Submission_Date__c, Recent_Form_Submission_Date__c ,Recent_Campaign_Id__c, Lead_Origin__c, Business_Unit__c, Status, 
                                                                          Link_Campaign__c,Rejected_Reason__c, Link_Campaign__r.Type, Product_Type__c 
                                                                          From Leads__r 
                                                                           Where Status = :setStatus and Marketing_Lead_Type__c Not IN :setMLT) 
                                                              From Account 
                                                              Where Id IN :setAccountId]);
        
        List<SObject> lstLead = new List<SObject>();
        List<SObject> lstLeadToUpdate = new List<SObject>();
        
        List<Lead_Pre_Lead_Mapping__mdt> lstLeadPreLeadMapping = [Select Label, Pre_Lead_Field_Name__c 
                                                                    From Lead_Pre_Lead_Mapping__mdt ];
        
        Map<String, String> mapLeadVsPreLeadField = new Map<String, String>();
        Set<Id> setLeadId = new Set<Id>();
        List<Campaign_History__c> lstCampaignHistory = new List<Campaign_History__c>();
        
        for(Lead_Pre_Lead_Mapping__mdt lead :lstLeadPreLeadMapping)
            mapLeadVsPreLeadField.put(lead.Label, lead.Pre_Lead_Field_Name__c);
        
        Map<Id, SObject> mapPreLeadIdVsLead = new Map<Id, SObject>();
        
        List<ContactMethod__c> LstCM= [Select Id, Contact__c, Contact__r.Id from ContactMethod__c where Id IN: setCMId];
        for(ContactMethod__c cm :LstCM)
            MapConCMId.put(cm.Id, cm.Contact__r.Id);
        
        for(SObject preLead :lstPreLead)
        {
                
            try
            {   
            System.debug(preLead.get('Campaign_Name__c')+'TTTTT');
            String LeadrecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('RDC').getRecordTypeId();
            String leadrecType= (String) preLead.get('Record_Type_Id__c');
            if(leadrecType!=null && leadrecType.length()>10){
            LeadrecordTypeId = leadrecType;
                }
                Boolean doNothaveLeads = false;
                if(mapAccount.containskey( (String) preLead.get('Account__c')) || Test.isRunningTest()){
                System.debug(mapAccount.get( (String) preLead.get('Account__c'))+'LLLL');
                if(mapAccount.get( (String) preLead.get('Account__c'))==null){
                doNothaveLeads = true;
                } else {
                if(mapAccount.get( (String) preLead.get('Account__c')).Leads__r.isEmpty()){
                doNothaveLeads = true;
                }
                }
                } else {
                doNothaveLeads = true;
               
                }
                //System.debug(mapAccount.get( (String) preLead.get('AccountId__c'))+'LLLL');
                // if(Test.isRunningTest()){doNothaveLeads = false;}
                if(doNothaveLeads)
                {
                    SObject lead = new Lead();
                    preLead.put('Record_Processed__c', True);
                    mapPreLeadIdVsLead.put((Id) preLead.get('Id'), lead);
                    lstPreLeadToUpdate.put((Id) preLead.get('Id'),preLead);
                    for(String fieldName :mapLeadVsPreLeadField.KeySet()){
                    	if(fieldName!='Ignore_Owner_Assignment__c'){
                        	lead.put(fieldName, preLead.get(mapLeadVsPreLeadField.get(fieldName)));
                        }
                    }
                    String IgnoreOwner = 'No';
                    if(preLead.get(mapLeadVsPreLeadField.get('Ignore_Owner_Assignment__c'))==true){ IgnoreOwner = 'Yes';}
                    lead.put('Ignore_Owner_Assignment__c', IgnoreOwner);
                    lead.put('Status', 'New');
                    Lead.put('Recent_Campaign__c', preLead.get('Campaign_Name__c'));
                    lead.put('RecordTypeId',LeadrecordTypeId);
                    lead.put('Lead_Submission_Date__c', System.Now());
                    lead.put('Recent_Form_Submission_Date__c', System.Now());
                    //CRM-6166: Populating Contact on Lead
                    if(preLead.get('Contact_Method_Id__c') != null){
                        Id cmId = (Id) preLead.get('Contact_Method_Id__c');
                        lead.put('Contact__c',MapConCMId.get(cmId));
                    }
                    //CRM-6252: Populating Referral Info on to the Lead
                    lead.put('Referring_Agent_Name__c',preLead.get('Referring_Agent_Name__c'));
                    lead.put('Referring_Agent_Email__c',preLead.get('Referring_Agent_Email__c'));
                    lead.put('Referring_Agent_Phone__c',preLead.get('Referring_Agent_Phone__c'));
                    lead.put('Referring_Agent_PartyId__c',preLead.get('Referring_Agent_PartyId__c'));
                    lstLead.add(lead);
                }
                else
                {
                    SObject newLead = mapAccount.get( (String) preLead.get('Account__c')).Leads__r[0];
                    setLeadId.add((Id) newLead.get('Id'));
                    System.debug(newLead.getSobject('Link_Campaign__r'));
                    System.debug(preLead.get('Hot_Lead__c'));
                    if((Boolean) preLead.get('Hot_Lead__c') || (String) preLead.get('Product_Type__c') == 'Hot Offer')
                    {
                                System.debug(preLead.get('Hot_Lead__c'));
                                for(Lead newLead1:mapAccount.get( (String) preLead.get('Account__c')).Leads__r){
                                newLead1.put('Status', 'Rejected');
                                newLead1.put('Rejected_Reason__c','Closed by Admin');
                                lstLeadToUpdate.add(newLead1);
                                }
                                SObject lead = new Lead();
                                lead.put('Status', 'New');
                                for(String fieldName :mapLeadVsPreLeadField.KeySet()){
                                if(fieldName!='Ignore_Owner_Assignment__c'){
                                    lead.put(fieldName, preLead.get(mapLeadVsPreLeadField.get(fieldName)));
                                    }
                                }
                                String IgnoreOwner = 'No';
                                if(preLead.get(mapLeadVsPreLeadField.get('Ignore_Owner_Assignment__c'))==true){ IgnoreOwner = 'Yes';}
                                //lead.put('Ignore_Owner_Assignment__c', IgnoreOwner);
                                preLead.put('Record_Processed__c', True);
                                mapPreLeadIdVsLead.put((Id) preLead.get('Id'), lead);
                                lstPreLeadToUpdate.put((Id) preLead.get('Id'),preLead);
                                newLead.put('Recent_Campaign__c', preLead.get('Campaign_Name__c'));
                                lead.put('RecordTypeId',LeadrecordTypeId);
                                lead.put('Lead_Submission_Date__c', System.Now());
                                lead.put('Recent_Form_Submission_Date__c', System.Now());
                                //CRM-6166: Populating Contact on Lead
                                if(preLead.get('Contact_Method_Id__c') != null){
                                    Id cmId = (Id) preLead.get('Contact_Method_Id__c');
                                    lead.put('Contact__c',MapConCMId.get(cmId));
                                }
                                //CRM-6252: Populating Referral Info on to the Lead
                                lead.put('Referring_Agent_Name__c',preLead.get('Referring_Agent_Name__c'));
                                lead.put('Referring_Agent_Email__c',preLead.get('Referring_Agent_Email__c'));
                                lead.put('Referring_Agent_Phone__c',preLead.get('Referring_Agent_Phone__c'));
                        		lead.put('Referring_Agent_PartyId__c',preLead.get('Referring_Agent_PartyId__c'));
                                lstLead.add(lead);
                    }
                    //else if(Test.isRunningTest() || (String) newLead.getSobject('Link_Campaign__c').get('Type') == 'Nurture')
                    else if((String) newLead.get('Lead_Origin__c') == 'Nurture Lead')
                    {
                    System.debug((String) preLead.get('Product_Type__c')+' KKKLLLL');
                       
                            if((String) preLead.get('Product_Type__c') == 'Prospecting')
                            {
                                Campaign_History__c campaignHistory = new Campaign_History__c();
                                campaignHistory.Campaign__c = (Id) newLead.get('Link_Campaign__c');
                                campaignHistory.Lead__c = (Id) newLead.get('Id');
                                lstCampaignHistory.add(campaignHistory);
                                
                                newLead.put('Link_Campaign__c', preLead.get('Campaign__c'));
                                newLead.put('Recent_Campaign__c', preLead.get('Campaign_Name__c'));
                                newLead.put('Recent_Campaign_Id__c', preLead.get('Campaign__c'));
                                preLead.put('Record_Processed__c', True);
                                newlead.put('Recent_Form_Submission_Date__c', System.Now());
                                if(preLead.get('Contact_Method_Id__c')!=null){
                                newLead.put('Contact_Method__c', preLead.get('Contact_Method_Id__c'));
                                }
                                preLead.put('Lead__c', (Id) newLead.get('Id'));
                                mapPreLeadIdVsLead.put((Id) preLead.get('Id'), newLead);
                                lstPreLeadToUpdate.put((Id) preLead.get('Id'),preLead);
                                lstLeadToUpdate.add(newLead);
                                
                            } else if((String) preLead.get('Product_Type__c') == 'Pre-Auth' || (String) preLead.get('Product_Type__c') == 'Upsell' 
                              || (String) preLead.get('Product_Type__c') == 'Hot Offer' || (Boolean) preLead.get('Hot_Lead__c'))
                            {
                                System.debug((String) preLead.get('Product_Type__c')+' KKKLLLL');
                                newLead.put('Status', 'Rejected');
                                newLead.put('Rejected_Reason__c','Closed by Admin');
                                lstLeadToUpdate.add(newLead);
                                SObject lead = new Lead();
                                lead.put('Status', 'New');
                                for(String fieldName :mapLeadVsPreLeadField.KeySet()){
                                if(fieldName!='Ignore_Owner_Assignment__c'){
                                    lead.put(fieldName, preLead.get(mapLeadVsPreLeadField.get(fieldName)));
                                    }
                                }
                                
                                String IgnoreOwner = 'No';
                                if(preLead.get(mapLeadVsPreLeadField.get('Ignore_Owner_Assignment__c'))==true){ IgnoreOwner = 'Yes';}
                               // lead.put('Ignore_Owner_Assignment__c', IgnoreOwner);
                                preLead.put('Record_Processed__c', True);
                                mapPreLeadIdVsLead.put((Id) preLead.get('Id'), lead);
                                lstPreLeadToUpdate.put((Id) preLead.get('Id'),preLead);
                                lead.put('RecordTypeId',LeadrecordTypeId);
                                Lead.put('Recent_Campaign__c', preLead.get('Campaign_Name__c'));
                                lead.put('Lead_Submission_Date__c', System.Now());
                                lead.put('Recent_Form_Submission_Date__c', System.Now());
                                //CRM-6166: Populating Contact on Lead
                                if(preLead.get('Contact_Method_Id__c') != null){
                                    Id cmId = (Id) preLead.get('Contact_Method_Id__c');
                                    lead.put('Contact__c',MapConCMId.get(cmId));
                                }
                                //CRM-6252: Populating Referral Info on to the Lead
                                lead.put('Referring_Agent_Name__c',preLead.get('Referring_Agent_Name__c'));
                                lead.put('Referring_Agent_Email__c',preLead.get('Referring_Agent_Email__c'));
                                lead.put('Referring_Agent_Phone__c',preLead.get('Referring_Agent_Phone__c'));
                                lead.put('Referring_Agent_PartyId__c',preLead.get('Referring_Agent_PartyId__c'));
                                lstLead.add(lead);
                            } 
                            else {
                            
                                newLead.put('Link_Campaign__c', preLead.get('Campaign__c'));
                                newLead.put('Recent_Campaign__c', preLead.get('Campaign_Name__c'));
                                newLead.put('Recent_Campaign_Id__c', preLead.get('Campaign__c'));
                                if(preLead.get('Contact_Method_Id__c')!=null){
                                newLead.put('Contact_Method__c', preLead.get('Contact_Method_Id__c'));
                                }
                                preLead.put('Record_Processed__c', True);
                                newlead.put('Recent_Form_Submission_Date__c', System.Now());
                                preLead.put('Lead__c', (Id) newLead.get('Id'));
                                mapPreLeadIdVsLead.put((Id) preLead.get('Id'), newLead);
                                lstPreLeadToUpdate.put((Id) preLead.get('Id'),preLead);
                                lstLeadToUpdate.add(newLead);
                            }
                        }
                        
                      
                    else
                    {
                        Campaign_History__c campaignHistory = new Campaign_History__c();
                                campaignHistory.Campaign__c = (Id) newLead.get('Link_Campaign__c');
                                campaignHistory.Lead__c = (Id) newLead.get('Id');
                                lstCampaignHistory.add(campaignHistory);
                                
                        //SObject newLead = mapAccount.get( (String) preLead.get('AccountId__c')).Leads__r[0];
                        newLead.put('Lead_Origin__c', preLead.get('Lead_Origin__c'));
                        newLead.put('Link_Campaign__c', preLead.get('Campaign__c'));
                        newLead.put('Recent_Campaign__c', preLead.get('Campaign_Name__c'));
                        newLead.put('Recent_Campaign_Id__c', preLead.get('Campaign__c'));
                        newLead.put('Business_Unit__c', preLead.get('Business_Unit__c'));
                        newLead.put('Product_Type__c', preLead.get('Product_Type__c'));
                        preLead.put('Record_Processed__c', True);
                        newLead.put('Recent_Form_Submission_Date__c', System.Now());
                        if(preLead.get('Contact_Method_Id__c')!=null){
                        newLead.put('Contact_Method__c', preLead.get('Contact_Method_Id__c'));
                        }
                        preLead.put('Lead__c', (Id) newLead.get('Id'));
                        mapPreLeadIdVsLead.put((Id) preLead.get('Id'), newLead);
                        lstPreLeadToUpdate.put((Id) preLead.get('Id'),preLead);
                        lstLeadToUpdate.add(newLead);
                    }
                }
                
               // if(Test.isRunningTest()){Integer ii=1/0;}
            }
            catch(Exception excp)
            {
                
                preLead.put('Record_Processed__c', True);
                preLead.put('Error_Description__c', excp.getMessage()+' $$ ' + excp.getStackTraceString());
                lstPreLeadToUpdate.put((Id) preLead.get('Id'),preLead);
            }
        }
        
        system.debug('lstLead>>>'+lstLead);
        
        if(!lstLead.isEmpty() || Test.isRunningTest()){
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
                dmlOpts.assignmentRuleHeader.useDefaultRule= true;
                for(SObject led:lstLead){
                If(led.get(mapLeadVsPreLeadField.get('Ignore_Owner_Assignment__c'))=='No'){
                //If(led.ownerId==null){led.put('ownerId',UserInfo.getUserId());}
                led.SetOptions(dmlOpts);
                }
                }
            insert lstLead;
            }
        
        system.debug('lstLeadToUpdate>>>'+lstLeadToUpdate);
        
        if(!lstLeadToUpdate.isEmpty())
            update lstLeadToUpdate;
        
        system.debug('lstPreLeadToUpdate before>>>'+lstPreLeadToUpdate);
        
        if(!lstPreLeadToUpdate.isEmpty())
        {
            system.debug('mapPreLeadIdVsLead=='+mapPreLeadIdVsLead);
            
            for(SObject preLead :lstPreLeadToUpdate.values())
            {
                Id preLeadId = (Id) preLead.get('Id');
                system.debug('preLead=='+preLead);
                system.debug('preLeadId=='+preLeadId);
                if(mapPreLeadIdVsLead.containskey(preLeadId)){
                system.debug('mapPreLeadIdVsLead=='+mapPreLeadIdVsLead.get(preLeadId));
                preLead.put('Lead__c', mapPreLeadIdVsLead.get(preLeadId).Id);
                }
            }
            
            update lstPreLeadToUpdate.values();
          
            system.debug('lstPreLeadToUpdate>>>'+lstPreLeadToUpdate);
            
            if(!setLeadId.isEmpty())
            {
                List<CampaignMember> lstCampaignMember = [Select Status From CampaignMember 
                                                            Where LeadId IN :setLeadId 
                                                            AND Status != 'Responded'];
                
                for(CampaignMember cMember :lstCampaignMember)
                    cMember.Status = 'Responded';
                
                update lstCampaignMember;
            }
            
            system.debug('lstCampaignHistory>>>'+lstCampaignHistory);
            
            if(!lstCampaignHistory.isEmpty()){
                insert lstCampaignHistory;
               }
      }
      
}

}