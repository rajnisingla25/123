//****************************************************************************************
//Name          : BigMachinesQuoteTriggerHandlerTest
//Date          : 11-JAN-2016
//Created by    : NTT Data
//Author        : Stanley Sequeira
//Description   : Test Class which covers the BigMachinesQuoteTriggerHandler Class functionality
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
private class BigMachinesQuoteTriggerHandlerTest {

    @isTest static void testNewQuoteCreation() {
        // TO DO: implement unit test
        
        test.startTest();
        
        // Test for 'New'  
        Account acc = createAccount();
        Product2 newProduct = createProduct();
        createCaseRecordType();
        List<BigMachines__Quote__c> lstBigMachinesQuote = new List<BigMachines__Quote__c>();
        
        BigMachines__Quote__c quote                     = new BigMachines__Quote__c();
        quote.BigMachines__Account__c                   = acc.id;        
        quote.BigMachines__Status__c                    = 'Pending';
        quote.BigMachines_Quote_Type__c                 = 'New';
        quote.BigMachines__Site__c = Label.BigMachineSite;
        insert quote;
        lstBigMachinesQuote.add(quote);
        
        BigMachines__Quote_Product__c bquote            = new BigMachines__Quote_Product__c();
        bquote.BigMachines__Quote__c                    = quote.Id;
        bquote.Line_Type__c                             = 'Add';
        bquote.BigMachines__Product__c                  = newProduct.Id;
        bquote.BigMachines__Quantity__c                 = 1;
        bquote.BigMachines__Sales_Price__c              = 10;
        insert bquote;
        
        BigMachines__Quote_Product__c bquoteRenew       = new BigMachines__Quote_Product__c();
        bquoteRenew.BigMachines__Quote__c               = quote.Id;
        bquoteRenew.Line_Type__c                        = 'Renew';
        bquoteRenew.BigMachines__Product__c             = newProduct.Id;
        bquoteRenew.BigMachines__Quantity__c            = 1;
        bquoteRenew.BigMachines__Sales_Price__c         = 10;
        insert bquoteRenew;
        
        quote.BigMachines__Status__c        = 'Ordered';
        update quote;
        set<Id> setQuoteIds = new set<Id>();
        for(BigMachines__Quote__c qte:lstBigMachinesQuote){
        setQuoteIds.Add(qte.id);
        }
        BigMachinesQuoteTriggerHandler.assignQuoteTask(setQuoteIds);
        test.stopTest();
     
    }
    
    @isTest static void testNewTaskCreation() {
        // TO DO: implement unit test
        
        test.startTest();
        
        // Test for 'New'  
        Account acc = createAccount();
        Product2 newProduct = createProduct();
        createCaseRecordType();
        List<BigMachines__Quote__c> lstBigMachinesQuote = new List<BigMachines__Quote__c>();
        
        BigMachines__Quote__c quote                     = new BigMachines__Quote__c();
        quote.BigMachines__Account__c                   = acc.id;        
        quote.BigMachines__Status__c                    = 'Pending';
        quote.BigMachines_Quote_Type__c                 = 'New';
        quote.BigMachines__Site__c = Label.BigMachineSite;
        insert quote;
        lstBigMachinesQuote.add(quote);
        
        BigMachines__Quote_Product__c bquote            = new BigMachines__Quote_Product__c();
        bquote.BigMachines__Quote__c                    = quote.Id;
        bquote.Line_Type__c                             = 'Add';
        bquote.BigMachines__Product__c                  = newProduct.Id;
        bquote.BigMachines__Quantity__c                 = 1;
        bquote.BigMachines__Sales_Price__c              = 10;
        insert bquote;
        
        BigMachines__Quote_Product__c bquoteRenew       = new BigMachines__Quote_Product__c();
        bquoteRenew.BigMachines__Quote__c               = quote.Id;
        bquoteRenew.Line_Type__c                        = 'Renew';
        bquoteRenew.BigMachines__Product__c             = newProduct.Id;
        bquoteRenew.BigMachines__Quantity__c            = 1;
        bquoteRenew.BigMachines__Sales_Price__c         = 10;
        insert bquoteRenew;
        
        quote.BigMachines__Status__c        = 'Ordered';
        update quote;
        set<Id> setQuoteIds = new set<Id>();
        set<Id> setTaskIds = new set<Id>();
        for(BigMachines__Quote__c qte:lstBigMachinesQuote){
        setQuoteIds.Add(qte.id);
        }
        
         Id salesActivitiesRecordTypeId = Schema.SObjectType.Task.RecordTypeInfosByName.get('Sales Activities').RecordTypeId;
       Task theTask = new Task();
        List<Task> tasklist = new List<Task>();
    
    Task theTask2 = new Task();
    theTask2 = new Task(
     WhatId = acc.id,
     Subject = 'Outbound call to +198765435678',
     Type = 'call',
     ActivityDate = System.Today(),
     NVM_Disposition__c  ='Left Message',
     Status = 'Completed');
    theTask2.RecordTypeId = salesActivitiesRecordTypeId;
    //theTask2.whatId = newAccount.Id;
    tasklist.add(theTask2);
    insert tasklist;
    setTaskIds.add(tasklist[0].id);
    
        BigMachinesQuoteTriggerHandler.updateQuoteTask(setTaskIds);
        test.stopTest();
     
    }
    
