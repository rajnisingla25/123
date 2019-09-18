global class ContactMethodCreationComponentCTRL {
    public boolean hidenewCM{get; set;}
    public List<ContactMethod__c> LstContactMethod {get; set;}
    //public Id cm {get;set;}
    public Id conID {get;set;}
    public Id accountId {get; set;}
    public Id accountConId {get; set;}
    public boolean isError = false;
    
    public boolean isRefresh {get;set;} {isRefresh = false;}
    public boolean isErrorFound {get; set;}
    
    public ContactMethodCreationComponentCTRL() {
        hidenewCM = false;
        LstContactMethod = new List<ContactMethod__c>();
        conID = ApexPages.currentPage().getParameters().get('id');
        if(conID != Null)
            accountConId = conID;
        else
            accountConId = accountId;
        
        isErrorFound = false;
    }
    
    public Pagereference cancelNewCM()
    {
        //errorMessage = '';
        hidenewCM = false;
        LstContactMethod.clear();        
        return null;
    }
    public Pagereference saveNewCM()
    {
        isErrorFound = false;
        set<String> existingCMs = new set<string>();
        List<Account> accList = new List<Account>();
        String accSubType = '';
        User loggedinuser;
        String profiles = Label.CustomerAccountProfileAccess;
        if(accountId != null){
            Account acc = [Select Id, Name, Type, Account_Sub_Type__c from Account where Id =: accountId limit 1];
            if(acc != null)
                accSubType = acc.Account_Sub_Type__c;
            System.debug('AccSubType:'+AccSubType);
            loggedinuser = [Select id, Profile.name from User where id = :userInfo.getUserId()];
        }
        
        for(ContactMethod__c newCMrec : LstContactMethod){         
            system.debug(' *** newCMrec **** '+newCMrec);
            if(String.isBlank(newCMrec.Type__c))
            {
                isErrorFound = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Select Type'));
                return null;
            }
            else if(newCMrec.Type__c == 'Email' && String.isBlank(newCMrec.Email__c))
            {
                isErrorFound = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter Email address'));
                return null;
            } else if(newCMrec.Type__c == 'Web' && newCMrec.Value__c == null)
            {
                isErrorFound = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter URL'));
                return null;
            } else if(newCMrec.Type__c == 'Phone' && newCMrec.Phone__c == null)
            {
                isErrorFound = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter Phone Number'));
                return null;
            }else if((newCMrec.Type__c == 'Phone' || newCMrec.Type__c == 'Web' ||
                      newCMrec.Type__c == 'Email') && newCMrec.Type_Purpose__c == null)
            {
                isErrorFound = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter Type Purpose'));
                return null;
            }else if(newCMrec.Type_Purpose__c == 'BUSINESS_FAX' && newCMrec.Primary_To_Contact__c == true){
                isErrorFound = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Business Fax cannot be Primary.'));
                return null;
            }else if(newCMrec.Type_Purpose__c == 'BUSINESS_FAX' && newCMrec.Primary_To_Account__c == true){
                isErrorFound = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Business Fax cannot be Primary.'));
                return null;
            }else if((newCMrec.Type_Purpose__c == 'BUSINESS_MOBILE' || newCMrec.Type_Purpose__c == 'PERSONAL_MOBILE') && newCMrec.Phone_Extension__c != null){
                isErrorFound = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'No Phone Extension for Mobile Category.'));
                return null;
            }else if(accountId != null && loggedinuser != null){
                System.debug('Label:'+profiles.contains(loggedinuser.Profile.name));
                if(profiles.contains(loggedinuser.Profile.name) && newCMrec.Type__c == 'Email'&& accSubType == 'Customer' && newCMrec.Primary_To_Account__c){
                    isErrorFound = true;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'You do not have access to update Account Primary Email Address for customer accounts.'));
                    return null;
                }
            }else if(newCMrec.Type__c == 'Phone'){
                Pattern p = Pattern.compile('[-() ]');
                String sPhone = p.matcher(newCMrec.Phone__c).replaceAll('');
                if(sPhone.length() != 10){
                    isErrorFound = true;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ' Phone number should have only 10 digits'));
                    return null;
                } 
                if(!sPhone.isNumeric()){
                    isErrorFound = true;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ' Phone number cannot have letters'));
                    return null;
                }
            }                        
        }
        for(ContactMethod__c existingCM :[Select Id,Source_Type__c,Active__c, Contact__c, Contact__r.Id, Type__c, Type_Purpose__c, Email__c, Phone__c, Value__c, 
                                          Primary_To_Contact__c, Primary_To_Account__c, Phone_Extension__c FROM ContactMethod__c Where Contact__c = :conID])
        {
            if(existingCM.Type__c == 'Email'){
                existingCMs.add(''+ existingCM.Type__c + existingCM.Email__c);
            } else if(existingCM.Type__c == 'Web'){
                existingCMs.add(''+ existingCM.Type__c + existingCM.Value__c);
            } else if(existingCM.Type__c == 'Phone'){
                existingCMs.add(''+ existingCM.Type__c + ContactMethodTriggerHelper.convertFromFormatted(''+existingCM.Phone__c) + existingCM.Phone_Extension__c);
            }
        }
        
        system.debug('LstContactMethod:'+LstContactMethod);
        system.debug('existingCMs:'+existingCMs);
        if(!LstContactMethod.isEmpty()){
            boolean isFoundDup = false;
            boolean isNewPrimary = false;
            for(ContactMethod__c newCMrec : LstContactMethod){
                if(newCMrec.Type__c == 'Email' && existingCMs.contains(''+ newCMrec.Type__c + newCMrec.Email__c))
                {
                    isErrorFound = true;
                    isFoundDup = true;
                    break;
                } else if(newCMrec.Type__c == 'Web' && existingCMs.contains(''+ newCMrec.Type__c + newCMrec.Value__c))
                {
                    isErrorFound = true;
                    isFoundDup = true;
                    break;
                } else if(newCMrec.Type__c == 'Phone' && existingCMs.contains(''+ newCMrec.Type__c + ContactMethodTriggerHelper.convertFromFormatted(''+newCMrec.Phone__c) + newCMrec.Phone_Extension__c))
                {
                    isErrorFound = true;
                    isFoundDup = true;
                    break;
                }
                if(newCMrec.Primary_To_Account__c){
                    isNewPrimary = true;
                }
            }
            system.debug('isFoundDup:: '+ isFoundDup);
            if(isFoundDup)
            {
                isErrorFound = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Sorry, Contact Method is already exist for this contact.'));
                return null;
            }
            hidenewCM = false;
            try{
                system.debug('try::: ');
                insert LstContactMethod;
            }
            catch(Exception ex)
            {
                system.debug('isError before:::'+isError);
                isErrorFound = true;
                isError = true;
                return null;
            }
            system.debug('isNewPrimary::'+isNewPrimary);
            isRefresh = true;
            if(accountId != null){
                // Query Relationship based on ContactId & Account Id
                Account_Relationship__c relationshipRecord = [Select id,name,Parent_Account__c,Contact_To__c,Contact_Role__c from Account_Relationship__c 
                                                              where Parent_Account__c =: accountId AND Contact_To__c =: conId][0];
                if(null != relationshipRecord && relationshipRecord.Contact_Role__c == 'Primary Contact'){
                    Account updateAcc = new Account(Id = accountId);
                    for(ContactMethod__c newCMrec : LstContactMethod){
                        System.debug('newCMrec.Type_Purpose__c:'+newCMrec.Type_Purpose__c);
                        if(newCMrec.Type__c == 'Phone'){
                            if(newCMrec.Type_Purpose__c == 'BUSINESS_MOBILE' || newCMrec.Type_Purpose__c == 'PERSONAL_MOBILE'){
                                if(updateAcc.SMS_Phone__c == null || updateAcc.PrimarySMS_CMId__c == newCMrec.Id){
                                    updateAcc.PrimarySMS_CMId__c = newCMrec.Id;
                                    updateAcc.SMS_Phone__c = newCMrec.Phone__c;
                                }
                            }
                        }
                        if(newCMrec.Primary_To_Account__c){
                            system.debug('newCMrec.Primary_To_Account__c=='+newCMrec.Primary_To_Account__c);
                            system.debug('newCMrec.Type__c=='+newCMrec.Type__c);
                            if(newCMrec.Type__c == 'Phone'){
                                updateAcc.PrimaryPhone_CMId__c = newCMrec.Id;
                                updateAcc.Phone_Extension__c = newCMrec.Phone_Extension__c;
                                updateAcc.Phone = newCMrec.Phone__c;
                                updateAcc.Preferred_Phone__c = newCMrec.Type_Purpose__c;                            
                            }
                            if(newCMrec.Type__c == 'Email'){
                                updateAcc.PrimaryEmail_CMId__c = newCMrec.Id;
                                updateAcc.Email_Address__c = newCMrec.Email__c;
                                updateAcc.Type_Purpose__c = newCMrec.Type_Purpose__c;
                            }
                        }
                    }
                    system.debug('updateAcc::'+updateAcc);
                    update updateAcc;
                }                                
            }
        }
        
        PageReference pageRef;
        /*if(accountId != Null)
{
pageRef = new PageReference('/apex/AccountContactMethodView?id=' + accountId);
}
else
pageRef = new PageReference('/apex/ContactMethodView?id=' + conID);

pageRef.setRedirect(true);
return pageRef;*/
        return null;
    }
    public Pagereference addCM()
    {
        system.debug(''+conId);
        hidenewCM = true;
        LstContactMethod.add(new ContactMethod__c(Contact__c = conId, Active__c = True,Source_Type__c = 'Web'));
        return null;
    }
    public void AddRow()
    {
        LstContactMethod.add(new ContactMethod__c(Contact__c = conId, Active__c = True,Source_Type__c = 'Web'));
    }
    
}