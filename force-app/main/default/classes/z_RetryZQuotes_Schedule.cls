//CRM-1686 Retry failed ZQuotes

public class z_RetryZQuotes_Schedule  implements schedulable{   
    List<Order> Orderlisttosend = new List<Order>();
    Boolean isretry =false;
    
    public z_RetryZQuotes_Schedule() {
        isretry =false;
    }
    public z_RetryZQuotes_Schedule(List<Order> orderlisttosend) {
        
        System.debug('Starting constructor 2');
        this.Orderlisttosend = orderlisttosend;
        isretry =true;
        
    }
    public void execute(SchedulableContext SC){
    
        if(!isretry){
            List<OrderItem> accountOrderItems = new List<OrderItem>();
            accountOrderItems = [Select Id, orderId,Order.AccountId, Zuora_Comment__c, Zuora_Status__c, (Select Id, zqu__Status__c From Quotes__r order by createddate ASC)
                FROM OrderItem 
            WHERE Order.EffectiveDate >= today and Zuora_Status__c = 'Error' and Zuora_Comment__c != 'Sent to Z-Billing' LIMIT 300];
           //Order.EffectiveDate = today and
            List<OrderItem> Orderitemtoupdate =  new List<OrderItem>();
            Set<Order> OrdertoSend =  new Set<Order>();
            List<zqu__Quote__c> ZQuotetoDelete =  new List<zqu__Quote__c>();
            for(OrderItem inloop:accountOrderItems){
                Boolean SkipOrderitem = false;
                for(zqu__Quote__c inloop2: inloop.Quotes__r){           
                    
                    if(inloop2.zqu__Status__c!= 'Sent to Z-Billing'){
                        zqu__Quote__c zqu = new zqu__Quote__c();
                        zqu.Id = inloop2.Id;
                        ZQuotetoDelete.add(zqu);                
                        }else{
                        SkipOrderitem = true; 
                        break;
                    }               
                }
                if(!SkipOrderitem){
                    OrderItem Oupdate = new OrderItem();
                    Oupdate.Id = inloop.Id;
                    Oupdate.Zuora_Status__c = '';
                    Oupdate.Zuora_Comment__c = '';
                    Orderitemtoupdate.add(Oupdate);
                    Order ord = new Order();
                    ord.Id = inloop.orderId;
                    Ord.AccountId = inloop.Order.AccountId;
                    OrdertoSend.add(Ord);
                }
                
            }
            
            if(OrdertoSend!=null && !OrdertoSend.isEmpty()){
            SkipOrderItemTrigger.setSkipTrgTrue();
                delete ZQuotetoDelete;
                update Orderitemtoupdate;
                Orderlisttosend = new List<Order>(OrdertoSend);
                
            }
        }
        
        if(Orderlisttosend!= null && !Orderlisttosend.isEmpty()){
        system.debug('Orderi@@@@ ' + Orderlisttosend.size());
        system.debug('Orderi@@ ' + Orderlisttosend);
        integer Availablejobs = 93 - [SELECT count() FROM CronTrigger where nextfiretime != null];                  
        Integer jobsize = Availablejobs > 15 ? 15 : Availablejobs;
        Integer Sendsize = Orderlisttosend.size() > jobsize ? jobsize : Orderlisttosend.size();
        system.debug('Sendsize# ' + Sendsize);
          
            for(Integer i = 0; i < Sendsize; i++){
                system.debug('i@ ' + i);                             
                system.debug('Orderi@ ' + Orderlisttosend.get(0));
                OrderDecompController controller = new OrderDecompController(Orderlisttosend.get(0));
                Orderlisttosend.remove(0);
                
            }
            if(Orderlisttosend.size()>0){
                z_RetryZQuotes_Schedule.Scheduleremainingorderlist(480 ,Orderlisttosend); 
                
            }
         }
        
    }
    public static void Scheduleremainingorderlist(Integer seconds, List<Order> RemainingOrderlist) {
       System.debug(' Scheduling ');
        DateTime now = datetime.now().addSeconds(seconds);
        String scheduledDateTime = '';
        scheduledDateTime += now.second();
        scheduledDateTime += ' ' + now.minute();
        scheduledDateTime += ' ' + now.hour();
        scheduledDateTime += ' ' + now.day();
        scheduledDateTime += ' ' + now.month();
        scheduledDateTime += ' ' + '?';
        scheduledDateTime += ' ' + now.year();

        String scheduledTaskName = 'Z_ScheduleRemainingOrderlisttoZQuotes ' + DateTime.now() + System.currentTimeMillis();
        String scheduledJobId = System.schedule(scheduledTaskName, scheduledDateTime, new z_RetryZQuotes_Schedule(RemainingOrderlist));
      
    }
    
}