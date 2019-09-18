//LCM-49 Create subscription record in Zuora application. this Job will scheduled for retry.
public class Z_SubscriptionManagerErrorSchedular implements schedulable{
      public void execute(SchedulableContext sc) {
           Z_SubscriptionManagerSchedular.updateZuoraSubscriptions('Error');   
    }

}