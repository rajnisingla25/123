@isTest
public class QueuesStatusReport_CC_Test
{
    private static testmethod void test1()
    {
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test@test.com',AssetTrigger__c = 'Test@test.com');
        insert Dtrg;
        
        Schema.DescribeSObjectResult cfrcSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrcSchema.getRecordTypeInfosByName(); 
        Id rtnId = CaseRecordTypeInfo.get('Retention').getRecordTypeId();
        CaseRecordTypes__c setting = new CaseRecordTypes__c(Name = 'Retention' , Record_Type_Id__c = rtnId);
                  insert setting;
        list<ID> qids = new list<ID>();
          for(QueueSobject oQueue :[SELECT ID ,QueueId , SobjectType FROM QueueSobject WHERE SobjectType =: 'Case']){
               qids.add(oQueue.QueueId);
           }
                           
        //Create Parent Case
         Case c = new Case(RecordTypeId = [Select Id from RecordType where DeveloperName='Global' and sObjectType = 'Case' limit 1].id, 
       
          Subject='UNIT TESTING',
          Description='UNIT TESTING',
          Origin='Phone',
          Priority='Medium',
          Status='New'
          );                
          c.ownerid = qids[0];
          insert c;          
          QueuesStatusReport_CC  obj_ins2 = new QueuesStatusReport_CC();
          
          c.status = 'Open';
          update c;
          QueuesStatusReport_CC  obj_ins1 = new QueuesStatusReport_CC();        

    }

}