// CRM-1965: Controller for Realtor Roster VF page
public with sharing class realtorRosterSearchController {
	 public String officeName {get;set;}
	 public String agentName {get;set;}
	 public String mlsAcctName {get;set;}
	 public String mlsId {get;set;}
	 public String mlsType {get;set;}
	 public String mlsStatus {get;set;}
	 public String state {get;set;}
	 public String mlsAlias {get;set;}
	 public String query {get;set;}
	 public String officeId {get;set;}
	 public Integer offsetsize {get;set;}
	
	 public List<MLS__c> mlsList {get;set;}
	 public Set<String> stateSet {get;set;}
	 
	 public List<SelectOption> stateOptions {get;set;}
	 public List<SelectOption> mlsCodeOptions {get;set;}


	Public realtorRosterSearchController() {
		clearInputs();
		
		mlsList = new List<MLS__c>();
		stateSet = new Set<String>();
        stateOptions = new List<SelectOption>();
        mlsCodeOptions = new List<SelectOption>();
      
        List<String> stateList = new List<String>{'Alabama','Alaska','Arizona','Arkansas','California','Colorado','Connecticut','Delaware','Florida','Georgia','Hawaii','Idaho','Illinois','Indiana','Iowa','Kansas','Kentucky','Louisiana','Maine','Maryland','Massachusetts','Michigan','Minnesota','Mississippi','Missouri','Montana','Nebraska','Nevada','New Hampshire','New Jersey','New Mexico','New York','North Carolina','North Dakota','Ohio','Oklahoma','Oregon','Pennsylvania','Rhode Island','South Carolina','South Dakota','Tennessee','Texas','Utah','Vermont','Virginia','Washington','West Virginia','Wisconsin','Wyoming'};
        for(String st: stateList){
        	stateOptions.add(new SelectOption(st, st));
        }

        // CRM-2136: Get MLS Codes from New object instead of hard coding values in the class.
        List<MLS_Name__c> mlsCodeList = [Select MLS_Label__c, MLS_Value__c from MLS_Name__c order by MLS_Label__c];

        for(MLS_Name__c mcl: mlsCodeList){
        	mlsCodeOptions.add(new SelectOption(mcl.MLS_Value__c, mcl.MLS_Label__c));
        }
	}

	public void clearInputs(){
		mlsType = '';
		mlsStatus = '';
		mlsId = '';
		officeName = '';
		agentName = '';
		mlsAcctName = '';
		state = '';
		mlsAlias = '';
	}

	public void searchMLS(){
		officeId = '';
		offsetsize = 0;
		mlsList = new List<MLS__c>();
		stateSet = new Set<String>();
		// Get values from VF page input components and form a query
		query = formQuery(mlsId, state, officeName, agentName, mlsAcctName, mlsType, mlsStatus, mlsAlias, false);
		system.debug('query---'+query);

		mlsList = filterResults(database.query(query));
	}

    // First only 500 records are displayed. Get more records using offset
	public void getMoreRows(){
		List<MLS__c> mlsListOffset = new List<MLS__c>();
	
		query = formQuery(mlsId, state, officeName, agentName, mlsAcctName, mlsType, mlsStatus, mlsAlias, false);
		if(offsetsize > 0 && offsetsize <= 2000){
	    	query += ' offset '+offsetsize+'';
	    }
       
		mlsListOffset = filterResults(database.query(query));
		mlsList.addAll(mlsListOffset);	
	}

    // CRM-2440 (Remove Duplicates): For a particular MLS Set, get Active record.
    // If there is no active record, then get the inactive record with recent end date.
	public List<MLS__c> filterResults(List<MLS__c> mlsListRaw){
		offsetsize += mlsListRaw.size();
		
		if(mlsStatus == 'Active' && String.isBlank(officeId)){
			return mlsListRaw;
		}
		Map<String, MLS__c> mlsSetIdMap = new Map<String, MLS__c>();
		
		for(MLS__c mls: mlsListRaw){
			if(mls.Status__c == 'Active'){
				mlsSetIdMap.put(mls.MLS_Set_ID__c, mls);
			} else if(mls.Status__c == 'Inactive') {
				if(!mlsSetIdMap.containsKey(mls.MLS_Set_ID__c)|| (mlsSetIdMap.containsKey(mls.MLS_Set_ID__c) && mlsSetIdMap.get(mls.MLS_Set_ID__c).Status__c != 'Active' && mlsSetIdMap.get(mls.MLS_Set_ID__c).End_Date__c < mls.End_Date__c)){
					mlsSetIdMap.put(mls.MLS_Set_ID__c, mls);
				}
			}
		}
		return mlsSetIdMap.values();
	}

	public String getInitQuery(){
		//CRM-3020: Added MLS__r.MLSTier__c
		String query = 'Select id, MLS_Set_ID__c, MLS_Set_Party_ID__c, MLS_State__c, MLS_Area_Source_Reference__c,'+
			          +' MLS_Set_Type__c, Office_Name__c, Agent_Name__c, MLS_Account_Name__c, MLS_Phone__c, End_Date__c,'+
			          +' Account_Sub_Type__c, Account_Advertiser_id__c,Parent_MLS_Set_ID__c, Primary_MLS_Set__c,'+
			          +' HLC__c, CLC__c, Status__c, Office__c, Agent__c, Name, MLS_City__c, Office__r.BillingCity, Agent__r.BillingCity,'+
			          +' Office__r.LandAMLC__c, Office__r.RentalAMLC__c, Office__r.ResidentialAMLC__c, MLS__r.MLSTier__c,'+
			          +' Agent__r.LandAMLC__c, Agent__r.RentalAMLC__c, Agent__r.ResidentialAMLC__c From MLS__c'+
                      +' Where';
        return query;
	}

	public String formQuery(String mlsId, String state, String officeName, String agentName, String mlsAcctName, String mlsType, String mlsStatus, String mlsAlias, Boolean isExport){
		String stateCode = '';
		
		Map<String, String> stateCodeMap = new Map<String, String>{'Alabama'=>'AL','Alaska'=>'AK','Arizona'=>'AZ','Arkansas'=>'AR','California'=>'CA','Colorado'=>'CO','Connecticut'=>'CT','Delaware'=>'DE','Florida'=>'FL','Georgia'=>'GA','Hawaii'=>'HI','Idaho'=>'ID','Illinois'=>'IL','Indiana'=>'IN','Iowa'=>'IA','Kansas'=>'KS','Kentucky'=>'KY','Louisiana'=>'LA','Maine'=>'ME','Maryland'=>'MD','Massachusetts'=>'MA','Michigan'=>'MI','Minnesota'=>'MN','Mississippi'=>'MS','Missouri'=>'MO','Montana'=>'MT','Nebraska'=>'NE','Nevada'=>'NV','New Hampshire'=>'NH','New Jersey'=>'NJ','New Mexico'=>'NM','New York'=>'NY','North Carolina'=>'NC','North Dakota'=>'ND','Ohio'=>'OH','Oklahoma'=>'OK','Oregon'=>'OR','Pennsylvania'=>'PA','Rhode Island'=>'RI','South Carolina'=>'SC','South Dakota'=>'SD','Tennessee'=>'TN','Texas'=>'TX','Utah'=>'UT','Vermont'=>'VT','Virginia'=>'VA','Washington'=>'WA','West Virginia'=>'WV','Wisconsin'=>'WI','Wyoming'=>'WY'};
       

        String query = getInitQuery();

        if(officeName != null && officeName != ''){
        	// CRM-2136: Escaping single quote and underscore characters.
        	// % will be used as wildcard char so no need to escape.
        	officeName = String.escapeSingleQuotes(officeName);
            officeName = officeName.replace('_', '\\_');
        	query += ' And  Office__r.Name LIKE \'%'+officeName+'%\'';
        }

        if(agentName != null && agentName != ''){
        	agentName = String.escapeSingleQuotes(agentName);
            agentName =  agentName.replace('_', '\\_');
        	query += ' And  Agent__r.Name LIKE \'%'+agentName+'%\'';
        }

         if(mlsAcctName != null && mlsAcctName != ''){
         	mlsAcctName = String.escapeSingleQuotes(mlsAcctName);
            mlsAcctName = mlsAcctName.replace('_', '\\_');
        	query += ' And  MLS_Account_Name__c LIKE \'%'+mlsAcctName+'%\'';
        }

		if(state != null && state != ''){
		   stateCode = stateCodeMap.get(state);
		   stateSet.add(state);
		   stateSet.add(stateCode);
		   system.debug('state'+stateSet);
		   query += ' And  (MLS_State__c IN :stateSet OR MLS_Area_Source_Reference__c LIKE \'%'+stateCode+'\')';
		
		}

		if(mlsId != null && mlsId != ''){
			query += ' And  MLS_Area_Source_Reference__c = \''+mlsId+'\'';
			
		}

		if(mlsAlias != null && mlsAlias != ''){
			mlsAlias = String.escapeSingleQuotes(mlsAlias);
            mlsAlias = mlsAlias.replace('_', '\\_');
			query += ' And  Name LIKE \'%'+mlsAlias+'\'';
		}

		if(mlsStatus != null && mlsStatus != ''){
			query += ' And  Status__c = \''+mlsStatus+'\'';
			
		}

		if(mlsType != null && mlsType != ''){
			query += ' And  MLS_Set_Type__c = \''+mlsType+'\'';
			
		}

		// 10000 records will be returned if users wants to export CSV file, else 1000 records will be dispalyed in VF page.

	    if(isExport){
	    	query += ' order by MLS_Set_ID__c,Status__c limit 10000';
	    } else {
	    	query += ' order by MLS_Set_ID__c,Status__c limit 500';
	    }

	    query = query.replace('MLS__c Where And', 'MLS__c Where');
	    query = query.replace('MLS__c Where order by', 'MLS__c order by');

        return query;

	}

	//CRM-2148 - When an office account is clicked then show all agents who belong to that  office.
	public void getAgents(){
        mlsList = new List<MLS__c>();

        String query = getInitQuery() + ' Office__c = \''+officeId+'\' And MLS_Set_Type__c =  \'Agent\' limit 1000';
        // CRM-2533 
		mlsList.addAll(filterResults(database.query(query)));
	}

// CRM-2136: Strings with single quotes are not passed in JS(VF page) so escape it before using in the URL.
  public void updateValuesForURL(){
  	officeName = String.escapeSingleQuotes(officeName);
	agentName = String.escapeSingleQuotes(agentName);
	mlsAcctName = String.escapeSingleQuotes(mlsAcctName);
	mlsAlias = String.escapeSingleQuotes(mlsAlias);
  }


}