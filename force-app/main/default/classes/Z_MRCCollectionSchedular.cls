//CRM-5242
//CRM-5314 Mortgage: Case Management
public class Z_MRCCollectionSchedular implements schedulable{
    public void execute(SchedulableContext SC){
        runSchedular(); 
        try{
            System.abortJob(SC.getTriggerId()); 
        }catch(exception ex){            
        }   
    }
    public static void runSchedular(){
        Set<String> lenderAcctype = new Set<String>{'Lender Parent','Lender Branch', 'Loan Officer'};          
            Map<Id, Zuora__Payment__c> Actids = new Map<Id, Zuora__Payment__c>();
        for(Zuora__Payment__c inloop: [Select Id, Zuora__Account__c From Zuora__Payment__c where Zuora__Account__r.Type IN:lenderAcctype and Zuora__Status__c = 'Error' and CreatedDate >=yesterday]){               
            Actids.Put(inloop.Zuora__Account__c, inloop);             
        }   
        
        List<Account>  Acts = [Select Id,OwnerId, (select Id, RCM_Payment_Amount__c  From Assets Where Status = 'Active' and Fulfillment_Status__c  = 'Fulfilled'),(select Id,Zuora__Balance__c,Zuora__Zuora_Id__c From R00N40000001kyLcEAI__r LIMIT 1), (Select Id,AccountId From Cases WHERE Status != 'Closed' and Type  = 'Collection' LIMIT 1) From Account Where Id IN:Actids.keyset()] ;
        List<Case> caseList = new List<Case>();
        for(Account AC : Acts){            
            Decimal assetsAmt = 0.00;           
            Decimal Amount = 0.00;
            if(AC.R00N40000001kyLcEAI__r.size()>0){
                for(Asset inloop:AC.Assets){
                    assetsAmt += inloop.RCM_Payment_Amount__c;               
                }
                Amount = assetsAmt + AC.R00N40000001kyLcEAI__r[0].Zuora__Balance__c;                  
            }
            if(Amount>0){
                Case Newcase= new Case();
                if(!(AC.Cases.Size()>0)){                
                    Newcase.Status= 'New';
                    Newcase.SubStatus__c= '';
                    Newcase.Origin= 'Web';
                    Newcase.Description = 'Payment failed for Lender Account';
                    Newcase.Subject= 'RCM Payment Failure';
                    Newcase.recordTypeId= CaseRecordTypes__c.getValues('Collection').Record_Type_Id__c;
                    Newcase.Type  = 'Mortgage';                
                    Newcase.AccountId  = AC.Id;  
                    Newcase.OwnerId  = AC.OwnerId; 
                    Newcase.Area__c = 'Billing'; 
                    //Newcase.setOptions(Z_InvoicecollectionSchedulable.fetchDMLOptions());     
                    Newcase.Top_Up_Amount__c = Amount;                                    
                }else{
                    Newcase = AC.Cases[0];
                    Newcase.Top_Up_Amount__c  = Amount;
                }
                caseList.add(Newcase);                
            }
            upsert caseList;
            
            for(Case inloop:caseList){
                Zuora__Payment__c pp = Actids.get(inloop.AccountId);
                pp.Case__c  = inloop.Id;
                Actids.put(inloop.AccountId, PP);
            }
            update Actids.values();
        }                
    }    
}