@isTest(seeAllData = false)
public  class TaskHelper_Test{
private static final Integer COUNTER = 5;

    public static testMethod void main(){ 
     MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
     User u = mtduc.CreateUserSingle();  
     mtduc.UpdateUserSingle();   

     //Inserting Customsetting
     string username = userinfo.getUserName();
    // Attachmentactivitydeleteaccess__c Dtrg1 = new Attachmentactivitydeleteaccess__c(Name= username,InputType__c = 'user');
    // insert Dtrg1; 
        
      //Inserting Customsetting for Account 
    DisabledTrigger__c Dtrg = mtduc.CreateDisabledTriggerSingle();
    Switch_AccountRelationshipTrigger__c art = new Switch_AccountRelationshipTrigger__c(name = 'Set Overall Trigger Off' , Set_Overall_Trigger_Off__c = True);
    insert art;    
    
    // Inserting Test Account.
    Account newAccount = mtduc.CreateBrokerAccountSingle();
        
   //set<Id> setOLIs = new set<Id>();
  // setOLIs.add(theCase.Order__c);
       Id salesActivitiesRecordTypeId = Schema.SObjectType.Task.RecordTypeInfosByName.get('Sales Activities').RecordTypeId;
       Task theTask = null;
        List<Task> tasklist = new List<Task>();
         theTask = TestDataFactory.createTask(
                newAccount.Id,
                'Outbound cll to +19876563477',
                (Math.mod(0, 2) == 0) ? 'Call' : 'Message',
                Date.today(),
                'Completed',
                false
        );
        theTask.RecordTypeId = salesActivitiesRecordTypeId;
        //theTask.WhatId  = theCase.Id;
        theTask.Is_Tiger_Lead__c = true;
        theTask.CallType = 'Outbound';
        theTask.CallObject = '015d3936-753b-f5cc-d6a0-8c23473992a2';
        //tasklist.add(theTask);
    //insert tasklist;
    
    NVMContactWorld__InteractionEvent__c nvmcw = new NVMContactWorld__InteractionEvent__c();
    nvmcw.Name = 'Deliver to agent Sean Jares';
    nvmcw.NVMContactWorld__Type__c = 'Deliver';
    nvmcw.NVMContactWorld__Agent__c = UserInfo.getUserId();
    nvmcw.NVMContactWorld__IndexedCallObjectIdentifier__c = '015d3936-753b-f5cc-d6a0-8c23473992a2';
    //nvmcw.NVMContactWorld__IsPreCallEvent__c = false;
    nvmcw.NVMContactWorld__TimeStamp__c = system.now();
    Insert nvmcw; 
    
    NVMContactWorld__InteractionEventNote__c nvmNotes = new NVMContactWorld__InteractionEventNote__c();
    nvmNotes.Name = 'asredfksfs';
    nvmNotes.NVMContactWorld__Detail__c = 'This is my task';
    nvmNotes.NVMContactWorld__Event__c = nvmcw.id;
    insert nvmNotes;
    Test.startTest();
           
           
        insert theTask;
        try{
        //insert tasklist; 
        }catch(Exception e){}
        theTask.CallObject  = '015d3936-753b-f5cc-d6a0-8c23473992a2';
        try{
        update theTask;                
       }catch(Exception e){}
       // boolean b = SkipAssetTrigger.isSkipTrg(); //Added by radhika.
       
       TaskHelper TH = new TaskHelper();
       TaskHelper.processTasks(tasklist);
        
                 
       Test.stopTest();
   }
}