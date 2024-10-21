public with sharing class UtilityMeterDomain extends Domain {
    public UtilityMeterDomain(List<UtilityMeter__c> records) {
        super(records);
    }

    public override void onAfterInsert() {
        UtilityMeterService.createQueueItemsForUtilityMeters((List<UtilityMeter__c>) this.records);
    }

    public override void onAfterUpdate(Map<Id, SObject> oldMap) {
        UtilityMeterService.createQueueItemsForUtilityMeters(
            (List<UtilityMeter__c>) this.records,
            (Map<Id, UtilityMeter__c>) oldMap
        );
        UtilityMeterService.createQueueItemsForSiteUpdate(
            (List<UtilityMeter__c>) this.records,
            (Map<Id, UtilityMeter__c>) oldMap
        );
    }
}