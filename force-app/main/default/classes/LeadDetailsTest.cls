@isTest
public class LeadDetailsTest {

    static testMethod void leadstest(){
       //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
            insert Dtrg;    
        Account theAccount = TestDataFactory.createAccount('The Test Account', null, false);
        theAccount.Primary_Email__c = 'theAcc@move.com';
        theAccount.Type = Constants.OFFICE_ACCOUNT_TYPE;    
        insert theAccount;
        system.debug('theAccount:' + theAccount.Id);
       Contact testContact = TestDataFactory.createContact('Test Contact','TestL',theAccount.Id,true,false);
        testContact.Email = 'rshekhawat@move.com';
        insert testContact; 
       
        list<lead> testleads = new list<lead>();
        for(integer i=0;i<15;i++){
             Lead Led = new Lead();
        //Led.LastName = 'Mr';
        Led.FirstName = 'Test';
        Led.LastName = 'Test';
        Led.Status = 'New';
        Led.Company = 'Test';
        Led.Account__c = theAccount.id;
        Led.Contact__c = testContact.id;
        //Led.Assigned_Group__c = 'test_group';
            testleads.add(Led);
        }
         insert testleads;
         List<Lead> UpLead = New List<Lead>();
         for(Lead ls: testleads){
             if(ls.Notes_Left__c == null){
                 ls.Notes_Left__c = 0;
             }    
             UpLead.add(ls);
         }
         update UpLead;
         
        /*String userId = UserInfo.getUserId();
        Task t = new Task();
            t.OwnerId = userId;
            t.Lead__c = UpLead[0].id;
            t.Description = 'Testing by';
            t.Status = 'Completed';
            t.Priority = 'Normal';
            t.WhatId = UpLead[0].AccountId__c;
            t.WhoId = UpLead[0].Contact__c;
            t.Outcome__c = 'New';
            t.Issue__c = 'Waitlist created';
            t.Type = 'Call - Outbound';
            t.ActivityDate = system.today(); 
        insert t; 
        */
        
        try{       
        ApexPages.currentPage().getParameters().put('Id',UpLead[0].id);
        apexPages.StandardSetController ssc = new apexpages.StandardSetController(UpLead);        
         LeadDetails leadssc = new LeadDetails(ssc);
         leadssc.mId = UpLead[0].id;
         leadssc.mDescription = 'Testing by';
         leadssc.mfollowup = 'Contacted – Callback';
         leadssc.mRejReason = 'Waitlist created';                
           
            String userId = UserInfo.getUserId();        
            Task t = new Task();
                t.OwnerId = userId;
                t.Lead__c = leadssc.mId;
                t.Description = leadssc.mDescription;
                t.Status = 'Completed';
                t.Priority = 'Normal';
                t.WhatId = UpLead[0].AccountId__c;
                t.WhoId = UpLead[0].Contact__c;
                t.Outcome__c = leadssc.mfollowup;
                t.Issue__c = leadssc.mRejReason;
                t.Type = 'Call - Outbound';
                t.ActivityDate = system.today();         
            insert t;
            
         leadssc.updateLead();
           pagereference p = leadssc.submit();
            list<lead> leads = leadssc.getselectedLeads();
        }
        catch(exception e){}
    }
    
     static testMethod void leadnulltest(){
       //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;    
    Account theAccount = TestDataFactory.createAccount('The Test Account', null, false);
    theAccount.Primary_Email__c = 'theAcc@move.com';
    theAccount.Type = Constants.OFFICE_ACCOUNT_TYPE;    
    insert theAccount;
    system.debug('theAccount:' + theAccount.Id);
   Contact testContact = TestDataFactory.createContact('Test Contact','TestL',theAccount.Id,true,false);
    testContact.Email = 'rshekhawat@move.com';
    insert testContact; 
       
        list<lead> testleads = new list<lead>();
        for(integer i=0;i<15;i++){
             Lead Led = new Lead();
        //Led.LastName = 'Mr';
        Led.FirstName = 'Test';
        Led.LastName = 'Test';
        Led.Status = 'New';
        Led.Company = 'Test';
        Led.Account__c = theAccount.id;
        Led.Contact__c = testContact.id;
        //Led.Assigned_Group__c = 'test_group';
            testleads.add(Led);
        }
       insert testleads;
        try{
        apexPages.StandardSetController ssc ;//= new apexpages.StandardSetController(testleads);
         LeadDetails leadssc = new LeadDetails(ssc);
         leadssc.updateLead();
           pagereference p = leadssc.submit();
            list<lead> leads = leadssc.getselectedLeads();
            leadssc.setid(testleads[0].id);
            string setval = leadssc.getId();
            leadssc.setStatus('In Progress');
            string getstat = leadssc.getStatus();
            leadssc.setRejReason('No Inventory');
            string setReason = leadssc.getRejReason();
            leadssc.setCallbackDate(string.valueof(system.today()+1));
            string callback = leadssc.getCallbackDate();
            leadssc.setCallbackTime(string.valueof(system.now()+1));
            string calldate = leadssc.getCallbackTime();
            leadssc.setfollowup('LM 1st Attempt');
            string follow = leadssc.getfollowup();
            leadssc.setDescription('Lead ststus changed from New to in progress.');
            string str = leadssc.getDescription();
        }
        catch(exception e){}
    }
}