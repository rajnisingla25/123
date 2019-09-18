@isTest(seeAllData = false)
public  class WaitlistItemtriggerHandler_Test{
private static final Integer COUNTERLESS = 5;

public static testMethod void activeWaitlist(){

// Insert Custom Setting for Case Trigger
   Switch_CaseTrigger__c testSetting = new Switch_CaseTrigger__c(Set_Overall_Trigger_Off__c = True);
   insert testSetting;
   //Inserting Customsetting for Account 
   DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
       insert Dtrg;
 Account acc = new Account(Sales_Lock_User__c  = userInfo.getUserId(), NAME = 'acctest',Display_Name__c='test',BillingCity = 'testcity', BillingStreet = 'teststreet', BillingCountry = 'canada',BillingState ='test',BillingPostalCode= '505001',Fax = '123', Home_Phone__c = '1234567890',Work_Phone__c='1234567890',Mobile1__c='1234567890',Mobile2_Other__c='1234567890',Type = 'press', website = 'move.com',ShippingCity = 'testscity',
            ShippingStreet='teststreet',ShippingCountry='testcountry',ShippingPostalCode='505001',ShippingState='test',Primary_Email__c='aj@move.com');
        insert acc;
       
   contact c = new contact();
   c.lastname = 'test';
   c.accountid = acc.id;
   c.FirstName = 'ravi';
   c.Title = 'sath';
   c.email ='ravi@gmail.com';
   c.Phone = '1234567895';
   c.MobilePhone= '1234567895';
   c.MailingState = 'California';
   c.MailingCountry = 'United States';
   c.MailingCity = 'knr';
   c.MailingStreet = 'test';
   c.MailingPostalCode = '524345';
   c.Preferred_Phone__c='1234567890';
   
   insert c;         
    
    Waitlist_Urls__c wURL = new Waitlist_Urls__c();
    wURL.Name = 'accountOwnerChange';
    wURL.URL__c = '';
    wURL.replacement_parameter__c = '';
    wUrl.owners_List__c = 'TestUser,TestUser2';
    insert wURL;
    
    Product2 p =new Product2();
    p.name = 'Test';
    p.S_No__c = 2;
    insert p;
    Waitlist__c  w = new Waitlist__c();
    w.Account__c= acc.id;
    w.Pre_Auth_Contact__c= c.id;
    w.Status__c='Created';
    w.Pre_Auth_Email__c='aj@gmail.com';
    w.Waitlist_Expiration_Date__c = System.today().addDays(90);
    insert w;
    
    Waitlist_Item__c wt = new Waitlist_Item__c();
    wt.Waitlist__c =w.id;
    wt.Original_Max_Spend__c=2000;
    wt.Status__c='Active';
    wt.Market__c='test';
    wt.Waitlist_ID__c='wwwww';
    wt.Lead_Routing__c='Fast';
    wt.Status__c='Active';
    wt.Product__c=p.id;
    wt.Account__c= acc.id;
    wt.Market_Type__c='Postal Code';
    wt.Amendment_Status__c='Active';
    wt.Waitlist_Expiration_Date__c=date.today();
    wt.Product_Size__c='Full';
    wt.Wailist_Type__c = 'Pre-Auth';
    wt.Inventory_Available__c = false;
    insert wt;
    /*
     Waitlist_Item__c wtNew = new Waitlist_Item__c();
    wtNew.Waitlist__c =w.id;
    wtNew.Original_Max_Spend__c=2000;
    wtNew.Status__c='Active';
    wtNew.Amendment_Status__c='Pending Pre-Auth Approval'; 
    
    wtNew.Market__c='test';
    wtNew.Waitlist_ID__c='12wwwww';
    wtNew.Lead_Routing__c='Fast';
    wtNew.Status__c='Active';
    wtNew.Product__c=p.id;
    wtNew.Account__c= acc.id;
    wtNew.Market_Type__c='Postal Code';
    wtNew.Waitlist_Expiration_Date__c=date.today();
    wtNew.Product_Size__c='Full';
    wtNew.Wailist_Type__c = 'Pre-Auth';
    wtNew.Inventory_Available__c = false;
    insert wtNew;
    */
 
    List<Waitlist_Item__c> waitlist= [select id,Status__c,CreatedDate,Rank__c from Waitlist_Item__c where Rank__c !=null  Order By Rank__c desc limit 5];
    Boolean  skipbeforeupdaterun = false;
    Boolean  skipafterupdaterun = false;
    Map<Id,Waitlist_Item__c> newitems = new Map<Id,Waitlist_Item__c>();
    Map<Id,Waitlist_Item__c> olditems = new Map<Id,Waitlist_Item__c>();
    List<Waitlist_Item__c> giverank = new List<Waitlist_Item__c>();
    List<Waitlist_Item__c> wlifulfil = new List<Waitlist_Item__c>(); 
    List<Waitlist_Item__c> Rerank = new List<Waitlist_Item__c>();  
    
    waitlistitemTriggerHandler wmm = new waitlistitemTriggerHandler();
    wmm.onBeforeUpdate(newitems,olditems);
  wmm.onAfterUpdateOnDocuSignAmend( wt,wt );
    Waitlist_Item__c wa =  new Waitlist_Item__c();
    wa.Status__c='Active';
    
    giverank.add(wa);
    
}

public static testMethod void fulfilledWaitlist()
{
// Insert Custom Setting for Case Trigger
    Switch_CaseTrigger__c testSetting = new Switch_CaseTrigger__c(Set_Overall_Trigger_Off__c = True);
   insert testSetting;
    //Inserting Customsetting for Account 
   DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
    insert Dtrg;
 Account acc = new Account(NAME = 'acctest',Display_Name__c='test',BillingCity = 'testcity', BillingStreet = 'teststreet', BillingCountry = 'canada',BillingState ='test',BillingPostalCode= '505001',Fax = '123', Home_Phone__c = '1234567890',Work_Phone__c='1234567890',Mobile1__c='1234567890',Mobile2_Other__c='1234567890',Type = 'press', website = 'move.com',ShippingCity = 'testscity',
            ShippingStreet='teststreet',ShippingCountry='testcountry',ShippingPostalCode='505001',ShippingState='test',Primary_Email__c='aj@move.com');
        insert acc;       
    Product2 p =new Product2(name='test',S_No__c = 2);
    insert p;
    
            
   contact c = new contact();
   c.lastname = 'test';
   c.accountid = acc.id;
   c.FirstName = 'ravi';
   c.Title = 'sath';
   c.email ='ravi@gmail.com';
   c.Phone = '1234567895';
   c.MobilePhone= '1234567895';
   c.MailingState = 'California';
   c.MailingCountry = 'United States';
   c.MailingCity = 'knr';
   c.MailingStreet = 'test';
   c.MailingPostalCode = '524345';
   c.Preferred_Phone__c='1234567890';
   
   insert c;  
    
    Waitlist_Urls__c wURL = new Waitlist_Urls__c();
    wURL.Name = 'accountOwnerChange';
    wURL.URL__c = '';
    wURL.replacement_parameter__c = 'TestUser,TestUser2';
    insert wURL;
    
    Waitlist__c  w = new Waitlist__c();
    w.Account__c= acc.id;
    w.Pre_Auth_Contact__c= c.id;
    w.Status__c='Created';
    w.Pre_Auth_Email__c='aj@gmail.com';
    insert w;
    
    
   Waitlist_Item__c wt = new Waitlist_Item__c();
    wt.Waitlist__c =w.id;
    wt.Original_Max_Spend__c=2000;
    wt.Status__c='Pending Pre-Auth Approval';
    wt.Market__c='test';
    wt.Waitlist_ID__c='wwwww';
    wt.Lead_Routing__c='Fast';
    wt.Product__c=p.id;
    wt.Account__c= acc.id;
    wt.Market_Type__c='Postal Code';
    wt.Waitlist_Expiration_Date__c=date.today();
    wt.Product_Size__c='Full';
    wt.Wailist_Type__c = 'Pre-Auth';
    wt.Amendment_Status__c='Pending Pre-Auth Approval';
    
    insert wt;
    wt.Status__c='Active';
     wt.Amendment_Status__c='Pending Pre-Auth Approval';
    update wt;
    List<Waitlist_Item__c> waitlist= [select id,Status__c,CreatedDate,Rank__c from Waitlist_Item__c where Rank__c !=null  Order By Rank__c desc limit 5];
    Boolean  skipbeforeupdaterun = false;
    Boolean  skipafterupdaterun = false;
    Map<Id,Waitlist_Item__c> newitems = new Map<Id,Waitlist_Item__c>();
    Map<Id,Waitlist_Item__c> olditems = new Map<Id,Waitlist_Item__c>();
    List<Waitlist_Item__c> giverank = new List<Waitlist_Item__c>();
    List<Waitlist_Item__c> wlifulfil = new List<Waitlist_Item__c>(); 
    List<Waitlist_Item__c> Rerank = new List<Waitlist_Item__c>();  
    
    waitlistitemTriggerHandler wmm = new waitlistitemTriggerHandler();
    wmm.onAfterUpdate(newitems,olditems);
    Waitlist_Item__c wa1 = new Waitlist_Item__c();
    //olditems.get(wa1.id).Status__c = 'Active';
    //olditems.get(wa1.id).Rank__c!=0;
    Rerank.add(wa1);
    
    
    
}
    
