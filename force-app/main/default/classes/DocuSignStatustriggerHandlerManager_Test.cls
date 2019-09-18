/**********************************************************************
Description: It Cover the DocuSignStatustriggerHandler,DocuSignStatustriggerHandlerManager classes
and DocuSignStatustrigger Trigger.
*********************************************************************/
@IsTest
public class DocuSignStatustriggerHandlerManager_Test{
    Static Testmethod Void DocusignStatusTesting_Sent(){
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        //Inserting Test Account       
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
        testAccount.Primary_Email__c = 'testAccount@move.com';
        testAccount.Billing_Preference__c = 'Invoice-CC';
        insert testAccount;
        //Inserting Test Contact 
        Contact testContact = TestDataFactory.createContact('Test Contact','TestL',testAccount.Id,true,false);
        testContact.Email = 'rshekhawat@move.com';
        insert testContact;
        // Insert Opportunity
        Schema.DescribeSObjectResult OppSchema = Schema.SObjectType.Opportunity; 
        Map<String,Schema.RecordTypeInfo> OppRecType= OppSchema.getRecordTypeInfosByName(); 
        Id opprtId = OppRecType.get('Broker Field Sales').getRecordTypeId(); 
        
        Opportunity op = New Opportunity();
        op.name = 'TESTING BY BOSS';
        op.AccountId = testAccount.id;
        op.Opportunity_Short_Description__c = 'Testing BY BOSS';
        op.CloseDate = System.today().addDays(28);
        op.StageName = 'Qualify Opportunity';
        op.ForecastCategoryName = 'Pipeline';
        op.RecordTypeId = opprtId;
        Insert op;
        
        
        Waitlist__c wldata = new Waitlist__c();
        wldata.Account__c = testAccount.id;
        wldata.Status__c = 'Created';
        wldata.Pre_Auth_Contact__c = testContact.Id;
        wldata.Pre_Auth_Email__c = testContact.Email;
        Insert wldata;
        Product2 prdctdata = new Product2();
        prdctdata.Name = 'product name';
        prdctdata.S_No__c = 2;
        insert prdctdata;
        /*
Waitlist_Item__c wlidata1 = new Waitlist_Item__c();
wlidata1.Waitlist__c    = wldata.Id;
wlidata1.Waitlist_ID__c = '1234'; 
wlidata1.Waitlist_Expiration_Date__c  = system.today();
wlidata1.Original_Max_Spend__c = 100;
wlidata1.Status__c = 'Pending Pre-Auth';
wlidata1.Account__c = testAccount.id;
wlidata1.Product__c = prdctdata.id;
wlidata1.Market__c = '30339';
wlidata1.Market_Type__c = 'City';
wlidata1.Product_Size__c = 'Full';
wlidata1.rank__c = 0;
insert wlidata1;

Waitlist_Item__c wlidata2 = new Waitlist_Item__c();
wlidata2.Waitlist__c    = wldata.Id;
wlidata2.Waitlist_ID__c = '1234'; 
wlidata2.Waitlist_Expiration_Date__c  = system.today();
wlidata2.Original_Max_Spend__c = 100;
wlidata2.Status__c = 'Active';
wlidata2.Account__c = testAccount.id;
wlidata2.Product__c = prdctdata.id;
wlidata2.Market__c = '30339';
wlidata2.Market_Type__c = 'City';
wlidata2.Product_Size__c = 'Full';
wlidata2.rank__c = 1;
insert wlidata2;
*/
        
        
        Test.StartTest();    
        Map<Id,dsfs__DocuSign_Status__c> newitems = New Map<Id,dsfs__DocuSign_Status__c>();
        Map<Id,dsfs__DocuSign_Status__c> olditems = New Map<Id,dsfs__DocuSign_Status__c>();
        list<dsfs__DocuSign_Status__c> newvalues = New list<dsfs__DocuSign_Status__c>();
        list<dsfs__DocuSign_Status__c> oldvalues = New list<dsfs__DocuSign_Status__c> ();
        
        //Inserting DocuSign Status
        dsfs__DocuSign_Status__c ds = new dsfs__DocuSign_Status__c();
        ds.dsfs__Company__c = testAccount.id;
        ds.dsfs__Opportunity__c  = op.id;
        ds.Waitlist__c =wldata.id;
        ds.dsfs__Envelope_Status__c='Sent';
        ds.dsfs__Sent_Date_Time__c = System.now();
        ds.dsfs__Declined_Date_Time__c  = System.now().addDays(12);
        ds.dsfs__Voided_Date_Time__c = System.now().addDays(2);
        ds.dsfs__Completed_Date_Time__c = System.now().addDays(17);
        Insert ds;                 
        newitems.put(ds.id, ds);
        newvalues.add(ds);
        /*
dsfs__DocuSign_Status__c ds1 = new dsfs__DocuSign_Status__c();
ds1.dsfs__Company__c = testAccount.id;
ds1.dsfs__Opportunity__c  = op.id;  
ds1.dsfs__Envelope_Status__c='Completed';
ds1.Waitlist__c =wldata.id;
ds1.dsfs__Voided_Date_Time__c = System.now().addDays(2);                   
Insert ds1;  


dsfs__DocuSign_Status__c ds11 = new dsfs__DocuSign_Status__c();
ds11.dsfs__Company__c = testAccount.id;
ds11.dsfs__Opportunity__c  = op.id;  
ds11.dsfs__Envelope_Status__c='Declined';
ds11.Waitlist__c =wldata.id;
ds11.dsfs__Voided_Date_Time__c = System.now().addDays(2);                   
Insert ds11; 
// newitems.put(ds11.id, ds11);



dsfs__DocuSign_Status__c ds111 = new dsfs__DocuSign_Status__c();
ds111.dsfs__Company__c = testAccount.id;
ds111.dsfs__Opportunity__c  = op.id;  
ds111.dsfs__Envelope_Status__c='Voided';
ds111.Waitlist__c =wldata.id;
ds111.dsfs__Voided_Date_Time__c = System.now().addDays(2);                   
Insert ds111; 


newitems.put(ds111.id, ds111);



newitems.put(ds1.id, ds1);

newvalues.add(ds1);
*/
        
        dsfs__DocuSign_Status__c ds2 = new dsfs__DocuSign_Status__c();
        ds2.dsfs__Company__c = testAccount.id;
        ds2.dsfs__Opportunity__c  = op.id;                     
        ds2.dsfs__Declined_Date_Time__c = System.now().addDays(12);                   
        Insert ds2;  
        newitems.put(ds2.id, ds2);
        newvalues.add(ds2); 
        dsfs__DocuSign_Status__c ds3 = new dsfs__DocuSign_Status__c();
        ds3.dsfs__Company__c = testAccount.id;
        ds3.dsfs__Opportunity__c  = op.id;                     
        ds3.dsfs__Sent_Date_Time__c= System.now();                   
        Insert ds3;  
        newitems.put(ds3.id, ds3);
        newvalues.add(ds3);
        //Insert BigMachines Quotes  
        BigMachines__Quote__c    bq = New BigMachines__Quote__c();
        bq.Name ='TESTING408';
        bq.BigMachines__Status__c = 'Customer Signed';
        bq.BigMachines__Account__c = ds.dsfs__Company__c;
        bq.BigMachines__Opportunity__c = ds.dsfs__Opportunity__c;
        Insert bq;
        
        // Updating  DocuSign Status;  
        ds.dsfs__Completed_Date_Time__c = System.now().addDays(19);
        
        ds.dsfs__Voided_Date_Time__c = System.now().addDays(3);
        Update ds;
        
        /*ds1.dsfs__Voided_Date_Time__c = System.now().addDays(14);
ds2.dsfs__Declined_Date_Time__c = System.now().addDays(14);  
ds3.dsfs__Sent_Date_Time__c= System.now().addDays(1);          
update ds1;
update ds2;
update ds3;
*/
        
        bq.BigMachines__Status__c = 'Customer Signed';
        Update bq;
        olditems.put(ds.id, ds);
        oldvalues.add(ds);
        /*
olditems.put(ds1.id, ds1);
oldvalues.add(ds1);
olditems.put(ds2.id, ds2);
oldvalues.add(ds2);
olditems.put(ds3.id, ds3);
oldvalues.add(ds3);
*/
        
        
        
        
        
        
        DocuSignStatustriggerHandler dst = new DocuSignStatustriggerHandler();
        dst.onBeforeUpdate(newitems, olditems); 
        dst.onAfterInsert(newitems);
        try{
            dst.onAfterUpdateforWaitList(newitems);
        }
        catch(Exception e){
            
        }
        DocuSignStatustriggerHandlerManager DSTR = New DocuSignStatustriggerHandlerManager();
        DSTR.giverank(newvalues , oldvalues);
        //  DSTR.updateCPQStatus(newitems, olditems);
        Test.StopTest();
    }
    
    
    Static Testmethod Void DocusignStatusTesting_Completed2(){
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        //Inserting Test Account       
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
        testAccount.Primary_Email__c = 'testAccount@move.com';
        testAccount.Billing_Preference__c = 'Invoice-CC';
        insert testAccount;
        //Inserting Test Contact 
        Contact testContact = TestDataFactory.createContact('Test Contact','TestL',testAccount.Id,true,false);
        testContact.Email = 'rshekhawat@move.com';
        insert testContact;
        // Insert Opportunity
        Schema.DescribeSObjectResult OppSchema = Schema.SObjectType.Opportunity; 
        Map<String,Schema.RecordTypeInfo> OppRecType= OppSchema.getRecordTypeInfosByName(); 
        Id opprtId = OppRecType.get('Broker Field Sales').getRecordTypeId(); 
        
        Opportunity op = New Opportunity();
        op.name = 'TESTING BY BOSS';
        op.AccountId = testAccount.id;
        op.Opportunity_Short_Description__c = 'Testing BY BOSS';
        op.CloseDate = System.today().addDays(28);
        op.StageName = 'Qualify Opportunity';
        op.ForecastCategoryName = 'Pipeline';
        op.RecordTypeId = opprtId;
        Insert op;
        
        
        Waitlist__c wldata = new Waitlist__c();
        wldata.Account__c = testAccount.id;
        wldata.Status__c = 'Created';
        wldata.Pre_Auth_Contact__c = testContact.Id;
       // wldata.Pre_Auth_Type__c='Renew' ;
        wldata.Pre_Auth_Email__c = testContact.Email;
        Insert wldata;
        Product2 prdctdata = new Product2();
        prdctdata.Name = 'product name';
        prdctdata.S_No__c = 2;
        insert prdctdata;
        
        Waitlist_Item__c wlidata1 = new Waitlist_Item__c();
        wlidata1.Waitlist__c    = wldata.Id;
        wlidata1.Waitlist_ID__c = '1234'; 
        wlidata1.Waitlist_Expiration_Date__c  = system.today();
        wlidata1.Original_Max_Spend__c = 100;
        // wlidata1.Status__c = 'Pending Pre-Auth';
        wlidata1.Account__c = testAccount.id;
        wlidata1.Product__c = prdctdata.id;
        wlidata1.Market__c = '30339';
        wlidata1.Market_Type__c = 'City';
        wlidata1.Product_Size__c = 'Full';
        //wlidata1.Is_Renewed_Row__c = true ; 
        //wlidata1.rank__c = 0;
        insert wlidata1;
        
        Waitlist_Item__c wlidata2 = new Waitlist_Item__c();
        wlidata2.Waitlist__c    = wldata.Id;
        wlidata2.Waitlist_ID__c = '1234'; 
        wlidata2.Waitlist_Expiration_Date__c  = system.today();
        wlidata2.Original_Max_Spend__c = 100;
        //   wlidata2.Status__c = 'Active';
        //wlidata2.Is_Renewed_Row__c = false ; 
        wlidata2.Account__c = testAccount.id;
        wlidata2.Product__c = prdctdata.id;
        wlidata2.Market__c = '30339';
        wlidata2.Market_Type__c = 'City';
        wlidata2.Product_Size__c = 'Full';
        // wlidata2.rank__c = 1;
        insert wlidata2;
        
        
        
        Test.StartTest();    
        Map<Id,dsfs__DocuSign_Status__c> newitems = New Map<Id,dsfs__DocuSign_Status__c>();
        Map<Id,dsfs__DocuSign_Status__c> olditems = New Map<Id,dsfs__DocuSign_Status__c>();
        list<dsfs__DocuSign_Status__c> newvalues = New list<dsfs__DocuSign_Status__c>();
        list<dsfs__DocuSign_Status__c> oldvalues = New list<dsfs__DocuSign_Status__c> ();
        
        
        dsfs__DocuSign_Status__c ds1 = new dsfs__DocuSign_Status__c();
        ds1.dsfs__Company__c = testAccount.id;
        ds1.dsfs__Opportunity__c  = op.id;  
        ds1.dsfs__Envelope_Status__c='Completed';
        ds1.Waitlist__c =wldata.id;
        ds1.dsfs__Voided_Date_Time__c = System.now().addDays(2);                   
        Insert ds1;  
        
        /*
dsfs__DocuSign_Status__c ds11 = new dsfs__DocuSign_Status__c();
ds11.dsfs__Company__c = testAccount.id;
ds11.dsfs__Opportunity__c  = op.id;  
ds11.dsfs__Envelope_Status__c='Declined';
ds11.Waitlist__c =wldata.id;
ds11.dsfs__Voided_Date_Time__c = System.now().addDays(2);                   
Insert ds11; 
// newitems.put(ds11.id, ds11);



dsfs__DocuSign_Status__c ds111 = new dsfs__DocuSign_Status__c();
ds111.dsfs__Company__c = testAccount.id;
ds111.dsfs__Opportunity__c  = op.id;  
ds111.dsfs__Envelope_Status__c='Voided';
ds111.Waitlist__c =wldata.id;
ds111.dsfs__Voided_Date_Time__c = System.now().addDays(2);                   
Insert ds111; 


newitems.put(ds111.id, ds111);



newitems.put(ds1.id, ds1);

newvalues.add(ds1);
*/
        
        dsfs__DocuSign_Status__c ds2 = new dsfs__DocuSign_Status__c();
        ds2.dsfs__Company__c = testAccount.id;
        ds2.dsfs__Opportunity__c  = op.id;                     
        ds2.dsfs__Declined_Date_Time__c = System.now().addDays(12);                   
        Insert ds2;  
        newitems.put(ds2.id, ds2);
        newvalues.add(ds2); 
        dsfs__DocuSign_Status__c ds3 = new dsfs__DocuSign_Status__c();
        ds3.dsfs__Company__c = testAccount.id;
        ds3.dsfs__Opportunity__c  = op.id;                     
        ds3.dsfs__Sent_Date_Time__c= System.now();                   
        Insert ds3;  
        newitems.put(ds3.id, ds3);
        newvalues.add(ds3);
        //Insert BigMachines Quotes  
        BigMachines__Quote__c    bq = New BigMachines__Quote__c();
        bq.Name ='TESTING408';
        bq.BigMachines__Status__c = 'Customer Signed';
        bq.BigMachines__Account__c = ds1.dsfs__Company__c;
        bq.BigMachines__Opportunity__c = ds1.dsfs__Opportunity__c;
        Insert bq;
        
        // Updating  DocuSign Status;  
        ds1.dsfs__Completed_Date_Time__c = System.now().addDays(19);
        
        ds1.dsfs__Voided_Date_Time__c = System.now().addDays(3);
        Update ds1;
        
        /*ds1.dsfs__Voided_Date_Time__c = System.now().addDays(14);
ds2.dsfs__Declined_Date_Time__c = System.now().addDays(14);  
ds3.dsfs__Sent_Date_Time__c= System.now().addDays(1);          
update ds1;
update ds2;
update ds3;
*/
        
        bq.BigMachines__Status__c = 'Customer Signed';
        Update bq;
        olditems.put(ds1.id, ds1);
        oldvalues.add(ds1);
        /*
olditems.put(ds1.id, ds1);
oldvalues.add(ds1);
olditems.put(ds2.id, ds2);
oldvalues.add(ds2);
olditems.put(ds3.id, ds3);
oldvalues.add(ds3);
*/
        
        
        
        
        
        
        DocuSignStatustriggerHandler dst = new DocuSignStatustriggerHandler();
        dst.onBeforeUpdate(newitems, olditems); 
        dst.onAfterInsert(newitems);
        try{
            dst.onAfterUpdateforWaitList(newitems);
        }
        catch(Exception e){
            
        }
        DocuSignStatustriggerHandlerManager DSTR = New DocuSignStatustriggerHandlerManager();
        DSTR.giverank(newvalues , oldvalues);
        //  DSTR.updateCPQStatus(newitems, olditems);
        Test.StopTest();
    }
    
    
    
