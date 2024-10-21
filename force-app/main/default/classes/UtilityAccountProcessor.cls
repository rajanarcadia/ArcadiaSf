public with sharing class UtilityAccountProcessor extends QueueItemWorkerBase {
    public override QueueItem__c process(QueueItem__c queueItem) {
        // Ignoring security here since this is a system process
        UtilityAccount__c accountToProcess = (UtilityAccount__c) new UtilityAccountSelector(false, false, false)
            .getRecordById(queueItem.RecordId__c);

        if (accountToProcess == null) {
            Logger.getInstance()
                .log(
                    UtilityAccountProcessor.class.getName(),
                    Logger.Level.WARN,
                    'Unable to Process Account as the record is null : ' + queueItem.RecordId__c
                );
            return queueItem;
        }

        if (accountToProcess.UrjanetId__c == null) {
            Logger.getInstance()
                .log(
                    UtilityAccountProcessor.class.getName(),
                    Logger.Level.WARN,
                    'Unable to Process Account as ArcadiaId is null : ' + queueItem.RecordId__c
                );
            return queueItem;
        }

        String pageSize = UrjanetUtils.getAPIPageSize();
        String pageNumber = (queueItem.PageNumber__c == null
            ? '0'
            : String.valueOf(Integer.valueOf(queueItem.PageNumber__c)));

        Datetime previousLastSyncDate = null;
        LastSuccessfulSyncDate__c lastSuccessfulSyncDate = LastSuccessfulSyncDate__c.getInstance(
            UserInfo.getProfileId()
        );
        if (lastSuccessfulSyncDate != null) {
            previousLastSyncDate = lastSuccessfulSyncDate.PreviousLastSyncDate__c != null
                ? lastSuccessfulSyncDate.PreviousLastSyncDate__c
                : Datetime.newInstance(1990, 1, 1);
        } else {
            previousLastSyncDate = Datetime.newInstance(1990, 1, 1);
            lastSuccessfulSyncDate.PreviousLastSyncDate__c = previousLastSyncDate;
            lastSuccessfulSyncDate.LastSyncDate__c = Datetime.now();
            upsert lastSuccessfulSyncDate;
        }

        List<String> requestParams = new List<String>{
            accountToProcess.UrjanetId__c,
            pageSize,
            pageNumber,
            String.valueOf(previousLastSyncDate.format('yyyy-MM-dd\'T\'HH:mm:ss'))
        };

        ////////Start Finish all the API callout first///////////
        GetMetersByAccountResponse meterResponse;

        if (
            queueItem.RequestType__c == null ||
            queueItem.RequestType__c == UrjanetEnums.RequestType.METERS_BY_ACCOUNT.name()
        ) {
            // Get Meters data from urjanet
            meterResponse = (GetMetersByAccountResponse) new UrjanetApiClient()
                .getUrjanetResponse(
                    UrjanetEnums.RequestType.METERS_BY_ACCOUNT,
                    UrjanetEnums.ApiMethod.GET,
                    requestParams
                );
        }
        ////////End Finish all the API callout first///////////

        if (meterResponse != null) {
            if (meterResponse.errorMsg != null) {
                UrjanetUtils.handleApiError(
                    queueItem,
                    meterResponse.errorMsg,
                    meterResponse.message,
                    meterResponse.status,
                    UtilityAccountProcessor.class.getName()
                );
            } else {
                // Meter records from Account Response
                List<UtilityMeter__c> metersByAccountList = UtilityMeterService.createMeterFromDataResponse(
                    meterResponse
                );

                if (metersByAccountList != null && !metersByAccountList.isEmpty()) {
                    //write All Meters List
                    UtilityMeterService.upsertMeterListForAccountProcessed(metersByAccountList, accountToProcess);

                    //check if needed for pagination to create queue items for the other pages
                    UrjanetUtils.createPaginationQueueItemFromAPIResponse(
                        meterResponse.page,
                        accountToProcess.Id,
                        UrjanetEnums.RequestType.METERS_BY_ACCOUNT.name(),
                        QueueItemProcessorFactory.getProcessorType(UtilityAccount__c.SObjectType)
                    );
                }
            }
        }

        return queueItem;
    }
}