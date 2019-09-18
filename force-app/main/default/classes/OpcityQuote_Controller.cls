// CRM-6098,CRM-6197 & CRM-6063 - Opcity BLA Quote Controller
public class OpcityQuote_Controller {
    public Account brokerAcc;
    public Asset tempAsset {get; set;}
    public List<OfficeDetail> offices {get; set;}
    public String retUrl {get; set;}
    public String quoteName {get; set;}
    public String currentPartyId {get; set;}
    public String currentMSA {get; set;}
    public List<SelectOption> confirmedSourceOptions {get; set;}
    public List<SelectOption> unConfirmedSourceOptions {get; set;}
    public List<SelectOption> contractTerms {get; set;}
    public List<SelectOption> prodTypes {get; set;}
    private static String defaultContractTerm;
    public Map<String, List<String>> stateVsMsa {get; set;}
    public Date launchDate { 
            get {
                return tempAsset.Launch_Date__c;
            }    
            set {
                tempAsset.Launch_Date__c = value;
            }
        }
    
    private static Set<String> states;
    private List<SelectOption> setConfirmedSourceOptions() {
        List<SelectOption> options = new List<SelectOption>();
        for (Opcity_Settings__c setting : [SELECT value__c FROM Opcity_Settings__c WHERE Type__c='Source' AND Category__c='Confirmed' Order By Order__c asc]) {
            options.add(new SelectOption(setting.value__c,setting.value__c));
        }
        return options;
    }
    
    private List<SelectOption> setUnconfirmedSourceOptions() {
        List<SelectOption> options = new List<SelectOption>();
        for (Opcity_Settings__c setting : [SELECT value__c FROM Opcity_Settings__c WHERE Type__c='Source' AND Category__c='Unconfirmed' Order By Order__c asc]) {
            options.add(new SelectOption(setting.value__c,setting.value__c));
        }
        return options;
    }
    
