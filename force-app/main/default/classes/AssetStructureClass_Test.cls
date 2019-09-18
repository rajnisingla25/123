@isTest
public class AssetStructureClass_Test{
    public static testMethod void mainMethod(){ 
    MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass(); 
    
     DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Account newAccount = new Account();
        newAccount.name='XYZ';
        newAccount.Phone = '+49-12345';
        newAccount.BillingStreet = 'Am Tierpark 16';
        newAccount.BillingCity = 'Cologne';
        newAccount.BillingPostalCode = '54321';
        newAccount.BillingState = 'Nordrhein-Westfalen';
        newAccount.BillingCountry = 'Germany';
        newAccount.Primary_Email__c= 'ra@gmail.com';
        newAccount.Home_Phone__c= '967622877';
        newAccount.Work_Phone__c = '456789';
        newAccount.Mobile1__c = '1234566';
        newAccount.Mobile2_Other__c = '1245787';
        newAccount.party_id__c = '206084041';
        newAccount.Type = 'Broker';
        //insert newAccount;
        newAccount = mtduc.CreateBrokerAccountSingle();
    Contact myContact = mtduc.CreateContactSingle();
   
        Asset assets = new Asset();
        assets.Name = 'test';
        assets.Renewal_Status__c = 'Renew';
        assets.Auto_Renewal__c = 'No';
        assets.Asset_Type__c = 'Parent';
        assets.AccountId = newAccount.id;
        assets.Fulfillment_Status__c = 'Fulfilled';
        assets.Status = 'Active';
        assets.At_Risk__c = false;
        assets.Billing_Period__c = 'Monthly';
        assets.Start_Date__c = system.today();
        assets.End_Date__c = system.today().addDays(10);
        assets.Auto_Renewal__c  = 'Yes';
        assets.Price = 10.00;
        assets.Include_Asset__c = true;
        insert assets;    
        assets.parent_asset__c = assets.id;
        
        Asset fulfillassets = new Asset();
        fulfillassets.Name = 'test1';
        fulfillassets.Renewal_Status__c = 'Renew';
        fulfillassets.Auto_Renewal__c = 'No';
        fulfillassets.Asset_Type__c = 'Fulfill to';
        fulfillassets.AccountId = newAccount.id;
        fulfillassets.Fulfillment_Status__c = 'Fulfilled';
        fulfillassets.Status = 'Active';
        fulfillassets.At_Risk__c = false;
        fulfillassets.Billing_Period__c = 'Monthly';
        fulfillassets.Start_Date__c = system.today();
        fulfillassets.End_Date__c = system.today().addDays(10);
        fulfillassets.Auto_Renewal__c  = 'Yes';
        fulfillassets.Include_Asset__c = true;
        fulfillassets.Price = 10.00;
        fulfillassets.parent_asset__c = assets.id;
        insert fulfillassets;    
        
        Asset Participantassets = new Asset();
        Participantassets.Name = 'test2';
        Participantassets.Renewal_Status__c = 'Renew';
        Participantassets.Auto_Renewal__c = 'No';
        Participantassets.Asset_Type__c = 'Participant';
        Participantassets.AccountId = newAccount.id;
        Participantassets.Status = 'Active';
        Participantassets.At_Risk__c = false;
        Participantassets.Billing_Period__c = 'Monthly';
        Participantassets.Start_Date__c = system.today();
        Participantassets.End_Date__c = system.today().addDays(10);
        Participantassets.Auto_Renewal__c  = 'Yes';
        Participantassets.Include_Asset__c = true;
        Participantassets.Price = 10.00;
        Participantassets.parent_asset__c = fulfillassets.id;
        insert Participantassets;    
        
        
    PageReference pageRef = Page.FinalAssetStructure;
    pageRef.getParameters().put('id',newAccount.id);
    Test.setCurrentPage(pageRef); 
    ApexPages.StandardController scr = new ApexPages.standardController(assets); 
    AssetStructureClass controller = new AssetStructureClass(scr);
    controller.DiaplayAssets();
    controller.DisplayActiveAssets();
    controller.display();
    controller.SaveAsset();
    controller.SaveAsset1();
    controller.NewAsset();
    controller.getlstAssetDisplay();
    controller.getlstAssetDisplay1();
    
    }
}