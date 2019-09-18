//**************************************************//
// (c) 2015 NTTDATA, Inc.
// Class Name : CaseCloserValidation
// This Class is Used to Prevent the case to be Closed if the case is having any PastDue Invoices. 
//
// Created 14th july 2015   Author Name:-  Venkataratamana Cheedara     Original
// Modified 29th july 2015   Author Name:-  Venkataratamana Cheedara     Modified
//**************************************************//
Public without sharing class  CaseCloserValidation{ 
  Public void ErrorMsg(List<Case> AllCases){
      Set<Id> CaseIds = new Set<Id>();
      Set<Id> accountids = new Set<id>();
      for(Case c :  AllCases){
          if(c.Type == 'Collections'){
              CaseIds.add(c.id); 
              accountids.add(c.AccountId); 
          }    
      }      
      List<Case> CasestoUpdate = new List<Case>();
      List<Zuora__ZInvoice__c> AllInvoices = [select id,Zuora__Status__c,Zuora__Account__c,Zuora__DueDate__c,Zuora__Balance2__c,Name,Case__c from Zuora__ZInvoice__c where Zuora__Account__c in : accountids];
      for(Case c : AllCases){
          system.debug('Case being closed : ' + c);
          for(Zuora__ZInvoice__c z : AllInvoices){
              system.debug('Invoice on the case : '+ z);
              if(c.Status == 'Closed'){
                   if ((z.Zuora__DueDate__c < System.TODAY()) && (z.Zuora__Balance2__c > 0 )) { 
                      c.Status.addError('Case Cannot be manually closed now. There are Past Due Invoices on the case. Case would be automatically closed when the last Invoice is Posted');
                          }                                        
                      }
                                                    
                  }              
             }  
         }   
   }