@isTest
public class CampaignMemberTriggerHandlerManager_Test{
    public static testMethod void mainMethod(){ 
    MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass(); 
    //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
    
    Account newAccount = new Account();
        newAccount.name='XYZ';
        newAccount.Phone = '+49-12345';
        newAccount.BillingStreet = 'Am Tierpark 16';
        newAccount.BillingCity = 'Atlanta';
        newAccount.BillingPostalCode = '54321';
        newAccount.BillingState = 'GA';
        newAccount.BillingCountry = 'USA';
        newAccount.Primary_Email__c= 'ra@gmail.com';
        newAccount.Home_Phone__c= '967622877';
        newAccount.Work_Phone__c = '456789';
        newAccount.Mobile1__c = '1234566';
        newAccount.Mobile2_Other__c = '1245787';
        newAccount.party_id__c = '206084041';
        newAccount.Type = 'Broker';
        newAccount.Auto_Renewal__c = True;
        newAccount.Territories__c = 'test';
        insert newAccount;
        
        Contact myContact = new Contact ();
        myContact.FirstName='Joe';
        myContact.LastName='Schmoe';
        myContact.Email='Joe.Schmoe@test.de';
        myContact.Account= newAccount;
        myContact.MailingStreet= newAccount.BillingStreet;
        myContact.MailingState = newAccount.BillingState;
        myContact.MailingCity=newAccount.BillingCity;
        myContact.MailingPostalCode=newAccount.BillingPostalCode;
        myContact.MailingCountry = newAccount.BillingCountry;
        myContact.Phone=newAccount.Phone;
        myContact.Type__c = 'Other';
        myContact.Active__c = true;
        insert myContact;
     List<Lead> LedAll = new List<Lead>();
       
        Lead Led = new Lead();
        Led.LastName = 'Mr';
        Led.FirstName = 'Test';
        Led.Status = 'New';
        Led.Company = 'Test';
        Led.Account__c = newAccount.id;
        Led.Contact__c = myContact.id;
        led.Assigned_Group__c = 'test_group';
        led.Marketing_Lead_Type__c ='Event';
        LedAll.add(Led);         
        Insert LedAll;  
        
    //Product2 newProduct = mtduc.CreateProductSingle();
    //Asset assets =  mtduc.CreateFullfilledAssetSingle();
    //Campaign Campaigns = mtduc.CreateCampaignSingle();
  
        Product2 newProduct = new Product2();
        newProduct.Name = 'TestProduct';
        newProduct.Commission_Category__c = 'Normal';    
        newProduct.Normalization_factor__c = 1.10;
        newProduct.Commission_Category__c = 'CFCB';
        newProduct.Fulfillment_Type__c = 'Manual';
        newProduct.Auto_Renewal__c = True;
        newProduct.ProductCode='SHOWCASE' ;
        newProduct.S_No__c = 3;
        insert newProduct;        
    
        Asset assets = new Asset();
        assets.Name = 'test';
        assets.Renewal_Status__c = 'Renew';
        assets.Auto_Renewal__c = 'No';
        assets.Asset_Type__c = 'Parent';
        assets.AccountId = newAccount.id;
        assets.Product2Id = newProduct.id;
        assets.Fulfillment_Status__c = 'Fulfilled';
        assets.Status = 'Active';
        assets.At_Risk__c = false;
        assets.Billing_Period__c = 'Monthly';
        assets.Start_Date__c = system.today();
        assets.End_Date__c = system.today().addDays(10);
        assets.Asset_Type__c = 'Parent';
        assets.Auto_Renewal__c  = 'Yes';
        assets.Line_Type__c = 'renew';
        assets.Price = 10.00;
        insert assets;
        
       Campaign Campaigns = new Campaign(); 
        Campaigns.Name = 'test';
        insert Campaigns;
    //Campaign_History__c CreateCampaignHistorySingle();
    Campaign_History__c Campaignhist = new Campaign_History__c(); 
        Campaignhist.Account__c = newAccount.id;
        Campaignhist.Contact__c = myContact.id;   
        Campaignhist.Lead__c = LedAll[0].id;
        Campaignhist.Campaign__c = Campaigns.id;
        insert Campaignhist;
        
        CampaignMember m1 = new CampaignMember();
        m1.ContactId = myContact.Id; 
        m1.status = 'sent';
        m1.CampaignId = Campaigns.Id;
        m1.LeadId = LedAll[0].id;
        insert m1;
        
        Map<id,CampaignMember> campmapold = new Map<id,CampaignMember>();
        campmapold.put(m1.id,m1);
        m1.status  = 'responded';
        Map<id,CampaignMember> campmapnew = new Map<id,CampaignMember>();
        campmapnew.put(m1.id,m1);
        
        CampaignMemberTriggerHandlerManager CMTH = new CampaignMemberTriggerHandlerManager();
        CMTH.updateCampaingns(campmapnew);
        CMTH.deleteCampaingns(campmapold);
        CMTH.UpdateCampaignMembers(campmapnew);
        CMTH.UpdateLeadProductCode(campmapnew);
        
    }
    }