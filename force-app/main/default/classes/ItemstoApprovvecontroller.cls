public class ItemstoApprovvecontroller {
  
    ApexPages.standardController stdController= null;
    public ItemstoApprovvecontroller(ApexPages.StandardController controller) {
        stdController=controller;
    }
    public case Objectcase {get; set;}
    public List<case> lstcaseapprove {get; set;}
    ID caseid;
    Set<ID> caseids=new Set<ID>();
  
    public class item_wrapper {
        public item_wrapper(String CaseNumber,String caseId,String OwnerName,String OwnerId,String DateSubmited,String recordType,String requestType,String subject,String Description,Decimal AssetsTotalNet,id approvalid ) {
            this.CaseNumber = CaseNumber;
            this.CaseId = CaseId;
            this.OwnerName = OwnerName;
            this.OwnerId = OwnerId;
            this.AssetsTotalNet = AssetsTotalNet;
            this.DateSubmited = DateSubmited;
            this.subject=subject;
            this.Description = Description;
            this.recordType = recordType;
            this.requestType = requestType;
            this.approvalid =approvalid;
        }
        public String CaseNumber { get; set; }
        public String CaseId { get; set; }
        public string OwnerName { get; set; }
        public String OwnerId { get; set; }
        public Decimal AssetsTotalNet { get; set; }
        public String DateSubmited { get; set; }
        public String recordType { get; set; }
        public String Description { get; set; }       
        public string subject{ get; set; }
        public string requestType {get; set;}
        public id approvalid { get; set; }
      
    }
  
    public list<item_wrapper> items_to_approve { get; set; }
  
    public ItemstoApprovvecontroller() {
        items_to_approve = new list<item_wrapper>();
      
        map<id,ProcessInstanceWorkItem> mpaPIWIdToPIW = new map<id,ProcessInstanceWorkItem>();
        list<ProcessInstanceWorkItem> lstPIWI = [select processinstance.targetobjectid,CreatedDate ,processinstance.targetobject.name,ProcessInstance.TargetObject.type from processinstanceworkitem where actorid = :userinfo.getuserid() Order by CreatedDate Desc];
        if(!lstPIWI.isEmpty()){
            for(ProcessInstanceWorkItem item: lstPIWI) {
                caseids.add(item.processinstance.targetobjectid);
                if(!mpaPIWIdToPIW.containsKey(item.processinstance.targetobjectid)){
                    mpaPIWIdToPIW.put(item.processinstance.targetobjectid,item);
                }
            }
        }
      
        map<id,Case> mapcaseIdtoMeetingnotes = new map<id,Case>();
        map<id,String> mapcaseIdtoRTName = new map<id,String>();
      
        if(caseids.size()>0){
            lstcaseapprove=[select id, CaseNumber, Owner_Name__c, OwnerId, Description, RecordTypeId, Case_Assets_Total_Net__c,status, Subject, Request_Type__c  from Case where id in : caseids];
            if(!lstcaseapprove.isEmpty()){
                for(case objcase:lstcaseapprove){
                    mapcaseIdtoMeetingnotes.put(objcase.id,objcase);
                    String RecordTypeName = Schema.SObjectType.Case.getRecordTypeInfosById().get(objcase.RecordTypeId).getName();
                    mapcaseIdtoRTName.put(objcase.Id,RecordTypeName);
                }
            }
        }
        if(!lstPIWI.isEmpty()){
          
            for(ProcessInstanceWorkItem item: mpaPIWIdToPIW.values()) {
                String dateTimeValue = item.CreatedDate.format('MM/dd/yyyy hh:mm a');
                system.debug(dateTimeValue +'Debug2 dateTimeValue ');
                if(item.processinstance.TargetObject.type == 'Case'){
                                    system.debug(item.processinstance.targetobjectid +'Debug2 dateTimeValue ');

                    items_to_approve.add(new item_wrapper(mapcaseIdtoMeetingnotes.get(item.processinstance.targetobjectid).CaseNumber,
                    mapcaseIdtoMeetingnotes.get(item.processinstance.targetobjectid).Id,
                    mapcaseIdtoMeetingnotes.get(item.processinstance.targetobjectid).Owner_Name__c,
                    mapcaseIdtoMeetingnotes.get(item.processinstance.targetobjectid).OwnerId,
                    dateTimeValue,
                    mapcaseIdtoRTName.get(item.processinstance.targetobjectid),
                    mapcaseIdtoMeetingnotes.get(item.processinstance.targetobjectid).Request_Type__c,
                    mapcaseIdtoMeetingnotes.get(item.processinstance.targetobjectid).Subject,
                    mapcaseIdtoMeetingnotes.get(item.processinstance.targetobjectid).Description,                    
                    mapcaseIdtoMeetingnotes.get(item.processinstance.targetobjectid).Case_Assets_Total_Net__c,item.id ));
                }/*else{
                   system.debug(item.processinstance.targetobjectid +'Debug2 dateTimeValue ');


                    String sObjName = item.processinstance.targetobjectid.getSObjectType().getDescribe().getLabel(); 
                                                           system.debug(sObjName +'sObjNameValue ');

                    items_to_approve.add(new item_wrapper(item.processinstance.targetobjectid,item.processinstance.targetobject.name,sObjName ,dateTimeValue ,'',item.id )); 
                }*/
            }
        }
    }   
    public  static String ApproveRejectnavigation() {
        String url=''; 
        string myParam = apexpages.currentpage().getparameters().get('myParam');
        url='https://'+ System.URL.getSalesforceBaseUrl().getHost() + 
            '/p/process/ProcessInstanceWorkitemWizardStageManager?id=' + myParam ;     
      
        return url; 
      
    }
    public  static String REASSIGNnavigation() {
        String url=''; 
        string myParam = apexpages.currentpage().getparameters().get('myParam');
        url='https://'+ System.URL.getSalesforceBaseUrl().getHost()+'/'+ myParam +'/e?et=REASSIGN';     
        return url; 
      
    }
  
}