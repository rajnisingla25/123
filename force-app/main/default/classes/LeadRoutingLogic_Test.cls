@isTest(seeAllData = false)
public  class LeadRoutingLogic_Test{
    public static testMethod void main(){          
        Profile p = [select id from profile where name='Standard User'];
        User u = new User(alias = 'test', email='test.data@move.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/New_York', username='testdata@test.com'); 
        insert u;
       //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
       insert Dtrg;
    
    Robin_Round__c rb = new Robin_Round__c(Name = 'MaxCount',Default_Size__c = 50);
    insert rb;   
       
    //Inserting Test Account       
     Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
          testAccount.Primary_Email__c = 'testAccount@move.com';
          insert testAccount; 
     //Inserting Test Contact 
    Contact testContact = TestDataFactory.createContact('Test Contact','TestL',testAccount.Id,true,false);
          testContact.Email = 'rshekhawat@move.com';
          insert testContact;
          
     Product2 newProduct = new Product2();
        newProduct.Name = 'TestProduct';
        newProduct.Commission_Category__c = 'Normal';    
        newProduct.Normalization_factor__c = 1.10;
        newProduct.Commission_Category__c = 'CFCB';
        newProduct.Fulfillment_Type__c = 'Manual';
        newProduct.Auto_Renewal__c = True;
        newProduct.ProductCode = 'COBROKE';
        newProduct.S_No__c = 2;
        insert newProduct;  
         
        List<id> accountlist = new List<id>();
        accountlist.add(testAccount.id);
        
        Map<Id,List<Id>> mapContactAccountIds = new  Map<Id,List<Id>>();
        mapContactAccountIds.put(testAccount.id,accountlist); 
       
        Group AssignedPublicGroups = new Group();
        AssignedPublicGroups.DeveloperName = 'test_group';
        AssignedPublicGroups.Name = 'test_group'; 
        AssignedPublicGroups.type = 'Queue'; 
        insert AssignedPublicGroups; 
       system.debug('AssignedPublicGroups:' + AssignedPublicGroups.Id);      
       
      System.runAs(new User(Id=UserInfo.getUserId()))
        {
        
       GroupMember gp = new GroupMember(GroupId = AssignedPublicGroups.Id,UserOrGroupId = UserInfo.getUserId());
          insert gp;            
        
        QueuesObject testQueue = new QueueSObject(QueueID = AssignedPublicGroups.id, SObjectType = 'Lead');
            insert testQueue;
            system.debug('testQueue:' + testQueue.Id);
        }
        
        Lead Led = new Lead();
        Led.LastName = 'Mr';
        Led.FirstName = 'Test';
        Led.OwnerId = AssignedPublicGroups.Id;        
        Led.Status = 'New';
        Led.Company = 'Test';
        Led.Account__c = testAccount.id;
        Led.Contact__c = testContact.id;        
        Led.Product__c = newProduct.id;        
        led.Assigned_Group__c = 'test_group';
        Insert Led;  
        
        system.debug('Laedid:' + Led.id);
        system.debug('Laedowner:' + Led.ownerId);
        system.debug('Laedownertype:' + Led.owner.type);
         
        Set<id> leadid = new Set<id>();
        leadid.add(Led.id);   
        
        
        Campaign Campaigns = new Campaign(); 
        Campaigns.Name = 'test';
        Campaigns.Type = 'Outbound call campaign';        
        insert Campaigns;
           
        Campaign_History__c Campaignhist = new Campaign_History__c(); 
        Campaignhist.Account__c = testAccount.id;
        Campaignhist.Contact__c = testContact.id;   
        Campaignhist.Lead__c = Led.id;
        Campaignhist.Campaign__c = Campaigns.id;       
        insert Campaignhist;
        
        
        CampaignMember m1 = new CampaignMember();
        //m1.ContactId = myContact.Id; 
        m1.CampaignId = Campaigns.Id;
        m1.LeadId = Led.id;       
        insert m1;
        system.debug('CampaignMember:' + m1.id);
       Test.startTest(); 
        LeadRoutingLogic.LeadToRoute(leadid);
        LeadRoutingLogic.LeadRoute(leadid);
        LeadRoutingLogic.SortUserIdCountWrapperClass SUCWC = new LeadRoutingLogic.SortUserIdCountWrapperClass();
        SUCWC.userIds = 'test';
        SUCWC.aleadcount = 10.00;
      Test.stopTest();  
    }
}