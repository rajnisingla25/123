public with sharing class AccountCMViewCTRL
{
    public string accID {get;set;}
    public list<ContactMethod__c> accCMPrefList {get;set;}
    Map<Id, Account_Relationship__c> mapAccountRelationship;
    public list<ContactMethod__c> CMPrefList {get;set;}
    public Map<Id, List<Contact>> conIdMap = new Map<Id, List<Contact>>();
    //public ApexPages.StandardController stdCntrlr {get; set;}
    public Map<Id, List<ContactMethod__c>> CMPrefMapList {get; set;}
    Map<Id, ContactMethod__c> mapConMethod = new Map<Id, ContactMethod__c>();
    private List<Contact> tempCont = new List<Contact>();
    public List<ContactAccountwrapper> CMAccWrapperList {get; set;}
    Set<Id> conIdSet = new Set<Id>();
    List<Id> conIdList = new List<Id>();
    public Account account {get;set;}
    /*public String contactmethodId { get; set; }
    public String userId1 { get; set; }
    public String prefcenter { get; set; }
    public String prefcenter1 { get; set; }*/
    public boolean isPrimaryContactExist {get;set;}
    public String accountRelationShipobjectId { get; set; }
    public Boolean viewTable {get;set;} {if(viewTable == null) viewTable = false;}
    private String buttonName;
    
    //public Boolean getViewTable(){return this.viewTable;}
    //public void setViewTable(Boolean value){this.viewTable = value;}
    public String getButtonName(){return this.buttonName;}
    
    public String newContactMethodBtnName {get;set;} {newContactMethodBtnName = 'New Contact Method';}
    
    public Boolean bIsnewRow {get; set;}
    public String conRelId {get; set;}
    private map<Id,Account_Relationship__c> mapInitialARs = new map<Id,Account_Relationship__c>();
    Map<String, Boolean> mapPrimaryCMIdVsStatus = new Map<String, Boolean>();
    
    //public Boolean displayPopup {get;set;}
    public String selectedConId {get; set;}
    //public List<ContactMethod__c> LstConMethod {get;set;}
    public boolean hasError {get; set;}
    
    public AccountCMViewCTRL() {
        bIsnewRow = false;
        mapAccountRelationship = new Map<Id, Account_Relationship__c>();
        //stdCntrlr = controller;
        accCMPrefList = new list<ContactMethod__c>();
        CMPrefList = new List<ContactMethod__c>();
        CMPrefMapList = new Map<Id, List<ContactMethod__c>>();
        accId = ApexPages.currentPage().getParameters().get('id');        
        System.debug('CTRL-accId:'+accId);
        CMAccWrapperList = new List<ContactAccountwrapper>();
        isPrimaryContactExist = FALSE;
        function(false);
        //viewTable = false;
        buttonName = 'Show Opt-Ins';
        this.hasError = false;
    }
    
    public void function(boolean flag){
        account = [SELECT Id, Name, Type, Account_Sub_Type__c,SyncButtonEnableDisable__c,BrokerAffiliationChanged__c, PrimarySMS_CMId__c, SMS_Phone__c,
                   PrimaryEmail_CMId__c, PrimaryPhone_CMId__c,RecordType.Name FROM Account WHERE Id = :accId];
        if (account.Account_Sub_Type__c == 'customer') {
            List <Account_Relationship__c> accConRelList = [select id, Parent_Account__r.name
                                                            from Account_Relationship__c 
                                                            where Relationship_Type__c = 'Contact' and Parent_Account__c =:accId
                                                            and Contact_Role__c = 'Primary Contact' limit 1];
            if(!accConRelList.isEmpty()){
                isPrimaryContactExist = TRUE;
            }
        }
        
        List<Account_Relationship__c> lstAccReln = [Select Id,Name, Parent_Account__r.Name, Contact_To__c, Contact_To__r.Name, 
                                                    Contact_To__r.Email, Contact_To__r.Preferred_Phone_Number__c, 
                                                    Contact_Role__c, Billing_Contact__c, 
                                                    Relationship_Type__c, Contact_To__r.NAR_ID__c, Contact_To__r.Type__c, 
                                                    Contact_To__r.DoNotCall, Active__c, End_Date__c,Parent_Account__r.Account_Sub_Type__c,
                                                    Parent_Account__r.PrimaryEmail_CMId__c, Parent_Account__r.PrimaryPhone_CMId__c 
                                                    From Account_Relationship__c 
                                                    //Where Relationship_Type__c = 'Contact' and Parent_Account__c =:accId];
                                                    Where RecordType.DeveloperName = 'Contact_Relationship' 
                                                    AND Active__c = true AND Parent_Account__c =:accId and Contact_To__c != null];
        
        for(Account_Relationship__c accountRelationship :lstAccReln)
        {
            conIdSet.add(accountRelationship.Contact_To__c);
            mapAccountRelationship.put(accountRelationship.Contact_To__c, accountRelationship);
            mapInitialARs.put(accountRelationship.Id, accountRelationship.clone(false, true));
        }
        
        Schema.DescribeSObjectResult result = Account_Relationship__c.sObjectType.getDescribe();
        accountRelationShipobjectId = result.getKeyPrefix();
        
        if(flag){
            if(!mapAccountRelationship.isEmpty()){
                accCMPrefList = [Select Id, Active__c, Contact__c, Contact__r.Id, Type__c, Type_Purpose__c, Email__c, Phone__c, Value__c, Primary_To_Contact__c, 
                                 Phone_Extension__c, Primary_To_Account__c, SMS_RDC_Promo_Pref__c,
                                 RDC_Event_OptIn__c, RDC_Info_OptIn__c, RDC_Promo_OptIn__c, TP_Event_OptIn__c, TP_Info_OptIn__c, TP_Promo_OptIn__c
                                 From ContactMethod__c 
                                 WHERE Contact__c IN: mapAccountRelationship.keySet() order by Type__c, Active__c, Type_Purpose__c DESC];
                
            }
        }else{
            if(!mapAccountRelationship.isEmpty()){
                accCMPrefList = [Select Id, Active__c, Contact__c, Contact__r.Id, Type__c, Type_Purpose__c, Email__c, Phone__c, Value__c, 
                                 Primary_To_Contact__c, Phone_Extension__c, Primary_To_Account__c, SMS_RDC_Promo_Pref__c,
                                 RDC_Event_OptIn__c, RDC_Info_OptIn__c, RDC_Promo_OptIn__c, TP_Event_OptIn__c, TP_Info_OptIn__c, TP_Promo_OptIn__c
                                 From ContactMethod__c 
                                 WHERE Contact__c IN: mapAccountRelationship.keySet() and Active__c = True order by Type__c, Type_Purpose__c DESC];
                
            }
        }
        
        Set<Id> setConId = new Set<Id>();        
        if(!accCMPrefList.isEmpty()){
            for(ContactMethod__c cm: accCMPrefList){
                mapConMethod.put(cm.Id, cm.clone(false, true));
                //if(!conIdSet.contains(cm.Contact__r.Id)) {
                //conIdSet.add(cm.Contact__r.Id);
                if(setConId.add(cm.Contact__r.Id))    
                    CMPrefList.add(cm);
                //}   
                if(CMPrefMapList.containsKey(cm.Contact__r.Id)) {
                    List<ContactMethod__c> PrefList = CMPrefMapList.get(cm.Contact__r.Id);
                    PrefList.add(cm);
                    CMPrefMapList.put(cm.Contact__r.Id, PrefList);
                } else {
                    CMPrefMapList.put(cm.Contact__r.Id, new List<ContactMethod__c> { cm });
                }
            }
        }
        
        System.debug(conIdSet);
        if(!conIdSet.isEmpty()) {
            conIdList.addAll(conIdSet);
            tempCont = [select Id, Name, Email, Phone, Active__c from Contact where id in: conIdList];
            for(Contact cont:tempCont){
                if(conIdMap.containsKey(accId)) {
                    List<Contact> accList = conIdMap.get(accId);
                    accList.add(cont);
                    conIdMap.put(accId, accList);
                } else {
                    conIdMap.put(accId, new List<Contact> { cont });
                }
            }
        }
        System.debug('Im here1');   
        String UserId = USerInfo.getUserId();
        for(Id cId: conIdMap.keyset()){
            List<AccountPreferencewrapper> AccWrapper = new List<AccountPreferencewrapper>();
            //ContactAccountwrapper conWrap = new ContactAccountwrapper();
            //conWrap.conId = conId;
            for(Contact cont:conIdMap.get(cId)){
                AccountPreferencewrapper acctwrapper = new AccountPreferencewrapper();
                acctwrapper.con=cont;
                system.debug('cont>>>>'+cont);
                system.debug('CMPrefMapList.get(cont.id)>>>>'+CMPrefMapList.get(cont.id));
                acctwrapper.AccountRelationship = mapAccountRelationship.get(cont.Id);
                List<PreferenceWrapper> PWrap = new List<PreferenceWrapper>();
                List<PreferenceWrapper> PWrap2 = new List<PreferenceWrapper>();
                acctwrapper.isEmailRecordPresent = false;
                acctwrapper.isPhoneRecordPresent = false;
                acctwrapper.isWebRecordPresent = false;
                
                if(CMPrefMapList.containsKey(cont.id))
                {
                    for(ContactMethod__c Apref:CMPrefMapList.get(cont.id)){
                        
                        if(Apref.Type__c == 'Phone')
                            acctwrapper.isPhoneRecordPresent = true;
                        else if(Apref.Type__c == 'Email')
                            acctwrapper.isEmailRecordPresent = true;
                        else if(Apref.Type__c == 'Social')
                            acctwrapper.isWebRecordPresent = true;
                        
                        PreferenceWrapper Wpref = new PreferenceWrapper();
                        if(account.PrimaryPhone_CMId__c == Apref.Id || account.PrimaryEmail_CMId__c == Apref.Id)
                        {
                            mapPrimaryCMIdVsStatus.put(Apref.Id, Apref.Active__c);
                            
                            Wpref.primaryNum = 1;
                            Apref.Primary_To_Account__c = true;
                            PWrap2.add(Wpref);
                        }
                        else
                        {
                            Wpref.primaryNum = 0;
                            Apref.Primary_To_Account__c = false;
                            PWrap.add(Wpref);
                        }
                        
                        if(acctwrapper.AccountRelationship.Contact_Role__c == 'Primary Contact')
                            Wpref.isPrimaryToAccount = true;
                        else
                            Wpref.isPrimaryToAccount = false;
                        
                        Wpref.cm=Apref;
                        System.debug('Im here2');
                    }
                    system.debug(' *** PWrap '+PWrap);
                    PWrap.sort();
                    if(!PWrap.isEmpty())
                        PWrap2.addAll(PWrap);
                }
                //Accwrapper.add(new AccountPreferencewrapper(acct,PWrap));
                acctwrapper.refWrap=PWrap2;
                Accwrapper.add(acctwrapper);
                System.debug('Im here3');
            }
            System.debug(Accwrapper);
            //conWrap.AcctWrap = Accwrapper;
            //System.debug(conWrap);
            Accwrapper.sort();
            CMAccWrapperList.add(new ContactAccountwrapper(accId,Accwrapper));
            //conAccWrapperList.add(conWrap);
            System.debug(CMAccWrapperList);
            System.debug('Im here4');
        }
        
    }
    
    public pagereference save() {
        return null;
    }
    
    public pagereference supress() {
        CMAccWrapperList.clear();
        accCMPrefList.clear();
        CMPrefList.clear();
        CMPrefMapList.clear();
        conIdMap.clear();
        conIdList.clear();
        conIdSet.clear();
        
        function(false);
        return null;
    }
    
    public pagereference showall() {
        CMAccWrapperList.clear();
        accCMPrefList.clear();
        CMPrefList.clear();
        CMPrefMapList.clear();
        conIdMap.clear();
        conIdList.clear();
        conIdSet.clear();
        
        function(true);
        return null;
    }
    
    public pagereference showHideTable(){
        system.debug('viewTable:: ' + viewTable);
        if(!viewTable){
            viewTable = true;
            buttonName = 'Hide Opt-Ins';
        }else{
            viewTable = false;
            buttonName = 'Show Opt-Ins';
        }
        system.debug('viewTable:: ' + viewTable);
        return null;
    }
    
    public pagereference redirectToPreferenceCenter(){
        String url = 'www.google.com'; 
      /*  system.debug(' *** contactMethodId *** '+contactMethodId+' *** prefcenter ***'+prefcenter);
        if(prefcenter == 'TPCRM'){
            url = Label.Preference_Center_TPCRM+'?contactMethodId='+contactmethodId+'&userId='+userId1; 
        }
        if(prefcenter1 == 'RDC'){
            url = Label.Preference_Center_RDC+'?contactMethodId='+contactmethodId+'&userId='+userId1; 
        } */
        Pagereference pageRef = new Pagereference(url);  
        viewTable = true;
        buttonName = 'Hide Opt-Ins';
        system.debug(' **** pageRef is *** '+pageRef);
        return pageRef;
    }
    
    //wrapper 1
    class ContactAccountwrapper{
        public Id accId {get;set;}
        public List<AccountPreferencewrapper> AcctWrap {get; set;}
        //ContactAccountwrapper(){}
        public ContactAccountwrapper(Id accId, List<AccountPreferencewrapper> AccWrap){
            accId = accId;
            AcctWrap = AccWrap;
        }
    }
    
    //wrapper 2
    class AccountPreferencewrapper implements Comparable {
        public Contact con {get; set;}
        public Account_Relationship__c AccountRelationship {get; set;}
        public List<PreferenceWrapper> refWrap {get; set;}
        public Boolean isWebRecordPresent {get; set;}
        public Boolean isPhoneRecordPresent {get; set;}
        public Boolean isEmailRecordPresent {get; set;}
        
        AccountPreferencewrapper(){
            if(con==null){con = new Contact();}
            if(refWrap==null){refWrap = new List<PreferenceWrapper>();}
        }
        public AccountPreferencewrapper(Contact cont, List<PreferenceWrapper> PWrap){
            con = cont;
            refWrap = PWrap;
        }
        
        public Integer compareTo(Object obj) {
            AccountPreferencewrapper accPrefWrapper = (AccountPreferencewrapper)(obj);
            if (this.AccountRelationship.Contact_Role__c == 'Primary Contact')
                return 0;
            
            if (this.AccountRelationship.Contact_Role__c < accPrefWrapper.AccountRelationship.Contact_Role__c)
                return 1;
            else if (this.AccountRelationship.Contact_Role__c == accPrefWrapper.AccountRelationship.Contact_Role__c)
                return 0;
            
            return -1;
        }
    }
    //wrapper 3 - the sub-wrapper
    class PreferenceWrapper implements Comparable
    {
        public ContactMethod__c cm {get; set;}
        public Account account {get;set;}
        public Boolean bIsnewRow {get; set;}
        public Boolean isPrimaryToAccount {get; set;}
        public Integer primaryNum;
        
        public Integer compareTo(Object obj)
        {
            PreferenceWrapper customer = (PreferenceWrapper)(obj);
            /*if(this.cm.Type_Purpose__c == 'Business Fax' || customer.cm.Type_Purpose__c == 'Business Fax') {
return -1;
}*/
            
            if(this.cm.Type_Purpose__c < customer.cm.Type_Purpose__c)
                return -1;
            if(this.cm.Type_Purpose__c < customer.cm.Type_Purpose__c)
                return -1;
            else if(this.cm.Type_Purpose__c > customer.cm.Type_Purpose__c)
                return 1;
            
            return 0;
        }
    }
    
    public Pagereference saveRecords()
    {
        system.debug('====saveRecords');
        bIsnewRow = false;
        List<Account_Relationship__c> lstAccountRel = new List<Account_Relationship__c>();
        List<ContactMethod__c> lstContactMethod = new List<ContactMethod__c>();
        errorMessage = '';
        String primaryEmailCMId = '';
        String primaryPhoneCMId = '';
        String primaryWebCMId = '';
        String primaryEmail = '';
        String primaryPhone = ''; String phoneExt = '';
        String phoneTypePurpose = ''; String emailTypePurpose = '';
        String BusinessPhoneCMId, PersonalPhoneCMId, BusinessmobileCMId, PersonalmobileCMId = null;
        String smsPhone = ''; String smsPhoneId = '';
        this.hasError = false;        
        String profiles = Label.CustomerAccountProfileAccess;
        String accSubType = '';
        Id contId;
        List<ContactMethod__c> cmList = new List<ContactMethod__c>();
        User loggedinuser = [Select id, Profile.name from User where id = :userInfo.getUserId()];
        
        for(ContactAccountwrapper record :CMAccWrapperList)
        {
            for(AccountPreferencewrapper accRecord :record.AcctWrap)
            {
                system.debug('record.AcctWrap.size()==>>'+record.AcctWrap.size());
                system.debug('record==>>'+accRecord);
                system.debug('record==>>'+accRecord.AccountRelationship.Contact_Role__c);
                accSubType = accRecord.AccountRelationship.Parent_Account__r.Account_Sub_Type__c;
                System.debug('accSubType:'+accSubType);
                
                if(record.AcctWrap.size() == 1 && accRecord.AccountRelationship.Contact_Role__c != 'Primary Contact')
                {
                    this.hasError = true;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Sorry, you cannot change Sales Contact Role.'));
                    return null;
                }
                if(accRecord.AccountRelationship.Active__c == False && accRecord.AccountRelationship.Contact_Role__c == 'Primary Contact')
                {
                    this.hasError = true;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Sorry, you cannot Inactivate Primary Relationship.'));
                    return null;
                }
                if(accRecord.AccountRelationship.Active__c == False){
                    accRecord.AccountRelationship.End_Date__c = Date.today();
                }
                if(mapInitialARs.get(accRecord.AccountRelationship.Id) != null){
                    Account_Relationship__c oldAR = mapInitialARs.get(accRecord.AccountRelationship.Id);
                    if(oldAR.Contact_Role__c != accRecord.AccountRelationship.Contact_Role__c || oldAR.Billing_Contact__c != accRecord.AccountRelationship.Billing_Contact__c
                       || oldAR.Active__c != accRecord.AccountRelationship.Active__c){
                           lstAccountRel.add(accRecord.AccountRelationship);
                       }
                }
                if(accRecord.AccountRelationship.Contact_Role__c == 'Primary Contact'){
                    contId = accRecord.AccountRelationship.Contact_To__c;
                }
                
                for(PreferenceWrapper pageRef :accRecord.refWrap){
                    pageRef.bIsnewRow = false;
                    if(pageRef.cm.Type__c == 'Phone'){
                        system.debug('====pageRef.cm.Primary_To_Account__c'+pageRef.cm.Primary_To_Account__c);
                        system.debug('====pageRef.cm.Phone__c'+pageRef.cm.Phone__c);
                        if(pageRef.cm.Type_Purpose__c == 'BUSINESS_FAX' && pageRef.cm.Primary_To_Account__c){
                            this.hasError = true;
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Business Fax cannot be Primary.'));
                            return null;
                        }
                        System.debug('pageRef.cm.Type_Purpose__c:'+pageRef.cm.Type_Purpose__c);
                        if(pageRef.cm.Type_Purpose__c == 'BUSINESS_MOBILE' || pageRef.cm.Type_Purpose__c == 'PERSONAL_MOBILE'){
                            smsPhone = pageRef.cm.Phone__c;
                            smsPhoneId = pageRef.cm.Id;
                        }
                    }
                    if(pageRef.cm.Primary_To_Account__c){
                        if(!mapPrimaryCMIdVsStatus.isEmpty() && mapPrimaryCMIdVsStatus.get(pageRef.cm.Id) != null && !pageRef.cm.Active__c)
                        {
                            this.hasError = true;
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Contact Method which is Primary to Account cannot be Inactive.'));
                            return null;
                        }
                        if(pageRef.cm.Type__c == 'Email' && profiles.contains(loggedinuser.Profile.name) && accSubType == 'Customer'){
                            this.hasError = true;
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'You do not have access to update Account Primary Email Address for customer accounts.'));
                            return null;
                        }
                        
                        if(pageRef.cm.Type__c == 'Email'){
                            primaryEmailCMId = ''+pageRef.cm.Id;
                            primaryEmail = pageRef.cm.Email__c;
                            emailTypePurpose = pageRef.cm.Type_Purpose__c;
                        }
                        else if(pageRef.cm.Type__c == 'Social'){
                            primaryWebCMId = ''+pageRef.cm.Id;
                        }
                        else if(pageRef.cm.Type__c == 'Phone'){
                            primaryPhoneCMId = ''+pageRef.cm.Id;
                            primaryPhone = pageRef.cm.Phone__c;
                            phoneExt = pageRef.cm.Phone_Extension__c;
                            phoneTypePurpose = pageRef.cm.Type_Purpose__c;
                            System.debug('phoneTypePurpose:'+phoneTypePurpose);
                        }
                    }
                    System.debug('primaryPhoneCMId:'+primaryPhoneCMId);
                    System.debug('smsPhoneId:'+smsPhoneId);                    
                    
                    if(mapConMethod.containsKey(pageRef.cm.Id) && pageRef.cm.Type__c != mapConMethod.get(pageRef.cm.Id).Type__c)
                    {
                        this.hasError = true;
                        //errorMessage = 'Sorry, you cannot change Type of Contact Method';
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage));
                        return null;
                    }
                    
                    if(mapConMethod.get(pageRef.cm.Id) != null){
                        ContactMethod__c oldCM = mapConMethod.get(pageRef.cm.Id);
                        system.debug('oldCM =='+oldCM);
                        system.debug('pageRef.cm.Phone__c =='+pageRef.cm.Phone__c);
                        system.debug('oldCM.Phone__c =='+oldCM.Phone__c);
                        
                        if(pageRef.cm.Email__c != oldCM.Email__c || pageRef.cm.Phone__c != oldCM.Phone__c || pageRef.cm.Type_Purpose__c  != oldCM.Type_Purpose__c 
                           || pageRef.cm.Phone_Extension__c != oldCM.Phone_Extension__c || pageRef.cm.Value__c != oldCM.Value__c || pageRef.cm.Active__c != oldCM.Active__c){
                               lstContactMethod.add(pageRef.cm);
                           }
                    }
                }
            }
        }        
        
        try
        {
            if(!lstAccountRel.isEmpty()){
                upsert lstAccountRel;
                for(Account_Relationship__c ar : lstAccountRel){
                    mapInitialARs.put(ar.Id, ar.clone(true,false));
                }
            }
            if(!lstContactMethod.isEmpty()){
                upsert lstContactMethod;
                for(ContactMethod__c cm : lstContactMethod){
                    mapConMethod.put(cm.Id, cm.clone(true,false));
                }
            }
            if(account != null){
                if(contId != null){
                    cmList = new List<ContactMethod__c>([Select Id, Email__c, Phone__c, Phone_Extension__c, Type__c, Type_Purpose__c
                                                         from ContactMethod__c Where Type__c = 'Phone' and Contact__c = :contId and Active__c = True
                                                         order by LastModifiedDate Desc]);
                }                
                
                if(account.PrimaryPhone_CMId__c != primaryPhoneCMId || account.PrimaryEmail_CMId__c != primaryEmailCMId){                                       
                    if(String.isNotEmpty(primaryEmailCMId)){
                        account.Email_Address__c = primaryEmail;
                        account.Type_Purpose__c = emailTypePurpose;
                        account.PrimaryEmail_CMId__c = primaryEmailCMId;
                    }
                    if(String.isNotEmpty(primaryPhoneCMId)){
                        account.Phone = primaryPhone;
                        account.Phone_Extension__c = phoneExt;
                        account.Preferred_Phone__c = phoneTypePurpose;
                        account.PrimaryPhone_CMId__c = primaryPhoneCMId;                        
                    }
                }
                if(account.SMS_Phone__c == null || account.PrimarySMS_CMId__c == smsPhoneId){
                    if(phoneTypePurpose == 'BUSINESS_MOBILE' || phoneTypePurpose == 'PERSONAL_MOBILE') {
                        if(account.SMS_Phone__c == null || account.PrimarySMS_CMId__c == smsPhoneId){
                            account.SMS_Phone__c  = smsPhone;
                            account.PrimarySMS_CMId__c  = smsPhoneId;
                        }
                    }
                }
                if(!cmList.isEmpty()){
                    account.Mobile2_Other__c  = null;
                    account.Other_Phone_Ext__c  = null;
                    account.Work_Phone__c  = null;
                    account.Work_Phone_Ext__c  = null;
                    account.Mobile1__c = null;
                    account.Home_Phone__c = null;
                    for(ContactMethod__c cm: cmList){
                        if(cm.Type_Purpose__c == 'BUSINESS_PHONE' && BusinessPhoneCMId == null){
                            BusinessPhoneCMId = cm.Id;
                            account.Work_Phone__c  = cm.Phone__c;
                            account.Work_Phone_Ext__c  = cm.Phone_Extension__c;
                        }                                
                        if(cm.Type_Purpose__c == 'PERSONAL_PHONE' && PersonalPhoneCMId == null){
                            PersonalPhoneCMId = cm.Id;
                            account.Home_Phone__c  = cm.Phone__c;
                            account.Other_Phone_Ext__c  = cm.Phone_Extension__c;
                        }
                        if(cm.Type_Purpose__c == 'BUSINESS_MOBILE' && BusinessmobileCMId == null){
                            BusinessmobileCMId = cm.Id;
                            account.Mobile1__c = cm.Phone__c;                                            
                        }
                        if(cm.Type_Purpose__c == 'PERSONAL_MOBILE' && PersonalmobileCMId == null){
                            PersonalmobileCMId = cm.Id;
                            account.Mobile2_Other__c = cm.Phone__c;
                        }
                    }
                }                
            }
            update account;
        }
        catch(Exception ex)
        {
            this.hasError = true;
            system.debug('Exception==>');
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
        }
        
        return null;
    }
    
    public Pagereference cancelAll()
    {
        errorMessage = '';
        /*for(ContactAccountwrapper caWrapper : CMAccWrapperList){
for(AccountPreferencewrapper apWrapper : caWrapper.AcctWrap){
list<PreferenceWrapper> prefWrapList = new list<PreferenceWrapper>();
for(PreferenceWrapper prefWrap : apWrapper.refWrap){
if(prefWrap != null && prefWrap.cm != null && prefWrap.cm.Id != null){
prefWrapList.add(prefWrap);
} 
}
apWrapper.refWrap = prefWrapList;
}
}*/
        
        //  this.CMAccWrapperList = null;
        //function(false); // added by venkat
        
        return null;
        //Pagereference page = mew Pagereference('/apex/AccountCMDataStewardView?Id='+accID);
        //return page;
    }
    
    public Pagereference addCM()
    {
        bIsnewRow = true;
        
        system.debug(''+ar);
        for(ContactAccountwrapper caWrapper : CMAccWrapperList){
            for(AccountPreferencewrapper apWrapper : caWrapper.AcctWrap){
                if(apWrapper.AccountRelationship.Contact_To__c == ar){
                    PreferenceWrapper Wpref = new PreferenceWrapper();
                    Wpref.cm = new ContactMethod__c();
                    Wpref.cm.Contact__c = ar;
                    Wpref.cm.Source_Type__c = 'web';
                    Wpref.bIsnewRow = true;
                    apWrapper.refWrap.add(Wpref);
                    ar = null;
                    return null;
                } 
            }
        }
        
        ar = null; 
        
        return null;
    }
    
    public void deleteRel()
    {
        system.debug('conRelId==>>'+conRelId);
        List<Account_Relationship__c> lstAccountRel = [Select Id From Account_Relationship__c 
                                                       Where Id =:conRelId];
        delete lstAccountRel;
    }
    
    public string ar{get;set;}
    public string errorMessage {get;set;}
    
    public Pagereference showPopup()
    {
        Pagereference page = new Pagereference('/apex/AccountContactClickToDial?Id='+selectedConId);
        return page;
    }
    
    public void closePopup() 
    {
        //displayPopup = false;    
    }
}