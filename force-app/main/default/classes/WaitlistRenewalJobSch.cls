global class WaitlistRenewalJobSch implements Schedulable {

    global void execute(SchedulableContext sc){
        Database.executeBatch(new WaitlistRenewalJob(),20);
    }
}