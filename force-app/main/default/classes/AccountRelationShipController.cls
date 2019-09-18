/*
 Description : To add multiple office affiliations for the broker from the account detail page
 @author : Ravinder
 Create Date : 8/18/15
LEAP # 3333 */

public with sharing class AccountRelationShipController 
{

    public list<AccountRelationWrapper> accRelationList = new list<AccountRelationWrapper>();
    public list<AccountWrapper> accountList = new list<AccountWrapper>();    
    public list<AccountRelationWrapper> accRelationBrokers {get;set;}
    public list<AccountRelationWrapper> accRelationOffices {get;set;} 
    public list<AccountWrapper> accountBrokers {get;set;}
    public list<AccountWrapper> accountOffices {get;set;} 
    private final String ACCOUNT_RELATIONSHIP_RECORD_TYPE = 'Account Relationship';    
    public Id accountRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get(ACCOUNT_RELATIONSHIP_RECORD_TYPE).RecordTypeId;   
       
    public account oaccountType {get;set;}
    private final Account acct;
    public string accName         {get;set;}
    public set<String> zipcodeSet = new set<String>();    
    public set<String> partyIDset = new set<String>();    
    public set<String> customerIDset = new set<String>();    
    public set<String> MLSset = new set<String>();        
        
    public string accPartyID      {get;set;}    
    public string accCustomerID   {get;set;}           
    public string accZipcode      {get;set;}   
    public string accCity         {get;set;}
    public string accState         {get;set;}    
    public string accMLS          {get;set;}
    
    public boolean onLoad {get;set;}
    public boolean onSearchClick {get;set;}    
    
    private set<String> accMLSset = new set<String>();    
    public string accIdSelected = '';
    public string RealtoraccIdSelected = '';    
            
    public AccountRelationShipController(ApexPages.StandardController stdcontroller) 
    {     
        onLoad = true;
        onSearchClick = false;
        oaccountType = new Account();
        accRelationBrokers   = new list<AccountRelationWrapper>();
        accRelationOffices   = new list<AccountRelationWrapper>();                
        accountBrokers       = new list<AccountWrapper>();
        accountOffices       = new list<AccountWrapper>();                
                
        this.acct = (Account)stdController.getRecord(); 
       System.debug('Acct:'+Acct.Id);               
        
     populaterecords();   
    }
    
    public void populateRecords()
    {
        set<ID> contactIds = new set<ID>();
        onLoad = false;
        onSearchClick = true;
        set<ID> parentIDs = new set<ID>();
        set<ID> officeIds = new set<ID>();      
        set<ID> childIDs = new set<ID>();  
        set<ID> contIDs = new set<ID>();
        set<ID> accBrokSet = new set<ID>();
        set<ID> accOffiSet = new set<ID>();
        
        
        if(this.acct.ID != null){
            for(Account oacc : [SELECT Parent_Broker__c,Parent_Broker__r.Name,Type,Name,Party_ID__c,Customer_Id__c,Total_HLC__C,Total_CLC__c,BillingPostalCode, BillingCity, MLS_Set_Id__c  FROM Account WHERE ID =:this.acct.ID])
            {
                if(oacc.Type == 'Broker')
                     parentIDs.add(oacc.ID);
                if(oacc.Type == 'Realtor Office')    
                    officeIds.add(oacc.ID);
                 
                 accountList.add(new AccountWrapper(oacc,oacc.Parent_Broker__r.Name));    
            }
         if(!parentIDs.isEmpty()){
             for(Account_Relationship__c accr : [SELECT ID,Child_Account__c,Parent_Account__c FROM Account_Relationship__c WHERE Parent_Account__c IN: parentIDs AND Active__c = true]){
               childIDs.add(accr.Child_Account__c);  
             }
         }
         
          for(Account_Relationship__c accr2 : [SELECT ID,Contact_To__c FROM Account_Relationship__c WHERE Parent_Account__c =: this.acct.ID AND Active__c = true]){
                    if(accr2.Contact_To__c != null)          
                       contIDs.add(accr2.Contact_To__c);  
          }
          set<ID> accIDs2 = new set<ID>();
          
          for(Account_Relationship__c accr2 : [SELECT ID,Contact_To__c,Parent_Account__c,Parent_Account__r.Type FROM Account_Relationship__c WHERE Contact_To__c IN:contIDs AND Active__c = true]){                   
                accIDs2.add(accr2.Parent_Account__c);              
          }
          for(Account_Relationship__c accr3 : [SELECT ID,Contact_To__c,Parent_Account__c,Parent_Account__r.Type FROM Account_Relationship__c WHERE Child_Account__c IN:officeIds AND Active__c = true]){                   
                accIDs2.add(accr3.Parent_Account__c);              
          }
          
          if(accIDs2.size() > 0){
            for(Account oacc4 :[SELECT Parent_Broker__c,Parent_Broker__r.Name,Type,Name,Party_ID__c,Customer_Id__c,Total_HLC__C,Total_CLC__c,BillingPostalCode, BillingCity, MLS_Set_Id__c  FROM Account WHERE ID IN: accIDs2]){
                  if(oacc4.Type== 'Broker' && !accBrokSet.contains(oacc4.ID) ){
                      accBrokSet.add(oacc4.ID);                                        
                      accountBrokers.add(new AccountWrapper(oacc4 ,oacc4.Parent_Broker__r.Name));                                        
                  }
                  if(oacc4.Type== 'Realtor Office' && !accOffiSet.contains(oacc4.ID)){
                      accOffiSet.add(oacc4.ID);                  
                      accountOffices.add(new AccountWrapper(oacc4 ,oacc4.Parent_Broker__r.Name));
                  }              
              } 
              
          }
                          
                      
         if(childIDs.isEmpty()){
             for(AccountWrapper accWrapper :accountList){
                  if(accWrapper.acctype == 'Broker' && !accBrokSet.contains(accWrapper.oaccount.ID)){
                      accBrokSet.add(accWrapper.oaccount.ID);                  
                      accountBrokers.add(accWrapper);                                        
                  }
                  if(accWrapper.acctype == 'Realtor Office' && !accOffiSet.contains(accWrapper.oaccount.ID)){
                      accOffiSet.add(accWrapper.oaccount.ID);                    
                      accountOffices.add(accWrapper);
                  }              
              }
          }
          else
          {
              accountList.clear();
              for(Account oacc :[SELECT Parent_Broker__c,Parent_Broker__r.Name,Type,Name,Party_ID__c,Customer_Id__c,Total_HLC__C,Total_CLC__c,BillingPostalCode, BillingCity, MLS_Set_Id__c  FROM Account WHERE ID =:this.acct.ID OR ID IN: childIDs]){
                  if(oacc.Type== 'Broker' && !accBrokSet.contains(oacc.ID)){
                      accBrokSet.add(oacc .ID); 
                      accountBrokers.add(new AccountWrapper(oacc,oacc.Parent_Broker__r.Name));                                        
                  }
                  if(oacc.Type== 'Realtor Office' && !accOffiSet.contains(oacc.ID)){
                      accOffiSet.add(oacc .ID);
                      accountOffices.add(new AccountWrapper(oacc,oacc.Parent_Broker__r.Name));
                  }              
              } 
          }
                      
        }  // account id null
        
         /*for(AccountWrapper accoffice :[SELECT ID FROM Account_Relationship__c WHERE ]){
                 
         }
         */
    }
    
    public class AccountRelationWrapper{
    
         public Account_Relationship__c  accRelationship{get; set;}
         public string acctype {get;set;}
         public string childacctype {get;set;}         
         public Boolean selected{get; set;}
          
         public AccountRelationWrapper(Account_Relationship__c   a) {
            accRelationship = a;
            if(a.Parent_Account__c != null)
                acctype = a.Parent_Account__r.Type;
            else if (a.Child_Account__c != null)
                accType = a.Child_Account__r.Type;
            if (a.Child_Account__c != null)                
            childacctype  =     a.Child_Account__r.Type;
            selected = false;              
         }
      }
      
    public class AccountWrapper{
    
         public Account oaccount{get; set;}
         public string acctype {get;set;}
         public string oparentAccName {get;set;}
         public boolean radioButton {get;set;}
         public Boolean selected{get; set;}
          
         public AccountWrapper(Account a,string parentAccountName) {
            oaccount = a;
             acctype = a.Type;
            selected = false;  
            oparentAccName =   parentAccountName; 
            radioButton = false;
            if(!String.isEmpty(oparentAccName))         
                radioButton = true;
            
         }
      }
      
            
      
     public PageReference getSelected() {
          return null;
      }
            
     public PageReference submit() {     
         system.debug('accRelationBrokers****'+accRelationBrokers);
         system.debug('accRelationOffices****'+accRelationOffices);
        Id RecordTypeId = Schema.SObjectType.Account_Relationship__c.getRecordTypeInfosByName().get('Account Relationship').getRecordTypeId();
         // if account relation brokers and Offices are selected.
         if(!accRelationBrokers.isEmpty() &&  !accRelationOffices.isEmpty() ){
         
             map<ID,AccountRelationWrapper> brokersMap = new map<ID,AccountRelationWrapper>();
             map<ID,AccountRelationWrapper> OfficesMap = new map<ID,AccountRelationWrapper>();
             
             for(AccountRelationWrapper ar_Broker :accRelationBrokers){
                 if(ar_Broker.selected){
                     brokersMap.put(ar_Broker.accRelationship.Parent_Account__c,ar_Broker);
                 }
             }
             for(AccountRelationWrapper ar_Office :accRelationOffices){
                 if(ar_Office.selected){
                     OfficesMap.put(ar_Office.accRelationship.Parent_Account__c,ar_Office);
                 }
             }         
             list<Account_Relationship__c> accRelations = new list<Account_Relationship__c>();
             
             for(AccountRelationWrapper ar_officenew: OfficesMap.values()){             
                 for(AccountRelationWrapper ar_brokernew: brokersMap.values()){
                     Account_Relationship__c newRelation = new Account_Relationship__c();                 
                         newRelation.Parent_Account__c = ar_brokernew.accRelationship.Parent_Account__c;
                         newRelation.Child_Account__c  = ar_officenew.accRelationship.Parent_Account__c;
                         newRelation.RecordTypeId      = RecordTypeId;   
                         accRelations.add(newRelation);                                        
                 }             
             }
             if(!accRelations.isEmpty()){
                     return insertRecords(accRelations);                
                 }                          
         } 
         boolean skipother = false;
         set<ID> ChildAccIDs = new set<ID>();         
         // if Account office and account brokers are selected.
         if(!accountOffices.isEmpty() &&  !accountBrokers.isEmpty()){
                     
             map<ID,AccountWrapper> brokersMap = new map<ID,AccountWrapper>();
             map<ID,AccountWrapper> OfficesMap = new map<ID,AccountWrapper>();
             
             for(AccountWrapper ar_Broker :accountBrokers){
                 if(ar_Broker.selected){
                     brokersMap.put(ar_Broker.oaccount.ID,ar_Broker);
                 }
             }
             for(AccountWrapper ar_Office :accountOffices){
                 if(ar_Office.selected){
                     OfficesMap.put(ar_Office.oaccount.ID,ar_Office);
                 }
             }         
             list<Account_Relationship__c> accRelations = new list<Account_Relationship__c>();
            
             string PaerentBrokerID = '';
             for(AccountWrapper  ar_officenew: OfficesMap.values()){             
                 for(AccountWrapper  ar_brokernew: brokersMap.values()){
                     PaerentBrokerID = '';
                     Account_Relationship__c newRelation = new Account_Relationship__c();                 
                         newRelation.Parent_Account__c = ar_brokernew.oaccount.ID;
                         if(ar_brokernew.oaccount.ID != null )                         
                             PaerentBrokerID = ''+ar_brokernew.oaccount.ID;                         
                         newRelation.Child_Account__c  = ar_officenew.oaccount.Id;
                         newRelation.Relationship_Type__c = 'Parent/Child';                         
                         newRelation.RecordTypeId      = RecordTypeId;                         
                         accRelations.add(newRelation);   
                         if(ar_officenew.oaccount.Id != null)
                         ChildAccIDs.add(ar_officenew.oaccount.Id);                                                              
                 }             
             }
             list<Account> oAccChilds = new list<Account>();
             system.debug('***ChildAccIDs***'+ChildAccIDs);
             system.debug('***PaerentBrokerID***'+PaerentBrokerID);
                         
             if(!ChildAccIDs.isEmpty())
                   updateAccountFuture(ChildAccIDs,PaerentBrokerID);
                                      
             if(!accRelations.isEmpty()){
                     return insertRecords(accRelations); 
                     skipother = true;                       
                                                     
                 }   
         }    
        // If radio button is selected and account offices are selected.   
                   
        if(!String.isEmpty(accIdSelected) && !accountOffices.isEmpty()){
             //Account oaccOffice = [SELECT ID,Type FROM Account WHERE ID=: accIdSelected];   
             //oaccOffice.Type = 'Broker';
             //update oaccOffice;
             string newaccountId = '';
             newaccountId = submitlogic(accIdSelected);
             System.debug('accIdSelected:'+accIdSelected);
             
             map<ID,AccountWrapper> OfficesMap = new map<ID,AccountWrapper>();                          
             
             for(AccountWrapper ar_Office :accountOffices){
                 if(ar_Office.selected){
                     OfficesMap.put(ar_Office.oaccount.ID,ar_Office);
                 }
             }
             list<Account_Relationship__c> accRelations = new list<Account_Relationship__c>();                          
             ChildAccIDs.clear();                
             for(AccountWrapper  ar_officenew: OfficesMap.values()){                          
                     Account_Relationship__c newRelation = new Account_Relationship__c();                 
                         newRelation.Parent_Account__c = newaccountId;
                         newRelation.Child_Account__c  = ar_officenew.oaccount.Id;
                         ChildAccIDs.add(ar_officenew.oaccount.Id);                         
                         newRelation.RecordTypeId      = RecordTypeId; 
                         newRelation.Relationship_Type__c = 'Parent/Child';
                         newRelation.Is_Parent_Primary__c = true; 
                         accRelations.add(newRelation);                                                     
             }
                 if(!ChildAccIDs.isEmpty())
                   updateAccountFuture(ChildAccIDs,newaccountId ); 
                   
             if(!accRelations.isEmpty()){
                     return insertRecords(accRelations);
                 }   

        }
         // If radio button is selected and account offices are selected.      
        if(!String.isEmpty(RealtoraccIdSelected) && !accRelationOffices.isEmpty()){              
             string newaccountId = '';        
             newaccountId = submitlogic(RealtoraccIdSelected);
                 
        }
        
        // if only account offices are selected and URL account id exits.
        if(skipother == false && !String.isEmpty(this.acct.ID) && !accountOffices.isEmpty()){
        
             map<ID,AccountWrapper> OfficesMap = new map<ID,AccountWrapper>();                                       
             for(AccountWrapper ar_Office :accountOffices){
                 if(ar_Office.selected){
                     OfficesMap.put(ar_Office.oaccount.ID,ar_Office);
                 }
             }
              list<Account_Relationship__c> accRelations = new list<Account_Relationship__c>();  
                                   
             for(AccountWrapper  ar_officenew: OfficesMap.values()){                          
                     Account_Relationship__c newRelation = new Account_Relationship__c();                 
                         newRelation.Parent_Account__c = this.acct.ID;
                         newRelation.Child_Account__c  = ar_officenew.oaccount.Id;                         
                         newRelation.RecordTypeId      = RecordTypeId;
                         newRelation.Relationship_Type__c = 'Parent/Child';
                         accRelations.add(newRelation);                                                     
             }
                        

             if(!accRelations.isEmpty()){
                     return insertRecords(accRelations);
                 }
                 
             
        }
         return new PageReference('/'+this.acct.ID);
     }
     //@future
     public static void updateAccountFuture(set<ID> accIDS,string parentID)
     {
             list<Account> oAccChilds = new list<Account>();
             for(Account oacc: [SELECT ID,Parent_Broker__c FROM Account WHERE ID IN: accIDS])
             {   
             system.debug('***PaerentBrokerID2****'+parentID);               
                oacc.Parent_Broker__c =parentID;                
                oAccChilds.add(oacc);                   
             } 
             update  oAccChilds;
     }
     public PageReference  insertRecords(list<Account_Relationship__c> relRecords)
     {
         try
         {
          insert relRecords;                    
             return new PageReference('/'+this.acct.ID);
         }
         catch(exception e)
         {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ''+e.getmessage()));
            return null;
         }
     }
              
     public PageReference  selectAccount()
     {
         system.debug('***accID***'+apexPages.currentPage().getParameters().get('primaryOfficeSelected')); 
         if(apexPages.currentPage().getParameters().containskey('primaryOfficeSelected'))
         accIdSelected = apexPages.currentPage().getParameters().get('primaryOfficeSelected');

         if(apexPages.currentPage().getParameters().containskey('realtorOfficeSelected'))
             RealtoraccIdSelected = apexPages.currentPage().getParameters().get('realtorOfficeSelected');
        system.debug('***accIdSelected****'+RealtoraccIdSelected );             
                  
         return null;
     }
     public PageReference  Convert(){
             if(!String.isEmpty(accIdSelected)){
                 
             }
         return null;
     }
     public PageReference  SearchRelatedAccount(){
        onLoad = false;
        onSearchClick = true;
//         string accRelationQuery = 'SELECT Type,Name,Party_ID__c,Customer_Id__c, BillingPostalCode, BillingCity, MLS_Set_Id__c  FROM Account WHERE RecordType.DeveloperName = \'B2B\' AND ( Type = \'Broker\' OR Type = \'Realtor Office\' ) ';  
         string accRelationQuery = 'SELECT Parent_Broker__c,Parent_Broker__r.Name,Type,Name,Party_ID__c,Customer_Id__c,Total_HLC__C,Total_CLC__c,BillingPostalCode, BillingCity, MLS_Set_Id__c  FROM Account WHERE ';  
         string wherecondition = '';
         string wildSearchString = '%';
//         string criteria1 = 'AND ( '; 
         string criteria2 = '';
         boolean criteriaMet = false;
         if(oaccountType != null && (oaccountType.Type != null || oaccountType.Account_Sub_Type__c != null)){
             boolean met = true;
            if(!string.isEmpty(oaccountType.Type) && !string.isEmpty(oaccountType.Account_Sub_Type__c)){
              criteria2 = criteria2 + ' ( Type = \'' + oaccountType.Type+ '\' ' + ' AND ' + ' Account_Sub_Type__c  = \''  + oaccountType.Account_Sub_Type__c + '\' ) ';   
            }
            else if(!string.isEmpty(oaccountType.Type)){
               criteria2 = criteria2 + ' ( Type = \'' + oaccountType.Type+ '\' ) ';                                                         
            }            
            else if(!string.isEmpty(oaccountType.Account_Sub_Type__c)){             
               criteria2 = criteria2 + ' ( Account_Sub_Type__c  = \''  + oaccountType.Account_Sub_Type__c + '\' ) ';   
            }             
            
          }
         string criteria1 = ''; 
             if(criteria2 != ''){
             criteria1 = criteria2 + ' AND ( ';
             }
             else{
             criteria1 = ' ( ';
             }
             
         
             if(!string.isEmpty(accName)){                                             
                 criteriaMet = true;                                                               
                criteria1 = criteria1  + ' Name LIKE   \'' + accName + wildSearchString + '\' '  ;                                                                        
             }
             
             if(!string.isEmpty(accPartyID)){
                 if(criteriaMet){
                     criteria1 = criteria1  + ' OR ';          
                     criteriaMet = false;
                 }
                 criteriaMet = true;         
                  partyIDset  = comma2Set(accPartyID); 
                  system.debug('***partyIDset***'+partyIDset);                                            
                    criteria1 = criteria1  + ' Party_ID__c IN: partyIDset'  ;                                           
                 
             }
             
             if(!string.isEmpty(acccustomerID)){
                 if(criteriaMet){
                     criteria1 = criteria1  + ' OR ';          
                     criteriaMet = false;
                 }
                 criteriaMet = true;    
                 customerIDset = comma2Set(acccustomerID);
                 criteria1 = criteria1  + ' Customer_Id__c IN:  customerIDset '  ;                                                       
             }

             if(!string.isEmpty(accZipcode)){
                 if(criteriaMet){
                     criteria1 = criteria1  + ' OR ';          
                     criteriaMet = false;
                 }
                criteriaMet = true;                    
                zipcodeSet = comma2Set(accZipcode);
                criteria1 = criteria1  + ' BillingPostalCode IN: zipcodeSet ';                                                        
             }
             if(!string.isEmpty(accCity)){
                 if(criteriaMet){
                     criteria1 = criteria1  + ' OR ';          
                     criteriaMet = false;
                 }
                criteriaMet = true;   
                criteria1 = criteria1  + ' BillingCity LIKE \'' + accCity+ wildSearchString  + '\' '  ;                                        
             }
             if(!string.isEmpty(accState)){
                 if(criteriaMet){
                     criteria1 = criteria1  + ' AND ';          
                     criteriaMet = false;
                 }
                criteriaMet = true;   
                criteria1 = criteria1  + ' BillingState LIKE \'' + accState+ wildSearchString  + '\' '  ;                                        
             }
                          
         
         if(!string.isEmpty(accMLS)){
                 if(criteriaMet){
                     criteria1 = criteria1  + ' OR ';          
                     criteriaMet = false;
                 }
                criteriaMet = true;   
                 MLSset= comma2Set(accMLS);
                  criteria1 = criteria1  + ' MLS_Set_Id__c IN: MLSset '  ;                                                       
             }
                          
                 
    
         criteria1 = criteria1  + ' ) ';         
         //accRelationQuery  = accRelationQuery + criteria1 + ' AND RecordType.DeveloperName = \'Account_Relationship\'  AND Active__c = '+ true + '  order by Name asc limit 49995';
         accRelationQuery  = accRelationQuery + criteria1 + '  order by Name asc limit 999';         
         system.debug('***accRelationQuery****'+accRelationQuery);
         accRelationList.clear();
         accountList.clear();
         accRelationBrokers.clear();
         accRelationOffices.clear();  
         accountBrokers.clear();
         accountOffices.clear();  
                  
         try{
                
         for(Account acc2 : database.Query(accRelationQuery ))  {
              accountList.add(new AccountWrapper(acc2,acc2.Parent_Broker__r.Name));   
             }
         }
         catch(exception e){
             system.debug('***exception***'+e);
         }
         system.debug('***accountList****'+accountList);   

                                 
         for(AccountWrapper accWrapper :accountList){
              if(accWrapper.acctype == 'Broker'){
                  accountBrokers.add(accWrapper);
              }
              if(accWrapper.acctype == 'Realtor Office'){
                  accountOffices.add(accWrapper);
              }              
          }          
          
          system.debug('***accRelationBrokers****'+accountBrokers);
          system.debug('***accRelationOffices****'+accountOffices);
         return null;
     } 
    
    public set<String> comma2Set(string str)
    {
        if(!String.isEmpty(str)){
            set<String> tempSet = new set<String>();
                for(String ostr:str.split(',')){
					ostr = ostr.trim(); //Added by Ravi CRM-1370 to remove the space affecting the search. comma2Set is only used for Zip Code, Party Id, Customer Id & MLS Set Id. 
                    tempset.add(ostr);
                }
                return tempset;
            }
        else
            return new set<String>();
    }    
    
    public string getfieldsfromSobject(string SobjectApiName)
    {
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
 
        String commaSepratedFields = '';
        for(String fieldName : fieldMap.keyset()){
            if(commaSepratedFields == null || commaSepratedFields == ''){
                commaSepratedFields = fieldName;
            }else{
                commaSepratedFields = commaSepratedFields + ', ' + fieldName;
            }
        }
        return 'SELECT ' + commaSepratedFields ;
    }
    
    public string  submitlogic(string accid)
    {
            // clone and insert new account    
             list<Account> acclist = database.query(getfieldsfromSobject('Account') + ' FROM Account  WHERE Id =: accid LIMIT 1 ');                         
             Account theAccount = acclist[0].clone();
             
             theAccount.Type = 'Broker';
             theAccount.Account_Sub_Type__c = 'Prospect';
             theAccount.Name = theAccount.Name + ' - Broker';
             theAccount.OwnerID = userinfo.getuserID();
             theAccount.Party_ID__c = '';
             theAccount.MLS_Set_Id__c = '';
             theAccount.Broker_NAR_Id__c = '';
             theAccount.Account_NAR_Id__c = '';
             theAccount.AdvertiserID__c = '';
             //theAccount.Display_Name__c = theAccount.Name + ' Broker';
              theAccount.Customer_Id__c = '';
              theAccount.Billing_Preference__c ='Invoice-CC';
             // CRM-1376
             theAccount.Ship_To_External_Id__c = '';
             theAccount.Bill_To_External_Id__c = '';
             theAccount.Website_row_id__c = '';
             //Commented as part of Jira SMCI-554
             //theAccount.Other2_Email_Row_ID__c = '';
             //theAccount.Other1_Email_Row_ID__c = '';
             //theAccount.Advertiser_Email_Row_ID__c = '';
             //theAccount.MLS_Email_Row_ID__c = '';
             //theAccount.Primary_Email_Row_ID__c = '';
             theAccount.Fax_Row_Id__c = '';
             //theAccount.Mobile2_Other_Row_Id__c = '';
             //theAccount.Mobile1_Row_Id__c = '';
             //theAccount.Home_Phone_Row_Id__c = '';
             //theAccount.Work_Phone_Row_ID__c = '';

             insert theAccount; 
             System.debug('>>>>>theAccount'+theAccount);
             //sendaccountdetails(theaccount.id);            
            // String Response = new xmlnsOracleComInt003ContactSyncacco.SyncAccountSFDCToCDHServiceBindingQSPort().process(theAccount.ID,'Account');                                                                                        
            // system.debug('***response***'+Response );
             // get account relation ship records for contact relatiohsip record type
            list<Account_Relationship__c> accRelationsnew = new list<Account_Relationship__c>();
            
            for(Account_Relationship__c  acc2 : [SELECT Broker_of_Record__c,Contact_Role__c,Active__c,Relationship_Type__c,Billing_Contact__c,Parent_Account__c,Parent_Account__r.Type,Contact_To__c,Contact_To__r.Type__c,Child_Account__c,Child_Account__r.Type FROM Account_Relationship__c WHERE Parent_Account__c =: this.acct.ID AND RecordType.DeveloperName = 'Contact_Relationship' AND Active__c = true AND (Broker_of_Record__c = true OR Contact_Role__c = 'Primary Contact') order by Name asc limit 49995])  {                                    
                Account_Relationship__c temp = acc2.clone();
                temp.Parent_Account__c = theAccount.ID;
                accRelationsnew.add(temp) ;          
            }
            if(!accRelationsnew.isEmpty())
                insert accRelationsnew; 
        return theAccount.Id + '';
        
        
        
    }
    
     @future(callout=true)
    public static void sendaccountdetails(string accid){
        if(!test.isRunningTest()){
     String Response = new xmlnsOracleComInt003ContactSyncacco.SyncAccountSFDCToCDHServiceBindingQSPort().process(accid,'Account');                                                                                        
             system.debug('***response***'+Response );
        }
  }
    
    
    
    
        
}