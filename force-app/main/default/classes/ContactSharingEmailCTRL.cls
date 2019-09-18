public class ContactSharingEmailCTRL {
    
    public ApexPages.StandardController controller;
    
    public string conId {get;set;}
    public Contact con {get;set;}
    //public list<Contact> conList {get;set;}
    public list<Contact> conEmailList {get;set;}
    public list<ContactMethod__c> conMetList {get;set;}
    public list<ContactMethod__c> conMetEmailList {get;set;}
    private set<String> conMetEmailSet = new Set<String>();
    private set<Id> conMetIdSet = new Set<Id>();
    
    public ContactSharingEmailCTRL(ApexPages.StandardController Controller) {
        //conList = new List<Contact>();
        conEmailList = new List<Contact>();
        conMetList = new List<ContactMethod__c>();
        conMetEmailList = new List<ContactMethod__c>();
        
        conId = ApexPages.currentPage().getParameters().get('id');
        for(Contact cont : [SELECT Id, Name, Email, Phone
                           from Contact where Id =: conId order by Name asc limit 1]){
                               con = cont;
                           }
        
        conMetList = [Select Id, Email__c, Type_Purpose__c, Type__c, Primary_To_Contact__c from ContactMethod__c 
                      where Type__c = 'Email' and Contact__c =: conId and Active__c = True order by Type_Purpose__c asc];                   
        for(ContactMethod__c cm: conMetList){
            conMetEmailSet.add(cm.Email__c);
            conMetIdSet.add(cm.Id);
        }
        System.debug('conMetEmailSet:'+conMetEmailSet);
        //String conEmail = conList[0].Email;
        /*conEmailList = [SELECT Id, Name, Email, Phone
                            from Contact where Email =: conEmail and Id !=: conId order by Name asc];*/
        
        conMetEmailList = [Select Id, Email__c, Type_Purpose__c, Type__c, Primary_To_Contact__c, Contact__r.Name, Contact__r.Id, Contact__r.Email, Contact__r.Phone from ContactMethod__c 
                      where Type__c = 'Email' and Email__c IN: conMetEmailSet and Id Not IN: conMetIdSet and Active__c = True order by Type_Purpose__c asc];
        System.debug('conMetEmailList:'+conMetEmailList);
    }
    
     public pageReference back() {
        return new PageReference('/'+conId);
    }

}