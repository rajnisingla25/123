@isTest
public class Z_InvoicecollectionSchedulable_Test{
    public static String CRON_EXP = '0 0 0 * * ?';
    public static testMethod void setupData() {
        Account theAccount = TestDataFactory.createAccount('The Test Account', null, false);
        theAccount.Primary_Email__c = 'hsingh@appirio.com';
        theAccount.Type = 'Broker';
        theAccount.Name = 'Broker2';
        theAccount.Customer_Care_Calls__c = 'Yes';
        theAccount.Sales_Calls__c = 'Yes';
        theAccount.Marketing_Emails__c = 'Yes';
        theAccount.Billing_Preference__c = 'Invoice-CC';
        theAccount.Agent_SLE__c = 'Yes';
        theAccount.Total_Contract_Value__c = 15000;
        theAccount.Exclusion_Notes__c = 'Test Exclusion Notes.';
                             
         Account theAccount3 = TestDataFactory.createAccount('The Test Account', null, false);
        theAccount3.Primary_Email__c = 'hsingh@appirio.com';
        theAccount3.Type = 'Broker';
        theAccount3.Name = 'Broker2';
        theAccount3.Customer_Care_Calls__c = 'Yes';
        theAccount3.Sales_Calls__c = 'Yes';
        theAccount3.Marketing_Emails__c = 'Yes';
        theAccount.Billing_Preference__c = 'CC-Direct';
        theAccount3.Agent_SLE__c = 'Yes';
        theAccount3.Total_Contract_Value__c = 2;
        theAccount3.Exclusion_Notes__c = 'Test Exclusion Notes.';              
      
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'test@test.com');
        insert Dtrg;
        
        List<Account> theTestAccounts = new List<Account>();
        theTestAccounts.add(theAccount);
        theTestAccounts.add(theAccount3);
        insert theTestAccounts;    
     list<AccountTeamMember>   TmemberList = new list<AccountTeamMember>();
        for(Account acc : theTestAccounts){
            TmemberList.add(new AccountTeamMember(TeamMemberRole = 'Collections Rep', AccountId=acc.Id, UserId=userInfo.getUserId() ));
        } 
        insert TmemberList;
        Zuora__CustomerAccount__c BiilAccount = new Zuora__CustomerAccount__c();
        BiilAccount.Zuora__Account__c = theTestAccounts[0].Id;
        insert BiilAccount;
        
        Zuora__ZInvoice__c inv = new Zuora__ZInvoice__c();
        inv.Name = 'TestInv';
        inv.Zuora__Status__c = '';
        inv.Zuora__Account__c = theTestAccounts[0].Id;
        inv.Zuora__DueDate__c = system.today();
        inv.Zuora__Balance2__c = 5;
        inv.Invoice_Status__c = 'Cancelled';             
       
        Zuora__ZInvoice__c inv2 = new Zuora__ZInvoice__c();
        inv2.Name = 'TestInv';
        inv2.Zuora__Status__c = '';
        inv2.Zuora__Account__c = theTestAccounts[1].Id;
        inv2.Zuora__DueDate__c = system.today();
        inv2.Zuora__Balance2__c = 5;
        inv2.Invoice_Status__c = 'Cancelled';             
       
        List<Zuora__ZInvoice__c> Invoices = new List<Zuora__ZInvoice__c>();
        Invoices.add(Inv);
        Invoices.add(Inv2);
        insert Invoices;
                     
        Zuora__Subscription__c  Sub= new Zuora__Subscription__c();
        Sub.Zuora__Account__c = theTestAccounts[0].Id;
        Sub.Name = '283838';
        insert Sub;
        system.debug('subId ' + Sub.id);
        
        Zuora__Payment__c  Payment= new Zuora__Payment__c();
        Payment.Zuora__Account__c = theTestAccounts[0].Id;
        Payment.Zuora__Status__c = 'Error';
        Payment.Zuora__BillingAccount__c = BiilAccount.Id;
        insert Payment;
        
        
        Zuora__PaymentInvoice__c Invpay = new Zuora__PaymentInvoice__c();       
        Invpay.Zuora__Invoice__c = Invoices[0].Id;
        Invpay.Zuora__Payment__c = Payment.Id;
        Invpay.Zuora__ApplyAmount__c = 2;
        insert Invpay;
        
        
        
