// CRM-6197 - Opcity BLA Focus Fire view Controller
public class BLAQuoteFocusFireView_Controller {
    public Map<Integer, FocusFireAccountDetail> focusFireAccounts {get; set;}
    private String quoteId;
    Static Contact primaryContact;
    private static Map<String, String> contractTypes = new Map<String, String>();
    private static Map<String, String> contractMonthlyPlan = new Map<String, String>();
    
    public class FocusFireAccountDetail {
        public Bigmachines__Quote_Product__c quoteProd {get; set;}
        public Account officeAccount {get; set;}
        public Account brokerAccount {get; set;}
        public String focusFireUrl {get; set;}
        
        public FocusFireAccountDetail(Bigmachines__Quote_Product__c  qp) {
            this.quoteProd = qp;
            officeAccount = qp.Product_Account__r;
            brokerAccount = qp.BigMachines__Quote__r.BigMachines__Account__r;
            setFocusFireUrl();
        }
        
        private void setFocusFireUrl() {
            focusFireUrl = Label.FocusFireUrl;
            focusFireUrl  += 'party_id=' + officeAccount.Party_Id__c;
            focusFireUrl  += '&name=' + EncodingUtil.urlEncode(officeAccount.Name + ' - PID:' + officeAccount.Party_Id__c,'UTF-8');
            if (brokerAccount.Email_Address__c != null && brokerAccount.Email_Address__c != '') {
                focusFireUrl  += '&contact_email=' + EncodingUtil.urlEncode(brokerAccount.Email_Address__c, 'UTF-8');
            }
            if (brokerAccount.Phone != null && brokerAccount.Phone != '') {
                focusFireUrl  += '&contact_phone=' + EncodingUtil.urlEncode(brokerAccount.Phone,'UTF-8');
            }
            String address = officeAccount.ShippingStreet + ' ' + officeAccount.ShippingCity + ' ' + officeAccount.ShippingState + ' ' + officeAccount.ShippingPostalCode + ' ' + officeAccount.ShippingCountry;
            address = address.replaceAll('null', '');
            if (address != null && address != '') {
                focusFireUrl  += '&address=' + EncodingUtil.urlEncode(address,'UTF-8');
            }
            if (quoteProd.BigMachines__Quote__r.Owner.Name != null && quoteProd.BigMachines__Quote__r.Owner.Name != '') {
                focusFireUrl  += '&sales_rep=' + EncodingUtil.urlEncode(quoteProd.BigMachines__Quote__r.Owner.Name,'UTF-8');
                focusFireUrl  += '&bla_sales_rep=' + EncodingUtil.urlEncode(quoteProd.BigMachines__Quote__r.Owner.Name,'UTF-8');    // CRM-6384
            }
            //focusFireUrl  += '&secondary_bla_sales_rep=' + TO DO;
            //focusFireUrl  += '&implementation_manager=' + TO DO;
            focusFireUrl  += '&account_manager=Pooled';
            if (primaryContact != null) {
                if (primaryContact.FirstName != null && primaryContact.FirstName != '') {
                    focusFireUrl  += '&contact_first_name=' + EncodingUtil.urlEncode(primaryContact.FirstName,'UTF-8');
                }
                if (primaryContact.LastName != null && primaryContact.LastName != '') {
                    focusFireUrl  += '&contact_last_name=' + EncodingUtil.urlEncode(primaryContact.LastName,'UTF-8');
                }
                if (primaryContact.Title != null) {
                    focusFireUrl  += '&contact_title=' + EncodingUtil.urlEncode(primaryContact.title,'UTF-8');
                }
            }
            if (quoteProd.Setup_Fee__c != null) {
                focusFireUrl  += '&contract_setup_fee='+quoteProd.Setup_Fee__c; //+ officeAccount.;
            }
            
            if (quoteProd.Product_Type__c != null && contractTypes.containsKey(quoteProd.Product_Type__c)) {
                focusFireUrl  += '&contract_type='+EncodingUtil.urlEncode(contractTypes.get(quoteProd.Product_Type__c),'UTF-8');
                
            }
            if (quoteProd.Product_Type__c != 'CONFIRMED' && quoteProd.Backup_Monthly_Plan__c != null && contractMonthlyPlan.containsKey(quoteProd.Backup_Monthly_Plan__c)) {
                focusFireUrl  += '&contract_monthly_plan='+EncodingUtil.urlEncode(contractMonthlyPlan.get(quoteProd.Backup_Monthly_Plan__c),'UTF-8');
                
            }
            if (quoteProd.Launch_Date__c != null) {
                focusFireUrl  += '&contract_start_date='+ EncodingUtil.urlEncode(quoteProd.Launch_Date__c.year() + '-' + quoteProd.Launch_Date__c.month() + '-' + quoteProd.Launch_Date__c.day(), 'UTF-8');
            }
            focusFireUrl  += '&unlicensed_state_leads=' + quoteProd.unlicensed_state_leads__c;
            focusFireUrl  += '&source_origin='+EncodingUtil.urlEncode(System.URL.getSalesforceBaseUrl().toExternalForm(), 'UTF-8');
            focusFireUrl  += '&can_disclose_fees=' + quoteProd.can_disclose_fees__c;
            focusFireUrl  += '&contract_expected_volume='+quoteProd.Expected_Monthly_Lead_Volume__c;
            if (quoteProd.Opcity_MSA__c!=null && quoteProd.Opcity_MSA__c!='') {
                for (String msa : quoteProd.Opcity_MSA__c.split(';')) {
                    focusFireUrl  += '&markets='+ EncodingUtil.urlEncode(msa,'UTF-8');
                }
            }
            focusFireUrl  += '&contract_length='+quoteProd.Contract_Term__c;
            if (quoteProd.Source__c!=null && quoteProd.Source__c!='') {
                for (String source : quoteProd.Source__c.split(';')) {
                   focusFireUrl  += '&contract_expected_lead_sources='+ EncodingUtil.urlEncode(source,'UTF-8');
                }
            }
            //focusFireUrl  += '&contract_type='+EncodingUtil.urlEncode('non-confirmed quality AdvantagePro','UTF-8'); //+ officeAccount.;
            //focusFireUrl  += '&markets=' + (quoteProd.Opcity_MSA__c!=null?EncodingUtil.urlEncode(quoteProd.Opcity_MSA__c,'UTF-8'):'');
            //focusFireUrl  += '&markets=Charleston,%20SC&markets=Florence,%20SC&markets=Columbia,%20MO';
            //focusFireUrl  += '&contract_expected_lead_sources=Realtor.com&contract_expected_lead_sources=Zillow';
            
            system.debug(focusFireUrl);
        }
    }
    
