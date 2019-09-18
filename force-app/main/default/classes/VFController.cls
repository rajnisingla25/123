public class VFController {       
    private final Lead lead;    
        public VFController(ApexPages.StandardController stdController) {         
        this.lead= (Lead)stdController.getRecord();     
        }              
        
        public PageReference autoRun() {        
            String theId = ApexPages.currentPage().getParameters().get('id');    
            if (theId == null) {             // Display the Visualforce page's content if no Id is passed over             
                return null;         
            }         
            for (Account acc:[SELECT Name, BillingStreet, BillingCity, BillingState, BillingPostalCode FROM Account where BillingPostalCode =:theId]) {         
                
            }        
                   
// Redirect the user back to the original page        
    PageReference pageRef = new PageReference('/' + theId);         
        pageRef.setRedirect(true);      
        return pageRef;   
        }  
}