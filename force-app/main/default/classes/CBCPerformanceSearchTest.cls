//****************************************************************************************
//Name          : CBCPerformanceSearchTest
//Date          : 11-JAN-2016
//Created by    : NTT Data
//Author        : Stanley Sequeira
//Description   : Test Class which covers the CBCPerformanceSearch Class functionality
//               
// *****************************************************************************************

/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */

@isTest
public class CBCPerformanceSearchTest {

private static boolean fast;
    
    @isTest static void testCBCReport(){

         DisabledTrigger__c Dtrg            = new DisabledTrigger__c();
         Dtrg.TaskTrigger__c                = 'datamigration@move.com.sit';
         Dtrg.AssetTrigger__c               = 'datamigration@move.com.sit';
         Dtrg.AccountTrigger__c             = 'datamigration@move.com.sit';
         Dtrg.Name                          = 'Disabled';
         insert Dtrg;
         
 
         InventoryAssetDetails__c setting1 = new InventoryAssetDetails__c(name ='invurl',InventoryAssetDetailsURL__c='https://uat-es-ap.api.move.com/json/reply/SearchAssetLeadPeformance');
         insert setting1;     
        
        List<Account> accountList           = new List<Account>();
        Account theTestAccount              = TestDataFactory.createAccount('The Test Account', null, false);
        theTestAccount.Primary_Email__c     = 'testEmail1@test.com';
        theTestAccount.Type                 = Constants.OFFICE_ACCOUNT_TYPE;
        theTestAccount.Party_ID__c          = theTestAccount.Id;
        theTestAccount.BillingCity          = 'test';
        theTestAccount.name                 = 'test';
        theTestAccount.BillingState         = 'test'; 
        theTestAccount.BillingPostalCode    = 'test';
        theTestAccount.Account_Sub_Type__c  = Constants.ACCOUNT_SUBTYPE_PROSPECT;
       
        accountList.add(theTestAccount);
        insert AccountList;

        Product2 prod                   = createProduct();
        

        Asset asst1                     = new Asset();
        asst1.Name                      = 'Test Asset - ';
        asst1.AccountId                 = AccountList[0].Id;
        asst1.Price                     = 10;
        asst1.End_Date__c               = Date.today().addDays(3);
        asst1.Auto_Renewal__c           = 'Yes';
        asst1.Product_Logins__c         ='www.login.salesforce.com/';
        asst1.Status                    = 'Active';
        asst1.BOP_Code__c               ='';
        asst1.External_ID__c            ='1-898249952';                 
        asst1.Line_Type__c              = 'Add';  
        asst1.market__c                 = 'market';
        asst1.Asset_Type__c             = 'Parent';
        asst1.Fulfillment_Status__c     = 'Fulfilled';
        asst1.Get_CP_Login_Status__c    ='Ready';
        asst1.Product2Id                = prod.Id;
        insert asst1;
        
        Asset asst2                     = new Asset();
        asst2.Name                      = 'Test Asset - ';
        asst2.AccountId                 = AccountList[0].Id;
        asst2.Price                     = 10;
        asst2.End_Date__c               = Date.today().addDays(3);
        asst2.Auto_Renewal__c           = 'Yes';
        asst2.Product_Logins__c         ='www.login.salesforce.com/';
        asst2.Status                    = 'Active';
        asst2.BOP_Code__c               ='';
        asst2.External_ID__c            ='1-898249953';                 
        asst2.Line_Type__c              = 'Add';  
        asst2.market__c                 = 'market';
        asst2.Asset_Type__c             = 'Fulfill To';
        asst2.Fulfillment_Status__c     = 'Fulfilled';
        asst2.Get_CP_Login_Status__c    ='Ready';
        asst2.Product2Id                = prod.Id;
        asst2.Parent_Asset__c           = asst1.Id;
        insert asst2;
        
        system.debug('@@ asst2 @@'+asst2);
    
         List<Asset> theTestAssets = new List<Asset>(); 
         
         for(Integer i=0;i<15;++i){

            theTestAssets.add(new Asset(
             Name                           = 'Test Asset1 - '+i,
             AccountId                      = AccountList[0].Id,
             Price                          = 10,
             End_Date__c                    = Date.today()+10,
             Auto_Renewal__c                = 'Yes',
             Product_Logins__c              ='www.login.salesforce.com/',
             Status                         = 'Active',
             BOP_Code__c                    ='',
             Parent_Asset__c                = asst1.id,  
            // External_ID__c                 ='1-89824995'+i,                  
             Product2                       = prod,
             Line_Type__c                   = 'Add',                     
             Asset_Type__c                  = 'Parent',
             Fulfillment_Status__c          = 'Fulfilled',
             Get_CP_Login_Status__c         ='Ready'
            ));
     }
        
    insert theTestAssets;
     
      test.startTest();
      AccountAssetInvWrapper aaIw                       = new AccountAssetInvWrapper();
      List<InventoryInformation> invList                = new List<InventoryInformation>();
      InventoryInformation inv                          = new InventoryInformation();
      inv.AssetId                                       = String.valueOf(asst1.Id);
      invList.add(inv);
      
      InventoryInformation.AssetLeadDetails inald       = new InventoryInformation.AssetLeadDetails();
      inald.LeadId                                      = 12345;
      inald.FirstName                                   = 'FirstName';
      inald.LastName                                    = 'LastName';
      inald.Email                                       = 'test@test.com';
      
      AccountAssetInvWrapper.AssetLeadDetails aaiald    = new AccountAssetInvWrapper.AssetLeadDetails(inald);
      AccountAssetInvWrapper.AssetDetails aaiad         = new AccountAssetInvWrapper.AssetDetails(asst1,inv);
      
      List<AccountAssetInvWrapper.AssetDetails> accAssetDetailsList         = new List<AccountAssetInvWrapper.AssetDetails>();
      accAssetDetailsList.add(aaiad);
      List<AccountAssetInvWrapper.AssetLeadDetails> accAssetLeadDetailsList = new List<AccountAssetInvWrapper.AssetLeadDetails>();
      accAssetLeadDetailsList.add(aaiald);
      aaIw.dwrap                                        = accAssetDetailsList;
      aaIw.ldwrap                                       = accAssetLeadDetailsList;
      AccountAssetInvWrapper aaIw1                      = new AccountAssetInvWrapper(accountList[0],theTestAssets,invList);
      CBCPerformanceSearch.JSONInput WRAPjson           = new CBCPerformanceSearch.JSONInput(asst1);
        
        
        apexpages.currentPage().getparameters().put('whatId',AccountList[0].Id);
        CBCPerformanceSearch controller = new CBCPerformanceSearch(new ApexPages.StandardController(AccountList[0]));
        
        controller.relatedAssets.add(aaIw1);
      
        system.debug('@@ aaiald @@'+aaiald);
        List<AccountAssetInvWrapper.AssetLeadDetails> assetLeadList =  controller.getLeadDetails;
        
        controller.first();
        controller.last();
        controller.previous();
        controller.next();
        Boolean nextVar         = controller.hasNext;
        Boolean prevVar         = controller.hasPrevious;
        Integer pageVar         = controller.pageNumber;
        Integer totalVar        = controller.totalPages;
         
       
     // Export to Excel
        controller.exportToExcel();
        controller.fastFlex();
        fast    =   true; 
        controller.flexFast();
        fast    =   false;   
        
        apexpages.currentPage().getparameters().put('whatId',AccountList[0].Id);
        apexpages.currentPage().getparameters().put('status','Active');
        CBCPerformanceExportToExcelHandler  exportHandler                       =  new CBCPerformanceExportToExcelHandler (new ApexPages.StandardController(AccountList[0]));    
        exportHandler.relatedAssets.add(aaIw1);
        List<AccountAssetInvWrapper.AssetLeadDetails> assetLeadExportList       =  exportHandler.getLeadDetails;
        CBCPerformanceExportToExcelHandler.JSONInput WRAPjsonExport             = new CBCPerformanceExportToExcelHandler.JSONInput(asst1);
        String xlsHeader                                                        = exportHandler.xlsHeader;
        
        CBCPerformanceExportToExcelHandler  exportConstructor                   =  new CBCPerformanceExportToExcelHandler();
        
        
     // Market Performance Search
        apexpages.currentPage().getparameters().put('marketid','market');
        
        CBCMarketPerfSearch marketSearchController                              = new CBCMarketPerfSearch();
        InventoryInformationAssets iia                                          = new InventoryInformationAssets();
        iia.AssetId                                                             = '1-898249953';
        iia.WebLead                                                             = 10;
        
        AssetMarketInvWrapper   amiw                                            = new AssetMarketInvWrapper(asst2,iia);
        system.debug('@@ amiw @@'+amiw);
        List<AssetMarketInvWrapper> amiwList                                    = new List<AssetMarketInvWrapper>();
        amiwList.add(amiw);
        marketSearchController.lstwrap                                          = amiwList;
        system.debug('@@ marketSearchController.lstwrap @@'+marketSearchController.lstwrap);
        
        system.debug('@@ AssetMarketInvWrapper @@'+amiw);
        marketSearchController.relatedAssets = marketSearchController.lstwrap;
        
        List<AssetMarketInvWrapper> someList = marketSearchController.relatedAssets;
        system.debug('@@ marketSearchController.relatedAssets @@ '+someList);
        
        test.stopTest();
    
   }
   
   public static Product2 createProduct(){
        Product2 newProduct                 = new Product2();
        newProduct.Name                     = 'Connection(SM) for Co-Brokerage';
        newProduct.Commission_Category__c   = 'Normal';    
        newProduct.Normalization_factor__c  = 1.10;
        newProduct.Commission_Category__c   = 'CFCB';
        newProduct.Fulfillment_Type__c      = 'Manual';
        newProduct.Auto_Renewal__c          = True;
        newProduct.ProductCode              ='COBROKE' ;
        newProduct.S_No__c                  = 2;
        insert newProduct;
        return newProduct;
    }
   
   
}