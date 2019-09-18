//  OTC-197 This class get the Credit balnces adjustment reocord from the Zuora Insert in Sales force

public class Z_CreditBalanceAdjestmetUpdate_Schedule implements schedulable{  
    public static Zuora.zApi zApi;

public void execute(SchedulableContext SC){
Date yesterday = System.today()-1;
string adjustdate = string.valueof(yesterday).left(10);
CreditAdjustment(adjustdate);
}   
    @future(callout=true)
    public static void CreditAdjustment(string adjustdate){
        List<Zuora.zObject> Adjustments = new List<Zuora.zObject>();
        List<CreditBalanceAdjustment__c> Creditss = new List<CreditBalanceAdjustment__c>();
        Set<String> Billid = new Set<String>();
        List<Zuora__CustomerAccount__c> Billidd = new List<Zuora__CustomerAccount__c>();
        List<String> ZId = new List<String>();
        List<Zuora__Payment__c> Pidd = new List<Zuora__Payment__c>();
        List<Zuora__Refund__c> Ridd = new List<Zuora__Refund__c>();
        List<Zuora__ZInvoice__c> NIdd= new List<Zuora__ZInvoice__c>();
        List<String> Pid = new List<String>();
        List<String> Rid = new List<String>();
        List<String> NId = new List<String>();
        List<system_logs__c> system_logs_list = new List<system_logs__c>();
        try{
        //String adjustdate = '2017-05-10';
        //if(!Test.isRunningTest())
       zApi = zuoraApiAccess(); 
        
        String Query = 'Select Id,Comment, AccountId, AdjustmentDate, Amount, CreatedDate, Number,ReasonCode, SourceTransactionNumber, SourceTransactionType, Status, Type,UpdatedDate From CreditBalanceAdjustment where AdjustmentDate=\''+adjustdate +'\'';
        if(!Test.isRunningTest()){
        //zApi = zuoraApiAccess();
        Adjustments = zApi.zQuery(Query);
        } else {
        Zuora.zObject Adjustment = new Zuora.zObject('CreditBalanceAdjustment');
            Adjustment.setValue('Id', '2c92c0f956f9e18');
            Adjustment.setValue('Comment', 'subscri');
            Adjustment.setValue('AccountId', '2c92c0f956f9e18');
            Adjustment.setValue('ReasonCode', 'Stanard adjustment');
            Adjustment.setValue('AdjustmentDate', System.Today());
            Adjustment.setValue('Amount', 70);
            Adjustment.setValue('CreatedDate', DateTime.now());
            Adjustment.setValue('Number', 'CBA');
            Adjustment.setValue('SourceTransactionNumber', '2c92c0f956f9e18');
            Adjustment.setValue('SourceTransactionType', 'Invoice');
            Adjustment.setValue('Status', '2c92c0f956f9e18');
            Adjustment.setValue('Type', '2c92c0f956f9e18');
            Adjustment.setValue('UpdatedDate', DateTime.now());
            Adjustments.add(Adjustment);
        }
        
        for(Zuora.zObject Numbe: Adjustments){
        system.debug('Numbe' +Numbe);
            if(string.valueOf(Numbe.getvalue('AccountId'))!=null)
            Billid.add(string.valueOf(Numbe.getvalue('AccountId')));
            if(string.valueOf(Numbe.getvalue('SourceTransactionType'))!=null){
                if(string.valueOf(Numbe.getvalue('SourceTransactionType'))=='Payment'){
                    Pid.add(string.valueof(Numbe.getvalue('SourceTransactionNumber')));
                    system.debug('Payment1' +String.valueOf(Numbe.getvalue('SourceTransactionNumber')));
                }else If(string.valueOf(Numbe.getvalue('SourceTransactionType'))=='Refund'){
                        Rid.add(string.valueOf(Numbe.getvalue('SourceTransactionNumber')));
                }else if(string.valueOf(Numbe.getvalue('SourceTransactionType'))=='Invoice'){
                      Nid.add(string.valueOf(Numbe.getvalue('SourceTransactionNumber')));
                      system.debug('Invoice1' +String.valueOf(Numbe.getvalue('SourceTransactionNumber')));
                }
             }          
        }
        

        Map<String, Zuora__CustomerAccount__c> MBillidd = new Map<String, Zuora__CustomerAccount__c>();
        Map<String, Id> MPidd  = new Map<String, Id>();
        Map<String, Id> MRidd = new Map<String, Id>();
        Map<String, Id> MNidd  = new Map<String, Id>();
        if(!Billid.isempty())
        Billidd = [Select Id ,Zuora__Zuora_Id__c, Zuora__Account__c From Zuora__CustomerAccount__c where Zuora__Zuora_Id__c IN: BillId];
        for(Zuora__CustomerAccount__c BillAcc : Billidd ){
            MBillidd.put(BillAcc.Zuora__Zuora_Id__c , BillAcc);
            
        }
        
        if(!Pid.isempty())
        Pidd=[Select Id, Name From Zuora__Payment__c where Name IN:Pid];
        for(Zuora__Payment__c TPid : Pidd){
          system.debug('TPid Name ' + TPid.Name);
          system.debug('TPid Id ' + TPid.Id);
           MPidd.put(Tpid.Name, Tpid.Id);      
        }
        
        if(!Rid.isempty())
        Ridd = [Select Id, Name From Zuora__Refund__c where Name IN:Rid];
        for(Zuora__Refund__c TRid : Ridd){
           MRidd.put(TRid.Name, TRid.Id);      
        }
        
        if(!Nid.isempty())
        Nidd = [Select Id, Name From Zuora__ZInvoice__c where Name IN:Nid];
        for(Zuora__ZInvoice__c TNid : Nidd){
          system.debug('TNid Name ' + TNid.Name);
          system.debug('TNid Id ' + TNid.Id);
           MNidd.put(TNid.Name, TNid.Id);          
        }
        
        
        
        for(Zuora.zObject Adjust : Adjustments){
            CreditBalanceAdjustment__c Credits = new CreditBalanceAdjustment__c();
            if(string.valueOf(Adjust.getvalue('AccountId'))!=null&&MBillidd.containskey(string.valueOf(Adjust.getvalue('AccountId')))){
                
            Credits.BillingAccount__c = MBillidd.get(string.valueOf(Adjust.getvalue('AccountId'))).Id;
            Credits.Zuora_Account__c = MBillidd.get(string.valueOf(Adjust.getvalue('AccountId'))).Zuora__Account__c;
            }
            if(string.valueOf(Adjust.getvalue('SourceTransactionType'))!=null){
                if(string.valueOf(Adjust.getvalue('SourceTransactionType'))=='Payment'&&MPidd.containskey(string.valueOf(Adjust.getvalue('SourceTransactionNumber')))){
               system.debug('Payment Number ' +MPidd.get(string.valueOf(Adjust.getvalue('SourceTransactionNumber'))));
                Credits.Payment__c = MPidd.get(string.valueOf(Adjust.getvalue('SourceTransactionNumber')));
                }else if(string.valueOf(Adjust.getvalue('SourceTransactionType'))=='Refund'&&MRidd.containskey(string.valueOf(Adjust.getvalue('SourceTransactionNumber')))){
                Credits.Refund__c = MRidd.get(string.valueOf(Adjust.getvalue('SourceTransactionNumber')));
                }else if(string.valueOf(Adjust.getvalue('SourceTransactionType'))=='Invoice'&&MNidd.containskey(string.valueOf(Adjust.getvalue('SourceTransactionNumber')))){
                Credits.Invoice__c = MNidd.get(string.valueOf(Adjust.getvalue('SourceTransactionNumber')));
                system.debug('Invoice Number ' +MNidd.get(string.valueOf(Adjust.getvalue('SourceTransactionNumber'))));
                }
             }      
            if(string.valueOf(Adjust.getvalue('AdjustmentDate'))!=null)
            Credits.Adjustment_Date__c = Date.valueof(Adjust.getvalue('AdjustmentDate'));
            if(string.valueOf(Adjust.getvalue('SourceTransactionType'))!=null)
            Credits.Source__c = String.valueof(Adjust.getvalue('SourceTransactionType'));
            if(string.valueOf(Adjust.getvalue('Amount'))!=null)
            Credits.Zuora_Amount__c =(Decimal)(Adjust.getvalue('Amount'));
            if(string.valueOf(Adjust.getvalue('CreatedDate'))!=null)
            Credits.Created_Date__c = DateTime.valueof(Adjust.getvalue('CreatedDate'));           
            if(string.valueOf(Adjust.getvalue('ReasonCode'))!=null)
            Credits.Reason_Code__c = String.valueof(Adjust.getvalue('ReasonCode'));   
            if(string.valueOf(Adjust.getvalue('Number'))!=null)
            Credits.Name = String.valueof(Adjust.getvalue('Number'));            
            if(string.valueOf(Adjust.getvalue('Status'))!=null)
            Credits.AdjustmentStatus__c = String.valueof(Adjust.getvalue('Status'));
            if(string.valueOf(Adjust.getvalue('Type'))!=null)
            Credits.Adjustment_Type__c = String.valueof(Adjust.getvalue('Type'));
            if(string.valueOf(Adjust.getvalue('UpdatedDate '))!=null)
            Credits.Updated_Date__c = DateTime.valueof(Adjust.getvalue('UpdatedDate'));
            if(string.valueOf(Adjust.getvalue('Id'))!=null)
            Credits.Zuora_Id__c = String.valueof(Adjust.getvalue('Id'));
            if(string.valueOf(Adjust.getvalue('Comment'))!=null)
            Credits.Comment__c =String.valueof(Adjust.getvalue('Comment'));
        Creditss.add(Credits);
    
        }  
         //upsert Creditss Zuora_Id__c;
        
        Database.UpsertResult[] srList = Database.upsert(Creditss, Schema.SObjectType.CreditBalanceAdjustment__c.fields.Zuora_Id__c.getSObjectField(), false);

        for (Database.Upsertresult sr : srList) {

            if (sr.isSuccess()) {
            System.debug('Success');
            }
            else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                   
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                    system_logs__c logs = new system_logs__c();
                    //logs.Record_ID__c = err.Id;
                    logs.Object_Type__c = 'CreditAdjustment';
                    logs.Message__c = err.getMessage();
                    system_logs_list.add(logs);
                }
            }
        }
        if(!system_logs_list.isempty()){
                    insert system_logs_list;
        }
       }catch(Exception ex){
                String ErrorMessage ='Exception Occured while updating Updating Creditbalance records: '+ex.getMessage()+' Date: '+System.today().format();             
                Boolean ErrorStatus = true;
                system.debug('@@ '+ErrorMessage);
                updateSystemLogs(ErrorStatus,ErrorMessage);
                return ;
    }
    }
       public static Zuora.ZApi zuoraApiAccess(){
                system.debug('@@@###Login');        
                zApi = new Zuora.ZApi();       
                Zuora.ZApi.LoginResult loginResult = (!Test.isRunningTest()) ? zApi.zLogin() : new Zuora.ZApi.LoginResult();         
                return zApi;
            }
            
      public static void updateSystemLogs(Boolean status, String message){
        system.debug('Entered into System Logs');
        system_logs__c logs = new system_logs__c();
        //logs.Record_ID__c = Account_Id;
        logs.Object_Type__c = 'Credit Balance Adjustment';
        logs.Message__c =message;
        insert logs;
       }   
}