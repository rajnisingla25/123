global class UpdateTCVCustomerType implements Schedulable {
   global void execute(SchedulableContext sc) {
     //Expire Assets
     try{
          SkipAssetTrigger.setSkipTrgTrue();
          SkipAccountTrigger.skiptrigger = True;          
          Set<Id> accIds = new Set<Id>();        
          Boolean expiredProcesstype = false;  
          List<Account> lstAccount = new List<Account>();         
          Map<Id,Decimal> mapAccActive = new Map<Id,Decimal>();
          Map<Id,Decimal> mapAccExpired = new Map<Id,Decimal>();
          Map<Id,Decimal> mapAccProspect = new Map<Id,Decimal>();
           Map<Id,Decimal> mapAccList= new Map<Id,Decimal>();
          
            Decimal rcount = 0.0;
            Date dt = System.Today().addDays(-90);
            Date dtold = System.Today().addDays(-93);
           List<Asset> lstAssett = [Select Id,AccountId,Status,Total_net__c,Expired_Date__c , Fulfillment_Status__c,TCV_Processed__c from Asset where Fulfillment_Status__c ='Fulfilled' and  Asset_Type__c = 'Parent' and Status ='Expired' and TCV_Processed__c = '90Days' and (Expired_Date__c<=:dt and Expired_Date__c>=:dtold ) order by LastModifiedDate Desc limit 50];
         // List<Asset> lstAssetmarkingtrue = [Select Id,AccountId,Status,Total_net__c,Expired_Date__c , Fulfillment_Status__c,TCV_Processed__c from Asset where Fulfillment_Status__c ='Fulfilled' and  Asset_Type__c = 'Parent' and TCV_Processed__c = 'true' and (Expired_Date__c<=:dt and Expired_Date__c>=:dtold ) and LastModifiedDate!=today order by LastModifiedDate Desc limit 50];
          List<Asset> lstAsset = new List<Asset>();
          if(lstAssett.size()>0){
          expiredProcesstype = true;
          lstAsset.addAll(lstAssett);
          }
          /* else if(lstAssetmarkingtrue.size()>0){
          for(Asset ast:lstAssetmarkingtrue){
              ast.TCV_Processed__c = 'false';            
            }  
            update lstAssetmarkingtrue;
          }  */
          else {
          lstAsset = [Select Id,AccountId,Status,Total_net__c,Expired_Date__c , Fulfillment_Status__c,TCV_Processed__c from Asset where Fulfillment_Status__c ='Fulfilled' and Asset_Type__c = 'Parent'and TCV_Processed__c = 'false' and order_line_item__r.order.Status='Fulfilled' order by LastModifiedDate Desc limit 50];

          }
          
          
          for(Asset ast:lstAsset){
              ast.TCV_Processed__c = 'true';
              //ast.Expired_Date__c = null;
              if(ast.AccountId!=null){
              accIds.add(ast.AccountId);  
              //mapAccList.put(ast.AccountId,0.0); 
              } 
              mapAccList.put(ast.AccountId,0.0);                 
            }  
            List<Account> AllAccounts = [Select id, Account_Sub_Type__c , Total_Contract_Value__c from Account where id IN: accIds ];   
                
            for(Asset ast:[Select Id,AccountId,Expired_Date__c,Status,End_Date__c,Total_net__c ,Fulfillment_Status__c from Asset where AccountId IN:accIds and Asset_Type__c = 'Parent']){
                   system.debug('Testing null2'+ast.status +'**'+ast.Expired_Date__c);
                    if(ast.Status == 'Active' && ast.Fulfillment_Status__c=='Fulfilled'){
                        if(mapAccList.containskey(ast.AccountId)){                           
                             //mapAccList.put(ast.AccountId,0.0);
                            Decimal rcountt = mapAccList.get(ast.AccountId);
                            system.debug('Testing null2'+ast.Total_net__c);
                            //if(){}
                            if(ast.Total_net__c!=null){rcountt =  rcountt+ast.Total_net__c;  }   
                            system.debug('Testing null2'+rcountt); 
                            mapAccList.put(ast.AccountId,rcountt);                      
                            mapAccActive.put(ast.AccountId,rcountt);
                        }                        
                    }             
                    if(ast.Expired_Date__c ==null){if(ast.End_Date__c!=null){ast.Expired_Date__c=ast.End_Date__c.AddDays(1);}} 
                    if(ast.Expired_Date__c ==null){ast.Expired_Date__c=system.today();}                 
                    System.debug('****** '+date.valueof(ast.Expired_Date__c).daysBetween(Date.today()));
                     if((ast.status == 'Expired' || ast.status == 'Cancelled') && (date.valueof(ast.Expired_Date__c).daysBetween(Date.today())) <90  && (!mapAccActive.containsKey(ast.AccountId))){ 
                     system.debug('Testing null'+ast.status +'**'+ast.Expired_Date__c);                        
                        
                           mapAccExpired.put(ast.AccountId,rcount);  
                            
                                         
                    }                
                   if((ast.status == 'Expired'  || ast.status == 'Cancelled') && (date.valueof(ast.Expired_Date__c).daysBetween(Date.today()) >= 90)  && (!mapAccExpired.containsKey(ast.AccountId)) && (!mapAccActive.containsKey(ast.AccountId))){        
                           system.debug('Testing null'+ast.status +'**'+ast.Expired_Date__c);                  
                           mapAccProspect.put(ast.AccountId,rcount);                           
                                              
                    }
                }   
                
                System.debug('******'+mapAccActive);
                for(Account acc : AllAccounts){
                    //Account acc = new Account(Id=accId,Total_Contract_Value__c=mapAccList.get(accId));
                     
                    if(mapAccActive.containsKey(acc.Id)){
                        acc.Account_Sub_Type__c = 'Customer';
                        acc.Total_Contract_Value__c=mapAccActive.get(acc.Id);
                    } else if(mapAccExpired.containsKey(acc.Id)) {
                        
                        acc.Account_Sub_Type__c = 'Former Customer';
                        acc.Total_Contract_Value__c=0.0;
                    } else if(mapAccProspect.containsKey(acc.Id)){                            
                            acc.Account_Sub_Type__c = 'Prospect';    
                            acc.Total_Contract_Value__c=0.0;                       
                    } else {}
                            
                    lstAccount.add(acc);
                }
                update lstAccount;
                update lstAsset;
        } catch(Exception ex){
     
        }
    }
}