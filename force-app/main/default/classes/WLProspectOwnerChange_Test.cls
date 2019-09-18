@isTest(seeAllData=false)
public class WLProspectOwnerChange_Test{
    public static testMethod void main(){
    
        Profile p = [select id from profile where name='Open Book Profile'];
        User user1 = Commissions_TestDataFactory.createUser(null,p.id,null,'test1548@move.com','test1548@move.com',true,'Collection Team');
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
            insert Dtrg;
        Incremental_data_load__c ic = new Incremental_data_load__c(Name= 'Incremental_data_load'  , Disable_Validation_Rules__c = true);
        insert ic;    
            
       //Inserting Test Account       
             Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
              testAccount.Primary_Email__c = 'testAccount@move.com';              
              testAccount.Account_Sub_Type__c = 'Prospect';
              testAccount.OwnerId = user1.Id;
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
              
             Test.StartTest();        
      list<dsfs__DocuSign_Status__c> newvalues = New list<dsfs__DocuSign_Status__c>();
      
        //Inserting DocuSign Status
                 dsfs__DocuSign_Status__c ds = new dsfs__DocuSign_Status__c();
                     ds.dsfs__Company__c = testAccount.id;
                     ds.dsfs__Opportunity__c  = op.id;
                     ds.dsfs__Sent_Date_Time__c = System.now();
                     ds.dsfs__Declined_Date_Time__c  = System.now().addDays(12);
                     ds.dsfs__Voided_Date_Time__c = System.now().addDays(2);
                     ds.dsfs__Completed_Date_Time__c = System.now().addDays(17);
                     ds.Waitlist__c = wldata.Id;
              Insert ds;              
              newvalues.add(ds);
            WLProspectOwnerChange wlp = new WLProspectOwnerChange();
            WLProspectOwnerChange.ProspectOwnerChange(newvalues);  
              
         Test.StopTest();                    
                 
    }
 }