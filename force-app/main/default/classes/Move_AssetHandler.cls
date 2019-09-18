// 25th July 2015   Rajamohan Vakati        Modified  (JIRA Number ADVP-2308) - Generate BOP Code - generateBOPCode

public class Move_AssetHandler{
    public static void PaidAmountcaliculation(List<Asset> NewAssets, Boolean isUpdate){
        Date minSt  = date.newInstance(2099,1,1);
        Date maxEnd = date.newInstance(1700,1,1);

        Set<id> assetsIds= new Set<id>();
        for(Asset ast: NewAssets){
            if(ast.Start_Date__c < minSt){
                minSt = ast.Start_Date__c;
            }
            if(ast.End_Date__c > maxEnd){
                maxEnd= ast.End_Date__c ;
            }
            assetsIds.add(ast.id);
        }
        System.debug('####-Assets'+ assetsIds);

        if(!assetsIds.isEmpty()){
            map<id, decimal> paidmap= new map<id, decimal>();
            map<id, decimal> pastDueMap = new map<id, decimal>();
            //CRM-2453 Added Service start date in the query and filtered based on service start date and removed status filter due to some having null values.
            for(Invoice_Item__c it: [SELECT id,Name, Asset__c,  Asset__r.Asset_Type__c, Charge_Date__c, Charge_Amount__c, Invoice__c,
                                     Invoice__r.Invoice_Status__c, Invoice__r.Zuora__Balance2__c,Service_Start_Date__c FROM Invoice_Item__c
                                     WHERE Asset__c IN:assetsIds AND Service_Start_Date__c >=: minSt AND Service_Start_Date__c <=: maxEnd ]){
                                         System.debug('@@@@-Items'+ it.name);
                                         //For paid and Zero Balance.
                                         //CRM-2453-- removed status filter due to some having null values
                                         if(it.Invoice__r.Zuora__Balance2__c == 0.00){
                                             decimal ChargeCal =0.00;
                                             system.debug('test1'+paidmap.containsKey(it.Asset__c));
                                             if(paidmap.containsKey(it.Asset__c)){
                                                 ChargeCal =  paidmap.get(it.Asset__c);
                                             }else{
                                                 ChargeCal =0.00;
                                             }
                                             ChargeCal += it.Charge_Amount__c;
                                             paidmap.put(it.Asset__c, ChargeCal);
                                         }
                                         //For Past Due and Balance.
                                         if(it.Invoice__r.Invoice_Status__c == 'Past Due' && it.Invoice__r.Zuora__Balance2__c > 0.00 ){
                                             decimal ChargeCalDue =0.00;
                                             system.debug('test1'+pastDueMap.containsKey(it.Asset__c));
                                             if(pastDueMap.containsKey(it.Asset__c)){
                                                 ChargeCalDue =  pastDueMap.get(it.Asset__c);
                                             }else{
                                                 ChargeCalDue =0.00;
                                             }
                                             ChargeCalDue += it.Charge_Amount__c;
                                             pastDueMap.put(it.Asset__c, ChargeCalDue);
                                         }

                                     }
            System.debug('@@@@-Amount==========>'+paidmap);
            System.debug('@@@@-Amount==========>'+pastDueMap);

            for(Asset ast : NewAssets){
                System.debug('@@@@-Amount==========>'+paidmap.containskey(ast.id));
                System.debug('@@@@-Amount==========>'+ ast.Asset_Type__c );
                if((paidmap.containskey(ast.id) || pastDueMap.containskey(ast.id)) && ast.Asset_Type__c == 'Parent'){
                    ast.Paid_Amount__c = paidmap.get(ast.id);
                    ast.Past_Due_Amount__c = pastDueMap.get(ast.id);
                    System.debug('@@@@-Amount==========>'+ ast.Past_Due_Amount__c);
                }
            }
        }
    }


    // Added by Rajamohan Vakati -- Start -- JIRA Story -ADVP-2308
    /*
@method      : generateBOPCOde()
@description : Update the BOP Code with the Auto Number .
@params      : List of  Asset records
@returns     : Void
*/

