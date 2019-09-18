public class displaycases {

    public displaycases() {

    }


    public displaycases(ApexPages.StandardController controller) {
      
    }

  public string getQueue {get;set;}  
  public string QueueId {get;set;}
  public  void displaycase (){}
  public list<case> caselst{get;set;}
  set<id> QueueIds = new set<id>();
   
  
    public list<selectoption> getQueue(){
        List<SelectOption> options = new List<SelectOption>();        
        for (QueueSobject  Q : [Select Queue.Name,SobjectType,QueueId,Id From QueueSobject where SobjectType = 'Case']){                    
        options.add(new SelectOption(Q.Queue.Name,Q.Queue.Name));
            QueueIds.add(Q.QueueId);         
        }
        return options;
    }
    
    public void displaycaselist(){
     
        caselst=new list<case>();
        caselst=[SELECT CaseNumber,ClosedDate,IsClosed,IsEscalated,Priority,Reason,Status,Subject,Type FROM Case where Status != 'Closed' and OwnerId IN :QueueIds];
       
    }
}