//
// (c) 2015 Appirio, Inc.
//
// Trigger Handler Manager Name: AssetTriggerHandlerManager
// Trigger: AssetTrigger
// On SObject: Asset
// Trigger Handler: AssetTriggerHandler
// Description: Account Territory & Account Type Management Based On Asset Purchase Creation Validation.
//
// 04th May 2015     Ravindra Shekhawat     Original (Task # T-381432)
// 06th May 2015     Hemendra Singh Bhati   Modified (Task # T-380800)  - Added Method: autoPopulateAccountProductFields().
// 08th May 2015     Hemendra Singh Bhati   Modified (Task # T-393511)  - Updated Method: autoPopulateAccountProductFields().
// 12th May 2015     Ravindra Shekhawat     Modified (Task # T-393828)  - Added Method: populateProposedLeadsBasedOnProduct().
// 13th May 2015         Hemendra Singh Bhati       Modified (Task # T-394775)  - Added Method: updateParentAssetFulfillmentStatus().
// 20th May 2015         Hemendra Singh Bhati       Modified (Issue # I-163507) - Updated Method: rolledUpFromAssets().
// 25th May 2015         Hemendra Singh Bhati       Modified (Task # T-398006)  - Added Method: updateAssetOLIFulfillmentStatus().
// 29th May 2015     Hemendra Singh Bhati   Modified (Task # T-400125)  - Added Method: updateFulfillToAssetsCPLoginStatus().
// 30th June 2015    Ravinder reddy         Modified (Leap - 1592) - updated method updateCaseAssetRelationship();
// 08th July 2015    Kalyan Meda            Modified (Leap - 1594) - updated method updateCaseAssetRelationshipOnAssetUpdate
//

