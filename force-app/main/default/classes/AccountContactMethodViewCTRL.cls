public class AccountContactMethodViewCTRL {
    public ApexPages.StandardController stdCntrlr {get; set;}
    public string accID {get;set;}
    
    public AccountContactMethodViewCTRL(ApexPages.StandardController controller){
        stdCntrlr = controller;
    }

}