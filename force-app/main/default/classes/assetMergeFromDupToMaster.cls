/***********************************************************************************
Created By          :    Srinivas Vadla    
Created Date        :    11.07.2016
Company             :    Move Inc.
Usage               :    The main purpose of this class is to get the Asset Id's based on the Asset merge record and update the victim Asset's related participant Assets parent asset with survivor asset Id
Modified By         :    Srinivas Vadla
Modifide Date       :    11.08.2016
************************************************************************************/
global class assetMergeFromDupToMaster implements Database.Batchable < sObject > {
    global Database.querylocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([Select Id, Survivor_Fulfill_To_Asset_ID__c, Victim_Fulfill_To_Asset_ID__c from Asset_Merge__c WHERE status__c = 'To be Updated']);
    }
    global void execute(Database.BatchableContext BC, List < sObject > scope) {

        set < String > survSet = new set < String > ();
        set < String > victSet = new set < String > ();

        // surveyVsvictMapIds is map collection used to store Victim_Fulfill_To_Asset_ID__c as key and Survivor_Fulfill_To_Asset_ID__c as value from asset merge object
        Map < String, String > surveyVsvictMapIds = new Map < String, String > ();
        List < Asset_Merge__c > Assetmergelist = new List < Asset_Merge__c > ();

        For(sObject am: scope) {
                Asset_Merge__c newObjScope = (Asset_Merge__c) am; //type casting from generic sOject to Asset_Merge__c
                newObjScope.status__c = 'Updated';
                Assetmergelist.add(newObjScope);
                //If Survivor_Fulfill_To_Asset_ID__c is not blank on Asset merge object records such asset ids are stored in survSet
                if (newObjScope.Survivor_Fulfill_To_Asset_ID__c != null) {
                    survSet.add(newObjScope.Survivor_Fulfill_To_Asset_ID__c);
                    system.debug('survSet' + survSet);
                }
                //If Victim_Fulfill_To_Asset_ID__c is not blank on Asset merge object records such asset ids are stored in victSet
                if (newObjScope.Victim_Fulfill_To_Asset_ID__c != null) {
                    victSet.add(newObjScope.Victim_Fulfill_To_Asset_ID__c);
                    system.debug('victSet' + victSet);
                }
                List < Asset > victimParticipants = [Select Id, Parent_Asset__c, parent_Asset__r.External_ID__c from Asset where Asset_Type__c = 'Participant'
                    AND Parent_Asset__r.External_ID__c IN: victSet
                ];
                // If Survivor_Fulfill_To_Asset_ID__c and Victim_Fulfill_To_Asset_ID__c are not blank on asset merge object such ids are stored in a key value pair combination 
                if (newObjScope.Survivor_Fulfill_To_Asset_ID__c != null && newObjScope.Victim_Fulfill_To_Asset_ID__c != null) {
                    surveyVsvictMapIds.put(newObjScope.Victim_Fulfill_To_Asset_ID__c, newObjScope.Survivor_Fulfill_To_Asset_ID__c);
                }
            }
            //List<Asset> softDeleteAssets= [select Id from Asset where External_ID__c IN:victSet];
            //Delete softDeleteAssets;
        Update Assetmergelist;

        // fetchin assets for all the survey and victim asset ids on asset merge object
        Map < Id, Asset > survAstMap = new Map < Id, Asset > ([select ID, Name, Account_Party_ID__c, Parent_Asset__c, External_ID__c, status from Asset Where External_ID__c IN: survSet AND status = 'Active']);
        Map < Id, Asset > victAstMap = new Map < Id, Asset > ([select ID, Name, Account_Party_ID__c, Parent_Asset__c, parent_Asset__r.External_ID__c from Asset Where External_ID__c IN: victSet AND status = 'Active']);
        Map < String, List < Asset >> victimparticipants = new Map < String, List < Asset >> ();
        List < Asset > victimparticipantslist = [select Id, parent_asset__c, parent_Asset__r.External_ID__c from Asset where
            Asset_Type__c = 'Participant'
            AND parent_Asset__r.External_ID__c IN: victSet
        ];

        Map < string, Id > SurvexternalIdMap = new Map < string, Id > ();
        For(Asset surast: survAstMap.values()) {
            SurvexternalIdMap.put(surast.External_ID__c, surast.Id);
        }

        For(Asset ast: victimparticipantslist) {
            List < Asset > templist = new List < Asset > ();
            If(victimparticipants.containskey(ast.parent_asset__r.External_ID__c)) {
                templist = victimparticipants.get(ast.parent_asset__r.External_ID__c);
            }
            templist.add(ast);
            victimparticipants.put(ast.parent_asset__r.External_ID__c, templist);
        }

        system.debug('survAstMap' + survAstMap);
        system.debug('victAstMap' + victAstMap);

        //This list can be used to update surveyers parent with victims parent using help of asset merge object 
        List < Asset > updateAssetList = new List < Asset > ();

        // Iterating through all the victims id on asset merge object records
        for (String viAstId: victimparticipants.keySet()) {
            List < Asset > participantslist = new List < Asset > ();
            participantslist = victimparticipants.get(viAstId);
            String SurvId = surveyVsvictMapIds.get(viAstId);
            for (Asset child: participantslist) {
                child.parent_asset__c = SurvexternalIdMap.get(SurvId);
                updateAssetList.add(child);
            }

        }

        List < Database.SaveResult > results = Database.update(updateAssetList, false);
        List < Error__c > errorlist = new List < Error__c > ();
        for (Database.SaveResult result: results) {
            if (!result.isSuccess()) {
                for (Database.Error err: result.getErrors()) {
                    Error__c error = new Error__c();
                    error.Entity_Id__c = string.valueOf(err.getStatusCode());
                    error.Error_Description__c = err.getMessage();
                    error.Interface_Name__c = 'Asset Merge';
                    errorlist.add(error);
                    System.debug('Error: ' + err.getStatusCode() + ' ' + err.getMessage());
                }
            }
        }
        Insert errorlist;
        List < Asset > softDeleteAssets = [select Id from Asset where External_ID__c IN: victSet];
        Delete softDeleteAssets;
    }
    global void finish(Database.BatchableContext BC) {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob WHERE Id =: BC.getJobId()
        ];

        // Send an email to the Apex job's submitter 
        //   notifying of job completion. 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {
            'srinivas.vadla@move.com'
        };
        mail.setToAddresses(toAddresses);
        mail.setSubject('Record Clean Up Status: ' + a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
            ' batches with ' + a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
            mail
        });
    }
}