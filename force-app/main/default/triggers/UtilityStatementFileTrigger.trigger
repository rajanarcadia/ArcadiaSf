trigger UtilityStatementFileTrigger on UtilityStatementFile__c (after insert,after update) {
    Domain.triggerHandler(UtilityStatementFileDomain.class);
}