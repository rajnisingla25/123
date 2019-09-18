global class CPLoginDetails {
    public String qId;
    public String attachment;
    public List<Order> orders {get;set;}
    public List<CPDetails__c> CPlogins {get;set;}
    public CPLoginDetails(){
        orders = new List<Order>();
        CPlogins = new List<CPDetails__c>();
    }
    public string getqId(){
        return qId;
    }
    public void setqId(String value){
        qId = value;  
        getOrders(qId);
        getCPLogins(qid);
    }  
    public string getAttachment(){
        return attachment;
    }
    public void setAttachment(String value){
        attachment = value;
    }
    private void getOrders(id qId){
        orders = [SELECT id, Account.Type, show_cp_details__c, orderNumber, (Select Name,SSOEmail__c, UserName__c,AgentName__c, Password__c FROM CPDetails__r), (Select PricebookEntry.Product2.Description FROM OrderItems) from Order where Oracle_quote__c =: qId AND is_BMS__c = true];
    }
    
    private void getCPLogins(id qId){
        CPLogins = [SELECT Name, SSOEmail__c, AgentName__c, AccountType__c, UserName__c, Password__c FROM CPDetails__c Where Quote__c =: qid];
    }
}