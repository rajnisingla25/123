//
// (c) 2012 Appirio, Inc.
// Class Name : UpdateCaseOwnerForDetailPageController
// Used this class for UpdateCaseOwnerForDetailPage page
//
// 15 April 2015     Kirti Agarwal    Original (Task-T-377382)
// 20th May 2015     Ravindra Shekhawat Modified (I-158116)
//
public class UpdateCaseOwnerForDetailPageController {
  public Case selectedCase {get;set;}
  public String selectedQueue {get;set;}

  //constructor
  public UpdateCaseOwnerForDetailPageController(ApexPages.StandardController controller) {
    selectedCase = (Case) controller.getRecord();
  }

  //  @method name: getAllQueue
  //  @purpose    : Used get all case queues
  //  @created by :  Kirti Agarwal
  //  @created date : 15 April 2015
  //  @return     : List <SelectOption>
  public List < SelectOption > getAllQueue() {
    List < SelectOption > allQueue = new List < SelectOption > ();
    List < QueueSobject > queueSobjectList = new List<QueueSobject>();
    Id profileId=UserInfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        if(profileName.equalsIgnoreCase('Move IT SysAdmin')) {
            queueSobjectList = [SELECT SobjectType, QueueId, Queue.Name, Queue.Id
                          FROM QueueSobject
                          WHERE SobjectType = 'Case'];
        }else {
            queueSobjectList = MoveUtility.getQueueForUser(UserInfo.getUserId());
        }
    for (QueueSobject queue: queueSobjectList) {
      allQueue.add(new SelectOption(queue.QueueId, queue.Queue.Name));
    }
    return allQueue;
  }

  //  @method name: saveRecords
  //  @purpose    : Used to update selected case record's Owner with seleted Queue
  //  @created by :  Kirti Agarwal
  //  @created date : 15 April 2015
  //  @return     : Pagereference
  public Pagereference saveRecords() {
    List < Case > updateCaseList = new List < Case > ();
    Pagereference page = null;
    for (Case cas: [SELECT id
                         , OwnerId
                    FROM Case
                    WHERE ID = : selectedCase.Id]) {
      cas.OwnerId = selectedQueue;
      updateCaseList.add(cas);
    }

    if (!updateCaseList.isEmpty()) {
      try {
        update updateCaseList;
        page = new Pagereference('/' + selectedCase.Id);
            page.setRedirect(true);
      } catch (exception e) {
        if (!(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') || e.getMessage().contains('FIELD_FILTER_VALIDATION_EXCEPTION'))) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
        } 
      }
    }
    
    return page;
  }

}