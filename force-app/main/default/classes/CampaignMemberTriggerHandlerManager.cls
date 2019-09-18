//28 Apr 2016 Pallavi Tammana - LEAP-8145: SFDC 50001 Error
//5/16/2017 Pallavi Tammana - CRM-1659
public class CampaignMemberTriggerHandlerManager {

    public void updateCampaingns(Map<Id, CampaignMember> newCampaignMember){
         //Commented by Pallavi as this method is needed while deleting Campaign Members.
         //UpdateCampaignMembers(newCampaignMember);
         NewCampaignMembers(newCampaignMember);
         UpdateLeadProductCode(newCampaignMember);     
        
    }// end function

    public void deleteCampaingns(Map<Id, CampaignMember> oldCampaignMember){
    
            
       UpdateCampaignMembers(oldCampaignMember);
        
    }// end function
    
    //Added by Pallavi - While Inserting new Campaign Members, corresponding Campaign will be updated with Total Leads/Total Contacts.
    public void NewCampaignMembers(Map<Id, CampaignMember> CampaignMembers){
    
        list<Campaign> Campaignlist = new list<Campaign>();    
        set<ID> campaignids = new set<id>();
        map<Id,list<CampaignMember>> campMembersMap = new map<ID,list<CampaignMember>>();
        
        for(CampaignMember ocamp :CampaignMembers.values()) {
            if(ocamp.status == 'Responded'){
                campaignids.add(ocamp.CampaignID);                    
            }
            if(!campMembersMap.containsKey(ocamp.CampaignID)){
                campMembersMap.put(ocamp.CampaignID ,new list<CampaignMember>());                    
                campMembersMap.get(ocamp.CampaignID ).add(ocamp);                         
            } 
            else{
               campMembersMap.get(ocamp.CampaignID ).add(ocamp);                                             
            }
        }
        for(Campaign ocamp : [SELECT ID,Total_Contacts__c,Total_Leads__c FROM Campaign WHERE ID IN: campaignids]){
            Campaign temp = new Campaign(ID=ocamp.ID);
            for(CampaignMember camMem: campMembersMap.get(ocamp.ID)) {
                if(camMem.Contact_Exist__c != null)
                    temp.Total_Contacts__c = ocamp.Total_Contacts__c + 1;
                else
                    temp.Total_Leads__c = ocamp.Total_Leads__c + 1;
            
            }
            Campaignlist.add(temp);
        }
        
        if(!Campaignlist.isEmpty())
            update  Campaignlist;
    }
    

    public void UpdateCampaignMembers(Map<Id, CampaignMember> CampaignMembers){
        list<Campaign> Campaignlist = new list<Campaign>();    
        set<ID> campaignids = new set<id>();
        map<Id,list<CampaignMember>> campMembersMap = new map<ID,list<CampaignMember>>();
        
        system.debug('******newCampaignMember****'+CampaignMembers);
   
        for(CampaignMember ocamp :CampaignMembers.values()){
            if(ocamp.status == 'Responded'){
                campaignids.add(ocamp.CampaignID);                    
            }
        }
        // commented by ravinder for Integration error
        /*
        for(Campaign ocamp: [SELECT ID,(SELECT ID FROM CampaignMembers) FROM Campaign WHERE ID IN:campaignids]){
                    if(!campMembersMap.containsKey(ocamp.ID)){
                        campMembersMap.put(ocamp.ID,new list<CampaignMember>());                    
                        campMembersMap.get(ocamp.ID).addAll(ocamp.CampaignMembers);                         
                    }                      
        }
        */
        for(CampaignMember ocampMember : [SELECT ID,CampaignID FROM CampaignMember WHERE CampaignID  IN: campaignids]){
                 if(!campMembersMap.containsKey(ocampMember.CampaignID)){
                        campMembersMap.put(ocampMember.CampaignID ,new list<CampaignMember>());                    
                        campMembersMap.get(ocampMember.CampaignID ).add(ocampMember);                         
                    } 
                    else{
                       campMembersMap.get(ocampMember.CampaignID ).add(ocampMember);                                             
                    }
                                          
        }
        
        map<ID,Integer> campContacts = new map<ID,Integer>();
        
        AggregateResult[] groupedResults = [SELECT CampaignId,Count(Lead.Contact__c) conCount ,Count(ContactID) con1Count FROM CampaignMember  WHERE CampaignId IN:campaignids GROUP BY CampaignId];
        
        for (AggregateResult ar : groupedResults)  
        {
            campContacts.put(''+ar.get('CampaignId'),Integer.valueOf(ar.get('conCount')));                                         
        }


        for(Campaign ocamp : [SELECT ID,Total_Contacts__c,Total_Leads__c FROM Campaign WHERE ID IN: campaignids]){
                Campaign temp = new Campaign(ID=ocamp.ID);
                if(campContacts.containsKey(ocamp.ID))                
                    temp.Total_Leads__c    = campMembersMap.get(ocamp.ID).size() - campContacts.get(ocamp.ID); 
                if(campContacts.containsKey(ocamp.ID))
                    temp.Total_Contacts__c =   campContacts.get(ocamp.ID);                  
                    
               if(groupedResults.isEmpty()){
                   temp.Total_Leads__c    = 0; 
                   temp.Total_Contacts__c = 0;                                     
               }
            Campaignlist.add(temp);

        }
        if(!Campaignlist.isEmpty())
            update  Campaignlist;   
   }
   
 public void UpdateLeadProductCode(Map<Id, CampaignMember> CampaignMembers){
        list<Campaign> Campaignlist = new list<Campaign>();    
        set<ID> campaignids = new set<id>();
        set<ID> leadids = new set<id>();
        set<ID> contactids = new set<id>();
        Set<String> targetProductCode = new Set<String>();         

        for(CampaignMember ocamp : CampaignMembers.values()){            
            campaignids.add(ocamp.CampaignID);
            leadids.add(ocamp.LeadID);
            contactids.add(ocamp.ContactID);
        }
        //CRM-1659 - Added condition to check for Target Product Code on Campaign is not blank.
        for(campaign camp : [select id,Name,Target_Product_Code__c from Campaign where Id In : campaignids and Target_Product_Code__c != null]){
            targetProductCode.add(camp.Target_Product_Code__c);
            Campaignlist.add(camp);
        }
        Map<id,Lead> UpdateLeads = new Map<id,Lead>();
        List<Product2> products = [select id,ProductCode from Product2 where ProductCode In : targetProductCode];
        
        for(campaign camp : Campaignlist){
            for(CampaignMember CM : CampaignMembers.values()){
                if(CM.campaignid == camp.Id && CM.leadId!=null){           
                    for(Product2 prod : products){
                        if(camp.Target_Product_Code__c == prod.ProductCode){
                            lead led = new Lead();
                            led.id = CM.leadId;
                            led.Product__c = prod.Id;
                            UpdateLeads.put(led.Id,led);
                        }
                    }
                }
            }
        }
        if(UpdateLeads.size() > 0){
        System.debug('#########'+UpdateLeads);
            Update UpdateLeads.values();    
        }
   }


}