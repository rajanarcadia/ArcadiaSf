public with sharing class UsageAndDownstreamDataDeletionBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public UsageAndDownstreamDataDeletionBatch() {
    }

    public Database.Querylocator start(Database.BatchableContext bc) {
        
        UtilityMeterUsageSelector selector = new UtilityMeterUsageSelector(false, false, false);
        Logger.getInstance(false)
            .log(UsageAndDownstreamDataDeletionBatch.class.getName(), Logger.Level.INFO, 'Usage and Downstream Data Deletion Batch Started');

        return selector.getUsagesToBeDeleted();
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        try {
            if (scope.size() > 0) {
                UtilityMeterUsageService.deleteDownstreamData(scope);
            }
        } catch (Exception e) {
            Logger.getInstance().log(UsageAndDownstreamDataDeletionBatch.class.getName(), 'Error in UsageAndDownstreamDataDeletionBatch: '+ e);
        }
        
    }
    
    public void finish(Database.BatchableContext bc) {
        Logger.getInstance(false).log(UtilityMeterAndUsageUpdateBatch.class.getName(), Logger.Level.INFO, 'Usage and Downstream Data Deletion Batch Completed');

    }
}