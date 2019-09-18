global with sharing class CreateMyQuoteControllerWL {
Public string usessionid{get;set;}
private final Account acct;
public String bmsessionid{get;set;}
    public String AccountId ='';
    public String OpportunityId ='006Z000000EnQMl';
    public String CaseId ='';
    public String quoteType{get;set;}
    public boolean autoprocess=false;
    public Set<Id> setAssetIds = new Set<Id>();
    public Map<Id,Integer> mapAssetIDDocumentNumber = new Map<Id,Integer>();
    public List<MyQuote> mQuoteItems{get;set;}
   

    private string mToken;
        private  string mMarket ='94010';
        private  string mMarkettype='Postal Code' ;
    //  private  string mAccountId ='12345';
         private  string mAccountId ;
        private  string mStatus ;
        private  string mDegree ;
        private  string mLeadroutingtype ;
        private  string mSlotsize ;
        private  string mMarketspend ;
        private  string mJson ;
        private string mnotes ;
        private string mqtyinterested;
        private string moperation;
        private string mMyOrderBy ='OrderByDesc=InventoryAvailableFlex';
        private string mMyFilter ='';
        private string mMyLimit = 'Take=10';
        private string mMyPageNo = 'Skip=1';
        
             
public string mSetting_CPQURL {get;set;}
public string mSetting_CPQFULLURL {get;set;}
public string mSetting_CPQUSER {get;set;}
public string mSetting_CPQPASSWORD {get;set;}
       
        


  public void setToken(String newvalue) 
        
        { 
            
            // do nothing 
            
            mToken = newvalue;
            System.debug('Hello');
            //return mToken;
            
        }
        
        public string getToken()
        
        { 
            
            // do nothing 
            
            return mToken ;
            
            
        } 
        
            
        public void setDegree(String newvalue) 
        
        { 
            
            // do nothing 
            
            mDegree = newvalue;
            System.debug('Hello');
            
            
        }
        
        public string getDegree()
        
        { 
            
            // do nothing 
            
            return mDegree ;
            
            
        }
        
        
            
        public void setSlotSize(String newvalue) 
        
        { 
            
            // do nothing 
            
            mSlotSize = newvalue;
            System.debug('Hello');
            
        }
        
        public string getSlotSize()
        
        { 
            
            // do nothing 
            
            return mSlotSize ;
            
            
        } 
        
         
            
        public void setLeadRoutingType(String newvalue) 
        
        { 
            
            // do nothing 
            
            mLeadRoutingType = newvalue;
            System.debug('Hello');
            
        }
        
        public string getLeadRoutingType()
        
        { 
            
            // do nothing 
            
            return mLeadRoutingType ;
            
            
        } 
        
        
    
        public void setStatus(String newvalue) 
        
        { 
            
            // do nothing 
            
            mStatus = newvalue;
            System.debug('Hello');
            
        }
        
        public string getStatus()
        
        { 
            
            // do nothing 
            
            return mStatus ;
            
            
        }       
        
               
        
     
                public void setAccountId(String newvalue) 
        
        { 
            
            // do nothing 
            
            mAccountId = newvalue;
            System.debug('Hello Setting Account Id ' + newvalue);
           
        }
        
        public string getAccountId()
        
        { 
            
            // do nothing 
            
            return mAccountId ;
            
            
        } 
        
        
        public void setNotes(String newvalue) 
        
        { 
            
            // do nothing 
            
            mNotes = newvalue;
            

            
        }
        
        public string getNotes()
        
        { 
            
            // do nothing 
            
            return mNotes ;
            
            
        } 
        
        
        
        
        public void setqtyinterested(String newvalue) 
        
        { 
            
            // do nothing 
            
            mqtyinterested = newvalue;
            

            
        }
        
        public string getqtyinterested()
        
        { 
            
            // do nothing 
            
            return mqtyinterested ;
            
            
        } 
        
        
        
        public void setoperation(String newvalue) 
        
        { 
            
            // do nothing 
            
            moperation = newvalue;
            

            
        }
        
        public string getoperation()
        
        { 
            
            // do nothing 
            
            return moperation;
            
            
        }   
        
        
        public string getMyOrderBy()
        
        { 
            
            // do nothing 
            
            return mMyOrderBy;
            
            
        } 
        
        
            
        public void setMyOrderBy(String newvalue) 
        
        { 
            
            // do nothing 
            
            mMyOrderBy = newvalue;
            

            
        }
        
            public string getMyFilter()
        
        { 
            
            // do nothing 
            
            return mMyFilter;
            
            
        } 
        
        
            
        public void setMyFilter(String newvalue) 
        
        { 
            
            // do nothing 
            
            mMyFilter = newvalue;
            

            
        }
        
        public string getMyLimit()
        
        { 
            
            // do nothing 
            
            return mMyLimit;
            
            
        } 
        
        
            
        public void setMyLimit(String newvalue) 
        
        { 
            
            // do nothing 
            
            mMyLimit = newvalue;
            System.debug(mMyLimit);

            
        }



Public String opptId{get;set;}
global CreateMyQuoteControllerWL(ApexPages.StandardController stdController) {
usessionid=UserInfo.getSessionid();
opptId = ApexPages.currentPage().getParameters().get('oppId');
        
        try
        {
            this.acct = (Account)stdController.getRecord();
            
         //     Id accountId = ApexPages.currentPage().getParameters().get('accountId');
                            
                        //    if (accountId ==null)
                          //  {
                            //  accountId = acct.id ;
        
         mQuoteItems = new  List<MyQuote>();
                        
                            //}
        }catch (exception e )
        {
         System.debug('Account is null' );
        
        }                   
                            
}


  public CreateMyQuoteControllerWL() { // added a comment
  }






  global PageReference createQuote() {
    Id accountId = ApexPages.currentPage().getParameters().get('accountId');
    
    if (accountId ==null)
    {
        accountId = acct.id ;
        
    }
    
 //   ID oppId = createOpportunity();
    String protocol = 'https://';
    String baseURL = System.URL.getSalesforceBaseUrl().getHost().remove('-api');
   // PageReference pageRef = new PageReference(protocol + baseURL +'/apex/BigMachines__QuoteEdit?oppId='+oppId+'&actId='+accountId);  
    
      PageReference pageRef = new PageReference(protocol + baseURL +'/apex/BigMachines__QuoteEdit?&actId='+accountId+'&siteid='+CreateQuoteController.oracleId);      //CRM-5484 - Added Siteid     
      
    return pageRef;
  }
  
   
   global pageReference CallQuote()
    {
        set<Id> assetIds;
        PageReference pr =null;
        string caseid;
        boolean returnCPQ=true;
        
        
pr = createMyQuote(
 mtoken, mDegree, mSlotSize,mAccountId,
 caseid ,returnCPQ, assetIds );
 


 
 
 
 /*   <apex:param name="firstParam" assignTo="{!token}" value="" />
        <apex:param name="secondParam" assignTo="{!Degree}" value="" />
        <apex:param name="thirdParam" assignTo="{!SlotSize}" value="" />
        <apex:param name="fourthParam" assignTo="{!AccountId}" value="" />
        <apex:param name="fifthParam" assignTo="{!LeadRoutingType}" value="" /> 
        <apex:param name="sixthParam" assignTo="{!status}" value="" />
        <apex:param name="sixthParam" assignTo="{!status}" value="" />
 */

return pr;
        
    }  
  
Public date clsdate{get;set;}
global pageReference createMyQuote(
String username,string password,string accountId,
String opportunityid , String caseid ,boolean returnCPQ,
set<Id> assetIds

/*,string caseid,boolean returnCPQ,set<Id> assetIds
*/
){
clsdate = System.today();
/*String username;
string password;
string accountId;
String opportunityid;*/

QuoteWrapper QW = new QuoteWrapper();
 username ='arunsharma';
 password ='CPQ123';
        
 List<MyQuote> li = new  List<MyQuote>();           
        
        
//QW.setAssetIds = assetIds;
string bmsessionid = QW.GetSessionId(username,password);
System.debug('Arun Session Id is ' + bmsessionid );
System.debug('Arun CPQreturn Id is ' + returnCPQ );

PageReference pr =null;

if(returnCPQ==true){
        
        
//pr = new PageReference('https://devmoveinc.bigmachines.com/commerce/buyside/document.jsp?bm_cm_process_id=36244034&formaction=performAction&document_id=36244074&action_id=36244076&version_id=36306984&id='+CreateBigMachineQuote());

//pr = new PageReference('https://devmoveinc.bigmachines.com/commerce/buyside/document.jsp?bm_cm_process_id=36244034&formaction=performAction&document_id=36244074&action_id=36589793&version_id=36306984&id='+CreateBigMachineQuote());

//pr = new PageReference('https://devmoveinc.bigmachines.com/commerce/buyside/document.jsp?bm_cm_process_id=36244034&formaction=performAction&document_id=36244074&action_id=36244076&version_id=36306984&id='+QW.CreateBigMachineQuote( li));
pr = new PageReference('https://devmoveinc.bigmachines.com/commerce/buyside/document.jsp?bm_cm_process_id=36244034&formaction=performAction&document_id=36244074&action_id=36244076&version_id=36306984');

System.debug('Return CPQ True pr ' + pr );
        

pr.setRedirect(true);
}
return pr;
}



    
    
    @RemoteAction
     global static pageReference CreateMyQuoteProc ( List<MyQuote> lQuoteItems)
    {
    
      
       List<MyQuote>  myQuoteItems =  lQuoteItems ;
     //   mExparam =ex;
     
  //   string username ='arunsharma';
  
      QuoteWrapper QW = new QuoteWrapper();             
          
//string bmsessionid = QW.GetSessionId(username,password);
//System.debug('Arun Session Id is ' + bmsessionid1 );

 string tmpAccId ;
 string tmpOppId ;
 
 System.debug('lQuoteItems' + lQuoteItems);
                   for (MyQuote li : lQuoteItems )
                   {
                                
                        if (li.sfdcid != tmpAccId &&  li.sfdcid!=null )
                        {
                         
                                                          try 
                                                          {
                                                                                      
                                                           
                                                           
                                                            if (QW.MyUserName == null)
                                                            {
                                                               QW.MyUserName = li.username;
                                                               QW.MyPassword = li.password;
                                                            }
                                                            QW.AccountId = li.sfdcid;
                                                            li.partyid = li.party_id; // duplicate , need to remove one
                                                            QW.party_Id = li.party_id; //li.party_id to be used
                                        
                                        System.debug('Create Opportunity Called ' + QW.AccountId );
                                            
                                                            tmpAccId =  li.sfdcid ; 
                                                    
                                        
                                                   //           li.opportunityId =      QW.CreateOpportunity();      // commenting this for the meantime as I am getting error with uncommiting transaction , call out combo . Need to split in two calls .           
                                                     //   QW.opportunityid = li.opportunityId; 
                                                      
                                                        if (li.OpportunityId ==  null)
                                                        {
                                                        li.OpportunityId ='006Z000000EnQMl';
                                                        QW.opportunityid = li.opportunityId; 
                                                        }
                                                        tmpOppId =  li.OpportunityId;
                                                
                                    
                                                         
                                                         
                                                         
                                                          }catch (exception e)
                                                          {
                                                                 System.debug('Create Opportunity Failed ' +e.getMessage());
                                                          }     
                                                          
                                                  }
                       
                         
                   else
                   {
                        li.OpportunityId = tmpOppId;
                        
                        
                   }     
                   
                   //    QW.sfdcid = li.sfdcid;
                                 QW.OpportunityId =li.OpportunityId ;
                   
                        }       



PageReference pr =null;

if(QW.returnCPQ==true){
        
        
//pr = new PageReference('https://devmoveinc.bigmachines.com/commerce/buyside/document.jsp?bm_cm_process_id=36244034&formaction=performAction&document_id=36244074&action_id=36244076&version_id=36306984&id='+CreateBigMachineQuote());

//pr = new PageReference('https://devmoveinc.bigmachines.com/commerce/buyside/document.jsp?bm_cm_process_id=36244034&formaction=performAction&document_id=36244074&action_id=36589793&version_id=36306984&id='+CreateBigMachineQuote());

//pr = new PageReference('https://devmoveinc.bigmachines.com/commerce/buyside/document.jsp?bm_cm_process_id=36244034&formaction=performAction&document_id=36244074&action_id=36244076&version_id=36306984&id='+QW.CreateBigMachineQuote(lQuoteItems , QW));

pr = new PageReference(QW.CreateBigMachineQuote(lQuoteItems , QW));
System.debug('Return CPQ True pr =' + pr );
        

pr.setRedirect(true);
}
return pr;
          
          
          
          
        
        
    }
    
    
    
  
    
     global class MyQuote
    {
        
   public  string username {get;set;}
    public string password {get;set;}
        
     public string market {get;set;}
     public string party_id  {get;set;}
     public string  geotype {get;set;}
     public string qtyinterested {get;set;}
     public string slotsize {get;set;}
     public string leadroutingtype {get;set;}
     public string product {get;set;}
     public string sfdcid  {get;set;}
     public String partyId {get;set;}
    public String OpportunityId {get;set;}
    public String CaseId {get;set;}
    public integer MarketTier {get;set;}        
        
       global MyQuote()
        {
        
      MarketTier =1;
    
                
        }
        
    }
    
    public class QuoteWrapper 
    {
    public String bmsessionid{get;set;}
    public String AccountId {get;set;}
    public String LeadId {get;set;}
    public String OpportunityId {get;set;}
    public String CaseId {get;set;}
    public String party_Id {get;set;}
    public String quoteType{get;set;}
    public boolean autoprocess=false;
    public Set<Id> setAssetIds = new Set<Id>();
    public Map<Integer,Integer> mapAssetIDDocumentNumber = new Map<Integer,Integer>();
    public List<MyQuote> mQuoteItems{get;set;}
    public integer assetid; 
    public String myUserName {get;set;}
    public String myPassword {get;set;}
    
    
        public Date renewalstartdate=System.today();
                public       Date renewalenddate=System.today().addMonths(6);
                public       String contractterm ='6';
                public       String prodemail='arun.sharma@move.com';
                public       String billingperiod='Monthly';
                public       String commercegrp='';
                public       String hlcoverride ='';
                public       String msaTier ='';
                public       Decimal assetpricee = 0.0;
                public       string ProductCode = 'Cobroke';
            public          set<Id> assetIds      ;
                public boolean returnCPQ = true ;
        public string Top_Connector='';
        public string Featured_Mortgage='';
        public string Suppress_Welcome_Calls='';
        public string Create_Broker_Tools='';
    
       
    
    
        public QuoteWrapper()
        {
                              renewalstartdate=System.today();
                              renewalenddate=System.today().addMonths(6);
                              contractterm ='6';
                              prodemail='arun.sharma@move.com';
                              billingperiod='Monthly';
                              commercegrp='';
                              hlcoverride ='';
                              msaTier ='';
                              assetpricee = 0.0;
                              ProductCode = 'Cobroke';
                             assetIds =null     ;
                              quoteType='New';
                              autoprocess=false;
                             returnCPQ = true ;
    
        }
        
       
 public String GetSessionId(string username,string password){
HttpRequest req = new HttpRequest(); 
 String tidd='';
  //Set HTTPRequest Method
  req.setMethod('POST');
  
     String CPQUSER = BigMachineUrls__c.getInstance('WLBM').DefaultUserName__c;
     String CPQPASSWORD = BigMachineUrls__c.getInstance('WLBM').DefaultPassword__c;
             
        
String cpqreceiver=  Waitlist_Urls__c.getInstance('CPQReciever').url__c;
String CPQXSD =Waitlist_Urls__c.getInstance('CPQXSD').url__c;
  
  if (username ==null)
  {
        username =  CPQUSER;
        password = CPQpassword;
        
  }
  
  
  //https://devmoveinc.bigmachines.com/v1_0/receiver
  
  req.setEndpoint(cpqreceiver);
  
  
  
  //Set the HTTPRequest body  
  String    body ='<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">';
            body = body+'<soapenv:Header>';
            body = body+'<bm:category xmlns:bm="urn:soap.bigmachines.com">Security</bm:category>';
            body = body+'<bm:xsdInfo xmlns:bm="urn:soap.bigmachines.com">';
            body = body+'<bm:schemaLocation>' + CPQXSD + '</bm:schemaLocation>' ; // https://devmoveinc.bigmachines.com/bmfsweb/devmoveinc/schema/v1_0/security/Security.xsd</bm:schemaLocation>';
         
         
            body = body+'</bm:xsdInfo>';
            body = body+'</soapenv:Header>';
            body = body+'<soapenv:Body>';
            body = body+'<bm:login xmlns:bm="urn:soap.bigmachines.com">';
            body = body+'<bm:userInfo>';
            if(username!=null && password!=null){
           body = body+'<bm:username>'+username+'</bm:username>';
            body = body+'<bm:password>'+password+'</bm:password>';
            
         //   body = body+'<bm:username>ssharma</bm:username>';
           // body = body+'<bm:password>hNE2E@#4E_</bm:password>'; 
            
            } else {
            body = body+'<bm:username>arunsharma</bm:username>';
            body = body+'<bm:password>CPQ123</bm:password>';
            
            //    body = body+'<bm:username>ssharma</bm:username>';
            //body = body+'<bm:password>hNE2E@#4E_</bm:password>'; 
             
            }
            body = body+'<bm:sessionCurrency/>';
            body = body+'</bm:userInfo>';
            body = body+'</bm:login>';
            body = body+'</soapenv:Body>';
            body = body+'</soapenv:Envelope>';
             req.setBody(body);    

         Http http = new Http();
  
        //Execute web service call here     
        HTTPResponse res = http.send(req);  
        Dom.Document doc = res.getBodyDocument();
        Dom.XMLNode envelope = doc.getRootElement();
        system.debug('!!!!!!!!! value of envelope' + envelope);
        Dom.XMLNode resbody = envelope.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/'); 
        Dom.XMLNode loginresponse= resbody.getChildElement('loginResponse', 'urn:soap.bigmachines.com'); 
        system.debug('@@@@@ value of body' + loginresponse);
        Dom.XMLNode userinfo= loginresponse.getChildElement('userInfo', 'urn:soap.bigmachines.com'); 
        system.debug('@@@@@ value of body' + userinfo);
        Dom.XMLNode sessid= userinfo.getChildElement('sessionId', 'urn:soap.bigmachines.com'); 
        system.debug('@@@@@ value of body' + sessid.getText());
        bmsessionid= sessid.getText();
  
return bmsessionid;
}
        
        
         //  public PageReference createOpportunity() {

 public string  createOpportunity() {
    //String baseURL = URL.getSalesforceBaseUrl().toExternalForm() + '/';
   
    //Id accountId = ApexPages.currentPage().getParameters().get('accountId');
  //    Id leadId = ApexPages.currentPage().getParameters().get('leadid');
  
  System.debug('Arun Accoutn Id is ' + this.AccountId );
   
  
     String myaccountId  = this.AccountId ;
     
      
  System.debug('Arun Accoutn Id after assignment is ' + this.AccountId );
   
  
     accountId = Id.valueOf(myaccountId);
     
      
  System.debug('Arun Accoutn Id is ID conversion ' + accountId  );
   
  
     
   //  String myleadId = mQuoteItems[0].leadid ;
    // leadId  =  Id.valueOf(myleadId);
       
  
    // String myaccountId  = mQuoteItems.sfdcid ;
     
     String leadId  ;
    
    System.debug('Arun Accoutn Id is ' + AccountId);
    System.debug('Arun Accoutn Id is ' + accountId);
    
    //accountId = AccountId; // converting string to ID here 
       
    if(String.isNotBlank(accountId)) {
        try {
        Opportunity theOpportunity = new Opportunity(
          Name = 'The Opportunity',
          StageName = 'Prospecting',
          CloseDate = system.today(),
          AccountId = accountId,
          Account_Type__c = 'Inside'
        );
        
       
       System.debug('leadId' + leadId);
         if ((leadId !=null) || (leadId !=''))
         {
        
                        for(CampaignMember ledd:[Select Id,campaignId from CampaignMember where LeadId=:leadId]){
                      
                        
                                                        if (leadId !=null || leadId !='')
                                                       {
                                                        theOpportunity.Lead__c = leadId;
                                                         theOpportunity.campaignId= ledd.campaignId ;
                                                        }
                        
                        }
                        
        
                        if(String.isNotBlank(leadId)) {
                                
                                                       try
                                                       {        
                                                        Lead led = new Lead(Id=leadId,Status='Converted');
                                                       }
                                                       catch(exception e)
                                                       {
                                                       System.debug('########### Lead Error ########'+e.getMessage());
                                                       
                                                       }
                                  }      // If leadid is not null 
                       
                        //update led;
                        }
        insert theOpportunity;
        
        System.debug('########### OPPortunity Created ########'+theOpportunity.Id);
/*
        ApexPages.addMessage(new ApexPages.Message(
          ApexPages.Severity.CONFIRM,
          'Opportunity successfully created. Record URL: ' + baseURL + theOpportunity.Id
        ));
*/
          return theOpportunity.Id;
        }
        catch(Exception e) {
            system.debug('TRACE: Exception Occurred - ' + e.getStackTraceString());
        ApexPages.addMessage(new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'An internal error occurred while processing your request. Please contact system administrator.'
        ));
        
        System.debug(e.getMessage());
        }
    }
    return null;  
    }     
   
Public String CreateBigMachineQuote( List<MyQuote> mquote , QuoteWrapper QW){
       
       string username =QW.MyUserName;
       string password =QW.MyPassword;
        string bmsessionid = GetSessionId(username,password);
   //   string quoteType ='New';  
     boolean autoprocess = false;
        string quoteType = this.quoteType;
        System.debug('76666');
        HttpRequest req = new HttpRequest(); 
        String tidd='';
        String newtidd='';
        //Set HTTPRequest Method
        req.setMethod('POST');
        
            String cpqreceiver=  Waitlist_Urls__c.getInstance('CPQReciever').url__c;
                        String CPQSECURITYXSD =Waitlist_Urls__c.getInstance('CPQSECURITYXSD').url__c;
                            String CPQInstance ='devmoveinc';
        String CPQUSER = BigMachineUrls__c.getInstance('WLBM').DefaultUserName__c;
          //   req.setEndpoint('https://devmoveinc.bigmachines.com/v1_0/receiver');
        
       req.setEndpoint(cpqreceiver);
        
        
        //Set the HTTPRequest body  
        String    body ='<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">';
        body = body+'<soapenv:Header>';
        body = body+'<bm:userInfo xmlns:bm="urn:soap.bigmachines.com">';
        body = body+'<bm:sessionId>'+this.bmsessionid+'</bm:sessionId>';
        body = body+'</bm:userInfo>';
        body = body+'<bm:category xmlns:bm="urn:soap.bigmachines.com">Commerce</bm:category>';
        body = body+'<bm:xsdInfo xmlns:bm="urn:soap.bigmachines.com">';
    //    body = body+'<bm:schemaLocation>https://devmoveinc.bigmachines.com/bmfsweb/devmoveinc/schema/v1_0/commerce/oraclecpqo.xsd</bm:schemaLocation>';
            body = body+'<bm:schemaLocation>' + CPQSECURITYXSD + '</bm:schemaLocation>' ; // https://devmoveinc.bigmachines.com/bmfsweb/devmoveinc/schema/v1_0/security/Security.xsd</bm:schemaLocation>';
      
      
        body = body+'</bm:xsdInfo>';
        body = body+'</soapenv:Header>';
        body = body+'<soapenv:Body>';
        body = body+'<bm:createTransaction xmlns:bm="urn:soap.bigmachines.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
        body = body+'<bm:items>';
        //body = body+'<bm:catalogItem>';
        body = body+'<bm:segment>realtor</bm:segment>';
        //body = body+'<bm:product_line>nonInventoryProducts</bm:product_line>';
        //body = body+'<bm:model>fiveStreet';
        //body = body+'</bm:model>';
        //body = body+'</bm:catalogItem>';
        body = body+'<bm:partItem>';
        body = body+'<bm:part/>';
        
        
        body = body+'<bm:quantity>' + 1 + '</bm:quantity>';
        //body = body+'<bm:quantity>1</bm:quantity>';
        
        
        body = body+'<bm:price_book_var_name/>';
        body = body+'</bm:partItem>';
        
        
        
        Integer iiii=2;
        
        
      //  for(Asset assst:[Select Id,Name,Product_Email__c,License_Tier__c,HLC_Override__c,Top_Connector__c,Commerce_Group__c,Contract_Term__c,Billing_Period__c,Promotion__c,Discount_Type__c,Renewal_End_Date__c,Product2.ProductCode,Quantity,Lead_Type__c,Product_Type__c,Market_Zip__c,Market__c,Price,Renewal_Start_Date__c from Asset where Accountid=:AccountId and Asset_Type__c='Parent']){
      
   
        integer assetCounter =0;
        for (MyQuote items : mquote )
        {
                assetCounter ++;
            Integer qtty=0;
            string pcode = 'COBROKE';
            
            
          //  pcode = items.ProductCode;
            
            if ((items.product=='CBC') || ( items.product=='Connection for Co-Brokerage') || ( items.product=='COBROKE'))
            {
              pcode = 'COBROKE';
            
            }
            else if ((items.product=='DAP') || (  items.product== 'Digital Ad Package') || (  items.product== 'DIGITALAGENT') )
            {
                 pcode =  'DIGITALAGENT';
            
            }
            
             else if ((items.product=='Featured Homes') || (  items.product== 'Featured Home') || (  items.product== 'Featured Homes(SM)') || (  items.product== 'FEATHOMES'))
            {
                 pcode =  'FEATHOMES';
            
            }
            
              else if ((items.product=='Featured CMA(SM)') || (  items.product== 'Featured CMA') || (items.product=='FEATCMA') )
            {
                 pcode =  'FEATCMA';
            
            }
            
             else if ((items.product=='Tigerleads HL') || (  items.product== 'HANDRAISER')  || (  items.product== 'HandRaiser') )
            {
                 pcode =  'HANDRAISER';
            
            }
              else if ((items.product=='Tigerleads HS') || (  items.product== 'Home Search')  || (  items.product== 'HOMESRCH') )
            {
                 pcode =  'HOMESRCH';
            
            }
            
            else if (items.product=='FAC' || (items.product== 'Featured Display')) 
            {
                 pcode =  'FEATDISP'; // for the time being 
                 items.slotsize ='Companion';
            }
            
                        
            
            
            
            
            if (pcode ==null)
            {
                pcode = 'COBROKE';
            }
            
      //      if(pcode!=null){pcode=assst.Product2.ProductCode;}  // commented by arun
            mapAssetIDDocumentNumber.put(assetCounter,iiii); // commented by arun
            
            try
            {
            this.assetId =assetCounter + iiii; 
            
            if(items.qtyinterested!=null){qtty =Integer.valueof(items.qtyinterested);}
            
            }catch(exception e)
            {
            this.assetId = 1 +  iiii ;
            
            }
            
            
            if (qtty ==null || qtty ==0)
            {
                qtty =1; // keep minimun qty
            }
            
            
            
            body = body+'<bm:partItem>';
            body = body+'<bm:part>'+pcode+'</bm:part>';
            body = body+' <bm:quantity>'+qtty+'</bm:quantity>';
            body = body+'<bm:price_book_var_name>_default_price_book</bm:price_book_var_name>';
            body = body+'<bm:lineType_line>add</bm:lineType_line>';
            body = body+'<bm:marketZip_line>'+'00009'+'</bm:marketZip_line>';
        
            body = body+'</bm:partItem>';
            iiii++;
        }
        body = body+'</bm:items>';
        body = body+'<bm:transaction>';
        body = body+'<bm:process_var_name>oraclecpqo</bm:process_var_name>';
        body = body+'<bm:quoteType_quote>'+quoteType+'</bm:quoteType_quote>';
        body = body+'<bm:_bm_cm_new_transaction_currency/>';
        body = body+'<bm:return_specific_attributes>';
        body = body+'<bm:documents>';
        body = body+'<bm:document>';
        body = body+'<bm:var_name>transaction</bm:var_name>';
        body = body+'<bm:attributes>';
        body = body+'<bm:attribute>_document_number</bm:attribute>';
        body = body+'</bm:attributes>';
        body = body+'</bm:document>';
        body = body+'</bm:documents>';
        body = body+'</bm:return_specific_attributes>';
        body = body+'</bm:transaction>';
        body = body+'</bm:createTransaction>';
        body = body+'</soapenv:Body>';
        body = body+'</soapenv:Envelope>';
        body = body+'';
        System.debug('##  '+body); 
        req.setBody(body);    
        System.debug('##  '+req); 
        Http http = new Http();
        
        try {
            
            //Execute web service call here     
            HTTPResponse res = http.send(req);  
            
            String docc = res.getBody();
            //System.debug(docc);   
            Dom.Document doc = res.getBodyDocument();
            Dom.XMLNode envelope = doc.getRootElement();
            system.debug('!!!!!!!!! value of envelope' + envelope);
            Dom.XMLNode resbody = envelope.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/'); 
            Dom.XMLNode createTransactionRes= resbody.getChildElement('createTransactionResponse', 'urn:soap.bigmachines.com'); 
            Dom.XMLNode trans= createTransactionRes.getChildElement('transaction', 'urn:soap.bigmachines.com'); 
            Dom.XMLNode tid= trans.getChildElement('id', 'urn:soap.bigmachines.com'); 
            system.debug('@@@@@ value of body' + tid.getText());
            tidd = tid.getText();
            
          
            newtidd = UpdateBigMachineQuote(tid.getText(),'cleanSave_t', mquote ,QW );
            newtidd = UpdateBigMachineQuote(tid.getText(),'_update_line_items' , mquote , QW );
            newtidd = UpdateBigMachineQuote(tid.getText(),'cleanSave_t' , mquote , QW);
            if(autoprocess==true){
            newtidd = UpdateBigMachineQuote(tid.getText(),'submit_t', mquote , QW );
            }
        } catch(System.CalloutException e) {
            
        }     
       // return [Select id,name,BigMachines__Transaction_Id__c from BigMachines__Quote__c where BigMachines__Transaction_Id__c=:newtidd].id;
          
          return newtidd;
    }
    
    Public String UpdateBigMachineQuote(String tId,String atype, List<MyQuote> mquote , QuoteWrapper QW){
        HttpRequest req = new HttpRequest(); 
        string quoteType='New';
        string marketZip;
        
        opportunityid = QW.opportunityid;
        
        if (opportunityid ==null)
        {
        opportunityid = '006g0000007cRgg';
        }
        //Set HTTPRequest Method
        req.setMethod('POST');
 //       req.setEndpoint('https://devmoveinc.bigmachines.com/v1_0/receiver');
            String cpqreceiver=  Waitlist_Urls__c.getInstance('CPQReciever').url__c;
                        String CPQXSD =Waitlist_Urls__c.getInstance('CPQXSD').url__c;
                         String CPQINSTANCE =BigMachineUrls__c.getInstance('WLBM').BigmachineInstance__c;
                        String CPQUSER = BigMachineUrls__c.getInstance('WLBM').DefaultUserName__c;
                
                          
                              String CPQCOMPANY =BigMachineUrls__c.getInstance('WLBM').BigmachineInstance__c;
        
        
          //   req.setEndpoint('https://devmoveinc.bigmachines.com/v1_0/receiver');
        
       req.setEndpoint(cpqreceiver);
        
        
        //Set the HTTPRequest body  
        String   body = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">';
        body = body+'<soapenv:Header>';
        body = body+'<bm:userInfo xmlns:bm="urn:soap.bigmachines.com">';
        body = body+'<bm:sessionId>'+bmsessionid+'</bm:sessionId>';
        body = body+'</bm:userInfo>';
        body = body+'<bm:category xmlns:bm="urn:soap.bigmachines.com">Commerce</bm:category>';
        body = body+'<bm:xsdInfo xmlns:bm="urn:soap.bigmachines.com">';
    //    body = body+'<bm:schemaLocation>https://devmoveinc.bigmachines.com/bmfsweb/devmoveinc/schema/v1_0/commerce/oraclecpqo.xsd</bm:schemaLocation>';
           body = body+'<bm:schemaLocation>' + CPQXSD + '</bm:schemaLocation>' ; // https://devmoveinc.bigmachines.com/bmfsweb/devmoveinc/schema/v1_0/security/Security.xsd</bm:schemaLocation>';
      
        
        body = body+'</bm:xsdInfo>';
        body = body+'</soapenv:Header>';
        body = body+'<soapenv:Body>';
        body = body+'<bm:updateTransaction xmlns:bm="urn:soap.bigmachines.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
        body = body+'<bm:transaction>';
        body = body+'<bm:id>'+Integer.valueof(tId)+'</bm:id>';
        body = body+'<bm:process_var_name>oraclecpqo</bm:process_var_name>';
        body = body+'<bm:buyer_company_name>'+ CPQINSTANCE + '</bm:buyer_company_name>';
        body = body+'<bm:supplier_company_name>' + CPQINSTANCE + '</bm:supplier_company_name>';
        body = body+'<bm:step_var_name/>';
        body = body+'<bm:last_document_number>1</bm:last_document_number>';
        //body = body+'<bm:date_added>2015-07-04 21:26:32</bm:date_added>';
        //body = body+'<bm:date_modified>2015-07-04 21:26:32</bm:date_modified>';
        body = body+'<bm:data_xml>';
        body = body+'<bm:transaction bm:bs_id="'+Integer.valueof(tId)+'" bm:buyer_company_name="' +CPQCOMPANY +'" bm:buyer_user_name=' + '"' + CPQUSER + '" bm:currency_pref="USD" bm:data_type="0" bm:document_name="Transaction" bm:document_number="1" bm:document_var_name="transaction" bm:process_var_name="oraclecpqo" bm:supplier_company_name="' + CPQCOMPANY +  '">';
        body = body+'<bm:_document_number>1</bm:_document_number>';
        body = body+'<bm:opportunityID_t>'+opportunityid+'</bm:opportunityID_t>';
        body = body+'<bm:status_t>In Progress</bm:status_t>';
        body = body+'<bm:lineType_line>add</bm:lineType_line>';
        body = body+'<bm:version_t>1</bm:version_t>';
        body = body+'<bm:bs_id>'+Integer.valueof(tId)+'</bm:bs_id>';
        
        System.debug('ARUN 88888888 Customer Id Is'+ QW.AccountId);
        body = body+'<bm:_customer_id>'+QW.AccountId+'</bm:_customer_id>';
        body = body+'<bm:partyID>'+QW.party_Id+'</bm:partyID>';
        body = body+'<bm:version_number_versionTransaction_t>1</bm:version_number_versionTransaction_t>';
        //body = body+'<bm:quoteNumber_quote>2015-2594</bm:quoteNumber_quote>';
        body = body+'<bm:quoteType_quote>'+quoteType+'</bm:quoteType_quote>';
        //body = body+'<bm:quoteType_quote>Auto Renewal</bm:quoteType_quote>';
        //body = body+'<bm:stringOfAsset_quote>Product2.BigMachines__Part_Number__c,Quantity,Start_Date__c,End_Date__c,Status,Product2.Id,Price,Lead_Type__c,Product_Type__c,Market__c,Contract_Term__c,Billing_Period__c,Promotion__c,Discount_Type__c,Commerce_Group__c,Broker_Plan_Affiliation__c,Product_Email__c,Participants__c,License_Tier_Range__c,Top_Connector__c,Featured_Mortgage__c,HLC_Override__c</bm:stringOfAsset_quote>';
     //   body = body+'<bm:caseId>'+caseid+'</bm:caseId>';
        //body = body+'<bm:_price_quantity>1</bm:_price_quantity>';
        body = body+'<bm:sub_documents>';
        
    /*    for(Asset assst:[Select Id,Name,Product_Email__c,Market_Tier__c,Featured_Mortgage__c,Extended_Net_Price__c,MSA_Tier__c,Suppress_Welcome_Calls__c,Create_Broker_Tools__c,License_Tier__c,HLC_Override__c,Top_Connector__c,Commerce_Group__c,Contract_Term__c,Billing_Period__c,Promotion__c,Discount_Type__c,Renewal_End_Date__c,Product2.ProductCode,Quantity,Lead_Type__c,Product_Type__c,Market_Zip__c,Market__c,Price,Renewal_Start_Date__c from
         Asset where  // Accountid=:AccountId and 
          Asset_Type__c='Parent' Limit 1] ) */
          
          integer docnumber =2;
            for (MyQuote items : mquote )
        {
                 
          
            Integer qtty=0;
            body = body+'<bm:transactionLine bm:bs_id="'+Integer.valueof(tId)+'" bm:buyer_company_name="' + CPQCOMPANY +'" bm:buyer_user_name="' + CPQUSER + '" bm:currency_pref="USD" bm:data_type="3" bm:document_name="Transaction Line" bm:document_number="'+docnumber+'" bm:document_var_name="transactionLine" bm:process_var_name="oraclecpqo"  bm:supplier_company_name="' + CPQCOMPANY +  '">';
            body = body+'<bm:_document_number>'+docnumber+'</bm:_document_number>';
            if(items.QtyInterested!=null){qtty =Integer.valueof(items.QtyInterested);}
           
            if (items.market==null)
            {
              marketZip ='94536';
            }
           
            
            
            String leadtype  =items.LeadRoutingType + ' Follow-up';
            String producttype =items.slotsize;
            Date renewalstartdate=System.today();
            Date renewalenddate=System.today().addMonths(6);
            String contractterm ='6';
            String prodemail='arun.sharma@move.com';
            String billingperiod='Monthly';
            String commercegrp='Agent';
            String hlcoverride ='';
            String msaTier ='';
            Integer MarketTier = 1;
            Decimal assetpricee = 0.0;
    
            if(items.market!=null && items.market!=''){marketZip=items.market;}
            if(items.LeadRoutingType!=null){ leadtype =items.LeadRoutingType;leadtype = leadtype.remove(' Follow-up'); }
            if(items.slotsize!=null){ producttype =items.slotsize;}
            if(items.product=='FAC')
            {
                 producttype = 'Companion';
                 items.slotsize = 'Companion';
            } 
            
            if(this.contractterm!=null){ contractterm =this.contractterm;}
            if(this.renewalstartdate!=null){ renewalstartdate=this.renewalstartdate;}
            if(this.renewalenddate!=null){ renewalenddate=this.renewalenddate;}
            if(this.contractterm!=null){ contractterm =this.contractterm;}
            if(this.prodemail!=null){ prodemail=this.prodemail;}
            if(this.billingperiod!=null){ billingperiod=this.billingperiod;}
            if(this.commercegrp!=null){ commercegrp=this.commercegrp;}
            if(this.hlcoverride!=null){ hlcoverride=this.hlcoverride+'';}
            if(this.commercegrp!=null){ commercegrp=this.commercegrp;}
            if(this.commercegrp!=null){ commercegrp=this.commercegrp;}
            if(items.MarketTier!=null){MarketTier = Integer.valueof(items.MarketTier);}
            if(this.assetpricee!=null){assetpricee = this.assetpricee;}
            body = body+'<bm:lineType_line>add</bm:lineType_line>';
            //body = body+'<bm:marketZip_line>'+marketZip+'</bm:marketZip_line>';
           // body = body+'<bm:assetID_l>'+this.assetid+'</bm:assetID_l>';
            body = body+'<bm:leadType_line>'+items.leadroutingtype +'</bm:leadType_line>'; 
            body = body+'<bm:productType_line>'+items.slotsize+'</bm:productType_line>';
            //body = body+'<bm:assetPrice_line>'+assst.Price+'</bm:assetPrice_line>';
            body = body+'<bm:contractStartDate_l>'+QW.renewalstartdate+'</bm:contractStartDate_l>';
            body = body+'<bm:contractEndDate_l>'+QW.renewalenddate+'</bm:contractEndDate_l>';
            body = body+'<bm:contractTerms_line>'+ QW.contractterm +'</bm:contractTerms_line>';
            body = body+'<bm:billingPeriod_line>'+QW.billingperiod+'</bm:billingPeriod_line>';
            //body = body+'<bm:promotion_line>'+assst.Promotion__c+'</bm:promotion_line>';
            //body = body+'<bm:discountType_line>'+assst.Discount_Type__c+'</bm:discountType_line>';
            body = body+'<bm:commerceGroup_line>'+QW.commercegrp+'</bm:commerceGroup_line>';
            body = body+'<bm:productEmail_line>'+QW.prodemail+'</bm:productEmail_line>';
            //body = body+'<bm:licenseTier_line>'+assst.License_Tier__c+'</bm:licenseTier_line>';
            body = body+'<bm:topConnector_line>'+QW.Top_Connector+'</bm:topConnector_line>';
            body = body+'<bm:featuredMortgage_line>'+QW.Featured_Mortgage+'</bm:featuredMortgage_line>';
            body = body+'<bm:mSATier_line>'+QW.msaTier+'</bm:mSATier_line>';
            body = body+'<bm:hlcOverride_line>'+QW.hlcoverride+'</bm:hlcOverride_line>';
            //body = body+'<bm:license_line>'+assst.License_Tier__c+'</bm:license_line>';
            body = body+'<bm:license_line>5</bm:license_line>';
            //body = body+'<bm:status_l>Active</bm:status_l>';
            //body = body+'<bm:fulfillToAccount_line>'+assst.License_Tier__c+'</bm:fulfillToAccount_line>';
            body = body + '<bm:assetPrice_line>'+assetpricee+'</bm:assetPrice_line>';
            body = body+'<bm:assetFlag_l>true</bm:assetFlag_l>';
            body = body+'<bm:marketType_line>'+items.geotype +'</bm:marketType_line>';
            body = body+'<bm:priceTier_line>'+MarketTier+'</bm:priceTier_line>';
            body = body+'<bm:marketZip_line>'+ items.market +'</bm:marketZip_line>';
            System.debug('#######72727272 items.market'+items.market);
            body = body+'<bm:suppressWelcomeCalls_line>'+QW.Suppress_Welcome_Calls+'</bm:suppressWelcomeCalls_line>';
            body = body+'<bm:priceEffectiveDate_line/>';
            //<bm:bundleID_line/>
            //<bm:invTransactionID_line/>
            body = body+'<bm:createBrokerTools_line>'+QW.Create_Broker_Tools+'</bm:createBrokerTools_line>';
            //body = body+'<bm:fulfillToAccount_line>'+assst.License_Tier__c+'</bm:fulfillToAccount_line>';
            //body = body+'<bm:fulfillToAccount_line>'+assst.License_Tier__c+'</bm:fulfillToAccount_line>';
           // body = body+'</bm:partItem>';
            body = body+'</bm:transactionLine>';
            
            docnumber =docnumber + 1;
           
          
            
        }
        
        body = body+'</bm:sub_documents>';
        body = body+'<bm:rule_data>';
        body = body+'<bm:totalAnnualValue_t bm:constrained="false" bm:hidden="true"/>';
        body = body+'<bm:totalContractValue_t bm:constrained="false" bm:hidden="true"/>';
        body = body+'<bm:totalMonthlyDiscount_t bm:constrained="false" bm:hidden="true"/>';
        body = body+'<bm:taxExemptReason_t bm:constrained="false" bm:hidden="true"/>';
        body = body+'<bm:totalMonthlyNetAmount_t bm:constrained="false" bm:hidden="true"/>';
        body = body+'<bm:totalMonthlyListAmount_t bm:constrained="false" bm:hidden="true"/>';
        body = body+'</bm:rule_data>';
        body = body+'</bm:transaction>';
        body = body+'</bm:data_xml>';
        body = body+'<bm:action_data>';
        body = body+'<bm:action_var_name>'+atype+'</bm:action_var_name>';
        body = body+'<bm:_bm_cm_new_transaction_currency/>';
        body = body+'<bm:performer_comment/>';
        body = body+'<bm:reason_var_name/>';
        body = body+'<bm:performer_name/>';
        body = body+'<bm:performer_type/>';
        body = body+'<bm:performer_company_name/>';
        body = body+'</bm:action_data>';
        body = body+'<bm:sub_step_name/>';
        body = body+'<bm:buyer_user_name>' + CPQUSER + '</bm:buyer_user_name>';
        body = body+'<bm:currency_pref>USD</bm:currency_pref>';
        body = body+'<bm:status>0</bm:status>';
        body = body+'<bm:update_count>2</bm:update_count>';
        body = body+'<bm:language_pref>English</bm:language_pref>';
        body = body+'<bm:offline_user_id>-1</bm:offline_user_id>';
        body = body+'<bm:num_transitions>0</bm:num_transitions>';
        body = body+'</bm:transaction>';
        body = body+'</bm:updateTransaction>';
        body = body+'</soapenv:Body>';
        body = body+'</soapenv:Envelope>';
        
        System.debug(body);
        req.setBody(body);    
        
        Http http = new Http();
        
        try {
            
            //Execute web service call here     
            HTTPResponse res = http.send(req);  
            
            //String doc = res.getBody();
            //System.debug(doc);   
            Dom.Document doc = res.getBodyDocument();
            System.debug(doc+'555555555');   
            //Retrieve the root element for this document.
            Dom.XMLNode address = doc.getRootElement();
            
            //String name = address.getChildElement('name', null).getText();
            //String state = address.getChildElement('bm:id', null).getText();
            //System.debug('######'+state);
            
        } catch(System.CalloutException e) {
            //Exception handling goes here....
        }       
        return tId;
    }
    
    
    } // end of the class QuoteWrapper 
    Public String accId{get;set;}
    public pageReference InsertOpportunity() {
           //String accId;
           accid='001Z000000yLRAk';
            //Insert opportunity
            Opportunity theOpportunity = new Opportunity(
                Name            = 'The Opportunity',
                StageName       = 'Prospecting',
                CloseDate       = system.today(),
                AccountId       = accId,
                Account_Type__c = 'Short');
            insert theOpportunity;
            pageReference pr = new pageReference('https://c.cs11.visual.force.com/apex/MyWaitlist?sfdc.tabName=01rZ00000000qVk&oppId='+theOpportunity.id);
      return pr;
       }
@RemoteAction
    global static string CreateNewOpportunity(String accountName) {
        Opportunity theOpportunity = new Opportunity(
                Name            = 'The Opportunity',
                StageName       = 'Prospecting',
                CloseDate       = system.today(),
                AccountId       = accountName,
                Account_Type__c = 'Short');
            insert theOpportunity;
            return theOpportunity.id;
    }
    
    
}