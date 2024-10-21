public class ElectricMeterUsageDeleter implements IUtilityMeterUsageDeleter {
    public void deleteUtilityMeterUsage(List<Id> meterUsageIds) {
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
                    ElectricMeterUsageDeleter.class.getName(),
                    Logger.Level.DEBUG,
                    'Deleting StnryAssetEnrgyUse Usage: ' + energy.size()
                );
            Logger.getInstance(false)
                .log(
                    ElectricMeterUsageDeleter.class.getName(),
                    Logger.Level.DEBUG,
                    'Deleting Meter Usage: ' + meterUsageIds.size()
                );
            Data.remove(energy, false, false, false);
            Data.remove(meterUsageIds, false, false, false);
        } catch (DmlException e) {
            Logger.getInstance()
                .log(
                    ElectricMeterUsageDeleter.class.getName(),
                    Logger.Level.ERROR,
                    'Error in deleteUtilityMeterUsage Energy : ' + e.getMessage()
                );
        }
    }
}