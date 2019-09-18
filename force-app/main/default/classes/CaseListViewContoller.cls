public with sharing class CaseListViewContoller {
    
    public String Queue {get;set;}
    public list<case> caselst{get;set;}  
    public list<CaseWrapper> caselstnew{get;set;}
    public List<QueueSobject> GroupNameList{get;set;} 
    public string caseId {get;set;}
    public string caseNumber {get;set;} 
     
   

    //public id caseID ;
    
    public CaseListViewContoller (){
        GroupNameList = new List<QueueSobject>();
        caseId =ApexPages.currentPage().getParameters().get('caseId');
        caseNumber          = '';
    } 
    
    public PageReference Refresh() {
        displaycaselist();          
        return null;
    }
    public List<SelectOption> QueueList{
        get{
         //List<GroupMember> groups = [select Id from GroupMember where Group.Type = 'Queue' and UserOrGroupId =: userinfo.getuserid()];
         
            GroupNameList  = [Select Queue.Name,SobjectType,QueueId,Id From QueueSobject where SobjectType = 'Case' Order by Queue.Name ASC];
            QueueList = new List<SelectOption>();            
            for(QueueSobject temp : GroupNameList){           
            
                QueueList.add(new SelectOption(temp.QueueId, temp.Queue.Name));            
           }        
            return QueueList;
        }
        set;
    }    
    
    public void displaycaselist(){     
        caselst =new list<case>();  
        caselstnew = new list<CaseWrapper>();
        
        if(Queue == 'Resolution_New'){
            caselst =[SELECT Id,CaseNumber,Priority,Status,SubStatus__c,Subject,ParentId,Parent.CaseNumber,Area__c,Account.name,ownerId ,owner.name,RecordTypeId,RecordType.Name,Contact.name,Sub_Area__c,Last_Worked_By__r.name,
                  LastModifiedById,CreatedDate,Last_Worked__c,Last_Worked_By__c,Type,StatusAsOfDate__c,Primary_MLS_Set_Id__c
                  FROM Case 
                  where  OwnerId =:Queue and status = 'New' order by Priority Asc , CreatedDate Asc];
        }else{
        
        caselst =[SELECT Id,CaseNumber,Priority,Status,SubStatus__c,Subject,ParentId,Parent.CaseNumber,Area__c,Account.name,ownerId ,owner.name,RecordTypeId,RecordType.Name,Contact.name,Sub_Area__c,Last_Worked_By__r.name,
                  LastModifiedById,CreatedDate,Last_Worked__c,Last_Worked_By__c,Type,StatusAsOfDate__c,Primary_MLS_Set_Id__c
                  FROM Case 
                  where  OwnerId =:Queue order by Priority Asc , CreatedDate Asc];  
                
         }          
        
        for(Case cs : caselst){     
            caselstnew.add(new CaseWrapper(cs));
        }
    }  
    
    public Pagereference Accept(){
        List<case> ownerChange = new List<case>();
        Integer count=0;
        for(CaseWrapper cs : caselstnew) {
            // chance of cs being null scenario has to  be handled.
            if(cs.checked == true) {
                count++;
            }
        }
        if(count>1){
            ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.ERROR,'Please select one case only');
            ApexPages.addMessage(myMsg) ;
            return null;
        }
        else {
            
            for(CaseWrapper cs : caselstnew) {
                if(cs.checked == true) {
                    caseID = cs.cs.Id; 
                    caseNumber = cs.cs.CaseNumber;
                    cs.cs.Ownerid = Userinfo.getUserid();
                    ownerChange.add(cs.cs);               
                }
            }
            if(ownerChange.size()>0){
                update ownerChange;
            }   
            
            Pagereference pg = New Pagereference('/' + caseId);
            pg.Setredirect(TRUE);
            //return pg;
            return null;
        }
        
    }
    
    public class CaseWrapper{
        Public case CS{Get;set;}
        public Boolean checked {get;set;}
        public  CaseWrapper(Case C){          
            this.Cs= c;
            this.checked = false;
        }
    }
    
   
    
}