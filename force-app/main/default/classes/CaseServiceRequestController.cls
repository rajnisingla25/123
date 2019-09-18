//History: CRM-3314: Service Request enhancements
public class CaseServiceRequestController {
    public Case caseRecord{get;set;}
    
    ID accountId{get;set;}
    public CaseServiceRequestController(ApexPages.StandardController controller) {
        caseRecord = new case();
         //account acc = [select id,Name from account where id =: ApexPages.currentPage().getParameters().get('id')];        
        //caseRecord.AccountId = acc.id;
        caseRecord.AccountId = ApexPages.currentPage().getParameters().get('id');
        caseRecord.Requesting_AE__c = Userinfo.getUserId();
        caseRecord.Date_Requested__c = system.today();
        caseRecord.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        caseRecord.Subject = 'Sales Service Request';
       
    }
    public PageReference saveAndRedirect() {
        if(caserecord.Request_Urgency__c == 'Future Request' && caserecord.Cancel_on_date__c == Null){
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'The "Cancel on Date" is required for Future Requests.'));
                return null;
        }
        else if((caserecord.Request_Type__c == 'Cancel Only' || caserecord.Request_Type__c == 'Cancel with Credit to Account' || caserecord.Request_Type__c == 'Cancel with Refund to Card' )&& caserecord.Cancel_Type__c == null){
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Cancel Type and Cancel Reason are required for Cancel Requests.'));
                return null;
        }
        else if(caserecord.Request_Urgency__c ==  'Urgent Request (bills soon)' && caserecord.Urgent_Request_Bill_Date__c  == Null){
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'The "Urgent Request Bill Date" is required for Urgent Requests.'));
                return null;
        }//CRM-3314: Added below 2 Validation rules to check for the values before creating case.
        else if((caserecord.Request_Type__c == 'Cancel with Credit to Account' || caserecord.Request_Type__c == 'Credit to Account Only') && caserecord.Credit_Amount__c == Null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'The "Credit Amount" is required for Credit Requests.'));
            return null;
        }// CRM-4248: Added condition to verify Refund Amount if Request Type is 'Refund/Rebill'.
        else if((caserecord.Request_Type__c == 'Cancel with Refund to Card' || caserecord.Request_Type__c == 'Refund to Card Only' || caserecord.Request_Type__c == 'Refund/Rebill') && caserecord.Refund_Amount__c == Null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'The "Refund Amount" is required for Refund Requests.'));
            return null;
        }
        else if((caserecord.Request_Type__c == 'Cancel with Refund to Card' || caserecord.Request_Type__c == 'Cancel Only' || caserecord.Request_Type__c == 'Cancel with Credit to Account') && caserecord.Amount_being_cancelled__c == Null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'The "$ Amount being cancelled" is required for Cancel Requests.'));
            return null;
        }
        
           insert caserecord;
        PageReference redirectPage = Page.CaseAssets;
        redirectPage.setRedirect(true);
        redirectPage.getParameters().put('id',caserecord.id);
        return redirectPage;
      } 
}