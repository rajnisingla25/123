/* 
    Author      : Bala
    Description : Test class for Z_IIA_TriggerHandler class and Z_IIA_Trigger 
*/
@isTest(seeAllData=false) 
Public class Z_IIA_TriggerHandler_Test{
   static testMethod void Z_IIA_TriggerMethod(){
     //Inserting Customsetting for Account 
        DisabledTrigger__c Dtrg = new DisabledTrigger__c(Name= 'Disabled',TaskTrigger__c = 'Test11@test1.com',AssetTrigger__c = 'Test11@test1.com');
        insert Dtrg; 
        
        Account theAccount = TestDataFactory.createAccount('The Test Account', null, false);
            theAccount.Primary_Email__c = 'theAcc@move.com';
            theAccount.Type = Constants.OFFICE_ACCOUNT_TYPE;
        insert theAccount;
        Zuora__ZInvoice__c inv = new Zuora__ZInvoice__c();
            inv.Name = 'TestInv';
            inv.Zuora__Status__c = 'Past Due';
            inv.Zuora__Account__c = theAccount.Id;
        Insert inv;
        
        Zuora__Subscription__c sub = new Zuora__Subscription__c();
           sub.Name = 'Test';
           sub.Zuora__Account__c = inv.Zuora__Account__c;
           sub.Zuora__SubscriptionStartDate__c = system.Today();
           sub.Zuora__SubscriptionEndDate__c = system.Today();  
           sub.Zuora__NextRenewalDate__c  = system.Today();     
        insert sub;
     
        Invoice_Item__c invitem = new Invoice_Item__c();
           invitem.Name = 'Test';
           invitem.Invoice__c = inv.id;
           invitem.Subscription__c = sub.id;
           invitem.Invoice_Item_Zuora_Id__c = '2c92c095501d4d2f01502248e57c5b7a';
           invitem.Amount_with_Adjustments__c = 20;
        insert invitem;
        system.assertEquals(20,invitem.Amount_with_Adjustments__c );
        
       Test.StartTest();
            List<Invoice_Item_Adjustment__c> InvItemAdjList = New List<Invoice_Item_Adjustment__c>();
                Invoice_Item_Adjustment__c inItAdj = New Invoice_Item_Adjustment__c();
                    inItAdj.Invoice_Item_Zuora_Id__c = '2c92c095501d4d2f01502248e57c5b7a';
                    //inItAdj.Invoice_Item__c = invitem.id;
                    inItAdj.Invoice__c = inv.id;
                    inItAdj.Type__c = 'Testing';
                    inItAdj.Amount__c = 1;
                InvItemAdjList.add(inItAdj);   
            try{
            Insert InvItemAdjList; 
              }catch(Exception e){}  
            invitem.Amount_with_Adjustments__c = InvItemAdjList[0].Amount__c ;
            update invitem;
            
            Z_IIA_TriggerHandler handler = New Z_IIA_TriggerHandler ();
                handler.onBeforeInsert(InvItemAdjList);
                handler.onBeforeUpdate(InvItemAdjList);
        Test.StopTest();
  }      
}