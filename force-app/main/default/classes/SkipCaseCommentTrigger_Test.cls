@isTest
public class SkipCaseCommentTrigger_Test{
    Static TestMethod void SkipTaskMethod(){
        SkipCaseCommentTrigger sc = New SkipCaseCommentTrigger();
        SkipCaseCommentTrigger.skipTrigger = False;
        SkipCaseCommentTrigger.isSkipTrg();
        SkipCaseCommentTrigger.setSkipTrgTrue();
    }
    Static TestMethod void SkipTaskMethod2(){
        SkipCaseCommentTrigger sc = New SkipCaseCommentTrigger();
        SkipCaseCommentTrigger.skipTrigger = True;
        SkipCaseCommentTrigger.isSkipTrg();
        SkipCaseCommentTrigger.setSkipTrgTrue();
    }
}