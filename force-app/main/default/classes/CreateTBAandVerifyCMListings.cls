global class CreateTBAandVerifyCMListings {
    @invocablemethod(label='Verifies Campaing Manager CLC' description='Create TBA record if CM CLC is Zero')
    public static void CreateTBAandVerifyCMListings(list<Time_Based_Actions__c > TBA){
        Set<Id> TBAIds = New Set<Id>(); 
        For (Time_Based_Actions__c TBAloop : TBA){
             TBAIds.add(TBAloop.id);
        }
        system.debug('-----tBAIds---'+TBAIds);
        If(!TBAIds.isEmpty()){
           createOpportunityandQuote(TBAIds);
        }
    }

    public static void createOpportunityandQuote(set<id> TBAIds){
        
        list<string> accountIdList = new list<string>();      
        for (Time_Based_Actions__c TBAloop : [	select 	Asset__r.AccountId, Action__c
	                                          	from 	Time_Based_Actions__c 
	                                          	Where 	
	                                          			Id IN :TBAIds
	                                          			AND
	                                          			asset__c != null
	                                          			AND
	                                          			asset__r.AccountId != null ]){
            
                if(TBAloop.Action__c == 'Send Cancellation Email'){
                    accountIdList.add( TBAloop.Asset__r.AccountId );
                }
        }
        
        map<string,opportunity> accountIdToOpportunity = new map<string,opportunity>();
        map<string,string> accountIdToOpportunityId = new map<string,string>();
        if( accountIdList != null && accountIdList.size() > 0 ){
	        accountIdToOpportunity = TurboUtilityClass.createOpportunities( accountIdList, 'CLC = 0');
	        
	        for( string accountId : accountIdToOpportunity.keySet() ){
	        	accountIdToOpportunityId.put(accountId, accountIdToOpportunity.get(accountId).Id  );
	        }
        }
        CallInventoryAndCreateQuote( TBAIds,accountIdToOpportunityId);
    }  
    
     @future(callout = true)
    public static void CallInventoryAndCreateQuote(set<id> TBAIds,map<string,string> accIdToOppId){
        Integer CLCcount = 0;
        
        List<Asset> assetUpdate 			  						= New List<Asset>();
        map<string,list<Asset>> accountIdToAssetListMapForQuote 	= new map<string,list<Asset>>();
        
        List<Time_Based_Actions__c> TBAInsert = New List<Time_Based_Actions__c>();
        List<Time_Based_Actions__c> TBADelete = New List<Time_Based_Actions__c>();

        list<Time_Based_Actions__c> TBA = [	select 	Name,
        											City__c,
        											County__c,
        											State__c,
        											Country__c,
        											Zip__c,
        											Asset__c,
        											Asset__r.AccountId,
        											PartyId__c,
        											CampaignID__c,
        											Action__c,
        											Account_Listings_Summary__c
                                          	from Time_Based_Actions__c 
                                          	Where 	
                                          			Id IN :TBAIds
                                          			AND
                                          			asset__c != null
                                          			AND
                                          			asset__r.AccountId != null];          
        For (Time_Based_Actions__c TBAloop : TBA){
            
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            String EndpintURL = Waitlist_Urls__c.getInstance('CheckCLC').URL__c;
            
            EndpintURL = EndpintURL + '/country/'+ EncodingUtil.urlEncode(TBAloop.Country__c,'UTF-8'); 
            EndpintURL = EndpintURL + '/states/' + EncodingUtil.urlEncode(TBAloop.State__c,'UTF-8');
            EndpintURL = EndpintURL + '/counties/' + EncodingUtil.urlEncode(TBAloop.County__c,'UTF-8');
            EndpintURL = EndpintURL + '/cities/' + EncodingUtil.urlEncode(TBAloop.City__c,'UTF-8'); 
            EndpintURL = EndpintURL + '?PartyId='+ EncodingUtil.urlEncode(TBAloop.PartyId__c,'UTF-8');
            EndpintURL = EndpintURL +'&PartNumbers=Turbo&format=json'; 
            system.debug('EndpintURL:'+EndpintURL);
            req.setEndpoint(EndpintURL);
            req.setTimeout(120000);
            req.setHeader('Content-Type', 'application/json');
            Http http = new Http();
            HTTPResponse res = http.send(req);
            system.debug('res body:'+res.getBody());
            
            if( res.getStatusCode() == 200 ){
            	InventoryJSONCLCResponseParser InventoryResponse = InventoryJSONCLCResponseParser.parse(res.getBody());
	            system.debug('InventoryResponse:'+InventoryResponse);
	            
	            for(InventoryJSONCLCResponseParser.Inventoryitems Invloop : InventoryResponse.Inventoryitems){
	                if (	Invloop.market_name.split(',')[0].trim().toUpperCase() == TBAloop.City__c.toUpperCase()
	                     &&	Invloop.market_type == 'City'){
	                    CLCcount = Invloop.clc;
	                }    
	            }
            }
            
            
            if(CLCcount == 0){
                if(TBAloop.Action__c == 'Send Warning Email'){
                    Time_Based_Actions__c TBAInsert1 = new Time_Based_Actions__c(	Name          				= TBAloop.Name,
															                        City__c 					= TBAloop.City__c,
															                        County__c 					= TBAloop.County__c,
															                        State__c 					= TBAloop.State__c,
															                        Country__c 					= TBAloop.Country__c,
															                        Zip__c						= TBAloop.Zip__c,
															                        Asset__c 					= TBAloop.Asset__c,
															                        CampaignID__c 				= TBAloop.CampaignID__c,
															                        Delete_Record__c 			= False, 
															                        Account_Listings_Summary__c = TBAloop.Account_Listings_Summary__c,
															                        PartyID__c 					= TBAloop.PartyID__c,
															                        Action__c  					= 'Send Cancellation Email'); 
                    TBAInsert.add(TBAInsert1);
                    
                    //Update Asset Turbo_Actions__c to send warning email
                    Asset assetUpdate1 = New Asset( Id 					= TBAloop.Asset__c,
                    								AccountId 			= TBAloop.Asset__r.AccountId,
                                                    Turbo_Actions__c 	= 'Send Warning Email - CLC is Zero from 96 hours');
                    assetUpdate.add(assetUpdate1);
                    
                }if(TBAloop.Action__c == 'Send Cancellation Email'){
                    
                    //Update Asset Turbo_Actions__c to Cancel Campaing and send Cancellation email
                    Asset assetUpdate2 = New Asset( Id 					= TBAloop.Asset__c,
                    								AccountId 			= TBAloop.Asset__r.AccountId,
                                                    Turbo_Actions__c 	= 'Send Cancellation Email - CLC is Zero from 144 hours');
                    assetUpdate.add(assetUpdate2);
                    
                    if( !accountIdToAssetListMapForQuote.containsKey( assetUpdate2.AccountId) ){
	                    accountIdToAssetListMapForQuote.put(  assetUpdate2.AccountId, new list<Asset>());
	                }
	                accountIdToAssetListMapForQuote.get(assetUpdate2.AccountId).add( assetUpdate2 );
                }
            }else{
                //Update Asset Turbo_Actions__c to Cancel Campaing and send Cancellation email
                Asset assetUpdate2 = New Asset( Id 				= TBAloop.Asset__c,
                                               Turbo_Actions__c = 'No Action Required');
                assetUpdate.add(assetUpdate2);
            }
            
            // Delete record since it is processed and no more required
            Time_Based_Actions__c TBADelete1 = new Time_Based_Actions__c( Id = TBAloop.Id);
            TBADelete.add(TBADelete1);
        }
        
        if(	!accountIdToAssetListMapForQuote.isEmpty() ){
	        for( string accId : accountIdToAssetListMapForQuote.keySet() ){
	                TurboUtilityClass.createBigMachineQuoteForCancelAndCreditAsset( accountIdToAssetListMapForQuote.get(accId) , 
	                																accId, 
	                																accIdToOppId.get(accId));
	        }
        }
        if(assetUpdate != null && assetUpdate.size() >0){
            update assetUpdate;
        }
        
        if(TBADelete != null && TBADelete.size() >0){
            delete TBADelete;
        }
        
        If (TBAInsert != null && TBAInsert.size() >0){
            insert TBAInsert;        
        }
    }    
    
    
}