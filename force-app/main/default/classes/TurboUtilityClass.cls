global class TurboUtilityClass {

	//datetime format to send to SOA
	public static final string dateTimeFormat  					= 'yyyy-MM-dd HH:mm:ss.S';
	//datetime format to send to SOA
	public static final string turboProductCode 				= 'TURBO';

	//datetime format to send to SOA
	public static final string assetStatusActive 						= 'Active';
	public static final string assetStatusExpired 						= 'Expired';
	public static final string assetTypeParent 							= 'Parent';
	public static final string creditNotRequiredStatus 					= 'Not Required';
	public static final string creditProcessedStatus 					= 'Processed';
	public static final string creditInProgressStatus 					= 'In Progress';
	public static final string creditFailedStatus 						= 'Failed';
	public static final string fulfilledStatus 							= 'Fulfilled';
	public static final string cancelEmailForImpressionActionValue 		= System.Label.Turbo_Cancel_Notification_String;
	public static final string cancelEmailForCLCZeroActionValue 		= 'Send Cancellation Email - CLC is Zero from 144 hours';
	public static final string warningEmailForCLCZeroActionValue 		= 'Send Warning Email - CLC is Zero from 96 hours';
	public static final string noActionRequired					 		= 'No Action Required';

	public static final string renewCredit					 			= 'RenewCredit';
	public static final string expiryCredit					 			= 'ExpiryCredit';

	public static integer assetCountForSOA								= 5;

	public static final string soaEndPointForAggrImpr			 		= SOAEndPoint__c.getInstance('AggregateImpression') != null ? SOAEndPoint__c.getInstance('AggregateImpression').EndPoint__c:'';


	webservice static string WebService_updateAssetWithDeliveredImpression( Id assetId ) {
		list<CampaignToImpressionResponseClass> response = new list<CampaignToImpressionResponseClass>();
		integer impressionsRemining;
		list<Asset> astList = 	[	SELECT 	Id,
											Product2.ProductCode,
											CampaignID__c,
											Start_Date__c,
											End_Date__c,
											Deliveredimpressions__c,
											DeliveredImpressionsUpdatedDate__c,
											ContractedImpressions__c
									FROM 	Asset
									WHERE 	Id =:assetId
									limit: 	1];
		if( astList != null && astList.size() > 0  ){
			response = getDeliveredImpressions( astList );
		}
		if( response != null  && response.size() == 1 && response[0].deliveredImpression != null ){
			impressionsRemining = integer.valueOf(astList[0].ContractedImpressions__c) - response[0].deliveredImpression;
			if( impressionsRemining < 0 ){
				impressionsRemining = 0;
			}
			return ('Impressions Delivered = ' + response[0].deliveredImpression + '\nImpressions Remaining = '+impressionsRemining );
		}else{
			return ' Something went wrong. Please contact system adminstrator.';
		}
	}

	//This method will take campaign id, startdate & enddate and then send it to BI via SOA to get the delivered impression
	// It will return a response received from SOA i.e campaignid and its delivered impression
	public static list<CampaignToImpressionResponseClass> getDeliveredImpressions( list<Asset> assetList){

		list<CampaignToImpressionResponseClass> CampaignToImpressionResponseList = new list<CampaignToImpressionResponseClass>();
		try{
			if( assetList != null && assetList.size() > 0 ){

				list<SOA_GetAggregateImpressions.CampaignRecord_element> requestVariableList = new list<SOA_GetAggregateImpressions.CampaignRecord_element>();
				SOA_GetAggregateImpressions.CampaignRecord_element requestVariable = new SOA_GetAggregateImpressions.CampaignRecord_element();

				for( Asset ast : assetList){
					requestVariable.CampaignId 	= ast.CampaignID__c;
					requestVariable.StartDate 	= dateTime.newInstance(ast.Start_Date__c, Time.newInstance(00, 00, 00, 00)).format( dateTimeFormat );
					requestVariable.EndDate 	= dateTime.newInstance(ast.End_Date__c+1, Time.newInstance(00, 00, 00, 00)).format( dateTimeFormat );

					requestVariableList.add( requestVariable );
					requestVariable = new SOA_GetAggregateImpressions.CampaignRecord_element();
				}

				if( requestVariableList != null && requestVariableList.size() > 0 ){

                    Integer requesttimeoutsetting = 60000;
                    Schedule_Batch_Setting__c timeset= Schedule_Batch_Setting__c.getValues('Turbo Request Timeout');
                  if(timeset!=null){
                   requesttimeoutsetting=Integer.valueof(timeset.Execution_Time_hr__c+'');
                  }
					SOA_GetAggregateImpressions.GetAggregateImpressionsAmazonService_pt callBIViaSoa = new SOA_GetAggregateImpressions.GetAggregateImpressionsAmazonService_pt();

					callBIViaSoa.timeout_x = requesttimeoutsetting;
					list<SOA_GetAggregateImpressions.ImpressionRecord_element> responseFromSOaList = callBIViaSoa.process( requestVariableList );

					for( SOA_GetAggregateImpressions.ImpressionRecord_element responseFromSOa : responseFromSOaList){
						CampaignToImpressionResponseList.add( new CampaignToImpressionResponseClass( responseFromSOa.CampaignId ,integer.valueOf( responseFromSOa.Impressions)));

					}
				}

			}//End If
		}catch( Exception e){
			system.debug('Exception occured while getting impression: '+e.getStackTraceString());
			string failedAssetIds = '';
			for( Asset ast : assetList){
					failedAssetIds += ast.Id+', ';
			}
			saveException(  e,failedAssetIds,'TurboUtilityClass.getDeliveredImpressions','');
		}
		return CampaignToImpressionResponseList;
	}


	//This method will take campaign id, startdate & enddate and then send it to BI via SOA to get the delivered impression
	// It will return a response received from SOA i.e campaignid and its delivered impression
	public static list<CampaignToImpressionResponseClass> getDeliveredImpressionsForReport( string assetId, Date startdate, Date endDate ){

		list<CampaignToImpressionResponseClass> CampaignToImpressionResponseList = new list<CampaignToImpressionResponseClass>();

		try{
		if( assetId != null  ){

			Asset  ast = [ select campaignId__c,Start_Date__c, End_Date__c from Asset where Id = :assetId limit 1];


			if( ast.CampaignID__c != null ){

				list<SOA_GetAggregateImpressions.CampaignRecord_element> requestVariableList = new list<SOA_GetAggregateImpressions.CampaignRecord_element>();
				SOA_GetAggregateImpressions.CampaignRecord_element requestVariable = new SOA_GetAggregateImpressions.CampaignRecord_element();

				requestVariable.CampaignId 	= ast.CampaignID__c;
				requestVariable.StartDate 	= dateTime.newInstance( startdate, Time.newInstance(00, 00, 00, 00)).format( dateTimeFormat );
				requestVariable.EndDate 	= dateTime.newInstance( endDate, Time.newInstance(00, 00, 00, 00)).format( dateTimeFormat );
				requestVariable.Usage		= 'Report';
				requestVariableList.add( requestVariable );

				SOA_GetAggregateImpressions.GetAggregateImpressionsAmazonService_pt callBIViaSoa = new SOA_GetAggregateImpressions.GetAggregateImpressionsAmazonService_pt();

				list<SOA_GetAggregateImpressions.ImpressionRecord_element> responseFromSOaList = callBIViaSoa.process( requestVariableList );

				CampaignToImpressionResponseClass tempRes = new CampaignToImpressionResponseClass();

				for( SOA_GetAggregateImpressions.ImpressionRecord_element responseFromSOa : responseFromSOaList){

					tempRes.campaignId 					= responseFromSOa.CampaignId;
					tempRes.deliveredImpression 		= responseFromSOa.Impressions;
					tempRes.count 						= responseFromSOa.count;
					tempRes.eventDate 					= responseFromSOa.eventDate;

					CampaignToImpressionResponseList.add( tempRes );
					tempRes = new CampaignToImpressionResponseClass();

				}
			}

		}//End If
		}catch( Exception e){
			system.debug('Exception occured while getting impression: '+e.getStackTraceString());
		}
		return CampaignToImpressionResponseList;
	}

	public static list<Asset> createBigMachineQuoteForProcessCredit( list<Asset> assetList, string accountId, string oppId ){

		boolean isError = false;
		list<Asset> failedAssetList = new list<Asset>();

		if( assetList != null && assetList.size() > 0 ){

			try{
				autoCreateBigMachineQuote( assetList, accountId, oppId ,'Auto-Credit', 'credit');

			}catch( Exception e){

				isError = true;
				string failedAssetIds = '';
           		for( Asset ast : assetList){
						failedAssetIds += ast.Id+', ';
						ast.Credit_Status__c = TurboUtilityClass.creditFailedStatus;
				}
				update assetList;
				saveException(  e,failedAssetIds,'TurboUtilityClass.createBigMachineQuoteForProcessCredit',accountId);
				failedAssetList = assetList;
			}

			if( !isError ){
				for( Asset ast : assetList ){
					ast.Credit_Status__c = creditInProgressStatus;
				}

				update assetList;

			}
		}
		return failedAssetList;
	}

	public static void createBigMachineQuoteForCancelAndCreditAsset( list<Asset> assetList, string accountId, string oppId ){

		if( assetList != null && assetList.size() > 0 ){
			autoCreateBigMachineQuote( assetList, accountId, oppId ,'Modify', 'cancel');
		}
	}

	private static void autoCreateBigMachineQuote( list<Asset> assetList, string accountId, string oppId ,string quoteType, string lineAction){

		map<Id,String> assetIdToBlankStringMap = new map<Id,String>();
		for( Asset ast : assetList ){
			assetIdToBlankStringMap.put( ast.id, '');
		}

		WebserviceCallBigMachineQuoteCls wscbm = new WebserviceCallBigMachineQuoteCls();
       	wscbm.CreateQuote(	null,//String username
       						null,//string password
       						accountId,//string accId
       						oppId,//String oppid
       						null,//string casid
       						quoteType,//String qupte type
       						lineAction,//,String line action Type
       						true,//boolean returnCPQ
       						true,//boolean auto populate
       						assetIdToBlankStringMap//Map<Id,String> assetIds
       					 );
	}

	public static map<string,Opportunity> createOpportunities(list<string> accountIdList, string descirption ) {
		string currentUserId = userInfo.getUserId();

        map<id,Account> accountIdToAccountRec = new map<id,Account>( [ 	select Id,
        																	   OwnerId,
        																	   Owner.IsActive
        																from Account
        																where Id in:accountIdList
        																limit: Limits.GetLimitQueryRows() - Limits.GetQueryRows() ] );
        map<string,Opportunity> accToopportunitymap = new map<string,Opportunity>();
        string oppOwnerId;
        try {
	        if( accountIdList != null && accountIdList.size() > 0 ) {

	                for(String  accountId: accountIdList){
	                	if( accountIdToAccountRec.ContainsKey( accountId ) && accountIdToAccountRec.get( accountId ).Owner.IsActive  ){
	                		oppOwnerId = accountIdToAccountRec.get( accountId ).OwnerId;
	                	}else{
	                		oppOwnerId = currentUserId;
	                	}
		                accToopportunitymap.put( 	accountId ,
		                							new Opportunity(   	Name = 'The Opportunity',
													                    StageName = 'Prospecting',
													                    CloseDate = system.today(),
													                    AccountId = accountId,
													                    ownerId = oppOwnerId,
													                    Opportunity_Short_Description__c = descirption,
													                    Amount = 0.00)
									            );

	                }
	                insert accToopportunitymap.values();
		    }
        }catch (Exception e) {
                system.debug('Exception while creating opportunity- ' + e.getStackTraceString());
        }

        return accToopportunitymap;
    }

	public static map<string,list<Asset>> createCreditQuoteForAssets_BatchMethod( 	list<Asset> eligibleAssetList,
																					map<string,opportunity> accountIdToOpportunity,
																					string AccountIdInScope,
																					string creditType){


		string batchName = '';
		if( creditType == renewCredit ){
			batchName = 'CreateCreaditQuoteForRenewalAssetBatch';
		}else if( creditType == expiryCredit){
			batchName = 'CreateCreaditQuoteForExpiredAssetBatch';
		}

		map<string,list<Asset>> reason_assetNotProcessedForCredit 	= new map<string,list<Asset>>();
		integer totalAssetCount                      = 0;
        map<string,Asset> campaignIdToAssetMap      = new map<string,Asset>();
        list<Asset> assetEligibleForCredit          = new list<Asset>();
        list<Asset> assetNotEligibleForCredit       = new list<Asset>();
        list<list<Asset>> assetChunkList            = new list<list<Asset>>();
        list<Asset> assetChunk                      = new list<Asset>();


		 try{

	        for( Asset ast : eligibleAssetList){

	                totalAssetCount += 1;
	                assetChunk.add(ast);
	                if( totalAssetCount == TurboUtilityClass.assetCountForSOA){
	                    assetChunkList.add( assetChunk );
	                    assetChunk = new list<Asset>();
	                    totalAssetCount = 0;
	                }
	                campaignIdToAssetMap.put( ast.CampaignId__c , ast);

	        }

	        if( assetChunk != null && assetChunk.size() > 0 ){
	            assetChunkList.add( assetChunk );
	        }

	        if( !campaignIdToAssetMap.isEmpty() ){

	            list<TurboUtilityClass.CampaignToImpressionResponseClass> resopnseFromSOAList = new list<TurboUtilityClass.CampaignToImpressionResponseClass>();

	            for( list<Asset> astList : assetChunkList ){
	                        resopnseFromSOAList.addAll(TurboUtilityClass.getDeliveredImpressions( astList ) );
	            }

	            totalAssetCount = 0;

	            if( resopnseFromSOAList != null && resopnseFromSOAList.size() > 0 ){

		            for( TurboUtilityClass.CampaignToImpressionResponseClass soaResponse : resopnseFromSOAList ){

		                if( campaignIdToAssetMap.containsKey( soaResponse.campaignId )){
		                    totalAssetCount += 1;
		                    Asset assetInScope = campaignIdToAssetMap.get( soaResponse.campaignId );

		                    if( (assetInScope.Contractedimpressions__c - soaResponse.deliveredImpression) > 0 ){
		                        assetEligibleForCredit.add( assetInScope );
		                    }else{
		                        assetInScope.Credit_Status__c = TurboUtilityClass.creditNotRequiredStatus;
		                        assetNotEligibleForCredit.add( assetInScope );
		                    }
		                }// end if - campaignid map check
		            }//end for

		            if( totalAssetCount == campaignIdToAssetMap.values().size() ){

		                if( assetEligibleForCredit != null && assetEligibleForCredit.size() > 0 ){

		                    list<Asset> failedAssetList = TurboUtilityClass.createBigMachineQuoteForProcessCredit( assetEligibleForCredit, AccountIdInScope, accountIdToOpportunity.get(AccountIdInScope).Id );

		                	if( failedAssetList != null && failedAssetList.size() > 0 ){

		                		if( !reason_assetNotProcessedForCredit.containsKey('Failed to create CPQ quote') ){
		                			reason_assetNotProcessedForCredit.put('Failed to create CPQ quote',new list<Asset>());
		                		}
		                		reason_assetNotProcessedForCredit.get('Failed to create CPQ quote').addAll( failedAssetList );
		                	}
		                }

		                if( assetNotEligibleForCredit != null && assetNotEligibleForCredit.size() > 0 ){
		                    update assetNotEligibleForCredit;
		                }
		            }
	           }else{
	           		string failedAssetIds = '';
	           		for( Asset ast : eligibleAssetList){
							failedAssetIds += ast.Id+', ';
							ast.Credit_Status__c = TurboUtilityClass.creditFailedStatus;

					}
					reason_assetNotProcessedForCredit.put('Failed to get delivered impression response from SOA',eligibleAssetList);
					update eligibleAssetList;
	           		//No response came from SOA
	           		TurboUtilityClass.saveManualException( 'No Response from SOA hence wont process credit for Assets',failedAssetIds,batchName,AccountIdInScope);
	           }
	        }// End map empty check
	       }catch( Exception e ){
		       	string failedAssetIds = '';
		       	for( Asset ast : eligibleAssetList){
						failedAssetIds += ast.Id+', ';
						ast.Credit_Status__c = TurboUtilityClass.creditFailedStatus;
				}
				reason_assetNotProcessedForCredit.put('Exception Occured in '+batchName,eligibleAssetList);
				update eligibleAssetList;
	       	 	TurboUtilityClass.saveException(  e,failedAssetIds,batchName,AccountIdInScope);

	         system.debug('Exception in '+batchName+'-----------'+e.getStackTraceString());
	       }

	       return reason_assetNotProcessedForCredit;
	}

	public static void saveException( Exception ex, string failedRecordIds,string interfaceName, string entityId){
    	Error__c error = new Error__c();
        error.Name = interfaceName;
        error.Entity_Id__c = 'For : ' + entityId;
        error.Interface_Name__c = interfaceName;
        string exceptionMsg = '';
        if( ex != null ){
        	exceptionMsg = '.------- Exception: ' + ex.getMessage() + '------StackTraceString: ---' + ex.getStackTraceString();
        }
        error.Error_Description__c = 'failedRecordIds: = '+failedRecordIds + exceptionMsg;
        insert error;
    }
    public static void saveManualException( string reason, string failedRecordIds,string interfaceName, string entityId){
    	Error__c error = new Error__c();
        error.Name = interfaceName;
        error.Entity_Id__c = 'For : ' + entityId;
        error.Interface_Name__c = interfaceName;
        string exceptionMsg = '';

        error.Error_Description__c = 'failedRecordIds: = '+failedRecordIds + '---- Reason = ' + reason;
        insert error;
    }


    /*  GetUserIdsFromGroup
    *   Get set of ids of users present in the group.
    */
    public static Set<Id> GetUserIdsFromGroup_Bulkified( Set<Id> groupIds ) {
        // store the results in a set so we don't get duplicates
        Set<Id> result=new Set<Id>();
        String userTypePre = Schema.SObjectType.User.getKeyPrefix();
        String groupTypePre = Schema.SObjectType.Group.getKeyPrefix();

        Set<Id> nestedGroupIds = new Set<Id>();
        // Loop through all group members in a group
        for ( GroupMember m : [ Select  Id, UserOrGroupId
                                From    GroupMember
                                Where   GroupId IN :groupIds
                                limit   :Limits.getLimitQueryRows() - Limits.getQueryRows() ]) {
            // If the user or group id is a user
            if ( ( ( String )m.UserOrGroupId ).startsWith( userTypePre ) ) {
                result.add( m.UserOrGroupId );
            }
            // If the user or group id is a group
            // Note: there may be a problem with governor limits if this is called too many times
            else if ( ( ( String)m.UserOrGroupId ).startsWith( groupTypePre ) ) {

                nestedGroupIds.add( m.UserOrGroupId );
            }
        }
        // Call this function again but pass in the group ids found within this group
        if( nestedGroupIds.size() > 0 ) {
        	result.addAll( GetUserIdsFromGroup_Bulkified( nestedGroupIds ) );
        }

        return result;
	}

    public static void sendEmailNotificationForTurboAssetCreditFailure( string emailBody, string subject, list<string> groupDeveloperNameList ){
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
			if( emailList.size() > 0 && !Test.isRunningTest()) {
				List<Messaging.SendEmailResult> results = Messaging.sendEmail( emailList );
			}

        }
    }

    public static string createEmailBodyForAssetCreditFaliureNotification( map<string,list<Asset>> reason_assetNotProcessedForCredit ){

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
					+ 		'We tried to process credit for Turbo assets however some Asset(s) has been failed. Please find the details below:   <br/><br/><br/>';

		emailBody += '<table style="border:1px solid #888888;border-collapse:collapse;">';
			emailBody += '<tr>';
				emailBody += '<td style="border:1px solid #888888;border-collapse:collapse;">Asset Name</td>';
				emailBody += '<td style="border:1px solid #888888;border-collapse:collapse;">Failure Reason</td>';
			emailBody += '</tr>';

			for( string reason : reason_assetNotProcessedForCredit.keySet()){
				for( Asset ast : reason_assetNotProcessedForCredit.get(reason)){

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
	//This class will be used to clubbed campaignId with impressions
	public class CampaignToImpressionResponseClass{
		public string 		campaignId {get;set;}
		public integer 		deliveredImpression {get;set;}
		public integer		count {get;set;}
		public DateTime		eventDate {get;set;}

		public CampaignToImpressionResponseClass( string campaignId, integer deliveredImpression ){
			this.campaignId 			= campaignId;
			this.deliveredImpression 	= deliveredImpression;
		}
		public CampaignToImpressionResponseClass( ){}
	}

}