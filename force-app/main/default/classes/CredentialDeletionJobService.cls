public with sharing class CredentialDeletionJobService {
    //default constructor

    public static void createQueueItemsForCredentialDeletionLogs(
        List<Credential_Deletion_Log__c> credentialDeletionLogs
    ) {
        Type processorClass = QueueItemProcessorFactory.getProcessorType(Credential_Deletion_Log__c.SObjectType);
        List<Database.SaveResult> saveResults = new QueueItemsBuilder(credentialDeletionLogs, processorClass)
            .buildQueueItemsPerRecord()
            .createRecords();
        UrjanetUtils.logFailures(
            CredentialDeletionJobService.class.getName(),
            String.valueOf(Credential_Deletion_Log__c.SObjectType),
            saveResults
        );
    }

    public static void deleteCredentialDeletionLog(String deletionLogId) {
        List<Credential_Deletion_Log__c> credentialDeletionLogs = (List<Credential_Deletion_Log__c>) new CredentialDeletionJobSelector()
            .getCredentialDeletionLogBasedonDeletionLogId(deletionLogId);
        if (credentialDeletionLogs != null && !credentialDeletionLogs.isEmpty()) {
            Data.remove(credentialDeletionLogs, false, false, false);
        }
    }

    public static void updateCredentialDeletionLogWithError(String deletionLogId, String errorMsg) {
        List<Credential_Deletion_Log__c> credentialDeletionLogs = (List<Credential_Deletion_Log__c>) new CredentialDeletionJobSelector()
            .getCredentialDeletionLogBasedonDeletionLogId(deletionLogId);
        if (credentialDeletionLogs != null && !credentialDeletionLogs.isEmpty()) {
            credentialDeletionLogs[0].Error_Message__c = errorMsg;
            credentialDeletionLogs[0].Status__c = UrjanetConstants.CRED_DEL_STATUS_FAILED;
            DATA.modify(credentialDeletionLogs[0], false, false, false);
        }
    }
}