        Invoice_Item__c Invitem= new Invoice_Item__c();
        Invitem.Invoice__c = Invoices[0].Id;
        Invitem.Subscription__c = Sub.Id;       
        insert Invitem;
        
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtId = AccountRecordTypeInfo.get('Collections').getRecordTypeId();
        
        CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Collection' , Record_Type_Id__c = rtId);
        insert setting;
        
        Schema.DescribeSObjectResult cfrSchema1 = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo1 = cfrSchema1.getRecordTypeInfosByName(); 
        Id rtId1 = AccountRecordTypeInfo1.get('Retention').getRecordTypeId();
        
        CaseRecordTypes__c setting1 = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtId1);
        insert setting1;
        Switch_AccountRelationshipTrigger__c art = new Switch_AccountRelationshipTrigger__c(name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
        insert art; 
        
        case cse = new case();
        cse.AccountId  = theTestAccounts[0].Id;
        cse.recordTypeId = rtId;
        cse.Status = 'New';
        cse.Origin = 'Web';
        cse.Type = 'C3 Collections';
        cse.Legacy_Product__c = True;
        cse.SubStatus__c = 'test';
        cse.Subject = '1st Invoice did not Collect on Asset';
        cse.CreatedDate  = System.today().adddays(-5);
                        
         case cse2 = new case();
        cse2.AccountId  = theTestAccounts[1].Id;
        cse2.recordTypeId = rtId;
        cse2.Status = 'New';
        cse2.Origin = 'Web';
        cse2.Type = 'Collections';
        cse2.Legacy_Product__c = True;
        cse2.SubStatus__c = 'test12';
        cse2.Subject = 'Collections Case with Past Due Invoices';
        cse2.CreatedDate  = System.today().adddays(-5);
              
        case cse3 = new case();
        cse3.AccountId  = theTestAccounts[1].Id;
        cse3.recordTypeId = rtId;
        cse3.Status = 'New';
        cse3.Origin = 'Web';
        cse3.Type = 'C3 Collections';
        cse3.Legacy_Product__c = True;
        cse3.SubStatus__c = 'test';
        cse3.Subject = '1st Invoice did not Collect on Asset';
        cse3.CreatedDate  = System.today().adddays(-5);
                       
        List<case> Caselist = new List<case>();
        Caselist.add(cse);
        Caselist.add(cse2);
        Caselist.add(cse3);
        
        insert Caselist;
        
        Case_Invoice_Relationship__c cir = new Case_Invoice_Relationship__c();
        cir.Invoice__c = Invoices[0].Id;
        cir.case__c = Caselist[0].Id;               
        
        Case_Invoice_Relationship__c cir2 = new Case_Invoice_Relationship__c();
        cir2.Invoice__c = Invoices[1].Id;
        cir2.case__c = Caselist[1].Id;   
      
         List<Case_Invoice_Relationship__c> Cirlist = new List<Case_Invoice_Relationship__c>();
        Cirlist.add(cir);
        Cirlist.add(cir2);
Try{
SkipCaseTrigger.setSkipTrgTrue();
        insert Cirlist;
        }
        Catch(DmlException E){
  System.debug('The error occured in QA'+E.getNumDml());
  System.debug('The error occured in QA'+E.getMessage());
  System.debug('The error occured in QA'+E.getcause());
  System.debug('The error occured in QA'+E.getStackTraceString());
  }
        Test.startTest();
        System.schedule('Test Check', CRON_EXP, new Z_InvoicecollectionSchedulable());
        //Z_InvoicecollectionSchedulable ee = new Z_InvoicecollectionSchedulable();
        Z_InvoicecollectionSchedulable.isRepOnVacation(date.today(), date.today().adddays(-3));
        Z_InvoicecollectionSchedulable.transfercases();
        Z_InvoicecollectionSchedulable.fetchDMLOptions();
        Test.stopTest();                                         
    }    
}