/*
* Description: Controller that contains WebService method invoked by the new Case Custom Button 'Accept'
* Fecha: 01/30/2013   
* Autor: Sonia de la Rubia Mu�oz
* Modified By Ravindra Shekhawat, Added Logic For Updating Case Status to Open After Case is accepted By A User Issue # I-155809
* Removed Test Code From Controller Class, Created Separate Class SmartCase_AcceptControllerTest
*/ 
global  class SmarterCase_AcceptController {
  
  WebService static String Accept(String[] ids) {
    // Check parameter
    if ((ids == null) || ids.isEmpty()){
      return ('Please select one or more items.');
    }

    // Get cases from ids
    List<Case> lCases = [Select Id,Status,
                CaseNumber,
                OwnerId,
                RecordTypeId
              From Case
              Where Id in :ids];
    if (lCases.isEmpty()){
      return ('Please select one or more items.');
    }
          
  
    // Variables
    String strResult = 'The following numbers of cases have already been assigned:\n\r';
    Boolean casesAlreadyAssigned = false;
    List<Case> lCasesToUpdate = new List<Case>();
    Id userId = UserInfo.getUserId();
    
    // Go through each Case passed
    for (Case item : lCases){     
      // If owner is a user, do nothing, else assign new owner
      if (String.valueOf(item.OwnerId).startsWith('005')){
        strResult += '-' + item.CaseNumber + '\n';
        casesAlreadyAssigned = true;
        lCasesToUpdate.clear();
        break;
      }else{
        item.OwnerId = userId;
          // Added Code to Change Case Status to Open After It is Accepted By A User
          // item.Status='Open';  Commented as per LEAP-5511
          // Added below code as per LEAP-5511
          if(item.Status != 'New'){
              item.Status='Open';
          }
        lCasesToUpdate.add(item);  
      }
    }
    
    // Update cases
    if (!lCasesToUpdate.isEmpty()){
      update lCasesToUpdate;
    }
    
    
    // Return
    return(casesAlreadyAssigned ? strResult : '');
  }
}