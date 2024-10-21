public with sharing class UtilityStatementFileProcessor extends QueueItemWorkerBase {
    public override QueueItem__c process(QueueItem__c queueItem) {
        // Ignoring security here since this is a system process
        UtilityStatementFile__c utilityStatementFileToProcess = (UtilityStatementFile__c) new UtilityStatementFileSelector(
                false,
                false,
                false
            )
            .getRecordById(queueItem.RecordId__c);
        if (utilityStatementFileToProcess.StatementId__c == null) {
            Logger.getInstance()
                .log(
                    UtilityStatementFileProcessor.class.getName(),
                    Logger.Level.WARN,
                    'Unable to Process Utility Statement File as StatementId is null : ' + queueItem.RecordId__c
                );
            return queueItem;
        }

        // Get Account data from urjanet for the file statement
        List<String> requestParams = new List<String>{ utilityStatementFileToProcess.StatementId__c };
        GetAccountsByCredsResponse response = (GetAccountsByCredsResponse) new UrjanetApiClient()
            .getUrjanetResponse(
                UrjanetEnums.RequestType.ACCOUNTS_BY_STATEMENTIDS,
                UrjanetEnums.ApiMethod.GET,
                requestParams
            );
        if (response.errorMsg != null) {
            UrjanetUtils.handleApiError(
                queueItem,
                response.errorMsg,
                response.message,
                response.status,
                UtilityStatementFileProcessor.class.getName()
            );
        } else {
            // write UtilityAccount__c records
            UtilityAccountService.createAccountFromDataResponse(response, utilityStatementFileToProcess);
        }

        return queueItem;
    }
}