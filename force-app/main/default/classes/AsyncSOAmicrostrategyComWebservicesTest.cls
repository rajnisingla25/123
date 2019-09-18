@IsTest
public class AsyncSOAmicrostrategyComWebservicesTest {
    private static testMethod void coverTypes()
    {
        string Uname = 'test';
        String Pwd = '123';
        MicroStrategy_Creds__c ms = new MicroStrategy_Creds__c ();
         ms.Name ='MicroStrategy ';
         ms.ProjectName__c = 'MicroStrategy';
         ms.ProjectSource__c = 'daz02mst20270';
         ms.AuthMode__c = 'MWSStandard';
         ms.PortNumber__c = '0';
         ms.HasHeuristics__c = TRUE;
         Insert ms;
     
        AsyncMicrostrategyComWebservicesV10AWS mstr = new AsyncMicrostrategyComWebservicesV10AWS();
        new AsyncMicrostrategyComWebservicesV10AWS.ConnectToProjectResponse_elementFuture();
        try{
        new AsyncMicrostrategyComWebservicesV10AWS.ConnectToProjectResponse_elementFuture().getValue();
        }
        catch(exception e){
            
        }
         try{
        new AsyncMicrostrategyComWebservicesV10AWS.AsyncMSTRWSSoap().beginConnectToProject(Null,Null); 
        }
        catch(exception e){
            
        }
    }
    }