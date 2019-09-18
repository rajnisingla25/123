/************************************************************
Author : Bala
Description: Test class for SkipCaseTrigger class
*************************************************************/

@isTest
public class SkipCaseTrigger_Test{
    Static TestMethod void SkipCaseMethod(){
        SkipCaseTrigger sc = New SkipCaseTrigger();
        SkipCaseTrigger.skiptrigger = False;
        SkipCaseTrigger.isSkipTrg();
        SkipCaseTrigger.setSkipTrgTrue();
    }
    Static TestMethod void SkipCaseMethod2(){
        SkipCaseTrigger sc = New SkipCaseTrigger();
        SkipCaseTrigger.skiptrigger = True;
        SkipCaseTrigger.isSkipTrg();
        SkipCaseTrigger.setSkipTrgTrue();
    }
}