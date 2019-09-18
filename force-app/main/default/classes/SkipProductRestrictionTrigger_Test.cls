@isTest
public class SkipProductRestrictionTrigger_Test{
    Static TestMethod void SkipCaseMethod(){
        SkipProductRestrictionTriggerTrigger sc = New SkipProductRestrictionTriggerTrigger();
        SkipProductRestrictionTriggerTrigger.skiptrigger = False;
        SkipProductRestrictionTriggerTrigger.isSkipTrg();
        SkipProductRestrictionTriggerTrigger.setSkipTrgTrue();
    }
    Static TestMethod void SkipCaseMethod2(){
        SkipProductRestrictionTriggerTrigger sc = New SkipProductRestrictionTriggerTrigger();
        SkipProductRestrictionTriggerTrigger.skiptrigger = True;
        SkipProductRestrictionTriggerTrigger.isSkipTrg();
        SkipProductRestrictionTriggerTrigger.setSkipTrgTrue();
    }
}