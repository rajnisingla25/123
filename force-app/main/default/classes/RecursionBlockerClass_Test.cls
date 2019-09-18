@isTest
private class RecursionBlockerClass_Test{
    public static testMethod void main1(){       
       RecursionBlockerClass.runOnceBool = true; 
       RecursionBlockerClass.runTwiceBool = true;     
       RecursionBlockerClass obj = new RecursionBlockerClass();
       RecursionBlockerClass.runOnce();
       RecursionBlockerClass.runTwice ();
    }
    public static testMethod void main2(){       
       RecursionBlockerClass.runOnceBool = false; 
       RecursionBlockerClass.runTwiceBool = false;     
       RecursionBlockerClass obj = new RecursionBlockerClass();
       RecursionBlockerClass.runOnce();
       RecursionBlockerClass.runTwice();
    }
}