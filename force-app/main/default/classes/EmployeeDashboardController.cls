/*****************************************************************************
* Class Name: EmployeeDashboardController
* Author: Shraddha Kabade
* Purpose: To perform various operations for community VF pages.
* JIRA : SUITE-3153
****************************************************************************/
global class EmployeeDashboardController {
    
    public EmployeeDashboardController(){
    }
    
    /**
* Get logged in user details.
*/
    @RemoteAction
    public static User getloggedInUser(){
        User userDetail = new User();
        Id currentLoggedInUser = UserInfo.getUserId();
        
        if(!Test.isRunningTest()){
            userDetail = [Select id, Name, Email, ContactId, Contact.AccountId, Account.Name, Account.type, Account.isBinder__c,
                          Account.Party_Id__c, CommunityNickname, Phone, Account.Binder_account_active_till_date__c
                          from User Where id = :currentLoggedInUser and ContactId != null limit 1];
        } else {
            Id p = [select id,name from profile where name='Customer Community Login user'].id;
            userDetail = [Select id, Name, Email, ContactId, Contact.AccountId, Account.Name, Account.type, Account.Party_Id__c, 
                          CommunityNickname, Phone, Account.isBinder__c, Account.Binder_account_active_till_date__c
                          from user where  profileId =:p and isActive=true limit 1];
            
        }
        return userDetail;
    }
    
    /**
* Method to check if accounts are already created by the user. 
*/
    @RemoteAction
    public static Account getfranchiseAcct(){
        User userDetail = EmployeeDashboardController.getloggedInUser();
        System.debug('acct---'+userDetail);
        if(!Test.isRunningTest() && (userDetail.Account.Name.contains(userDetail.CommunityNickname) && userDetail.Account.isBinder__c)){
            Account a = new Account();
            a.Id = userDetail.AccountId;
            a.Binder_account_active_till_date__c = userDetail.Account.Binder_account_active_till_date__c;
            return a;
        }
        return null;
    }
    
    /**
* Method to create accounts, relationships and MLS records.
* @param Type of account
* @param Number of agents for Broker type
* @param Number of offices for Broker type
* @param Number of days the account will be active
* @param Map of office and number of agents. Used to clone existing user details.
*/
    @RemoteAction
    public static String createAccounts(String acctType, Integer numOfAgents, Integer numOfOffices, Integer activeDays){
        
        List<Account> acctList = new List<Account>();
        List<Account> officeAcctList = new List<Account>();
        List<Account> agentAcctList = new List<Account>();
        Set<Account> acctSet = new Set<Account>();
        List<MLS__c> mlsList = new List<MLS__c>();
        Set<MLS__c> mlsSet = new Set<MLS__c>();
        List<Account_Relationship__c> relList = new List<Account_Relationship__c>();
        Set<Account_Relationship__c> relSet = new Set<Account_Relationship__c>();
        Id accB2BRecTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('B2B').RecordTypeId;
        Id accB2CRecTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('B2C').RecordTypeId;
        Id accRelRecTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Account Relationship').RecordTypeId;  
        Id mlsRecAgn = Schema.getGlobalDescribe().get('MLS__c').getDescribe().getRecordTypeInfosByName().get('MLS Agent').getRecordTypeId();
        Id mlsRecOff = Schema.getGlobalDescribe().get('MLS__c').getDescribe().getRecordTypeInfosByName().get('MLS Office').getRecordTypeId();

        EmployeeDashboardController ed = new EmployeeDashboardController();
        User userDetail = EmployeeDashboardController.getloggedInUser();
        // Get Binder MLS Account. This account will be populated as MLS_Account on all MLS records.
        List<Account> MLSAccts = new List<Account>();
        MLSAccts = [Select id from Account where Name='BINDER1' and type = 'MLS Account' and Customer_Id__c='B1CA' limit 1];
        Collection_Users__c cu = Collection_Users__c.getValues('Binder account user');
        
        // CRM-3038
        // Associate new franchise Account to the user contact. And create multiple broker/agent accounts under it.
        Account fa = EmployeeDashboardController.getfranchiseAcct();
        String franchiseId = '';
        
        // This field is used to get total number of broker accounts under franchise.
        Integer acctCnt = 0;
        Account franchiseAcct = new Account();
        if(fa == null){
            franchiseAcct.Name = userDetail.Name+'-'+userDetail.CommunityNickname+' Franchise';
            franchiseAcct.Email_Address__c = userDetail.Email;
            franchiseAcct.phone = userDetail.Phone;
            franchiseAcct.isBinder__c = franchiseAcct.Test__c= true;
            franchiseAcct.OwnerId = cu.id__c;
            franchiseAcct.RecordTypeId = accB2BRecTypeId;
            franchiseAcct.Type = 'Franchise Company';
            franchiseAcct.Binder_account_active_till_date__c = Date.today().adddays(activeDays);
            acctSet.add(franchiseAcct);
            
        } else {
            // Else if franchise acct already exists then add new Brokers under it
            franchiseId = fa.Id;
            acctCnt = [Select count() from Account_Relationship__c where Parent_Account__c = :franchiseId and Relationship_Type__c = 'Parent/Child' and Child_Account_Type__c = 'Broker'];
        }
        
        acctCnt++;
        System.debug('acctcnt---'+acctCnt);
        Contact cont = new Contact();
        cont.id = userDetail.ContactId;
        cont.BAD_Email__c = 'No';
        if(acctType == 'Agent'){
            
            // For Agent type only 1 agent and office will be created.
            // Create Agent Account
            Account a = new account();
            a.Name = userDetail.Name+'-'+userDetail.CommunityNickname+'-Agent Acct'+acctCnt;
            //CRM-3038 : Creating brokers with diff email addresses
            a.Email_Address__c = userDetail.Email.replace('@', '+'+acctCnt+'@');
            a.OwnerId = cu.id__c;
            a.type = 'Realtor Agent';
            a.RecordTypeId = accB2CRecTypeId;
            a.Phone  = userDetail.Phone;
            a.isBinder__c = a.Test__c= true;
            acctSet.add(a);
            
            //Create Office Account
            Account offAct = new account();
            offAct.Name = userDetail.Name+'-'+userDetail.CommunityNickname+'-Office Acct'+acctCnt;
            offAct.Email_Address__c = userDetail.Email.replace('@','O+'+acctCnt+'@');
            offAct.OwnerId = cu.id__c;
            offAct.type = 'Realtor Office';
            offAct.RecordTypeId = accB2BRecTypeId;
            offAct.Phone  = userDetail.Phone;
            offAct.isBinder__c = offAct.Test__c = true;
            acctSet.add(offAct);
            
            if(!acctSet.isEmpty()){
                acctList.addAll(acctSet);
                insert acctList;
            }
            if(franchiseId == ''){
                franchiseId = franchiseAcct.id;
                cont.accountId = franchiseAcct.Id;
                update cont;
            }
            
            //Add relationship between Office and Franchise
            Account_Relationship__c actRel1 = new Account_Relationship__c();
            actRel1.Parent_Account__c = franchiseId;
            actRel1.Child_Account__c =  offAct.id;
            actRel1.Relationship_Type__c = 'Parent/Child';
            actRel1.Active__c = true;
            actRel1.Is_Parent_Primary__c = true;
            actRel1.RecordTypeId = accRelRecTypeId;
            relSet.add(actRel1);
            
            //Add relationship between Office and Agent
            Account_Relationship__c actRel = new Account_Relationship__c();
            actRel.Parent_Account__c = offAct.Id;
            actRel.Child_Account__c =  a.id;
            actRel.Relationship_Type__c = 'Parent/Child';
            actRel.Active__c = true;
            actRel.Is_Parent_Primary__c = true;
            actRel.RecordTypeId = accRelRecTypeId;
            relSet.add(actRel);
            
            if(!relSet.isEmpty()){
                relList.addAll(relSet);
                insert relList;
            }
            
            
            //Create agent MLS
            MLS__c agentMLS = new MLS__c();
            agentMLS.Name = agentMLS.MLS_Set_ID__c = 'A-B1CA-'+userDetail.CommunityNickname+'ACCT'+acctCnt;
            agentMLS.Primary_MLS_Set__c = true;
            agentMLS.MLS_Area_Source_Reference__c = 'B1CA';
            agentMLS.agent__c = a.id;
            agentMLS.Office__c = offAct.id;
            agentMLS.MLS__c = MLSAccts[0].id;
            agentMLS.status__c = 'Active';
            agentMLS.MLS_Set_Type__c = 'Agent';
            agentMLS.RecordTypeId = mlsRecAgn;
            mlsSet.add(agentMLS);  
            
            //Create office MLS
            MLS__c offMLS = new MLS__c();
            offMLS.Name = offMls.MLS_Set_ID__c = 'O-B1CA-'+acctCnt+userDetail.CommunityNickname+'ACCT'+acctCnt;
            offMLS.Primary_MLS_Set__c = true;
            offMLS.MLS_Area_Source_Reference__c = 'B1CA';
            offMLS.agent__c = a.id;
            offMLS.Office__c = offAct.id;
            offMLS.MLS__c = MLSAccts[0].id;
            offMLS.status__c = 'Active';
            offMLS.MLS_Set_Type__c = 'Office';
            offMls.RecordTypeId = mlsRecOff;
            mlsSet.add(offMLS);  
            
            if(!mlsSet.isEmpty()){
                mlsList.addAll(mlsSet);
                insert mlsList;
            }
            system.debug('MLSAccts---'+mlsSet);
            // Update MLS_Set_Id__c field on agent and office accounts.
            ed.updFieldsOnAcct(mlsSet);
            return 'success';
            
        } else if(acctType == 'Broker'){
            
            // CRM-3038 :If user already has only 1 agent and office account, then associate 
            // this agent's office account under new broker, instead of creating extra office and agent. 
            
            Account existingAgn = new Account();
            Account existingOff = new Account();
            System.debug(existingAgn);
             if(fa != null){
                List<Account> accl = getAllParentAccounts(false);
                if(accl.size() == 1 && accl[0].Type == 'Realtor Agent'){
                    existingAgn = accl[0];
                    List<Id> fidL = new List<Id>{franchiseId};
                    List<Account> ol = getOffUnderBroker(fidL);
                    if(ol.size() == 1){
                        existingOff = ol[0];
                        numOfOffices--;
                        numOfAgents--;
                    }
            }
             }
            System.debug('agent----****'+existingAgn);
             System.debug('agent----****'+existingAgn.Id);
                //Create Office Accounts
            for(Integer i=0; i<numOfOffices;i++){
                Account offA = new account();
                offA.Name = userDetail.Name+'-'+userDetail.CommunityNickname+'Acc'+acctCnt+' Office'+(i+1);
                offA.Email_Address__c = userDetail.Email.replace('@','O+'+acctCnt+(i+1)+'@');
                offA.OwnerId = cu.id__c;
                //CRM-2972
                offA.Phone  = userDetail.Phone;
                offA.type = 'Realtor Office';
                offA.RecordTypeId = accB2BRecTypeId;
                offA.isBinder__c = offA.Test__c =true;
                acctSet.add(offA);
            }
            

            //Create Agent Accounts
            for(Integer i=0; i<numOfAgents;i++){
                system.debug('agent acc---');
                Account agnAcct = new account();
                agnAcct.Name = userDetail.Name+'-'+userDetail.CommunityNickname+'Acc'+acctCnt+' Agent'+(i+1);
                agnAcct.Email_Address__c = userDetail.Email.replace('@','A+'+acctCnt+(i+1)+'@');
                //CRM-2972
                agnAcct.Phone  = userDetail.Phone;
                agnAcct.OwnerId = cu.id__c;
                agnAcct.type = 'Realtor Agent';
                agnAcct.RecordTypeId = accB2CRecTypeId;
                agnAcct.isBinder__c = agnAcct.Test__c = true;
                acctSet.add(agnAcct);
            }
            
            //Create a broker account
            Account a = new account();
            a.Name = userDetail.Name+'-'+userDetail.CommunityNickname+'-Broker'+acctCnt;
            a.Email_Address__c = userDetail.Email.replace('@', '+'+acctCnt+'@');
            a.Phone  = userDetail.Phone;
            a.OwnerId = cu.id__c;
            a.type = 'Broker';
            a.RecordTypeId = accB2BRecTypeId;
            a.isBinder__c = a.Test__c = true;
            acctSet.add(a);
            
            if(!acctSet.isEmpty()){
                acctList.addAll(acctSet);
                insert acctList;
            }

            if(franchiseId == ''){
                franchiseId = franchiseAcct.id;
                cont.accountId = franchiseAcct.Id;
                update cont;
            }
            
            // Add relationship between Broker and Franchise
            Account_Relationship__c actRel1 = new Account_Relationship__c();
            actRel1.Parent_Account__c = franchiseId;
            actRel1.Child_Account__c =  a.id;
            actRel1.Relationship_Type__c = 'Parent/Child';
            actRel1.Active__c = true;
            actRel1.Is_Parent_Primary__c = true;
            actRel1.RecordTypeId = accRelRecTypeId;
            relSet.add(actRel1);
            
            // CRM-3423: Add existing agent and office to accounts list.
            if(existingAgn.Id != null && existingOff.Id != null){
                acctList.add(existingAgn);
                acctList.add(existingOff);
                numOfOffices++;
                numOfAgents++;
                // Delete relationship between office and franchise account
                List<Account_Relationship__c> ofrel = [Select id from Account_Relationship__c where Parent_Account__c = :franchiseId and Child_Account__c = :existingOff.Id];
                delete ofrel;
            }
             system.debug('agent acc---'+acctList);
            
            Integer counter = 1;
            for(Account acct: acctList){
                
                if(acct.type == 'Realtor Agent'){
                    agentAcctList.add(acct);
                }
                
                if(acct.type == 'Realtor Office'){
                    officeAcctList.add(acct);
                    
                    // Create Office MLS
                    if(acct.Id != existingOff.Id){
                        MLS__c offMls = new MLS__c();
                    offMls.Name = offMls.MLS_Set_ID__c = 'O-B1CA-'+userDetail.CommunityNickname+'ACCT'+acctCnt+'O'+counter;
                    //offMls.RecordTypeId = 
                    offMls.Primary_MLS_Set__c = true;
                    offMls.MLS_Area_Source_Reference__c = 'B1CA';
                    offMls.Office__c = acct.id;
                    offMls.MLS__c = MLSAccts[0].id;
                    offMls.status__c = 'Active';
                    offMls.MLS_Set_Type__c = 'Office';
                    offMls.RecordTypeId = mlsRecOff;
                    mlsSet.add(offMls);  
                    }
                    counter++;  
                     system.debug(' accts---'+acct);
                    // Add relationship between Offices and Broker
                    Account_Relationship__c actRel = new Account_Relationship__c();
                    actRel.Parent_Account__c = a.Id;
                    actRel.Child_Account__c =  acct.id;
                    actRel.Relationship_Type__c = 'Parent/Child';
                    actRel.Active__c = true;
                    actRel.Is_Parent_Primary__c = true;
                    actRel.RecordTypeId = accRelRecTypeId;

                    relSet.add(actRel);
                }
            }
            
            if(numOfAgents > 0 || numOfOffices > 0){
            // Distribute agents among offices equally. 
            counter = 0;
            Double val = Math.floor(numOfAgents/numOfOffices);
            
            // List<Integer> countList = offAgnCountMap.values();
            for(Integer i = 0; i<officeAcctList.size(); i++){
                // Add any extra agents under last office
                if(i == officeAcctList.size()-1){
                    val = Math.floor(numOfAgents/numOfOffices) + Math.mod(numOfAgents, numOfOffices);
                    
                }
                for(Integer j = 0; j<val; j++){
                    
                    //Create Agent MLS
                    if(agentAcctList[counter+j].id != existingAgn.Id){
                        MLS__c aMls = new MLS__c();
                    aMls.Name = aMls.MLS_Set_ID__c = 'A-B1CA-'+userDetail.CommunityNickname+'ACCT'+acctCnt+'A'+(counter+j+1);
                    aMls.Primary_MLS_Set__c = true;
                    aMls.MLS_Area_Source_Reference__c = 'B1CA';
                    aMls.Office__c = officeAcctList[i].id;
                    aMls.agent__c = agentAcctList[counter+j].id;
                    aMls.MLS__c = MLSAccts[0].id;
                    aMls.status__c = 'Active';
                    aMls.MLS_Set_Type__c = 'Agent';
                    aMls.RecordTypeId = mlsRecAgn;
                    mlsSet.add(aMls);   
                    
                    //Add relationship between Offices and Agents
                    Account_Relationship__c aRel = new Account_Relationship__c();
                    aRel.Parent_Account__c = officeAcctList[i].Id;
                    aRel.Child_Account__c = agentAcctList[counter+j].id;
                    aRel.Relationship_Type__c = 'Parent/Child';
                    aRel.Active__c = true;
                    aRel.Is_Parent_Primary__c = true;   
                    aRel.RecordTypeId = accRelRecTypeId;    
                    relSet.add(aRel);
                }
                }
                
                counter += val.intValue();  
                
            }
        }
            
            if(!mlsSet.isEmpty()){
                mlsList.addAll(mlsSet);
                insert mlsList;
            }
            
            if(!relSet.isEmpty()){
                relList.addAll(relSet);
                insert relList;
            }
            
            // Update MLS_Set_Id__c field on all agent and office accounts.
            ed.updFieldsOnAcct(mlsSet);
            
            return 'success';
        }
        return null;
    }
    
    // Update MLS_Set_Id__c field on all agent and office accounts.
    public void updFieldsOnAcct(Set<MLS__c> mlsSet){
        List<Account> acctList = new List<Account>();
        Set<Account> acctSet = new Set<Account>();
        for(MLS__c mls: mlsSet){
            Account acc = new Account();
            
            if(mls.MLS_Set_Type__c == 'Agent'){
                acc.id = mls.agent__c;
                
            } else {
                acc.id = mls.Office__c;
                
            }
            acc.MLS_Set_Id__c = mls.Name;
            acctSet.add(acc);
        }
        
        if(!acctSet.isEmpty()){
            acctList.addAll(acctSet);
            update acctList;
        }
        
    }
    
    /**
     * CRM 3038: Method to get all accounts of logged in user.
     * @param onlyBrokers
     */
    @RemoteAction
    public static List<Account> getAllParentAccounts(Boolean onlyBrokers){

        User userDetail = EmployeeDashboardController.getloggedInUser();
        Account accDetail = new Account();
        // Account field on community user will be populated on user creation.
        // Get this franchise account detail.
        Id accId = userDetail.Contact.AccountId;
        Set<Id> acctIdSet = new Set<Id>();
        List<Id> al = new List<Id>();
        Set<Id> offSet = new Set<Id>();
        List<Account_Relationship__c> arlist = [Select id, Parent_Account__c, Child_Account__c, Child_Account_Type__c from Account_Relationship__c where Parent_Account__c = :accId and Relationship_Type__c = 'Parent/Child'];
        System.debug('office type--'+arlist);
        for(Account_Relationship__c ar: arlist){
            if(ar.Child_Account_Type__c == 'Realtor Office'){
                offSet.add(ar.Child_Account__c);
            } else {
                acctIdSet.add(ar.Child_Account__c);
            }
        }
        System.debug('office type--'+offSet);
        arlist.clear();
        // If onlyBrokers is false, then also return the Agent account
        if(!onlyBrokers && !offSet.isEmpty()){
            arlist = [Select id, Parent_Account__c, Child_Account__c, Child_Account_Type__c from Account_Relationship__c where Parent_Account__c IN :offSet and Relationship_Type__c = 'Parent/Child'];
            for(Account_Relationship__c ar: arlist){
                acctIdSet.add(ar.Child_Account__c);
            }
        }

        if(!acctIdSet.isEmpty()){
            al.addAll(acctIdSet);
        }
        return getAcctsFromIds(al);
    }
    
    /**
     * Method to check if user account has main Agent account.
     */
    @RemoteAction
    public static Boolean hasMainAgent(){
        User userDetail = EmployeeDashboardController.getloggedInUser();
        Account accDetail = new Account();
        Id accId = userDetail.Contact.AccountId;
        List<Account_Relationship__c> arlist = [Select id, Parent_Account__c, Child_Account__c, Child_Account_Type__c from Account_Relationship__c where Child_Account_Type__c= 'Realtor Office' and Parent_Account__c = :accId and Relationship_Type__c = 'Parent/Child'];
        if(arlist.isEmpty()){
            return false;
        }
        return true;
    }
    
    
    /**
     * Method to update Binder_account_active_till_date__c on account.
     */
    @RemoteAction
    public static void extendDays(Account acct, Integer numOfDays){
        acct.Binder_account_active_till_date__c = Date.today().adddays(numOfDays);
        update acct;
    }
    
    /**
     * Method to get Office accounts for Broker and Agent.
     */
    @RemoteAction
    public static List<Account> getAllOffices(){
        List<Account> accList = EmployeeDashboardController.getAllParentAccounts(true);
        List<Id> brokerIds = new List<Id>();
        for(Account acc: accList){
            brokerIds.add(acc.Id);
        }
        return getOffUnderBroker(brokerIds);
    }
    
    /**
     * Method to get Office accounts for Broker.
     */
    @RemoteAction
    public static List<Account> getOffUnderBroker(List<id> brokerIds){
        List<Account_Relationship__c> accRelList = new List<Account_Relationship__c>();
        
        //Get office account related to this broker
        accRelList = [Select id, Parent_Account__c, Parent_Account__r.Name, Child_Account__r.id, Child_Account__r.Name,  Child_Account_Type__c,
                      Child_Account__r.Email_Address__c, Child_Account__r.MLS_Set_Id__c, Child_Account__r.Party_Id__c
                       from Account_Relationship__c Where Parent_Account__c IN :brokerIds and Child_Account_Type__c ='Realtor Office'];
        
        List<Id> idList = new List<Id>();
        for(Account_Relationship__c aRel: accRelList){
            idList.add(aRel.Child_Account__c);
        }
        return getAcctsFromIds(idList);
    }
    
    
    /**
     * CRM 3038: Method to get number of agents under list of office accounts.
     * Used to limit only 10 agents for a perticular broker
     */
    @RemoteAction
    public static Integer getNumberOfAgents(Id offId){
        // Get Broker from rel
        List<Account_Relationship__c> ar = [Select id, Parent_Account__c from Account_Relationship__c Where Child_Account__c = :offId and Child_Account_Type__c ='Realtor Office'];
        List<Id> accIds = new List<Id>{ar[0].Parent_Account__c};
            List<Account> offList = getOffUnderBroker(accIds);
        accIds.clear();
        for(Account a: offList){
            accIds.add(a.Id);
        }
        List<Account> agnList = getAgentAccounts(accIds);
        return agnList.size();
    }
    
    /**
     * Method to get agent accounts details
     * @param Office id for which agents need to be retrived.
     */
    @RemoteAction
    public static List<Account> getAgentAccounts(List<id> offAccId){
        
        List<Account_Relationship__c> accRelList = new List<Account_Relationship__c>();
        List<Account> acctList = new List<Account>();
        //Get all agents which are related to the office
        accRelList = [Select id, Parent_Account__c, Child_Account__r.id, Child_Account__r.Name, Child_Account__r.ImpersonationLink__c,
                      Child_Account__r.Email_Address__c, Child_Account__r.MLS_Set_Id__c, Child_Account__r.Party_Id__c, 
                      Child_Account__r.EssentialsStatus__c, Child_Account__r.Advertiserid__c
                      from Account_Relationship__c Where Parent_Account__c IN :offAccId and Relationship_Type__c='Parent/Child'];

        List<Id> idList = new List<Id>();
        for(Account_Relationship__c aRel: accRelList){
            idList.add(aRel.Child_Account__c);
        }
        return getAcctsFromIds(idList);
    }
    
    /**
    * Method to add an office or agent account
    * @param Type of account
    * @param parentId under which agent/office needs to be added
    * @param brokerNum is existing number of brokers
    * @param offNum 
    * @param agnNum 
    */
    @RemoteAction
    
    public static void addAccount(String acctType, Id parentId, String brokerNum, String offNum, String agnNum){
        EmployeeDashboardController ed = new EmployeeDashboardController();
        Collection_Users__c cu = Collection_Users__c.getValues('Binder account user');
        User userDetail = EmployeeDashboardController.getloggedInUser();
        Set<MLS__c> mlsSet = new Set<MLS__c>();
        Id accB2BRecTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('B2B').RecordTypeId;
        Id accB2CRecTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('B2C').RecordTypeId;
        Id accRelRecTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Account Relationship').RecordTypeId;       
        
        List<Account> MLSAccts = new List<Account>();
        MLSAccts = [Select id from Account where Name='BINDER1' and type = 'MLS Account' and Customer_Id__c='B1CA' limit 1];
        
        
        // Create account and populate common fields for agent/office
        Account acc = new account();
        acc.isBinder__c = acc.Test__c = true;
        acc.Email_Address__c = userDetail.Email;
        acc.OwnerId = cu.id__c;
        acc.Phone = userDetail.Phone;
        
        // Relationship between accounts
        Account_Relationship__c actRel = new Account_Relationship__c();
        actRel.Relationship_Type__c = 'Parent/Child';
        actRel.Is_Parent_Primary__c = true;
        actRel.RecordTypeId = accRelRecTypeId;
        
        // MLS record
        MLS__c mls = new MLS__c();
        mls.Primary_MLS_Set__c = true;
        mls.MLS_Area_Source_Reference__c = 'B1CA';
        mls.MLS__c = MLSAccts[0].id;
        mls.status__c = 'Active';
        
        if(acctType == 'Agent'){
            
            acc.Name = userDetail.Name+'-'+userDetail.CommunityNickname+'Acc'+brokerNum+' Agent'+offNum+agnNum;
            acc.Email_Address__c = userDetail.Email.replace('@','a+'+(brokerNum+offNum+agnNum)+'@');
            acc.type = 'Realtor Agent';
            acc.RecordTypeId = accB2CRecTypeId;
            insert acc;
            
            // Rel between office and agent
            actRel.Parent_Account__c = parentId;
            actRel.Child_Account__c =  acc.id;
            insert actRel;
            
            mls.Name = 'A-B1CA-'+userDetail.CommunityNickname+'Acc'+brokerNum+'A'+offNum+agnNum;
            mls.Agent__c = acc.id;
            mls.MLS_Set_Type__c = 'Agent';
            mlsSet.add(mls);
            
        } else {
            
            acc.Name = userDetail.Name+'-'+userDetail.CommunityNickname+'Acc'+brokerNum+' Office'+offNum;
            acc.Email_Address__c = userDetail.Email.replace('@','o+'+brokerNum+offNum+'@');
            acc.type = 'Realtor Office';
            acc.RecordTypeId = accB2BRecTypeId;
            insert acc;
            
            // Rel between broker and office
            actRel.Parent_Account__c = parentId;
            actRel.Child_Account__c =  acc.id;
            insert actRel;
            
            mls.Name = 'O-B1CA-'+userDetail.CommunityNickname+'Acc'+brokerNum+'O'+offNum;
            mls.Office__c = acc.id;
            mls.MLS_Set_Type__c = 'Office';
            mlsSet.add(mls);
        }            
        
        insert mls;
        ed.updFieldsOnAcct(mlsSet);
        
    }
    
    /**
     * CRM-2972: Method to edit account details.
     */
    @RemoteAction
    public static void editAccount(Account a){
        
        update a;
    }

    /**
     * Method to get products owned by the account.
     */
    @RemoteAction
    public static List<License_Quantity__c> getProducts(List<Id> acctIdList){
        List<License_Quantity__c> licQuanList = new List<License_Quantity__c>();
        licQuanList = [Select id, Quantity__c, Product_Part_Number__c, Account__c, Account__r.type, Market__c from License_Quantity__c where Account__c IN :acctIdList];
        return licQuanList;
    }

    /**
     * Method to get account with id.
     */
    @RemoteAction
    public static List<Account> getAcctsFromIds(List<Id> idList){
        List<Account> accList = new List<Account>();
       for(Account a: [Select id, Name, MLS_Set_Id__c, Email_Address__c,Party_Id__c, Account_NAR_Id__c,ImpersonationLink__c, Advertiserid__c,
                                 Phone, Binder_account_active_till_date__c, Preferred_Phone__c, fax,WelcomeEmailURL__c,
                                 Parent.Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,Type,EssentialsStatus__c,
                                 ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, Owner.name
                                 from Account Where id IN :idList order by createdDate]){
        //CRM-3682: Check if endpoint returns data, if not then remove fields from list
        if(a.Type == 'Realtor agent' && !isImpLinkPresent(a.Advertiserid__c)){
            Map<String, Object> acctMap = new Map<String, Object>( a.getPopulatedFieldsAsMap() );
            acctMap.remove('ImpersonationLink__c');
            acctMap.remove('WelcomeEmailURL__c');
            Account a2 = (Account) JSON.deserialize( JSON.serialize( acctMap ), Account.class );
            accList.add(a2);
        } else {
            accList.add(a);
        }
        
       }
        return accList;
    }

    /**
     * CRM-3682: Method to check if data is returned by given endpoint and then populate Impersonation link 
     */
    
    public static Boolean isImpLinkPresent(String advId){
        try{
            HttpRequest req = new HttpRequest(); 
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            req.setMethod('GET');
            req.setTimeout(5000);
            Waitlist_Urls__c url = Waitlist_Urls__c.getValues('EmpDashMfarURL');
            String endPointUrl = url.URL__c;
            endPointUrl = endPointUrl + advId;
            req.setEndpoint(endPointUrl);
            res = http.send(req);
            system.debug('Response--->>'+res.getBody());
            
            Dom.Document doc = res.getBodyDocument();
            //Retrieve the root element for this document.
            Dom.XMLNode address = doc.getRootElement();
            String namespace = address.getNamespace();  
            String id = address.getChildElement('id', namespace).getText();
            if(id.contains('not present')){
                return false;
            }
        } catch(Exception e){
            return true;
        }
        
        return true;
    }

    /**
     * CRM-3230: Makes a call to EmployeeDashboardAccountDeleteJob class to delete all account and dependencies associated with the user
     */
    @RemoteAction
    public static Boolean deleteAll(Id acctId, String parentActType){
        Account a = new Account();
        a.Id = acctId;
        List<Account> accRec = new List<Account>{a};
        EmployeeDashboardAccountDeleteJob edj = new EmployeeDashboardAccountDeleteJob();
        edj.deleteAll(accRec, parentActType);
        return true;
    }
    
    
    /**
     * Method to add license quantity for the given product in fulfillment.
     */
    @RemoteAction
    public static Map<String, String> sendToFulfillment1(List<fulfillmentReq> fullReq){
        system.debug('fullReq'+fullReq);
        Map<String, fulfillmentReq> crltnIdRequestMap = new Map<String, fulfillmentReq>();
        Set<String> failCrltnIdSet = new Set<String>();
        Map<String, String> resultMap = new Map<String, String>();
        HttpRequest req = new HttpRequest(); 
        HttpResponse res = new HttpResponse();
        Date startDate = Date.today();
        Date endDate = startDate.addYears(1);
        Http http = new Http();
        req.setMethod('POST');
        // CRM-3423: Updated timeout
        req.setTimeout(120000);
        req.setHeader('Content-Type', 'application/json'); 
        req.setHeader('Accept', 'application/json'); 
        Waitlist_Urls__c wlu= Waitlist_Urls__c.getValues('SOAFulfillmentAPIForBinder');
        String endPointUrl = wlu.URL__c;
        req.setEndpoint(endPointUrl);
        String body = '{"SyncLicense": [';
        Integer i = 0;
        for(fulfillmentReq freq: fullReq){
            i++;
            crltnIdRequestMap.put(freq.co_relation_id, freq);
            if(freq.accountType == 'Realtor Agent'){
                body += '{"co_relation_id":"'+freq.co_relation_id+'","sold_to_account":{"advertiser_id":0,"party_id":"'+freq.partyId+'","account_name":"'+freq.accountName+'","account_type":"Realtor Agent"},"fulfill_to_account":{"advertiser_id":0,"party_id":"'+freq.partyId+'","account_name":"'+freq.accountName+'","account_type":"Realtor Agent"},"product_part_number":"'+freq.partNumber+'",';
                // CRM-3039: Added for Advantage product
                if(freq.partNumber == 'ADVANTAGE'){
                    body += '"product_type" : "PRO",';
                }
                //CRM-4192: Added for CFB fulfillment
                if(freq.partNumber == 'COBROKE'){
                     body += '"lead_recipient_type" : "Flex","market_name" : "'+ freq.market+'",';
                }
                body += '"action":"'+freq.action+'","start_date":"'+startDate+'","end_date":"'+endDate+'","quantity":'+freq.quantity+'}';
                System.debug('body==='+body);
            } else{
                body += '{"co_relation_id":"'+freq.co_relation_id+'","sold_to_account":{"advertiser_id":0,"party_id":"'+freq.partyId+'","account_name":"'+freq.accountName+'","account_type":"Broker"},';
                // CRM-3039: Added for Advantage product
                if(freq.partNumber == 'ADVANTAGE'){
                    List<id> bid = new List<id>();
                    bid.add(freq.accountId);
                    List<Account> ol = getOffUnderBroker(bid);
                    body += '"fulfill_to_account":[';
                    for(Account a: ol){
                        body += '{"advertiser_id":0,"party_id":"'+a.Party_Id__c+'","account_name":"'+a.Name+'","account_type":"Realtor office"},';
                    }
                    System.debug('body==='+body);
                    //body.removeEnd(',');
                    body = body.substring(0, body.length()-1);
                    body += '],"product_part_number":"'+freq.partNumber+'","product_type" : "PRO",';
                    body += '"action":"'+freq.action+'","start_date":"'+startDate+'","end_date":"'+endDate+'","quantity":'+freq.quantity+'}';
                    
                } else {
                     body += '"fulfill_to_account":{"advertiser_id":0,"party_id":"'+freq.partyId+'","account_name":"'+freq.accountName+'","account_type":"Broker"},"product_part_number":"'+freq.partNumber+'",'; 
                     if(freq.partNumber == 'COBROKE'){
                         body += '"lead_recipient_type" : "Flex","market_name" : "'+ freq.market+'",';
                     }
                     body += '"action":"'+freq.action+'","start_date":"'+startDate+'","end_date":"'+endDate+'","quantity":'+freq.quantity+'}';
    
                }
            
            }
            body += ',';
        }
        body = body.removeEnd(',');
        body += ']}';

        system.debug('Request Body--->>'+body);
        req.setBody(body);
        if(!Test.isRunningTest()){
             res = http.send(req);
        }
       
        system.debug('Response--->>'+res.getBody());
        /*Sample response structure
        {
          "LicenseResponse": [
            {
              "LicenseResponse": {
                "asset_id": null,
               ...
              },
              "LicenseResponse": {
                "asset_id": null,
                "fulfillment_status": {...
                  "status": "Failure",
                  "message": "..."
                }
                ...
              }
            }
          ]
        }
        */
        List<fulfillmentRes> responseList = new List<fulfillmentRes>();
        JSONParser parser = JSON.createParser(res.getBody());
            while (parser.nextToken() != null) {
            system.debug('stage1--'+parser.getCurrentToken());
            if(parser.getCurrentToken() == JSONToken.START_ARRAY){
                 while (parser.nextToken() != null) {
                     system.debug('stage 2---'+parser.getCurrentToken()+parser.getText());
                      if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                          while (parser.nextToken() != null) {
                               if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                                   responseList.add((fulfillmentRes)parser.readValueAs(fulfillmentRes.class));
                            }
                          }
                      }
                 }
            }
        }
        System.debug('responseList=='+responseList);
        Set<License_Quantity__c> lqInsertSet = new  Set<License_Quantity__c>();
        Set<License_Quantity__c> lqUpdateSet = new  Set<License_Quantity__c>();
        Set<License_Quantity__c> lqDeleteSet = new  Set<License_Quantity__c>();
        List<License_Quantity__c> lqList = new  List<License_Quantity__c>();
        Set<Id> acctIdSet = new Set<Id>();
        Set<String> partNumSet = new Set<String>();
        Set<String> processedCrelId = new Set<String>();
        for(fulfillmentRes fRes: responseList){
            if(fRes.fulfillment_status.status == 'fulfilled' && fRes.asset_id != null && fRes.asset_id != '' && !processedCrelId.contains(fRes.co_relation_id)){
                fulfillmentReq fr = crltnIdRequestMap.get(fRes.co_relation_id);
                if(fr.action == 'add'){
                    License_Quantity__c lc = new License_Quantity__c();
                    lc.Account__c = fr.accountId;
                    lc.Product_Part_Number__c = fr.partNumber;
                    lc.Quantity__c = fr.quantity;
                    lc.Market__c = fr.market;
                    processedCrelId.add(fRes.co_relation_id);
                    lqInsertSet.add(lc);
                } else {
                    acctIdSet.add(fr.accountId);
                    partNumSet.add(fr.partNumber);
                }
            } else {
                 failCrltnIdSet.add(fRes.co_relation_id);
            }
            resultMap.put(fRes.co_relation_id,fRes.fulfillment_status.message );
        }
        system.debug('failCrltnIdSet'+lqInsertSet+acctIdSet+partNumSet);
        if(!lqInsertSet.isEmpty()){
            lqList.addAll(lqInsertSet);
            insert lqList;
            lqList.clear();
        }
        
        If(!acctIdSet.isEmpty()){
          
            List<License_Quantity__c> lQuanList = [Select id, Quantity__c, Product_Part_Number__c, Account__c,market__c from 
                                                   License_Quantity__c where Account__c In :acctIdSet and Product_Part_Number__c In :partNumSet];
            for(fulfillmentReq frq: fullReq){
                system.debug(frq);
                if(!failCrltnIdSet.contains(frq.co_relation_id) && !processedCrelId.contains(frq.co_relation_id)){
                    processedCrelId.add(frq.co_relation_id);
                    for(License_Quantity__c lc: lQuanList){
                         system.debug(lc);
                        if(frq.action == 'amend'){
                             system.debug(lc);
                            if(lc.Account__c == frq.accountId && lc.Product_Part_Number__c == frq.partNumber && (lc.market__c == frq.market || frq.market == null || frq.market == '')){
                                 system.debug(lc);
                                License_Quantity__c lcUpd = new License_Quantity__c();
                                lcUpd.id = lc.id;
                                lcUpd.Quantity__c = frq.quantity;
                                lqUpdateSet.add(lcUpd);
                            }
                        } else if(frq.action == 'cancel'){
                            if(lc.Account__c == frq.accountId && lc.Product_Part_Number__c == frq.partNumber && (lc.market__c == frq.market || frq.market == null || frq.market == '') && lc.Quantity__c == frq.quantity){
                                lqDeleteSet.add(lc);
                            }
                        }
                    }
                }
            }
            system.debug('lqUpdateSet'+lqUpdateSet);
            if(!lqUpdateSet.isEmpty()){
                lqList.addAll(lqUpdateSet);
                update lqList;
                lqList.clear();
            }
            
            if(!lqDeleteSet.isEmpty()){
                lqList.addAll(lqDeleteSet);
                delete lqList;
            }
        }

        return resultMap;
    }
    
     public class fulfillmentReq{
        public String accountId;
        public String partyId;
        public Integer quantity;
        public String accountName;
        public String accountType;
        public String partNumber;
        public String action;
        public String market;
        public String co_relation_id;
        
    }
    
    public class fulfillmentRes{
        public String asset_id;
        public String parent_asset_id;
        public String co_relation_id;
        public fulfillmentStatus fulfillment_status;
    }
    
    public class fulfillmentStatus{
        public String message;
        public String status;
        public String status_code;
    }
   
}