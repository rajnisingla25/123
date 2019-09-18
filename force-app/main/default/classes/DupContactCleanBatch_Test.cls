@isTest(seeAllData =false)
public  class DupContactCleanBatch_Test{
    
    static{
        DuplicateContactBatch__c dcb = new DuplicateContactBatch__c(Name = 'DupContactCleanBatch', Bad_Contact_Email__c = 'BAD Email', Bad_Email__c = 'Yes', Skip_Record_Types__c='consumer');
        insert dcb;
    }

    public static testMethod void mainMethod1(){       
      
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        Switch_AccountRelationshipTrigger__c arc = new Switch_AccountRelationshipTrigger__c(Name ='Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
        insert arc;     
    
        //Inserting Test Account       
         Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
          testAccount.Primary_Email__c = 'testAccount@move.com';
          testAccount.Account_Sub_Type__c ='Prospect';
          testAccount.Type = 'Broker';
          insert testAccount; 
          
        Account childAccount = TestDataFactory.createAccount('Child Account',null,false);
        childAccount.Primary_Email__c = 'childacc@move.com';  
        //childAccount.Type = 'Realtor Office';
        
        insert childAccount;  
        childAccount.Name='Test';
        update childAccount;
       
         //Inserting Test Contact 
        Contact testContact = TestDataFactory.createContact('Test Contact','TestL',testAccount.Id,true,false);
          testContact.Email = 'rshekhawat@move.com';
          testContact.BAD_Email__c = 'Yes';
          testContact.Contact_Party_ID__c ='Test';
          testContact.Process_Flag__c = True;
          testContact.Reference_Winner_Id__c ='Test';
          testContact.NAR_ID__c = '1234567';
          insert testContact;
          
        Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;
        List<Account_Relationship__c> toBeInserted = new List<Account_Relationship__c>();
     
        //Create Account Relationship Records for Accounts
        Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship
                                                                (testAccount.Id, childAccount.Id,  testContact.Id, null, true, false);
        accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
        accountRelation.Active__c = true;
        accountRelation.Is_Parent_Primary__c = true;   
        accountRelation.Billing_Contact__c =true;
        accountRelation.Contact_Role__c = 'Primary Contact';
        toBeInserted.add(accountRelation); //0
        insert toBeInserted;
        
        map<ID,Account_Relationship__c> newValues =new map<ID,Account_Relationship__c> ();
        newValues.put(toBeInserted[0].Id,toBeInserted[0]);
        Test.StartTest();
        DupContactCleanBatch AROSch = new DupContactCleanBatch();
        Database.executeBatch(AROSch,200);     
        Test.StopTest();  
    }
   
    public static testMethod void mainMethod3(){       
      
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        Switch_AccountRelationshipTrigger__c arc = new Switch_AccountRelationshipTrigger__c(Name ='Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
        insert arc;     
    
        //Inserting Test Account       
         Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
          testAccount.Primary_Email__c = 'testAccount@move.com';
          testAccount.Account_Sub_Type__c ='Customer';
          testAccount.Type = 'Broker';
          insert testAccount; 
          
        Account childAccount = TestDataFactory.createAccount('Child Account',null,false);
        childAccount.Primary_Email__c = 'childacc@move.com';  
        //childAccount.Type = 'Realtor Office';
    
        insert childAccount;  
        childAccount.Name='Test';
        update childAccount;
       
         //Inserting Test Contact 
        Contact testContact = TestDataFactory.createContact('Test Contact','TestL',testAccount.Id,true,false);
          testContact.Email = 'rshekhawat@move.com';
          testContact.BAD_Email__c = 'Yes';
          testContact.Contact_Party_ID__c ='Test';
          testContact.Process_Flag__c = True;
          testContact.Reference_Winner_Id__c ='Test';
          testContact.NAR_ID__c = '1234567';
          insert testContact;
          
        Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;
        List<Account_Relationship__c> toBeInserted = new List<Account_Relationship__c>();
     
        //Create Account Relationship Records for Accounts
        Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship
                                                                (testAccount.Id, childAccount.Id,  testContact.Id, null, true, false);
        accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
        accountRelation.Active__c = true;
        accountRelation.Is_Parent_Primary__c = true;   
        accountRelation.Billing_Contact__c =true;
        accountRelation.Contact_Role__c = 'Primary Contact';
        toBeInserted.add(accountRelation); //0
        insert toBeInserted;
      
        map<ID,Account_Relationship__c> newValues =new map<ID,Account_Relationship__c> ();
        newValues.put(toBeInserted[0].Id,toBeInserted[0]);
        Test.StartTest();
        DupContactCleanBatch AROSch = new DupContactCleanBatch();
        Database.executeBatch(AROSch,200);     
        Test.StopTest();  
    }
    public static testMethod void mainMethod4(){       
      
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        Switch_AccountRelationshipTrigger__c arc = new Switch_AccountRelationshipTrigger__c(Name ='Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
        insert arc;     
    
        //Inserting Test Account       
         Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
          testAccount.Primary_Email__c = 'testAccount@move.com';
          testAccount.Account_Sub_Type__c ='Former Customer';
          testAccount.Type = 'Broker';
          insert testAccount; 
          
        Account childAccount = TestDataFactory.createAccount('Child Account',null,false);
        childAccount.Primary_Email__c = 'childacc@move.com';  
        //childAccount.Type = 'Realtor Office';
    
        insert childAccount;  
        childAccount.Name='Test';
        update childAccount;
       
         //Inserting Test Contact 
        Contact testContact = TestDataFactory.createContact('Test Contact','TestL',testAccount.Id,true,false);
          testContact.Email = 'rshekhawat@move.com';
          testContact.BAD_Email__c = 'Yes';
          testContact.Contact_Party_ID__c ='Test';
          testContact.Process_Flag__c = True;
          testContact.Reference_Winner_Id__c ='Test';
          testContact.NAR_ID__c = '1234567';
          insert testContact;
          
        Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;
        List<Account_Relationship__c> toBeInserted = new List<Account_Relationship__c>();
     
        //Create Account Relationship Records for Accounts
        Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship
                                                                (testAccount.Id, childAccount.Id,  testContact.Id, null, true, false);
        accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
        accountRelation.Active__c = true;
        accountRelation.Is_Parent_Primary__c = true;   
        accountRelation.Billing_Contact__c =true;
        accountRelation.Contact_Role__c = 'Primary Contact';
        toBeInserted.add(accountRelation); //0
        insert toBeInserted;
      
        map<ID,Account_Relationship__c> newValues =new map<ID,Account_Relationship__c> ();
        newValues.put(toBeInserted[0].Id,toBeInserted[0]);
        Test.StartTest();
        DupContactCleanBatch AROSch = new DupContactCleanBatch();
        Database.executeBatch(AROSch,200);     
        Test.StopTest();  
    }
    public static testMethod void mainMethod5(){       
      
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
            
        Switch_AccountRelationshipTrigger__c arc = new Switch_AccountRelationshipTrigger__c(Name ='Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
        insert arc;     
    
        //Inserting Test Account       
         Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
          testAccount.Primary_Email__c = 'testAccount@move.com';
          testAccount.Account_Sub_Type__c ='Test';
          testAccount.Type = 'Broker';
          insert testAccount; 
          
        Account childAccount = TestDataFactory.createAccount('Child Account',null,false);
        childAccount.Primary_Email__c = 'childacc@move.com';  
        //childAccount.Type = 'Realtor Office';
    
        insert childAccount;  
        childAccount.Name='Test';
        update childAccount;
       
         //Inserting Test Contact 
        Contact testContact = TestDataFactory.createContact('Test Contact','TestL',testAccount.Id,true,false);
          testContact.Email = 'rshekhawat@move.com';
          testContact.BAD_Email__c = 'Yes';
          testContact.Contact_Party_ID__c ='Test';
          testContact.Process_Flag__c = True;
          testContact.Reference_Winner_Id__c ='Test';
          testContact.NAR_ID__c = '1234567';
          insert testContact;
          
         Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;
          List<Account_Relationship__c> toBeInserted = new List<Account_Relationship__c>();
         
        //Create Account Relationship Records for Accounts
        Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship
                                                                (testAccount.Id, childAccount.Id,  testContact.Id, null, true, false);
        accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
        accountRelation.Active__c = true;
        accountRelation.Is_Parent_Primary__c = true;   
        accountRelation.Billing_Contact__c =true;
        accountRelation.Contact_Role__c = 'Primary Contact';
        toBeInserted.add(accountRelation); //0
        insert toBeInserted;
      
        map<ID,Account_Relationship__c> newValues =new map<ID,Account_Relationship__c> ();
        newValues.put(toBeInserted[0].Id,toBeInserted[0]);
        Test.StartTest();
        DupContactCleanBatch AROSch = new DupContactCleanBatch();
        Database.executeBatch(AROSch,200);     
        Test.StopTest();  
    }
   
    public static testMethod void mainMethod6(){   
   
   
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        Switch_AccountRelationshipTrigger__c arc = new Switch_AccountRelationshipTrigger__c(Name ='Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
        insert arc;     
    
        //Inserting Test Account       
         Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
          testAccount.Primary_Email__c = 'testAccount@move.com';
          testAccount.Account_Sub_Type__c ='Prospect';
          testAccount.Type = 'Broker';
          insert testAccount; 
          
        Account childAccount = TestDataFactory.createAccount('Child Account',null,false);
        childAccount.Primary_Email__c = 'childacc@move.com';  
        //childAccount.Type = 'Realtor Office';
    
        insert childAccount;  
        childAccount.Name='Test';
        update childAccount;
           
         //Inserting Test Contact 
    
        Contact testContact2 = TestDataFactory.createContact('Test Contact2','TestL',testAccount.Id,true,false);
        testContact2.Email = 'rshekhawat@move.com';
        testContact2.BAD_Email__c = 'Yes';
        testContact2.Contact_Party_ID__c ='Test456';
        testContact2.Process_Flag__c = True;
        testContact2.NAR_ID__c = '1234567';
        insert testContact2;
        
        Contact testContact = TestDataFactory.createContact('Test Contact1','TestL',testAccount.Id,true,false);
        testContact.Email = 'rshekhawat1@move.com';
        testContact.BAD_Email__c = 'Yes';
        testContact.Contact_Party_ID__c ='Test123';
        testContact.Process_Flag__c = True;
        testContact.NAR_ID__c = '1234567';
        insert testContact;
                    
        Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;
        List<Account_Relationship__c> toBeInserted = new List<Account_Relationship__c>();
     
        //Create Account Relationship Records for Accounts
        Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship
                                                                (testAccount.Id, childAccount.Id,  testContact.Id, null, true, false);
        accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
        accountRelation.Active__c = true;
        accountRelation.Is_Parent_Primary__c = true;   
        accountRelation.Billing_Contact__c =true;
        accountRelation.Contact_Role__c = 'Primary Contact';
        toBeInserted.add(accountRelation); //0
        Account_Relationship__c accountRelation2 = TestDataFactory.createAccountRelationship
                                                                (testAccount.Id, childAccount.Id,  testContact2.Id, null, true, false);
        accountRelation2.RecordTypeId =  contactRelationshipRecordTypeId;
        accountRelation2.Active__c = true;
        accountRelation2.Is_Parent_Primary__c = true;   
        accountRelation2.Billing_Contact__c =true;
        accountRelation2.Contact_Role__c = 'Primary Contact';
        toBeInserted.add(accountRelation2); //0
        insert toBeInserted;
         
        map<ID,Account_Relationship__c> newValues =new map<ID,Account_Relationship__c> ();
        newValues.put(toBeInserted[0].Id,toBeInserted[0]);
        Test.StartTest();
        DupContactCleanBatch AROSch = new DupContactCleanBatch();
        Database.executeBatch(AROSch,200);     
        Test.StopTest();   
    }
    
    public static testMethod void mainMethod7(){       
      
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        Switch_AccountRelationshipTrigger__c arc = new Switch_AccountRelationshipTrigger__c(Name ='Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
        insert arc;     
    
        //Inserting Test Account       
         Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
          testAccount.Primary_Email__c = 'testAccount@move.com';
          testAccount.Account_Sub_Type__c ='Prospect';
          testAccount.Type = 'Realtor Agent';
          insert testAccount; 
          
        Account childAccount = TestDataFactory.createAccount('Child Account',null,false);
        childAccount.Primary_Email__c = 'childacc@move.com';  
        //childAccount.Type = 'Realtor Office';
    
        insert childAccount;  
        childAccount.Name='Test';
        update childAccount;
       
         //Inserting Test Contact 
        Contact testContact = TestDataFactory.createContact('Test Contact','TestL',testAccount.Id,true,false);
          testContact.Email = 'rshekhawat@move.com';
          testContact.BAD_Email__c = 'Yes';
          testContact.Contact_Party_ID__c ='Test';
          testContact.Process_Flag__c = True;
          testContact.Reference_Winner_Id__c ='Test';
          testContact.NAR_ID__c = '1234567';
          insert testContact;
          
        Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;
        List<Account_Relationship__c> toBeInserted = new List<Account_Relationship__c>();
         
        //Create Account Relationship Records for Accounts
        Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship
                                                                (testAccount.Id, childAccount.Id,  testContact.Id, null, true, false);
        accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
        accountRelation.Active__c = true;
        accountRelation.Is_Parent_Primary__c = true;   
        accountRelation.Billing_Contact__c =true;
        accountRelation.Contact_Role__c = 'Primary Contact';
        toBeInserted.add(accountRelation); //0
        insert toBeInserted;
      
        map<ID,Account_Relationship__c> newValues =new map<ID,Account_Relationship__c> ();
        newValues.put(toBeInserted[0].Id,toBeInserted[0]);
        Test.StartTest();
        DupContactCleanBatch AROSch = new DupContactCleanBatch();
        Database.executeBatch(AROSch,200);     
        Test.StopTest();  
    }
   
    public static testMethod void mainMethod8(){       
      
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        Switch_AccountRelationshipTrigger__c arc = new Switch_AccountRelationshipTrigger__c(Name ='Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
        insert arc;     
    
        //Inserting Test Account       
         Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
          testAccount.Primary_Email__c = 'testAccount@move.com';
          testAccount.Account_Sub_Type__c ='Customer';
          testAccount.Type = 'Realtor Agent';
          insert testAccount; 
          
        Account childAccount = TestDataFactory.createAccount('Child Account',null,false);
        childAccount.Primary_Email__c = 'childacc@move.com';  
        //childAccount.Type = 'Realtor Office';
    
        insert childAccount;  
        childAccount.Name='Test';
        update childAccount;
           
             //Inserting Test Contact 
        Contact testContact = TestDataFactory.createContact('Test Contact','TestL',testAccount.Id,true,false);
          testContact.Email = 'rshekhawat@move.com';
          testContact.BAD_Email__c = 'Yes';
          testContact.Contact_Party_ID__c ='Test';
          testContact.Process_Flag__c = True;
          testContact.Reference_Winner_Id__c ='Test';
          testContact.NAR_ID__c = '1234567';
          insert testContact;
          
        Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;
        List<Account_Relationship__c> toBeInserted = new List<Account_Relationship__c>();
     
        //Create Account Relationship Records for Accounts
        Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship
                                                                (testAccount.Id, childAccount.Id,  testContact.Id, null, true, false);
        accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
        accountRelation.Active__c = true;
        accountRelation.Is_Parent_Primary__c = true;   
        accountRelation.Billing_Contact__c =true;
        accountRelation.Contact_Role__c = 'Primary Contact';
        toBeInserted.add(accountRelation); //0
        insert toBeInserted;
      
        map<ID,Account_Relationship__c> newValues =new map<ID,Account_Relationship__c> ();
        newValues.put(toBeInserted[0].Id,toBeInserted[0]);
        Test.StartTest();
        DupContactCleanBatch AROSch = new DupContactCleanBatch();
        Database.executeBatch(AROSch,200);     
        Test.StopTest();  
    }
    
    public static testMethod void mainMethod9(){       
      
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        Switch_AccountRelationshipTrigger__c arc = new Switch_AccountRelationshipTrigger__c(Name ='Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
        insert arc;     
    
        //Inserting Test Account       
         Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
          testAccount.Primary_Email__c = 'testAccount@move.com';
          testAccount.Account_Sub_Type__c ='Former Customer';
          testAccount.Type = 'Realtor Agent';
          insert testAccount; 
          
        Account childAccount = TestDataFactory.createAccount('Child Account',null,false);
        childAccount.Primary_Email__c = 'childacc@move.com';  
        //childAccount.Type = 'Realtor Office';
    
        insert childAccount;  
        childAccount.Name='Test';
        update childAccount;
           
             //Inserting Test Contact 
        Contact testContact = TestDataFactory.createContact('Test Contact','TestL',testAccount.Id,true,false);
          testContact.Email = 'rshekhawat@move.com';
          testContact.BAD_Email__c = 'Yes';
          testContact.Contact_Party_ID__c ='Test';
          testContact.Process_Flag__c = True;
          testContact.Reference_Winner_Id__c ='Test';
          testContact.NAR_ID__c = '1234567';
          insert testContact;
          
        Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;
        List<Account_Relationship__c> toBeInserted = new List<Account_Relationship__c>();
     
        //Create Account Relationship Records for Accounts
        Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship
                                                                (testAccount.Id, childAccount.Id,  testContact.Id, null, true, false);
        accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
        accountRelation.Active__c = true;
        accountRelation.Is_Parent_Primary__c = true;   
        accountRelation.Billing_Contact__c =true;
        accountRelation.Contact_Role__c = 'Primary Contact';
        toBeInserted.add(accountRelation); //0
        insert toBeInserted;
      
        map<ID,Account_Relationship__c> newValues =new map<ID,Account_Relationship__c> ();
        newValues.put(toBeInserted[0].Id,toBeInserted[0]);
        Test.StartTest();
        DupContactCleanBatch AROSch = new DupContactCleanBatch();
        Database.executeBatch(AROSch,200);     
        Test.StopTest();  
    }

    public static testMethod void mainMethod10(){       
      
        //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        Switch_AccountRelationshipTrigger__c arc = new Switch_AccountRelationshipTrigger__c(Name ='Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
        insert arc;     
    
        //Inserting Test Account       
         Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
          testAccount.Primary_Email__c = 'testAccount@move.com';
          testAccount.Account_Sub_Type__c ='Test';
          testAccount.Type = 'Realtor Agent';
          insert testAccount; 
          
        Account childAccount = TestDataFactory.createAccount('Child Account',null,false);
        childAccount.Primary_Email__c = 'childacc@move.com';  
        //childAccount.Type = 'Realtor Office';
    
        insert childAccount;  
        childAccount.Name='Test';
        update childAccount;
           
             //Inserting Test Contact 
        Contact testContact = TestDataFactory.createContact('Test Contact','TestL',testAccount.Id,true,false);
          testContact.Email = 'rshekhawat@move.com';
          testContact.BAD_Email__c = 'Yes';
          testContact.Contact_Party_ID__c ='Test';
          testContact.Process_Flag__c = True;
          testContact.Reference_Winner_Id__c ='Test';
          testContact.NAR_ID__c = '1234567';
          insert testContact;
          
        Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;
        List<Account_Relationship__c> toBeInserted = new List<Account_Relationship__c>();
     
        //Create Account Relationship Records for Accounts
        Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship
                                                                (testAccount.Id, childAccount.Id,  testContact.Id, null, true, false);
        accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
        accountRelation.Active__c = true;
        accountRelation.Is_Parent_Primary__c = true;   
        accountRelation.Billing_Contact__c =true;
        accountRelation.Contact_Role__c = 'Primary Contact';
        toBeInserted.add(accountRelation); //0
        insert toBeInserted;
      
        map<ID,Account_Relationship__c> newValues =new map<ID,Account_Relationship__c> ();
        newValues.put(toBeInserted[0].Id,toBeInserted[0]);
        Test.StartTest();
        DupContactCleanBatch AROSch = new DupContactCleanBatch();
        Database.executeBatch(AROSch,200);     
        Test.StopTest();  
   }
   
   public static testMethod void mainMethod2(){   
   
   
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        Switch_AccountRelationshipTrigger__c arc = new Switch_AccountRelationshipTrigger__c(Name ='Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
        insert arc;     
    
        //Inserting Test Account       
         Account testAccount = TestDataFactory.createAccount('Test Account',null,false);
          testAccount.Primary_Email__c = 'testAccount@move.com';
          testAccount.Account_Sub_Type__c ='Prospect';
          testAccount.Type = 'Realtor Agent';
          insert testAccount; 
          
        Account childAccount = TestDataFactory.createAccount('Child Account',null,false);
        childAccount.Primary_Email__c = 'childacc@move.com';  
        //childAccount.Type = 'Realtor Office';
    
        insert childAccount;  
        childAccount.Name='Test';
        update childAccount;
       
         //Inserting Test Contact 
    
        Contact testContact2 = TestDataFactory.createContact('Test Contact2','TestL',testAccount.Id,true,false);
        testContact2.Email = 'rshekhawat@move.com';
        testContact2.BAD_Email__c = 'Yes';
        testContact2.Contact_Party_ID__c ='Test456';
        testContact2.Process_Flag__c = True;
        testContact2.NAR_ID__c = '1234567';
        insert testContact2;
        
        Contact testContact = TestDataFactory.createContact('Test Contact1','TestL',testAccount.Id,true,false);
        testContact.Email = 'rshekhawat1@move.com';
        testContact.BAD_Email__c = 'Yes';
        testContact.Contact_Party_ID__c ='Test123';
        testContact.Process_Flag__c = True;
        testContact.NAR_ID__c = '1234567';
        insert testContact;
                   
        Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;
        List<Account_Relationship__c> toBeInserted = new List<Account_Relationship__c>();
        
        //Create Account Relationship Records for Accounts
        Account_Relationship__c accountRelation = TestDataFactory.createAccountRelationship
                                                                (testAccount.Id, childAccount.Id,  testContact.Id, null, true, false);
        accountRelation.RecordTypeId =  contactRelationshipRecordTypeId;
        accountRelation.Active__c = true;
        accountRelation.Is_Parent_Primary__c = true;   
        accountRelation.Billing_Contact__c =true;
        accountRelation.Contact_Role__c = 'Primary Contact';
        toBeInserted.add(accountRelation); //0
        Account_Relationship__c accountRelation2 = TestDataFactory.createAccountRelationship
                                                                (testAccount.Id, childAccount.Id,  testContact2.Id, null, true, false);
        accountRelation2.RecordTypeId =  contactRelationshipRecordTypeId;
        accountRelation2.Active__c = true;
        accountRelation2.Is_Parent_Primary__c = true;   
        accountRelation2.Billing_Contact__c =true;
        accountRelation2.Contact_Role__c = 'Primary Contact';
        toBeInserted.add(accountRelation2); //0
        insert toBeInserted;
         
        map<ID,Account_Relationship__c> newValues =new map<ID,Account_Relationship__c> ();
        newValues.put(toBeInserted[0].Id,toBeInserted[0]);
        Test.StartTest();
        DupContactCleanBatch AROSch = new DupContactCleanBatch();
        Database.executeBatch(AROSch,200);     
        Test.StopTest();   
   }
    static testMethod void method1(){
        DuplicateContactBatch__c dcb = new DuplicateContactBatch__c(Name = 'DupContactCleanBatch', Bad_Contact_Email__c = 'BAD Email', Bad_Email__c = 'Yes', Batch_Size__c = 10 ,Skip_Record_Types__c='consumer');
        insert dcb;
        test.startTest();
        DupContactCleanBatch sh1 = new DupContactCleanBatch();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
 
 }