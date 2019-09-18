//**************************************************//
// (c) 2015 NTTDATA, Inc.
// Class Name : InvoiceCaseCloserNew
// This Class is Used to Close the Case when its all Invoices are Posted. 

//**************************************************//

public class InvoiceCaseCloserNew{ 

    public static boolean invoiceTriggerRun = true;
    public void CaseCloser(List<Zuora__ZInvoice__c> AllInvoices){
        Map<Id,AccountTeamMember > atmList  = new Map<Id,AccountTeamMember > ();        
        AccountTeamMember atm               = new AccountTeamMember();
        set<Id> sInvoiceIds                 = new set<Id>();
        Map<Id,Double> invoicePaidMap       = new Map<Id,Double>();
        Set<ID> invoiceIds                  = new Set<Id>();
        
        
        // Set Zuora Status to Posted for invoices
            for(Zuora__ZInvoice__c z :  AllInvoices){
                if (z.Zuora__Status__c  == 'Posted' && z.Zuora__Balance2__c <=0){
                        
                   // objInvoice = new Zuora__ZInvoice__c(id=z.id);
                    z.Invoice_Status__c  = 'Paid';
                    sInvoiceIds.add(z.Id);
                    invoicePaidMap.put(z.Id,z.Zuora__Balance2__c);
                    
                }
            }
            
            for(Zuora__ZInvoice__c z :  AllInvoices){
                    invoiceIds.add(z.Id);
            }
            
            system.debug('@@ invoiceIds @@'+invoiceIds);
            List<Case_Invoice_Relationship__c> lstCir =     [SELECT id, Past_Due_Amount__c, Days_Past__c, Invoice__r.Zuora__Balance2__c,Invoice__r.Days_Past_Due__c FROM Case_Invoice_Relationship__c
                                                               WHERE Invoice__c in: invoiceIds];
            
            system.debug('@@ lstCir @@'+lstCir);
            if(lstCir.size()>0){
                for(Case_Invoice_Relationship__c cir: lstCir){
                    system.debug('@@ cir.Invoice__r.Zuora__Balance2__c @@'+cir.Invoice__r.Zuora__Balance2__c);
                    system.debug('@@ cir.Invoice__r.Days_Past_Due__c @@'+cir.Invoice__r.Days_Past_Due__c);
                    cir.Past_Due_Amount__c  = cir.Invoice__r.Zuora__Balance2__c;
                    cir.Days_Past__c        = cir.Invoice__r.Days_Past_Due__c; 
                }                                                   
            }
             
            
          
        system.debug('@@ sInvoiceIds @@'+sInvoiceIds);
        If(sInvoiceIds.size()> 0){

            set<Id> sAccId                      = new set<Id>();
            set<Id> sCaseIDs                    = new set<Id>();  
            Map<Id,Id> accountCaseOwnerMap      = new Map<Id,Id>();
            Boolean isAllinvoicePaid            = true;
            
            List<Case_Invoice_Relationship__c> lstCasInvRel = [SELECT id, Past_Due_Amount__c ,Invoice__r.Zuora__Balance2__c,Case__c, Case__r.OwnerId, case__r.AccountId, Invoice__r.Days_Past_Due__c FROM Case_Invoice_Relationship__c
                                                               WHERE Case__r.Status!='Closed' AND Invoice__c in: sInvoiceIds];
                                                               
            system.debug('@@ lstCasInvRel @@'+lstCasInvRel);
                                                               
            for(Case_Invoice_Relationship__c cir: lstCasInvRel){
                sCaseIDs.add(cir.Case__c);
                accountCaseOwnerMap.put(cir.case__r.AccountId,cir.Case__r.OwnerId); // Contains the Account on case and case Owner Id's
            }
            system.debug('TRACE : Account case owner Map : '+ accountCaseOwnerMap );
            
            // Set Status Closed for Cases which has all invoices payment done
            List<Case> lstCaseUpdate = [SELECT Id, Accountid, (SELECT id, Invoice__r.Zuora__Balance2__c FROM Case_Invoice_Relationships__r) 
                                        FROM CASE WHERE Id IN: sCaseIDs];
            system.debug('TRACE : cases to be updated : '+ lstCaseUpdate );

            // sAccId willl have the account only if all the invoices are paid
            for(Case cs: lstCaseUpdate){
            	//CRM-1730 reset variable inside Case for loop
            	isAllinvoicePaid = true;
                for(Case_Invoice_Relationship__c cir: cs.Case_Invoice_Relationships__r){
                    system.debug('TRACE  CIR : ' +cir);
                    
                    system.debug('@@ invoicePaidMap.get(cir.Invoice__r.Id) @@'+invoicePaidMap.get(cir.Invoice__r.Id));
                    if(cir.Invoice__r.Zuora__Balance2__c > 0 && !invoicePaidMap.containsKey(cir.Invoice__r.Id)){
                        
                        isAllinvoicePaid = false;
                        break;
                    }
                    
                    if(invoicePaidMap.containsKey(cir.Invoice__r.Id)){
                        if(invoicePaidMap.get(cir.Invoice__r.Id)!= 0.0){
                            isAllinvoicePaid = false;
                            break;
                        }
                    }
                    
                }
                system.debug('@@ isAllinvoicePaid @@'+isAllinvoicePaid);
                if(isAllinvoicePaid == true){
                    cs.Status = 'Closed';
                    sAccId.add(cs.Accountid);
                }
            }

            system.debug('TRACE : Cases ' + lstCaseUpdate);
            system.debug('TRACE : Accounts '+sAccId);
            if (lstCaseUpdate.size() > 0) {
                try{
                    update lstCaseUpdate;
                }catch (Exception e){                
                    system.debug('TRACE : Case  update failed with the error: ' + e.getMessage());
                }                     
            }
            
            // Set Past due field at the Account level
            List<Account> lstAccountUpdate = [select Id from Account where id in: sAccId];
            for(Account acc: lstAccountUpdate ){
                acc.Past_Due__c = False;
                
            }
            if (lstAccountUpdate.size() > 0) {
                try{
                    update lstAccountUpdate;
                }catch (Exception e){  
                    system.debug('TRACE : CIR  update failed with the error: ' + e.getMessage());
                }                     
            }
            
          //  update lstCasInvRel;
          
            
           // TODO - Stan : Check if this is really needed! 
           
            /*
            system.debug('SACCID: '+saccid);
            // Get the reps on the accounts
            List < AccountTeamMember > CollectionsRepsOnTheAccount = [SELECT UserId, AccountId FROM AccountTeamMember 
                                                                      WHERE TeamMemberRole = 'Collections Rep' AND AccountId IN: sAccId];   
            for (AccountTeamMember teamMember: CollectionsRepsOnTheAccount ) {
                if (teamMember.AccountId != null) {
                    sAccId.remove(teamMember.AccountId);
                }
            }
            system.debug('TRACE : CollectionsRepsOnTheAccount '+ CollectionsRepsOnTheAccount);
            // Iterate over the accounts which does not have a rep associated and associate the current user as a rep on the account.    
           Set<Id> setAccountDupIds = new Set<Id>();
            for (Id acct: sAccId) {
            
            if(!setAccountDupIds.contains(acct)){
            setAccountDupIds.add(acct);
                atm.AccountId = acct;
                atm.TeamMemberRole = 'Collections Rep';
                atm.UserId = accountCaseOwnerMap.get(acct); // Adding the owner as Collections Rep on the account when he close the case
                atmList.put(acct,atm);
                }
            }
            system.debug('### ATM List: ' + atmList);
            // Try to insert the team members on the account and catch exceptions
            try{
                insert atmList.values();
            }catch( DmlException e){
                system.debug('EXCEPTION OCCURED In addRepToAccountTeamOnCaseClosure  : ' + e.getMessage());
            }
            */
            
            
            
            
        }
        system.debug('@@ update lstCir @@'+lstCir);
        update lstCir;
        
    }
    
}