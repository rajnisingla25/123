@isTest
public class QuoteProductOpportunityProductSch_Test {
static testMethod void QuoteProductOpportunityProductSch_Test(){
      //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
    insert Dtrg;
    Error_Notification_Email_Settings__c ent = new Error_Notification_Email_Settings__c(Name ='Email Addresses' ,Asset_Creation_Batch_Distribution__c = 'Test@test.com',Asset_Creation_Error_Emails__c = 'Test@test.com',View_Link__c = 'https://cs11.salesforce.com/02i?fcf=00BZ00000017ilI');
   insert ent; 
     //insert parentAccount;
    Account officeAccount = TestDataFactory.createAccount('Office Account', null, false);
    officeAccount.Primary_Email__c = 'parentAcc@move.com';
    officeAccount.type = 'Realtor Office';
    insert officeAccount;
     // Inserting Test Product.
        Product2 theTestProduct         = new Product2(
          Name                          = 'Connection(SM) for Co-Brokerage',
          Family                        = 'Hardware',
          S_No__c                       = 2,
          ProductCode                   = 'COBROKE'
        );
        insert theTestProduct;
    Id StandardPriceBookId = Test.getStandardPricebookId();
        PricebookEntry thePricebookEntrie   = new PricebookEntry();
        thePricebookEntrie.Pricebook2Id     = StandardPriceBookId;
        thePricebookEntrie.Product2Id       = theTestProduct.Id;
        thePricebookEntrie.UnitPrice        = 1000;
        thePricebookEntrie.IsActive         = true;        
        insert thePricebookEntrie;
    //insert Opportunity
     Opportunity theOpportunity = new Opportunity();
        theOpportunity.Name = 'The Opportunity';
        theOpportunity.StageName = 'Prospecting';
        theOpportunity.CloseDate = system.today();
        theOpportunity.AccountId = officeAccount.id;
        theOpportunity.Account_Type__c = 'Inside';
        theOpportunity.Is_Renewal_Opp__c = true;
        insert theOpportunity;         
        //insert BigMachines__Quote__c
       BigMachines__Quote__c OracleQuote = new BigMachines__Quote__c();
        OracleQuote.BigMachines_authorization_status__c = 'Success';
        OracleQuote.BigMachines_authorization_amount__c = 10.00;
        OracleQuote.BigMachines_first_month_payment__c = 30.00;
        OracleQuote.BigMachines__Account__c = officeAccount.id;
        OracleQuote.BigMachines__Opportunity__c = theOpportunity.id;
        OracleQuote.BigMachines__Is_Primary__c = true;
        OracleQuote.BigMachines_Quote_Type__c = 'New';
        OracleQuote.BigMachines__Process_Sync__c=false ;
        OracleQuote.BigMachines__Status__c = 'In Progress';
        OracleQuote.tigerLeadProductExists__c = true;       
        insert OracleQuote;
        //insert OpportunityLineItem
        OpportunityLineItem theOpportunityProduct = new OpportunityLineItem();
        theOpportunityProduct.PricebookEntryId = thePricebookEntrie.id;        
        theOpportunityProduct.OpportunityId = theOpportunity.id;
        theOpportunityProduct.Quantity = 10;
        theOpportunityProduct.TotalPrice = 1000;     
        theOpportunityProduct.BigMachines__Origin_Quote__c  = OracleQuote.Id;
        insert theOpportunityProduct;
          test.startTest();
       Try{
        QuoteProductOpportunityProductSchedule  sh1 = new QuoteProductOpportunityProductSchedule ();
        String sch = '0 0 23 * * ?'; 
        //system.schedule('QuoteProduct',sch,sh1);     
        }catch(exception e){}  
        Test.stopTest(); 
    }
  }