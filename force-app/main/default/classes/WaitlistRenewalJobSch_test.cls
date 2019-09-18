@isTest
private class WaitlistRenewalJobSch_test {
    private static testmethod void test(){
        System.Test.startTest() ; 
        WaitlistRenewalJobSch sh1 = new WaitlistRenewalJobSch();      
        String sch = '0 0 23 * * ?';
        system.schedule('waitlist renwal job', sch, sh1);
        
        
        System.Test.stopTest() ; 
        
    }
}