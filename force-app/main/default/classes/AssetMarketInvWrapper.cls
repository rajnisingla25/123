public class AssetMarketInvWrapper {
        public String AccountId {set;get;}
        public String AssetId {set;get;}
        public String FromDate {set;get;}
        public String ToDate {set;get;}
        public Transient Integer AssetLeadDetailCount {set;get;}
        public Transient Double AverageListingPriceWebLead {set;get;}
        public Transient Double AverageListingPriceMobileLead {set;get;}
        public Transient Double AverageListingPriceAllLead {set;get;}
        public Transient Integer WebLead {set;get;}
        public Transient Integer MobileLead {set;get;}
        public Transient Integer PaidLead {set;get;}
        public Transient Integer CourtesyLead {set;get;}
        public Transient Integer TotalLeads {set;get;}
        //public Transient String PartyId {set;get;}
        public String Name {set;get;}
        public String Status {set;get;}
        public Decimal Quantity {set;get;}
        //public Transient String OwnerId {set;get;}
        public Transient String ProductType {set;get;}
        public Transient String LeadType {set;get;}
        public Transient String MarketZip {set;get;}
        public Transient String ContractTerm {set;get;}
        public Transient Date StartDate {set;get;}
        public Transient Date End_Date {set;get;}
        //public Transient String AssetType {set;get;}
        //public Transient Decimal ListPrice {set;get;}
        //public Transient Decimal RenewalPrice {set;get;}
        //public Transient String SigninAE {set;get;}
        public String assetAccountName {set;get;}
        public Transient String Performance {set;get;}
        public Transient Integer i {set;get;}
        public AssetMarketInvWrapper(){}
        public AssetMarketInvWrapper(Asset a, InventoryInformationAssets assinv){
            if(!Test.isRunningTest()){this.AccountId = a.Account.id!=null?a.Account.id:'';}
            //this.PartyId = a.Account.Party_ID__c!=null?a.Account.Party_ID__c: '';
            this.Status = a.Status!=null?a.Status: '';
            this.Quantity = a.Parent_Asset__r.Quantity!=null?a.Parent_Asset__r.Quantity: 0;
            //this.OwnerId = a.OwnerId!=null?a.OwnerId: '';
            this.ProductType = a.Product_Type__c!=null?a.Product_Type__c: '';
            this.LeadType = a.Lead_Type__c!=null?a.Lead_Type__c.SubString(0,4): '';
            this.MarketZip = a.Parent_Asset__r.Market__c!=null?a.Parent_Asset__r.Market__c: '';
            this.ContractTerm = a.Parent_Asset__r.Contract_Term__c!=null?a.Parent_Asset__r.Contract_Term__c: '';
            this.StartDate = a.Start_Date__c!=null?Date.valueOf(a.Start_Date__c): Date.valueOf(system.now());
            this.End_Date = a.End_Date__c!=null?Date.valueOf(a.End_Date__c): Date.valueOf(system.now());
            //this.AssetType = a.Asset_Type__c!=null?a.Asset_Type__c: '';
            //this.ListPrice = a.List_Price__c!=null?a.List_Price__c: 0;
            //this.RenewalPrice = a.Renewal_Price__c!=null?a.Renewal_Price__c: 0;
            this.AssetId = assinv.AssetId!=null?assinv.AssetId: ''; 
            this.FromDate = assinv.FromDate!=null?assinv.FromDate: '';
            this.ToDate = assinv.ToDate!=null?assinv.ToDate: '';
            this.AssetLeadDetailCount = assinv.AssetLeadDetailCount!=null?assinv.AssetLeadDetailCount: 0;
            this.AverageListingPriceWebLead = assinv.AverageListingPriceWebLead!=null?assinv.AverageListingPriceWebLead: 0;
            this.AverageListingPriceMobileLead = assinv.AverageListingPriceMobileLead!=null?assinv.AverageListingPriceMobileLead: 0;
            this.AverageListingPriceAllLead = assinv.AverageListingPriceAllLead!=null?assinv.AverageListingPriceAllLead: 0;
            this.WebLead = assinv.WebLead!=null?assinv.WebLead: 0;
            this.MobileLead = assinv.MobileLead!=null?assinv.MobileLead: 0;
            this.PaidLead = assinv.PaidLead!=null?assinv.PaidLead: 0;
            this.CourtesyLead = assinv.CourtesyLead!=null?assinv.CourtesyLead: 0;
            this.TotalLeads = assinv.TotalLeads!=null?assinv.TotalLeads: 0;
            this.assetAccountName = a.Account_Name__c !=null? a.Account_Name__c : '';
            System.debug ('this.PaidLead'+this.PaidLead);
            System.debug ('this.days'+this.StartDate.daysBetween(Date.valueof(system.now())));
            System.debug ('this.size'+this.ProductType == 'Full'?0.1111:0.0556);
            System.debug ('this.Quantity'+this.Quantity);
            if (this.Quantity > 0)
                i = Integer.valueof(Math.floor((this.PaidLead/((this.StartDate.daysBetween(Date.valueof(system.now()))<=0?1:this.StartDate.daysBetween(Date.valueof(system.now()))) * (this.ProductType == 'Full'?0.1111:0.0556) * this.Quantity))*100));
            else
                i = 0;
            
            if (i!=null)
                this.Performance = string.valueof(i)+'%';
            else
                this.Performance = '';

        }
}