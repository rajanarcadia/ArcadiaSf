global with sharing class UtilityBatchSyncScheduler implements Schedulable {
    private static final Integer DEFAULT_INTERVAL = 1;
    private static final String JOB_NAME = 'Batch Sync Scheduler';

    public UtilityBatchSyncScheduler() {
    }

    /**
     * Default method to schedule sync to run based on default interval
     * @return Job ID
     */
    global static String scheduleJob() {
        abortDefaultScheduledJob();
        return scheduleJob(JOB_NAME, UrjanetUtils.getSchedulerExpression(DateTime.Now().addMinutes(DEFAULT_INTERVAL)));
    }

    /**
     * Overload method to allow subscribers to schedule job based in own cron expression
     * @param jobName - Name of scheduled job
     * @param cron - Cron expression
     *
     * @return Job ID
     */
    global static String scheduleJob(String jobName, String cron) {
        return System.schedule(jobName, cron, new UtilityBatchSyncScheduler());
    }
    /**
     * Schedulable implementation
     * @param sc
     */
    public void execute(SchedulableContext sc) {
        AccessToken__c accessTokenSetting = AccessToken__c.getInstance(UserInfo.getProfileId());
        if (
            null != accessTokenSetting &&
            null != accessTokenSetting.Token1__c &&
            null != accessTokenSetting.ExpirationTime__c &&
            accessTokenSetting.ExpirationTime__c > DateTime.now()
        ) {
            Integer batchSize = UrjanetUtils.getBatchSize(false);
            Logger.getInstance()
                .log(UtilityBatchSyncScheduler.class.getName(), Logger.Level.INFO, 'Sync Started from Scheduler');

            UrjanetUtils.upsertLastSuccessfulSyncDate();
            Database.executeBatch(new UtilityCredentialSyncBatch(), batchSize);

            //batch for accounts with no credentials
            Database.executeBatch(new UtilityAccountSyncBatch(), batchSize);

            //batch for files
            Database.executeBatch(new UtilityStatementFileSyncBatch(), batchSize);

            Database.executeBatch(new UtilityMeterSyncBatch(), batchSize);

            //For Processing Credential Deletion Logs
            Database.executeBatch(new CredentialDeletionJobBatch(), batchSize);

            Database.executeBatch(new UtilityMeterAndUsageUpdateBatch(), batchSize);
        } else {
            Logger.getInstance()
                .log(
                    UtilityBatchSyncScheduler.class.getName(),
                    Logger.Level.ERROR,
                    'Sync Failed to Start from Scheduler'
                );
        }
    }

    /**
     * Gets the default scheduled job
     * @return
     */
    private static List<CronTrigger> getDefaultScheduledJob() {
        //CRUD/FLS is ignored since permissions cannot be applied to CRON TRIGGER object
        return Data.read(
            'Select Id, CronJobDetail.Name, NextFireTime, PreviousFireTime From CronTrigger Where CronJobDetail.Name LIKE \'%' +
                JOB_NAME +
                '%\'',
            null,
            false,
            false,
            false
        );
    }

    /**
     * Aborts the default scheduled job
     */
    private static void abortDefaultScheduledJob() {
        abortJobs(getDefaultScheduledJob());
    }

    /**
     * Aborts scheduled apex jobs.
     * @param cronRecs - jobs to abort
     */
    private static void abortJobs(List<CronTrigger> cronRecs) {
        for (CronTrigger cron : cronRecs) {
            System.abortJob(cron.id);
        }
    }

    global void finish(Database.BatchableContext BC) {
        // Get the ID of the AsyncApexJob representing this batch job from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [SELECT Id FROM AsyncApexJob WHERE Id = :BC.getJobId()];

        //then use the active job id and abort it
        system.abortJob(a.id);
    }
}