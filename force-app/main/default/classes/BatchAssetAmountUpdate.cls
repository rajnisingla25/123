/* Class : batchAssetAmountUpdate 
     Purpose : To update Balance Amount on Asset
     Created Date : 25th May 2016
     Modified To update the correct past due and paid amnount values: 17 Jan 2018 */
  // Batch class to update Balance Amount in Asset
  
  
 global class BatchAssetAmountUpdate implements Database.Batchable<sObject> {
  //Start Method
  global Database.QueryLocator start(Database.BatchableContext BC) {
         datetime myDateTime = datetime.now().addHours(-24);
      	 //datetime myDateTime = datetime.now().addDays(-9); 
        string Paid='Paid';
        string PastDue='Past Due';
      // CRM-2453-- removed Pastdue status filter due to some having null values.
        String query = 'Select Id,Name,Invoice_Status__c,Zuora__Balance2__c from Zuora__ZInvoice__c WHERE SystemModStamp >=:myDateTime  AND Invoice_status_check__c = TRUE ';
       //String query = 'Select Id,Name,Invoice_Status__c,Zuora__Balance2__c from Zuora__ZInvoice__c WHERE SystemModStamp >= 2018-02-05T23:40:05.000+0000  AND Invoice_status_check__c = TRUE ';
       return Database.getQueryLocator(query);
    }
    // Execute Method
    global void execute(Database.BatchableContext BC, List<Zuora__ZInvoice__c> scope) {
    //List<Batch_Status__c> BatchStatuses = new List<Batch_Status__c>();

         List<Asset> AssetsListToUpdate = new List<Asset> ();
         Date minSt  = date.newInstance(2099,1,1);
         Date maxEnd = date.newInstance(1700,1,1);
        // datetime myDateTime = datetime.now().addHours(-24);
         Set<id> assetsIds= new Set<id>();
       	 Set<id> FilteredassetsIds= new Set<id>();
         set<id> inids = new set<id>();
         for(Zuora__ZInvoice__c zz: scope){
            inids.add(zz.id);
         }
        system.debug('Invoice id:' +inids);
         if(!inids.isEmpty()){
          List<Invoice_Item__c> itlist = [select id,Charge_Date__c, Charge_Amount__c,Asset__c,  Asset__r.Asset_Type__c, Asset__r.Start_Date__c,Asset__r.End_Date__c,Asset__r.Paid_Amount__c,Asset__r.Past_Due_Amount__c,Invoice__c FROM Invoice_Item__c WHERE Invoice__c IN:inids];
          for(Invoice_Item__c iitm : itlist){
            assetsIds.add(iitm.Asset__c);
          }
          }
          if(!assetsIds.isEmpty()){
          List<Asset> lstAsst = [select id, Name,Start_Date__c,End_Date__c,Paid_Amount__c,Past_Due_Amount__c,Asset_Type__c FROM Asset WHERE ID IN :assetsIds AND Asset_Type__c ='Parent' AND Status != 'Cancelled' AND Status != 'Expired' ];
          for(Asset ast : lstAsst){
            if(ast.Start_Date__c < minSt){  
                minSt = ast.Start_Date__c;
            }
            if(ast.End_Date__c > maxEnd){  
                maxEnd= ast.End_Date__c ;                
            } 
            //FilteredassetsIds.add(ast.id);               
         }
 		system.debug('Start Date:' + minSt);             
        system.debug('end Date:' + maxEnd); 
         System.debug('####-Assets'+ assetsIds);
         
            map<id, decimal> paidmap= new map<id, decimal>();
            map<id, decimal> pastDueMap = new map<id, decimal>();
            
              // CRM-2453 Modification to pass correct start date and end date.
            for(Asset ast : lstAsst){
                for(Invoice_Item__c it: [SELECT id,Name, Asset__c,  Asset__r.Asset_Type__c, Charge_Date__c,Service_Start_Date__c,Charge_Amount__c, Invoice__c,
                                         Invoice__r.Invoice_Status__c, Invoice__r.Zuora__Balance2__c FROM Invoice_Item__c
                                         WHERE Asset__c = :ast.Id AND Service_Start_Date__c >= :ast.Start_Date__c AND Service_Start_Date__c <=: ast.End_Date__c ])
                {              
                    //System.debug('Asset Id in loop:' + it.Asset__c);
                    //For paid and Zero Balance.
                    // CRM-2453-- removed status filter due to some having null values.
                    if(it.Invoice__r.Zuora__Balance2__c == 0.00){
                        decimal ChargeCal =0.00;
                        //system.debug('test1'+paidmap.containsKey(it.Asset__c));
                        if(paidmap.containsKey(it.Asset__c)){                 
                            ChargeCal =  paidmap.get(it.Asset__c); 
                        }else{
                            ChargeCal =0.00;
                        }
                        ChargeCal += it.Charge_Amount__c;
                        paidmap.put(it.Asset__c, ChargeCal);
                    }
                    //For Past Due and Balance.
                    if(it.Invoice__r.Invoice_Status__c == 'Past Due' && it.Invoice__r.Zuora__Balance2__c > 0.00 ){
                        decimal ChargeCalDue =0.00;
                        // system.debug('test1'+pastDueMap.containsKey(it.Asset__c));
                        if(pastDueMap.containsKey(it.Asset__c)){                 
                            ChargeCalDue =  pastDueMap.get(it.Asset__c); 
                        }else{
                            ChargeCalDue =0.00;
                        }
                        ChargeCalDue += it.Charge_Amount__c;
                        pastDueMap.put(it.Asset__c, ChargeCalDue);
                    }
                    
                }
            }
            System.debug('@@@@- Paid Amount==========>'+paidmap);
            System.debug('@@@@- Past Due Amount==========>'+pastDueMap);
           
            for(Asset ast : lstAsst){   
                if((paidmap.containskey(ast.id) || pastDueMap.containskey(ast.id)) && ast.Asset_Type__c == 'Parent'){
                    ast.Paid_Amount__c = paidmap.get(ast.id);
                    ast.Past_Due_Amount__c = pastDueMap.get(ast.id);
                     system.debug('Asset Id:' + ast.id + ' Paid:' + ast.Paid_Amount__c + ' Past Due:' + ast.Past_Due_Amount__c);
                     //System.debug('@@@@-Amount==========>'+ ast.Past_Due_Amount__c);
                     AssetsListToUpdate.add(ast);
                }
            }
            SkipAssetTrigger.setSkipTrgTrue();  
             update AssetsListToUpdate;     
        }
        
    }   
    // Finish Method
    global void finish(Database.BatchableContext BC) {
    }
  }