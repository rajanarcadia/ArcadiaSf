public with sharing class UtilityCredentialProcessor extends QueueItemWorkerBase {
    public override QueueItem__c process(QueueItem__c queueItem) {
        // Ignoring security here since this is a system process
        UtilityCredential__c credentialToProcess = (UtilityCredential__c) new UtilityCredentialSelector(
                false,
                false,
                false
            )
            .getRecordById(queueItem.RecordId__c);
        if (credentialToProcess.UrjanetId__c == null) {
            Logger.getInstance()
                .log(
                    UtilityCredentialProcessor.class.getName(),
                    Logger.Level.WARN,
                    'Unable to Process Credential as ArcadiaId is null : ' + queueItem.RecordId__c
                );
            return queueItem;
        }

        // Get Account data from urjanet
        String pageSize = UrjanetUtils.getAPIPageSize();
        String pageNumber = (queueItem.PageNumber__c == null
            ? '0'
            : String.valueOf(Integer.valueOf(queueItem.PageNumber__c)));

        List<String> requestParams = new List<String>{ credentialToProcess.UrjanetId__c, pageSize, pageNumber };

        if (
            queueItem.RequestType__c == null ||
            queueItem.RequestType__c == UrjanetEnums.RequestType.ACCOUNTS_BY_CREDS.name()
        ) {
            GetAccountsByCredsResponse response = (GetAccountsByCredsResponse) new UrjanetApiClient()
                .getUrjanetResponse(
                    UrjanetEnums.RequestType.ACCOUNTS_BY_CREDS,
                    UrjanetEnums.ApiMethod.GET,
                    requestParams
                );
            if (response.errorMsg != null) {
                UrjanetUtils.handleApiError(
                    queueItem,
                    response.errorMsg,
                    response.message,
                    response.status,
                    UtilityCredentialProcessor.class.getName()
                );
            } else {
                // write UtilityAccount__c records
                UtilityAccountService.createAccountFromDataResponse(response, credentialToProcess);
                //check if needed for pagination to create queue items for the other pages
                UrjanetUtils.createPaginationQueueItemFromAPIResponse(
                    response.page,
                    credentialToProcess.Id,
                    UrjanetEnums.RequestType.ACCOUNTS_BY_CREDS.name(),
                    QueueItemProcessorFactory.getProcessorType(UtilityCredential__c.SObjectType)
                );
            }
        }

        return queueItem;
    }
}