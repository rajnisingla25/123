public with sharing class ManagerSettingsController {

	public List<SelectOption> profileOptions {get;set;}
	public String selectedProfile {get;set;}
	public BillingAccountManagerSettings__c managerSettings {get;set;}
	private BillingAccountManagerSettings__c userSettings;
	public Boolean isAdmin {get;set;}
	private List<Profile> tenantProfiles = new List<Profile>();
	private final String DEFAULT_SETTINGS_LABEL = '--Organizational Default Settings--';
	public final String DEFAULT_SETTINGS_VALUE {get;set;}
	private String returnToLevel;
	private String newHPM;

	public ManagerSettingsController() {
		userSettings = BillingAccountManagerSettings__c.getInstance(UserInfo.getProfileId());
		isAdmin = userSettings.hasAdminPermissions__c;
		DEFAULT_SETTINGS_VALUE = 'Default';
		profileOptions = new List<SelectOption>();
		tenantProfiles = [Select Id, Name FROM Profile];
		createProfileOptions(tenantProfiles);
		managerSettings = BillingAccountManagerSettings__c.getOrgDefaults();
		selectedProfile = DEFAULT_SETTINGS_VALUE;
		returnToLevel = managerSettings.ReturnToPage__c;
		newHPM = managerSettings.UseNewHpm__c;

	}

	private void createProfileOptions(List<Profile> profileList){
		profileOptions.add(new SelectOption(DEFAULT_SETTINGS_VALUE, DEFAULT_SETTINGS_LABEL));
		for (Profile profile : profileList){
			profileOptions.add(new SelectOption(profile.Id, profile.Name));
		}
	}

	public void changeProfile(){
		if (selectedProfile == DEFAULT_SETTINGS_VALUE){
			managerSettings = BillingAccountManagerSettings__c.getOrgDefaults();
		} else {
			managerSettings = BillingAccountManagerSettings__c.getInstance(selectedProfile);
		}
		managerSettings.ReturnToPage__c = returnToLevel;
		managerSettings.UseNewHPM__c = newHPM;
	}

	public void saveSettings(){
		if (managerSettings.SetupOwnerId == null && selectedProfile != DEFAULT_SETTINGS_VALUE){
			managerSettings.SetupOwnerId = selectedProfile;
		}
		upsert managerSettings;
	}

	public void setToDefault(){
		if (selectedProfile != DEFAULT_SETTINGS_VALUE && managerSettings.Id != null){
			delete managerSettings;
			managerSettings = BillingAccountManagerSettings__c.getInstance(selectedProfile);
		}
	}
}