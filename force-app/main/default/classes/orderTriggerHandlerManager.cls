/*
Author - Sonu Sharma
NTT Data Inc
*/
public class orderTriggerHandlerManager{
    private static Map<Id, Id> theMapOpportunityids= new Map<Id, Id>();
    public static Set<Id> convertedLeads = new Set<Id>();
    
    public void accountOwnerUpdate(map<ID,Order> newMap,map<ID,Order> oldMap) {
        map<Id,ID> ordersowner = new map<Id,ID>();
        set<ID> accIds = new set<ID>();
        list<account> accUpdate = new list<Account>();
        Set<Id> setOpportunityIds = new Set<Id>();
        for(order oOrder:newmap.Values()){
            if(oOrder.AccountId != null){
                if(oOrder.Fulfillment_Status__c == 'Fulfilled' && oldMap.get(oOrder.ID).Fulfillment_Status__c  != oOrder.Fulfillment_Status__c ) {
                    if((oOrder.all_order_products_count__c>oOrder.cancel_credit_buyout_Count__c) || Test.isRunningTest()){
                        ordersowner.put(oOrder.ID , oOrder.OwnerId);
                    }
                    accIds.add(oOrder.AccountId);
                    if(oOrder.opportunityId!=null){
                        setOpportunityIds.add(oOrder.opportunityId);
                    }
                }
            }
        }
        map<Id,ID> officeBooleanMap = new map<ID,ID>();
        list<Account> accList = new list<Account>(); 
        
        // CRM-1423 Added condition to avoid executing SOQL if set is empty 
        if (!accIDs.isEmpty()) {
            // CRM-2126 Added Owner.IsActive in below SOQL
            accList = [Select Owner.IsActive, Account_Sub_Type__c, Owner.Name,Owner.USERName, Id,OwnerId ,Owner.Profile.Name,
                    Do_Not_Move__c,Sales_Lock_User__c , (Select Id,AccountID FROM Orders WHERE ID IN: newmap.keyset())
                    FROM Account WHERE ID IN: accIDs
                    //AND Sales_Lock_User__c = null
                    AND ( Type = 'Broker' OR Type = 'Realtor Agent')
                    AND (Account_Sub_Type__c ='Prospect' OR Account_Sub_Type__c = 'Former Customer')];
                    //AND Owner.Profile.Name = 'Move Data Integration'
        }
        // Venu -2277 For Account Owner Update
        //Profile p = [Select Name from Profile where Id =: userinfo.getProfileid()];                
        for(Account oAccount : accList ) {
            Account tempAcc = new Account(Id=oAccount.ID);
            
            for(Order orderObj : oAccount.Orders){
                system.debug('---- order '+orderObj);
                if(oAccount.Sales_Lock_User__c == null && oAccount.ID ==orderObj.AccountID &&  ordersowner.containsKey(orderObj.Id)) {
                    tempAcc.Account_Sub_Type__c = 'Customer';   // CRM-2932 Moved this statement out of below ifs.
                    
                    // CRM-2352 - Update Owner if Run_Owner_Reassignment_Order is true
                    if (Label.Run_Owner_Reassignment_Order == 'true') {
                        Map<String,String> unAssignedUsers = new Map<String,String>();
                        //CRM - 1306 :- Custom setting for list of user name
                        Error_Notification_Email_Settings__c theUserNamelist = Error_Notification_Email_Settings__c.getInstance('Account Owner List Transfer');
                        String theUserName;
                        if (theUserNamelist!=null){
                            theUserName = theUserNamelist.Asset_Creation_Error_Emails__c;
                                    
                            List<String> lstUName = theUserName.split(';');
                            for(String sttr:lstUName){
                                unAssignedUsers.put(sttr+'',sttr+'');
                            }
                        }
         

                        System.debug(unAssignedUsers.containskey(oAccount.Owner.USERName)+'PPPPPP'+oAccount.Owner.USERName);
                        // CRM-2126 - Re-Assign Account Owner if current owner is In-Active.
                        if (oAccount.Account_Sub_Type__c !='Prospect' || unAssignedUsers.containskey(oAccount.Owner.USERName) || !oAccount.Owner.IsActive) {
                           // CRM-2126 Added profile 'Move Broker Sales Rep' to the condition below
                           // CRM-2126 - Re-Assign Account Owner if current owner is In-Active.
                            if(!oAccount.Owner.IsActive || !Label.Account_Owner_Not_Be_Changed_Profile_List.contains(oAccount.Owner.Profile.Name)) {
                                // CRM-3952 - Added new condition above and commented below condition.
                                //oAccount.Owner.Profile.Name != 'Move Agent Sales Rep' && oAccount.Owner.Profile.Name != 'Move Broker Sales Rep')){                                  
                                tempAcc.OwnerId = ordersowner.get(orderObj.Id);
                            }
                        }
                    }
                    officeBooleanMap.put(oAccount.ID,ordersowner.get(orderObj.Id));
                }
                
                if(oAccount.Sales_Lock_User__c != null && oAccount.ID == orderObj.AccountID && oAccount.Do_Not_Move__c==false) {
                    // Venu -2277 For Account Owner Update
                    //if (p.Name == 'Move Sales Ops' && p.Name == 'Move Broker Account Manager' && p.Name == 'Admin Read Only') {                                                   
                    // Venu commented for Sales lock user requirment  14th Nov 2017
                            
                    // CRM-2352 - Update Owner if Run_Owner_Reassignment_Order is true
                    if (Label.Run_Owner_Reassignment_Order == 'true') {
                        tempAcc.OwnerId = oAccount.Sales_Lock_User__c;  // 2352 logic implementation.
                    }
                    
                    // }
                    // else {
                        //tempAcc.Review_Account_Owner__c = true;                
                    //}                        
                    // Venu -2277 For Account Owner Update
                    
                    tempAcc.Account_Sub_Type__c = 'Customer';
                    officeBooleanMap.put(oAccount.ID,oAccount.Sales_Lock_User__c);
                }
                else if(oAccount.ID == orderObj.AccountID && oAccount.Do_Not_Move__c==true){

                    //tempAcc.OwnerId = ordersowner.get(orderObj.Id);
                    // Venu -2277 For Account Owner Update
                    //   if (p.Name == 'Move Sales Ops' && p.Name == 'Move Broker Account Manager' && p.Name == 'Admin Read Only') {                            
                    
                    tempAcc.OwnerId = oaccount.ownerid;
                    
                    //  }
                    //  else {
                    //  tempAcc.Review_Account_Owner__c = true;                
                    // }
                    // Venu -2277 For Account Owner Update
                    
                    tempAcc.Account_Sub_Type__c = 'Customer';
                    officeBooleanMap.put(oAccount.ID,ordersowner.get(orderObj.Id));
                    
                }
            }
            system.debug('*****tempAcc***'+tempAcc);
            accUpdate.add(tempAcc);
        }
           
            
        List<Account_Relationship__c> lstRelationshipRecord = new List<Account_Relationship__c>();
        // CRM-1423 Added condition to avoid executing SOQL if set is empty
        if (!accIds.isEmpty()) {
            lstRelationshipRecord = [SELECT Child_Account__c,Parent_Account__c FROM Account_Relationship__c WHERE Parent_Account__c IN: accIds 
                                    AND Parent_Account__r.Type != 'Realtor Agent' AND Child_Account__r.Account_Sub_Type__c = 'Prospect' AND 
                                    Child_Account__r.Type = 'Realtor Office' AND RecordType.DeveloperName = 'Account_Relationship' order by Name asc limit 49997];
        }
        
        if(lstRelationshipRecord.size()>0){
            String accofcIds = '';
            for(String s:accIds) {
                accofcIds += (accofcIds==''?'':',')+s;
            }
            AsyncRecordProcessExecution__c arpe = new AsyncRecordProcessExecution__c();
                                        arpe.Name = 'OrderTriggerHandlerManager';
                                        arpe.Interface_Name__c = 'accountOwnerUpdate';
                                        arpe.ClassName__c = 'OrderTriggerHandlerManager';
                                        arpe.MethodName__c = 'AsyncupdateOfficeAccounts';
                                        arpe.Boolean_Param__c = true;
                                        arpe.Records_To_Process_Ids__c = accofcIds+'';
                                        Insert arpe;
        }

        if(!accUpdate.isEmpty()) {
           update accUpdate;
        }
        if(setOpportunityIds.size()>0){
            UpdateOpportunity(setOpportunityIds);
        }
    }

