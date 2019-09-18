global class Mortgage_Email_Controller {
    public String NewLine {
        get { return '\r\n'; }
        set;
    }
        
    public String quotes {
        get { return '"'; }
        set;
    }
    
    public static Map<Id, List<ContactAndRole>> contacts {get;set;}
    public class ContactAndRole {
        public String role {get;set;}
        public Contact con {get; set;}
        public ContactAndRole(String role, Contact con) {
            this.role = role;
            this.con = con;
        }
    }
    
    public static boolean sendEmail(List<Id> assetIds) {
        Map<Id, Id> oppVSAssetId = new Map<Id, Id>();
        Set<id> accountIds = new Set<Id>();
        List<Asset> assets = [SELECT Id, Line_Type__c, AccountId, Order_Line_Item__r.Order.OpportunityId, Sign_in_AE__r.Email, Account.Owner.Email FROM Asset WHERE Id IN :assetIds];
        for (Asset asset : assets) {
            oppVSAssetId.put(asset.Order_Line_Item__r.Order.OpportunityId, asset.Id);
            accountIds.add(asset.accountId);
        }
        
        // Fetch contact and role for each account
        setContactsandRoles(accountIds);
        
        // Send email
        return sendEmailToCake(assets, fetchAssetAttachments(oppVSAssetId));
    }
    
    // fetch given accounts contact and role and set in static variable Contacts.
    private static void setContactsandRoles(Set<id> accountIds) {
        try {
            contacts = new Map<Id, List<ContactAndRole>>();
            Id contactRelationshipRecordTypeId = Schema.SObjectType.Account_Relationship__c.RecordTypeInfosByName.get('Contact Relationship').RecordTypeId;
            Map<Id, Map<Id, String>> conIdsRole = new Map<Id, Map<Id, String>>();
            for (Account_Relationship__c conRel : [SELECT Parent_Account__c, Contact_Role__c, Contact_To__c FROM Account_Relationship__c WHERE Parent_Account__c IN :accountIds AND RecordTypeId = :contactRelationshipRecordTypeId AND Active__c=true AND Parent_Account__c != null AND Contact_To__c != null]) {
               Map<Id, String> rel = conIdsRole.get(conRel.Contact_To__c);
               if (rel == null) {
                   rel = new Map<Id, String>();
               }
               rel.put(conRel.Parent_Account__c, conRel.Contact_Role__c);
               conIdsRole.put(conRel.Contact_To__c, rel);
            }
            if (!conIdsRole.isEmpty()) {
               for(Contact c:  (List<Contact>)getContacts(conIdsRole.keySet())) {
                   Map<Id, String> rels = conIdsRole.get(c.Id);
                   for (Id accId : rels.keySet()) {
                   List<ContactAndRole> cRoles = contacts.get(accId);
                       if (cRoles == null) {
                           cRoles = new List<ContactAndRole>();
                       }
                       cRoles.add(new ContactAndRole(conIdsRole.get(c.Id).get(accId), c));
                       contacts.put(accId, cRoles);
                   }
               }
            }
        }
        catch (Exception e) {
            system.debug('setContactsandRoles :: ' + e.getMessage());
        }
    }
    
    // function to fetch contact and contact methods
    private Static List<sObject> getContacts(Set<id> contactIds) {
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : SObjectType.Contact.FieldSets.Mortgage_Order_Fulfillment.getFields()) {
            if (f.getFieldPath() != 'Id') {
                query += f.getFieldPath() + ', ';
            }
        }
        // SMCI-554 - Changes for Contact Method
        query += 'Id, (CONTACTMETHODQUERY) FROM Contact WHERE Id = :contactIds';
        
        String contactMethodQuery = 'SELECT Type__c,Type_Purpose__c,';
        for(Schema.FieldSetMember f : SObjectType.ContactMethod__c.FieldSets.Mortgage_Order_Fulfillment_Phone.getFields()) {
            if(!contactMethodQuery.contains(f.getFieldPath())) {
                contactMethodQuery += f.getFieldPath() + ',';
            }
        }
        for(Schema.FieldSetMember f : SObjectType.ContactMethod__c.FieldSets.Mortgage_Order_Fulfillment_Email.getFields()) {
            if(!contactMethodQuery.contains(f.getFieldPath())) {
                contactMethodQuery += f.getFieldPath() + ',';
            }        
        }
       
        contactMethodQuery  = contactMethodQuery.removeEnd(',');
        contactMethodQuery += ' FROM Contact_Methods__r WHERE Active__c=true';
        query = query.replace('CONTACTMETHODQUERY', contactMethodQuery);
        // SMCI-554 - End
        System.debug('query ------>'+query );
        return Database.query(query);   
    } 
    
    // function to fetch asset attachment from Opportunity
    private static Map<Id, Attachment> fetchAssetAttachments(Map<Id, Id> oppVSAssetId) {
        Map<Id, Attachment> assetVsAttachment = new Map<Id, Attachment>();
        try {
            Set<Id> included = new Set<Id>();
            for (Attachment attach: [SELECT ParentId, Body, Name FROM Attachment WHERE ParentId IN :oppVSAssetId.keySet() AND Name Like '%InsertionOrder%' Order By CreatedDate Desc]) {
                if (!included.contains(attach.ParentId)) {
                    included.add(attach.ParentId);
                    assetVsAttachment.put(oppVSAssetId.get(attach.ParentId), attach); 
                }
            }
        }
        catch (Exception e) {
            system.debug('fetchAssetAttachments :: ' + e.getMessage());
        }
        return assetVsAttachment;
    }
    
    // function to send email with attachment
    private static boolean sendEmailToCake(List<Asset> assets, Map<Id, Attachment> assetVsAttachment) {
        Boolean retVal = true;
        Id mortgageTemplateId = [SELECT Id FROM EmailTemplate WHERE Name = 'Mortgage Email'].Id;
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for (Asset asset : assets) {
            Attachment attach = assetVsAttachment.get(asset.Id);
            if (attach != null || asset.Line_Type__c != 'Add') { 
                Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(mortgageTemplateId, null, asset.Id);
                if (attach != null) {
                    Messaging.Emailfileattachment IOAttach = new Messaging.Emailfileattachment();
                    IOAttach.setFileName(attach.Name);
                    IOAttach.setBody(attach.Body);
                    List <Messaging.EmailFileAttachment> attachments = mail.getFileAttachments();
                    attachments.add(IOAttach);
                    mail.setFileAttachments(attachments);
                }
                mail.setToAddresses(Label.Mortgage_Cake_User_Email_Address.split(';'));
                List<String> ccAddresses = new List<String>{asset.Account.Owner.Email};
                if (asset.Sign_in_AE__r.Email != null) {
                    ccAddresses.add(asset.Sign_in_AE__r.Email);
                }
                mail.setCcAddresses(ccAddresses);
                mail.setReplyTo(Label.Mortgage_Cake_User_Email_Reply_To_Address);
                mail.saveAsActivity = false;
                mails.add(mail);
            }
            else {
                retVal = false;
            }
        }
        if (mails.size() > 0) { 
            Messaging.sendEmail(mails);
        }
        return retVal;
    }
    
    // Asset custom button function to resend email
    webservice static boolean sendEmailFromAsset(Id assetId) {
       return sendEmail(new List<Id>{assetId});
    }
}