    @isTest static void testModifyQuoteCreation(){
    
         // Test for 'Modify'  
        Account acc                                     = createAccount();
        Product2 newProduct                             = createProduct();
        createCaseRecordType();
         
        test.startTest();
        
        BigMachines__Quote__c quoteModify               = new BigMachines__Quote__c();
        quoteModify.BigMachines__Account__c             = acc.Id;        
        quoteModify.BigMachines__Status__c              = 'Pending';
        quoteModify.BigMachines_Quote_Type__c           = 'Modify';
        quoteModify.BigMachines__Site__c                 = Label.BigMachineSite;
        insert quoteModify;
        
        
        BigMachines__Quote_Product__c bquoteAddModify   = new BigMachines__Quote_Product__c();
        bquoteAddModify.BigMachines__Quote__c           = quoteModify.Id;
        bquoteAddModify.Line_Type__c                    = 'Add';
        bquoteAddModify.BigMachines__Product__c         = newProduct.Id;
        bquoteAddModify.BigMachines__Quantity__c        = 1;
        bquoteAddModify.BigMachines__Sales_Price__c     = 10;
        insert bquoteAddModify;
        
        BigMachines__Quote_Product__c bquoteRenewMod    = new BigMachines__Quote_Product__c();
        bquoteRenewMod.BigMachines__Quote__c            = quoteModify.Id;
        bquoteRenewMod.Line_Type__c                     = 'Renew';
        bquoteRenewMod.BigMachines__Product__c          = newProduct.Id;
        bquoteRenewMod.BigMachines__Quantity__c         = 1;
        bquoteRenewMod.BigMachines__Sales_Price__c      = 10;
        insert bquoteRenewMod;
        
        quoteModify.BigMachines__Status__c              = 'Ordered';
        system.assert(true);
        update quoteModify; 
        test.stopTest();  
    }
    
    
    @isTest static void testRetentionQuoteCreation(){
    
         // Test for 'Modify'  
        Account acc                                     = createAccount();
        Product2 newProduct                             = createProduct();
        createCaseRecordType();
         
        test.startTest();
        List<BigMachines__Quote_Product__c> lstBigMachinesQuoteProduct = new List<BigMachines__Quote_Product__c>();
        
        BigMachines__Quote__c quoteRetention            = new BigMachines__Quote__c();
        quoteRetention.BigMachines__Account__c          = acc.Id;        
        quoteRetention.BigMachines__Status__c           = 'Pending';
        quoteRetention.BigMachines_Quote_Type__c        = 'Retention';
        quoteRetention.BigMachines__Site__c                 = Label.BigMachineSite;
        insert quoteRetention;
        
        
        BigMachines__Quote_Product__c bquoteAddModify   = new BigMachines__Quote_Product__c();
        bquoteAddModify.BigMachines__Quote__c           = quoteRetention.Id;
        bquoteAddModify.Line_Type__c                    = 'Add';
        bquoteAddModify.BigMachines__Product__c         = newProduct.Id;
        bquoteAddModify.BigMachines__Quantity__c        = 1;
        bquoteAddModify.BigMachines__Sales_Price__c     = 10;
        lstBigMachinesQuoteProduct.add(bquoteAddModify);
        insert bquoteAddModify;
        
        BigMachines__Quote_Product__c bquoteRenewMod    = new BigMachines__Quote_Product__c();
        bquoteRenewMod.BigMachines__Quote__c            = quoteRetention.Id;
        bquoteRenewMod.Line_Type__c                     = 'Renew';
        bquoteRenewMod.BigMachines__Product__c          = newProduct.Id;
        bquoteRenewMod.BigMachines__Quantity__c         = 1;
        bquoteRenewMod.BigMachines__Sales_Price__c      = 10;
        lstBigMachinesQuoteProduct.add(bquoteRenewMod);
        insert bquoteRenewMod;
        
        quoteRetention.BigMachines__Status__c           = 'Ordered';
        system.assert(true);
        update quoteRetention;
        
        test.stopTest();  
    }
    
    
    public static Account createAccount(){
        DisabledTrigger__c Dtrg             = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'test@test.com');
        insert Dtrg;

        Account acc                         = TestDataFactory.createAccount('The Test Account', null, false);
        acc.Primary_Email__c                = 'test@test.com';
        insert acc;
        return acc;
    }
    
    public static Product2 createProduct(){
        Product2 newProduct                 = new Product2();
        newProduct.Name                     = 'Test Product';
        newProduct.Commission_Category__c   = 'Normal';    
        newProduct.Normalization_factor__c  = 1.10;
        newProduct.Commission_Category__c   = 'CFCB';
        newProduct.Fulfillment_Type__c      = 'Manual';
        newProduct.Auto_Renewal__c          = True;
        newProduct.ProductCode              ='SHOWCASE' ;
        newProduct.S_No__c                  = 2;
        insert newProduct;
        return newProduct;
    }
    
  // This is not needed if the orginal class handled this in a better way  
    public static void createCaseRecordType(){
        Id caseRecordTypeId                 = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Retention').getRecordTypeId();
        insert new CaseRecordTypes__c(Name='Retention', Record_Type_Id__c = String.valueOf(caseRecordTypeId));
        
    }
    
    
}