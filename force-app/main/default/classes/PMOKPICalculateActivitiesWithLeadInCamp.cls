/*

* This class is used by PMO tool. 

COUNT of Tasks and Events related to Lead with campaign type = 'Email Call Campaign' OR Campaign.Type = 'Organic Campaign OR Campaign.Type = Event Campaign'


*/

global without sharing class PMOKPICalculateActivitiesWithLeadInCamp implements WebServiceMock {
  private static final String EXTERNAL_CALCULATOR_RESULT = 'result';
  global void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {
        if (stub instanceof Id) { Id userId = (Id) stub; response.put(EXTERNAL_CALCULATOR_RESULT, calculate(userId)); }
    }


    @TestVisible
    private static Integer calculate(Id userId) {

        Map<id , List<task>> leadTask = new Map<id, List<task>>();
        Map<id , List<event>> leadEvent = new Map<id, List<event>>();


        List<Task> tasks = [Select Id, whoid from Task where who.Type = 'Lead' AND OwnerId =: userId AND IsClosed = true LIMIT 20000];
        List<Event> events = [Select Id, whoid from Event where who.Type = 'Lead' AND OwnerId =: userId AND EndDateTime < TODAY  LIMIT 20000];

        Set<Id> leadids = new Set<Id>();
        Integer activityCnt = 0;

        for(task t : tasks)
        {
            leadids.add(t.whoid);   
            if(leadTask.containskey(t.Whoid))
            { 
                 leadTask.get(t.Whoid).add(t);
            }
            else
            {
                leadTask.put(t.Whoid, new List<Task>{t});
            }
        }

        for(event e : events)
        {
            leadids.add(e.whoid);   
            if(leadEvent.containskey(e.Whoid))
            {
                 leadEvent.get(e.Whoid).add(e);
            }
            else
            {
                leadEvent.put(e.Whoid, new List<event>{e});
            }
        }

        system.debug('leadids = ' + leadids);
        if(leadids != null && leadids.size() > 0){
            List<CampaignMember> campmems = [Select Id, LeadId from CampaignMember where LeadId IN : leadids AND (Campaign.Type = 'Email Call Campaign' OR Campaign.Type = 'Organic Campaign' OR Campaign.Type = 'Event Campaign'  OR Campaign.Type = 'RDC Webinar') LIMIT 20000]; 
    
            for(CampaignMember c : campmems)
            {
                if(leadTask.containsKey(c.LeadId))
                {
                    activityCnt += leadTask.get(c.LeadId).size();
                }
                
                if(leadEvent.containsKey(c.LeadId))
                {
                    activityCnt += leadEvent.get(c.LeadId).size();
                }
            }    
    
        }
        return activityCnt;

    }
}