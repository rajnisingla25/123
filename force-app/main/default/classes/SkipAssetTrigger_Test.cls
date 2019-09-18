@isTest
public class SkipAssetTrigger_Test{
    Static TestMethod void SkipAssetMethod(){
        //SkipCaseTrigger sc = New SkipCaseTrigger();
        SkipAssetTrigger.skiptrigger = False;
        SkipAssetTrigger.isSkipTrg();
        SkipAssetTrigger.setSkipTrgTrue();
    }
    Static TestMethod void SkipAssetMethod2(){
        //SkipCaseTrigger sc = New SkipCaseTrigger();
        SkipAssetTrigger.skiptrigger = True;
        SkipAssetTrigger.isSkipTrg();
        SkipAssetTrigger.setSkipTrgTrue();
    }
}