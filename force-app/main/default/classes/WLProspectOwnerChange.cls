global class WLProspectOwnerChange {
    @invocablemethod(label='Prospect Account Onwer Change' description='Prospect Account Onwer Change')
    public static void ProspectOwnerChange(list<dsfs__DocuSign_Status__c> DocStatus){
        string waitlistid = DocStatus[0].Waitlist__c;
        waitlist__C WLData = [select Account__c,Account__r.owner.profile.name,Account__r.Account_Sub_Type__c,CreatedByid from waitlist__c where id = :waitlistid];
        If(WLData.Account__r.Account_Sub_Type__c == 'Prospect' || WLData.Account__r.Account_Sub_Type__c == 'Former Customer'){
            Account AcctUpdate = new Account(id 		= 	WLData.Account__c,
                                             ownerid 	= 	WLData.CreatedByid);
            update AcctUpdate;
        }
    }
}