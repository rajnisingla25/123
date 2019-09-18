global class MSTR_GetSessionClass {
webservice static string getMSTRSessionId(string uname, String pwd){
        //EOR-1294 : Calling SOA Service for SessionId to access MSTR reports from salesforce. 
        microstrategyComWebservicesV10AWS.MSTRWSSoap mestrSoapReq = new microstrategyComWebservicesV10AWS.MSTRWSSoap();
        mestrSoapReq.timeout_x = 120000;
        microstrategyComWebservicesV10AWS.MWSConnectInfo connectInfo = new microstrategyComWebservicesV10AWS.MWSConnectInfo();
        
        MicroStrategy_Creds__c ms = MicroStrategy_Creds__c.getvalues('MicroStrategy');
        connectInfo.Login = uname;
        connectInfo.Password = pwd;
        connectInfo.ProjectName = ms.ProjectName__c;
        connectInfo.ProjectSource = ms.ProjectSource__c;
        connectInfo.AuthMode = ms.AuthMode__c;
        connectInfo.PortNumber = Integer.valueOf(ms.PortNumber__c);
        system.debug('@@@connectInfo'+connectInfo.Login+'@@password'+connectInfo.Password);
        connectInfo.HasHeuristics = ms.HasHeuristics__c;
        
         
        microstrategyComWebservicesV10AWS.MWSSoapHeader soapHeader = new microstrategyComWebservicesV10AWS.MWSSoapHeader();
        soapHeader.xy199Val = '1';
        soapHeader.xy299Val = '1';
        soapHeader.xy399Val = '1';
        mestrSoapReq.MWSSoapHeader = soapHeader;
        
        
        list<microstrategyComWebservicesV10AWS.MWSConnectProperty2>  connectProperty2Array = new list<microstrategyComWebservicesV10AWS.MWSConnectProperty2>();
        microstrategyComWebservicesV10AWS.MWSConnectProperty2  connectProperty2Var = new microstrategyComWebservicesV10AWS.MWSConnectProperty2();
        connectProperty2Var.ConnectPropertyFlag = ms.ConnectPropertyFlag__c;
        connectProperty2Var.ConnectPropertyValue = ms.ConnectPropertyValue__c;
        connectProperty2Array.add( connectProperty2Var );
        
        
        microstrategyComWebservicesV10AWS.ArrayOfMWSConnectProperty2 connectProperty2ClassInst = new microstrategyComWebservicesV10AWS.ArrayOfMWSConnectProperty2();
        connectProperty2ClassInst.MWSConnectProperty2 = connectProperty2Array;
        
        
        connectInfo.ArrayConnectProperty = connectProperty2ClassInst;
        try{
            microstrategyComWebservicesV10AWS.MWSProjectSessionInfo sessionResponse = mestrSoapReq.ConnectToProject( connectInfo );
            system.debug( '------------'+sessionResponse  );
            return sessionResponse.Session;
        }
        catch (Exception e){
            string error = ms.MSTR_Error__c ;
            return error;
        }
       
       
    }

}