global class MoveSalesScrpopRulephase2
{

    public Static List<List<sObject>> qResults {get;set;}
    public Static String cResults{get;set;}
    
    public  Static List<Account> AccountResults{get;set;}
    public  Static List<Contact> ContactResults{get;set;}
    public  Static List<Lead> LeadResults{get;set;}
    public  Static List<Case> CaseResults{get;set;}
    public  Static List<Opportunity> OpportunityResults{get;set;}
    public  Static List<Campaign> CampaignResults{get;set;}

    
    public Static boolean singleAccount = false;
    public Static boolean singleLead = false;
    public Static boolean aniMatchLead = false;
    
    public String cParams;


    public MoveSalesScrpopRulephase2(){
    
        AccountResults = null;
        ContactResults = null;
        LeadResults = null;
        CaseResults = null;
        OpportunityResults = null;
        CampaignResults = null;
        
        Map<String,String> params = ApexPages.currentPage().getParameters();
        if(params.size() > 0) {
        cParams= params.get('params');
        }
        
        cResults = search(cParams);
      
    
    }
  
    public PageReference doRedirect() {
        // Add the account to the database. 
        PageReference pageRef;
        if(AccountResults == null &&
        ContactResults == null &&
        LeadResults == null &&
        CaseResults == null &&
        OpportunityResults == null &&
        CampaignResults == null)
        {
        
             pageRef = new PageReference('/003/e');
             pageRef.setRedirect(true);
        }
        else
        {
            pageRef = null;
        }
         
      
        return pageRef;
    }

    

    static Boolean isEmpty (List <List <sObject>> oList) {
    
        if ( oList.size() == 0 ) return true;
        Boolean empty = true;
        cleanLists();
        for ( List<sObject> subList : oList ) {
            
            subList = filterResults(subList);
            if ( subList.size() > 0 ) {
                empty = false;
            }
        }
        return empty;
    }
      
    static void cleanLists()
    {
    
        AccountResults = null;
        ContactResults = null;
        LeadResults = null;
        CaseResults = null;
        OpportunityResults = null;
        CampaignResults = null;
        
    
    }
    static List <sObject> filterResults(List <sObject> qry) {
            if(qry == null || qry.size() < 1) return qry;
            
            List <sObject> tmp = new List <sObject>();
            SObjectType sObjectType = qry.getSObjectType();
            
             for (sObject obj: qry) {

            if(sObjectType == Account.sObjectType)
            {
                 Account tAccount = (Account)obj;
                 if(tAccount.Account_Status__c != null && tAccount.Account_Status__c.equals('Active'))
                     {
                     tmp.add(tAccount);
                     if(AccountResults == null) AccountResults = new List<Account>();
                     AccountResults.add(tAccount);
                     }
            }
            
            else if(sObjectType == Contact.sObjectType)
            {
                 Contact tContact= (Contact)obj;
                 if(tContact.Active__c != null && tContact.Active__c)
                     {
                     tmp.add(tContact);
                     if(ContactResults == null) ContactResults = new List<Contact>();
                     ContactResults.add(tContact);
                     }
            }
            
            else if(sObjectType == Lead.sObjectType)
            {
                 Lead tLead= (Lead)obj;
                 if(tLead.Status != null && (tLead.Status.contains('Open') || tLead.Status.contains('In Progress') || tLead.Status.contains('New')) )
                 {
                 tmp.add(tLead);
                  if(LeadResults == null) LeadResults =  new List<Lead>();
                 LeadResults.add(tLead);
                 }
            }

            else if(sObjectType == Campaign.sObjectType)
            {
                 Campaign tCampaign= (Campaign)obj;
                 if(tCampaign.IsActive != null && tCampaign.IsActive)
                 {
                     tmp.add(tCampaign);
                     if(CampaignResults == null) CampaignResults = new List<Campaign>();
                     CampaignResults.add(tCampaign);
                 }
            }
        }
              
          if(tmp != null && tmp.size() > 0)
           { 
               if(qResults == null) qResults = new List<List<sObject>>();
               
               qResults.add(tmp);  
           }
          return tmp;
    }
     
  
     
    static boolean searchDNIS(String SQL) {
    
        // SOSL: 'FIND \'1001\' IN PHONE FIELDS RETURNING Account(ID, Name), Contact(ID, Name)'
        // serializes into an array of arrays of JSON [[JSON1],[JSON2],...]
        //system.debug('**searchDNIS  run1:' + SQL);   
        List <List <sObject>> qry = search.query(SQL);
            
                                
            if ( isEmpty(qry) ) {
                return false;
            }
            
            boolean found = false;
            

            for (List<Campaign> res: qry) {
            
               for (Campaign cpg: res) {
                   if(cpg.isActive)
                   {
                       found = true;

                   }                            

                }
            } 
            
            return found;
            
           
    } 
    

    static String searchAccount(String[] SQL, boolean activeCampaign) {
        // SOSL: 'FIND \'1001\' IN PHONE FIELDS RETURNING Account(ID, Name), Contact(ID, Name)'
        // serializes into an array of arrays of JSON [[JSON1],[JSON2],...]
            List <List <sObject>> qry = search.query(SQL[1]);
        
            Integer resultcount = 0;
            Account AccountToUse = null;
                                    
            if ( isEmpty(qry) ) {
               
                return searchLead(SQL,activeCampaign);
            }
            else
            {
                    cleanLists();
                  for (List<Account> res: qry) {
            
                        res = filterResults(res);
                        
                       for (Account act: res) {
                           
                            resultcount =  resultcount + 1;
                            AccountToUse = act;
                        }
                   } 
           
            
                  if(resultcount == 1) 
                  {
                    
                      if(activeCampaign)
                      {
                            
                           matchLead(AccountToUse, SQL);
   
                      }
                      
                      qResults = null;
                      cleanLists();
                      for (List<sObject> param : qry) {
                      
                           param = filterResults(param);
            
                           //setResults(param); 
                      }   
                          
                     return JSON.serialize(qResults);
                     
                  }  
                  else
                  {
        
                     if(!activeCampaign)
                     {
  
                        return searchACL(SQL[5]);
                     }
                     else
                     {     
                          return searchACL(SQL[6]);
                     }
                  } 
            }
    }  
    
     static String matchLead(Account act, String[] SQL) {//pass in the lead
         
            
            List <List <sObject>> qry = search.query(SQL[3]);
              if (!isEmpty(qry) ) {
                          
                return 'lead found'; 
            }
                       
              
                Lead newLead = new Lead();
                newLead.Account__c = act.Id;
                newLead.LastName = act.Name;
                newLead.Company = act.Name;
                newLead.Status = 'new';
                newLead.Marketing_Lead_Type__c = 'Inbound Call Leads';  
                newLead.LeadSource =  'Phone';             
                insert newLead;
                return newLead.Id;
           

                      
    } 
    
  
    static String searchLead(String[] SQL, boolean activeCampaign) {
         List <List <sObject>> qry = search.query(SQL[3]);
            
            Integer resultcount = 0;
                                   
            if ( isEmpty(qry) ) {
                         
                return searchContact(SQL,activeCampaign);
            }
            
            cleanLists();
            for (List<Lead> res: qry) {
            
             res = filterResults(res);
             
               for (Lead ld: res) {
                   
                       resultcount =  resultcount + 1;
                           

                }
            } 
            
            
          if(resultcount == 1) 
          {
              qResults = null;
              cleanLists();
              for (List<sObject> param : qry) {
            
                  param = filterResults(param);
                 //setResults(param); 
              }   
                      
             return JSON.serialize(qResults);
          }   
          else
              return searchACL(SQL[4]);

    } 
    
     static String searchContact(String[] SQL, boolean activeCampaign) {
       
         List <List <sObject>> qry = search.query(SQL[2]);
            
            Integer resultcount = 0;
                                
            if ( isEmpty(qry) ) {
                  
                if(!activeCampaign)
                {
                
                    return null;
                }
                else
                {
                    
                    return searchACL(SQL[0]);
                }
                    
            }
            
            qResults = null;
            cleanLists();
            for (List<sObject> param : qry) {
                param = filterResults(param);
          
            }   
                      
            return JSON.serialize(qResults);
          

    } 
    
    static String searchACL(String SQL) {
  
        // SOSL: 'FIND \'1001\' IN PHONE FIELDS RETURNING Account(ID, Name), Contact(ID, Name)'
        // serializes into an array of arrays of JSON [[JSON1],[JSON2],...]
            List <List <sObject>> qry = search.query(SQL);
            Integer resultcount = 0;
           
                                 
            if ( isEmpty(qry) ) {
                return null;
            }
            
            return JSON.serialize(qry); 
    }  
       
 
     
    /**
     * Search using a param sequence
     * @param params: var1=val1,var2=val2,...
     */
    webService static String search (String params) 
    {
        // TODO: fetch SQL from some SF table
        String[] SQL = new String[7];
        
         SQL[0] = 'FIND \'${dnis}\' IN ALL FIELDS RETURNING Campaign(ID, Name, IsActive, Type, Status,StartDate, EndDate,OwnerId,Owner.Alias)';
         SQL[1] = 'FIND \'${ani}\' IN PHONE FIELDS RETURNING Account(ID, Name, Site,Phone,OwnerId,Owner.Alias,MLS_Set_Id__c,Account_Status__c,BillingAddress,Type,Email_Address__c,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,Owner.Name)';
         SQL[2] = 'FIND \'${ani}\' IN PHONE FIELDS RETURNING Contact(ID, Name,AccountId, Account.Name, Account.Site,Phone,OwnerId,Owner.Alias,Email,Active__c)';
         SQL[3] = 'FIND \'${ani}\' IN PHONE FIELDS RETURNING Lead(ID, Name, Title,Company,Email,Status,OwnerId,Owner.Alias)';
         SQL[4] = 'FIND \'${ani}\' IN PHONE FIELDS RETURNING Lead(ID, Name, Title,Company,Email,Status,OwnerId,Owner.Alias),Contact(ID, Name,AccountId, Account.Name, Account.Site,Phone,OwnerId,Owner.Alias,Email,Active__c)';    
         SQL[5] = 'FIND \'${ani}\' IN PHONE FIELDS RETURNING Account(ID, Name, Site,Phone,OwnerId,Owner.Alias,MLS_Set_Id__c,Account_Status__c,BillingAddress,Type,Email_Address__c,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,Owner.Name),Lead(ID, Name, Title,Company,Email,Status,OwnerId,Owner.Alias),Contact(ID, Name,AccountId, Account.Name, Account.Site,Phone,OwnerId,Owner.Alias,Email,Active__c)';    
         SQL[6] = 'FIND {${ani} OR ${dnis}} IN ALL FIELDS RETURNING Account(ID, Name, Site,Phone,OwnerId,Owner.Alias,MLS_Set_Id__c,Account_Status__c,BillingAddress,Type,Email_Address__c,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,Owner.Name),Campaign(ID, Name, IsActive, Type, Status,StartDate, EndDate,OwnerId,Owner.Alias),Contact(ID, Name,AccountId, Account.Name, Account.Site,Phone,OwnerId,Owner.Alias,Email,Active__c)';    
                
        // extract params: var1=val,va2=val2,...
        List<String> oParams = params.split(',', 0);
        
        for (String param : oParams ) {
            String[] keyVal = param.split('=', -1);
            
            if ( keyVal.size() != 2 ) 
                continue;
                
            String varName   = '${' + keyVal[0] + '}';  // var name ${ani}, ${status},...
            String varVal    = keyVal[1];
            

            
            // replace
            for (Integer i = 0 ; i < SQL.size() ; i++ ) {
                SQL[i] = SQL[i].replace(varName, varVal);
            }
        }

        String result = null;     
        if ( searchDNIS(SQL[0]) ) {
       
             result = searchAccount(SQL,true);     
            if(result == null)
                return JSON.serialize(null);
            else
                return result;
        }
        else
        {
        
            result = searchAccount(SQL,false);  
            if(result == null)
                return JSON.serialize(null);
            else
                return result;
        
        }

    }


}