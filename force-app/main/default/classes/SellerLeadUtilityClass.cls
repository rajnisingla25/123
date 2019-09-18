global class SellerLeadUtilityClass {
	
	//datetime format to send to SOA
	public static final string sellerLeadProductCode 					= 'SELLERLEADBUNDLE';
	public static final string assetTypeFulfillTo 						= 'Fulfill To';
	public static final string lineTypeCredit 							= 'Credit';
	public static final string pendingfulfillmentStatus					= 'Pending Fulfillment';
	public static final string soaEndPointForAggrLead			 		= SOAEndPoint__c.getInstance('AggregateLeads') != null ? SOAEndPoint__c.getInstance('AggregateLeads').EndPoint__c:'';
	
	webservice static string WebService_GetDeliveredLead( Id assetId ) {
	
		list<AssetIdToAggrLeadsResponseClass> response = new list<AssetIdToAggrLeadsResponseClass>();
		integer leadsRemaining;
	 
		list<Asset> astList = 	[	SELECT 	Asset_ID_18_Digit__c,
											Start_Date__c,
											End_Date__c, 
											Asset_Type__c,
											(	select 	Asset_ID_18_Digit__c,
														Start_Date__c,
														End_Date__c, 
														Asset_Type__c
												from Assets__r 
												limit 1)
									FROM 	Asset 
									WHERE 	Id =:assetId
									limit: 	1];
									
		if( astList != null && astList.size() > 0  ){
			if( TurboUtilityClass.assetTypeParent.equalsIgnoreCase(astList[0].Asset_Type__c) ){
				if( astList[0].Assets__r != null && astList[0].Assets__r.size() > 0 ){
					astList = astList[0].Assets__r;
				} 
			}
			response = getDeliveredLeads( astList , assetTypeFulfillTo );
		} 
		
		if( response != null  && response.size() == 1 && response[0].totalLeads != null ){
			return ('Total Leads Delivered = ' + response[0].totalLeads);
		}else{
			return ' Something went wrong. Please contact system adminstrator.';
		}
	}
	
	//This method will take assetList and then send it to BI via SOA to get the delivered Leads 
	// It will return a response received from SOA i.e FulfillToAssetId and its delivered Leads
	public static list<AssetIdToAggrLeadsResponseClass> getDeliveredLeads( list<Asset> assetList, string assettype){
		
		list<AssetIdToAggrLeadsResponseClass> assetIdToAggrLeadsResponseList = new list<AssetIdToAggrLeadsResponseClass>(); 
		
		try{
			if( assetList != null && assetList.size() > 0 ){
				
				list<SOA_GetAggregateLeads.GetSellerLeads_element> requestVariableList = new list<SOA_GetAggregateLeads.GetSellerLeads_element>();
				SOA_GetAggregateLeads.GetSellerLeads_element requestVariable = new SOA_GetAggregateLeads.GetSellerLeads_element();
				
				for( Asset ast : assetList){
					if( assettype == assetTypeFulfillTo){
							requestVariable.FulfillToAssetId 	= ast.Asset_ID_18_Digit__c;
					}else{
							requestVariable.FulfillToAssetId 	= ast.Assets__r[0].Asset_ID_18_Digit__c;
					}
					
					requestVariable.StartDateOfTerm 	= dateTime.newInstance(ast.Start_Date__c, Time.newInstance(00, 00, 00, 00)).format( TurboUtilityClass.dateTimeFormat );
					requestVariable.EndDate 	= dateTime.newInstance(ast.End_Date__c+1, Time.newInstance(00, 00, 00, 00)).format( TurboUtilityClass.dateTimeFormat );
					requestVariable.Source = 'SFDC';
					requestVariableList.add( requestVariable );
					requestVariable = new SOA_GetAggregateLeads.GetSellerLeads_element();
				}
				
				if( requestVariableList != null && requestVariableList.size() > 0 ){
					
					SOA_GetAggregateLeads.GetAggregateSellerLeadsAmazon_pt callBIViaSoa = new SOA_GetAggregateLeads.GetAggregateSellerLeadsAmazon_pt();
					
					list<SOA_GetAggregateLeads.GetSellerRecordResponse_element> responseFromSOaList = callBIViaSoa.process( requestVariableList );
					
					for( SOA_GetAggregateLeads.GetSellerRecordResponse_element responseFromSOa : responseFromSOaList){
						assetIdToAggrLeadsResponseList.add( new AssetIdToAggrLeadsResponseClass( responseFromSOa.FulfillToAssetId ,responseFromSOa.totalLeads));
						
					}
				}
				
			}//End If
		}catch( Exception e){
			system.debug('Exception occured while getting Leads: '+e.getStackTraceString());
			string failedAssetIds = '';
			for( Asset ast : assetList){
					failedAssetIds += ast.Id+', ';
			}
			TurboUtilityClass.saveException(  e,failedAssetIds,'SellerLeadUtilityClass.getDeliveredLeads','');
		}
		return assetIdToAggrLeadsResponseList; 
	}
	
	public static void createNoteForDeltaAmount( list<AssetDeltaAmountInformation> assetDeltaAmountInformationList ){
		
		list<Note> noteList = new list<Note>();
		try{
			
			for( AssetDeltaAmountInformation adal : assetDeltaAmountInformationList){
				Note noteInstance = new Note();
				noteInstance.Title = 'Credit amount $'+ adal.deltaAmount.format() + ' for SellerLeadBundle';
				noteInstance.ParentId = adal.parentId;
				noteInstance.Body = 'Delta amount of $'+ adal.deltaAmount.format() + ' on '+ DateTime.Now().format() + ' has been populated on asset based on actual lead delivered.Below are the details\n';
				noteInstance.Body += 'Forecasted Lead = '+ adal.forecastedLeads +'\n';
				noteInstance.Body += 'Lead Delivered = '+ adal.totalLeads +'\n';
				noteInstance.Body += 'CPL (cost per lead) = $'+ adal.cpl.format() +'\n';
				noteInstance.Body += 'Delta Amount ( (Lead Delivered - forecasted Leads ) * CPL ) = $' + adal.deltaAmount.format()  + ' ( ( ' + adal.totalLeads +' - ' + adal.forecastedLeads + ') '+ ' * ' + adal.cpl.format()+' )';
				
				noteList.add( noteInstance );
			}
			
			
			if( noteList != null && noteList.size() > 0 ){
				insert noteList;
			}
		}catch( exception e){
			system.debug('exception while creating notes-- '+ e.getStackTraceString() );
			TurboUtilityClass.saveException(  e,'','SellerLeadUtilityClass.createNoteForDeltaAmount',null);
		}
		
		
	}
	
	public static map<string,list<Asset>> populateDeltaAmountOnAsset_BatchMethod( 	list<Asset> eligibleAssetList ){
		
		map<string,list<Asset>> reason_assetNotProcessed 		= new map<string,list<Asset>>();
		map<string,Asset> fulfillAssetIdToParentAssetMap      	= new map<string,Asset>();
		list<Asset> assetsToUpdate          					= new list<Asset>();
        list<list<Asset>> assetChunkList            			= new list<list<Asset>>();
        list<Asset> assetChunk                      			= new list<Asset>();
		integer totalAssetCount                     	 		= 0;
		string batchName 										= 'PopulateDeltaAmountOnAsset_Batch';
		list<SellerLeadUtilityClass.AssetIdToAggrLeadsResponseClass> resopnseFromSOAList 
																= new list<SellerLeadUtilityClass.AssetIdToAggrLeadsResponseClass>();
		 
 		list<AssetDeltaAmountInformation> assetDeltaAmountInfoList = new list<AssetDeltaAmountInformation>();
 		try{
        	
	        for( Asset ast : eligibleAssetList){
	        	
                if( ast.Assets__r != null && ast.Assets__r.size() > 0  ){
	                
	                totalAssetCount += 1;
	                assetChunk.add(ast);
	                if( totalAssetCount == TurboUtilityClass.assetCountForSOA){
	                    assetChunkList.add( assetChunk );
	                    assetChunk = new list<Asset>();
	                    totalAssetCount = 0;
	                }               
	                fulfillAssetIdToParentAssetMap.put( ast.Assets__r[0].Asset_ID_18_Digit__c , ast);
                }
	        }
	        
	        if( assetChunk != null && assetChunk.size() > 0 ){
	            assetChunkList.add( assetChunk );
	        }
	        if( !fulfillAssetIdToParentAssetMap.isEmpty() ){
	            
	            for( list<Asset> astList : assetChunkList ){
	                   resopnseFromSOAList.addAll( SellerLeadUtilityClass.getDeliveredLeads( astList , ''));
	            }                         
	            if( resopnseFromSOAList != null && resopnseFromSOAList.size() > 0 ){
	            	
		            for( SellerLeadUtilityClass.AssetIdToAggrLeadsResponseClass soaResponse : resopnseFromSOAList ){
		                if( fulfillAssetIdToParentAssetMap.containsKey( soaResponse.FulfillToAssetId )){
		                    
		                    
		                    Asset assetInScope = fulfillAssetIdToParentAssetMap.get( soaResponse.FulfillToAssetId );
		                    
		                    if( (assetInScope.Contractedimpressions__c - soaResponse.totalLeads) != 0 ){
		                       
		                        if( assetInScope.Renewal_Start_Date__c != null && assetInScope.Renewal_Order_Product__c != null 
		                        										&& assetInScope.Renewal_Order_Product__r.Line_Type__c == 'Renew' ){
			                        //For renwal asset
			                        assetInScope.Credit_Status__c 						= 	TurboUtilityClass.creditInProgressStatus;
			                        assetInScope.Line_Type__c	  						= 	lineTypeCredit;
			                        assetInScope.Order_Line_Item__c	  					= 	null;
			                        assetInScope.Fulfillment_Status__c 					= 	pendingfulfillmentStatus;
			                        assetInScope.Total_Net__c 							=  	soaResponse.totalLeads * assetInScope.PricePerImpressionSold__c;
			                        assetInScope.Record_Processed_for_commission__c 	= false;
			                        assetInScope.Commissions_are_calculated__c 			= false;
			                        Asset fulfillToAsset = new Asset(Id				=	soaResponse.FulfillToAssetId,
			                        								 Line_Type__c	= lineTypeCredit,
			                        								 Fulfillment_Status__c 	= pendingfulfillmentStatus);
			                        assetsToUpdate.add( fulfillToAsset );
			                    }else{
		                        	//For expired asset
		                        	assetInScope.Credit_Status__c 		= TurboUtilityClass.creditProcessedStatus;
		                        }
		                        
		                        assetInScope.Delta_Price__c		 	= ( soaResponse.totalLeads - assetInScope.Contractedimpressions__c ) * assetInScope.PricePerImpressionSold__c;
			                    assetInScope.Delta_Price_w_o_Tax__c	= assetInScope.Delta_Price__c;
			                    
			                    AssetDeltaAmountInformation assetDeltaAmountInfo = new AssetDeltaAmountInformation();
			                    
			                    assetDeltaAmountInfo.parentId = assetInScope.id;
			                    assetDeltaAmountInfo.totalLeads = soaResponse.totalLeads;
			                    assetDeltaAmountInfo.forecastedLeads = integer.valueOf( assetInScope.Contractedimpressions__c );
			                    assetDeltaAmountInfo.deltaAmount = assetInScope.Delta_Price__c;
			                    assetDeltaAmountInfo.cpl = assetInScope.PricePerImpressionSold__c;
			                    
			                    assetDeltaAmountInfoList.add( assetDeltaAmountInfo );
		                        
		                    }else{
		                        assetInScope.Credit_Status__c = TurboUtilityClass.creditNotRequiredStatus;
		                    }
		                	assetsToUpdate.add( assetInScope );
		                }// end if - FulfillToAssetId map check 
		            }//end for
		           
		            if( assetsToUpdate != null && assetsToUpdate.size() > 0 ){
	                    update assetsToUpdate;
	                    
	                    if( assetDeltaAmountInfoList != null && assetDeltaAmountInfoList.size() > 0 ){
	                    	createNoteForDeltaAmount( assetDeltaAmountInfoList );
	                    }
	                    
	                }
		            
	           }else{
	           		
	           		string failedAssetIds = '';
	           		for( Asset ast : eligibleAssetList){
							failedAssetIds += ast.Id+', ';
							ast.Credit_Status__c = TurboUtilityClass.creditFailedStatus;
					}
					
					reason_assetNotProcessed.put('Failed to get delivered lead response from SOA',eligibleAssetList);
					update eligibleAssetList;
	           		
	           		//No response came from SOA
	           		TurboUtilityClass.saveManualException( 'No Response from SOA hence wont populate delta on Assets',failedAssetIds,batchName,null);
	           }
	        }// End map empty check
    	}catch( Exception e ){
	       	string failedAssetIds = '';
	       	for( Asset ast : eligibleAssetList){
					failedAssetIds += ast.Id+', ';
					ast.Credit_Status__c = TurboUtilityClass.creditFailedStatus;
			}
			reason_assetNotProcessed.put('Exception Occured in '+batchName,eligibleAssetList);
			update eligibleAssetList;
       	 	TurboUtilityClass.saveException(  e,failedAssetIds,batchName,null);
	       	 
	        system.debug('Exception in '+batchName+'-----------'+e.getStackTraceString());
       }
	       
       return reason_assetNotProcessed;
	}
	
	 public static void sendEmailNotificationForDeltaAssetAmountFailure( string emailBody, string subject, list<string> groupDeveloperNameList ){
    	set<id> groupIds = new set<id>();
    	set<id> userIds  = new set<id>();
    	list<String> notificationUserEmailIds = new List<String>();
    	List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
    	
        if( !string.isBlank( emailBody ) ){
	        
	        list<Group>	 notificationGroup = [	select 	Id
												from	Group
												where	DeveloperName in :groupDeveloperNameList
												limit	:Limits.getLimitQueryRows() - Limits.getqueryRows() ];
												
			for( Group grp:  [	select 	Id
								from	Group
								where	DeveloperName in :groupDeveloperNameList
								limit	:Limits.getLimitQueryRows() - Limits.getqueryRows() ]){
					groupIds.add( grp.Id);
			
			}
			if( !groupIds.isEmpty() ){
				userIds = TurboUtilityClass.GetUserIdsFromGroup_Bulkified( groupIds );
			}
			
			if( !userIds.isEmpty() ){
				
				for( User u :[	select	Email
								from 	User
								where	Id IN :userIds
								limit	:Limits.getLimitQueryRows() - Limits.getqueryRows() ] ) {
					notificationUserEmailIds.add( u.Email );	
				}
				
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
	            /*If toAddresses has a value :
	            	1. get email subject
	            	2. get email body
	            	3. get email attachments
	            	
	            */
	            if( notificationUserEmailIds.size() > 0 ) {
		            mail.setToAddresses( notificationUserEmailIds ); 
		            mail.setSubject( subject );
		            mail.setBccSender( false );
		            mail.setHtmlBody( emailBody );            
		            
		            emailList.add( mail );
	            }
			}	
			//Send the email notifications
			if( emailList.size() > 0 && !Test.isRunningTest() ) {
				List<Messaging.SendEmailResult> results = Messaging.sendEmail( emailList );
			}
			
        }
    }
    
    public static string createEmailBodyForDeltaAssetAmountFailureNotification( map<string,list<Asset>> reason_assetNotProcessed ){
    	
    	String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
    	String emailBody = '';
		emailBody = '<html>'
    				+	'<head>'
    				+		'<style type="text/css" media="print">'
    				+			'* { font-family: Sans-serif;color: #222222;font-size:95%;}'
    				+			'body, td {font-family: Sans-serif;font-size:95%; }'
    				+		'</style>'
    				+	'</head>'
					+ 	'<body style="width:96%;font-size:95%;font-family: Sans-serif;margin-left:1%;margin-right:1%;color: #222222;">'
					+ 		'Hello, <br/><br/>'
					+ 		'We tried to populate delta amount for assets however some of them has been failed. Please find the details below:   <br/><br/><br/>';
					
		emailBody += '<table style="border:1px solid #888888;border-collapse:collapse;">';
			emailBody += '<tr>';
				emailBody += '<td style="border:1px solid #888888;border-collapse:collapse;">Asset Name</td>';
				emailBody += '<td style="border:1px solid #888888;border-collapse:collapse;">Failure Reason</td>';
			emailBody += '</tr>';
			
			for( string reason : reason_assetNotProcessed.keySet()){
				for( Asset ast : reason_assetNotProcessed.get(reason)){
					
					emailBody += '<tr>';
						emailBody += '<td style="border:1px solid #888888;border-collapse:collapse;">';
							emailBody +=  '<a href="'+ baseURL + '/' + ast.Id +'">'+ ast.Name +'</a>'; 
						emailBody += '</td>';
						emailBody += '<td style="border:1px solid #888888;border-collapse:collapse;">';
							emailBody += '<p>'+reason+'</p>';
						emailBody += '</td>';
						
					emailBody += '</tr>';
				}
			}
		emailBody += '</table>';			
			emailBody	+= '<br/>';
			
			emailBody	+=	'</body>'
						+ '</html>'; 
		
		return emailBody;
    }
    
    
	//This class will be used to clubbed AssetId with Leads
	public class AssetIdToAggrLeadsResponseClass{
		public string		fulfillToAssetId {get;set;}
		public integer 		totalLeads {get;set;}
		
		
		public AssetIdToAggrLeadsResponseClass( string fulfillToAssetId, integer totalLeads ){
			this.FulfillToAssetId 			= fulfillToAssetId;
			this.totalLeads 			= totalLeads;
		}
		public AssetIdToAggrLeadsResponseClass( ){}
	} 
	
	public class AssetDeltaAmountInformation{
		public string		parentId {get;set;}
		public integer 		totalLeads {get;set;}
		public integer 		forecastedLeads {get;set;}
		public decimal 		deltaAmount {get;set;}
		public decimal 		cpl {get;set;}
		
		public AssetDeltaAmountInformation( ){}
	}
	
}