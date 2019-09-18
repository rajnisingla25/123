/*******************************************************************************
Created By         :   Srinivas Vadla
Created Date       :   7-Oct-2017
Usage              :   The purpose of this class/Page is to display the Qualifiers to reps
********************************************************************************/
public class Commissions_QuotaPageControllerRead{   
    //VARIALBLE DECLERATION
    public list<Quota_Product__c> allProducts {get;set;} 
    public Commissions_QuotaPageControllerRead(ApexPages.StandardController controller) {
        allProducts = [select id,Name,
                              Product_Name1__c,Sales__c,Sales_Achivement__c,
                              Target__c,Target_Achieved__c,Product_Family__c 
                              FROM Quota_Product__c 
                              WHERE Related_To_Quota__c =: ApexPages.currentPage().getParameters().get('id') 
                              Order by CreatedDate Desc];
    }    
}