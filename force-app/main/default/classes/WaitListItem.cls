public class WaitListItem{
       Public Integer index {get;set;}
       Public String product{get;set;}
       Public String waitlistProductType{get;set;}
       Public String market{get;set;}
       Public String state{get;set;}
       Public String waitlistType {get; set;}
       Public List<SelectOption> leadRoutes {get; set;}
       Public List<SelectOption> productsizes {get; set;}
       Public String defaultLeadRoute {get;set;}
       Public String defaultProductSize {get;set;}
       Public String waitlistStatus {get; set;}
       Public Date expirationDate {get; set;}
       Public List<SelectOption> terms {get; set;}
       Public String defaultTerm {get;set;}
       Public Decimal maxSpend {get; set;}
       Public String status {get; set;}
       Public Decimal currentUtilizedSpend {get; set;}
       Public Boolean disableCurrentUtilizedSpend {get; set;}
       Public Decimal rateCardPrice {get; set;}   
       Public Decimal rank;    
       Public String preAuthType;
       Public String parentId; //CRM-1587
       public WaitListItem(Integer index,
                               String product,
                               String waitlistProductType,
                               String market,
                               String state,
                               String waitlistType,
                               List<SelectOption> leadRoutes,
                               List<SelectOption> productsizes,
                               String defaultLeadRoute,
                               String defaultProductSize,
                               String waitlistStatus,
                               Date expirationDate,
                               List<SelectOption> terms,
                               String defaultTerm,
                               Decimal maxSpend,
                               String status,
                               Decimal currentUtilizedSpend,
                               Boolean disableCurrentUtilizedSpend,
                               Decimal rateCardPrice, 
                               Decimal rank,
                               String preAuthType ){
            this.index = index;
            this.product = product;
            this.waitlistProductType = waitlistProductType;
            this.market = market;
            this.state = state;
            this.waitlistType = waitlistType;
            this.leadRoutes = leadRoutes;
            this.productsizes = productsizes;
            this.defaultLeadRoute = defaultLeadRoute;
            this.defaultProductSize = defaultProductSize;
            this.waitlistStatus = waitlistStatus;
            this.expirationDate = expirationDate;
            this.terms = terms;
            this.defaultTerm = defaultTerm;
            this.maxSpend = maxSpend; 
            this.status = status;
            this.currentUtilizedSpend = currentUtilizedSpend;
            this.disableCurrentUtilizedSpend = disableCurrentUtilizedSpend;
            this.rateCardPrice = rateCardPrice;  
            this.rank = rank; 
            this.preAuthType = preAuthType;                 
                               
        }
}