@IsTest
public class CreateTBAandVerifyCMListings_Test{    
 private static final Integer COUNTER = 10;
  
    static testMethod  void CreateTBAandVerifyCMListings_Test(){
    
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
            insert Dtrg;
    Waitlist_Urls__c wls = new Waitlist_Urls__c(Name= 'CheckCLC' , URL__c = 'https://uat-es-is.api.move.com');   
    insert wls;     
      //inserting Test Account.  
     Account acc = new Account();
     acc.name='XYZ';
     acc.Type = 'Broker';
     insert acc;   
      Account acc1 = new Account();
     acc1.name='XYZ';
     acc1.Type = 'Broker';
     insert acc1;   
    
     // Inserting Test Asset. 
       List<Asset> Assets = new List<Asset>();
        for(Integer index = 0; index < COUNTER; index++) {
       Assets.add(new Asset(
         Name                         = 'Test Asset123 - ',
        AccountId                     = acc.Id,       
         End_Date__c                  = Date.today().addDays(3),
         Status                       = 'Active',        
        Line_Type__c                  = 'Add',                  
        Asset_Type__c                 = 'Parent',
        Fulfillment_Status__c         = 'Fulfilled',       
        start_date__c                 = system.today(),   
        Credit_Status__c              = 'Processed'       
          ));
        }
        Insert Assets;
     //inserting test Time_Based_Actions__c 
     Time_Based_Actions__c TBA = new Time_Based_Actions__c ();
     TBA.Name = acc.Id;
     TBA.asset__c = Assets[0].Id;
     TBA.Action__c =  'Send Cancellation Email';
     TBA.Country__c = 'USA';
     TBA.State__c = 'Ny' ;
     TBA.County__c = 'TEST';
     TBA.City__c = 'New york';
     TBA.PartyID__c = '123456';
     insert TBA;
     Time_Based_Actions__c TBA1 = new Time_Based_Actions__c ();
     TBA1.Name = acc1.Id;
     TBA1.asset__c = Assets[1].Id;
     TBA1.Action__c =  'Send Warning Email';
     TBA1.Country__c = 'USA';
     TBA1.State__c = 'Ny' ;
     TBA1.County__c = 'TEST';
     TBA1.City__c = 'New york';
     TBA1.PartyID__c = '123456';
     insert TBA1;
     list<Time_Based_Actions__c > TBAs = new list<Time_Based_Actions__c > ();
     set<id> TBAIds = new set<id>();
     TBAIds.add(TBA.Id);
     TBAIds.add(TBA1.Id);
     TBAs.add(TBA);
     TBAs.add(TBA1);
     map<string,string> accIdToOppId = new map<string,string> ();
     accIdToOppId.put(acc.id , acc.id);
     
            Test.startTest();
            
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerators ());
            CreateTBAandVerifyCMListings.CreateTBAandVerifyCMListings(TBAs);
         CreateTBAandVerifyCMListings.CallInventoryAndCreateQuote(TBAIds,accIdToOppId);
           
            Test.stopTest();     
        
   }
 }