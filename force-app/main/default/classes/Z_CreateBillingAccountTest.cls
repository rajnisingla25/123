@isTest
public class Z_CreateBillingAccountTest {

    
       
    static testmethod void testCreateBillingAccountTest()
    {
        string accid='801Z0000000F0fd';
        string order = '003Z000001OpsGZ';
        string zbillingId='500Z000000BrlRn';
        test.startTest();
        Z_CreateBillingAccount sh1 = new Z_CreateBillingAccount(accid,order,zbillingid);      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
        
        
     }   
}