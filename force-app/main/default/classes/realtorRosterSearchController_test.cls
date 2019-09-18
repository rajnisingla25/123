// Test class for realtorRosterSearchController and mlsRecordsController
@isTest
public class realtorRosterSearchController_test {
    
    public static testMethod void searchMLS(){
        realtorRosterSearchController r = new realtorRosterSearchController();
        r.officeName = 'o';
        r.agentName = 'a';
        r.state = 'CA';
        r.mlsAcctName = 'abc';
        r.searchMLS();
    }
    
    public static testMethod void mlsRecordsExport(){
        
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

    Account agentAccount = TestDataFactory.createAccount('Agent Account', null, false);
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
            mlsInsert.Status__c = 'Active';
        }
            else{
            mlsInsert.Agent__c = oacc.ID;
            mlsInsert.MLS_Set_Type__c = 'Realtor Agent';
            mlsInsert.Primary_MLS_Set__c = true; 
            mlsInsert.Status__c = 'Inactive';
        }
        
        mlsList.add(mlsInsert);     
        }
    }

    if(!mlsList.isEmpty())
        insert mlsList;
        
         PageReference pageRef = Page.MLSRecords;
        pageRef.getParameters().put('mlsType', 'Realtor Agent');
          pageRef.getParameters().put('mlsId', '');
          pageRef.getParameters().put('state', '');
          pageRef.getParameters().put('officeName', '');
          pageRef.getParameters().put('mlsStatus', '');
         pageRef.getParameters().put('mlsAlias', '');
        Test.setCurrentPage(pageRef);
        
        mlsRecordsController m = new mlsRecordsController();
        
    }
    
       

}