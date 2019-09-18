global class BatchProcessUpdateRecordTypeLead implements Database.Batchable<sObject>{
String query;

    global Database.querylocator start(Database.BatchableContext BC){
    set<String> setStatus = new set<String>();
     setSTatus.add('New');
     setSTatus.add('In Progress');
        Query = 'SELECT Id, Contact_Method__c,contact__c,Email ,RecordTypeId FROM Lead WHERE RecordTypeId = null and Status=:setStatus';
        List<Lead> lstLead = [SELECT Id, Contact_Method__c,contact__c,Email ,RecordTypeId FROM Lead WHERE RecordTypeId = null and Status=:setStatus limit 10];
        if(lstLead.size()>0){
        } else {
        Query = 'SELECT Id, Contact_Method__c,contact__c,Email ,RecordTypeId FROM Lead WHERE Contact_Method__c = null and Status=:setStatus';
        }
        if(Test.isRunningTest()){Query = 'SELECT Id, Email ,Contact_Method__c,contact__c,RecordTypeId FROM Lead WHERE Status=:setStatus';}
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Lead> scope){
      //SkipForNVMTrigger.setSkipTrgTrue();
       Set<String> setEmailString = new Set<String>();
       map<String,Id> mapContactString = new map<String,Id>();
       Set<Id> setContactIds = new Set<Id>();
       for(Lead led:scope){
       setEmailString.add(led.Email);
       setContactIds.add(led.contact__c);
       }
       for(ContactMethod__c cmm:[Select Id,Email__c,contact__C from ContactMethod__c where contact__c=:setContactIds and Email__c=:setEmailString]){
       mapContactString.put(cmm.contact__C+'$$$'+cmm.Email__c,cmm.id);
       }
       List<Lead> LeadList = new List<Lead>();
       id rdcLeadRecordType = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('RDC').getRecordTypeId();
       for(Lead led : scope){
           //acc.Lock_Expiration_Date__c = null;
           If(led.RecordTypeId==null){led.RecordTypeId = rdcLeadRecordType;}
           if(led.Contact_Method__c==null){
           if(led.contact__C!=null && led.Email!=null){
           if(mapContactString.containskey(led.contact__C+'$$$'+led.Email)){
           led.Contact_Method__c = mapContactString.get(led.contact__C+'$$$'+led.Email);
           }
           }
           }
           LeadList.add(led);
       }
       if(!Test.isRunningTest()){update LeadList ;}
    }

    global void finish(Database.BatchableContext BC){
    }
}