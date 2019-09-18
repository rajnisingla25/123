/********************************************************************************************
*   @Author :       Vamsi Ch(Brillio Technologies) 
*   @Purpose:       Class for invoking Case Assignment rules for re-opened case
*   @Class          CaseProcessBuilderHandler
*   @TestClass      CaseProcessBuilderHandler_Test
*   @JIRA           
*   @CreatedDate:   June 7, 2018
*********************************************************************************************
   JIRA No      Date       Modified By         Description                                Tag No
*********************************************************************************************

*/
public class CaseProcessBuilderHandler{

    /****************************************************************
    Method: invokeCaseAssignmentRules
    Description : to invoke caseAssignmentRules for the list of cases
    Parameters : List<case>
    Returntype : None
    ******************************************************************/
    @InvocableMethod(label='Invoke Case Assignment Rules' description='Invokes the case assignment rules for the re-opened case')
    public static void invokeCaseAssignmentRules(list<case> newCaseList){
        try{
            system.debug('@@ in invokeCaseAssignmentRules');       
            if(!newCaseList.isEmpty()){                
             system.debug('@@ inside if in invokeCaseAssignmentRules');                 
                Database.DMLOptions dmo = new Database.DMLOptions();
                //Assign the default (active) assignment rule for the case
                dmo.assignmentRuleHeader.useDefaultRule = true;
                Database.update(newCaseList, dmo);                         
            }
        }
        catch(exception e){
            system.debug('@@ in exception e'+e.getMessage());
        }
    }
    
}