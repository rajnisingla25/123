@isTest 
private class PMOCaptureAssetTotalNetFirstDay_Sch_Test {
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    static testmethod void testSch() {
        String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new PMOCaptureAssetTotalNetFirstDay_Sch());
    }
}