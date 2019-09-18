@isTest(seealldata=false)
public  class LeadScoreCalculationCls_Test{

@testSetup static void DataSetUpClass() {

        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Product_flag_mapping__c pfm = new Product_flag_mapping__c(Name='Own_Co_Broke__c',Field_API_name__c='Own_Co_Broke__c',Product_Code__c='COBROKE');
        insert pfm;
        List<Lead_Scoring_Settings__c> lstLeadScore = new List<Lead_Scoring_Settings__c>();
        Lead_Scoring_Settings__c lsww = new Lead_Scoring_Settings__c(Name='Waitlist Weight',Weight__c=1.0);
        lstLeadScore.add(lsww);
        Lead_Scoring_Settings__c lssww = new Lead_Scoring_Settings__c(Name='Waitlist Score Weight',Weight__c=1.0);
        lstLeadScore.add(lssww);
        Lead_Scoring_Settings__c lsfw = new Lead_Scoring_Settings__c(Name='Form Weight',Weight__c=1.0);
        lstLeadScore.add(lsfw);
        Lead_Scoring_Settings__c lsbs = new Lead_Scoring_Settings__c(Name='BuyerSide Weight',Weight__c=2.0);
        lstLeadScore.add(lsbs);
        Lead_Scoring_Settings__c lslsw = new Lead_Scoring_Settings__c(Name='Listing Weight',Weight__c=1.0);
        lstLeadScore.add(lslsw);
        Lead_Scoring_Settings__c lsow = new Lead_Scoring_Settings__c(Name='Office Weight',Weight__c=1.0);
        lstLeadScore.add(lsow);
        Lead_Scoring_Settings__c lscw = new Lead_Scoring_Settings__c(Name='Customer Weight',Weight__c=1.0);
        lstLeadScore.add(lscw);
        Lead_Scoring_Settings__c lsforw = new Lead_Scoring_Settings__c(Name='Former Weight',Weight__c=1.0);
        lstLeadScore.add(lsforw);
        Lead_Scoring_Settings__c lspw = new Lead_Scoring_Settings__c(Name='Prospect Weight',Weight__c=1.0);
        lstLeadScore.add(lspw);
        Lead_Scoring_Settings__c lscww = new Lead_Scoring_Settings__c(Name='Credit Worthiness Weight',Weight__c=1.0);
        lstLeadScore.add(lscww);
        Lead_Scoring_Settings__c lsaow = new Lead_Scoring_Settings__c(Name='Account owner Weight',Weight__c=1.0);
        lstLeadScore.add(lsaow);
        Lead_Scoring_Settings__c lsc1w = new Lead_Scoring_Settings__c(Name='Custom1 Weight',Weight__c=1.0);
        lstLeadScore.add(lsc1w);
        Lead_Scoring_Settings__c lsc2w = new Lead_Scoring_Settings__c(Name='Custom2 Weight',Weight__c=1.0);
        lstLeadScore.add(lsc2w);
        Lead_Scoring_Settings__c lsc3w = new Lead_Scoring_Settings__c(Name='Custom3 Weight',Weight__c=1.0);
        lstLeadScore.add(lsc3w);
        Lead_Scoring_Settings__c lsc4w = new Lead_Scoring_Settings__c(Name='Custom4 Weight',Weight__c=1.0);
        lstLeadScore.add(lsc4w);
        Lead_Scoring_Settings__c lsc5w = new Lead_Scoring_Settings__c(Name='Custom5 Weight',Weight__c=1.0);
        lstLeadScore.add(lsc5w);
        Lead_Scoring_Settings__c lsoow = new Lead_Scoring_Settings__c(Name='Owner Weight',Weight__c=1.0);
        lstLeadScore.add(lsoow);
        Lead_Scoring_Settings__c lsoow21 = new Lead_Scoring_Settings__c(Name='Waitlist Warm',Weight__c=1.0);
        lstLeadScore.add(lsoow21);
        Lead_Scoring_Settings__c lsoow22 = new Lead_Scoring_Settings__c(Name='Waitlist Pipeline',Weight__c=1.0);
        lstLeadScore.add(lsoow22);
        Insert lstLeadScore;
           List<Account> acclist = new List<Account>(); 
            
        Account theAccount = new Account(Name = 'First office');
        theAccount.ShippingStreet = 'Test Street';
        theAccount.ShippingCity = 'City';
        theAccount.Type = 'Realtor Office';
        theAccount.Total_Contract_Value__c = 70000;
        theAccount.ShippingState = 'State';
        theAccount.ShippingPostalCode = '12345';
        
            acclist.add(theAccount);
            
            Account theAccountAgent = new Account(Name = 'First office');
        theAccountAgent.ShippingStreet = 'Test Street';
        theAccountAgent.ShippingCity = 'City';
        theAccountAgent.Type = 'Realtor Agent';
        theAccountAgent.Account_Sub_Type__c = 'Prospect';
        theAccountAgent.ShippingState = 'State';
        theAccountAgent.ShippingPostalCode = '12345';
        acclist.add(theAccountAgent);
            insert acclist;
            OrderDecompController.testClassTriggerFlag  = true;
        Account_Relationship__c Arrc = new Account_Relationship__c();
        Arrc.Parent_Account__c = acclist[0].id;
        Arrc.Child_Account__c = acclist[1].id;
        Insert Arrc;
        //acclist.add(theTestAccount);
                // Inserting Test Product.
        Product2 theTestProduct         = new Product2(Name = 'Connection(SM) for Co-Brokerage',ProductCode='COBROKE',S_No__c= 2);
        insert theTestProduct;   
        Id StandardPriceBookId = Test.getStandardPricebookId();
        PricebookEntry thePricebookEntrie   = new PricebookEntry();
        thePricebookEntrie.Pricebook2Id     = StandardPriceBookId;
        thePricebookEntrie.Product2Id       = theTestProduct.Id;
        thePricebookEntrie.UnitPrice        = 1000;
        thePricebookEntrie.IsActive         = true;        
        insert thePricebookEntrie;
        Inventory_Data__c Idd = new Inventory_Data__c();
         Idd.Name = '89044';
         Idd.Inventory_Count__c = 20;
         Idd.Inventory_Count_Half__c = 10;
         Idd.Is_available__c = true;
         Idd.Last_updated__c = System.today();
         Idd.Market_Key__c = '8757';
         Idd.City__c = 'Westlake Village';
         Idd.State__c = 'CA';
         Idd.Promotion__c = 'GFRTYJ';
         //Idd.Is_available__c = true;
         Insert Idd;
         
         Inventory_Account__c Iaa = new Inventory_Account__c();
         Iaa.Account__c = acclist[0].id;
         Iaa.Inventory_Data__c = Idd.id;
         //Iaa.Waitlist__c = true;
         Insert Iaa;
         
         Iaa.Waitlist__c = True;
         update Iaa;
        Set<Id> setId = new Set<Id>();
        setId.add(Idd.Id);
        LeadScoreCalculationCls.pullInventoryWaitlistInformationRequest(setId);
}

