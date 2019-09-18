@IsTest
public class LeadListInventoryRefreshTest {

    static testMethod void leadsInventorytest(){
       //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
    Account theAccount1 = TestDataFactory.createAccount('The Test Account', null, false);
    theAccount1.Primary_Email__c = 'theAccount@move.com';  
     insert theAccount1;   
    Account theAccount = TestDataFactory.createAccount('The Test Account', null, false);
    theAccount.Primary_Email__c = 'theAccount@move.com';
    theAccount.Type = Constants.OFFICE_ACCOUNT_TYPE;
    theAccount.Party_ID__c= theaccount1.id;   
    insert theAccount;
    system.debug('theAccount:' + theAccount.Id);
   Contact testContact = TestDataFactory.createContact('Test Contact','TestL',theAccount.Id,true,false);
    testContact.Email = 'test@move.com';
    insert testContact; 
        
        Product2 prod = new Product2(Name = 'Anti-infectives 2007', Family = 'Best Practices', IsActive = true,S_No__c=12, BigMachines__Part_Number__c='12345',ProductCode='12346');
            insert prod;
        
        Account_Listing__c acclist = new Account_Listing__c(Name='test',Listing_Count__c=5,Listing_Type__c='test',Zip__c='12345',Account_Name__c=theAccount.id, CFCB_City_Fast__c=12345,  
                                            CFCB_City_Flex__c=12345,  CFCB_City_Half_Fast__c=12345, CFCB_City_Half_Flex__c=12345, CFCB_CITYHALF_TIER__c=12345,  CFCB_CITY_TIER__c=12345,  
                                           CFCB_Full_Fast__c=12345,  CFCB_Full_Flex__c=12345,  CFCB_FULL_TIER__c=12345,  CFCB_Half_Fast__c=12345,  CFCB_Half_Flex__c=12345,  
                                            CFCB_HALF_TIER__c=12345,  DAP__c=12345, FAC_COMP_Qty__c=12345,    FAC_LB_Qty__c=12345,  FAC_MREC_Qty__c=12345,    
                                             FH__c=12345,  Hand_Raiser__c=12345, Featured_CMA_SM__c=12345, Home_Search__c =12345,Parent_Agent_Broker__c=theAccount.id);
        insert acclist;
        
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
        Led.Product__c = prod.id;
      //  Led.Product__r.BigMachines__Part_Number__c = 'test';
      //  Led.Product__r.ProductCode = 'test';
        
        //Led.Assigned_Group__c = 'test_group';
            testleads.add(Led);
        }
         insert testleads;
       
        
        try{
        apexPages.StandardSetController ssc = new apexpages.StandardSetController(testleads);
         LeadListInventoryRefresh leadssc = new LeadListInventoryRefresh(ssc);
         leadssc.updateInventory();
       //    pagereference p = leadssc.submit();
       //     list<lead> leads = leadssc.getselectedLeads();
        }
        catch(exception e){}
    }
    
    static testMethod void leadsInventoryNullTest(){
       //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;    
    Account theAccount = TestDataFactory.createAccount('The Test Account', null, false);
    theAccount.Primary_Email__c = 'theAccount@move.com';
    theAccount.Type = Constants.OFFICE_ACCOUNT_TYPE;    
    insert theAccount;
    system.debug('theAccount:' + theAccount.Id);
   Contact testContact = TestDataFactory.createContact('Test Contact','TestL',theAccount.Id,true,false);
    testContact.Email = 'test@move.com';
    insert testContact; 
        
        Product2 prod = new Product2(Name = 'Anti-infectives 2007', Family = 'Best Practices', IsActive = true,S_No__c=12, BigMachines__Part_Number__c='12345',ProductCode='12346');
            insert prod;
        
        Account_Listing__c acclist = new Account_Listing__c(Name='test',Listing_Count__c=5,Listing_Type__c='test',Zip__c='12345',Account_Name__c=theAccount.id, CFCB_City_Fast__c=12345,  CFCB_City_Flex__c=12345,  CFCB_City_Half_Fast__c=12345, CFCB_City_Half_Flex__c=12345, CFCB_CITYHALF_TIER__c=12345,  CFCB_CITY_TIER__c=12345,  CFCB_Full_Fast__c=12345,  CFCB_Full_Flex__c=12345,  CFCB_FULL_TIER__c=12345,  CFCB_Half_Fast__c=12345,  CFCB_Half_Flex__c=12345,  CFCB_HALF_TIER__c=12345,  DAP__c=12345, FAC_COMP_Qty__c=12345,    FAC_LB_Qty__c=12345,  FAC_MREC_Qty__c=12345,    FH__c=12345,  Hand_Raiser__c=12345, Featured_CMA_SM__c=12345, Home_Search__c =12345);
        insert acclist;
       
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
        Led.Product__c = prod.id;
      //  Led.Product__r.BigMachines__Part_Number__c = 'test';
      //  Led.Product__r.ProductCode = 'test';
        
        //Led.Assigned_Group__c = 'test_group';
            testleads.add(Led);
        }
         insert testleads;
       
        
        try{
        apexPages.StandardSetController ssc; 
         LeadListInventoryRefresh leadssc = new LeadListInventoryRefresh(ssc);
         leadssc.updateInventory();
       //    pagereference p = leadssc.submit();
       //     list<lead> leads = leadssc.getselectedLeads();
        }
        catch(exception e){}
    }
}