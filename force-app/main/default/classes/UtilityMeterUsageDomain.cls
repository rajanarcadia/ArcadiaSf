public with sharing class UtilityMeterUsageDomain extends Domain {
    public UtilityMeterUsageDomain(List<UtilityMeterUsage__c> records) {
        super(records);
    }

    public override void onAfterInsert() {
        UtilityMeterUsageService.createQueueItemsForUtilityMeterUsages((List<UtilityMeterUsage__c>) this.records);
    }

    public override void onAfterUpdate(Map<Id, SObject> oldMap) {
        UtilityMeterUsageService.createQueueItemstoUpdateUtilityMeterUsages(
            (List<UtilityMeterUsage__c>) this.records,
            (Map<Id, UtilityMeterUsage__c>) oldMap
        );
    }
}