    public static testMethod void mainMethod1(){   
         List<Account> acclist = [Select Id,Name,Primary_Email__c from Account]; 
        test.startTest();
         Inventory_Data__c Idd = new Inventory_Data__c();
         Idd.Name = '89044';
         Idd.Inventory_Count__c = 20;
         Idd.Inventory_Count_Half__c = 10;
         Idd.Is_available__c = false;
         Idd.Last_updated__c = System.today();
         Idd.Market_Key__c = '8757';
         Idd.City__c = 'Westlake Village';
         Idd.State__c = 'CA';
         Idd.Promotion__c = 'GFRTYJ';
         //Idd.Is_available__c = true;
         Insert Idd;
         
        insert new Waitlist_Urls__c(Name = 'SOALocalExpertCityScoringURL', Url__c = 'https//test.SOAURL.com/leadscoring');
 
         
         
         
         Inventory_Account__c Iaa = new Inventory_Account__c();
         Iaa.Account__c = acclist[0].id;
         Iaa.Inventory_Data__c = Idd.id;
         //Iaa.Buyers_Side__c = true;
         //Iaa.Form__c = true;
         //Iaa.Listing__c = true;
         Iaa.Custom_field5__c = true;
         //Iaa.Is_available__c = True;
         //Iaa.Waitlist__c = true;
         //Iaa.Waitlist_Half__c = true;
         Insert Iaa;
         Iaa.Waitlist__c = true;
         update Iaa;
         Iaa.Waitlist__c = false;
         Iaa.Form__c = true;
         update Iaa;
         Iaa.Form__c = false;
         Iaa.Buyers_Side__c = true;
         update Iaa;
         Iaa.Buyers_Side__c = false;
         Iaa.Listing__c = true;
         update Iaa;
         Iaa.Listing__c = false;
         Iaa.office__c = true;
         update Iaa;
         Iaa.office__c = false;
         Iaa.Custom_field1__c = true;
         update Iaa;
         Iaa.Custom_field1__c = false;
         Iaa.Custom_field2__c = true;
         update Iaa;
         Iaa.Custom_field2__c = false;
         Iaa.Custom_field3__c = true;
         update Iaa;
         Iaa.Custom_field3__c = false;
         Iaa.Custom_field4__c = true;
         update Iaa;
         Iaa.Custom_field4__c = false;
         Iaa.Custom_field5__c = true;
         update Iaa;
         Iaa.Custom_field5__c = false;
         Iaa.Has_Assets__c = true;
         update Iaa;
         
         LeadScoreCalculationCls.available_inventories aii = new LeadScoreCalculationCls.available_inventories();
         String strr1 = aii.party_id;
         String strr2 = aii.part_number;
         String strr3 = aii.market_name;
         String strr4 = aii.postal_code;
         String strr5 = aii.market_type;
         String strr6 = aii.product_name;
         String strr7 = aii.product_size;
         Decimal strr8 = aii.available_flex;
         Decimal strr9 = aii.available_fast;
         Decimal strr10 = aii.total_available;
         Decimal strr11 = aii.available_presale_flex;
         Decimal strr12 = aii.available_presale_fast;
         Decimal strr13 = aii.price_tier;
         Decimal strr14 = aii.flex_unit_price;
         Decimal strr15 = aii.fast_unit_price;
        
        LeadScoreCalculationCls.pullInventoryWaitlistInformation(new Set<Id>());
        LeadScoreCalculationCls.pullInventoryWaitlistInformationforCity(new Set<Id>());
        test.stopTest();

  }
  
