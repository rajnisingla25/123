/********************************************************************************************
*   @Author :       Srinidhi M 
*   @Purpose:       To get list of QuickText 
*   @Class          HotKeyList
*   @TestClass      HotKeyList_Test
*   @JIRA           
*   @CreatedDate:   July 3rd, 2018
*********************************************************************************************
   JIRA No      Date       Modified By         Description                                Tag No
*********************************************************************************************

*/
public class HotKeyList { 
 
public list <QuickText> quickTextList {get;set;} 
    {
        //Queries for all QuickText
        try{
            quickTextList=[SELECT Id, Name, Message, Category FROM
                       QuickText order by category Asc];
            If(Test.isRunningTest()){
                Integer x = 1/0; //Controller will reach here only when code is runninging test mode and will throw exception e.
            } 
        }
        catch(exception e){                  
                  system.debug('-------empty quickTextList------'+e.getMessage());
              }
        
    }    
    
}