/************************************************************
Author : Vinay
Description: Test class for SkipCaseTrigger class
*************************************************************/

@isTest
public class SkipQuotaTrigger_Test{
    Static TestMethod void SkipQuotaTriggerMethod(){
        SkipQuotaTrigger sc = New SkipQuotaTrigger();
        SkipQuotaTrigger.skiptrigger = False;
        SkipQuotaTrigger.isSkipTrg();
        SkipQuotaTrigger.setSkipTrgTrue();
    }
    Static TestMethod void SkipQuotaTriggerMethod2(){
        SkipQuotaTrigger sc = New SkipQuotaTrigger();
        SkipQuotaTrigger.skiptrigger = True;
        SkipQuotaTrigger.isSkipTrg();
        SkipQuotaTrigger.setSkipTrgTrue();
    }
}