@isTest
public class SkipIATrigger_Test{
    Static TestMethod void SkipIATriggerMethod(){
        SkipIATrigger sc = New SkipIATrigger();
        SkipIATrigger.skiptrigger = False;
        SkipIATrigger.isSkipTrg();
        SkipIATrigger.setSkipTrgTrue();
    }
    Static TestMethod void SkipIATriggerMethod2(){
        SkipIATrigger sc = New SkipIATrigger();
        SkipIATrigger.skiptrigger = True;
        SkipIATrigger.isSkipTrg();
        SkipIATrigger.setSkipTrgTrue();
    }
}