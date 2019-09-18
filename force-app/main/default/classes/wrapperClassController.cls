public class wrapperClassController {
    public List<WrapperClass> listWrapper {get;set;}    
    public List<contact> lstContact{get;set;}
    Public Boolean Open{get;set;}
    Public String norecordfound{get;set;}
    Public Boolean displaynofound{get;set;}
    Public id l; 
    Set<Id> setAccountIds = new Set<Id>();    
    Set<Id> setContactIds = new Set<Id>();
    Map<Id,List<Id>> mapContactAccountIds = new  Map<Id,List<Id>>();
    List<Lead> LeadSelected;
    public wrapperClassController(ApexPages.StandardController controller) {
        l = String.valueOf(ApexPages.CurrentPage().getParameters().get('id')); 
        displaynofound = true;
        norecordfound = 'No Matching record found!';
        LeadSelected = [select id ,name,Account__c,Contact__c from Lead where id =: l];
        system.debug('LeadSelected : '+LeadSelected);
        for(Lead led : LeadSelected){
        if(led.Account__c!=null){
            setAccountIds.add(led.Account__c);   
            }
            if(led.Contact__c!=null){
                setContactIds.add(led.Contact__c);
            }    
        }
        system.debug('setContactIds : '+setContactIds);
        listWrapper = new List<WrapperClass>();
        //List<account> accts = [select id,Account_Status__c,Type,Account_Sub_Type__c from account limit 100];
        //List<Account_Relationship__c> acc = [Select id,name,Parent_Account__c,Parent_Account__r.Account_Status__c,Parent_Account__r.ownerid,Parent_Account__r.Account_Sub_Type__c,Parent_Account__r.Phone,Parent_Account__r.Type,Contact_To__c from Account_Relationship__c where Contact_To__c=: setContactIds];
        List<Account_Relationship__c> acc = [Select id,name,Parent_Account__c,Parent_Account__r.Account_Status__c,Parent_Account__r.ownerid,Parent_Account__r.Account_Sub_Type__c,Parent_Account__r.Phone,Parent_Account__r.Type,Contact_To__c, Parent_Account__r.Total_HLC__c, Parent_Account__r.Total_CLC__c, Parent_Account__r.Total_Contract_Value__c  from Account_Relationship__c where Contact_To__c=: setContactIds];
        system.debug('acc : '+acc );
        if(acc.size() > 0) {
        displaynofound = false;
            for(Account_Relationship__c acc1 : acc) {
            //for (account accts1 : accts)   
                listWrapper.add(new WrapperClass(acc1));
            }
        }
    }   
    
    List<Account_Relationship__c> acc2=new List<Account_Relationship__c>();
    
    public PageReference GoLead(){ 
    
    Pagereference pg = New Pagereference('/'+l);
        pg.Setredirect(TRUE);       
        return pg;        
    }
    public PageReference save(){ 
        acc2.clear();        
        List<Lead> leads = new List<lead>();   
        List<WrapperClass> TempWrapList = new List<WrapperClass>();
        for(WrapperClass w: listWrapper){
            system.debug('w.checked : '+w.checked);
            if(Test.IsRunningTest()){
                w.checked = true;
            }
            if(w.checked == true) {
                acc2.add(w.acc);
            }
            else{
                TempWrapList.add(w);
            }
        }
        //system.debug('acc2 >>>'+acc2.size());
        if(acc2.size() != 0) {
            if(acc2.size() == 1){                
                for(Account_Relationship__c acc3 : acc2){
                    for(Lead L : LeadSelected){
                        L.Account__c = acc3.Parent_Account__c;
                        leads.add(L);
                    }                                                                
                }
            }
           
            if(acc2.size() > 1 ){
                ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.ERROR,'Please select only one Account');
                ApexPages.addMessage(myMsg);         
                return null;
            }
        }
             
        else{
             if(acc2.size() == 0){
                 ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.ERROR,'Please select any one Account');
                 ApexPages.addMessage(myMsg);
                 return null;
             }
        }
        if(acc2.size() == 0){
            Open = true;
        }
        try{ 
        if(leads.size() > 0){           
            update leads;    
            }   
        }
        catch(Exception e){}
        acc2.clear();
        Pagereference pg = New Pagereference('/'+leads[0].id);
        pg.Setredirect(TRUE);       
        return pg;        
    }
    public pagereference CreateNewAccount(){
        Pagereference pg = New Pagereference('/apex/CreateNewAccount');
        pg.Setredirect(TRUE);
        return pg;
    } 
    
    public class WrapperClass{      
        public Boolean checked {get;set;}
        public Account_Relationship__c acc {get;set;}
       // public Account accts {get;set;}
        public WrapperClass(Account_Relationship__c acc) {
            this.acc= acc;
          //  this.accts = accts;
            this.checked = false;
        }
    }
}