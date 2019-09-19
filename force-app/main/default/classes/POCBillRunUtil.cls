public class POCBillRunUtil {
    public static void searchSubscriptions(List<Billing_Account_Temp__c> billAccounts,Date startdate,date enddate)
    {
     
       /*for(Billing_Account_Temp__c accountWithSub : [select id, name, 
           (select id, name 
         		from Subscription_Temps__r  where Billing_Account_Temp__c  IN :billAccounts
            		and EffectiveStartDate__c <:startdate
     		) 
         from Billing_Account_Temp__c where Id IN :billAccounts])
       {
           
           
       }*/
        Map<Billing_Account_Temp__c,Invoice_temp__c > AccountInvoices= new Map<Billing_Account_Temp__c,Invoice_temp__c >();
        Map<Id,List<Amendment_Temp__c> > AccountAmendments= new Map<Id,List<Amendment_Temp__c>>();
        Set<Id> subIds= new Set<Id>();
        

      for(Amendment_Temp__c amds   :[Select Id,Subscription_Temp__r.Id, Subscription_Temp__r.Billing_Account_Temp__c 
                                        from Amendment_Temp__c
                                       where Subscription_Temp__r.Billing_Account_Temp__c in :billAccounts
                                       and EffectiveStartDate__c <:startdate and LastInvoiceDate__c= null
                                       and EffectiveEndtDate__c = null])
      {
        subIds.add(amds.Subscription_Temp__c);
          if(AccountAmendments.containsKey(amds.Subscription_Temp__r.Billing_Account_Temp__c))
          {
          	if(AccountAmendments.get(amds.Subscription_Temp__r.Billing_Account_Temp__c)!=null)
              	AccountAmendments.get(amds.Subscription_Temp__r.Billing_Account_Temp__c).add(amds);
          	else
            {
                List<Amendment_Temp__c> amdList=AccountAmendments.get(amds.Subscription_Temp__r.Billing_Account_Temp__c);
                   amdList= new List<Amendment_Temp__c>();
                	amdList.add(amds);
               
            }
          }
          else
          {
              	List<Amendment_Temp__c> amdList= new List<Amendment_Temp__c>();
                amdList.add(amds);
              	AccountAmendments.put(amds.Subscription_Temp__r.Billing_Account_Temp__c,amdList);               
	          }
      }
      
  
       
    }

}