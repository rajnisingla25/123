@isTest(seeAllData = false)
public class Updatecasecmntcountbatch_Test
{

public static testMethod void test1(){ 


    Schema.DescribeSObjectResult cfrcSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrcSchema.getRecordTypeInfosByName(); 
         Id rtnId = CaseRecordTypeInfo.get('Retention').getRecordTypeId();
      CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtnId);
                  insert setting;
      Switch_CaseTrigger__c Csetting = new Switch_CaseTrigger__c(Set_Overall_Trigger_Off__c = True);
      insert Csetting;           
         //Inserting Customsetting for Account     
      DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
              insert Dtrg;          
                
        //Create Parent Case
         Case c = new Case(RecordTypeId = [Select Id from RecordType where DeveloperName='Global' and sObjectType = 'Case' limit 1].id, 
          
          Subject='UNIT TESTING',
          Description='UNIT TESTING',
          Origin='Phone',
          Priority='Medium',
          Status='New'
          );                
        insert c;
        system.assertEquals(1, [select id from case where id=:c.id and isdeleted=false].size());
        
        // Create Child Case
         Case childCase = new Case(RecordTypeId = [Select Id from RecordType where DeveloperName='Standard' and sObjectType = 'Case' limit 1].id, 
         
          Subject='UNIT TESTING',
          Description='UNIT TESTING',
          Origin='Phone',
          ParentId = c.Id,
          Priority='Medium',
          Status='New'
          );               
        insert childCase ;
        
        CaseComment childCaseComment = new CaseComment (ParentID = childCase.id, CommentBody = 'UNIT TESTING', isPublished=false);
        insert childCaseComment ;
        CaseComment parentCaseComment = new CaseComment (ParentID = c.id, CommentBody = 'UNIT TESTING', isPublished=false);
        insert parentCaseComment ;
        test.startTest();
        Updatecasecmntcountbatch bt = new Updatecasecmntcountbatch();
        Database.executeBatch(bt);
        test.stopTest();

        
}
}