    public BLAQuoteFocusFireView_Controller() {
        focusFireAccounts = new Map<Integer, FocusFireAccountDetail>();
        quoteId = ApexPages.currentPage().getParameters().get('quoteId');
        if (quoteId != null) {
            for (Opcity_Settings__c contractTypeSetting : [SELECT Category__c,Value__c, Type__c FROM Opcity_Settings__c WHERE Category__c='ContractType' OR Category__c='Contract_Monthly_Plan']) {
                if (contractTypeSetting.Category__c == 'ContractType'){
                    contractTypes.put(contractTypeSetting.Type__c, contractTypeSetting.Value__c);
                }
                else{
                    contractMonthlyPlan.put(contractTypeSetting.Type__c, contractTypeSetting.Value__c);
                }
            }
            Bigmachines__Quote__c quote = [SELECT Bigmachines__Account__c, Name FROM Bigmachines__Quote__c WHERE ID =:quoteId];
            List<Contact> contacts = [SELECT firstname, lastname, title FROM Contact WHERE ID IN 
                            (SELECT Contact_To__c FROM Account_Relationship__c WHERE Parent_Account__c = :quote.Bigmachines__Account__c 
                            AND Active__c=true AND RecordType.Name='Contact Relationship' AND (Is_Parent_Primary__c=true OR Contact_Role__c='Primary Contact')) LIMIT 1];
            if (contacts.size() > 0) {
                primaryContact = contacts[0];
            }
            String isNew = ApexPages.currentPage().getParameters().get('new');
            String msg = 'Quote# ' + quote.Name + ' is due for Focus Fire Setup!';
            if (isNew != null) {
                msg = 'Quote# ' + quote.Name + ' has been created!';
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, msg));
    
            Integer i=0;
            List<String> blaProductCodes = Label.Opcity_BLA_Product_Codes.split(',');
            for (Bigmachines__Quote_Product__c qp : [SELECT Backup_Monthly_Plan__c,Focus_Fire_Id__c,can_disclose_fees__c,unlicensed_state_leads__c,Product_Type__c ,Setup_Fee__c,Expected_Monthly_Lead_Volume__c,Source__c,Contract_Term__c,Launch_Date__c,Bigmachines__Quote__r.BigMachines__Account__c, Id,Line_Type__c,Focus_Fire_Status_Completed__c ,Opcity_MSA__c,Product_Account__c,BigMachines__Quote__r.Owner.Name,Product_Account__r.Party_Id__c, Product_Account__r.ShippingStreet,Product_Account__r.ShippingCity,
                Product_Account__r.Focus_Fire_Url__c,Product_Account__r.ShippingState,Product_Account__r.ShippingPostalCode,Product_Account__r.ShippingCountry,Product_Account__r.Name,BigMachines__Quote__r.BigMachines__Account__r.Email_Address__c,BigMachines__Quote__r.BigMachines__Account__r.Phone FROM Bigmachines__Quote_Product__c WHERE BigMachines__Quote__c=:quoteId 
                AND BigMachines__Product__r.ProductCode IN :blaProductCodes AND Focus_Fire_Status_Completed__c=false]) {
                if (qp.Product_Account__c != null) {
                    FocusFireAccountDetail focusFireOffice = new FocusFireAccountDetail(qp);
                    focusFireAccounts.put(i, focusFireOffice);
                    i++;
                }
                else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Quote Product is not Linked to any Office Account!'));
                }
            }
        }
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No Quote Id found in the Url!'));
        }
    }
    
    public void finish() {
        Boolean completed = true;
        for (FocusFireAccountDetail detail : focusFireAccounts.values()) {
            if (!detail.quoteProd.Focus_Fire_Status_Completed__c) {
                completed = false;
                break;
            }
        }
        if (!completed) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Focusfire setup is not yet completed for one or more office(s)!'));
        }
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Focusfire setup has been completed!'));
        }
    }
    
    public void updateQuoteProduct() {
        Integer currentIndex = Integer.valueOf(Apexpages.currentPage().getParameters().get('qpId'));
        BigMachines__Quote_product__c qp = focusFireAccounts.get(currentIndex).quoteProd;
        qp.Stage__c = Apexpages.currentPage().getParameters().get('stage');
        String opId = Apexpages.currentPage().getParameters().get('opId');
        if (opId != null && qp.Focus_Fire_Id__c == null) {
            qp.Focus_Fire_Id__c = opId;
        }
        if (qp.Stage__c == 'Agreement Sent') {
            qp.Focus_Fire_Status_Completed__c = true;
        }
        update qp;
    }
}