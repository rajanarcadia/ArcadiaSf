trigger UtilityMeterUsageTrigger on UtilityMeterUsage__c(after insert, after update) {
    Domain.triggerHandler(UtilityMeterUsageDomain.class);
}