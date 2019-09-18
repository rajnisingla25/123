@isTest
public class SkipBackoutAssetTrigger_Test{
    Static TestMethod void SkipCaseMethod(){
        SkipBackoutAssetTrigger sc = New SkipBackoutAssetTrigger();
        SkipBackoutAssetTrigger.skiptrigger = False;
        SkipBackoutAssetTrigger.isSkipTrg();
        SkipBackoutAssetTrigger.setSkipTrgTrue();
    }
    Static TestMethod void SkipCaseMethod2(){
        SkipBackoutAssetTrigger sc = New SkipBackoutAssetTrigger();
        SkipBackoutAssetTrigger.skiptrigger = True;
        SkipBackoutAssetTrigger.isSkipTrg();
        SkipBackoutAssetTrigger.setSkipTrgTrue();
    }
}