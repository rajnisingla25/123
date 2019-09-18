public class AccountdetailedViewController {
    
    public static PageReference reDirect(){
        Account acctdata;
        String PartyID = ApexPages.currentPage().getParameters().get('Partyid');
        try{
            acctdata = [SELECT ID FROM Account WHERE Party_ID__C =: PartyID LIMIT 1];
        }catch(exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Party ID "'+PartyID +'" doesn\'t have account'));
            return null;
        }
        String urlVal = URL.getSalesforceBaseUrl().toExternalForm();
        PageReference pageRef = new PageReference(urlVal+'/'+acctdata.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }    
    
}