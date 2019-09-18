@isTest
public class SortUserIdCountClass_Test {

    static testMethod void sortUserClass()
    {
        
        SortUserIdCountClass srt = new SortUserIdCountClass();
        //enum e {10,20,30,40,50};
          srt.aleadcount=20;
          srt.userIds='00123456789789';
        SortUserIdCountClass srt1 = new SortUserIdCountClass();
        srt1.aleadcount=30;  
        integer i = srt1.compareTo(srt);
    }
}