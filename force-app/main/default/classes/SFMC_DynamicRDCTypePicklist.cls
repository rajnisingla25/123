/*
 * Created by: Atul Rakate
 * Date: 8/7/2019
 * Description: Class to fetch global picklist values and send them to designer attribute in SFMC_ConfigurationComponent.
*/
global class SFMC_DynamicRDCTypePicklist extends VisualEditor.DynamicPickList{
	global override VisualEditor.DataRow getDefaultValue(){
		//This method needs to be implemented as this class extends VisualEditor.DynamicPickList.
        return null;
    }
    global override VisualEditor.DynamicPickListRows getValues() {
        Schema.DescribeFieldResult describeEAPT = Engagement_Activity__c.Product__c.getDescribe();
        Schema.sObjectField sobjFields = describeEAPT.getSObjectField();
        List<PicklistEntry> entries = sobjFields.getDescribe().getPicklistValues();
        VisualEditor.DynamicPickListRows  picklistEntries = new VisualEditor.DynamicPickListRows();
        for(PicklistEntry objPicklist : entries){
            VisualEditor.DataRow prodTypeVal = new VisualEditor.DataRow(objPicklist.getLabel(), objPicklist.getValue());
            picklistEntries.addRow(prodTypeVal);            
        }
        return picklistEntries;
    }
}