  public static testMethod void mainMethod4(){   
         List<Account> acclist = [Select Id,Name,Primary_Email__c,Total_Contract_Value__c from Account where Type='Realtor Agent']; 
         List<Account> accOfclist = [Select Id,Name,Primary_Email__c,Total_Contract_Value__c from Account where Type='Realtor Office']; 
         Set<Id> setIds = new Set<Id>();
         Set<Id> setOAIds = new Set<Id>();
        test.startTest();
         Inventory_Data__c Idd = new Inventory_Data__c();
         Idd.Name = '89044';
         Idd.Inventory_Count__c = 20;
         Idd.Inventory_Count_Half__c = 10;
         Idd.Is_available__c = false;
         Idd.Last_updated__c = System.today();
         Idd.Market_Key__c = '8757';
         Idd.City__c = 'Westlake Village';
         Idd.State__c = 'CA';
         Idd.Red_market__c = true;
         Idd.Green_market__c = true;
         Idd.Yellow_market__c = true;
         Idd.Promotion__c = 'GFRTYJ';
         //Idd.Is_available__c = true;
         Insert Idd;
         setIds.add(Idd.id);
         
         Inventory_Account__c Iaa = new Inventory_Account__c();
         Iaa.Account__c = acclist[0].id;
         Iaa.Inventory_Data__c = Idd.id;
         //Iaa.Buyers_Side__c = true;
         //Iaa.Form__c = true;
         //Iaa.Listing__c = true;
         Iaa.Custom_field5__c = true;
         Iaa.Waitlist__c = true;
         
         Iaa.Form__c = true;
         
         Iaa.Buyers_Side__c = true;
         
         Iaa.Listing__c = true;
         
         Iaa.office__c = true;
         
         
         Iaa.Has_Assets__c = true;
         //update Iaa;
         Insert Iaa;
         setOAIds.Add(accOfclist[0].id);
       
        
        LeadScoreCalculationCls.CalculateOpcityScoreFuture(setIds);
        
        BatchProcessOfficeScore bpqs = new BatchProcessOfficeScore();
        bpqs.setIds = setOAIds;
        Id batchJobId = Database.executeBatch(bpqs, 1);
        test.stopTest();

  }
   
   public static testMethod void mainMethod2(){   
         List<Account> acclist = [Select Id,Name,Primary_Email__c from Account]; 
        test.startTest();
         Inventory_Data__c Idd = new Inventory_Data__c();
         Idd.Name = '89044';
         Idd.City__c = 'Westlake Village';
         Idd.State__c = 'CA';
         Idd.Inventory_Count__c = 20;
         Idd.Inventory_Count_Half__c = 10;
         Idd.Is_available__c = false;
         Idd.Error__c = true;
         Idd.Soa_Error__c = false;
         Idd.Error_Message__c = 'error is there';
         Idd.Last_updated__c = System.today();
         Idd.Market_Key__c = '8757';
         Idd.Promotion__c = 'GFRTYJ';
         //Idd.Is_available__c = true;
         Insert Idd;
         //BatchProcessFailedInventory bps = new BatchProcessFailedInventory();
         //Id batchJobId = Database.executeBatch(new BatchProcessFailedInventory(), 1);
         //delete Idd;
         LeadScoreCalculationCls.isSkipTrg();
        test.stopTest();

  }
  
  public static testMethod void mainMethod3(){  
  List<Inventory_Data__c> lstInventoryData = [Select Id,Name from Inventory_Data__c];  
  delete lstInventoryData;
         List<Account> acclist = [Select Id,Name,Primary_Email__c from Account]; 
        test.startTest();
         Inventory_Data__c Idd = new Inventory_Data__c();
         Idd.Name = '89044';
         Idd.City__c = 'Westlake Village';
         Idd.State__c = 'CA';
         Idd.Inventory_Count__c = 0;
         Idd.Inventory_Count_Half__c = 0;
         Idd.SOA_Error_Full_Count__c = 2;
         Idd.Is_available__c = false;
         Idd.Error__c = false;
         Idd.Soa_Error__c = true;
         Idd.Error_Message__c = 'error is there';
         Idd.Last_updated__c = System.today();
         Idd.Market_Key__c = '8757';
         Idd.Promotion__c = 'GFRTYJ';
         //Idd.Is_available__c = true;
         Insert Idd;
         //BatchProcessFailedInventory bps = new BatchProcessFailedInventory();
         Id batchJobId = Database.executeBatch(new BatchProcessFailedInventory(), 1);
      
        test.stopTest();

  }
}