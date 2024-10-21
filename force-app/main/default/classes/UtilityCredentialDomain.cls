public with sharing class UtilityCredentialDomain extends Domain {
    public UtilityCredentialDomain(List<UtilityCredential__c> utilityCredentials) {
        super(utilityCredentials);
    }

    public override void onAfterInsert() {
        UtilityCredentialService.generateCorrelationId((List<UtilityCredential__c>) this.records, null);
        UtilityCredentialService.createQueueItemsForUtilityCredentials((List<UtilityCredential__c>) this.records);
    }

    public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
        UtilityCredentialService.generateCorrelationId(
            (List<UtilityCredential__c>) this.records,
            (Map<Id, UtilityCredential__c>) oldMap
        );
        UtilityCredentialService.createQueueItemsForUtilityCredentials(
            (List<UtilityCredential__c>) this.records,
            (Map<Id, UtilityCredential__c>) oldMap
        );
    }
}