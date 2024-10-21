public with sharing class CredentialDeletionJobProcessor extends QueueItemWorkerBase {
    public override QueueItem__c process(QueueItem__c queueItem) {
        // Ignoring security here since this is a system process
        Credential_Deletion_Log__c credentialJobToProcess = (Credential_Deletion_Log__c) new CredentialDeletionJobSelector(
                false,
                false,
                false
            )
            .getRecordById(queueItem.RecordId__c);

        if (credentialJobToProcess == null || credentialJobToProcess.Deletion_Log_Id__c == null) {
            Logger.getInstance()
                .log(
                    CredentialDeletionJobProcessor.class.getName(),
                    Logger.Level.WARN,
                    'Unable to Process Credential Deletionlog as Deletion_Log_Id__c is null : ' + queueItem.RecordId__c
                );
            return queueItem;
        }

        CredentialDeletionJobApiResponse deletionJobResponse = (CredentialDeletionJobApiResponse) new UrjanetApiClient()
            .getUrjanetResponse(
                UrjanetEnums.RequestType.GET_DELETION_JOB_STATUS,
                UrjanetEnums.ApiMethod.GET,
                new List<String>{ credentialJobToProcess.Deletion_Log_Id__c }
            );
        if (
            deletionJobResponse.id != null &&
            (deletionJobResponse.status == UrjanetConstants.CRED_DELETION_JOB_STATUS_COMPLETED ||
            deletionJobResponse.status == UrjanetConstants.CRED_DELETION_JOB_STATUS_SUCCESS)
        ) {
            CredentialDeletionJobService.deleteCredentialDeletionLog(credentialJobToProcess.Deletion_Log_Id__c);
        }

        if (deletionJobResponse.errorMsg != null) {
            Logger.getInstance()
                .log(
                    CredentialDeletionJobProcessor.class.getName(),
                    Logger.Level.ERROR,
                    UrjanetConstants.ERROR_IN_PROCESSING_CREDENTIAL_DELETION_JOB +
                        credentialJobToProcess.Deletion_Log_Id__c +
                        (deletionJobResponse.statusCode != null
                            ? ' Status Code :' + String.valueOf(deletionJobResponse.statusCode)
                            : ' ') +
                        deletionJobResponse.errorMsg
                );

            CredentialDeletionJobService.updateCredentialDeletionLogWithError(
                credentialJobToProcess.Deletion_Log_Id__c,
                deletionJobResponse.errorMsg
            );
        }
        return queueItem;
    }
}