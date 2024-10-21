public with sharing class UtilityCredentialSyncBatchController {
    @AuraEnabled
    public static void executeBatchJob(Boolean isTesting) {
        AccessToken__c accessToken = Urjanetutils.checkAndUpdateAccessToken();

        if (null != accessToken) {
            try {
                Integer batchSize = isTesting ? UrjanetUtils.getBatchSize(true) : UrjanetUtils.getBatchSize(false);
                Logger.getInstance()
                    .log(UtilityCredentialSyncBatchController.class.getName(), Logger.Level.INFO, 'Sync Started');
                UrjanetUtils.upsertLastSuccessfulSyncDate();
                UrjanetUtils.updateMeasuredUsageInText();

                Database.executeBatch(new UtilityCredentialSyncBatch(), batchSize);

                //batch for accounts with no credentials
                Database.executeBatch(new UtilityAccountSyncBatch(), batchSize);

                //batch for files
                Database.executeBatch(new UtilityStatementFileSyncBatch(), batchSize);

                Database.executeBatch(new UtilityMeterSyncBatch(), batchSize);

                //For Processing Credential Deletion Logs
                Database.executeBatch(new CredentialDeletionJobBatch(), batchSize);

                Database.executeBatch(new UtilityMeterAndUsageUpdateBatch(), batchSize);
            } catch (Exception e) {
                AuraHandledException ahe = new AuraHandledException(e.getMessage());
                ahe.setMessage(e.getMessage());
                throw ahe;
            }
        }
    }

    @AuraEnabled
    public static void pushSitesToUrjanet() {
        try {
            StationaryAssetSourceService.createQueueItemsToSendStationaryAssetSource();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean isBatchExecutionCompleted(Boolean isTesting) {
        Boolean batchCompleted = false;
        String query = 'SELECT COUNT() FROM AsyncApexJob WHERE JobType = \'BatchApex\' AND Status IN (\'Queued\', \'Preparing\', \'Processing\')';
        
        if (!isTesting) {
            query += ' AND ApexClass.NameSpacePrefix= \'urjanet\'';
        }
        Integer enqueuedJobs = Database.countQuery(query);

        Integer queueItems = [
            SELECT COUNT()
            FROM QueueItem__c
            WHERE ErrorCount__c = NULL
        ];
        if (enqueuedJobs > 0) {
            Logger.getInstance()
                .log(
                    UtilityCredentialSyncBatchController.class.getName(),
                    Logger.Level.WARN,
                    'Jobs execution is not completed'
                );
        } else if (queueItems > 0) {
            Logger.getInstance()
                .log(
                    UtilityCredentialSyncBatchController.class.getName(),
                    Logger.Level.WARN,
                    'Queue items processing is not completed'
                );
        } else {
            batchCompleted = true;
            Logger.getInstance()
                .log(
                    UtilityCredentialSyncBatchController.class.getName(),
                    Logger.Level.DEBUG,
                    'No pending jobs to be completed'
                );
        }
        return batchCompleted;
    }
}