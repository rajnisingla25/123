// (c) 2015 Appirio, Inc.
//
// Class Name: CaseCommentsControllerTest
// Description: TestClass  for CaseCommentsComponentController & CaseCommentExtension
//
// 27th March 2015    Ravindra Shekhawat   Original (Task # T-T-373931)
//

@isTest
public class CaseCommentsControllerTest {
 static testMethod void myTestCaseComments() {
        
               
        //Navigate to Case page
        //PageReference pageRef = Page.Case;     //**** Enter your Case overridden view page name here  
        
        //Inserting Custom setting for Case trigger before insert event Exception
        
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
          Case_Comment_Count__c = 0,
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
          Case_Comment_Count__c = 0,
          Priority='Medium',
          Status='New'
          );               
        insert childCase ;
        
        CaseComment childCaseComment = new CaseComment (ParentID = childCase.id, CommentBody = 'UNIT TESTING', isPublished=false);
        insert childCaseComment ;
        CaseComment parentCaseComment = new CaseComment (ParentID = c.id, CommentBody = 'UNIT TESTING', isPublished=false);
        insert parentCaseComment ;
        system.assertNotEquals(null, childCaseComment.id);
        
        ApexPages.currentPage().getParameters().put('id',childCase.Id);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(childCase);
        // Case Comment Extension
        CaseCommentExtension extension = new CaseCommentExtension(stdController);
        
        //create controller first
        CaseCommentsComponentController controller = new CaseCommentsComponentController();
        controller.comments = null;
        //Test.setCurrentPage(pageRef);
        controller.parentCaseId = c.id;
        controller.currentCaseId = childCase.Id;
        System.assertEquals(controller.comments.size(),1);
        
        //Create a casecomment for further testing
     
        ApexPages.currentPage().getParameters().put('CommentId_d',parentCaseComment .id) ;       
        controller.deleteComment();
        
        List<CaseComment> lstCaseComment = new List<CaseComment>();
        lstCaseComment.add(parentCaseComment);
        CaseCommentTriggerHandlerManager cctm = new CaseCommentTriggerHandlerManager();
        cctm.decrementTotalCaseCommentCount(lstCaseComment);
        
        System.assertEquals(controller.comments.size(),0);
        
    }
        
}