@isTest
public class SkipTaskTrigger_Test{
    Static TestMethod void SkipTaskMethod(){
        SkipTaskTrigger sc = New SkipTaskTrigger();
        SkipTaskTrigger.skiptrigger = False;
        SkipTaskTrigger.isSkipTrg();
        SkipTaskTrigger.setSkipTrgTrue();
    }
    Static TestMethod void SkipTaskMethod2(){
        SkipTaskTrigger sc = New SkipTaskTrigger();
        SkipTaskTrigger.skiptrigger = True;
        SkipTaskTrigger.isSkipTrg();
        SkipTaskTrigger.setSkipTrgTrue();
    }
}