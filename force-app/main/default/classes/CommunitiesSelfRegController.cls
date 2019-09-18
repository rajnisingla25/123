/**
 * An apex page controller that supports self registration of users in communities that allow self registration
 */
public class CommunitiesSelfRegController {

    public String firstName {get; set;}
    public String lastName {get; set;}
    public String email {get; set;}
    public String phone {get; set;}
    public String password {get; set {password = value == null ? value : value.trim(); } }
    public String confirmPassword {get; set { confirmPassword = value == null ? value : value.trim(); } }
    public String communityNickname {get; set { communityNickname = value == null ? value : value.trim(); } }
    
    public CommunitiesSelfRegController() {}
    
    private boolean isValidPassword() {
        return password == confirmPassword;
    }
    
   
    public PageReference registerUser() {
    
           // it's okay if password is null - we'll send the user a random password in that case
        if (!isValidPassword()) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.site.passwords_dont_match);
            ApexPages.addMessage(msg);
            return null;
        }    

        Collection_Users__c cu1 = Collection_Users__c.getValues('Employee Dashboard Profile');
        Collection_Users__c cu2 = Collection_Users__c.getValues('Employee Dashboard Default Account');
        EmployeeDashboard__c ed = EmployeeDashboard__c.getValues('UsernameSuffix');
        String profileId = cu1.id__c; // To be filled in by customer.
        String roleEnum = null; // To be filled in by customer.
        String accountId = cu2.id__c; // To be filled in by customer.
        String userName = email;
       
        // appending ".ed" to username in Prod as users will be using same email(username) to login into community and standard SFDC
        // CRM-2818 
        if(ed.Value__c != null){
            userName = userName+ed.Value__c;
        }

        User u = new User();
        u.Username = userName;
        u.Email = email;
        u.FirstName = firstName;
        u.LastName = lastName;
        u.CommunityNickname = communityNickname;
        u.EmployeeNumber = communityNickname;
        u.Phone = phone;
        u.ProfileId = profileId;
 
        String userId;

        try {
           userId = Site.createExternalUser(u, accountId, password);  
        } catch(Site.ExternalUserCreateException ex) {
            String error = ex.getMessage();
            error = error.replace('nickname', 'employee number');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
            // This message is used for debugging. Do not display this in the UI to the end user.
            // It has the information around why the user creation failed.
            System.debug(ex.getMessage());
        }
  
        if (userId != null) { 
            if (password != null && password.length() > 1) {
                return Site.login(userName, password, ApexPages.currentPage().getParameters().get('startURL'));
            }
            else {
                PageReference page = System.Page.CommunitiesSelfRegConfirm;
                page.setRedirect(true);
                return page;
            }
        }
        return null;
    }
   
}