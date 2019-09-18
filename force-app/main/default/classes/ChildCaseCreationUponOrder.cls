//**************************************************//
// (c) 2015 NTTDATA, Inc.
// Class Name : ChildCaseCreationUponOrder 
// This Class is Used to Create a Child case to Retention Case when the Order Status is Complete & Order Item Action is Credit/Refund. 
//
// Created 07th july 2015   Author Name:-  Venkataramana Cheedara     Original
// Modified 27th july 2015   Author Name:-  Venkataramana Cheedara     Modified
//**************************************************//

public class ChildCaseCreationUponOrder {

    public void ChildCaseCreationUponOrderUpdate(List < Order > Orders) {
        set < id > caseId = new set < id > ();
        set < id > OrderId = new set < id > ();
        set < id > OredrItemId = new set <id> ();
        // We need to store a List of Cases to create and a List of Case Asset Relationships.
        List < Case > casesToCreate = new List < Case > ();
        List<Case_Asset_Relationship__c> CARList = new List<Case_Asset_Relationship__c>();

        for (order o: orders) {
            caseId.add(o.Case__c);
            OrderId.add(o.id);
        }
        //Query for child case and Oredr Items if there are any existing 
        List < Case > childcase = [Select id, status,ParentId from case where ParentId  != null AND Status != 'Closed'AND ParentId in : caseId];
        List<OrderItem> orderItems = [Select id, Asset__c, OrderId, Line_Type__c from OrderItem where OrderId in : OrderId];
                
        for(OrderItem Oitem : orderItems ){
            OredrItemId.add(Oitem.id);
          }       
        
        Asset ParentAsset = new Asset();
        try{
        ParentAsset = [SELECT Id,Asset_Type__c,Order_Line_Item__c FROM Asset where Asset_Type__c = 'Parent' and Order_Line_Item__c in : OredrItemId limit 1];
        }
        catch(Exception e){}
        if(ParentAsset.id != Null){
        RecordType RT = [select id, name from Recordtype where name = 'Finance' limit 1];
        QueueSobject queue = [SELECT Id, queue.Name, QueueId FROM QueueSobject WHERE queue.Name = 'Finance Credit Queue'];

        // Loop over the Orders. Remember, we don't know how many Orders we will have
        for (Order ord: Orders) {
            if (childcase.size() == 0) {
                if (ord.Status == 'Complete') {
                    for(OrderItem Oitem : orderItems){
                          if (Oitem.Line_Type__c == 'Credit') {
                                // Order & OrderItem meets the criteria to create the case and
                                // add it to List of cases
                                Case caseToAdd = new Case();
                                caseToAdd.Status = 'Open';
                                caseToAdd.OwnerId = queue.QueueId;
                                caseToAdd.SubStatus__c = 'Pending Customer';
                                caseToAdd.ParentId = ord.Case__c;
                                caseToAdd.AccountId = ord.AccountId;
                                caseToAdd.Area__c = 'Credit Request';
                                caseToAdd.Subject = 'Zoura Customer Needed Credit/Refund';
                                caseToAdd.Origin = 'Phone';
                                caseToAdd.recordTypeId = RT.Id;
                                caseToAdd.Type = RT.Name;
                                if (ParentAsset.id != Null){
                                     caseToAdd.AssetId = ParentAsset.Id; 
                                }
                                
                                caseToAdd.Description = 'Credit Order has been approved and completed. Please process in Zuora Account ';
                                casesToCreate.add(caseToAdd);
                    }
                }
            }
        }
     }   
        // we have our full List of cases to add, now just run the insert DML statement
        if (casesToCreate.size() > 0) {
            system.debug('casesToCreate' + casesToCreate.Size());
            insert casesToCreate;
        }
        //Creating a Case Asset Relationship record with the cretaed Case and Case Asset
         if (parentasset!=null){ 
           for(case cas : casesToCreate){
               for(OrderItem Oitem : orderItems){
                Case_Asset_Relationship__c CAR = new Case_Asset_Relationship__c();
                CAR.Case__c = cas.id;
                if (ParentAsset.id != Null){
                    CAR.Asset__c = ParentAsset.Id;
                }
                CAR.Cancellation_Reason__c = 'Financial Hardship';
                CARList.add(CAR);
           }
         }
       }   
          if(CARList.size()>0){
              Insert CARList;
            }  
          }                 
    }
}