    private List<SelectOption> setProdTypeOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','None'));
        options.add(new SelectOption('CONFIRMED','Confirmed Quality: 20%'));
        options.add(new SelectOption('UNCONFIRMED','Non-Confirmed Quality: 10%'));
        return options;
    }
    
    private List<SelectOption> setContractTermOptions(String activeContractTerms) {
        List<SelectOption> options = new List<SelectOption>();
        for (String str : activeContractTerms.split(';')) {
            options.add(new SelectOption(str,str));
        }
        return options;
    }
    
    public List<String> confirmedSources { 
        get {
            return new List<String>();
        } 
        set;
    }
    
    public List<String> unConfirmedSources { 
        get {
            return new List<String>();
        } 
        set;
    }
    
    public class OfficeDetail {
        public Boolean selected {get; set;}
        public Asset fulfillToAsset {get; set;}
        public Asset fulfillToCoreAsset {get; set;}
        public Account fulfillToAccount {get; set;}
        public String action {get; set;}
        public List<SelectOption> actions {get; set;}
        public String inflight {get; set;}
        public String address {get; set;}
        public Date launchDate { 
            get {
                return fulfillToAsset.Launch_Date__c;
            }    
            set {
                fulfillToAsset.Launch_Date__c = value;
            }
        }
        public List<String> msa {get;set;}
        private String selectedConfirmedSources;
        private String selectedUnConfirmedSources;
        public List<String> confirmedSources { 
            get {
                List<String> selected = new List<String>();
                    for(String str : fulfillToAsset.Source__c.split(';')) {
                        selected.add(str);
                    }
                    return selected;
            } 
            set {
                String selectedCheckBox = '';
                for(String s : value) {
                    if (selectedCheckBox == '') {
                        selectedCheckBox += s;
                    }
                    else {
                        selectedCheckBox += ';' + s;
                    }
                }
                selectedConfirmedSources = selectedCheckBox;
            }
        }
        
        public List<String> unConfirmedSources { 
            get {
                List<String> selected = new List<String>();
                    for(String str : fulfillToAsset.Source__c.split(';')) {
                        selected.add(str);
                    }
                    return selected;
            } 
            set {
                String selectedCheckBox = '';
                for(String s : value) {
                    if (selectedCheckBox == '') {
                        selectedCheckBox += s;
                    }
                    else {
                        selectedCheckBox += ';' + s;
                    }
                }
                selectedUnConfirmedSources = selectedCheckBox;
            }
        }
        
        public OfficeDetail(Account acc, Asset asset, Asset coreAsset) {
            
            fulfillToAccount = acc;
            fulfillToAsset = asset;
            fulfillToCoreAsset = coreAsset;
            address = acc.ShippingStreet + ' ' + acc.ShippingCity + ' ' + acc.ShippingState + ' ' + acc.ShippingPostalCode + ' ' + acc.ShippingCountry;
            address = address.replaceAll('null', '');
            actions = new List<SelectOption>();
            selected = false;
            if (fulfillToAsset == null) {
                fulfillToAsset = new Asset();
                fulfillToAsset.Source__c = '';
                fulfillToAsset.AccountId = acc.Id;
                fulfillToAsset.Backup_Monthly_Plan__c  = '$1200 (100 leads @ $12/Lead)';
                fulfillToAsset.Launch_Date__c = System.today().addDays(14);
                fulfillToAsset.Contract_Term__c = defaultContractTerm;
                actions.add(new SelectOption('add','Add'));
            }
            else {
                if (asset.Fulfillment_Status__c == 'Manual') {
                    inflight = ' In Progress';
                }
                actions.add(new SelectOption('amend','Amend'));
                actions.add(new SelectOption('cancel','Cancel'));
            }
            //launchDate = fulfillToAsset.Launch_Date__c;
            if (fulfillToAsset.Source__c == null) {
                fulfillToAsset.Source__c = '';
            }
            if (fulfillToAsset.Opcity_State__c != null) {
                states.add(fulfillToAsset.Opcity_State__c);
            }
            if (fulfillToAsset.Opcity_MSA__c != null && fulfillToAsset.Opcity_MSA__c != '' && fulfillToAsset.Opcity_MSA__c.length()>0) {
                msa = fulfillToAsset.Opcity_MSA__c.split(';');
            }
        }
    }
    
    public PageReference pageLoadAction() {
        PageReference returnP = null;
        Id accId = ApexPages.currentPage().getParameters().get('id');
        if (accId != null) {
            try {
                List<Bigmachines__Quote__c> pendingQuote = [SELECT Id, Name FROM Bigmachines__Quote__c WHERE BigMachines__Account__c=:accId AND BigMachines__Status__c='Pending Focusfire Setup' Order By CreatedDate DESC LIMIT 1];
                if (pendingQuote.size() > 0) {
                    returnP = new PageReference('/apex/BLAQuoteFocusFireView?quoteId='+pendingQuote[0].Id);
                }
                else {
                    brokerAcc = [SELECT Id, Party_Id__c,Past_Due__c,Credit_Risk__c FROM Account WHERE Id = :accId];
                    List<Contact> contacts = [SELECT Email, Phone, FirstName, LastName, Title FROM Contact WHERE ID IN 
                                              (SELECT Contact_To__c FROM Account_Relationship__c WHERE Parent_Account__c = :brokerAcc.ID
                                               AND Active__c=true AND RecordType.Name='Contact Relationship' AND (Is_Parent_Primary__c=true OR Contact_Role__c='Primary Contact')) LIMIT 1];
                    Contact primaryContact = null;
                    if (contacts.size() > 0) {
                        primaryContact = contacts[0];
                    }
                    List<String> errorMessages = validateContact(primaryContact,brokerAcc);
                    if (errorMessages.size()>0) {
                        for (String error : errorMessages) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, error));
                        }
                    }
                    else {
                        List<String> blaProductCodes = Label.Opcity_BLA_Product_Codes.split(',');
                        for (Account officeAcc : [SELECT Id,Name,Party_Id__c,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,Office_Agent_BLA__c,
                          (SELECT can_disclose_fees__c,unlicensed_state_leads__c,Id,Parent_Asset__r.Extended_Net_Price__c,Sign_in_AE__r.Name,Fulfillment_Status__c,Product_Type__c,Setup_Fee__c,Backup_Monthly_Plan__c,Launch_Date__c,Contract_Term__c,
                           Expected_Monthly_Lead_Volume__c,Source__c,Parent_Asset__c,AccountId,Opcity_State__c,Opcity_MSA__c,Product_Code__c FROM Assets WHERE 
                           (Product_Code__c IN :blaProductCodes OR Product_Code__c = 'OPCITYCORE') AND ((Fulfillment_Status__c='Fulfilled' AND Status='Active') 
                            OR (Fulfillment_Status__c='Manual'))) FROM Account WHERE Id IN (SELECT Child_Account__c FROM Account_Relationship__c 
                            WHERE Parent_Account__c = :accId AND Active__c=true AND Child_Account__r.Type='Realtor Office' AND 
                            Parent_Account__r.Type='Broker')]) {
                                Asset fulfillToAsset = null;    // BLA
                                Asset fulfillToCoreAsset = null;    // CORE
                                for (Asset ast : officeAcc.assets) {
                                    if (ast.Product_Code__c == 'OPCITYCORE') {
                                        fulfillToCoreAsset = ast;
                                    }
                                    else if (blaProductCodes.contains(ast.Product_Code__c)) {
                                        fulfillToAsset = ast;
                                    }
                                }
                                offices.add(new OfficeDetail(officeAcc, fulfillToAsset, fulfillToCoreAsset));
                            }
                    }
                }
            }
            catch (Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            }
        }
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No Account Id found in the Url!'));
        }
        return returnP;
    }
    public OpcityQuote_Controller () {
        tempAsset = new Asset();
        tempAsset.Launch_Date__c = System.today().addDays(14);
        // Set picklist options
        stateVsMsa = new Map<String, List<String>>();
        states = new Set<String>();
        confirmedSourceOptions = setConfirmedSourceOptions();
        unConfirmedSourceOptions = setUnconfirmedSourceOptions();
        prodTypes = setProdTypeOptions();
        Product2 BLAProd = [SELECT Default_Term__c, Active_Contract_Terms__c FROM Product2 WHERE ProductCode='OPCITYBLA' LIMIT 1];
        contractTerms = setContractTermOptions(BLAProd.Active_Contract_Terms__c);
        defaultContractTerm = BLAProd.Default_Term__c;
        offices = new List<OfficeDetail>();
        for (Opcity_MSA__c rec : [SELECT Name__c, State__c FROM Opcity_MSA__c Order by Name__c]) {
            List<String> msa = stateVsMsa.get(rec.State__c);
            if (msa == null) {
                msa = new List<String>();
            }
            msa.add(rec.Name__c);
            stateVsMsa.put(rec.State__c, msa);
        }  
    }
    
    public class CPQJson {
        Public String partyId {get; set;}
        List<Office> offices {get; set;}
    }
    
    public class Office {
        public String partyId {get; set;}
        public String officeName_l {get; set;}
        public String action {get; set;}
        public String productType_line {get; set;}
        public Decimal oneTimeSetupFee_line {get; set;}
        public String bLAMonthlyPlan_l {get; set;}
        public Date launchDate {get; set;}
        public String contractTerms_line {get; set;}
        public Integer expectedNoOfLeads_l {get; set;}
        public String leadSource_l {get; set;}
        public String fulfillToAssetID_l {get; set;}
        public String assetID_l {get; set;}
        public String fulfillToOfficeID_l {get; Set;}
        public String officeAgentBla_l {get; set;}
        public String inflight {get; set;}
        public String officeAddress_l {get; set;}
        public String state {get; set;}
        public String market {get; set;}
        public String coreFulfillToAssetId {get; set;}
        public Decimal assetPrice_line {get; set;}
        public Boolean unlicensed_state_leads_l {get; set;}
        public Boolean can_disclose_fees_l {get; set;}
        
        public Office() {}
        public Office(OfficeDetail detail) {
            fulfillToAssetID_l  = '';
            assetID_l = '';
            coreFulfillToAssetId = '';
            
            this.partyId = detail.fulfillToAccount.Party_Id__c;
            this.officeName_l = EncodingUtil.urlEncode(detail.fulfillToAccount.Name,'UTF-8');
            officeAgentBla_l = detail.fulfillToAccount.Office_Agent_BLA__c != null ? detail.fulfillToAccount.Office_Agent_BLA__c : '';
            action = detail.action != null ? detail.action : '';
            inflight = detail.inflight != null ? detail.inflight : '';
            this.officeAddress_l = EncodingUtil.urlEncode(detail.address,'UTF-8');
            
            // Asset fields
            productType_line = detail.fulfillToAsset.Product_Type__c != null ? detail.fulfillToAsset.Product_Type__c : '';
            oneTimeSetupFee_line = detail.fulfillToAsset.Setup_Fee__c != null ? detail.fulfillToAsset.Setup_Fee__c : 0;
            bLAMonthlyPlan_l = detail.fulfillToAsset.Backup_Monthly_Plan__c != null ? detail.fulfillToAsset.Backup_Monthly_Plan__c : '';
            launchDate = detail.fulfillToAsset.Launch_Date__c != null ? detail.fulfillToAsset.Launch_Date__c : system.today();
            contractTerms_line = detail.fulfillToAsset.Contract_Term__c != null ? detail.fulfillToAsset.Contract_Term__c : '';
            expectedNoOfLeads_l = detail.fulfillToAsset.Expected_Monthly_Lead_Volume__c != null ? Integer.valueOf(detail.fulfillToAsset.Expected_Monthly_Lead_Volume__c) : 0;
            leadSource_l = detail.fulfillToAsset.Source__c != null ? detail.fulfillToAsset.Source__c : '';
            market = detail.fulfillToAsset.Opcity_MSA__c != null ? detail.fulfillToAsset.Opcity_MSA__c : '';
            state = detail.fulfillToAsset.Opcity_State__c!= null ? detail.fulfillToAsset.Opcity_State__c: '';
            assetPrice_line = detail.fulfillToAsset.Parent_Asset__r.Extended_Net_Price__c!=null?detail.fulfillToAsset.Parent_Asset__r.Extended_Net_Price__c:0;
            unlicensed_state_leads_l = detail.fulfillToAsset.unlicensed_state_leads__c;
            can_disclose_fees_l = detail.fulfillToAsset.can_disclose_fees__c;
            if (detail.fulfillToAsset.Id != null) {
                fulfillToAssetID_l  = detail.fulfillToAsset.Id;
                assetID_l = detail.fulfillToAsset.Parent_Asset__c;
            }
            fulfillToOfficeID_l = detail.fulfillToAsset.AccountId;
            if (detail.fulfillToCoreAsset != null) {
                coreFulfillToAssetId = detail.fulfillToCoreAsset.Id;
            }
            
        }
    }
    
    public List<String> validateContact(Contact primaryContact, Account brokerAccount) {
        List<String> errorMessages = new List<String>();
        if (primaryContact == null) {
            errorMessages.add('There is no Primary Contact related to this Account. Please add a new contact or mark an existing contact as primary');
        }
        else {
            if (primaryContact.firstName == null || primaryContact.firstName == '') {
                errorMessages.add('Please update the primary contact name');
            }
            if (primaryContact.lastName == null || primaryContact.lastName == '') {
                errorMessages.add('Please update the primary contact name');
            }
            if (primaryContact.title == null || primaryContact.title == '') {
                //errorMessages.add('Primary Contact Title is not updated!');
            }
            if (primaryContact.email == null || primaryContact.email == '') {
                errorMessages.add('Please update the email address on the Primary Contact of Account.');
            }
            if (primaryContact.email.startswith('bad_') || primaryContact.email.endswith('@default.com')) {
                errorMessages.add('The Primary email on the Account is flagged as a Bad Email. Please contact Sales Operations for assistance.');
            }
            if (primaryContact.phone == null || primaryContact.phone == '') {
                errorMessages.add('Please update the phone number on the Primary Contact of Account.');
            }
        }
        if(brokerAccount.Past_Due__c == true)
        {
            errorMessages.add('This account is Past Due. Please clear the Past Due before creating a quote.');
        }
        if(brokerAccount.Credit_Risk__c == true)
        {
            errorMessages.add('This account is marked as a credit risk. Please contact finance before creating a quote.');
        }
        return errorMessages;
    }
   
    public PageReference createCPQQuote() {
        PageReference returnP = null;
        retUrl = null;
        CPQJson jsonObj = new CPQJson();
        jsonObj.partyId = brokerAcc.Party_id__c;
        jsonObj.offices = new List<Office>();
        updateAllAssetSources();
        for (OfficeDetail officeDetail : offices) {
            if (officeDetail.selected) {
                jsonObj.offices.add(new Office(officeDetail));
            }
        }
        
        system.debug(JSON.serialize(jsonObj));
        OpcityBLACPQUtility cpqUtility = new OpcityBLACPQUtility();
        cpqUtility.accountId = brokerAcc.Id;
        cpqUtility.opcityBlaJson = JSON.serialize(jsonObj);
        OpcityBLACPQUtility.SfdcQuote quote = cpqUtility.createBLAQuote();
        if (quote == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Quote creation failed!'));
        }
        else {
            retUrl = quote.editUrl;
            quoteName = quote.name;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Quote# ' + quoteName + ' has been created!'));
            returnP = new PageReference('/apex/BLAQuoteFocusFireView?new=1&quoteId='+quote.Id);
        }
        
        return returnP;
    }
   
    public void saveMsa() {
        for (OfficeDetail officeDetail : offices) {
            if (officeDetail.fulfillToAccount.Party_Id__c == currentPartyId) {
                officeDetail.fulfillToAsset.Opcity_MSA__c = currentMSA;
                if (officeDetail.fulfillToAsset.Opcity_MSA__c != null && officeDetail.fulfillToAsset.Opcity_MSA__c != '' && officeDetail.fulfillToAsset.Opcity_MSA__c.length()>0) {
                    officeDetail.msa =  officeDetail.fulfillToAsset.Opcity_MSA__c.split(';');
                }
                break;
            }
        }
        updateAllAssetSources();
    }
   
    public void updateAllAssetSources() {    
        for (OfficeDetail officeDetail : offices) {
            officeDetail.fulfillToAsset.Source__c = '';
            if (officeDetail.selectedConfirmedSources != '') {
                officeDetail.fulfillToAsset.Source__c = officeDetail.selectedConfirmedSources;
            }
            if (officeDetail.selectedUnConfirmedSources != '') {
                if (officeDetail.fulfillToAsset.Source__c != '') {
                    officeDetail.fulfillToAsset.Source__c += ';';
                }
                officeDetail.fulfillToAsset.Source__c += officeDetail.selectedUnConfirmedSources;
            }
        }
    }
}