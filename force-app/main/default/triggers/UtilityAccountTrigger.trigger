trigger UtilityAccountTrigger on UtilityAccount__c(after insert, before update) {
    Domain.triggerHandler(UtilityAccountDomain.class);
}