    public static void generateBOPCode(Map<Id ,Asset> newAssetMap){
        List<Asset> assettobeUpdated = new List<Asset>();
        Set<Id> recods = newAssetMap.keySet();
        String conditionalValuesToDisplay = System.Label.BOP_Code_Array ;
        List<String> lstString = conditionalValuesToDisplay.split(',');
        Set<String> uniqueValues = new Set<String>();
        uniqueValues.addAll(lstString);

        Asset assetCount = [Select Id ,Asset_id__c, Asset.AccountId from Asset order by CreatedDate desc limit 1] ;
                                   String autoNumberVal = assetCount.Asset_Id__c.replace('A-','') ;
                                   Integer val = integer.valueOf(autoNumberVal);
		// Commented for CRM-830 , SOQL inside for loop 
        /*for(Asset  a :[Select Id , Name,product2.productcode ,Asset.AccountId,
                       OwnerId,DecommissionedAsset__c,
                       DecommissionedAsset__r.BOP_Code__c,Asset_id__c from Asset where id in:recods] ){
                           if(uniqueValues.contains(a.product2.productcode)){
                               List<Asset> existingBOPCodeCheck  =[Select Id ,Asset.AccountId,BOP_Code__c from Asset
                                                                   where OwnerId=:a.OwnerId
                                                                   AND  product2.productcode IN:lstString
                                                                   AND  AccountId = :a.AccountId Limit 1];
                               if(a.DecommissionedAsset__c !=null){
                                   a.BOP_Code__c = a.DecommissionedAsset__r.BOP_Code__c ;
                               }else if(existingBOPCodeCheck.size()>1){
                                   a.BOP_Code__c = existingBOPCodeCheck[0].BOP_Code__c;
                               }
                               else{
                                   a.BOP_Code__c = String.valueOf(val);
                                   val= val+1 ;
                               }

                           }
                           assettobeUpdated.add(a);
                       }*/
		// Added for CRM-830 to take SOQL out of for loop
		Set<id> ownerIds = new Set<id>();
		Set<id> accIds = new Set<id>();
		List<Asset> assets = [Select Id , Name,product2.productcode ,Asset.AccountId,OwnerId,DecommissionedAsset__c,
								DecommissionedAsset__r.BOP_Code__c,Asset_id__c from Asset where id in:recods];
		for (Asset a : assets) {
			ownerIds.add(a.OwnerId);
			accIds.add(a.AccountId);
		}
		Map<String, String> bpoCodes = new Map<String, String>();
		for (Asset a : [Select Id ,OwnerId, AccountId, BOP_Code__c from Asset where OwnerId in :ownerIds
                                            AND  product2.productcode IN:lstString AND  AccountId in :accIds limit 100]) {
                                            	
        	bpoCodes.put('' + a.OwnerId + a.AccountId, a.BOP_Code__c);                                    	
        }
        
        for (Asset a : assets) {
        	if(uniqueValues.contains(a.product2.productcode)){
				if (a.DecommissionedAsset__c !=null) {
	            	a.BOP_Code__c = a.DecommissionedAsset__r.BOP_Code__c ;
	            }
	            else {
	            	String code = bpoCodes.get(''+a.OwnerId + a.AccountId);
	            	if (code != null) {
	            		a.BOP_Code__c = code;
	            	}
	            	else {
		                a.BOP_Code__c = String.valueOf(val);
		                val= val+1 ;
	                }
	            }
	            
	            assettobeUpdated.add(a);
        	}
		}
		
        update assettobeUpdated;
    }

    @future
    Public static void UpdateParentAssetCampaignId(Set<Id> setAssetIds){
    List<Asset> lstFulfilltoAssets = [Select Id,CampaignID__c,parent_asset__c from Asset where id=:setAssetIds and asset_type__c='Fulfill to'];
    List<Asset> lstParentAssets = new List<Asset>();
    for(Asset ast:lstFulfilltoAssets){
    Asset astt = new Asset(Id=ast.parent_asset__c,CampaignID__c=ast.CampaignID__c);
lstParentAssets.add(astt);
    }
    if(lstParentAssets.size()>0){
    	Update lstParentAssets;
    }
    }


    // End -- by Rajamohan Vakati -- Start -- JIRA Story -ADVP-2308

   // public static void updateWaitListPrice(List<asset> asst){
       /*
        for(asset a :asst){
            if(a.WaitlistItem__c!=null){
                if(a.Total_List_Price__c!=null){
            			 a.WaitlistItem__r.Current_Utilized_Spend__c =   a.WaitlistItem__r.Current_Utilized_Spend__c+a.Total_List_Price__c ;
                         update a.WaitlistItem__r ;
                }
            }

        }



        for(asset a : asst){
            System.debug('Going === >>'+a.Order_Line_Item__c);
             System.debug('a.Order_Line_Item__r'+a.Order_Line_Item__r.Id);
            System.debug('a.Order_Line_Item__r.Order '+a.Order_Line_Item__r.Order.Id);
            OrderItem ol = [Select id, OrderItemNumber , OrderId  from OrderItem where id=:a.Order_Line_Item__c];
               System.debug('ololol'+ol.OrderId);
            Order  ord =[Select Id from Order  where id=:ol.Id];


            If(a.Order_Line_Item__r.Order.Oracle_Quote__r !=null){
               System.debug('a.Order_Line_Item__r.Orders.Oracle_Quote__r'+a.Order_Line_Item__r.Order.Oracle_Quote__r);

              //  List<Waitlist_Item__c> wItems = [Select Id , Name from Waitlist_Item__c where Quote__c =:a.Order_Line_Item__r.Order.Oracle_Quote__r];


            }



        }

      */
   // }



}