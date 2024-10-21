trigger UtilityCredentialTrigger on UtilityCredential__c(after insert, before update) {
    Domain.triggerHandler(UtilityCredentialDomain.class);
}