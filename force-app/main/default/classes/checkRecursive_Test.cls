@isTest
private class checkRecursive_Test{
    public static testMethod void main1(){       
       checkRecursive.run = true;
       checkRecursive.runone = true;
       checkRecursive.runTwo = true;
       checkRecursive.runthree = true;       
       checkRecursive obj = new checkRecursive();
       checkRecursive.runOnce();
    }
    public static testMethod void main2(){       
       checkRecursive.run = false;
       checkRecursive.runone = true;
       checkRecursive.runTwo = true;
       checkRecursive.runthree = true;       
       checkRecursive obj = new checkRecursive();
       checkRecursive.runOnce();
    }
}