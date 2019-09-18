@isTest
public class LeadRoutingLogic_RoundRobinTest {
    
    public static testMethod void RoutingLogic_RoundRobin(){      
        
        Profile p = [select id from profile where name='Standard User'];
        User u = new User(alias = 'test', email='test.data@move.com',
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                          localesidkey='en_US', profileid = p.Id,
                          timezonesidkey='America/New_York', username='testdata@test.com'); 
        insert u;
        //Disabling the Trigger  
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        //Inserting Test Account       
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
        testAccount.Primary_Email__c = 'testAccount@move.com';
        insert testAccount; 
        
        //Inserting Test Contact
        Contact testContact = TestDataFactory.createContact('Test Contact','TestL',testAccount.Id,true,false);
        testContact.Email = 'testcontact@move.com';
        insert testContact;
        
        Group AssignedPublicGroups = new Group();
        AssignedPublicGroups.DeveloperName = 'test_group';
        AssignedPublicGroups.Name = 'test_group'; 
        AssignedPublicGroups.type = 'Queue'; 
        insert AssignedPublicGroups; 
        //system.debug('AssignedPublicGroups:' + AssignedPublicGroups.Id);    
        
       System.runAs(new User(Id=UserInfo.getUserId())){
            
            GroupMember gp = new GroupMember(GroupId = AssignedPublicGroups.Id,UserOrGroupId = UserInfo.getUserId());
            insert gp;            
            
            QueuesObject testQueue = new QueueSObject(QueueID = AssignedPublicGroups.id, SObjectType = 'Lead');
            insert testQueue;
            //system.debug('testQueue:' + testQueue.Id);
        }
        
        Lead Led = new Lead();
        Led.LastName = 'Mr';
        Led.FirstName = 'Test';
        Led.OwnerId = AssignedPublicGroups.Id;        
        Led.Status = 'New';
        Led.Company = 'Test';
        Led.Account__c = testAccount.id;
        Led.Contact__c = testContact.id;               
        led.Assigned_Group__c = 'test_group';
        Insert Led;  
        
        Set<id> leadid = new Set<id>();
        leadid.add(Led.id);   
        
        Round_Robin_State__c objRRS = new Round_Robin_State__c();
        objRRS.Name = AssignedPublicGroups.id;
        objRRS.Queue_Id__c = '12345';
        objRRS.Round_Robin_Id__c = 123;
        insert objRRS;
        
       Test.startTest(); 
        
        LeadRoutingLogic_RoundRobin objLeadRoutingLogic = new LeadRoutingLogic_RoundRobin();
        LeadRoutingLogic_RoundRobin.LeadToRoute(leadid);
        Test.stopTest();     
              
    }
    
   public static testMethod void RoutingLogic_RoundRobin2(){      
        
        Profile p = [select id from profile where name='Standard User'];
        User u = new User(alias = 'test', email='test.data@move.com',
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                          localesidkey='en_US', profileid = p.Id,
                          timezonesidkey='America/New_York', username='testdata@test.com'); 
        insert u;
        //Disabling the Trigger 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        //Inserting Test Account       
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
        testAccount.Primary_Email__c = 'testAccount@move.com';
        insert testAccount; 
        
        //Inserting Test Contact 
        Contact testContact = TestDataFactory.createContact('Test Contact','TestL',testAccount.Id,true,false);
        testContact.Email = 'rshekhawat@move.com';
        insert testContact;   
        
        Group AssignedPublicGroups = new Group();
        AssignedPublicGroups.DeveloperName = 'test_group';
        AssignedPublicGroups.Name = 'test_group'; 
        AssignedPublicGroups.type = 'Queue'; 
        insert AssignedPublicGroups; 
        //system.debug('AssignedPublicGroups:' + AssignedPublicGroups.Id);      
        
        System.runAs(new User(Id=UserInfo.getUserId())){
            
            GroupMember gp = new GroupMember(GroupId = AssignedPublicGroups.Id,UserOrGroupId = UserInfo.getUserId());
            insert gp;            
            
            QueuesObject testQueue = new QueueSObject(QueueID = AssignedPublicGroups.id, SObjectType = 'Lead');
            insert testQueue;
            //system.debug('testQueue:' + testQueue.Id);
        }
        
        Lead Led = new Lead();
        Led.LastName = 'Mr';
        Led.FirstName = 'Test';
        Led.OwnerId = AssignedPublicGroups.Id;        
        Led.Status = 'New';
        Led.Company = 'Test';
        Led.Account__c = testAccount.id;
        Led.Contact__c = testContact.id;             
        led.Assigned_Group__c = 'test_group';
        Insert Led;  
        
        Set<id> leadid = new Set<id>();
        leadid.add(Led.id);   
        
        Test.startTest(); 
        
        LeadRoutingLogic_RoundRobin objLeadRoutingLogic = new LeadRoutingLogic_RoundRobin();
        LeadRoutingLogic_RoundRobin.LeadToRoute(leadid);
        Test.stopTest();     
    }
    
}