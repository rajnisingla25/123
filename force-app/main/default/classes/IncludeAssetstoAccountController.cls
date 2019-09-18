public class IncludeAssetstoAccountController {
    Integer pageSize = 100;
    ApexPages.StandardSetController setCon;
    Map<Id, Asset> assetIncludeFlagMap = new Map<Id, Asset>();
    String baseWhereClause;
    Boolean defaultSearchQuery;
    String defaultSortField = 'End_Date__c';
    String defaultSortingOrder = 'DESC';
    
    public List<Asset> assetRecords {get; set;}
    public String accName {get; set;}
    public Integer recCount {get; set;}
    public Boolean allCheck {get; set;}
    public String ascDsc {get; set;}
    public String sortField {get; set;}
    public String baseurl{get;set;}
    Public Date rendat{get;set;} 
    public Asset assetDate { get; set; } //Added for CRM-3280
    public static date StartDateBegin  { get; set; }
    public static date StartDateEnd  { get; set; }
    public static date EndDateBegin  { get; set; }
    public static date EndDateEnd  { get; set; }
    public string assetNumber {get;set;}
    public string market {get;set;}
    Public String accId{get;set;}
    
    public IncludeAssetstoAccountController() {
        //CRM-3147
        defaultSearchQuery = false;
        ascDsc = defaultSortingOrder;
        sortField = defaultSortField;
        if(rendat==null){rendat =System.Date.today().toStartOfMonth().addMonths(1).addDays(-1);}
        assetDate = new Asset(); //Added for CRM-3280
        baseurl = System.URL.getSalesforceBaseUrl().toExternalForm(); //CRM-2530
        assetRecords = new List<Asset>();
        accId = '';
        accId = ApexPages.CurrentPage().getparameters().get('id');
               
        if (accId != null) {
            List<Account> accs = [SELECT Name FROM Account WHERE Id = :accId LIMIT 1];
            if (accs.size() > 0) {
            System.debug(accs);
                accName = accs[0].Name; //AND End_Date__c<:rendat
                system.debug(accName);
                Set<String> setRenewalStatus = new Set<String>();
                        setRenewalStatus.add('Do Not Renew');
                        setRenewalStatus.add('Pending Fulfillment');
                baseWhereClause = ' WHERE Status = \'Active\' and Fulfillment_Status__c=\'Fulfilled\' and Product2.Beta__c=false and (Renewal_Status__c !=\'Pending Fulfillment\' AND Renewal_Status__c !=\'Do Not Renew\' )and Renewal_Start_Date__c=null and Renewal_Type__c!=\'Auto\' and Haircut_Asset__c=false and End_Date__c<:rendat AND accountId =\''+ String.escapeSingleQuotes(accId)+'\' and asset_type__c = \'Parent\'';
                //baseWhereClause = ' WHERE Status = \'Active\' AND End_Date__c<:rendat AND accountId =\''+ String.escapeSingleQuotes(accId)+'\' and asset_type__c = \'Parent\'';
                
                search();
defaultSearchQuery = true;
            }
        }
    }
 
    public Boolean hasNext {
        get {
            Boolean hasNext = false;
            if (setCon != null)
                hasNext = setCon.getHasNext();
            return hasNext;
        }
        set;
    }
    public Boolean hasPrevious {
        get {
            Boolean hasPrevious = false;
            if (setCon != null)
                hasPrevious = setCon.getHasPrevious();
            return hasPrevious;
        }
        set;
    }

    public void first() {
        updateAssetMap();
        setCon.first();
        setAssets();
    }

    public void previous() {
        updateAssetMap();
        setCon.previous();
        setAssets();
    }

    public void next() {
        updateAssetMap();
        setCon.next();
        setAssets();
    }

    public void last() {
        updateAssetMap();
        setCon.last();
        setAssets();
    }

    
    public void search() {
        try {
        if(defaultSearchQuery){
        baseWhereClause = ' WHERE Status = \'Active\' AND accountId =\''+ String.escapeSingleQuotes(accId)+'\' and asset_type__c = \'Parent\'';                
            }
            updateAssetMap();
            //if(rendat==null){rendat =system.today().addMonths(600);}
            //CRM-2874 Adding Asset Performance, Licenses and Renewal type fields to the query // CRM -5916/6050 Added NR Reason and EG Flag 
            String query = 'SELECT id,Reason__c,Reason_Details__c,Prosoft_Evergreen_Renewal__c,Follow_Up_Status__c, Haircut_Asset__c, Non_Renewable_Reason__c, Asset_Id__c, Asset_Number__c, name,MLS_Set__r.Name, Commerce_Group__c, Auto_Renewal__c, BOP_Code__c,' +
                    'Renewal_Status__c, asset_type__c,Product_Type__c, Status, parent_asset__c, Quantity, Include_Asset__c,' +
                    'ultimate_parent__c,Start_Date__c,Fulfillment_Status__c, End_Date__c, Lead_Type__c,' +
                    'Total_Net__c, Extended_Net_Price__c,Asset_Performance__c,License_Tier__c,Renewal_Type__c,Market_Zip__c,Market__c,ARIIPrice_Info_Status__c FROM asset';
            query = query + baseWhereClause;
            if(startDateBegin != null && startDateEnd != null) {
                query = query + ' AND (Start_Date__c >='+ getStringDate(startDateBegin) +' AND Start_Date__c <= '+ getStringDate(startDateEnd)+ ')';
            }
            if(EndDateBegin != null && EndDateEnd != null) {
                query = query + ' AND (End_Date__c >='+ getStringDate(EndDateBegin) +' AND End_Date__c <= '+ getStringDate(EndDateEnd)+ ')';
            }
            if (assetNumber != null && string.isNotBlank(assetNumber)) {
               // query = query + ' AND (Asset_Number__c =\'' + String.escapeSingleQuotes(assetNumber) +'\')';
               List<string> assetNumbers = new List<string>();
               assetNumbers = assetNumber.split(',');
               query = query + ' AND (Asset_Number__c IN :assetNumbers)';
            }
            
            if (market != null && string.isNotBlank(market)) {
               List<string> markets = new List<string>();
               markets = market.split(',');
               query = query + ' AND (Market__c IN :markets)';
            }
            
            ascDsc = ascDsc.equals('ASC') ? 'DESC' : 'ASC';
            query = query + ' ORDER BY ' + sortField + ' ' + ascDsc + ' LIMIT 10000';
            system.debug('SOQL:' + query);
            setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query));
            if (setCon == null || setCon.getResultSize() == 0) {
            String errormsg = 'The assets on this account do not have a start date or end date in this date range. Please select a new valid date range.';
            if(!defaultSearchQuery){
            errormsg = 'There are no assets available for manual renewal this month. Please click the Show All button to see all assets';
            }
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errormsg));
            }
            setCon.setPageSize(pageSize);
            setAssets();
            recCount = assetRecords.size();
        }
        catch(Exception e) {
             ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.Error,e.getMessage());
             ApexPages.addMessage(myMsg) ;
        }
    }

    private void setAssets() {
        assetRecords.clear();
        allCheck = true;
        for (Asset assetRec : (List<Asset>)setCon.getRecords().deepClone(true, true, true)) {
            Boolean flag = false;
            if(assetIncludeFlagMap.containskey(assetRec.Id)){ flag = assetIncludeFlagMap.get(assetRec.Id).Include_Asset__c;
            }
            if (flag != null) {
                assetRec.Include_Asset__c = flag;
            }
            assetRecords.add(assetRec);
            if (!assetRec.Include_Asset__c) {
                allCheck = false;
            }
        }
    }
    
    private void updateAssetMap() {
        for (Asset asset : assetRecords) {
            assetIncludeFlagMap.put(asset.Id, asset);
        }
    }
    
    public void Save() {
        try {
            updateAssetMap();
            List<Asset> toBeUpdatedAssets = new List<Asset>();
            for (Id assetId : assetIncludeFlagMap.keySet()) {
                toBeUpdatedAssets.add(new Asset(Id=assetId,Reason__c=assetIncludeFlagMap.get(assetId).Reason__c,Reason_Details__c=assetIncludeFlagMap.get(assetId).Reason_Details__c,Follow_Up_Status__c=assetIncludeFlagMap.get(assetId).Follow_Up_Status__c, Include_Asset__c=assetIncludeFlagMap.get(assetId).Include_Asset__c));
                
            }
            if (toBeUpdatedAssets.size() > 10000) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Cannot update more than 10000 records in single save.'));
            }
            else if (toBeUpdatedAssets.size() > 0) {
                update toBeUpdatedAssets;
                 //CRM-3147
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'asset(s) have been saved for CPQ usage'));
             }      
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
        }
    }
    
    public static String getStringDate(Date d) {
        string dt='';
        dt=string.valueOf(d.year());
        if (string.valueOf(d.month()).length()==1){
            dt = dt+'-0' + string.valueOf(d.month());
        }
        else {
            dt = dt+ '-'+ string.valueOf(d.month());
        }
        if (string.valueOf(d.day()).length()==1) {
            dt = dt+'-0'+string.valueOf(d.day());
        }
        else {
            dt = dt+'-'+string.valueOf(d.day());
        }
        return dt;
    }
    
    public void checkActiveCBC() {
        checkUnCheckActiveSuspendedCBC(true);
    }
    public void checkSuspendedCBC() {
        checkUnCheckActiveSuspendedCBC(false);
    }
    
    //Added by MRB
    public void checkActiveLocalExperts() {
        checkUnCheckActiveLocalExperts(true);
    }
    
    private void checkUnCheckActiveSuspendedCBC(Boolean active) {
        updateAssetMap();
        String query = 'SELECT id, Include_Asset__c FROM Asset' + baseWhereClause;
        query = query + ' AND Product_Code__c = \'COBROKE\' AND Status = \'Active\' AND Fulfillment_Status__c =';
        String msg = 'No CBC fulfilled record found';
        if (active) {
            query  = query + '\'Fulfilled\'';
            //query  = query + '\'Pending Fulfillment\'';
        }
        else {
            query  = query + '\'Suspended\'';
            //query  = query + '\'Failure\'';
            msg = 'No CBC suspended record found';
        }
        List<Asset> records = (List<Asset>)DataBase.query(query);
        if (records.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, msg));
        }
        else {
            allCheck = true;
            clearFilters();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Filters are cleared if any. ' + records.size() + ' assets are selected.'));
            for (Asset assetRec : records) {
            assetRec.Include_asset__c = true;
                assetIncludeFlagMap.put(assetRec.id, assetRec);
            }
            
            for (Asset asset : assetRecords) {
                if (assetIncludeFlagMap.containsKey(asset.Id)) {
                    asset.Include_Asset__c = assetIncludeFlagMap.get(asset.Id).Include_Asset__c;
                }
                if (!asset.Include_Asset__c) {
                        allCheck = false;
                }
            }
        } 
    }
    //Added by MRB
    private void checkUnCheckActiveLocalExperts(Boolean active) {
        updateAssetMap();
        String query = 'SELECT id, Include_Asset__c FROM Asset' + baseWhereClause;
        query = query + ' AND Product_Code__c = \'LOCALEXPERT\' AND Status = \'Active\' AND Fulfillment_Status__c =';
        String msg = 'No Local Experts fulfilled record found';
        if (active) {
            query  = query + '\'Fulfilled\'';
            //query  = query + '\'Pending Fulfillment\'';
        }
        
        List<Asset> records = (List<Asset>)DataBase.query(query);
        if (records.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, msg));
        }
        else {
            allCheck = true;
            clearFilters();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Filters are cleared if any. ' + records.size() + ' assets are selected.'));
            for (Asset assetRec : records) {
            assetRec.Include_asset__c = true;
                assetIncludeFlagMap.put(assetRec.id, assetRec);
            }
            
            for (Asset asset : assetRecords) {
                if (assetIncludeFlagMap.containsKey(asset.Id)) {
                    asset.Include_Asset__c = assetIncludeFlagMap.get(asset.Id).Include_Asset__c;
                }
                if (!asset.Include_Asset__c) {
                        allCheck = false;
                }
            }
        } 
    }
    
    
    // CRM-3909 - Uncheck All Assets
    private void clearFilters() {
        StartDateBegin = null; StartDateEnd  = null; EndDateBegin  = null; EndDateEnd = null; assetNumber = null; market = null;
        ascDsc = defaultSortingOrder;
        sortField = defaultSortField;
        search();
    }
    public void unCheckAllAssets() {
        assetIncludeFlagMap.clear();
        String query = 'SELECT id, Include_Asset__c,Follow_Up_Status__c FROM Asset' + baseWhereClause + ' AND Include_Asset__c = true';
        List<Asset> assets = (List<Asset>)DataBase.query(query);
        if (assets.size() > 0) {
            clearFilters();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Filters are cleared if any. ' + assets.size() + ' included asset(s) found, same will be unchecked after save.'));
            assetIncludeFlagMap.clear();
            for (Asset asset : assets) {
            asset.Include_Asset__c = false;
                assetIncludeFlagMap.put(asset.id, asset);
            }   
        }
        else {
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'There are no already included assets on this Account'));
          
        }
        for (Asset asset : assetRecords) {
            asset.Include_Asset__c = false;
        }
        allCheck = false;
    }
    // CRM-3909 End
}