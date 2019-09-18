public class TurboImpressionReport {
	public string assetId;
	public list<TurboUtilityClass.CampaignToImpressionResponseClass> dailyAggrImprList {get;set;}
	public integer totalImpressionCount {get;set;}
	public TurboImpressionReport( ApexPages.StandardController sc ){
		assetId = sc.getId();
		dailyAggrImprList = new list<TurboUtilityClass.CampaignToImpressionResponseClass>();
		totalImpressionCount = 0;
	}
	
	public void getDeliverdImpressionList(){
		string startDate = ApexPages.currentPage().getParameters().get('startDate');
		string endDate = ApexPages.currentPage().getParameters().get('endDate');
		
		
		dailyAggrImprList = new list<TurboUtilityClass.CampaignToImpressionResponseClass>();
		dailyAggrImprList = TurboUtilityClass.getDeliveredImpressionsForReport( assetId, Date.valueOf( startDate ), Date.valueOf( endDate ) );
		totalImpressionCount = 0;
		for( TurboUtilityClass.CampaignToImpressionResponseClass impInst : dailyAggrImprList){
			if( impInst.count != null && impInst.count > 0 ){
				totalImpressionCount += impInst.count;
			}
		}
	}
}