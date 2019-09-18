global class BatchRealSuiteBundleRenewalProcess implements Database.Batchable<sObject>,Database.AllowsCallouts{

/************ Global variable *********/
//global final set<String> setProductCodeAdd = new set<String>{'RSRESPOND','RSCONNECT','RSTRANSACT'};
global final set<String> setProductCodeAdd = new set<String>{};
//global final set<String> setProductCodeAmend = new set<String>{'TOPCRM','TOPMRKSNP','FIVESTREET'};
global final set<String> setProductCodeAmend = new set<String>{};
global final map<Id,id>lstAccount;
global  map<Id,String> mapQuoteNumber;
public BatchRealSuiteBundleRenewalProcess(map<Id,Id> AccountIds)
{
    lstAccount = AccountIds;
}



global Database.querylocator start(Database.BatchableContext BC){
system.debug('lstAccount---'+lstAccount);
Set<Id> setAllAccountIds = new Set<Id>();
setAllAccountIds.addAll(lstAccount.keyset());
string Query = 'select id,ownerid,owner.username,Name from Account where id in:setAllAccountIds';
    return Database.getQueryLocator(query);
}

global void execute(Database.BatchableContext BC, List<Account> scope)
{
   
    map<id,map<string,Asset>>MapAccountAssests = new map<id,map<string,Asset>>();
    WebserviceCallBigMachineQuoteCls createquote = new WebserviceCallBigMachineQuoteCls();
   
    system.debug('scope'+scope);
   
    /********* get Acitve Products ********/
      for(Asset objAsset: [Select accountId, Product2.ProductCode, Promotion__c FROM Asset where asset.accountId IN: scope AND status = 'Active' and Product2.ProductCode in : setProductCodeAmend])
      {
         if(MapAccountAssests.containskey(objAsset.accountId))
         {
             MapAccountAssests.get(objAsset.accountId).put(objAsset.Product2.ProductCode,objAsset);
         }
         else
         {
             MapAccountAssests.put(objAsset.accountId,new map<string,Asset>{objAsset.Product2.ProductCode=>objAsset});
         }
      }
      
      for(account  objAcc: scope){
            /**** Add all Lines ********/
             list<CreateWaitlistQuoteWrapper> quotedata = new list<CreateWaitlistQuoteWrapper>();
              /**** Add all Lines ********/
                 for(string s1 : setProductCodeAdd)
                 {
                    string uniqueRecordId=getRandomNumber();
                    string ProductCode =s1;
                    string productSize='Standard';
                    string productType='Standard';
                    string Email='';
                    integer priceTier=1;
                    date priceEffectiveDate=system.today();
                    string lineType='Add';
                    CreateWaitlistQuoteWrapper tempdata = createQuoteData(uniqueRecordId,ProductCode, productSize,productType,Email,  priceTier, priceEffectiveDate,lineType);
                     quotedata.add(tempdata);
                 }
                 /*************** Amend **************/
                 for(string objAmend : setProductCodeAmend)
                 {
                     if(MapAccountAssests.containskey(objAcc.id))
                     {
                         if(MapAccountAssests.get(objAcc.id).containskey(objAmend))
                         {
                            asset objassets= MapAccountAssests.get(objAcc.id).get(objAmend);
                            string uniqueRecordId=getRandomNumber();
                            string ProductCode =objAmend;
                            string productSize='Standard';
                            string productType='Standard';
                            string Email='';
                            integer priceTier=1;
                            date priceEffectiveDate=system.today();
                            string lineType='Amend';
                            CreateWaitlistQuoteWrapper tempdata = createQuoteData(uniqueRecordId,ProductCode, productSize,productType,Email,  priceTier, priceEffectiveDate,lineType);
                             quotedata.add(tempdata);
                         }
                     }
                 }
                 if(!Test.isRunningTest()){
                 System.debug('My Test Quote'+mapQuoteNumber);
                 createquote.mapQuoteAccountWebservice = mapQuoteNumber;
                 String  sfdcquoteid = createquote.CreateWaitlistQuote(null,null,
                                                                  objAcc.id,lstAccount.get(objAcc.id),null,'New','CFBQuote',
                                                                  false,true,null,
                                                                  objAcc.owner.username,objAcc.ownerid,quotedata);
                                                                  }

                  
             //   }
                 
                 
      }
      
      
         
                                          
}

    
  
    global void finish(Database.BatchableContext BC){            
    }
    
    /*************
     * Description : This method is used to create Quote data
     * Created by : Sonu
     * Created Date: 06/28/2018
     ******************/
    public static CreateWaitlistQuoteWrapper createQuoteData(string uniqueRecordId,string ProductCode, string productSize,string productType,
                                                      string Email, integer priceTier, date priceEffectiveDate,string lineType)
    {
        
        
        CreateWaitlistQuoteWrapper tempdata1 = new CreateWaitlistQuoteWrapper();
        tempdata1.uniqueRecordId     = uniqueRecordId;
        tempdata1.ProductCode        = ProductCode;
        tempdata1.productSize        = productSize;
        tempdata1.productType        = productType;
        tempdata1.Quantity           = 1;
        tempdata1.Term              =  12;
        tempdata1.Email              = Email;
        tempdata1.priceTier          = priceTier;
        tempdata1.priceEffectiveDate = priceEffectiveDate;
        tempdata1.lineType =lineType; 
         
        return tempdata1;
         
    }
    
    public static Opportunity InsertOpportunity(list<CreateWaitlistQuoteWrapper> quotedata,Account acct) {
    Opportunity theOpportunity = new Opportunity();
             //  for (CreateWaitlistQuoteWrapper loop1 : quotedata){
            //Insert opportunity
            //Opportunity theOpportunity = new Opportunity(
                //Name            = acctdata.get(loop1.Account__c).Name.replace(' ','-') + '-' + Datetime.now().format('yyyy-MM-dd'),
                theOpportunity.Name            = acct.Name.replace(' ','-') + '-' + Datetime.now().format('yyyy-MM-dd');
                theOpportunity.StageName       = 'Prospecting';
                theOpportunity.CloseDate       = system.today();
                theOpportunity.AccountId       = acct.Id;
                theOpportunity.Account_Type__c = 'Short';
            insert theOpportunity;
            //return theOpportunity;
            //loop1.Opportunity__c = theOpportunity.id;
        //}
       // waitlistitemTriggerHandler.skipbeforeupdaterun = true;
       return theOpportunity;
    }
    
    public string getRandomNumber()
    {
        integer len=10;
        final string chars='0123456789';
        string randstr='';
        while(randstr.length()<len)
        {
            integer idx=math.mod(math.abs(Crypto.getRandomInteger()),chars.length());
            randstr+=chars.substring(idx,idx+1);
            
        }
        
        
        
        return randstr;
        
    }
}