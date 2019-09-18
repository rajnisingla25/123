/*
    Purpose:        Controller for Engagement Activity related list VF page.
    Also includes aura enbaled methods called by lightning component embedded in this VF page
    Created by:     Sarang D
    Created date:   15/1/2018
*/
public with sharing class SFMC_EngagementActivityController {
    public Contact contactRecord {get;set;}
    public List<Engagement_Activity__c> engagementActivityList;
    public List<EngagementActivityWrapper> engActivityWrapperList;
    @AuraEnabled public String wrapperList {get;set;}
    public SFMC_EngagementActivityController(ApexPages.StandardController stdController){
        contactRecord = (Contact)stdController.getRecord();
    }

    /*
        Purpose:        To call getOffsetRecords() method passing contactId.
        It is required as we can not access contactRecord variable directly in static method.
        Created by:     Sarang D
        Created date:   15/1/2018
    */
    public void getEngagementActivityList(){
            wrapperList = getOffsetRecords(0,contactRecord.Id, Label.SFMC_Picklist_Default_Label, true, Label.SFMC_Picklist_Default_Label);
    }


    /*
        Purpose: Method to return a set of records as per offset and filter values provided from client side lightning component.
        Created by: Sarang D
        Created date : 16/1/2018
    */
    @AuraEnabled
    public static String getOffsetRecords(Integer offset,Id contactId, String engagementTypeFilter, Boolean isFilter, String selectedProduct){
        try{            
            List<EngagementActivityWrapper> engActivityWrapperList = new List<EngagementActivityWrapper>();
            Integer recordListSizeAfterFilter;
            boolean isLimitExceeded = false;
            
            /*Recalculate limit exceeded and totla record count everytime a filter is applied or on intialisation.*/
            if(isFilter){
                String countQuery = 'select count(id) from Engagement_Activity__c where Contact__c =: contactId';
                countQuery += engagementTypeFilter.equalsIgnoreCase(Label.SFMC_Picklist_Default_Label) ? '' : ' and Engagement_Activity_Type__r.Channel__c =: engagementTypeFilter';
                countQuery += selectedProduct.equalsIgnoreCase(Label.SFMC_Picklist_Default_Label) ? '' : ' and Product__c =: selectedProduct';
                recordListSizeAfterFilter = (Integer)database.query(countQuery)[0].get('expr0');
                if(recordListSizeAfterFilter > 2000){
                    isLimitExceeded = true;
                    recordListSizeAfterFilter = 2000;
                }
            }
            
            system.debug('recordListSizeAfterFilter ' + recordListSizeAfterFilter);
                        
            String query = 'select Activity_Title__c,Source__c,Email__c,Phone__c, Product__c,Activity_Date__c,Journey_Name__c,' +
                'Form_Submission_URL__c,Engagement_Activity_Type__r.Channel__c,Engagement_Activity_Type__r.Icon_Image__c, Contact_Method__r.Type__c, Contact_Method__r.Contact__r.Name,Campaign__r.name,Campaign__c ' +
                'from Engagement_Activity__c';
            query += ' where Contact__c =: contactId';
            query += engagementTypeFilter.equalsIgnoreCase(Label.SFMC_Picklist_Default_Label) ? '' : ' and Engagement_Activity_Type__r.Channel__c =: engagementTypeFilter';
            query += selectedProduct.equalsIgnoreCase(Label.SFMC_Picklist_Default_Label) ? '' : ' and Product__c =: selectedProduct';
            query += ' order by Activity_Date__c desc limit ' + Integer.valueOf(Label.SFMC_Page_Size_value) + ' offset ' + offset;

            String domainURLString = URL.getOrgDomainUrl().toExternalForm() + '/';
            System.debug('query >>'+query);
            for(Engagement_Activity__c activity :  database.query(query)){
                List<EngagementAttributeWrapper> attributeWrapperList = new List<EngagementAttributeWrapper>();
                if(activity.Contact_Method__r.Contact__r.Name != null && (activity.Engagement_Activity_Type__r.Channel__c.equals(SFMC_Constants.ENGAGEMENT_ACTIVITY_TYPE_CHANNEL_FORM_SUBMISSION) ||
                   activity.Engagement_Activity_Type__r.Channel__c.equals(SFMC_Constants.ENGAGEMENT_ACTIVITY_TYPE_CHANNEL_WEBINAR) ||
                   activity.Engagement_Activity_Type__r.Channel__c.equals(SFMC_Constants.ENGAGEMENT_ACTIVITY_TYPE_EVENTS ))){

                       attributeWrapperList.add(new EngagementAttributeWrapper(Label.SFMC_Contact_Name_Field_Label, activity.Contact_Method__r.Contact__r.Name,
                                                                     true,domainURLString + activity.Contact_Method__r.Contact__c));
                   }
                if(activity.Email__c != null){
                       attributeWrapperList.add(new EngagementAttributeWrapper(Label.SFMC_Email_Field_Label, activity.Email__c,
                                                                     false, null));
                   }
                if(activity.Phone__c != null){
                       attributeWrapperList.add(new EngagementAttributeWrapper(Label.SFMC_Phone_Field_Label, activity.Phone__c,
                                                                     false, null));
                   }
                if(activity.Product__c != null){
                    attributeWrapperList.add(new EngagementAttributeWrapper(Label.SFMC_Product_Field_Label, activity.Product__c,
                                                                  false, null));
                }
                if(activity.Source__c != null){
                    attributeWrapperList.add(new EngagementAttributeWrapper(Label.SFMC_Source_Field_Label, activity.Source__c, false, null));
                }
                if(activity.Campaign__c != null){
                    attributeWrapperList.add(new EngagementAttributeWrapper(Label.SFMC_Campaign_Field_Label, activity.Campaign__r.name, false, null));
                }
                if(activity.Form_Submission_URL__c != null){
                    attributeWrapperList.add(new EngagementAttributeWrapper(Label.SFMC_Form_Submission_URL, activity.Form_Submission_URL__c, false, null));
                }
                if(activity.Journey_Name__c != null){
                    attributeWrapperList.add(new EngagementAttributeWrapper(Label.SFMC_Journey_Name_Label, activity.Journey_Name__c, false, null));
                }

                //Code to fetch static resource path of the image from rich text field.
                String iconPath = activity.Engagement_Activity_Type__r.Icon_Image__c.substringBetween('<img', '/>').substringBetween('src="', '"');

                system.debug('recordListSizeAfterFilter :' + recordListSizeAfterFilter);
                EngagementActivityWrapper engActivityWrapper = new EngagementActivityWrapper(activity.Activity_Title__c,
                                                                                             domainURLString + activity.id,
                                                                                             activity.Activity_Date__c,
                                                                                             attributeWrapperList,
                                                                                             iconPath,
                                                                                             recordListSizeAfterFilter,
                                                                                             isLimitExceeded
                                                                                            );
                engActivityWrapperList.add(engActivityWrapper);
            }
            system.debug('engActivityWrapperList.size : ' + engActivityWrapperList.size());
            system.debug('engActivityWrapperList : ' + JSON.serialize(engActivityWrapperList,true));
            return JSON.serialize(engActivityWrapperList,true);
        }
        catch(QueryException ex){
            system.debug('Stack trace : ' + ex.getStackTraceString());
            Error__c logError = new Error__c(Entity_Id__c =contactId, Interface_Name__c = 'SFMC_EngagementActivityController', Error_Description__c = ex.getMessage());
            insert logError;
            String msgWrap = JSON.serialize(new EngagementActivityWrapper(true, Label.SFMC_Eng_List_Error),true);
            system.debug('msgWrap : ' + msgWrap);
            return msgWrap;
        }
        catch(Exception ex){
            system.debug('Stack trace : ' + ex.getStackTraceString());
            Error__c logError = new Error__c(Entity_Id__c =contactId, Interface_Name__c = 'SFMC_EngagementActivityController', Error_Description__c = ex.getMessage());
            insert logError;
            String msgWrap = JSON.serialize(new EngagementActivityWrapper(true, Label.SFMC_Eng_List_Error),true);
            system.debug('msgWrap : ' + msgWrap);
            return msgWrap;
        }
    }

    /*
    Purpose: Method to get all values of Channel__c picklist field.
    Created by: Sarang D
    Created date : 16/1/2018
    */
    @AuraEnabled
    public static String getPicklistValues(){
        return SFMC_Utility.getPicklistLabelvalueJSON('Engagement_Activity_Type__c', 'Channel__c');
    }

    /*
    Purpose: Method to get all values of Product_Type__c picklist field.
    Created by: Atul
    Created date : 27/3/2018
    */
    @AuraEnabled
    public static String getProductTypeValues(){
        return SFMC_Utility.getPicklistLabelvalueJSON('Engagement_Activity__c', 'Product__c');
    }

    /*
    Purpose: Outer wrapper class containing values to be shown on UI.
    Created by: Sarang D
    Created date : 16/1/2018
    */
    public class EngagementActivityWrapper{
        @AuraEnabled public String activityDescriptionTitle;
        @AuraEnabled public String activityURL;
        @AuraEnabled public String iconPath;
        @AuraEnabled public String activityDate;
        @AuraEnabled public String activityTime;
        @AuraEnabled public Id contactId;
        @AuraEnabled public Integer recordListSize;
        @AuraEnabled public List<EngagementAttributeWrapper> attributeWrapper;
        @AuraEnabled public Boolean isLimitExceeded;
        @AuraEnabled public Boolean isError;
        @AuraEnabled public String errorMessage;
        
        public EngagementActivityWrapper(String activityDescriptionTitle,String activityURL,Datetime activityDateTime,List<EngagementAttributeWrapper> attributeWrapper, String iconPath, Integer recordListSize, Boolean isLimitExceeded){
            this.attributeWrapper = attributeWrapper;
            this.iconPath = iconPath;
            if(activityDateTime != null){
                this.activityDate = activityDateTime.date().format();
                Datetime myDateTime = Datetime.newInstance(activityDateTime.date(), activityDateTime.time());
                this.activityTime = myDateTime.format('h:mm a');
            }
            this.activityURL = activityURL;
            this.activityDescriptionTitle = activityDescriptionTitle;
            this.recordListSize = recordListSize;
            this.isError = false;
            this.isLimitExceeded = isLimitExceeded;
        }
        
        public EngagementActivityWrapper(Boolean isError, String errorMessage){
            this.isError = isError;
            this.errorMessage = errorMessage;
        }
    }

    /*
    Purpose: Inner wrapper class containing field names and values to be shown on UI.
    Created by: Sarang D
    Created date : 16/1/2018
    */
    public class EngagementAttributeWrapper{
        @AuraEnabled public String columnLabel;
        @AuraEnabled public String value;
        @AuraEnabled public Boolean isLink;
        @AuraEnabled public String redirectURL;

        public EngagementAttributeWrapper(String columnLabel,String value,Boolean isLink, String redirectURL){
            this.columnLabel = columnLabel;
            this.value = value;
            this.isLink = isLink;
            this.redirectURL = redirectURL;
        }
    }

}