     public static testMethod void fulfilledWaitlist3()
    {
    // Insert Custom Setting for Case Trigger
       Switch_CaseTrigger__c testSetting = new Switch_CaseTrigger__c(Set_Overall_Trigger_Off__c = True);
      insert testSetting;
      // Inserting Customsetting for Account 
       DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
         insert Dtrg; 
        CreateWaitlist__c crt = new CreateWaitlist__c(Name = 'COBROKE' ,Product_Code__c = 'COBROKE', Default_Term__c = 12);
       insert crt;   
             
    id rectypid = [select id from RecordType where SobjectType = 'Account' and name = 'B2B'].id;
     Account acc = new Account(NAME = 'acctest',Display_Name__c='test',BillingCity = 'testcity', BillingStreet = 'teststreet', BillingCountry = 'canada',BillingState ='test',BillingPostalCode= '505001',Fax = '123', Home_Phone__c = '1234567890',Work_Phone__c='1234567890',Mobile1__c='1234567890',Mobile2_Other__c='1234567890',Type = 'press', website = 'move.com',ShippingCity = 'testscity',
                ShippingStreet='teststreet',ShippingCountry='testcountry',ShippingPostalCode='505001',ShippingState='test',Primary_Email__c='aj@move.com');
            insert acc;       
        Product2 p =new Product2(name='test',S_No__c = 2,ProductCode = 'COBROKE');
        insert p;
        
     //id cntctrectypid = [select id from RecordType where SobjectType = 'Contact' and Developername = 'Standard'].id;  
     id cntctrectypid = [SELECT Id FROM RecordType WHERE Name = 'Standard'limit 1].id;      
       contact c = new contact();
       c.lastname = 'test';
       c.accountid = acc.id;
       c.FirstName = 'ravi';
       c.Title = 'sath';
       c.email ='ravi@gmail.com';
       c.Phone = '1234567895';
       c.MobilePhone= '1234567895';
       c.MailingState = 'California';
       c.MailingCountry = 'United States';
       c.MailingCity = 'knr';
       c.MailingStreet = 'test';
       c.MailingPostalCode = '524345';
       c.Preferred_Phone__c='1234567890';
       
       insert c; Waitlist_Urls__c wURL = new Waitlist_Urls__c();
    wURL.Name = 'accountOwnerChange';
    wURL.URL__c = '';
    wURL.replacement_parameter__c = 'TestUser,TestUser2';
    insert wURL;
        
        
        
        
        Waitlist__c  w = new Waitlist__c();
        w.Account__c= acc.id;
        w.Pre_Auth_Contact__c= c.id;
        w.Status__c='Created';
        w.Pre_Auth_Email__c='aj@gmail.com';    
        insert w;
        
       Waitlist_Item__c wt = new Waitlist_Item__c();
        wt.Waitlist__c =w.id;
        wt.Original_Max_Spend__c=2000;
        wt.Status__c='Active';
        wt.Market__c='test';
        wt.Waitlist_ID__c='wwwww';
        wt.Lead_Routing__c='Fast';
        wt.Product__c=p.id;
        wt.Account__c= acc.id;
        wt.Market_Type__c='Postal Code';
        wt.Rank__c = 1;
        wt.Wailist_Type__c = 'Pre-Auth';
        wt.Waitlist_Expiration_Date__c=date.today();
        wt.Product_Size__c='Full';    
        insert wt;
            
        List<InventoryAvailability__c> invList = new List<InventoryAvailability__c>();
        for(Integer index = 0;index < COUNTERLESS;index++) {
                invList.add(new InventoryAvailability__c(    
                Name = p.name,
                Waitlist_Item__c = wt.id,
                Waitlist_Item_Ext__c = '12345'+index,
                    PriceTier__c =12
            ));
        }   
        insert invList ;  
        
        case tempcase           = new case();
        tempcase.Status         = 'New';
        tempcase.Origin         = 'Web';
        tempcase.Type           = 'Sales Support';
        tempcase.Area__c         = 'Create Quote';
        tempcase.Subject         = 'Create quote for pre-auth waitlist id:' + wt.id ;
        insert tempcase;
        
        List<Waitlist_Item__c> waitlist =new List<Waitlist_Item__c>();
        waitlist.add(wt);
        
        List<Waitlist_Item__c> Rerank =new List<Waitlist_Item__c>();
        Rerank.add(wt);
        
       Test.startTest();        
        WaitlistItemtriggerHandlerManager wmm = new WaitlistItemtriggerHandlerManager();
        Map<Id, waitlist_Item__c> oldItemsMap = new Map<Id, waitlist_Item__c>();
        oldItemsMap.put(waitlist[0].id, waitlist[0]);
         wmm.rerank(waitlist, oldItemsMap);       
        List<Waitlist_Item__c> torank = new List<Waitlist_Item__c>();
        set<id> WLIids = new set<id> ();
        Waitlist_Item__c wt1 =new Waitlist_Item__c(Waitlist__c =w.id,Original_Max_Spend__c=2000,Status__c='Active',Market__c='test',Waitlist_ID__c='wwwww',Lead_Routing__c='Fast',Product__c=p.id,Account__c= acc.id,Market_Type__c='Postal Code',Waitlist_Expiration_Date__c=date.today(),Product_Size__c='Full',Wailist_Type__c = 'Hot');
        torank.add(wt1); 
        WLIids.add(wt.Id);        
        WaitlistItemtriggerHandlerManager.InsertOpportunity(torank);
        try{
        WaitlistItemtriggerHandlerManager.CreateQuote(WLIids);        
        }catch(exception e){}
       Test.stopTest();
    }
    
  
public static testMethod void fulfilledWaitlist1()
{
    
// Insert Custom Setting for Case Trigger
  Switch_CaseTrigger__c testSetting = new Switch_CaseTrigger__c(Set_Overall_Trigger_Off__c = True);
  insert testSetting;
    //Inserting Customsetting for Account 
DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
  insert Dtrg;
 Account acc = new Account(NAME = 'acctest',Display_Name__c='test',BillingCity = 'testcity', BillingStreet = 'teststreet', BillingCountry = 'canada',BillingState ='test',BillingPostalCode= '505001',Fax = '123', Home_Phone__c = '1234567890',Work_Phone__c='1234567890',Mobile1__c='1234567890',Mobile2_Other__c='1234567890',Type = 'press', website = 'move.com',ShippingCity = 'testscity',
            ShippingStreet='teststreet',ShippingCountry='testcou//ntry',ShippingPostalCode='505001',ShippingState='test',Primary_Email__c='aj@move.com');
   acc.Total_MAX_Monthly_Pre_Auth_Spend__c =12000 ;
   // acc.Current_Monthly_Pre_Auth_Spend__c =19 ;
    
    insert acc;       
    Product2 p =new Product2(name='test',S_No__c = 2);
    insert p;
    
            
   contact c = new contact();
   c.lastname = 'test';
   c.accountid = acc.id;
   c.FirstName = 'ravi';
   c.Title = 'sath';
   c.email ='ravi@gmail.com';
   c.Phone = '1234567895';
   c.MobilePhone= '1234567895';
   c.MailingState = 'California';
   c.MailingCountry = 'United States';
   c.MailingCity = 'knr';
   c.MailingStreet = 'test';
   c.MailingPostalCode = '524345';
   c.Preferred_Phone__c='1234567890';
   
   insert c;  
    
    Waitlist_Urls__c wURL = new Waitlist_Urls__c();
    wURL.Name = 'accountOwnerChange';
    wURL.URL__c = '';
    wURL.replacement_parameter__c = 'TestUser,TestUser2';
    insert wURL;
    
    
    Waitlist__c  w = new Waitlist__c();
    w.Account__c= acc.id;
    w.Pre_Auth_Contact__c= c.id;
    w.Status__c='Fulfilled';
    w.Pre_Auth_Email__c='aj@gmail.com';
    w.Total_MAX_Monthly_Pre_Auth_Spend__c=10 ;
    insert w;
   Waitlist_Item__c wt = new Waitlist_Item__c();
    wt.Waitlist__c =w.id;
    wt.Original_Max_Spend__c=2000;
    wt.Status__c='Fulfilled';
    wt.Market__c='test';
    wt.Waitlist_ID__c='wwwww';
    wt.Lead_Routing__c='Fast';
    wt.Current_Utilized_Spend__c =12 ;
    wt.Product__c=p.id;
    wt.Account__c= acc.id;
    wt.Market_Type__c='Postal Code';
    wt.Waitlist_Expiration_Date__c=date.today();
    wt.Product_Size__c='Full';
    wt.Wailist_Type__c = 'Pre-Auth';
    insert wt;
  
    
     Waitlist_Item__c wt1 = new Waitlist_Item__c();
    wt1.Waitlist__c =w.id;
    wt1.Original_Max_Spend__c=2000;
    wt1.Status__c='Active';
    wt1.Market__c='test';
    wt1.Waitlist_ID__c='wwwww';
    wt1.Lead_Routing__c='Fast';
    wt1.Product__c=p.id;
    wt1.Account__c= acc.id;
    wt1.Market_Type__c='Postal Code';
    wt1.Waitlist_Expiration_Date__c=date.today();
    wt1.Current_Utilized_Spend__c =1200 ;
    wt1.Product_Size__c='Full';
    wt1.Wailist_Type__c = 'Pre-Auth';
   wt1.Amendment_Status__c='';
    insert wt1;
      
    
    Waitlist_Item__c wt11 = new Waitlist_Item__c();
    wt11.Waitlist__c =w.id;
    wt11.Original_Max_Spend__c=2000;
    wt11.Status__c='Active';
    wt11.Market__c='test';
    wt11.Waitlist_ID__c='wwwww';
    wt11.Lead_Routing__c='Fast';
    wt11.Product__c=p.id;
    wt11.Account__c= acc.id;
    wt11.Market_Type__c='Postal Code';
    wt11.Waitlist_Expiration_Date__c=date.today().addDays(90);
    wt11.Current_Utilized_Spend__c =1200 ;
    wt11.Product_Size__c='Full';
    wt11.Wailist_Type__c = 'Pre-Auth';
   wt11.Amendment_Status__c='Pending Pre-Auth Approval';
    insert wt11;
        
     DocuSignCredentials__c  DSC = new DocuSignCredentials__c();
        DSC.Name = 'test';
        DSC.AccountId__c = 'Test Account';
        DSC.IntegratorsKey__c = 'Test Key';
        DSC.Password__c = 'Test Password';
        DSC.UserId__c = 'Test USerID';
        DSC.WebServiceUrl__c = 'https://www.google.com';
        insert DSC;

    
    
    List<Waitlist_Item__c> waitlist= [select id,Status__c,CreatedDate,Rank__c from Waitlist_Item__c where Rank__c !=null  Order By Rank__c desc limit 5];
    Boolean  skipbeforeupdaterun = false;
    Boolean  skipafterupdaterun = false;
    Map<Id,Waitlist_Item__c> newitems = new Map<Id,Waitlist_Item__c>();
    Map<Id,Waitlist_Item__c> olditems = new Map<Id,Waitlist_Item__c>();
    List<Waitlist_Item__c> giverank = new List<Waitlist_Item__c>();
    List<Waitlist_Item__c> wlifulfil = new List<Waitlist_Item__c>(); 
    List<Waitlist_Item__c> Rerank = new List<Waitlist_Item__c>();  
        Test.startTest();

    waitlistitemTriggerHandler wmm = new waitlistitemTriggerHandler();
    try{
    wmm.onAfterUpdate(newitems,olditems);
     
     wt1.Lead_Routing__c='Any';
        wt1.Original_Max_Spend__c=210;
    

  wt1.Amendment_Status__c='Pending Pre-Auth Approval';
    update wt1 ;
   
   wmm.onAfterUpdateOnDocuSignAmend(wt1, wt1);
    }catch(Exception e){
        
    }
    Waitlist_Item__c wa1 = new Waitlist_Item__c();
    //olditems.get(wa1.id).Status__c = 'Active';
    //olditems.get(wa1.id).Rank__c!=0;
    Rerank.add(wa1);
    Test.stopTest();
    
}


}