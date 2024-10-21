public class StationaryAssetEnergyUseDeleter implements IStationaryAssetDeleter {
    public void deleteStationaryAsset(UtilityMeterUsage__c meterUsage) {
        Database.DMLOptions option = new Database.DMLOptions();
        option.OptAllOrNone = false;
        try {
            List<StnryAssetEnrgyUse> energy = [
                SELECT Id
                FROM StnryAssetEnrgyUse
                WHERE UtilityMeterUsage__r.Id = :meterUsage.Id
            ];

            if (!energy.isEmpty()) {
                Logger.getInstance(false)
                    .log(
                        StationaryAssetEnergyUseDeleter.class.getName(),
                        Logger.Level.DEBUG,
                        'Deleting Stationary Asset Energy Usage: ' + energy.size()
                    );
                Data.remove(energy, false, false, false);
            }
        } catch (DmlException e) {
            Logger.getInstance()
                .log(
                    StationaryAssetEnergyUseDeleter.class.getName(),
                    Logger.Level.ERROR,
                    'Error in deleting StnryAssetEnrgyUse : ' + e.getMessage()
                );
        }
    }
}