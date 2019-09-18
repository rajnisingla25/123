public class InventoryInformation {
    public class AssetLeadDetails {
        public Integer LeadId {set;get;}
        public Transient String Guid {set;get;}
        public Transient String SubmitDate {set;get;}
        public String Source {set;get;}
        public String Comment {set;get;}
        public String LeadType {set;get;}
        public String AssetId {set;get;}
        public String MasterPropertyRecordId {set;get;}
        public Transient String PropertyId {set;get;}
        public Transient String ListingPermanentLink {set;get;}
        public String ListingAddress {set;get;}
        public String ListingCity {set;get;}
        public String ListingStateId {set;get;}
        public String ListingPostalCode {set;get;}
        public String ListingStatus {set;get;}
        public Double ListingPrice {set;get;}
        public String SourceEmailAddress {set;get;}
        public Transient String SourceName {set;get;}
        public String FirstName {set;get;}
        public String LastName {set;get;}
        public String Email {set;get;}
        public String Phone {set;get;}
        public String CreateDate {set;get;}
    }
    public String AssetId {set;get;}
    public Transient String FromDate {set;get;}
    public Transient String ToDate {set;get;}
    public Integer AssetLeadDetailCount {set;get;}
    public Double AverageListingPriceWebLead {set;get;}
    public Double AverageListingPriceMobileLead {set;get;}
    public Double AverageListingPriceAllLead {set;get;}
    public Integer WebLead {set;get;}
    public Integer MobileLead {set;get;}
    public Integer PaidLead {set;get;}
    public Integer CourtesyLead {set;get;}
    public Integer TotalLeads {set;get;}
    public Integer FullFlexAvailable {set;get;}
    public Integer FullFastAvailable {set;get;}
    public Integer FullPriceTier {set;get;}
    public Decimal FullFlexUnitPrice {set;get;}
    public Decimal FullFastUnitPrice {set;get;}
    public Integer HalfPriceTier {set;get;}
    public Integer HalfFlexAvailable {set;get;}
    public Integer HalfFastAvailable {set;get;}
    public Decimal HalfFlexUnitPrice {set;get;}
    public Decimal HalfFastUnitPrice {set;get;}
    public Decimal OverSoldFull {set;get;}
    public Decimal OverSoldHalf {set;get;}
    public List<AssetLeadDetails> AssetLeadDetails {set;get;}
}