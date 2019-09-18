global class AccountAssetInvWrapper {
    public class AssetLeadDetails {
        public transient Integer LeadId {set;get;}
        public transient String Guid {set;get;}
        public transient String SubmitDate {set;get;}
        public transient String Source {set;get;}
       // public transient String Comment {set;get;}
        public transient String LeadType {set;get;}
        public transient String AssetId {set;get;}
        public String MasterPropertyRecordId {set;get;}
        public transient String PropertyId {set;get;}
        public transient String ListingPermanentLink {set;get;}
        public transient String ListingAddress {set;get;}
        public transient String ListingCity {set;get;}
        public transient String ListingStateId {set;get;}
        public transient String ListingPostalCode {set;get;}
        public transient String ListingStatus {set;get;}
        public transient Double ListingPrice {set;get;}
        public transient String SourceEmailAddress {set;get;}
        public transient String SourceName {set;get;}
        public transient String FirstName {set;get;}
        public transient String LastName {set;get;}
        public transient String Email {set;get;}
        public transient String Phone {set;get;}
        public transient String CreateDate {set;get;}
        
        
       
       
        public AssetLeadDetails(InventoryInformation.AssetLeadDetails asslead){
            if(asslead!=null){
                this.LeadId = asslead.LeadId!=null?asslead.LeadId: 0;
                this.Guid = asslead.Guid!=null?asslead.Guid: '';
                this.SubmitDate = asslead.SubmitDate!=null?asslead.SubmitDate: '08-01-2015';
                this.Source = asslead.Source!=null?asslead.Source: '';
             //   this.Comment = asslead.Comment!=null?asslead.Comment: '';
                this.LeadType = asslead.LeadType!=null?asslead.LeadType: '';
                this.AssetId = asslead.AssetId!=null?asslead.AssetId: '';
                this.MasterPropertyRecordId = asslead.MasterPropertyRecordId!=null?asslead.MasterPropertyRecordId: '';
                this.PropertyId = asslead.PropertyId!=null?asslead.PropertyId: '';
                this.ListingPermanentLink = asslead.ListingPermanentLink!=null?asslead.ListingPermanentLink: '';
                this.ListingAddress = asslead.ListingAddress!=null?asslead.ListingAddress: '';
                this.ListingCity = asslead.ListingCity!=null?asslead.ListingCity: '';
                this.ListingStateId = asslead.ListingStateId!=null?asslead.ListingStateId: '';
                this.ListingPostalCode = asslead.ListingPostalCode!=null?asslead.ListingPostalCode: '';
                this.ListingStatus = asslead.ListingStatus!=null?asslead.ListingStatus: '';
                this.ListingPrice = asslead.ListingPrice!=null?asslead.ListingPrice: 0;
                this.SourceEmailAddress = asslead.SourceEmailAddress!=null?asslead.SourceEmailAddress: '';
                this.SourceName = asslead.SourceName!=null?asslead.SourceName: '';
                this.FirstName = asslead.FirstName!=null?asslead.FirstName: '';
                this.LastName = asslead.LastName!=null?asslead.LastName: '';
                this.Email = asslead.Email!=null?asslead.Email: '';
                this.Phone = asslead.Phone!=null?asslead.Phone: '';
                this.CreateDate = asslead.CreateDate!=null?asslead.CreateDate.SubString(0,19): '';
            }
        }
    }
    public class AssetDetails {
        public transient String AssetId {set;get;}
        public transient String FromDate {set;get;}
        public transient String ToDate {set;get;}
     //   public transient Integer AssetLeadDetailCount {set;get;}
        public transient Double AverageListingPriceWebLead {set;get;}
        public transient Double AverageListingPriceMobileLead {set;get;}
        public transient Double AverageListingPriceAllLead {set;get;}
        public transient Integer WebLead {set;get;}
        public transient Integer MobileLead {set;get;}
        public transient Integer PaidLead {set;get;}
        public transient Integer CourtesyLead {set;get;}
        public transient Integer TotalLeads {set;get;}
     //   public transient Decimal OverSoldFull {set;get;}
    //    public transient Decimal OverSoldHalf {set;get;}
        public transient Integer FullFlexAvailable {set;get;}
        public transient Integer FullFastAvailable {set;get;}
        public transient Integer FullPriceTier {set;get;}
        public transient Decimal FullFlexUnitPrice {set;get;}
        public transient Decimal FullFastUnitPrice {set;get;}
        public transient Integer HalfPriceTier {set;get;}
        public transient Integer HalfFlexAvailable {set;get;}
        public transient Integer HalfFastAvailable {set;get;}
        public transient Decimal HalfFlexUnitPrice {set;get;}
        public transient Decimal HalfFastUnitPrice {set;get;}
        public transient Decimal FullFlexAll {set;get;}
        public transient Decimal HalfFlexAll {set;get;}
        public transient Decimal FullFastAll {set;get;}
        public transient Decimal HalfFastAll {set;get;}
        public transient String Name {set;get;}
        public transient String Status {set;get;}
        public transient  Decimal Quantity {set;get;}
        public transient String ProductType {set;get;}
        public transient String LeadType {set;get;}
        public transient String MarketZip {set;get;}
        public transient Integer ContractTerm {set;get;}
        public transient Date StartDate {set;get;}
        public transient Date End_Date {set;get;}
        public transient Decimal ListPrice {set;get;}
        public transient Decimal RenewalPrice {set;get;}
        public transient String Performance {set;get;}
        public transient String BOPCode {set;get;}
        public transient Integer i {set;get;}
        public transient Double renewalPriceValue{set;get;}
        public transient Id Id{set;get;} // Added on 03/02
        
        AssetDetails(){}
        Public AssetDetails(Asset a, InventoryInformation assinv){
        if(a!=null){
        if(a.Ultimate_Parent_Id_Text__c!=null){
            this.Id = a.Ultimate_Parent_Id_Text__c!=null?a.Ultimate_Parent_Id_Text__c: ''; // Added on 03/02 //Changed from Id to Ultimate_Parent_Id_Text__c by Ravi Pasala 3/24/2016
            }
            }
            this.Name = a.Name!=null?a.Name: '';
            this.Status = a.Status!=null?a.Status: '';
            this.Quantity = a.Parent_Asset__r.Quantity!=null?a.Parent_Asset__r.Quantity: 0;
            this.ProductType = a.Product_Type__c!=null?a.Product_Type__c: '';
            this.LeadType = a.Lead_Type__c!=null?a.Lead_Type__c.SubString(0,4): '';
            this.MarketZip = a.Parent_Asset__r.Market__c!=null?a.Parent_Asset__r.Market__c: '';
            this.BOPCode = a.Parent_Asset__r.BOP_Code__c!=null?a.Parent_Asset__r.BOP_Code__c: '';
            this.ContractTerm = a.Parent_Asset__r.Contract_Term__c!=null?Integer.valueOf(a.Parent_Asset__r.Contract_Term__c): 6;
            this.StartDate = a.Start_Date__c!=null?Date.valueOf(a.Start_Date__c): Date.valueOf(system.now());
            this.End_Date = a.End_Date__c!=null?Date.valueOf(a.End_Date__c): Date.valueOf(system.now());
            this.ListPrice = a.Parent_Asset__r.Total_Net__c!=null?a.Parent_Asset__r.Total_Net__c: 0;
           
            this.AssetId = assinv.AssetId!=null?assinv.AssetId: ''; 
            this.FromDate = assinv.FromDate!=null?assinv.FromDate: '';
            this.ToDate = assinv.ToDate!=null?assinv.ToDate: '';
       //     this.AssetLeadDetailCount = assinv.AssetLeadDetailCount!=null?assinv.AssetLeadDetailCount: 0;
            this.AverageListingPriceWebLead = assinv.AverageListingPriceWebLead!=null?assinv.AverageListingPriceWebLead: 0;
            this.AverageListingPriceMobileLead = assinv.AverageListingPriceMobileLead!=null?assinv.AverageListingPriceMobileLead: 0;
            this.AverageListingPriceAllLead = assinv.AverageListingPriceAllLead!=null?assinv.AverageListingPriceAllLead: 0;
            this.WebLead = assinv.WebLead!=null?assinv.WebLead: 0;
            this.MobileLead = assinv.MobileLead!=null?assinv.MobileLead: 0;
            this.PaidLead = assinv.PaidLead!=null?assinv.PaidLead: 0;
            this.CourtesyLead = assinv.CourtesyLead!=null?assinv.CourtesyLead: 0;
            this.TotalLeads = assinv.TotalLeads!=null?assinv.TotalLeads: 0;
        //    this.OverSoldFull = assinv.OverSoldFull!=null?assinv.OverSoldFull: 0;
        //    this.OverSoldHalf = assinv.OverSoldHalf!=null?assinv.OverSoldHalf: 0;
            this.FullFlexAvailable = assinv.FullFlexAvailable!=null?assinv.FullFlexAvailable: 0;
            this.FullFastAvailable = assinv.FullFastAvailable!=null?assinv.FullFastAvailable: 0;
            this.FullPriceTier = assinv.FullPriceTier!=null?assinv.FullPriceTier: 0;
            this.FullFlexUnitPrice = assinv.FullFlexUnitPrice!=null? assinv.FullFlexUnitPrice * this.ContractTerm: 0.00;
            this.FullFastUnitPrice = assinv.FullFastUnitPrice!=null? assinv.FullFastUnitPrice * this.ContractTerm: 0.00;
            this.HalfPriceTier = assinv.HalfPriceTier!=null?assinv.HalfPriceTier: 0;
            this.HalfFlexAvailable = assinv.HalfFlexAvailable!=null?assinv.HalfFlexAvailable: 0;
            this.HalfFastAvailable = assinv.HalfFastAvailable!=null?assinv.HalfFastAvailable: 0;
            this.HalfFlexUnitPrice = assinv.HalfFlexUnitPrice!=null? assinv.HalfFlexUnitPrice * this.ContractTerm: 0.00;
            this.HalfFastUnitPrice = assinv.HalfFastUnitPrice!=null? assinv.HalfFastUnitPrice * this.ContractTerm: 0.00;
            this.FullFlexAll = this.FullFlexAvailable * this.FullFlexUnitPrice;
            this.HalfFlexAll = this.HalfFlexAvailable * this.HalfFlexUnitPrice;
            this.FullFastAll = this.FullFastAvailable * this.FullFastUnitPrice;
            this.HalfFastAll = this.HalfFastAvailable * this.HalfFastUnitPrice;
            
            if(this.ProductType == 'Full'){
                if(this.LeadType == 'Fast'){
                    renewalPriceValue = this.FullFastUnitPrice;
                }
                if(this.LeadType == 'Flex'){
                    renewalPriceValue = this.FullFlexUnitPrice;
                }
            }
            else if (this.ProductType == 'Half'){
                if(this.LeadType == 'Fast'){
                    renewalPriceValue = this.HalfFastUnitPrice;
                }
                if(this.LeadType == 'Flex'){
                    renewalPriceValue = this.HalfFlexUnitPrice;
                }
            
            }
            
            this.RenewalPrice = renewalPriceValue!=null?renewalPriceValue: 0;
            
            
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
    public transient String PartyId {set;get;}
    public transient String Type {set;get;}
    public transient String PrimaryEmail {set;get;}
    public transient String Phone {set;get;}
    public transient String Name {set;get;}
    public transient String BrokerNARId {set;get;}
    public transient String BillingState {set;get;}
    public transient String BillingPostalCode {set;get;}
    public transient String BillingCountry {set;get;}
    public transient String BillingCity {set;get;}
    public transient Double TotalAverageListingPriceWebLead = 0;
    public transient Double TotalAverageListingPriceMobileLead = 0;
    public transient Double TotalAverageListingPriceAllLead = 0;
    public transient Integer TotalWebLead = 0;
    public transient Integer TotalMobileLead = 0;
    public transient Integer TotalPaidLead = 0;
    public transient Integer TotalCourtesyLead = 0;
    public transient Integer TotalTotalLeads = 0;
    public transient Map<String, List<AssetLeadDetails>> Mldwrap {set;get;}
    public transient List<AssetDetails> dwrap {set;get;}
    public transient List<AssetLeadDetails> ldwrap {set;get;}
    public AccountAssetInvWrapper(){}
    
    
    public AccountAssetInvWrapper(Account ppass, List<Asset> ppassdetails, List<InventoryInformation> assinv){
        dwrap = new List<AssetDetails>();
        ldwrap = new List<AssetLeadDetails>();
        Mldwrap = new Map<String, List<AssetLeadDetails>>();
        this.PartyId = ppass.Party_ID__c!=null?ppass.Party_ID__c:'';
        this.Type = ppass.Type!=null?ppass.Type:'';
        this.PrimaryEmail = ppass.Email_Address__c!=null?ppass.Email_Address__c: '';
        this.Phone = ppass.Phone!=null?ppass.Phone: '';
        this.Name = ppass.Name!=null?ppass.Name: '';
        this.BrokerNARId = ppass.Broker_NAR_Id__c!=null?ppass.Broker_NAR_Id__c: '';
        this.BillingState = ppass.BillingState!=null?ppass.BillingState: '';
        this.BillingPostalCode = ppass.BillingPostalCode!=null?ppass.BillingPostalCode: '';
        this.BillingCountry = ppass.BillingCountry!=null?ppass.BillingCountry: '';
        this.BillingCity = ppass.BillingCity!=null?ppass.BillingCity: '';
        
        for(Asset a: ppassdetails){
            if(a!=null){
                //ldwrap = new List<AssetLeadDetails>();
                Transient Integer j = assinv.size();
                for(Integer i=0;i < j;i++){
                    if(assinv.get(i)!=null && a.External_ID__c == assinv.get(i).AssetId){
                        if(assinv.get(i).AssetLeadDetails != null){
                            for(InventoryInformation.AssetLeadDetails inv: assinv.get(i).AssetLeadDetails){ 
                                if (inv != null && inv.AssetId == a.External_ID__c){
                                    ldwrap.add(new AssetLeadDetails(inv));
                                }
                            }
                        }
                     //   Added by stanley here
                            dwrap.add(new AssetDetails(a,assinv.get(i)));
                            Mldwrap.put(a.External_ID__c,ldwrap);
                    }
                }
            }
        }
        //system.debug('ldwrap2_________'+ldwrap);
        for (AccountAssetInvWrapper.AssetDetails b: dwrap){
                TotalAverageListingPriceWebLead += b.AverageListingPriceWebLead;
                TotalAverageListingPriceMobileLead += b.AverageListingPriceMobileLead;
                TotalAverageListingPriceAllLead += b.AverageListingPriceAllLead;
                TotalWebLead += b.WebLead;
                TotalMobileLead += b.MobileLead;
                TotalPaidLead += b.PaidLead;
                TotalCourtesyLead += b.CourtesyLead;
                TotalTotalLeads += b.TotalLeads;
        }
        Transient Integer agg = dwrap.size();
        if (agg > 0){
            AccountAssetInvWrapper.AssetDetails totalRecord = new AccountAssetInvWrapper.AssetDetails();
            totalRecord.AverageListingPriceWebLead = TotalAverageListingPriceWebLead/agg;
            totalRecord.AverageListingPriceMobileLead = TotalAverageListingPriceMobileLead/agg;
            totalRecord.AverageListingPriceAllLead = TotalAverageListingPriceAllLead/agg;
            totalRecord.WebLead = TotalWebLead;
            totalRecord.MobileLead = TotalMobileLead;
            totalRecord.PaidLead = TotalPaidLead;
            totalRecord.CourtesyLead = TotalCourtesyLead;
            totalRecord.TotalLeads = TotalTotalLeads;
            totalRecord.AssetId = 'Total';        
            dwrap.add(totalRecord);        
        }
    }
    public List<AssetLeadDetails> getLead(String AssetId){
        return Mldwrap.get(AssetId);
    }
}