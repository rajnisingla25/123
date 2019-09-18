@isTest
public class EssentialsWelcomeBatch_Test {

    static testMethod void method1(){
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        // Insert account as current user
        System.runAs (thisUser) { 
        	EmailTemplate e = new EmailTemplate (developerName = 'EssentialsWelcomeEmailOnetime', folderId=UserInfo.getUserId(),TemplateType= 'Custom', Name = 'Essentials Welcome Email Onetime'); 
            insert e;
        }
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        Collection_Users__c coll = new Collection_Users__c(Name='batchintegration user', id__c= '005j000000CdBiE');
        insert coll;
        
        //Inserting Test Account
        Account newAccount = TestDataFactory.createAccount('newAccount',null,false);
            newAccount.Primary_Email__c = 'testAccount@move.com';
            newAccount.Type = 'Broker';
            newAccount.party_id__c ='12345';            
        insert newAccount; 
        newAccount.EssentialsStatus__c  = 'Activated';
        update newAccount;
        
        //Inserting Test Contact 
        Contact testContact = TestDataFactory.createContact('Test Contact','TestL',newAccount.Id,true,false);
              testContact.Email = 'testAccount@move.com';
        insert testContact; 
        List<Account> accounts = [ SELECT  Id, Name, EssentialsStatus__c FROM Account WHERE EssentialsStatus__c = 'Activated' AND Type = 'Broker'];
        
        Product2 newProduct = new Product2();
            newProduct.Name = 'TestProduct';
            newProduct.Commission_Category__c = 'Normal';    
            newProduct.Normalization_factor__c = 1.10;
            newProduct.Commission_Category__c = 'CFCB';
            newProduct.Fulfillment_Type__c = 'Manual';
            newProduct.Auto_Renewal__c = True;
            newProduct.S_No__c = 2;
            newProduct.EssentialsRequired__c = true;
        insert newProduct;   
        string RecordTypId = [SELECT id from RecordType where Name ='Contact Relationship'].Id;
        Account_Relationship__c primarycntct = new Account_Relationship__c();
            primarycntct .Contact_To__c = testContact.id;
            primarycntct.Contact_Role__c = 'Primary Contact';
            primarycntct.Entity_Name__c = 'abc';
            primarycntct.Is_Parent_Primary__c = true;
            primarycntct.Billing_Contact__c = true;
            primarycntct.Parent_Account__c = newAccount.id;
            primarycntct.Active__c = true;
            primarycntct.RecordTypeId = RecordTypId;
            primarycntct.Relationship_Type__c = 'Member';
            primarycntct.Zuora_Bill_to_Contact_ID__c = 'test';
            primarycntct.Zuora_Ship_to_Contact_ID__c = 'testing';
            primarycntct.Zuora_Sync__c = true;
        insert primarycntct;
        
        Asset assets = new Asset();
            assets.Name = 'test';
            assets.Renewal_Status__c = 'Renew';
            assets.Auto_Renewal__c = 'No';
            assets.Asset_Type__c = 'Parent';
            assets.AccountId = newAccount.id;
            assets.Product2Id = newProduct.id;
            assets.Fulfillment_Status__c = 'Fulfilled';
            assets.Status = 'Active';
            assets.At_Risk__c = false;
            assets.Billing_Period__c = 'Monthly';
            assets.Start_Date__c = system.today();
            assets.End_Date__c = system.today().addDays(10);
            assets.Asset_Type__c = 'Parent';
            assets.Auto_Renewal__c  = 'Yes';
            assets.Price = 10.00;
        insert assets;
        
        System.debug('accounts:'+accounts);
        test.startTest();
            EssentialsWelcomeBatch sh1 = new EssentialsWelcomeBatch();
            Database.BatchableContext bc; 	
            sh1.execute(bc,accounts);
            String sch = '0 0 23 * * ?';
            system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }

}