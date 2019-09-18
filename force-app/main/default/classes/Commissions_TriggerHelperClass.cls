public with sharing class Commissions_TriggerHelperClass {
    public static boolean firstRun = false;
    public static boolean secondRun = false;
    public static boolean quotaTriggerCheck = false;
    public static boolean quotaTriggerRDCheck = false;
    public static boolean quotaTriggerRDCheckRun = false;
    public static boolean quotaTriggerRDCheckRuntwo = false;
    public static boolean quotaTriggerafter = false;
    public static boolean run =false;
    public static boolean CaseTriggerRun = false;
    public static boolean orderItemHandler = true;
    public static boolean quotaTriggerRDCheck1 = false;
    public static boolean QuotaTriggerNew = false;
    public static boolean payoutApproval = false;    
    public static boolean payoutApprovalAfter= false;
    public static boolean kickerQualifier =false;
    public static  void  recursiveHelper (Boolean tempBool){
        firstRun = tempBool;
    }
}