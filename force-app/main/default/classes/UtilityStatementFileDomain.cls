public with sharing class UtilityStatementFileDomain extends Domain{
    public UtilityStatementFileDomain(List<UtilityStatementFile__c> lstUtilityStatementFiles) {
        super(lstUtilityStatementFiles);
    }

    public override void onAfterInsert() {
        UtilityStatementFileService.createQueueItemsForUtilityStatementFiles((List<UtilityStatementFile__c>) this.records);
    }

    public override void onAfterUpdate(Map<Id, SObject> oldMap) {
        UtilityStatementFileService.createQueueItemsForUtilityStatementFiles((List<UtilityStatementFile__c>) this.records,(Map<Id, UtilityStatementFile__c>) oldMap);
    }
}