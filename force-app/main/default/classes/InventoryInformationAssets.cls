public class InventoryInformationAssets {
    public class AssetLeadDetails {
        public Transient Integer LeadId {set;get;}
        public Transient String Guid {set;get;}
        public Transient String SubmitDate {set;get;}
        public Transient String Source {set;get;}
        public Transient String Comment {set;get;}
        public Transient String LeadType {set;get;}
        public Transient String AssetId {set;get;}
        public Transient String MasterPropertyRecordId {set;get;}
        public Transient String PropertyId {set;get;}
        public Transient String ListingPermanentLink {set;get;}
        public Transient String ListingAddress {set;get;}
        public Transient String ListingCity {set;get;}
        public Transient String ListingStateId {set;get;}
        public Transient String ListingPostalCode {set;get;}
        public Transient String ListingStatus {set;get;}
        public Transient Double ListingPrice {set;get;}
        public Transient String SourceEmailAddress {set;get;}
        public Transient String SourceName {set;get;}
        public Transient String FirstName {set;get;}
        public Transient String LastName {set;get;}
        public Transient String Email {set;get;}
        public Transient String Phone {set;get;}
        public Transient String CreateDate {set;get;}
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
    public Transient Integer FullFlexAvailable {set;get;}
    public Transient Integer FullFastAvailable {set;get;}
    public Transient Integer FullPriceTier {set;get;}
    public Transient Decimal FullFlexUnitPrice {set;get;}
    public Transient Decimal FullFastUnitPrice {set;get;}
    public Transient Integer HalfPriceTier {set;get;}
    public Transient Integer HalfFlexAvailable {set;get;}
    public Transient Integer HalfFastAvailable {set;get;}
    public Transient Decimal HalfFlexUnitPrice {set;get;}
    public Transient Decimal HalfFastUnitPrice {set;get;}
    public Transient Decimal OverSoldFull {set;get;}
    public Transient Decimal OverSoldHalf {set;get;}
    public List<AssetLeadDetails> AssetLeadDetails {set;get;}

}