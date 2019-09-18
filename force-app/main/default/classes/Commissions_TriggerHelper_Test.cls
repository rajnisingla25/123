@isTest(seeAllData = false)
public class Commissions_TriggerHelper_Test {
private static boolean tempBool;
public static testMethod void mainTest1() {
tempBool = true;
Commissions_TriggerHelperClass.recursiveHelper(tempBool);

}
}