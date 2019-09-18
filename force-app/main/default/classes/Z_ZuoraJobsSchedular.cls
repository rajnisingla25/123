public class Z_ZuoraJobsSchedular implements Schedulable {
    
    public static void execute(SchedulableContext sc) {
        String Comment = '';
        Boolean sendeEmail = false;
        try{
            Map<String, ZuoraSchedulesJobSetting__c> Settings = ZuoraSchedulesJobSetting__c.getall();
            List<ZuoraSchedulesJobSetting__c> updatesettings = new List<ZuoraSchedulesJobSetting__c>();            
            try{
                for(String inloop: Settings.keyset()){ 
                    ZuoraSchedulesJobSetting__c setting = Settings.get(inloop);
                    if(setting!= null && !setting.Individual_Job__c && setting.Is_Running__c && setting.Schedule_Time__c < system.now()){
                        system.debug(inloop);
                        Type t = Type.forName(inloop);                   
                        Comment = 'Inside executing: '+ t + ' Schedule_Time__c: '+setting.Schedule_Time__c+ '  Executaion interval :' + setting.Execution_interval__c;
                        system.debug(Comment);
                        Schedulable ee = (Schedulable)t.newInstance(); 
                        ee.execute(null);
                        setting.Last_execution__c = system.now();
                        Datetime nextShceduleTime = setting.Schedule_Time__c.addminutes(integer.valueof(setting.Execution_interval__c));
                        if(nextShceduleTime < system.now())
                            nextShceduleTime = system.now().addminutes(integer.valueof(setting.Execution_interval__c));                                                           
                        setting.Schedule_Time__c = nextShceduleTime;                   
                        updatesettings.add(setting);
                    }                   
                }
            }catch(exception ex){
                Comment += Comment + ' Message : ' + ex.getmessage();
                sendeEmail = true;
            }
            system.debug('at abort '+SC.getTriggerId());
            try{
            System.abortJob(SC.getTriggerId()); 
            }catch(exception ex){
               System.debug('exception at abort ' +ex);
            }
            ZuoraSchedulesJobSetting__c setting = Settings.get('Z_ZuoraJobsSchedular');
            if(setting != null && setting.Is_Running__c){
                Z_ZuoraJobsSchedular pp = new Z_ZuoraJobsSchedular();  
                Datetime dtime = System.now().addMinutes(integer.valueof(setting.Execution_interval__c));
                String tt = dtime.Second() + ' ' + dtime.Minute() + ' ' + dtime.hour() + ' ' + dtime.day() + ' ' + dtime.Month() + ' ? ' + dtime.year();
                system.schedule('Z_ZuoraJobsSchedular' + dtime, tt, pp);
                setting.Last_execution__c = system.now();
                updatesettings.add(setting);
            }
            update updatesettings;
        }catch(exception ex){
           Comment += Comment + ' at rescheduling : ' + ex.getmessage(); 
       		 sendeEmail = true; 
        }
        
        if(sendeEmail){
            sendemail(Comment);
        }
        
    }
     public static void sendemail(String Exceptionmessage){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();   
        String toAddresses = UserInfo.getUserEmail();
         String custAddresses = '';
         if(Error_Notification_Email_Settings__c.getInstance('ZuoraJobNotification')!= null)
        custAddresses = Error_Notification_Email_Settings__c.getInstance('ZuoraJobNotification').Suspension_Failure__c; 
        mail.Subject = 'Zuora Z_ZuoraJobsSchedular Job failed to run';
        if(custAddresses!=null && custAddresses != '')
        toAddresses += ';'+custAddresses;
        mail.setToAddresses(toAddresses.split(';'));
        mail.plainTextBody = Exceptionmessage;       
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {mail};
        Messaging.SendEmailResult[] resu= Messaging.sendEmail(messages);     
        system_logs__c logs = new system_logs__c();         
        logs.Object_Type__c = 'Z_ZuoraJobsSchedular';
        logs.Message__c =Exceptionmessage;
        insert logs;        
    }
   /* Datetime dtime = System.now().addminutes(1);
         String tt = dtime.Second() + ' ' + dtime.Minute() + ' ' + dtime.hour() + ' ' + dtime.day() + ' ' + dtime.Month() + ' ? ' + dtime.year();               
         System.schedule('Z_ZuoraJobsSchedular-'+ dtime, tt, new Z_ZuoraJobsSchedular());  */
      
}