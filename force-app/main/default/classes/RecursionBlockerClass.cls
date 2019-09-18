public class RecursionBlockerClass {
    public static boolean runOnceBool = true;
    public static boolean runOnce(){
        if(runOnceBool){
         runOnceBool=false;
         return true;
        }else{
            return runOnceBool;
        }
    }
    public static boolean runTwiceBool = true;
    public static boolean runTwice(){
        if(runTwiceBool){
         runTwiceBool=false;
         return true;
        }else{
            return runTwiceBool;
        }
    }

}