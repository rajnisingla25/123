public class CheckAllUsingJavascriptController {
    public List<wrapAccount> wrapAccountList {get; set;}
     
    public CheckAllUsingJavascriptController(){
        if(wrapAccountList == null) {
            wrapAccountList = new List<wrapAccount>();
            for(Account a: [select Id, Name,BillingState, Website, Phone from Account limit 10]) {
                // As each Account is processed we create a new wrapAccount object and add it to the wrapAccountList
                wrapAccountList.add(new wrapAccount(a));
            }
        }
    }
     
    public class wrapAccount {
        public Account acc {get; set;}
        public Boolean selected {get; set;}
 
        //This is the contructor method. When we create a new wrapAccount object we pass a Account that is set to the acc property. We also set the selected value to false
        public wrapAccount(Account a) {
            acc = a;
            selected = false;
        }
    }
}