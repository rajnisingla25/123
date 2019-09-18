@isTest
private class PMOKPICalculateActivitiesWithLeadTest {
  
  @isTest
    static void calculateTest() {
        DisabledTrigger__c dt = new DisabledTrigger__c();
        dt.Name='Disabled';
        dt.TaskTrigger__c = 'test@test.com';
        dt.AssetTrigger__c = 'test@test.com';
        dt.AccountTrigger__c = 'test@test.com';
        insert dt;
        
        //CREATE CAMPAIGN
        Campaign c = new Campaign(Name='Test Camp', Type='Email Call Campaign');
        insert c;
        //CREATE LEAD
        Lead l = new Lead(LastName='lname', Company='testCompany');
        insert l;
        //CREATE CAMPAIGN MEMBER
        CampaignMember cm = new CampaignMember(CampaignId = c.id, LeadId = l.id);
        insert cm;
        //ADD EVENT AND TASK TO LEAD
        Event e = new Event(DurationInMinutes = 10, ActivityDateTime = System.NOW().addDays(-10), WhoId = l.id);
        insert e;
        Task t = new Task(ActivityDate = System.Today(), WhoId = l.id, Status='Completed');
        insert t;
        
        Integer result = PMOKPICalculateActivitiesWithLeadInCamp.calculate(UserInfo.getUserId());
        System.assertEquals (2, result);
    } 
    
}