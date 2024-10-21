public with sharing class UtilityMeterSyncBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public UtilityMeterSyncBatch() {
    }

    public Database.Querylocator start(Database.BatchableContext bc) {
        Logger.getInstance(false)
            .log(UtilityMeterSyncBatch.class.getName(), Logger.Level.INFO, 'Utility Meter Sync Batch Started');
        UtilityMeterSelector selector = new UtilityMeterSelector(false, false, false);
        return selector.getUtilityMetersWithNullValues();
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        if (scope.size() > 0) {
            UtilityMeterUsageService.checkForMeterWithUsageIdNullAndDelete(scope);
        }
    }
    public void finish(Database.BatchableContext bc) {
        // Delete Water usages if Growth package is not present.
        Map<String, String> deleterMapping = UrjanetUtils.getServiceToDeleterTypeMappings();
        if (!deleterMapping.containsKey('water')) {
            UtilityMeterUsageService.deleteGrowthMeterUsages();
        }        

        Logger.getInstance(false)
            .log(
                UtilityMeterSyncBatch.class.getName(),
                Logger.Level.INFO,
                'QueueItems Successfully Created for Meters Processing.'
            );
    }
}