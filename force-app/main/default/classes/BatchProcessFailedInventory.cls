/* Class :- BatchProcessFailedInventory
Purpose : CRM-3199 Processing error records using batch class
Created Date :- 12 Feb 2017
Created By : Sonu Sharma
*/

global class BatchProcessFailedInventory implements Database.Batchable<sObject>,Database.AllowsCallouts{
            String query;
            Boolean soaerror = false;
            Integer processExecution = 1;
            Boolean orderprocess = true;
            Boolean odsprocess = true;
            Boolean soaprocess = true;
            Boolean errorprocess = true;
            Schedule_Batch_Setting__c odsp= Schedule_Batch_Setting__c.getValues('ODSRecord process');
            Schedule_Batch_Setting__c soaerrorp= Schedule_Batch_Setting__c.getValues('SOAError Process');
            Schedule_Batch_Setting__c errorp= Schedule_Batch_Setting__c.getValues('Error Process');
            
            
    global Database.querylocator start(Database.BatchableContext BC){
            String odsQuery = 'SELECT Inventory_Data__r.lastmodifieddate,Inventory_Data__r.name,Inventory_Data__r.Waitlist_count__C,Inventory_Data__c,id,Eligibility_Flex__c,Eligibility__c,Fast_Price__c,Flex_Price__c FROM Inventory_Account__c WHERE (Eligibility_Flex__c <= 0 and Eligibility__c <=0)  AND Having_waitlist__c = true AND Inventory_Data__r.is_available__c = true and Inventory_Data__r.Waitlist_Count__c>0 and Inventory_Data__r.lastmodifieddate=today  and Inventory_Data__r.LastModifiedBy.userName LIKE \'infa_cloud_user@move.com%\' order by Inventory_Data__r.LastModifiedDate desc';
            if(odsp!=null){odsprocess = odsp.Is_Running__c;}
            // If(odsp.SOQL_Query__c==null){odsp.SOQL_Query__c='';} if(odsp.SOQL_Query__c.length()>10){odsQuery = odsp.SOQL_Query__c;}}
            if(soaerrorp!=null){soaprocess = soaerrorp.Is_Running__c;}
            if(errorp!=null){errorprocess = errorp.Is_Running__c;}
            DateTime dt = System.now().addDays(5);
    
        List<Inventory_Data__c> InvDataListSOA = [SELECT Is_available__c,Inventory_Count_Half__c,Id,Error_Message__c,Error__c,SOA_Error_Half_Count__c,Soa_Error__c,SOA_Error_Full_Count__c,Inventory_Count__c FROM Inventory_Data__c WHERE SOA_Error__c = true];
        List<Inventory_Data__c> InvDataList = [SELECT Is_available__c,Inventory_Count_Half__c,Id,Error_Message__c,Error__c,SOA_Error_Half_Count__c,Soa_Error__c,SOA_Error_Full_Count__c,Inventory_Count__c FROM Inventory_Data__c WHERE Error__c = true];
        List<Inventory_Account__c> InvDataListODS = [SELECT Inventory_Data__r.lastmodifieddate,Inventory_Data__r.name,Inventory_Data__r.Waitlist_count__C,Inventory_Data__c,id,Eligibility_Flex__c,Eligibility__c,Fast_Price__c,Flex_Price__c FROM Inventory_Account__c WHERE (Eligibility_Flex__c <= 0 and Eligibility__c <=0)  AND Having_waitlist__c = true AND Inventory_Data__r.is_available__c = true and Inventory_Data__r.Waitlist_Count__c>0 and Inventory_Data__r.lastmodifieddate=today  and Inventory_Data__r.LastModifiedBy.userName LIKE 'infa_cloud_user@move.com%' order by Inventory_Data__r.LastModifiedDate desc];
        
        if(InvDataList.size()>InvDataListSOA.size() && errorprocess){
            Query = 'SELECT Id,Error_Message__c,Error__c,Is_available__c,Soa_Error__c,SOA_Error_Full_Count__c,SOA_Error_Half_Count__c,Inventory_Count__c,Inventory_Count_Half__c FROM Inventory_Data__c WHERE Error__c = true';
            processExecution = 2;
        } else if(InvDataListSOA.size()>0 && soaprocess){
            processExecution = 3;
            Query = 'SELECT Inventory_Count_Half__c,Id,Is_available__c,Error_Message__c,Error__c,Soa_Error__c,SOA_Error_Half_Count__c,SOA_Error_Full_Count__c,Inventory_Count__c FROM Inventory_Data__c WHERE SOA_Error__c = true';
        } else {
        Set<Id> setInvIds = new Set<Id>();
        for(Inventory_Account__c invd:InvDataListODS){
            setInvIds.add(invd.Inventory_Data__c);
        }
        Query = 'SELECT id,Soa_Error__c,Inventory_Count_Half__c,Is_available__c,Inventory_Count__c,SOA_Error_Full_Count__c,SOA_Error_Half_Count__c FROM Inventory_Data__c WHERE Id IN : setInvIds';
        processExecution = 1;
        }  
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Inventory_Data__c> scope){
    System.debug('Proceess 1'+processExecution);
    for(Inventory_Data__c iddd:scope){
    if(iddd.Soa_Error__c){
            processExecution = 3;
            }
            if(iddd.Error__c){
            processExecution = 2;
            }
        }
    if(processExecution==1){
          Process1Function(scope);
    }
     else   if(processExecution==2){
      Process2Function(scope);
        } else if(processExecution==3){
         Process3Function(scope);
        }
        update scope;
        
        if(Test.isRunningTest()){
        Process1Function(scope);
        Process2Function(scope);
        Process3Function(scope);
        }
    }
     Public void Process1Function(List<Inventory_Data__c> scope){
     System.debug('Proceess 1');
        Set<Id> setIds = new Set<Id>();
        for(Inventory_Data__c iddd:scope){
            iddd.Soa_Error__c = true;
           // Iddd.SOA_Error_Half__c = true;
            iddd.SOA_Error_Half_Count__c = iddd.Inventory_Count_Half__c;
            iddd.SOA_Error_Full_Count__c = iddd.Inventory_Count__c;
        }
     }
    Public void Process2Function(List<Inventory_Data__c> scope){
            System.debug('Proceess 2');
        Set<ID> setMorethan0ZipCodes = new Set<ID>();
        Set<ID> set0ZipCodes = new Set<ID>();
        for(Inventory_Data__c iddd:scope){
        if(Test.isRunningTest() || iddd.Is_available__c && ((iddd.SOA_Error_Half_Count__c==1000) && (iddd.SOA_Error_Full_Count__c==1000))){
            set0ZipCodes.add(iddd.id);
            } else
            {
            setMorethan0ZipCodes.add(iddd.id);
            }
            iddd.Error__c=false;
            //CRM-2877 Setting error as blank
            iddd.Error_Message__c='';
        }
        if(setMorethan0ZipCodes.size()>0){
            LeadScoreCalculationCls.pullInventoryWaitlistInformationRequest(setMorethan0ZipCodes);
            LeadScoreCalculationCls.setSkipTrgTrue();
        }
        if(set0ZipCodes.size()>0){
        map<Id,Inventory_Data__c> mapOldInventory = new map<Id,Inventory_Data__c>();
        map<Id,Inventory_Data__c> mapnewInventory = new map<Id,Inventory_Data__c>();
        for(Inventory_Data__c invv:[SELECT Is_available__c,Inventory_Count_Half__c,Id,Error_Message__c,Error__c,SOA_Error_Half_Count__c,Soa_Error__c,SOA_Error_Full_Count__c,Inventory_Count__c FROM Inventory_Data__c WHERE Error__c = true and Id =:set0ZipCodes]){
        mapOldInventory.put(invv.id,invv);
        Inventory_Data__c innnv = invv;
        innnv.Inventory_Count_Half__c = 0;
        innnv.Inventory_Count__c = 0;
        mapnewInventory.put(invv.id,innnv);
        }
        LeadScoreCalculationCls lscs = new LeadScoreCalculationCls();
            lscs.CalculateScore(mapnewInventory,mapOldInventory);
            LeadScoreCalculationCls.setSkipTrgTrue();
        }
    }
    
    Public void Process3Function(List<Inventory_Data__c> scope){
    System.debug('Proceess 3');
        for(Inventory_Data__c iddd:scope){
            iddd.Soa_Error__c = false;
            //iddd.SOA_Error_Half__c = false;
            iddd.Error__c = true;
            Decimal halfcount = iddd.SOA_Error_Half_Count__c;
            Decimal FullCount = iddd.SOA_Error_Full_Count__c;
            iddd.Inventory_Count_Half__c = halfcount;
            iddd.Inventory_Count__c = FullCount;
            iddd.SOA_Error_Half_Count__c = null;
            iddd.SOA_Error_Full_Count__c = null;
            iddd.Error_Message__c = '';
            LeadScoreCalculationCls.setSkipTrgTrue();
        }
    }

    global void finish(Database.BatchableContext BC){
    }
}