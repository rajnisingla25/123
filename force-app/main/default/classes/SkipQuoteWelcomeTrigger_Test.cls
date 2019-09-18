@isTest
public class SkipQuoteWelcomeTrigger_Test{
    Static TestMethod void SkipTaskMethod(){
        SkipQuoteWelcomeTrigger sc = New SkipQuoteWelcomeTrigger();
        SkipQuoteWelcomeTrigger.skiptrigger = False;
        SkipQuoteWelcomeTrigger.isSkipTrg();
        SkipQuoteWelcomeTrigger.setSkipTrgTrue();
    }
    Static TestMethod void SkipTaskMethod2(){
        SkipQuoteWelcomeTrigger sc = New SkipQuoteWelcomeTrigger();
        SkipQuoteWelcomeTrigger.skiptrigger = True;
        SkipQuoteWelcomeTrigger.isSkipTrg();
        SkipQuoteWelcomeTrigger.setSkipTrgTrue();
    }
}