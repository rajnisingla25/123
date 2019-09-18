global class CPloginparserandattachmentBatch implements Database.Batchable<sObject>{
    Public string AccountType;
    Public string CustID;
    Public string MlsID;
    Public string MlsName;
    Public string Name;
    Public string Password;
    public string SSOEmail;

    set<id> OrderItemids                    = new set<id>();
    list<OrderItem> OrdrItems               = new list<OrderItem>();
    list<CPDetailsWrapper> CPLoginDetails   = new list<CPDetailsWrapper>();
    list<asset> assetdata                   = new list<asset>();
    map<string,string> ordrordritmids       = new map<string,string>();
    list<order> updateorders                = new list<order>();
    set<order> ordersnodups                  = new set<order>();
    list<CPDetails__c> cpdetailsinsert     = new list<CPDetails__c>();
    set<CPDetails__c> cpdetailsnodups     = new set<CPDetails__c>();
    list<CPDetails__c> cpdetailsdelete     = new list<CPDetails__c>();
    set<id> orederids            = new set<id>();
    set<Id> uniqueOrderIds = new set<Id>();
    List<BigMachines__Quote__c> quotestoUpdate = new List<BigMachines__Quote__c>();
    Map<id, BigMachines__Quote__c > uniqueQuoteIds = new Map<Id, BigMachines__Quote__c >();
    Map<id,id> orderToQuoteMap = new Map<id,id>();
    /*list<Attachment> insertathmnt           = new list<Attachment>();
    map<string,string> cpdetaildata      = new map<string,string>();

    public static final String FORM_HTML_START = '<HTML><BODY>';
    public static final String FORM_HTML_END = '</BODY></HTML>';

    public static final String space1 = '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
    public static final String space2 = '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
    public static final String space3 = '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';*/


    //Wrapper class to hold parsed CPlogin Details
    public class CPDetailsWrapper{
        Public id orderid;
        Public id quoteid;
        Public string AccountType;
        Public string CustID;
        Public string MlsID;
        Public string MlsName;
        Public string Name;
        Public string Password;
        public string SSOEmail;
        public boolean isBMS;
        public CPDetailsWrapper(id oorderid, id oquoteid, String oAccountType,String oCustID,String oMlsID,String oMlsName,String oName,String oPassword,string oSSOEmail,boolean oisBMS){
            orderid         = oorderid;
            quoteid         = oquoteid;
            AccountType     = oAccountType;
            CustID          = oCustID;
            MlsID           = oMlsID;
            MlsName         = oMlsName;
            Name            = oName;
            Password        = oPassword;
            SSOEmail        = oSSOEmail;
            isBMS           = oisBMS;
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
       //String query = 'select id, is_BMS__c, Non_Renewal_count__c, Oracle_Quote__c, Oracle_Quote__r.cansendemail__c, type, show_cp_details__c, (select id,OrderId, order.oracle_quote__c from OrderItems) from Order where Status = \'Complete\' and (Type = \'New\' OR Type = \'Renewal\' OR Type = \'Auto-Renew\' OR (type = \'Modify\' AND Non_Renewal_count__c = 0)) and cansendemail__c = false and tigerLeadProductExists__c = false and LastModifiedDate = today;
         String query = 'select id, is_BMS__c, Non_Renewal_count__c, Oracle_Quote__c, Oracle_Quote__r.cansendemail__c, type, show_cp_details__c, (select id,OrderId, order.oracle_quote__c from OrderItems) from Order where Status = \'Complete\' and (Type = \'New\' OR Type = \'Renewal\' OR Type = \'Auto-Renew\' OR (type = \'Modify\' AND Non_Renewal_count__c = 0)) and cansendemail__c = false and tigerLeadProductExists__c = false and EndDate >= today and  LastModifiedDate = today'; //CRM-3118 Added EndDate > Today filter to restrict order confirmation mails on expired Orders
         // String query = 'select id,(select id,OrderId from OrderItems) from Order where Status = \'Complete\' and Type = \'New\' and cansendemail__c = false and id = \'801m00000011eDI\'';  //Broker CC  801m0000001VaoH
       // String query = 'select id,(select id,OrderId from OrderItems) from Order where Status = \'Complete\' and Type = \'New\' and cansendemail__c = false and id = \'801m00000011eu7\'';   //Agent
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Order > orderdata){
        for(order orderloop : orderdata){
        if(orderloop.OrderItems.size()>0){
            OrdrItems.addall(orderloop.OrderItems);
            if(orderloop.show_cp_details__c == 0 &&
                (orderloop.type == 'New' ||
                   (orderloop.type == 'Modify' && orderloop.Non_Renewal_count__c == 0))){
                    orderloop.cansendemail__c = true;
                    if(!uniqueOrderIds.contains(orderLoop.id)){
                        updateorders.add(orderloop);
                        uniqueOrderIds.add(orderLoop.id);
                    }

                    //as part of LEAP -8345
                    if(orderLoop.is_BMS__c){
                        if(!uniqueQuoteIds.keySet().contains(orderloop.Oracle_Quote__c)){
                            BigMachines__Quote__c quoteToupdate = new BigMachines__Quote__c();
                            quoteToupdate.cansendemail__c = true;
                            quoteToupdate.id = orderloop.Oracle_Quote__c;
                            uniqueQuoteIds.put(quoteToupdate.id,quoteToupdate);
                        }
                        else{
                            BigMachines__Quote__c quoteToupdate = uniqueQuoteIds.get(orderloop.Oracle_Quote__c);
                            quoteToupdate.cansendemail__c = true;
                            quoteToupdate.id = orderloop.Oracle_Quote__c;
                            uniqueQuoteIds.put(quoteToupdate.id,quoteToupdate);
                        }


                    }
                    //**** Added by MRB
                }
                }
        }
        for(OrderItem orditmloop : OrdrItems){
            OrderItemids.add(orditmloop.id);
            ordrordritmids.put(orditmloop.id,orditmloop.OrderId);
            orderToQuoteMap.put(orditmloop.orderId, orditmloop.Order.oracle_quote__c);

        }
        list<OrderItem> Orderitmdata = [select id, (select id,Product_Logins__c,product_code__c,Order_Line_Item__c, Order_Line_item__r.order.is_BMS__c,Order_Line_item__r.order.Account_Type__c, Order_Line_Item__r.order.Oracle_Quote__c, Order_Line_Item__r.order.Oracle_Quote__r.cansendemail__c from Assets__r where Get_CP_Login_Status__c = 'Complete'
                                                   and Asset_Type__c = 'Parent') from OrderItem where id in :OrderItemids];
        for(OrderItem orditmloop1 : Orderitmdata){
            assetdata.addall(orditmloop1.Assets__r);
        }
        assetdata.sort();
        If(assetdata.size() > 0 ){
            for (Asset Assetloop : assetdata){
                id orderid = ordrordritmids.get(Assetloop.Order_Line_Item__c);
                id quoteId = orderToQuoteMap.get(ordrordritmids.get(Assetloop.Order_Line_Item__c));//LEAP 8345 MRB
                boolean isBMS = Assetloop.Order_Line_Item__r.order.is_BMS__c;
                String AccountType = Assetloop.Order_Line_Item__r.order.Account_Type__c;
                String ProductCode = Assetloop.product_code__c;

                if(AccountType=='Realtor Agent' || ProductCode!='ADVANTAGE'){
                       if(!uniqueOrderIds.contains(OrderId)){ // added this condition along with uniqueOrderIds variable for LEAP-8401 ~ MRB
                                    updateorders.add(new Order(id=OrderId, cansendemail__c = true));
                                    uniqueOrderIds.add(OrderId);
                                }
                                if(isBMS){
                                    if(!uniqueQuoteIds.keySet().contains(quoteId)){
                                        BigMachines__Quote__c quoteToupdate = new BigMachines__Quote__c();
                                        quoteToupdate.cansendemail__c = true;
                                        quoteToupdate.id = quoteId;
                                        uniqueQuoteIds.put(quoteToupdate.id, quoteToupdate);
                                    }else{
                                        BigMachines__Quote__c quoteToupdate = uniqueQuoteIds.get(quoteId);
                                        quoteToupdate.cansendemail__c = true;
                                        quoteToupdate.id = quoteId;
                                        uniqueQuoteIds.put(quoteToupdate.id, quoteToupdate);
                                    }


                               }
                } else{
                if(Assetloop.Product_Logins__c != null && Assetloop.Product_Logins__c != ''){
                    //Parse XML to retrieve CPlogin details
                    Dom.Document domDoc = new Dom.Document();
                    domDoc.load(Assetloop.Product_Logins__c);
                    Dom.XMLNode CPLoginInfoResponse = domDoc.getRootElement();
                    for(Dom.XMLNode child : CPLoginInfoResponse.getChildElements()){
                        if(child.getName() == 'CPLoginList'){
                        if(!child.getChildElements().isEmpty()){
                            for(DOM.XMLNode Child1 : child.getChildElements()){
                                if(child1.getName() == 'CPLoginInfo'){
                                    AccountType         = ' ';
                                    CustID              = ' ';
                                    MlsID               = ' ';
                                    MlsName             = ' ';
                                    Name                = ' ';
                                    Password            = ' ';
                                    SSOEmail            = ' ';
                                    for(DOM.XMLNode child2 : Child1.getChildElements()){
                                        if(child2.getName() == 'AccountType')
                                            AccountType =  child2.getText().trim();
                                        if(child2.getName() == 'CustID')
                                            CustID =  child2.getText().trim();
                                        if(child2.getName() == 'MlsID')
                                            MlsID =  child2.getText().trim();
                                        if(child2.getName() == 'MlsName')
                                            MlsName =  child2.getText().trim();
                                        if(child2.getName() == 'Name')
                                            Name =  child2.getText().trim();
                                        if(child2.getName() == 'Password')
                                            Password =  child2.getText().trim();
                                        if(child2.getName() == 'SSOEmail')
                                            SSOEmail =  child2.getText().trim();
                                    }
                                CPLoginDetails.add(new CPDetailsWrapper(orderid,quoteid,AccountType,CustID,MlsID,MlsName,Name,Password,SSOEmail,isBMS));
                                }
                            }


                             }
                            else{ //updating the can send email file when the CP login details do not come LEAP-8313 ~ MRB
                                if(!uniqueOrderIds.contains(OrderId)){ // added this condition along with uniqueOrderIds variable for LEAP-8401 ~ MRB
                                    updateorders.add(new Order(id=OrderId, cansendemail__c = true));
                                    uniqueOrderIds.add(OrderId);
                                }
                                if(isBMS){
                                    if(!uniqueQuoteIds.keySet().contains(quoteId)){
                                        BigMachines__Quote__c quoteToupdate = new BigMachines__Quote__c();
                                        quoteToupdate.cansendemail__c = true;
                                        quoteToupdate.id = quoteId;
                                        uniqueQuoteIds.put(quoteToupdate.id, quoteToupdate);
                                    }else{
                                        BigMachines__Quote__c quoteToupdate = uniqueQuoteIds.get(quoteId);
                                        quoteToupdate.cansendemail__c = true;
                                        quoteToupdate.id = quoteId;
                                        uniqueQuoteIds.put(quoteToupdate.id, quoteToupdate);
                                    }


                               }

                            }
                        }
                    }
                }
            }
            }
        }
        //CPLoginDetails.sort();

        system.debug('CPLoginDetails:'+CPLoginDetails);

        for (CPDetailsWrapper cploop : CPLoginDetails){
            CPDetails__c temp2      = new CPDetails__c();
            temp2.Name              = cploop.MlsName;
            temp2.AccountType__c    = cploop.AccountType;
            temp2.AgentName__c      = cploop.Name;
            temp2.Password__c       = cploop.Password;
            temp2.UserName__c       = cploop.MlsID;
            temp2.Order__c          = cploop.orderid;
            temp2.SSOEmail__c       = cploop.SSOEmail;
            if(cploop.isbms){
                temp2.Quote__c          = cpLoop.quoteId;
                if(uniqueQuoteIds.keySet().contains(cpLoop.quoteId)){
                   BigMachines__Quote__c quoteToUpdate = uniqueQuoteIds.get(cpLoop.quoteId);
                   quoteToupdate.show_cp_details_attachment__c = true;
                   uniqueQuoteIds.put(cpLoop.quoteId,quoteToUpdate);
                }
                else{
                   BigMachines__Quote__c quoteToUpdate = new BigMachines__Quote__c();
                   quoteToupdate.show_cp_details_attachment__c = true;
                   uniqueQuoteIds.put(cpLoop.quoteId,quoteToUpdate);
                }
            }
            cpdetailsnodups.add(temp2);
        }
        cpdetailsinsert.addAll(cpdetailsnodups);

        for(CPDetails__c orderloop : cpdetailsinsert){
            order temp1             = new order();
            temp1.id                = orderloop.order__c;
            temp1.cansendemail__c   = true;
            if(!uniqueOrderIds.contains(temp1.id)){
                ordersnodups.add(temp1);
                uniqueOrderIds.add(temp1.id);
            }

            if(!uniqueQuoteIds.keySet().contains(orderToQuoteMap.get(orderLoop.order__c))){
                  BigMachines__Quote__c quoteToupdate = new BigMachines__Quote__c();
                  quoteToupdate.cansendemail__c = true;
                  quoteToupdate.id = orderToQuoteMap.get(orderLoop.order__c);
                  uniqueQuoteIds.put(quoteToupdate.id,quoteToUpdate);
            }else{
                 BigMachines__Quote__c quoteToupdate = uniqueQuoteIds.get(orderToQuoteMap.get(orderLoop.order__c));
                  quoteToupdate.cansendemail__c = true;
                  quoteToupdate.id = orderToQuoteMap.get(orderLoop.order__c);
                  uniqueQuoteIds.put(quoteToupdate.id,quoteToUpdate);
            }

            orederids.add(orderloop.order__c);
        }
        updateorders.addall(ordersnodups);

    cpdetailsdelete = [select id from cpdetails__c where order__c in : orederids];
        if(cpdetailsdelete.size() > 0){
           delete cpdetailsdelete;
        }
        if(!cpdetailsinsert.isEmpty()){
            insert cpdetailsinsert;
        }
        if(!uniqueQuoteIds.isEmpty()){
            for(Id key: uniqueQuoteIds.keySet()){

            quotesToUpdate.add(uniqueQuoteIds.get(key));
            }
            update quotesToUpdate;
        }
        if(!updateorders.isEmpty()){
            update updateorders;
        }
    }

    global void finish(Database.BatchableContext BC){
    }


}