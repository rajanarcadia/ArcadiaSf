public class StationaryAssetEnergyUseProcessor implements IUtilityMeterUsageProcessor {
    public void processUtilityMeterUsage(UtilityMeterUsage__c meterUsage) {
        StationaryAssetEnergyUseService.createStationaryAssetEnergyUses(meterUsage);
    }
}