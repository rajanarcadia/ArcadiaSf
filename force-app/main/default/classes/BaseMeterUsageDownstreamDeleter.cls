public class BaseMeterUsageDownstreamDeleter implements IUtilityMeterUsageDownstreamDeleter {
    public void deleteMeterUsageDownstreamData(List<Id> meterUsageIds) {
        Database.DMLOptions option = new Database.DMLOptions();
        option.OptAllOrNone = false;
        try {
            List<StnryAssetEnrgyUse> energy = [
                SELECT Id
                FROM StnryAssetEnrgyUse
                WHERE UtilityMeterUsage__r.Id IN :meterUsageIds
            ];
            Logger.getInstance(false)
                .log(
                    BaseMeterUsageDownstreamDeleter.class.getName(),
                    Logger.Level.DEBUG,
                    'Deleting StnryAssetEnrgyUse: ' + energy.size()
                );
            Data.remove(energy, false, false, false);
        } catch (DmlException e) {
            Logger.getInstance()
                .log(
                    BaseMeterUsageDownstreamDeleter.class.getName(),
                    Logger.Level.ERROR,
                    'Error in deleteMeterUsageDownstreamData StnryAssetEnrgyUse : ' + e.getMessage()
                );
        }
    }
}