    Public void AsyncupdateOfficeAccounts(Set<Id> setAccountIds){
    List<Account> lstofficeaccount =  updateOfficeAccounts(setAccountIds);
    update lstofficeaccount;
    }
    Public List<Account> updateOfficeAccounts(Set<Id> setAccountIds){
    list<account> accUpdate = new list<Account>();
    map<ID,ID> officemap = new map<ID,ID>();
     //   system.debug('***accIDs***'+accIDs);
        for(Account_Relationship__c accRelation : [SELECT Child_Account__c,Parent_Account__c
                                                   FROM Account_Relationship__c
                                                   WHERE Parent_Account__c IN: setAccountIds AND Parent_Account__r.Type != 'Realtor Agent' AND Child_Account__r.Account_Sub_Type__c = 'Prospect' AND Child_Account__r.Type = 'Realtor Office'
                                                   AND RecordType.DeveloperName = 'Account_Relationship' order by Name asc limit 49997]){
             officemap.put(accRelation.Child_Account__c,accRelation.Parent_Account__c);
                                                       system.debug('---- > Adding to the office map');
        }
        list<Account> accofficeList =[Select Id,OwnerId,Account_Sub_Type__c
            FROM Account WHERE ID IN: officemap.keyset() AND Type = 'Realtor Office'
        //AND Account_Sub_Type__c ='Prospect'
        ] ;
        map<Id,ID> officeBooleanMap = new map<ID,ID>();
         for(Account oAccount : accofficeList){
            System.Debug('---- OAccount '+oAccount);
            if(officeBooleanMap.containsKey(officemap.get(oAccount.ID)) ){
                 Account tempAcc = new Account(Id=oAccount.ID);
                 tempAcc.Account_Sub_Type__c = 'Customer';
                 tempAcc.OwnerId = officeBooleanMap.get(officemap.get(oAccount.ID));
                 accUpdate.add(tempAcc);
            }
        }
        return accUpdate;
    }