    Static Testmethod Void DocusignStatusTesting_Completed(){
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        //Inserting Test Account       
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
        testAccount.Primary_Email__c = 'testAccount@move.com';
        testAccount.Billing_Preference__c = 'Invoice-CC';
        insert testAccount;
        //Inserting Test Contact 
        Contact testContact = TestDataFactory.createContact('Test Contact','TestL',testAccount.Id,true,false);
        testContact.Email = 'rshekhawat@move.com';
        insert testContact;
        // Insert Opportunity
        Schema.DescribeSObjectResult OppSchema = Schema.SObjectType.Opportunity; 
        Map<String,Schema.RecordTypeInfo> OppRecType= OppSchema.getRecordTypeInfosByName(); 
        Id opprtId = OppRecType.get('Broker Field Sales').getRecordTypeId(); 
        
        Opportunity op = New Opportunity();
        op.name = 'TESTING BY BOSS';
        op.AccountId = testAccount.id;
        op.Opportunity_Short_Description__c = 'Testing BY BOSS';
        op.CloseDate = System.today().addDays(28);
        op.StageName = 'Qualify Opportunity';
        op.ForecastCategoryName = 'Pipeline';
        op.RecordTypeId = opprtId;
        Insert op;
        
        
        Waitlist__c wldata = new Waitlist__c();
        wldata.Account__c = testAccount.id;
        wldata.Status__c = 'Created';
        wldata.Pre_Auth_Contact__c = testContact.Id;
        wldata.Pre_Auth_Type__c='Renew' ;
        wldata.Pre_Auth_Email__c = testContact.Email;
        Insert wldata;
        Product2 prdctdata = new Product2();
        prdctdata.Name = 'product name';
        prdctdata.S_No__c = 2;
        insert prdctdata;
        
        Waitlist_Item__c wlidata1 = new Waitlist_Item__c();
        wlidata1.Waitlist__c    = wldata.Id;
        wlidata1.Waitlist_ID__c = '1234'; 
        wlidata1.Waitlist_Expiration_Date__c  = system.today();
        wlidata1.Original_Max_Spend__c = 100;
        wlidata1.Status__c = 'Pending Pre-Auth Approval';
        wlidata1.Account__c = testAccount.id;
        wlidata1.Product__c = prdctdata.id;
        wlidata1.Market__c = '30339';
        wlidata1.Market_Type__c = 'City';
        wlidata1.Product_Size__c = 'Full';
        wlidata1.Is_Renewed_Row__c = true ; 
        //wlidata1.rank__c = 0;
        insert wlidata1;
        
        Waitlist_Item__c wlidata2 = new Waitlist_Item__c();
        wlidata2.Waitlist__c    = wldata.Id;
        wlidata2.Waitlist_ID__c = '1234'; 
        wlidata2.Waitlist_Expiration_Date__c  = system.today();
        wlidata2.Original_Max_Spend__c = 100;
        //   wlidata2.Status__c = 'Active';
        wlidata2.Is_Renewed_Row__c = false ; 
        wlidata2.Account__c = testAccount.id;
        wlidata2.Product__c = prdctdata.id;
        wlidata2.Market__c = '30339';
        wlidata2.Market_Type__c = 'City';
        wlidata2.Product_Size__c = 'Full';
        // wlidata2.rank__c = 1;
        insert wlidata2;
        
        
        
        Test.StartTest();    
        Map<Id,dsfs__DocuSign_Status__c> newitems = New Map<Id,dsfs__DocuSign_Status__c>();
        Map<Id,dsfs__DocuSign_Status__c> olditems = New Map<Id,dsfs__DocuSign_Status__c>();
        list<dsfs__DocuSign_Status__c> newvalues = New list<dsfs__DocuSign_Status__c>();
        list<dsfs__DocuSign_Status__c> oldvalues = New list<dsfs__DocuSign_Status__c> ();
        
        
        dsfs__DocuSign_Status__c ds1 = new dsfs__DocuSign_Status__c();
        ds1.dsfs__Company__c = testAccount.id;
        ds1.dsfs__Opportunity__c  = op.id;  
        ds1.dsfs__Envelope_Status__c='Completed';
        ds1.Waitlist__c =wldata.id;
        ds1.dsfs__Voided_Date_Time__c = System.now().addDays(2);                   
        Insert ds1;  
        
        /*
dsfs__DocuSign_Status__c ds11 = new dsfs__DocuSign_Status__c();
ds11.dsfs__Company__c = testAccount.id;
ds11.dsfs__Opportunity__c  = op.id;  
ds11.dsfs__Envelope_Status__c='Declined';
ds11.Waitlist__c =wldata.id;
ds11.dsfs__Voided_Date_Time__c = System.now().addDays(2);                   
Insert ds11; 
// newitems.put(ds11.id, ds11);



dsfs__DocuSign_Status__c ds111 = new dsfs__DocuSign_Status__c();
ds111.dsfs__Company__c = testAccount.id;
ds111.dsfs__Opportunity__c  = op.id;  
ds111.dsfs__Envelope_Status__c='Voided';
ds111.Waitlist__c =wldata.id;
ds111.dsfs__Voided_Date_Time__c = System.now().addDays(2);                   
Insert ds111; 


newitems.put(ds111.id, ds111);



newitems.put(ds1.id, ds1);

newvalues.add(ds1);
*/
        
        dsfs__DocuSign_Status__c ds2 = new dsfs__DocuSign_Status__c();
        ds2.dsfs__Company__c = testAccount.id;
        ds2.dsfs__Opportunity__c  = op.id;                     
        ds2.dsfs__Declined_Date_Time__c = System.now().addDays(12);                   
        Insert ds2;  
        newitems.put(ds2.id, ds2);
        newvalues.add(ds2); 
        dsfs__DocuSign_Status__c ds3 = new dsfs__DocuSign_Status__c();
        ds3.dsfs__Company__c = testAccount.id;
        ds3.dsfs__Opportunity__c  = op.id;                     
        ds3.dsfs__Sent_Date_Time__c= System.now();                   
        Insert ds3;  
        newitems.put(ds3.id, ds3);
        newvalues.add(ds3);
        //Insert BigMachines Quotes  
        BigMachines__Quote__c    bq = New BigMachines__Quote__c();
        bq.Name ='TESTING408';
        bq.BigMachines__Status__c = 'Customer Signed';
        bq.BigMachines__Account__c = ds1.dsfs__Company__c;
        bq.BigMachines__Opportunity__c = ds1.dsfs__Opportunity__c;
        Insert bq;
        
        // Updating  DocuSign Status;  
        ds1.dsfs__Completed_Date_Time__c = System.now().addDays(19);
        
        ds1.dsfs__Voided_Date_Time__c = System.now().addDays(3);
        Update ds1;
        
        /*ds1.dsfs__Voided_Date_Time__c = System.now().addDays(14);
ds2.dsfs__Declined_Date_Time__c = System.now().addDays(14);  
ds3.dsfs__Sent_Date_Time__c= System.now().addDays(1);          
update ds1;
update ds2;
update ds3;
*/
        
        bq.BigMachines__Status__c = 'Customer Signed';
        Update bq;
        olditems.put(ds1.id, ds1);
        oldvalues.add(ds1);
        /*
olditems.put(ds1.id, ds1);
oldvalues.add(ds1);
olditems.put(ds2.id, ds2);
oldvalues.add(ds2);
olditems.put(ds3.id, ds3);
oldvalues.add(ds3);
*/
        
        
        
        
        
        
        DocuSignStatustriggerHandler dst = new DocuSignStatustriggerHandler();
        dst.onBeforeUpdate(newitems, olditems); 
        dst.onAfterInsert(newitems);
        try{
            dst.onAfterUpdateforWaitList(newitems);
        }
        catch(Exception e){
            
        }
        DocuSignStatustriggerHandlerManager DSTR = New DocuSignStatustriggerHandlerManager();
        DSTR.giverank(newvalues , oldvalues);
        //  DSTR.updateCPQStatus(newitems, olditems);
        Test.StopTest();
    }
    
    
    Static Testmethod Void DocusignStatusTesting_Voided(){
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        //Inserting Test Account       
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
        testAccount.Primary_Email__c = 'testAccount@move.com';
        testAccount.Billing_Preference__c = 'Invoice-CC';
        insert testAccount;
        //Inserting Test Contact 
        Contact testContact = TestDataFactory.createContact('Test Contact','TestL',testAccount.Id,true,false);
        testContact.Email = 'rshekhawat@move.com';
        insert testContact;
        // Insert Opportunity
        Schema.DescribeSObjectResult OppSchema = Schema.SObjectType.Opportunity; 
        Map<String,Schema.RecordTypeInfo> OppRecType= OppSchema.getRecordTypeInfosByName(); 
        Id opprtId = OppRecType.get('Broker Field Sales').getRecordTypeId(); 
        
        Opportunity op = New Opportunity();
        op.name = 'TESTING BY BOSS';
        op.AccountId = testAccount.id;
        op.Opportunity_Short_Description__c = 'Testing BY BOSS';
        op.CloseDate = System.today().addDays(28);
        op.StageName = 'Qualify Opportunity';
        op.ForecastCategoryName = 'Pipeline';
        op.RecordTypeId = opprtId;
        Insert op;
        
        
        Waitlist__c wldata = new Waitlist__c();
        wldata.Account__c = testAccount.id;
        wldata.Status__c = 'Created';
        wldata.Pre_Auth_Contact__c = testContact.Id;
        wldata.Pre_Auth_Email__c = testContact.Email;
        Insert wldata;
        Product2 prdctdata = new Product2();
        prdctdata.Name = 'product name';
        prdctdata.S_No__c = 2;
        insert prdctdata;
        /*
Waitlist_Item__c wlidata1 = new Waitlist_Item__c();
wlidata1.Waitlist__c    = wldata.Id;
wlidata1.Waitlist_ID__c = '1234'; 
wlidata1.Waitlist_Expiration_Date__c  = system.today();
wlidata1.Original_Max_Spend__c = 100;
wlidata1.Status__c = 'Pending Pre-Auth';
wlidata1.Account__c = testAccount.id;
wlidata1.Product__c = prdctdata.id;
wlidata1.Market__c = '30339';
wlidata1.Market_Type__c = 'City';
wlidata1.Product_Size__c = 'Full';
wlidata1.rank__c = 0;
insert wlidata1;

Waitlist_Item__c wlidata2 = new Waitlist_Item__c();
wlidata2.Waitlist__c    = wldata.Id;
wlidata2.Waitlist_ID__c = '1234'; 
wlidata2.Waitlist_Expiration_Date__c  = system.today();
wlidata2.Original_Max_Spend__c = 100;
wlidata2.Status__c = 'Active';
wlidata2.Account__c = testAccount.id;
wlidata2.Product__c = prdctdata.id;
wlidata2.Market__c = '30339';
wlidata2.Market_Type__c = 'City';
wlidata2.Product_Size__c = 'Full';
wlidata2.rank__c = 1;
insert wlidata2;
*/
        
        
        Test.StartTest();    
        Map<Id,dsfs__DocuSign_Status__c> newitems = New Map<Id,dsfs__DocuSign_Status__c>();
        Map<Id,dsfs__DocuSign_Status__c> olditems = New Map<Id,dsfs__DocuSign_Status__c>();
        list<dsfs__DocuSign_Status__c> newvalues = New list<dsfs__DocuSign_Status__c>();
        list<dsfs__DocuSign_Status__c> oldvalues = New list<dsfs__DocuSign_Status__c> ();
        
        
        
        
        dsfs__DocuSign_Status__c ds11 = new dsfs__DocuSign_Status__c();
        ds11.dsfs__Company__c = testAccount.id;
        ds11.dsfs__Opportunity__c  = op.id;  
        ds11.dsfs__Envelope_Status__c='Voided';
        ds11.Waitlist__c =wldata.id;
        ds11.dsfs__Voided_Date_Time__c = System.now().addDays(2);                   
        Insert ds11; 
        // newitems.put(ds11.id, ds11);
        
        /*

dsfs__DocuSign_Status__c ds111 = new dsfs__DocuSign_Status__c();
ds111.dsfs__Company__c = testAccount.id;
ds111.dsfs__Opportunity__c  = op.id;  
ds111.dsfs__Envelope_Status__c='Voided';
ds111.Waitlist__c =wldata.id;
ds111.dsfs__Voided_Date_Time__c = System.now().addDays(2);                   
Insert ds111; 


newitems.put(ds111.id, ds111);



newitems.put(ds1.id, ds1);

newvalues.add(ds1);
*/
        
        dsfs__DocuSign_Status__c ds2 = new dsfs__DocuSign_Status__c();
        ds2.dsfs__Company__c = testAccount.id;
        ds2.dsfs__Opportunity__c  = op.id;                     
        ds2.dsfs__Declined_Date_Time__c = System.now().addDays(12);                   
        Insert ds2;  
        newitems.put(ds2.id, ds2);
        newvalues.add(ds2); 
        dsfs__DocuSign_Status__c ds3 = new dsfs__DocuSign_Status__c();
        ds3.dsfs__Company__c = testAccount.id;
        ds3.dsfs__Opportunity__c  = op.id;                     
        ds3.dsfs__Sent_Date_Time__c= System.now();                   
        Insert ds3;  
        newitems.put(ds3.id, ds3);
        newvalues.add(ds3);
        //Insert BigMachines Quotes  
        BigMachines__Quote__c    bq = New BigMachines__Quote__c();
        bq.Name ='TESTING408';
        bq.BigMachines__Status__c = 'Customer Signed';
        bq.BigMachines__Account__c = ds11.dsfs__Company__c;
        bq.BigMachines__Opportunity__c = ds11.dsfs__Opportunity__c;
        Insert bq;
        
        // Updating  DocuSign Status;  
        ds11.dsfs__Completed_Date_Time__c = System.now().addDays(19);
        
        ds11.dsfs__Voided_Date_Time__c = System.now().addDays(3);
        Update ds11;
        
        /*ds1.dsfs__Voided_Date_Time__c = System.now().addDays(14);
ds2.dsfs__Declined_Date_Time__c = System.now().addDays(14);  
ds3.dsfs__Sent_Date_Time__c= System.now().addDays(1);          
update ds1;
update ds2;
update ds3;
*/
        
        bq.BigMachines__Status__c = 'Customer Signed';
        Update bq;
        olditems.put(ds11.id, ds11);
        oldvalues.add(ds11);
        /*
olditems.put(ds1.id, ds1);
oldvalues.add(ds1);
olditems.put(ds2.id, ds2);
oldvalues.add(ds2);
olditems.put(ds3.id, ds3);
oldvalues.add(ds3);
*/
        
        
        
        
        
        
        DocuSignStatustriggerHandler dst = new DocuSignStatustriggerHandler();
        dst.onBeforeUpdate(newitems, olditems); 
        dst.onAfterInsert(newitems);
        try{
            dst.onAfterUpdateforWaitList(newitems);
        }
        catch(Exception e){
            
        }
        DocuSignStatustriggerHandlerManager DSTR = New DocuSignStatustriggerHandlerManager();
        DSTR.giverank(newvalues , oldvalues);
        //  DSTR.updateCPQStatus(newitems, olditems);
        Test.StopTest();
    }
    Static Testmethod Void DocusignStatusTesting_Declined(){
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        //Inserting Test Account       
        Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
        testAccount.Primary_Email__c = 'testAccount@move.com';
        testAccount.Billing_Preference__c = 'Invoice-CC';
        insert testAccount;
        //Inserting Test Contact 
        Contact testContact = TestDataFactory.createContact('Test Contact','TestL',testAccount.Id,true,false);
        testContact.Email = 'rshekhawat@move.com';
        insert testContact;
        // Insert Opportunity
        Schema.DescribeSObjectResult OppSchema = Schema.SObjectType.Opportunity; 
        Map<String,Schema.RecordTypeInfo> OppRecType= OppSchema.getRecordTypeInfosByName(); 
        Id opprtId = OppRecType.get('Broker Field Sales').getRecordTypeId(); 
        
        Opportunity op = New Opportunity();
        op.name = 'TESTING BY BOSS';
        op.AccountId = testAccount.id;
        op.Opportunity_Short_Description__c = 'Testing BY BOSS';
        op.CloseDate = System.today().addDays(28);
        op.StageName = 'Qualify Opportunity';
        op.ForecastCategoryName = 'Pipeline';
        op.RecordTypeId = opprtId;
        Insert op;
        
        
        Waitlist__c wldata = new Waitlist__c();
        wldata.Account__c = testAccount.id;
        wldata.Status__c = 'Created';
        wldata.Pre_Auth_Contact__c = testContact.Id;
        wldata.Pre_Auth_Email__c = testContact.Email;
        Insert wldata;
        Product2 prdctdata = new Product2();
        prdctdata.Name = 'product name';
        prdctdata.S_No__c = 2;
        insert prdctdata;
        /*
Waitlist_Item__c wlidata1 = new Waitlist_Item__c();
wlidata1.Waitlist__c    = wldata.Id;
wlidata1.Waitlist_ID__c = '1234'; 
wlidata1.Waitlist_Expiration_Date__c  = system.today();
wlidata1.Original_Max_Spend__c = 100;
wlidata1.Status__c = 'Pending Pre-Auth';
wlidata1.Account__c = testAccount.id;
wlidata1.Product__c = prdctdata.id;
wlidata1.Market__c = '30339';
wlidata1.Market_Type__c = 'City';
wlidata1.Product_Size__c = 'Full';
wlidata1.rank__c = 0;
insert wlidata1;

Waitlist_Item__c wlidata2 = new Waitlist_Item__c();
wlidata2.Waitlist__c    = wldata.Id;
wlidata2.Waitlist_ID__c = '1234'; 
wlidata2.Waitlist_Expiration_Date__c  = system.today();
wlidata2.Original_Max_Spend__c = 100;
wlidata2.Status__c = 'Active';
wlidata2.Account__c = testAccount.id;
wlidata2.Product__c = prdctdata.id;
wlidata2.Market__c = '30339';
wlidata2.Market_Type__c = 'City';
wlidata2.Product_Size__c = 'Full';
wlidata2.rank__c = 1;
insert wlidata2;
*/
        
        
        Test.StartTest();    
        Map<Id,dsfs__DocuSign_Status__c> newitems = New Map<Id,dsfs__DocuSign_Status__c>();
        Map<Id,dsfs__DocuSign_Status__c> olditems = New Map<Id,dsfs__DocuSign_Status__c>();
        list<dsfs__DocuSign_Status__c> newvalues = New list<dsfs__DocuSign_Status__c>();
        list<dsfs__DocuSign_Status__c> oldvalues = New list<dsfs__DocuSign_Status__c> ();
        
        
        
        
        dsfs__DocuSign_Status__c ds11 = new dsfs__DocuSign_Status__c();
        ds11.dsfs__Company__c = testAccount.id;
        ds11.dsfs__Opportunity__c  = op.id;  
        ds11.dsfs__Envelope_Status__c='Declined';
        ds11.Waitlist__c =wldata.id;
        ds11.dsfs__Voided_Date_Time__c = System.now().addDays(2);                   
        Insert ds11; 
        // newitems.put(ds11.id, ds11);
        
        /*

dsfs__DocuSign_Status__c ds111 = new dsfs__DocuSign_Status__c();
ds111.dsfs__Company__c = testAccount.id;
ds111.dsfs__Opportunity__c  = op.id;  
ds111.dsfs__Envelope_Status__c='Voided';
ds111.Waitlist__c =wldata.id;
ds111.dsfs__Voided_Date_Time__c = System.now().addDays(2);                   
Insert ds111; 


newitems.put(ds111.id, ds111);



newitems.put(ds1.id, ds1);

newvalues.add(ds1);
*/
        
        dsfs__DocuSign_Status__c ds2 = new dsfs__DocuSign_Status__c();
        ds2.dsfs__Company__c = testAccount.id;
        ds2.dsfs__Opportunity__c  = op.id;                     
        ds2.dsfs__Declined_Date_Time__c = System.now().addDays(12);                   
        Insert ds2;  
        newitems.put(ds2.id, ds2);
        newvalues.add(ds2); 
        dsfs__DocuSign_Status__c ds3 = new dsfs__DocuSign_Status__c();
        ds3.dsfs__Company__c = testAccount.id;
        ds3.dsfs__Opportunity__c  = op.id;                     
        ds3.dsfs__Sent_Date_Time__c= System.now();                   
        Insert ds3;  
        newitems.put(ds3.id, ds3);
        newvalues.add(ds3);
        //Insert BigMachines Quotes  
        BigMachines__Quote__c    bq = New BigMachines__Quote__c();
        bq.Name ='TESTING408';
        bq.BigMachines__Status__c = 'Customer Signed';
        bq.BigMachines__Account__c = ds11.dsfs__Company__c;
        bq.BigMachines__Opportunity__c = ds11.dsfs__Opportunity__c;
        Insert bq;
        
        // Updating  DocuSign Status;  
        ds11.dsfs__Completed_Date_Time__c = System.now().addDays(19);
        
        ds11.dsfs__Voided_Date_Time__c = System.now().addDays(3);
        Update ds11;
        
        /*ds1.dsfs__Voided_Date_Time__c = System.now().addDays(14);
ds2.dsfs__Declined_Date_Time__c = System.now().addDays(14);  
ds3.dsfs__Sent_Date_Time__c= System.now().addDays(1);          
update ds1;
update ds2;
update ds3;
*/
        
        bq.BigMachines__Status__c = 'Customer Signed';
        Update bq;
        olditems.put(ds11.id, ds11);
        oldvalues.add(ds11);
        /*
olditems.put(ds1.id, ds1);
oldvalues.add(ds1);
olditems.put(ds2.id, ds2);
oldvalues.add(ds2);
olditems.put(ds3.id, ds3);
oldvalues.add(ds3);
*/
        
        
        
        
        
        
        DocuSignStatustriggerHandler dst = new DocuSignStatustriggerHandler();
        dst.onBeforeUpdate(newitems, olditems); 
        dst.onAfterInsert(newitems);
        try{
            dst.onAfterUpdateforWaitList(newitems);
        }
        catch(Exception e){
            
        }
        DocuSignStatustriggerHandlerManager DSTR = New DocuSignStatustriggerHandlerManager();
        DSTR.giverank(newvalues , oldvalues);
        //  DSTR.updateCPQStatus(newitems, olditems);
        Test.StopTest();
    }
}