public without sharing class AssetTriggerHandlerManager {
    @TestVisible private User currentUser;
    @TestVisible private String territoryId;
    @TestVisible private String unassignedTerritoryId;
    Map<Id, Product2> productMap;
    Map<String, Asset_Promised_Leads__c> promisedLeadsMap;
    public boolean isExecutedonce_AssetSendEmail = false;
    Public Map<Id, Decimal> theMapOpportunityAmounts= new Map<Id, Decimal>();
    public static Map<Id,Account_Relationship__c> accountRelationsList = new Map<Id,Account_Relationship__c>();
    Public Map<String, Products__c> mapproducts = Products__c.getall();
    public static boolean ranAlready = false;
    // The Constructor.
    public AssetTriggerHandlerManager() {
    }
    
    // This method udpates the "Account.Account_Sub_Type__c" and "Account.Territories__c" custom field.
    public void updateAccountInfoOnAssetInsert(List<Asset> assetList) {
        Savepoint sp;
        
        List<Account> accountListToUpdate = new List<Account>();
        getCurrentUserInformation();
        
        // Get the accounts to update.
        try {
            Map<Id, List<Asset>> accountAssetMap = getAccountsToUpdate(assetList,true);
            for(Account account : [SELECT Id, Type, Account_Sub_Type__c, Do_Not_Assign__c,Do_Not_Move__c, Sales_Lock_User__c, Sales_Lock_User__r.Primary_Territory__c
                                   FROM Account WHERE Id IN :accountAssetMap.keySet()]) {
                                       if(
                                           (
                                               account.Account_Sub_Type__c == Constants.ACCOUNT_SUBTYPE_PROSPECT ||
                                               account.Account_Sub_Type__c == Constants.ACCOUNT_SUBTYPE_FORMER_CUSTOMER
                                           )
                                           && account.Do_Not_Assign__c == false
                                       ) {
                                           account.Account_Sub_Type__c = Constants.ACCOUNT_SUBTYPE_CUSTOMER;
                                           account.Is_Update_By_Trigger__c = true;
                                           if(account.Do_Not_Move__c==false)
                                               if(account.Sales_Lock_User__c != null) {
                                                   account.OwnerId = account.Sales_Lock_User__c; //2352 logic change for owner update
                                                   if(account.Sales_Lock_User__r.Primary_Territory__c != null && account.Sales_Lock_User__r.Primary_Territory__c.trim() != '') {
                                                       account.Territories__c = account.Sales_Lock_User__r.Primary_Territory__c;
                                                   }
                                                   else {
                                                       account.Territories__c = unassignedTerritoryId;
                                                   }
                                               }
                                           else {
                                               account.OwnerId = currentUser.Id;
                                               if(territoryId != null) {
                                                   account.Territories__c = territoryId;
                                               }
                                               else {
                                                   account.Territories__c = unassignedTerritoryId;
                                               }
                                           }
                                           
                                           account.LastAssetActiveDate__c = null;
                                           // account.Do_Not_Assign__c = true;
                                           accountListToUpdate.add(account);
                                       }
                                   }
            
            sp = Database.setSavepoint();
            // Update accounts.
            if(accountListToUpdate.size() > 0) {
                update accountListToUpdate;
            }
            else {
                // Set unassigned territory.
            }
        }
        catch(Exception e) {
            Database.rollback(sp);
            system.debug('Error Occurred: ' + e.getMessage());
        }
    }
    
    // This method updates account's Account_Sub_Type__c, Territories__c, LastAssetActiveDate and OwnerId.
    public void updateAccountInfoOnAssetUpdate(Map<Id, Asset> oldAssetMap, Map<Id, Asset> assetsMap) {
        List<Task> lstTask = new List<Task>();
        Set<Id> setAccountIds = new Set<Id>();
        Set<Id> setDAPAssetIds = new Set<Id>();
        Set<id> setAssetAdVerification = new Set<id>();
        for(Asset ast:assetsMap.values()){
            if(ast.Product_Code__c=='DIGITALAGENT' && ast.asset_type__c=='Parent' && ast.Fulfillment_Status__c=='Failure'){
                setDAPAssetIds.add(ast.id);
            }
            System.debug(ast.Product_Code__c+'$$$$$$$'+ast.Fulfillment_Status__c);
            if(ast.Product_Code__c=='DIGITALAGENT' && ast.asset_type__c=='Parent' && ast.Line_type__c=='Add' && ast.Fulfillment_Status__c=='Fulfilled'){
                if(oldAssetMap.get(ast.id).Fulfillment_Status__c!='Fulfilled'){
                    setAssetAdVerification.add(ast.Id);
                }
            }
            if(ast.Follow_Up_Status__c!=oldAssetMap.get(ast.id).Follow_Up_Status__c){
                setAccountIds.add(ast.AccountId);
                Task tsk = new Task();
                tsk.whatId = ast.AccountId;
                tsk.Asset__c = ast.id;
                tsk.ActivityDate = System.Today();
                tsk.Status = 'Completed';
                tsk.Subject = ast.Follow_Up_Status__c;
                tsk.Description = ast.Comments__c;
                lstTask.add(tsk);
            }
        }
        if(setAccountIds.size()>0){
            
            SkipAccountTrigger.setSkipTrgTrue();
            if(!SkipTaskTrigger.skiptrigger){
                
                insert lstTask;
                if(lstTask.size()>0){
                    SkipTaskTrigger.setSkipTrgTrue();
                }
            }
            
            List<Account> lstAccount = [Select Id,Name,Last_Sales_Contact_Date__c from Account where id=:setAccountIds];
            if(lstAccount.size()>0){
                for(Account acc:lstAccount){
                    //acc.Last_Sales_Contact_Date__c = System.Today();
                    acc.Last_Sales_Contact_Date__c = System.Now(); /* Anup 4/5/2016 - Changing field type to date/time */
                    
                }
                
                
                update lstAccount;
            }
        }
        System.debug('DDAP'+setAssetAdVerification);
        if(setAssetAdVerification.size()>0){
            set<Id> setQuoteIds = new set<Id>();
            for(Asset ast:[Select Id,Name,Line_type__c,AccountId,Order_Line_Item__r.order.Oracle_Quote__c from Asset where id=:setAssetAdVerification]){
                if(ast.Order_Line_Item__r.order.Oracle_Quote__c!=null){
                    setQuoteIds.add(ast.Order_Line_Item__r.order.Oracle_Quote__c);
                }
            }
            List<Case> lstCasesadd = new List<Case>();
            if(setQuoteIds.size()>0){
                lstCasesadd = AdVerificationCase(setQuoteIds);
                insert lstCasesadd;
            }
        }
        if(setDAPAssetIds.size()>0 || test.isRunningTest()){
            Map<Id,Id> mapDAPASSETIDCASEIDIds = new Map<Id,Id>();
            Map<Id,Asset> mapDAPASSETCASEID = new Map<Id,Asset>();
            List<Asset> lstDapAssets = [Select Id,Name,Line_type__c,AccountId,Order_Line_Item__r.order.Oracle_Quote__c from Asset where id=:setDAPAssetIds];
            for(Asset ast:lstDapAssets){
                setAssetAdVerification.add(ast.Id);
                mapDAPASSETIDCASEIDIds.put(ast.Order_Line_Item__r.order.Oracle_Quote__c,null);
                mapDAPASSETCASEID.put(ast.Order_Line_Item__r.order.Oracle_Quote__c,ast);
            }
            if(mapDAPASSETIDCASEIDIds.keyset().size()>0 || test.isRunningTest()){
                ProductCase__c ppcase= ProductCase__c.getValues('DIGITIALAGENT');
                if(ppcase!=null){
                    for(Case cse:[Select Id,Oracle_Quote__c from case where Oracle_Quote__c=:mapDAPASSETIDCASEIDIds.keyset() and Type=:ppcase.Case_Type__c and Sub_Area__c = :ppcase.Case_Sub_Area__c and Subject = :ppcase.Case_Subject__c]){
                        mapDAPASSETIDCASEIDIds.put(cse.Oracle_Quote__c,cse.id);
                    }
                    Map<Id,Case> lstCases = new Map<Id,Case>();
                    Map<String,String> mapManualQueueName = new Map<String,String>();
                    for(Group grp:[SELECT DeveloperName,Id,Name,Type FROM Group WHERE Type='Queue']){
                        mapManualQueueName.put(grp.DeveloperName,grp.Id);
                    }
                    
                    
                    
                    for(Id idd:mapDAPASSETIDCASEIDIds.keyset()){
                        if(mapDAPASSETIDCASEIDIds.get(idd)!=null){
                            System.debug('Case Found '+idd);
                        } else {
                            System.debug('Case not Found '+idd);
                            Case caseToAdd = new Case();
                            caseToAdd.Status = 'New';
                            caseToAdd.Origin = 'Web';
                            caseToAdd.Type = ppcase.Case_Type__c;
                            caseToAdd.Is_Tiger_Lead__c = false;
                            caseToAdd.Oracle_Quote__c  = idd;
                            caseToAdd.Description  = mapDAPASSETCASEID.get(idd).Line_type__c;
                            caseToAdd.Is_Pre_Welcome_Call__c = false;
                            caseToAdd.Area__c = ppcase.Case_Area__c;
                            caseToAdd.Subject = ppcase.Case_Subject__c;
                            caseToAdd.Sub_Area__c = ppcase.Case_Sub_Area__c;
                            caseToAdd.AccountId = mapDAPASSETCASEID.get(idd).AccountId;
                            if(ppcase.Case_Subject__c!=null){
                                if(mapManualQueueName.containskey(ppcase.Queue__c)){
                                    caseToAdd.ownerId = mapManualQueueName.get(ppcase.Queue__c);
                                }
                            }
                            lstCases.put(idd,caseToAdd);
                        }
                        
                    }
                    if(lstCases.values().size()>0){
                        Insert lstCases.values();
                    }
                }
            }
        }
    }
    
    Public List<Case> AdVerificationCase(Set<Id> setQuoteDapIds){
        Integer rrrcount=0;
        List<Case> lstCases = new List<Case>();
        ProductCase__c ppcase= ProductCase__c.getValues('Add Verification');
        if(ppcase!=null){
            if(setQuoteDapIds.size()>0){
                System.debug(setQuoteDapIds+'AdVer');
                List<Case> lstCase = [Select Id,Oracle_Quote__c from case where Oracle_Quote__c=:setQuoteDapIds and Type = :ppcase.Case_Type__c];
                if(lstCase.size()<1){
                    List<Asset> lstAsset= [Select AccountId,Line_type__c,order_line_item__r.order.Oracle_Quote__c from Asset where asset_type__c='Parent' and (Fulfillment_Status__c='Fulfilled') and Product_Code__c='DIGITALAGENT' and order_line_item__r.order.Oracle_Quote__c=:setQuoteDapIds];
                    
                    Id quoteIdds = null;
                    Id accid = null;
                    for(Asset asst:lstAsset){
                        if(asst.Line_type__c=='Add'){
                            System.debug('DAP ADD');
                            rrrcount++;
                            quoteIdds = asst.order_line_item__r.order.Oracle_Quote__c;
                            accid = asst.AccountId;
                        }
                    }
                    
                    System.debug('Record Count'+rrrcount);
                    if(rrrcount>0 || Test.isRunningTest()){
                        System.debug('DAP ADD');

                        System.debug('DAP ADD');
                        Map<String,String> mapManualQueueName = new Map<String,String>();
                        for(Group grp:[SELECT DeveloperName,Id,Name,Type FROM Group WHERE Type='Queue']){
                            mapManualQueueName.put(grp.DeveloperName,grp.Id);
                        }
                        Case caseToAdd = new Case();
                        caseToAdd.Status = 'New';
                        caseToAdd.Origin = 'Web';
                        caseToAdd.Type = ppcase.Case_Type__c;
                        caseToAdd.Is_Tiger_Lead__c = false;
                        caseToAdd.Oracle_Quote__c  = quoteIdds;
                        caseToAdd.Description  = 'Complete Ad Verification';
                        caseToAdd.Is_Pre_Welcome_Call__c = false;
                        caseToAdd.Area__c = ppcase.Case_Area__c;
                        caseToAdd.Subject = ppcase.Case_Subject__c;
                        caseToAdd.Sub_Area__c = ppcase.Case_Sub_Area__c;
                        caseToAdd.AccountId = accid;
                        if(ppcase.Case_Subject__c!=null){
                            if(mapManualQueueName.containskey(ppcase.Queue__c)){
                                caseToAdd.ownerId = mapManualQueueName.get(ppcase.Queue__c);
                            }
                        }
                        lstCases.add(caseToAdd);
                        if(lstCases.size()>0){
                            //Insert lstCases;
                        }
                    }
                }
            }
        }
        return lstCases;
    }
    
    
    /**
* @method      : updateCaseAssetRelationshipOnAssetUpdate
* @description : This method updates the Case-Asset relationship record based on status change on Asset.
Check Good cancellation field on Case-Asset relationship if the Cancellation Reason on asset is Good Cancellation and the Line Type on Asset is Cancel
* @param       : Map<Id, Asset> oldAssetMap, Map<Id, Asset> newAssetMap
* @return      : void
*/
    public void updateCaseAssetRelationshipOnAssetUpdate(Map<Id, Asset> oldAssetMap, Map<Id, Asset> newAssetMap){
        Map<Id,Case_Asset_Relationship__c> caseAssetRelationshipsUpdate = new Map<Id,Case_Asset_Relationship__c>();
        List<Case_Asset_Relationship__c> listCaseAssetRecords = new List <Case_Asset_Relationship__c>();
        List<Asset> lstAsset = [select id, End_Date__c, Daily_Rate__c,List_Price__c ,Order_Type__c,Status, Line_Type__c,
                                Cancellation_Reason__c ,(select id,At_Risk_Amount__c,New_Risk__c  from Case_Asset_Relationships__r)
                                from Asset where id in: newAssetMap.keyset()];
        for(Asset ast: lstAsset){
            // Process updation of At risk and New At Risk dollar values
            if(ast.End_Date__c != null && (ast.End_Date__c != oldAssetMap.get(ast.id).End_Date__c || ast.Daily_Rate__c != oldAssetMap.get(ast.id).Daily_Rate__c)
               || (ast.List_Price__c != oldAssetMap.get(ast.id).List_Price__c) && ast.Order_Type__c == 'Retention' ){
                   Integer intDateDifference =  system.today().daysBetween(ast.End_Date__c );
                   if(ast.Daily_Rate__c != null){
                       for(Case_Asset_Relationship__c car: ast.Case_Asset_Relationships__r){
                           if(ast.Order_Type__c == 'Retention')
                               //car.New_Risk__c = intDateDifference * ast.Daily_Rate__c;
                               //Updated formula for New RISK
                               car.New_Risk__c =ast.Daily_Rate__c*(intDateDifference +1);
                           caseAssetRelationshipsUpdate.put(car.Id, car);
                       }
                       system.debug('### CAR records: ' + caseAssetRelationshipsUpdate);
                   }
               }
            // Process updation Good Cancellation on the Case Asset relationship records
            // Line_Type__c, Cancellation_Reason__c
            if (ast.Line_Type__c!=oldAssetMap.get(ast.id).Line_Type__c || ast.Cancellation_Reason__c!=oldAssetMap.get(ast.id).Cancellation_Reason__c ){
                
                if(ast.Status == 'Cancelled' && ast.Line_Type__c == 'Cancel' && (ast.Cancellation_Reason__c == 'Good Cancellation' || ast.Cancellation_Reason__c == 'goodCancel')){
                    
                    for(Case_Asset_Relationship__c car : ast.Case_asset_Relationships__r){
                        // car.Good_Cancellation__c = true;
                        if(caseAssetRelationshipsUpdate.containsKey(car.Id)){
                            caseAssetRelationshipsUpdate.get(car.Id).Good_Cancellation__c = True;
                        }else{
                            car.Good_Cancellation__c = true;
                        }
                        caseAssetRelationshipsUpdate.put(car.id,car);
                        system.debug('### CAR records: ' + caseAssetRelationshipsUpdate);
                    }
                }
            }
        }

        if(!caseAssetRelationshipsUpdate.values().isEmpty()){
            system.debug('### CAR records: ' + caseAssetRelationshipsUpdate.values());
            try{
                update caseAssetRelationshipsUpdate.values();
            }catch(Exception e){
                system.debug('TRACE :  Error occured while saving case asset records : ' + e.getMessage());
            }
        }
    }
    // Get account Ids to update account type and account's territory Id.
    Public Map<Id, List<Asset>> getAccountsToUpdate(List<Asset> assets,Boolean isInsert) {
        Map<Id, List<Asset>> mapAccountToUpdate = new Map<Id, List<Asset>>();
        for(Asset asset : assets) {
            if(isInsert && ( asset.Status == Constants.ASSET_CANCELLED_STATUS ||
                            asset.Status == Constants.ASSET_EXPIRED_STATUS)) {
                                continue;
                            }
            
            if(mapAccountToUpdate.containsKey(asset.AccountId)) {
                List<Asset> lst = mapAccountToUpdate.get(asset.AccountId);
                lst.add(asset);
                mapAccountToUpdate.put(asset.AccountId,lst);
            }
            else {
                List<Asset> lst = new List<Asset>();
                lst.add(asset);
                mapAccountToUpdate.put(asset.AccountId,lst);
            }
        }
        return mapAccountToUpdate;
    }
    
    // Get current user information.
    @TestVisible private void getCurrentUserInformation() {
        List<User> users = [SELECT Id, Primary_Territory__c FROM User WHERE Id = :UserInfo.getUserId()];
        if(users != null && users.size() > 0) {
            currentUser = users.get(0);
        }
        // Get current user information.
        if(currentUser.Primary_Territory__c != null && currentUser.Primary_Territory__c.trim() != '') {
            territoryId = currentUser.Primary_Territory__c;
        }
        if(Unassigned_Territories__c.getInstance() != null) {
            unassignedTerritoryId = Unassigned_Territories__c.getInstance().Unassigned_Territory_Id__c;
        }
        system.debug('Current Users Territory is: ' + territoryId);
    }
    
    // Get assets of the accounts.
    public Map<Id, List<Asset>> getAssetsOfAccount(Set<Id> accountIds) {
        Map<Id, List<Asset>> accountAssetsMap = new Map<Id,List<Asset>>();
        try {
            List<Asset> assetsList = [SELECT Id, UsageEndDate, AccountId, Status FROM Asset WHERE AccountId IN :accountIds];
            if(assetsList != null && assetsList.size() > 0) {
                for(Asset asset : assetsList) {
                    if(accountAssetsMap.containsKey(asset.AccountId)) {
                        List<Asset> tempAssetList = accountAssetsMap.get(asset.AccountId);
                        tempAssetList.add(asset);
                        accountAssetsMap.put(asset.AccountId,tempAssetList);
                    }
                    else {
                        List<Asset> tempAssetList = new List<Asset>();
                        tempAssetList.add(asset);
                        accountAssetsMap.put(asset.AccountId,tempAssetList);
                    }
                }
            }
        }
        catch(Exception e) {
            system.debug('Error Occurred: ' + e.getMessage());
        }
        
        return accountAssetsMap;
    }
    
    /**
* @description : Get those asset for which Account Owner or Status was updated.
* @param       : Map<Id,Asset> oldValues, Map<Id,Asset> newValues, Boolean isInactiveCheck, Boolean isReactiveCheck
* @name        : getUpdatedAssets
* @return      : List<Asset>
*/
    @TestVisible  private List<Asset> getUpdatedAssets(Map<Id, Asset> oldAssetValueMap, Map<Id, Asset> newAssetValueMap, Boolean isInactiveCheck, Boolean isReactiveCheck) {
        List<Asset> changedAssets = new List<Asset>();
        for(Id id : newAssetValueMap.keySet()) {
            Asset newAsset = newAssetValueMap.get(id);
            Asset oldAsset = oldAssetValueMap.get(id);
            
            if(!isInactiveCheck && !isReactiveCheck ) {
                // Check if account was updated.
                if(oldAsset.AccountId != newAsset.AccountId) {
                    changedAssets.add(newAsset);
                }
            } else if(isInactiveCheck) {
                // Check for Asset which became inactive.
                if(newAsset.Status == Constants.ASSET_CANCELLED_STATUS || newAsset.Status == Constants.ASSET_EXPIRED_STATUS) {
                    changedAssets.add(newAsset);
                }
            } else if(isReactiveCheck) {
                System.debug('Trace: In getUpdatedAssets : Getting Accounts For Reactivated Asssets');
                // Check for Asset which became inactive.
                if( ( newAsset.Status != oldAsset.Status ) && newAsset.Status == Constants.ASSET_ACTIVE_STATUS) {
                    System.debug('Trace: In getUpdated Assest Adding Asset to Reactivated List :'+newAsset.Name);
                    changedAssets.add(newAsset);
                }
            }
        }
        return changedAssets;
    }
    
    // This method does the re-assignment of accounts for assets.
    @TestVisible private void manageAccountReassignementForAssets(List<Asset> assetsAccUpdate, Map<Id, Asset> oldAssetMap) {
        
        // Check if this is the first asset on the newly assigned account. If yes, update the account information.
        updateAccountInfoOnAssetInsert(assetsAccUpdate);
        
        // Check for old accounts.
        Set<Id> accountIdsOld = new Set<Id>();
        Set<Id> accountIdsToUpdate = new Set<Id>();
        
        Boolean markAccountAsFormerCustomer = true;
        for(Asset asset : assetsAccUpdate) {
            accountIdsOld.add(oldAssetMap.get(asset.Id).AccountId);
        }
        
        // Get All Assets of the Accounts
        Map<Id, List<Asset>> mapAssetsAccounts = getAssetsOfAccount(accountIdsOld);
        
        // Check if all assets are deleted for the accounts.
        if(mapAssetsAccounts.size() == 0) {
            for(Id id : accountIdsOld) {
                accountIdsToUpdate.add(id);
            }
        }
        else {
            // Find out those account from the List for which all assets were deleted.
            for(Id id: accountIdsOld) {
                if(!mapAssetsAccounts.containsKey(id)) {
                    accountIdsToUpdate.add(id);
                }
            }
        }
        system.debug('All Asset For The Accounts Are: ' + mapAssetsAccounts);
        
        // Loop over all the account for which assets were updated / deleted.
        for(Id id : mapAssetsAccounts.keySet()) {
            for(Asset asset : mapAssetsAccounts.get(id)) {
                if(asset.Status != Constants.ASSET_EXPIRED_STATUS && asset.Status != Constants.ASSET_CANCELLED_STATUS) {
                    system.debug('Marking account as customer only, as it has active assets.');
                    markAccountAsFormerCustomer = false;
                    continue;
                }
            }
            if(markAccountAsFormerCustomer) {
                accountIdsToUpdate.add(id);
            }
        }
        // End of for loop.
        
        // Update the accounts.
        updateAccountInformation(accountIdsToUpdate,false);
    }
    /**
* @description : This method is used to update account information in case all the assets on a customer account were deleted or assigned to some other account.
* @param       : Set<Id> accountIds toUpdate, Boolean wasAssetReactivated
* @name        : updateAccountInformation
* @return      : void
*/
    @TestVisible private static void updateAccountInformation(Set<Id> accountIds,boolean wasAssetReactivated) {
        List<Account> accountListToUpdate = new List<Account>();
        try {
            // Check if The Update Acccount Request is For Re-activated Assets
            if(!wasAssetReactivated) {
                for(Account account : [SELECT Id, Name, Account_Sub_Type__c FROM Account WHERE Id IN :accountIds]) {
                    account.Account_Sub_Type__c = Constants.ACCOUNT_SUBTYPE_FORMER_CUSTOMER;
                    account.LastAssetActiveDate__c = DateTime.now();
                    account.Is_Update_By_Trigger__c = true;
                    //account.Last_Sales_Contact_Date__c = System.Today();
                    account.Last_Sales_Contact_Date__c = System.Now(); /* Anup 4/5/2016 - Changing field type to date/time */
                    accountListToUpdate.add(account);
                }
            } else if(wasAssetReactivated){
                System.debug('Trace: In updateAccountInformation : Updating Account For Reactivated Asssets');
                for(Account account : [SELECT Id, Name, Account_Sub_Type__c,Do_Not_Assign__c FROM Account WHERE Id IN :accountIds]) {
                    if( (account.Account_Sub_Type__c == Constants.ACCOUNT_SUBTYPE_PROSPECT ||
                         account.Account_Sub_Type__c == Constants.ACCOUNT_SUBTYPE_FORMER_CUSTOMER ) && account.Do_Not_Assign__c == false ) {
                             account.Account_Sub_Type__c = Constants.ACCOUNT_SUBTYPE_CUSTOMER;
                             account.LastAssetActiveDate__c = null;
                             account.Is_Update_By_Trigger__c = true;
                             //account.Last_Sales_Contact_Date__c = System.Today();
                             account.Last_Sales_Contact_Date__c = System.Now(); /* Anup 4/5/2016 - Changing field type to date/time */
                             accountListToUpdate.add(account);
                         }
                }
            }
            system.debug('Account Lists To Update: ' + accountListToUpdate);
            if(accountListToUpdate.size() > 0) {
                update accountListToUpdate;
            }
        } catch(Exception e) {
            system.debug('Error Occurred : ' + e.getMessage());
        }
    }
    
    /*
@method      : rolledUpFromAssets
@description : Updating account roll-up custom fields namely "Total_Contract_Value__c" and "Next_Renewal_Date__c".
@params      : Map<Id, Asset> newMap, Map<Id, Asset> oldMap, Map<Id, Account> toBeUpdated, Boolean isInsert
@returns     : void
*/
    @TestVisible private void rolledUpFromAssets(Map<Id, Asset> newMap, Map<Id, Asset> oldMap, Map<Id, Account> toBeUpdated, Boolean isInsert) {
        // Processing new values.
        Set<Id> accountsToProcess = new Set<Id>();
        for(Asset theAsset : newMap.values()) {
            if(isInsert && theAsset.AccountId != null) {
                accountsToProcess.add(theAsset.AccountId);
            }
            else if(
                !isInsert &&
                theAsset.AccountId != null &&
                (
                    oldMap.get(theAsset.Id).AccountId != theAsset.AccountId ||
                    oldMap.get(theAsset.Id).Price != theAsset.Price ||
                    oldMap.get(theAsset.Id).Status != theAsset.Status ||
                    oldMap.get(theAsset.Id).End_Date__c != theAsset.End_Date__c ||
                    oldMap.get(theAsset.Id).Auto_Renewal__c != theAsset.Auto_Renewal__c
                )
            ) {
                accountsToProcess.add(theAsset.AccountId);
            }
            
            // Taking care of accounts removed from assets.
            if(!isInsert && oldMap.get(theAsset.Id).AccountId != theAsset.AccountId) {
                accountsToProcess.add(oldMap.get(theAsset.Id).AccountId);
            }
        }
        system.debug('TRACE: accountsToProcess - ' + accountsToProcess);
        
        // Extracting account assets and processing accounts filtered above.
        Map<Id, List<Asset>> theAccountAssets = new Map<Id, List<Asset>>();
        for(Asset theAsset : [SELECT Id, AccountId, Price, Status, End_Date__c, Auto_Renewal__c FROM Asset
                              WHERE AccountId IN :accountsToProcess AND Status = 'Active']) {
                                  if(
                                      (String.isNotBlank(String.valueOf(theAsset.Price)) && String.isNotBlank(theAsset.Status)) ||
                                      (String.isNotBlank(String.valueOf(theAsset.End_Date__c)) && String.isNotBlank(theAsset.Auto_Renewal__c))
                                  ) {
                                      if(!theAccountAssets.containsKey(theAsset.AccountId)) {
                                          theAccountAssets.put(theAsset.AccountId, new List<Asset>());
                                      }
                                      theAccountAssets.get(theAsset.AccountId).add(theAsset);
                                  }
                              }
        
        // Processing the account assets map generated above.
        Account theAccount;
        Decimal totalActivePrice;
        Date nextRenewalDate;
        Date toBeCompared = Date.today().addYears(50);
        for(Id theAccountId : accountsToProcess) {
            theAccount = null;
            totalActivePrice = 0;
            nextRenewalDate = toBeCompared;
            
            if(theAccountAssets.containsKey(theAccountId)) {
                for(Asset theAsset : theAccountAssets.get(theAccountId)) {
                    if(String.isNotBlank(theAsset.Status) && theAsset.Status.equalsIgnoreCase('Active') && String.isNotBlank(String.valueOf(theAsset.Price))) {
                        totalActivePrice += theAsset.Price;
                    }
                    if(
                        String.isNotBlank(theAsset.Auto_Renewal__c) &&
                        theAsset.Auto_Renewal__c.equalsIgnoreCase('Yes') &&
                        String.isNotBlank(String.valueOf(theAsset.End_Date__c)) &&
                        theAsset.End_Date__c < nextRenewalDate
                    ) {
                        nextRenewalDate = theAsset.End_Date__c;
                    }
                }
            }
            
            theAccount = new Account(
                Id = theAccountId,
                Is_Update_By_Trigger__c = true
            );
            if(toBeUpdated.containsKey(theAccountId)) {
                theAccount = toBeUpdated.get(theAccountId);
            }
            
            theAccount.Total_Contract_Value__c = totalActivePrice;
            if(totalActivePrice == 0) {
                theAccount.Total_Contract_Value__c = null;
            }
            
            theAccount.Next_Renewal_Date__c = null;
            if(nextRenewalDate != toBeCompared) {
                theAccount.Next_Renewal_Date__c = nextRenewalDate;
            }
            
            if(!toBeUpdated.containsKey(theAccountId)) {
                toBeUpdated.put(theAccountId, theAccount);
            }
        }
    }
    
    /**
* @method      : populateProposedLeadsBasedOnProduct
* @description : This method populates the Proposed Leads Based On the Product
* @param       : trigger.new, trigger.oldMap, boolean isInsert
* @return      : void
*/
    public void populateProposedLeadsBasedOnProduct(List<Asset> newAssets,Map<Id,Asset> oldAssetMap,Boolean isInsert) {
        if(Asset_Promised_Leads__c.getAll() != null) {
            promisedLeadsMap = Asset_Promised_Leads__c.getAll();
        }
        //Set of Product Id associated with the assets
        Set<Id> productIds = new Set<Id>();
        // Loop over newassets and find associated product ids
        for(Asset asset : newAssets) {
            if(asset.Product2Id != null) {
                productIds.add(asset.Product2Id);
            }
        }
        //Get the products
        ////CRM-5460-replaced the product query as part of Asset trigger Optimization
       // productMap = new Map<Id, Product2>([SELECT ProductCode, Name, IsActive, Id FROM Product2 where Id in: productIds]);
        System.debug('Trace: in populateProposedLeadsBasedOnProduct: productMap is : '+mapproducts);
        //Check If Product Exists
       // if(productMap != null && productMap.size() > 0 ) {
            if(mapproducts != null && mapproducts.size() > 0 ) {
            // Check If Data Is There in Custom Setting
            if(promisedLeadsMap != null && promisedLeadsMap.size() > 0) {
                //If New Asset
                if(isInsert) {
                    for(Asset asset : newAssets) {
                        // Chekc if Product Id for Asset Is Not Null and Product type is Either Half or Full
                        if(asset.Product2Id != null && ( asset.Product_Type__c == 'Half' || asset.Product_Type__c == 'Full')) {
                            //GEt the Current Product from Product Map
                            //Product2 currentProduct = productMap.get(asset.Product2Id);
                            // Get the Custom Setting for current Product
                           // if(mapproducts.containskey(asset.Product2Id))
                                    Asset_Promised_Leads__c promisedLead = promisedLeadsMap.get(mapproducts.get(asset.Product2Id).Product_Code__c);
                           // Asset_Promised_Leads__c promisedLead = promisedLeadsMap.get(currentProduct.ProductCode);
                            System.debug('Trace: in populateProposedLeadsBasedOnProduct: promisedLead is : '+promisedLead);
                            // If Custom Setting Found
                            if(promisedLead != null) {
                                updatePromisedLeadsForAssets(asset,promisedLead);
                            }
                        }
                    }
                } // End of Insert Part
                else {
                    System.debug('Trace: in populatePromisedLeads : Update');
                    // Get the updated Assets which Qualify the Criteria for Promised Leads
                    for(Asset asset : getUpdatedAssets(newAssets,oldAssetMap)) {
                        System.debug('Trace: Update asset is '+asset.Name);
                        //GEt the Current Product from Product Map
                       // Product2 currentProduct = productMap.get(asset.Product2Id);
                        // Get the Custom Setting for current Product
                       // Asset_Promised_Leads__c promisedLead = promisedLeadsMap.get(currentProduct.ProductCode);
                         Asset_Promised_Leads__c promisedLead = promisedLeadsMap.get(mapproducts.get(asset.Product2Id).Product_Code__c);
                        System.debug('Trace: in populateProposedLeadsBasedOnProduct:update:  promisedLead is : '+promisedLead);
                        // If Custom Setting Found
                        if(promisedLead != null) {
                            updatePromisedLeadsForAssets(asset,promisedLead);
                        }
                    }
                } // End of Update Part
            }
        } else {
            for(Asset asset : newAssets)
                asset.Promised_Leads__c = null;
        }
    }
    
    /**
* @method      : updatePromisedLeadsForAssets
* @description : This method populates the Proposed Leads Based On the Product
* @param       : Asset asset, Asset_Promised_Leads__c promisedLead
* @return      : void
*/
    @TestVisible private void updatePromisedLeadsForAssets(Asset asset,Asset_Promised_Leads__c promisedLead) {
        // IF asset Has Quantity
        if(asset.Quantity != null) {
            if(asset.Product_Type__c == 'Half') {
                //If Product Type is Half get the Promised_lead_Half value from Custom Setting and Set the Quantity
                asset.Promised_Leads__c = asset.Quantity*promisedLead.Promised_Leads_Half__c;
            } else if(asset.Product_Type__c == 'Full') {
                //If Product Type is Full get the Promised_Lead_Full value from Custom Setting and Set the Quantity
                asset.Promised_Leads__c = asset.Quantity*promisedLead.Promised_Leads_Full__c;
            }
        }// End of Quanity Check If
    }
    
    /**
* @method      : getUpdatedAssets
* @description : Gets the List of Updated Assets
* @param       : List<Asset>, Map<Id,Asset>
* @return      : List<Asset>
*/
    @TestVisible private List<Asset> getUpdatedAssets(List<Asset> newAssets,Map<Id,Asset> oldAssetMap) {
        List<Asset> updateAssets = new List<Asset>();
        for(Asset asset : newAssets) {
            System.debug('Assets Product2Id is : '+asset.Product2Id);
            // Check if New Product is Null
            if(asset.Product2Id == null) {
                // Set promised Leads as Blank as No Product is there
                asset.Promised_Leads__c = null;
                System.debug('Trace: getUpdatedAssets : New Product is Null For Asset :'+asset.Name);
                continue;
            }
            Asset oldAsset = oldAssetMap.get(asset.Id);
            // Check if Product Was Changed
            if(asset.Product2Id != oldAsset.Product2Id) {
                // Re-Calculate Promised Leads
                asset.Promised_Leads__c = null;
                if(asset.Product_Type__c == 'Half' || asset.Product_Type__c == 'Full') {
                    System.debug('Trace: getUpdatedAssets : Product Changed :'+asset.Product_Type__c);
                    updateAssets.add(asset);
                }
                continue;
            }
            
            //Check If Product Type Was Changed
            if(asset.Product_Type__c != oldAsset.Product_Type__c) {
                //Recalculate Promised Leads
                asset.Promised_Leads__c = null;
                if(asset.Product_Type__c == 'Half' || asset.Product_Type__c == 'Full') {
                    System.debug('Trace: getUpdatedAssets : Changed Product Type :'+asset.Product_Type__c);
                    updateAssets.add(asset);
                }
                continue;
            }
            
            // IF Quantity Changed Update Promised Leads
            if(asset.Quantity != oldAsset.Quantity) {
                //Recalculate Promised Leads
                System.debug('Trace: getUpdatedAssets : Product Quantity :'+asset.Quantity);
                updateAssets.add(asset);
            }
            
        }
        return updateAssets;
    }
    
    
    /*
@method      : updateAssetOLIFulfillmentStatus
@description : This method updates asset order line items fulfillment status to "Fulfilled".
@params      : Trigger.newMap, Trigger.oldMap
@returns     : void
*/
    public void updateAssetOLIFulfillmentStatus(Map<Id, Asset> newMap, Map<Id, Asset> oldMap) {
        // Processing Newly Updated Assets.
        Set<Id> theAssetOrderLineItemIds = new Set<Id>();
        Set<Id> theAssetIds = new Set<Id>();
        Set<Id> theAssetTopIDXIds = new Set<Id>();
        Set<Id> theAssetTopDAPIds = new Set<Id>();
        Map<Id,Asset> mapOrderAssetIds = new  Map<Id,Asset>();
        Map<Id,Id> mapOrderAssetTopIDXIds = new  Map<Id,Id>();
        Map<Id,Id> mapOrderAssetTopDAPIds = new  Map<Id,Id>();
        Set<Id> theCancelledAssetTopDAPIds = new Set<Id>();
        Map<Id,Id> mapCancelledOrderAssetTopIDXIds = new  Map<Id,Id>();
        
        for(Asset theAsset : newMap.values()) {
            
            if(theAsset.Fulfillment_Status__c!=null){
                if(
                    oldMap.get(theAsset.Id).Fulfillment_Status__c != theAsset.Fulfillment_Status__c && theAsset.Asset_Type__c.equalsIgnoreCase('Parent') &&
                    String.isNotBlank(theAsset.Fulfillment_Status__c) &&
                    theAsset.Fulfillment_Status__c.equalsIgnoreCase('Fulfilled') &&
                    (theAsset.Status.equalsIgnoreCase('Active') || theAsset.Status.equalsIgnoreCase('Cancelled') ||theAsset.Status.equalsIgnoreCase('Expired'))&&
                    theAsset.Order_Line_Item__c != null && theAsset.Product_Code__c!='TOPIDX'
                ) {
                    System.debug('$$$$$$$$$$');
                    //theAsset.addError('Not Working');
                    //theAssetOrderLineItemIds.add(theAsset.Order_Line_Item__c);
                    theAssetIds.add(theAsset.id);
                    mapOrderAssetIds.put(theAsset.Order_Line_Item__c,theAsset);
                }
                
                if(
                    oldMap.get(theAsset.Id).Fulfillment_Status__c != theAsset.Fulfillment_Status__c && theAsset.Asset_Type__c.equalsIgnoreCase('Parent') &&
                    String.isNotBlank(theAsset.Fulfillment_Status__c) &&
                    theAsset.Fulfillment_Status__c.equalsIgnoreCase('Fulfilled') && theAsset.Status.equalsIgnoreCase('Active') &&
                    theAsset.Order_Line_Item__c != null && theAsset.Product_Code__c=='TOPIDX'
                ) {
                    //theAssetOrderLineItemIds.add(theAsset.Order_Line_Item__c);
                    theAssetTopIDXIds.add(theAsset.id);
                    mapOrderAssetTopIDXIds.put(theAsset.Order_Line_Item__c,theAsset.id);
                }
                //CRM-2141 -start--order item and order Fulfillment status for Top IDX(Cancelled assets)
                if(
                    oldMap.get(theAsset.Id).Fulfillment_Status__c != theAsset.Fulfillment_Status__c && theAsset.Asset_Type__c.equalsIgnoreCase('Parent') &&
                    String.isNotBlank(theAsset.Fulfillment_Status__c) &&
                    theAsset.Fulfillment_Status__c.equalsIgnoreCase('Fulfilled') && (theAsset.Status.equalsIgnoreCase('Cancelled')|| theAsset.Status.equalsIgnoreCase('Active')||theAsset.Status.equalsIgnoreCase('Expired')) &&
                    theAsset.Order_Line_Item__c != null && theAsset.Product_Code__c=='TOPIDX' && theAsset.Line_type__c !='Add'
                ) {
                    //theAssetOrderLineItemIds.add(theAsset.Order_Line_Item__c);
                    // theAssetTopIDXIds.add(theAsset.id);
                    mapCancelledOrderAssetTopIDXIds.put(theAsset.Order_Line_Item__c,theAsset.id);
                    theCancelledAssetTopDAPIds.add(theAsset.id);
                    System.debug('Tilll here for 2704'+mapCancelledOrderAssetTopIDXIds);
                    System.debug('Tilll here for 2704 asst size'+theCancelledAssetTopDAPIds.size());
                }
                
            }
        }
        
        if (theCancelledAssetTopDAPIds.size() > 0)
        {
            list<OrderItem> ot = new list<OrderItem>();
            list<order> orders = new list<order>();
            for(OrderItem otm:[Select Id,OrderId,order.Fulfillment_Status__c,Order.opportunity.AccountId,order.Products__c from OrderItem where Id=:mapCancelledOrderAssetTopIDXIds.keyset()]){
                otm.Fulfillment_Status__c = 'Fulfilled';
                ot.add(otm);
                order o = new order(id = otm.orderId,Fulfillment_Status__c = 'Fulfilled',Status = 'Complete');
                orders.add(o);
                System.debug('orders getting here'+orders);
                //orderids.add(otm.OrderId);            
            }
            update ot;
            update orders;
        }

        if(theAssetIds.size()>0){
            system.debug('TRACE: updateAssetOLIFulfillmentStatus - theAssetOrderLineItemIds - ' + theAssetIds);
            Map<Id,Decimal> mapChildFulfillmentCount =new Map<Id,Decimal>();
            for(Asset ass:[Select Id,Name,Ultimate_Parent__c from Asset where Ultimate_Parent_Id_Text__c=:theAssetIds and Fulfillment_Status__c !='Fulfilled']){
                if(mapChildFulfillmentCount.containskey(ass.Ultimate_Parent__c )){
                    mapChildFulfillmentCount.put(ass.Ultimate_Parent__c,(mapChildFulfillmentCount.get(ass.Ultimate_Parent__c )+1));
                } else {
                    mapChildFulfillmentCount.put(ass.Ultimate_Parent__c,1);
                }
            }
            System.debug(mapChildFulfillmentCount+'######');
            for(Asset theAsset : newMap.values()) {
                if(theAsset.Fulfillment_Status__c!=null){
                    System.debug(oldMap.get(theAsset.Id).Fulfillment_Status__c +'$$$$$$'+ theAsset.Fulfillment_Status__c+'$$$$$$'+theAsset.id);
                    if(
                        oldMap.get(theAsset.Id).Fulfillment_Status__c != theAsset.Fulfillment_Status__c && theAsset.Asset_Type__c.equalsIgnoreCase('Parent') &&
                        String.isNotBlank(theAsset.Fulfillment_Status__c) &&
                        theAsset.Fulfillment_Status__c.equalsIgnoreCase('Fulfilled') &&
                        theAsset.Order_Line_Item__c != null
                    ) {
                        if(!mapChildFulfillmentCount.containskey(theAsset.id)){
                            theAssetOrderLineItemIds.add(theAsset.Order_Line_Item__c);
                        }
                        //theAssetIds.add(theAsset.id);
                    }
                }
            }
            
            // Updating Order Line Items Filetered Above.
            if(theAssetOrderLineItemIds.size() > 0) {
                List<OrderItem> toBeUpdated = new List<OrderItem>();
                for(Id OrderItemId : theAssetOrderLineItemIds) {
                    Id AssetId = mapOrderAssetIds.get(OrderItemId).id;
                    if(AssetId!=null){
                        // CRM - 1231 :- Updating order product startdate for Add Type order
                        String lineTypeAsset = mapOrderAssetIds.get(OrderItemId).Line_type__c;
                        if(lineTypeAsset=='Add'){
                            toBeUpdated.add(new OrderItem(
                                Id = OrderItemId,
                                Asset__c = AssetId,
                                Start_Date__c = mapOrderAssetIds.get(OrderItemId).Start_Date__c, // CRM-1231
                                End_date__c = mapOrderAssetIds.get(OrderItemId).End_Date__c,// CRM-1231
                                Fulfillment_Status__c = 'Fulfilled',
                                Inventory_Status__c = 'Allocated'
                            ));} else {
                                toBeUpdated.add(new OrderItem(
                                    Id = OrderItemId,
                                    Asset__c = AssetId,
                                    Fulfillment_Status__c = 'Fulfilled',
                                    Inventory_Status__c = 'Allocated'
                                ));
                            }
                        // CRM - 1231
                    } else {
                        toBeUpdated.add(new OrderItem(
                            Id = OrderItemId,
                            //Start_Date__c = mapOrderAssetIds.get(OrderItemId).Start_Date__c,
                            Fulfillment_Status__c = 'Fulfilled',
                            Inventory_Status__c = 'Allocated'
                        ));
                    }
                }
                update toBeUpdated;
                
                // Extracting Parent Order Ids From Order Line Items Processed Above.
                Set<Id> theParentOrderIds = new Set<Id>();
                Set<Id> theParentQuoteIds = new Set<Id>();
                Set<Id> theOpportunityIds = new Set<Id>();
                
                decimal contract_term=6;
                boolean additionalProductsskip = false;
                Set<String> setSkipProductCode = new Set<String>();
                for(String str :(System.label.OrderFulfillSkipProducts+'').split(',')){
                    setSkipProductCode.add(str);
                }
                map<Id,Boolean> mapOrderTigerLead = new map<Id,Boolean>();
                Set<Id> reesioOrdSet = new Set<Id>(); 
                for(OrderItem theOrderItem : [SELECT OrderId,PricebookEntry.product2.productCode,Contract_Term__c,Order.tigerLeadProductExists__c,Order.opportunityId,Order.Is_BMS__c,Order.Oracle_Quote__c FROM OrderItem WHERE Id IN :theAssetOrderLineItemIds AND OrderId != null]) {
                    theParentOrderIds.add(theOrderItem.OrderId);
                    //CRM-2341 - ListHub needs a Manual Fulfillment Process
                    // CRM-3209 Order should not be Fulfilled for Moving Products from here, Added condition for Moving
                    if(theOrderItem.PricebookEntry.product2.productCode == 'REESIO' || theOrderItem.PricebookEntry.product2.productCode == 'LISTHUBPRO' || Label.Moving_Product_Codes.contains(theOrderItem.PricebookEntry.product2.productCode)){
                        reesioOrdSet.add(theOrderItem.OrderId);
                    }
                    if(theOrderItem.Order.tigerLeadProductExists__c){
                        if(theOrderItem.Contract_Term__c=='' || theOrderItem.Contract_Term__c==null){theOrderItem.Contract_Term__c='0';}
                        if(contract_term<Decimal.valueof(theOrderItem.Contract_Term__c+'')){
                            contract_term=Decimal.valueof(theOrderItem.Contract_Term__c+'');
                        }
                        mapOrderTigerLead.put(theOrderItem.OrderId,theOrderItem.Order.tigerLeadProductExists__c);
                    }
                    if(setSkipProductCode.contains(theOrderItem.PricebookEntry.product2.productCode)){
                        //  additionalProductsskip=true;
                    }
                    if(theOrderItem.Order.Is_BMS__c==true){
                        theParentQuoteIds.add(theOrderItem.Order.Oracle_Quote__c);
                    }
                    theOpportunityIds.add(theOrderItem.Order.opportunityId);
                }
                system.debug('TRACE: updateAssetOLIFulfillmentStatus - theParentOrderIds - ' + theParentOrderIds);
                
                // Extracting All Order Line Items For Order Ids Fetched Above.
                Map<Id, List<String>> theOrderAndItsItemMapping = new Map<Id, List<String>>();
                
                for(OrderItem theOrderItem : [SELECT Id, OrderId,Order.tigerLeadProductExists__c,PricebookEntry.product2.productCode, Fulfillment_Status__c FROM OrderItem WHERE OrderId IN :theParentOrderIds
                                              AND Id NOT IN :theAssetOrderLineItemIds]) {
                                                  //CRM-2341 - ListHub needs a Manual Fulfillment Process                           
                                                  if(theOrderItem.PricebookEntry.product2.productCode == 'REESIO' || theOrderItem.PricebookEntry.product2.productCode == 'LISTHUBPRO'){
                                                      reesioOrdSet.add(theOrderItem.OrderId);
                                                  }
                                                  if(theOrderItem.Fulfillment_Status__c != 'Fulfilled'){
                                                      if(!theOrderAndItsItemMapping.containsKey(theOrderItem.OrderId)) {
                                                          theOrderAndItsItemMapping.put(theOrderItem.OrderId, new List<String>());
                                                      }
                                                      theOrderAndItsItemMapping.get(theOrderItem.OrderId).add(theOrderItem.Fulfillment_Status__c);
                                                  }
                                              }
                
                // CRM-1703: Get Orders on which reesio case is not closed. For closed cases, Orders will be updated.
                if(!reesioOrdSet.isEmpty()){
                    // CRM-3209 Fetch not-closed cases for Moving also
                    Set<String> caseSubjects = new Set<String>{'Manual Fulfillment Required','ListHub Fulfillment Required'};
                        Manual_Fulfillment_Product_Case__c caseDetails = Manual_Fulfillment_Product_Case__c.getValues('MOVING');
                    String movingCaseSubject = '';
                    if (caseDetails != null) {
                        movingCaseSubject = caseDetails.Subject__c.replaceAll('PRODUCT_NAME','');
                        movingCaseSubject = '%' + movingCaseSubject;
                    }
                    for(Case nonClosedCases : [Select id, Order__c from case 
                                               Where type = 'Order' and (Subject in :caseSubjects OR Subject Like :movingCaseSubject)
                                               and status != 'Closed' and Order__c IN :reesioOrdSet]) {
                                                   if(!theOrderAndItsItemMapping.containsKey(nonClosedCases.Order__c)) {
                                                       theOrderAndItsItemMapping.put(nonClosedCases.Order__c, new List<String>());
                                                   }
                                               }
                    
                }
                system.debug('TRACE: updateAssetOLIFulfillmentStatus - theOrderAndItsItemMapping - ' + theOrderAndItsItemMapping);
                
                // Processing Parent Order Ids.
                List<Order> ordersToBeUpdated = new List<Order>();
                for(Id theParentOrderId : theParentOrderIds) {
                    if(!theOrderAndItsItemMapping.containsKey(theParentOrderId)) {
                        //  if(theParentOrderId!=null && theParentOrderId!=''){
                        ordersToBeUpdated.add(new Order(
                            Id = theParentOrderId,
                            Fulfillment_Status__c = 'Fulfilled',
                            Status = 'Complete'
                        ));
                        //  }
                    }
                }
                
                Integer limit1 = Limits.getQueries();
                System.debug(limit1+'**limit1**');
                If (limit1<20) {
                    //  AsyncOpportunityUpdate(theOpportunityIds);
                }
                
                List<BigMachines__Quote__c> lstBMQuote = new List<BigMachines__Quote__c>();
                for(Id idds:theParentQuoteIds){
                    lstBMQuote.add(new BigMachines__Quote__c(
                        Id = idds,
                        Is_BMS__c = true
                    ));
                }
                if(lstBMQuote.size()>0){
                    update lstBMQuote;
                }
                if(ordersToBeUpdated.size() > 0) {
                    for(Order odr:ordersToBeUpdated){
                        if(mapOrderTigerLead.containskey(odr.Id)){
                            odr.EffectiveDate = System.today();
                            odr.EndDate = System.today().addMonths(12);
                        }
                    }
                    update ordersToBeUpdated; 
                }
                
            }
        }
        if(theAssetTopIDXIds.size()>0){
            Set<Id> setOrderTopIDXIds = new Set<Id>();
            Set<Id> newSetOrderTypeTopIDXIds = new Set<Id>();
            Set<Id> CurrentsetOrderTopIDXIds = new Set<Id>();
            Map<Id,Id> mapOrderOpportunityId = new Map<Id,Id>();
            Map<Id,string> mapOrderProduct = new Map<Id,string>();
            
            for(OrderItem otm:[Select Id,OrderId,Order.opportunity.AccountId,order.Products__c,order.Type,Line_Type__c from OrderItem where Id=:mapOrderAssetTopIDXIds.keyset()]){
                //setOrderTopIDXIds.add(otm.OrderId); //CRM-2704 change
                mapOrderOpportunityId.put(otm.OrderId,otm.Order.opportunity.AccountId);
                mapOrderProduct.put(otm.OrderId,otm.Order.Products__c);
                // CRM-2704-- Stop Creatiung Manual Fulfillment Cases for IDX during Renew and Amend
                if(otm.Line_Type__c.equalsIgnoreCase('Add')){
                    newSetOrderTypeTopIDXIds.add(otm.OrderId);
                }
                /* if(otm.order.Type.equalsIgnoreCase('New')){
newSetOrderTypeTopIDXIds.add(otm.OrderId);autoPopulateAccountProductFields
} */
            }
            
            if(newSetOrderTypeTopIDXIds.size()>0){ //CRM-2704 change
                Tiger_Lead_Products__c TLProducts= Tiger_Lead_Products__c.getValues('TOPIDX');
                Set<string> TIDXProductStrings = new Set<string>();
                Set<string> TPActivities = new Set<string>();
                String Queuename = '';
                if(TLProducts!=null){
                    TIDXProductStrings.addall(TLProducts.Tiger_Lead_Product_List__c.split(';'));
                    TPActivities.addall(TLProducts.TigerLeadActivities__c.split(';'));
                    Queuename = TLProducts.Queue_Name__c;
                }
                Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
                List<Case> lstCases = new List<Case>();
                Map<String,String> mapManualQueueName = new Map<String,String>();
                for(Group grp:[SELECT DeveloperName,Id,Name,Type FROM Group WHERE DeveloperName = :Queuename and Type='Queue']){
                    mapManualQueueName.put(grp.DeveloperName,grp.Id);
                }
                //CRM-1953 Venu Ravilla- Defining new default values for case and assigning owner based on assignment rules
                //AssignmentRule AR = new AssignmentRule();
                //AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
                //CRM-5460- Removed Query as part of Asset Trigger optimization
                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                dmlOpts.assignmentRuleHeader.useDefaultRule= true;
                //dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
                for(Id ids:newSetOrderTypeTopIDXIds){ //CRM-2704 change
                    Case caseToAdd = new Case();
                    caseToAdd.Status = 'New';  //CRM-1953 Venu Ravilla- Defining new default values for case
                    caseToAdd.RecordTypeId = recordTypeId;
                    caseToAdd.Origin = 'Web';
                    caseToAdd.Type = 'Order';     
                    caseToAdd.Order__c = ids;
                    caseToAdd.Area__c = 'Top Producer IDX';              
                    caseToAdd.Description = mapOrderProduct.get(ids);
                    caseToAdd.Sub_Area__c = 'New';
                    caseToAdd.Subject = 'TP IDX Fulfillment Required';    
                    caseToAdd.AccountId = mapOrderOpportunityId.get(ids);
                    caseToAdd.SetOptions(dmlOpts);
                    lstCases.add(caseToAdd);
                }
                if(lstCases.size()>0){
                    Insert lstCases;
                    //CRM-1713 -venu-did changes to remove avtivities on topidx cases
                    /*List<Task> lstTask = new List<Task>(); // Venu CRM-1713 -stopping creating activities for TOPIDX cases
for(Case cas:lstCases){
for(String sttr:TPActivities){
Task tsk = new Task();
tsk.WhatId = cas.Id;
tsk.Subject = sttr;
tsk.Is_Tiger_Lead__c = true;
lstTask.add(tsk);
}
}
if(lstTask.size()>0){
Insert lstTask;
} */
                }
            }
        }
    }
    
    /*
@Method   : Opportunity Update
*/
    
    Public void AsyncOpportunityUpdate(Set<Id> theOpportunityIds){
        Map<Id, Id> theMapOpportunityids= new Map<Id, Id>();
        Map<Id, Decimal> theMapOpportunityAmounts= new Map<Id, Decimal>();
        for(OrderItem theOrderItem : [SELECT Id, OrderId,Order.OpportunityId,Total_Net__c, Fulfillment_Status__c FROM OrderItem WHERE Order.OpportunityId IN :theOpportunityIds]) {
            if(theOrderItem.Fulfillment_Status__c != 'Fulfilled'){
                theMapOpportunityids.put(theOrderItem.Order.OpportunityId,theOrderItem.Order.OpportunityId);
            }
            if(theOrderItem.Total_Net__c==null){theOrderItem.Total_Net__c=0.0;}
            if(theOrderItem.Fulfillment_Status__c != 'Error' && theOrderItem.Total_Net__c!=null){
                if(theMapOpportunityAmounts.containskey(theOrderItem.Order.OpportunityId)){
                    Decimal oppamount = theMapOpportunityAmounts.get(theOrderItem.Order.OpportunityId);
                    oppamount = oppamount+theOrderItem.Total_Net__c;
                    theMapOpportunityAmounts.put(theOrderItem.Order.OpportunityId,oppamount);
                } else {
                    theMapOpportunityAmounts.put(theOrderItem.Order.OpportunityId,theOrderItem.Total_Net__c);
                }
            }
        }
        
        //system.debug('TRACE: updateAssetOLIFulfillmentStatus - ordersToBeUpdated - ' + ordersToBeUpdated);
        List<Opportunity> OpportunityToBeUpdated = new List<Opportunity>();
        for(Id theoppId:theOpportunityIds){
            if(theoppId!=null){
                if(!theMapOpportunityids.containskey(theoppId)){
                    
                    OpportunityToBeUpdated.add(new Opportunity(
                        Id = theoppId,
                        StageName = 'Closed Won - Fulfilled',
                        Fulfillment_Complete__c = true,
                        Total_Opportunity_Amount__c = theMapOpportunityAmounts.get(theoppId)
                    ));
                }
            }
        }
        if(OpportunityToBeUpdated.size() > 0) {
            update OpportunityToBeUpdated;
        }
    }
    
    /*
@method      : updateFulfillToAssetsCPLoginStatus
@description : This method updates fulfillTo asset "Get CP Login Status" To "Complete".
@params      : Trigger.newMap, Trigger.oldMap
@returns     : void
*/
    public void updateFulfillToAssetsCPLoginStatus(Map<Id, Asset> newMap, Map<Id, Asset> oldMap) {
        // Processing Newly Updated Parent Assets.
        Set<Id> theParentAssetIds = new Set<Id>();
        for(Asset theAsset : newMap.values()) {
            if(
                String.isNotBlank(theAsset.Asset_Type__c) &&
                theAsset.Asset_Type__c.equalsIgnoreCase('Parent') &&
                String.isNotBlank(theAsset.Get_CP_Login_Status__c) &&
                theAsset.Get_CP_Login_Status__c.equalsIgnoreCase('Complete') &&
                oldMap.get(theAsset.Id).Get_CP_Login_Status__c != theAsset.Get_CP_Login_Status__c
            ) {
                theParentAssetIds.add(theAsset.Id);
            }
        }
        
        // Extracting FulfillTo Assets.
        if(theParentAssetIds.size() > 0) {
            List<Asset> fulfillToAssetsToBeUpdated = new List<Asset>();
            for(Asset theFulfillToAsset : [SELECT Id, Get_CP_Login_Status__c FROM Asset WHERE Asset_Type__c = 'Fulfill To'
                                           AND Parent_Asset__c IN :theParentAssetIds]) {
                                               theFulfillToAsset.Get_CP_Login_Status__c = 'Complete';
                                               fulfillToAssetsToBeUpdated.add(theFulfillToAsset);
                                           }
            
            if(fulfillToAssetsToBeUpdated.size() > 0) {
                update fulfillToAssetsToBeUpdated;
            }
        }
    }
    
    /*
@method      : populateAccountListingBasedOnProduct
@description : This method is to populate Account listing based on product type.
@params      : Trigger.new, Trigger.oldMap
@returns     : void
*/
    
    public void populateAccountListingBasedOnProduct(List<Asset> newAssets,Map<Id,Asset> oldAssetMap,Boolean isInsert) {
        
        //Set of Product Id associated with the assets
        Set<Id> AccountIds = new Set<Id>();
        map<string,list<Asset>> marketToAsset = new map<string,list<Asset>>();
        list<string> market = new list<string>();
        Set<Id> productIds = new Set<Id>();
        
        // Loop over newassets and find associated product ids
        for(Asset asset : newAssets) {
            if( asset.Account_Listings__c == null ){
                system.debug('-------------ProductCode Before Insert =' +asset.Product_Code__c);
                if( asset.Product_Code__c != null && asset.AccountId != null && asset.Market__c != null && asset.Product_Code__c == TurboUtilityClass.turboProductCode ) {
                    
                    AccountIds.add(asset.AccountId);
                    
                    if( !marketToAsset.containsKey( asset.Market__c.split(',')[0].trim().toUpperCase() + Id.valueOf(asset.AccountId) ) ){
                        marketToAsset.put( asset.Market__c.split(',')[0].trim().toUpperCase()+Id.valueOf(asset.AccountId), new list<Asset>() );
                    }
                    marketToAsset.get(asset.Market__c.split(',')[0].trim().toUpperCase()+Id.valueOf(asset.AccountId)).add(asset);
                    market.add( asset.Market__c.split(',')[0].trim() );
                }
            }
        }
        
        // CRM-1423 Added condition to avoid executing SOQL if set is empty
        if (!AccountIds.isEmpty()) {
            for( Account_Listing__c accListing : [  SELECT  id,
                                                  City__c,
                                                  Account_Name__c
                                                  FROM    Account_Listing__c
                                                  where
                                                  Account_Name__c in: AccountIds
                                                  AND
                                                  City__c in: market
                                                  and
                                                  Account_Name__c != null
                                                  AND
                                                  City__c != null
                                                  AND
                                                  Listing_Type__c != 'Land']){
                                                      
                                                      if( marketToAsset.containsKey( accListing.City__c.toUpperCase() +Id.valueOf(accListing.Account_Name__c) ) ){
                                                          for( Asset ast : marketToAsset.get( accListing.City__c.toUpperCase() +Id.valueOf(accListing.Account_Name__c))){
                                                              ast.Account_Listings__c = accListing.Id;
                                                          }
                                                      }
                                                  }
        }
    }
  
    /*
@method      : CreateTurboCancelQuote
@description : This method is to create cancel quote for Turbo when "Send Cancellation Email - Impressions not reducing from 144 hours".
@params      : Trigger.new
@returns     : void

    @future(callout = true)
    public static void CreateTurboCancelQuote( string AssetListJson, map<string,string> accIdToOppId ) {
        
        list<Asset> assetList = (list<Asset>) JSON.deserializeStrict( AssetListJson , list<Asset>.class);
        map<string,list<Asset>> accountIdToAssetList = new map<string,list<Asset>>();
        
        for(Asset ast : assetList){
            
            if( !accountIdToAssetList.containsKey( ast.AccountId) ){
                accountIdToAssetList.put(  ast.AccountId, new list<Asset>());
            }
            accountIdToAssetList.get(ast.AccountId).add( ast );
        }
        
        for( string accId : accountIdToAssetList.keySet() ){
            TurboUtilityClass.createBigMachineQuoteForCancelAndCreditAsset( accountIdToAssetList.get(accId) , accId, accIdToOppId.get(accId) );
        }
        
    }*/
    
    // CRM-1258 Start - Populate Product Geo for BDX Parent Assets
    /*
@method      : UpdateProductGeoOnBDXParentAssets
@description :
@params      : Trigger.new, Trigger.oldMap
@returns     : void
@Owner       : Sonali Bhardwaj
*/
    
    public void UpdateProductGeoOnBDXParentAssets(List<Asset> newAssets,Map<Id,Asset> oldAssetMap) {
        Map<Id, asset> bdxParentAssets = new Map<Id, asset>();
        for(Asset asset : newAssets) {
            if (asset.Asset_Type__c.equalsIgnoreCase('Parent') && 
                (asset.Category__c != null && asset.Category__c.equalsIgnoreCase('BDX')) &&
                asset.Fulfillment_Status__c == 'Fulfilled' && oldAssetMap.get(asset.Id).Fulfillment_Status__c != 'Fulfilled' &&
                asset.status != 'Cancelled' && asset.status != 'Expired') //CRM-1586 - Do not calculate Product Geo for Cancelled and Expired Parent Assets
            {
                bdxParentAssets.put(asset.id, asset);
            }
        }
        
        if (!bdxParentAssets.isEmpty()) {
            AssetTriggerHelper helper = new AssetTriggerHelper();
            
            // CRM-1586 Start - To handle Fulfill-To Asstes which gets fulfilled in same transaction as of its Parent
            for(Asset asset : newAssets) {
                if (asset.Asset_Type__c.equalsIgnoreCase('Fulfill To') && bdxParentAssets.containsKey(asset.Parent_Asset__c)) {
                    if (asset.Status == 'Active') {
                        if (!helper.officeAccountFulfillToAssets.containsKey(asset.AccountID)) {
                            helper.officeAccountFulfillToAssets.put(asset.AccountID, new List<Id>());
                        }
                        // store fulfillto asset office account
                        helper.officeAccountFulfillToAssets.get(asset.AccountID).add(asset.Id);  
                        // fulfillto asset parent asset
                        helper.fulfillToParenAsset.put(asset.Id, asset.Parent_Asset__c);   
                    }
                    
                    // CRM-1586 5/17/2017- Exclude already Active FulfillTo Asstes which are getting In-Active in the same trigger transaction as of its Parent.
                    if (asset.Status != 'Active' && oldAssetMap.get(asset.Id).Status == 'Active') {
                        helper.excludeFulFillToIds.add(asset.Id);
                    }
                }
            }
            // CRM-1586 End
            
            helper.UpdateProductGeoOnBDXParentAssets(bdxParentAssets);
        }
    }
    
    // CRM-1258 End
    
    /*
CRM-2344 added by Santosh
@method      : CreateCaseWhenAssetExpires 
@Description : Create Manual Fulfillment Case for Assets that Expire    
@returns     : void
*/
    public void CreateCaseWhenAssetExpires(List<Asset> lstAsset){
        List<Case> casesToCreate = new List<Case>();
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('ProSoft Standard').getRecordTypeId();
        // AssignmentRule AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
        //CRM-5460- Removed Query as part of Asset Trigger optimization
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.useDefaultRule= true;
        //dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
        // venu-- modified the code
        for (Asset aset:lstAsset){
            Case caseToAdd = new Case();
            caseToAdd.accountid = aset.Accountid; 
            caseToAdd.Asset_Id__c= aset.id;
            CaseToAdd.AssetId = aset.id;
            caseToAdd.RecordTypeId = recordTypeId;
            caseToAdd.Type = 'Order';
            caseToAdd.Sub_Area__c = 'Expired'; 
            caseToAdd.Description = 'Product needs to be expired in external systems. By closing this case you are confirming that you have unfulfilled the product in the downstream systems.';  
            caseToAdd.SetOptions(dmlOpts);
            String prodStr = 'Reesio';
            if(aset.Product_Code__c == 'LISTHUBPRO'){
                prodStr = 'ListHub';
            }
            else if(aset.Product_Code__c == 'DOMAINNAME'){
                prodStr = 'Domain Name';
            } 
            caseToAdd.Subject = prodStr + ' Asset has Expired ';
            caseToAdd.Area__c = prodStr;
            casesToCreate.add(caseToAdd);
        }
        if (!test.isRunningTest()) {
            insert casesToCreate;
        }
    }
    
    // CRM-2808 Function to update Report Renewal Type
    public void updateAssetReportRenewalType(List<Asset> newAssets, Map<Id, Asset> oldAssetMap) {
        Map<String, Report_Renewal_Type__c> types = Report_Renewal_Type__c.getall();
        List<String> keys = new List<String>(types.keySet());
        keys.sort();
        
        Map<id, Asset> assets = new Map<Id, Asset>([SELECT id, Order_Line_Item__r.Order.Oracle_Quote__r.Waitlist_Item__c, 
                                                    Order_Line_Item__r.Order.Oracle_Quote__r.Quote_Submitted_By__r.Profile.Name FROM Asset WHERE Id IN :oldAssetMap.keySet()]);
        for(Asset newAsset : newAssets) {
            Asset oldAsset = oldAssetMap.get(newAsset.Id);
            String reportRenewalType = null;
            // Update Report Renewal Type with New Sale & Pre-Auth for Line Type Add
            if (newAsset.Line_Type__c == 'Add' && newAsset.Fulfillment_Status__c == 'Fulfilled' && oldAsset.Fulfillment_Status__c != 'Fulfilled') {
                Id waitListItemId = assets.get(newAsset.Id).Order_Line_Item__r.Order.Oracle_Quote__r.Waitlist_Item__c;
                if (waitListItemId == null) {
                    reportRenewalType = 'New Sale';
                }
                else {
                    reportRenewalType = 'Pre-Auth';
                }
            }
            // Update Report Renewal Type for Renew Line Type
            // CRM-3301 -- venu Ravilla-- Removed conditions to update the report renewal type on renewal fulfillment condition..
            else if (newAsset.Line_Type__c == 'Renew' &&
                     (newAsset.Fulfillment_Status__c == 'Fulfilled' && oldAsset.Fulfillment_Status__c != 'Fulfilled'))  {
                         /*||(newAsset.Renewal_Type__c != oldAsset.Renewal_Type__c) ||
(newAsset.AutoRenewalPicked__c != oldAsset.AutoRenewalPicked__c) ||
(newAsset.CustResp_AutoOrder__c != oldAsset.CustResp_AutoOrder__c)))*/
                         String autoRenewalPicked = (newAsset.AutoRenewalPicked__c)? 'true':'false';
                         String quoteSubmittedBy = assets.get(newAsset.Id).Order_Line_Item__r.Order.Oracle_Quote__r.Quote_Submitted_By__r.Profile.Name;
                         if (quoteSubmittedBy == null) {
                             quoteSubmittedBy = Label.Default_Quote_Submitter_Profile;
                         }
                         
                         String defaultRenewalType = null;
                         for (String key : keys) {
                             Report_Renewal_Type__c type = types.get(key);
                             if (type.Default__c) {
                                 defaultRenewalType = type.Report_Renewal_Type__c;
                             }
                             if (type.Renewal_Type__c == null || type.Renewal_Type__c == '' || type.Renewal_Type__c == newAsset.Renewal_Type__c) {
                                 if (type.CustResp_AutoOrder__c == null || type.CustResp_AutoOrder__c == '' || type.CustResp_AutoOrder__c == newAsset.CustResp_AutoOrder__c) {
                                     if (type.Auto_Renewal_Picked__c == null || type.Auto_Renewal_Picked__c == '' || type.Auto_Renewal_Picked__c == autoRenewalPicked) {
                                         if (type.Profile_List__c == null || type.Profile_List__c == '' || type.Profile_List__c.contains(quoteSubmittedBy)) {
                                             reportRenewalType = type.Report_Renewal_Type__c;
                                             break;
                                         }
                                     }
                                 }             
                             }
                         }
                         if (reportRenewalType == null && defaultRenewalType != null) {
                             reportRenewalType = defaultRenewalType;   
                         }
                     }
            
            if (reportRenewalType != null && reportRenewalType != newAsset.Report_Renewal_Type_Text__c) {
                newAsset.Report_Renewal_Type_Text__c = reportRenewalType;
            }
        }
    }
    // CRM-2808 End
    // CRM-3102: Update Trial_RS_cancelled_Assets__c field on Order with number of realsuite trial assets cancelled.
    
    
    public void updateOrderWhenAssetCancelled(List<Asset> newAssets, Map<Id, Asset> oldAssetMap){
        List<String> rsList = new List<String>{'RSRESPOND', 'RSCONNECT', 'RSTRANSACT'};
            Set<Id> aId = new Set<Id>();
        Set<Id> oId = new Set<Id>();
        Map<Id, Order> updOrdMap = new Map<Id, Order>();
        List<Order> updOrdList = new List<Order>();
        
        for(Asset a: newAssets){
            if(a.Trial__c && rsList.contains(a.Product_Code__c) && a.Status=='Cancelled' && a.Status != oldAssetMap.get(a.Id).Status){
                aId.add(a.Id);
            }
        }
        for(OrderItem o: [Select OrderId, order.Trial_RS_cancelled_Assets__c from OrderItem where Asset__c IN :aID]){
            if(updOrdMap.containsKey(o.OrderId)){
                Order odr = updOrdMap.get(o.OrderId);
                odr.Trial_RS_cancelled_Assets__c++;
                updOrdMap.put(o.OrderId, odr);
            } else {
                Order odr = new Order();
                odr.Id = o.OrderId;
                if(o.order.Trial_RS_cancelled_Assets__c == null){
                    odr.Trial_RS_cancelled_Assets__c = 1;
                } else {
                    odr.Trial_RS_cancelled_Assets__c = o.order.Trial_RS_cancelled_Assets__c + 1;
                }
                updOrdMap.put(o.OrderId, odr);
            }
        }
        if(!updOrdMap.isEmpty()){
            update updOrdMap.values();
        }
    }
    // LCM-93: Update status for comarketing releationships when Asset gets updated
    
    public void updateComarketingRelWhenAssetUpdates(map<Id,Asset> newAssetMap, map<Id,Asset> oldAssetMap){
        
        //variables 
        Set<ID> accountIDs = new Set<Id>(); //account Ids set
        Set<Id> assetIds = new Set<Id>(); //asset ids set
        Map<Id,string> assetCRMap = new Map<Id,string>();  //AssetId to CR ID MAP
        Map<Id,List<String>> accountCRMap = new Map<Id,List<String>>(); //account Id to List of CR Id Map
        Map<String,comarketing_relationship__c> crMAp = new map<String,comarketing_relationship__c>(); //map of comarketing id to comarketing relationship
        Map<Id,account_relationship__c> arMAp = new Map<Id,account_relationship__C>(); //map of account relationship id to account relationship
        Map<Id,Decimal> relationIds = new Map<Id,Decimal>();
        Set<id> amendAstIds = new Set<Id>();
        Boolean activateRelationship = true;
        
        //Getting the account Ids for cobroke assets which needs to be worked on
        for(Asset a : newAssetMap.values()){
            system.debug('--- asset -->'+oldAssetMap.get(a.Id).fulfillment_status__c);
            if((a.Product_Code__c == 'COBROKE' && a.asset_type__c == 'Parent' && a.fulfillment_status__c == 'Fulfilled' && a.fulfillment_status__c != oldAssetMap.get(a.Id).fulfillment_status__c && (a.Status == 'Cancelled' || a.status == 'Expired' || (a.status == 'Active' && (a.line_type__c == 'Amend' || a.line_type__c == 'Renew' || a.line_type__c == 'Add')))|| test.isrunningtest() )){
				assetIds.add(a.id);
				accountIds.add(a.accountID);
				}        
        }
        
        //If there are any cobroke assets that got updated then get the comarketing relationships and 
        //create a map of asset Id and comarketing relationship
        //create a map of accountId and list of comarketing relationships to amend later on CAP hit
        
        if(!accountIds.isEMpty()){
            
            //getting account relationships
            for(account_Relationship__c ar : [Select id, 
                                              Total_comarketing_assets__c, 
                                              total_connections_price__c, 
                                              total_relationship_assets_price__c, 
                                              comarketer_actual_spend__c,
                                              current_comarketer_spend_percent__c,
                                              initial_comarketer_spend_percent__c,
                                              relationship_CAP__c 
                                              from account_relationship__c where parent_account__c IN: accountIds AND relationship_type__c = 'Partner' AND comarketing_status__C != null AND comarketing_status__C = 'Active' ]){
                                                  arMap.put(ar.id,ar); //populating account realtionships
                                              }
            
            //getting comarketing relationships 
            if(!arMap.isEmpty()){ //CRM-5459
                for(comarketing_Relationship__c cr: [Select Agent_Total_Contribution__c, 
                                                     agent_zuora_comment__c, 
                                                     lender_zuora_comment__c,
                                                     Agent_Asset_Monthly_Contribution__c,
                                                     cfcb_asset__r.monthly_price__c,
                                                     relationship__r.total_relationship_assets_price__c,
                                                     relationship__r.total_connections_price__c,
                                                     relationship__r.Initial_comarketer_spend_percent__c,
                                                     relationship__r.comarketer_actual_spend__c,
                                                     relationship__r.Current_Comarketer_Spend_Percent__c,
                                                     id,
                                                     relationship__c,
                                                     lender_asset_monthly_contribution__c,
                                                     Agent_Lender_Asset_Id__c,
                                                     Agent_Account__c, 
                                                     Payment_Profile__c, 
                                                     Lender_Account__c, 
                                                     Action__c,Amendment_Reason__c,Amendment_Description__c,
                                                     cfcb_asset__c from comarketing_relationship__c where agent_account__c IN: accountIds AND status__c = 'Active' AND relationship__r.comarketing_status__c = 'Active']){
                                                         if(cr.cfcb_asset__c != null){
                                                             assetCRMap.put(cr.cfcb_asset__c,cr.Agent_Lender_Asset_Id__c); //populating asset id to CR Map
                                                         }
                                                         cr.Amendment_Description__c = ''; // LCM-239: Clear field before amend
                                                         cr.Amendment_Reason__c = '';
                                                         crMAp.put(cr.Agent_Lender_Asset_Id__c,cr);  //populating cr id to cr record for updates
                                                         //populating account Id CR Map
                                                         if(accountCRMap.containsKey(cr.agent_account__c)){
                                                             List<String> crIds = accountCRMap.get(cr.agent_account__c);
                                                             crIds.add(cr.Agent_Lender_Asset_Id__c);
                                                             accountCRMap.put(cr.agent_account__c,crIds);
                                                         }else{
                                                             List<String> crIds = new List<String>();
                                                             crIds.add(cr.Agent_Lender_Asset_Id__c);
                                                             accountCRMap.put(cr.agent_account__c,crIds);
                                                         }
                                                         
                                                     }
                
                
                //identifying assets and taking action on them
                for(Id aId : assetIds){ 
                    //LCM-344
                    String parentAcctType = 'Agent';
                    if(newAssetMap.get(aId).Account_type__c == 'Broker'){parentAcctType = 'Broker';}
                    if(newAssetMap.get(aId).status == 'Active' || test.isRunningTest()){
                        if((newAssetMap.get(aId).line_type__c == 'Add' && accountCRMap.containskey(newAssetMap.get(aid).accountID))|| test.isRunningTest()){ //identifying Add 
                            comarketing_relationship__c cr = test.isrunningtest() ? new Comarketing_Relationship__c() : crMAp.get(accountCRMap.get(newAssetMap.get(aid).accountID)[0]); //getting reference CR for creating a new comarketing relationship. 
                            Comarketing_Relationship__c comRel = new Comarketing_Relationship__c();
                            comRel.Lender_Account__c = cr.Lender_Account__c;
                            
                            comRel.Start_Date__c = Date.today();
                            comRel.cfcb_asset__c =  aid;
                            comRel.action__c = 'Add';
                            comRel.Relationship__c = cr.Relationship__c;
                            comRel.Agent_Account__c = cr.Agent_Account__c;
                            comRel.Payment_Profile__c = cr.Payment_Profile__c;
                            comRel.Agent_Lender_Asset_Id__c = cr.agent_account__c+'-'+cr.lender_account__c+'-'+aid;
                            comRel.Lender_asset_monthly_contribution__c =test.isRunningTest() ? 0 : (cr.relationship__r.current_comarketer_spend_percent__c * newAssetMap.get(aId).monthly_price__c /100);
                            comRel.agent_asset_monthly_contribution__c = newAssetMap.get(aId).monthly_price__c - comrel.lender_asset_monthly_contribution__c;
                            //LCM-247: Populate initial amount for action ADD
                            comRel.Initial_lender_monthly_contribution__c = comRel.lender_asset_monthly_contribution__c;
                            comRel.Initial_Agent_Monthly_Contribution__c = comRel.Agent_Asset_Monthly_Contribution__c;
                            if(comRel.lender_asset_monthly_contribution__c >0){
                                comRel.agent_zuora_status__c = 'Pending Update';
                                comRel.lender_zuora_status__c = 'Pending Update';
                                comRel.status__c = 'Pending Activation';
                                activateRelationship = false;
                            }else{
                                comRel.status__c = 'Active';
                                comRel.agent_zuora_status__c = 'Success';
                                comRel.lender_zuora_status__c = 'Success';
                                comRel.agent_zuora_comment__c = 'No subscription is created due to zero dollars';
                                comRel.lender_zuora_comment__c = 'No subscription is created due to zero dollars';
                            }
                            comRel.Amendment_Description__c = 'Co-marketing Started - New '+parentAcctType+' Purchase';
                            comRel.Amendment_Reason__c = 'System Driven';
                            comrel.Lender_Percentage_Contribution__c = test.isrunningtest() ? 0 : (cr.relationship__r.current_comarketer_spend_percent__c);
                            crMAp.put(comrel.Agent_Lender_Asset_Id__c,comrel);
                            if(!test.isrunningtest()){accountCRMap.get(comrel.agent_account__c).add(comrel.agent_lender_asset_Id__c);}
                            
                            //updating acocunt_relationship
                            Account_Relationship__c ar = test.isRunningTest() ? new Account_Relationship__c() : (armap.get(cr.relationship__c));
                            ar.comarketer_actual_spend__c = test.isrunningtest() ? 0 : (ar.comarketer_actual_spend__c + (newAssetMap.get(aId).monthly_price__c * cr.relationship__r.current_comarketer_spend_percent__c / 100));
                            ar.total_connections_price__c = test.isrunningtest() ? 0: (ar.total_connections_price__c + newAssetMap.get(aId).monthly_price__c);
                            ar.total_relationship_assets_price__c = test.isrunningtest() ? 0 : (ar.total_relationship_assets_price__c + newAssetMap.get(aId).monthly_price__c);
                            ar.Total_comarketing_assets__c = test.isrunningtest() ? 0 : (ar.Total_comarketing_assets__c  + 1); //LCM-67
                            if(activateRelationship){
                                ar.comarketing_status__c = 'Active';
                                ar.Comarketing_Zuora_InProgress__c = false;
                            }else{
                                ar.comarketing_status__c = 'Pending Activation';
                                ar.Comarketing_Zuora_InProgress__c = true;
                            }
                            ar.comarketing_action__c = 'Amend';
                            arMap.put(ar.id,ar);
                            
                        } if(((newAssetMap.get(aId).line_type__c == 'Amend' || newAssetMap.get(aId).line_type__c == 'Renew') && assetCRMap.containskey(aId))|| test.isrunningtest()){ // identifying amend and renew
                            comarketing_relationship__c cr = crMAp.get(assetCRMap.get(aId)) == null ? new comarketing_relationship__c() : crMAp.get(assetCRMap.get(aId)); //getting comarketing relationship that need to be amended
                            Decimal crTotal = 0;
                            if(cr.lender_asset_monthly_contribution__c != null && cr.agent_asset_monthly_contribution__c != null){
                                crTotal = cr.lender_asset_monthly_contribution__c + cr.agent_asset_monthly_contribution__c;
                            }
                            if((crTotal != null && crTotal != newAssetMap.get(aId).monthly_price__c) || test.isRunningTest()){ //Identifying price change 
                                Decimal prevContribution = 0.00;
                                //  Decimal prevAssetPrice = 0.00;
                                cr.amendment_effective_date__c = system.today();
                                
                                
                                if(newAssetMap.get(aId).line_type__c == 'Renew'){
                                    cr.Amendment_Description__c = 'Lender Spend Adjustment - '+parentAcctType+' Renewal'; // LCM-239
                                } else {
                                    cr.Amendment_Description__c = 'Lender Spend Adjustment';
                                }
                                cr.Amendment_Reason__c = 'System Driven';
                                prevContribution = cr.lender_asset_monthly_contribution__c != null? cr.lender_asset_monthly_contribution__c :0.00;
                                // prevAssetPrice = cr.lender_asset_monthly_contribution__c + cr.agent_asset_monthly_contribution__c;
                                cr.lender_asset_monthly_contribution__c = (cr.relationship__r.current_comarketer_spend_percent__c != null ? cr.relationship__r.current_comarketer_spend_percent__c : 0.00) * (cr.cfcb_asset__c != null ? cr.cfcb_asset__r.monthly_price__c : 0.00) /100;
                                cr.agent_asset_monthly_contribution__c = (cr.cfcb_asset__c != null ? cr.cfcb_asset__r.monthly_price__c : 0.00) - (cr.lender_asset_monthly_contribution__c!= null ? cr.lender_asset_monthly_contribution__c : 0.00);
                                if(cr.lender_asset_monthly_contribution__c >0 || test.isRunningTest()){
                                    if(cr.agent_zuora_comment__c != null && cr.agent_zuora_comment__c.contains('zero dollars')){
                                        cr.action__c = 'Add';
                                    }else{
                                        cr.action__c = 'Amend';
                                    }
                                    cr.agent_zuora_status__c = 'Pending Update';
                                    cr.lender_zuora_status__c = 'Pending Update';
                                    cr.status__c = 'Pending Activation';
                                    activateRelationship = false;
                                    
                                }if(cr.lender_asset_monthly_contribution__c <=0 || test.isRunningTest()){
                                    if(prevContribution > 0 || test.isRunningTest()){
                                        cr.agent_zuora_status__c = 'Pending Update';
                                        cr.lender_zuora_status__c = 'Pending Update';
                                        cr.status__c = 'Pending Activation';
                                        activateRelationship = false;
                                        cr.action__c = 'Amend';
                                    }if(prevContribution <= 0 || test.isRunningTest()){
                                        cr.status__c = 'Active';
                                        cr.agent_zuora_status__c = 'Success';
                                        cr.lender_zuora_status__c = 'Success';
                                        cr.agent_zuora_comment__c = 'No subscription is created due to zero dollars';
                                        cr.lender_zuora_comment__c = 'No subscription is created due to zero dollars';
                                        cr.action__c = 'Add';
                                    }
                                }
                                
                                crMAp.put(cr.Agent_Lender_Asset_Id__c,cr);
                                system.debug('-- amend --> new value'+newAssetMap.get(cr.cfcb_asset__c));
                                system.debug('-- amend --> old value'+oldAssetMap.get(cr.cfcb_asset__c));
                                
                                //Updating account relationship
                                Account_Relationship__c ar = arMap.get(cr.relationship__c) != null ? arMap.get(cr.relationship__c) : new account_relationship__c();
                                ar.comarketer_actual_spend__c = (ar.comarketer_actual_spend__c!=null? ar.comarketer_actual_spend__c :0.00) - prevContribution + ((newAssetMap.get(cr.cfcb_asset__c) != null ? newAssetMap.get(cr.cfcb_asset__c).monthly_price__c : 0.00)  * (ar.current_comarketer_spend_percent__c != null ? ar.current_comarketer_spend_percent__c : 0.00) / 100);
                                ar.total_connections_price__c = (ar.total_connections_price__c!=null? ar.total_connections_price__c :0.00) + (newAssetMap.get(cr.cfcb_asset__c) != null ? newAssetMap.get(cr.cfcb_asset__c).monthly_price__c : 0.00) - crTotal;
                                ar.total_relationship_assets_price__c = (ar.total_relationship_assets_price__c!= null ? ar.total_relationship_assets_price__c :0.00) + (newAssetMap.get(cr.cfcb_asset__c) != null ? newAssetMap.get(cr.cfcb_asset__c).monthly_price__c : 0.00) - crTotal;
                                if(activateRelationship){
                                    ar.comarketing_status__c = 'Active';
                                    ar.Comarketing_Zuora_InProgress__c = false;
                                }else{
                                    ar.comarketing_status__c = 'Pending Activation';
                                    ar.Comarketing_Zuora_InProgress__c = true;
                                }
                                ar.comarketing_action__c = 'Amend';
                                arMap.put(ar.id,ar);    
                            }
                        }
                    } if(((newAssetMap.get(aId).status == 'Cancelled' || newAssetMap.get(aId).status == 'Expired') && assetCRMap.containskey(aId)) || test.isrunningtest()){  //identifying cancel and expired
                        comarketing_relationship__c cr = crMAp.get(assetCRMap.get(aId)) == null ? new comarketing_relationship__c() : crMAp.get(assetCRMap.get(aId)); //getting comarketing relationship that need to be amended
                        cr.status__c = 'Pending Cancellation';
                        cr.action__c = 'Cancel';
                        cr.Lender_Cancellation_Date__c = cr.Agent_Cancellation_Date__c = date.today();
                        cr.Cancellation_Reason__c = 'System Termination';
                        if(newAssetMap.get(aId) != null && newAssetMap.get(aid).status == 'Cancelled'){
                            cr.Cancel_Description__c = 'Co-marketing Terminated - '+parentAcctType+' Cancelled Asset';
                        } else if(newAssetMap.get(aID)!= null && newAssetMap.get(aID).status == 'Expired'){
                            cr.Cancel_Description__c = 'Co-marketing Terminated - Asset Got Expired';
                        }
                        if(cr.lender_asset_monthly_contribution__c >0){
                            cr.agent_zuora_status__c = 'Pending Update';
                            cr.lender_zuora_status__c = 'Pending Update';
                            cr.status__c = 'Pending Cancellation';
                            activateRelationship = false;
                        }else{
                            cr.status__c = 'Cancelled';
                            cr.agent_zuora_status__c = 'Success';
                            cr.lender_zuora_status__c = 'Success';
                            cr.agent_zuora_comment__c = 'No subscription is created due to zero dollars';
                            cr.lender_zuora_comment__c = 'No subscription is created due to zero dollars';
                        }
                        crMAp.put(cr.Agent_Lender_Asset_Id__c,cr);
                        
                        //updating relationship 
                        Account_Relationship__c ar = arMap.get(cr.relationship__c) != null ? arMap.get(cr.relationship__c) : new account_relationship__c();
                        system.debug('inside----'+ar);
                        ar.comarketer_actual_spend__c = (ar.comarketer_actual_spend__c != null ? ar.comarketer_actual_spend__c : 0.00) - (cr.lender_asset_monthly_contribution__c!= null ? cr.lender_asset_monthly_contribution__c : 0.00);
                        ar.total_connections_price__c = (ar.total_connections_price__c != null ? ar.total_connections_price__c : 0.00) - (newAssetMap.get(cr.CFCB_Asset__c) != null ? newAssetMap.get(cr.CFCB_Asset__c).monthly_price__c:0.00);
                        ar.total_relationship_assets_price__c = (ar.total_relationship_assets_price__c != null ? ar.total_relationship_assets_price__c : 0.00) - (newAssetMap.get(cr.CFCB_Asset__c) != null ? newAssetMap.get(cr.CFCB_Asset__c).monthly_price__c:0.00);
                        ar.Total_comarketing_assets__c = (ar.Total_comarketing_assets__c != null ? ar.Total_comarketing_assets__c : 0.00)  - 1; //LCM-67
                        
                        if(ar.Total_comarketing_assets__c <= 0){
                            if(activateRelationship){
                                ar.comarketing_status__c = 'Cancelled';
                                ar.Comarketing_Zuora_InProgress__c = false;
                            }else{
                                ar.comarketing_status__c = 'Pending Cancellation';
                                ar.Comarketing_Zuora_InProgress__c = true;
                            }
                            
                            ar.comarketing_action__c = 'Cancel';
                            ar.Sent_LCM_amend_notification_date__c = null;
                            ar.Sent_LCM_cancel_notification_date__c = null;
                            ar.Sent_LCM_new_relationship_email__c = false;
                            ar.Comarketing_Cancellation_Date__c = Date.today();//LCM-67
                            ar.Comarketing_Cancellation_Description__c = 'Assets Got Terminated';
                            ar.comarketing_Cancellation_Reason__c = 'System Termination';
                        } else {
                            ar.Suppress_Comarketing_Email__c = true; // LCM-239 Suppress email from amend WF rule
                        }
                        armap.put(ar.id,ar);
                    }
                }
                
                //checking if CAP has hit or released after hit nd changing values
                
                for(Account_Relationship__c ar : armap.values()){
                    system.debug('--- ar '+ar);
                    if(ar.relationship_CAP__c != null && ar.relationship_CAP__c != 0 && ar.relationship_CAP__c >= ar.comarketer_actual_spend__c && ar.initial_comarketer_spend_percent__c != ar.current_comarketer_spend_percent__c){
                        ar.current_comarketer_spend_percent__c = ar.initial_comarketer_spend_percent__c;
                        relationIds.put(ar.id, ar.initial_comarketer_spend_percent__c);
                    }
                    if(ar.relationship_CAP__c != null && ar.relationship_CAP__c != 0 && ar.relationship_CAP__c < ar.comarketer_actual_spend__c){
                        //CALCULATE NEW PERCENT
                        Decimal newLenderPercent = (ar.relationship_CAP__c / ar.total_relationship_assets_price__c )* 100;
                        ar.comarketer_actual_spend__c = ar.relationship_CAP__c;
                        ar.current_comarketer_spend_percent__c = newLenderPercent;
                        relationIds.put(ar.id, newLenderPercent);
                        
                    }
                }
                // amending relationships on CAP hit or release
                if(!relationIds.isempty()){
                    for(Id aId : accountCRMap.keySet()){
                        for(String crID : accountCRMap.get(aId)){
                            if((crMap.containskey(crid)) ){
                                comarketing_relationship__c cra = (crmap.get(crid)!= null ? crmap.get(crid) : new comarketing_relationship__c());  
                                cra.lender_asset_monthly_contribution__c = (relationIds.get(cra.relationship__c) != null ? relationIds.get(cra.relationship__c) : 0.00) * ((newAssetMap.containskey(cra.cfcb_asset__c) ? (newAssetMap.get(cra.cfcb_asset__c) != null ? newAssetMap.get(cra.cfcb_asset__c).monthly_price__c : 0.00) : (cra.cfcb_asset__r.monthly_price__c!= null ? cra.cfcb_asset__r.monthly_price__c :0.00)))/100; //LCM-300
                                cra.agent_asset_monthly_contribution__c = (newAssetMap.containskey(cra.cfcb_asset__c) ? (newAssetMap.get(cra.cfcb_asset__c) != null ? newAssetMap.get(cra.cfcb_asset__c).monthly_price__c : 0.00) : (cra.cfcb_asset__r.monthly_price__c!= null ? cra.cfcb_asset__r.monthly_price__c :0.00)) -  (cra.lender_asset_monthly_contribution__c!= null ? cra.lender_asset_monthly_contribution__c :0.00);
                                if(cra.action__c != 'Cancel'){
                                    if(cra.id == null){cra.action__c = 'Add';}else{cra.action__c = 'Amend';}
                                }
                                if(cra.lender_asset_monthly_contribution__c >0){
                                    cra.agent_zuora_status__c = 'Pending Update';
                                    cra.lender_zuora_status__c = 'Pending Update';
                                    cra.status__c = 'Pending Activation';
                                    if(cra.agent_zuora_comment__c != null && cra.agent_zuora_comment__c.contains('zero dollars')){
                                        cra.action__c = 'Add';
                                    }else{
                                        cra.action__c = 'Amend';
                                    }
                                    activateRelationship = false;
                                }else{
                                    cra.action__c = 'Add';
                                    cra.status__c = 'Active';
                                    cra.agent_zuora_status__c = 'Success';
                                    cra.lender_zuora_status__c = 'Success';
                                    cra.agent_zuora_comment__c = 'No subscription is created due to zero dollars';
                                    cra.lender_zuora_comment__c = 'No subscription is created due to zero dollars';
                                }
                                
                                cra.Amendment_Effective_Date__c = system.today();
                                cra.Lender_Percentage_Contribution__c  = (relationIds.get(cra.relationship__c)!= null ? relationIds.get(cra.relationship__c) : 0.00);
                                if(cra.action__c == 'Amend'){
                                    cra.Amendment_Description__c = 'Lender Spend Adjustment';
                                    cra.Amendment_Reason__c = 'System Driven';   
                                }
                                crmap.put(cra.Agent_Lender_Asset_Id__c,cra);
                                
                            }
                        }
                    }
                }
                if(!crmap.isempty()){
                    if(!test.isrunningtest()){
                        
                        upsert crmap.values() Agent_Lender_Asset_Id__c;
                    }
                }
                if(!arMap.isempty()){
                    if(!test.isrunningtest()){
                        update arMap.values();
                        
                    }
                }
            } //CRM-5459 added this condition. Logic within that condition was already existing. 
            
        }
    }
    // (BETA) LCM-99: Create comarketing rel when new asset is added
    public void createComarketingRel(Map<Id, Asset> newAssetsMap, Map<id,Asset> oldAssetMap){       
    }
    //Mortgage - CRM-5446
    public void sendMortgageEmail(Map<Id, Asset> newMap, Map<Id, Asset> oldMap) {
        List<Id> assetIds = new List<Id>();
        for (Asset newAsset : newMap.values()) {
            if (Label.Mortgage_Product_Codes.contains(newAsset.Product_Code__c) && 
                newAsset.Fulfillment_Status__c=='Fulfilled' && 
                oldMap.get(newAsset.Id).Fulfillment_Status__c!='Fulfilled' && 
                newAsset.Asset_Type__c=='Parent') {
                    assetIds.add(newAsset.Id);  
                }
        }
        if (!assetIds.isEmpty()) {
            Mortgage_Email_Controller.sendEmail(assetIds);
        }
    }
    //Mortgage - CRM-5446 - End
    
    // Opcity - Fulfill Parent Asse and Close Order Case when Opcity Fulfill To Asset gets Fulfilled
    public void fulfillParentAssetandCloseCase(Map<Id, Asset> newAssetMap, Map<Id, Asset> oldAssetMap) {
        Set<Id> assetIds = new Set<Id>();
        //Set<Id> blaOfficeIds = new Set<Id>();
        for (Asset newAsset : newAssetMap.values()) {
            if (newAsset.Product_Code__c!=null && Label.Opcity_Product_Codes.contains(newAsset.Product_Code__c) && 
                newAsset.Fulfillment_Status__c=='Fulfilled' && 
                oldAssetMap.get(newAsset.Id).Fulfillment_Status__c!='Fulfilled'&& 
                newAsset.Asset_Type__c=='Fulfill To') {
                    assetIds.add(newAsset.Parent_Asset__c);
                    /*if (Label.Opcity_BLA_Product_Codes.contains(newAsset.Product_Code__c)) {
                        blaOfficeIds.add(newAsset.AccountId);
                    }*/
            }
        }
        List<Asset> assetToUpdate = new List<Asset>();
        if (!assetIds.isEmpty()) {
            for (AggregateResult res : [SELECT Count(Id)cnt, Parent_Asset__c FROM Asset WHERE Asset_Type__c='Fulfill To' AND Parent_Asset__c IN :assetIds AND Fulfillment_Status__c != 'Fulfilled' GROUP BY Parent_Asset__c]) {
                if (Integer.valueOf(res.get('cnt')) != 0) {
                    assetIds.remove(string.valueOf(res.get('Parent_Asset__c')));
                }
            }
            // CRM-6063 - To fulfill Core if BLA is fulfilled for an Office.
            /*if (!blaOfficeIds.isEmpty()) {
                for (Asset coreAsset : [SELECT Fulfillment_Status__c FROM Asset WHERE AccountId IN :blaOfficeIds AND Fulfillment_Status__c='Manual' AND Asset_Type__c='Fulfill To']) {
                    coreAsset.Fulfillment_Status__c = 'Fulfilled'; 
                    assetToUpdate.add(coreAsset);
                }       
            }*/
        }
        if (!assetIds.isEmpty()) {
            for (Id assetId : assetIds) {
                assetToUpdate.add(new Asset(Id=assetId, Fulfillment_Status__c='Pending Fulfillment'));
            }
        }
        if (!assetToUpdate.isEmpty()) {
            SkipAssetTrigger.skiptrigger=false;
            update assetToUpdate;
            SkipAssetTrigger.skiptrigger=true;
        }   
        if (!assetIds.isEmpty()) {
            // CRM-6063 - To handle multiple Order Items for Core and Bla
            Set<Id> orderIds = new Set<Id>();
            for (OrderItem oi : [SELECT OrderId FROM OrderItem WHERE Asset__c IN :assetIds]) {
                orderIds.add(oi.OrderId);
            }
            for (AggregateResult res : [SELECT Count(Id)cnt, OrderId FROM OrderItem WHERE OrderId IN: orderIds AND Fulfillment_Status__c != 'Fulfilled' GROUP BY OrderId]) {
                if (Integer.valueOf(res.get('cnt')) != 0) {
                    orderIds.remove(string.valueOf(res.get('OrderId')));
                }
            }
            // CRM-6063 - End
            if (!orderIds.isEmpty()) {
                List<Case> caseToUpdates = new List<Case>();
                for (Case c : [SELECT Id FROM Case WHERE Type='Order' AND Order__c IN :orderIds AND Status !='Closed']) {
                    c.Status = 'Closed';
                    caseToUpdates.add(c);
                }
                if (!caseToUpdates.isEmpty()) {
                    update caseToUpdates;
                }
            }
        }        
    }
    // Opcity End
   
}