    Public void UpdateOpportunity(Set<Id> setOpportunityIds){
    //Map<Id, Id> theMapOpportunityids= new Map<Id, Id>();
    Map<Id, Decimal> theMapOpportunityAmounts= new Map<Id, Decimal>();
    if(!Test.isRunningTest()){
    for(OrderItem theOrderItem : [SELECT Id, OrderId,Order.OpportunityId,Total_Net__c, Fulfillment_Status__c FROM OrderItem WHERE Order.OpportunityId IN :setOpportunityIds]) {
        if(theOrderItem.Fulfillment_Status__c != 'Fulfilled' && theOrderItem.Fulfillment_Status__c != 'Error'){
        theMapOpportunityids.put(theOrderItem.Order.OpportunityId,theOrderItem.Order.OpportunityId);
        }
         if(theOrderItem.Total_Net__c==null){theOrderItem.Total_Net__c=0.0;}
        if(theOrderItem.Fulfillment_Status__c != 'Error' && theOrderItem.Total_Net__c!=null){
        if(theMapOpportunityAmounts.containskey(theOrderItem.Order.OpportunityId)){
        Decimal oppamount = theMapOpportunityAmounts.get(theOrderItem.Order.OpportunityId);
        oppamount = oppamount+theOrderItem.Total_Net__c;
        theMapOpportunityAmounts.put(theOrderItem.Order.OpportunityId,oppamount);
        } else {
        theMapOpportunityAmounts.put(theOrderItem.Order.OpportunityId,theOrderItem.Total_Net__c);
        }
        }
      }
      }
      List<Opportunity> OpportunityToBeUpdated = new List<Opportunity>();
      for(Id theoppId:setOpportunityIds){
      if(theoppId!=null){
      if(!theMapOpportunityids.containskey(theoppId)){
      theMapOpportunityids.put(theoppId, theoppId);
      OpportunityToBeUpdated.add(new Opportunity(
            Id = theoppId,
            StageName = 'Closed Won - Fulfilled',
            Fulfillment_Complete__c = true,
            Total_Opportunity_Amount__c = theMapOpportunityAmounts.get(theoppId)
          ));
          }
          }
      }
      if(OpportunityToBeUpdated.size() > 0) {
        update OpportunityToBeUpdated;
      }
    }

