/* DO NOT migrate this class to prod.

Only for closing open cases in QA.

*/

public class CloseCaseBatch implements Database.Batchable<sObject>
{
    //String query = 'Select Id, Status, OwnerId From Case Where Status != \'Closed\' AND Type = \'Outbound\' ';
    //query += ' AND Area__c =\'Product Set Up\' ';
    //CloseCaseBatch newCloseCaseBatch = new CloseCaseBatch(query, Date.newInstance(2018, 11, 15));
    //Database.executeBatch(newCloseCaseBatch, 10);
    String query;
    Date myDate;
    
    public CloseCaseBatch(String strQuery, Date selectedDate)
    {
        myDate = selectedDate;
        query = strQuery;
        query += 'AND CreatedDate <:myDate ';
    }
    
    public Database.querylocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Case> lstCase)
    {
        List<Group> lstGroup = [Select Id From Group Where Type = 'Queue' AND Name = 'Closed Cases'];
        for(Case objCase :lstCase)
        {
            objCase.Status = 'Closed';
            objCase.OwnerId = lstGroup[0].Id;
        }
        
        update lstCase;
    }
    
    public void finish(Database.BatchableContext BC)
    {
    }
}