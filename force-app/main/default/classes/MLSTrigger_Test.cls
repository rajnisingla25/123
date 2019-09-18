@isTest(seeAllData = false)
public class MLSTrigger_Test {
 
 static testMethod void testmethod_one() {

     //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
    insert Dtrg;

    // Inserting account records.
    list<Account> accs = new list<Account>();
    list<MLS__c>  mlsList = new list<MLS__c>();
    list<MLS__c>  mlsListUpdate = new list<MLS__c>();


    //insert parentAccount;
    Account officeAccount = TestDataFactory.createAccount('Office Account', null, false);
    officeAccount.Primary_Email__c = 'parentAcc@move.com';
    officeAccount.type = 'Realtor Office';
    accs.add(officeAccount);

    Account agentAccount = TestDataFactory.createAccount('Office Account', null, false);
    agentAccount.Primary_Email__c = 'parentAcc@move.com';
    agentAccount.type = 'Realtor Agent';
    accs.add(agentAccount);
    insert accs;

    for(Account oacc:accs){
        if(oacc.type != null){
        MLS__c mlsInsert = new MLS__c();
        mlsInsert.Name = 'testMLS'+oacc.type;
        mlsInsert.MLS__c = oacc.ID;
            if(oacc.type == 'Realtor Office'){
            mlsInsert.Office__c = oacc.ID;
            mlsInsert.Primary_MLS_Set__c = false; 
        }
            else{
            mlsInsert.Agent__c = oacc.ID;
            mlsInsert.Primary_MLS_Set__c = true; 
        }
        
        mlsList.add(mlsInsert);     
        }
    }

    if(!mlsList.isEmpty())
        insert mlsList;
    for(MLS__c omls:mlsList){
        MLS__c tempmls = new MLS__c(ID=omls.ID);
            if(!omls.Primary_MLS_Set__c)
            tempmls.Primary_MLS_Set__c = true;
            else
            tempmls.Primary_MLS_Set__c = false;         
        mlsListUpdate.add(tempmls);
    }  
     if(!mlsListUpdate.isEmpty())
        update mlsListUpdate;

 }
 
 static testMethod void testmethodsettype() {

     //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
    insert Dtrg;

    // Inserting account records.
    list<Account> accs = new list<Account>();
    list<MLS__c>  mlsList = new list<MLS__c>();
    list<MLS__c>  mlsListUpdate = new list<MLS__c>();


    //insert parentAccount;
    Account officeAccount = TestDataFactory.createAccount('Office Account', null, false);
    officeAccount.Primary_Email__c = 'parentAcc@move.com';
    officeAccount.type = 'Realtor Office';
    accs.add(officeAccount);

    Account agentAccount = TestDataFactory.createAccount('Office Account', null, false);
    agentAccount.Primary_Email__c = 'parentAcc@move.com';
    agentAccount.type = 'Realtor Agent';
    accs.add(agentAccount);
    insert accs;

    for(Account oacc:accs){
        if(oacc.type != null){
        MLS__c mlsInsert = new MLS__c();
        mlsInsert.Name = 'testMLS'+oacc.type;
        mlsInsert.MLS__c = oacc.ID;
            if(oacc.type == 'Realtor Office'){
            mlsInsert.Office__c = oacc.ID;
            mlsInsert.Primary_MLS_Set__c = false; 
        }
            else{
            mlsInsert.Agent__c = oacc.ID;
            mlsInsert.Primary_MLS_Set__c = true; 
        }
        mlsInsert.MLS_Set_Type__c ='office';
        mlsList.add(mlsInsert);     
        }
    }

    if(!mlsList.isEmpty())
        insert mlsList;
    for(MLS__c omls:mlsList){
        MLS__c tempmls = new MLS__c(ID=omls.ID);
            if(!omls.Primary_MLS_Set__c)
            tempmls.Primary_MLS_Set__c = true;
            else
            tempmls.Primary_MLS_Set__c = false;         
        mlsListUpdate.add(tempmls);
    }  
     if(!mlsListUpdate.isEmpty())
        update mlsListUpdate;

 }   


}