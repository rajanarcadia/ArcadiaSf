public with sharing class UtilityAccountDomain extends Domain {
    public UtilityAccountDomain(List<UtilityAccount__c> utilityAccounts) {
        super(utilityAccounts);
    }

    public override void onAfterInsert() {
        UtilityAccountService.createQueueItemsForUtilityAccounts((List<UtilityAccount__c>) this.records);
    }

    public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
        UtilityAccountService.createQueueItemsForUtilityAccounts(
            (List<UtilityAccount__c>) this.records,
            (Map<Id, UtilityAccount__c>) oldMap
        );
    }
}