public with sharing class getAccountsOnContacts {
    public List<Account_Relationship__c> AllAccounts{get;set;}
    public Boolean Ischecked{get;set;}
    
    Public Id led; 
    Set<Id> setAccountIds = new Set<Id>();    
    Set<Id> setContactIds = new Set<Id>();
    Map<Id,List<Id>> mapContactAccountIds = new  Map<Id,List<Id>>();
    Public ID paramValue{set;get;}
    List<Lead> Leads;  
    public getAccountsOnContacts(ApexPages.StandardController controller) {
        led = ApexPages.CurrentPage().getParameters().get('id'); 
        system.debug('led >>>>'+led);
        Leads = [select id ,name,Account__c,Contact__c from Lead where id =: led];
        for(Lead led : Leads ){
            if(led != NULL)
            {
                setAccountIds.add(led.Account__c);   
                setContactIds.add(led.Contact__c);    
            }
        }
        
        AllAccounts = [select id,Name,Parent_Account__c,Parent_Account__r.Phone from Account_Relationship__c where Contact_To__c =: setContactIds];    
    }
    public void Save(){
        system.debug('Param >>>>'+this.paramValue);
        Account_Relationship__c account = [select id,Name,Parent_Account__c,Parent_Account__r.Phone from Account_Relationship__c where Id = : this.paramValue ];
        system.debug('account >>>>'+account );
        Map<id,Lead> mapLed = new Map<id,Lead>();
        for(Lead L : Leads){
           l.Account__c = account.id;
           mapLed.put(l.id,l);
        }
         system.debug('mapLed>>>>'+mapLed.size());
        try{
            update mapLed.Values();
        }
        catch(Exception e){}
    }
    public void CreateNewAccount(){}

}