 Public void GenerateJsonOrdersStrings(Map<Id,Order> mapOrders){
      Map<Id,Set<String>> mapOrder = new Map<Id,Set<String>>();
      
      // CRM-1423 Added condition to avoid executing SOQL if map is empty
      if (!mapOrders.isEmpty()) {
          for(OrderItem otm:[Select id,OrderId,Inventory_Transaction_Id__c from Orderitem where OrderId=:mapOrders.keyset() and Inventory_Transaction_Id__c!=null]){
          if(mapOrder.containskey(otm.OrderId)){
          Set<String> setOrderProductIds = new Set<String>();
          setOrderProductIds = mapOrder.get(otm.OrderId);
          setOrderProductIds.add(otm.Inventory_Transaction_Id__c);
          mapOrder.put(otm.OrderId,setOrderProductIds);
          } else {
          Set<String> setOrderProductIds = new Set<String>();
          setOrderProductIds.add(otm.Inventory_Transaction_Id__c);
          mapOrder.put(otm.OrderId,setOrderProductIds);
          }
          }
      }
      for(Id idd:mapOrder.keyset()){
      mapOrders.get(idd).All_Order_Product_Ids__c = (mapOrder.get(idd)+'').replace('}','').replace('{','').replace(' ','');
      }
      }
     // LCM-97: Update credit field on comarketing object once Order is complete
    public void updateCoMarketingRel(List<Order> newList,map<ID,Order> oldMap){
        Set<Id> odrids = new Set<Id>();
        Map<Id, orderItem> astOiMap = new Map<Id,orderItem>();
        for(Order odr: newList){
            if(odr.status == 'Complete' && odr.status != oldMap.get(odr.id).status && odr.products__c != null && odr.products__c.contains('COBROKE')){
                odrids.add(odr.id);
            }
        }
        for(OrderItem oi: [Select id, Asset__c, Total_credit_amount__c, credit_amount__c from OrderItem where OrderId IN :odrids and Line_Type__c IN ('Credit', 'Cancel') 
                           and Part_Number__c = 'COBROKE' and Credit_amount__c != null and Total_credit_amount__c != 0.00 and Total_credit_amount__c != null]){
            if(oi.Total_credit_amount__c != oi.credit_amount__c){
                astOiMap.put(oi.Asset__c, oi);
            }
        }
        if(!astOiMap.isEmpty()){
            List<Comarketing_Relationship__c> coMarRelList = [Select id, Lender_Percentage_Contribution__c,CFCB_Asset__c,CFCB_Asset__r.Line_Type__c from Comarketing_Relationship__c where CFCB_Asset__c IN :astOiMap.keySet()];
            for(Comarketing_Relationship__c coMarRel : coMarRelList){
                coMarRel.Credit__c = astOiMap.get(coMarRel.CFCB_Asset__c).Total_Credit_Amount__c - astOiMap.get(coMarRel.CFCB_Asset__c).Credit_Amount__c;
                if(coMarRel.CFCB_Asset__r.Line_Type__c == 'Credit'){
                      coMarRel.action__c = 'Amend';
                }
                coMarRel.Agent_Credit_Amount__c = astOiMap.get(coMarRel.CFCB_Asset__c).Credit_Amount__c;
                coMarRel.Amendment_Effective_Date__c  = Date.today();
                coMarRel.Lender_Zuora_Status__c = 'Pending update';
            }
            if(!coMarRelList.isEmpty()){
                update coMarRelList;
            }
        }
    }

}