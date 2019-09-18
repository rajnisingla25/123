public class ContactMethodViewCTRL {
    public List<ContactMethod__c> LstEmailContactMethod {get; set;}
    public List<ContactMethod__c> LstPhoneContactMethod {get; set;}
    public List<ContactMethod__c> LstWebContactMethod {get; set;}

    Map<Id, ContactMethod__c> MapLstCMethod = new Map<Id, ContactMethod__c>();
    public ApexPages.StandardController stdCntrlr {get; set;}
    public string conID {get;set;}
    
    public Boolean viewTable;
    public String buttonName;  

    public Boolean getViewTable(){return this.viewTable;}
    public String getButtonName(){return this.buttonName;}
    public string errorMessage {get;set;}
    public Id cm {get;set;}
    private boolean refreshlist = false;
    public boolean isErrorFound {get; set;}
    
    public System.PageReference setRefresh(boolean value){
            system.debug('value:::'+value);
        if(value == true){
            System.PageReference reload = new PageReference(ApexPages.currentPage().getUrl());
            //reload.getUrl()
            reload.setRedirect(false);
            return reload;
        }
        return null;
    }
    
    public ContactMethodViewCTRL(ApexPages.StandardController controller) {
        LstEmailContactMethod = new List<ContactMethod__c>();
        LstPhoneContactMethod = new List<ContactMethod__c>();
        LstWebContactMethod = new List<ContactMethod__c>();
        //LstContactMethod = new List<ContactMethod__c>();
        stdCntrlr = controller;
        conId = ApexPages.currentPage().getParameters().get('id');
        viewTable = false;
        buttonName = 'Show Opt-Ins';
        
        for(ContactMethod__c con: [Select Id, Type__c, Type_Purpose__c, Email__c, Phone__c, Value__c, Primary_To_Contact__c, Active__c, Phone_Extension__c,
                                        SMS_RDC_Promo_Pref__c, Source_Type__c,
                                        RDC_Event_OptIn__c, RDC_Info_OptIn__c, RDC_Promo_OptIn__c, TP_Event_OptIn__c, TP_Info_OptIn__c, TP_Promo_OptIn__c
                                From ContactMethod__c 
                                Where Contact__c =:conId 
                                ORDER BY Primary_To_Contact__c DESC, Active__c DESC, Type_Purpose__c]){
                            
            if(con.Type__c == 'Email'){
                LstEmailContactMethod.add(con);
            }
            else if(con.Type__c == 'Phone'){
                LstPhoneContactMethod.add(con);
            }
            else if(con.Type__c == 'Social'){
                LstWebContactMethod.add(con);
            }
            MapLstCMethod.put(con.Id, con.clone(false, true));
            system.debug('MapLstCMethod:'+MapLstCMethod);
           
        }        
    }
    
    public void showHideTable(){
        if(!viewTable){
           viewTable = true;
           buttonName = 'Hide Opt-Ins';
        }else{
           viewTable = false;
           buttonName = 'Show Opt-Ins';
        }
    
    }
    
    public Pagereference saveRecords()
    {
        //isErrorFound = false;
        List<ContactMethod__c> lstContactMethod = new List<ContactMethod__c>();
        Map<Id,ContactMethod__c> oldMapContactMethods = new Map<Id,ContactMethod__c>();
        errorMessage = '';
        this.isErrorFound = false;
        system.debug('MapLstCMethod:'+MapLstCMethod);
        
        for(ContactMethod__c newcm :LstEmailContactMethod) {
            System.debug('newcm:'+newcm);
            ContactMethod__c oldCM = MapLstCMethod.get(newcm.Id);
            System.debug('oldcm:'+oldcm);
            if(newcm.Type_Purpose__c != oldcm.Type_Purpose__c || newcm.Email__c != oldcm.Email__c ||
               newcm.Primary_To_Contact__c != oldcm.Primary_To_Contact__c || newcm.Active__c != oldcm.Active__c) {
               lstContactMethod.add(newcm); 
            }           
            
        } 
        for(ContactMethod__c newcm :LstPhoneContactMethod) {
            
            System.debug('newcm Phone:'+newcm);         
            ContactMethod__c oldcm = MapLstCMethod.get(newcm.Id);
            System.debug('oldcm Phone :'+oldcm);
            if(newcm.Type_Purpose__c == 'BUSINESS_FAX' && newcm.Primary_To_Contact__c == true){
                isErrorFound = true;
                System.debug('isErrorFound:'+isErrorFound); 
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Business Fax cannot be Primary.'));
                return null;
            }
            else if((newcm.Type_Purpose__c == 'BUSINESS_MOBILE' || newcm.Type_Purpose__c == 'PERSONAL_MOBILE') && newcm.Phone_Extension__c != null){
                isErrorFound = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'No Phone Extension for Mobile.'));
                return null;
            }
            if(newcm.Type_Purpose__c != oldcm.Type_Purpose__c || newcm.Phone__c != oldcm.Phone__c || 
               newcm.Phone_Extension__c != oldcm.Phone_Extension__c ||
               newcm.Primary_To_Contact__c != oldcm.Primary_To_Contact__c || newcm.Active__c != oldcm.Active__c) {
               lstContactMethod.add(newcm); 
            }
        }
        for(ContactMethod__c newcm :LstWebContactMethod) {
            System.debug('newcm:'+newcm);               
            ContactMethod__c oldcm = MapLstCMethod.get(newcm.Id);
            if(newcm.Type_Purpose__c != oldcm.Type_Purpose__c || newcm.Value__c != oldcm.Value__c ||
               newcm.Primary_To_Contact__c != oldcm.Primary_To_Contact__c || newcm.Active__c != oldcm.Active__c) {
               lstContactMethod.add(newcm); 
            }
        }
        try
        {
            update lstContactMethod;        
        }
        catch(Exception ex) 
        {
            isErrorFound = true;
            system.debug('Exception==>');
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Contact Method which is Primary to Contact cannot be Inactive.'));
        }
        system.debug('isErrorFound:'+isErrorFound);
        return null;
    }
    
    public Pagereference cancelAll()
    {
        errorMessage = '';
        /*for(ContactAccountwrapper caWrapper : CMAccWrapperList){
            for(AccountPreferencewrapper apWrapper : caWrapper.AcctWrap){
                list<PreferenceWrapper> prefWrapList = new list<PreferenceWrapper>();
                for(PreferenceWrapper prefWrap : apWrapper.refWrap){
                    if(prefWrap != null && prefWrap.cm != null && prefWrap.cm.Id != null){
                        prefWrapList.add(prefWrap);
                    } 
                }
                apWrapper.refWrap = prefWrapList;
            }
        }*/
        return null;
    } 
}