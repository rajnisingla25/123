global class AccountTreeConfiguration
{
public decimal BatchSize{get;set;}
public string GlobalSelectedFilter{get;set;}
public string GlobalSelectedType{get;set;}

public AccountTreeConfiguration(ApexPages.StandardController stdController) {
BatchSize=1000;
GlobalSelectedFilter='Agent View';
GlobalSelectedType='Realtor Office';
}
}