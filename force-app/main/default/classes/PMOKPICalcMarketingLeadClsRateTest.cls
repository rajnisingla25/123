@isTest
private class PMOKPICalcMarketingLeadClsRateTest {
  
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
        
        //Create Account 
        Account a = new Account(Name='TestAcc', Display_Name__c='TestAcc');
        insert a;
        
        //create Opportunity
        Opportunity o = new Opportunity(Name = 'testName', AccountId = a.id, StageName = 'Closed Won - Fulfilled', CloseDate = System.today(), CampaignId = c.Id, Lead__c = l.id);
        insert o;
        
        //create Order
        //create Opportunity
        Order ord = new Order(Name = 'testName', OpportunityId = o.id, Status = 'Created', Accountid = a.id, EffectiveDate = System.Today(), EndDate = System.Today() + 1);
        insert ord;
        
        Integer result = PMOKPICalcMarketingLeadClsRate.calculate(UserInfo.getUserId());
    }
}