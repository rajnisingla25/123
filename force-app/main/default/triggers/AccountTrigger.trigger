//
// (c) 2015 Appirio, Inc.
//
// Trigger Name: AccountTrigger
// On SObject: Account
// Description: Trigger on Account to send outbound message
//
// 7th April 2015    Kirti Agarwal   Original (Task # T-376543)
// 11th May 2015     Ravindra Shekhawat Modified ( Task # T-393815)  added onBeforeInsert , onBeforeUpdate
// 08th June 2016    Krishnaveni Bodala Added onBeforeUpdate()(Leap#7995)
// 27th June 2016    Pallavi Tammana (Leap-8900)
// 24th May  2017    CRM-1166           Varun Kavoori         Added Method     afterupdate   SuspensionResumeStatusUpdate
//
trigger AccountTrigger on Account (before insert, Before update, after insert, after update, after delete) {

    
    if(OrderDecompController.testClassTriggerFlag  == true){
    system.debug('Inside test');
    } else {
        DisabledTrigger__c Dtrg= DisabledTrigger__c.getValues('Disabled');
        // Turn off trigger if the value of custom setting field is true.
        if(Dtrg != null && Dtrg.TaskTrigger__c!=UserInfo.getUserName() && Dtrg.AccountTrigger__c!=UserInfo.getUserName()){
        system.debug('Inside disable trigger');
            if(Trigger.isBefore)
            {
                //Updated By Pratik on 9th August 2018 for CRM-4544
                /*if(Trigger.isInsert)
                {
                    for(Account acct :Trigger.new)
                        acct.Scheduled_CallBack__c = acct.NextContactTime__c;
                        
                        
                }*/
                //MRB for LCM
                system.debug('Inside is before');
                if(Trigger.isInsert){
                    for(Account acct: Trigger.new){
                        if(acct.type == 'Lender Individual'){
                            acct.EssentialsStatus__c = 'Activate';
                            acct.Consolidated_Billing_Flag__c = false;
                                            system.debug('Inside lender loop');

                        }
                    }
                                    system.debug('Inside is insert');

                }
                if(Trigger.isUpdate)
                {
                    set<Id> setAccountTaskIds = new set<Id>();
                    for(Account acct:Trigger.new)
                    {           
                        if(acct.NVM_CallBack_DateTime__c != Trigger.oldMap.get(acct.Id).NVM_CallBack_DateTime__c)
                        {
                        setAccountTaskIds.add(acct.id);
                        }
                    }
                    Map<Id,Id> mapTaskAssignTo = new Map<Id,Id>();
                    if(setAccountTaskIds.size()>0){
                        
                        for(Task tsk:[Select id,Lead__c,whatId, OwnerId,Owner.name from task where whatId=:setAccountTaskIds order by createddate Desc limit 6]){
                        if(!tsk.Owner.name.contains('nvmapiuser@move.com') && !mapTaskAssignTo.containskey(tsk.whatId)){
                            mapTaskAssignTo.put(tsk.whatId,tsk.OwnerId);
                            }
                        }
                        }
                    for(Account acct:Trigger.new)
                    {
                        if(acct.Inventory_score__c!=null && acct.Account_Score__c!=null)
                        {
                            acct.Total_Score_Numeric__c = acct.Inventory_score__c*acct.Account_Score__c;
                        }
                        
                      //  if(!SkipAccountTrigger.skiptrigger){
                        //Updated By Pratik on 9th August 2018 for CRM-4544
                        if(acct.NVM_CallBack_DateTime__c != Trigger.oldMap.get(acct.Id).NVM_CallBack_DateTime__c )
                           //Commented by Pratik for CRM-4665 on 4th September 2018
                            //&& (acct.Follow_Up_Status__c == 'Follow up Scheduled- no Pitch' || acct.Follow_Up_Status__c == 'Follow up Scheduled- Pitched'))
                        {
                          
                             acct.Scheduled_CallBack__c = acct.NVM_CallBack_DateTime__c;
                             acct.Callback_User__c = mapTaskAssignTo.get(acct.Id);
                             //Added by Pratik on 27th September 2018 for CRM-4698
                             acct.Object_Id__c = acct.Id;
                             //Added by Pratik for CRM-4665 on 4th September 2018
                             //acct.NextContactTime__c = null;
                        }
                      //  }
                        //ends here
                    }
                }
            }  

            if(!SkipAccountTrigger.skiptrigger){
                AccountTriggerHandler theAccountTriggerHandler = new AccountTriggerHandler(Trigger.isExecuting, Trigger.size);  
                if(Switch_AccountTrigger__c.getInstance().Set_Overall_Trigger_Off__c == false) {
                    if(trigger.isAfter){
                    /* if(Trigger.isInsert){ //MRB LCM
                     list<Contact> contacts = new List<Contact>();
                     set<ID> accIds = new Set<Id>();
                     system.debug('After Insert');
                            for(Account acct: Trigger.new){
                            system.debug('for each account');
                                if(acct.type == 'Lender'){
                                contact c = new contact();
                                system.debug('if lender');
                                c.Firstname = acct.name.split(' ')[0];
                                c.lastName = acct.name.split(' ').size()>1 ? acct.name.split(' ')[1] : acct.name.split(' ')[0];
                                c.phone = acct.Home_Phone__c != null ? acct.Home_Phone__c : '';
                                c.Preferred_Phone__c = acct.preferred_phone__c != null ? acct.preferred_phone__c : 'Home';
                                c.Email = acct.Primary_Email__c;
                                c.accountId = acct.id;
                                c.active__c = true;
                                    contacts.add(c);
                                  accIds.add(acct.id);
                                }
                                
                            }
                            if(!contacts.isEmpty()){
                                insert contacts;
                                Set<Id> accountIds = new Set<Id>();
                                    for(Contact c: contacts){
                                        accountIds.add(c.accountId);
                                    }
                                    Id recordTypeIDCR = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;
                                    list<Account_Relationship__c> accRelationList = [SELECT ID FROM Account_Relationship__c WHERE Parent_Account__c IN: accountids AND RecordType.DeveloperName = 'Contact_Relationship' AND Active__c = true order by Name asc limit 49996];
                                    list<Account_Relationship__c> relations = new list<Account_Relationship__c>();
                                    for(contact c: contacts){   
                                      Account_Relationship__c accRelation = new Account_Relationship__c();
                                      accRelation.Active__c = true;
                                      accRelation.recordTypeId = recordTypeIDCR;
                                      accRelation.Parent_Account__c = c.accountId;
                                      accRelation.Contact_To__c = c.ID;
                                                
                                      if(accRelationList.isEmpty()){
                                           accRelation.Billing_Contact__c = true;
                                           accRelation.Contact_Role__c  = 'Primary Contact';              
                                      }
                                      
                                      relations.add(accRelation); 
                                    }
                                    if(!relations.isEmpty()){
                                        insert relations;
                                    }
                               
                            }
                            
                            
                                            system.debug('Inside is insert');
        
                        } */
                        if(checkRecursive.run == true){  
                            checkRecursive.run = false;    
                            if(trigger.isUpdate){
                                // Web service callout for Account records
                                theAccountTriggerHandler.onAfterUpdate(trigger.newMap, trigger.oldMap);   
                               // AccountTriggerHandler.InsertUpdatePhone(trigger.newMap, trigger.oldMap);                 
                            }    
                            if(trigger.isInsert){
                                // Web service callout for Account records && Populating the Associated Fields on Account
                                theAccountTriggerHandler.onAfterInsert(trigger.newMap);
                               // AccountTriggerHandler.InsertUpdatePhone(trigger.newMap, null);
                            }
                            //InsertUpdatePhone(trigger.newMap, trigger.oldMap);
                        }           
                    } 
                }
                AccountTriggerHandlerManager theAccountTriggerHandlerManager = new AccountTriggerHandlerManager();
                // Assets auto renewal method from Account    
                if(Trigger.IsAfter && Trigger.IsUpdate){ 
                    if(checkRecursive.runTwo == true){  
                        checkRecursive.runTwo = false;
                       // theAccountTriggerHandlerManager.AccountAssetAutoRenewal(Trigger.Newmap,Trigger.OldMap);                                         
                    } 
                }
                if(Trigger.IsAfter && Trigger.IsUpdate){ 
                     for(Account acctloop : Trigger.Newmap.values()){
                        Account oldvalues = Trigger.OldMap.get(acctloop.Id);
                        if(acctloop.Total_Contract_Value__c != oldvalues.Total_Contract_Value__c){
                             theAccountTriggerHandler.CollectioncaseReAssignment(Trigger.Newmap,Trigger.OldMap); 
                         }
                    }       
               }
               if(Trigger.IsAfter && Trigger.IsUpdate){ 
                    theAccountTriggerHandler.accountConsolidatedBilling(Trigger.New, Trigger.OldMap);
                }    
                
                
                
                if(Trigger.isBefore && Trigger.isUpdate){
                    for(Account acct:Trigger.new){
                    //acct.Total_Score_Numeric__c = acct.total_score__c;
                    }
                    theAccountTriggerHandler.AccountOwnerSync(Trigger.NewMap,Trigger.OldMap);                   
                    theAccountTriggerHandler.onBeforeUpdate(trigger.newMap, trigger.oldMap);
                }
                if(Trigger.IsAfter && Trigger.IsUpdate){ 
                     for(Account acctloop : Trigger.Newmap.values()){
                        Account oldvalues = Trigger.OldMap.get(acctloop.Id);
                        if(acctloop.Suspension_Status__c != oldvalues.Suspension_Status__c){
                             theAccountTriggerHandler.SuspensionResumeStatusUpdate(Trigger.Newmap,Trigger.OldMap); 
                         }
                    }       
               }  
                if(Trigger.IsAfter && Trigger.IsDelete){
                    theAccountTriggerHandler.binderAcctDeleteCallout(Trigger.OldMap);
                }
            }  
        }
    }
}