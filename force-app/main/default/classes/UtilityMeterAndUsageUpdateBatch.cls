public with sharing class UtilityMeterAndUsageUpdateBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public UtilityMeterAndUsageUpdateBatch() {
    }

    public Database.Querylocator start(Database.BatchableContext bc) {
        UtilityMeterUsageSelector selector = new UtilityMeterUsageSelector(false, false, false);
        Logger.getInstance(false)
            .log(
                UtilityMeterAndUsageUpdateBatch.class.getName(),
                Logger.Level.INFO,
                'Utility Meter And Usage Update Sync Batch Started'
            );

        return selector.getUsagesToBeCheckedForDuplicacy();
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        try {
            Set<Id> recordIds = new Set<Id>();
            for (sObject record : scope) {
                recordIds.add(record.Id);
            }
            // Querying to get the updated Records
            List<UtilityMeterUsage__c> updatedRecords = [
                SELECT
                    Id,
                    MeasuredUsage__c,
                    UsageUnit__c,
                    MeasuredUsageInText__c,
                    PeriodStart__c,
                    PeriodEnd__c,
                    Arcadia_Statement_ID__c,
                    To_Be_Ignored__c,
                    UtilityMeter__c,
                    UtilityMeter__r.PodNumber__c,
                    UtilityMeter__r.ServiceType__c,
                    UtilityMeter__r.StationaryAssetEnvironmentalSource__c,
                    UtilityMeter__r.Enabled__c
                FROM UtilityMeterUsage__c
                WHERE Id IN :recordIds AND To_Be_Ignored__c = FALSE AND UtilityMeter__r.Enabled__c = TRUE
                ORDER BY CreatedDate ASC
            ];

            if (!updatedRecords.isEmpty()) {
                UtilityMeterUsageService.validateMeterAndUsages(updatedRecords);
            }
        } catch (Exception e) {
            Logger.getInstance(false)
                .log(
                    UtilityMeterAndUsageUpdateBatch.class.getName(),
                    'Error in UtilityMeterAndUsageUpdateBatch: ' + e.getMessage() + ' ' + e.getStackTraceString()
                );
        }
    }

    public void finish(Database.BatchableContext bc) {
        Logger.getInstance(false)
            .log(
                UtilityMeterAndUsageUpdateBatch.class.getName(),
                Logger.Level.INFO,
                'Utility Meter And Usage Update Sync Batch Completed'
            );
        try {
            Database.executeBatch(new UsageAndDownstreamDataDeletionBatch());
        } catch (Exception e) {
            Logger.getInstance(false)
                .log(
                    UsageAndDownstreamDataDeletionBatch.class.getName(),
                    'Error in UsageAndDownstreamDataDeletionBatch: ' + e.getMessage() + ' ' + e.getStackTraceString()
                );
        }
    }
}