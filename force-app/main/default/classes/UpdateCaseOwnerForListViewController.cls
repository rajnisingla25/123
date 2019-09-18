//
// (c) 2012 Appirio, Inc.
// Class Name : UpdateCaseOwnerForListViewController
// Used this class for UpdateCaseOwnerForListView page
//
// 15 April 2015     Kirti Agarwal    Original (Task-T-377382)
// 20th May 2015     Ravindra Shekhawat Modified (I-158116)
//
public class UpdateCaseOwnerForListViewController {

  public String selectedQueue {get;set;}
  public List<Case> selectedCases {get;set;}
  public Map<String, String> displayErrorMap {get;set;}
  public String error {get;set;}
  //constructor
  public UpdateCaseOwnerForListViewController (ApexPages.StandardSetController controller) {
    selectedCases = controller.getSelected();
  }

  //  @method name: getAllQueue
  //  @purpose    : Used get all case queues
  //  @created by :  Kirti Agarwal
  //  @created date : 15 April 2015
  //  @return     : List <SelectOption> 
  public List <SelectOption> getAllQueue() {
    List <SelectOption> allQueue = new List <SelectOption> ();
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
    for (QueueSobject queue: MoveUtility.getQueueForUser(UserInfo.getUserId())) {
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
    List <Case> updateCaseList = new List <Case> ();
    displayErrorMap = new Map<String, String>();
    for (Case cas: [SELECT id, OwnerId, CaseNumber
                    FROM Case
                    WHERE ID IN: selectedCases]) {
      cas.OwnerId = selectedQueue;
      updateCaseList.add(cas);
    }

    if (!updateCaseList.isEmpty()) {
          Savepoint sp;
        Boolean isError = false;
        sp = Database.setSavepoint();
        Database.SaveResult[] srList = Database.update(updateCaseList, false);
                // Iterate through each returned result
                for(integer i = 0; i<updateCaseList.size(); i++) {
                   if (!srList[i].isSuccess()) {
                     for(Database.Error err : srList[i].getErrors()) {
                      isError = true;
                      if(!displayErrorMap.containsKey(err.getMessage())) {
                        displayErrorMap.put(err.getMessage(), err.getMessage().substring(0,(err.getMessage().length())-1)
                           + ' with following Cases: ' + updateCaseList[i].CaseNumber);
                      }else {
                        String msg = displayErrorMap.get(err.getMessage());
                        msg +=  ', ' + updateCaseList[i].CaseNumber;
                        displayErrorMap.put(err.getMessage(), msg);
                      }
             }
                   }
       }
       //Creating error list
       if(isError) {
         Database.rollback(sp);
         error = '';
         Integer i = 0;
         for(String err : displayErrorMap.values()) {
            if(i == 0) {
              error += '<ul><li>' + err + '</li>';
            }else if(i == displayErrorMap.values().size()-1) {
                error += '<li>' + err + '</li></ul>';
            }else {
                error += '<li>' + err + '</li>';
            }
            i++;
         }
         return null;
      }
    }

    //redirect page to the my open case list view
    Pagereference page = new Pagereference('/500?fcf=' + Label.My_Case_List_View_Id);
    page.setRedirect(true);
    return page;
  }

}