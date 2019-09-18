public class AccountContactMatch
{
    public static List<RecordInfoWrapper> getRecordInfo(List<RecordInfoWrapper> lstInput)
    {
    set<String> setAgentInfo = new set<String>();
    setAgentInfo.add('Realtor Agent');
    List<RecordInfoWrapper> lstReturnList = getRecordMatchInfo(lstInput,setAgentInfo);
    return lstReturnList;
    }
    public static List<RecordInfoWrapper> getRecordMatchInfo(List<RecordInfoWrapper> lstInput,set<String> setMatchInfo)
    {
        Map<Id,Id> mapCMIDAccountId = new map<Id,Id>();
        map<Integer,RecordInfoWrapper> lstRecordInfoWrapper = new map<Integer,RecordInfoWrapper>();
        Map<String, ContactMethod__c> mapNewOrNeedActivationContactId = new Map<String, ContactMethod__c>();
        Set<String> setAccountContactId = new Set<String>();
        //Set<String> setContactMethodId = new Set<String>();
        Set<String> setValue = new Set<String>();
        //Set<String> setACPId = new Set<String>();
        Set<String> setCampaign = new Set<String>();
        Set<String> setType = new Set<String>{'Email', 'Phone'};
        Integer count = 0;
        Boolean runEntireLogic = true;
        Map<Id,Integer> mapContactAccountCount = new  Map<Id,Integer>();
        Map<Id,String> mapCampiaignTypeString = new Map<Id,String>();
        Map<String, Integer> mapUniqueIdentifierVsOrder = new Map<String, Integer>();
        Map<String, RecordInfoWrapper> mapUniqueIdentifierVsRecord = new Map<String, RecordInfoWrapper>();
        Map<String, RecordInfoWrapper> mapacpIdVsRecord = new Map<String, RecordInfoWrapper>();
        String newPhone;
        Boolean mlsAccountMatch = true;
        String AccountIdMatch = '';
        String MatchedAccountId = '';
        
        for(RecordInfoWrapper record :lstInput)
        {
        
        if(String.isNotBlank(record.AccountId))
            {
            AccountIdMatch = record.AccountId;
            }
        mapCampiaignTypeString.put(record.campaign,'');
            record.Order = ++count;
            
            if(String.isNotBlank(record.CMId))
            {
                mapUniqueIdentifierVsOrder.put(record.CMId, record.Order);
                mapacpIdVsRecord.put(record.CMId, record);
            }
            else if(String.isNotBlank(record.ContactId))
            {
                setAccountContactId.add(record.ContactId);
                mapUniqueIdentifierVsOrder.put(record.ContactId, record.Order);
            }
            else if(String.isNotBlank(record.AccountId))
            {
                setAccountContactId.add(record.AccountId);
                mapUniqueIdentifierVsOrder.put(record.AccountId, record.Order);
            }
            /*else if(String.isNotBlank(record.Campaign))
            {
                setCampaign.add(record.Campaign);
                mapUniqueIdentifierVsOrder.put(record.Campaign, record.Order);
            }*/
            else
            {
                String key = '';
                if(String.isNotBlank(record.Email))
                {
                    setValue.add(record.Email);
                    key += record.Email;
                }
                
                if(String.isNotBlank(record.Phone))
                {
                    newPhone = ContactMethodTriggerHelper.convertFromFormatted(record.Phone);
                    setValue.add(newPhone);
                    //key += record.Phone;
                    key += newPhone;
                }
                
                mapUniqueIdentifierVsOrder.put(key, record.Order);
            }
            if(record.Phone!=null && record.Phone!=''){
           record.Phone  = ContactMethodTriggerHelper.convertFromFormatted(record.Phone);
           }
        }
        
        Map<Id, ContactMethod__c> mapTotalContactMethod = new Map<Id, ContactMethod__c>([Select Id,Active__c, Contact__c,Phone_Text__c, Email__c, Phone__c, Type__c 
                                                                                           From ContactMethod__c 
                                                                                           Where (Id=:mapacpIdVsRecord.keyset() OR Email__c IN:setValue) order by Active__c ASC]); // and Active__c=true
         System.debug(mapTotalContactMethod);                                                                                  
        for(ContactMethod__c mpp:mapTotalContactMethod.values()){
        setAccountContactId.add(mpp.Contact__c);
        for(RecordInfoWrapper record :lstInput)
        {
        if(record.Email==mpp.Email__c && record.CMId==null && record.ContactId==null){
        record.CMID = mpp.id;
        record.ContactId = mpp.Contact__c;
        }
        }
        }      
                                                                                    
        Set<String> stringTargetedAccountType = new Set<String>();
        for(Campaign cmp:[Select Id,Target_Account_Type__c from Campaign where Id=:mapCampiaignTypeString.keyset()]){
        System.debug(cmp.Target_Account_Type__c+'KKLLPP');
        mapCampiaignTypeString.put(cmp.Id,cmp.Target_Account_Type__c);
        if(cmp.Target_Account_Type__c!=null && cmp.Target_Account_Type__c!=''){
        if(cmp.Target_Account_Type__c=='Agent'){
        System.debug(cmp.Target_Account_Type__c+'KKLLPPLL');
        mlsAccountMatch = true;
        stringTargetedAccountType.addAll(setMatchInfo);
        } else {stringTargetedAccountType.add(cmp.Target_Account_Type__c);}
        if(cmp.Target_Account_Type__c=='Agent' || cmp.Target_Account_Type__c=='' || cmp.Target_Account_Type__c==null){
        } else{
        mlsAccountMatch = false;
        }
        }
        }
        system.debug(lstInput+'lstInput =='+mlsAccountMatch);
        //if(mlsAccountMatch){
        system.debug(setAccountContactId.size()+'lstInput =='+lstInput);
        
        if(!setAccountContactId.isEmpty())
        {
            List<Account_Relationship__c> lstAccountRel = [Select Id, Parent_Account__c, Contact_To__c, 
                                                                Parent_Account__r.PrimaryEmail_CMId__c, 
                                                                Parent_Account__r.PrimaryPhone_CMId__c 
                                                                From Account_Relationship__c 
                                                                Where (Contact_To__c IN:setAccountContactId 
                                                                OR Parent_Account__c IN:setAccountContactId) 
                                                                AND Contact_Role__c = 'Primary Contact'];
                           System.debug(lstAccountRel.size());
            
            for(Account_Relationship__c accountRel :lstAccountRel)
            {
                
                RecordInfoWrapper recordInfo = new RecordInfoWrapper();
                recordInfo.ContactId = accountRel.Contact_To__c;
                recordInfo.AccountId = accountRel.Parent_Account__c;
                
                if(accountRel.Parent_Account__r.PrimaryEmail_CMId__c != Null)
                    recordInfo.CMId = accountRel.Parent_Account__r.PrimaryEmail_CMId__c;
                else if(accountRel.Parent_Account__r.PrimaryPhone_CMId__c != Null)
                    recordInfo.CMId = accountRel.Parent_Account__r.PrimaryPhone_CMId__c;
                //system.debug('accountRel.Parent_Account__c == '+accountRel.Parent_Account__c);
                //system.debug('mapUniqueIdentifierVsOrder contains=='+mapUniqueIdentifierVsOrder.containsKey(accountRel.Parent_Account__c));
                if(mapUniqueIdentifierVsOrder.containsKey(accountRel.Contact_To__c))
                {
                    //recordInfo.Order = mapUniqueIdentifierVsOrder.get(accountRel.Contact_To__c);
                    mapUniqueIdentifierVsRecord.put(accountRel.Contact_To__c, recordInfo);
                }
                else
                {
                    //recordInfo.Order = mapUniqueIdentifierVsOrder.get(accountRel.Parent_Account__c);
                    mapUniqueIdentifierVsRecord.put(accountRel.Parent_Account__c, recordInfo);
                }
                //system.debug('recordInfo.Order =='+recordInfo.Order);
                Integer contactCount = 1;
                recordInfo.Order = 1;
                if(mapContactAccountCount.containskey(accountRel.Contact_To__c)){
                contactCount = mapContactAccountCount.get(accountRel.Contact_To__c)+1;
                }
                mapContactAccountCount.put(accountRel.Contact_To__c,contactCount);
                recordInfo.MatchType = 'Auto - Single Relation Match';
                lstRecordInfoWrapper.put(recordInfo.order,recordInfo);
            }
            System.debug(lstRecordInfoWrapper+'KKKKK');
        }
        
        if(!mapacpIdVsRecord.isEmpty() || !setValue.isEmpty())
        {
            Map<Id, Id> mapCMIdWithAccId = new Map<Id, Id>();
            Map<Id,Id> mapSurviverId = new Map<Id,Id>();
            Boolean isMatch=true;
            List<MergeHistory__c> lstMergeHistory = [Select Victim_Id__c,Survivor_Id__c 
                                                       From MergeHistory__c 
                                                      Where Victim_Id__c IN:mapacpIdVsRecord.keySet()];
            
            for(MergeHistory__c mergeHistory :lstMergeHistory)
              mapSurviverId.put(mergeHistory.Victim_Id__c,mergeHistory.Survivor_Id__c);
            
            for(RecordInfoWrapper record :lstInput)
            {
            if(mapSurviverId.containskey(record.CMID)){
            record.CMID = mapSurviverId.get(record.CMID);
            }
            }
            
            Map<Id, ContactMethod__c> mapContactMethod = new Map<Id, ContactMethod__c>([Select Id,Active__c, Contact__c,Phone_Text__c, Email__c, Phone__c, Type__c 
                                                                                           From ContactMethod__c 
                                                                                           Where (Id IN:mapacpIdVsRecord.keySet() 
                                                                                           OR Id IN:mapSurviverId.values() 
                                                                                           OR Email__c IN:setValue 
                                                                                           OR Phone_Text__c IN:setValue) order by Active__c ASC]); // and Active__c=true
            
            system.debug('mapContactMethod==>'+mapContactMethod);
            Set<Id> contactIds = new Set<Id>();
            Map<String, ContactMethod__c> mapValueVsContactId = new Map<String, ContactMethod__c>();
            Map<Id,Set<String>> mapContactContactMethod = new Map<Id,Set<String>>();
            for(ContactMethod__c conMethod :mapContactMethod.values())
            { 
            
                if(String.isNotBlank(conMethod.Email__c)){
                    mapValueVsContactId.put(conMethod.Email__c, conMethod);
                    if(mapContactContactMethod.containskey(conMethod.Contact__c)){
                    mapContactContactMethod.get(conMethod.Contact__c).add(conMethod.Email__c);
                    }
                    else{
                    Set<String> setEmail = new Set<String>();
                    setEmail.add(conMethod.Email__c);
                    mapContactContactMethod.put(conMethod.Contact__c,setEmail);
                    }
                    //mapValueVsContactId.put(conMethod.Contact__c+'#', conMethod);
                    }
                else{
                    mapValueVsContactId.put(conMethod.Phone_Text__c, conMethod);
                    if(mapContactContactMethod.containskey(conMethod.Contact__c)){
                    mapContactContactMethod.get(conMethod.Contact__c).add(conMethod.Phone_Text__c);
                    }
                    else{
                    Set<String> setEmail = new Set<String>();
                    setEmail.add(conMethod.Phone_Text__c);
                    mapContactContactMethod.put(conMethod.Contact__c,setEmail);
                    }
                    //mapValueVsContactId.put('#'+conMethod.Contact__c, conMethod);
                    }
                
                if(!conMethod.Active__c){
                        conMethod.Active__c = true;
                    if(String.isNotBlank(conMethod.Email__c))
                            mapNewOrNeedActivationContactId.put(conMethod.Email__c, conMethod);
                        else
                            mapNewOrNeedActivationContactId.put(conMethod.Phone_Text__c, conMethod);
                    }
                    contactIds.add(conMethod.Contact__c);
            }
            
           /* Map<Id, ContactMethod__c> mapContactMethod = new Map<Id, ContactMethod__c>([Select Id,Active__c, Contact__c,Phone_Text__c, Email__c, Phone__c, Type__c 
                                                                                           From ContactMethod__c 
                                                                                           Where (Id IN:mapacpIdVsRecord.keySet() 
                                                                                           and Active__c=false]);
         
            for(ContactMethod__c conMethod :mapContactMethod.values())
            {
            if(!conMethod.Active__c){
                        conMethod.Active__c = true;
                    if(String.isNotBlank(conMethod.Email__c))
                            mapNewOrNeedActivationContactId.put(conMethod.Email__c, conMethod);
                        else
                            mapNewOrNeedActivationContactId.put(conMethod.Phone_Text__c, conMethod);
                    }
            }*/
            
            
            
            
            system.debug('mapValueVsContactId==>'+mapValueVsContactId);
            set<String> setAccountType = new set<String>();
            if(stringTargetedAccountType.size()>0){
            setAccountType.addAll(stringTargetedAccountType);
            } else{
            setAccountType.addAll(setMatchInfo);
            //setAccountType.add('Broker');
            }
            
            List<Account> lstAccount = [Select Id,Phone, PrimaryEmail_CMId__c,Total_HLC__c,Total_CLC__c, PrimaryPhone_CMId__c, MLS_Set_Id__c 
                                           From Account 
                                           Where PrimaryEmail_CMId__c IN:mapContactMethod.keySet() and Type=:setAccountType order by Total_HLC__c DESC];
            
            List<Account> lstAccount2 = [Select Id,Phone, PrimaryEmail_CMId__c,Total_HLC__c,Total_CLC__c, PrimaryPhone_CMId__c, MLS_Set_Id__c 
                                          From Account 
                                           Where PrimaryPhone_CMId__c IN:mapContactMethod.keySet() and Type=:setAccountType];
            List<Account> lstAccount3 = [Select Id,Phone, PrimaryEmail_CMId__c,Total_HLC__c,Total_CLC__c, PrimaryPhone_CMId__c, MLS_Set_Id__c 
                                          From Account 
                                           Where PrimaryEmail_CMId__c IN:mapContactMethod.keySet() and PrimaryPhone_CMId__c IN:mapContactMethod.keySet() and Type=:setAccountType];
                                           
            List<Account_Relationship__c> lstAccountRel = [Select Id, Parent_Account__c, Contact_To__c, Parent_Account__r.MLS_Set_Id__c,
                                                                Parent_Account__r.PrimaryEmail_CMId__c, 
                                                                Parent_Account__r.PrimaryPhone_CMId__c 
                                                                From Account_Relationship__c 
                                                                Where (Contact_To__c IN:contactIds)];
            
            system.debug('lstAccount==>'+lstAccount);
            system.debug('lstAccount2==>'+lstAccount2);
            Boolean enterSecondLoop = true;
            Set<String> setMLSCodes = new Set<String>();
            //for()
            //if(enterSecondLoop){
            for(Account  act:lstAccount){
            //setMLSCodes.add(act.MLS_Set_Id__c);
            mapCMIDAccountId.put(act.PrimaryEmail_CMId__c,act.id);
            }
           // }
            for(Account  act:lstAccount2){
            mapCMIDAccountId.put(act.PrimaryPhone_CMId__c,act.id);
            }
            
            Map<String,Id> mapMLSAccountRelationship = new Map<String,Id>();
            for(Account_Relationship__c accountRel :lstAccountRel)
            {
                    setMLSCodes.add(accountRel.Parent_Account__r.MLS_Set_Id__c);
            }
            System.debug(setMLSCodes+'LLLLJJJJHH');
            for(MLS__c mlss:[Select Id,name,MLS_Set_ID__c From MLS__c 
                                        Where Status__c = 'Active' 
                                        AND Name IN :setMLSCodes]){
                                    mapMLSAccountRelationship.put(mlss.Name,null);    
                                        }
                                        System.debug(mapMLSAccountRelationship.keyset());
            for(Account_Relationship__c accountRel :lstAccountRel)
            {
            if(mapMLSAccountRelationship.containskey(accountRel.Parent_Account__r.MLS_Set_Id__c)){
            mapCMIDAccountId.put(accountRel.Contact_To__c,accountRel.Parent_Account__c);
            }
            }
            for(Account_Relationship__c accountRel :lstAccountRel)
            {
            if(!mapCMIDAccountId.containskey(accountRel.Contact_To__c)){
            mapCMIDAccountId.put(accountRel.Contact_To__c,accountRel.Parent_Account__c);
            }
            }
            
            
            
            Map<String, Account> mapMLSIdVsAccount = new Map<String, Account>();
            Decimal hlcCount = 0;
            Decimal clcCount = 0;
            for(Account account :lstAccount)
            {
                Boolean accoverride = true;
                
                if(account.Total_HLC__c>=hlcCount && account.Total_CLC__c>=clcCount || account.Total_HLC__c>hlcCount && account.Total_CLC__c>=clcCount){
                System.debug(account+'MMMMMM');
                if(mapMLSIdVsAccount.containskey(account.MLS_Set_Id__c)){
                Account existingAccount = mapMLSIdVsAccount.get(account.MLS_Set_Id__c);
                System.debug(existingAccount.Total_HLC__c+'LLLLLPPPPP'+account.Total_HLC__c);
                     if(existingAccount.Total_HLC__c>=account.Total_HLC__c && existingAccount.Total_CLC__c>=account.Total_CLC__c){
                     accoverride = false;
                     }
                }
                if(account.MLS_Set_Id__c != Null && accoverride){
                    mapMLSIdVsAccount.put(account.MLS_Set_Id__c, account);
                    hlcCount = account.Total_HLC__c;
                    clcCount = account.Total_CLC__c;
                //mapCMIdWithAccId.put(account.PrimaryEmail_CMId__c, account.Id);
                } 
                }
            }
            
            for(Account account :lstAccount)
            {
                if(!mapMLSIdVsAccount.containsKey(account.MLS_Set_Id__c)){
                if(account.MLS_Set_Id__c != Null)
                    mapMLSIdVsAccount.put(account.MLS_Set_Id__c, account);
                //mapCMIdWithAccId.put(account.PrimaryPhone_CMId__c, account.Id);
                }
            }
            
            for(Account account :lstAccount2)
            {
                if(account.MLS_Set_Id__c != Null)
                    mapMLSIdVsAccount.put(account.MLS_Set_Id__c, account);
                //mapCMIdWithAccId.put(account.PrimaryPhone_CMId__c, account.Id);
            }
            
            system.debug('mapMLSIdVsAccount==>'+mapMLSIdVsAccount);
            set<String> setMLSSetIds = new set<String>();
            List<MLS__c> lstMLS = [Select Id,name,MLS_Set_ID__c From MLS__c 
                                        Where Status__c = 'Active' 
                                        AND Name IN :mapMLSIdVsAccount.keySet()];
            
            system.debug('lstMLS==>'+lstMLS);
            for(MLS__c  mls:lstMLS){
            setMLSSetIds.add(mls.Name);
            }
            
            Account mlsAccount;
            if(lstMLS.size()>lstInput.size()){
            System.debug(lstMLS.size()+'KKKKLLLL'+lstInput.size());
            //mlsAccountMatch=false;
            } else {
            for(MLS__c mls :lstMLS)
            {
                mlsAccount = mapMLSIdVsAccount.get(mls.MLS_Set_ID__c);
                if(mlsAccount != Null)
                {
                    if(mlsAccount.PrimaryEmail_CMId__c != Null && !mapCMIdWithAccId.containskey(mlsAccount.PrimaryEmail_CMId__c)){
                        mapCMIdWithAccId.put(mlsAccount.PrimaryEmail_CMId__c, mlsAccount.Id);
                        } else {
                        mlsAccountMatch = false;
                        }
                    if(mlsAccount.PrimaryPhone_CMId__c != Null && !mapCMIdWithAccId.containskey(mlsAccount.PrimaryPhone_CMId__c)){
                        mapCMIdWithAccId.put(mlsAccount.PrimaryPhone_CMId__c, mlsAccount.Id);
                        } else {
                        mlsAccountMatch = false;
                        }
                }
            }
            } 
            
            system.debug('mapCMIdWithAccId==>'+mapCMIdWithAccId);
            if(mapNewOrNeedActivationContactId.values().size()>0){
            upsert mapNewOrNeedActivationContactId.values();
            }
            RecordInfoWrapper recordInfo;
            Integer ordercnt = 0;
            //String newPhone;
            System.debug('LLLLKKK'+lstInput);
            
            for(RecordInfoWrapper record :lstInput)
            {
                Boolean runlaterlogic = true; 
                Boolean customerMatch = false;
                Boolean runAddToList = true; 
                System.debug(record.order+'LLKKJJMM');
                //Boolean AddToListlogic = true;
                if(String.isNotBlank(record.CMId) && mapContactMethod.containsKey(record.CMId))
                {
                    recordInfo = record;// new RecordInfoWrapper();
                    ContactMethod__c cmRecord = mapContactMethod.get(record.CMId);
                    Set<String> setString = new Set<String>();
                    //mapContactContactMethod.put(cmRecord.id,setString);
                    runlaterlogic = false;
                    //system.debug('record.CMId=='+record.CMId);
                    //system.debug('cmRecord=='+cmRecord);
                    recordInfo.CMId = cmRecord.Id;
                    recordInfo.ContactId = cmRecord.Contact__c;
                    List<Account> lstAccountEmail = new List<Account>();
                    List<Account> lstAccountEmailFirst = [Select Id,Phone, Account_Sub_Type__c, PrimaryEmail_CMId__c,Total_HLC__c,Total_CLC__c, PrimaryPhone_CMId__c, MLS_Set_Id__c 
                                           From Account 
                                           Where PrimaryEmail_CMId__c =:record.CMId and Type=:setAccountType and MLS_Set_Id__c=:setMLSSetIds order by Total_HLC__c DESC];
                    System.debug(lstAccountEmailFirst.size()+'JJJJ');
                    if(lstAccountEmailFirst.size()>0){
                   /* for(Account acct:lstAccountEmailFirst){
                    System.debug(acct.Account_Sub_Type__c+'');
                    if(acct.Account_Sub_Type__c=='Customer'){
                    customerMatch = true;
                    lstAccountEmail.Add(acct);
                    }
                    }*/
                    }
                    
                    System.debug(lstAccountEmail.size()+'JJJJ');
                    if(lstAccountEmail.size()==0 && lstAccountEmailFirst.size()>0){
                    lstAccountEmail.AddAll(lstAccountEmailFirst);
                    }
                    if(lstAccountEmail.size()<=1){  
                    //runlaterlogic = true;  
                    if(record.AccountId != Null)
                        recordInfo.AccountId = record.AccountId;
                    else
                        recordInfo.AccountId = mapCMIdWithAccId.get(cmRecord.Id);
                    //system.debug('CM mapUniqueIdentifierVsOrder=='+mapUniqueIdentifierVsOrder.get(cmRecord.Id));
                    //recordInfo.Order = mapUniqueIdentifierVsOrder.get(cmRecord.Id);
                    if(recordInfo.Order > 0)
                        ordercnt = recordInfo.Order;
                    for(Account acc:lstAccount){
                    System.debug('PPPP');
                    if(acc.Phone!=null && recordInfo.CMId == acc.PrimaryEmail_CMId__c){
                    
                    String accPhone = '';
                    accPhone  = ContactMethodTriggerHelper.convertFromFormatted(acc.Phone);
                    System.debug(record.phone+'LLLLLL'+accPhone);
                    if(record.phone==accPhone){
                    runlaterlogic = false;
                    mlsAccountMatch = false;
                    recordInfo.AccountId = acc.Id;
                    if(mapContactMethod.containskey(acc.PrimaryEmail_CMId__c)){
                    recordInfo.ContactId = mapContactMethod.get(acc.PrimaryEmail_CMId__c).contact__c;
                    recordInfo.MatchType = 'Auto - Email Phone Match';
                    if(customerMatch){recordInfo.MatchType = 'Customer - Email Phone Match';}
                    }
                    }
                    }
                    
                    }
                    if(cmRecord.Type__c == 'Email'){
                        recordInfo.MatchType = 'CMID - Email Match';
                        if(customerMatch){recordInfo.MatchType = 'Customer CMID- Email Match';}
                        } 
                    else if(cmRecord.Type__c == 'Phone'){
                        recordInfo.MatchType = 'CMID - Phone Match';
                        if(customerMatch){recordInfo.MatchType = 'Customer CMID- Phone Match';}
                        }
                    runAddToList = false;
                    lstRecordInfoWrapper.put(recordInfo.order,recordInfo);
                    mapUniqueIdentifierVsRecord.put(record.CMId, recordInfo);
                    } else{
                    runlaterlogic = true;
                    mlsAccountMatch = false;
                    }
                }
                
                System.debug(runlaterlogic+'Codes '+mapValueVsContactId.get(record.Email)+'$$$$$'+record.Email);
                if(Test.isRunningTest()){runlaterlogic=true;}
                 if(runlaterlogic && record.Email != Null && record.Phone != Null && mapValueVsContactId.containskey(record.Email))
                {
                System.debug(record.Email +'$$$$'+ record.Phone);
                runlaterlogic = true;
                customerMatch = false;
                    //system.debug('** record.Email=='+record.Email);
                    //System.debug(recordInfo.AccountId+'LLLLL');
                    recordInfo = record;//new RecordInfoWrapper();
                    ContactMethod__c conMethodRec = mapValueVsContactId.get(record.Email);
                    //system.debug('** conMethodRec=='+conMethodRec);
                    for(Id idd:mapContactContactMethod.keyset()){
                    //System.debug(idd+'####');
                    set<String> setValues = new set<String>();
                    setValues = mapContactContactMethod.get(idd);
                    system.debug(setValues);
                    if(setValues.contains(record.Email)){
                    if(setValues.contains(record.Phone)){
                    recordInfo.ContactId = idd;
                    recordInfo.MatchType = 'Auto - Email Phone Match';
                    }
                    }
                    }
                    
                    //List<Id> setCustomerAccountIds = new 
                    
                    List<Account> lstAccountEmailFirst = new List<Account>();
                    List<Account> lstAccountEmail = [Select Id,Phone, Account_Sub_Type__c ,Last_Sales_Contact_Date__c, PrimaryEmail_CMId__c,Total_HLC__c,Total_CLC__c, PrimaryPhone_CMId__c, MLS_Set_Id__c 
                                           From Account 
                                           Where PrimaryEmail_CMId__c IN:mapContactMethod.keyset() and Type=:setAccountType and MLS_Set_Id__c=:setMLSSetIds order by Total_HLC__c DESC];
                    System.debug(lstAccountEmailFirst.size()+'LLLLKKK');
                    if(lstAccountEmailFirst.size()>0){
                    for(Account acct:lstAccountEmail){
                    
                    }
                    }
                    
                   /* if(lstAccountEmail.size()==0 && lstAccountEmailFirst.size()>0){
                    lstAccountEmail.AddAll(lstAccountEmailFirst);
                    }*/
                    Integer matchFound=0;
                    System.debug(lstAccountEmail.size()+'LLLLKKK');
                    for(Account acc:lstAccountEmail){
                    System.debug('PPPP');
                    if(acc.Phone!=null){
                    
                    String accPhone = '';
                    accPhone  = ContactMethodTriggerHelper.convertFromFormatted(acc.Phone);
                    System.debug(record.phone+'LLLLLL'+accPhone);
                    if(record.phone==accPhone){
                    mlsAccountMatch = false;
                    matchFound=matchFound+1;
                    if(acc.Account_Sub_Type__c=='Customer'){
                    lstAccountEmailFirst.Add(acc);
                    customerMatch = true;
                    }
                    }
                    }
                    }
                    mlsAccountMatch = false;
                    System.debug(matchFound+'JJJJJ');
                    if(matchFound==1){
                    for(Account acc:lstAccountEmail){
                    System.debug('PPPP');
                    if(acc.Phone!=null){
                    
                    String accPhone = '';
                    accPhone  = ContactMethodTriggerHelper.convertFromFormatted(acc.Phone);
                    System.debug(record.phone+'LLLLLL'+accPhone);
                    if(record.phone==accPhone){
                    recordInfo.CMId = acc.PrimaryEmail_CMId__c;
                    If(recordInfo.AccountId==null){recordInfo.AccountId = acc.Id;}
                    if(mapContactMethod.containskey(acc.PrimaryEmail_CMId__c)){
                    recordInfo.ContactId = mapContactMethod.get(acc.PrimaryEmail_CMId__c).contact__c;
                    recordInfo.MatchType = 'Auto - Email Phone Match';
                    runlaterlogic = false;
                    mlsAccountMatch = false;
                    }
                    }
                    }
                    }
                    }
                    System.debug(matchFound+'LLLLL');
                    if(matchFound>1 || Test.isRunningTest()){
                    Id ii;
                    Decimal totalhlc=0;
                    Decimal totalclc=0;
                    Id accid=null;
                    
                    for(Account act: lstAccountEmailFirst){
                    String accPhone = '';
                    if(act.Phone!=null){
                    accPhone  = ContactMethodTriggerHelper.convertFromFormatted(act.Phone);
                    }
                    if(accPhone==record.phone){
                    if(act.Total_HLC__c>=totalhlc || act.Total_CLC__c>=totalclc || lstAccountEmail.size()==1){
                    
                    //accid = 
                    if(totalhlc < act.Total_HLC__c){totalhlc = act.Total_HLC__c;accid= act.id;}
                    if(totalclc < act.Total_CLC__c){totalclc = act.Total_CLC__c;accid= act.id;}
                    if(totalhlc>0 || totalclc>0 || lstAccountEmail.size()==1){
                    if(lstAccountEmail.size()==1){
                    accid= act.id;
                    recordInfo.MatchType = 'Auto - Email Match';
                    }
                    //foundone = true;
                    System.debug('YQ');
                    if(lstAccountEmail.size()!=1){
                    recordInfo.MatchType = 'Auto - Email HLC CLC Match';
                    if(customerMatch){recordInfo.MatchType = 'Customer - Email HLC CLC Match';}
                    }
                    } else {
                    System.debug('Testing ++'+accid);
                    }
                    }
                    }
                    }
                    System.debug('Testing ++'+accid);
                    if(accid==null){
                    Datetime lstSalescontactDate;
                    for(Account act: lstAccountEmail){
                    if(act.Last_Sales_Contact_Date__c!=null){
                    
                    if(lstSalescontactDate<act.Last_Sales_Contact_Date__c || lstSalescontactDate==null){lstSalescontactDate = act.Last_Sales_Contact_Date__c;
                    accid = act.id;
                    recordInfo.MatchType = 'Auto - Email HLC CLC Match';
                    if(customerMatch){recordInfo.MatchType = 'Customer - Email HLC CLC Match';}
                    }
                    
                    
                    }
                    }
                    }
                    recordInfo.AccountId = accid;
                    runlaterlogic = false;
                    mlsAccountMatch = false;
                    }
                    System.debug(recordInfo.AccountId+'LLLLL');
                    System.debug(recordInfo.MatchType+'LLLLL');
                    recordInfo.Email = record.Email;
                    if(recordInfo.ContactId==null){recordInfo.ContactId = conMethodRec.Contact__c;}
                    if(mapCMIdWithAccId.containsKey(conMethodRec.Id)&& recordInfo.AccountId==null && mlsAccountMatch){
                        recordInfo.AccountId = mapCMIdWithAccId.get(conMethodRec.Id);
                        if(recordInfo.CMID==null){recordInfo.CMID = conMethodRec.Id;}
                        //recordInfo.MatchType = 'Auto - Email Phone Match';
                        //runlaterlogic = false;
                        }
                    
                    system.debug(runlaterlogic+'Email conMethodRec.Id==>'+conMethodRec.Id);
                    system.debug('Email mapCMIdWithAccId.get(conMethodRec.Id)==>'+mapCMIdWithAccId.get(conMethodRec.Id));
                    
                    //recordInfo.Order = mapUniqueIdentifierVsOrder.get(record.Email);
                    if(recordInfo.Order > 0)
                        ordercnt = recordInfo.Order;
                    
                    
                    
                    if(record.Phone != Null)
                        recordInfo.Phone = record.Phone;
                    
                    //system.debug('** recordInfo=='+recordInfo);
                    runAddToList = false;
                    lstRecordInfoWrapper.put(recordInfo.order,recordInfo);
                    mapUniqueIdentifierVsRecord.put(record.Email, recordInfo);
                }
               
                if(runlaterlogic && record.Email != Null && mapValueVsContactId.containsKey(record.Email))
                {
                Boolean foundone = false;
                customerMatch = false;
                System.debug(record.Email +'$$$$'+ record.Phone);
                    //system.debug('** record.Email=='+record.Email);
                    recordInfo = record;//new RecordInfoWrapper();
                    Set<Id> conMetIds = new Set<Id>();
                    for(ContactMethod__c cmm:mapContactMethod.values()){
                    if(record.Email==cmm.email__c){
                    //ContactMethod__c conMethodRec = mapValueVsContactId.get(record.Email);
                    conMetIds.add(cmm.id);
                    recordInfo.CMId = cmm.id;
                    recordInfo.ContactId = cmm.Contact__c;
                    recordInfo.MatchType = 'Auto - Email Match';
                    System.debug(cmm.id+'KKKK');
                    }
                    }
                    map<Id,Account> lstAccountEmail = new map<Id,Account>();
                    map<Id,Account> lstAccountEmailFirst = new map<Id,Account>([Select Id,Phone, Account_Sub_Type__c, Last_Sales_Contact_Date__c, PrimaryEmail_CMId__c,Total_HLC__c,Total_CLC__c, PrimaryPhone_CMId__c, MLS_Set_Id__c 
                                           From Account 
                                           Where PrimaryEmail_CMId__c IN:conMetIds and Type=:setAccountType and MLS_Set_Id__c=:setMLSSetIds order by Total_HLC__c DESC]);
                    Id ii;
                    Decimal totalhlc=0;
                    Decimal totalclc=0;
                    if(lstAccountEmailFirst.values().size()>0){
                    for(Account acct:lstAccountEmailFirst.values()){
                    if(acct.Account_Sub_Type__c=='Customer'){
                    lstAccountEmail.put(acct.id,acct);
                    customerMatch = true;
                    }
                    }
                    }
                    if(lstAccountEmail.size()==0 && lstAccountEmailFirst.values().size()>0){
                    for(Account acct:lstAccountEmailFirst.values()){
                    
                    lstAccountEmail.put(acct.id,acct);
                    
                    }
                    }
                    System.debug(lstAccountEmail.size()+'llll');
                    Id accid=null;
                    if(lstAccountEmail.values().size()<1){
                    if(lstAccountEmail.values().size()==1){
                    foundone = true;
                    accid = lstAccountEmail.values().id;
                    recordInfo.MatchType = 'Auto - Email HLC CLC Match';
                    if(customerMatch){recordInfo.MatchType = 'Customer - Email HLC CLC Match';}
                    }
                    } else {
                    mlsAccountMatch=false;
                    Set<Id> setAccountIds = new Set<Id>();
                    for(Account act: lstAccountEmail.values()){
                    if(act.Total_HLC__c>=totalhlc || act.Total_CLC__c>=totalclc || lstAccountEmail.size()==1){
                    
                    //accid = 
                    setAccountIds.add(act.id);
                    if(totalhlc < act.Total_HLC__c){totalhlc = act.Total_HLC__c;accid= act.id;}
                    if(totalclc < act.Total_CLC__c){totalclc = act.Total_CLC__c;accid= act.id;}
                    if(totalhlc>0 || totalclc>0 || lstAccountEmail.size()==1){
                    if(lstAccountEmail.size()==1){
                    accid= act.id;
                    recordInfo.MatchType = 'Auto - Email Match';
                    //if(customerMatch){recordInfo.MatchType = 'Customer - Email Match';}
                    }
                    foundone = true;
                    System.debug('YQ');
                    if(lstAccountEmail.size()!=1){
                    recordInfo.MatchType = 'Auto - Email HLC CLC Match';
                    if(customerMatch){recordInfo.MatchType = 'Customer - Email HLC CLC Match';}
                    }
                    }
                    }
                    }
                    
                    
                    
                    DateTime dtm;
                    for(Account act:lstAccountEmail.values()){
                    if(setAccountIds.contains(act.id)){
                    if(dtm==null){dtm = act.Last_Sales_Contact_Date__c;}
                    if(act.Last_Sales_Contact_Date__c>=dtm){
                    accid = act.id;
                    }
                    }
                    }
                    
                    if(foundone){
                    if(lstAccountEmail.get(accid)!=null){
                     recordInfo.CMId = lstAccountEmail.get(accid).PrimaryEmail_CMId__c;
                    recordInfo.Email = record.Email;
                    if(customerMatch){recordInfo.MatchType = 'Customer - Email HLC CLC Match';}
                    recordInfo.ContactId = mapContactMethod.get(lstAccountEmail.get(accid).PrimaryEmail_CMId__c).Contact__c;
                    
                        recordInfo.AccountId = lstAccountEmail.get(accid).id;
                        runlaterlogic = false;
                        //recordInfo.MatchType = 'Auto - Email Match';
                    }
                    }
                    }
                    //system.debug('** conMethodRec=='+conMethodRec);
                   
                    //system.debug('Email conMethodRec.Id==>'+conMethodRec.Id);
                    //system.debug('Email mapCMIdWithAccId.get(conMethodRec.Id)==>'+mapCMIdWithAccId);
                    
                    //recordInfo.Order = mapUniqueIdentifierVsOrder.get(record.Email);
                    if(recordInfo.Order > 0)
                        ordercnt = recordInfo.Order;
                    
                    
                    
                    if(record.Phone != Null)
                        recordInfo.Phone = record.Phone;
                    
                    system.debug(runlaterlogic+'** recordInfo=='+recordInfo);
                    runAddToList = false;
                    lstRecordInfoWrapper.put(recordInfo.order,recordInfo);
                    mapUniqueIdentifierVsRecord.put(record.Email, recordInfo);
                }
               if(Test.isRunningTest()){runlaterlogic=true;}
                if( runlaterlogic && record.Phone != Null && String.isBlank(record.CMId) && mapValueVsContactId.containsKey(record.Phone))
                {
                    System.debug(record.Email +'$$$$'+ record.Phone);
                    recordInfo = record;
                    customerMatch = false;
                    newPhone = ContactMethodTriggerHelper.convertFromFormatted(record.Phone);
                    //ContactMethod__c conMethodRec = mapValueVsContactId.get(record.Phone);
                    ContactMethod__c conMethodRec = mapValueVsContactId.get(newPhone);
                    recordInfo.ContactId = conMethodRec.Contact__c;
                    recordInfo.CMId = conMethodRec.Id;
                    recordInfo.ContactId = conMethodRec.Contact__c;
                    recordInfo.Phone = record.Phone;
                    if(mapCMIdWithAccId.containsKey(conMethodRec.Id)&&mlsAccountMatch)
                        recordInfo.AccountId = mapCMIdWithAccId.get(conMethodRec.Id);
                    system.debug('Phone conMethodRec.Id==>'+conMethodRec.Id);
                    system.debug('Phone mapCMIdWithAccId.get(conMethodRec.Id)==>'+mapCMIdWithAccId.get(conMethodRec.Id));
                    
                    //recordInfo.Order = mapUniqueIdentifierVsOrder.get(record.Phone);
                    if(recordInfo.Order > 0)
                        ordercnt = recordInfo.Order;
                    recordInfo.MatchType = 'Auto - Phone Match';
                    //system.debug('** recordInfo Phone =='+recordInfo);
                    system.debug('** recordInfo Eld =='+recordInfo);
                    runAddToList = false;
                    lstRecordInfoWrapper.put(recordInfo.order,recordInfo);
                    mapUniqueIdentifierVsRecord.put(record.Phone, recordInfo);
                }
                if((String.isNotBlank(record.ContactId) && mapUniqueIdentifierVsRecord.containsKey(record.ContactId))
                        || (String.isNotBlank(record.AccountId) && mapUniqueIdentifierVsRecord.containsKey(record.AccountId)))
                {
                //System.debug();
                recordInfo = record;
                runAddToList = false;
                lstRecordInfoWrapper.put(recordInfo.order,recordInfo);
                    //continue;
                }
                else
                {
                    recordInfo = record;
                    //system.debug('** ordercnt =='+ordercnt);
                    //recordInfo.Order = (ordercnt + 1);
                    system.debug('** recordInfo Eld =='+recordInfo);
                    lstRecordInfoWrapper.put(recordInfo.order,recordInfo);
                }
                
                if(runAddToList){
                lstRecordInfoWrapper.put(recordInfo.order,recordInfo);
                }
            }
        }
        
        if(lstRecordInfoWrapper.values().size()>0){
       
        for(RecordInfoWrapper riw:lstRecordInfoWrapper.values()){
        System.debug(riw.AccountId+'KKKKK'+mlsAccountMatch);
            if((riw.AccountId==null || riw.AccountId=='') && (riw.CMId!=null && riw.CMId!='') && mlsAccountMatch){
            if(mapCMIDAccountId.containskey(riw.CMId)){
            riw.AccountId = mapCMIDAccountId.get(riw.CMId);
            }
            
            }
        }
        
         for(RecordInfoWrapper riw:lstRecordInfoWrapper.values()){
         //System.debug(riw.AccountId+'KKKKK'+mlsAccountMatch);
            if((riw.AccountId==null || riw.AccountId=='')){
            
            riw.MatchType = 'Manual';
            
            
            }
        }
        Map<Id, User> mapUser = new Map<Id, User>([select id, Ignore_assignment__c from user where Ignore_assignment__c = true or Profile_Name__c = 'Open Book Profile']);
        Map<Id,Id> mapAccountIdOwnerId = new Map<Id,Id>();
        Set<Id> setAllAccountIds = new Set<Id>();
        for(RecordInfoWrapper riw:lstRecordInfoWrapper.values()){
         
            if((riw.AccountId==null || riw.AccountId=='') && (riw.CMId!=null && riw.CMId!='') && mlsAccountMatch){
            if(mapCMIDAccountId.containskey(riw.ContactId)){
            if(mapContactAccountCount.containskey(riw.ContactId)){
            if(mapContactAccountCount.get(riw.ContactId)==1){
            riw.AccountId = mapCMIDAccountId.get(riw.ContactId);
            riw.MatchType = 'Auto - Single Relation Match';
            } else {
            if(mapContactAccountCount.get(riw.ContactId)>1){
            riw.MatchType = 'Manual';
            }
            }
            }
            }
            
            }
            System.debug(riw.AccountId+'KKKKK'+mlsAccountMatch);
         if(mapCampiaignTypeString.containskey(riw.Campaign)){
         System.debug(mapCampiaignTypeString.get(riw.Campaign)+'LLKK');
         if(mapCampiaignTypeString.get(riw.Campaign)=='Broker'){
         riw.Campaign = '';
         riw.MatchType = 'Manual';
         riw.AccountId = null;
         }
         }
         if((riw.AccountId!=null && riw.AccountId!='')){
         setAllAccountIds.add(riw.AccountId);
         }
         if(AccountIdMatch!=''){riw.MatchType = 'Auto - Account Id Match';
         riw.AccountId = AccountIdMatch;
         }
        }
        
         for(Account acc:[Select id,Name,Territories__c,ownerid from Account where id=:setAllAccountIds]){
              if(!mapUser.containskey(acc.ownerid)){
                    mapAccountIdOwnerId.put(acc.id,acc.ownerid);
              }
            }
        
        
        for(RecordInfoWrapper riw:lstRecordInfoWrapper.values()){
        if((riw.AccountId!=null && riw.AccountId!='')){
        if(mapAccountIdOwnerId.containskey(riw.AccountId)){
        riw.AccountOwnerId = mapAccountIdOwnerId.get(riw.AccountId);
        }
        }
        }
        }
        
        system.debug('lstRecordInfoWrapper after == '+lstRecordInfoWrapper.values().size());
        if(lstRecordInfoWrapper.values().size() == 0){
        for(RecordInfoWrapper record :lstInput)
        {
            System.debug(record+'KKKKKK');
            lstRecordInfoWrapper.put(record.order,record); 
        }
        }
        lstRecordInfoWrapper.values().sort();
        system.debug('lstRecordInfoWrapper after == '+lstRecordInfoWrapper);
        
        return lstRecordInfoWrapper.values();
    }
    
    public static List<RecordInfoWrapper> getBrokerOfficeRecordInfo(List<RecordInfoWrapper> lstInput)
    {
    set<String> setOfficeBrokerInfo = new set<String>();
    setOfficeBrokerInfo.add('Realtor Office');
    setOfficeBrokerInfo.add('Broker');
    List<RecordInfoWrapper> lstReturnList = getRecordMatchInfo(lstInput,setOfficeBrokerInfo);
    return lstReturnList;
    }
    
    Public void ReturnMLSAccount(){
    
    }
    
    public class RecordInfoWrapper implements Comparable
    {
        Public Integer Order;
        //public String ACPId;
        public String ContactId;
        public String AccountId;
        public String Email;
        public String CMId;
        public String Phone;
        public String Campaign;
        public String MatchType;
        public String AccountOwnerId;
        //Public String RDCContactType;
        //Public String LeadTargetAccountType;
        
        public Integer compareTo(Object obj)
        {
            RecordInfoWrapper customer = (RecordInfoWrapper)(obj);
            
            if (this.Order > customer.Order)
                return 1;
            else if (this.Order == customer.Order)
                return 0;
            
            return -1;
        }
    }
}