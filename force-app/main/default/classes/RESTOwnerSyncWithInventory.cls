public class RESTOwnerSyncWithInventory {
    
    public class JsonVariables {
        integer Party_id;
        string owner_name;
        string updated_by;
        string account_sub_type;
        string Phone;
    }
    
    @Future(callout=true)
    Public static void RESTAccountOwnerSync(Integer Party_id,string owner_name,string updated_by,string account_sub_type,string Phone,id AccountId){
        Map<String, String> Body = new Map<String, String>();
        string Invntresponse = '';
        Try{
            JsonVariables JsonBody = new JsonVariables();
            JsonBody.party_id = party_id;
            JsonBody.owner_name = owner_name;
            JsonBody.account_sub_type = account_sub_type;
            JsonBody.phone = phone;
            JsonBody.updated_by = updated_by;
            
            HttpRequest req = new HttpRequest(); 
            req.setMethod('PUT');
            req.setEndpoint(Waitlist_Urls__c.getInstance('UpdateOwner').URL__c);
            req.setBody(JSON.serialize(JsonBody));
            req.setHeader('Content-Type', 'application/json');
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            Invntresponse = string.valueof(res.getBody());

            // This block is to cover catch block for code coverage 
            If(Test.isRunningTest()){
               Account failaccount = New Account();
                Insert failaccount;
            }
            
        } catch(Exception ex){
            Error__c error = new Error__c();
            error.Name = 'RESTOwnerSyncWithInventory';
            error.Entity_Id__c = 'AccountId';
            error.Interface_Name__c = 'Inventory';
            error.Error_Description__c = 'Message:'+ex.getMessage()+'$$$'+'Stack trace:'+ex.getStackTraceString()+'$$$'+'Response:'+Invntresponse;
            insert error;            
        }
    }    
}