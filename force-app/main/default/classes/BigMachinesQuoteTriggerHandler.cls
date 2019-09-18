//****************************************************************************************
//Name          : BigMachinesQuoteTriggerHandler
//Date          : 15-DEC-2015
//Created by    : NTT Data
//Author        : Stanley Sequeira
//Description   : This Class is meant to Create Cases when Quotes get added to the system
//
// *****************************************************************************************

public with sharing class BigMachinesQuoteTriggerHandler{

 // Global Maps used in multiple methods to avoid queries in loops
    public static Map<Id,List<BigMachines__Quote_Product__c>> quoteProductMap;
    public static Map<Id,Id> accountTeamMemberMap;
    public static Map<Id,String> accountTypeMap;

//  This method is invoked from the Trigger. The Entry poinfzst to create cases
    public static void createCases(List<BigMachines__Quote__c> quotes, Map<Id,BigMachines__Quote__c> quotesMap){
            system.debug('@@ createCases - Start @@');

            List<Case> insertCaseList               = new List<Case>();
            Set<Id> quoteIdSet                      = new Set<Id>();
            Set<Id> accountIdSet                    = new Set<Id>();
            Map<Id,Boolean> mapOrderRSMap = new Map<Id,Boolean>();
            Set<String> rsBundleProd = new Set<String>{'RSRESPOND', 'RSTRANSACT', 'RSCONNECT'};
            for(BigMachines__Quote__c loopvar: quotes){
                system.debug('@@ loopvar.Status__c @@'+loopvar.BigMachines__Status__c);

                if(loopvar.BigMachines__Status__c == 'Ordered'){

                    if(quotesMap!=Null){
                        BigMachines__Quote__c oldRecord  = quotesMap.get(loopvar.Id);


               // Check the previous and the current state
                    if(loopvar.BigMachines__Status__c != oldRecord.BigMachines__Status__c){
                        quoteIdSet.add(loopvar.Id);
                        accountIdSet.add(loopvar.BigMachines__Account__c);
                       }
                    }
                }
               
            }


            system.debug('@@ quoteIdSet @@'+quoteIdSet);

          // Build the maps here
            quoteProductMap                         = getQuoteProductMap(quoteIdSet);
            accountTeamMemberMap                    = fetchAccountOwner(accountIdSet);
            accountTypeMap                          = createAccountTypeMap(accountIdSet);
            Database.DMLOptions dmlOpts             = assignRules();

            for(BigMachines__Quote__c loopvar: quotes){
                if(loopvar.BigMachines__Status__c == 'Ordered'){

                    if(quotesMap!=Null){
                        BigMachines__Quote__c oldRecord     = quotesMap.get(loopvar.Id);

                    // Check the previous and the current state
                     if(loopvar.BigMachines__Status__c != oldRecord.BigMachines__Status__c){

                    Map<String,Boolean> checkStatusList     = new Map<String,Boolean>();
                    Id caseOwnerId;

                    checkStatusList                         = checkStatus(loopvar);

                    if(checkStatusList.size()>0){
                       // String subAreaStr = 'New';
                        List<BigMachines__Quote_Product__c> quoteProductList = new List<BigMachines__Quote_Product__c>();
                        quoteProductList                    = quoteProductMap.get(loopvar.Id);

                       system.debug('@@ loopvar.BigMachines__Account__r.Type @@'+loopvar.BigMachines__Account__r.Type);
                   // Logic here to find the Case Owner
                       if(accountTypeMap.get(loopvar.BigMachines__Account__c)=='Broker'){
                            try{
                                if(loopvar.BigMachines__Account__c != Null){
                                    caseOwnerId             = accountTeamMemberMap.get(loopvar.BigMachines__Account__c);
                                }
                            }
                            catch(NullPointerException np){
                                system.debug('@@ Null Pointer Exception @@'+np);
                            }
                       }

                        Integer counter = 0;
                   // Maximum two cases can get created when it's Modify - Add / Renew
                        for(String str : checkStatusList.keySet()){

                            Case caseRecord         = new Case (
                                RecordTypeId        = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
                                Status              = 'New',
                                Origin              = 'Web',
                                Type                = 'Outbound',
                                Area__c             = 'Product Set Up',
                                Subject             = 'Welcome Call',
                                 
                                Oracle_Quote__c     = loopvar.Id,
                                AccountId           = loopvar.BigMachines__Account__c,
                                Sub_Area__c         = str,
                                Description         = createCaseDescription(quoteProductList,str)

                            );

                          // This fires the Active Assignment Rules
                            if(caseOwnerId == Null){
                                caseRecord.setOptions(dmlOpts);
                            }
                            else{
                                caseRecord.OwnerId  = caseOwnerId;
                            }
                            if(caseRecord.Description.contains('Respond') || caseRecord.Description.contains('Connect') || caseRecord.Description.contains('Transact') ){
                                    caseRecord.bundle_RS__c = true;
                                  }
                            //Commented By Pratik on 18th December 2018 for CRM-3405
                            //insertCaseList.add(caseRecord);
                            counter++;
                        }
                     }
                   }
                  }
                } // End of Ordered - If
            } // End of For Loop

            if(insertCaseList.size()>0){
                insert insertCaseList;
                SkipQuoteWelcomeTrigger.setSkipTrgTrue();
            }

            system.debug('@@ createCases - Start @@');
           }


//  Method to check if Case Creation is required
    private static Map<String,Boolean> checkStatus(BigMachines__Quote__c quote){
        system.debug('@@ checkStatus - Start @@');

        Map<String,Boolean> createCase          = new Map<String,Boolean>();

     // If Quote Type is New; Case Creation is allowed
        if(quote.BigMachines_Quote_Type__c == 'New'){
            // CRM-3209 - Do not create case for Moving Products
            for (BigMachines__Quote_Product__c quoteProd : quoteProductMap.get(quote.Id)) { // CRM-3209
                if (!Label.Moving_Product_Codes.contains(quoteProd.BigMachines__Product__r.ProductCode)) { // CRM-3209
                    createCase.put('New',true);
                    break;
                }
            }
        }

      // TODO Stan: Check the logic here
        else if(quote.BigMachines_Quote_Type__c == 'Modify'){
            List<BigMachines__Quote_Product__c> quoteProductList = quoteProductMap.get(quote.Id);
            if(checkType(quoteProductList,'Add')){
                createCase.put('New',true);
            }

            if(checkType(quoteProductList,'Renew')){
                createCase.put('Renew',true);
            }

        }

        else if(quote.BigMachines_Quote_Type__c == 'Retention'){
            List<BigMachines__Quote_Product__c> quoteProductList = quoteProductMap.get(quote.Id);
            if(checkType(quoteProductList,'Add')){
                createCase.put('New',true);
            }
          }
        return createCase;
    }


//  Returns the count of the Line Items based on the Parent Quote Id
//  This should not be a part of any loop
    private static Map<Id,List<BigMachines__Quote_Product__c>> getQuoteProductMap (Set<Id> quoteIdSet){
        system.debug('@@ checkCount - Start @@');

        Map<Id,List<BigMachines__Quote_Product__c>> quoteAllProductMap  = new Map<Id,List<BigMachines__Quote_Product__c>>();
        
         // CRM-1423 Added condition to avoid executing SOQL if set is empty
        if (!quoteIdSet.isEmpty()) {
            List<BigMachines__Quote_Product__c> quoteProductList          = [SELECT Id,BigMachines__Quote__c,Line_Type__c,BigMachines__Product__r.Name, Product_Type__c, // CRM-3446 Added Prduct_Type__c
                                                                                BigMachines__Product__r.ProductCode FROM BigMachines__Quote_Product__c //CRM-3209 Added ProductCode
                                                                                WHERE BigMachines__Quote__c =: quoteIdSet
                                                                             ];
    
            for(BigMachines__Quote_Product__c loopvar: quoteProductList){
    
                if(String.isNotBlank(loopvar.BigMachines__Quote__c)){
                    if(!quoteAllProductMap.containsKey(loopvar.BigMachines__Quote__c)) {
                        quoteAllProductMap.put(loopvar.BigMachines__Quote__c, new List<BigMachines__Quote_Product__c>());
                    }
                    quoteAllProductMap.get(loopvar.BigMachines__Quote__c).add(loopvar);
                }
    
            }
        }
        system.debug('@@ checkCount - End @@');
        return quoteAllProductMap;

    }


//  This method will check if the Quote Product contains a specific type
    private static boolean checkType(List<BigMachines__Quote_Product__c> quoteProductList, String typeValue){
        system.debug('@@ checkType - Start @@');

        Boolean doesExist = false;
        if(quoteProductList.size()>0)
        for(BigMachines__Quote_Product__c loopvar: quoteProductList){
            if(loopvar.Line_Type__c == typeValue){
                doesExist = true;
                break;
            }
        }

        system.debug('@@ checkType - End @@');
        return doesExist;

    }

//  This method will construct the Case Description by forming a String based on the Quote Products
    private static String createCaseDescription(List<BigMachines__Quote_Product__c> quoteProductList, String caseType){
        system.debug('@@ createCaseDescription - Start @@');

        String caseDescriptionStr   = '';

        if(quoteProductList.size()>0){
            for(BigMachines__Quote_Product__c loopvar: quoteProductList){
                    // CRM-3446 - Take Advantage - Branding in description when Product Type is Brand.
                    String description =  loopvar.BigMachines__Product__r.Name;
                    if (loopvar.BigMachines__Product__r.ProductCode.equalsIgnoreCase('ADVANTAGE') && loopvar.Product_Type__c.equalsIgnoreCase('Brand')) {
                        description = System.label.AdvantageBranding;
                    }
                    // CRM-3446 - End
                    if(caseType == 'Renew' && loopvar.Line_Type__c == 'Renew'){
                        // CRM-3446 - Commented below line, added new just below
                        //caseDescriptionStr += ' '+loopvar.BigMachines__Product__r.Name +';';
                        caseDescriptionStr += ' '+description +';';
                    }

                    if(caseType == 'New' && loopvar.Line_Type__c == 'Add'){
                        // CRM-3446 - Commented below line, added new just below
                        //caseDescriptionStr += ' '+loopvar.BigMachines__Product__r.Name +';';
                        caseDescriptionStr += ' '+description +';';
                    }
               }
          }

         caseDescriptionStr = caseDescriptionStr.trim();
         caseDescriptionStr = caseDescriptionStr.substring(0, caseDescriptionStr.length()-1);
         system.debug('@@ createCaseDescription - End @@');
         return caseDescriptionStr;

    }

//  This fetches the Account Team Member name for Case Ownership
//  This method should not be a part of any loop
    private static Map<Id,Id> fetchAccountOwner(Set<Id> accountIds){
        system.debug('@@ fetchAccountOwner - Start @@');

        List<AccountTeamMember> accTeamMemberList   = new List<AccountTeamMember> ();
        Map<Id,Id> accTeamMemberMap                 = new Map<Id,Id>();
        
        // CRM-1423 Added condition to avoid executing SOQL if set is empty
        if (!accountIds.isEmpty()) {
            accTeamMemberList                           = [SELECT Id,UserId,AccountID
                                                        FROM AccountTeamMember
                                                        WHERE AccountID IN: accountIds
                                                        AND TeamMemberRole = 'Account Manager'
                                                        ];
        }
        
        for(AccountTeamMember loopvar: accTeamMemberList){
            accTeamMemberMap.put(loopvar.AccountID, loopvar.UserId);

        }


        if (accTeamMemberList.size()>0){
            system.debug('@@ fetchAccountOwner - End @@');
            return accTeamMemberMap;
        }
        else{
            system.debug('@@ fetchAccountOwner - End @@');
            return null;
        }

    }

// This method assigns the Case using Active Assignment Rules
    private static Database.DMLOptions assignRules(){
        system.debug('@@ assignRules - Start @@');
        AssignmentRule assignmentRule                   = new AssignmentRule();
        assignmentRule                                  = [SELECT Id
                                                            FROM AssignmentRule
                                                            WHERE SobjectType = 'Case'
                                                            AND Active = true
                                                            limit 1
                                                            ];

        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmlOpts                     = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId   = assignmentRule.id;
        system.debug('@@ assignRules - End @@');
        return dmlOpts;


    }

//  This method checks if the Account is a Broker Account
    private static Map<Id,String> createAccountTypeMap(Set<Id> accountIds){
        system.debug('@@ createAccountTypeMap - Start @@');

        List<Account> accountList                       = new List<Account>();
        Map<Id,String> accountMap                       = new Map<Id,String>();
        
        // CRM-1423 Added condition to avoid executing SOQL if set is empty
        if (!accountIds.isEmpty()) {
            accountList                                     = [SELECT Id, Type
                                                            FROM Account
                                                            WHERE Id IN:accountIds
                                                            AND Type = 'Broker'
                                                            ];
        }
        
        if(accountList.size()>0){
            for(Account acc: accountList){
                accountMap.put(acc.Id, acc.Type);
            }
        }


        system.debug('@@ createAccountTypeMap - End @@');
        return accountMap;
    }
    public static void createOpportunityforQQ(List<BigMachines__Quote__c> quickQuotes){
        //Added by Pratik on 24th September 2018 for CRM-4812
        //assignQuoteTask(quickQuotes);
        system.debug('@@@@@@@@@inside create oppty method@@@@@@@@@');
        List<Opportunity> OpportunityList = new List<Opportunity>();
        List<BigMachines__Quote__c> bigMachinesQuote=new List<BigMachines__Quote__c>();
        Id recordtype1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Inside Sales').getRecordTypeId();
        Id recordtype2 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Broker Field Sales').getRecordTypeId();
        for(BigMachines__Quote__c qq: quickQuotes){
            if(qq.Is_Quick_Quote__c){
            system.debug('qq@@@@@@'+qq);
                Opportunity theOpportunity = new Opportunity();
                  theOpportunity.Name = 'The Opportunity';
                  theOpportunity.StageName = 'Prospecting';
                  theOpportunity.CloseDate = system.today();
                  theOpportunity.Bigmachine_Quote_ID1__c =qq.id;
                  theOpportunity.AccountId = qq.BigMachines__Account__c;
                  if(qq.Account_Type__c == 'Realtor Agent')
                  theOpportunity.RecordTypeId =  recordtype1; 
                  else
                  theOpportunity.RecordTypeId = recordtype2;
                  OpportunityList.add(theOpportunity);
            }
        }
        try{
        if(OpportunityList!=null && OpportunityList.size()>0){
            insert OpportunityList;
            /*for(Opportunity oppy: OpportunityList){
                    bigMachinesQuote.add(new BigMachines__Quote__c(
                        id=oppy.Bigmachine_Quote_ID1__c,
                        Opportunity__c= oppy.Id
                        ));
                }
            update bigMachinesQuote; */
        }
        }
        catch (exception ex){
            system.debug('Error Occured While Creating an Opportunity for QuickQuote'+ex.getStackTraceString());
        }
        
    }
    
     //Added by Sonu on 24th July 2019 for CRM-6278
    //@future
    public static void updateQuoteTask(Set<Id> setTask)
    {
    Set<String> setTaskSubject = new Set<String>();
        setTaskSubject.add('%Outbound call%');
        setTaskSubject.add('%Inbound call%');
        map<Id,Id> mapAllIds = new map<Id,Id>();
        DateTime CurrentTime = system.now().addMinutes(-30);
        Map<Id, Task> mapTask = new Map<Id, Task>();
        map<Id,Quote_Task__c> mapQTIds = new map<Id,Quote_Task__c>();
       
        List<Task> lstTask = [Select OwnerId, Quote_Task__c,WhatId,AccountId,Lead__c,Lead__r.RecordType.Name, Lead__r.Account__c, Opportunity__c, Opportunity__r.AccountId,Who.RecordType.Name, WhoId,NVMContactWorld__CW_Call_Start_Time__c,CallDurationInSeconds From Task 
                                Where Subject Like :setTaskSubject and Id=:setTask and Quote_Task__c=null]; //
        
        for(Task task :lstTask){
            if(task.WhatId!=null && Schema.Opportunity.SObjectType != task.WhatID.getSobjectType()){
            mapAllIds.put(task.WhatId,task.id);
            }
            
            if(task.WhatId!=null && Schema.Opportunity.SObjectType == task.WhatID.getSobjectType()){
            mapAllIds.put(task.AccountId,task.id);
            }
            if(task.WhoId!=null && task.Who.RecordType.Name!='OPCITY'){
            mapAllIds.put(task.WhoId,task.id);
            }
            if(task.Lead__c!=null && task.Lead__r.RecordType.Name!='OPCITY'){
            if(task.Lead__r.Account__c!=null){
            mapAllIds.put(task.Lead__r.Account__c,task.id);
            }
            }
            if(task.Opportunity__c!=null){
            if(task.Opportunity__r.AccountId!=null && !mapAllIds.containskey(task.Opportunity__r.AccountId)){
            mapAllIds.put(task.Opportunity__r.AccountId,task.id);
            }
            }
            }
            if(mapAllIds.keyset().size()>0){
            List<Quote_Task__c> lstQuoteTask = [Select Id,name,Quote__r.CreatedDate,Quote__r.OwnerId,Quote__r.BigMachines__Account__c from Quote_Task__c where Quote__r.BigMachines__Account__c=:mapAllIds.keyset()]; // ,(select Id from Activities__r)

System.debug(lstQuoteTask+'PPPP');
            for(Quote_Task__c quoteTask :lstQuoteTask)
            { 
            //if(quoteTask.Activities__r.size()<1 || Test.isRunningTest()){
            mapQTIds.put(quoteTask.Quote__r.BigMachines__Account__c,quoteTask);
            //}
            }
            }
            Boolean runUpdate = false;
            for(Task task :lstTask){
            System.debug('working 1');
            if(mapQTIds.containsKey(task.WhatId) && Schema.Opportunity.SObjectType != task.WhatID.getSobjectType()){
            System.debug('working 2');
            runUpdate = true;
            Quote_Task__c quoteTask = mapQTIds.get(task.WhatId);
            task.Quote_Task__c = quoteTask.Id;
            }
if(mapQTIds.containsKey(task.AccountId) && Schema.Opportunity.SObjectType == task.WhatID.getSobjectType()){
            System.debug('working 2');
            runUpdate = true;
            Quote_Task__c quoteTask = mapQTIds.get(task.AccountId);
            task.Quote_Task__c = quoteTask.Id;
            }
            if(task.Lead__c!=null && task.Quote_Task__c==null){
            System.debug('working 3');
            if(task.Lead__r.Account__c!=null){
            System.debug('working 4');
            if(mapQTIds.containsKey(task.Lead__r.Account__c)){
            System.debug('working 5');
            runUpdate = true;
            Quote_Task__c quoteTask = mapQTIds.get(task.Lead__r.Account__c);
            task.Quote_Task__c = quoteTask.Id;
            }
            }
            }
        if(task.Opportunity__c!=null && task.Quote_Task__c==null){
            System.debug('working 3');
            if(task.Opportunity__r.AccountId!=null){
            System.debug('working 4');
            if(mapQTIds.containsKey(task.Opportunity__r.AccountId)){
            System.debug('working 5');
            runUpdate = true;
            Quote_Task__c quoteTask = mapQTIds.get(task.Opportunity__r.AccountId);
            task.Quote_Task__c = quoteTask.Id;
            }
            }
            }
            }
            if(runUpdate){
            SkipTaskTrigger.setSkipTrgTrue();
            update lstTask;

            }
        
    }
    
    //Added by Pratik on 24th September 2018 for CRM-4812
    public static void assignQuoteTask(Set<Id> setQuotes)
    {
         List<BigMachines__Quote__c> lstQuotes= [Select Id,OwnerId,Lead_Id__c, BigMachines__Opportunity__c , BigMachines__Opportunity__r.Lead__c, Opportunity__c, Opportunity__r.Lead__c, BigMachines__Account__c from BigMachines__Quote__c where Id=:setQuotes and BigMachines_Quote_Type__c Not IN ('Pre auth','Auto-Renew') and CreatedDate=Today];
         Map<Id, Id> mapOwnerIdVsQuoteId = new Map<Id, Id>();
         Set<Id> setRecordIds = new Set<Id>();
        DateTime CurrentTime = system.now().addMinutes(-30);
        for(BigMachines__Quote__c quote :lstQuotes){
            mapOwnerIdVsQuoteId.put(quote.OwnerId, quote.Id);
            if(quote.BigMachines__Opportunity__c!=null){
            if(quote.BigMachines__Opportunity__r.Lead__c!=null){
            setRecordIds.add(quote.BigMachines__Opportunity__r.Lead__c);
            }
            }
            if(quote.Opportunity__c!=null){
            if(quote.Opportunity__r.Lead__c!=null){
            setRecordIds.add(quote.Opportunity__r.Lead__c);
            }
            }
            if(quote.Lead_Id__c!=null && quote.Lead_Id__c!=''){
            setRecordIds.add(quote.Lead_Id__c);
            }
            if(quote.BigMachines__Account__c!=null){
            setRecordIds.add(quote.BigMachines__Account__c);
            }
            }
        Set<String> setTaskSubject = new Set<String>();
        setTaskSubject.add('%Outbound call%');
        setTaskSubject.add('%Inbound call%');
        Map<Id, Task> mapTask = new Map<Id, Task>();
        if(setRecordIds.size()>0){
        List<Task> lstTask = [Select OwnerId, Quote_Task__c,CallDurationInSeconds From Task 
                                Where OwnerId IN:mapOwnerIdVsQuoteId.keySet() 
                                AND Subject Like :setTaskSubject and (WhatId=:setRecordIds OR WhoId=:setRecordIds) and CreatedDate>:CurrentTime
                                ORDER BY CallDurationInSeconds DESC limit 1];
        
        for(Task task :lstTask){
            mapTask.put(task.OwnerId, task);
            }
        }
        List<Quote_Task__c> lstQuoteTask = new List<Quote_Task__c>();
        
        for(BigMachines__Quote__c quote :lstQuotes)
        {
           
                Quote_Task__c quoteTask  = new Quote_Task__c();
                quoteTask.Quote__c = quote.Id;
                quoteTask.OwnerId = quote.OwnerId;
                lstQuoteTask.add(quoteTask);
           // }
        }
        
        if(!lstQuoteTask.isEmpty())
        {
            insert lstQuoteTask;
            
            List<Task> lstTaskToUpdate = new List<Task>();
            for(Quote_Task__c quoteTask :lstQuoteTask)
            {
                if(mapTask.containsKey(quoteTask.OwnerId))
                {
                    Task task = mapTask.get(quoteTask.OwnerId);
                    task.Quote_Task__c = quoteTask.Id;//mapOwnerIdVsQuoteId.get(quoteTask.OwnerId);
                    lstTaskToUpdate.add(task);
                }
            }
            
            if(!lstTaskToUpdate.isEmpty())
                update lstTaskToUpdate;
        }
    }
}