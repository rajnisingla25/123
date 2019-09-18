public Class checkRecursive{
    public static boolean run = true;
    public static boolean runone = true;
    public static boolean runTwo = true;
    public static boolean runthree = true;
    
    public static boolean runOnce(){
        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
    }
}