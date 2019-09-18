public with sharing class Z_SendToZBilling  extends Z_VirtualSendToZBilling{ 
    //queueable contructor with set of ids and the context
    public Z_SendToZBilling(Set<String> ids, String stageContext){
        quoteIds = ids;
        stage = stageContext;
    }
    //default constructor
    public Z_SendToZBilling(){

    }

    
    
}