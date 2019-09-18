public class ViewAssetValueController {
    public List<Asset> allParentAssets { get; set;}
    public list<wrapAsset> wrapAssetList { get; set; }   
    public Decimal TotalRemainingValue { get; set;}
    public Decimal TotalPendingValue { get; set;}
    Decimal Price;
    Decimal TotalPrice ;
    
    public ViewAssetValueController(){
        Id AccountId = ApexPages.CurrentPage().getparameters().get('accId');
        wrapAssetList = new list<wrapAsset>();
        allParentAssets = [select id,Name,price,Asset_Type__c,Start_Date__c,End_Date__c from Asset where Asset_Type__c = 'Parent' and AccountId =: AccountId and Status!='Expired'];
        //allParentAssets = [select id,Name,price,Asset_Type__c,Start_Date__c,End_Date__c from Asset where Asset_Type__c = 'Parent' and start_Date__C != Null and End_Date__c!= Null and AccountId =: AccountId ];
        Set<Id> AssetIds = new Set<Id>();
        for(Asset OLT : allParentAssets){
            AssetIds.add(OLT.Id);
        }        
        List<OrderItem> allOrderItems = new List<OrderItem>();
        allOrderItems = [select Id,OrderId,UnitPrice,Asset__c,Quantity from OrderItem where Asset__c In : AssetIds];
        TotalPendingValue = 0.0;
        TotalRemainingValue = 0.0;
        for(Asset a : allParentAssets){   
            if(allOrderItems.size() > 0){
                for(OrderItem Oitem : allOrderItems){               
                    if(Oitem.Asset__c == a.id){
                        Integer TotalDays = 0;
                        Integer UptillDays =0;
                        Price = 0;
                        TotalPrice = 0;
                        If(a.start_Date__C != Null && a.End_Date__c != Null) {
                            
                            TotalDays = a.start_Date__C.daysBetween(date.valueof(a.End_Date__c));
                            UptillDays = a.start_Date__C.daysBetween(date.valueof(Date.Today()));
                        }
                        try{      
                      
                            Price = (((a.price)/(TotalDays)) * UptillDays).setScale(2); 
                            TotalPrice = (Oitem.UnitPrice*Oitem.Quantity).setScale(2);
                            TotalRemainingValue += Price;
                            TotalPendingValue += TotalPrice ; 
                        }
                        catch(Exception e){}                                                               
                        wrapAssetlist.add(new wrapAsset(a,Price,TotalPrice));                       
                    }                
                }
            } 
             if(allOrderItems.size() == 0){
                Integer TotalDays = 0;
                    Integer UptillDays =0;
                    Price = 0;
                    TotalPrice = 0;
                    If(a.start_Date__C != Null && a.End_Date__c != Null) {
                        
                        TotalDays = a.start_Date__C.daysBetween(date.valueof(a.End_Date__c));
                        UptillDays = a.start_Date__C.daysBetween(date.valueof(Date.Today()));
                    }
                    try{
                        Price = (((a.price)/(TotalDays)) * UptillDays).setScale(2); 
                        TotalRemainingValue += Price;
                        TotalPendingValue += TotalPrice ; 
                        }catch(Exception e){}
                 wrapAssetlist.add(new wrapAsset(a,Price,TotalPrice));  
            }
        }
    }    
   
    public class wrapAsset{
        public Asset assets {get; set;}
        public Decimal Price {get; set;}
        public Decimal TotalPrice {get; set;}
        public boolean isSelected {get;set;}        
        public wrapAsset(Asset a, Decimal Price1,Decimal TotalPrice1){
            Assets = a;
            Price = Price1;
            TotalPrice = TotalPrice1;
        }
    }
}