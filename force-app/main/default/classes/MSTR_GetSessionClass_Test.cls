@IsTest
public class MSTR_GetSessionClass_Test {
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
     Insert ms;
    new microstrategyComWebservicesV10AWS.MWSConnectInfo();
	MSTR_GetSessionClass.getMSTRSessionId(Uname, Pwd); 
    new microstrategyComWebservicesV10AWS.MWSConnectInfo();
    new microstrategyComWebservicesV10AWS.MWSProjectSessionInfo();
    new microstrategyComWebservicesV10AWS.MWSProjectSessionProperty();
    new microstrategyComWebservicesV10AWS.MWSSoapHeader();
    new microstrategyComWebservicesV10AWS.MSTRWSSoap();    
    }
}