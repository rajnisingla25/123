@isTest
public class SkipTrigger_Test{
    Static TestMethod void SkipTaskMethod(){
        SkipTrigger sc = New SkipTrigger();
        SkipTrigger.skiptrigger = False;
        SkipTrigger.isSkipTrg();
        SkipTrigger.setSkipTrgTrue();
    }
    Static TestMethod void SkipTaskMethod2(){
        SkipTrigger sc = New SkipTrigger();
        SkipTrigger.skiptrigger = True;
        SkipTrigger.isSkipTrg();
        SkipTrigger.setSkipTrgTrue();
    }
}