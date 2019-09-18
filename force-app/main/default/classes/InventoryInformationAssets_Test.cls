@istest
public class InventoryInformationAssets_Test{

    
    static testmethod void inventorymethod(){
    MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
          //ProductExclusionTrigger
          mtduc.CreateDisabledTriggerSingle();
           mtduc.CreateBrokerAccountSingle();
   list<InventoryInformation.AssetLeadDetails>  listHelper = new list<InventoryInformation.AssetLeadDetails>();
   for(integer i=0;i<=5;i++){
   InventoryInformation.AssetLeadDetails innerController = new InventoryInformation.AssetLeadDetails();
      innerController.LeadId =123456789;
       innerController.Guid='string';
       
        innerController.SubmitDate='12/26/2015';
        innerController.Source='source';
        //innerController.Comment='comments';
        innerController.LeadType='types';
        innerController.AssetId='1234567890';
        innerController.MasterPropertyRecordId='123412341';
        innerController.PropertyId='90876';
        innerController.ListingPermanentLink='123456789';
        innerController.ListingAddress ='street';
        innerController.ListingCity='citystreet';
        innerController.ListingStateId ='stateid';
        innerController.ListingPostalCode ='pocode';
        innerController.ListingStatus ='status';
        innerController.ListingPrice =12.0;
        innerController.SourceEmailAddress='test@mailinator.com';
        innerController.SourceName ='sources';
        innerController.FirstName='firstname';
        innerController.LastName ='lastnames';
        innerController.Email ='mail@mail.com';
        innerController.Phone='123456789';
        innerController.CreateDate ='12/28/2015';
        listHelper.add(innerController);
    }
    
      InventoryInformation helper = new InventoryInformation();
      helper.AssetId='145782547';
    helper.FromDate='456788913';
    helper.ToDate='12/15/15';
    helper.AssetLeadDetailCount=1234;
    helper.AverageListingPriceWebLead=12.0;
    helper.AverageListingPriceMobileLead=13.5;
    helper.AverageListingPriceAllLead=14.0;
    helper.WebLead=1547;
    helper.MobileLead=1478;
    helper.PaidLead =1232;
    helper.CourtesyLead=147;
    helper.TotalLeads=15;
    helper.FullFlexAvailable=17;
    helper.FullFastAvailable=17;
    helper.FullPriceTier=14;
    helper.FullFlexUnitPrice=14.0;
    helper.FullFastUnitPrice=13.0;
    helper.HalfPriceTier=17;
    helper.HalfFlexAvailable=15;
    helper.HalfFastAvailable=14;
    helper.HalfFlexUnitPrice=21.0;
    helper.HalfFastUnitPrice =15.3;
    helper.OverSoldFull=15.2;
    helper.OverSoldHalf=14.0;
    helper.AssetLeadDetails =listHelper;

    }
    
    static testmethod void inventoryinformationmethod(){
         DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
    // Inserting Test Account.
    Account theTestAccount = TestDataFactory.createAccount('The Test Account', null, false);
    theTestAccount.Primary_Email__c = 'hsingh@appirio.com';
    insert theTestAccount;
    MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
          //ProductExclusionTrigger
          mtduc.CreateDisabledTriggerSingle();
           mtduc.CreateBrokerAccountSingle();
           mtduc.CreateRealtorOfficeAccountSingle();
          mtduc.CreateRealtorAgentAccountSingle();
          mtduc.CreateContractSingle();
          mtduc.CreateBrockerOfficeAccountRelationshipSingle();
          mtduc.CreateRealtorAgentAccountRelationshipSingle();
          mtduc.CreateProductSingle();
          mtduc.CreatePricebookEntrySingle();
        Asset a=  new Asset(
         Name = 'Test Asset - 1',
         AccountId = mtduc.newAccount.Id,
         Price = 10,
         End_Date__c = Date.today().addDays(3),
         Auto_Renewal__c = 'Yes',
         Status = 'Active'
        );
        insert a;
        
        mtduc.CreateFullfilledAssetSingle();
     
           list<InventoryInformationAssets.AssetLeadDetails>  listHelper = new list<InventoryInformationAssets.AssetLeadDetails>();
           for(integer i=0;i<=5;i++){
           InventoryInformationAssets.AssetLeadDetails innerController = new InventoryInformationAssets.AssetLeadDetails();
              innerController.LeadId =12345678;
                innerController.LeadId =12345678;//integer.valueOf('a00123456789a00067');
               innerController.Guid='string';
                innerController.SubmitDate='12/26/2015';
                innerController.Source='source';
                innerController.Comment='comments';
                innerController.LeadType='types';
                innerController.AssetId=mtduc.assets.id;
                innerController.MasterPropertyRecordId=mtduc.assets.id;//'ao21234567890rw123';
                innerController.PropertyId='90876';
                innerController.ListingPermanentLink=mtduc.assets.id;//'ao21234567890rw123';
                innerController.ListingAddress ='street';
                innerController.ListingCity='citystreet';
                innerController.ListingStateId ='stateid';
                innerController.ListingPostalCode ='pocode';
                innerController.ListingStatus ='status';
                innerController.ListingPrice =12.0;
                innerController.SourceEmailAddress='test@mailinator.com';
                innerController.SourceName ='sources';
                innerController.FirstName='firstname';
                innerController.LastName ='lastnames';
                innerController.Email ='mail@mail.com';
                innerController.Phone='123456789';
                innerController.CreateDate ='12/28/2015';
                listHelper.add(innerController);
            }
            
              InventoryInformationAssets helper = new InventoryInformationAssets();
               helper.AssetId=mtduc.assets.id;//'ao21234567890rw123';
            helper.FromDate='456788913';
            helper.ToDate='12/15/15';
            helper.AssetLeadDetailCount=1234;
            helper.AverageListingPriceWebLead=12.0;
            helper.AverageListingPriceMobileLead=13.5;
            helper.AverageListingPriceAllLead=14.0;
            helper.WebLead=1547;
            helper.MobileLead=1478;
            helper.PaidLead =1232;
            helper.CourtesyLead=147;
            helper.TotalLeads=15;
            helper.FullFlexAvailable=17;
            helper.FullFastAvailable=17;
            helper.FullPriceTier=14;
            helper.FullFlexUnitPrice=14.0;
            helper.FullFastUnitPrice=13.0;
            helper.HalfPriceTier=17;
            helper.HalfFlexAvailable=15;
            helper.HalfFastAvailable=14;
            helper.HalfFlexUnitPrice=21.0;
            helper.HalfFastUnitPrice =15.3;
            helper.OverSoldFull=15.2;
            helper.OverSoldHalf=14.0;
            helper.AssetLeadDetails =listHelper;
        AssetMarketInvWrapper tempController = new AssetMarketInvWrapper(mtduc.assets,helper);
            }
}