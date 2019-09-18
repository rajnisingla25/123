// CRM-1965: Controller for MLSRecords VF page
public with sharing class mlsRecordsController {
    
    public List<MLS__c> mlsList {get;set;}
    public List<mlsCsvWrapper> mlsListCsv {get;set;}
    public Set<String> stateSet {get;set;}
    
    public mlsRecordsController(){
        mlsList = new List<MLS__c>();
        mlsListCsv = new List<mlsCsvWrapper>();
        String stateCode = '';
        stateSet = new Set<String>();
        realtorRosterSearchController r = new realtorRosterSearchController();
        system.debug('url----'+ApexPages.currentPage().getURL());
        
        //CRM-2148 - When an office account is clicked then show all agents who belong to that  office.
        String officeId = apexpages.currentpage().getparameters().get('officeId');
        
        if(officeId != '' && officeId != null){
            String query = r.getInitQuery() + ' Office__c = \''+officeId+'\' And MLS_Set_Type__c =  \'Agent\'';
            mlsList = database.query(query);
            mlsListCsv = getMlsCsvWrapper(mlsList);
        } else {
            
            String mlsId = apexpages.currentpage().getparameters().get('mlsId');
            String state = apexpages.currentpage().getparameters().get('state');
            String officeName = apexpages.currentpage().getparameters().get('officeName');
            String agentName = apexpages.currentpage().getparameters().get('agentName');
            String mlsAcctName = apexpages.currentpage().getparameters().get('mlsAcctName');
            String mlsType = apexpages.currentpage().getparameters().get('mlsType');
            String mlsStatus = apexpages.currentpage().getparameters().get('mlsStatus');
            String mlsAlias = apexpages.currentpage().getparameters().get('mlsAlias');
            
            
            Map<String, String> stateCodeMap = new Map<String, String>{'Alabama'=>'AL','Alaska'=>'AK','Arizona'=>'AZ','Arkansas'=>'AR','California'=>'CA','Colorado'=>'CO','Connecticut'=>'CT','Delaware'=>'DE','Florida'=>'FL','Georgia'=>'GA','Hawaii'=>'HI','Idaho'=>'ID','Illinois'=>'IL','Indiana'=>'IN','Iowa'=>'IA','Kansas'=>'KS','Kentucky'=>'KY','Louisiana'=>'LA','Maine'=>'ME','Maryland'=>'MD','Massachusetts'=>'MA','Michigan'=>'MI','Minnesota'=>'MN','Mississippi'=>'MS','Missouri'=>'MO','Montana'=>'MT','Nebraska'=>'NE','Nevada'=>'NV','New Hampshire'=>'NH','New Jersey'=>'NJ','New Mexico'=>'NM','New York'=>'NY','North Carolina'=>'NC','North Dakota'=>'ND','Ohio'=>'OH','Oklahoma'=>'OK','Oregon'=>'OR','Pennsylvania'=>'PA','Rhode Island'=>'RI','South Carolina'=>'SC','South Dakota'=>'SD','Tennessee'=>'TN','Texas'=>'TX','Utah'=>'UT','Vermont'=>'VT','Virginia'=>'VA','Washington'=>'WA','West Virginia'=>'WV','Wisconsin'=>'WI','Wyoming'=>'WY'};
                if(state != null && state != ''){
                    stateCode = stateCodeMap.get(state);
                    stateSet.add(state);
                    stateSet.add(stateCode);
                }
            String query = r.formQuery(mlsId, state, officeName, agentName, mlsAcctName, mlsType, mlsStatus, mlsAlias, true);
            
            // CRM 2440 : Filter records
            r.offsetsize = 0;
            mlsList = r.filterResults(database.query(query));
            mlsListCsv = getMlsCsvWrapper(mlsList);
        }
    }
    
    public List<mlsCsvWrapper> getMlsCsvWrapper(List<MLS__c> mlsSetList){
        
        List<mlsCsvWrapper> newObject = new List<mlsCsvWrapper>();
        for(MLS__c mls: mlsSetList){
            String mls_city = mls.MLS_City__c;
            Decimal landAMLC;
            Decimal resiAMLC;
            Decimal rentalAMLC;
            String office_Name =  '';
            String Agent_Name = '';
            String MLS_Account_Name =  '';
            
            if(String.isBlank(mls_city)){
                if(mls.MLS_Set_Type__c == 'Agent'){
                    mls_city =  mls.Agent__r.BillingCity;
                }else {
                     mls_city =  mls.Office__r.BillingCity;
                }
            }
            if(mls.MLS_Set_Type__c == 'Agent'){
                landAMLC = mls.Agent__r.LandAMLC__c;
                resiAMLC = mls.Agent__r.ResidentialAMLC__c;
                rentalAMLC = mls.Agent__r.RentalAMLC__c;
            } else {
                landAMLC = mls.Office__r.LandAMLC__c;
                resiAMLC = mls.Office__r.ResidentialAMLC__c;
                rentalAMLC = mls.Office__r.RentalAMLC__c;
            }
            if( mls.office_Name__c != null){
                office_Name =  mls.office_Name__c.escapeCsv();
            }
            if( mls.Agent_Name__c != null){
                Agent_Name =  mls.Agent_Name__c.escapeCsv();
            }
            
            if( mls.MLS_Account_Name__c != null){
                MLS_Account_Name =  mls.MLS_Account_Name__c.escapeCsv();
            }
            
            newObject.add(new mlsCsvWrapper(
                office_Name,
                Agent_Name,
                mls.Name,
                mls.MLS_State__c,
                mls_city,
                mls.MLS_Area_Source_Reference__c,
                mls.MLS__r.MLSTier__c,
                mls.Primary_MLS_Set__c,
                MLS_Account_Name,
                mls.MLS_Phone__c,
                mls.MLS_Set_Type__c,
                mls.Account_Sub_Type__c,
                mls.Account_Advertiser_id__c,
                mls.HLC__c,
                mls.CLC__c,
                landAMLC,
                resiAMLC,
                rentalAMLC,
                mls.MLS_Set_Party_ID__c,
                mls.Parent_MLS_Set_ID__c
                
            ));
            
        }
        
        return newObject;
        
    }
    
    
    
    public class mlsCsvWrapper{
        
        public string office_Name {get; set;} 
        public string Agent_Name  {get; set;}
        public string Name  {get; set;}
        public string MLS_State  {get; set;}
        public string MLS_City  {get; set;}
        public String MLS_Area_Source_Reference  {get; set;}
        public String MLSTier {get; set;}
        public Boolean Primary_MLS_Set  {get; set;}
        public string MLS_Account_Name {get; set;}
        public String MLS_Phone {get; set;}
        public String MLS_Set_Type {get; set;}
        public string Account_Sub_Type   {get; set;}
        public string Account_Advertiser_id   {get; set;}
        public Decimal HLC  {get; set;}
        public Decimal CLC   {get; set;}
        public Decimal landAMLC   {get; set;}
        public Decimal resiAMLC   {get; set;}
        public Decimal rentalAMLC   {get; set;}
        public string MLS_Set_Party_ID {get; set;}
        public string Parent_MLS_Set_ID  {get; set;}
        
        public mlsCsvWrapper(
            
            string officeName_wrap,
            string agentName_wrap,  
            string mlsSet_wrap, 
            string mlsState_wrap, 
            string mlsCity_wrap, 
            String mlsName_wrap,
            string mlsTier_wrap, 
            Boolean PrimaryMLSSet_wrap,
            string mlsAcctName_wrap, 
            String mlsPhnNum_wrap,
            String acctType_wrap,
            string acctSubType_wrap,  
            string acctAdvId_wrap,
            Decimal hlc_wrap, 
            Decimal clc_wrap, 
            Decimal landAMLC_wrap, 
            Decimal resiAMLC_wrap, 
            Decimal rentalAMLC_wrap, 
            string mlsPartyId_wrap,
            String ParentMlsSet_wrap){
                
                this.office_Name = officeName_wrap;
                this.Agent_Name = agentName_wrap;
                this.Name = mlsSet_wrap;
                this.MLS_State = mlsState_wrap;  
                this.MLS_City = mlsCity_wrap;  
                this.MLS_Area_Source_Reference = mlsName_wrap;
                this.MLS_Area_Source_Reference = mlsName_wrap;
                //CRM-3020
                this.MLSTier = mlsTier_wrap;
                this.MLS_Account_Name = mlsAcctName_wrap; 
                this.MLS_Phone = mlsPhnNum_wrap;
                this.MLS_Set_Type = acctType_wrap;
                this.Account_Sub_Type = acctSubType_wrap;  
                this.Account_Advertiser_id = acctAdvId_wrap;
                this.HLC = hlc_wrap;  
                this.CLC = clc_wrap; 
                this.landAMLC = landAMLC_wrap; 
                this.resiAMLC = resiAMLC_wrap; 
                this.rentalAMLC = rentalAMLC_wrap; 
                this.MLS_Set_Party_ID = mlsPartyId_wrap;
                this.Parent_MLS_Set_ID = ParentMlsSet_wrap;
            }
        
        
    }
    
}