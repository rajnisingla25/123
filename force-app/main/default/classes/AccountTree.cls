public with sharing class AccountTree {

public string result{get;set;}

private final Account acct;
            public AccountTree(ApexPages.StandardController stdController) {
 //Fetching user Id from UserInfo Object           
                    result = UserInfo.getUserId();
                   
                        this.acct = (Account)stdController.getRecord();
            
            
            }
            
 public List<SelectOption> getFilterList() {

        List<SelectOption> options = new List<SelectOption>();      
    
        options.add(new SelectOption('Agent View','Office/Agent View'));
        options.add(new SelectOption('Products','Products'));
        options.add(new SelectOption('Asset','Agents Asset View'));
        options.add(new SelectOption('BrokerAsset','Broker Assets/Participants View'));
        options.add(new SelectOption('MLS','MLS View'));
        options.add(new SelectOption('Account Listings','Account Listings View'));
        options.add(new SelectOption('Case','Cases'));
        options.add(new SelectOption('Lead','Leads'));
        
       //options.add(new SelectOption('Payments','Payments'));
       //options.add(new SelectOption('Subscriptions','Subscriptions')); 
       //options.add(new SelectOption('Orders','Orders'));
       //options.add(new SelectOption('Opportunity','Opportunity'));
       //options.add(new SelectOption('Quotes','Quotes'));                 

 
        return options;

    }
    


}