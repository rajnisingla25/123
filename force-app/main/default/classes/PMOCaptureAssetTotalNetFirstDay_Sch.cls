global class PMOCaptureAssetTotalNetFirstDay_Sch implements Schedulable {
   global void execute(SchedulableContext sc) {
        PMOCaptureAssetTotalNetFirstDay p = new PMOCaptureAssetTotalNetFirstDay();
        Database.executeBatch(p);
   }
}