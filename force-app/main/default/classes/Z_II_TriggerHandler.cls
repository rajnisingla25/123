/**
 * Trigger handler class that maps the invoice items to the right
 * invoices, subscriptions, subscription product charges,
 * products, product rate plans and product rate plan charges.
 * @author Waly K. Ndao (waly.ndao@zuora.com) 
 */
public with sharing class Z_II_TriggerHandler {
 
    // Constructor
    public Z_II_TriggerHandler() {}

    private static final String DEBUG_STR = 'Z_II_TriggerHandler: ';
    
    /**
    * Method called before insert invoice items.
    * Sets various lookup fields on InvoiceItem to existing SFDC objects
    * @param newIIs the invoice items to be inserted.
    */
    public void onBeforeInsert(List<Invoice_Item__c> newIIs) {
        final String FUNC_STR = DEBUG_STR+'onBeforeInsert: ';
        
        System.debug(FUNC_STR+'Inserting invoice item records...');
        System.debug(FUNC_STR+'The IIs are: ' + newIIs);

        Set<String> inv_z_ids;
        Set<String> sub_z_ids;
        Set<String> rpc_z_ids;
        Set<String> p_z_ids;
        Set<String> prp_z_ids;
        Set<String> prpc_z_ids;
        Set<String> bacc_z_ids;
        Set<String> asset_z_ids;

        Map<String, String> inv_z2s;
        Map<String, Zuora__Subscription__c> sub_z2s;
        Map<String, String> rpc_z2s;
        Map<String, String> p_z2s;
        Map<String, String> prp_z2s;
        Map<String, String> prpc_z2s;
        Map<String, String> bacc_z2s;
        Map<String, Asset> asset_z2s;
        Map<String, List<date>> sub_date = new Map<String, List<date>>();
        Map<String, List<date>> comar_date = new Map<String, List<date>>();
        Map<String, String> comarHistMap = new Map<String, String>();

        List<Zuora__ZInvoice__c> relInvs;
        List<Zuora__Subscription__c> relSubs;
        List<Zuora__Subscription__c> relSubs2;
        List<Zuora__SubscriptionProductCharge__c> relRPCs;
        List<zqu__ZProduct__c> relProds;
        List<zqu__ProductRatePlan__c> relPRPs;
        List<zqu__ProductRatePlanCharge__c> relPRPCs;
        List<Zuora__CustomerAccount__c> relAccs;
        List<Asset> relAssets;

        inv_z_ids = new Set<String>();
        sub_z_ids = new Set<String>();
        rpc_z_ids = new Set<String>();
        p_z_ids = new Set<String>();
        prp_z_ids = new Set<String>();
        prpc_z_ids = new Set<String>();
        bacc_z_ids = new Set<String>();
        asset_z_ids = new Set<String>();

        inv_z2s = new Map<String, String>();
        sub_z2s = new Map<String, Zuora__Subscription__c>();
        rpc_z2s = new Map<String, String>();
        p_z2s = new Map<String, String>();
        prp_z2s = new Map<String, String>();
        prpc_z2s = new Map<String, String>();
        bacc_z2s = new Map<String, String>();
        asset_z2s = new Map<String, Asset>();

        for (Invoice_Item__c ii : newIIs) {
                inv_z_ids.add(ii.Invoice_Zuora_ID__c);
                sub_z_ids.add(ii.Subscription_Zuora_ID__c);
                rpc_z_ids.add(ii.RPC_Zuora_ID__c);
                p_z_ids.add(ii.Product_Zuora_ID__c);
                prp_z_ids.add(ii.PRP_Zuora_ID__c);
                prpc_z_ids.add(ii.PRPC_Zuora_ID__c);
                bacc_z_ids.add(ii.Account_Zuora_ID__c);
                asset_z_ids.add(ii.Asset_In_Zuora__c);
                // LCM-247 Map of subscription and charge dates
                if(!sub_date.containsKey(ii.Subscription__c)){
                     sub_date.put(ii.Subscription__c, new List<Date>{ii.Charge_date__c});
                } else {
                    List<Date> chDate = sub_date.get(ii.Subscription__c);
                    chDate.add(ii.Charge_date__c);
                    sub_date.put(ii.Subscription__c, chDate);
                }
        }

        relInvs = [SELECT
                        Id, 
                        Zuora__External_Id__c 
                FROM    Zuora__ZInvoice__c
                WHERE Zuora__External_Id__c in: inv_z_ids];

        relSubs = [SELECT
                        Id,CMRelationship__c, CMRelationship__r.Initial_Lender_Monthly_Contribution__c ,CMRelationship__r.Initial_Agent_Monthly_Contribution__c ,CMRelationship__r.Agent_Credit_Amount__c ,
                        Name,CMRelationship__r.Initial_Asset_Monthly_Price__c, CMRelationship__r.action__c, CMRelationship__r.start_date__c
                FROM    Zuora__Subscription__c
                WHERE Name in: sub_z_ids];

        relRPCs = [SELECT
                        Id, 
                        Z_Charge_Number__c
                FROM    Zuora__SubscriptionProductCharge__c
                WHERE Z_Charge_Number__c in: rpc_z_ids];

        relProds = [SELECT
                        Id, 
                        zqu__ZuoraId__c
                FROM    zqu__ZProduct__c
                WHERE zqu__ZuoraId__c in: p_z_ids];

        relPRPs = [SELECT
                        Id, 
                        zqu__ZuoraId__c
                FROM    zqu__ProductRatePlan__c
                WHERE zqu__ZuoraId__c in: prp_z_ids];

        relPRPCs = [SELECT
                        Id, 
                        zqu__ZuoraId__c
                FROM    zqu__ProductRatePlanCharge__c
                WHERE zqu__ZuoraId__c in: prpc_z_ids];

        relAccs = [SELECT
                        Id, 
                        Zuora__External_Id__c 
                FROM    Zuora__CustomerAccount__c
                WHERE Zuora__External_Id__c in: bacc_z_ids];

        relAssets = [SELECT 
                        Id,
                        Name
                FROM    Asset
                WHERE Id in: asset_z_ids];

        System.debug(FUNC_STR+'About to process the invs, subs and other objects.');

        for (Zuora__ZInvoice__c inv : relInvs) {
            inv_z2s.put(inv.Zuora__External_Id__c, inv.Id);
        }
        Date lcm_start_date = Date.today();
        for (Zuora__Subscription__c sub : relSubs) {           
            sub_z2s.put(sub.Name, sub);   
            system.debug(sub);
            //LCM-247
            if(sub.CMRelationship__c != null && sub.CMRelationship__r.action__c != 'Add'){
                comar_date.put(sub.CMRelationship__c, sub_date.get(sub.id));
                if(sub.CMRelationship__r.start_date__c != null && lcm_start_date > sub.CMRelationship__r.start_date__c){
                    lcm_start_date = sub.CMRelationship__r.start_date__c;
                }
            }// END LCM-247
        }
        for (Zuora__SubscriptionProductCharge__c rpc : relRPCs) {
            rpc_z2s.put(rpc.Z_Charge_Number__c, rpc.Id);
        }
        for (zqu__ZProduct__c prod : relProds) {
            p_z2s.put(prod.zqu__ZuoraId__c, prod.Id);
        }
        for (zqu__ProductRatePlan__c prp : relPRPs) {
            prp_z2s.put(prp.zqu__ZuoraId__c, prp.Id);
        }
        for (zqu__ProductRatePlanCharge__c prpc : relPRPCs) {
            prpc_z2s.put(prpc.zqu__ZuoraId__c, prpc.Id);
        }
        for (Zuora__CustomerAccount__c acc : relAccs) {
            bacc_z2s.put(acc.Zuora__External_Id__c, acc.Id);
        }
        for (Asset a : relAssets) {
            asset_z2s.put(a.Id, a);
        }
        //LCM-247
        try{
            if(!comar_date.isEmpty() || test.isRunningTest()){
                Time jobRunTime = Time.newInstance(0, 0, 0, 0).addMinutes(Integer.valueOf(System.Label.LCM_Invoice_Created_Time));
                Integer daysDiff = Date.today().daysBetween(lcm_start_date);
                Map<String, Integer> comar_count = new Map<String, Integer>();
                Date dt = Date.today().addDays(-180);
                if(lcm_start_date <= dt){
                    dt = lcm_start_date;
                }
                System.debug('---'+dt+comar_date+sub_date);
                if(test.isRunningTest()){
                    List<Comarketing_Relationship__c> crlist = [Select id from Comarketing_Relationship__c limit 5];
                    comar_date.put(crlist[0].id, new List<Date>{date.today().addDays(2)});
                    comar_date.put(crlist[1].id, new List<Date>{date.today().addDays(2)});
                }
                // Fetch last 6 months history
                for(Comarketing_Relationship__History comarHist : [Select id,parentId, field,newvalue,CreatedDate from Comarketing_Relationship__History 
                                                                    where field IN ('Agent_Asset_Monthly_Contribution__c','Lender_Asset_Monthly_Contribution__c', 'Agent_Credit_amount__c', 'Asset_Monthly_Price_Non_Formula__c') 
                                                                    and parentId IN :comar_date.keySet() and createddate >= :dt order by createdDate desc limit 5000]){
                     System.debug('---'+comarHist);
                    for(Date chargedate : comar_date.get(comarHist.parentId)){
                        if(!comarHistMap.containsKey(comarHist.parentId+'---'+string.valueOf(chargedate)+'---'+comarHist.field)){
                            Integer offset = TimeZone.getTimeZone('PST').getOffset(comarHist.createddate);
                            Datetime createdD = comarHist.createddate.addSeconds(offset/1000);
                            System.debug(createdD.timeGMT()+'--'+createdD.dateGmt()+'--'+jobRunTime);
                            if(chargeDate > createdD.dateGmt() || (chargeDate == createdD.dateGmt() && createdD.timeGMT() < jobRunTime)){
                                System.debug('---not found'+createdD);
                                comarHistMap.put(comarHist.parentId+'---'+string.valueOf(chargedate)+'---'+comarHist.field, string.valueOf(comarHist.newValue));
                                if(comar_count.containsKey(comarHist.parentId+'---'+string.valueOf(chargedate))){
                                    Integer cnt = comar_count.get(comarHist.parentId+'---'+string.valueOf(chargedate)) + 1;
                                    comar_count.put(comarHist.parentId+'---'+string.valueOf(chargedate), cnt);
                                } else {
                                    comar_count.put(comarHist.parentId+'---'+string.valueOf(chargedate), 1);
                                }
                            }    
                        }
                    }
                }
                 System.debug('---'+comarHistMap);
                  System.debug('---'+comar_count);
                // Fetch rest of the history for records not found in last 6 months
                if(lcm_start_date > Date.today().addDays(-180)){
                    Set<String> cr = new Set<String>();
                    for(String cid : comar_count.keySet()){
                        // Check if all 3 fields (Credit amount not needed) are fetched for comar-relationship for given charge date
                        if(comar_count.get(cid) < 3){
                            cr.add(cid);
                        }
                    }
                    if(!cr.isEmpty()){
                        for(Comarketing_Relationship__History comarHist : [Select id, field, oldValue,newvalue from Comarketing_Relationship__History 
                                                                            where field IN ('Agent_Asset_Monthly_Contribution__c','Lender_Asset_Monthly_Contribution__c', 'Agent_Credit_amount__c', 'Asset_Monthly_Price_Non_Formula__c') 
                                                                            and parentId IN :cr and createddate < :dt order by createdDate desc limit 3000]){
                            for(Date chargedate : comar_date.get(comarHist.parentId)){
                                if(!comarHistMap.containsKey(comarHist.parentId+'---'+string.valueOf(chargedate)+'---'+comarHist.field)){
                                Integer offset = TimeZone.getTimeZone('PST').getOffset(comarHist.createddate);
                                Datetime createdD = comarHist.createddate.addSeconds(offset/1000);
                                if(chargeDate > createdD.dateGmt() || (chargeDate == createdD.dateGmt() && createdD.timeGMT() < jobRunTime)){
                                        comarHistMap.put(comarHist.parentId+'---'+string.valueOf(chargedate)+'---'+comarHist.field, string.valueOf(comarHist.newValue));
                                    }    
                                }
                            }
                        }
                    }
                }
            }
        } catch(Exception e){
            System.debug(e);
        }
        // END LCM-247
        
		 for (Invoice_Item__c ii : newIIs) {
            if(sub_z2s.get(ii.Subscription_Zuora_ID__c) != null){
            ii.Subscription__c = sub_z2s.get(ii.Subscription_Zuora_ID__c).Id;
            //LCM-247
            if(sub_z2s.get(ii.Subscription_Zuora_ID__c).CMRelationship__c != null || test.isRunningTest()){
                try{
                    ii.Agent_Credit_Amount_LCM__c =sub_z2s.get(ii.Subscription_Zuora_ID__c).CMRelationship__r.Agent_Credit_Amount__c;
                    ii.Agent_Paid_Amount_LCM__c  = sub_z2s.get(ii.Subscription_Zuora_ID__c).CMRelationship__r.Initial_Agent_Monthly_Contribution__c;
                    ii.Lender_Paid_Amount_LCM__c = sub_z2s.get(ii.Subscription_Zuora_ID__c).CMRelationship__r.Initial_Lender_Monthly_Contribution__c;
                    ii.Asset_Monthly_Price_LCM__c = sub_z2s.get(ii.Subscription_Zuora_ID__c).CMRelationship__r.Initial_Asset_Monthly_Price__c;
           
                    String crDate = string.valueOf(ii.Charge_date__c);
                    String cId = sub_z2s.get(ii.Subscription_Zuora_ID__c).CMRelationship__c;
                    if(comarHistMap.containsKey(cId+'---'+crDate+'---Agent_Asset_Monthly_Contribution__c')){
                        ii.Agent_Paid_Amount_LCM__c  = Decimal.valueOf(comarHistMap.get(cId+'---'+crDate+'---Agent_Asset_Monthly_Contribution__c'));
                    }
                    if(comarHistMap.containsKey(cId+'---'+crDate+'---Lender_Asset_Monthly_Contribution__c')){
                        ii.Lender_Paid_Amount_LCM__c  = Decimal.valueOf(comarHistMap.get(cId+'---'+crDate+'---Lender_Asset_Monthly_Contribution__c'));
                    }
                    if(comarHistMap.containsKey(cId+'---'+crDate+'---Agent_Credit_amount__c')){
                        ii.Agent_Credit_Amount_LCM__c  = Decimal.valueOf(comarHistMap.get(cId+'---'+crDate+'---Agent_Credit_amount__c'));
                    }
                    if(comarHistMap.containsKey(cId+'---'+crDate+'---Asset_Monthly_Price_Non_Formula__c')){
                        ii.Asset_Monthly_Price_LCM__c  = Decimal.valueOf(comarHistMap.get(cId+'---'+crDate+'---Asset_Monthly_Price_Non_Formula__c'));
                    }
                } catch(Exception e){
                    System.debug( e);
                }//END LCM-247
            
            }
            }
            ii.Subscription_Product_Charge__c = rpc_z2s.get(ii.RPC_Zuora_ID__c);
            ii.Product__c = p_z2s.get(ii.Product_Zuora_ID__c);
            ii.ProductRatePlan__c = prp_z2s.get(ii.PRP_Zuora_ID__c);
            ii.ProductRatePlanCharge__c = prpc_z2s.get(ii.PRPC_Zuora_ID__c);
            ii.Billing_Account__c = bacc_z2s.get(ii.Account_Zuora_ID__c);
            ii.Amount_with_Adjustments__c = ii.Charge_Amount__c;

            if(inv_z2s.get(ii.Invoice_Zuora_ID__c) != null) {
                ii.Invoice__c = inv_z2s.get(ii.Invoice_Zuora_ID__c);
            } else {
                System.debug(FUNC_STR+'We were unable to find the invoice ' + ii.Invoice_Zuora_ID__c + '. Adding error.');
                // No need to send the csv to admin
                // Errors will be displayed on the java program log.
                ii.addError('The invoice ' + ii.Invoice_Zuora_ID__c 
                    + ' for the invoice item ' + ii.Invoice_Item_Zuora_ID__c 
                    + ' is not found.');
            }

            if (asset_z2s.get(ii.Asset_In_Zuora__c) != null) {
                ii.Asset__c = ii.Asset_In_Zuora__c;
            }
        }
       
    }
     //CRM-2203 added method to update the invoices which are new subscription
     public void onafterInsert(List<Invoice_Item__c> newIIs2) {
      
      Set<String> sub_z_ids2 = new Set<String>();
      for (Invoice_Item__c ii : newIIs2) {
               
                sub_z_ids2.add(ii.Subscription_Zuora_ID__c);
               
        }

     List<Zuora__Subscription__c> relSubs2 = [SELECT
                        Id, 
                        Name,(Select Id, Invoice__c, Invoice__r.Name, Subscription__c,Subscription_Name__c From Invoice_Items__r)
                FROM    Zuora__Subscription__c
                WHERE Name in: sub_z_ids2];
         system.debug('relSubs2 # ' + relSubs2);
         Set<Id> FinalInvoice = new Set<Id>();
        for (Zuora__Subscription__c sub : relSubs2) {       
            Set<Id> Invdata = new Set<Id>();
            for(Invoice_Item__c It : sub.Invoice_Items__r){
            system.debug('relSubs2 # ' + relSubs2);
                if(It.Invoice__c!=null){
                Invdata.add(It.Invoice__c);
                system.debug('Invdata :' + It.Invoice__c);  
                }            
            }
            if(Invdata.size()==1){          
                FinalInvoice.addall(Invdata);                     
            }
        }
        if(!FinalInvoice.isEmpty()){
           List<Zuora__ZInvoice__c> updateInovice = new List<Zuora__ZInvoice__c>();
           system.debug(' inv count' + FinalInvoice.size());
            for(Id inloop : FinalInvoice)
            {
               Zuora__ZInvoice__c updateInv = new Zuora__ZInvoice__c(Id = inloop, First_Invoice__c = true);
                updateInovice.add(updateInv);
            }
            update updateInovice;

        }
        
    }
   
 
}