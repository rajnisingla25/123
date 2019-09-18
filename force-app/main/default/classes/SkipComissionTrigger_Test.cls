@isTest
public class SkipComissionTrigger_Test{
    Static TestMethod void SkipComissionMethod(){
        SkipComissionTrigger sc = New SkipComissionTrigger();
        SkipComissionTrigger.skiptrigger = False;
        SkipComissionTrigger.isSkipTrg();
        SkipComissionTrigger.setSkipTrgTrue();
    }
    Static TestMethod void SkipComissionMethod2(){
        SkipComissionTrigger sc = New SkipComissionTrigger();
        SkipComissionTrigger.skiptrigger = True;
        SkipComissionTrigger.isSkipTrg();
        SkipComissionTrigger.setSkipTrgTrue();
    }
}