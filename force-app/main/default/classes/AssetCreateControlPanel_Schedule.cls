global class AssetCreateControlPanel_Schedule implements Schedulable
{
    
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new AssetCreateControlPanel_Batch (), 200);
    }
}