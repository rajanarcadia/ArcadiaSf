/**
 * Created by mike on 5/10/22.
 */

public with sharing class QueueItemProcessorFactory {
    public static Type getProcessorType(SObjectType objectType) {
        if (objectType == UtilityMeter__c.SObjectType) {
            return UtilityMeterProcessor.class;
        } else if (objectType == UtilityMeterUsage__c.SObjectType) {
            return UtilityMeterUsageProcessor.class;
        } else if (objectType == UtilityCredential__c.SObjectType) {
            return UtilityCredentialProcessor.class;
        } else if (objectType == UtilityAccount__c.SObjectType) {
            return UtilityAccountProcessor.class;
        } else if (objectType == UtilityStatementFile__c.SObjectType) {
            return UtilityStatementFileProcessor.class;
        } else if (objectType == Credential_Deletion_Log__c.SObjectType) {
            return CredentialDeletionJobProcessor.class;
        } else {
            throw new NoProcessorDefinedException();
        }
    }

    public class NoProcessorDefinedException extends Exception {
    }
}